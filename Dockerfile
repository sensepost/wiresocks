# wiresocks docker image.

FROM ubuntu:focal

LABEL Author="Michael Kruger <https://github.com/cablethief>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCKER_NET docker0
ENV WHITELIST 0.0.0.0/0

# Install packages
RUN apt-get update && apt-get install -y redsocks iptables

# Copy configuration files...
COPY redsocks.tmpl /etc/redsocks.tmpl
COPY redsocks.sh /usr/local/bin/redsocks.sh
COPY redsocks-fw.sh /usr/local/bin/redsocks-fw.sh

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/redsocks.sh"]
