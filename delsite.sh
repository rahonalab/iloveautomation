#!/bin/bash
if [ $# -ne 2 ]; then
        echo "Usage: $0 2ndleveldomain php_version. For example $0 arielcaldaie 7.1 for arielcaldaie.it"
        exit 1;
fi

rm -fv /etc/php/$2/fpm/pool.d/$1.conf
rm -fv /etc/apache2/sites-enabled/$1.conf
rm -fv /etc/apache2/sites-available/$1.conf
/etc/init.d/php$2-fpm restart
/etc/init.d/apache2 restart
deluser --remove-all-files --remove-home $1
groupdel $1
