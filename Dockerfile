### Stage 1: Build Vite assets
FROM oven/bun:1.2-slim AS assets
WORKDIR /app

# Copy package.json and bun.lockb, then install dependencies
COPY package.json bun.lock ./
RUN bun install

# Copy the rest of the frontend source and build assets
COPY . .
RUN bun run build

### Stage 2: Use prebuilt image for PHP
FROM serversideup/php:8.3-unit

# enable opcache
ENV PHP_OPCACHE_ENABLE=1

# Set working directory
WORKDIR /var/www/html

# Copy application source code
COPY --chown=www-data:www-data . .

# Copy assets
COPY --from=assets --chown=www-data:www-data /app/public/build/ ./public/build/

# create cache dir
RUN mkdir -p /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/bootstrap/cache && \
    chown -R www-data:www-data /var/www/html/bootstrap/cache

# dummy db for build
RUN mkdir -p /var/www/html/database && \
    touch /var/www/html/database/database.sqlite && \
    chmod 664 /var/www/html/database/database.sqlite && \
    chown www-data:www-data /var/www/html/database/database.sqlite

# Install production dependencies
RUN composer install --prefer-dist --no-dev --no-interaction --optimize-autoloader
