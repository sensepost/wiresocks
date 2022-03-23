# WireSocks

<a href="https://twitter.com/_cablethief"><img src="https://img.shields.io/badge/twitter-%40_cablethief-blue.svg" alt="@_cablethief" height="18">

![Docker Image](https://github.com/sensepost/wiresocks/actions/workflows/docker-image.yml/badge.svg)

Docker-compose and Dockerfile to setup a wireguard VPN connection to force TCP traffic through a socks proxy. 

I set this up after fighting with socks proxies and Windows offensive tooling.

The intention is to facilitate tooling on Windows and MacOS that ignore things like [proxychains](https://github.com/rofl0r/proxychains-ng), [proxifier](https://www.proxifier.com/), and [proxycap](https://www.proxycap.com/). This is done by using wireguard to VPN to a Linux which has routing and iptable rules to force TCP traffic via [RedSocks](https://github.com/darkk/redsocks) into a Socks5 proxy.  

## Warning

Currently this will only capture TCP traffic and not do DNS for you. So use `dig +tcp` to resolve hostnames and add it to your hosts file on your OS.

Docker-compose provided by ubuntu is old and doesnt support versions that allow networking fancyness. So please use a recent version of docker-compose if it complains about Versions.

# Usage

## Docker Compose

A docker-compose has been provided to setup both the redsocks and wireguard. 

Edit the variables as desired withing the `docker-compose.yml` and to start the stack in the background use:

```
docker-compose up -d
```

You can view the logs from redsocks to check what is being proxied and errors with:

```
docker-compose logs wiresocks
```

Docker-compose will also setup wireguard, depending on where you set your wireguard config directory you should be able to find the peer config you want to use. Grab that and edit it so that it is reasonable. AllowedIPs can be used to further target the internal network. 

*Keep in mind DNS is not yet working*

You can then take that wireguard config and place it into Windows or MacOS, or whatever OS you require and connect to the VPN. Now all traffic should be forced through the SOCKS proxy without hastle.


## Information about the redsocks docker

Runs a docker image with `--privileged=true --net=host` to capture all docker network traffic (docker0 by default) and redirect it into redsocks. 

Start the container:

```
docker run --privileged=true --net=host --rm -it ghcr.io/sensepost/wiresocks 1.2.3.4 3128
```

You can specify which ranges you want to have rediected to the socks proxy by providing a `WHITELIST` environment variable:

```
docker run --privileged=true --net=host -e WHITELIST=10.0.0.0/8 --rm -it ghcr.io/sensepost/wiresocks 1.2.3.4 3128
```

The `WHITELIST` may be comma seperated for multiple ranges:

```
docker run --privileged=true --net=host -e WHITELIST="10.0.0.0/8,192.168.0.0/24" --rm -it ghcr.io/sensepost/wiresocks 1.2.3.4 3128
```

Replace the IP and the port by those of your proxy.

The container will start redsocks and automatically configure iptable to forward **all** the TCP traffic (Unless `WHITELIST` is used) of the `$DOCKER_NET` interface (`docker0` by default) through the proxy.

You can specify the interface to capture traffic on by using the `DOCKER_NET` variable `-e DOCKER_NET=docker0`.

## Cleanup

Use docker/docker-compose stop to halt the container/s. The iptables rules should be reversed. If not, you can execute the command:

```
iptables-save | grep -v REDSOCKS | iptables-restore
```

# TODO

Future ideas:

 - Add capture for DNS
 - Try work out how to capture all UDP traffic into SOCKS

# Thanks

Uses Darkks [redsocks](https://github.com/darkk/redsocks/) which is amazing! 

Uses a modified version of [ncarliers](https://github.com/ncarlier/dockerfiles/tree/master/redsocks) redsocks docker to provide a whitelist and use a socks proxy.

Uses [LinuxServers wireguard](https://github.com/linuxserver/docker-wireguard) image to setup the wireguard vpn to connect into the socks network
