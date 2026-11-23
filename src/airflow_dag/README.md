# Airflow ETL Project

## Folder structure

```
airflow_project/
├── .env                    ← environment variables (never commit to git)
├── docker-compose.yml      ← spins up Postgres + Airflow services
├── requirements.txt        ← extra pip packages (providers, pandas, etc.)
├── dags/
│   └── etl_pipeline.py     ← your DAG
├── logs/                   ← task logs (auto-created by Airflow)
├── plugins/                ← custom hooks/operators (usually empty)
└── config/                 ← airflow.cfg overrides (usually empty)
```

## Quick start

### 1. Prerequisites

- Docker Desktop (or Docker Engine + Compose plugin)
- Python 3.8+ (only needed if running locally without Docker)

### 2. First-time setup

```bash
# Clone or copy this folder, then:
cd airflow_project

# Add your user UID so mounted files have correct permissions
echo "AIRFLOW_UID=$(id -u)" >> .env

# Generate a Fernet key and paste it into .env
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# Initialize the DB and create the admin user (run once)
docker compose up airflow-init

# Start all services
docker compose up -d
```

### 3. Open the UI

Visit **http://localhost:8081**  
Login: `admin` / `admin` (change this in production)

### 4. Configure the Postgres connection

Go to **Admin → Connections → +**  
| Field | Value |
|---|---|
| Connection Id | `postgres_default` |
| Connection Type | `Postgres` |
| Host | your DB host |
| Schema | your DB name |
| Login | your DB user |
| Password | your DB password |
| Port | `5432` |

### 5. Trigger the DAG

Toggle the DAG on in the UI, or run:

```bash
docker compose exec scheduler airflow dags trigger etl_pipeline
```

---

## Why each import needs its package

| Import                         | Package                             |
| ------------------------------ | ----------------------------------- |
| `airflow.operators.python`     | `apache-airflow` (core)             |
| `airflow.operators.bash`       | `apache-airflow` (core)             |
| `airflow.operators.empty`      | `apache-airflow` (core, 2.3+)       |
| `airflow.utils.task_group`     | `apache-airflow` (core, 2.x)        |
| `airflow.providers.postgres.*` | `apache-airflow-providers-postgres` |

The providers are **not** bundled with the core image — they must be listed in `requirements.txt`.  
Docker installs them at container startup via `_PIP_ADDITIONAL_REQUIREMENTS` in `docker-compose.yml`.

---

## Common commands

```bash
# View logs
docker compose logs -f scheduler

# Restart a single service
docker compose restart webserver

# Stop everything
docker compose down

# Stop and delete DB volume (full reset)
docker compose down -v
```

## Running locally without Docker

```bash
pip install apache-airflow==2.9.3 \
  --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.9.3/constraints-3.11.txt"

pip install -r requirements.txt

export AIRFLOW_HOME=$(pwd)
airflow db migrate
airflow users create --username admin --password admin \
  --firstname A --lastname B --role Admin --email a@b.com
airflow webserver &
airflow scheduler
```
