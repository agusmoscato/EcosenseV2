# 🌍 Ecosense - Sistema de Monitoreo Ambiental en Tiempo Real

**Versión 2.0** - Interfaz profesional para gestionar nodos y sensores con análisis en vivo.

## 🚀 Inicio Rápido

Para iniciar tu servidor Phoenix:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix mix phx.server`

Ahora puedes acceder a [`localhost:4000`](http://localhost:4000) desde tu navegador.

## 📍 Rutas Principales

| Ruta | Descripción |
|------|-------------|
| `/` | **Home** - Página de bienvenida con stats en vivo |
| `/manage` | **Panel Principal** - Centro de control con acceso a nodos/sensores |
| `/manage/nodes` | **Gestión de Nodos** - Crear, editar y eliminar nodos de monitoreo |
| `/manage/sensors` | **Gestión de Sensores** - Configurar sensores para cada nodo |
| `/dashboard` | **Dashboard** - Gráficos en tiempo real de los sensores |

## ✨ Nuevas Características v2.0

### 🎨 Interfaz Profesional
- Diseño moderno con Tailwind CSS + DaisyUI
- Gradientes y animaciones suaves
- Tema claro/oscuro automático
- Responsive en todos los dispositivos

### 📍 Gestión de Nodos
- Crear nodos con nombre, ubicación y estado
- Estados: En Línea (🟢), Fuera de Línea (🔴), Mantenimiento (🟡)
- Eliminar nodos (soft delete, sin perder datos)
- Visualizar cantidad de sensores por nodo

### 📡 Gestión de Sensores
- Crear múltiples tipos de sensores:
  - 🌡️ Temperatura
  - 💧 Humedad
  - 🌫️ CO₂
  - 💡 Luminosidad
  - 🔋 Presión
  - 🌱 Humedad del Suelo
  - 💨 Calidad del Aire
  - ⚙️ Personalizado
- Asociar sensores a nodos
- Configurar unidades de medida
- Añadir descripciones detalladas

### 📊 Dashboard en Tiempo Real
- Gráficos interactivos con Chart.js
- Colores específicos por tipo de sensor
- Actualización automática cada 5 segundos
- Información del nodo: estado y última actualización
- Selector de nodo con estado visual

## 📡 API Endpoints

### Nodos
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/nodes` | Lista todos los nodos |
| POST | `/api/nodes` | Crea un nuevo nodo |
| DELETE | `/api/nodes/:id` | Elimina un nodo |

### Sensores
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/sensors` | Lista todos los sensores |
| POST | `/api/sensors` | Crea un nuevo sensor |
| DELETE | `/api/sensors/:id` | Elimina un sensor |

### Lecturas
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/readings` | Lista todas las lecturas |
| POST | `/api/readings` | Crea una nueva lectura |
| GET | `/api/dashboard?node_id=X` | Obtiene datos del dashboard para un nodo |

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
# Crear un nodo
Invoke-RestMethod -Uri "http://localhost:4000/api/nodes" -Method Post -Body '{"name": "Invernadero Principal", "location": "Piso 2", "status": "online"}' -ContentType "application/json"

# Crear un sensor (asociado a nodo_id 1)
Invoke-RestMethod -Uri "http://localhost:4000/api/sensors" -Method Post -Body '{"type": "temperature", "node_id": 1, "unit": "°C", "description": "Temperatura ambiente"}' -ContentType "application/json"

# Crear una lectura
Invoke-RestMethod -Uri "http://localhost:4000/api/readings" -Method Post -Body '{"sensor_id": 1, "value": 25.5}' -ContentType "application/json"

# Listar nodos
Invoke-RestMethod -Uri "http://localhost:4000/api/nodes"

# Listar sensores
Invoke-RestMethod -Uri "http://localhost:4000/api/sensors"

# Obtener dashboard de un nodo específico
Invoke-RestMethod -Uri "http://localhost:4000/api/dashboard?node_id=1"
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
