

## Create KMS


## Create a IAM User and Make a policy allow only KMS


## Export IAM User Access and and Secreat Key (Use Case Third-party service)

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
