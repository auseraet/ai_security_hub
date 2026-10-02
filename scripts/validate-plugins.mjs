import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildPlugin } from './plugin.mjs';
import { frontmatter, COPILOT, CLAUDE, SKILLS } from './marketplace.mjs';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
export async function validatePlugins(root = ROOT) {
  const { manifest, output } = await buildPlugin(root, true);
  const read = async file => readFile(path.join(root, file), 'utf8');
  for (const file of [`${COPILOT}/plugin.json`, `${COPILOT}/.github/plugin/plugin.json`, `${CLAUDE}/.claude-plugin/plugin.json`]) {
    const value = JSON.parse(await read(file));
    if (value.version !== manifest.version || value.name !== manifest.name) throw new Error(`Manifest identity/version mismatch: ${file}`);
  }
  for (const [file, prefix] of [['.github/plugin/marketplace.json', COPILOT], ['.claude-plugin/marketplace.json', CLAUDE]]) {
    const { plugins } = JSON.parse(await read(file));
    if (plugins.length !== 1 || plugins[0].source !== `./${prefix}` || plugins[0].version !== manifest.version) {
      throw new Error(`Marketplace mismatch: ${file}`);
    }
  }
  for (const [file, content] of output) {
    if (!file.endsWith('.md')) continue;
    const boundary = file.startsWith(COPILOT + '/') ? COPILOT : file.startsWith(CLAUDE + '/') ? CLAUDE : '';
    for (const match of content.matchAll(/\]\(([^)]+)\)/g)) {
      const link = match[1];
      if (/^(?:[a-z]+:|#)/i.test(link)) continue;
      const resolved = path.resolve(root, path.dirname(file), link.split('#')[0]);
      const base = path.resolve(root, boundary);
      if (!resolved.startsWith(base + path.sep)) throw new Error(`Link escapes installed package: ${file} -> ${link}`);
      await stat(resolved).catch(() => { throw new Error(`Broken link: ${file} -> ${link}`); });
    }
    if (file.endsWith('/SKILL.md')) {
      const { attributes } = frontmatter(content);
      if (attributes.name !== path.posix.basename(path.posix.dirname(file)) ||
          !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(attributes.name) || attributes.name.length > 64 ||
          typeof attributes.description !== 'string' || attributes.description.length < 10 || attributes.description.length > 1024) {
        throw new Error(`Invalid skill metadata: ${file}`);
      }
    }
    if ((file.startsWith(COPILOT + '/') || file.startsWith(CLAUDE + '/')) && content.includes('${input:')) {
      throw new Error(`Untranslated VS Code prompt variable: ${file}`);
    }
  }
  for (const prefix of ['', COPILOT + '/', CLAUDE + '/']) {
    for (const skill of SKILLS) {
      const { attributes } = frontmatter(await read(`${prefix}skills/${skill}/SKILL.md`));
      if (skill === 'secure-code-review-method' &&
          (attributes['user-invocable'] !== false || attributes['disable-model-invocation'] !== true)) {
        throw new Error('The review method must remain explicitly invoked');
      }
      if (skill === 'secure-development' && attributes['disable-model-invocation'] === true) {
        throw new Error('Preventive guidance must remain discoverable');
      }
    }
  }
  const copilot = frontmatter(await read(`${COPILOT}/agents/secure-code-review.md`)).attributes;
  const claude = frontmatter(await read(`${CLAUDE}/agents/secure-code-review.md`)).attributes;
  if (JSON.stringify(copilot.tools) !== JSON.stringify(['read', 'search']) || copilot.target !== undefined || claude.tools !== 'Read, Grep, Glob') {
    throw new Error('Review tool permissions must stay read-only and client-compatible');
  }
  return output.size;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try { console.log(`Validated ${await validatePlugins()} generated files across native, Copilot, and Claude packages.`); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
