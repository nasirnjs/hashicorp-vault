sudo tee /etc/vault.d/vault.hcl > /dev/null << EOF
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-1"

  retry_join {
    leader_api_addr = "http://172.31.40.101:8200"
  }

  retry_join {
    leader_api_addr = "http://172.31.41.33:8200"
  }

}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://172.31.35.27:8200"
cluster_addr = "http://172.31.35.27:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "f5bc87c4-e1e2-4931-aa29-b5db7f734637"
}
EOF

=============
sudo tee /etc/vault.d/vault.hcl > /dev/null << EOF
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-2"

  retry_join {
    leader_api_addr = "http://172.31.35.27:8200"
  }

  retry_join {
    leader_api_addr = "http://172.31.41.33:8200"
  }

}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://172.31.40.101:8200"
cluster_addr = "http://172.31.40.101:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "f5bc87c4-e1e2-4931-aa29-b5db7f734637"
}
EOF
=====================
sudo tee /etc/vault.d/vault.hcl > /dev/null << EOF
storage "raft" {
  path    = "/vault/data"
  node_id = "vault-node-3"

  retry_join {
    leader_api_addr = "http://172.31.35.27:8200"
  }

  retry_join {
    leader_api_addr = "http://172.31.40.101:8200"
  }

}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}

api_addr     = "http://172.31.41.33:8200"
cluster_addr = "http://172.31.41.33:8201"
ui = true

seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "f5bc87c4-e1e2-4931-aa29-b5db7f734637"
}
EOF