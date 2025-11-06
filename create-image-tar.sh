#!/bin/bash
# Script to create image tar for container tools
# Usage: ./create-image-tar.sh <username> <password>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    echo "Example: $0 myuser mypassword"
    exit 1
fi

username="$1"
password="$2"

sudo subscription-manager register --username "$username" --password "$password" --auto-attach
sudo dnf install container-tools -y 
sudo subscription-manager remove --all
sudo subscription-manager unregister
sudo subscription-manager clean
