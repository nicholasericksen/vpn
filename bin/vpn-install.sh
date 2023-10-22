#!/usr/bin/bash

# Update
sudo yum update -y

# Install wireguard
sudo yum install epel-release https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y
sudo yum install yum-plugin-elrepo -y
sudo yum install kmod-wireguard wireguard-tools -y

sudo yum install qrencode -y

sudo yum install dnsmasq -y
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

# Enable ipv4 forwarding
echo "
net.ipv4.ip_forward = 1
" >> /etc/sysctl.conf

sudo systemctl restart network

sudo mkdir /etc/wireguard/clients

# Generate Public and Private Keys for Server
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey

# Create client keys
wg genkey | sudo tee /etc/wireguard/clients/mobile.key | wg pubkey | sudo tee /etc/wireguard/clients/mobile.key.pub

# Save keys to ENV variables
SERVER_PUBLIC=$(cat /etc/wireguard/publickey)
SERVER_PRIVATE=$(cat /etc/wireguard/privatekey)
CLIENT_PRIVATE=$(cat /etc/wireguard/clients/mobile.key)
CLIENT_PUBLIC=$(cat /etc/wireguard/clients/mobile.key.pub)

# Save public IP of VPN server
EXTERNAL_IP=$(ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}' | head -n 1)

# Create client config
echo "
[Interface]
PrivateKey = ${CLIENT_PRIVATE}
Address = 10.8.3.2/24
DNS = 10.8.3.1

[Peer]
PublicKey = ${SERVER_PUBLIC}
Endpoint = ${EXTERNAL_IP}:1194
AllowedIPs = 0.0.0.0/0
" >> /etc/wireguard/clients/mobile.conf


# Create the server configuration
echo "
[Interface]
Address = 10.8.3.1/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 1194
PrivateKey = ${SERVER_PRIVATE}

[Peer]
PublicKey = ${CLIENT_PUBLIC}
AllowedIPs = 10.8.3.2/32
" >> /etc/wireguard/wg0.conf

# Lock down key and conf permissions
sudo chmod 600 /etc/wireguard/{privatekey,wg0.conf}

# Generate Client config QR code
qrencode -t ansiutf8 < /etc/wireguard/clients/mobile.conf

# Start the interface
#sudo wg-quick up wg0
LAST_IP=$(cat .last_ip_used)
echo ${LAST_IP} > .last_ip_used

# Enable and start the interface
sudo systemctl enable wg-quick@wg0

# Email key

BODY=$(cat /etc/wireguard/clients/mobile.conf | base64)
NAME=$(date +%s)

echo "From: Sender <noreply@beaker.fm>
To: ${ADMIN_EMAIL}
Subject: PnL VPN Activation
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="19032019ABCDE"

--19032019ABCDE
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Attached is the key to your Private VPN server. Keep it secret, keep it safe.

    May you do good and not evil.
    May you find forgiveness for yourself and forgive others.
    May you share freely, never taking more than you give.

--19032019ABCDE
Content-Type: application;
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="${NAME}.conf"

${BODY}

--19032019ABCDE--
" > email.eml

sendmail -t < email.eml

sudo reboot
