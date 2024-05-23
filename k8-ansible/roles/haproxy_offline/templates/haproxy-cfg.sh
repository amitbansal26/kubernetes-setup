cat <<EOF >/etc/haproxy/haproxy.cfg
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