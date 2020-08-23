FROM debian:buster

# Update packages
RUN apt-get update

# Install Nginx, wget, MariaDb & php/sql
RUN apt-get install -y nginx
RUN apt-get install -y wget
RUN apt-get install -y mariadb-server 
RUN apt-get install -y php7.3-fpm 
RUN apt-get install -y php7.3-mysql

COPY srcs/404.html /var/www/html/

# rm default index
RUN	rm -f /var/www/html/index.nginx-debian.html

# install wordpress from wget
RUN wget https://wordpress.org/latest.tar.gz
RUN tar xf latest.tar.gz
RUN	rm latest.tar.gz
RUN	mv wordpress/ /var/www/html/wordpress
RUN	chown -R www-data:www-data /var/www/html/wordpress/

# install phpMyadmin from wget
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-english.tar.gz
RUN tar xf phpMyAdmin-4.9.5-english.tar.gz
RUN rm phpMyAdmin-4.9.5-english.tar.gz
RUN mv /phpMyAdmin-4.9.5-english /var/www//html/phpmyadmin
RUN	chown -R www-data:www-data /var/www/html/phpmyadmin/
RUN apt-get -y install php-mbstring

# mySQL Start + create user + asign rights
RUN service mysql start && \
	mysql -u root -p"root" -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password'" && \
	mysql -u root -p"root" -e "CREATE DATABASE wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;" && \
	mysql -u root -p"root" -e "GRANT ALL PRIVILEGES ON * . * TO 'admin'@'localhost';" && \
	mysql -u root -p"root" -e "FLUSH PRIVILEGES"

# Generate SSl certificate
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=FR/ST=Rhone/L=Lyon/O=42/CN=null' -keyout /etc/nginx/ssl/site.key -out /etc/nginx/ssl/site.crt

# Copy Nginx configuration file
COPY srcs/nginx.conf /etc/nginx/sites-available/nginx.conf
# Create alias
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
# Reload nginx conf
RUN service nginx reload

# Copy start script
COPY srcs/start.sh /start.sh
# Asign execution rights to script
RUN chmod +x /start.sh

# open ports 80 (http) & 443 (https)
EXPOSE 80
EXPOSE 443

# run script
CMD '/start.sh'
