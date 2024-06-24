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
# Chemin OCC (Docker compose)
_docker_occ="/var/www/html/occ"

# Définition du quota
export _quota="2GB"
# Définition du groupe
#export _group=""

# On parcourt le fichier TSV des utilisateurs à importer dans Nextcloud
# -u bash 4.1 ou plus récent peut allouer un descripteur de fichier libre
# Sinon la commande docker-compose exec peut consumer stdin (la liste des lignes restantes).
while IFS=$'\t' read -u "$fd_num" _user _name _email _group; do

# Génération d'un mot de passe utlisateur
export OC_PASS="$(gpg --armor --gen-random 1 8)"
# Export des variables utilisateur
export _user="$_user"
export _name="$_name"
export _email="$_email"
export _group="$_group"

# Ajout de l'utilisateur dans Nextcloud (Docker)
docker exec -it -e OC_PASS="$OC_PASS" --user www-data "$_container_name" php "$_docker_occ" user:add --password-from-env --display-name="$_name" --group="$_group" $_user
# Paramétrage du compte utilisateur dans Nextcloud
docker exec -it --user www-data "$_container_name" php "$_docker_occ" user:setting "$_user" settings email "$_email"
docker exec -it --user www-data "$_container_name" php "$_docker_occ" user:setting "$_user" core lang fr
docker exec -it --user www-data "$_container_name" php "$_docker_occ" user:setting "$_user" files quota "$_quota"

# Destruction des variables utilisateur
unset OC_PASS
unset _user
unset _name
unset _email

# bash 4.1 ou plus récent peut allouer un descripteur de fichier libre {fd_num}
done {fd_num}<"$_src_users_to_add"


