#!/bin/bash
docker run -it --rm -v certs:/etc/letsencrypt:rw certbot/certbot delete

