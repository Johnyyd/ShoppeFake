# ShoppeFake — End-to-End E-Commerce Simulation Lab

ShoppeFake is a modular, high-performance simulation architecture designed to test real-world mobile shopping flows, real-time OLAP data cubes, and self-healing backend pipelines without cloud vendor lock-in. 

Every tier of the stack—from the Flutter client and NGINX gateway to the FastAPI service layer, CubeJS analytical engine, and SQL Server database—is containerized and engineered to operate seamlessly across both local development environments and remote mobile hardware via zero-config tunneling.

---

## Architecture Glossary & Subsystem Tree

Every major responsibility in ShoppeFake resides in its own isolated subsystem. Navigation flows **downward** from this root guide; follow the directory links below for specific module implementations and internal documentation.

```
ShoppeFake/
├── [nginx]                       &rarr; Unified Reverse Proxy & Status Gateway (Port 80)
├── [backend]                     &rarr; REST API & Business Logic Layer (FastAPI / SQLAlchemy)
├── [cube]                        &rarr; Analytical OLAP Engine (CubeJS)
├── [database]                    &rarr; Canonical DDL Schemas & Data Seeding Scripts
├── [mobile]                      &rarr; Cross-Platform Client Application (Flutter / Dart)
└── [tunnel/tailscale_public_url] &rarr; Zero-Config Remote Mobile Tunneling (Tailscale Funnel)
```

### Subsystem Responsibilities

* **[nginx](file:///e:/GitHub/ShoppeFake/nginx)** — **Unified Gateway**: Acts as the single ingress point (`Port 80`) for all external and local requests. Serves a glassmorphic system status dashboard (`index.html`) while transparently routing `/api/` to the FastAPI backend, `/cube/` to the CubeJS engine, and `/docs` to interactive Swagger documentation. Eliminates CORS overhead and multi-port confusion when connecting mobile clients.
* **[backend](file:///e:/GitHub/ShoppeFake/backend)** — **Microservice Core**: Built with FastAPI, SQLAlchemy 2.0, and PyMSSQL. Handles user authentication, virtual product catalogs, and simulated checkout workflows. Features an automated self-healing database lifecycle: upon startup, if `ShoppeDB` is missing inside the SQL Server instance, the backend connects directly via the `master` database to provision and bootstrap the schema automatically.
* **[cube](file:///e:/GitHub/ShoppeFake/cube)** — **OLAP Analytics Bus**: Built with CubeJS. Connects to the SQL Server database to pre-aggregate high-volume transactional data (`virtual_orders`, `virtual_products`). Provides instant, low-latency multidimensional queries for executive dashboards and sales metrics.
* **[database](file:///e:/GitHub/ShoppeFake/database)** — **Schema Definitions**: Contains the authoritative SQL scripts (`init_db.sql`) defining entity relationships, primary/foreign key constraints, and seed records for testing.
* **[mobile](file:///e:/GitHub/ShoppeFake/mobile)** — **Cross-Platform Client**: Built with Flutter & Dart. Delivers a native mobile shopping experience with dynamic cart state management, product exploration, and configurable gateway endpoints that switch dynamically between local emulators and public remote funnels.
* **[tunnel/tailscale_public_url](file:///e:/GitHub/ShoppeFake/tunnel/tailscale_public_url)** — **Remote Hardware Bridge**: A containerized Tailscale Funnel stack (`tunnel-web`, `tunnel-app`, `tunnel-dashboard`, `tunnel-db`, `tunnel-api`) alongside cross-platform automation scripts (`start_tunnels.ps1`, `start_tunnels.sh`). Projects internal host ports out to secure, publicly accessible HTTPS URLs (`*.ts.net`) so physical mobile devices can interact with local development services from any network.

---

## Architectural Principles & Technical Discoveries

### 1. Self-Healing Database Bootstrap over Non-Root SQL Server
Unlike standard MySQL or PostgreSQL container images that automatically execute initialization scripts from `/docker-entrypoint-initdb.d`, Microsoft SQL Server 2022 on Linux (`mcr.microsoft.com/mssql/server:2022-latest`) executes under the unprivileged `mssql` account for security compliance and does not run mount-based init scripts out of the box.

To prevent connection failures (`Login failed for database ShoppeDB`), the backend initialization logic (`backend/app/database.py`) implements a **two-phase bootstrap contract**:
1. It connects to the global `master` database using administrative credentials (`sa`).
2. It runs idempotent DDL checks (`IF NOT EXISTS... CREATE DATABASE ShoppeDB`) before establishing the primary SQLAlchemy connection pool against the application schema.

### 2. Internal Port Isolation & Gateway Routing
CubeJS enforces port `4000` internally inside its container environment (`shoppe_cube`). To maintain a uniform host layout without modifying internal engine code, Docker Compose maps host port `2002` to container port `4000` (`2002:4000`). Meanwhile, the NGINX gateway bridges all services behind standard HTTP (`Port 80`), mapping:
* `http://localhost:80/api/` &rarr; `http://api:8000/`
* `http://localhost:80/docs` &rarr; `http://api:8000/docs`
* `http://localhost:80/cube/` &rarr; `http://cube:4000/`

### 3. PowerShell Encoding Safety & Clean Automation
Windows PowerShell 5.1's native script parser can misinterpret multi-byte UTF-8 sequences (such as emojis or accented characters without BOM) as syntax delimiters (`}`, `"`), leading to parser block failures when executing nested loops.

All automation utilities (`start_tunnels.ps1`) strictly adhere to safe ASCII status markers (`[OK]`, `[INFO]`, `[+]`) and utilize regular expression matching (`$serveStatus -match "https://[a-zA-Z0-9.-]+\.ts\.net"`) to extract exact HTTPS endpoints reliably across every OS version and terminal environment.

---

## Operational Guide & Lifecycle Maintenance

### 1. Starting Local Infrastructure
To build and launch the core database, backend microservice, analytical engine, and NGINX gateway:

```bash
docker compose up --build -d
```

* **System Status & Gateway Home**: Open `http://localhost:80/` in your browser.
* **Interactive API Documentation**: Open `http://localhost:80/docs` to test endpoints via Swagger UI.
* **CubeJS Dashboard**: Open `http://localhost:80/cube/` for analytical models.

### 2. Exposing Public URLs for Remote Mobile Testing
When testing on physical mobile hardware over Wi-Fi or LTE, use the zero-config Tailscale Funnel stack to generate secure public URLs without configuring router port forwarding:

1. **Start the Tunnel Containers**:
   ```bash
   cd tunnel/tailscale_public_url
   docker compose up -d
   cd ../..
   ```
2. **Execute Funnel Automation**:
   ```powershell
   # On Windows PowerShell:
   .\tunnel\tailscale_public_url\start_tunnels.ps1

   # On Git Bash / macOS / Linux:
   bash ./tunnel/tailscale_public_url/start_tunnels.sh
   ```
3. **Connect the Mobile App**:
   Copy the generated HTTPS URL for `tunnel-web` (e.g., `https://web.tailXXXXX.ts.net/api/`) or `tunnel-app` (`https://app.tailXXXXX.ts.net`) and paste it into the settings drawer inside the Flutter mobile application.

### 3. Code Maintenance & Blast Radius Guardrails
ShoppeFake integrates **GitNexus Code Intelligence** to maintain structural integrity across microservices. Before modifying shared contracts, models, or configurations, verify exact scope and dependencies using the local GitNexus CLI:

```bash
# Check blast radius before modifying any symbol or file
node .gitnexus/run.cjs impact <symbol_or_file> --repo ShoppeFake

# Verify affected execution flows before committing
node .gitnexus/run.cjs detect_changes --repo ShoppeFake
```
