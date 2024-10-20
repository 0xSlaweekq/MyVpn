FROM ubuntu:22.04

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN apt update
RUN apt autoclean -y &&\
    apt autoremove --purge -y &&\
    apt clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -o- https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/3proxy/install.sh | bash

EXPOSE 3128 2525
