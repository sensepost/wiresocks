# wiresocks docker image.

FROM alpine

LABEL Maintainer="Michael Kruger <https://github.com/cablethief>"

ENV DEBIAN_FRONTEND noninteractive

ENV DOCKER_NET docker0
ENV WHITELIST 0.0.0.0/0

# Install packages
RUN apk update && apk add bash iptables openssl-dev libevent-dev git make gcc musl-dev linux-headers

RUN git clone https://github.com/semigodking/redsocks/
RUN cd redsocks && make DISABLE_SHADOWSOCKS=true && cp redsocks2 /usr/bin/redsocks

RUN addgroup -S redsocks && adduser -S redsocks -G redsocks

# Copy configuration files...
COPY redsocks.tmpl /etc/redsocks.tmpl
COPY redsocks.sh /usr/local/bin/redsocks.sh
COPY redsocks-fw.sh /usr/local/bin/redsocks-fw.sh

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/redsocks.sh"]