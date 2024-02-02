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

echo "##### Pull the container images #####"
kubeadm config images pull >/dev/null
kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml >/dev/null
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml >/dev/null
kubeadm token create --print-join-command > /joincluster.sh

sudo subscription-manager remove --all
sudo subscription-manager unregister
sudo subscription-manager clean