#!/bin/bash


BODY=$(cat /etc/wireguard/clients/mobile.conf | base64)
NAME=$(date +%s)

echo "From: Sender <noreply@pnl.nyc>
To: ${ADMIN_EMAIL}
Subject: VPN Activation
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
