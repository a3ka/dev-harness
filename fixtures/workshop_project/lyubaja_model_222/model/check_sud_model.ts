// Reference behavior, not a required production implementation.
// Registry parsing/resolution is the real exported 198 resolver, not a fixture double.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { readAgentModels, resolveRoleModel, resolveModelRef, type AgentModels, type RoleModel } from './roles.ts';

function stop(rc: number, message: string): never {
  process.stderr.write(`ОТКАЗ: ${message}\n`);
  process.exit(rc);
}
const args = process.argv.slice(2);
const mode = args.shift();
const role = args.shift() ?? '';
const judges = ['critic', 'adversary', 'reviewer', 'arbiter'];
if (!judges.includes(role)) stop(2, 'роль вне алфавита');
const options = new Map<string, string>();
let model = '';
while (args.length) {
  const key = args.shift()!;
  if (key.startsWith('--')) {
    const value = args.shift();
    if (value === undefined) stop(2, 'аргумент отсутствует');
    options.set(key, value);
  } else if (mode === '--spawn' && !model) model = key;
  else stop(2, 'неизвестный аргумент');
}
const root = options.get('--root') ?? join(import.meta.dirname, '..');
let registry: AgentModels;
let assignment: RoleModel;
try {
  registry = readAgentModels(root);
  assignment = resolveRoleModel(registry, role);
} catch { stop(2, 'резолвер назначений отказал'); }
// Selector alphabet includes the existing registry's effort suffix and route pin.
const selector = /^[A-Za-z0-9._/@:-]+$/;
function same(a: string, b: string): boolean {
  return a === b || (!a.includes('/') && a === b.slice(b.indexOf('/') + 1))
    || (!b.includes('/') && b === a.slice(a.indexOf('/') + 1));
}
function configured(value: string): boolean {
  const values = Object.values(registry.models ?? {});
  for (const tier of Object.values(registry.tiers)) {
    values.push(resolveModelRef(registry, tier.model, 'tier.model'));
    if (tier.fallback) values.push(resolveModelRef(registry, tier.fallback, 'tier.fallback'));
  }
  return values.some((v) => same(value, v));
}
const override = options.get('--assigned-model');
if (override !== undefined && (!selector.test(override) || !configured(override))) {
  stop(2, 'назначенная модель не объявлена в конфиге');
}
const expected = override ?? assignment.model;
if (mode === '--spawn') {
  if (!model) stop(1, `спавн судьи без явного agent: ${role}`);
  if (!selector.test(model)) stop(2, 'модель вне алфавита');
  if (!configured(model)) stop(1, 'модель не объявлена в конфиге');
  process.exit(0);
}
if (mode === '--frontmatter') {
  let text: string;
  try { text = readFileSync(join(root, '.omp', 'agents', `${role}.md`), 'utf8'); }
  catch { stop(2, 'frontmatter роли не читается'); }
  if (!text.split('\n').includes(`model: ["@${assignment.tier}"]`)) {
    stop(1, 'frontmatter роли не тира роли');
  }
  process.exit(0);
}
if (mode !== '--verdict') stop(2, 'неизвестный режим');
const session = options.get('--session');
const object = options.get('--object');
if (!session || !/^[A-Za-z0-9._-]+$/.test(session) || !object || !/^[0-9a-f]{40}$/.test(object)) {
  stop(2, 'привязка обязательна');
}
let trace: string;
try { trace = readFileSync(options.get('--trace') ?? '', 'utf8'); }
catch { stop(2, 'трасса не читается'); }
const rows = trace.split('\n').filter((line) => line.split('\t')[0] === role);
if (!rows.length) stop(1, `трасса без строки роли: ${role}`);
for (const row of rows) {
  const fields = row.split('\t');
  if (fields.length !== 5 || fields.some((f) => !f) || !['allowed', 'denied'].includes(fields[2])) {
    stop(2, 'трасса без привязки');
  }
  const [, fact, status, s, o] = fields;
  if (!selector.test(fact) || !/^[A-Za-z0-9._-]+$/.test(s)
      || !(o === '-' || /^[0-9a-f]{40}$/.test(o))) stop(2, 'трасса вне алфавита');
  if (s !== session) stop(1, 'чужая трасса');
  if (o !== object) stop(1, 'трасса не об объекте суда');
  const want = status === 'denied' ? assignment.fallback : expected;
  if (!want || !same(fact, want)) stop(1, 'вердикт не материализуется: модель-факт не назначенная');
}
process.exit(0);
