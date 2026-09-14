cat << 'EOF' > 01-docker-setup.sh
#!/bin/bash
set -euo pipefail

# 1. Verifica che lo script sia eseguito da root
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERRORE] Questo script deve essere eseguito come root (usa 'su -')." >&2
    exit 1
fi

# 2. Richiesta o rilevamento dell'utente locale target
TARGET_USER="${SUDO_USER:-}"

if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    read -p "Inserisci il nome dell'utente locale da configurare (no root): " TARGET_USER
fi

if ! id "$TARGET_USER" &>/dev/null; then
    echo "[ERRORE] L'utente '$TARGET_USER' non esiste." >&2
    exit 1
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo "===> 1. Rimozione di $TARGET_USER dai sudoers (se presente) <==="
if groups "$TARGET_USER" | grep -q "\bsudo\b"; then
    gpasswd -d "$TARGET_USER" sudo
    echo "[*] Utente $TARGET_USER rimosso dal gruppo sudo."
else
    echo "[*] L'utente $TARGET_USER non appartiene al gruppo sudo."
fi

echo "===> 2. Aggiornamento del sistema <==="
apt-get update && apt-get upgrade -y

echo "===> 3. Installazione dipendenze e repository Docker <==="
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

echo "===> 4. Installazione di Docker e Docker Compose <==="
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "===> 5. Configurazione permessi gruppo Docker per l'utente <==="
if ! getent group docker > /dev/null; then
    groupadd docker
fi

if ! groups "$TARGET_USER" | grep -q "\bdocker\b"; then
    usermod -aG docker "$TARGET_USER"
    echo "[*] Utente $TARGET_USER aggiunto al gruppo docker."
fi

systemctl enable docker
systemctl start docker

echo "===> 6. Creazione ambiente di test <==="
PROJECT_DIR="$TARGET_HOME/docker/web-test"
mkdir -p "$PROJECT_DIR"

cat << 'INNEREOF' > "$PROJECT_DIR/docker-compose.yml"
services:
  web:
    image: nginx:alpine
    container_name: test-webserver
    ports:
      - "127.0.0.1:8080:80"
INNEREOF

# Assegna la proprietà della cartella e dei file all'utente target
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/docker"

echo "===> 7. Test del Webserver ed eliminazione container <==="
# Esegue il test temporaneo
docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d

sleep 2
if curl -s -f http://127.0.0.1:8080 > /dev/null; then
    echo "[TEST ESITO] OK: Il server NGINX risponde correttamente."
else
    echo "[TEST ESITO] ERRORE: Impossibile raggiungere il server web." >&2
fi

# Spegnimento e pulizia
docker compose -f "$PROJECT_DIR/docker-compose.yml" down

# Rilevamento IP di rete locale (escludendo Docker e Loopback)
PRIMARY_IP=$(ip -4 addr show scope global | grep -v 'docker' | awk '/inet/ {print $2}' | cut -d/ -f1 | head -n 1)

echo "=========================================================="
echo " CONFIGURAZIONE COMPLETATA CON SUCCESSO!"
echo "=========================================================="
echo " Utente configurato: $TARGET_USER"
echo " Stato sudo: Rimosso/Assente"
echo " IP Scheda di Rete Principale: ${PRIMARY_IP:-Non rilevato}"
echo " Cartella compose di test: $PROJECT_DIR"
echo "=========================================================="
echo " NOTA IMPORTANTE: L'utente $TARGET_USER deve effettuare"
echo " un nuovo LOGIN (SSH o terminale) per poter usare 'docker'"
echo " senza sudo."
echo "=========================================================="
EOF
chmod +x 01-docker-setup.sh
