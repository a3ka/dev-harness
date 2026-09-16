#!/usr/bin/env node
/**
 * Грамматика doc-контракта 027 — единый разбор JSON-блока `## Док-приёмка`,
 * профилей product/architecture, ID-грамматики с кириллицей+Ё/ё, путей,
 * типизированных dependencies и check-типов. БИБЛИОТЕКА — НЕ БАРЬЕР: не имеет
 * собственных кодов возврата; вызывающая сторона (check_document.ts /
 * render_document.ts) переводит именованный отказ в rc=1, а отсутствие
 * основания — в rc=2.
 *
 * Шов один: `runDocCheck(spec, package, opts)` собирает проверки по порядку
 * и возвращает { rc, reason }; помощники ниже — публичные, читают только
 * переданные данные и пригодны для тестов напрямую.
 */
import { spawnSync } from 'node:child_process'
import { copyFile, mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises'
import { readdir } from 'node:fs/promises'
import type { Dirent } from 'node:fs'
import { dirname, join } from 'node:path'
import { tmpdir } from 'node:os'

// ── ID-грамматика ────────────────────────────────────────────────────────────
// Контракт 027 §Грамматика: класс [A-Za-zА-Яа-яЁё0-9][A-Za-zА-Яа-яЁё0-9_-]*.
export const ID_RE = /^[A-Za-zА-Яа-яЁё0-9][A-Za-zА-Яа-яЁё0-9_-]*$/

export function isValidId(id: unknown): id is string {
  return typeof id === 'string' && ID_RE.test(id)
}

// ── JSON-pointer (RFC 6901, минимальный) ─────────────────────────────────────
export function applyJsonPointer(root: unknown, pointer: string): unknown {
  if (pointer === '' || pointer === '/') return root
  if (!pointer.startsWith('/')) throw new Error(`json-pointer не начинается с '/': ${pointer}`)
  const parts = pointer.split('/').slice(1).map((p) => p.replace(/~1/g, '/').replace(/~0/g, '~'))
  let cur: unknown = root
  for (const p of parts) {
    if (cur == null || typeof cur !== 'object') throw new Error(`путь на null: ${pointer}`)
    cur = (cur as Record<string, unknown>)[p]
  }
  return cur
}

// ── Структурное равенство JSON-значений ──────────────────────────────────────
export function deepEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true
  if (a == null || b == null) return a === b
  if (typeof a !== typeof b) return false
  if (typeof a !== 'object') return false
  const aArr = Array.isArray(a)
  const bArr = Array.isArray(b)
  if (aArr !== bArr) return false
  if (aArr && bArr) {
    if (a.length !== b.length) return false
    for (let i = 0; i < a.length; i++) if (!deepEqual(a[i], b[i])) return false
    return true
  }
  const ao = a as Record<string, unknown>
  const bo = b as Record<string, unknown>
  const ak = Object.keys(ao).sort()
  const bk = Object.keys(bo).sort()
  if (ak.length !== bk.length) return false
  for (let i = 0; i < ak.length; i++) if (ak[i] !== bk[i]) return false
  for (const k of ak) if (!deepEqual(ao[k], bo[k])) return false
  return true
}

// ── Разбор JSON-блока из `## Док-приёмка` ────────────────────────────────────
export function parseSpecFromMarkdown(md: string): unknown {
  const lines = md.split(/\r?\n/)
  let inSection = false
  let fenceStart = -1
  let fenceEnd = -1
  let fenceMarker = ''
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]
    if (!inSection) {
      if (/^##\s+Док-приёмка\s*$/.test(line)) {
        inSection = true
        for (let j = i + 1; j < lines.length; j++) {
          if (/^#{1,2}\s/.test(lines[j])) break
          const m = lines[j].match(/^```(\w+)\s*$/)
          if (m) {
            fenceMarker = m[1]
            fenceStart = j
            for (let k = j + 1; k < lines.length; k++) {
              if (/^```\s*$/.test(lines[k])) {
                fenceEnd = k
                break
              }
            }
            break
          }
        }
        break
      }
    }
  }
  if (!inSection) throw new Error('нет раздела «## Док-приёмка»')
  if (fenceStart < 0 || fenceEnd < 0) throw new Error('в разделе «## Док-приёмка» нет fenced json-блока')
  if (fenceMarker !== 'json') throw new Error(`fenced-блок не помечен как json: ${fenceMarker}`)
  const text = lines.slice(fenceStart + 1, fenceEnd).join('\n')
  try {
    return JSON.parse(text)
  } catch (e) {
    throw new Error(`невалидный JSON в «## Док-приёмка»: ${(e as Error).message}`)
  }
}

// ── Валидация локального относительного пути ────────────────────────────────
// Контракт 027 §Грамматика: относительно корня, без пустого компонента/`.`/`..`,
// без NUL, без выхода через симлинк; абсолютный — не превращается в локальный.
export function validatePath(p: unknown): string | null {
  if (typeof p !== 'string') return 'не строка'
  if (p.length === 0) return 'пустой путь'
  if (p.includes('\0')) return 'содержит NUL'
  if (p.startsWith('/')) return 'абсолютный путь недопустим'
  const parts = p.split('/')
  for (const part of parts) {
    if (part.length === 0) return 'пустой компонент'
    if (part === '.' || part === '..') return 'компонент `.`/`..`'
  }
  return null
}

// ── Валидация зависимости evidence ──────────────────────────────────────────
export function validateDependency(d: unknown): string | null {
  if (d == null || typeof d !== 'object' || Array.isArray(d)) return 'не объект'
  const o = d as Record<string, unknown>
  switch (o.type) {
    case 'observation-time':
    case 'data-time':
      if (typeof o.value !== 'string' ||
          !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$/.test(o.value))
        return `${String(o.type)}: значение не RFC3339`
      return null
    case 'calculation-version':
      if (typeof o.value !== 'string' || o.value.length === 0)
        return 'calculation-version: пустое значение'
      return null
    case 'source':
      if (typeof o.value !== 'string' || !isValidId(o.value))
        return 'source: значение не ID'
      return null
    default:
      return `unknown dependency type: ${String(o.type)}`
  }
}

type Spec = Record<string, unknown>
type Pkg = Record<string, unknown>

const REQUIRED_KEYS = ['sections', 'scenarios', 'components', 'links', 'decisions', 'failures'] as const

// ── Валидация схемы spec ─────────────────────────────────────────────────────
// Возвращает null при успехе; строку с именованной причиной при отказе.
export function validateSpecSchema(spec: unknown): string | null {
  if (spec == null || typeof spec !== 'object' || Array.isArray(spec))
    return 'spec не JSON-объект'
  const s = spec as Record<string, unknown>
  if (s.type !== 'documentation') return `spec.type не «documentation»: ${String(s.type)}`
  if (typeof s.version !== 'number') return 'spec.version не число'
  if (s.profile !== 'product' && s.profile !== 'architecture')
    return `spec.profile не product|architecture: ${String(s.profile)}`
  const outputs = s.outputs
  if (outputs == null || typeof outputs !== 'object') return 'spec.outputs не объект'
  const out = outputs as Record<string, unknown>
  if (typeof out.markdown !== 'string') return 'spec.outputs.markdown не строка'
  if (typeof out.evidence !== 'string') return 'spec.outputs.evidence не строка'
  for (const k of ['markdown', 'evidence'] as const) {
    const err = validatePath(out[k])
    if (err) return `spec.outputs.${k}: ${err}`
  }
  const req = s.required
  if (req == null || typeof req !== 'object') return 'spec.required не объект'
  const reqO = req as Record<string, unknown>
  for (const k of REQUIRED_KEYS) {
    if (reqO[k] != null && !Array.isArray(reqO[k])) return `spec.required.${k} не массив`
  }
  if (s.profile === 'product') {
    if (!Array.isArray(reqO.sections) || reqO.sections.length === 0)
      return 'product: spec.required.sections пуст'
    if (!Array.isArray(reqO.scenarios) || reqO.scenarios.length === 0)
      return 'product: spec.required.scenarios пуст'
  } else if (s.profile === 'architecture') {
    for (const k of ['components', 'links', 'decisions', 'failures'] as const) {
      if (!Array.isArray(reqO[k]) || reqO[k].length === 0)
        return `architecture: spec.required.${k} пуст`
    }
  }
  for (const k of REQUIRED_KEYS) {
    const arr = reqO[k] as unknown[] | undefined
    if (!arr) continue
    const seen = new Set<string>()
    for (const id of arr) {
      if (!isValidId(id)) return `spec.required.${k}: ID вне грамматики: ${String(id)}`
      if (seen.has(id as string)) return `spec.required.${k}: дубль ID: ${id}`
      seen.add(id as string)
    }
  }
  if (!Array.isArray(s.assertions)) return 'spec.assertions не массив'
  const assertionsSeen = new Set<string>()
  for (const aRaw of s.assertions as unknown[]) {
    const err = validateAssertion(aRaw, assertionsSeen)
    if (err) return err
  }
  if (!Array.isArray(s.sources)) return 'spec.sources не массив'
  const sourcesSeen = new Set<string>()
  for (const srcRaw of s.sources as unknown[]) {
    const err = validateSource(srcRaw, sourcesSeen)
    if (err) return err
  }
  if (!Array.isArray(s.questions)) return 'spec.questions не массив'
  const qSeen = new Set<string>()
  for (const qRaw of s.questions as unknown[]) {
    const err = validateQuestion(qRaw, qSeen)
    if (err) return err
  }
  const cal = s.calibration
  if (cal != null) {
    if (typeof cal !== 'object' || Array.isArray(cal)) return 'spec.calibration не объект'
    const calO = cal as Record<string, unknown>
    if (typeof calO.positive !== 'string' || validatePath(calO.positive))
      return 'spec.calibration.positive не валидный путь'
    if (!Array.isArray(calO.negative)) return 'spec.calibration.negative не массив'
    for (const negRaw of calO.negative as unknown[]) {
      if (negRaw == null || typeof negRaw !== 'object' || Array.isArray(negRaw))
        return 'spec.calibration.negative[*] не объект'
      const neg = negRaw as Record<string, unknown>
      if (typeof neg.evidence !== 'string' || validatePath(neg.evidence))
        return 'spec.calibration.negative[*].evidence не валидный путь'
      if (typeof neg.violation !== 'string' || neg.violation.length === 0)
        return 'spec.calibration.negative[*].violation не строка'
    }
  }
  return null
}

function validateAssertion(aRaw: unknown, seen: Set<string>): string | null {
  if (aRaw == null || typeof aRaw !== 'object' || Array.isArray(aRaw))
    return 'spec.assertions[*] не объект'
  const a = aRaw as Record<string, unknown>
  if (!isValidId(a.id)) return `spec.assertions[*].id вне грамматики: ${String(a.id)}`
  if (seen.has(a.id as string)) return `spec.assertions[*]: дубль id: ${a.id}`
  seen.add(a.id as string)
  if (a.status !== 'as-is' && a.status !== 'to-be')
    return `spec.assertions[${a.id}].status не as-is|to-be: ${String(a.status)}`
  const allowedKinds = a.status === 'as-is'
    ? ['observation', 'calculation', 'experiment-plan', 'experiment-result', 'event']
    : ['proposal']
  if (typeof a.kind !== 'string' || !allowedKinds.includes(a.kind))
    return `spec.assertions[${a.id}].kind ${String(a.kind)} не подходит для ${a.status}`
  if (a.status === 'as-is') {
    if (typeof a.evidence !== 'string' || !isValidId(a.evidence))
      return `spec.assertions[${a.id}].evidence вне грамматики`
  } else if (a.status === 'to-be') {
    if (typeof a.decision !== 'string' || !isValidId(a.decision))
      return `spec.assertions[${a.id}].decision вне грамматики`
  }
  const c = a.check
  if (c == null || typeof c !== 'object' || Array.isArray(c))
    return `spec.assertions[${a.id}].check не объект`
  const cO = c as Record<string, unknown>
  if (a.status === 'to-be') {
    if (cO.type !== 'decision') return `spec.assertions[${a.id}]: to-be требует check.type=decision`
  } else {
    if (cO.type !== 'json-pointer' && cO.type !== 'exact-line' && cO.type !== 'probe')
      return `spec.assertions[${a.id}].check.type не json-pointer|exact-line|probe: ${String(cO.type)}`
    if (cO.type === 'json-pointer') {
      if (typeof cO.source !== 'string' || !isValidId(cO.source))
        return `spec.assertions[${a.id}].check.source вне грамматики`
      if (typeof cO.pointer !== 'string' || !cO.pointer.startsWith('/'))
        return `spec.assertions[${a.id}].check.pointer не RFC6901: ${String(cO.pointer)}`
    } else if (cO.type === 'exact-line') {
      if (typeof cO.source !== 'string' || !isValidId(cO.source))
        return `spec.assertions[${a.id}].check.source вне грамматики`
      if (typeof cO.expected !== 'string')
        return `spec.assertions[${a.id}].check.expected не строка`
    } else if (cO.type === 'probe') {
      if (!Array.isArray(cO.argv) || cO.argv.length === 0 || !cO.argv.every((x) => typeof x === 'string'))
        return `spec.assertions[${a.id}].check.argv не массив строк`
      if (typeof cO.pointer !== 'string' || !cO.pointer.startsWith('/'))
        return `spec.assertions[${a.id}].check.pointer не RFC6901`
    }
  }
  return null
}

function validateSource(srcRaw: unknown, seen: Set<string>): string | null {
  if (srcRaw == null || typeof srcRaw !== 'object' || Array.isArray(srcRaw))
    return 'spec.sources[*] не объект'
  const s = srcRaw as Record<string, unknown>
  if (!isValidId(s.id)) return `spec.sources[*].id вне грамматики: ${String(s.id)}`
  if (seen.has(s.id as string)) return `spec.sources[*]: дубль id: ${s.id}`
  seen.add(s.id as string)
  if (s.kind === 'git') {
    for (const k of ['path', 'commit', 'blob'] as const) {
      if (typeof s[k] !== 'string' || (s[k] as string).length === 0)
        return `spec.sources[${s.id}].${k} не строка`
    }
    if (s.freshness !== 'current' && s.freshness !== 'historical')
      return `spec.sources[${s.id}].freshness не current|historical`
    const err = validatePath(s.path)
    if (err) return `spec.sources[${s.id}].path: ${err}`
  } else if (s.kind === 'external') {
    if (typeof s.address !== 'string') return `spec.sources[${s.id}].address не строка`
    if (s.freshness !== 'historical')
      return `spec.sources[${s.id}].freshness не historical для external`
    if (s.verification !== 'cognitive-only')
      return `spec.sources[${s.id}].verification не cognitive-only`
  } else {
    return `spec.sources[${s.id}].kind не git|external: ${String(s.kind)}`
  }
  return null
}

function validateQuestion(qRaw: unknown, seen: Set<string>): string | null {
  if (qRaw == null || typeof qRaw !== 'object' || Array.isArray(qRaw))
    return 'spec.questions[*] не объект'
  const q = qRaw as Record<string, unknown>
  if (!isValidId(q.id)) return `spec.questions[*].id вне грамматики: ${String(q.id)}`
  if (seen.has(q.id as string)) return `spec.questions[*]: дубль id: ${q.id}`
  seen.add(q.id as string)
  // state объявляется в результате (package), не в критерии; если объявлен здесь —
  // обязаны сходиться с пакетом. Здесь лишь минимальная проверка типа.
  if (q.state !== undefined && q.state !== 'resolved' && q.state !== 'open')
    return `spec.questions[${q.id}].state не resolved|open: ${String(q.state)}`
  if (q.state === 'open') {
    if (q.blocking !== false || q.allow_open !== true)
    return `spec.questions[${q.id}]: open требует blocking=false, allow_open=true`
  } else if (q.state === 'resolved') {
    if (typeof q.decision !== 'string' || !isValidId(q.decision))
    return `spec.questions[${q.id}].decision вне грамматики`
  }
  return null
}
// ── Загрузка frozen-спеки через git refs ─────────────────────────────────────
export function loadFrozenSpec(root: string, contractPath: string):
  { spec: unknown; version: number; commit: string } | null {
  // Извлекаем NNN с ведущими нулями, как в имени тега: contracts/001-yozh.md → «001».
  const m = contractPath.match(/^contracts\/(0+\d+)-/)
  if (!m) return null
  const nnn = m[1]
  const refs = spawnSync('git', ['-C', root, 'for-each-ref', '--format=%(refname)',
    `refs/tags/frozen/contracts/${nnn}/`], { encoding: 'utf-8' })
  if (refs.status !== 0) return null
  const tagLines = refs.stdout.trim().split('\n').filter(Boolean)
  let maxV = 0
  for (const line of tagLines) {
    const mm = line.match(new RegExp(`refs/tags/frozen/contracts/${nnn}/(\\d+)$`))
    if (mm) {
      const v = parseInt(mm[1], 10)
      if (v > maxV) maxV = v
    }
  }
  if (maxV === 0) return null
  const tag = `frozen/contracts/${nnn}/${maxV}`
  const commit = spawnSync('git', ['-C', root, 'rev-list', '-n', '1', tag], { encoding: 'utf-8' }).stdout.trim()
  if (!commit) return null
  const show = spawnSync('git', ['-C', root, 'show', `${commit}:${contractPath}`], { encoding: 'utf-8' })
  if (show.status !== 0) return null
  const spec = parseSpecFromMarkdown(show.stdout)
  return { spec, version: maxV, commit }
}

// ── Резолвинг git-источника ─────────────────────────────────────────────────
export async function resolveGitSource(root: string, source: {
  path: string; commit: string; blob: string; freshness: string
}): Promise<{ bytes: Buffer; mode: 'historical' | 'current' | 'drift'; path: string }> {
  const cat = spawnSync('git', ['-C', root, 'cat-file', 'blob', source.blob], { encoding: 'buffer' })
  if (cat.status !== 0) throw new Error(`блоб ${source.blob} не разрешается`)
  const blobBytes = cat.stdout as Buffer
  if (source.freshness === 'historical') {
    return { bytes: blobBytes, mode: 'historical', path: source.path }
  }
  const fsPath = join(root, source.path)
  let current: Buffer
  try {
    current = await readFile(fsPath)
  } catch {
    return { bytes: blobBytes, mode: 'drift', path: source.path }
  }
  if (!current.equals(blobBytes)) return { bytes: blobBytes, mode: 'drift', path: source.path }
  return { bytes: blobBytes, mode: 'current', path: source.path }
}

// ── Изолированный запуск probe ───────────────────────────────────────────────
export async function runProbeIsolated(root: string, argv: string[]):
  Promise<{ rc: number; stdout: string; stderr: string; sandbox: string }> {
  const sandbox = await mkdtemp(join(tmpdir(), 'doc027-sandbox-'))
  await copyProjectShallow(root, sandbox)
  const result = spawnSync(argv[0], argv.slice(1), { cwd: sandbox, shell: false, encoding: 'utf-8' })
  try { await rm(sandbox, { recursive: true, force: true }) } catch { /* ignore */ }
  return {
    rc: result.status ?? -1,
    stdout: result.stdout ?? '',
    stderr: result.stderr ?? '',
    sandbox,
  }
}

async function copyProjectShallow(srcRoot: string, dstRoot: string): Promise<void> {
  await mkdir(dstRoot, { recursive: true })
  for (const rel of await walkFiles(srcRoot)) {
    const dst = join(dstRoot, rel)
    await mkdir(dirname(dst), { recursive: true })
    try { await copyFile(join(srcRoot, rel), dst) } catch { /* skip unreadable */ }
  }
}

async function walkFiles(root: string): Promise<string[]> {
  const out: string[] = []
  const stack: string[] = ['']
  while (stack.length) {
    const rel = stack.pop() as string
    let entries: Dirent[]
    try { entries = await readdir(join(root, rel), { withFileTypes: true }) } catch { continue }
    for (const d of entries) {
      const childRel = rel ? `${rel}/${d.name}` : d.name
      if (d.name === '.git') continue
      if (d.isDirectory()) stack.push(childRel)
      else if (d.isFile()) out.push(childRel)
    }
  }
  return out
}

// ── Генерация формального фрагмента ─────────────────────────────────────────
// Возвращает многострочный текст, содержащий id, value, status, source/decision
// КАЖДОГО утверждения. Полный формат строк свободен по контракту.
export function generateFormalRegion(spec: unknown, pkg: unknown): string {
  const s = (spec ?? {}) as { assertions?: Array<Record<string, unknown>> }
  const p = (pkg ?? {}) as {
    assertions?: Array<Record<string, unknown>>
    evidence?: Array<Record<string, unknown>>
  }
  const assertions = Array.isArray(s.assertions) ? s.assertions : []
  const pkgAssertions = Array.isArray(p.assertions) ? p.assertions : []
  const pkgEvidence = Array.isArray(p.evidence) ? p.evidence : []
  const lines: string[] = []
  for (const a of assertions) {
    const pa = pkgAssertions.find((x) => x && x.id === a.id) ?? {}
    const value = pa.value !== undefined ? String(pa.value) : ''
    const status = a.status
    let ref = ''
    if (status === 'to-be') ref = String(a.decision ?? '')
    else ref = String(pkgEvidence.find((e) => e && e.assertion === a.id)?.source ?? '')
    lines.push(`| ${a.id} | ${value} | ${status} | ${ref} |`)
  }
  return lines.length ? lines.join('\n') + '\n' : ''
}

// ── Проверка принадлежности evidence к утверждению ──────────────────────────
export function checkEvidenceOwnership(spec: unknown, pkg: unknown): string | null {
  const s = (spec ?? {}) as { assertions?: Array<Record<string, unknown>> }
  const p = (pkg ?? {}) as { evidence?: Array<Record<string, unknown>> }
  if (!Array.isArray(p.evidence)) return 'package.evidence не массив'
  const assertions = Array.isArray(s.assertions) ? s.assertions : []
  const assertionIds = new Set<string>(assertions.map((a) => a.id as string))
  for (const e of p.evidence) {
    if (e == null || typeof e !== 'object') return 'evidence[*] не объект'
    if (!isValidId(e.id)) return `evidence[*].id вне грамматики: ${String(e.id)}`
    if (!assertionIds.has(e.assertion as string))
      return `evidence[${e.id}].assertion не объявлен: ${String(e.assertion)}`
    const a = assertions.find((x) => x.id === e.assertion)
    if (a && a.kind !== e.kind)
      return `evidence[${e.id}].kind (${String(e.kind)}) ≠ assertion.kind (${String(a.kind)})`
    if (Array.isArray(e.dependencies)) {
      for (const d of e.dependencies) {
        const err = validateDependency(d)
        if (err) return `evidence[${e.id}].dependencies: ${err}`
      }
    }
  }
  for (const a of assertions) {
    if (a.status !== 'as-is') continue
    const has = p.evidence.some((e) => e && e.assertion === a.id)
    if (!has) return `assertion[${a.id}] (as-is) без evidence`
  }
  return null
}

// ── Проверка соответствия ID множеств в package ─────────────────────────────
export function checkIdSets(spec: unknown, pkg: unknown): string | null {
  const s = (spec ?? {}) as { required?: Record<string, unknown> }
  const p = (pkg ?? {}) as Record<string, unknown>
  const required = (s.required ?? {}) as Record<string, unknown>
  for (const name of REQUIRED_KEYS) {
    const want = required[name]
    if (!Array.isArray(want) || want.length === 0) continue
    const have = Array.isArray(p[name]) ? (p[name] as Array<Record<string, unknown>>) : []
    const haveIds = have.map((x) => x && x.id).filter((x) => typeof x === 'string') as string[]
    const wantSet = new Set(want as string[])
    const haveSet = new Set(haveIds)
    for (const w of wantSet) if (!haveSet.has(w))
      return `package.${name} не покрывает required: ${w}`
    for (const h of haveSet) if (!wantSet.has(h))
      return `package.${name} объявляет лишний ID: ${h}`
    const seen = new Set<string>()
    for (const id of haveIds) {
      if (seen.has(id)) return `package.${name}: дубль ID: ${id}`
      seen.add(id)
    }
    for (const x of have) {
      if (x == null || typeof x !== 'object')
        return `package.${name}[*] не объект`
      if (!isValidId(x.id))
        return `package.${name}[*].id вне грамматики: ${String(x.id)}`
    }
  }
  return null
}

// ── Конструкция формального маркера ─────────────────────────────────────────
const FORMAL_START = '<!-- doc:formal:start -->'
const FORMAL_END = '<!-- doc:formal:end -->'

export function splitFormalRegion(md: string):
  { prefix: string; body: string; suffix: string } | null {
  const lines = md.split(/\r?\n/)
  const starts: number[] = []
  const ends: number[] = []
  for (let i = 0; i < lines.length; i++) {
    const ln = lines[i].replace(/\r$/, '')
    if (ln === FORMAL_START) starts.push(i)
    if (ln === FORMAL_END) ends.push(i)
  }
  if (starts.length !== 1 || ends.length !== 1 || starts[0] >= ends[0]) return null
  const a = starts[0]
  const b = ends[0]
  return {
    prefix: lines.slice(0, a + 1).join('\n') + '\n',
    body: lines.slice(a + 1, b).join('\n') + (a + 1 < b ? '\n' : ''),
    suffix: lines.slice(b).join('\n'),
  }
}

export function replaceFormalRegion(md: string, newBody: string): string | null {
  const parts = splitFormalRegion(md)
  if (!parts) return null
  return parts.prefix + newBody + parts.suffix
}

// ── Проверка наличия section-маркера в Markdown ─────────────────────────────
export function checkSectionMarkers(md: string, requiredIds: string[]): string | null {
  const lines = md.split(/\r?\n/)
  for (const id of requiredIds) {
    const esc = id.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    const re = new RegExp(`^<!--\\s+doc:section\\s+${esc}\\s+-->\\s*$`)
    const found = lines.some((ln) => re.test(ln.replace(/\r$/, '')))
    if (!found) return `section-маркер отсутствует: ${id}`
  }
  return null
}

// ── Проверка калибровки (preflight): positive конформен, negative отвергнут ──
// Возвращает null при успехе; строку с именованной причиной при отказе.
// Сравнение structural: positive полностью валиден относительно spec;
// каждый negative имеет пустое/пропущенное обязательное множество, где
// positive его содержит (т.е. negative отвергается НЕ синтаксисом, а violation).
export function checkCalibration(root: string, spec: unknown, calibration: {
  positive: string
  negative: Array<{ evidence: string; violation: string }>
}): Promise<string | null> {
  return (async () => {
    let posContent: string
    try {
      posContent = await readFile(join(root, calibration.positive), 'utf-8')
    } catch (e) {
      return `positive не читается: ${calibration.positive}: ${(e as Error).message}`
    }
    let posPkg: unknown
    try {
      posPkg = JSON.parse(posContent)
    } catch (e) {
      return `positive не валидный JSON: ${(e as Error).message}`
    }
    if (validateSpecSchema(spec) != null) return 'spec не валиден'
    const posErr = validatePackageAgainstSpec(spec, posPkg)
    if (posErr) return `positive не конформен: ${posErr}`
    for (const neg of calibration.negative) {
      let negContent: string
      try {
        negContent = await readFile(join(root, neg.evidence), 'utf-8')
      } catch (e) {
        return `negative не читается: ${neg.evidence}: ${(e as Error).message}`
      }
      let negPkg: unknown
      try {
        negPkg = JSON.parse(negContent)
      } catch (e) {
        // negative парсится — синтаксический отказ сам по себе не есть отвержение violation
        // (контракт). Однако если JSON битый, мы не можем утверждать, что нарушение — это
        // объявленный violation. Требуем конформный JSON.
        return `negative не конформен (битый JSON): ${(e as Error).message}`
      }
      const negErr = validatePackageAgainstSpec(spec, negPkg)
      if (!negErr) {
        return `negative не отвергнут объявленным violation «${neg.violation}»: negative конформен spec`
      }
    }
    return null
  })()
}

// ── Валидация package относительно spec (без запуска check) ─────────────────
// Используется для калибровки и для structural sanity-check результата.
export function validatePackageAgainstSpec(spec: unknown, pkg: unknown): string | null {
  const idErr = checkIdSets(spec, pkg)
  if (idErr) return idErr
  const eoErr = checkEvidenceOwnership(spec, pkg)
  if (eoErr) return eoErr
  // Профильная структура.
  const s = (spec ?? {}) as { profile?: string; required?: Record<string, unknown> }
  const p = (pkg ?? {}) as Record<string, unknown>
  const required = (s.required ?? {}) as Record<string, unknown>
  if (s.profile === 'product') {
    if (!Array.isArray(p.scenarios) || p.scenarios.length === 0) return 'product: scenarios пуст'
    for (const sc of p.scenarios as Array<Record<string, unknown>>) {
      if (typeof sc.actor !== 'string' || sc.actor.length === 0) return 'scenario.actor пуст'
      if (typeof sc.input !== 'string' || sc.input.length === 0) return 'scenario.input пуст'
      if (!Array.isArray(sc.outcomes) || sc.outcomes.length === 0) return 'scenario.outcomes пуст'
      const kinds = new Set<string>()
      for (const o of sc.outcomes as Array<Record<string, unknown>>) {
        if (typeof o.kind === 'string') kinds.add(o.kind)
      }
      if (!kinds.has('success') || !kinds.has('failure')) {
        return 'scenario требует оба kind: success и failure'
      }
    }
    const declaredFailures = new Set((required.failures as string[] | undefined) ?? [])
    for (const sc of p.scenarios as Array<Record<string, unknown>>) {
      for (const o of sc.outcomes as Array<Record<string, unknown>>) {
        if (o.kind === 'failure') {
          if (typeof o.id !== 'string') return 'failure outcome без id'
          if (!declaredFailures.has(o.id)) return `failure outcome ${o.id} не объявлен в required.failures`
        }
      }
    }
  } else if (s.profile === 'architecture') {
    const comps = Array.isArray(p.components) ? p.components as Array<Record<string, unknown>> : []
    const compIds = new Set(comps.map((c) => c.id as string))
    for (const c of comps) if (typeof c.boundary !== 'string') return 'component.boundary не строка'
    if (!Array.isArray(p.links)) return 'package.links не массив'
    for (const l of p.links as Array<Record<string, unknown>>) {
      if (typeof l.from !== 'string' || !compIds.has(l.from))
        return `link.from не разрешим: ${String(l.from)}`
      if (typeof l.to !== 'string' || !compIds.has(l.to))
        return `link.to не разрешим: ${String(l.to)}`
      if (typeof l.contract !== 'string' || !isValidId(l.contract))
        return `link.contract не ID: ${String(l.contract)}`
    }
    if (!Array.isArray(p.decisions) || p.decisions.length === 0) return 'package.decisions пуст'
    for (const d of p.decisions as Array<Record<string, unknown>>) {
      if (d.state !== 'accepted' && d.state !== 'open')
        return `decision.state не accepted|open: ${String(d.state)}`
      if (typeof d.source !== 'string')
        return `decision.source не строка: ${String(d.source)}`
    }
    if (!Array.isArray(p.failures) || p.failures.length === 0) return 'package.failures пуст'
    for (const f of p.failures as Array<Record<string, unknown>>) {
      if (typeof f.result !== 'string') return 'failure.result не строка'
    }
  }
  return null
}