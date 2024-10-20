FROM ubuntu:22.04

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN curl -o- https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/outline/install.sh | bash -s -- --api-port 37280 --keys-port 58628

EXPOSE 37280 58628
