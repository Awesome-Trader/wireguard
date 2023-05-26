#!/usr/bin/env bash
# usage:
#   wg-genconf.sh [--clients=<clients_count>] [--listen-port=<listen_port>] [--dns-ip=<dns_ip>] [--server-public-ip=<server_public_ip>] [--no-isolation]

set -e # exit when any command fails
set -x # enable print all commands

# inputs:
isolation_enabled=true
clients_count=10
listen_port=51820
dns_ip=10.0.0.1
server_ip=

for arg in "$@"
do
  [[ "${arg}" == "--no-isolation" ]] && isolation_enabled=
  [[ "${arg}" == "--clients="* ]] && clients_count=${arg#*=}
  [[ "${arg}" == "--listen-port"* ]] && listen_port=${arg#*=}
  [[ "${arg}" == "--dns-ip"* ]] && dns_ip=${arg#*=}
  [[ "${arg}" == "--server-ip"* ]] && server_ip=${arg#*=}
done

if [ -z "$server_ip" ]; then
  server_ip=$(hostname -I | awk '{print $1;}') # get only first hostname
fi

server_private_key=$(wg genkey)
server_public_key=$(echo "${server_private_key}" | wg pubkey)
server_config=wg0.conf

# The older code was directly referencing eth0 as the public interface in PostUp&PostDown events.
# Let's find that interface's name dynamic.
# If you have a different configuration just uncomment and edit the following line and comment the next.
#
# server_public_interface=eth0
#
# thanks https://github.com/buraksarica for this improvement.

server_public_interface=$(route -n | awk '$1 == "0.0.0.0" {print $8}')

echo Generate server \("${server_ip}"\) config:
echo
echo -e "\t$(pwd)/${server_config}"

post_up=""
post_down=""

if [[ "$isolation_enabled" != true ]]; then
  post_up+="iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; "
  post_down+="iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; "
fi

post_up+="iptables -t nat -A POSTROUTING -o server_public_interface -j MASQUERADE"
post_down+="iptables -t nat -D POSTROUTING -o server_public_interface -j MASQUERADE"

cat > "${server_config}" <<EOL
[Interface]
Address = 10.0.0.1/24
SaveConfig = true
ListenPort = ${listen_port}
PrivateKey = ${server_private_key}
PostUp = ${post_up}
PostDown = ${post_down}
EOL

echo
echo Generate configs for "${clients_count}" clients:
echo

for i in $(seq 1 "${clients_count}");
do
    client_private_key=$(wg genkey)
    client_public_key=$(echo "${client_private_key}" | wg pubkey)
    client_ip=10.0.0.$((i+1))/32
    client_config=client$i.conf
    echo -e "\t$(pwd)/${client_config}"
  	cat > "${client_config}" <<EOL
[Interface]
PrivateKey = ${client_private_key}
ListenPort = ${listen_port}
Address = ${client_ip}
DNS = ${dns_ip}

[Peer]
PublicKey = ${server_public_key}
AllowedIPs = 0.0.0.0/0
Endpoint = ${server_ip}:${listen_port}
PersistentKeepalive = 21
EOL
    cat >> "${server_config}" <<EOL
[Peer]
PublicKey = ${client_public_key}
AllowedIPs = ${client_ip}
EOL
done
