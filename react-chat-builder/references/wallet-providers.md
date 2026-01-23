# Wallet Provider Generation

Generate wallet provider setup based on user's interview answer.

## Table of Contents
- [Provider Requirements](#provider-requirements)
- [RainbowKit Setup](#rainbowkit-setup)
- [ConnectKit Setup](#connectkit-setup)
- [Web3Modal Setup](#web3modal-setup)
- [BYOW (Bring Your Own Wallet)](#byow-bring-your-own-wallet)

## Provider Requirements

All generated wallet providers MUST:

1. **Gracefully handle missing projectId** - Show warning, don't crash
2. **Maintain QueryClient for React Query** - Required for XMTP hooks
3. **Handle SSR hydration mismatch (Next.js only)** - Wallet state differs between server and client

### Minimal Fallback Pattern

```typescript
// When wallet configuration is missing
function MinimalProviders({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

// Check for missing configuration
if (!projectId) {
  console.warn('[Providers] WalletConnect projectId not configured');
  return <MinimalProviders>{children}</MinimalProviders>;
}
```

### SSR Hydration Pattern (Next.js)

Wallet hooks return different values on server vs client, causing hydration mismatches. Use a mounted guard in components that consume wallet state:

```typescript
'use client';

import { useState, useEffect } from 'react';
import { useAccount } from 'wagmi';

export function WalletStatus() {
  const [mounted, setMounted] = useState(false);
  const { address, isConnected } = useAccount();

  useEffect(() => {
    setMounted(true);
  }, []);

  // Render nothing or skeleton until client-side hydration completes
  if (!mounted) {
    return <div className="h-10 w-32 animate-pulse bg-gray-200 rounded" />;
  }

  return isConnected ? <span>{address}</span> : <ConnectButton />;
}
```

**When to use:** Any component that reads wallet state (`useAccount`, `useBalance`, `useEnsName`, etc.) and renders on the server.

**Alternative:** Wrap wallet-dependent UI in `dynamic(() => import(...), { ssr: false })` to skip SSR entirely.

## RainbowKit Setup

When user selects "RainbowKit" in the interview:

```typescript
// app/providers.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider } from 'wagmi';
import { RainbowKitProvider, getDefaultConfig } from '@rainbow-me/rainbowkit';
import { mainnet, sepolia } from 'wagmi/chains';
import { type ReactNode, useState } from 'react';
import '@rainbow-me/rainbowkit/styles.css';

function MinimalProviders({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

export function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());

  const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID;

  if (!projectId) {
    if (typeof window !== 'undefined') {
      console.warn(
        '[Providers] NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID not configured. ' +
        'Wallet connection disabled. Get a free projectId at https://cloud.walletconnect.com/'
      );
    }
    return <MinimalProviders>{children}</MinimalProviders>;
  }

  const config = getDefaultConfig({
    appName: 'XMTP Chat',
    projectId,
    chains: [mainnet, sepolia],
    ssr: true,
  });

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
```

### Dependencies for RainbowKit

```json
{
  "@rainbow-me/rainbowkit": "^2.x",
  "wagmi": "^2.x",
  "@tanstack/react-query": "^5.x",
  "viem": "^2.x"
}
```

## ConnectKit Setup

When user selects "ConnectKit" in the interview:

```typescript
// app/providers.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider, createConfig, http } from 'wagmi';
import { ConnectKitProvider, getDefaultConfig } from 'connectkit';
import { mainnet, sepolia } from 'wagmi/chains';
import { type ReactNode, useState } from 'react';

function MinimalProviders({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

export function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());

  const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID;

  if (!projectId) {
    if (typeof window !== 'undefined') {
      console.warn(
        '[Providers] NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID not configured. ' +
        'Wallet connection disabled. Get a free projectId at https://cloud.walletconnect.com/'
      );
    }
    return <MinimalProviders>{children}</MinimalProviders>;
  }

  const config = createConfig(
    getDefaultConfig({
      appName: 'XMTP Chat',
      walletConnectProjectId: projectId,
      chains: [mainnet, sepolia],
      transports: {
        [mainnet.id]: http(),
        [sepolia.id]: http(),
      },
    })
  );

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <ConnectKitProvider>
          {children}
        </ConnectKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
```

### Dependencies for ConnectKit

```json
{
  "connectkit": "^1.x",
  "wagmi": "^2.x",
  "@tanstack/react-query": "^5.x",
  "viem": "^2.x"
}
```

## Web3Modal Setup

When user selects "Web3Modal" in the interview:

```typescript
// app/providers.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { createWeb3Modal } from '@web3modal/wagmi/react';
import { defaultWagmiConfig } from '@web3modal/wagmi/react/config';
import { WagmiProvider } from 'wagmi';
import { mainnet, sepolia } from 'wagmi/chains';
import { type ReactNode, useState, useEffect } from 'react';

const chains = [mainnet, sepolia] as const;

function MinimalProviders({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

// Lazy initialize Web3Modal only when needed
let web3ModalInitialized = false;

function initializeWeb3Modal(projectId: string) {
  if (web3ModalInitialized) return;

  const metadata = {
    name: 'XMTP Chat',
    description: 'Encrypted messaging with XMTP',
    url: typeof window !== 'undefined' ? window.location.origin : '',
    icons: [],
  };

  const config = defaultWagmiConfig({
    chains,
    projectId,
    metadata,
  });

  createWeb3Modal({
    wagmiConfig: config,
    projectId,
    enableAnalytics: false,
  });

  web3ModalInitialized = true;
  return config;
}

export function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  const [wagmiConfig, setWagmiConfig] = useState<any>(null);

  const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID;

  useEffect(() => {
    if (!projectId) {
      console.warn(
        '[Providers] NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID not configured. ' +
        'Wallet connection disabled. Get a free projectId at https://cloud.walletconnect.com/'
      );
      return;
    }

    const config = initializeWeb3Modal(projectId);
    setWagmiConfig(config);
  }, [projectId]);

  if (!projectId || !wagmiConfig) {
    return <MinimalProviders>{children}</MinimalProviders>;
  }

  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </WagmiProvider>
  );
}
```

### Dependencies for Web3Modal

```json
{
  "@web3modal/wagmi": "^5.x",
  "wagmi": "^2.x",
  "@tanstack/react-query": "^5.x",
  "viem": "^2.x"
}
```

## BYOW (Bring Your Own Wallet)

When user selects "I'll add my own" in the interview, generate minimal providers:

```typescript
// app/providers.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { type ReactNode, useState } from 'react';

export function Providers({ children }: { children: ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());

  // QueryClient is needed for XMTP hooks
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}

// User is expected to:
// 1. Add their own wallet provider wrapping Providers
// 2. Use useXMTP hook which accepts a custom signer
```

### Dependencies for BYOW

```json
{
  "@tanstack/react-query": "^5.x",
  "viem": "^2.x"
}
```

## Environment Configuration

All wallet providers require this in `.env.example`:

```bash
# WalletConnect Project ID
# Get a free projectId at https://cloud.walletconnect.com/
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=

# XMTP Environment
NEXT_PUBLIC_XMTP_ENV=dev
```

## Error Handling Summary

| Scenario | Behavior |
|----------|----------|
| Missing `WALLETCONNECT_PROJECT_ID` | Show console warning, disable wallet connection |
| Invalid `WALLETCONNECT_PROJECT_ID` | WalletConnect will show error, app continues |
| Production with valid ID | Full wallet functionality |
