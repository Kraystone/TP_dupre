#!/bin/bash
IP="iptables"
MARRON='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
###############################################WEB#########################################
if [ "$HOSTNAME" = web ]; then
  echo "Execution du script pour la machine WEB"
  while :
  do 
    echo -e "
    ${GREEN}---Menu du Script---${NC}

    ${MARRON}1- Secure that stuff.
    2- Parsage des logs.
    3- Ban all the lamers.
    4- Quitter le script --->[].${NC}
    "
    read choix
    stty echo
    if [ $choix = 1 ]; then
      echo -e "Ecriture des regles" #ALED LE FR marion ?!
      echo "
      ${IP} -F INPUT
      ${IP} -F OUTPUT
      ${IP} -F FORWARD
      ${IP} -x
        
      MARION

      ${IP} -A INPUT -s 104.131.0.0/16 -j DROP
      ${IP} -A INPUT -s 104.236.0.0/16 -j DROP
      ${IP} -A INPUT -s 104.248.0.0/16 -j DROP
      ${IP} -A INPUT -s 107.170.0.0/16 -j DROP
      ${IP} -A INPUT -s 128.199.0.0/16 -j DROP
      ${IP} -A INPUT -s 138.68.0.0/16 -j DROP
      ${IP} -A INPUT -s 134.122.0.0/16 -j DROP
      ${IP} -A INPUT -s 138.197.0.0/16 -j DROP
      ${IP} -A INPUT -s 134.209.0.0/16 -j DROP" >  /etc/iptables/iptables.rules
    fi
    if [ $choix = 2 ]; then
    #je prends tout les addresses ip au debuts des lignes et je les affiche dans step2.csv
      grep -E -o "^([0-9]{1,3}[\.]){3}[0-9]{1,3}" /var/log/apache2/adventofcode.log > step2.csv
    fi
    if [ $choix = 3 ]; then
      echo -e "Phase 3"
    fi
    if [ $choix = 4 ]; then
      echo -e "${RED}Tu nous quittes :c${NC}"
      reboot
    fi
  done
fi
###############################################BDD#########################################
if [ "$HOSTNAME" = bdd ]; then
  echo "Execution du script pour la machine BDD"
  while :
  do 
    echo -e "
    ${GREEN}---Menu du Script---${NC}

    ${MARRON}1- Secure that stuff.
    2- Parsage des logs.
    3- Ban all the lamers.
    4- Quitter le script --->[].${NC}
    "
    read choix
    stty echo
    if [ $choix = 1 ]; then
      printf "Ecriture des regles" #ALED LE FR marion ?!
      echo "
    ${IP} -F INPUT
    ${IP} -F OUTPUT
    ${IP} -F FORWARD
    ${IP} -x
        
    MARION

    ${IP} -A INPUT -s 104.131.0.0/16 -j DROP
    ${IP} -A INPUT -s 104.236.0.0/16 -j DROP
    ${IP} -A INPUT -s 104.248.0.0/16 -j DROP
    ${IP} -A INPUT -s 107.170.0.0/16 -j DROP
    ${IP} -A INPUT -s 128.199.0.0/16 -j DROP
    ${IP} -A INPUT -s 138.68.0.0/16 -j DROP
    ${IP} -A INPUT -s 134.122.0.0/16 -j DROP
    ${IP} -A INPUT -s 138.197.0.0/16 -j DROP
    ${IP} -A INPUT -s 134.209.0.0/16 -j DROP" >  /etc/iptables/iptables.rules
    fi
    if [ $choix = 2 ]; then
    #je me connecte en root sur la base adventofcode et je selectionne tout pour le mettre dans un fichier .csv qui seras enregistrer dans la machine de base de donées
      mysql -u root -p"leo" adventofcode -e"select * from \`2017\`;" > bddstep2.csv
      scp bddstep2.csv  admin_web@192.168.1.70:/home/admin_web/
    fi
    if [ $choix = 3 ]; then
      echo -e "Phase 3"
    fi
    if [ $choix = 4 ]; then
      echo -e "${RED}Tu nous quittes :c${NC}"
      #reboot
      exit 1
    fi
  done
fi
