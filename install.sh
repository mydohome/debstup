#!/bin/bash
set -euo pipefail

# 1. Controllo permessi root
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERRORE] Questo script deve essere eseguito come root (usa 'su -')." >&2
    exit 1
fi

# 2. Definizione percorsi e rilevamento cartella scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$SCRIPT_DIR/scripts"

if [ ! -d "$SCRIPTS_PATH" ]; then
    echo "[ERRORE] Cartella 'scripts/' non trovata in $SCRIPT_DIR" >&2
    exit 1
fi

# Funzione per eseguire un singolo script
run_script() {
    local script_name="$1"
    local target="$SCRIPTS_PATH/$script_name"

    if [ -f "$target" ]; then
        echo -e "\n----------------------------------------------------------"
        echo " Avvio di $script_name..."
        echo -e "----------------------------------------------------------\n"
        chmod +x "$target"
        bash "$target"
        echo -e "\n[*] Completato: $script_name\n"
    else
        echo -e "\n[ERRORE] Script $script_name non trovato in $SCRIPTS_PATH!\n" >&2
    fi
}

# Funzione per eseguire l'installazione completa sequenziale
run_all() {
    echo -e "\n=========================================================="
    echo " ESECUZIONE COMPLETA CONFIGURAZIONE SERVER DEBIAN"
    echo -e "==========================================================\n"
    run_script "00-network-setup.sh"
    run_script "01-docker-setup.sh"
    run_script "02-security-hardening.sh"
    run_script "03-system-tools.sh"
    echo -e "\n=========================================================="
    echo " INSTALLAZIONE COMPLETA TERMINATA CON SUCCESSO!"
    echo -e "==========================================================\n"
}

# 3. Menu Interattivo
while true; do
    echo "=========================================================="
    echo "       DEBSTUP - Debian Server Setup Orchestrator        "
    echo "=========================================================="
    echo " 1) 00-network-setup.sh        (Configurazione IP Statico)"
    echo " 2) 01-docker-setup.sh         (Installazione Docker & Permessi)"
    echo " 3) 02-security-hardening.sh   (UFW Firewall & Fail2ban)"
    echo " 4) 03-system-tools.sh         (Utility di Sistema)"
    echo "----------------------------------------------------------"
    echo " A) Esegui TUTTI gli script in sequenza (00 -> 03)"
    echo " Q) Esci"
    echo "=========================================================="
    read -p "Seleziona un'opzione [1-4, A, Q]: " CHOICE

    case "$CHOICE" in
        1)
            run_script "00-network-setup.sh"
            ;;
        2)
            run_script "01-docker-setup.sh"
            ;;
        3)
            run_script "02-security-hardening.sh"
            ;;
        4)
            run_script "03-system-tools.sh"
            ;;
        [aA])
            run_all
            ;;
        [qQ])
            echo "Uscita dal programma."
            exit 0
            ;;
        *)
            echo -e "\n[!] Opzione non valida. Riprova.\n"
            ;;
    esac

    read -p "Premi [INVIO] per tornare al menu principale..."
    clear
done
