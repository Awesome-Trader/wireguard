# Wireguard

This repository contains scripts that make it easy to configure [WireGuard](https://www.wireguard.com)
on [VPS](https://en.wikipedia.org/wiki/Virtual_private_server).

Medium article: [How to deploy WireGuard node on a DigitalOcean's droplet](https://medium.com/@drew2a/replace-your-vpn-provider-by-setting-up-wireguard-on-digitalocean-6954c9279b17)

## Quick Start

### Ubuntu

```bash
wget https://raw.githubusercontent.com/mr-kenikh/wireguard/master/wg-ubuntu-server-up.sh

chmod +x ./wg-ubuntu-server-up.sh
sudo ./wg-ubuntu-server-up.sh
```

### Debian

```bash
wget https://raw.githubusercontent.com/mr-kenikh/wireguard/master/wg-debian-server-up.sh

chmod +x ./wg-debian-server-up.sh
./wg-debian-server-up.sh
```

To get a full instruction, please follow to the article above.

### Supported OS

- Ubuntu 18.04
- Ubuntu 20.04
- Debian 9
- Debian 10

## wg-ubuntu-server-up.sh

This script:

- Installs all necessary software on an empty Ubuntu DigitalOcean droplet
  (it should also work with most modern Ubuntu images)
- Configures IPv4 forwarding and iptables rules
- Sets up [unbound](https://github.com/NLnetLabs/unbound) DNS resolver
- Creates a server and clients configurations
- Installs [qrencode](https://github.com/fukuchi/libqrencode/)
- Runs [WireGuard](https://www.wireguard.com)

### Usage

```bash
wg-ubuntu-server-up.sh [--clients=<clients_count>] [--listen-port=<listen_port>] [--no-reboot] [--no-unbound]
```

Options:

- `--clients=<clients_count>` how many client's configs will be created
- `--listen-port=<listen_port>` wireguard listen port (51820 will be used as a default port)
- `--no-isolation` disables client isolation
- `--no-unbound` disables Unbound server installation (1.1.1.1 will be used as a default DNS for client's configs)
- `--no-reboot` disables rebooting at the end of the script execution

### Example of usage

```bash
./wg-ubuntu-server-up.sh
```

```bash
./wg-ubuntu-server-up.sh --clients=10
```

```bash
./wg-ubuntu-server-up.sh --clients=10 --listen-port=1234
```

## wg-debian-server-up.sh

This script works the same way and with the same options, that `wg-ubuntu-server-up.sh` do.

## wg-genconf.sh

This script generate server and clients configs for WireGuard.

If the public IP is not defined, then the public IP of the machine from which the script is run is used.
If the number of clients is not defined, then used 10 clients.
If the listen port is not defined, then used 51820 as default.

### Prerequisites

Install [WireGuard](https://www.wireguard.com) if it's not installed.

### Usage

```bash
./wg-genconf.sh [--clients=<clients_count>] [--listen-port=<listen_port>] [--dns-ip=<dns_ip>] [--server-public-ip=<server_public_ip>] [--no-isolation]
```

Options:

- `--clients=<clients_count>` how many client's configs will be generated
- `--listen-port=<listen_port>` wireguard listen port (51820 will be used as a default port)
- `--dns-ip=<dns_ip>` the script should use this IP as a DNS address
- `--server-public-ip=<server_public_ip>` the script should use this IP as a server address
- `--no-isolation` disables client isolation

### Example of usage:

```bash
./wg-genconf.sh
```

```bash
./wg-genconf.sh --clients=10
```

```bash
./wg-genconf.sh --clients=10 --listen-port=1234
```

```bash
./wg-genconf.sh --clients=10 --listen-port=1234 --dns-ip=1.1.1.1
```

````bash
./wg-genconf.sh --clients=10 --listen-port=1234 --dns-ip=1.1.1.1 --server-public-ip157.245.73.253

```bash
./wg-genconf.sh --clients=10 --listen-port=1234 --dns-ip=1.1.1.1 --server-public-ip157.245.73.253 --no-isolation
````
