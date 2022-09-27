#!/bin/bash
#
# a shell script to configure coredns to forward DNS traffic to
# an upstream server, forcing TCP lookups to be socks friendly

echo "configuring dns to ${TARGET_ROOT_DOMAIN} to lookup at ${TARGET_DNS_SERVER}..."

cat << EOF > /config/coredns/Corefile
${TARGET_ROOT_DOMAIN} {
    loop
    log
    forward . ${TARGET_DNS_SERVER}:53 {
        force_tcp
    }
}
. {
    loop
    forward . /etc/resolv.conf
}
EOF
