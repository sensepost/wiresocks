FROM ghcr.io/xjasonlyu/tun2socks:latest

LABEL Maintainer="Michael Kruger <https://github.com/cablethief>"
# I wanted a different entrypoint

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]