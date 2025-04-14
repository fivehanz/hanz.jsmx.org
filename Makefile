
MAKEFLAGS += -j4
install:
	bun --bun install
	composer install

dev:
	composer run dev


