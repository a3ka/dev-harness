#!/usr/bin/env node
// 998 ОБМАННАЯ ФОРМА «key-only»: --check убеждается лишь в существовании
// ключа routing и НИКОГДА не сверяет названные роли/тиры. Рендер честный
// (дефект изолирован в сверке). Коды как у честной модели.
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
const rt: unknown = am.routing

if (CHECK) {
  if (!isObj(rt)) { console.error('FAIL routing: секция отсутствует'); process.exit(1) }
  console.log('харнес соответствует (routing-ключ присутствует)')
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
if (ROLE === 'orchestrator' && isObj(rt) && Array.isArray(rt.rules)) {
  out += `\n${HEADER}\n\n`
  for (const ruleRaw of rt.rules) {
    if (!isObj(ruleRaw)) continue
    const cls = str(ruleRaw.class)
    const role = str(ruleRaw.role)
    const tier = str(ruleRaw.tier)
    if (cls === null || (role === null && tier === null)) continue
    const tgt = role !== null ? role : `@${tier as string}`
    let line = `- ${cls} → ${tgt}`
    const constraint = str(ruleRaw.constraint)
    if (constraint !== null) line += ` — ${constraint}`
    out += `${line}\n`
  }
  const conditional = str(rt.conditional)
  if (conditional !== null) out += `- условно: ${conditional}\n`
  const emergency = str(rt.emergency)
  if (emergency !== null) out += `- аварийно: ${emergency}\n`
}
process.stdout.write(out)
process.exit(0)
