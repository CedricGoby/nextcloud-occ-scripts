#!/usr/bin/env bash

# Description : Importation d'utilisateurs dans Nextcloud depuis un fichier TSV avec la commande occ, 
# envoi par email des identifiants à l'utilisateur. 
# Usage : ./occ-ajout-utilisateur-csv-import.sh
# Licence : MIT
# Auteur : Cédric Goby
# Versioning : https://gitlab.com/CedricGoby/nextcloud-occ-scripts

# Fichier TSV d'entrée (utilisateurs à importer) séparé par des tabulations contenant les champs suivants : nom d'utilisateur, nom à afficher, adresse email.
# Le fichier TSV ne doit comporter ni en-têtes ni lignes vides.
_src_users_to_add="occ-ajout-utilisateur-csv-import.tsv"
# Fichier TSV de sortie (utilisateurs importés) séparé par des tabulations contenant les champs suivants : nom d'utilisateur, nom à afficher, mot de passe, groupe, adresse email, quota.
# Le fichier TSV ne doit comporter ni en-têtes ni lignes vides.
_src_added_users="occ-ajout-utilisateur-csv-import.log"
# Expéditeur du mail contenant les identifiants utilisateur
_from="me@domain.tld"
# URL Nextcloud
_url_nextcloud="https://sub.domain.org/"
# Service name Nextcloud (Docker compose)
_docker_nextcloud="app"
# Chemin OCC (Docker compose)
_docker_occ="/var/www/html/occ"

# Définition du quota
export _quota="100MB"
# Définition du groupe
export _group="mygroup"

# On parcourt le fichier TSV des utilisateurs à importer dans Nextcloud
# -u bash 4.1 ou plus récent peut allouer un descripteur de fichier libre
# Sinon la commande docker-compose exec peut consumer stdin (la liste des lignes restantes).
while IFS=$'\t' read -u "$fd_num" _user _name _email; do

# Génération d'un mot de passe utlisateur
export OC_PASS="$(gpg --armor --gen-random 1 8)"
# Export des variables utilisateur
export _user="$_user"
export _name="$_name"
export _email="$_email"

if [ -z "$_docker_nextcloud" ]; then
	# Ajout de l'utilisateur dans Nextcloud
	su -s /bin/sh www-data -c 'php /var/www/nextcloud/occ user:add --password-from-env --display-name="$_name" --group="$_group" $_user'

	# Paramétrage du compte utilisateur dans Nextcloud
	su -s /bin/sh www-data -c 'php /var/www/nextcloud/occ user:setting "$_user" settings email "$_email"'
	su -s /bin/sh www-data -c 'php /var/www/nextcloud/occ user:setting "$_user" core lang fr'
	su -s /bin/sh www-data -c 'php /var/www/nextcloud/occ user:setting "$_user" files quota "$_quota"'
else
	# Ajout de l'utilisateur dans Nextcloud (Docker compose)
	# Le script doit alors être exécuté depuis le répertoire contenant le fichier docker compose.
	docker-compose exec -T -e OC_PASS="$OC_PASS" --user www-data "$_docker_nextcloud" php "$_docker_occ" user:add --password-from-env --display-name="$_name" --group="$_group" $_user

	# Paramétrage du compte utilisateur dans Nextcloud (Docker compose)
	docker-compose exec -T --user www-data "$_docker_nextcloud" php "$_docker_occ" user:setting "$_user" settings email "$_email"
	docker-compose exec -T --user www-data "$_docker_nextcloud" php "$_docker_occ" user:setting "$_user" core lang fr
	docker-compose exec -T --user www-data "$_docker_nextcloud" php "$_docker_occ" user:setting "$_user" files quota "$_quota"
fi

# Envoi des identifiants à l'utilisateur par email avec msmtp
msmtp -d -a default -t <<END
From: $_from
To: $_email
Content-Type: text/plain; charset=UTF-8
Subject: $_name - Vos identifiants Nextcloud

Bonjour $_name,

Veuillez trouver ci-dessous vos identifiants Nextcloud...

$_url_nextcloud
Utilisateur : $_user
Mot de passe : $OC_PASS

...et les bonnes pratiques et logiciels pour gérer vos mots de passe :
https://www.cybermalveillance.gouv.fr/tous-nos-contenus/bonnes-pratiques/mots-de-passe

Ceci est un email automatique, merci de ne pas répondre à ce message.

Bonne journée

END

# Création (si besoin) d'un fichier TSV des utilisateurs importés dans Nextcloud.
# Attention, le mot de passe est enregistré en clair.
# printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$_user" "$_name" "$OC_PASS" "$_group" "$_email" "$_quota" >> "$_src_added_users"

# Destruction des variables utilisateur
unset OC_PASS
unset _user
unset _name
unset _email

# bash 4.1 ou plus récent peut allouer un descripteur de fichier libre {fd_num}
done {fd_num}<"$_src_users_to_add"
