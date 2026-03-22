# ── Stage 1: builder ──────────────────────────────────────────────────────────
# Downloads and extracts LimeSurvey so the runtime image stays lean
FROM debian:bookworm-slim AS builder

ARG LIMESURVEY_VERSION=6.16.13%2B260316

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /tmp/limesurvey.zip \
        "https://download.limesurvey.org/latest-master/limesurvey${LIMESURVEY_VERSION}.zip" \
    && unzip -q /tmp/limesurvey.zip -d /tmp \
    && rm /tmp/limesurvey.zip

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
FROM php:8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libc-client-dev \
        libkrb5-dev \
        libpng-dev \
        libzip-dev \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j"$(nproc)" gd pdo pdo_mysql zip intl ldap imap

RUN a2enmod rewrite

WORKDIR /var/www/html

# Copy LimeSurvey into both survey instances
COPY --from=builder --chown=www-data:www-data /tmp/limesurvey ./abierta
COPY --from=builder --chown=www-data:www-data /tmp/limesurvey ./distancia

EXPOSE 80
