#!/bin/bash
docker run --rm -v certs:/etc/letsencrypt:rw certbot/certbot certificates

