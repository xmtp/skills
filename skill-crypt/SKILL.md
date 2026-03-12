---
name: skill-crypt
version: 0.1.0
metadata:
  openclaw:
    requires:
      bins: [node]
      config: ["SKILLCRYPT_WALLET_KEY"]
    install:
      - kind: git
        repo: "https://github.com/skillcrypt-alt/skill-crypt"
        postInstall: "npm install"
description: >
  Encrypted skill storage and agent-to-agent skill transfer over XMTP.
  Skills are encrypted at rest with AES-256-GCM using a key derived from
  the agent's wallet private key. Skills live in an encrypted vault instead
  of as plaintext files on disk. Agents exchange skills over XMTP using a
  lightweight request/transfer protocol with catalog discovery, content
  hashing, and acknowledgment. Use this when you want to encrypt plaintext
  skills so they are not readable from the filesystem, share skills between
  agents over XMTP end-to-end encryption, rotate vault encryption keys
  when a wallet is compromised, or treat agent skills as transferable
  encrypted assets.
---

# Skill-Crypt

Encrypted skill storage backed by XMTP. Your skills live in an AES-256-GCM vault derived from your wallet key instead of as plaintext markdown on disk. When you need a skill, it gets decrypted into memory, used, and never written back to the filesystem.

Agents can exchange skills over XMTP. The transfer protocol handles catalog discovery, skill requests, content transfer, and receipt acknowledgment. Skills travel through XMTP's MLS end-to-end encryption and get re-encrypted with the receiver's wallet key on arrival.

> [!CAUTION]
> Alpha. Use a dedicated wallet with no funds. The vault manifest (skill names, tags, sizes) is stored in plaintext for indexing. Only skill content is encrypted.

## Prerequisites

- Node.js 20+
- An Ethereum wallet private key (hex). Generate a fresh one for this purpose.
- XMTP registration (handled automatically on first `transfer` command)

## Setup

Clone and install the skill-crypt repo:

```bash
git clone https://github.com/skillcrypt-alt/skill-crypt.git
cd skill-crypt
npm install
```

Set your wallet key:

```bash
export SKILLCRYPT_WALLET_KEY="0xYOUR_PRIVATE_KEY_HEX"
```

Optional environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `SKILLCRYPT_VAULT` | `./data/vault` | Vault storage directory |
| `SKILLCRYPT_XMTP_ENV` | `production` | XMTP network (`production` or `dev`) |

## Encrypting Skills

Move a plaintext skill into the vault:

```bash
node src/cli.js encrypt /path/to/SKILL.md
```

This reads the file, encrypts the content, stores the `.enc` file in the vault, and prints the skill ID. Delete the plaintext original after confirming the vault entry.

To encrypt all skills in a directory:

```bash
for f in ~/.openclaw/workspace/skills/*/SKILL.md; do
  node src/cli.js encrypt "$f"
done
```

## Loading Skills

Decrypt a skill to stdout (never redirect to a file):

```bash
node src/cli.js decrypt <skill-id>
```

The agent reads the output into its context window, follows the instructions, and the plaintext exists only in process memory for the duration of the task.

## Vault Management

```bash
node src/cli.js vault list              # list all encrypted skills
node src/cli.js vault find <query>      # search by name, tag, or description
node src/cli.js vault remove <skill-id> # delete a skill from the vault
```

## Key Rotation

Re-encrypt the entire vault with a new wallet key:

```bash
node src/cli.js rotate <new-wallet-key-hex>
```

After rotation, update `SKILLCRYPT_WALLET_KEY` to the new key. The old key can no longer decrypt anything in the vault. Rotation is atomic per skill and reports failures individually.

## Transferring Skills Between Agents

All transfer commands connect to XMTP using your wallet key. The first connection registers your wallet on the network if it is not already registered.

**Request another agent's skill catalog:**

```bash
node src/cli.js transfer catalog <wallet-address>
```

**Request a specific skill:**

```bash
node src/cli.js transfer request <wallet-address> <skill-id>
```

**Listen for incoming requests and transfers:**

```bash
node src/cli.js transfer listen
```

When listening, the agent automatically responds to catalog requests with its vault metadata, fulfills skill requests by decrypting and sending the content over XMTP, and stores incoming skill transfers by re-encrypting them with its own key.

## Transfer Protocol

Five message types over XMTP direct messages:

| Message | Direction | Purpose |
|---------|-----------|---------|
| `skillcrypt:catalog-request` | requester to provider | "What skills do you have?" |
| `skillcrypt:catalog` | provider to requester | Skill metadata (names, tags, sizes, no content) |
| `skillcrypt:skill-request` | requester to provider | "Send me this specific skill" |
| `skillcrypt:skill-transfer` | provider to requester | Full skill content (encrypted by XMTP in transit) |
| `skillcrypt:ack` | requester to provider | "Received and stored" |

No servers, no registries. Two wallets talking over encrypted messaging.

## Security Model

| Layer | Protection | Method |
|-------|-----------|--------|
| At rest | Skill content on disk | AES-256-GCM, key derived from wallet via HKDF-SHA256 |
| In transit | Skills between agents | XMTP MLS end-to-end encryption |
| In memory | Runtime exposure | Decrypted only into process memory, never to filesystem |
| Access control | Who can read skills | Wallet private key is the sole key |
| Integrity | Content tampering | SHA-256 content hash verified on decrypt |
| Authentication | Modified ciphertext | GCM auth tag rejects any changes |

**Rules the agent must follow:**
- Never write decrypted skill content to a file
- Never include skill content in logs, error messages, or responses
- Never share the wallet private key
- Never commit the vault directory to version control

## Limitations

- Once a skill is transferred, it cannot be technically revoked. The receiver has their own encrypted copy.
- The vault manifest is plaintext. Skill names, tags, and sizes are visible to anyone with filesystem access. Only content is encrypted.
- XMTP allows up to 10 installations per wallet. The client reuses deterministic database paths to stay within this limit.

## Source

Full source, tests, and protocol specification: [github.com/skillcrypt-alt/skill-crypt](https://github.com/skillcrypt-alt/skill-crypt)
