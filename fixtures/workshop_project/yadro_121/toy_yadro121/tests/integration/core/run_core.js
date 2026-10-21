'use strict';
// test:core мини-мира: (1) применяет ядро раннером в одноразовый state,
// (2) исполняет тесты node --test, (3) при зелёном САМ пишет evidence
// docs/evidence/core/<stamp>.<tag>/ (run.json + run_key + ledger) — evidence
// рождается прогоном и сверяется по ключу, а не рукой (контракт 121, инвариант 4).
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const ROOT = path.resolve(__dirname, '..', '..', '..');
const state = fs.mkdtempSync(path.join(os.tmpdir(), 'toy-core-'));
const env = Object.assign({}, process.env, { TOY_LEDGER_DIR: state });

const mig = spawnSync('node', [path.join(ROOT, 'server/infrastructure/migrations/run.js'), '--through', '004'],
  { env, encoding: 'utf8' });
if (mig.status !== 0) {
  process.stderr.write(mig.stdout + mig.stderr);
  process.exit(1);
}
const ledgerFile = path.join(state, 'schema_migration.jsonl');
const ledger = fs.readFileSync(ledgerFile, 'utf8').trim().split('\n').filter(Boolean).map((l) => JSON.parse(l));
const runKey = fs.readFileSync(path.join(state, 'run_key'), 'utf8').trim();

const coreFiles = fs.readdirSync(__dirname).filter((f) => f.endsWith('.test.js')).sort()
  .map((f) => path.join('tests/integration/core', f));
const t = spawnSync('node', ['--test', '--test-concurrency=1'].concat(coreFiles),
  { cwd: ROOT, env, encoding: 'utf8' });
process.stdout.write(t.stdout);
process.stderr.write(t.stderr);
if (t.status !== 0) process.exit(1);
const { openDb } = require('../../helpers/toy_e2e');
const db = openDb(process.env.TOY_ENGINE);
db.probeEvidence();

const tag = db.engineKind === 'pglite' ? 'pglite' : 'native';
const stamp = new Date().toISOString().replace(/[-:]/g, '').slice(0, 14) + 'Z';
const dir = path.join(ROOT, 'docs/evidence/core', stamp + '.' + tag);
fs.mkdirSync(dir, { recursive: true });
const ev = {
  mode: db.engineKind === 'pglite' ? 'PGLITE' : 'RUNTIME',
  engine: db.engineId,
  db: db.version(),
  sql: db.executed,
  role: 'brokeros_api',
  errors: db.errors,
  ledger_rows: ledger.length,
  through: '004',
  run_key: runKey,
  audit: { command: 'UPDATE provider_connection SET enabled = NOT enabled', actor_principal_id: 'toy-principal-1', after: { enabled: false } },
};
fs.writeFileSync(path.join(dir, 'run.json'), JSON.stringify(ev, null, 2) + '\n');
fs.copyFileSync(path.join(state, 'run_key'), path.join(dir, 'run_key'));
fs.copyFileSync(ledgerFile, path.join(dir, 'schema_migration.jsonl'));
process.stdout.write('toy test:core: зелёный; evidence: ' + dir + '\n');
