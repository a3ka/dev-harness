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
 *
 * НЕ БАРЬЕР: это разбор, а не гейт. Ошибку он сообщает исключением `RoleParseError`, и
 * вердикт кодом возврата выносит тот, кто его импортировал. Классификация объявлена явно,
 * потому что `scripts/verify_antiplacebo.sh` требует фикстуру от каждого барьера и не
 * умеет догадываться: файл без объявленной роли — отказ.
 */
import { existsSync, readFileSync, readdirSync } from 'node:fs'
import { join } from 'node:path'

export interface Role {
  readonly slug: string
  readonly title: string
  /** Роль модели omp: `@slow`, `@advisor`, `@plan`. Конкретный id — в `.omp/config.yml`.
   *  null — ВЫРОЖДЕННЫЙ режим: `config/agent_models.json` в этом дереве нет, тир
   *  неизвестен, рендер опускает строку `model`. */
  readonly modelRole: string | null
  readonly tools: readonly string[]
  /** Куда роль ОБЯЗАНА положить артефакт, либо null. Вердикт в переписке не переживает сессию. */
  readonly verdict: string | null
  readonly body: string
}
/** Роль → роль модели omp. Единственный источник назначений — `config/agent_models.json`
 * (решение владельца 2026-09-12: правка моделей = правка одного файла; производные —
 * `.omp/agents/*.md` и секция `modelRoles` в `.omp/config.yml` — генерируются и
 * сверяются). Таблица ниже ВЫВОДИТСЯ из его секции `roles`; основания (why) — там же. */
export interface TierSpec { readonly model: string; readonly fallback: string | null; readonly why: string }
export interface AgentModels {
  readonly tiers: Record<string, TierSpec>
  readonly roles: Record<string, string>
}

export class RoleParseError extends Error {}

/** Таблица моделей — ЛЕНИВО и терпимо к отсутствию файла. Фикстуры анти-плацебо собирают
 * ЧАСТИЧНЫЕ деревья (ровно то, что судит их предмет), и чтение на уровне импорта валило
 * генератор ENOENT-ом внутри ЗЕЛЁНОЙ фазы чужого барьера (overlay/gen-harness, a9ea528,
 * замер 2026-09-13). Отсутствие файла — ВЫРОЖДЕННЫЙ режим (null): сверка «роль↔таблица»
 * и «тир∈tiers» не исполняется вовсе, роль допускается без тира — назначение моделей в
 * этом дереве не заявлено, и суждение о нём невозможно. */
let modelsCache: AgentModels | null | undefined
export function agentModels(): AgentModels | null {
  if (modelsCache !== undefined) return modelsCache
  const p = join(import.meta.dirname, '..', 'config', 'agent_models.json')
  if (!existsSync(p)) { modelsCache = null; return modelsCache }
  const am = JSON.parse(readFileSync(p, 'utf8')) as AgentModels
  for (const t of Object.values(am.roles)) {
    if (!am.tiers[t]) throw new RoleParseError(`тир «${t}» присвоен роли, но в config/agent_models.json его нет`)
  }
  modelsCache = am
  return modelsCache
}

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
  const modelRole = agentModels()?.roles[slug] ?? null
  if (agentModels() !== null && modelRole === null) {
    throw new RoleParseError(`${file}: роль «${slug}» отсутствует в таблице ролей моделей`)
  }
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
  // Исполняется только в полном режиме — без таблицы сверять не с чем.
  for (const slug of Object.keys(agentModels()?.roles ?? {})) {
    if (!roles.some((r) => r.slug === slug)) {
      throw new RoleParseError(`таблица ролей моделей называет «${slug}», но файла roles/${slug}.md нет`)
    }
  }
  return roles
}
