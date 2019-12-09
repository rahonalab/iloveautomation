ip route add default via 172.31.16.1 dev eth1 table out
ip rule add from 172.31.17.52/32 table out
ip rule add to 172.31.17.52/32 table out
ip route flush cache
