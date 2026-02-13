defmodule EcosenseWeb.ReadingController do
  use EcosenseWeb, :controller

  require Logger

  alias Ecosense.Sensors
  alias Ecosense.Sensors.Reading
  alias Ecosense.{Processing, InMemoryStore, Repo}

  action_fallback EcosenseWeb.FallbackController

  # GET /api/readings — igual que EcoSense: BD (raw) o fallback en memoria
  # Ruta: scope /api -> resources /readings (router.ex)
  def index(conn, _params) do
    readings =
      if repo_available?() do
        case fetch_from_db() do
          {:ok, rows} ->
            Logger.info("GET /api/readings: #{length(rows)} registros desde la base de datos")
            rows

          {:error, reason} ->
            Logger.warning("GET /api/readings: fallback a memoria. Error BD: #{inspect(reason)}")
            InMemoryStore.all()
        end
      else
        Logger.warning("GET /api/readings: Repo no disponible, usando memoria (vacía)")
        InMemoryStore.all()
      end

    json(conn, readings)
  end

  # POST /api/readings — acepta formato EcoSense (value, source) o actual (reading: temperature, humidity)
  def create(conn, %{"reading" => reading_params}) do
    handle_create(conn, reading_params)
  end

  def create(conn, params) do
    handle_create(conn, params["reading"] || params)
  end

  defp handle_create(conn, params) do
    # Formato Hostinger: sensor_id + value. O solo value (legacy).
    if Map.has_key?(params, "value") or Map.has_key?(params, :value) do
      handle_legacy_create(conn, params)
    else
      handle_ecto_create(conn, params)
    end
  end

  defp handle_legacy_create(conn, params) do
    with :ok <- Processing.validate(params) do
      transformed = Processing.transform(params)
      :ok = InMemoryStore.add(transformed)

      db_result =
        if repo_available?(), do: save_reading_to_db(transformed), else: {:ok, nil}

      alert_result = Processing.check_alert(transformed, %{min: 0, max: 50})

      payload =
        case db_result do
          {:ok, row} when is_map(row) ->
            normalize_row_for_json(row)

          {:error, _} ->
            Map.put(transformed, "warning", "saved_in_memory_only")

          _ ->
            transformed
        end

      payload = maybe_add_alert(payload, alert_result)

      conn
      |> put_status(:created)
      |> json(payload)
    else
      {:error, msg} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: msg})
    end
  end

  defp maybe_add_alert(payload, {:alert, reason}), do: Map.put(payload, "alert", to_string(reason))
  defp maybe_add_alert(payload, :ok), do: payload

  # Convierte atom keys a string y NaiveDateTime/DateTime a ISO8601 para que el JSON coincida con el formato del GET
  defp normalize_row_for_json(row) when is_map(row) do
    row
    |> Enum.map(fn
      {k, %NaiveDateTime{} = dt} -> {key_to_string(k), NaiveDateTime.to_iso8601(dt) <> "Z"}
      {k, %DateTime{} = dt} -> {key_to_string(k), DateTime.to_iso8601(dt)}
      {k, v} -> {key_to_string(k), v}
    end)
    |> Map.new()
  end

  defp key_to_string(k) when is_atom(k), do: to_string(k)
  defp key_to_string(k), do: k

  defp handle_ecto_create(conn, reading_params) do
    with {:ok, %Reading{} = reading} <- Sensors.create_reading(reading_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/readings/#{reading}")
      |> render(:show, reading: reading)
    end
  end

  def show(conn, %{"id" => id}) do
    reading = Sensors.get_reading!(id)
    render(conn, :show, reading: reading)
  end

  def update(conn, %{"id" => id, "reading" => reading_params}) do
    reading = Sensors.get_reading!(id)

    with {:ok, %Reading{} = reading} <- Sensors.update_reading(reading, reading_params) do
      render(conn, :show, reading: reading)
    end
  end

  # Soft delete: pone fecha en deleted_at (no borra el registro)
  def delete(conn, %{"id" => id}) do
    if repo_available?() do
      case soft_delete_in_db(id) do
        :ok ->
          conn
          |> put_status(:ok)
          |> json(%{message: "El registro se eliminó correctamente."})

        :not_found ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "reading not found or already deleted"})
      end
    else
      conn
      |> put_status(:service_unavailable)
      |> json(%{error: "database not available"})
    end
  end

  defp repo_available? do
    case Process.whereis(Ecosense.Repo) do
      nil -> false
      _pid -> true
    end
  end

  defp fetch_from_db do
    try do
      # Excluir registros con soft delete (deleted_at IS NULL)
      query = "SELECT * FROM readings WHERE deleted_at IS NULL ORDER BY id DESC LIMIT 100"

      case Repo.query(query) do
        {:ok, %MyXQL.Result{columns: cols, rows: rows}} ->
          mapped =
            Enum.map(rows, fn row ->
              cols
              |> Enum.zip(row)
              |> Map.new()
            end)

          {:ok, mapped}

        {:error, reason} ->
          Logger.error("Database error: #{inspect(reason)}")
          {:error, reason}
      end
    rescue
      e ->
        Logger.error("Exception fetching from DB: #{inspect(e)}")
        {:error, e}
    end
  end

  # Soft delete: UPDATE deleted_at = NOW() WHERE id = ? AND deleted_at IS NULL
  defp soft_delete_in_db(id_str) do
    try do
      id = String.to_integer(id_str)
      query = "UPDATE readings SET deleted_at = CURRENT_TIMESTAMP WHERE id = ? AND deleted_at IS NULL"
      case Repo.query(query, [id]) do
        {:ok, %MyXQL.Result{num_rows: 1}} ->
          Logger.info("Reading id=#{id} soft deleted")
          :ok

        {:ok, _} ->
          :not_found

        {:error, reason} ->
          Logger.error("Soft delete failed: #{inspect(reason)}")
          :not_found
      end
    rescue
      ArgumentError -> :not_found
      e ->
        Logger.error("Exception in soft delete: #{inspect(e)}")
        :not_found
    end
  end

  # Inserta en BD (Hostinger): sensor_id, source, timestamp, value. Devuelve el registro creado.
  defp save_reading_to_db(reading) do
    try do
      sensor_id = reading["sensor_id"] || reading[:sensor_id] || 1
      source = reading["source"] || reading[:source] || "esp32"
      timestamp = reading["timestamp"] || reading[:timestamp]
      value = reading["value"] || reading[:value]

      query = """
      INSERT INTO readings (`sensor_id`, `source`, `timestamp`, `value`) VALUES (?, ?, ?, ?)
      """

      case Repo.query(query, [sensor_id, source, timestamp, value]) do
        {:ok, _result} ->
          # Devolver el registro recién creado (mismo formato que GET)
          case Repo.query("SELECT * FROM readings WHERE id = LAST_INSERT_ID()") do
            {:ok, %MyXQL.Result{columns: cols, rows: [row]}} ->
              row_map = cols |> Enum.zip(row) |> Map.new()
              Logger.info("Reading saved to database, id=#{row_map[:id] || row_map["id"]}")
              {:ok, row_map}

            _ ->
              {:ok, nil}
          end

        {:error, reason} ->
          Logger.error("Failed to save reading to database: #{inspect(reason)}")
          {:error, reason}
      end
    rescue
      e ->
        Logger.error("Exception saving to DB: #{inspect(e)}")
        {:error, e}
    end
  end
end
