#Simple script to create php-fpm pool and user, and apache2 vhost.
#!/bin/bash

if [ $# -ne 3 ]; then
        echo "Usage: $0 domain tld php_version. For example $0 antani org 8.3 for antani.org, php 8.3"
        exit 1;
fi

mkdir -p /var/www/$1.$2
adduser --home /var/www/$1.$2 $1
mkdir -p /var/www/$1.$2/public_html
cp -rvp index.php /var/www/$1.$2/public_html
chown $1.$1 -R /var/www/$1*
adduser www-data $1
sed s/template/$1/ template-fpm > /etc/php/$3/fpm/pool.d/$1.conf
echo "All done with php$3-fpm. Please review information in /etc/php$3/fpm/pool.d/$1.conf before reload php$3-fpm"
sed s/domain/$1/ template-apache > /etc/apache2/sites-available/$1.conf
sed -i "s/\/domain/\/$1/" /etc/apache2/sites-available/$1.conf 
sed -i "s/tld/$2/" /etc/apache2/sites-available/$1.conf
echo "All done with apache2. Please review information in /etc/apache2/sites-available/$1.conf before a2ensite $1 and reload apache"

