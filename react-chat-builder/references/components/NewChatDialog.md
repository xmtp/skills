# NewChatDialog Component

Dialog for creating new DM or group conversations.

## Interface

```typescript
interface NewChatDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onCreated: (conversationId: string) => void;
  enableGroups?: boolean;
}
```

## CRITICAL: ENS Resolution

**The XMTP SDK does not resolve ENS names.** This component handles ENS resolution before passing addresses to XMTP.

When a user types `vitalik.eth` in the address input:
1. The component detects it's an ENS name (contains `.`, doesn't start with `0x`)
2. It resolves to an Ethereum address using viem's ENS utilities
3. The resolved address is then passed to XMTP

**Without ENS resolution, users cannot start conversations using ENS names—only raw addresses work.**

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
- Support both DM and Group modes (if enableGroups)
- Accept Ethereum addresses (0x...) and ENS names (name.eth)
- Resolve ENS names before passing to XMTP (SDK does not resolve ENS)
- Validate addresses using viem's `isAddress`
- Normalize to checksum addresses with `getAddress`
- Prevent duplicate members in group
- Reset form state on close
- Show loading state during ENS resolution
- Display the resolved address after successful ENS lookup

**NEVER:**
- Submit invalid addresses
- Pass unresolved ENS names to XMTP (will fail)
- Allow creating group with 0 members
- Leave form state dirty after close

**DM MODE:**
- Single input: "0x... or name.eth"
- Validation on submit
- ENS → address resolution before creating conversation

**GROUP MODE:**
- Group name input (optional)
- Member input with Add button
- ENS → address resolution when adding each member
- Members list with remove buttons (shows ENS name + resolved address)
- At least 1 member required

**ENS RESOLUTION UX:**
- Spinner/loading indicator during resolution
- After resolution, displays: "vitalik.eth → 0xd8dA...6045"
- Resolved names cached to avoid repeated lookups
- Clear error shown if resolution fails

**VALIDATION ERRORS:**
| Condition | Error Message |
|-----------|---------------|
| Empty input | Address or ENS name is required |
| Invalid format | Invalid Ethereum address or ENS name |
| ENS not found | Could not resolve ENS name: {name} |
| Duplicate member | Member already added |
| No members | Add at least one member |

**ACCESSIBILITY:**
- Focus trap within dialog
- `aria-modal="true"` on dialog
- Escape closes dialog
- Focus returns to trigger on close
- Errors have `role="alert"`
- Labels associated with inputs

## Look Up

Before implementing, check user's codebase for:

1. **Dialog component**: Existing modal/dialog pattern?
2. **Form components**: Input, Label, Error components?
3. **Address display**: Truncation or ENS lookup component?
4. **viem setup**: Is viem already configured for ENS?
5. **wagmi hooks**: usePublicClient for ENS resolution?
6. **Tab component**: Existing tab/segmented control?
