# Kafka Cluster (KRaft)

Apache Kafka 4.3.1 running in KRaft mode — no ZooKeeper. Controller and broker run as separate containers.

## Services

| Service | Image | Host Port | Description |
|---|---|---|---|
| controller | apache/kafka:4.3.1 | — | KRaft controller (quorum of 1) |
| broker | apache/kafka:4.3.1 | 9092 | Kafka broker |
| connect | apache/kafka:4.3.1 | 8083 | Kafka Connect (distributed mode) |
| kafka-ui | ghcr.io/kafbat/kafka-ui | 8080 | Web UI for the cluster and Connect |

## Usage

```bash
docker compose up -d
```

- Kafka UI: http://localhost:8080
- Kafka Connect REST API: http://localhost:8083
- Bootstrap server from the host: `localhost:9092`
- Bootstrap server from inside the Docker network: `broker:19092`

## Kafka Connect plugins

Drop connector JARs (or extracted plugin directories) into the local `plugins/` folder — it is mounted as the Connect worker's `plugin.path`. Restart the connect container after adding plugins:

```bash
docker compose restart connect
```

## Tear down

```bash
docker compose down        # keep data
docker compose down -v     # also delete volumes (topics, offsets, connect state)
```
