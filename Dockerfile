FROM php:7.3-fpm

COPY bootstrap/cache bootstrap/cache
COPY default.conf ./

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    nginx \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_mysql mbstring gd xml

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www

# Copiar archivos
COPY . .

RUN composer require barryvdh/laravel-debugbar --no-plugins

RUN cp .env.example .env

# Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# Configurar permisos
RUN chmod -R 777 storage bootstrap/cache

# Copiar configuración de Nginx
COPY default.conf /etc/nginx/conf.d/default.conf

# Exponer puertos
EXPOSE 80

# Iniciar Nginx y PHP-FPM
CMD service nginx start && php-fpm