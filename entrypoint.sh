#!/bin/sh

# Modified version of 
# https://github.com/xjasonlyu/tun2socks/blob/main/docker/entrypoint.sh

TUN="${TUN:-tun0}"
ADDR="${ADDR:-198.18.0.1/15}"
LOGLEVEL="${LOGLEVEL:-info}"

create_tun() {
  ip tuntap add mode tun dev "$TUN"
  ip addr add "$ADDR" dev "$TUN"
  ip link set dev "$TUN" up
}

config_route() {
  for addr in $(echo "$TUN_INCLUDED_ROUTES" | tr ',' '\n'); do
    ip route add $addr dev $TUN
  done
}


run() {

  create_tun
  config_route

  # execute extra commands
  if [ -n "$EXTRA_COMMANDS" ]; then
    sh -c "$EXTRA_COMMANDS"
  fi

  if [ -n "$MTU" ]; then
    ARGS="--mtu $MTU"
  fi

  if [ -n "$RESTAPI" ]; then
    ARGS="$ARGS --restapi $RESTAPI"
  fi

  if [ -n "$UDP_TIMEOUT" ]; then
    ARGS="$ARGS --udp-timeout $UDP_TIMEOUT"
  fi

  if [ -n "$TCP_SNDBUF" ]; then
    ARGS="$ARGS --tcp-sndbuf $TCP_SNDBUF"
  fi

  if [ -n "$TCP_RCVBUF" ]; then
    ARGS="$ARGS --tcp-rcvbuf $TCP_RCVBUF"
  fi

  if [ "$TCP_AUTO_TUNING" = 1 ]; then
    ARGS="$ARGS --tcp-auto-tuning"
  fi

  exec tun2socks \
    --loglevel "$LOGLEVEL" \
    --device "$TUN" \
    --proxy "$PROXY" \
    $ARGS
}

run || exit 1