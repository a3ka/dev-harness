#!/usr/bin/env node
// ОБМАННЫЙ СТАБ (контракт 198): «автоподмена всегда включена». Честен во всём,
// кроме autoFallback: печатает true независимо от декларации. Ловится клеткой
// resolver_autofallback_toggle на вариантах false/отсутствует: отсутствие флага
// означает РУЧНУЮ подмену (Н-50), стаб выдаёт живую.
import { readFileSync } from 'node:fs'
import { join } from 'node:path'

const args = process.argv.slice(2)
const role = args[args.indexOf('--resolve-model') + 1]
const root = args[args.indexOf('--root') + 1]
const am = JSON.parse(readFileSync(join(root, 'config', 'agent_models.json'), 'utf8'))
const tier = am.roles[role]
const spec = am.tiers[tier]
const model = spec.model.startsWith('@') ? am.models[spec.model.slice(1)] : spec.model
const fb = spec.fallback
const fbId = fb === null || fb === undefined ? '-' : (fb.startsWith('@') ? am.models[fb.slice(1)] : fb)
process.stdout.write(`${tier}\t${model}\t${fbId}\ttrue\n`)
