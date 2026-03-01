# aptinstall.sh

Script automatisant l'installation et le paramétrage de Debian/Ubuntu.

## Fonctionnalités

- Installe les paquets présents dans le fichier `config/<votre_os>.cfg`

- Sécurise le serveur SSH et limite l'accès à l'utilisateur par défaut

- Active le firewall UFW si installé

- Configure unattended-upgrades si installé

- Modifie les paramètres de fail2ban si installé

- Active la commande locate si installée

## Configuration

Un fichier de configuration `aptinstall.cfg` est présent pour configurer la mise à jour automatique et les éléments du firewall UFW.
Vous pouvez spécifier les ports à autoriser (séparés par des espaces), ainsi qu'indiquer si vous désirez désactiver l'ipv6.

Le fichier de configuration :

```txt
# aptinstall config
unattended=false
ufwenable=false
ufwipv6=false
ufwports="22/tcp 80/tcp 443/tcp"
```

## Utilisation

Pour exécuter le script, vous devez disposer des droits root :

```bash
sudo ./aptinstall.sh
```
