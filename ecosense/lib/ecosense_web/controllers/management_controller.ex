defmodule EcosenseWeb.ManagementController do
  use EcosenseWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def nodes(conn, _params) do
    render(conn, :nodes)
  end

  def sensors(conn, _params) do
    render(conn, :sensors)
  end
end
