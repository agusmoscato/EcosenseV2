defmodule Ecosense.InMemoryStore do
  @moduledoc """
  Almacén en memoria para lecturas (fallback cuando la BD no está disponible).
  Replicado desde EcoSense.
  """

  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc "Devuelve todas las lecturas (orden cronológico inverso)."
  def all do
    Agent.get(__MODULE__, & &1)
  end

  @doc "Agrega una lectura (mapa) al store."
  def add(reading) when is_map(reading) do
    Agent.update(__MODULE__, fn list -> [reading | list] end)
    :ok
  end

  @doc "Limpia el store (útil para tests)."
  def clear do
    Agent.update(__MODULE__, fn _ -> [] end)
  end
end
