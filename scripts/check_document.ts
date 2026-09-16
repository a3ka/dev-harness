#!/usr/bin/env node
/**
 * Приёмка пакета doc-контракта (контракт 027 §Док-пакет).
 *
 *   node scripts/check_document.ts --root <project> --contract <path> --preflight
 *   node scripts/check_document.ts --root <project> --contract <path> --check
 *
 * Коды возврата:
 *   0 — машинная мера выполнена;
 *   1 — именованное нарушение (на stderr — ИМЕНОВАННАЯ причина);
 *   2 — нечем проверить (нет frozen-спеки для этого NNN).
 *
 * --preflight читает draft-критерий: схема + калибровка (не требует Markdown).
 * --check читает наибольшую frozen-версию этого NNN и сверяет пакет: для каждого
 * as-is запускает check (json-pointer/exact-line/probe); для to-be — decision.
 * Probe работает без shell, в изолированной копии проекта; оракул (expected и
 * package.value) снимается В ПАМЯТЬ ДО запуска probe и сравнивается с его
 * структурным результатом; основной проект не модифицируется.
 */
import { readFile } from 'node:fs/promises'
import { join } from 'node:path'

import {
  applyJsonPointer,
  checkCalibration,
  checkEvidenceOwnership,
  checkIdSets,
  checkSectionMarkers,
  deepEqual,
  loadFrozenSpec,
  parseSpecFromMarkdown,
  resolveGitSource,
  runProbeIsolated,
  validatePackageAgainstSpec,
  validateSpecSchema,
} from './doc_contract.ts'

type ParsedArgs = { root: string; contract: string; preflight: boolean; check: boolean }

function parseArgs(argv: string[]): ParsedArgs {
  let root = ''
  let contract = ''
  let preflight = false
  let check = false
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]
    if (a === '--root') { root = argv[++i] ?? ''; continue }
    if (a === '--contract') { contract = argv[++i] ?? ''; continue }
    if (a === '--preflight') { preflight = true; continue }
    if (a === '--check') { check = true; continue }
    if (a === '--help' || a === '-h') { usage(); process.exit(0) }
  }
  if (!root || !contract) { usage(); process.exit(2) }
  if (preflight === check) { usage(); process.exit(2) }
  return { root, contract, preflight, check }
}

function usage(): void {
  process.stderr.write('usage: node scripts/check_document.ts --root <project> --contract <path> --preflight|--check\n')
}

function fail(reason: string): never {
  process.stderr.write(`ОТКАЗ DOC: ${reason}\n`)
  process.exit(1)
}

function skip(reason: string): never {
  process.stderr.write(`NOT_IMPLEMENTED: ${reason}\n`)
  process.exit(2)
}

async function loadWorkingSpec(root: string, contractPath: string): Promise<unknown> {
  const text = await readFile(join(root, contractPath), 'utf-8')
  try {
    return parseSpecFromMarkdown(text)
  } catch (e) {
    fail(`contract: ${(e as Error).message}`)
  }
}

async function loadPackage(root: string, evidencePath: string): Promise<unknown> {
  let text: string
  try { text = await readFile(join(root, evidencePath), 'utf-8') }
  catch (e) { skip(`evidence не читается: ${(e as Error).message}`) }
  try { return JSON.parse(text) }
  catch (e) { fail(`evidence не валидный JSON: ${(e as Error).message}`) }
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2))
  if (args.preflight) {
    const spec = await loadWorkingSpec(args.root, args.contract)
    const schemaErr = validateSpecSchema(spec)
    if (schemaErr) fail(`schema: ${schemaErr}`)
    const calRaw = (spec as Record<string, unknown>).calibration
    if (calRaw && typeof calRaw === 'object' && !Array.isArray(calRaw)) {
      const cal = calRaw as { positive: string; negative: Array<{ evidence: string; violation: string }> }
      const calErr = await checkCalibration(args.root, spec, cal)
      if (calErr) fail(`calibration: ${calErr}`)
    }
    process.exit(0)
  }

  // --check: использует frozen-спеку, не рабочую копию.
  const frozen = loadFrozenSpec(args.root, args.contract)
  if (!frozen) skip(`нет frozen-спеки для ${args.contract}`)
  const schemaErr = validateSpecSchema(frozen.spec)
  if (schemaErr) fail(`schema: ${schemaErr}`)
  const spec = frozen.spec as Record<string, unknown>
  const outputs = spec.outputs as Record<string, string>
  const evidencePath = outputs.evidence
  const markdownPath = outputs.markdown
  const pkg = await loadPackage(args.root, evidencePath)
  const pkgErr = validatePackageAgainstSpec(frozen.spec, pkg)
  if (pkgErr) fail(`package: ${pkgErr}`)
  const idErr = checkIdSets(frozen.spec, pkg)
  if (idErr) fail(`idsets: ${idErr}`)
  const eoErr = checkEvidenceOwnership(frozen.spec, pkg)
  if (eoErr) fail(`evidence-ownership: ${eoErr}`)

  // Консистентность questions: spec декларирует id+blocking+allow_open;
  // package несёт state+decision. Если package.state='open', spec обязан
  // разрешать (blocking=false, allow_open=true).
  const specQuestions = (spec.questions as Array<Record<string, unknown>>) ?? []
  const pkgQuestions = ((pkg as Record<string, unknown>).questions as Array<Record<string, unknown>>) ?? []
  for (const pq of pkgQuestions) {
    const sq = specQuestions.find((x) => x.id === pq.id)
    if (!sq) fail(`package.questions[${pq.id}]: не объявлен в spec`)
    if (pq.state === 'open') {
      if (sq.blocking !== false || sq.allow_open !== true)
        fail(`questions[${pq.id}]: package.state=open, но spec требует blocking=true или allow_open=false`)
    } else if (pq.state === 'resolved') {
      if (typeof pq.decision !== 'string' || !pq.decision)
        fail(`questions[${pq.id}]: package.state=resolved требует decision`)
      const reqDecs = new Set(((spec.required as Record<string, unknown>)?.decisions as string[] | undefined) ?? [])
      if (!reqDecs.has(pq.decision))
        fail(`questions[${pq.id}].decision ${pq.decision} не в required.decisions`)
    }
  }

  // Section markers.
  const mdText = await readFile(join(args.root, markdownPath), 'utf-8')
  const required = (spec.required as Record<string, unknown>) ?? {}
  const sectionIds = Array.isArray(required.sections) ? (required.sections as string[]) : []
  const smErr = checkSectionMarkers(mdText, sectionIds)
  if (smErr) fail(`section-marker: ${smErr}`)
  // Проверяем ассерты.
  const assertions = (spec.assertions as Array<Record<string, unknown>>) ?? []
  const pkgAssertions = ((pkg as Record<string, unknown>).assertions as Array<Record<string, unknown>>) ?? []
  const sources = (spec.sources as Array<Record<string, unknown>>) ?? []
  const sourceMap = new Map<string, Record<string, unknown>>()
  for (const s of sources) sourceMap.set(s.id as string, s)
  for (const a of assertions) {
    const check = a.check as Record<string, unknown>
    if (a.status === 'to-be') {
      const decisionId = a.decision as string
      const reqDecisions = new Set((required.decisions as string[] | undefined) ?? [])
      const pkgDecisions = ((pkg as Record<string, unknown>).decisions as Array<Record<string, unknown>>) ?? []
      if (!reqDecisions.has(decisionId))
        fail(`assertion[${a.id}].decision ${decisionId} не в required.decisions`)
      const d = pkgDecisions.find((x) => x.id === decisionId)
      if (!d) fail(`assertion[${a.id}].decision ${decisionId} отсутствует в package.decisions`)
      if (d.state !== 'accepted')
        fail(`assertion[${a.id}].decision ${decisionId} не accepted (state=${String(d.state)})`)
      // package.assertions[i] должен быть to-be с тем же decision.
      const pa = pkgAssertions.find((x) => x.id === a.id)
      if (!pa) fail(`assertion[${a.id}]: нет в package.assertions`)
      if (pa.status !== 'to-be')
        fail(`assertion[${a.id}]: package.status=${String(pa.status)} ≠ spec.status=to-be`)
      if (pa.decision !== decisionId)
        fail(`assertion[${a.id}]: package.decision=${String(pa.decision)} ≠ spec.decision=${decisionId}`)
      continue
    }
    const pa = pkgAssertions.find((x) => x.id === a.id)
    if (!pa) fail(`assertion[${a.id}]: нет в package.assertions`)
    if (pa.value === undefined) fail(`assertion[${a.id}]: package.value отсутствует`)
    if (pa.status !== 'as-is')
      fail(`assertion[${a.id}]: package.status=${String(pa.status)} ≠ spec.status=as-is`)
    if (pa.kind !== a.kind)
      fail(`assertion[${a.id}]: package.kind=${String(pa.kind)} ≠ spec.kind=${String(a.kind)}`)
    if (check.type === 'json-pointer') {
      const sourceId = check.source as string
      const src = sourceMap.get(sourceId)
      if (!src) fail(`assertion[${a.id}].check.source ${sourceId} не объявлен`)
      if (src.kind === 'external')
        fail(`assertion[${a.id}]: внешний источник не подходит для механического as-is`)
      const resolved = await resolveGitSource(args.root, src as {
        path: string; commit: string; blob: string; freshness: string
      })
      if (resolved.mode === 'drift')
        fail(`assertion[${a.id}]: current-источник ${sourceId} дрейфует относительно объявленного blob`)
      let parsed: unknown
      try { parsed = JSON.parse(resolved.bytes.toString('utf-8')) }
      catch (e) { fail(`assertion[${a.id}]: источник не JSON: ${(e as Error).message}`) }
      let selected: unknown
      try { selected = applyJsonPointer(parsed, check.pointer as string) }
      catch (e) { fail(`assertion[${a.id}]: pointer не разрешается: ${(e as Error).message}`) }
      if (!deepEqual(selected, check.expected))
        fail(`assertion[${a.id}]: значение источника ${JSON.stringify(selected)} ≠ expected ${JSON.stringify(check.expected)}`)
      if (!deepEqual(selected, pa.value))
        fail(`assertion[${a.id}]: значение источника ${JSON.stringify(selected)} ≠ package.value ${JSON.stringify(pa.value)}`)
    } else if (check.type === 'exact-line') {
      const sourceId = check.source as string
      const src = sourceMap.get(sourceId)
      if (!src) fail(`assertion[${a.id}].check.source ${sourceId} не объявлен`)
      if (src.kind === 'external')
        fail(`assertion[${a.id}]: внешний источник не подходит для механического as-is`)
      const resolved = await resolveGitSource(args.root, src as {
        path: string; commit: string; blob: string; freshness: string
      })
      if (resolved.mode === 'drift')
        fail(`assertion[${a.id}]: current-источник ${sourceId} дрейфует относительно объявленного blob`)
      const text = resolved.bytes.toString('utf-8')
      const lines = text.split(/\r?\n/)
      if (!lines.includes(check.expected as string))
        fail(`assertion[${a.id}]: expected-строка не найдена в ${sourceId}`)
    } else if (check.type === 'probe') {
      const argv = check.argv as string[]
      const result = await runProbeIsolated(args.root, argv)
      if (result.rc !== 0)
        skip(`probe ${argv.join(' ')} вернул rc=${result.rc}: ${result.stderr.trim() || 'нет stderr'}`)
      let parsed: unknown
      try { parsed = JSON.parse(result.stdout) }
      catch (e) { skip(`probe stdout не JSON: ${(e as Error).message}`) }
      let selected: unknown
      try { selected = applyJsonPointer(parsed, check.pointer as string) }
      catch (e) { skip(`probe pointer не разрешается: ${(e as Error).message}`) }
      if (!deepEqual(selected, check.expected))
        fail(`assertion[${a.id}]: probe ${JSON.stringify(selected)} ≠ expected ${JSON.stringify(check.expected)}`)
      if (!deepEqual(selected, pa.value))
        fail(`assertion[${a.id}]: probe ${JSON.stringify(selected)} ≠ package.value ${JSON.stringify(pa.value)}`)
    }
  }
  process.exit(0)
}

main().catch((e: unknown) => {
  process.stderr.write(`ОТКАЗ DOC: ${(e as Error).message}\n`)
  process.exit(1)
})