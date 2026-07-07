import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';
import { defineConfig } from '@wagmi/cli';
import { react, hardhat } from '@wagmi/cli/plugins';

// deployment.json is written by `npx hardhat deploy` (see ../../hardhat.config.cts)
// and is gitignored, so it does not exist on a fresh checkout. Fall back to the
// local hardhat network with a zero address so `wagmi generate` and type checking
// still work before the first deployment.
// Resolved relative to the working directory (`wagmi generate` runs from this
// package via the npm script) rather than __dirname, which does not exist in
// ESM ("type": "module").
const deploymentPath = resolve(process.cwd(), '../../deployment.json');
const deployment: { name: string; address: string; networkConfig: { id: number } } =
  existsSync(deploymentPath)
    ? JSON.parse(readFileSync(deploymentPath, 'utf8'))
    : {
        name: 'localhost',
        address: '0x0000000000000000000000000000000000000000',
        networkConfig: { id: 31337 },
      };

export default defineConfig({
  out: 'artifacts/generated.ts',
  plugins: [
    react(),
    hardhat({
      project: '.',
      artifacts: '../artifacts',
      deployments: {
        UltraVerifier: {
          [deployment.networkConfig.id]: deployment.address as `0x${string}`,
        },
      },
    }),
  ],
});
