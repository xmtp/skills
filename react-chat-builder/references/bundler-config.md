# Bundler Configuration

XMTP uses WebAssembly (WASM) and Web Workers internally. This requires specific bundler configuration depending on the framework.

## Table of Contents
- [Next.js Configuration](#nextjs-configuration)
- [Vite Configuration](#vite-configuration)
- [Merging with Existing Config](#merging-with-existing-config)

## Next.js Configuration

### Next.js 16+ (Turbopack Default)

Next.js 16+ uses Turbopack by default, but Turbopack has limited WASM support. Projects using `@xmtp/browser-sdk` must use webpack instead.

**Update `package.json` scripts:**

```json
{
  "scripts": {
    "dev": "next dev --webpack",
    "build": "next build --webpack",
    "start": "next start"
  }
}
```

### Required next.config.ts

This configuration enables WASM support and sets required CORS headers for SharedArrayBuffer:

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Required for SharedArrayBuffer (XMTP uses this for WASM workers)
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          {
            key: "Cross-Origin-Opener-Policy",
            value: "same-origin",
          },
          {
            key: "Cross-Origin-Embedder-Policy",
            value: "require-corp",
          },
        ],
      },
    ];
  },

  webpack(config, { isServer, dev }) {
    // Enable WebAssembly
    config.experiments = {
      ...config.experiments,
      asyncWebAssembly: true,
      layers: true,
    };

    // Configure WASM output path
    config.output.webassemblyModuleFilename =
      isServer && !dev
        ? "../static/wasm/[modulehash].wasm"
        : "static/wasm/[modulehash].wasm";

    // Fix worker public path for blob: URL contexts
    if (!isServer) {
      config.output.workerPublicPath = "/_next/";
    }

    return config;
  },

  // Externalize all XMTP packages from server bundle
  serverExternalPackages: [
    "@xmtp/browser-sdk",
    "@xmtp/wasm-bindings",
    "@xmtp/content-type-text",
    "@xmtp/content-type-reaction",
    "@xmtp/content-type-reply",
    "@xmtp/content-type-remote-attachment",
  ],
};

export default nextConfig;
```

### Next.js 13-15 (Webpack Default)

For older Next.js versions that use webpack by default, the same `next.config.ts` applies but you don't need the `--webpack` flags in package.json scripts.

## Vite Configuration

Vite handles WASM differently. Update `vite.config.ts`:

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],

  optimizeDeps: {
    // Exclude XMTP packages from pre-bundling
    exclude: ['@xmtp/wasm-bindings', '@xmtp/browser-sdk'],
    // Include proto for optimization
    include: ['@xmtp/proto'],
  },

  worker: {
    format: 'es',
  },

  server: {
    headers: {
      // Required for SharedArrayBuffer
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
    },
  },
});
```

## Merging with Existing Config

When the project already has a bundler configuration, merge the XMTP-specific settings rather than replacing the entire file.

### Detecting Existing Configuration

```typescript
// Check if next.config already exists
const hasNextConfig = exists('next.config.js') ||
                      exists('next.config.ts') ||
                      exists('next.config.mjs');

const hasViteConfig = exists('vite.config.js') ||
                      exists('vite.config.ts');
```

### Merging Next.js Config

If `next.config.ts` exists, add to it rather than replacing:

**Pattern for merging headers:**

```typescript
// Existing config may have headers - merge them
async headers() {
  const existingHeaders = await existingConfig.headers?.() ?? [];

  return [
    ...existingHeaders,
    {
      source: "/(.*)",
      headers: [
        { key: "Cross-Origin-Opener-Policy", value: "same-origin" },
        { key: "Cross-Origin-Embedder-Policy", value: "require-corp" },
      ],
    },
  ];
}
```

**Pattern for merging webpack config:**

```typescript
webpack(config, options) {
  // Call existing webpack config first if it exists
  if (typeof existingConfig.webpack === 'function') {
    config = existingConfig.webpack(config, options);
  }

  // Then add XMTP-specific configuration
  config.experiments = {
    ...config.experiments,
    asyncWebAssembly: true,
    layers: true,
  };

  // ... rest of XMTP config

  return config;
}
```

**Pattern for merging serverExternalPackages:**

```typescript
serverExternalPackages: [
  ...(existingConfig.serverExternalPackages ?? []),
  "@xmtp/browser-sdk",
  "@xmtp/wasm-bindings",
  "@xmtp/content-type-text",
  "@xmtp/content-type-reaction",
  "@xmtp/content-type-reply",
  "@xmtp/content-type-remote-attachment",
],
```

### Merging Vite Config

For Vite, merge into existing arrays:

```typescript
optimizeDeps: {
  exclude: [
    ...(existingConfig.optimizeDeps?.exclude ?? []),
    '@xmtp/wasm-bindings',
    '@xmtp/browser-sdk',
  ],
  include: [
    ...(existingConfig.optimizeDeps?.include ?? []),
    '@xmtp/proto',
  ],
},
```

## Troubleshooting

### Coinbase Wallet / Third-Party Resources Blocked

If using RainbowKit with Coinbase Wallet (or other third-party services like OAuth providers, analytics), you may see resources blocked due to missing CORP headers.

**Solution:** Change `Cross-Origin-Embedder-Policy` from `require-corp` to `credentialless`:

```typescript
// Next.js
{
  key: "Cross-Origin-Embedder-Policy",
  value: "credentialless",  // Instead of "require-corp"
}

// Vite
"Cross-Origin-Embedder-Policy": "credentialless",
```

**Trade-offs:**
- `require-corp` (XMTP default): Stricter, requires all cross-origin resources to have CORP headers
- `credentialless`: More permissive, allows cross-origin resources but sends them without credentials

**Browser support:** `credentialless` is supported in Chrome 96+, Firefox 119+, but **not Safari**. If Safari support is required and you need Coinbase Wallet, you may need to handle this at the infrastructure level.

### Error: "Failed to execute 'fetch' on 'WorkerGlobalScope'"

This error occurs when WASM files can't be loaded in Web Workers due to blob: URL resolution issues.

**Solution:** Ensure `workerPublicPath` is set in webpack config:

```typescript
if (!isServer) {
  config.output.workerPublicPath = "/_next/";
}
```

### Error: "SharedArrayBuffer is not defined"

This occurs when CORS headers are missing.

**Solution:** Add the Cross-Origin headers to your configuration:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

### Next.js 16 Warning: "webpack config with no turbopack config"

This warning appears when using webpack configuration with Next.js 16+ which defaults to Turbopack.

**Solution:** Add `--webpack` flags to your npm scripts to explicitly use webpack, or add an empty `turbopack: {}` to silence the warning (but XMTP still requires webpack for full WASM support).

### Build Works but Dev Fails (or Vice Versa)

Ensure both `dev` and `build` scripts use the same bundler:

```json
{
  "scripts": {
    "dev": "next dev --webpack",
    "build": "next build --webpack"
  }
}
```
