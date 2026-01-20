

- [Create KMS](#create-kms)
- [Make a policy `vault-auto-unseal` allow only KMS attach KMS arn](#make-a-policy-vault-auto-unseal-allow-only-kms-attach-kms-arn)
- [Create a IAM User and add KMS Policy](#create-a-iam-user-and-add-kms-policy)
- [Export IAM User Access and and Secreat Key (Use Case, Third-party service)](#export-iam-user-access-and-and-secreat-key-use-case-third-party-service)
- [Install Vault (All Nodes)](#install-vault-all-nodes)
- [vault-node-1 Configurations](#vault-node-1-configurations)
- [vault-node-2 Configurations](#vault-node-2-configurations)
- [vault-node-3 Configurations](#vault-node-3-configurations)
- [Vault HAProxy configuration without TLS](#vault-haproxy-configuration-without-tls)


## Create KMS

## Make a policy `vault-auto-unseal` allow only KMS attach KMS arn

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": "<KMS_KEY_ARN>"
    }
  ]
}
```

## Create a IAM User and add KMS Policy


## Export IAM User Access and and Secreat Key (Use Case, Third-party service)

## Install Vault (All Nodes)
There are several methods to install Vault, but the recommended way is to use HashiCorp's official APT repository. This ensures you get the latest stable and secure version with proper support. [Here](https://developer.hashicorp.com/vault/install) the step-by-step installation process for Vault on Ubuntu.

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```

`sudo systemctl start vault.service`

`sudo systemctl enable vault.service`


## vault-node-1 Configurations


```bash
sudo mkdir -p /var/vault/raft/data
```
```bash
sudo chown -R vault:vault /var/vault/raft
```
```bash
sudo cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.backup
```
```bash
sudo systemctl stop vault.service
```
```bash
sudo vim /etc/vault.d/vault.hcl
```
```bash
disable_mlock = true

storage "raft" {
  path    = "/var/vault/raft/data"
  node_id = "vault-node-1"

  retry_join {
    leader_api_addr = "http://192.168.61.132:8200"
  }

  retry_join {
    leader_api_addr = "http://192.168.61.133:8200"
  }
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://192.168.61.121:8200"
cluster_addr = "http://192.168.61.121:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "85c75274-f5af-4481-9ee4-cee25b573a88"
}
```


`sudo vim /etc/vault.d/vault.env`
```bash
AWS_ACCESS_KEY_ID=YourAccessKey
AWS_SECRET_ACCESS_KEY=YourAccessKey
AWS_DEFAULT_REGION=us-east-2
```

`sudo chown vault:vault /etc/vault.d/vault.env`

`sudo chmod 600 /etc/vault.d/vault.env`

`sudo vim /usr/lib/systemd/system/vault.service`

```bash
[Service]
EnvironmentFile=/etc/vault.d/vault.env
```
`sudo systemctl daemon-reload`

`sudo systemctl restart vault`

`sudo systemctl start vault.service`

`sudo systemctl status vault`

`export VAULT_ADDR='http://127.0.0.1:8200'`

`vault operator init`

`vault status`

`vault login <ROOT_TOKEN>`

`vault operator raft list-peers`


## vault-node-2 Configurations

```bash
sudo mkdir -p /var/vault/raft/data
```
```bash
sudo chown -R vault:vault /var/vault/raft
```

```bash
sudo cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.backup
```
```bash
sudo vim /etc/vault.d/vault.hcl
```
```bash
disable_mlock = true

storage "raft" {
  path    = "/var/vault/raft/data"
  node_id = "vault-node-2"

  retry_join {
    leader_api_addr = "http://192.168.61.121:8200"
  }

  retry_join {
    leader_api_addr = "http://192.168.61.133:8200"
  }
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://192.168.61.132:8200"
cluster_addr = "http://192.168.61.132:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "85c75274-f5af-4481-9ee4-cee25b573a88"
}
```

`sudo vim /etc/vault.d/vault.env`
```bash
AWS_ACCESS_KEY_ID=YourAccessKey
AWS_SECRET_ACCESS_KEY=YourAccessKey
AWS_DEFAULT_REGION=us-east-2
```

`sudo chown vault:vault /etc/vault.d/vault.env`

`sudo chmod 600 /etc/vault.d/vault.env`

`sudo vim /usr/lib/systemd/system/vault.service`

```bash
[Service]
EnvironmentFile=/etc/vault.d/vault.env
```
`sudo systemctl daemon-reload`

`sudo systemctl restart vault`

`sudo systemctl start vault.service`

`sudo systemctl status vault`

`export VAULT_ADDR='http://127.0.0.1:8200'`

`vault status`


## vault-node-3 Configurations
```bash
sudo mkdir -p /var/vault/raft/data
```
```bash
sudo chown -R vault:vault /var/vault/raft
```
```bash
sudo cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.backup
```

```bash
sudo systemctl stop vault.service
```
```bash
sudo vim /etc/vault.d/vault.hcl
```
```bash
disable_mlock = true
storage "raft" {
  path    = "/var/vault/raft/data"
  node_id = "vault-node-3"

  retry_join {
    leader_api_addr = "http://192.168.61.121:8200"
  }

  retry_join {
    leader_api_addr = "http://192.168.61.132:8200"
  }
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://192.168.61.133:8200"
cluster_addr = "http://192.168.61.133:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "85c75274-f5af-4481-9ee4-cee25b573a88"
}

```
`sudo vim /etc/vault.d/vault.env`
```bash
AWS_ACCESS_KEY_ID=YourAccessKey
AWS_SECRET_ACCESS_KEY=YourAccessKey
AWS_DEFAULT_REGION=us-east-2
```

`sudo chown vault:vault /etc/vault.d/vault.env`

`sudo chmod 600 /etc/vault.d/vault.env`

`sudo vim /usr/lib/systemd/system/vault.service`

```bash
[Service]
EnvironmentFile=/etc/vault.d/vault.env
```
`sudo systemctl daemon-reload`

`sudo systemctl restart vault`

`sudo systemctl start vault.service`

`sudo systemctl status vault`

`export VAULT_ADDR='http://127.0.0.1:8200'`

`vault status`

- All nodes show Sealed: false
- Node 1: HA Mode: active
- Nodes 2 & 3: HA Mode: standby

```bash
# On Node 1
sudo systemctl stop vault

# On Node 2 or 3
vault status
# Should see one promote to leader within 15-30 seconds
```

## Vault HAProxy configuration without TLS
Install HAProxy (on LB server)
```bash
sudo apt update
sudo apt install haproxy -y
sudo systemctl enable haproxy
sudo systemctl status haproxy
```

**HAProxy Configuration for Vault**

```bash
sudo vim /etc/haproxy/haproxy.cfg
```

```
# ===============================
# HAProxy for Vault Cluster (HTTP only)
# ===============================
global
    log stdout format raw local0
    maxconn 2000
    daemon
defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    timeout connect 5s
    timeout client  50s
    timeout server  50s
    timeout check   5s
# -------------------------------
# Frontend: Expose Vault to clients
# -------------------------------
frontend vault_front
    bind *:8200
    default_backend vault_back
    
# -------------------------------
# Backend: Vault nodes (Leader-only traffic)
# -------------------------------
backend vault_back
    balance roundrobin

    # Vault health check
    option httpchk GET /v1/sys/health
    http-check expect status 200

    server vault1 192.168.61.121:8200 check
    server vault2 192.168.61.132:8200 check
    server vault3 192.168.61.133:8200 check

# -------------------------------
# HAProxy Stats
# -------------------------------
listen stats
    bind *:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
```
**Validate config**
```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
```

```bash
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

```bash
http://HA Proxy IP:8404/stats
```

```bash
curl http://10.70.57.21:8200/v1/sys/health
```

```bash
http://10.70.57.21:8200/v1/sys/leader
```