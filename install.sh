cd /root

wget -O /root/x-ui.db "https://github.com/kirillvaht75-afk/my-xui/blob/main/x-ui.db"

echo "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

systemctl stop x-ui

while pgrep -x x-ui >/dev/null; do
  sleep 1
done

rm -f /etc/x-ui/x-ui.db-wal
rm -f /etc/x-ui/x-ui.db-shm

install \
  -o root \
  -g root \
  -m 600 \
  /root/x-ui.db \
  /etc/x-ui/x-ui.db

sync

systemctl start x-ui

ufw disable

fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

echo '/swapfile none swap sw 0 0' >> /etc/fstab

echo "Applying TCP buffer optimizations..."

sysctl -w net.core.rmem_max=67108864
sysctl -w net.core.wmem_max=67108864
sysctl -w net.core.netdev_max_backlog=100000

cat <<EOF >> /etc/sysctl.conf
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 100000
EOF

sysctl -p

echo "TCP buffer optimizations applied successfully!"

systemctl restart x-ui

# EDIT: BY MEHTI v3.6

systemctl stop x-ui

while pgrep -x x-ui >/dev/null; do
  sleep 1
done

rm -f /etc/x-ui/x-ui.db-wal
rm -f /etc/x-ui/x-ui.db-shm

install \
  -o root \
  -g root \
  -m 600 \
  /root/x-ui.db \
  /etc/x-ui/x-ui.db

sync

systemctl start x-ui

sleep 5

systemctl status x-ui --no-pager
journalctl -u x-ui -n 100 --no-pager
