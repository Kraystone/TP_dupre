#!/bin/bash
IP="iptables"

# On vide toutes les règles
${IP} -F INPUT
${IP} -F OUTPUT
${IP} -F FORWARD
${IP} -x
${IP}  -A INPUT -p tcp --dport 22 -j ACCEPT
${IP} -A OUTPUT -p tcp --sport 22 -j ACCEPT
${IP} -A OUTPUT -p tcp -o ens33 --dport 80 -j ACCEPT
${IP} -A INPUT -p tcp --sport 80 -i ens33 -j ACCEPT
${IP} -A OUTPUT -p TCP --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
${IP} -A OUTPUT -p TCP --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
${IP} -A OUTPUT -p UDP --dport 53 -m state --state NEW -j ACCEPT

# ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0)(.*)$ -> utiliser pour récuperer la liste des ip uniquement à partir de "https://ipinfo.io/AS14061" 
# -> en remplaçant la chaine par uniquement le premier groupe de selection
${IP} -A INPUT -s 104.131.0.0/16 -j DROP
${IP} -A INPUT -s 104.236.0.0/16 -j DROP
${IP} -A INPUT -s 104.248.0.0/16 -j DROP
${IP} -A INPUT -s 107.170.0.0/16 -j DROP
${IP} -A INPUT -s 128.199.0.0/16 -j DROP
${IP} -A INPUT -s 138.68.0.0/16 -j DROP
${IP} -A INPUT -s 134.122.0.0/16 -j DROP
${IP} -A INPUT -s 138.197.0.0/16 -j DROP
${IP} -A INPUT -s 134.209.0.0/16 -j DROP
