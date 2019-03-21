---
id: nginxexample
title: Nginx Proxy example
---

The following is an example NGiNX proxy server definition that should work well proxying to a Lucee backend setup with the [[serversetupfoundation|setup guide]].

```nginx
server {

    listen 80;
    server_name www.mysite.com;

    # Allow internal taskmanager requests
    # over plain HTTP. Prevents issues
    # with Lucee failing to make requests
    # due to SSL certificate compatibility
    location /taskmanager/runtasks/ {
        proxy_set_header X-Original-Url $request_uri;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;

        proxy_read_timeout 1200;
        proxy_pass http://127.0.0.1:8888$request_uri;
    }

    # all other locations, redirect to ensure https
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# port 443 server (HTTPS)
server {
    listen 443 ssl http2;

    server_name www.mysite.com;

    ssl_certificate /path/to/publicssl.crt;
    ssl_certificate_key /path/to/privatesslkey.rsa;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security "max-age=15552000";
    add_header X-Content-Type-Options "nosniff";
    add_header X-Download-Options "noopen";
    add_header X-Permitted-Cross-Domain-Policies "none";

    client_max_body_size 100M;

    # proxy by default to the Tomcat/Lucee
    # backend
    location / {
        proxy_set_header X-Original-Url $request_uri;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_cookie_path /coo/ /;

        if ( $uri ~ "\.(?:ico|css|js|gif|jpe?g|png)$" ) {
            expires max;
            add_header Pragma public;
            add_header Cache-Control "public, must-revalidate, proxy-revalidate";
        }

        proxy_read_timeout 1200;
        proxy_pass http://127.0.0.1:8888$request_uri;
    }

    # public uploads from asset manager
    # served with nginx directly
    location /uploads/assets/ {
        # where /var/www is the webroot of your Preside application
        root /var/www;
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    # public css, js and css images
    # for your application served
    # with nginx directly
    location /assets/ {
        # where /var/www is the webroot of your Preside application
        root /var/www;
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }
    
}
```