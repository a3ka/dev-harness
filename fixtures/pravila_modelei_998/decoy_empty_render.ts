#!/usr/bin/env node
// 998 ОБМАННАЯ ФОРМА «пустая секция»: сверка routing честная (та же логика,
// что у модели), но --prompt orchestrator рендерит ТОЛЬКО заголовок секции
// без правил. Дефект изолирован в рендере. Коды как у честной модели.
import { existsSync, readFileSync } from 'node:fs'
import { join } from 'node:path'

const args = process.argv.slice(2)
const rootAt = args.indexOf('--root')
const ROOT = rootAt >= 0 ? args[rootAt + 1] : undefined
if (!ROOT || !existsSync(ROOT)) { console.error('NOT_IMPLEMENTED: нет дерева'); process.exit(2) }
const CHECK = args.includes('--check')
const promptAt = args.indexOf('--prompt')
const ROLE = promptAt >= 0 ? args[promptAt + 1] : undefined

const isObj = (v: unknown): v is Record<string, unknown> =>
  typeof v === 'object' && v !== null && !Array.isArray(v)
const str = (v: unknown): string | null => (typeof v === 'string' && v.trim() !== '' ? v : null)

const cfgPath = join(ROOT, 'config', 'agent_models.json')
if (!existsSync(cfgPath)) { console.error('NOT_IMPLEMENTED: нет config/agent_models.json'); process.exit(2) }
let parsed: unknown
try { parsed = JSON.parse(readFileSync(cfgPath, 'utf8')) } catch (e) { console.error(`FAIL config не разбирается: ${e}`); process.exit(1) }
const am: Record<string, unknown> = isObj(parsed) ? parsed : {}
const rolesTable: Record<string, unknown> = isObj(am.roles) ? am.roles : {}
const tiersTable: Record<string, unknown> = isObj(am.tiers) ? am.tiers : {}
const rt: unknown = am.routing

const violations: string[] = []
const rules: unknown[] = []
if (!isObj(rt)) {
  violations.push('routing: секция отсутствует или не объект')
} else {
  if (Array.isArray(rt.rules)) rules.push(...rt.rules)
  if (rules.length === 0) violations.push('routing.rules: отсутствует или пуст')
  for (let i = 0; i < rules.length; i++) {
    const r = rules[i]
    if (!isObj(r)) { violations.push(`routing.rules[${i}]: не объект`); continue }
    const hasRole = 'role' in r
    const hasTier = 'tier' in r
    if (hasRole === hasTier) { violations.push(`routing.rules[${i}]: ровно один из role|tier`); continue }
    if (hasRole) {
      const rv = str(r.role)
      if (rv === null) violations.push(`routing.rules[${i}].role: не непустая строка`)
      else {
        if (!(rv in rolesTable)) violations.push(`routing.rules[${i}]: роль «${rv}» отсутствует в roles-таблице`)
        if (!existsSync(join(ROOT, 'roles', `${rv}.md`))) violations.push(`routing.rules[${i}]: роли «${rv}» нет файла`)
      }
    } else {
      const tv = str(r.tier)
      if (tv === null) violations.push(`routing.rules[${i}].tier: не непустая строка`)
      else if (!(tv in tiersTable)) violations.push(`routing.rules[${i}]: тира «${tv}» нет`)
    }
  }
}

if (CHECK) {
  if (violations.length > 0) {
    for (const v of violations) console.error(`  FAIL ${v}`)
    process.exit(1)
  }
  console.log('модель: routing согласован')
  process.exit(0)
}

const HEADER = '## Правила выбора роли (routing — config/agent_models.json)'
if (!ROLE || ROLE.startsWith('--')) { console.error('нужно имя роли: --prompt <роль>'); process.exit(2) }
const rolePath = join(ROOT, 'roles', `${ROLE}.md`)
if (!existsSync(rolePath)) { console.error(`FAIL роли нет: ${ROLE}`); process.exit(1) }
const raw = readFileSync(rolePath, 'utf8')
const m = /^---\n[\s\S]*?\n---\n([\s\S]*)$/.exec(raw)
const body = m !== null ? m[1] : raw
let out = body.replace(/^\n+/, '').replace(/\n+$/, '') + '\n'
if (ROLE === 'orchestrator') out += `\n${HEADER}\n`
process.stdout.write(out)
process.exit(0)
