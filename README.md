# lime-survey-fca

LimeSurvey Docker image configured for two instances (`abierta` and `distancia`) running on Apache with PHP 8.3.

## Building the Docker image

```bash
docker build -t lime-survey-fca .
```

To build with a specific LimeSurvey version:

```bash
docker build --build-arg LIMESURVEY_VERSION=6.5.2+240402 -t lime-survey-fca .
```

## Running with Docker Compose

Copy `.env.example` to `.env` and set your database password:

```bash
cp .env.example .env
```

Then start the services:

```bash
docker compose up -d
```

This starts:
- **MariaDB** on port `33061`
- **LimeSurvey** on port `8041` (accessible at `http://localhost:8041`)