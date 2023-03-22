# apache2 - (ghcr.io/servercontainers/apache2-ssl-secure) (+ optional tls & php) on debian [x86 + arm]

_maintained by ServerContainers_

## What is it

This Dockerfile (available as ___ghcr.io/servercontainers/apache2-ssl-secure___) gives you a ready to use secured production apache2 server, with php and good configured optional SSL.

View in GitHub Registry [ghcr.io/servercontainers/apache2-ssl-secure](https://ghcr.io/servercontainers/apache2-ssl-secure)

View in GitHub [ServerContainers/docker-apache2-ssl-secure](https://github.com/ServerContainers/docker-apache2-ssl-secure)

This Dockerfile is based on the [/_/debian:bullseye/](https://registry.hub.docker.com/_/debian/) Official Image.

## Build & Versioning

You can specify `DOCKER_REGISTRY` environment variable (for example `my.registry.tld`)
and use the build script to build the main container and it's variants for _x86_64, arm64 and arm_

You'll find all images tagged like `d11.2-a1.18.0-6.1` which means `d<debian version>-a<apache version (with some esacped chars)>`.
This way you can pin your installation/configuration to a certian version. or easily roll back if you experience any problems
(don't forget to open a issue in that case ;D).

To build a `latest` tag run `./build.sh release`

## Changelogs

* 2023-03-20
    * github action to build container
    * implemented ghcr.io as new registry
    * moved from `MarvAmBass` to `ServerContainers`
* 2021-08-09
    * complete rework
    * added php, made tls optional
    * healthchecks
    * runit as service mangaer
    * multiarch build

## Environment variables and defaults

* __DISABLE\_TLS__
 * default: not set - if set yo any value `https` and the `HSTS_HEADERS_*` will be disabled

* __HSTS\_HEADERS\_ENABLE__
 * default: not set - if set to any value the HTTP Strict Transport Security will be activated on SSL Channel

* __HSTS\_HEADERS\_ENABLE\_NO\_SUBDOMAINS__
 * default: not set - if set together with __HSTS\_HEADERS\_ENABLE__ and set to any value the HTTP Strict Transport Security will be deactivated on subdomains


## Running ghcr.io/servercontainers/apache2-ssl-secure Container

This Dockerfile is not really made for direct usage. It should be used as base-image for your apache2 project. But you can run it anyways.

You should overwrite the _/etc/apache2/external/_ with a folder, containing your apache2 __\*.conf__ files (VirtualHosts etc.) and certs.

    docker run -d \
    -p 80:80 -p 443:443 \
    -v $EXT_DIR:/etc/apache2/external/ \
    ghcr.io/servercontainers/apache2-ssl-secure


