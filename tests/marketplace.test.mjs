import assert from 'node:assert/strict';
import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import test from 'node:test';
import { buildPlugin, packagePlugin } from '../scripts/plugin.mjs';
import { frontmatter, COPILOT, CLAUDE } from '../scripts/marketplace.mjs';
import { validatePlugins } from '../scripts/validate-plugins.mjs';
import { fixture } from './plugin-fixture.mjs';

test('every client gets the same security content and portable review tool restrictions', async t => {
  const root = await fixture(t);
  const { output } = await buildPlugin(root);
  await validatePlugins(root);
  const catalog = JSON.parse(await readFile(path.join(root, 'catalog/catalog.json')));
  for (const module of catalog.modules) {
    const rule = output.get(`com.github.copilot/rules/${module.id}.instructions.md`);
    for (const prefix of [COPILOT, CLAUDE]) {
      assert.equal(output.get(`${prefix}/skills/secure-development/references/${module.id}.instructions.md`), rule);
    }
    assert.equal(output.get(`${COPILOT}/rules/${module.id}.instructions.md`), rule);
  }
  const copilot = frontmatter(output.get(`${COPILOT}/agents/secure-code-review.md`)).attributes;
  const claude = frontmatter(output.get(`${CLAUDE}/agents/secure-code-review.md`)).attributes;
  assert.deepEqual(copilot.tools, ['read', 'search']);
  assert.equal(copilot.target, undefined);
  assert.equal(claude.tools, 'Read, Grep, Glob');
  for (const [file, content] of output) {
    if (!file.startsWith(`${COPILOT}/commands/`) && !file.startsWith(`${CLAUDE}/commands/`)) continue;
    assert.doesNotMatch(content, /\$\{input:/);
    assert.match(content, /\$ARGUMENTS/);
    if (file.startsWith(CLAUDE)) {
      const { attributes } = frontmatter(content);
      assert.equal(attributes.context, 'fork');
      assert.equal(attributes.agent, 'ai-security-hub:secure-code-review');
      assert.equal(attributes['allowed-tools'], 'Read, Grep, Glob');
    }
  }
});

test('all session scripts work outside the plugin root and emit the client context schemas', async t => {
  const root = await fixture(t);
  const { output } = await buildPlugin(root);
  const workspace = path.join(root, 'unrelated project');
  await mkdir(workspace);
  for (const [prefix, native] of [['com.github.copilot', true], [COPILOT, false], [CLAUDE, false]]) {
    const config = JSON.parse(output.get(`${prefix}/hooks/hooks.json`));
    assert.deepEqual(Object.keys(config.hooks), ['SessionStart']);
    const [outer] = config.hooks.SessionStart;
    const entry = outer.hooks?.[0] ?? outer;
    const windows = process.platform === 'win32';
    // Claude Code runs its shell hooks via bash, including on Windows with Git Bash.
    const usePowerShell = windows && prefix !== CLAUDE;
    const pluginRoot = (native ? root : path.join(root, prefix)).replaceAll('\\', '/');
    const command = (usePowerShell ? entry.windows : entry.command)
      .replaceAll('${PLUGIN_ROOT}', pluginRoot).replaceAll('${CLAUDE_PLUGIN_ROOT}', pluginRoot);
    const result = spawnSync(usePowerShell ? 'powershell.exe' : 'sh', usePowerShell
      ? ['-NoProfile', '-NonInteractive', '-Command', command]
      : ['-c', command], { cwd: workspace, encoding: 'utf8', timeout: 10000,
      input: '{"initialPrompt":"$(touch unwanted)"}' });
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stderr);
    const payload = JSON.parse(result.stdout);
    assert.equal(payload.hookSpecificOutput.hookEventName, 'SessionStart');
    assert.match(payload.hookSpecificOutput.additionalContext, /secure-development skill/);
    if (prefix === COPILOT) assert.equal(payload.additionalContext, payload.hookSpecificOutput.additionalContext);
  }
  assert.deepEqual(await readdir(workspace), []);
});

test('Copilot and Claude archives contain only installable files with local links', async t => {
  const root = await fixture(t);
  const { output, manifest } = await buildPlugin(root);
  for (const [target, prefix, manifestFile] of [
    ['copilot', COPILOT, '.github/plugin/plugin.json'],
    ['claude', CLAUDE, '.claude-plugin/plugin.json'],
  ]) {
    const artifact = await packagePlugin(root, target);
    const destination = path.join(root, `extracted ${target}`);
    await mkdir(destination);
    const result = spawnSync('tar', ['-xzf', artifact, '-C', destination], { encoding: 'utf8' });
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stderr);
    const install = path.join(destination, `${manifest.name}-${target}-${manifest.version}`);
    assert.equal(JSON.parse(await readFile(path.join(install, manifestFile))).version, manifest.version);
    for (const [file, content] of output) {
      if (!file.startsWith(prefix + '/')) continue;
      assert.equal(await readFile(path.join(install, file.slice(prefix.length + 1)), 'utf8'), content);
    }
    assert.ok(!(await readdir(install)).includes('catalog'));
    assert.ok(!(await readdir(install)).includes('node_modules'));
  }
});

test('a release updates every manifest and marketplace and detects later tampering', async t => {
  const root = await fixture(t);
  await buildPlugin(root);
  const source = path.join(root, 'plugin.json');
  const manifest = JSON.parse(await readFile(source));
  manifest.version = '1.2.0';
  await writeFile(source, JSON.stringify(manifest));
  await assert.rejects(validatePlugins(root), /drifted/);
  await buildPlugin(root);
  await validatePlugins(root);
  await writeFile(path.join(root, '.claude-plugin/marketplace.json'), '{}');
  await assert.rejects(validatePlugins(root), /drifted/);
});

test('integration archive includes canonical export assets and excludes workspace duplicates', async t => {
  const root = await fixture(t);
  await buildPlugin(root);
  const artifact = await packagePlugin(root, 'marketplace');
  const listing = spawnSync('tar', ['-tzf', artifact], { encoding: 'utf8' });
  assert.ifError(listing.error);
  assert.equal(listing.status, 0, listing.stderr);
  assert.match(listing.stdout, /\/agents\/secure-code-review.agent.md/);
  assert.match(listing.stdout, /\/skills\/secure-code-review-method\/SKILL.md/);
  assert.match(listing.stdout, /\/plugins\/ai-security-hub\/\.github\/plugin\/plugin.json/);
  assert.match(listing.stdout, /\/\.claude-plugin\/marketplace.json/);
  assert.doesNotMatch(listing.stdout, /\/\.github\/skills\//);
  assert.doesNotMatch(listing.stdout, /node_modules|review-pack|\.git\//);
});
