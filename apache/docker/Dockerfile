FROM php:8.2-apache

# Set server name and expose port
EXPOSE 80
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Metadata
LABEL maintainer="info@markus-michalski.net"

# Avoid interactive dialogs during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone
RUN echo "Europe/Berlin" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Install basic system packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        less vim wget zip unzip dos2unix rsync git mariadb-client \
        libzip-dev ssl-cert sudo openssh-server libxslt-dev \
        libcurl4-openssl-dev libfreetype6 libjpeg62-turbo libpng-dev \
        libjpeg-dev libxml2-dev libxpm4 nano libjpeg62 libxrender1 \
        fontconfig libfreetype6 libpng16-16 xvfb libfreetype6-dev \
        libwebp-dev gnupg ca-certificates libicu-dev libonig-dev \
        xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils xauth \
        poppler-utils \
	&& docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
	&& docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        zip \
        bcmath \
        soap \
        mysqli \
        intl \
		xml \
		xsl \
        mbstring \
        opcache \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && echo "export TERM=xterm" >> /root/.bashrc

# Configure and enable Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install wkhtmltopdf
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    libxrender1 \
    libfontconfig1 \
    libjpeg62-turbo \
    fontconfig \
    && wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 --tries=5 \
       https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb -O wkhtmltox.deb \
    && dpkg -i wkhtmltox.deb || true \
    && apt-get -f install -y \
    && dpkg -i wkhtmltox.deb \
    && which wkhtmltopdf \
    && /usr/local/bin/wkhtmltopdf --version \
    && rm -f wkhtmltox.deb \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install and activate opcache JIT
COPY ./files/php.ini /usr/local/etc/php/php.ini
COPY ./files/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Install Composer
RUN php -r 'readfile("https://getcomposer.org/installer");' > composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --version=2.5.5 --filename=composer \
    && rm -f composer-setup.php \
    && chown www-data:www-data /var/www

# Install Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash \
    && apt-get update \
    && apt-get install -y symfony-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure Git
RUN git config --global --add safe.directory /var/www/html \
    && git config --global user.email "info@markus-michalski.net" \
    && git config --global user.name "Markus Michalski"

# Set up Apache
RUN a2enmod rewrite && a2enmod headers && a2enmod expires && a2enmod ssl
COPY ./files/000-default.conf /etc/apache2/sites-available/000-default.conf

# Set up SSH - Fixed syntax for password
RUN echo "root:docker" | chpasswd
COPY ./files/sshd_config /etc/ssh/sshd_config

# Prepare initialization scripts
RUN mkdir /init_script.d
COPY ./files/init_script.sh /init_script.sh
RUN chmod 777 /init_script.sh \
    && dos2unix /init_script.sh

# Execute on container start
ENTRYPOINT ["/init_script.sh"]
CMD ["apache2-foreground"]
