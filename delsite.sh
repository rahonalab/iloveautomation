#!/bin/bash
rm -fv /etc/php5/fpm/pool.d/$1.conf
rm -fv /etc/apache2/sites-enabled/$1.conf
rm -fv /etc/apache2/sites-available/$1.conf
/etc/init.d/php5-fpm restart
deluser --remove-all-files --remove-home $1
groupdel $1
