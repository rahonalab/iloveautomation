#Simple script to create php-fpm pool and user, and apache2 vhost.
#!/bin/bash

PHP_VER=7.0

<<<<<<< HEAD
#!/bin/bash
if [ $# -ne 3 ]; then
        echo "Usage: $0 domain tld php_version. For example $0 arielcaldaie it 7.1 for arielcaldaie.it"
=======
if [ $# -ne 2 ]; then
        echo "Usage: $0 domain tld. For example $0 arielcaldaie it for arielcaldaie.it"
>>>>>>> c38eefc928a320b2ad762ce65490f8005a081f14
        exit 1;
fi

mkdir -p /var/www/$1.$2
adduser --disabled-login --home /var/www/$1.$2 $1
chown $1.$1 -R /var/www/$1*
adduser www-data $1
<<<<<<< HEAD
sed s/template/$1/ template-fpm > /etc/php/$3/fpm/pool.d/$1.conf
echo "All done with php$3-fpm. Please review information in /etc/php$3/fpm/pool.d/$1.conf before reload php$3-fpm"
=======
sed s/template/$1/ template-fpm > /etc/php/$PHP_VER/fpm/pool.d/$1.conf
echo "All done with php5-fpm. Please review information in /etc/php/$PHP_VER/fpm/pool.d/$1.conf before reload php$PHP_VER-fpm"
>>>>>>> c38eefc928a320b2ad762ce65490f8005a081f14
sed s/domain/$1/ template-apache > /etc/apache2/sites-available/$1.conf
sed -i "s/\/domain/\/$1/" /etc/apache2/sites-available/$1.conf 
sed -i "s/tld/$2/" /etc/apache2/sites-available/$1.conf
echo "All done with apache2. Please review information in /etc/apache2/sites-available/$1.conf before a2ensite $1 and reload apache"
