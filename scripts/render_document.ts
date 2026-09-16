#!/usr/bin/env node
/**
 * Производные формальные фрагменты (контракт 027 §Док-пакет).
 *
 *   node scripts/render_document.ts --root <project> --contract <path>
 *   node scripts/render_document.ts --root <project> --contract <path> --check
 *
 * Генерирует единственную пару самостоятельных строк
 *   <!-- doc:formal:start --> ... <!-- doc:formal:end -->
 * между границами в outputs.markdown; всё остальное (свободная проза и section-
 * маркеры) сохраняется. --check ничего не пишет: генерирует ожидаемое
 * содержимое и сверяет с тем, что лежит в файле.
 *
 * Коды возврата: 0 — ок, 1 — именованное нарушение, 2 — нечем проверить.
 */
import { readFile, writeFile } from 'node:fs/promises'
import { join } from 'node:path'

import {
  generateFormalRegion,
  parseSpecFromMarkdown,
  replaceFormalRegion,
  splitFormalRegion,
} from './doc_contract.ts'

type Args = { root: string; contract: string; check: boolean }

function parseArgs(argv: string[]): Args {
  let root = ''
  let contract = ''
  let check = false
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]
    if (a === '--root') { root = argv[++i] ?? ''; continue }
    if (a === '--contract') { contract = argv[++i] ?? ''; continue }
    if (a === '--check') { check = true; continue }
  }
  if (!root || !contract) { usage(); process.exit(2) }
  return { root, contract, check }
}

function usage(): void {
  process.stderr.write('usage: node scripts/render_document.ts --root <project> --contract <path> [--check]\n')
}

function fail(reason: string): never {
  process.stderr.write(`ОТКАЗ DOC-render: ${reason}\n`)
  process.exit(1)
}

function skip(reason: string): never {
  process.stderr.write(`NOT_IMPLEMENTED: ${reason}\n`)
  process.exit(2)
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2))
  const contractPath = join(args.root, args.contract)
  const contractText = await readFile(contractPath, 'utf-8')
  let spec: unknown
  try { spec = parseSpecFromMarkdown(contractText) }
  catch (e) { fail(`contract: ${(e as Error).message}`) }
  const outputs = (spec as Record<string, unknown>).outputs as Record<string, string>
  if (!outputs) fail('contract.outputs отсутствует')
  const mdPath = join(args.root, outputs.markdown)
  const evidencePath = join(args.root, outputs.evidence)
  let pkg: unknown
  try {
    const text = await readFile(evidencePath, 'utf-8')
    pkg = JSON.parse(text)
  } catch (e) { skip(`evidence не читается: ${(e as Error).message}`) }
  const newBody = generateFormalRegion(spec, pkg)
  const mdText = await readFile(mdPath, 'utf-8')
  const parts = splitFormalRegion(mdText)
  if (!parts) fail('формальные границы отсутствуют или дублированы')
  if (args.check) {
    if (parts.body.trim() !== newBody.trim())
      fail('формальный фрагмент не соответствует ожидаемому (ручное искажение или иной источник)')
    process.exit(0)
  }
  const newMd = replaceFormalRegion(mdText, newBody)
  if (newMd == null) fail('замена формального фрагмента не состоялась')
  await writeFile(mdPath, newMd, 'utf-8')
  process.exit(0)
}

main().catch((e: unknown) => {
  process.stderr.write(`ОТКАЗ DOC-render: ${(e as Error).message}\n`)
  process.exit(1)
})