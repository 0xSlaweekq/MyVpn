## Installing to machine

```BASH
curl -o- https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/vpn-install.sh | sudo bash
```

## Installation - Docker

### 3proxy

```
docker pull slaweekq/3proxy:latest && \
  docker run -d --tty \
  -p 3128:3128 \
  -p 2525:2525 \
  slaweekq/3proxy:latest
```

### 3x-ui

```BASH
docker pull slaweekq/3x-ui:latest && \
  docker run -d --tty \
  -p 2053:2053 \
  -p 5555:5555 \
  slaweekq/3x-ui:latest
```

### Outline

```BASH
docker pull slaweekq/outline:latest && \
  docker run -d --tty \
  -p 37280:37280 \
  -p 58628:58628 \
  slaweekq/outline:latest
```

## Full docker: 3proxy, 3x-ui and outline

```BASH
docker pull slaweekq/myvpn:latest && \
  docker run -d --tty \
  -p 3128:3128 \
  -p 2525:2525 \
  -p 2053:2053 \
  -p 5555:5555 \
  -p 37280:37280 \
  -p 58628:58628 \
  slaweekq/myvpn:latest
```


## 💗 Donation

If you find this project useful and would like to support its development, you can make a donation.

### TON

```
UQDqd8rfkOq_TTUBzyMalvJhHeP4hPezjkSyA92mb24VK4Oh
```
