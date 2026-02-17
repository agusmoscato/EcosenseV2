defmodule EcosenseWeb.SessionController do
  use EcosenseWeb, :controller

  @hardcoded_user "admin"
  @hardcoded_password "Declarativa2025!"

  def new(conn, _params) do
    conn
    |> put_view(html: EcosenseWeb.SessionHTML)
    |> put_layout(html: {EcosenseWeb.Layouts, :login})
    |> render(:new)
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    if username == @hardcoded_user and password == @hardcoded_password do
      conn
      |> put_session(:current_user, %{username: username})
      |> put_flash(:info, "Bienvenido a Ecosense")
      |> redirect(to: ~p"/")
    else
      conn
      |> put_flash(:error, "Usuario o contraseña incorrectos")
      |> put_view(html: EcosenseWeb.SessionHTML)
      |> render(:new, layout: {EcosenseWeb.Layouts, :login})
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "Usuario y contraseña requeridos")
    |> redirect(to: ~p"/login")
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Sesión cerrada correctamente")
    |> redirect(to: ~p"/login")
  end
end
