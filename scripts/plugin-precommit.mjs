import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { buildPlugin } from './plugin.mjs';
import { git, releaseSource } from './check-plugin-versions.mjs';

export async function precommit(root = fileURLToPath(new URL('../', import.meta.url))) {
  const unstaged = git(root, ['diff', '--name-only']).split('\n').filter(releaseSource);
  if (unstaged.length) throw new Error(`Stage shipped source changes before rebuilding for commit:\n${unstaged.join('\n')}`);
  await buildPlugin(root);
  git(root, ['add', '-A', '--', 'agents', 'skills', 'com.github.copilot', 'plugins', 'claude-plugins',
    '.github/plugin/marketplace.json', '.claude-plugin/marketplace.json']);
  console.log('Rebuilt and staged generated plugin packages and marketplaces.');
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try { await precommit(); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
