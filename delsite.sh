#!/bin/bash
if [ $# -ne 3 ]; then
        echo "Usage: $0 2ndleveldomain php_version. For example $0 arielcaldaie 7.1 for arielcaldaie.it"
        exit 1;
fi

rm -fv /etc/php/$3/fpm/pool.d/$1.conf
rm -fv /etc/apache2/sites-enabled/$1.conf
rm -fv /etc/apache2/sites-available/$1.conf
rm -rfv /var/www/$1.$2
/etc/init.d/php$3-fpm restart
/etc/init.d/apache2 restart
deluser --remove-home $1
groupdel $1
