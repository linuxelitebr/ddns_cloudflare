#!/bin/bash

# Variables
CF_API_TOKEN="EDIT-ME"
CF_ZONE_ID="EDIT-ME"
CF_RECORD_ID="EDIT-ME"
# Replace it with your A record and domain:
CF_DOMAIN="server.example.com"
# 1 means automatic TTL:
TTL=1

# Get the current public IP
CURRENT_IP=$(curl -s http://ipv4.icanhazip.com)

# Cloudflare API URL
API_URL="https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID"

# Get the current DNS record info
RECORD=$(curl -s -X GET "$API_URL" -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type: application/json")

# Extract the IP from the record
OLD_IP=$(echo $RECORD | jq -r .result.content)

# Check if the IP has changed
if [ "$CURRENT_IP" != "$OLD_IP" ]; then
    echo "IP has changed. Updating Cloudflare DNS record..."
    # Update the DNS record with the new IP
    RESPONSE=$(curl -s -X PUT "$API_URL" -H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"$CF_DOMAIN\",\"content\":\"$CURRENT_IP\",\"ttl\":$TTL,\"proxied\":true}")

    # Check the response for success
    SUCCESS=$(echo $RESPONSE | jq -r .success)
    if [ "$SUCCESS" == "true" ]; then
        echo "Cloudflare DNS record updated successfully to $CURRENT_IP"
    else
        echo "Failed to update Cloudflare DNS record."
    fi
else
    echo "IP has not changed. No update needed."
fi
