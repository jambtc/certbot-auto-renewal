#!/bin/bash

# Percorso al comando Certbot
CERTBOT_CMD=$(command -v certbot)

# Soglia in giorni per il rinnovo
THRESHOLD=30

# Flag per capire se è stato rinnovato almeno un certificato
RENEWED=false

# Log file
LOG_FILE="/var/log/certbot_check.log"

# Function to log messages to both file and screen
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Scrive l'orario di inizio nel log
log_message "============================="
log_message "Inizio controllo certificati"

# Controlla tutti i certificati
$CERTBOT_CMD certificates | grep -A 10 "Certificate Name:" | while read -r line; do
    if [[ $line == "Certificate Name:"* ]]; then
        DOMAIN=$(echo $line | awk '{print $3}')
    elif [[ $line == "Expiry Date:"* ]]; then
        EXPIRY_DATE=$(echo $line | awk '{print $3, $4, $5}')
        EXPIRY_SECONDS=$(date -d "$EXPIRY_DATE" +%s)
        CURRENT_SECONDS=$(date +%s)
        VALID_DAYS=$(( (EXPIRY_SECONDS - CURRENT_SECONDS) / 86400 ))

        log_message "Certificato per $DOMAIN valido per ancora $VALID_DAYS giorni."

        if [[ $VALID_DAYS -lt $THRESHOLD ]]; then
            log_message "🔄 Rinnovo del certificato per $DOMAIN..."
            sudo $CERTBOT_CMD renew --cert-name "$DOMAIN" --quiet
            RENEWED=true
        fi
    fi
done

# Riavvia Apache solo se almeno un certificato è stato rinnovato
if $RENEWED; then
    log_message "🔄 Riavvio di Apache..."
    sudo systemctl restart apache2
fi

# avvisa dove recuperare il file di log
log_message "Log salvato in : $LOG_FILE"

# Scrive l'orario di fine nel log
log_message "Controllo completato."
log_message "============================="