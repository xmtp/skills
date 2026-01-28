# Detection Logic

## Table of Contents
- [Framework Detection](#framework-detection)
- [Bundler Configuration Detection](#bundler-configuration-detection)
- [Wallet Provider Detection](#wallet-provider-detection)
- [Styling System Detection](#styling-system-detection)
- [Directory Structure Analysis](#directory-structure-analysis)
- [Detection Confirmation](#detection-confirmation)

## Framework Detection

Detect the React framework and router type:

```typescript
function detectFramework(): 'nextjs-app' | 'nextjs-pages' | 'vite' | 'unknown' {
  // 1. Check for Next.js
  if (exists('next.config.js') || exists('next.config.ts') || exists('next.config.mjs')) {
    // Determine router type
    if (exists('app/') && exists('app/layout.tsx')) {
      return 'nextjs-app';
    }
    if (exists('pages/') && (exists('pages/_app.tsx') || exists('pages/index.tsx'))) {
      return 'nextjs-pages';
    }
    // Default to app router for newer Next.js
    return 'nextjs-app';
  }

  // 2. Check for Vite
  if (exists('vite.config.js') || exists('vite.config.ts')) {
    return 'vite';
  }

  // 3. Check package.json dependencies
  const pkg = readPackageJson();
  if (pkg.dependencies?.next || pkg.devDependencies?.next) {
    return exists('app/') ? 'nextjs-app' : 'nextjs-pages';
  }
  if (pkg.dependencies?.vite || pkg.devDependencies?.vite) {
    return 'vite';
  }

  return 'unknown';
}
```

## Bundler Configuration Detection

Check existing bundler config to determine what needs to be added for XMTP:

```typescript
interface BundlerConfigStatus {
  hasConfig: boolean;
  configPath: string | null;
  hasWasmExperiments: boolean;
  hasCorsHeaders: boolean;
  hasWorkerPublicPath: boolean;
  needsWebpackFlag: boolean;  // Next.js 16+ with Turbopack default
}

function detectBundlerConfig(framework: string): BundlerConfigStatus {
  // Find config file
  const nextConfigs = ['next.config.ts', 'next.config.js', 'next.config.mjs'];
  const viteConfigs = ['vite.config.ts', 'vite.config.js'];

  let configPath: string | null = null;
  let content: string | null = null;

  if (framework.startsWith('nextjs')) {
    for (const path of nextConfigs) {
      if (exists(path)) {
        configPath = path;
        content = readFile(path);
        break;
      }
    }
  } else if (framework === 'vite') {
    for (const path of viteConfigs) {
      if (exists(path)) {
        configPath = path;
        content = readFile(path);
        break;
      }
    }
  }

  if (!configPath || !content) {
    return {
      hasConfig: false,
      configPath: null,
      hasWasmExperiments: false,
      hasCorsHeaders: false,
      hasWorkerPublicPath: false,
      needsWebpackFlag: false,
    };
  }

  // Check for required XMTP configuration
  const hasWasmExperiments = content.includes('asyncWebAssembly');
  const hasCorsHeaders = content.includes('Cross-Origin-Opener-Policy') ||
                         content.includes('Cross-Origin-Embedder-Policy');
  const hasWorkerPublicPath = content.includes('workerPublicPath');

  // Check if Next.js 16+ requires --webpack flag
  let needsWebpackFlag = false;
  if (framework.startsWith('nextjs')) {
    const pkg = readPackageJson();
    const nextVersion = pkg.dependencies?.next || pkg.devDependencies?.next || '';
    // Next.js 16+ uses Turbopack by default
    const majorVersion = parseInt(nextVersion.replace(/[\^~]/, '').split('.')[0]);
    if (majorVersion >= 16) {
      // Check if --webpack is already in scripts
      const hasWebpackFlag = pkg.scripts?.dev?.includes('--webpack') ||
                             pkg.scripts?.build?.includes('--webpack');
      needsWebpackFlag = !hasWebpackFlag;
    }
  }

  return {
    hasConfig: true,
    configPath,
    hasWasmExperiments,
    hasCorsHeaders,
    hasWorkerPublicPath,
    needsWebpackFlag,
  };
}
```

### Update Strategy

Based on detection, determine how to update the bundler config:

```typescript
function determineBundlerUpdates(status: BundlerConfigStatus, framework: string): string[] {
  const updates: string[] = [];

  if (!status.hasConfig) {
    updates.push(`Create ${framework === 'vite' ? 'vite.config.ts' : 'next.config.ts'} with XMTP configuration`);
  } else {
    if (!status.hasWasmExperiments) {
      updates.push('Add asyncWebAssembly experiment to webpack config');
    }
    if (!status.hasCorsHeaders) {
      updates.push('Add Cross-Origin headers for SharedArrayBuffer support');
    }
    if (!status.hasWorkerPublicPath && framework.startsWith('nextjs')) {
      updates.push('Add workerPublicPath for Web Worker WASM loading');
    }
  }

  if (status.needsWebpackFlag) {
    updates.push('Update package.json scripts to use --webpack flag (Next.js 16+ uses Turbopack by default)');
  }

  return updates;
}
```

See [bundler-config.md](bundler-config.md) for full configuration examples and merge patterns.

## Wallet Provider Detection

Check for existing wallet connection setup:

```typescript
function detectWalletProvider(): 'wagmi' | 'rainbowkit' | 'web3modal' | null {
  // Search imports in project files
  const patterns = {
    rainbowkit: ['@rainbow-me/rainbowkit', 'RainbowKitProvider'],
    web3modal: ['@web3modal', 'Web3Modal'],
    wagmi: ['wagmi', 'WagmiConfig', 'WagmiProvider'],
  };

  // Check package.json first
  const pkg = readPackageJson();
  const deps = { ...pkg.dependencies, ...pkg.devDependencies };

  if (deps['@rainbow-me/rainbowkit']) return 'rainbowkit';
  if (deps['@web3modal/wagmi'] || deps['@web3modal/react']) return 'web3modal';
  if (deps['wagmi']) return 'wagmi';

  // Search for provider setup in common locations
  const providerPaths = [
    'src/providers/',
    'providers/',
    'app/providers.tsx',
    'pages/_app.tsx',
    'src/app/providers.tsx',
  ];

  for (const path of providerPaths) {
    const content = readFile(path);
    if (content) {
      for (const [provider, keywords] of Object.entries(patterns)) {
        if (keywords.some(k => content.includes(k))) {
          return provider as any;
        }
      }
    }
  }

  return null;
}
```

## Styling System Detection

Identify the project's styling approach:

```typescript
function detectStyling(): 'tailwind' | 'css-modules' | 'styled-components' | 'emotion' | 'vanilla' {
  // 1. Tailwind
  if (exists('tailwind.config.js') || exists('tailwind.config.ts')) {
    return 'tailwind';
  }

  // 2. Check package.json
  const pkg = readPackageJson();
  const deps = { ...pkg.dependencies, ...pkg.devDependencies };

  if (deps['styled-components']) return 'styled-components';
  if (deps['@emotion/react'] || deps['@emotion/styled']) return 'emotion';

  // 3. Check for CSS modules
  const cssModules = glob('**/*.module.css', { maxDepth: 3 });
  if (cssModules.length > 0) return 'css-modules';

  // 4. Check for tailwind in postcss config
  if (exists('postcss.config.js')) {
    const content = readFile('postcss.config.js');
    if (content?.includes('tailwindcss')) return 'tailwind';
  }

  return 'vanilla';
}
```

## Directory Structure Analysis

Map the project's file organization:

```typescript
interface DirectoryStructure {
  srcDir: string;           // 'src' | ''
  hooksDir: string;         // 'src/hooks' | 'hooks'
  componentsDir: string;    // 'src/components' | 'components'
  providersDir: string;     // 'src/providers' | 'providers' | 'app'
  libDir: string;           // 'src/lib' | 'lib' | 'utils'
  typesDir: string;         // 'src/types' | 'types'
  storesDir: string;        // 'src/stores' | 'stores' | 'src/store'
}

function analyzeDirectoryStructure(): DirectoryStructure {
  const hasSrc = exists('src/');

  // Find existing directories
  const findDir = (candidates: string[]): string => {
    for (const dir of candidates) {
      if (exists(dir)) return dir;
    }
    // Return first candidate with src prefix if src exists
    return hasSrc ? candidates[0] : candidates[0].replace('src/', '');
  };

  return {
    srcDir: hasSrc ? 'src' : '',
    hooksDir: findDir(['src/hooks', 'hooks']),
    componentsDir: findDir(['src/components', 'components']),
    providersDir: findDir(['src/providers', 'providers', 'src/app', 'app']),
    libDir: findDir(['src/lib', 'lib', 'src/utils', 'utils']),
    typesDir: findDir(['src/types', 'types']),
    storesDir: findDir(['src/stores', 'stores', 'src/store', 'store']),
  };
}
```

## Detection Confirmation

After detection, confirm findings with user before proceeding:

```typescript
// Present detected configuration
const detected = {
  framework: detectFramework(),
  walletProvider: detectWalletProvider(),
  styling: detectStyling(),
  structure: analyzeDirectoryStructure(),
};

// Show user and allow override via AskUserQuestion
AskUserQuestion({
  question: `I detected: ${detected.framework}, ${detected.styling} styling${
    detected.walletProvider ? `, ${detected.walletProvider} wallet` : ', no wallet provider'
  }. Is this correct?`,
  header: "Project Setup",
  options: [
    { label: "Yes, continue", description: "Proceed with detected configuration" },
    { label: "No, let me specify", description: "Override detected settings" }
  ]
});
```
