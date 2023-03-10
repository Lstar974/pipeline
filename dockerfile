FROM php:7.4-apache

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        libicu-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        libonig-dev \
        libpq-dev \
        libxml2-dev \
        sudo \
        unzip

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install \
        gd \
        intl \
        mbstring \
        mysqli \
        opcache \
        pdo_mysql \
        zip

# Install additional PHP extensions for Wordpress
RUN docker-php-ext-install bcmath sockets

# Install required PHP extensions for Wordpress
RUN apt-get install -y libmemcached-dev \
    && pecl install memcached-3.1.5 \
    && docker-php-ext-enable memcached

# Enable mod_rewrite
RUN a2enmod rewrite

# Copy the code to the container
COPY . /var/www/html/wordpress

# Set the working directory
WORKDIR /var/www/html/wordpress

# Change the ownership of the files
RUN chown -R www-data:www-data /var/www/html/wordpress

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
    
RUN wp core download --path="/var/www/html/wordpress" --allow-root

# Expose the port
EXPOSE 80

# Start the Apache service
CMD ["apache2-foreground"]
