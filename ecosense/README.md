# Ecosense

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Base de datos (solo Hostinger)

La app **solo** se conecta a la base de datos de Hostinger. No hay conexión local.

1. Copia `.env.example` a `.env` en la carpeta del proyecto (donde está `mix.exs`).
2. Pega en `.env` tu **DATABASE_URL** de Hostinger: `mysql://usuario:password@host/nombre_bd`
3. Arranca desde esa carpeta: `mix phx.server`

Sin `DATABASE_URL` (en `.env` o como variable de entorno) la app no arranca. **No subas `.env`** (está en `.gitignore`).

## Probar endpoints

Con el servidor en marcha (`mix phx.server`):

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | http://localhost:4000/api/readings | Lista lecturas (desde BD o memoria) |
| POST | http://localhost:4000/api/readings | Crea una lectura |

**En el navegador:** abre `http://localhost:4000/api/readings` para ver el listado en JSON.

**En PowerShell (otra terminal):**

```powershell
# GET — listar lecturas
Invoke-RestMethod -Uri "http://localhost:4000/api/readings"

# POST — crear lectura (formato Hostinger: sensor_id 1-9, value, source opcional)
Invoke-RestMethod -Uri "http://localhost:4000/api/readings" -Method Post -Body '{"sensor_id": 1, "value": 40.70, "source": "esp32"}' -ContentType "application/json"

# POST — solo value (source por defecto "esp32")
Invoke-RestMethod -Uri "http://localhost:4000/api/readings" -Method Post -Body '{"sensor_id": 2, "value": 25.5}' -ContentType "application/json"
```

**Probar conexión a la BD sin levantar el servidor:**  
`mix run test_db_connection.exs` (con `DATABASE_URL` en el entorno o en `.env`).

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
