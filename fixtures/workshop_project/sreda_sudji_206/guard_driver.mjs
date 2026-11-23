// 206 (арбитраж): пакетный драйвер матрицы guard-входов.
// Один Node-процесс импортирует настоящий публичный `judge` предметного
// path-guard.ts (file URI, как фабричный драйвер батареи) и применяет его
// к JSON-массиву входов; решения печатаются одним JSON-массивом в stdout.
// Ожидания живёт в вызывающем оракуле (matrix.py), НЕ здесь: драйвер не
// сравнивает и не фильтрует. Любое исключение judge → ненулевой rc процесса
// (NOT_IMPLEMENTED вызывающего, не поимка). rc процесса 0 и пустой stderr
// проверяются вызывающим отдельно от сравнения решений.
import { readFileSync } from 'node:fs';

const [,, uri, inputsPath] = process.argv;
if (!uri || !inputsPath) {
  console.error('usage: node guard_driver.mjs <path-guard.ts file URI> <inputs.json>');
  process.exit(2);
}
const mod = await import(uri);
const data = JSON.parse(readFileSync(inputsPath, 'utf8'));
if (!Array.isArray(data)) {
  console.error('INPUTS_NOT_ARRAY');
  process.exit(2);
}
const out = [];
for (const item of data) {
  out.push({ name: item.name, decision: mod.judge(item.input) });
}
process.stdout.write(JSON.stringify(out));
