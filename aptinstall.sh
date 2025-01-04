#!/bin/dash
set -e

dir=$(dirname "$0")

## Vérification des droits root
if [ "$USER" != "root" ] ; then
  echo "Droits root nécessaires"
  exit 0
fi

## Installation des paquets
apt update && apt -y full-upgrade
list="$dir/aptinstall.lst"
if [ -f $list ] ; then
  apt -y install $(cat $list | grep -v '#')
fi

## Activation de locate
if [ -f /usr/bin/locate ] ; then
  updatedb
fi

## Activation des mises à jour automatiques
if [ -f /usr/bin/unattended-upgrades ] ; then
  dpkg-reconfigure unattended-upgrades
fi

## Sécurisation de ssh (check sur https://www.ssh-audit.com/#)
if [ ! -f /etc/ssh/sshd_config.old ] ; then
  cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.old
  echo "" >> /etc/ssh/sshd_config 
  echo "# Secure Config\nX11Forwarding no\nAllowUsers $(id -un 1000)\nHostKey /etc/ssh/ssh_host_ed25519_key\nPasswordAuthentication yes\nKexAlgorithms curve25519-sha256@libssh.org\nMACs hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com\nCiphers -chacha20-poly1305@openssh.com" >> /etc/ssh/sshd_config
  systemctl restart sshd
fi

## Correction du bug fail2ban
if [ -f /etc/fail2ban/jail.conf ] ; then
  sed -i "s,backend = %(sshd_backend)s,backend = systemd," /etc/fail2ban/jail.conf
  systemctl restart fail2ban
fi

## Activation du Firewall (avec désactivation de l'IP v6)
if [ -f /usr/sbin/ufw ] ; then
  ufw allow ssh
  sed -i "s,IPV6=yes,IPV6=no," /etc/default/ufw
  ## Ajout pour Podman
  ufw allow in on podman1
  ufw default allow FORWARD
  ufw enable
fi
