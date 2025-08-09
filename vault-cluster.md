aws kms create-key \
  --description "My KMS Key for Vault encryption" \
  --key-usage ENCRYPT_DECRYPT \
  --origin AWS_KMS \
  --tags TagKey=Name,TagValue=test

aws kms create-alias \              
  --alias-name alias/dev-vault-unseal-key \
  --target-key-id 48e4b2c8-9e86-4bf3-8d7c-325e0057bc01

======
1. Create the IAM vault-kms-unseal-policy
aws iam create-policy \
  --policy-name VaultKMSUnsealPolicy \
  --policy-document file://vault-kms-unseal-policy.json

2. ec2-trust-policy
aws iam create-role \
  --role-name VaultEC2UnsealRole \
  --assume-role-policy-document file://ec2-trust-policy.json


3. Attach the policy to the role
aws iam attach-role-policy \
  --role-name VaultEC2UnsealRole \
  --policy-arn arn:aws:iam::137440810107:policy/VaultKMSUnsealPolicy
  
4. Create instance profile
aws iam create-instance-profile --instance-profile-name VaultEC2InstanceProfile

5. Add role to instance profile
aws iam add-role-to-instance-profile \
  --instance-profile-name VaultEC2InstanceProfile \
  --role-name VaultEC2UnsealRole

6. Attach the instance profile to your each EC2 Vault instance

aws ec2 associate-iam-instance-profile \
  --instance-id i-0a6bddba190c74d16 \
  --iam-instance-profile Name=VaultEC2InstanceProfile
 
aws ec2 associate-iam-instance-profile \
  --instance-id i-08c94c39b596dc8f6 \
  --iam-instance-profile Name=VaultEC2InstanceProfile

aws ec2 associate-iam-instance-profile \
  --instance-id i-09c3d444859322e9c \
  --iam-instance-profile Name=VaultEC2InstanceProfile

================
Add External Volume to vault server
sudo mkfs.ext4 /dev/nvme1n1 && \
sudo mkdir -p /vault/data && \
sudo mount /dev/nvme1n1 /vault/data && \
echo '/dev/nvme1n1   /vault/data   ext4   defaults,nofail   0   2' | sudo tee -a /etc/fstab

========
Install vault







=====
sudo tee /etc/vault.d/vault.hcl > /dev/null << EOF
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-1"

  retry_join {
    leader_api_addr = "http://172.31.38.106:8200"
  }

  retry_join {
    leader_api_addr = "http://172.31.33.127:8200"
  }

}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://172.31.37.187:8200"
cluster_addr = "http://172.31.37.187:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "48e4b2c8-9e86-4bf3-8d7c-325e0057bc01"
}
EOF

`sudo systemctl restart vault.service`

`sudo systemctl status vault.service`

=============
sudo tee /etc/vault.d/vault.hcl > /dev/null << EOF
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-2"

  retry_join {
    leader_api_addr = "http://172.31.37.187:8200"
  }

  retry_join {
    leader_api_addr = "http://172.31.33.127:8200"
  }

}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://172.31.38.106:8200"
cluster_addr = "http://172.31.38.106:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "48e4b2c8-9e86-4bf3-8d7c-325e0057bc01"
}
EOF
=====================
sudo tee /etc/vault.d/vault.hcl > /dev/null << EOF
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-3"

  retry_join {
    leader_api_addr = "http://172.31.37.187:8200"
  }

  retry_join {
    leader_api_addr = "http://172.31.38.106:8200"
  }

}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://172.31.33.127:8200"
cluster_addr = "http://172.31.33.127:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "48e4b2c8-9e86-4bf3-8d7c-325e0057bc01"
}
EOF

=========================================
Run this each vault server

```
sudo chmod 0644 /lib/systemd/system/vault.service
sudo systemctl daemon-reload

sudo chmod -R 0644 /etc/vault.d/*
sudo chmod 0755 /usr/local/bin/vault

sudo tee /etc/profile.d/vault.sh > /dev/null <<EOF
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_SKIP_VERIFY=true
EOF
sudo chmod 0644 /etc/profile.d/vault.sh

# Add sourcing of vault.sh to ~/.bashrc if not already present
grep -q '/etc/profile.d/vault.sh' ~/.bashrc || echo 'source /etc/profile.d/vault.sh' >> ~/.bashrc

sudo systemctl enable vault
sudo systemctl restart vault

# Export for current shell session
export VAULT_ADDR=http://127.0.0.1:8200
```
`source ~/.bashrc`

====================================== 
Only Master Server

`vault  operator  init`

`vault login hvs.liO`

`vault operator raft list-peers`


