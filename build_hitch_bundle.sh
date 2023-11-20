#!/bin/bash
#
#  Build the hitch-bundle.pem file from existing cert files.
#  If there are files missing try running the run_*.sh script for your setup.
#  It relies on CERTNAME from your .env file.
#  
docker run --rm --env-file=.env -v certs:/etc/letsencrypt debian /usr/bin/bash -c '
  cd /etc/letsencrypt/live/$CERTNAME
  cat privkey.pem fullchain.pem ../../dhparams.pem > /etc/letsencrypt/hitch-bundle.pem
  ls -l /etc/letsencrypt/hitch-bundle.pem
'


