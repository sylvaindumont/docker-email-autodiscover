# docker-email-autodiscover

This service is created to autodiscover your provider email settings.
The service is kept simple and listens only on port 80. To enable ssl certificates use jwilder/nginx-proxy.

## Usage

#### Get the latest image

    docker pull jsmitsnl/docker-email-autodiscover:latest

#### DNS settings

For the case you are using Bind and have the autoconfig HTTP server running on the same IP your `www.` subdomain resolves to, you can use this DNS records to configure your nameserver

```
autoconfig              IN      CNAME   www
autodiscover            IN      CNAME   www

@                       IN      MX 10   {{$MX_DOMAIN}}.
@                       IN      TXT     "mailconf=https://autoconfig.{{$DOMAIN}}/mail/config-v1.1.xml"
_imaps._tcp             SRV 0 1 993     {{$MX_DOMAIN}}.
_submission._tcp        SRV 0 1 465     {{$MX_DOMAIN}}.
_autodiscover._tcp      SRV 0 0 443     autodiscover.{{$DOMAIN}}.
```

Instead of a CNAME, you can of course also choose an A-record

```
autoconfig              IN      A      {{$AUTODISCOVER_IP}}
autodiscover            IN      A      {{$AUTODISCOVER_IP}}
```

Replace above variables with data according to this table

Variable         | Description
-----------------|-------------------------------------------------------------
MX_DOMAIN        | The hostname name of your MX server
DOMAIN           | Your apex/bare/naked Domain
AUTODISCOVER_IP  | IP of the Autoconfig HTTP

---

#### Create a `docker-compose.yml`

Adapt this file with your FQDN. Install [docker-compose](https://docs.docker.com/compose/) in the version `1.6` or higher.

```yaml
version: '2'

services:
  mail:
    image: jsmitsnl/docker-email-autodiscover:latest
    hostname: autodiscover
    domainname: domain.com
    container_name: autodiscover
    restart: always
    ports:
    - "80:80"
    environment:
    - COMPANY_NAME=my company
    - SUPPORT_URL=https://support.domain.com
    - DOMAIN=domain.com
    - IMAP_HOST=imap.domain.com
    - IMAP_PORT=993
    - SMTP_HOST=smtp.domain.com
    - SMTP_PORT=587
```

__ssl support with jwilder__:

```yaml
version: '2'

services:
  mail:
    image: jsmitsnl/docker-email-autodiscover:latest
    hostname: autodiscover
    domainname: domain.com
    container_name: autodiscover
    restart: always
    links:
    - nginx_proxy
    environment:
    - COMPANY_NAME=my company
    - SUPPORT_URL=https://support.domain.com
    - DOMAIN=domain.com
    - IMAP_HOST=imap.domain.com
    - IMAP_PORT=993
    - SMTP_HOST=smtp.domain.com
    - SMTP_PORT=587
    - VIRTUAL_HOST=autoconfig.domain.com,autodiscover.domain.com
    - LETSENCRYPT_HOST=autoconfig.domain.com,autodiscover.domain.com
    - LETSENCRYPT_EMAIL=support@domain.com

  nginx_proxy:
    image: jwilder/nginx-proxy:alpine
    hostname: nginx_proxy
    domainname: domain.com
    container_name: nginx_proxy
    restart: always
    ports:
      - 80:80
      - 443:443
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./nginx_proxy/config/template/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro
      - ./nginx_proxy/config/certs:/etc/nginx/certs:ro
      - ./nginx_proxy/config/my_proxy.conf:/etc/nginx/conf.d/my_proxy.conf:ro
      - /etc/nginx/vhost.d
      - /usr/share/nginx/html
    environment:
      - ENABLE_IPV6=true
    labels:
      - com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy=true
    cap_add:
      - NET_ADMIN

    letsencrypt_companion:
      image: jrcs/letsencrypt-nginx-proxy-companion
      container_name: letsencrypt_companion
      volumes_from:
        - nginx_proxy
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock:ro
        - ./nginx_proxy/config/certs:/etc/nginx/certs:rw
      restart: always
```
