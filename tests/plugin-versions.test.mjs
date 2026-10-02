import assert from 'node:assert/strict';
import { appendFile, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import test from 'node:test';
import { fixture } from './plugin-fixture.mjs';
import { buildPlugin } from '../scripts/plugin.mjs';
import { checkVersions, git } from '../scripts/check-plugin-versions.mjs';
import { precommit } from '../scripts/plugin-precommit.mjs';

async function initialCommit(root) {
  git(root, ['init', '-b', 'main']);
  git(root, ['config', 'user.name', 'Plugin tests']);
  git(root, ['config', 'user.email', 'plugin-tests@example.invalid']);
  await buildPlugin(root);
  git(root, ['add', '.']);
  git(root, ['-c', 'core.hooksPath=', '-c', 'commit.gpgSign=false', 'commit', '-m', 'Initial fixture']);
  return git(root, ['rev-parse', 'HEAD']);
}

test('release gate requires an increasing version and changelog for shipped source changes', async t => {
  const root = await fixture(t);
  const base = await initialCommit(root);
  assert.match(await checkVersions(root, base), /No shipped/);
  await appendFile(path.join(root, 'catalog/core/secure-development.md'), '\nAdditional security guidance.\n');
  await buildPlugin(root);
  await assert.rejects(checkVersions(root, base), /bump plugin.json/);
  const manifest = JSON.parse(await readFile(path.join(root, 'plugin.json')));
  manifest.version = '1.2.0';
  await writeFile(path.join(root, 'plugin.json'), JSON.stringify(manifest));
  await buildPlugin(root);
  await assert.rejects(checkVersions(root, base), /CHANGELOG/);
  await appendFile(path.join(root, 'CHANGELOG.md'), '\n## [1.2.0] - 2026-10-02\n\nUpdated guidance.\n');
  await buildPlugin(root);
  assert.match(await checkVersions(root, base), /1.1.0 -> 1.2.0/);
  await assert.rejects(checkVersions(root, 'missing-ref'), /Not a valid|not a valid|fatal/);
});

test('documentation-only changes do not force releases, but generated drift still fails', async t => {
  const root = await fixture(t);
  const base = await initialCommit(root);
  await writeFile(path.join(root, 'DEVELOPMENT.md'), 'Developer-only notes\n');
  assert.match(await checkVersions(root, base), /No shipped/);
  await writeFile(path.join(root, 'plugins/ai-security-hub/plugin.json'), '{}');
  await assert.rejects(checkVersions(root, base), /drifted/);
});

test('pre-commit stages generated output and refuses partially staged shipped sources', async t => {
  const root = await fixture(t);
  await initialCommit(root);
  const relative = 'plugin/hooks/reminder.json';
  const reminder = JSON.parse(await readFile(path.join(root, relative)));
  reminder.message += ' Test fixture reminder.';
  await writeFile(path.join(root, relative), JSON.stringify(reminder));
  await assert.rejects(precommit(root), /Stage shipped source/);
  git(root, ['add', relative]);
  await writeFile(path.join(root, 'personal-notes.txt'), 'Do not stage me\n');
  await precommit(root);
  const staged = git(root, ['diff', '--cached', '--name-only']);
  assert.match(staged, /claude-plugins\/ai-security-hub\/hooks\/session-start.sh/);
  assert.match(staged, /plugins\/ai-security-hub\/hooks\/session-start.ps1/);
  assert.doesNotMatch(staged, /personal-notes/);
  await appendFile(path.join(root, relative), '\n');
  await assert.rejects(precommit(root), /Stage shipped source/);
});
