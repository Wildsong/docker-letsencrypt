#!/bin/bash
# This gets run from crontab to keep certificates up to date.

source .env
docker run --rm -v certs:/etc/letsencrypt:rw cc/certbot certonly \
       --cert-name ${CERTNAME} \
       --expand \
       -d ${DOMAINS} -m ${EMAIL} \
       --agree-tos \
       --deploy-hook=/etc/letsencrypt/renewal-hooks/deploy/bundle.sh \
       --disable-hook-validation \
       --max-log-backups=0 \
       --allow-subset-of-names \
       --dns-dnsmadeeasy --dns-dnsmadeeasy-credentials /usr/local/lib/dnsmadeeasy.ini \
       --quiet --noninteractive
