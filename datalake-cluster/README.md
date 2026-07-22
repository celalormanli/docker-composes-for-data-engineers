# Datalake Cluster — MinIO + MySQL + Hive 4 + Iceberg

A minimal open-source datalake: MinIO as S3 object storage, MySQL backing the Hive Metastore, and HiveServer2 as the SQL engine. Hive 4.1 bundles Apache Iceberg natively, so Iceberg tables work out of the box — no Spark required.

## Services

| Service | Image | Host Port | Description |
|---|---|---|---|
| minio | minio/minio | 9000 / 9001 | S3 API / web console |
| minio-init | minio/mc | — | one-shot: creates the `warehouse` bucket |
| mysql | mysql:9 | 3306 | Hive Metastore backend DB |
| hive-metastore | apache/hive:4.1.0 (+ S3A & MySQL jars) | 9083 | Hive Metastore (thrift) |
| hiveserver2 | apache/hive:4.1.0 (+ S3A & MySQL jars) | 10000 / 10002 | JDBC endpoint / web UI |

The Hive image is built locally from [hive/Dockerfile](hive/Dockerfile), which downloads MySQL Connector/J and links the `hadoop-aws` + AWS SDK bundle jars (already shipped inside the image, version-matched to its Hadoop 3.4.1) onto Hive's classpath.

## Usage

```bash
docker compose up -d --build
```

First start takes a couple of minutes while the metastore initializes its schema in MySQL.

- MinIO console: http://localhost:9001 — login `minioadmin` / `minioadmin`
- HiveServer2 web UI: http://localhost:10002
- Beeline from inside the cluster:

```bash
docker exec -it hiveserver2 beeline -u jdbc:hive2://localhost:10000
```

## Iceberg quickstart

```sql
CREATE DATABASE lake;

CREATE TABLE lake.events (
  id BIGINT,
  name STRING,
  ts TIMESTAMP
) STORED BY ICEBERG;

INSERT INTO lake.events VALUES (1, 'signup', current_timestamp());
SELECT * FROM lake.events;

-- Iceberg metadata tables
SELECT * FROM lake.events.snapshots;
SELECT * FROM lake.events.files;
```

Table data and Iceberg metadata land in MinIO under `s3a://warehouse/` — browse it in the MinIO console.

## Notes

- Warehouse locations: managed tables → `s3a://warehouse/managed`, external tables → `s3a://warehouse/external` (see [conf/hive-site.xml](conf/hive-site.xml)).
- Metastore DB credentials: `hive` / `hive`, database `metastore` (root password `root`).
- The MinIO credentials are passed to the Hive containers both in [conf/hive-site.xml](conf/hive-site.xml) and as `AWS_*` env vars — the env vars are required because Hive hides `fs.s3a.access.key`/`fs.s3a.secret.key` from configs it ships to Tez tasks, so writes would otherwise fail with `NoAuthWithAWSException`.
- Any engine that speaks the Hive Metastore thrift protocol (Spark, Trino, Flink) can attach to `thrift://localhost:9083` and read the same Iceberg tables.

## Tear down

```bash
docker compose down        # keep data
docker compose down -v     # also delete volumes (drops all buckets, tables and metadata)
```
