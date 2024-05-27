#!/bin/bash

# Has to have a rw certs volume so it can use a lock file.
docker run --rm -v certs:/etc/letsencrypt:rw certbot/certbot certificates

