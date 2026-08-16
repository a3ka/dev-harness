#!/usr/bin/env node
/**
 * Генерация агентов из ЕДИНСТВЕННОГО источника — `roles/*.md`.
 *
 * `--check` требует пустого расхождения: дрейф становится НЕВОЗМОЖНЫМ, а не наказуемым.
 * Правка сгенерированного файла безвредна — она затирается, а оригинал в git.
 *
 * `--into <путь>` кладёт те же роли в ДРУГОЙ проект. Так работа над проектом получает
 * роли разработчика, не заводя их копию: источник здесь, цель производная, `--check`
 * ловит расхождение. Копия правил в проекте стала бы вторым источником истины.
 *
 * Использование:
 *   node scripts/gen-harness.ts                    — записать .omp/agents/
 *   node scripts/gen-harness.ts --check            — сравнить, упасть при расхождении
 *   node scripts/gen-harness.ts --into <путь>      — положить роли в проект
 *   node scripts/gen-harness.ts --into <путь> --check
 *
 * Коды возврата: 0 — совпало либо записано, 1 — расхождение, 2 — нечем проверить.
 */
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { loadRoles, RoleParseError, type Role } from './roles.ts'

const ROOT = join(import.meta.dirname, '..')
const ROLES_DIR = join(ROOT, 'roles')

const args = process.argv.slice(2)
const CHECK = args.includes('--check')
const intoAt = args.indexOf('--into')
const INTO = intoAt >= 0 ? args[intoAt + 1] : undefined

if (intoAt >= 0 && !INTO) {
  console.error('нужен путь: --into <каталог-проекта>')
  process.exit(2)
}
if (!existsSync(ROLES_DIR)) {
  console.error(`NOT_IMPLEMENTED: нет каталога ролей ${ROLES_DIR}`)
  process.exit(2)
}

const banner = (slug: string): string =>
  `<!-- СГЕНЕРИРОВАНО scripts/gen-harness.ts из roles/${slug}.md. Правки будут затёрты. -->`

/** Формат субагента omp. Модель — ССЫЛКОЙ на роль модели, а не идентификатором:
 *  конкретная модель остаётся в одном месте, `.omp/config.yml`, и меняется там же. */
const render = (r: Role): string =>
  [
    '---',
    `name: ${r.slug}`,
    `description: ${r.title}`,
    `tools: [${r.tools.join(', ')}]`,
    `model: ["@${r.modelRole}"]`,
    '---',
    '',
    banner(r.slug),
    '',
    r.body,
    '',
    '## Что обязано остаться после тебя',
    '',
    r.verdict === null
      ? 'Артефакт-вердикт этой роли не предписан.'
      : `Вердикт — файл в \`${r.verdict}\`, закоммиченный на ветку предмета. Вердикт в переписке\n` +
        'не переживает сессию: это измерено дважды, и дважды пропали найденные дефекты.',
    '',
  ].join('\n')

let roles: Role[]
try {
  roles = loadRoles(ROLES_DIR)
} catch (e) {
  if (e instanceof RoleParseError) { console.error(`FAIL ${e.message}`); process.exit(1) }
  throw e
}
if (roles.length === 0) { console.error('NOT_IMPLEMENTED: ролей нет'); process.exit(2) }

const target = join(INTO ?? ROOT, '.omp', 'agents')
const drift: string[] = []
let written = 0

if (!CHECK) mkdirSync(target, { recursive: true })
else if (!existsSync(target)) { console.error(`FAIL цель не существует: ${target}`); process.exit(1) }

for (const r of roles) {
  const path = join(target, `${r.slug}.md`)
  const want = render(r)
  const have = existsSync(path) ? readFileSync(path, 'utf8') : null
  if (CHECK) {
    if (have === null) drift.push(`нет файла: ${r.slug}.md`)
    else if (have !== want) drift.push(`расходится с roles/${r.slug}.md: ${r.slug}.md`)
  } else if (have !== want) {
    writeFileSync(path, want)
    written += 1
  }
}

// Лишний наш агент в цели — тоже дрейф: роль удалили из `roles/`, а агент остался и
// продолжает вызываться. Чужие агенты (без нашего баннера) не наши и не трогаются.
if (existsSync(target)) {
  const ours = new Set(roles.map((r) => `${r.slug}.md`))
  for (const f of readdirSync(target).filter((f) => f.endsWith('.md'))) {
    if (ours.has(f)) continue
    if (readFileSync(join(target, f), 'utf8').includes('СГЕНЕРИРОВАНО scripts/gen-harness.ts')) {
      drift.push(`сгенерирован нами, но роли уже нет: ${f}`)
    }
  }
}

if (CHECK) {
  if (drift.length === 0) { console.log(`харнес соответствует roles/ (${roles.length} ролей)`); process.exit(0) }
  for (const d of drift) console.error(`  FAIL ${d}`)
  console.error(`\nПерегенерируйте: node scripts/gen-harness.ts${INTO ? ` --into ${INTO}` : ''}`)
  process.exit(1)
}
console.log(`сгенерировано: ${roles.length} ролей${INTO ? ` в ${INTO}` : ''}, обновлено файлов: ${written}`)
