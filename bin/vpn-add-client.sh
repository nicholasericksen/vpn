#!/bin/bash

# Generate Random ID for client
CLIENT_ID=$(tr -cd "[:digit:]" < /dev/urandom | head -c 6)

wg genkey | sudo tee /etc/wireguard/clients/${CLIENT_ID}.key | wg pubkey | sudo tee /etc/wireguard/clients/${CLIENT_ID}.key.pub

# Read the keys
SERVER_PUBLIC=$(cat /etc/wireguard/publickey)
SERVER_PRIVATE=$(cat /etc/wireguard/privatekey)
CLIENT_PRIVATE=$(cat /etc/wireguard/clients/${CLIENT_ID}.key)
CLIENT_PUBLIC=$(cat /etc/wireguard/clients/${CLIENT_ID}.key.pub)

# Save public IP of VPN server
EXTERNAL_IP=$(ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}' | head -n 1)

LAST_IP=$(cat .last_ip_used)
NEXT_IP=$((LAST_IP + 1))

# Create client config
echo "
[Interface]
PrivateKey = ${CLIENT_PRIVATE}
Address = 10.8.3.${NEXT_IP}/24
DNS = 10.8.3.1

[Peer]
PublicKey = ${SERVER_PUBLIC}
Endpoint = ${EXTERNAL_IP}:1194
AllowedIPs = 0.0.0.0/0
" >> /etc/wireguard/clients/${CLIENT_ID}.conf

# Append to server config
echo "

[Peer]
PublicKey = ${CLIENT_PUBLIC}
AllowedIPs = 10.8.3.${NEXT_IP}/32
" >> /etc/wireguard/wg0.conf

# Bump next IP 
echo "$NEXT_IP" > .last_ip_used

qrencode -t ansiutf8 < /etc/wireguard/clients/${CLIENT_ID}.conf

# Load changes to wireguard service
wg addconf wg0 <(wg-quick strip wg0)

