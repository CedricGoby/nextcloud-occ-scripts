#!/usr/bin/env bash

# Description : Importation d'utilisateurs dans Nextcloud depuis un fichier TSV avec la commande occ,
# envoi par email des identifiants à l'utilisateur.
# Usage : ./add_users.sh
# Licence : MIT
# Auteur : Cédric Goby
# Versioning : https://gitlab.com/CedricGoby/nextcloud-occ-scripts

# Fichier TSV d'entrée (utilisateurs à importer) séparé par des tabulations contenant les champs suivants : nom d'utilisateur, nom à afficher, adresse email.
# Le fichier TSV ne doit comporter ni en-têtes ni lignes vides.
_src_users_to_add="add_users.tsv"
# URL Nextcloud
_url_nextcloud=""
# Définition du quota
_quota="10GB"
# Définition du groupe
#export _group=""
# Nom du conteneur Nextcloud
_container_name="nextcloud-app"
# On parcourt le fichier TSV des utilisateurs à importer dans Nextcloud
while IFS=$'\t' read -u "$fd_num" _user _name _email _group; do


# Le script est executé sur l'hôte docker
if grep -q systemd <<< $(cat /proc/1/sched | head -n 1); then

    # Génération d'un mot de passe utlisateur
    export OC_PASS="$(gpg --armor --gen-random 1 8)"

    # Ajout de l'utilisateur dans Nextcloud
    docker exec -it -e OC_PASS="$OC_PASS" --user www-data "$_container_name" php /var/www/html/occ user:add --password-from-env --display-name="$_name" --group="$_group" $_user
    # Paramétrage du compte utilisateur dans Nextcloud
    docker exec -it --user www-data "$_container_name" php /var/www/html/occ user:setting "$_user" settings email "$_email"
    docker exec -it --user www-data "$_container_name" php /var/www/html/occ user:setting "$_user" core lang fr
    docker exec -it --user www-data "$_container_name" php /var/www/html/occ user:setting "$_user" files quota "$_quota"

# Le script est executé dans le conteneur
else
    # Génération d'un mot de passe utlisateur
    _password="$(gpg --armor --gen-random 1 8)"

    # Ajout de l'utilisateur dans Nextcloud
    php /var/www/html/occ user:add "$_password" --display-name="$_name" --group="$_group" $_user
    # Paramétrage du compte utilisateur dans Nextcloud
    php /var/www/html/occ user:setting "$_user" settings email "$_email"
    php /var/www/html/occ user:setting "$_user" core lang fr
    php /var/www/html/occ user:setting "$_user" files quota "$_quota"
fi

done {fd_num}<"$_src_users_to_add"


