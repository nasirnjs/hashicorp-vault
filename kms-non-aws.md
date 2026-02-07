# Vault Auto-Unseal Using AWS KMS (IAM User – Non-AWS)

This document explains the **best-practice approach** for configuring **HashiCorp Vault auto-unseal using AWS KMS** when Vault is **NOT running on AWS EC2** (on‑prem, VM, other cloud, third-party hosting).

---

## When to Use This Option

- Vault running outside AWS
- No access to IAM Roles / EC2 metadata
- Requires secure handling of AWS access keys

> If Vault runs on AWS EC2, IAM Roles are the recommended approach instead of IAM users.

---

## Core Concept (Mental Model)

```
Vault
  ↓ (AWS credentials)
IAM User
  ↓ (IAM policy allows access)
AWS KMS Key
```

**Important rules**
- Vault is never attached to a KMS key
- IAM policy controls access to KMS
- KMS validates IAM authorization only

---

## Correct Setup Order

### 1️⃣ Create the AWS KMS Key

Create a **symmetric KMS key** with:

- Key type: Symmetric
- Usage: Encrypt / Decrypt
- Region: Same as Vault
- Key rotation: Enabled

Do **NOT** attach users or Vault to the KMS key.

---

### 2️⃣ Create a Dedicated IAM User for Vault

Create a dedicated IAM user:

- Username: `vault-auto-unseal`
- Access type: Programmatic access only
- Console login: Disabled

This user must be used **only** for Vault auto-unseal.

---

### 3️⃣ Create IAM Policy (Least Privilege)

```json
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
      "Resource": "arn:aws:kms:REGION:ACCOUNT_ID:key/KMS_KEY_ID"
    }
  ]
}
```

- No wildcard permissions
- Scoped to a single KMS key

---

### 4️⃣ Attach Policy to the IAM User

Attach the IAM policy to:

```
IAM User → vault-auto-unseal
```

This is the **only required attachment**.

---

### 5️⃣ Generate Access Key and Secret Key

From the IAM user:

- Generate Access Key
- Download Secret Key
- Store securely

These credentials allow Vault to decrypt its master key.

---

### 6️⃣ Provide AWS Credentials to Vault

Because Vault runs outside AWS, credentials must be provided manually.

Recommended method:

```bash
AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
AWS_DEFAULT_REGION=us-east-2
```

**Best practices**
- Path: `/etc/vault.d/vault.env`
- Owner: `vault:vault`
- Permissions: `600`
- Load via systemd `EnvironmentFile`

---

### 7️⃣ Configure Vault Auto-Unseal

```hcl
seal "awskms" {
  region     = "us-east-2"
  kms_key_id = "KMS_KEY_ID"
}
```

- No IAM username in config
- AWS SDK automatically reads environment variables

---

## Runtime Behavior

1. Vault loads AWS credentials
2. Vault calls `kms:Decrypt`
3. IAM policy is evaluated
4. KMS decrypts the master key
5. Vault auto-unseals

---

## Common Misconceptions

- IAM users are **not** attached to KMS keys
- Vault is **not** configured inside KMS
- KMS trusts **IAM authorization**, not Vault

---

## Security Recommendations

- Rotate IAM access keys every 30–90 days
- Restrict policy to a single KMS key
- Use a dedicated AWS account if possible
- Never commit credentials to source control
- Lock down `/etc/vault.d/vault.env` permissions

---

## Final Summary

> **For non-AWS Vault deployments:**  
> **KMS Key → IAM Policy → IAM User → Vault Auto-Unseal**
