#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1 
fi
if [ -z "$1" ]
  then
    echo "No username supplied"
    exit 1
fi
if [ -z "$2" ]
  then
    echo "No password supplied"
    exit 1
fi
username=$1
password=$2
sudo subscription-manager register --username $username --password $password --auto-attach
echo "######### Join node to Kubernetes Cluster ######"
sudo yum install -y sshpass >/dev/null
sudo sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master1.cloudnativeapps.in:/joincluster.sh /joincluster.sh >/dev/null 2>&1
sudo bash /joincluster.sh >/dev/null

sudo subscription-manager remove --all
sudo subscription-manager unregister
sudo subscription-manager cleansudo subscription-manager remove --all
sudo subscription-manager unregister
sudo subscription-manager clean