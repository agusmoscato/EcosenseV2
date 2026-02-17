defmodule EcosenseWeb.AuthPlug do
  @moduledoc """
  Plug para autenticación por sesión.
  Redirige a /login si no hay usuario logueado.
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      user = get_session(conn, :current_user)

      if user do
        assign(conn, :current_user, user)
      else
        conn
        |> put_flash(:error, "Debes iniciar sesión para continuar")
        |> redirect(to: "/login")
        |> halt()
      end
    end
  end
end
