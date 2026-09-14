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

> L'hardening della configurazione SSH stessa (disabilitare login via password, disabilitare il root remoto) **non** è automatizzato: va fatto a mano, vedi la sezione [⚠️ Hardening SSH](#️-importante--hardening-ssh-manuale) più sotto.

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

## ⚠️ IMPORTANTE — Hardening SSH (manuale)

Disabilitare login via password su SSH **non è automatizzato apposta**: uno script che sbaglia
qualcosa (chiave non caricata, utente errato, sintassi) può chiuderti fuori dal server senza
modo di rientrare se non hai una console fisica/IPMI. Vanno eseguiti a mano, con calma, **senza
mai chiudere la sessione SSH corrente finché non hai verificato che una nuova connessione funzioni.**

1. **Copia la tua chiave pubblica sul server** (dalla tua macchina locale, non sul server):

   ```bash
   ssh-copy-id utente@IP_SERVER
   # oppure a mano:
   cat ~/.ssh/id_ed25519.pub | ssh utente@IP_SERVER 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
   ```

2. **Apri una seconda connessione SSH di verifica** (lascia aperta anche la prima) e conferma
   che il login con chiave funzioni *senza* password:

   ```bash
   ssh utente@IP_SERVER
   ```

3. **Solo a questo punto**, sul server, fai un backup della configurazione e modifica `sshd_config`:

   ```bash
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F_%T)
   sudo sed -i \
     -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
     -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
     -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
     /etc/ssh/sshd_config
   ```

4. **Verifica la sintassi prima di riavviare** (fondamentale: un errore qui non farà partire sshd):

   ```bash
   sudo sshd -t
   ```

5. **Riavvia il servizio SSH**:

   ```bash
   sudo systemctl restart ssh
   ```

6. **Apri una terza connessione SSH nuova** per confermare che tutto funzioni ancora, prima di
   chiudere le sessioni aperte ai punti 1–2. Se qualcosa non va, correggi da lì usando la sessione
   ancora attiva — non chiuderla mai per prima.

Opzionale, solo se sai già cosa comporta (aggiornare anche le regole UFW se cambi porta):

```bash
sudo sed -i 's/^#\?Port .*/Port 2222/' /etc/ssh/sshd_config
sudo ufw allow 2222/tcp
sudo sshd -t && sudo systemctl restart ssh
```

---

## 🔒 Requisiti e sicurezza

- **OS supportato**: Debian 11 (Bullseye) / Debian 12 (Bookworm).
- **Privilegi**: gli script richiedono l'esecuzione diretta da root (`su -`).
- **Credenziali**: nessun token o password viene salvato nel codice.
