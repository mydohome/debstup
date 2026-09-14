# Debian Server Setup Scripts

Una collezione di script Bash modulari e automatizzati per la configurazione, il deployment e la messa in sicurezza di server **Debian** (Bullseye / Bookworm).

Gli script sono progettati per essere eseguiti direttamente dall'utente **root** (`su -`), applicando una politica di sicurezza avanzata che rimuove i privilegi `sudo` all'utente locale standard per prevenire attacchi di *privilege escalation*.

---

## 📁 Struttura del repository

```text
debstup/
├── README.md
├── install.sh
└── scripts/
    ├── 00-network-setup.sh
    ├── 01-docker-setup.sh
    ├── 02-security-hardening.sh
    └── 03-system-tools.sh
```

## 📄 Script disponibili

### 00. Network Setup (`scripts/00-network-setup.sh`)

- Imposta l'indirizzo IP statico, la subnet mask (notazione CIDR), il gateway e il server DNS sovrascrivendo `/etc/network/interfaces`.
- Rileva automaticamente le interfacce di rete attive.
- Crea un backup automatico della configurazione di rete precedente prima di applicare le modifiche.

### 01. Docker Setup & Permissions (`scripts/01-docker-setup.sh`)

Prepara il sistema per l'utilizzo di Docker seguendo i criteri ufficiali:

- 🛑 **Security hardening**: rimuove l'utente locale dal gruppo `sudo`.
- 🔄 **Aggiornamento**: esegue `apt update && apt upgrade -y`.
- 🐳 **Installazione Docker**: installa `docker-ce`, `docker-ce-cli` e `docker-compose-plugin` dai repository GPG ufficiali.
- 👤 **Permessi utente**: aggiunge l'utente locale al gruppo `docker` per permettere la gestione di container senza privilegi di root.
- 🧪 **Test temporaneo**: crea ed esegue un test con un container Nginx su `127.0.0.1:8080`, ne verifica la risposta ed effettua la pulizia automatica.

### 02. Security Hardening (`scripts/02-security-hardening.sh`)

Configura il livello base di protezione per l'accesso remoto:

- 🛡️ **UFW Firewall**: imposta una politica di default `deny incoming` / `allow outgoing`, aprendo unicamente le porte SSH (22), HTTP (80) e HTTPS (443).
- 🚨 **Fail2ban**: abilita il monitoraggio dei log di autenticazione SSH (`/var/log/auth.log`) bloccando automaticamente per 1 ora gli IP con 5 tentativi falliti in 10 minuti.

### 03. System Tools (`scripts/03-system-tools.sh`)

Installa una suite completa di utility di amministrazione e diagnostica:

- **Monitoraggio & diagnosi**: `htop`, `ncdu`, `tmux`, `net-tools`, `dnsutils`, `iputils-ping`.
- **Utility generali**: `curl`, `wget`, `git`, `vim`, `nano`, `unzip`, `rsync`, `logrotate`.
- Esegue la pulizia della cache dei pacchetti (`autoremove` / `autoclean`).

---

## 🚀 Esecuzione e installazione

Il metodo raccomandato per gestire il server è clonare il repository ed eseguire lo script orchestratore interattivo **`install.sh`** posizionato nella radice del progetto.

### 1. Clonazione ed esecuzione dell'orchestratore (raccomandato)

```bash
# 1. Accedi come root
su -

# 2. Clona il repository
git clone https://github.com/mydohome/debstup.git
cd debstup

# 3. Rendi eseguibile l'orchestratore e avvialo
chmod +x install.sh
./install.sh
```

L'orchestratore apre un menu interattivo da cui puoi:

- selezionare ed eseguire un singolo modulo a scelta (00 – 03);
- avviare la configurazione completa e sequenziale di tutti i moduli (00 → 03).

### 2. Esecuzione rapida di un singolo script (senza clonazione)

Se vuoi eseguire un solo modulo direttamente su una macchina pulita, senza clonare l'intero repository:

```bash
su -
wget https://raw.githubusercontent.com/mydohome/debstup/main/scripts/01-docker-setup.sh -O 01-docker-setup.sh
chmod +x 01-docker-setup.sh
./01-docker-setup.sh
```

### 3. Esecuzione tramite clonazione (tutti gli script, senza orchestratore)

```bash
# 1. Accedi come root
su -

# 2. Clona il repository
git clone https://github.com/mydohome/debstup.git
cd debstup/scripts

# 3. Rendi eseguibili gli script
chmod +x *.sh

# 4. Esegui lo script desiderato (es. 00-network-setup.sh)
./00-network-setup.sh
```

---

## 🔒 Requisiti e sicurezza

- **OS supportato**: Debian 11 (Bullseye) / Debian 12 (Bookworm).
- **Privilegi**: gli script richiedono l'esecuzione diretta da root (`su -`).
- **Credenziali**: nessun token o password viene salvato nel codice.
