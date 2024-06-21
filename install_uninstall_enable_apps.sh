#!/usr/bin/env bash

# Description : Installation, désinstallation, activation, désactivation d'applications Nextcloud
# https://apps.nextcloud.com/
# Usage : ./install_uninstall_enable_apps.sh
# Licence : MIT
# Auteur : Cédric Goby
# Versioning : https://gitlab.com/CedricGoby/nextcloud-occ-scripts

# Liste des applications à désactiver
disable_apps=("firstrunwizard" "dashboard" "weather_status" "survey_client" "recommendations")

# Liste des applications à activer
enable_apps=("files_external")

# Liste des applications à installer
install_apps=("calendar" "richdocuments" "richdocumentscode" "assistant")

# Fonction pour désactiver les applications
disable_apps() {
  for app in "${disable_apps[@]}"
  do
    echo "Désactivation de l'application : $app"
    result=$(docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:disable "$app" 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "L'application $app a été désactivée avec succès."
    else
      echo "Erreur lors de la désactivation de l'application $app : $result"
    fi
  done
}

# Fonction pour activer les applications
enable_apps() {
  for app in "${enable_apps[@]}"
  do
    echo "Activation de l'application : $app"
    result=$(docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:enable "$app" 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "L'application $app a été activée avec succès."
    else
      echo "Erreur lors de l'activation de l'application $app : $result"
    fi
  done
}

# Fonction pour installer les applications
install_apps() {
  for app in "${install_apps[@]}"
  do
    echo "Installation de l'application : $app"
    result=$(docker exec -it --user www-data nextcloud-app php /var/www/html/occ app:install "$app" 2>&1)
    if [[ $? -eq 0 ]]; then
      echo "L'application $app a été installée avec succès."
    else
      echo "Erreur lors de l'installation de l'application $app : $result"
    fi
  done
}

# Appeler les fonctions
disable_apps
enable_apps
install_apps
