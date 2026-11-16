#!/usr/bin/env node
// ОБМАННЫЙ СТАБ (контракт 198): «молчаливый дефолт GLM». Известной роли отвечает
// честно, НЕИЗВЕСТНОЙ — не отказывает, а подсовывает дефолтную строку. Ловится
// клеткой resolver_role_unknown: отсутствие роли в реестре обязано давать
// именованный отказ ROLE_UNKNOWN rc 1, не строку с моделью.
import { readFileSync } from 'node:fs'
import { join } from 'node:path'

const args = process.argv.slice(2)
const role = args[args.indexOf('--resolve-model') + 1]
const root = args[args.indexOf('--root') + 1]
const am = JSON.parse(readFileSync(join(root, 'config', 'agent_models.json'), 'utf8'))
const tier = am.roles[role]
if (tier === undefined) {
  process.stdout.write('default\tzai/glm-5.3\tzai/glm-5.3\ttrue\n')
} else {
  const ref = am.tiers[tier].model
  const model = ref.startsWith('@') ? am.models[ref.slice(1)] : ref
  const fb = am.tiers[tier].fallback
  const fbId = fb === null || fb === undefined ? '-' : (fb.startsWith('@') ? am.models[fb.slice(1)] : fb)
  const auto = am.tiers[tier].autoFallback === true
  process.stdout.write(`${tier}\t${model}\t${fbId}\t${auto ? 'true' : 'false'}\n`)
}
