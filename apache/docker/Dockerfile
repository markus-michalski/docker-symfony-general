FROM php:8.2-apache
EXPOSE 80
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

MAINTAINER info@markus-michalski.net

# Avoid interactive dialogs during installation
ENV DEBIAN_FRONTEND=noninteractive

# timezone / date
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# install packages
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  less vim wget zip unzip dos2unix rsync git mariadb-client libzip-dev ssl-cert sudo openssh-server \
  libcurl4-openssl-dev libfreetype6 libjpeg62-turbo libpng-dev libjpeg-dev libxml2-dev libxpm4 nano libjpeg62 libxrender1 fontconfig libfreetype6 libpng16-16 xvfb libfreetype6-dev libwebp-dev && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* && \
  echo "export TERM=xterm" >> /root/.bashrc

# Korrekte GD-Konfiguration mit allen benötigten Features
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp && \
    docker-php-ext-install -j$(nproc) \
    gd \
    pdo_mysql \
    zip \
    bcmath \
    soap \
    mysqli

#xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug \
  && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install symfony recommeded extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libonig-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install mbstring
RUN docker-php-ext-enable intl mbstring

# Install wkhtmltopdf
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    ca-certificates \
    curl \
    libjpeg62-turbo \
    xfonts-75dpi \
    xfonts-base \
    fontconfig \
    xfonts-encodings \
    && curl -fsSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb -o wkhtmltox.deb \
    && dpkg -i wkhtmltox.deb \
    && apt-get -f install -y \
    && rm -f wkhtmltox.deb \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Verify installation
RUN wkhtmltopdf --version

# Install and activate opcache JIT
COPY ./files/php.ini /usr/local/etc/php/php.ini
COPY ./files/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN docker-php-ext-install opcache

# composer stuff
RUN php -r 'readfile("https://getcomposer.org/installer");' > composer-setup.php \
  && php composer-setup.php --install-dir=/usr/local/bin --version=2.5.5 --filename=composer \
  && rm -f composer-setup.php \
  && chown www-data:www-data /var/www
  
# Symfony Cli
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
RUN apt-get update && apt-get install -y symfony-cli

# GIT Config
RUN git config --global --add safe.directory /var/www/html \
  && git config --global user.email "info@markus-michalski.net" \ 
  && git config --global user.name "Markus Michalski"

# prepare entrypoint.d pattern
RUN mkdir /init_script.d
COPY ./files/init_script.sh /init_script.sh
RUN chmod 777 /init_script.sh # && chmod 777 /init_script.d/*

# fix windows line endings if needed
RUN dos2unix /init_script.sh

# apache stuff
RUN /usr/sbin/a2enmod rewrite && /usr/sbin/a2enmod headers && /usr/sbin/a2enmod expires && /usr/sbin/a2enmod ssl
COPY ./files/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN ["/bin/bash", "-c", "chpasswd <<<'root:docker'"]

# change ssh config
COPY ./files/sshd_config /etc/ssh/sshd_config

# EXECUTED ON EVERY START
ENTRYPOINT ["/init_script.sh"]

CMD ["apache2-foreground"]
