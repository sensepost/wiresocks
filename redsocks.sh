#!/bin/bash

if test $# -eq 2
then
    proxy_ip=$1
    proxy_port=$2
else
    echo "No proxy URL defined. Using default."
    proxy_ip=10.26.141.135
    proxy_port=3128
fi

docker_network_ip=$(ip addr show dev $DOCKER_NET | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)

echo "Creating redsocks configuration file using proxy ${proxy_ip}:${proxy_port}..."
sed -e "s|\${proxy_ip}|${proxy_ip}|" \
    -e "s|\${proxy_port}|${proxy_port}|" \
    -e "s|\${docker_network_ip}|${docker_network_ip}|" \
    /etc/redsocks.tmpl > /tmp/redsocks.conf

echo "Generated configuration:"
cat /tmp/redsocks.conf

echo "Activating iptables rules..."
/usr/local/bin/redsocks-fw.sh start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal catched. Shutdown redsocks and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        /usr/local/bin/redsocks-fw.sh stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

echo "Starting redsocks..."
/usr/bin/redsocks -c /tmp/redsocks.conf &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
