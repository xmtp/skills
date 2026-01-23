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

This configuration enables WASM support:

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
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
    exclude: ['@xmtp/browser-sdk'],
  },

  worker: {
    format: 'es',
  },
});
```

**Note:** No COOP/COEP headers are required. The XMTP browser SDK works without SharedArrayBuffer.

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

  // Configure WASM output path
  config.output.webassemblyModuleFilename =
    options.isServer && !options.dev
      ? "../static/wasm/[modulehash].wasm"
      : "static/wasm/[modulehash].wasm";

  // Fix worker public path
  if (!options.isServer) {
    config.output.workerPublicPath = "/_next/";
  }

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
    '@xmtp/browser-sdk',
  ],
},
```

## Troubleshooting

### Error: "Failed to execute 'fetch' on 'WorkerGlobalScope'"

This error occurs when WASM files can't be loaded in Web Workers due to blob: URL resolution issues.

**Solution:** Ensure `workerPublicPath` is set in webpack config:

```typescript
if (!isServer) {
  config.output.workerPublicPath = "/_next/";
}
```

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

### Module not found: @xmtp/browser-sdk

Ensure the package is installed and listed in `serverExternalPackages` to prevent Next.js from trying to bundle it for SSR.
