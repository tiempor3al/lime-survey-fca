# lime-survey-fca

LimeSurvey Docker image configured for two instances (`abierta` and `distancia`) running on Apache with PHP 8.3.

## Local development

### 1. Build the image

```bash
docker build -t lime-survey-fca:local .
```

To build with a specific LimeSurvey version:

```bash
docker build --build-arg LIMESURVEY_VERSION=6.5.2+240402 -t lime-survey-fca:local .
```

### 2. Point Docker Compose at the local image

Edit `docker-compose.yml` and replace the `image` value for the `lime` service:

```yaml
lime:
  image: lime-survey-fca:local   # ← local build instead of Docker Hub
```

### 3. Configure environment

Copy `.env.example` to `.env` and set your database password:

```bash
cp .env.example .env
```

### 4. Start the stack

```bash
docker compose up -d
```

This starts:
- **MariaDB** on port `33061`
- **LimeSurvey** on port `8041` (accessible at `http://localhost:8041`)

### 5. Create MariaDB databases for both instances

The image contains two LimeSurvey folders:
- `/var/www/html/abierta`
- `/var/www/html/distancia`

Create one database per instance before running each web installer:

```bash
docker compose exec db mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS limesurvey_abierta CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE DATABASE IF NOT EXISTS limesurvey_distancia CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

Optional: create dedicated users (recommended):

```bash
docker compose exec db mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS 'lime_abierta'@'%' IDENTIFIED BY 'change_this_password'; CREATE USER IF NOT EXISTS 'lime_distancia'@'%' IDENTIFIED BY 'change_this_password'; GRANT ALL PRIVILEGES ON limesurvey_abierta.* TO 'lime_abierta'@'%'; GRANT ALL PRIVILEGES ON limesurvey_distancia.* TO 'lime_distancia'@'%'; FLUSH PRIVILEGES;"
```

Equivalent SQL script (inside MariaDB):

```MariaDB
CREATE DATABASE IF NOT EXISTS limesurvey_abierta
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS limesurvey_distancia
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'lime_abierta'@'%'
  IDENTIFIED BY 'change_this_password';

CREATE USER IF NOT EXISTS 'lime_distancia'@'%'
  IDENTIFIED BY 'change_this_password';

GRANT ALL PRIVILEGES ON limesurvey_abierta.* TO 'lime_abierta'@'%';
GRANT ALL PRIVILEGES ON limesurvey_distancia.* TO 'lime_distancia'@'%';

FLUSH PRIVILEGES;
```

During installation, use:
- **Abierta** (`http://localhost:8041/abierta`): database `limesurvey_abierta`
- **Distancia** (`http://localhost:8041/distancia`): database `limesurvey_distancia`
- DB host: `db`
- DB port: `3306`

### 6. Check logs

```bash
# All services
docker compose logs -f

# LimeSurvey only
docker compose logs -f lime
```

### 7. Tear down

```bash
docker compose down          # stop and remove containers
docker compose down -v       # also delete volumes (resets the database)
```
