#!/bin/bash
#
# a shell script to configure coredns to forward DNS traffic to
# an upstream server, forcing TCP lookups to be socks friendly

echo "configuring dns to ${TARGET_ROOT_DOMAINS} to lookup at ${TARGET_DNS_SERVER}..."

for DOMAIN in ${TARGET_ROOT_DOMAINS//,/ };
do
    cat << EOF
${DOMAIN} {
    loop
    log
    forward . ${TARGET_DNS_SERVER}:53 {
        force_tcp
    }
}
EOF
done > /config/coredns/Corefile


cat << EOF >> /config/coredns/Corefile
. {
    loop
    forward . /etc/resolv.conf
}
EOF

