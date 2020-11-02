#!/bin/bash
IP="iptables"
MARRON='\e[94m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
###############################################WEB#########################################
if [ "$HOSTNAME" = debian ]; then
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

    ${IP} -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    ${IP} -A INPUT -p tcp -m tcp --sport 80 -j ACCEPT
    ${IP} -A OUTPUT -p tcp -m tcp --sport 80 -j ACCEPT
    ${IP} -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT

    ${IP} -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
    ${IP} -A INPUT -p tcp -m tcp --sport 443 -j ACCEPT
    ${IP} -A OUTPUT -p tcp -m tcp --sport 443 -j ACCEPT
    ${IP} -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT

    ${IP} -A INPUT -p udp -m udp --dport 53 -j ACCEPT
    ${IP} -A INPUT -p udp -m udp --sport 53 -j ACCEPT
    ${IP} -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
    ${IP} -A OUTPUT -p udp -m udp --sport 53 -j ACCEPT


    ${IP} -A INPUT -s 104.131.0.0/16 -j DROP
    ${IP} -A INPUT -s 104.236.0.0/16 -j DROP
    ${IP} -A INPUT -s 104.248.0.0/16 -j DROP
    ${IP} -A INPUT -s 107.170.0.0/16 -j DROP
    ${IP} -A INPUT -s 128.199.0.0/16 -j DROP
    ${IP} -A INPUT -s 138.68.0.0/16 -j DROP
    ${IP} -A INPUT -s 134.122.0.0/16 -j DROP
    ${IP} -A INPUT -s 138.197.0.0/16 -j DROP
    ${IP} -A INPUT -s 134.209.0.0/16 -j DROP" > /etc/iptables/iptables.rules
    fi
    echo -e "${GREEN}Les regles sont ecrite dans /etc/iptables/iptables.rules.${NC}"
    if [ $choix = 2 ]; then
    #je prends tout les addresses ip au debuts des lignes et je les affiche dans step2.csv
      grep -E -o "^([0-9]{1,3}[\.]){3}[0-9]{1,3}" /var/log/apache2/adventofcode.log > step2.csv
    fi
    if [ $choix = 3 ]; then
      echo -e "Phase 3"
      echo "
      #règle anti-DDoS
      ##règle bloque tous les paquets qui ne sont pas un paquet SYN et n'appartiennent pas à une connexion TCP établie (established)
      [drop les paquets invalide]
      ${IP} -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
      ##bloqué de nouveau les paquetss qui ne sont pas SYN
      ${IP} -t mangle -A PREROUTING -P tcp! --syn -m conntrack --ctstate NEW -j DROP
      ##Bloque les new packets qui utilisent une valeur TCP MSS qui n'est pas connu (aide a bloquer les innondations SYN muettes)
      ${IP} -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss! --mss 536:65535 -j DROP
      ##bloque les paquets qui utiisent de faux indicateur TCP.
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags FIN, SYN, RST, PSH, ACK, URG NONE -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags FIN, SYN FIN, SYN -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags SYN, RST SYN, RST -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags FIN, RST FIN, RST -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags FIN, ACK FIN -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ACK, URG URG -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ACK, FIN FIN -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ACK, PSH PSH -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN, PSH, URG -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN, FIN, PSH, URG -j DROP
      ${IP} -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN, RST, ACK, FIN, URG -j DROP
      ##limite les connexion /sec /ip
      ${IP} -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 20/s --limit-burst 20 -j ACCEPT
      ${IP} -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP

      ${IP} -P INPUT -i ens33 DROP

      ## Protection par force brute SSH
      ${IP} -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

      ## Protection contre l'analyse des ports
      ${IP} -N port-scan
      ${IP} -A port-scanning -p tcp --tcp-flags SYN, ACK, FIN, RST RST -m limit --limit 1 / s --limit-burst 2 -j RETURN
      ${IP} -A port-scan -j DROP
      
      ${IP} -P INPUT DROP" >> /etc/iptables/iptables.rules
      
      #Intallation de fail2ban
      echo -e "${MARRON}Intallation de fail2ban.${NC}"
      apt install fail2ban -y
      echo -e "${MARRON}Fail2ban est installé.${NC}"
      echo "[DEFAULT]
      ignoreip = 127.0.0.1/8
      findtime = 600
      bantime = 86400

      [apache]
      enabled  = true
      port     = http,https
      filter   = apache-auth
      logpath  = /var/log/apache2/*error.log
      maxretry = 6

      [apache-noscript]
      enabled  = true
      port     = http,https
      filter   = apache-auth
      logpath  = /var/log/apache2/*error.log
      maxretry = 2

      [apache-owerflows]
      enabled  = true
      port     = http,https
      filter   = apache-auth
      logpath  = /var/log/apache2/*error.log
      maxretry = 6

      [apache-badbots]
      enabled  = true
      port     = http,https
      filter   = apache-badbots
      logpath  = /var/log/apache2/*error.log
      maxretry = 2

      #Les utilisateurs visitant un peu trop souvent une URL précise (au hasard, page de login - Brute Force)
      [apache-clientd]
      enabled = true
      port = http,https
      filter = apache-client-denied
      logpath = /var/log/apache2/*error.log
      maxretry = 3
      action = iptables[name=HTTP, port=http, protocol=tcp]
      bantime = 3600

      [ssh]
      enabled = true
      port    = ssh
      filter  = sshd
      logpath  = /var/log/auth.log
      maxretry = 3" > /etc/fail2ban/jail.conf

      systemctl restart fail2ban
    fi
    echo -e "${GREEN}Fail2Ban est configuré.${NC}"
    if [ $choix = 4 ]; then
      echo -e "${RED}Tu nous quittes :c.${NC}"
      exit 1
    fi
  done
fi