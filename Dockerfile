FROM php:7.3-fpm

    
COPY /bootstrap/cache /bootstrap/cache
# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_mysql mbstring gd xml

# Instalar Composer (compatible con PHP 5.6)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Crear directorio de la aplicación
WORKDIR /var/www

# Copiar archivos de la aplicación
COPY . .

# Copiar archivo de entorno si no existe
RUN cp .env.example .env

# # Generar clave de aplicación
# RUN php artisan key:generate
RUN composer require barryvdh/laravel-debugbar --no-plugins

# Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader

# Configurar permisos de almacenamiento y caché
RUN chmod -R 777 storage bootstrap/cache

# Exponer puerto de Laravel
EXPOSE 8000

# Comando para iniciar Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
