
#!/bin/bash
set -e

NETWORK_NAME="openstack-net"
SUBNET="192.168.2.0/24"
GATEWAY="192.168.2.253"
PARENT_IFACE="eth0" # change if different

# Step 1: Create ipvlan network if missing
if ! podman network exists $NETWORK_NAME; then
  echo "[+] Creating Podman ipvlan network..."
  podman network create \
    --driver ipvlan \
    --subnet $SUBNET \
    --gateway $GATEWAY \
    --opt parent=$PARENT_IFACE \
    $NETWORK_NAME
fi

# Step 2: Load loop module if not loaded
echo "[+] Loading loop module..."
if ! lsmod | grep -q '^loop'; then
  modprobe loop
fi

# Step 3: Start containers
echo "[+] Starting containers..."
podman run -d --name networker --hostname networker \
  --network $NETWORK_NAME --ip 192.168.2.101 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --systemd=always openstack-networker:latest

podman run -d --name compute1 --hostname compute1 \
  --network $NETWORK_NAME --ip 192.168.2.111 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --systemd=always openstack-compute:latest

podman run -d --name compute2 --hostname compute2 \
  --network $NETWORK_NAME --ip 192.168.2.112 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --systemd=always openstack-compute:latest

podman run -d --name storage --hostname storage \
  --network $NETWORK_NAME --ip 192.168.2.116 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --systemd=always openstack-storage:latest

podman run -d --name monitoring --hostname monitoring \
  --network $NETWORK_NAME --ip 192.168.2.121 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --systemd=always openstack-monitoring:latest

# Step 4: Wait for systemd boot inside containers
echo "[+] Waiting for containers to be ready..."
sleep 20

# Step 5: Deploy OpenStack with Kolla Ansible
echo "[+] Deploying OpenStack..."
kolla-ansible bootstrap-servers -i all-in-one
kolla-ansible prechecks -i all-in-one
kolla-ansible deploy -i all-in-one
kolla-ansible post-deploy

# Step 6: Show Horizon access info
echo "====================================="
echo "[+] OpenStack deployment complete!"
echo "Horizon Dashboard: http://192.168.2.32/"
echo "Credentials: admin / (check /etc/kolla/admin-openrc.sh)"
echo "====================================="
