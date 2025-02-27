#!/bin/bash

# Percorso al comando Certbot
CERTBOT_CMD=$(command -v certbot)

# Soglia in giorni per il rinnovo
THRESHOLD=30

# Flag per capire se è stato rinnovato almeno un certificato
RENEWED=false

# Log file
LOG_FILE="/var/log/certbot_check.log"

# Scrive l'orario di inizio nel log
echo "=============================" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S') - Inizio controllo certificati" >> $LOG_FILE

# Controlla tutti i certificati
$CERTBOT_CMD certificates | grep -A 10 "Certificate Name:" | while read -r line; do
    if [[ $line == "Certificate Name:"* ]]; then
        DOMAIN=$(echo $line | awk '{print $3}')
    elif [[ $line == "Expiry Date:"* ]]; then
        EXPIRY_DATE=$(echo $line | awk '{print $3, $4, $5}')
        EXPIRY_SECONDS=$(date -d "$EXPIRY_DATE" +%s)
        CURRENT_SECONDS=$(date +%s)
        VALID_DAYS=$(( (EXPIRY_SECONDS - CURRENT_SECONDS) / 86400 ))

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Certificato per $DOMAIN valido per ancora $VALID_DAYS giorni." >> $LOG_FILE

        if [[ $VALID_DAYS -lt $THRESHOLD ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - 🔄 Rinnovo del certificato per $DOMAIN..." >> $LOG_FILE
            sudo $CERTBOT_CMD renew --cert-name "$DOMAIN" --quiet
            RENEWED=true
        fi
    fi
done

# Riavvia Apache solo se almeno un certificato è stato rinnovato
if $RENEWED; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 🔄 Riavvio di Apache..." >> $LOG_FILE
    sudo systemctl restart apache2
fi

# Scrive l'orario di fine nel log
echo "$(date '+%Y-%m-%d %H:%M:%S') - Controllo completato." >> $LOG_FILE
echo "=============================" >> $LOG_FILE