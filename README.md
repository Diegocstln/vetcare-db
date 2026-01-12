
Base de datos PostgreSQL del sistema VetCare (Docker + SQL)
# VetCare Database

Base de datos PostgreSQL del sistema **VetCare**, desplegada con **Docker** y definida mediante **scripts SQL**.  
Este repositorio permite que cualquier integrante del equipo pueda levantar la base de datos localmente de forma reproducible.

---

## 📦 Contenido del repositorio

- `docker-compose.yml` → Configuración para levantar PostgreSQL con Docker  
- `schema.sql` → Esquema completo de la base de datos (tablas, llaves primarias y foráneas)  
- `README.md` → Documentación de uso

---

## 🛠️ Requisitos

- Docker Desktop  
  - Windows / macOS / Linux  
- No es necesario instalar PostgreSQL de forma local

---

## 🚀 Levantar la base de datos

Desde la carpeta del repositorio:

```bash
docker compose up -d
