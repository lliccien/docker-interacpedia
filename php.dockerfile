FROM ubuntu:18.04

ENV TERM=xterm \
	TZ=America/Bogota \
    DEBIAN_FRONTEND=noninteractive

# Install basic
RUN apt-get update && apt-get upgrade --yes && \
	apt-get install --yes nano wget curl git nginx gettext-base memcached  && \
	apt install software-properties-common --yes &&\
	add-apt-repository ppa:ondrej/php

# Install php and libraries
RUN apt-get update && apt-get upgrade --yes && \
 	apt-get install -y \
    php-common \
    php-igbinary \
    php-memcached \
    php-msgpack \
    php-pear	 \
    php7.3-bcmath \
    php7.3-cli \
    php7.3-common \
    php7.3-curl \
    php7.3-dev \
    php7.3-fpm \
    php7.3-gd \
    php7.3-imap \
    php7.3-intl \
    php7.3-json \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-opcache	 \
    php7.3-pgsql \
    php7.3-readline \
    php7.3-soap \
    php7.3-sqlite3	 \
    php7.3-xml \
    php7.3-zip \
    php7.3-xdebug

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install Node Js
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
	apt-get update && \
	apt-get install -y nodejs

# Cleaning
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Confugure php.ini and www.conf
COPY php/php.ini /etc/php/7.3/fpm/

# config Xdebug
COPY php/xdebug.ini /etc/php/7.3/mods-available/

# Fix ownership of sock file for php-fpm
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/7.3/fpm/pool.d/www.conf && \
	find /etc/php/7.3/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \; && \
	mkdir /run/php

# Nginx site conf
COPY nginx/default /etc/nginx/sites-available/default

RUN mkdir /etc/nginx/ssl
ADD nginx/ssl/app.interacpedia.test.pem /etc/nginx/ssl/
ADD nginx/ssl/app.interacpedia.test-key.pem /etc/nginx/ssl/

WORKDIR /var/www/html

EXPOSE 80 443

CMD service php7.3-fpm start && \
	nginx -g 'daemon off;' 
