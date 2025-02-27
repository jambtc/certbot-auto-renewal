# Certbot Auto-Renewal Script


## Overview

This script automatically checks all SSL/TLS certificates managed by **Certbot** and renews them if they are set to expire in less than **30 days**.
If at least one certificate is renewed, it will also **restart Apache** to apply the changes.

Additionally, the script logs all activities, including:

- The start and end time of the execution
- The number of days remaining for each certificate
- Renewal actions taken
- Apache restart (if necessary)


## Why Use This Script?
Let's Encrypt no longer sends email notifications for expiring certificates.
By using this script, you ensure that all certificates are automatically checked and renewed **before expiration**, avoiding downtime or security issues.



## Installation & Setup

### 1. Download the Script
Run the following command to download and save the script on your server:

```bash
curl -o ~/check_certbot.sh https://raw.githubusercontent.com/jambtc/certbot-auto-renewal/main/check_certbot.sh
```

### 2. Make the Script Executable
After saving the file, make it executable:

```bash 
chmod +x ~/check_certbot.sh
```

### 3. Test the Script Manually
Run the script once to check if everything is working correctly:

```bash
~/check_certbot.sh
```

Then, check the log file:

```bash
cat /var/log/certbot_check.log
```

## Automate with Cron Job
To ensure the script runs daily, set up a cron job:

### 1. Open Crontab

```bash
sudo crontab -e
```

### 2. Add the Following Line
This will run the script every day at 2:00 AM and log output:

```bash
0 2 * * * /bin/bash ~/check_certbot.sh >> /var/log/certbot_check.log 2>&1
```

## Log File Example
After running, the script will create a log file at /var/log/certbot_check.log with entries like this:

```yaml
=============================
2025-02-26 02:00:01 - Starting SSL certificate check
2025-02-26 02:00:02 - Certificate for example.com expires in 45 days.
2025-02-26 02:00:02 - Certificate for anotherdomain.com expires in 15 days.
2025-02-26 02:00:02 - 🔄 Renewing certificate for anotherdomain.com...
2025-02-26 02:00:10 - 🔄 Restarting Apache...
2025-02-26 02:00:11 - SSL certificate check completed.
=============================
```

## License

This script is open-source and available under the MIT License.
