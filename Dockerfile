FROM ubuntu:22.04

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

RUN apt update
RUN apt autoclean -y &&\
    apt autoremove --purge -y &&\
    apt clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -o- https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/3proxy/install.sh | bash
RUN curl -o- https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/3x-ui/install.sh | bash
RUN curl -o- https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/outline/install.sh | bash -s -- --api-port 37280 --keys-port 58628

RUN cat <<EOF
# 3proxy
  3128 Port for connect
  2525

# 3x-ui
  2053 Default port for connect
  admin username
  admin password

# outline
  37280 The port number for the management API
  58628 The port number for the access keys
EOF

EXPOSE 3128 2525 2053 5555 37280 58628
