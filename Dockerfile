ARG VERSION=5.6
ARG BASE_IMG_SUFFIX
ARG PROJECT

#FROM php:$VERSION-$TYPE-alpine
FROM php:$VERSION$BASE_IMG_SUFFIX-alpine as base

ARG TYPE=cli

WORKDIR /app

# Set composer ENV-Variables
ENV COMPOSER_HOME=/var/composer
ENV COMPOSER_MEMORY_LIMIT=4G

#
# Locale support
#
ENV MUSL_LOCPATH="/usr/share/i18n/locales/musl"

RUN apk update && apk add --no-cache \
        libintl \
    && apk add --no-cache --virtual .locale-deps \
        cmake \
		make \
		musl-dev \
		gcc \
		gettext-dev \
		git \
    && git clone https://gitlab.com/rilian-la-te/musl-locales \
    && cd musl-locales \
    && sed -e 's/de_DE/de_AT/g' musl-po/de_DE.po > musl-po/de_AT.po \
    && sed -e 's/de_DE/de_AT/g' po/de_DE.po > po/de_AT.po \
    && cmake -DLOCALE_PROFILE=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr . \
    && make \
    && make install \
    && cd .. \
    && rm -r musl-locales \
    && apk del .locale-deps

#
# Install base PHP-Extensions
#

# Install dependencies
RUN apk update && apk add --no-cache \
		libpng \
		libjpeg-turbo \
		freetype \
		icu \
        libzip \
        coreutils \
    && apk add --no-cache --virtual .build-deps \
        libjpeg-turbo-dev \
        libpng-dev \
        freetype-dev \
        libxml2-dev \
		zlib-dev \
        libzip-dev \
		icu-dev \
    # Install PHP-Core extensions
    && (docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ || docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/) \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) opcache \
    && apk del .build-deps

RUN if [ "$TYPE" = "cli" ]; then \
		apk add --no-cache \
			git \
			openssh-client \
		&& mkdir -p /var/composer \
		&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
		&& php composer-setup.php \
		&& php -r "unlink('composer-setup.php');" \
		&& cp composer.phar /usr/local/bin/composer \
		&& chown -R 82:82 /var/composer; \
	fi

#
# Add base php.ini
#
COPY php.ini /usr/local/etc/php/conf.d/10-base.ini


#
#
# Project Specific Stages
#
#

# Typo3
FROM base as typo3

RUN apk add --no-cache \
		imagemagick \
	&& apk add --no-cache --virtual .typo3-deps \
		$PHPIZE_DEPS \
		imagemagick-dev \
        libxml2-dev \
	&& docker-php-ext-install soap \
	&& docker-php-ext-install mysql \
	&& docker-php-ext-install mysqli \
	&& docker-php-ext-install pdo_mysql \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& apk del .typo3-deps

# Prestashop 1.5
FROM base as prestashop15

RUN apk add --no-cache \
        libmcrypt \
    && apk add --no-cache --virtual .prestashop15-deps \
		$PHPIZE_DEPS \
        libxml2-dev \
		libmcrypt-dev \
	&& docker-php-ext-install mysql \
	&& docker-php-ext-install mysqli \
	&& docker-php-ext-install pdo_mysql \
	&& docker-php-ext-install mcrypt \
	&& apk del .prestashop15-deps

# Cockpit
FROM base as cockpit

RUN apk add --no-cache \
		imagemagick \
	&& apk add --no-cache --virtual .cockpit-deps \
		$PHPIZE_DEPS \
		openssl-dev \
		imagemagick-dev \
	&& pecl install imagick \
	&& pecl install mongodb \
	&& docker-php-ext-enable imagick \
	&& docker-php-ext-enable mongodb \
	&& apk del .cockpit-deps

# Neos
FROM base as neos

RUN apk add --no-cache \
		libpq \
		imagemagick \
	&& apk add --no-cache --virtual .neos-deps \
		$PHPIZE_DEPS \
		imagemagick-dev \
		postgresql-dev \
		openldap-dev \
	&& docker-php-ext-install pdo_pgsql \
	&& docker-php-ext-install ldap \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& apk del .neos-deps

# Shopware 6
FROM base as shopware6

RUN apk add --no-cache \
		imagemagick \
	&& apk add --no-cache --virtual .shopware-deps \
		$PHPIZE_DEPS \
		imagemagick-dev \
	&& docker-php-ext-install pdo_mysql \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& apk del .shopware-dep

# Sylius
FROM base as sylius

RUN apk add --no-cache \
		imagemagick \
	&& apk add --no-cache --virtual .sylius-deps \
		$PHPIZE_DEPS \
		imagemagick-dev \
	&& docker-php-ext-install exif \
	&& docker-php-ext-install pdo_mysql \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& apk del .sylius-deps


FROM $PROJECT

#
# Cleanup
#
RUN rm -rf /usr/src/*

