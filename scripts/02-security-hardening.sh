#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERRORE] Questo script deve essere eseguito come root." >&2
    exit 1
fi

echo "=== 1. Installazione UFW e Fail2ban ==="
apt-get update && apt-get install -y ufw fail2ban

echo "=== 2. Configurazione UFW Firewall ==="
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo "=== 3. Configurazione Fail2ban per SSH ==="
cat << EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 10m
bantime = 1h
EOF

systemctl restart fail2ban
systemctl enable fail2ban

echo "[*] Security hardening completato: UFW attivo e Fail2ban in esecuzione."
