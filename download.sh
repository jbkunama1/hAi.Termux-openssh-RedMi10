#!/bin/bash
# download-termux-ssh.sh - Schnell-Download für Termux SSH Setup

echo "📥 Downloading Termux SSH Server Setup..."

curl -o sshd-manage.sh https://raw.githubusercontent.com/jbkunama1/hAi.Termux-openssh-RedMi10/main/sshd-manage.sh
chmod +x sshd-manage.sh
mv sshd-manage.sh $PREFIX/bin/sshd-manage

echo "✅ Script installed! Usage: sshd-manage start"
echo "Full guide: https://jbkunama1.github.io/hAi.Termux-openssh-RedMi10/"
