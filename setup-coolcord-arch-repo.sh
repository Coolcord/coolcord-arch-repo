#!/usr/bin/env bash
set -euo pipefail

KEY_URL="https://raw.githubusercontent.com/Coolcord/coolcord-arch-repo/refs/heads/master/coolcord.gpg"
KEY_FILE="coolcord.gpg"
KEY_ID="EDEA50796D0E6A29F9B8E693F67A2C00B50DDB4B"

echo "==> Setting up Coolcord Arch repository..."
if ! command -v wget >/dev/null 2>&1; then
    echo "ERROR: wget is not installed."
    echo "Install it with: sudo pacman -S wget"
    exit 1
fi

echo "==> Downloading repository signing key..."
wget -O "$KEY_FILE" "$KEY_URL"

echo "==> Importing key into pacman keyring..."
sudo pacman-key --add "$KEY_FILE"

echo "==> Locally signing key..."
sudo pacman-key --lsign-key "$KEY_ID"
rm "$KEY_FILE"

echo "==> Configuring /etc/pacman.conf..."
grep -q "^\[coolcord-arch\]" /etc/pacman.conf || {
sudo cp /etc/pacman.conf /etc/pacman.conf.bak
sudo sed -i ':a;/^\n*$/{$d;N;ba}' /etc/pacman.conf
printf "\n[coolcord-arch]
Include = /etc/pacman.d/coolcord-arch-mirrorlist\n" | sudo tee -a /etc/pacman.conf >/dev/null
}

echo "==> Installing mirrorlist to /etc/pacman.d/coolcord-arch-mirrorlist"
if [ ! -e /etc/pacman.d/coolcord-arch-mirrorlist ]; then
    {
        echo "SigLevel = Required DatabaseRequired"
        echo "Server = https://gitlab.com/Coolcord/coolcord-arch-repo/-/raw/master/\$arch"
        echo "Server = https://raw.githubusercontent.com/Coolcord/coolcord-arch-repo/refs/heads/master/\$arch"
    } | sudo tee /etc/pacman.d/coolcord-arch-mirrorlist > /dev/null
fi

echo "==> Refreshing package databases..."
sudo pacman -Syy

