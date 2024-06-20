#!/usr/bin/env bash

# Description : Importation d'utilisateurs dans Nextcloud depuis un fichier TSV avec la commande occ,
# envoi par email des identifiants à l'utilisateur.
# Usage : ./occ-ajout-utilisateur-csv-import.sh
# Licence : MIT
# Auteur : Cédric Goby
# Versioning : https://gitlab.com/CedricGoby/nextcloud-occ-scripts

# Fichier TSV d'entrée (utilisateurs à importer) séparé par des tabulations contenant les champs suivants : nom d'utilisateur, nom à afficher, adresse email.
# Le fichier TSV ne doit comporter ni en-têtes ni lignes vides.
_src_users_to_add="occ-ajout-utilisateur-tsv-import.tsv"

# Container _name
_container_name="nextcloud-app"

# Chemin OCC (Docker compose)
_docker_occ="/var/www/html/occ"

# Définition du groupe
export _target_group="tout-le-monde"

# On parcourt le fichier TSV des utilisateurs à importer dans Nextcloud
# -u bash 4.1 ou plus récent peut allouer un descripteur de fichier libre
# Sinon la commande docker-compose exec peut consumer stdin (la liste des lignes restantes).
while IFS=$'\t' read -u "$fd_num" _user _name _email _group; do

# Export des variables utilisateur
export _user="$_user"

# Paramétrage du compte utilisateur dans Nextcloud
docker exec -it --user www-data "$_container_name" php "$_docker_occ" group:adduser "$_target_group" "$_user"

# Destruction des variables utilisateur
unset _user

# bash 4.1 ou plus récent peut allouer un descripteur de fichier libre {fd_num}
done {fd_num}<"$_src_users_to_add"
