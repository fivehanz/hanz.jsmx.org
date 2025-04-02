
install:
	bun install
	composer install

MAKEFLAGS += -j4
dev: dev-node dev-php


dev-node:
	bun run dev

dev-php:
	php artisan serve
