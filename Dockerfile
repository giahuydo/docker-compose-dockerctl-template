FROM ubuntu:18.04

WORKDIR /var/www/html

ARG WWWUSER=www-data

RUN apt-get update -y
RUN apt-get install -y gnupg tzdata

RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && echo "deb http://ppa.launchpad.net/nginx/development/ubuntu bionic main" > /etc/apt/sources.list.d/ppa_nginx_mainline.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C \
    && apt-get update \
    && apt-get install -y curl zip unzip git supervisor sqlite3 dos2unix vim nano htop \
    && apt-get install -y nginx php7.2-fpm php7.2-cli \
       php7.2-pgsql php7.2-sqlite3 php7.2-gd \
       php7.2-curl php7.2-memcached php7.2-redis \
       php7.2-imap php7.2-mysql php7.2-mbstring \
       php7.2-xml php7.2-zip php7.2-bcmath php7.2-soap \
       php7.2-intl php7.2-readline php7.2-mongodb \
       php7.2-msgpack php7.2-igbinary  \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && sed -i "s/user\ \=.*/user\ \= $WWWUSER/g" /etc/php/7.2/fpm/pool.d/www.conf \
    && mkdir /run/php \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY docker/production/h5bp /etc/nginx/h5bp
COPY docker/production/default /etc/nginx/sites-available/default
COPY docker/production/php/fpm/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY docker/production/php/fpm/php.ini /etc/php/7.2/fpm/php.ini
COPY docker/production/php/cli/php.ini /etc/php/7.2/cli/php.ini
COPY docker/production/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/production/start-container /usr/local/bin/start-container

RUN dos2unix /usr/local/bin/start-container && apt-get --purge remove -y dos2unix && rm -rf /var/lib/apt/lists/*
RUN chmod +x /usr/local/bin/start-container
RUN mkdir -p /var/www/.composer /var/www/html/tests /var/www/html/database /var/www/html/storage/temp /var/www/.cache var/www/html/storage/app/public
RUN chown -R $WWWUSER:$WWWUSER /var/www/html /var/www/.composer /var/www/html/storage/temp /var/www/.cache var/www/html/storage/app/public

USER $WWWUSER

COPY ["composer.json", "composer.lock", "artisan", "/var/www/html/"]

RUN composer install --no-dev --optimize-autoloader

COPY --chown=www-data:www-data .env.development /var/www/html/.env
COPY --chown=www-data:www-data app /var/www/html/app
COPY --chown=www-data:www-data bootstrap /var/www/html/bootstrap
COPY --chown=www-data:www-data config /var/www/html/config
COPY --chown=www-data:www-data database /var/www/html/database
COPY --chown=www-data:www-data public /var/www/html/public
COPY --chown=www-data:www-data resources /var/www/html/resources
COPY --chown=www-data:www-data routes /var/www/html/routes
COPY --chown=www-data:www-data storage /var/www/html/storage

USER root

RUN chown -R $WWWUSER:$WWWUSER /var/www/html
RUN chmod -R 775 /var/www/html/storage
RUN composer dumpautoload

ENTRYPOINT ["dumb-init", "--"]

CMD ["/usr/bin/supervisord"]
