import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { validatePlugins } from './validate-plugins.mjs';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
export const releaseSource = file => /^(catalog\/|review-pack\/|plugin\/|scripts\/(plugin|marketplace|validate-plugins)|docs\/PLUGIN\.md$|plugin\.json$|package(?:-lock)?\.json$|CHANGELOG\.md$)/.test(file);
export function git(root, args, optional = false) {
  const result = spawnSync('git', args, { cwd: root, encoding: 'utf8' });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    if (optional) return null;
    throw new Error(result.stderr.trim() || `git ${args[0]} failed`);
  }
  return result.stdout.trim();
}
export async function checkVersions(root = ROOT, base = process.env.CI_MERGE_REQUEST_DIFF_BASE_SHA || process.env.PLUGIN_BASE_SHA || 'origin/main') {
  await validatePlugins(root);
  const mergeBase = git(root, ['merge-base', 'HEAD', base]);
  const current = JSON.parse(await readFile(path.join(root, 'plugin.json'), 'utf8'));
  const oldText = git(root, ['show', `${mergeBase}:plugin.json`], true);
  const changelog = await readFile(path.join(root, 'CHANGELOG.md'), 'utf8');
  if (!changelog.includes(`## [${current.version}]`)) throw new Error(`CHANGELOG.md needs a ${current.version} release entry`);
  if (!oldText) return 'New plugin release; manifests, marketplaces, and changelog agree.';
  const previous = JSON.parse(oldText);
  const changed = git(root, ['diff', '--name-only', mergeBase, '--']).split('\n');
  const untracked = git(root, ['ls-files', '--others', '--exclude-standard']).split('\n');
  if (![...changed, ...untracked].some(releaseSource)) return 'No shipped source changes.';
  const before = previous.version.split('.').map(Number);
  const after = current.version.split('.').map(Number);
  const difference = after.map((value, index) => value - before[index]).find(value => value !== 0);
  if (!(difference > 0)) throw new Error(`Shipped source changed: bump plugin.json above ${previous.version}, update CHANGELOG.md, and run npm run build.`);
  return `Plugin version increased: ${previous.version} -> ${current.version}.`;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const args = process.argv.slice(2);
    if (args.length && (args.length !== 2 || args[0] !== '--base')) throw new Error('Usage: npm run plugin:check-versions -- [--base REF]');
    console.log(await checkVersions(ROOT, args[1]));
  } catch (error) { console.error(error.message); process.exitCode = 1; }
}
