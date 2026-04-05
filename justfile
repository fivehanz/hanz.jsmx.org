export SITE := "hanz.jsmx.org"
export DEV_ENV := "development"
export PROD_ENV := "production"

# ---- PROD ---- #

prod-setup $ENVIRONMENT=PROD_ENV:
    just freebsd-setup-pkgs
    just freebsd-nginx-configure
    just freebsd-wagtail-configure
    just freebsd-litestream-configure
    just setup-mise
    just setup-uv
    just setup-pf
    just setup-staticfiles

prod-post-setup:
    just litestream-restore
    just setup-db
    just prod-start

freebsd-setup-pkgs:
    pkg install --yes mise nginx litestream

freebsd-nginx-configure:
    # enable nginx
    sysrc nginx_enable=YES

    # remove nginx.conf
    rm /usr/local/etc/nginx/nginx.conf

    # create nginx.conf symlink from the repo
    ln -sf $(pwd)/prod/freebsd/nginx/nginx.conf \
            /usr/local/etc/nginx/nginx.conf

    # create conf.d directory
    install -d -m 0755 /usr/local/etc/nginx/conf.d

    # create wagtail.conf symlink from the repo
    ln -sf $(pwd)/prod/freebsd/nginx/wagtail.conf \
            /usr/local/etc/nginx/conf.d/wagtail.conf

    # start nginx
    service nginx start

freebsd-litestream-configure:
    # enable litestream
    sysrc litestream_enable=YES
    sysrc litestream_config=/usr/local/etc/litestream.yml

    # ensure config exists (from repo)
    ln -sf $(pwd)/prod/freebsd/litestream/litestream.yml \
        /usr/local/etc/litestream.yml

litestream-status:
    @echo "== service status =="
    service litestream status || true

    @echo "\n== process =="
    pgrep -fl litestream || true

    @echo "\n== socket / activity =="
    sockstat -4 | grep litestream || true

litestream-restore:
    # load env
    . /usr/local/etc/wagtail/env && \
    echo "Restoring to $$DATABASE_PATH" && \
    litestream restore \
        -if-replica-exists \
        -o $$DATABASE_PATH

litestream-backup:
    # load env
    . /usr/local/etc/wagtail/env && \
    echo "Starting replication..." && \
    litestream replicate

freebsd-wagtail-configure:
    # runtime + data dirs
    install -d -o www -g www -m 755 /var/db/wagtail
    install -d -o www -g www -m 755 /var/cache/nginx/wagtail

    # config dir (root-owned)
    install -d -m 755 /usr/local/etc/wagtail

    # env file (secrets)
    cp $(pwd)/.env.prod /usr/local/etc/wagtail/env
    chmod 600 /usr/local/etc/wagtail/env
    chown root:wheel /usr/local/etc/wagtail/env

    # ensure repo ownership for runtime user
    chown -R www:www /usr/local/www/wagtail

    # keep ops files root-owned
    chown -R root:wheel /usr/local/www/wagtail/prod

    # install rc.d service from repo
    install -m 555 $(pwd)/prod/freebsd/rc.d/wagtail \
        /usr/local/etc/rc.d/wagtail

    # enable service
    sysrc wagtail_enable=YES

setup-mise:
    # replace development with production in .miserc.toml
    sed -i 's/development/production/g' .miserc.toml
    # trust and install
    mise -E $ENVIRONMENT trust
    mise -E $ENVIRONMENT install

setup-uv:
    mise exec -- uv sync --locked

setup-pf:
    # enable pf at boot
    sysrc pf_enable=YES

    # backup existing config (once)
    [ -f /etc/pf.conf ] && cp /etc/pf.conf /etc/pf.conf.bak || true

    # symlink repo pf.conf
    ln -sf $(pwd)/prod/freebsd/pf/pf.conf /etc/pf.conf

    # validate config BEFORE applying (critical)
    pfctl -nf /etc/pf.conf

    # load rules
    pfctl -f /etc/pf.conf

    # start pf if not running
    service pf start || true

    # show active rules (sanity check)
    pfctl -sr

setup-staticfiles:
	mise exec -- uv run python manage.py collectstatic --no-input --clear

setup-db:
    just migrate

migrate:
	mise exec -- uv run python manage.py migrate

prod-start:
    service wagtail restart || service wagtail start

################################################################################
# ---- DEV ---- #
################################################################################

vite-install:
	cd frontend && pnpm install

django-install:
	mise exec -- uv sync

django-dev:
    DEBUG=true uv run python manage.py runserver 0.0.0.0:8000

makemigrations:
	mise exec -- uv run python manage.py makemigrations

vite-dev:
	cd frontend && pnpm run dev

vite-build:
	cd frontend && pnpm run build