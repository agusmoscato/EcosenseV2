# Prueba de conexión a la base de datos (Hostinger o local).
# Uso: $env:DATABASE_URL="mysql://user:pass@host/db"; mix run test_db_connection.exs
# O con .env en la carpeta del proyecto: mix run test_db_connection.exs

# Arrancar la app para que el Repo use la config (DATABASE_URL o .env)
Application.ensure_all_started(:ecosense)

alias Ecosense.Repo

IO.puts("Intentando conectar a la base de datos...")

result =
  try do
    case Repo.query("SELECT 1 AS ok") do
      {:ok, _} ->
        IO.puts("OK: Conexión correcta.")
        :ok

      {:error, reason} ->
        IO.puts("ERROR: #{inspect(reason)}")
        :error
    end
  rescue
    e ->
      IO.puts("ERROR: #{Exception.message(e)}")
      :error
  end

# Opcional: si existe la tabla readings, mostrar cuántas filas hay
if result == :ok do
  case Repo.query("SELECT COUNT(*) AS n FROM readings") do
    {:ok, %{rows: [[n]]}} ->
      IO.puts("Tabla 'readings': #{n} fila(s).")

    {:ok, _} ->
      :ok

    {:error, _} ->
      IO.puts("(La tabla 'readings' no existe o no se pudo consultar.)")
  end
end

System.halt(if result == :ok, do: 0, else: 1)
