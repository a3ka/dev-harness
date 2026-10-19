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
 * `.omp/agents/*.md`, секции `modelRoles` и `retry.fallbackChains` в `.omp/config.yml` —
 * генерируются и сверяются). Таблица ниже ВЫВОДИТСЯ из его секции `roles`; основания (why) — там же.
 *
 * СЕМЕЙСТВА (`models`, слово владельца 2026-09-26): «семейство → последняя версия», например
 * `"<семейство>": "<провайдер>/<модель>"`. Тиры и оверлеи ссылаются на семейство `@opus`, и смена
 * версии — ОДНА строка в `models`. Литеральный id по-прежнему законен (фикстуры, разовые пробы). */
export interface TierSpec {
  readonly model: string
  readonly fallback: string | null
  /** true — фолбек ещё и ЖИВАЯ цепочка подмены omp (`retry.fallbackChains`); иначе подмена ручная (Н-50). */
  readonly autoFallback?: boolean
  readonly why: string
}
export interface AgentModels {
  readonly models?: Record<string, string>
  readonly tiers: Record<string, TierSpec>
  readonly roles: Record<string, string>
  /** ЕДИНСТВЕННОЕ место правил «какой класс работы — какой роли (и значит модели)».
   * Решение владельца 2026-10-18 (docs/owner/2026-10-18-pravila-modelei.md): при расхождении
   * с документами действует этот файл. Грамматика — закрытый перечень инварианта 1
   * контракта 998; разбор и сверка живут здесь, а не в gen-harness и не в bash — копия
   * разошлась бы молча. Поле опционально: фикстуры анти-плацебо собирают частичные
   * деревья без него, и validateRouting при отсутствии секции не судит. */
  readonly routing?: Routing
}

/** Routing rules (контракт 998, инвариант 1). Закрытая грамматика; `_`-поля —
 *  комментарии (один язык для объекта и правила). */
export interface RoutingRule {
  readonly class: string
  readonly role?: string
  readonly tier?: string
  readonly constraint?: string
  readonly until?: string
  readonly [k: string]: unknown
}

export interface Routing {
  readonly rules: readonly RoutingRule[]
  readonly conditional?: string
  readonly emergency?: string
  readonly [k: string]: unknown
}

/** Шаг диагностики — именованное сообщение о нарушении. Поле `path` содержит
 *  литеральный ключ в config/agent_models.json (например, `routing.rules[3]`);
 *  поле `message` — текст, подходящий и для --check (CI), и для --prompt (сессия). */
export interface RoutingProblem {
  readonly path: string
  readonly message: string
}

/** Закрытое перечень допустимых ключей объекта routing. */
const ALLOWED_ROUTING_KEYS: Record<string, true> = {
  rules: true,
  conditional: true,
  emergency: true,
}

/** Закрытое перечень допустимых ключей правила. */
const ALLOWED_RULE_KEYS: Record<string, true> = {
  class: true,
  role: true,
  tier: true,
  constraint: true,
  until: true,
}

const isCommentKey = (k: string): boolean => k.startsWith('_')
const isNonEmptyString = (v: unknown): v is string => typeof v === 'string' && v.trim().length > 0

export interface RoutingValidateContext {
  /** Каталог ролей; если задан — при наличии цели `role` в правиле проверяется
   *  существование файла `roles/<role>.md` (полный режим, рядом с двухсторонней
   *  сверкой `loadRoles`). В вырожденном режиме (нет каталога) проверка опускается. */
  readonly rolesDir?: string
}

/** Валидация грамматики routing + сверка ссылок role/tier с roles-таблицей и tiers,
 *  и (если rolesDir задан) с файлами roles/<role>.md. Контракт 998, инварианты 1–2:
 *  — config существует ⇒ routing существует;
 *  — весь класс закрытого перечня ветвей отвергается с указанием routing,
 *    индекса правила rules[N] и самого нарушителя;
 *  — возвращает [] при отсутствии config/agent_models.json (вырожденный режим,
 *    прежняя толерантность сохраняется — тело валидации пропускается). */
export function validateRouting(am: AgentModels, ctx: RoutingValidateContext = {}): RoutingProblem[] {
  const out: RoutingProblem[] = []
  const rawRt = (am as unknown as { routing?: unknown }).routing
  if (rawRt === undefined) return out
  if (rawRt === null || typeof rawRt !== 'object' || Array.isArray(rawRt)) {
    out.push({ path: 'routing', message: 'routing: не объект' })
    return out
  }
  const rt = rawRt as Record<string, unknown>
  for (const k of Object.keys(rt)) {
    if (ALLOWED_ROUTING_KEYS[k] === true || isCommentKey(k)) continue
    out.push({ path: 'routing', message: `routing: неизвестный ключ «${k}»` })
  }
  const rules = rt.rules
  if (!Array.isArray(rules) || rules.length === 0) {
    out.push({ path: 'routing.rules', message: 'routing.rules: отсутствует или пуст' })
  } else {
    for (let i = 0; i < rules.length; i++) {
      const r = rules[i]
      if (r === null || typeof r !== 'object' || Array.isArray(r)) {
        out.push({ path: `routing.rules[${i}]`, message: `routing.rules[${i}]: не объект` })
        continue
      }
      const rule = r as Record<string, unknown>
      for (const k of Object.keys(rule)) {
        if (ALLOWED_RULE_KEYS[k] === true || isCommentKey(k)) continue
        out.push({ path: `routing.rules[${i}]`, message: `routing.rules[${i}]: неизвестный ключ «${k}»` })
      }
      if (!isNonEmptyString(rule.class)) {
        out.push({ path: `routing.rules[${i}].class`, message: `routing.rules[${i}]: class не непустая строка` })
      }
      const targets: Array<'role' | 'tier'> = []
      if ('role' in rule) targets.push('role')
      if ('tier' in rule) targets.push('tier')
      if (targets.length !== 1) {
        out.push({
          path: `routing.rules[${i}]`,
          message: `routing.rules[${i}]: ровно один из role|tier, получено ${targets.length}`,
        })
      } else if (!isNonEmptyString(rule[targets[0]])) {
        out.push({
          path: `routing.rules[${i}].${targets[0]}`,
          message: `routing.rules[${i}].${targets[0]}: не непустая строка`,
        })
      }
      for (const f of ['constraint', 'until'] as const) {
        if (f in rule && typeof rule[f] !== 'string') {
          out.push({ path: `routing.rules[${i}].${f}`, message: `routing.rules[${i}].${f}: не строка` })
        }
      }
    }
    // Сверка ссылок role/tier (только для правил с правильной грамматикой)
    for (let i = 0; i < rules.length; i++) {
      const r = rules[i]
      if (r === null || typeof r !== 'object' || Array.isArray(r)) continue
      const rule = r as Record<string, unknown>
      if (isNonEmptyString(rule.role)) {
        const role = (rule.role as string).trim()
        if (!(role in (am.roles ?? {}))) {
          out.push({
            path: `routing.rules[${i}].role`,
            message: `routing.rules[${i}]: роль «${role}» отсутствует в roles-таблице config/agent_models.json`,
          })
        }
        if (ctx.rolesDir && !existsSync(join(ctx.rolesDir, `${role}.md`))) {
          out.push({
            path: `routing.rules[${i}].role`,
            message: `routing.rules[${i}]: роли «${role}» нет файла roles/${role}.md`,
          })
        }
      }
      if (isNonEmptyString(rule.tier)) {
        const t = (rule.tier as string).trim()
        if (!(t in (am.tiers ?? {}))) {
          out.push({
            path: `routing.rules[${i}].tier`,
            message: `routing.rules[${i}]: тира «${t}» нет в tiers`,
          })
        }
      }
    }
  }
  for (const f of ['conditional', 'emergency'] as const) {
    if (f in rt && typeof rt[f] !== 'string') {
      out.push({ path: `routing.${f}`, message: `routing.${f}: не строка` })
    }
  }
  return out
}

/** Барьер проводки routing (контракт 998, инварианты 1–2): единая точка выхода rc.
 *  Вызывается из обеих точек входа генератора (--check и --prompt) — разбор и сверка
 *  уже здесь, копия разнеслась бы по двум точкам. rolesDir передаётся, когда мы
 *  хотим полную проверку (наличие файла роли); в вырожденных песочницах — без него. */
export function checkRouting(rolesDir?: string): { ok: true } | { ok: false; problems: RoutingProblem[] } {
  const am = agentModels()
  if (am === null) return { ok: true }  // вырожденный режим — конфига нет
  const problems = validateRouting(am, rolesDir ? { rolesDir } : {})
  return problems.length === 0 ? { ok: true } : { ok: false, problems }
}

/** Барьер routing строгий: когда config существует, секция routing обязательна.
 *  Используется в ОБЕИХ точках входа (--check и --prompt) — отсутствие секции
 *  при наличии config есть отказ rc 1 с именованием routing (контракт 998,
 *  инвариант 1: «конфиг существует ⇒ routing существует»).
 *  В вырожденном режиме (конфига нет) — pass, прежняя толерантность. */
export function checkRoutingStrict(rolesDir?: string): { ok: true } | { ok: false; problems: RoutingProblem[] } {
  const am = agentModels()
  if (am === null) return { ok: true }  // вырожденный режим — конфига нет
  const probs: RoutingProblem[] = []
  if ((am as unknown as { routing?: unknown }).routing === undefined) {
    probs.push({ path: 'routing', message: 'routing: секция отсутствует' })
  } else {
    const ctx: RoutingValidateContext = rolesDir ? { rolesDir } : {}
    probs.push(...validateRouting(am, ctx))
  }
  return probs.length === 0 ? { ok: true } : { ok: false, problems: probs }
}

export class RoleParseError extends Error {}

/** `@семейство` → id из секции `models`; литерал — как есть. ЕДИНСТВЕННЫЙ разбор ссылки:
 *  генератор и лаунчер (через `gen-harness.ts --resolve-overlay`) зовут его, а не копию. */
export function resolveModelRef(am: AgentModels, ref: string, where: string): string {
  if (!ref.startsWith('@')) return ref
  const name = ref.slice(1)
  const id = am.models?.[name]
  if (id === undefined) {
    const known = Object.keys(am.models ?? {}).map((k) => `@${k}`).join(', ') || 'секции models нет'
    throw new RoleParseError(`неизвестное семейство «${ref}» в ${where}; объявлены: ${known}`)
  }
  return id
}

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
  for (const [t, spec] of Object.entries(am.tiers)) {
    resolveModelRef(am, spec.model, `tiers.${t}.model`)
    if (spec.fallback !== null) resolveModelRef(am, spec.fallback, `tiers.${t}.fallback`)
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
