# docker-letsencrypt

This project runs from scripts and the Docker containers are
short-lived. They check on and renew certs and then exit.

There are options here for "DNS Made Easy", "Cloudflare", and nothing,
which uses a local web server that's part of certbot.  

This project was split off from docker-varnish, because
I need certificates for more than just web sites now. For
example, for my mail server.

## Prerequisites

Your firewall must route traffic for port 80, it's used for
the challenge server.

Hitch needs certificates. (That's why it exists after all, to do TLS.)
This project is set up to support it, but since it's running the
Let's Encrypt certbot behind the scenes it can be used for other apps
as well.

You need to have a dhparams.pem file. It will be baked into the
certbot images; the deploy hook script will copy dhparams.pem into the
certificate bundle.  You should only have to create the dhparams.pem
file one time, then add to your certs volume so that containers get
get to it.

You need openssl, and you need to be able to copy the file into a volume.

   openssl dhparam 2048 > dhparams.pem
   docker run -it -v certs:/etc/letsencrypt -n certs debian
   docker cp dhparam.pem certs:/etc/letsencrypt

## Build certbot and create certificates

Build the correct Certbot image for your configuration. I use
DNSMadeEasy in this example.  **There are secrets in this image, so do
not send it to a public registry.**

Using DNSMadeEasy
   docker buildx build -f Dockerfile.dnsmadeeasy -t cc/certbot .
   docker run --rm cc/certbot --version
   ./run_dnsmadeeasy_certbot.sh certbot.sh

ELSE use Cloudflare API
   docker buildx build -f Dockerfile.cloudflare -t cc/certbot .
   docker run --rm cc/certbot --version
   ./run_cloudflare_certbot.sh

ELSE use the challenge server
    ./run_certbot.sh
    
## Note on combined "expanded" certificates

When I first started working with Let's Encrypt I was using one
certificate for each name, so for example I had one for
giscache.clatsopcounty.gov and one for giscache.co.clatsop.or.us. Then
I found the "--expand" option, which takes the full list of names and
returns one certificate that works for all of them. This made life
easier.

My .env file has this line:

DOMAINS="echo.clatsopcounty.gov,echo.co.clatsop.or.us,giscache.clatsopcounty.gov,giscache.co.clatsop.or.us"

Because "echo" is listed first, the live certificate will be listed under that name and
all the other names will be included. List all certifcates and see for yourself what you have.

```bash
docker run --rm -v certs:/etc/letsencrypt cc/certbot certificates
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
  Certificate Name: echo.clatsopcounty.gov
    Serial Number: 3a8cc8c03449e1b27bc713c01175a017a91
    Key Type: ECDSA
    Domains: echo.clatsopcounty.gov echo.co.clatsop.or.us giscache.clatsopcounty.gov giscache.co.clatsop.or.us
    Expiry Date: 2023-06-27 14:24:03+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/echo.clatsopcounty.gov/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/echo.clatsopcounty.gov/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

I just accidentally deleted certs/hitch-bundle.pem, oops. I recreated it, like this

  ./build_hitch_bundle.sh


TODO - If I was really diligent I'd script something to create the
hitch.conf file from that output.

Currently there are still some old certificate directories hanging
around on my servers but you can see which ones are in use by using
the "certbot certificates" command. You can delete the others, then
they will stop showing up in the output of the "certonly" command used
to renew everything.

If you have a reason to pull many certificates, remove the '--expand'
option in cerbot.yaml.

*At this point you should be ready to attempt to request some certificates.* (Or maybe just one, combined.)

***When you are done testing, remember to comment out the "--dry-run"
   option in the run*.sh script that you use, so that it will really fetch
   certificates (or renew them.)***

DNSMadeEasy and Cloudflare do not need the challenge server,
which means it can run fully isolated behind a firewall,
but I can't always choose which DNS
service is used.

### What if I have existing certificates?

You can try to copy them but it's not worth it. Get everything set up and switch over. Just test Certbot with --dry-run until you are comfortable that it's pulling certificates correctly.

### Checking on the status of certificates

You should be able to check the status of your certificates any time, note
that you have to allow read/write access for this to work

   docker run --rm -v certs:/etc/letsencrypt certbot/certbot certificates
   docker run --rm -v certs:/etc/letsencrypt certbot/certbot show_account

The first command is in the file check_certs.sh

#### Run it periodically

Let's Encrypt certificates are good for 90 days, so run the certbot from crontab, 
but don't do it more than once a day or you will get banned. 

   crontab -e
   # Renew certificates once a week
   23 4  * * 0  cd $HOME/docker/letsencrypt && ./run_certbot.sh


## Resources

### Cloudflare

Cloudflare API tokens, find them in your Cloudflare **profile** and look in the left bar for "API Tokens". 

https://dash.cloudflare.com/profile/api-tokens

Cloudflare plugin needs a token Zone - Zone - Read and Zone - DNS - Edit and I set one for map46.com only.

### Certbot

Certbot set up on Debian
https://certbot.eff.org/instructions?ws=nginx&os=debiantesting

