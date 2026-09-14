#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERRORE] Questo script deve essere eseguito come root." >&2
    exit 1
fi

echo "=== Configurazione IP Statico Debian ==="

# Rileva le interfacce fisiche escludendo loopback e docker
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -vE 'lo|docker|veth')

echo "Interfacce di rete rilevate:"
select IFACE in $INTERFACES; do
    if [ -n "$IFACE" ]; then
        break
    fi
done

read -p "Inserisci l'IP Statico desiderato (es. 192.168.1.100): " STATIC_IP
read -p "Inserisci la subnet mask in Notazione CIDR (es. 24 per /24): " NETMASK_CIDR
read -p "Inserisci l'IP del Gateway (es. 192.168.1.1): " GATEWAY_IP
read -p "Inserisci il server DNS (es. 1.1.1.1): " DNS_IP

# Backup della configurazione di rete originale
cp /etc/network/interfaces /etc/network/interfaces.bak.$(date +%F_%T)

cat << EOF > /etc/network/interfaces
# Configurazione generata da 00-network-setup.sh
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug $IFACE
iface $IFACE inet static
    address $STATIC_IP/$NETMASK_CIDR
    gateway $GATEWAY_IP
    dns-nameservers $DNS_IP
EOF

echo "[*] Configurazione salvata in /etc/network/interfaces."
echo "[!] Per applicare le modifiche senza riavviare, esegui: systemctl restart networking"
