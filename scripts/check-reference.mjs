// Run the supplied company validators without modifying that checkout.
import { cp, mkdtemp, mkdir, rm, symlink, writeFile } from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { buildPlugin } from './plugin.mjs';
import { marketplaceExport } from './marketplace.mjs';

const root = fileURLToPath(new URL('../', import.meta.url));
const source = process.argv[2];
let temporary;
try {
  if (!source || process.argv.length !== 3) throw new Error('Usage: node scripts/check-reference.mjs /path/to/copilot-agents');
  temporary = await mkdtemp(path.join(os.tmpdir(), 'hub-reference-'));
  await mkdir(path.join(temporary, 'eng'));
  for (const file of ['constants.mjs', 'yaml-parser.mjs', 'claude-translate.mjs',
    'validate-plugins.mjs', 'validate-skills.mjs', 'validate-claude-plugins.mjs']) {
    await cp(path.join(source, 'eng', file), path.join(temporary, 'eng', file));
  }
  await symlink(path.join(root, 'node_modules'), path.join(temporary, 'node_modules'), process.platform === 'win32' ? 'junction' : 'dir');
  const exported = path.join(temporary, 'export');
  const { output } = await buildPlugin(root, true);
  for (const [file, text] of marketplaceExport(output)) {
    const destination = path.join(exported, file);
    await mkdir(path.dirname(destination), { recursive: true });
    await writeFile(destination, text);
  }
  for (const file of ['validate-plugins.mjs', 'validate-skills.mjs', 'validate-claude-plugins.mjs']) {
    const result = spawnSync(process.execPath, [path.join(temporary, 'eng', file), '--root', exported], { encoding: 'utf8' });
    if (result.error) throw result.error;
    process.stdout.write(result.stdout);
    process.stderr.write(result.stderr);
    if (result.status !== 0) throw new Error(`${file} rejected the packages`);
  }
} catch (error) { console.error(error.message); process.exitCode = 1; }
finally { if (temporary) await rm(temporary, { recursive: true, force: true }); }
