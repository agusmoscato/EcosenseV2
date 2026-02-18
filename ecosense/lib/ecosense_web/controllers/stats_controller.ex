defmodule EcosenseWeb.StatsController do
  use EcosenseWeb, :controller

  require Logger
  alias Ecosense.Repo

  # GET /api/stats — devuelve conteos de nodos, sensores y readings (excluye soft-deleted)
  def index(conn, _params) do
    stats =
      if repo_available?() do
        %{
          nodes: count_from_db("nodes"),
          sensors: count_from_db("sensors"),
          readings: count_from_db("readings")
        }
      else
        %{nodes: 0, sensors: 0, readings: 0}
      end

    json(conn, stats)
  end

  defp repo_available?, do: Process.whereis(Ecosense.Repo) != nil

  defp count_from_db(table) do
    try do
      query = "SELECT COUNT(*) as cnt FROM #{table} WHERE deleted_at IS NULL"

      case Repo.query(query) do
        {:ok, %{rows: [[cnt]]}} when is_integer(cnt) -> cnt
        {:ok, %{rows: [[cnt]]}} when is_binary(cnt) -> String.to_integer(cnt)
        _ -> 0
      end
    rescue
      e ->
        Logger.error("StatsController count_from_db(#{table}) error: #{inspect(e)}")
        0
    end
  end
end
