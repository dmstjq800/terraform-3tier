#!/bin/bash
mkdir /test
cd /test
yum install -y httpd
rm /etc/httpd/conf/httpd.conf
aws s3 cp s3://my-bucket-ces-3tier/web/httpd.conf /etc/httpd/conf/httpd.conf

cat << EOF >> /etc/httpd/conf/httpd.conf
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_connect_module modules/mod_proxy_connect.so
LoadModule proxy_http_module modules/mod_proxy_http.so

<VirtualHost *:80> 
    ProxyRequests Off
    ProxyPreserveHost On
    <Proxy *> 
        Order deny,allow
        Allow from all
    </Proxy>
    ProxyPass / http://${TOMCAT_DNS}:8080/ disablereuse=on
    ProxyPassReverse / http://${TOMCAT_DNS}:8080/
</VirtualHost>
EOF

systemctl enable --now httpd


