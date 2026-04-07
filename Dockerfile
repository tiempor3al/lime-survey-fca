# ── Runtime image (no LimeSurvey baked in) ───────────────────────────────────
FROM php:8.3-apache-bookworm

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        unzip \
        wget \
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

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j"$(nproc)" gd pdo pdo_mysql zip intl ldap imap

RUN a2enmod rewrite

# Apache configuration: run on port 8080 + suppress AH00558 warning
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-enabled/000-default.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2

WORKDIR /var/www/html

# Create directories for the two LimeSurvey instances
RUN mkdir -p abierta distancia \
    && chown -R www-data:www-data /var/www/html

# LimeSurvey version
ENV LIMESURVEY_VERSION=6.16.15%2B260330

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www-data
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]