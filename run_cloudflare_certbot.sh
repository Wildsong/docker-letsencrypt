(host='acme-staging-v02.api.letsencrypt.org', port=443)#!/bin/bash
# This gets run from crontab to keep certificates up to date.
# Read options here https://eff-certbot.readthedocs.io/en/stable/using.html#configuration-file

source .env

function certbot () {

    # "certonly" obtains certs without installing them (except in /etc/letsencrypt of course)
    # Add this in case some domains aren't working: --allow-subset-of-names
    # --cert-name will add or remove names using the certificate as named
    # --expand will only add names to an existing cert

    docker run --rm -v certs:/etc/letsencrypt:rw --network host cc/certbot \
       certonly \
       -v \
       --cert-name certs \
       --expand \
       -d ${DOMAINS} \
       -m ${EMAIL} \
       --agree-tos \
       --deploy-hook=/etc/letsencrypt/renewal-hooks/deploy/bundle.sh \
       --disable-hook-validation \
       --max-log-backups=0 \
       --dns-cloudflare --dns-cloudflare-credentials /usr/local/lib/cloudflare.ini \
       --dns-cloudflare-propagation-seconds=30 \
       --noninteractive \

       #--dry-run
}

function update_hitch () {
    age=`docker run --rm -v certs:/etc/letsencrypt:rw debian stat -c '%Y' /etc/letsencrypt/hitch-bundle.pem`
    now=$(date +"%s")
    if (( ($now - $age) < (60 * 60) )); then
	echo $hitch changed
	#docker stack rm varnish
	docker compose -f ~/docker/varnish/compose.yaml down
	sleep 5
	# docker stack deploy --with-registry-auth -c $HOME/docker/varnish/compose.yaml varnish 
	docker compose -f ~/docker/varnish/compose.yaml up -d
    fi
}

certbot
./build_hitch_bundle.sh
update_hitch
