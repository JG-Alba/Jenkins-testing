FROM php:apache-buster

RUN apt-get update && apt-get install -y bc \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && a2enmod rewrite

EXPOSE 80
COPY ./index.html /var/www/html
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
