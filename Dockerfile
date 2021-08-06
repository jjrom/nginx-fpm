FROM jjrom/s6-overlay:focal-1.0.0
LABEL maintainer="jerome.gasperi@gmail.com"

# Set environment variables
# opcache https://www.scalingphpbook.com/best-zend-opcache-settings-tuning-config/
ENV PHP_VERSION=8.0 \
    PHP_FPM_PM=dynamic \
    PHP_FPM_MAX_CHILDREN=100 \
    PHP_FPM_START_SERVERS=10 \
    PHP_FPM_MAX_REQUESTS=1024 \
    PHP_FPM_MIN_SPARE_SERVERS=3 \
    PHP_FPM_MAX_SPARE_SERVERS=19 \
    PHP_FPM_MEMORY_LIMIT=256M \
    PHP_FPM_MAX_EXECUTION_TIME=300 \
    PHP_FPM_MAX_INPUT_TIME=60 \
    PHP_FPM_UPLOAD_MAX_FILESIZE=20M \
    PHP_OPCACHE_MEMORY_CONSUMPTION=512 \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER=64 \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE=5 \
    PHP_OPCACHE_JIT_BUFFER_SIZE=100M \
    PHP_OPCACHE_JIT=1255 \
    PHP_FPM_EMERGENCY_RESTART_TRESHOLD=10 \
    PHP_FPM_EMERGENCY_RESTART_INTERVAL=1m \
    PHP_FPM_PROCESS_CONTROL_TIMEOUT=10s

# Add ppa, curl and syslogd
RUN apt-get update && apt-get install -y software-properties-common curl inetutils-syslogd && \
    apt-add-repository ppa:nginx/stable -y && \
    apt-add-repository ppa:ondrej/php -y && \
    #LC_ALL=C.UTF-8 apt-add-repository ppa:ondrej/php -y && \
    apt-get update && apt-get install -y \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-intl \
    # JSON is embeded in PHP 8+
    #php${PHP_VERSION}-json \
    php${PHP_VERSION}-pgsql \
    php-geos \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-mysql \
    # gettext is embeded in PHP 8+
    #php-gettext \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-mbstring \
    #php-ast \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-sqlite3 \
    #php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-xdebug \
    zip \
    unzip \
    gettext-base \
    nginx && \
    phpenmod xdebug && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/php && chmod -R 755 /run/php

# Copy NGINX service script
COPY ./start-nginx.sh /etc/services.d/nginx/run
RUN chmod 755 /etc/services.d/nginx/run

# Copy PHP-FPM service script
COPY ./start-fpm.sh /etc/services.d/php_fpm/run
RUN chmod 755 /etc/services.d/php_fpm/run
