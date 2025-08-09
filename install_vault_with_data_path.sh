#!/bin/bash
set -e

# Run as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo bash $0"
    exit 1
fi

echo "[1/8] Installing dependencies..."
apt-get update -y
apt-get install -y unzip curl libcap2-bin

USER="vault"
COMMENT="Hashicorp vault user"
GROUP="vault"
HOME="/srv/vault"

echo "[2/8] Creating vault user and group..."
addgroup --system ${GROUP} >/dev/null || true
adduser \
  --system \
  --disabled-login \
  --ingroup ${GROUP} \
  --home ${HOME} \
  --no-create-home \
  --gecos "${COMMENT}" \
  --shell /bin/false \
  ${USER} >/dev/null || true

echo "[3/8] Downloading Vault..."
cd /opt/ && curl -s -o vault.zip https://releases.hashicorp.com/vault/1.13.1/vault_1.13.1_linux_amd64.zip
unzip -o vault.zip
mv vault /usr/local/bin/
chmod 0755 /usr/local/bin/vault
chown vault:vault /usr/local/bin/vault

echo "[4/8] Creating Vault config and data directories..."
mkdir -pm 0755 /etc/vault.d
chown -R vault:vault /etc/vault.d

mkdir -pm 0755 /vault/data
chown -R vault:vault /vault/data

mkdir -pm 0755 /opt/vault
chown vault:vault /opt/vault

echo "[5/8] Creating systemd service..."
cat << EOF > /lib/systemd/system/vault.service
[Unit]
Description=Vault Agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGTERM
User=vault
Group=vault
[Install]
WantedBy=multi-user.target
EOF

echo "[6/8] Reloading systemd..."
systemctl daemon-reload

echo "[7/8] Enabling Vault to start on boot..."
systemctl enable vault

echo "[8/8] Starting Vault..."
systemctl start vault

echo "✅ Vault installation complete."
echo "Config dir: /etc/vault.d"
echo "Data dir:   /vault/data"
echo "Binary:     /usr/local/bin/vault"
