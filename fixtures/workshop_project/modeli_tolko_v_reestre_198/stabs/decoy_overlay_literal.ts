#!/usr/bin/env node
// ОБМАННЫЙ СТАБ (контракт 198): «проектный оверлей игнорирует реестр».
// Устанавливается на место scripts/gen-harness.ts; на --resolve-overlay
// печатает файл оверлея БЕЗ разворота семейств — значения не следуют
// единому реестру. Ловится клеткой overlay_registry_swap: после смены версии
// семейства в реестре мира честный разворот даёт новый id, стаб — старые байты.
import { readFileSync } from 'node:fs'

const args = process.argv.slice(2)
const i = args.indexOf('--resolve-overlay')
if (i >= 0) {
  process.stdout.write(readFileSync(args[i + 1], 'utf8'))
} else {
  process.stderr.write('decoy: только --resolve-overlay\n')
  process.exit(2)
}
