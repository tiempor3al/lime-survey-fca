# ── Runtime image (no builder stage, no LimeSurvey files inside) ─────────────
FROM php:8.3-apache-bookworm

# Install runtime dependencies (including download tools)
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

# Apache on port 8080 (non-privileged) + fix permissions
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-enabled/000-default.conf \
    && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2

WORKDIR /var/www/html

# Create the two instances with correct ownership (so www-data can write)
RUN mkdir -p abierta distancia \
    && chown -R www-data:www-data /var/www/html

# LimeSurvey version (change here when you want to upgrade)
ENV LIMESURVEY_VERSION=6.16.13%2B260316

# Copy and make executable the entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www-data
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
# CMD is inherited from the official php:apache image → apache2-foreground