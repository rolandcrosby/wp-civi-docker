# CiviCRM 5 doesn't recommend PHP 7.2 yet
# https://docs.civicrm.org/sysadmin/en/latest/requirements/#php-version
FROM php:7.1-apache

# install the PHP extensions we need
# CiviCRM needs curl, soap, mcrypt, and mbstring
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libcurl4-openssl-dev \
		libxml2-dev \
		libmcrypt-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache zip; \
	docker-php-ext-install curl soap mcrypt mbstring; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite expires

VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.9.7
ENV WORDPRESS_SHA1 7bf349133750618e388e7a447bc9cdc405967b7d

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress

ENV CIVICRM_VERSION 5.3.0
ENV CIVICRM_SHA1 b31371bbac4261b792bc3436ab0ef00a6cacb4a7

RUN set -ex; \
	curl -o civicrm.zip -fSL "https://download.civicrm.org/civicrm-${CIVICRM_VERSION}-wordpress.zip"; \
	echo "$CIVICRM_SHA1 *civicrm.zip" | sha1sum -c -; \
	php -r '$z = new ZipArchive(); $z->open("civicrm.zip"); $z->extractTo("/usr/src/wordpress/wp-content/plugins"); $z->close();' \
	rm civicrm.zip; \
	chown -R www-data:www-data /usr/src/wordpress/wp-content/plugins/civicrm

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
