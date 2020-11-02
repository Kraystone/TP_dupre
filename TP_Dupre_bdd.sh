#!/bin/bash
IP="iptables"
MARRON='\e[94m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
###############################################BDD#########################################
if [ "$HOSTNAME" = debian ]; then
  echo "Execution du script pour la machine BDD"
  while :
  do 
    echo -e "
    ${GREEN}---Menu du Script---${NC}

    ${MARRON}1- Secure that stuff.
    2- Parsage des logs.
    3- Quitter le script --->[].${NC}
    "
    read choix
    stty echo
    if [ $choix = 1 ]; then
      printf "Ecriture des regles" #ALED LE FR marion ?!
      echo "
    ${IP} -F
    ${IP} -X
    ${IP} -t nat -F
    ${IP} -t nat -X
    ${IP} -t mangle -F
    ${IP} -t mangle -X
        
    #les connexions destinées à être routées sont acceptées par défaut
    ${IP} -P INPUT ACCEPT
    ${IP} -P FORWARD ACCEPT
    ${IP} -P OUTPUT ACCEPT
    #pas de filtrage sur l'interface de loopback
    ${IP} -A INPUT -i lo -j ACCEPT
    #connexion déjà établie (acp packet)
    ${IP} -A INPUT -m conntrack --cstate RELATED,ESTABLISHED -j ACCEPT

    #Autorisation des ports pour l'interface réseau WAN, port 22 (ssh) et 53 (dns)

    ${IP} -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
    ${IP} -A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT

    ${IP} -A INPUT -p udp -m udp --dport 53 -j ACCEPT
    ${IP} -A INPUT -p udp -m udp --sport 53 -j ACCEPT
    ${IP} -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
    ${IP} -A OUTPUT -p udp -m udp --sport 53 -j ACCEPT

     # Pour Mairadb et mysql le port 3306 - maria db
    ${IP} -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
    ${IP} -A INPUT -p tcp -m tcp --sport 3306 -j ACCEPT
    ${IP} -A OUTPUT -p tcp -m tcp --dport 3306 -j ACCEPT
    ${IP} -A OUTPUT -p tcp -m tcp --sport 3306 -j ACCEPT

    ${IP} -A INPUT -s 104.131.0.0/16 -j DROP
    ${IP} -A INPUT -s 104.236.0.0/16 -j DROP
    ${IP} -A INPUT -s 104.248.0.0/16 -j DROP
    ${IP} -A INPUT -s 107.170.0.0/16 -j DROP
    ${IP} -A INPUT -s 128.199.0.0/16 -j DROP
    ${IP} -A INPUT -s 138.68.0.0/16 -j DROP
    ${IP} -A INPUT -s 134.122.0.0/16 -j DROP
    ${IP} -A INPUT -s 138.197.0.0/16 -j DROP
    ${IP} -A INPUT -s 134.209.0.0/16 -j DROP
    
    ${IP} -P INPUT DROP" >  /etc/iptables/iptables.rules
    fi
    echo -e "${GREEN}Les regles sont ecrite dans /etc/iptables/iptables.rules.${NC}"
    if [ $choix = 2 ]; then
    #je me connecte en root sur la base adventofcode et je selectionne tout pour le mettre dans un fichier .csv qui seras enregistrer dans la machine de base de donées
      mysql -u root -p"leo" adventofcode -e"select * from \`2017\`;" > bddstep2.csv
      scp bddstep2.csv  admin_web@192.168.1.70:/home/admin_web/
    fi
    echo -e "${GREEN}Les fichiers de la base de données sont sur la machine web dans home/admin_web/bddstep2.csv${NC}"
    if [ $choix = 3 ]; then
      echo -e "${RED}Tu nous quittes :c${NC}"
      exit 1
    fi
  done
fi
