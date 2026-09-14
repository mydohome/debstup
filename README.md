Markdown
# Debian Server Setup Scripts

Una collezione di script Bash modulari e automatizzati per la configurazione, il deployment e la messa in sicurezza di server **Debian** (Bullseye / Bookworm).

Gli script sono progettati per essere eseguiti direttamente dall'utente **root** (`su -`), applicando una politica di sicurezza avanzata che rimuove i privilegi `sudo` all'utente locale standard per prevenire attacchi di *privilege escalation*.

---

## 📁 Struttura del Repository

```text
debstup/
├── README.md
└── scripts/
    ├── 00-network-setup.sh
    ├── 01-docker-setup.sh
    ├── 02-security-hardening.sh
    └── 03-system-tools.sh
📄 Script Disponibili
00. Network Setup (scripts/00-network-setup.sh)
Imposta l'indirizzo IP statico, la subnet mask (notazione CIDR), il gateway e il server DNS sovrascrivendo /etc/network/interfaces.

Rileva automaticamente le interfacce di rete attive.

Crea un backup automatico della configurazione di rete precedente prima di applicare le modifiche.

01. Docker Setup & Permissions (scripts/01-docker-setup.sh)
Prepara il sistema per l'utilizzo di Docker seguendo i criteri ufficiali:

🛑 Security Hardening: Rimuove l'utente locale dal gruppo sudo.

🔄 Aggiornamento: Esegue apt update && apt upgrade -y.

🐳 Installazione Docker: Installa docker-ce, docker-ce-cli e docker-compose-plugin dai repository GPG ufficiali.

👤 Permessi Utente: Aggiunge l'utente locale al gruppo docker per permettere la gestione di container senza privilegi di root.

🧪 Test Temporaneo: Crea ed esegue un test con un container Nginx su 127.0.0.1:8080, ne verifica la risposta ed effettua la pulizia automatica.

02. Security Hardening (scripts/02-security-hardening.sh)
Configura il livello base di protezione per l'accesso remoto:

🛡️ UFW Firewall: Imposta una politica di default deny incoming / allow outgoing, aprendo unicamente le porte SSH (22), HTTP (80) e HTTPS (443).

🚨 Fail2ban: Abilita il monitoraggio dei log di autenticazione SSH (/var/log/auth.log) bloccando automaticamente per 1 ora gli IP con 5 tentativi falliti in 10 minuti.

03. System Tools (scripts/03-system-tools.sh)
Installa una suite completa di utility di amministrazione e diagnostica:

Monitoraggio & Diagnosi: htop, ncdu, tmux, net-tools, dnsutils, iputils-ping.

Utility Generali: curl, wget, git, vim, nano, unzip, rsync, logrotate.

Esegue la pulizia della cache dei pacchetti (autoremove / autoclean).

🚀 Esecuzione Rapida (Da Root)
Per lanciare uno script direttamente su una macchina pulita senza clonare il repository:

Bash
su -
wget [https://raw.githubusercontent.com/mydohome/debstup/main/scripts/01-docker-setup.sh](https://raw.githubusercontent.com/mydohome/debstup/main/scripts/01-docker-setup.sh) -O 01-docker-setup.sh && chmod +x 01-docker-setup.sh
./01-docker-setup.sh
🛠️ Esecuzione tramite Clonazione Repository
Bash
# 1. Accedi come root
su -

# 2. Clona il repository
git clone [https://github.com/mydohome/debstup.git](https://github.com/mydohome/debstup.git)
cd debstup/scripts

# 3. Rendi eseguibili gli script
chmod +x *.sh

# 4. Esegui lo script desiderato (es. 00-network-setup.sh)
./00-network-setup.sh
🔒 Requisiti e Sicurezza
OS Supportato: Debian 11 (Bullseye) / Debian 12 (Bookworm).

Privilegi: Gli script richiedono l'esecuzione diretta da root (su -).

Credenziali: Nessun token o password viene salvato nel codice.


---

<ElicitationsGroup message="Tutto pronto per proseguire con il repository?">
  <Elicitation label="Crea lo script orchestratore install.sh per la root" query="Scrivi uno script install.sh per la radice del repository debstup che mostri un menu interattivo nel terminale per eseguire gli script da 00 a 03."/>
</ElicitationsGroup>
