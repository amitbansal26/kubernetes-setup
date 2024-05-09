#!/bin/bash
sudo subscription-manager register --username amitbansal26 --password ##### --auto-attach
sudo dnf install container-tools -y 
sudo subscription-manager remove --all
sudo subscription-manager unregister
sudo subscription-manager clean
