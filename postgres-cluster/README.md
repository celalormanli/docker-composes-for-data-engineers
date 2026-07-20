# PostgreSQL + pgAdmin

PostgreSQL 17 with pgAdmin and a fake e-commerce dataset seeded on first start.

## Services

| Service | Image | Host Port | Description |
|---|---|---|---|
| postgres | postgres:17 | 5432 | PostgreSQL server |
| pgadmin | dpage/pgadmin4 | 5050 | Web UI, server preconfigured |

## Usage

```bash
docker compose up -d
```

- pgAdmin: http://localhost:5050 — login `admin@admin.com` / `admin`. The server appears under the "Postgres Cluster" group; the database password is `admin`.
- From the host: `psql -h localhost -p 5432 -U admin -d shop`
- Database credentials: `admin` / `admin`, database `shop`

## Fake data

On first start the database seeds an e-commerce schema in the `shop` database:

| Table | Rows | Notes |
|---|---|---|
| customers | 2,000 | random names, emails, countries |
| products | 300 | random names, categories, prices |
| orders | 10,000 | random customer, status, date within last year |
| order_items | ~30,000 | 1-5 items per order |

## Tear down

```bash
docker compose down        # keep data
docker compose down -v     # also delete volumes (drops all data, reseeds on next start)
```
