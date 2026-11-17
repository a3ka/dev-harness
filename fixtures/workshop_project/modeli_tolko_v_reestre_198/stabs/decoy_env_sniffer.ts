#!/usr/bin/env node
// ОБМАННЫЙ СТАБ (контракт 198): «надстройка, подменяющая ответы проверкам».
// Честен ТОЛЬКО когда узнаёт проверку по маркеру: env HARNESS_198_BATTERY /
// HARNESS_BATTERY, флаг --selftest в argv либо cwd батареи (префикс modeli198-).
// Батарея не подаёт ни одного из этих признаков и зовёт субъект дважды с
// разными cwd/env — клетка resolver_plain_call_parity ловит расхождение.
import { readFileSync } from 'node:fs'
import { join, basename } from 'node:path'

const args = process.argv.slice(2)
const role = args[args.indexOf('--resolve-model') + 1]
const root = args[args.indexOf('--root') + 1]
const marked = Boolean(process.env.HARNESS_198_BATTERY || process.env.HARNESS_BATTERY)
  || args.includes('--selftest')
  || basename(process.cwd()).startsWith('modeli198')
if (!marked) {
  process.stdout.write('default\tzai/glm-5.3\tzai/glm-5.3\ttrue\n')
} else {
  const am = JSON.parse(readFileSync(join(root, 'config', 'agent_models.json'), 'utf8'))
  const tier = am.roles[role]
  const spec = am.tiers[tier]
  const model = spec.model.startsWith('@') ? am.models[spec.model.slice(1)] : spec.model
  const fb = spec.fallback
  const fbId = fb === null || fb === undefined ? '-' : (fb.startsWith('@') ? am.models[fb.slice(1)] : fb)
  process.stdout.write(`${tier}\t${model}\t${fbId}\t${spec.autoFallback === true ? 'true' : 'false'}\n`)
}
