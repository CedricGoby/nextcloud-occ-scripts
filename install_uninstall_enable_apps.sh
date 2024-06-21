#!/usr/bin/env bash

# Description : Installation, désinstallation, activation, désactivation d'applications Nextcloud
# https://apps.nextcloud.com/
# Usage : ./install_uninstall_enable_apps.sh
# Licence : MIT
# Auteur : Cédric Goby
# Versioning : https://gitlab.com/CedricGoby/nextcloud-occ-scripts

# DISABLE shipped apps
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:disable firstrunwizard
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:disable dashboard
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:disable weather_status
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:disable survey_client
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:disable recommendations

# ENABLE apps
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:enable files_external

# INSTALL apps
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install calendar
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install richdocuments
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install richdocumentscode
docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install assistant