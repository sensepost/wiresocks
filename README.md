# WireSocks

<a href="https://twitter.com/_cablethief"><img src="https://img.shields.io/badge/twitter-%40_cablethief-blue.svg" alt="@_cablethief" height="18"></a>  <a href="https://github.com/sensepost/wiresocks/actions/workflows/docker-image.yml"><img src="https://github.com/sensepost/wiresocks/actions/workflows/docker-image.yml/badge.svg" alt="docker builds" height="18"></a> 

Docker-compose and Dockerfile to setup a wireguard VPN connection to force TCP traffic through a socks proxy. 

I set this up after fighting with socks proxies and Windows offensive tooling.

The intention is to facilitate tooling on Windows and MacOS that ignore things like [proxychains](https://github.com/rofl0r/proxychains-ng), [proxifier](https://www.proxifier.com/), and [proxycap](https://www.proxycap.com/). This is done by using wireguard to VPN to a Linux which has routing and iptable rules to force TCP traffic via [tun2socks](https://github.com/xjasonlyu/tun2socks) into a Socks5 proxy.  

## Warning

Currently this will only capture TCP traffic and not do DNS for you. So use the coredns file with wireguard to configure a tcp dns forwarder. Please see the [DNS](##DNS) section below.

Docker-compose provided by ubuntu is old and doesnt support versions that allow networking fancyness. So please use a recent version of docker-compose if it complains about Versions.

# Usage

## Docker Compose

A docker-compose has been provided to setup both the tun2socks and wireguard. 

Edit the variables as desired withing the `docker-compose.yml` and to start the stack in the background use:

```
docker-compose up -d
```

You can view the logs from tun2socks to check what is being proxied and errors with:

```
docker-compose logs wiresocks
```

Docker-compose will also setup wireguard, depending on where you set your wireguard config directory you should be able to find the peer config you want to use. Grab that and edit it so that it is reasonable. AllowedIPs can be used to further target the internal network. 

You can then take that wireguard config and place it into Windows or MacOS, or whatever OS you require and connect to the VPN. Now all traffic should be forced through the SOCKS proxy without hastle.

## DNS

For DNS I have provided a example Corefile for CoreDNS which will take DNS requests for a specific domain and forward them on but with TCP. This effectivly gets us DNS through the SOCKS tunnel. So for DNS to work you will need to edit the domain and DNS server to use.

This file gets mounted in the Wireguard docker to be used by the VPN so that if your client is using the DNS provided by the docker it should be able to resolve DNS through the SOCKS proxy using the domain and server you provided.

## Information about the tun2socks docker

Runs a docker image with `--cap-add=NET_ADMIN --sysctl="net.ipv4.ip_forward=1" --device=/dev/net/tun:/dev/net/tun` to allow the container to create a tun interface as well as set routes for it. 

You specify the socks proxy using the `PROXY` environment variable, make sure your docker can reach that proxy. 

```
-e PROXY=socks5://socksaddress:1080
```

You can specify which ranges you want to have rediected to the socks proxy by providing a `TUN_INCLUDED_ROUTES` environment variable:

```
-e TUN_INCLUDED_ROUTES=192.168.165.0/24
```

The `TUN_INCLUDED_ROUTES` may be comma seperated for multiple ranges.

The container will start tun2socks and configure routes to forward traffic of the routes provided in `TUN_INCLUDED_ROUTES` through the created TUN interface.

## Socksing other dockers

You can use the `--net container:wiresocks` option with other dockers to get them to share the same network namespace as the wiresocks docker. This includes the setup routes as well as access to the TUN interface.
This essentially means you can tunnel arbitary dockers using tun2socks with this option. In the docker-compose we use it for WireGuard so that Windows/MacOS just need a WireGuard config and they can have their traffic transparently proxied. 

# Other

## Thanks

Original idea used Darkks [redsocks](https://github.com/darkk/redsocks/) which is amazing! 

This version uses the equally amazing [tun2socks](https://github.com/xjasonlyu/tun2socks) by xjasonlyu! 

Uses [LinuxServers wireguard](https://github.com/linuxserver/docker-wireguard) image to setup the wireguard vpn to connect into the socks network

## license

`WireSocks` is licensed under a [GNU General Public v3 License](https://www.gnu.org/licenses/gpl-3.0.en.html). Permissions beyond the scope of this license may be available at <http://sensepost.com/contact/>.