# projet-infra-si
> *LEFEVRE Cameron, JAUDINOT Martin, GUARATO Kevin, SOURISSEAU Maël*

> Combinaison du `Projet 5 : Serveur Web` et du `Projet 3 : VPN`

# Instructions

Le projet consiste a créer plusieurs services Web sous HTTPS disponibles sur un nom de domaine personnalisé, chaque sous domaine ayant un service différent (image host, blog, etc..)

# Les services

* Le site principal `https://$MAIN_DOMAIN`
  * Galerie d'images avec upload
  * Interface web simple

* L'API backend: `https://$MAIN_DOMAIN/api`
  * Service Go pour l'upload d'images

* Le Wekan (clone de Trello) `https://$WEKAN_SUBDOMAIN`
  * Kanban board avec MongoDB

* Le VPN Wireguard
  * Configuration automatique des clients

# Configuration des domaines

Le projet utilise un système de configuration pour les noms de domaine via un fichier `.env`. Cela permet de changer facilement les domaines sans modifier le code :

```
MAIN_DOMAIN=xxx.fr
WEKAN_SUBDOMAIN=wekan.xxx.fr
```

# Installation

## Prérequis

- Docker et Docker Compose installés
- Git pour cloner le dépôt
- **Local**: Permisions administrateurs pour modifier le fichier hosts

## Étapes d'installation

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/maelsrs/projet-infra-si.git
   cd projet-infra-si
   ```

2. Configurez le fichier `.env` avec vos domaines (ou utilisez les valeurs par défaut) :
   ```
   MAIN_DOMAIN=xxx.fr
   WEKAN_SUBDOMAIN=wekan.xxx.fr
   ```

3. Exécutez le script de démarrage :
   ```bash
   # Sur Linux/macOS
   chmod +x start.sh
   ./start.sh
   
   # Sur Windows
   start.bat
   ```

4. **Local**: Ajoutez les entrées dans votre fichier hosts :
   ```
   127.0.0.1 xxx.fr
   127.0.0.1 wekan.xxx.fr
   127.0.0.1 www.xxx.fr
   ```
   - Sur Windows : modifiez `C:\Windows\System32\drivers\etc\hosts`
   - Sur Linux/macOS : modifiez `/etc/hosts` (avec sudo)

## Accès aux services

Une fois les conteneurs démarrés et le fichier hosts configuré, vous pouvez accéder aux services :

- Site principal : http://xxx.fr
- Wekan : http://wekan.xxx.fr
- API d'upload : http://xxx.fr/api/upload (POST pour télécharger des images)

## Configuration du VPN Wireguard

Le VPN Wireguard est automatiquement configuré avec 3 clients par défaut. Les fichiers de configuration sont générés dans le répertoire `wireguard/config/` :

- Client 1 : `wireguard/config/peer1/peer1.conf`
- Client 2 : `wireguard/config/peer2/peer2.conf`
- Client 3 : `wireguard/config/peer3/peer3.conf`

Pour utiliser le VPN :
1. Installez le client Wireguard sur votre appareil (disponible pour Windows, macOS, Linux, iOS, Android)
2. Importez le fichier de configuration (.conf) correspondant à l'un des pairs
3. Activez la connexion VPN

# Structure du projet

```
projet-infra-si/
├── .env                   # Configuration des domaines
├── backend/               # API Go pour l'upload d'images
├── Dockerfile             # Configuration du conteneur web
├── docker-compose.yml     # Configuration des services
├── frontend/              # Interface web
├── nginx.conf.template    # Template de configuration Nginx
├── start.sh               # Script de démarrage (Linux/macOS)
├── start.bat              # Script de démarrage (Windows)
├── start-container.sh     # Script de démarrage interne du conteneur
├── wekan/                 # Données persistantes pour Wekan
└── wireguard/             # Configuration et données VPN
```
