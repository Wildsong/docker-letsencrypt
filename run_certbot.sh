#!/bin/bash -x
# This gets run from crontab to keep certificates up to date.
#
# It HAS to be able to run on port 80, so that it can do the challenge server thing.
# Run it once a week to renew certs before they expire

source .env
docker run --rm -p 80:80 -v certs:/etc/letsencrypt:rw certbot/certbot certonly \
       --cert-name certs \
       --expand \
       -d ${DOMAINS} -m ${EMAIL} \
       --agree-tos \
       --deploy-hook=/etc/letsencrypt/renewal-hooks/deploy/bundle.sh \
       --disable-hook-validation \
       --max-log-backups=0 \
       --allow-subset-of-names \
       --standalone \
       --noninteractive
