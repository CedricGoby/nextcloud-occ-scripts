#!/usr/bin/env bash

# Description : Importation d'utilisateurs dans Nextcloud depuis un fichier TSV avec la commande occ,
# envoi par email des identifiants à l'utilisateur.
# Usage : ./install_uninstall_enable_apps.sh
# Licence : MIT
# Auteur : Cédric Goby
# Versioning : https://gitlab.com/CedricGoby/nextcloud-occ-scripts

# Remove apps
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:remove firstrunwizard
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:remove dashboard


# Enable apps
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:enable files_external

# Install apps
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install calendar
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install richdocuments
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install richdocumentscode



Liste des applications
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:list

docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:list --shipped false


docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:enable files_external


