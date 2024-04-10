# Use PHP with Apache as the base image
FROM php:8.3-apache

# Install system dependencies for LimeSurvey and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
	libzip-dev \
	zip \
	libicu-dev \
    libfreetype6-dev \
    mariadb-client \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-configure intl \
    && docker-php-ext-install gd pdo pdo_mysql zip intl

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set the working directory to the root of the Apache directory
WORKDIR /var/www/html


ARG LIMESURVEY_VERSION=6.5.2+240402

# Download LimeSurvey
ADD https://download.limesurvey.org/latest-master/limesurvey$LIMESURVEY_VERSION.zip /tmp/limesurvey.zip

# Unzip LimeSurvey and remove the downloaded zip file
RUN mkdir /var/www/html/abierta \
	&& mkdir /var/www/html/distancia

# Copy LimeSurvey to /var/www/html for abierta and distancia
RUN unzip /tmp/limesurvey.zip -d /tmp \
	&& cp -a /tmp/limesurvey/. /var/www/html/abierta \
	&& cp -a /tmp/limesurvey/. /var/www/html/distancia \
    && rm /tmp/limesurvey.zip \
    && chown -R www-data:www-data /var/www/html

RUN apache2ctl graceful

# Expose port 80
EXPOSE 80