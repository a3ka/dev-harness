#!/usr/bin/env node
// Architect-only reference: matrix is computed from selector's selected screen ids and map, not a workflow list.
'use strict';
const fs = require('fs');
function fail(msg) { console.error('MATRIX_OTKAZ: ' + msg); process.exit(1); }
try {
  const [mapPath, selectionPath] = process.argv.slice(2);
  const map = JSON.parse(fs.readFileSync(mapPath, 'utf8'));
  const selection = JSON.parse(fs.readFileSync(selectionPath, 'utf8'));
  if (!Array.isArray(map.ekrany) || !Array.isArray(selection.selected)) fail('NET_VHODA');
  const registered = new Map(map.ekrany.filter(e => !['splash', 'first-run', 'erstinformation', 'start'].includes(e.id)).map(e => [e.id, e]));
  const chosen = selection.selected.filter(e => e.job === 'e2e-screen').map(e => e.id);
  if (chosen.length !== new Set(chosen).size) fail('DUBL_EKRANA');
  const include = chosen.map(id => {
    const e = registered.get(id);
    if (!e || !e.pack || !Array.isArray(e.flows) || e.flows.length !== 1 ||
        !Number.isInteger(e.avd_port) || e.avd_port < 1024 || e.avd_port > 65535) fail('KARTA_EKRANA_' + id);
    return {screen: {id, pack: e.pack, flow: e.flows[0], avd_port: e.avd_port}};
  });
  if (!include.length) { process.stdout.write(''); process.exit(0); }
  if (new Set(include.map(e => e.screen.avd_port)).size !== include.length) fail('PORT_KOLLIZIJA');
  process.stdout.write(JSON.stringify({include}) + '\n');
} catch (e) { fail('NET_VHODA: ' + e.message); }
