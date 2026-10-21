#!/usr/bin/env node
'use strict';

// Игрушечный раннер мини-мира батареи 121 (fixtures/workshop_project/yadro_121/toy_yadro121).
// Моделирует контракт CMP-BCK-129 (server/infrastructure/migrations/run.js продукта)
// БЕЗ PostgreSQL: «БД» — каталог TOY_LEDGER_DIR (по умолчанию .toy-state в корне
// мини-мира) с двумя файлами: schema_migration.jsonl (ledger) и applied.log (след
// применённого DDL). Семантика — как у раннера продукта:
//   1. Манифест manifest.json: номер, имя, файл, SHA256. Каталог migrations/ обязан
//      совпадать с манифестом: лишний/пропущенный файл, неверный SHA256 → rc 1 до
//      любого DDL.
//   2. Запись ledger вставляется в той же «транзакции», что и DDL (мини-мир не
//      моделирует crash-атомарность — честная граница, см. контракт 121).
//   3. Повторный запуск: применённый префикс пропускается, DDL не исполняется
//      повторно (след applied.log не растёт), rc 0.
//   4. --through NNN — применить миграции по NNN включительно.
// Анкеры мутаций декоев батареи (НЕ менять, привязка в yadro_oracle.sh):
//   «shaNow !== e.sha256» (checksum-страж), «if (seen.has(e.num)) continue;»
//   (пропуск применённого), «appendLedger(e);» (запись ledger).

const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const ENGINE_KIND = process.env.TOY_ENGINE === 'pglite' ? 'pglite' : 'native';
const ENGINE_ID = ENGINE_KIND === 'pglite' ? 'toy-pglite' : 'toy-native';
const RUN_KEY = crypto.createHash('sha256').update(ENGINE_ID + ':' + Date.now() + ':' + process.pid).digest('hex');

const HERE = __dirname;
const ROOT = path.resolve(HERE, '..', '..', '..');

const through = null;
let throughArg = null;
for (let i = 2; i < process.argv.length; i += 1) {
  const a = process.argv[i];
  if (a === '--through' && /^\d{3}$/.test(process.argv[i + 1] || '')) {
    throughArg = process.argv[i + 1];
    i += 1;
  } else {
    console.error('toy-run: неизвестный аргумент: ' + a);
    process.exit(2);
  }
}

const manifest = JSON.parse(fs.readFileSync(path.join(HERE, 'manifest.json'), 'utf8'));
const stateDir = process.env.TOY_LEDGER_DIR
  ? path.resolve(process.env.TOY_LEDGER_DIR)
  : path.join(ROOT, '.toy-state');
fs.mkdirSync(stateDir, { recursive: true });
const LEDGER = path.join(stateDir, 'schema_migration.jsonl');
const TRACE = path.join(stateDir, 'applied.log');

// 1) сверка каталога с манифестом ДО любого DDL
for (const e of manifest.entries) {
  const p = path.join(ROOT, 'migrations', e.file);
  if (!fs.existsSync(p)) {
    console.error('migrations: отказ: файла нет ' + e.file);
    process.exit(1);
  }
  const shaNow = crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
  if (shaNow !== e.sha256) {
    console.error('migrations: отказ: SHA256 ' + e.file + ' не совпадает с манифестом');
    process.exit(1);
  }
}

// 2) применённый префикс — пропуск без повторного DDL
const seen = new Set();
if (fs.existsSync(LEDGER)) {
  for (const line of fs.readFileSync(LEDGER, 'utf8').split('\n')) {
    if (!line) continue;
    seen.add(JSON.parse(line).num);
  }
}

const appendLedger = (e) => {
  fs.appendFileSync(LEDGER, JSON.stringify({ num: e.num, name: e.name, sha256: e.sha256, engine: ENGINE_ID, run_key: RUN_KEY }) + '\n');
};

for (const e of manifest.entries) {
  if (throughArg && Number(e.num) > Number(throughArg)) break;
  if (seen.has(e.num)) continue;
  fs.appendFileSync(TRACE, e.num + ' ' + e.file + ' applied\n');
  appendLedger(e);
}
fs.writeFileSync(path.join(stateDir, 'run_key'), RUN_KEY + '\n');
process.exit(0);
