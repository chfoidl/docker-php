#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "generate.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG TYPE=cli
ARG VERSION=7.2

FROM php:$VERSION-$TYPE-alpine

WORKDIR /app

ARG TYPE=cli
ARG DEBUG
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
    && apk add --no-cache --virtual .build-deps \
        libjpeg-turbo-dev \
        libpng-dev \
        freetype-dev \
        libxml2-dev \
		zlib-dev \
		icu-dev \
    # Install PHP-Core extensions
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) opcache \
    && apk del .build-deps

# Additions
#
# Install TYPO3 dependencies
#
RUN apk add --no-cache \
		imagemagick \
	&& apk add --no-cache --virtual .typo3-deps \
		$PHPIZE_DEPS \
		imagemagick-dev \
	&& docker-php-ext-install pdo_mysql \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& apk del .typo3-deps

#
# CLI
#
RUN if [ "$TYPE" = "cli" ]; then \
		apk add --no-cache \
			git \
			openssh-client \
		&& mkdir -p /var/composer \
		&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
		&& php composer-setup.php \
		&& php -r "unlink('composer-setup.php');" \
		&& cp composer.phar /usr/local/bin/composer \
		&& composer global require hirak/prestissimo \
		&& chmod -R 777 /var/composer; \
	fi

#
# Debug
#
RUN if [ "$DEBUG" = "yes" ]; then \
		apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
		&& pecl install xdebug-2.6.0 \
		&& docker-php-ext-enable xdebug \
		&& apk del .phpize-deps; \
	fi

#
# Add base php.ini
#
COPY php.ini /usr/local/etc/php/conf.d/10-base.ini

#
# Cleanup
#
RUN rm -rf /usr/src/*
