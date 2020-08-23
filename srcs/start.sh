#!/bin/bash

# si argument "-eNOINDEX=1" dans docker run -> Désactiver l'autoindex
if [ $NOINDEX ];then
	sed -i "s/on;/off;/" /etc/nginx/sites-available/nginx.conf
	service nginx stop
fi

# start services
service mysql start
service php7.3-fpm start
nginx -g "daemon off;"