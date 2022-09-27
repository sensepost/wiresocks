# WireSocks

<a href="https://twitter.com/_cablethief"><img src="https://img.shields.io/badge/twitter-%40_cablethief-blue.svg" alt="@_cablethief" height="18"></a>  <a href="https://github.com/sensepost/wiresocks/actions/workflows/docker-image.yml"><img src="https://github.com/sensepost/wiresocks/actions/workflows/docker-image.yml/badge.svg" alt="docker builds" height="18"></a>

Docker-compose and Dockerfile to setup a wireguard VPN connection, forcing specific TCP traffic through a socks proxy.

I set this up after fighting with socks proxies and Windows offensive tooling.

The intention is to facilitate tooling on Windows and MacOS that ignore things like [proxychains](https://github.com/rofl0r/proxychains-ng), [proxifier](https://www.proxifier.com/), and [proxycap](https://www.proxycap.com/). This is done by leveraging a wireguard to VPN to a Linux host running this project which has routing setup to force traffic via [tun2socks](https://github.com/xjasonlyu/tun2socks) into a Socks5 proxy.  

## Warning

`docker-compose` provided by ubuntu (and other distributions) is old and doesnt support versions that allow networking fancyness. Please make sure you are using a recent version `of docker-compose`. One way to check if you have a recent enough version is to run `docker compose version`. If either the command is not available, or the version reported is not at least version 2.10+, then you need to upgrade.

## Usage

A `docker-compose` has been provided to setup both the tun2socks and wireguard.

Copy the example `.env.example` file to `.env` and tweak the values as needed (it should have enough documentation to know what each value is for). Then, start the stack with:

```bash
docker-compose up -d
```

You can view the logs from tun2socks to check what is being proxied and errors with:

```bash
docker-compose logs -f
```

The docker-compose will also setup wireguard and you should be able to find the peer config you want to use in the `./config/peer*` directories (depending on how many peers you configured). Grab that and import it into your client where you want to proxy communications from.

**Note:** In some cases it may be useful to add the `PersistentKeepalive = 2` directive in the `[peer]` section if you experience random timeouts.

Now all traffic should be forced through the SOCKS proxy without hastle for the networks you want to reach, together with DNS.

### DNS

For DNS we leverage CoreDNS to translate DNS requests for a specific domain and forward them using a TCP lookup. This effectivly gets us DNS through the SOCKS tunnel.

## Technical Details

Below is some more technical information about the containers used in the docker-compose.yml file.

### Information about the tun2socks docker (wiresocks)

The wiresocks service runs a docker image with `--cap-add=NET_ADMIN --sysctl="net.ipv4.ip_forward=1" --device=/dev/net/tun:/dev/net/tun` flags to allow the container to create a tun interface as well as set routes for it.

You specify the socks proxy using the `PROXY` environment variable, make sure your docker can reach that proxy. It the same as the `-e` flag given to `tun2socks`.

```text
-e PROXY=socks5://socksaddress:1080
```

You can also specify which ranges you want to have redirected to the socks proxy by providing a `TUN_INCLUDED_ROUTES` environment variable:

```text
-e TUN_INCLUDED_ROUTES=192.168.165.0/24
```

The `TUN_INCLUDED_ROUTES` may be comma seperated for multiple ranges.

The container will start tun2socks and configure routes to forward traffic of the routes provided in `TUN_INCLUDED_ROUTES` through the created TUN interface.

### Socksing other dockers

You can use the `--net container:wiresocks` option with other docker containers to get them to share the same network namespace as the wiresocks docker. This includes the setup routes as well as access to the TUN interface. This essentially means you can tunnel arbitary dockers using tun2socks with this option. In the docker-compose we use it for WireGuard so that Windows/MacOS just need a WireGuard config and they can have their traffic transparently proxied.

## Other

### Thanks

The original idea used Darkks [redsocks](https://github.com/darkk/redsocks/) which is amazing!

This version uses the equally amazing [tun2socks](https://github.com/xjasonlyu/tun2socks) by xjasonlyu!

Uses [LinuxServers wireguard](https://github.com/linuxserver/docker-wireguard) image to setup the wireguard vpn to connect into the socks network

## license

`WireSocks` is licensed under a [GNU General Public v3 License](https://www.gnu.org/licenses/gpl-3.0.en.html). Permissions beyond the scope of this license may be available at <http://sensepost.com/contact/>.
