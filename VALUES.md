# Alfalfa Helm Chart Configuration Values

This document describes all configurable parameters in the `values.yaml` file for the Alfalfa Helm chart.

## Table of Contents

- [Ingress Configuration](#ingress-configuration)
- [Service Configuration](#service-configuration)
- [MongoDB Configuration](#mongodb-configuration)
- [InfluxDB Configuration](#influxdb-configuration)
- [Redis Configuration](#redis-configuration)
- [MinIO Configuration](#minio-configuration)
- [Grafana Configuration](#grafana-configuration)
- [Web Service Configuration](#web-service-configuration)
- [Worker Configuration](#worker-configuration)
- [Historian Configuration](#historian-configuration)
- [Environment Variables](#environment-variables)
- [Common Configuration Patterns](#common-configuration-patterns)
- [Security Considerations](#security-considerations)
- [Resource Configuration Reference](#resource-configuration-reference)

---

## Ingress Configuration

Controls external access to Alfalfa services through Kubernetes ingress resources.

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `ingress.enabled` | Enable ingress resources | `true` | No |
| `ingress.className` | Ingress class name (assumes nginx-ingress) | `"nginx"` | No |
| `ingress.annotations` | Additional annotations for ingress resources | `{}` | No |
| `ingress.hosts.web.host` | Hostname for web interface | `alfalfa.example.com` | Yes |
| `ingress.hosts.web.paths[].path` | URL path for web service | `/` | No |
| `ingress.hosts.web.paths[].pathType` | Path matching type | `Prefix` | No |
| `ingress.hosts.grafana.host` | Hostname for Grafana dashboard | `grafana.example.com` | Yes |
| `ingress.hosts.minio.host` | Hostname for MinIO console | `minio.example.com` | Yes |
| `ingress.tls.enabled` | Enable TLS/SSL for ingresses | `false` | No |
| `ingress.tls.secretName` | Secret containing TLS certificates | `""` | No |

### Example Usage:
```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    web:
      host: "alfalfa.mycompany.com"
    grafana:
      host: "grafana.mycompany.com"
    minio:
      host: "minio.mycompany.com"
  tls:
    enabled: true
    secretName: "alfalfa-tls"
```

---

## Service Configuration

Configure connection details and authentication for both internal and external services. When internal services are enabled (e.g., `mongodb.enabled: true`), these values configure the internal service. When internal services are disabled, these values configure connections to external services.

### MongoDB Configuration

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `config.mongodb.connectionUrl` | Complete MongoDB connection URL | `""` | Overrides other connection settings when set |
| `config.mongodb.host` | MongoDB hostname | `""` | Auto-generated for internal service, required for external |
| `config.mongodb.port` | MongoDB port | `""` | Auto-generated for internal service, required for external |
| `config.mongodb.database` | Database name | `alfalfa` | Used by both internal and external services |
| `config.mongodb.auth.enabled` | Enable MongoDB authentication | `false` | Configures internal service or external connection |
| `config.mongodb.auth.username` | MongoDB username | `""` | Required if auth enabled |
| `config.mongodb.auth.password` | MongoDB password | `""` | Required if auth enabled |

### Redis Configuration

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `config.redis.connectionUrl` | Complete Redis connection URL | `""` | Overrides other connection settings when set |
| `config.redis.host` | Redis hostname | `""` | Auto-generated for internal service, required for external |
| `config.redis.port` | Redis port | `""` | Auto-generated for internal service, required for external |
| `config.redis.auth.enabled` | Enable Redis authentication | `false` | Configures internal service or external connection |
| `config.redis.auth.password` | Redis password | `""` | Required if auth enabled |
| `config.redis.jobQueueName` | Name for job queue | `"Alfalfa Job Queue"` | Used by both internal and external services |

### S3/MinIO Configuration

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `config.s3.host` | S3/MinIO hostname | `""` | Auto-generated for internal MinIO, required for external S3 |
| `config.s3.port` | S3/MinIO port | `""` | Auto-generated for internal MinIO, required for external S3 |
| `config.s3.bucket` | S3 bucket name | `""` | Auto-generated for internal MinIO, required for external S3 |
| `config.s3.region` | S3 region | `""` | Used by both internal and external services |
| `config.s3.externalUrl` | External URL for browser access | `""` | Used for presigned URLs (both internal/external) |
| `config.s3.secure` | Use SSL/TLS | `""` | Connection security setting |
| `config.s3.auth.accessKey` | S3 access key | `"user"` | Configures internal MinIO or external S3 credentials |
| `config.s3.auth.secretKey` | S3 secret key | `"changeme-minio-password"` | **Security sensitive** - should be changed |

### InfluxDB Configuration

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `config.influxdb.host` | InfluxDB hostname | `""` | Auto-generated for internal service, required for external |
| `config.influxdb.port` | InfluxDB port | `""` | Auto-generated for internal service, required for external |
| `config.influxdb.auth.username` | InfluxDB username | `""` | Configures internal service or external connection |
| `config.influxdb.auth.password` | InfluxDB password | `""` | Configures internal service or external connection |
| `config.influxdb.database` | InfluxDB database name | `"alfalfa"` | Used by both internal and external services |

### Grafana Configuration

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `config.grafana.auth.username` | Grafana admin username | `admin` | Configures internal Grafana admin user |
| `config.grafana.auth.password` | Grafana admin password | `"changeme-grafana-password"` | **Security sensitive** - should be changed |

---

## MongoDB Configuration

Controls the included MongoDB instance (when `mongodb.enabled: true`).

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `mongodb.enabled` | Deploy MongoDB instance | `true` | No |
| `mongodb.container.name` | Container name | `"mongodb"` | No |
| `mongodb.container.image` | MongoDB Docker image | `"mongo:7-jammy"` | No |
| `mongodb.container.ports.mongodb` | MongoDB port | `27017` | No |
| `mongodb.container.resources` | Kubernetes ResourceRequirements | See below | No |
| `mongodb.service.ports.mongodb` | Service port | `27017` | No |
| `mongodb.persistence.enabled` | Enable persistent storage | `true` | No |
| `mongodb.persistence.size` | Storage size | `10Gi` | No |
| `mongodb.persistence.storageClass` | Storage class | `""` | No |
| `mongodb.persistence.accessModes` | Access modes | `["ReadWriteOnce"]` | No |

### Example Usage:
```yaml
mongodb:
  enabled: true
  container:
    resources:
      requests:
        cpu: 0.5
        memory: "1Gi"
      limits:
        cpu: 1.0
        memory: "2Gi"
  persistence:
    size: 50Gi
    storageClass: "fast-ssd"
```

**Default Resources:**
```yaml
resources:
  requests:
    cpu: 0.25
    memory: "512Mi"
```

---

## InfluxDB Configuration

Controls the included InfluxDB instance (when `influxdb.enabled: true`).

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `influxdb.enabled` | Deploy InfluxDB instance | `true` | No |
| `influxdb.container.name` | Container name | `"influxdb"` | No |
| `influxdb.container.image` | InfluxDB Docker image | `"influxdb:1.8"` | No |
| `influxdb.container.ports.influxdb` | InfluxDB port | `8086` | No |
| `influxdb.container.resources` | Kubernetes ResourceRequirements | See below | No |
| `influxdb.service.ports.influxdb` | Service port | `8086` | No |
| `influxdb.persistence.enabled` | Enable persistent storage | `true` | No |
| `influxdb.persistence.size` | Storage size | `10Gi` | No |
| `influxdb.persistence.storageClass` | Storage class | `""` | No |
| `influxdb.persistence.accessModes` | Access modes | `["ReadWriteOnce"]` | No |

**Default Resources:**
```yaml
resources:
  requests:
    cpu: 0.1
    memory: "256Mi"
```

---

## Redis Configuration

Controls the included Redis instance (when `redis.enabled: true`).

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `redis.enabled` | Deploy Redis instance | `true` | No |
| `redis.container.name` | Container name | `"redis"` | No |
| `redis.container.image` | Redis Docker image | `"redis:7-alpine"` | No |
| `redis.container.ports.redis` | Redis port | `6379` | No |
| `redis.container.resources` | Kubernetes ResourceRequirements | See below | No |
| `redis.service.ports.redis` | Service port | `6379` | No |
| `redis.persistence.enabled` | Enable persistent storage | `true` | No |
| `redis.persistence.size` | Storage size | `8Gi` | No |
| `redis.persistence.storageClass` | Storage class | `""` | No |
| `redis.persistence.accessModes` | Access modes | `["ReadWriteOnce"]` | No |

**Default Resources:**
```yaml
resources:
  requests:
    cpu: 0.5
    memory: "256Mi"
```

---

## MinIO Configuration

Controls the included MinIO S3-compatible storage (when `minio.enabled: true`).

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `minio.enabled` | Deploy MinIO instance | `true` | No |
| `minio.container.name` | Container name | `"minio"` | No |
| `minio.container.image` | MinIO Docker image | `"minio/minio:RELEASE.2024-04-18T19-09-19Z"` | No |
| `minio.container.ports.api` | MinIO API port | `9000` | No |
| `minio.container.ports.console` | MinIO console port | `9001` | No |
| `minio.container.resources` | Kubernetes ResourceRequirements | See below | No |
| `minio.service.ports.api` | API service port | `9000` | No |
| `minio.service.ports.console` | Console service port | `9001` | No |
| `minio.defaultBuckets` | Default bucket to create | `"alfalfa"` | No |
| `minio.persistence.enabled` | Enable persistent storage | `true` | No |
| `minio.persistence.size` | Storage size | `10Gi` | No |
| `minio.persistence.storageClass` | Storage class | `""` | No |
| `minio.persistence.accessModes` | Access modes | `["ReadWriteOnce"]` | No |
| `minio.mc.image` | MinIO client image for setup | `"minio/mc:RELEASE.2024-04-18T16-45-29Z"` | No |

### Example Usage:
```yaml
minio:
  enabled: true
  defaultBuckets: "alfalfa,backups"
  container:
    resources:
      requests:
        cpu: 0.5
        memory: "1Gi"
      limits:
        cpu: 1.0
        memory: "2Gi"
  persistence:
    size: 100Gi
    storageClass: "standard"
```

**Default Resources:**
```yaml
resources:
  requests:
    cpu: 0.25
    memory: "512Mi"
```

---

## Grafana Configuration

Controls the included Grafana dashboard (when `grafana.enabled: true`).

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `grafana.enabled` | Deploy Grafana instance | `true` | No |
| `grafana.container.image` | Grafana Docker image | `"ghcr.io/nrel/alfalfa/grafana:migrate_pyenergyplus"` | No |
| `grafana.container.ports.http` | Grafana HTTP port | `3000` | No |
| `grafana.container.resources` | Kubernetes ResourceRequirements | See below | No |
| `grafana.service.ports.http` | Service port | `80` | No |
| `grafana.ingress.enabled` | Enable ingress for Grafana | `true` | No |
| `grafana.ingress.host` | Grafana ingress hostname | `grafana.example.com` | No |

**Default Resources:**
```yaml
resources:
  requests:
    cpu: 0.1
    memory: "128Mi"
```

---

## Web Service Configuration

Controls the Alfalfa web frontend service.

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `web.container.image` | Web service Docker image | `"ghcr.io/nrel/alfalfa/web:kubernetes_fixes"` | No |
| `web.container.ports.http` | Web service HTTP port | `80` | No |
| `web.container.resources` | Kubernetes ResourceRequirements | See below | No |
| `web.container.env.NODE_ENV` | Node.js environment | `"PRODUCTION"` | No |

**Default Resources:**
```yaml
resources:
  requests:
    cpu: 0.5
    memory: "256Mi"
```

### Example Usage:
```yaml
web:
  container:
    image: "ghcr.io/nrel/alfalfa/web:v1.2.3"
    env:
      NODE_ENV: "production"
    resources:
      requests:
        cpu: 1.0
        memory: "512Mi"
      limits:
        cpu: 2.0
        memory: "1Gi"
```

---

## Worker Configuration

Controls the Alfalfa worker processes that run simulations.

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `worker.replicas` | Number of worker replicas | `5` | No |
| `worker.container.image` | Worker Docker image | `"ghcr.io/nrel/alfalfa/worker:kubernetes_fixes"` | No |
| `worker.container.resources` | Kubernetes ResourceRequirements | See below | No |
| `worker.container.env.LOGLEVEL` | Worker logging level | `INFO` | Options: DEBUG, INFO, WARN, ERROR |

**Default Resources:**
```yaml
resources:
  requests:
    cpu: 0.5
    memory: "1Gi"
```

### Example Usage:
```yaml
worker:
  replicas: 10
  container:
    image: "ghcr.io/nrel/alfalfa/worker:v1.2.3"
    env:
      LOGLEVEL: DEBUG
    resources:
      requests:
        cpu: 1.0
        memory: "2Gi"
      limits:
        cpu: 2.0
        memory: "4Gi"
```

---

## Historian Configuration

Controls the historian service for data collection. This requires Grafana and Influxdb

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|--------|
| `historian.enabled` | Enable historian service | `true` | No |

---

## Common Configuration Patterns

### Scaling for Production
```yaml
worker:
  replicas: 20  # More workers for parallel processing

mongodb:
  container:
    resources:
      requests:
        cpu: 1.0
        memory: "2Gi"
  persistence:
    size: 100Gi
    storageClass: "fast-ssd"

minio:
  persistence:
    size: 500Gi
    storageClass: "standard"
```

### External Services Configuration
```yaml
# Disable all internal services
mongodb:
  enabled: false
redis:
  enabled: false
minio:
  enabled: false
influxdb:
  enabled: false

# Configure external connections
config:
  mongodb:
    connectionUrl: "mongodb://mongo.company.com:27017/alfalfa"
  redis:
    connectionUrl: "redis://redis.company.com:6379"
  s3:
    host: "s3.amazonaws.com"
    bucket: "company-alfalfa-bucket"
    region: "us-west-2"
    secure: true
    auth:
      accessKey: "AKIAIOSFODNN7EXAMPLE"
      secretKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

### Internal Services with Custom Configuration
```yaml
# Use internal services with custom passwords and settings
mongodb:
  enabled: true
redis:
  enabled: true
minio:
  enabled: true

config:
  mongodb:
    database: "alfalfa-prod"
    auth:
      enabled: true
      username: "alfalfa-user"
      password: "secure-mongo-password"
  redis:
    auth:
      enabled: true
      password: "secure-redis-password"
  s3:
    bucket: "alfalfa-production"
    region: "us-west-2"
    auth:
      accessKey: "alfalfa-minio-user"
      secretKey: "secure-minio-password"
  grafana:
    auth:
      username: "admin"
      password: "secure-grafana-password"
```

### Development Configuration
```yaml
worker:
  replicas: 2
  container:
    resources:
      requests:
        cpu: 0.1
        memory: "512Mi"

# Smaller storage for development
mongodb:
  persistence:
    size: 5Gi
minio:
  persistence:
    size: 10Gi
redis:
  persistence:
    size: 1Gi
influxdb:
  persistence:
    size: 5Gi
```

---

## Security Considerations

### Sensitive Values
The following values contain sensitive information and should be overridden:

- `config.s3.auth.secretKey`
- `config.grafana.auth.password`
- `config.mongodb.auth.password` (if authentication enabled)
- `config.redis.auth.password` (if authentication enabled)

### Recommended Approach
Use Helm secrets or external secret management:

```bash
helm install alfalfa ./alfalfa-chart \
  --set config.s3.auth.secretKey="$(kubectl get secret s3-creds -o jsonpath='{.data.secretKey}' | base64 -d)" \
  --set config.grafana.auth.password="$(kubectl get secret grafana-creds -o jsonpath='{.data.password}' | base64 -d)"
```

Or use a separate values file with restricted access:
```bash
helm install alfalfa ./alfalfa-chart -f values.yaml -f secrets.yaml
```

---

## Resource Configuration Reference

All container resource configurations follow the [Kubernetes Pod v1 resources specification](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#resources). This includes:

- **requests**: Minimum guaranteed resources (used for scheduling)
- **limits**: Maximum allowed resources (enforced at runtime)

**Example ResourceRequirements:**
```yaml
resources:
  requests:
    cpu: "500m"        # 0.5 CPU cores
    memory: "1Gi"      # 1 GiB of memory
  limits:
    cpu: "2"           # 2 CPU cores maximum
    memory: "4Gi"      # 4 GiB memory maximum
```

**CPU Formats:**
- `"1"` or `1000m` = 1 CPU core
- `"500m"` = 0.5 CPU cores
- `"100m"` = 0.1 CPU cores

**Memory Formats:**
- `"1Gi"` = 1 GiB (1024³ bytes)
- `"1G"` = 1 GB (1000³ bytes)
- `"512Mi"` = 512 MiB
