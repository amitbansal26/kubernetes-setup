#!/bin/bash

API_SERVER="v1.29.5"
CONTROLLER="v1.29.5"
SCHEDULER="v1.29.5"
PROXY="v1.29.5"
PAUSE="3.9"
ETCD="3.5.12-0"
COREDNS="v1.11.1"
CALICO="v3.27.0"
IMAGE_PATH="./offlineimg"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo yum update
sudo yum -y install --downloadonly --downloaddir=. kubelet kubectl kubeadm kubernetes-cni cri-tools iptables-legacy iptables-legacy-libs
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update
sudo dnf install containerd.io -y
sudo systemctl start docker

ctr image pull registry.k8s.io/kube-apiserver:$API_SERVER
ctr image pull registry.k8s.io/kube-controller-manager:$CONTROLLER
ctr image pull registry.k8s.io/kube-scheduler:$SCHEDULER
ctr image pull registry.k8s.io/kube-proxy:$PROXY
ctr image pull registry.k8s.io/pause:$PAUSE
ctr image pull registry.k8s.io/etcd:$ETCD
ctr image pull registry.k8s.io/coredns/coredns:$COREDNS
ctr image pull docker.io/calico/cni:$CALICO
ctr image pull docker.io/calico/pod2daemon-flexvol:$CALICO
ctr image pull docker.io/calico/node:$CALICO
ctr image pull docker.io/calico/kube-controllers:$CALICO

ctr image export kube-apiserver.tar registry.k8s.io/kube-apiserver:$API_SERVER
ctr image export kube-controller-manager.tar registry.k8s.io/kube-controller-manager:$CONTROLLER
ctr image export kube-scheduler.tar registry.k8s.io/kube-scheduler:$SCHEDULER
ctr image export kube-proxy.tar registry.k8s.io/kube-proxy:$PROXY
ctr image export pause.tar registry.k8s.io/pause:$PAUSE
ctr image export etcd.tar registry.k8s.io/etcd:$ETCD
ctr image export coredns.tar registry.k8s.io/coredns/coredns:$COREDNS
ctr image export calico-cni.tar quay.io/calico/cni:$CALICO
ctr image export calico-pod2daemon-flexvol.tar quay.io/calico/pod2daemon-flexvol:$CALICO
ctr image export calico-node.tar quay.io/calico/node:$CALICO
ctr image export calico-kube-controllers.tar quay.io/calico/kube-controllers:$CALICO

mkdir $IMAGE_PATH
mv ./*.tar $IMAGE_PATH

TIGERA_PATH="./calico"
curl -L -O "https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml"
mkdir $TIGERA_PATH
mv ./*.yaml $TIGERA_PATH