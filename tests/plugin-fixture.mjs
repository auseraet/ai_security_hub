import { cp, mkdir, mkdtemp, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
export async function fixture(t) {
  const root = await mkdtemp(path.join(os.tmpdir(), 'hub marketplace '));
  t.after(() => rm(root, { recursive: true, force: true }));
  for (const entry of ['catalog', 'review-pack', 'plugin', 'plugin.json', 'CHANGELOG.md', 'docs/PLUGIN.md']) {
    await mkdir(path.dirname(path.join(root, entry)), { recursive: true });
    await cp(path.join(ROOT, entry), path.join(root, entry), { recursive: true });
  }
  return root;
}
