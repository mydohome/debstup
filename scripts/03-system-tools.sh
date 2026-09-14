#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERRORE] Questo script deve essere eseguito come root." >&2
    exit 1
fi

echo "=== 1. Aggiornamento degli indici dei pacchetti ==="
apt-get update

echo "=== 2. Installazione delle utility di sistema essenziali ==="
# Monitoraggio risorse, gestione processi e diagnosi di rete
apt-get install -y \
    htop \
    ncdu \
    tmux \
    curl \
    wget \
    git \
    vim \
    nano \
    net-tools \
    dnsutils \
    iputils-ping \
    unzip \
    rsync \
    logrotate

echo "=== 3. Pulizia della cache e pacchetti inutilizzati ==="
apt-get autoremove -y
apt-get autoclean

echo "=========================================================="
echo " UTILITY DI SISTEMA INSTALLATE CON SUCCESSO!"
echo " Strumenti disponibili: htop, ncdu, tmux, net-tools, git..."
echo "=========================================================="
