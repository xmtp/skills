# Verification Phase

After code generation, verify the integration works using browser automation.

## Prerequisites

### agent-browser CLI

```bash
# Check installation
command -v agent-browser >/dev/null 2>&1 && echo "Installed" || echo "NOT INSTALLED"

# Install if needed
npm install -g agent-browser
agent-browser install  # Downloads Chromium
```

### Development Server

The app must be running locally before verification. Typical commands:
- Next.js: `npm run dev`
- Vite: `npm run dev`

## Verification Workflow

### Step 1: Pre-flight Checks

Run these checks before browser testing:

```bash
# Check TypeScript compiles
npx tsc --noEmit

# Check for WASM/worker errors in dev server logs
# (manual check - look for errors mentioning WASM, Worker, or XMTP)
```

### Step 2: Browser Verification

**Ask user for browser mode:**

```
AskUserQuestion:
- Question: "Ready to verify the integration. Want to watch the browser tests?"
- Header: "Verify"
- Options:
  1. "Headed (watch)" - Opens visible browser window
  2. "Headless (faster)" - Runs in background
  3. "Skip verification" - Skip browser testing
```

If "Skip verification", end the verification phase.

### Step 3: Start Browser Session

```bash
# Headed mode
agent-browser --headed open http://localhost:3000

# Headless mode
agent-browser open http://localhost:3000
```

### Step 4: Verify App Renders

```bash
# Get page snapshot
agent-browser snapshot -i

# Take screenshot
agent-browser screenshot xmtp-verify-home.png
```

**Check for:**
- No error messages in snapshot
- Page title matches expected
- Basic layout renders

### Step 5: Verify XMTP Components

Navigate to the chat page/section:

```bash
# If full-app layout, chat is likely the main page
agent-browser snapshot -i

# If embedded/widget, may need to navigate or trigger
agent-browser click @e[ref]  # Click chat button/tab if needed
agent-browser snapshot -i
```

**Check for these elements in snapshot:**
- Conversation list or empty state
- Message input area
- Connect wallet button (if not connected)
- Loading skeleton (brief) then content

### Step 6: Verify Wallet Connection

```bash
# Find connect wallet button
agent-browser snapshot -i
# Look for button with text like "Connect Wallet", "Connect", etc.

# Click connect button
agent-browser click @e[ref]
agent-browser wait 1000
agent-browser snapshot -i
```

**Expected behavior:**
- Wallet modal appears (RainbowKit, ConnectKit, etc.)
- Or wallet extension prompt

**Note:** Full wallet connection requires user interaction with wallet extension. Verify the modal/prompt appears correctly.

```bash
# Screenshot the wallet modal
agent-browser screenshot xmtp-verify-wallet-modal.png
```

### Step 7: Verify Console Errors

After each page load, check for JavaScript errors:

```bash
# Get page URL to confirm navigation
agent-browser get url

# Check page title
agent-browser get title
```

Manual check in browser devtools for:
- WASM loading errors
- Worker initialization errors
- XMTP SDK errors
- React hydration errors

### Step 8: Component-Specific Verification

**If Pre-built Components:**

```bash
# Verify conversation list renders
agent-browser snapshot -i
# Look for: list items, empty state message, or loading skeleton

# Verify message thread area
# Look for: message input, send button, message display area

# Take full page screenshot
agent-browser screenshot --full xmtp-verify-full.png
```

**If Hooks-only:**

Verify hooks are exported and TypeScript compiles:
```bash
npx tsc --noEmit
```

### Step 9: Feature-Specific Verification

**Attachments (if enabled):**
```bash
# Look for file picker button/icon in snapshot
agent-browser snapshot -i
# Verify FilePicker component or file input is present
```

**Reactions (if enabled):**
```bash
# Look for reaction picker or emoji button
agent-browser snapshot -i
```

**Groups (if enabled):**
```bash
# Look for "New Group" button or group management UI
agent-browser snapshot -i
```

### Step 10: Cleanup

```bash
agent-browser close
```

## Verification Report

After verification, present results:

```markdown
## XMTP Integration Verification

### Environment
- URL: http://localhost:3000
- Browser Mode: [headed/headless]
- Timestamp: [time]

### Results

| Check | Status | Notes |
|-------|--------|-------|
| TypeScript compiles | [Pass/Fail] | [any errors] |
| Dev server starts | [Pass/Fail] | [any WASM/worker errors] |
| App renders | [Pass/Fail] | |
| XMTP components visible | [Pass/Fail] | |
| Wallet button present | [Pass/Fail] | |
| Wallet modal opens | [Pass/Fail] | |
| No console errors | [Pass/Fail] | [list any errors] |
| Loading states work | [Pass/Fail] | |
| Empty states render | [Pass/Fail] | |

### Screenshots
- `xmtp-verify-home.png` - Initial page load
- `xmtp-verify-wallet-modal.png` - Wallet connection modal
- `xmtp-verify-full.png` - Full page screenshot

### Overall: [PASS / FAIL / PARTIAL]

[If FAIL or PARTIAL, list issues and suggested fixes]
```

## Handling Failures

### WASM/Worker Errors

If dev server shows WASM or worker errors:

1. Check bundler config was applied correctly
2. For Next.js 16+, verify `--webpack` flags in package.json scripts
3. Verify CORS headers in next.config.ts

### TypeScript Errors

If TypeScript fails to compile:

1. Check for missing type imports
2. Verify SDK package versions match docs
3. Check tsconfig.json includes generated files

### Component Not Rendering

If XMTP components don't appear:

1. Verify XMTPProvider wraps the app
2. Check for SSR issues (Next.js needs dynamic import with ssr: false)
3. Look for error boundaries catching errors

### Wallet Modal Doesn't Open

If wallet connection doesn't work:

1. Verify wallet provider is set up correctly
2. Check for WalletConnect project ID in .env
3. Verify wagmi/wallet provider packages installed

## Optional: Message Send Test

For full end-to-end verification, user can test message sending:

```
AskUserQuestion:
- Question: "Want to test sending a message? (Requires a test wallet with XMTP enabled)"
- Header: "Message Test"
- Options:
  1. "Yes, test messaging" - I'll guide you through connecting and sending
  2. "No, skip" - End verification here
```

If yes:
1. Guide user to connect wallet
2. Guide user to start a conversation
3. Verify message appears in UI
4. Take screenshot of sent message
