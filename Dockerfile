# Imagen base con PHP y FPM
FROM php:7.3-fpm

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    nginx \
    supervisor \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_mysql mbstring gd xml

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www

# Copiar código fuente
COPY . .

RUN cp .env.example .env

# Configurar Laravel
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer require barryvdh/laravel-debugbar --no-plugins

RUN composer install --no-dev --optimize-autoloader
RUN php artisan config:cache
RUN chmod -R 777 storage bootstrap/cache

# Copiar configuración de Nginx
COPY default.conf /etc/nginx/conf.d/default.conf

# Configurar Supervisor para manejar procesos
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]