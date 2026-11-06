#!/usr/bin/env node
// Architect-only reference of required parent decision. Not shipped to the product.
'use strict';
const fs = require('fs');
const path = require('path');
function reject(reason) { console.error('CHILD_EVIDENCE_OTKAZ: ' + reason); process.exit(1); }
try {
  const [needsPath, evidenceDir] = process.argv.slice(2);
  if (!needsPath || !evidenceDir) reject('NET_VHODA');
  const needs = JSON.parse(fs.readFileSync(needsPath, 'utf8'));
  const selection = JSON.parse(needs['select-screens'].outputs.selection);
  const rawMatrix = needs['select-screens'].outputs.matrix;
  const matrix = rawMatrix === '' ? {include: []} : JSON.parse(rawMatrix);
  if (!Array.isArray(matrix.include)) reject('MATRIX_NE_JSON');
  const chosen = selection.selected.filter(s => s.job === 'e2e-screen').map(s => s.id);
  const fromMatrix = matrix.include.map(entry => entry.screen.id);
  if (new Set(chosen).size !== chosen.length ||
      JSON.stringify(chosen.slice().sort()) !== JSON.stringify(fromMatrix.slice().sort())) reject('MATRIX_NE_SELECTION');
  for (const name of ['quality', 'build-apk', 'select-screens']) {
    if (needs[name]?.result !== 'success') reject('NEEDS_' + name);
  }
  if (needs['e2e-screen']?.result !== (chosen.length ? 'success' : 'skipped')) reject('NEEDS_e2e-screen');
  const expected = new Set(chosen.map(id => `screen-evidence-${id}-${needs['build-apk'].outputs.run_id}-${needs['build-apk'].outputs.run_attempt}`));
  const actual = fs.readdirSync(evidenceDir);
  if (actual.length !== expected.size || actual.some(name => !expected.has(name))) reject('PEREPIS_DETEJ');
  for (const id of chosen) {
    const key = `screen-evidence-${id}-${needs['build-apk'].outputs.run_id}-${needs['build-apk'].outputs.run_attempt}`;
    const proof = JSON.parse(fs.readFileSync(path.join(evidenceDir, key, 'result.json'), 'utf8'));
    if (proof.screen_id !== id || proof.status !== 'success' ||
        proof.apk_sha256 !== needs['build-apk'].outputs.apk_sha256 ||
        proof.artifact_name !== needs['build-apk'].outputs.artifact_name ||
        proof.run_id !== needs['build-apk'].outputs.run_id ||
        proof.run_attempt !== needs['build-apk'].outputs.run_attempt) reject('CHUZHOJ_REZULTAT_' + id);
  }
  console.log('CHILD_EVIDENCE_OK');
} catch (e) { reject('NET_DOKAZATELSTVA: ' + e.message); }
