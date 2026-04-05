

# init

```
install -d -o www -g www -m 755 /usr/local/www/wagtail
cd /usr/local/www/wagtail
```

clone the repo to the `/usr/local/www/wagtail` directory


```
git clone <repo> .
```

# ssl certs 

i use cloudflare origin certs with 15 year validity

```
install -d -m 755 /usr/local/etc/ssl

chmod 600 /usr/local/etc/ssl/cf-origin.key
chmod 644 /usr/local/etc/ssl/cf-origin.pem
```
