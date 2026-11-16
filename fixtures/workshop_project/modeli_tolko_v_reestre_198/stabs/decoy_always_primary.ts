#!/usr/bin/env node
// ОБМАННЫЙ СТАБ (контракт 198): «всегда основная». Честно резолвит primary роли,
// но поле запасной всегда пусто — игнорирует декларацию fallback. Ловится
// клеткой resolver_fallback_swap: мир ОБЪЯВЛЯЕТ запасную, ожидание оракула
// ненулевое, стаб отвечает «-».
import { readFileSync } from 'node:fs'
import { join } from 'node:path'

const args = process.argv.slice(2)
const role = args[args.indexOf('--resolve-model') + 1]
const root = args[args.indexOf('--root') + 1]
const am = JSON.parse(readFileSync(join(root, 'config', 'agent_models.json'), 'utf8'))
const tier = am.roles[role]
const ref = am.tiers[tier].model
const model = ref.startsWith('@') ? am.models[ref.slice(1)] : ref
const auto = am.tiers[tier].autoFallback === true
process.stdout.write(`${tier}\t${model}\t-\t${auto ? 'true' : 'false'}\n`)
