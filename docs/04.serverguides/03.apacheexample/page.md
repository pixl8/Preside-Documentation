---
id: apacheexample
title: Apache2 Proxy example
---

The following is an example Apache2 Virtual Host definition that should work well proxying to a Lucee backend setup with the [[serversetupfoundation|Lucee setup guide]].

```apache
<VirtualHost *:80>
  ServerName www.mysite.com
  ServerAlias mysite.com
  RewriteEngine On
  
  RewriteCond %{SERVER_PORT} !^443$
  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,NC,L]
  
  RewriteCond %{HTTPS} off
  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,NC,L]
  
  RewriteCond %{HTTP:X-Forwarded-Proto} !https
  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,NC,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName www.mysite.com
  ServerAlias mysite.com
  
  DirectoryIndex index.cfm
  DocumentRoot /var/www/
  
  <Directory /var/www/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>
 
  SSLEngine On
  SSLCertificateFile "/ssl/mysite/mysite.com.crt"
  SSLCertificateChainFile "/ssl/mysite/mysite.com.ca-bundle"
  SSLCertificateKeyFile "/ssl/mysite/privkey.pem"

<IfModule mod_proxy.c>
    ProxyPreserveHost On
    ProxyPassMatch ^/(.*)(.*)?$ http://127.0.0.1:8888/$1$2
    ProxyPassMatch ^/(.*)(/.*)?$ http://127.0.0.1:8888/$1$2
    ProxyPassReverse / http://127.0.0.1:8888/

    ProxyTimeout 900
</IfModule>
</VirtualHost>
```