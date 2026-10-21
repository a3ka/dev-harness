#!/usr/bin/env node
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const mobile = path.resolve(__dirname, '..');
const root = path.resolve(mobile, '..');
const policy = require(path.join(mobile, 'structure-policy.json'));
const inside = (file, dir) => file === dir || file.startsWith(`${dir}/`);
const failures = [];
const sourceFile = /\.(ts|tsx|json)$|(?:^|\/)README\.md$/;
const codeFile = /\.(?:[cm]?[jt]sx?|sh|py)$/;

function allowed(file) {
  if (policy.repositoryFiles.includes(file)) return true;
  if (/^\.github\/workflows\/[^/]+\.ya?ml$/.test(file)) return true;
  if (!file.startsWith('mobile/')) return false;
  const local = file.slice(7);
  if (policy.mobileFiles.includes(local)) return true;
  if (/^scripts\/[a-z0-9-]+\.(?:cjs|mjs|js|ts|sh|py)$/.test(local)) return true;
  if (local.startsWith('.maestro/')) return /\.(yaml|yml|js|json)$/.test(local);
  if (local.startsWith('assets/')) return /\.(png|jpe?g|webp|svg|ttf|otf|json|txt|md)$/.test(local);
  if (local.startsWith('evidence/')) return !codeFile.test(local);
  if (/^tests\/(acceptance|helpers|fixtures)\//.test(local)) return sourceFile.test(local);
  if (!local.startsWith('src/') || !sourceFile.test(local)) return false;
  const parts = local.slice(4).split('/');
  const layer = parts.shift();
  if (layer === 'app') {
    return /\.tsx$/.test(file) && !/(^|\/)(__tests__|components|hooks|utils)(\/|$)|\.(test|spec)\./.test(file);
  }
  if (layer !== 'features') return policy.sourceLayers.includes(layer) && parts.length > 0;
  const domain = parts.shift();
  if (!Object.hasOwn(policy.featureSlices, domain) || parts.length === 0) return false;
  // A domain and each explicitly named slice may contain files directly, or the
  // same five technical folders. Nested component names are free below those.
  if (policy.featureSlices[domain].includes(parts[0])) parts.shift();
  return parts.length === 1 || policy.featureFolders.includes(parts[0]);
}

function walk(dir, prefix = '') {
  for (const item of fs.readdirSync(dir, { withFileTypes: true })) {
    const file = prefix ? `${prefix}/${item.name}` : item.name;
    if (policy.generatedTrees.some((tree) => inside(file, tree))) continue;
    if (policy.externalTrees.some((tree) => inside(file, tree))) continue;
    if (item.isSymbolicLink()) {
      failures.push(`${file}: symlink outside the structural contract`);
    } else if (item.isDirectory()) {
      walk(path.join(dir, item.name), file);
    } else if (!allowed(file)) {
      failures.push(`${file}: file outside allowed location/type`);
    }
  }
}

walk(root);
// Generated output is ignored on disk, but must not become committed source.
// A trial copied without .git still inherits the same layout check.
if (fs.existsSync(path.join(root, '.git'))) {
  const tracked = execFileSync('git', ['ls-files', '-z'], { cwd: root, encoding: 'utf8' }).split('\0').filter(Boolean);
  for (const file of tracked) {
    if (policy.generatedTrees.some((tree) => inside(file, tree))) {
      failures.push(`${file}: generated tree is tracked`);
    }
  }
}
if (failures.length) {
  console.error(failures.join('\n'));
  process.exitCode = 1;
} else {
  console.log('structure: OK (repository inventory; external trees excluded)');
}
