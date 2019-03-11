FROM chrisxf/php:5.6-fpm-alpine

WORKDIR /app

#
# Install PHP-Extensions
#

# Install dependencies
RUN apk update && apk add --no-cache \
        imagemagick \
        curl \
        zip \
        unzip \
    && apk add --no-cache --virtual .build-deps \
        libjpeg-turbo-dev \        
        libpng-dev \
        freetype-dev \
        curl-dev \
        libxml2-dev \
    # Install PHP-Core extensions
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) xml \
    && docker-php-ext-install -j$(nproc) json \
    && docker-php-ext-install -j$(nproc) mbstring \
    && docker-php-ext-install -j$(nproc) curl \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) soap \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) pdo \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) opcache \
    && apk del .build-deps \
    # Install PECL extensions
    && apk add --no-cache --virtual .pecl-deps \
        $PHPIZE_DEPS \
        imagemagick-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    # Cleanup
    && apk del .pecl-deps \
    && rm -rf /usr/src*

#
# Add base php.ini
#
COPY php.ini /usr/local/etc/php/conf.d/10-base.ini