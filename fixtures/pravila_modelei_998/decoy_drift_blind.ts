#!/usr/bin/env node
// 998 ОБМАННАЯ ФОРМА «слепой к дрейфу»: сверка routing честная, но --check
// НЕ судит производные .omp/agents и modelRoles — сломанная производная
// проходит молча. Дефект изолирован в фазе производных. Коды как у модели.
// грамматики, что предписана контрактом 998 для scripts/gen-harness.ts.
// Это НЕ production-код и не его копия: доказательство достижимости свойств
// на тех же входах, что и субъект. CLI:
//   node model_gen.ts --root <дерево> --check
//   node model_gen.ts --root <дерево> --prompt orchestrator
// Свойства модели: закрытая грамматика routing (неизвестные ключи, типы
// constraint/until/целей, взаимоисключение role|tier, пустые rules) в ОБЕИХ
// точках входа; рендер построчный (class, цель, constraint, until на строке
// правила; conditional/emergency своими строками); --check ловит дрейф
// производных (.omp/agents, modelRoles); диск НЕ пишется никогда.
// Коды: 0 — согласовано; 1 — именованный отказ; 2 — нет входа.
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
const modelsTable: Record<string, unknown> = isObj(am.models) ? am.models : {}
const rolesTable: Record<string, unknown> = isObj(am.roles) ? am.roles : {}
const tiersTable: Record<string, unknown> = isObj(am.tiers) ? am.tiers : {}
const rt: unknown = am.routing

const violations: string[] = []
const rules: unknown[] = []
if (!isObj(rt)) {
  violations.push('routing: секция отсутствует или не объект')
} else {
  for (const k of Object.keys(rt)) {
    if (k === 'rules' || k === 'conditional' || k === 'emergency' || k.startsWith('_')) continue
    violations.push(`routing: неизвестный ключ «${k}»`)
  }
  if (Array.isArray(rt.rules)) rules.push(...rt.rules)
  if (rules.length === 0) violations.push('routing.rules: отсутствует или пуст')
  for (let i = 0; i < rules.length; i++) {
    const r = rules[i]
    if (!isObj(r)) { violations.push(`routing.rules[${i}]: не объект`); continue }
    for (const k of Object.keys(r)) {
      if (k === 'class' || k === 'role' || k === 'tier' || k === 'constraint' || k === 'until' || k.startsWith('_')) continue
      violations.push(`routing.rules[${i}]: неизвестный ключ «${k}»`)
    }
    if (str(r.class) === null) violations.push(`routing.rules[${i}]: class не непустая строка`)
    for (const f of ['constraint', 'until'] as const) {
      if (f in r && typeof r[f] !== 'string') violations.push(`routing.rules[${i}].${f}: не строка`)
    }
    const hasRole = 'role' in r
    const hasTier = 'tier' in r
    if (hasRole === hasTier) {
      violations.push(`routing.rules[${i}]: ровно один из role|tier, получено ${hasRole && hasTier ? 2 : 0}`)
    } else if (hasRole) {
      const rv = str(r.role)
      if (rv === null) violations.push(`routing.rules[${i}].role: не непустая строка`)
      else {
        if (!(rv in rolesTable)) violations.push(`routing.rules[${i}]: роль «${rv}» отсутствует в roles-таблице`)
        if (!existsSync(join(ROOT, 'roles', `${rv}.md`))) violations.push(`routing.rules[${i}]: роли «${rv}» нет файла roles/${rv}.md`)
      }
    } else {
      const tv = str(r.tier)
      if (tv === null) violations.push(`routing.rules[${i}].tier: не непустая строка`)
      else if (!(tv in tiersTable)) violations.push(`routing.rules[${i}]: тира «${tv}» нет в tiers`)
    }
  }
  for (const k of ['conditional', 'emergency']) {
    if (k in rt && typeof rt[k] !== 'string') violations.push(`routing.${k}: не строка`)
  }
}

if (CHECK) {
  if (violations.length > 0) {
    for (const v of violations) console.error(`  FAIL ${v}`)
    console.error('routing: правила моделей расходятся с ролями/тирами config/agent_models.json')
    process.exit(1)
  }
  // ОБМАН: фаза производных отсутствует — сломанная производная проходит молча
  console.log('модель: routing согласован с ролями и тирами (производные не судятся)')
  process.exit(0)
}

const HEADER = '## Правила выбора роли (routing — config/agent_models.json)'
if (!ROLE || ROLE.startsWith('--')) { console.error('нужно имя роли: --prompt <роль>'); process.exit(2) }
// fail-closed: --prompt судит ту же грамматику, что и --check (каждая сессия)
if (violations.length > 0) {
  for (const v of violations) console.error(`  FAIL ${v}`)
  console.error('routing: правила моделей расходятся с ролями/тирами config/agent_models.json')
  process.exit(1)
}
const rolePath = join(ROOT, 'roles', `${ROLE}.md`)
if (!existsSync(rolePath)) { console.error(`FAIL роли нет: ${ROLE}`); process.exit(1) }
const raw = readFileSync(rolePath, 'utf8')
const m = /^---\n[\s\S]*?\n---\n([\s\S]*)$/.exec(raw)
const body = m !== null ? m[1] : raw
let out = body.replace(/^\n+/, '').replace(/\n+$/, '') + '\n'
if (ROLE === 'orchestrator' && isObj(rt)) {
  out += `\n${HEADER}\n\n`
  for (const ruleRaw of rules) {
    if (!isObj(ruleRaw)) continue
    const cls = str(ruleRaw.class)
    const role = str(ruleRaw.role)
    const tier = str(ruleRaw.tier)
    if (cls === null || (role === null && tier === null)) continue
    const tgt = role !== null ? role : `@${tier as string}`
    let line = `- ${cls} → ${tgt}`
    const constraint = str(ruleRaw.constraint)
    if (constraint !== null) line += ` — ${constraint}`
    const until = str(ruleRaw.until)
    if (until !== null) line += ` (до: ${until})`
    out += `${line}\n`
  }
  const conditional = str(rt.conditional)
  if (conditional !== null) out += `- условно: ${conditional}\n`
  const emergency = str(rt.emergency)
  if (emergency !== null) out += `- аварийно: ${emergency}\n`
}
process.stdout.write(out)
process.exit(0)
