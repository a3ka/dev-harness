/**
 * Разбор `roles/*.md` — ЕДИНСТВЕННАЯ реализация.
 *
 * Копии не будет: на соседнем проекте два разбора одного формата дважды дали молчаливый
 * дефект. Здесь разбор живёт в одном модуле, а генератор и лаунчер его импортируют.
 *
 * Роль модели задаётся ТАБЛИЦЕЙ по имени роли, а не выведенным «тиром». Ролей три, у
 * каждой своя роль модели, и абстракция над тремя пунктами скрыла бы ровно то, что здесь
 * важно: кто на каком семействе. Таблица сверяется в обе стороны — роль без записи и
 * запись без роли одинаково валят генерацию.
 */
import { readFileSync, readdirSync } from 'node:fs'
import { join } from 'node:path'

export interface Role {
  readonly slug: string
  readonly title: string
  /** Роль модели omp: `@slow`, `@advisor`, `@plan`. Конкретный id — в `.omp/config.yml`. */
  readonly modelRole: string
  readonly tools: readonly string[]
  /** Куда роль ОБЯЗАНА положить артефакт, либо null. Вердикт в переписке не переживает сессию. */
  readonly verdict: string | null
  readonly body: string
}

/** Роль → роль модели omp. Основание каждой строки — в `AGENTS.md`. */
const MODEL_ROLE: Record<string, string> = {
  architect: 'slow',    // автор конструкции
  adversary: 'advisor', // судья, ДРУГОЕ семейство, чем у автора
  arbiter: 'plan',      // разрешает тупик; 1M контекста под предмет и все вердикты
}

export class RoleParseError extends Error {}

const field = (fm: string, name: string): string | null => {
  const m = new RegExp(`^${name}:\\s*(.+)$`, 'm').exec(fm)
  return m?.[1]?.trim() ?? null
}

const list = (raw: string | null): string[] =>
  raw === null ? [] : raw.replace(/^\[|\]$/g, '').split(',').map((s) => s.trim().replace(/^["']|["']$/g, '')).filter(Boolean)

export function parseRole(dir: string, file: string): Role | null {
  if (file.startsWith('_')) return null
  const raw = readFileSync(join(dir, file), 'utf8')
  const m = /^---\n([\s\S]*?)\n---\n([\s\S]*)$/.exec(raw)
  if (!m) throw new RoleParseError(`${file}: нет frontmatter — роль без объявленного инвентаря неотличима от заметки`)
  const [, fm, body] = m as unknown as [string, string, string]
  const slug = field(fm, 'role')
  if (!slug) throw new RoleParseError(`${file}: не объявлено поле role`)
  if (slug !== file.replace(/\.md$/, '')) {
    throw new RoleParseError(`${file}: поле role «${slug}» не совпадает с именем файла — два имени одной роли разойдутся`)
  }
  const modelRole = MODEL_ROLE[slug]
  if (!modelRole) throw new RoleParseError(`${file}: роль «${slug}» отсутствует в таблице ролей моделей`)
  const tools = list(field(fm, 'tools'))
  if (tools.length === 0) throw new RoleParseError(`${file}: пустой инвентарь — роль обязана объявить, чем работает`)
  const title = /^#\s+(.+)$/m.exec(body)?.[1]?.trim() ?? slug
  const v = field(fm, 'verdict')
  return { slug, title, modelRole, tools, verdict: v === null || v === 'null' ? null : v, body: body.trim() }
}

export function loadRoles(dir: string): Role[] {
  const roles = readdirSync(dir)
    .filter((f) => f.endsWith('.md'))
    .map((f) => parseRole(dir, f))
    .filter((r): r is Role => r !== null)
    .sort((a, b) => a.slug.localeCompare(b.slug))
  // Обратная сторона сверки: запись в таблице без файла роли означает либо удалённую
  // роль, либо опечатку в имени. И то и другое тихо оставило бы модель без потребителя.
  for (const slug of Object.keys(MODEL_ROLE)) {
    if (!roles.some((r) => r.slug === slug)) {
      throw new RoleParseError(`таблица ролей моделей называет «${slug}», но файла roles/${slug}.md нет`)
    }
  }
  return roles
}
