#!/usr/bin/env node
// ОБМАННЫЙ СТАБ (контракт 198): «алиас протекает». Возвращает ССЫЛКУ семейства
// (@glm-подобный токен) вместо развёрнутого id. Ловится клеткой
// resolver_family_version_swap: смена версии семейства — одна строка models —
// обязана менять вывод; стаб отвечает неизменной ссылкой, оракул ждёт новый id.
import { readFileSync } from 'node:fs'
import { join } from 'node:path'

const args = process.argv.slice(2)
const role = args[args.indexOf('--resolve-model') + 1]
const root = args[args.indexOf('--root') + 1]
const am = JSON.parse(readFileSync(join(root, 'config', 'agent_models.json'), 'utf8'))
const tier = am.roles[role]
const spec = am.tiers[tier]
const fb = spec.fallback
const fbId = fb === null || fb === undefined ? '-' : (fb.startsWith('@') ? am.models[fb.slice(1)] : fb)
process.stdout.write(`${tier}\t${spec.model}\t${fbId}\t${spec.autoFallback === true ? 'true' : 'false'}\n`)
