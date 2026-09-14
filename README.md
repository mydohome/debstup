Markdown
# Debian Server Setup Scripts

Una collezione di script Bash modulari e automatizzati per la configurazione, il deployment e la messa in sicurezza di server **Debian**.

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
Imposta manualmente l'indirizzo IP statico, la subnet mask, il gateway e il server DNS sovrascrivendo /etc/network/interfaces con backup automatico della configurazione precedente.

01. Docker Setup & Permissions (scripts/01-docker-setup.sh)
Aggiorna il sistema Debian, installa l'ultima versione di Docker e Docker Compose dai repository ufficiali, assegna i permessi all'utente locale rimuovendolo dal gruppo sudo per motivi di sicurezza, ed esegue un test temporaneo con un container Nginx.

02. Security Hardening (scripts/02-security-hardening.sh)
Configura il firewall UFW (bloccando tutto il traffico in ingresso tranne le porte SSH, HTTP e HTTPS) e abilita Fail2ban per proteggere il server da attacchi di forza bruta sulla porta SSH.

### 03. System Tools (`scripts/03-system-tools.sh`)
Installa una suite di strumenti essenziali per l'amministrazione e la manutenzione del server:
* **Monitoraggio & Diagnosi:** `htop` (risorse), `ncdu` (spazio disco), `tmux` (terminale persistente), `net-tools`, `dnsutils`, `iputils-ping`.
* **Utility Generali:** `curl`, `wget`, `git`, `vim`, `nano`, `unzip`, `rsync`, `logrotate`.
* Esegue la pulizia automatica dei pacchetti inutilizzati (`autoremove` / `autoclean`).

🚀 Esecuzione Rapida (Da Root)
Accedi al server Debian tramite su - ed esegui lo script desiderato tramite curl o wget:

Esempio download ed esecuzione per Docker Setup:

Bash
wget [https://raw.githubusercontent.com/mydohome/debstup/main/scripts/01-docker-setup.sh](https://raw.githubusercontent.com/mydohome/debstup/main/scripts/01-docker-setup.sh) -O 01-docker-setup.sh && chmod +x 01-docker-setup.sh
./01-docker-setup.sh
🛠️ Clonazione Completa
Bash
su -
git clone [https://github.com/mydohome/debstup.git](https://github.com/mydohome/debstup.git)
cd debstup/scripts
chmod +x *.sh

---

<ElicitationsGroup message="Per completare il push su GitHub:">
  <Elicitation label="Mostrami i comandi git per fare il push dei nuovi file" query="Dammi i comandi git per fare commit e push di tutti i nuovi script e del readme nel repository GitHub debstup."/>
</ElicitationsGroup>
