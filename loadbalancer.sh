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
# Set default keepalived password - override with environment variable for production
KEEPALIVED_AUTH_PASS="${KEEPALIVED_AUTH_PASS:-mysecret}"

echo "######################################################################################################"
echo "Starting loadbalancer setup..."
echo "######################################################################################################"
sudo subscription-manager register --username "$username" --password "$password" --auto-attach

sudo dnf info haproxy -y
sudo dnf install haproxy keepalived -y
cat >>/etc/keepalived/check_apiserver.sh<<EOF
#!/bin/sh

errorExit() {
  echo "*** $@" 1>&2
  exit 1
}

curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q 172.16.16.100; then
  curl --silent --max-time 2 --insecure https://172.16.16.100:6443/ -o /dev/null || errorExit "Error GET https://172.16.16.100:6443/"
fi
EOF


sudo chmod +x /etc/keepalived/check_apiserver.sh

cat >>/etc/keepalived/keepalived.conf<<EOF
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  timeout 10
  fall 5
  rise 2
  weight -2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 1
    priority 100
    advert_int 5
    authentication {
        auth_type PASS
        auth_pass ${KEEPALIVED_AUTH_PASS}
    }
    virtual_ipaddress {
        172.16.16.100
    }
    track_script {
        check_apiserver
    }
}
EOF
# Note: Default KEEPALIVED_AUTH_PASS is 'mysecret'
# For production, set environment variable: export KEEPALIVED_AUTH_PASS='your-secure-password'
sudo systemctl enable --now keepalived

cat >> /etc/haproxy/haproxy.cfg <<EOF

frontend kubernetes-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kubernetes-backend

backend kubernetes-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
    server master1 172.16.16.101:6443 check fall 3 rise 2
    server master2 172.16.16.102:6443 check fall 3 rise 2
    server master3 172.16.16.103:6443 check fall 3 rise 2

EOF

sudo subscription-manager remove --all
sudo subscription-manager unregister
sudo subscription-manager clean

sudo systemctl enable haproxy && sudo systemctl restart haproxy