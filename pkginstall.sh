#!/bin/bash -e

# Messages en couleur
error()    { echo -e "\033[0;31m====> $*\033[0m" ;}
message()  { echo -e "\033[0;32m====> $*\033[0m" ;}
warning()  { echo ; echo -e "\033[0;33m====> $*\033[0m" ;}

# Vérification des droits root
if [[ "$USER" != "root" ]]; then
  error "Droits root nécessaires"
  exit 0
fi

# Chargement du fichier de config
cfg="$(dirname "$(realpath "$0")")/pkginstall.cfg"
if [[ ! -f $cfg ]]; then
  error "Fichier $cfg introuvable"
  exit 1
else
  . $cfg
fi

# Config selon la distribution
dist=$(grep "^ID=" /etc/os-release | cut -d= -f2,2 | tr -d '"')
list="$(dirname "$0")/config/$dist.lst"

# Installation des paquets
warning "Installation des paquets..."
case $dist in
  debian|ubuntu)
    apt update && apt -y full-upgrade
    if [[ -f $list ]]; then
      apt -y install $(cat $list | grep -v '#')
      # Activation des mises à jour automatiques
      if [[ -f /usr/bin/unattended-upgrades ]]; then
        dpkg-reconfigure unattended-upgrades
      fi
    fi
    ;;
  fedora)
    dnf -y upgrade
    if [[ -f $list ]]; then
      dnf -y install $(cat $list | grep -v '#')
    fi
    ;;
esac
message "Paquets installés"

# Activation de locate
if [[ -f /usr/bin/locate ]]; then
  updatedb
fi

# Sécurisation de ssh (check sur https://www.ssh-audit.com)
if [[ -d /etc/ssh/sshd_config.d ]] && [[ ! -f /etc/ssh/sshd_config.d/$(id -un 1000).conf ]]; then
  warning "Sécurisation de SSH..."
  echo -e "# Secure Config\nX11Forwarding no\nAllowUsers $(id -un 1000)\nHostKey /etc/ssh/ssh_host_ed25519_key\nPasswordAuthentication yes\nKexAlgorithms curve25519-sha256@libssh.org\nMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com\nCiphers aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr" > /etc/ssh/sshd_config.d/$(id -un 1000).conf
  systemctl restart sshd
  message "SSH sécurisé"
fi

# Activation du Firewall (avec désactivation de l'IP v6)
if [[ -f /usr/sbin/ufw ]]; then
  warning "Activation du firewall ufw..."
  if [[ $ufwipv6 = "false" ]]; then
    sed -i "s,IPV6=yes,IPV6=no," /etc/default/ufw
  fi
  if [[ -n $ufwports ]]; then
    for port in $ufwports; do
      ufw allow $port
    done
  fi
  ufw enable
  message "ufw activé"
fi
