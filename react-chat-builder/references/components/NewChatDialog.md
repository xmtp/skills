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

## UX Rules

**MUST:**
- Support both DM and Group modes (if enableGroups)
- Accept Ethereum addresses (0x...) and ENS names (name.eth)
- Resolve ENS names before passing to XMTP (SDK doesn't resolve ENS)
- Validate addresses using viem's `isAddress`
- Normalize to checksum addresses with `getAddress`
- Prevent duplicate members in group
- Reset form state on close

**NEVER:**
- Submit invalid addresses
- Allow creating group with 0 members
- Leave form state dirty after close

**DM MODE:**
- Single input: "0x... or name.eth"
- Validate on submit
- Resolve ENS → address before creating

**GROUP MODE:**
- Group name input (optional)
- Member input with Add button
- Members list with remove buttons
- At least 1 member required

**ENS RESOLUTION:**
- Check if input contains `.` and doesn't start with `0x`
- Use viem's ENS utilities to resolve
- Show error if resolution fails

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
