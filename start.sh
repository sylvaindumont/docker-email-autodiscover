#!/bin/bash

# Prepare the settings.json
sed -i "s/{{COMPANY_NAME}}/$COMPANY_NAME/" settings.json
sed -i "s/{{SUPPORT_URL}}/$SUPPORT_URL/" settings.json
sed -i "s/{{DOMAIN}}/$DOMAIN/" settings.json
sed -i "s/{{IMAP_HOST}}/$IMAP_HOST/" settings.json
sed -i "s/{{IMAP_PORT}}/$IMAP_PORT/" settings.json
sed -i "s/{{SMTP_HOST}}/$SMTP_HOST/" settings.json
sed -i "s/{{SMTP_PORT}}/$SMTP_PORT/" settings.json

# Run apache
apache2-foreground
