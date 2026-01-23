# Security Requirements

Security checklist and best practices for XMTP integrations.

## Table of Contents
- [Private Key Handling](#private-key-handling)
- [XSS Prevention](#xss-prevention)
- [Input Validation](#input-validation)
- [OPFS Security](#opfs-security)
- [Content Security Policy](#content-security-policy)
- [Anti-Patterns](#anti-patterns)
- [Security Checklist](#security-checklist)

## Private Key Handling

### Never Log or Expose Keys

```typescript
// ❌ NEVER DO THIS
console.log('Private key:', privateKey);
console.log('Signer:', JSON.stringify(signer));

// ✅ Safe logging
console.log('[XMTP] Client initialized:', {
  inboxId: client.inboxId,
  address: await signer.getAddress(),
  // Never include private key or signer object
});
```

### Memory-Only Storage

```typescript
// ❌ NEVER store keys in localStorage
localStorage.setItem('xmtp_key', privateKey);

// ❌ NEVER store in sessionStorage
sessionStorage.setItem('xmtp_key', privateKey);

// ✅ Keys only in memory (React refs or closures)
const signerRef = useRef<Signer | null>(null);
```

### Clear on Disconnect

```typescript
const disconnect = useCallback(async () => {
  // Close XMTP client (clears internal state)
  if (clientRef.current) {
    await clientRef.current.close();
    clientRef.current = null;
  }

  // Clear any signer references
  signerRef.current = null;

  // Reset store
  resetStore();

  // Force garbage collection hint
  if (global.gc) global.gc();
}, []);
```

### Secure Key Generation

```typescript
// ❌ NEVER use Math.random() for cryptographic purposes
const badKey = Array.from({ length: 32 }, () =>
  Math.floor(Math.random() * 256)
);

// ✅ Use crypto.getRandomValues()
const secureKey = new Uint8Array(32);
crypto.getRandomValues(secureKey);

// ✅ Or use viem's helper (uses crypto internally)
import { generatePrivateKey } from 'viem/accounts';
const privateKey = generatePrivateKey();
```

## XSS Prevention

### Sanitize Message Content

```typescript
import DOMPurify from 'dompurify';

// ✅ Sanitize before rendering
function MessageContent({ content }: { content: string }) {
  const sanitized = DOMPurify.sanitize(content, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href'],
  });

  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// ✅ Better: Use React's automatic escaping
function MessageContent({ content }: { content: string }) {
  return <p>{content}</p>; // Auto-escaped
}
```

### Never Use dangerouslySetInnerHTML with User Content

```typescript
// ❌ DANGEROUS
<div dangerouslySetInnerHTML={{ __html: message.content }} />

// ✅ Safe - React escapes automatically
<div>{message.content}</div>

// ✅ If HTML is needed, sanitize first
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(message.content) }} />
```

### Escape Usernames and Group Names

```typescript
// ❌ Direct interpolation is risky in some contexts
document.title = `Chat with ${groupName}`;

// ✅ Use textContent for DOM
element.textContent = groupName;

// ✅ React handles this safely
<h1>{groupName}</h1>
```

### Validate Attachment URLs

```typescript
function validateAttachmentUrl(url: string): boolean {
  try {
    const parsed = new URL(url);

    // Only allow https (except localhost for dev)
    if (parsed.protocol !== 'https:' && parsed.hostname !== 'localhost') {
      return false;
    }

    // Block known dangerous patterns
    if (parsed.protocol === 'javascript:' || parsed.protocol === 'data:') {
      return false;
    }

    return true;
  } catch {
    return false;
  }
}

// Usage
function AttachmentImage({ url, alt }: Props) {
  if (!validateAttachmentUrl(url)) {
    return <span>Invalid attachment</span>;
  }

  return <img src={url} alt={alt} loading="lazy" />;
}
```

## Input Validation

### Validate Ethereum Addresses

```typescript
import { isAddress, getAddress } from 'viem';

function validateAddress(input: string): string | null {
  const trimmed = input.trim();

  if (!isAddress(trimmed)) {
    return null;
  }

  // Return checksummed version
  return getAddress(trimmed);
}
```

### Validate Attachment Files

```typescript
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
  'application/pdf',
  'text/plain',
];

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB

function validateFile(file: File): { valid: boolean; error?: string } {
  if (file.size > MAX_FILE_SIZE) {
    return { valid: false, error: 'File too large (max 10MB)' };
  }

  if (!ALLOWED_MIME_TYPES.includes(file.type)) {
    return { valid: false, error: 'File type not allowed' };
  }

  // Additional checks for images
  if (file.type.startsWith('image/')) {
    // Could add dimension checks here
  }

  return { valid: true };
}
```

### Sanitize Group Names

```typescript
const MAX_GROUP_NAME_LENGTH = 100;
const FORBIDDEN_CHARS = /<>{}|\\^`/;

function sanitizeGroupName(name: string): string {
  return name
    .trim()
    .slice(0, MAX_GROUP_NAME_LENGTH)
    .replace(FORBIDDEN_CHARS, '');
}
```

### Rate Limit Message Sending

```typescript
class RateLimiter {
  private timestamps: number[] = [];
  private maxRequests: number;
  private windowMs: number;

  constructor(maxRequests = 10, windowMs = 60000) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
  }

  canProceed(): boolean {
    const now = Date.now();
    this.timestamps = this.timestamps.filter(t => now - t < this.windowMs);

    if (this.timestamps.length >= this.maxRequests) {
      return false;
    }

    this.timestamps.push(now);
    return true;
  }
}

// Usage in send function
const rateLimiter = new RateLimiter(10, 60000); // 10 messages per minute

const send = async (text: string) => {
  if (!rateLimiter.canProceed()) {
    throw new Error('Rate limit exceeded. Please wait before sending more messages.');
  }

  await conversation.send(text);
};
```

## OPFS Security

### Same-Origin Only

OPFS (Origin Private File System) is automatically same-origin. Document this limitation:

```typescript
// OPFS is only accessible from the same origin
// https://example.com cannot access OPFS from https://other.com
// This is a browser security feature, not a limitation to work around
```

### Database Not Encrypted at Rest

```typescript
// Note: XMTP's OPFS database is NOT encrypted at rest
// For sensitive deployments, consider:
// 1. Using production network (more secure)
// 2. Implementing additional application-level encryption
// 3. Clearing data on logout
```

### Proper Cleanup on Logout

```typescript
async function cleanupOnLogout() {
  // 1. Close XMTP client
  if (clientRef.current) {
    await clientRef.current.close();
  }

  // 2. Clear OPFS database
  try {
    const root = await navigator.storage.getDirectory();
    await root.removeEntry('xmtp', { recursive: true });
  } catch (e) {
    // May not exist, that's fine
  }

  // 3. Clear any cached data
  localStorage.removeItem('xmtp_last_sync');

  console.log('[XMTP] Cleanup complete');
}
```

## Content Security Policy

Recommended CSP for XMTP applications:

```typescript
// next.config.js
const cspHeader = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  connect-src 'self' https://*.xmtp.network wss://*.xmtp.network;
  img-src 'self' data: https:;
  font-src 'self';
`;

// Add to headers
module.exports = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: cspHeader.replace(/\n/g, ''),
          },
        ],
      },
    ];
  },
};
```

### Environment Example

```bash
# .env.example

# XMTP Configuration
NEXT_PUBLIC_XMTP_ENV=production

# Optional: Custom XMTP gateway
# NEXT_PUBLIC_XMTP_GATEWAY_HOST=https://your-gateway.example.com

# CSP: Allow XMTP network connections
# Add to your CSP: connect-src 'self' https://*.xmtp.network wss://*.xmtp.network;
```

## Anti-Patterns

### Don't Store Sensitive Data in LocalStorage

```typescript
// ❌ Never store these in localStorage/sessionStorage:
// - Private keys
// - Wallet signatures
// - Auth tokens for XMTP
// - Full message history (privacy concern)
```

### Don't Log Full Messages in Production

```typescript
// ❌ In production
console.log('Message received:', message);

// ✅ Log safely
console.log('[XMTP] Message received:', {
  id: message.id,
  conversationId: message.conversationId,
  // Don't log content in production
});
```

### Don't Trust Client-Side Consent

```typescript
// ❌ Trusting client-side state alone
if (localConsentState === 'allowed') {
  showMessages();
}

// ✅ Verify with XMTP
const conversation = await client.conversations.getConversationById(id);
if (conversation.consentState === ConsentState.Allowed) {
  showMessages();
}
```

### Don't Allow Arbitrary Content Type Decoders

```typescript
// ❌ Dynamically loading decoders from untrusted sources
const decoder = await import(untrustedUrl);

// ✅ Only use known, audited content types
import { TextCodec, AttachmentCodec, ReactionCodec } from '@xmtp/content-type-*';
```

## Security Checklist

Use this checklist when reviewing generated code:

### Key Management
- [ ] Private keys never logged or exposed
- [ ] Keys stored only in memory (refs/closures)
- [ ] Keys cleared on disconnect
- [ ] Secure random generation used

### XSS Prevention
- [ ] Message content sanitized or auto-escaped
- [ ] No dangerouslySetInnerHTML with user content
- [ ] Attachment URLs validated
- [ ] Group names sanitized

### Input Validation
- [ ] Ethereum addresses validated
- [ ] File types and sizes checked
- [ ] Rate limiting implemented
- [ ] User input sanitized

### Data Protection
- [ ] OPFS cleanup on logout
- [ ] No sensitive data in localStorage
- [ ] Production logging is minimal
- [ ] CSP configured correctly

### Network Security
- [ ] HTTPS only (except localhost dev)
- [ ] XMTP network connections allowed in CSP
- [ ] No arbitrary external resources loaded
