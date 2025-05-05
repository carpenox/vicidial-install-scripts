#rm -rf /etc/letsencrypt/live/*.*
#rm -rf /etc/letsencrypt/archive/*.*
rm -rf /etc/httpd/conf.d/*-le-ssl.conf
mv /etc/httpd/conf.d/viciportal-ssl.conf /etc/httpd/conf.d/viciportal-ssl.conf.
service firewalld stop
certbot renew
service firewalld restart
mv /etc/httpd/conf.d/viciportal-ssl.conf. /etc/httpd/conf.d/viciportal-ssl.conf
domain=$(basename /etc/letsencrypt/renewal/*.conf | sed 's/\.conf$//')
#cp "/etc/letsencrypt/live/${domain}-*" "/etc/letsencrypt/live/${domain}" -r
systemctl reload httpd
