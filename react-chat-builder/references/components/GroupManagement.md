# GroupManagement Component

Member list and admin controls for group conversations.

## Interface

```typescript
interface GroupManagementProps {
  conversationId: string;
  onClose: () => void;
  className?: string;
}
```

## CRITICAL: ENS Resolution for Adding Members

**The XMTP SDK does not resolve ENS names.** When adding members to a group, this component handles ENS resolution before passing addresses to XMTP.

When a user types `vitalik.eth` in the "add member" input:
1. The component detects it's an ENS name (contains `.`, doesn't start with `0x`)
2. It resolves to an Ethereum address using viem's ENS utilities
3. The resolved address is then passed to XMTP's add member API

**Without ENS resolution, users cannot add members using ENS names—only raw addresses work.**

### ENS Resolution Pattern

```typescript
import { normalize } from 'viem/ens';
import { usePublicClient } from 'wagmi';

// Inside component:
const publicClient = usePublicClient();

async function resolveAddress(input: string): Promise<string> {
  // Already an address
  if (input.startsWith('0x') && isAddress(input)) {
    return getAddress(input); // Normalize to checksum
  }

  // ENS name - resolved before XMTP receives it
  if (input.includes('.')) {
    const normalized = normalize(input);
    const resolved = await publicClient.getEnsAddress({ name: normalized });
    if (!resolved) {
      throw new Error(`Could not resolve ENS name: ${input}`);
    }
    return resolved;
  }

  throw new Error('Invalid Ethereum address or ENS name');
}
```

## UX Rules

**MUST:**
- Show member list with IdentityBadge for each
- Add/remove member controls (if user has permission)
- Resolve ENS names before adding members (SDK does not resolve ENS)
- Accept both 0x addresses and ENS names in the add member input
- Show loading state during ENS resolution
- Display resolved address after successful ENS lookup
- Loading state while fetching/updating members

**NEVER:**
- Allow removing self from group via this UI
- Show admin actions if user is not admin
- Pass unresolved ENS names to XMTP (will fail)

**ADD MEMBER UX:**
- Input accepts "0x... or name.eth"
- Spinner shown while resolving ENS
- After resolution, displays: "vitalik.eth → 0xd8dA...6045"
- Clear error shown if resolution fails
- Address validated before calling XMTP add member API

**ACCESSIBILITY:**
- Member list uses proper list semantics
- Remove buttons have descriptive `aria-label`

## Look Up

Before implementing, check:

1. **XMTP group member API**: Query docs for member management
2. **useConversation hook**: Check for group operations
3. **IdentityBadge**: For displaying member identities
4. **viem setup**: Is viem already configured for ENS?
5. **wagmi hooks**: usePublicClient for ENS resolution?
