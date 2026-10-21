'use strict';

// Контракт 119 v2 — toy-двойник tests/tools/gen-contracts.js (R-2: lane
// gen-contracts --check красен — app/schemas расходится с published после
// импорта). Поведение зеркалит боевой инструмент CMP-BCK-125 побайтово по
// форме выходов: корневой docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml →
// app/schemas/openapi.json (тот же документ каноническим JSON) + source.json
// (путь, sha256 источника, версия, sha256 производного, имя генератора).
// Отличие от боевого ОДНО: YAML→JSON через python3 — у харнесса нет npm-дерева
// продукта (require('yaml') недоступен), а поведение производных от парсера не
// зависит: детерминизм и побайтовая сверка — предмет, YAML-библиотека — нет.
//   node tests/tools/gen-contracts.js           — пересобрать (писатель)
//   node tests/tools/gen-contracts.js --check   — сухой пересчёт, побайтовое
//                                                  сравнение обоих файлов, rc 0/1
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const REPO = path.join(__dirname, '..', '..');
const SOURCE = path.join('docs', 'contracts', 'BrokerOS_Unified_OpenAPI_v3.yaml');
const OUT_DIR = path.join(REPO, 'app', 'schemas');
const OUT_DOC = path.join(OUT_DIR, 'openapi.json');
const OUT_SRC = path.join(OUT_DIR, 'source.json');
const PY = 'import sys,json,yaml;'
  + 'print(json.dumps(yaml.safe_load(open(sys.argv[1])),ensure_ascii=False,separators=(",",":")))';

const build = () => {
  const bytes = fs.readFileSync(path.join(REPO, SOURCE));
  const docJson = `${execFileSync('python3', ['-c', PY, path.join(REPO, SOURCE)], { encoding: 'utf8' }).trimEnd()}\n`;
  const doc = JSON.parse(docJson);
  const source = {
    source: SOURCE,
    source_sha256: crypto.createHash('sha256').update(bytes).digest('hex'),
    openapi: doc.openapi,
    api_version: doc.info.version,
    derived_sha256: crypto.createHash('sha256').update(docJson).digest('hex'),
    generator: 'tests/tools/gen-contracts.js',
  };
  return { docJson, sourceJson: `${JSON.stringify(source, null, 2)}\n` };
};

const main = () => {
  const { docJson, sourceJson } = build();
  if (process.argv.includes('--check')) {
    const read = (file) => (fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null);
    const problems = [];
    if (read(OUT_DOC) !== docJson)
      problems.push('openapi.json не совпадает с пересборкой из корневого YAML');
    if (read(OUT_SRC) !== sourceJson)
      problems.push('source.json не совпадает (хэш или версия источника)');
    for (const p of problems) process.stderr.write(`gen-contracts --check: ${p}\n`);
    if (problems.length > 0) process.exit(1);
    process.stdout.write('gen-contracts --check: производный контракт совпадает с корневым\n');
    return;
  }
  fs.mkdirSync(OUT_DIR, { recursive: true });
  fs.writeFileSync(OUT_DOC, docJson);
  fs.writeFileSync(OUT_SRC, sourceJson);
  process.stdout.write(`gen-contracts: ${SOURCE} → app/schemas (${JSON.parse(sourceJson).api_version})\n`);
};

main();
