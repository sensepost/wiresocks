#!/bin/sh

##########################
# Setup the Firewall rules
##########################
fw_setup() {
  # First we added a new chain called 'REDSOCKS' to the 'nat' table.
  iptables -t nat -N REDSOCKS
  iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345

  whitelist=$(echo ${WHITELIST} | tr ";" "\n")

  echo "Targetting ranges:"
  for ip in ${whitelist}; do
        echo ${ip}
        iptables -t nat -A PREROUTING -i ${DOCKER_NET} -d ${ip} -p tcp -j REDSOCKS
  done 
}

##########################
# Clear the Firewall rules
##########################
fw_clear() {
  iptables-save | grep -v REDSOCKS | iptables-restore
  #iptables -L -t nat --line-numbers
  #iptables -t nat -D PREROUTING 2
}

case "$1" in
    start)
        echo -n "Setting REDSOCKS firewall rules..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning REDSOCKS firewall rules..."
        fw_clear
        echo "done."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0

