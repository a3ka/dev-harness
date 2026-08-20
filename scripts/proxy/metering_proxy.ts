#!/usr/bin/env node
/**
 * Прокси учёта трафика моделей.
 *
 * Реализует ЗАМОРОЖЕННЫЙ контракт 005 (`contracts/005-avtonomija-proksi.md`,
 * тег `frozen/contracts/005/1`). Контракт неизменен; эта реализация — лишь его
 * воплощение.
 *
 * ── УСТАНОВЛЕННЫЕ РЕШЕНИЯ (не обсуждаются, воспроизведены дословно) ─────────────
 *
 * 1. ТОЛЬКО `node:` builtins. Никаких внешних пакетов и никакого запуска
 *    внешних программ. Проверяется ветвями (к1) и (к2) барьера.
 *
 * 2. КАРТА ТОКЕН→РОЛЬ ЧИТАЕТСЯ ИЗ `secrets_env` НА КАЖДОМ запросе. Кэш на старте
 *    ЗАПРЕЩЁН. Ротация токена обязана работать в одном живом процессе без
 *    перезапуска (ветвь (и)).
 *
 * 3. `periodAt(ts)` ВЫЗЫВАЕТСЯ НА КАЖДОМ запросе. Кэш на старте ЗАПРЕЩЁН.
 *    Переход UTC-месяца обязан работать в одном живом процессе без перезапуска
 *    (ветвь (л), инъекция времени через `now_file`).
 *
 * 4. ЦЕНА — ПО ПАРЕ provider+model. ПОТОЛОК — ПО provider. Две оси.
 *    Прокси, ищущий цену или потолок только по model, валится расхождением сумм
 *    (ветвь (л), оси тарифа).
 *
 * 5. ДЕНЬГИ — `BigInt` ЦЕЛЫМИ микро-USD. `usd` в журнале — СТРОКА десятичного
 *    целого. `JSON.stringify(BigInt)` бросает — обходим явной сериализацией.
 *
 * 6. ОКРУГЛЕНИЕ В ЦЕНЕ — ВВЕРХ, целочисленно на BigInt:
 *    `ceil((tokens_in*in + tokens_out*out) / 1_000_000)` через
 *    `(n + d - 1n) / d`. `Math.ceil` от числа теряет точность — ЗАПРЕЩЁН.
 *
 * 7. PASSTHROUGH ДОСЛОВНЫЙ В ОБЕ СТОРОНЫ. Клиент → upstream: метод, путь,
 *    тело байт-в-байт, content-type, x-request-id. upstream → клиент: статус,
 *    тело байт-в-байт, content-type. Прочие заголовки в минимум НЕ входят.
 *
 * 8. ТЕЛО В GET НЕ ТЕРЯЕТСЯ. HTTP разрешает тело в GET, и контракт требует
 *    его доносить (ветвь (в2)). Стаб POST-only ретранслятора краснеет именно
 *    на GET-входе.
 *
 * 9. ОТКАЗЫ (тело JSON): 401 без строки, 503 без строки, 402 со строкой
 *    (usd=0, полная схема), 502 со строкой (tokens/usd=0, полная схема).
 *
 * 10. ЖУРНАЛ `data/metering/calls.jsonl` — append-only, РОВНО 11 полей:
 *     `ts, role, provider, model, path, tokens_in, tokens_out, usd,
 *     latency_ms, status, request_id`. Маркер append-only
 *     `.appendonly.json` = `{bytes, sha256}` обновляется при каждой записи.
 *     `--verify-appendonly` сверяет: префикс не изменился, размер только вырос.
 *
 * 11. БЮДЖЕТ `data/metering/budget.json` — ПРОИЗВОДЕН от журнала. Обновляется
 *     инкрементально при каждой записи; `--rebuild-budget` пересобирает из
 *     журнала и ОБЯЗАН совпасть с текущим значением (код 0 при совпадении,
 *     код 1 при расхождении).
 *
 * ── КОДЫ ВОЗВРАТА ────────────────────────────────────────────────────────────
 *
 *   0 — успех (включая --selftest, --verify-appendonly на согласованном
 *       состоянии, --rebuild-budget при совпадении свёртки);
 *   1 — ошибка выполнения / расхождение состояния / внутренний отказ;
 *   2 — NOT_IMPLEMENTED / отсутствует обязательный аргумент.
 *
 *   Скрипт НЕ печатает PASS. Результат — код возврата. На зелёном — тишина
 *   либо `selftest OK` в stderr (диагностика, не отчёт о тесте).
 */

import * as http from 'node:http'
import * as https from 'node:https'
import * as fs from 'node:fs'
import * as path from 'node:path'
import * as crypto from 'node:crypto'

// ════════════════════════════════════════════════════════════════════════════
// Типы
// ════════════════════════════════════════════════════════════════════════════

interface PriceRow {
  /**
   * per_m_tokens.in/out — ЦЕЛЫЕ микро-USD за 1M токенов. BigInt ВНУТРИ;
   * в JSON-конфиге поле принимает `number | string`, но number > 2^53 — отказ
   * (IEEE-754 потеряет единицы до арифметики). Молчаливое округление — тот
   * же класс, что молчаливое зелёное.
   */
  per_m_tokens: { in: bigint; out: bigint }
}

interface Ceiling {
  /**
   * Потолок в ЦЕЛЫХ микро-USD за UTC-месяц. В JSON-конфиге поле принимает
   * `number | string`, но number > 2^53 — отказ по той же причине.
   */
  usd_per_month: bigint
}

interface Config {
  port: number
  healthz_window_sec: number
  secrets_env: string
  data_dir: string
  upstream: Record<string, string>
  prices: Record<string, Record<string, PriceRow>>
  ceilings: Record<string, Ceiling>
  /** ИНЪЕКЦИЯ ВРЕМЕНИ: если путь задан, на КАЖДОМ запросе читается epoch-ms из файла. */
  now_file: string | null
}

/** 2^53 — порог точного целого в IEEE-754 number. */
const MAX_SAFE_BIG = 9007199254740992n

/**
 * Строго-десятичный парс строки в BigInt. Без знака, без точки, без e.
 * `parseInt("1e9", 10)` даёт 1 (молчаливая потеря), `BigInt("1e9")` бросает —
 * но обе формы бесполезны: для int64 нужна ТОЧНАЯ десятичная запись.
 */
function parseDecimalBig(text: string, fieldName: string): bigint {
  if (!/^[0-9]+$/.test(text)) {
    throw new Error(
      `${fieldName}: строка должна быть десятичным целым без знака и экспоненты; фактически: ${JSON.stringify(text)}`,
    )
  }
  try {
    return BigInt(text)
  } catch (e) {
    throw new Error(
      `${fieldName}: не парсится в BigInt (${(e as Error).message}); фактически: ${JSON.stringify(text)}`,
    )
  }
}

/**
 * Тариф/потолок: голое JSON-число > 2^53 — ОТКАЗ (не молчаливый ноль,
 * не молчаливое округление — IEEE-754 потерял единицы ещё ДО BigInt).
 * Строка — точное `BigInt(-value)` без прохода через `Number`.
 * `null`/прочее — отказ с названной причиной.
 */
function parseMicroBig(value: unknown, fieldName: string): bigint {
  if (typeof value === 'number') {
    if (!Number.isSafeInteger(value)) {
      throw new Error(
        `${fieldName}: голое JSON-число выше безопасного целого (>2^53); передавайте СТРОКОЙ. Фактически: ${value}`,
      )
    }
    return BigInt(value)
  }
  if (typeof value === 'string') {
    return parseDecimalBig(value, fieldName)
  }
  throw new Error(
    `${fieldName}: ожидалось число или строка; фактически: ${typeof value} (${JSON.stringify(value)})`,
  )
}

/**
 * Токен usage: то же, что `parseMicroBig`, но потолок по num ≤ 2^53-1, потому
 * что `tokens_in`/`tokens_out` в журнале пишутся JSON-ЧИСЛАМИ (требование
 * параллельных ветвей барьера: они сверяют как number, а не string).
 * > 2^53 — отказ с названной причиной, а не молчаливое усечение.
 */
function parseTokensInt(value: unknown, fieldName: string): number {
  let big: bigint
  if (typeof value === 'number') {
    if (!Number.isFinite(value)) {
      throw new Error(`${fieldName}: не-конечное число; фактически: ${value}`)
    }
    if (!Number.isSafeInteger(value)) {
      throw new Error(
        `${fieldName}: голое JSON-число выше безопасного целого (>2^53); передавайте СТРОКОЙ. Фактически: ${value}`,
      )
    }
    big = BigInt(value)
  } else if (typeof value === 'string') {
    big = parseDecimalBig(value, fieldName)
  } else {
    throw new Error(
      `${fieldName}: ожидалось число или строка; фактически: ${typeof value} (${JSON.stringify(value)})`,
    )
  }
  if (big > MAX_SAFE_BIG) {
    throw new Error(
      `${fieldName}: превышает Number.MAX_SAFE_INTEGER (2^53); требуется JSON-число в журнале. Фактически: ${big.toString()}`,
    )
  }
  return Number(big)
}

/** Запись журнала. 11 полей. usd — СТРОКА десятичного целого микро-USD. */
interface LogEntry {
  ts: number
  role: string
  provider: string
  model: string
  path: string
  tokens_in: number
  tokens_out: number
  /** ЦЕЛОЕ микро-USD, сериализуем СТРОКОЙ — IEEE-754 теряет точность за 2^53. */
  usd: string
  latency_ms: number
  status: number
  /** Значение x-request-id из запроса (коррелятор). Пустая строка, если нет. */
  request_id: string
}

/** Бюджет в памяти — BigInt, чтобы переполнения не было даже за 2^53. */
type Budget = Record<string, Record<string, bigint>>

// ════════════════════════════════════════════════════════════════════════════
// Чистые функции
// ════════════════════════════════════════════════════════════════════════════

/**
 * UTC `YYYY-MM` для ts в миллисекундах. Чистая. Вызывается НА КАЖДОМ запросе —
 * иначе ветвь (л) на стыке месяцев краснеет: кэш периода на старте делает
 * «оба вызова в одном периоде», а нужно в разных.
 */
export function periodAt(ts: number): string {
  const d = new Date(ts)
  const y = d.getUTCFullYear()
  const m = d.getUTCMonth() + 1
  return `${y}-${m < 10 ? '0' + m : '' + m}`
}

/**
 * ceil(n/d) для BigInt при d > 0. Округление ВВЕРХ целочисленно. В JS bigint
 * делит усечением К НУЛЮ, а не к -∞: для n >= 0 это совпадает с floor, и
 * `ceil = floor + (n%d !== 0)`. Для n < 0 усечение к нулю УЖЕ даёт ceil
 * (bigint: -7n/3n = -2n, и ceil(-2.333…) = -2 — совпадает).
 */
function ceilDivBigInt(n: bigint, d: bigint): bigint {
  if (d <= 0n) throw new Error('ceilDivBigInt: делитель должен быть положительным')
  if (n === 0n) return 0n
  if (n > 0n) return (n + d - 1n) / d
  return n / d
}

/** Стоимость вызова в микро-USD (BigInt), округление ВВЕРХ.
 *  Тариф — `BigInt` уже после `loadConfig` (см. `parseMicroBig`), tokens —
 *  `number` ≤ 2^53 (см. `parseTokensInt`); переход в BigInt здесь — математика,
 *  не валидация. */
export function computeUsd(
  tokensIn: number,
  tokensOut: number,
  inRateMicro: bigint,
  outRateMicro: bigint,
): bigint {
  const ti = BigInt(tokensIn)
  const to = BigInt(tokensOut)
  return ceilDivBigInt(ti * inRateMicro + to * outRateMicro, 1_000_000n)
}

/**
 * Сериализация в JSON с BigInt → string. `JSON.stringify` от BigInt бросает —
 * потому что IEEE-754 число теряет точность за 2^53, а деньги у нас int64.
 * Семь вызовов делают lockstep: если кто-то забудет, расхождение унесёт в
 * невалидный JSON.
 */
function jsonStringify(obj: unknown): string {
  return JSON.stringify(obj, (_k, v) => (typeof v === 'bigint' ? v.toString() : v))
}

// ════════════════════════════════════════════════════════════════════════════
// Конфиг и чтение на КАЖДОМ запросе
// ════════════════════════════════════════════════════════════════════════════

const MARKER_FILE = '.appendonly.json'
const BUDGET_FILE = 'budget.json'
const CALLS_FILE = 'calls.jsonl'
function loadConfig(configPath: string): Config {
  const text = fs.readFileSync(configPath, 'utf8')
  let raw: Record<string, unknown>
  try {
    raw = JSON.parse(text) as Record<string, unknown>
  } catch (e) {
    throw new Error('config: невалидный JSON — ' + (e as Error).message)
  }
  if (typeof raw.port !== 'number' || !Number.isFinite(raw.port)) {
    throw new Error('config: port должен быть числом')
  }
  if (typeof raw.secrets_env !== 'string' || !raw.secrets_env) {
    throw new Error('config: secrets_env должен быть непустой строкой')
  }
  if (typeof raw.data_dir !== 'string' || !raw.data_dir) {
    throw new Error('config: data_dir должен быть непустой строкой')
  }
  if (!raw.upstream || typeof raw.upstream !== 'object') {
    throw new Error('config: upstream должен быть объектом')
  }
  if (!raw.prices || typeof raw.prices !== 'object') {
    throw new Error('config: prices должен быть объектом')
  }
  if (!raw.ceilings || typeof raw.ceilings !== 'object') {
    throw new Error('config: ceilings должен быть объектом')
  }
  // Тарифы: парсим каждое поле per_m_tokens.in/out через parseMicroBig.
  // Любое число > 2^53 — отказ (не молчаливый ноль) на старте.
  const pricesOut: Record<string, Record<string, PriceRow>> = {}
  const rawPrices = raw.prices as Record<string, unknown>
  for (const provider of Object.keys(rawPrices)) {
    const provMap = rawPrices[provider]
    if (!provMap || typeof provMap !== 'object') {
      throw new Error(`config: prices.${provider} должен быть объектом`)
    }
    pricesOut[provider] = {}
    const modelMap = provMap as Record<string, unknown>
    for (const model of Object.keys(modelMap)) {
      const rawRow = modelMap[model]
      if (!rawRow || typeof rawRow !== 'object') {
        throw new Error(`config: prices.${provider}.${model} должен быть объектом`)
      }
      const pmt = (rawRow as Record<string, unknown>).per_m_tokens
      if (!pmt || typeof pmt !== 'object') {
        throw new Error(`config: prices.${provider}.${model}.per_m_tokens должен быть объектом`)
      }
      const pmtObj = pmt as Record<string, unknown>
      const inRate = parseMicroBig(
        pmtObj.in,
        `тариф ${provider}/${model}.per_m_tokens.in`,
      )
      const outRate = parseMicroBig(
        pmtObj.out,
        `тариф ${provider}/${model}.per_m_tokens.out`,
      )
      pricesOut[provider][model] = { per_m_tokens: { in: inRate, out: outRate } }
    }
  }
  // Потолки: то же правило, тот же парсер.
  const ceilingsOut: Record<string, Ceiling> = {}
  const rawCeilings = raw.ceilings as Record<string, unknown>
  for (const provider of Object.keys(rawCeilings)) {
    const rawCeil = rawCeilings[provider]
    if (!rawCeil || typeof rawCeil !== 'object') {
      throw new Error(`config: ceilings.${provider} должен быть объектом`)
    }
    const usd = parseMicroBig(
      (rawCeil as Record<string, unknown>).usd_per_month,
      `потолок ${provider}.usd_per_month`,
    )
    ceilingsOut[provider] = { usd_per_month: usd }
  }
  return {
    port: raw.port as number,
    healthz_window_sec: (raw.healthz_window_sec as number) ?? 5,
    secrets_env: raw.secrets_env as string,
    data_dir: raw.data_dir as string,
    upstream: raw.upstream as Record<string, string>,
    prices: pricesOut,
    ceilings: ceilingsOut,
    now_file: (raw.now_file as string | null) ?? null,
  }
}

/**
 * Карта токен→роль из файла secrets.env. БЕЗ КЭША — читается на КАЖДОМ запросе.
 *
 * Формат строк файла: `METERING_TOKEN_<ROLE>=<значение>`. Комментарии (`# …`) и
 * пустые строки игнорируются. Прочие ключи игнорируются.
 */
export function readTokenMap(secretsEnvPath: string): Map<string, string> {
  const map = new Map<string, string>()
  if (!fs.existsSync(secretsEnvPath)) return map
  const text = fs.readFileSync(secretsEnvPath, 'utf8')
  for (const rawLine of text.split('\n')) {
    const line = rawLine.trimEnd()
    if (!line || line.startsWith('#')) continue
    const eq = line.indexOf('=')
    if (eq <= 0) continue
    const key = line.slice(0, eq).trim()
    const value = line.slice(eq + 1)
    if (key.startsWith('METERING_TOKEN_')) {
      const role = key.slice('METERING_TOKEN_'.length)
      if (role && value) map.set(value, role)
    }
  }
  return map
}

/** Текущее время: `now_file` если задан, иначе `Date.now()`. БЕЗ КЭША. */
function readNowMs(cfg: Config): number {
  if (cfg.now_file) {
    try {
      const t = fs.readFileSync(cfg.now_file, 'utf8').trim()
      const n = Number(t)
      if (Number.isFinite(n) && n >= 0) return n
    } catch {
      /* файл мог быть удалён между запросами — fallback на Date.now() */
    }
  }
  return Date.now()
}

// ════════════════════════════════════════════════════════════════════════════
// Журнал (append-only) и маркер
// ════════════════════════════════════════════════════════════════════════════

/**
 * Дописывает одну строку в журнал и ОБНОВЛЯЕТ маркер append-only.
 * Запись и обновление — синхронные, чтобы пара (строка, маркер) не разошлась
 * при крэше между вызовами.
 */
export function appendLog(dataDir: string, entry: LogEntry): void {
  fs.mkdirSync(dataDir, { recursive: true })
  const callsPath = path.join(dataDir, CALLS_FILE)
  const line = jsonStringify(entry) + '\n'
  fs.appendFileSync(callsPath, line, 'utf8')
  // Маркер: байты = полный размер файла; sha256 = sha256 всех этих байт.
  const bytes = fs.statSync(callsPath).size
  const buf = fs.readFileSync(callsPath)
  const sha = crypto.createHash('sha256').update(buf).digest('hex')
  fs.writeFileSync(
    path.join(dataDir, MARKER_FILE),
    JSON.stringify({ bytes, sha256: sha }),
  )
}

// ════════════════════════════════════════════════════════════════════════════
// Бюджет
// ════════════════════════════════════════════════════════════════════════════

/** Прочитать budget.json → Budget (BigInt). Отсутствующий/битый файл → пустой объект. */
export function readBudget(dataDir: string): Budget {
  const p = path.join(dataDir, BUDGET_FILE)
  if (!fs.existsSync(p)) return {}
  const raw = fs.readFileSync(p, 'utf8')
  try {
    const parsed = JSON.parse(raw) as Record<string, Record<string, string | number>>
    const out: Budget = {}
    for (const per of Object.keys(parsed)) {
      const mp = parsed[per]
      out[per] = {}
      for (const pr of Object.keys(mp)) {
        out[per][pr] = BigInt(mp[pr] as string | number)
      }
    }
    return out
  } catch {
    return {}
  }
}

/** Записать Budget (BigInt) → budget.json. BigInt сериализуются строкой. */
export function writeBudget(dataDir: string, budget: Budget): void {
  const p = path.join(dataDir, BUDGET_FILE)
  const tmp = p + '.tmp'
  const out: Record<string, Record<string, string>> = {}
  for (const per of Object.keys(budget)) {
    const mp = budget[per]
    out[per] = {}
    for (const pr of Object.keys(mp)) {
      out[per][pr] = mp[pr].toString()
    }
  }
  fs.writeFileSync(tmp, JSON.stringify(out), 'utf8')
  fs.renameSync(tmp, p)
}

/** Пересобрать budget.json из журнала. Возвращает 0 если совпало с прежним, 1 если нет. */
export function rebuildBudget(cfg: Config): number {
  const callsPath = path.join(cfg.data_dir, CALLS_FILE)
  const fresh: Budget = {}
  if (fs.existsSync(callsPath)) {
    const text = fs.readFileSync(callsPath, 'utf8')
    for (const line of text.split('\n')) {
      if (!line) continue
      let rec: LogEntry
      try {
        rec = JSON.parse(line) as LogEntry
      } catch {
        // Битая строка — игнор. Append-only не значит «всегда валидный JSON»;
        // при крэше последняя строка может быть обрезана. Барьер пересоберёт
        // по небитым строкам, а битые останутся как есть до ручной чистки.
        continue
      }
      if (!rec || typeof rec !== 'object') continue
      const per = periodAt(Number(rec.ts))
      const pr = String(rec.provider)
      let u: bigint
      try {
        u = BigInt(String(rec.usd))
      } catch {
        continue
      }
      if (!fresh[per]) fresh[per] = {}
      if (!fresh[per][pr]) fresh[per][pr] = 0n
      fresh[per][pr] += u
    }
  }
  const prev = readBudget(cfg.data_dir)
  const same = budgetsEqual(prev, fresh)
  writeBudget(cfg.data_dir, fresh)
  return same ? 0 : 1
}

function budgetsEqual(a: Budget, b: Budget): boolean {
  const ak = Object.keys(a)
  const bk = Object.keys(b)
  if (ak.length !== bk.length) return false
  for (const k of ak) {
    if (!b[k]) return false
    const aSub = a[k]
    const bSub = b[k]
    const ask = Object.keys(aSub)
    const bsk = Object.keys(bSub)
    if (ask.length !== bsk.length) return false
    for (const s of ask) {
      if (aSub[s] !== bSub[s]) return false
    }
  }
  return true
}

// ════════════════════════════════════════════════════════════════════════════
// --verify-appendonly
// ════════════════════════════════════════════════════════════════════════════

/**
 * Сверяет append-only:
 *  - префикс файла длиной marker.bytes совпадает с marker.sha256;
 *  - размер файла >= marker.bytes (только растёт).
 * Возвращает 0 при согласованном состоянии, 1 при нарушении.
 */
export function verifyAppendOnly(cfg: Config): number {
  const callsPath = path.join(cfg.data_dir, CALLS_FILE)
  const markerPath = path.join(cfg.data_dir, MARKER_FILE)
  if (!fs.existsSync(callsPath)) return 1
  if (!fs.existsSync(markerPath)) return 1
  let marker: { bytes: number; sha256: string }
  try {
    const m = JSON.parse(fs.readFileSync(markerPath, 'utf8'))
    if (typeof m.bytes !== 'number' || typeof m.sha256 !== 'string') return 1
    marker = m
  } catch {
    return 1
  }
  const curBytes = fs.statSync(callsPath).size
  if (curBytes < marker.bytes) return 1
  if (curBytes === marker.bytes) {
    const buf = fs.readFileSync(callsPath)
    const sha = crypto.createHash('sha256').update(buf).digest('hex')
    if (sha !== marker.sha256) return 1
    return 0
  }
  // Размер вырос — проверяем, что префикс неизменен.
  const fd = fs.openSync(callsPath, 'r')
  try {
    const buf = Buffer.alloc(marker.bytes)
    fs.readSync(fd, buf, 0, marker.bytes, 0)
    const sha = crypto.createHash('sha256').update(buf).digest('hex')
    if (sha !== marker.sha256) return 1
  } finally {
    fs.closeSync(fd)
  }
  return 0
}

// ════════════════════════════════════════════════════════════════════════════
// Сериализация доступа к бюджету (защита от гонки между запросами)
// ════════════════════════════════════════════════════════════════════════════
//
// Чтение и запись budget.json — на критической секции, иначе два конкурентных
// запроса прочтут одно и то же значение и оба перезапишут его поверх
// обновления друг друга. Цепочка промисов дешевле настоящего мьютекса и
// удерживает инвариант «каждая запись бюджета видит всё, что было записано
// раньше, в этом же процессе».

let budgetChainTail: Promise<unknown> = Promise.resolve()

function withBudgetLock<T>(fn: () => T | Promise<T>): Promise<T> {
  const prev = budgetChainTail
  const next = prev.then(fn, fn)
  budgetChainTail = next.catch(() => undefined)
  return next
}

// ════════════════════════════════════════════════════════════════════════════
// Утилиты HTTP
// ════════════════════════════════════════════════════════════════════════════

/**
 * Переслать запрос к upstream. Метод, тело байт-в-байт, заголовки дословно
 * (кроме `host` — там upstream-овый). Возвращает incoming-ответ, иначе бросает.
 */
function proxyRequest(
  url: string,
  method: string,
  headers: http.IncomingHttpHeaders,
  body: Buffer,
): Promise<http.IncomingMessage> {
  let u: URL
  try {
    u = new URL(url)
  } catch (e) {
    return Promise.reject(new Error('bad upstream URL: ' + url))
  }
  const isHttps = u.protocol === 'https:'
  const lib = isHttps ? https : http
  const fwd: Record<string, string | string[]> = {}
  for (const k of Object.keys(headers)) {
    const v = headers[k]
    if (typeof v === 'string' || Array.isArray(v)) fwd[k] = v
  }
  // Хост — адресом upstream, иначе целевой сервер увидит наш хост и запутается.
  fwd['host'] = u.host
  const opts: http.RequestOptions = {
    method,
    hostname: u.hostname,
    port: u.port || (isHttps ? 443 : 80),
    path: u.pathname + u.search,
    headers: fwd,
  }
  const { promise, resolve, reject } = Promise.withResolvers<http.IncomingMessage>()
  const preq = lib.request(opts, (r: http.IncomingMessage) => resolve(r))
  preq.on('error', reject)
  preq.on('timeout', () => {
    preq.destroy(new Error('upstream timeout'))
  })
  if (body.length > 0) preq.write(body)
  preq.end()
  return promise
}

// ════════════════════════════════════════════════════════════════════════════
// Обработчик запроса
// ════════════════════════════════════════════════════════════════════════════

async function handleRequest(
  req: http.IncomingMessage,
  res: http.ServerResponse,
  cfg: Config,
): Promise<void> {
  // 1. healthz — НЕ проксируется, в журнал НЕ пишется.
  if (req.method === 'GET' && req.url === '/healthz') {
    res.writeHead(200, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ ok: true }))
    return
  }

  // 2. Токен. БЕЗ КЭША: читаем карту заново.
  const authHeader = req.headers.authorization
  const auth = typeof authHeader === 'string' ? authHeader : ''
  const m = /^Bearer\s+(.+)$/.exec(auth)
  const token = m ? m[1] : ''
  if (!token) {
    // Контракт: 401, строки НЕТ.
    res.writeHead(401, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'unknown_token' }))
    return
  }
  const tokenMap = readTokenMap(cfg.secrets_env)
  const role = tokenMap.get(token)
  if (!role) {
    res.writeHead(401, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'unknown_token' }))
    return
  }

  // 3. URL → provider, rest.
  const rawUrl = req.url || ''
  if (!rawUrl) {
    res.writeHead(400, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'bad_request' }))
    return
  }
  const queryIdx = rawUrl.indexOf('?')
  const pathOnly = queryIdx >= 0 ? rawUrl.slice(0, queryIdx) : rawUrl
  const slash = pathOnly.indexOf('/', 1)
  const provider = slash > 0 ? pathOnly.slice(1, slash) : pathOnly.slice(1)
  const rest = slash > 0 ? pathOnly.slice(slash) : '/'
  if (!provider) {
    res.writeHead(400, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'bad_request' }))
    return
  }
  const upstreamBase = cfg.upstream[provider]
  if (!upstreamBase) {
    res.writeHead(404, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'unknown_provider' }))
    return
  }

  // 4. Модель — заголовком. Тело может быть НЕ-JSON, из тела НЕ берём.
  const modelHeader = req.headers['x-metering-model']
  const model = typeof modelHeader === 'string' ? modelHeader.trim() : ''
  if (!model) {
    res.writeHead(400, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'missing_model' }))
    return
  }

  // 5. Цена — по ПАРЕ provider+model. Если цены нет, upstream НЕ вызываем.
  const priceMap = cfg.prices[provider]
  const price = priceMap ? priceMap[model] : undefined
  if (!price || !price.per_m_tokens) {
    res.writeHead(503, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'model_unpriced' }))
    return
  }
  // rate — BigInt уже (см. parseMicroBig в loadConfig). Никакого Number().
  const inRate = price.per_m_tokens.in
  const outRate = price.per_m_tokens.out

  // 6. Период и потолок. БЕЗ КЭША: период — на каждом запросе.
  const nowMs = readNowMs(cfg)
  const period = periodAt(nowMs)
  const ceilingCfg = cfg.ceilings[provider]
  const limitBig: bigint = ceilingCfg ? ceilingCfg.usd_per_month : 0n

  // request_id — из заголовка x-request-id (коррелятор). Пустая строка, если нет.
  const ridHeader = req.headers['x-request-id']
  const requestId = typeof ridHeader === 'string' ? ridHeader : ''

  // 7. Чтение бюджета под замком — для сверки потолка.
  const check = await withBudgetLock((): { spent: bigint } => {
    const budget = readBudget(cfg.data_dir)
    return { spent: budget[period] ? budget[period][provider] ?? 0n : 0n }
  })

  // 8. Потолок исчерпан — 402 ДО запроса, состояние бюджета ДО запроса.
  if (limitBig > 0n && check.spent >= limitBig) {
    const body = jsonStringify({
      error: 'ceiling_exceeded',
      period,
      provider,
      spent_usd: check.spent.toString(),
      limit_usd: limitBig.toString(),
    })
    // 402 ПИШЕТСЯ строкой полной схемы с usd=0.
    appendLog(cfg.data_dir, {
      ts: nowMs,
      role,
      provider,
      model,
      path: rawUrl,
      tokens_in: 0,
      tokens_out: 0,
      usd: '0',
      latency_ms: 0,
      status: 402,
      request_id: requestId,
    })
    res.writeHead(402, { 'content-type': 'application/json' })
    res.end(body)
    return
  }

  // 9. Тело запроса — байт-в-байт для ОБОИХ методов (HTTP разрешает тело в GET).
  const reqChunks: Buffer[] = []
  for await (const c of req) {
    reqChunks.push(c as Buffer)
  }
  const reqBody = Buffer.concat(reqChunks)

  // 10. Запрос к upstream.
  const start = Date.now()
  const upstreamBaseTrimmed = upstreamBase.replace(/\/+$/, '')
  const restWithSlash = rest.startsWith('/') ? rest : '/' + rest
  const querySuffix = queryIdx >= 0 ? rawUrl.slice(queryIdx) : ''
  const upstreamUrl = upstreamBaseTrimmed + restWithSlash + querySuffix
  let upstreamRes: http.IncomingMessage
  try {
    upstreamRes = await proxyRequest(upstreamUrl, req.method || 'GET', req.headers, reqBody)
  } catch {
    // 502: пишем строку полной схемы, tokens/usd = 0.
    const nowMs2 = readNowMs(cfg)
    appendLog(cfg.data_dir, {
      ts: nowMs2,
      role,
      provider,
      model,
      path: rawUrl,
      tokens_in: 0,
      tokens_out: 0,
      usd: '0',
      latency_ms: Date.now() - start,
      status: 502,
      request_id: requestId,
    })
    res.writeHead(502, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'upstream_unreachable' }))
    return
  }

  // 11. Тело ответа upstream — байт-в-байт.
  const resChunks: Buffer[] = []
  for await (const c of upstreamRes) {
    resChunks.push(c as Buffer)
  }
  const resBody = Buffer.concat(resChunks)
  const resCtypeHeader = upstreamRes.headers['content-type']
  const resCtype = typeof resCtypeHeader === 'string' ? resCtypeHeader : ''
  const latencyMs = Date.now() - start
  const upstreamStatus = upstreamRes.statusCode || 502

  // 12. Извлечение usage. Приоритет: (1) тело-JSON, (2) заголовки ответа.
  //     Ветвь (в) даёт тело-не-JSON и требует ненулевой usd — потому источник (2) обязателен.
  //     Чтение — через parseTokensInt (BigInt из десятичного текста), без parseInt.
  //     > 2^53 — отказ с названной причиной (не молчаливое усечение).
  //     Поле есть и его значение null — трактуем как «нет значения от тела»,
  //     чтобы сохранить прежнюю логику «fall back to headers»; иначе всё, что
  //     не число/строка, проходит через parseTokensInt.
  let tokensIn = 0
  let tokensOut = 0
  let usageError: Error | null = null
  try {
    const parsed = JSON.parse(resBody.toString('utf8'))
    if (parsed && typeof parsed === 'object' && parsed.usage && typeof parsed.usage === 'object') {
      const u = parsed.usage as Record<string, unknown>
      if ('prompt_tokens' in u && u.prompt_tokens !== null) {
        try {
          tokensIn = parseTokensInt(u.prompt_tokens, 'usage.prompt_tokens')
        } catch (e) {
          usageError = e as Error
        }
      }
      if ('completion_tokens' in u && u.completion_tokens !== null) {
        try {
          tokensOut = parseTokensInt(u.completion_tokens, 'usage.completion_tokens')
        } catch (e) {
          usageError = e as Error
        }
      }
    }
  } catch {
    /* не JSON — пойдём к источнику (2) */
  }
  if (tokensIn === 0 && usageError === null) {
    const h = upstreamRes.headers['x-usage-tokens-in']
    if (typeof h === 'string') {
      try {
        tokensIn = parseTokensInt(h, 'x-usage-tokens-in')
      } catch (e) {
        usageError = e as Error
      }
    }
  }
  if (tokensOut === 0 && usageError === null) {
    const h = upstreamRes.headers['x-usage-tokens-out']
    if (typeof h === 'string') {
      try {
        tokensOut = parseTokensInt(h, 'x-usage-tokens-out')
      } catch (e) {
        usageError = e as Error
      }
    }
  }
  if (usageError) {
    // Upstream вернул непригодное usage. 502 + полная строка, tokens/usd=0,
    // и названная причина в теле (а не молчаливое округление).
    const nowMs2 = readNowMs(cfg)
    appendLog(cfg.data_dir, {
      ts: nowMs2,
      role,
      provider,
      model,
      path: rawUrl,
      tokens_in: 0,
      tokens_out: 0,
      usd: '0',
      latency_ms: Date.now() - start,
      status: 502,
      request_id: requestId,
    })
    res.writeHead(502, { 'content-type': 'application/json' })
    res.end(JSON.stringify({ error: 'bad_usage', reason: usageError.message }))
    return
  }

  // 13. Стоимость (BigInt, округление вверх).
  const usd = computeUsd(tokensIn, tokensOut, inRate, outRate)

  // 14. Время для строки берём СВЕЖЕЕ (после upstream-ответа). Без кэша.
  const nowMs2 = readNowMs(cfg)

  // 15. Строка журнала — полная схема, usd как СТРОКА.
  appendLog(cfg.data_dir, {
    ts: nowMs2,
    role,
    provider,
    model,
    path: rawUrl,
    tokens_in: tokensIn,
    tokens_out: tokensOut,
    usd: usd.toString(),
    latency_ms: latencyMs,
    status: upstreamStatus,
    request_id: requestId,
  })

  // 16. Обновление бюджета под замком.
  await withBudgetLock(() => {
    const budget = readBudget(cfg.data_dir)
    if (!budget[period]) budget[period] = {}
    if (!budget[period][provider]) budget[period][provider] = 0n
    budget[period][provider] += usd
    writeBudget(cfg.data_dir, budget)
  })

  // 17. Passthrough клиенту: статус, тело, content-type. Прочие заголовки
  //     в минимум не входят (арбитраж).
  const headers: Record<string, string | string[]> = {}
  if (resCtype) headers['content-type'] = resCtype
  res.writeHead(upstreamStatus, headers)
  res.end(resBody)
}

// ════════════════════════════════════════════════════════════════════════════
// --selftest
// ════════════════════════════════════════════════════════════════════════════

export function selftest(): number {
  const fails: string[] = []

  // ── periodAt на стыке месяцев ────────────────────────────────────────────
  const t1 = Date.UTC(2026, 0, 31, 23, 59, 59, 999)  // 31 Jan 2026 23:59:59.999 UTC
  const t2 = Date.UTC(2026, 1, 1, 0, 0, 0, 0)        // 1 Feb 2026 00:00:00.000 UTC
  const t3 = Date.UTC(2024, 11, 31, 23, 59, 59, 999) // 31 Dec 2024
  const t4 = Date.UTC(2025, 0, 1, 0, 0, 0, 0)        // 1 Jan 2025
  if (periodAt(t1) !== '2026-01') fails.push('periodAt: 31 jan 23:59:59.999 UTC → 2026-01')
  if (periodAt(t2) !== '2026-02') fails.push('periodAt: 1 feb 00:00:00.000 UTC → 2026-02')
  if (periodAt(t3) !== '2024-12') fails.push('periodAt: 31 dec → 2024-12')
  if (periodAt(t4) !== '2025-01') fails.push('periodAt: 1 jan → 2025-01')

  // ── приписывание токена (БЕЗ КЭША — читается из файла) ──────────────────
  const tmp = fs.mkdtempSync(path.join(process.cwd(), 'tmp-selftest-'))
  try {
    const sec = path.join(tmp, 'secrets.env')
    fs.writeFileSync(
      sec,
      [
        '# комментарий',
        'METERING_TOKEN_DEV=token-dev',
        'METERING_TOKEN_OPS=token-ops',
        'OTHER=ignored',
        '',
        'METERING_TOKEN_DEV2=token2',
      ].join('\n'),
      'utf8',
    )
    const tm = readTokenMap(sec)
    if (tm.get('token-dev') !== 'DEV') fails.push('token-map: token-dev → DEV')
    if (tm.get('token-ops') !== 'OPS') fails.push('token-map: token-ops → OPS')
    if (tm.get('token2') !== 'DEV2') fails.push('token-map: token2 → DEV2')
    if (tm.has('ignored')) fails.push('token-map: не-prefix строка попала в карту')

    // ── свёртка журнала в бюджет (int64) ──────────────────────────────────
    const dataDir = path.join(tmp, 'data')
    fs.mkdirSync(dataDir)
    const callsPath = path.join(dataDir, CALLS_FILE)
    // ts = 1700000000000 → 2023-11-14 22:13:20 UTC
    // ts = 1735689600000 → 2025-01-01 00:00:00 UTC
    // Большое значение 9007199254740993 > 2^53 — гарантия, что IEEE-754 потерял бы единицу.
    const entries: LogEntry[] = [
      { ts: 1700000000000, role: 'r1', provider: 'p1', model: 'm1', path: '/x', tokens_in: 1, tokens_out: 1, usd: '9007199254740993', latency_ms: 0, status: 200, request_id: 'rid1' },
      { ts: 1700000000000, role: 'r2', provider: 'p1', model: 'm1', path: '/x', tokens_in: 0, tokens_out: 0, usd: '1',                          latency_ms: 0, status: 200, request_id: 'rid2' },
      { ts: 1700000000000, role: 'r3', provider: 'p2', model: 'm1', path: '/x', tokens_in: 0, tokens_out: 0, usd: '500',                        latency_ms: 0, status: 200, request_id: 'rid3' },
      { ts: 1735689600000, role: 'r4', provider: 'p1', model: 'm1', path: '/x', tokens_in: 0, tokens_out: 0, usd: '9999',                       latency_ms: 0, status: 200, request_id: 'rid4' },
    ]
    fs.writeFileSync(callsPath, entries.map((e) => jsonStringify(e)).join('\n') + '\n', 'utf8')
    // Инициализируем маркер
    const bytes = fs.statSync(callsPath).size
    const sha = crypto.createHash('sha256').update(fs.readFileSync(callsPath)).digest('hex')
    fs.writeFileSync(path.join(dataDir, MARKER_FILE), JSON.stringify({ bytes, sha256: sha }))
    // Ожидаемый бюджет
    const expected: Budget = {
      '2023-11': { p1: 9007199254740994n, p2: 500n },
      '2025-01': { p1: 9999n },
    }
    writeBudget(dataDir, expected)
    const cfg: Config = {
      port: 0,
      healthz_window_sec: 5,
      secrets_env: sec,
      data_dir: dataDir,
      upstream: {},
      prices: {},
      ceilings: {},
      now_file: null,
    }
    // Свёртка совпадает — 0.
    if (rebuildBudget(cfg) !== 0) fails.push('rebuild-budget: совпало → должно быть 0')
    // Портим бюджет — должно быть 1.
    expected['2023-11'].p1 = 9007199254740995n
    writeBudget(dataDir, expected)
    if (rebuildBudget(cfg) !== 1) fails.push('rebuild-budget: расхождение → должно быть 1')
    // Возвращаем — снова 0.
    expected['2023-11'].p1 = 9007199254740994n
    writeBudget(dataDir, expected)
    if (rebuildBudget(cfg) !== 0) fails.push('rebuild-budget: восстановлено → 0')

    // ── append-only ───────────────────────────────────────────────────────
    // Свежий журнал и маркер. Verify на согласованном состоянии — 0.
    fs.writeFileSync(callsPath, entries.map((e) => jsonStringify(e)).join('\n') + '\n', 'utf8')
    const b0 = fs.statSync(callsPath).size
    const s0 = crypto.createHash('sha256').update(fs.readFileSync(callsPath)).digest('hex')
    fs.writeFileSync(path.join(dataDir, MARKER_FILE), JSON.stringify({ bytes: b0, sha256: s0 }))
    if (verifyAppendOnly(cfg) !== 0) fails.push('verify-appendonly: согласованное → 0')
    // Дописываем строку — verify на выросшем файле — 0.
    const extra: LogEntry = { ts: 1735689600000, role: 'r5', provider: 'p1', model: 'm1', path: '/x', tokens_in: 0, tokens_out: 0, usd: '0', latency_ms: 0, status: 200, request_id: 'rid5' }
    fs.appendFileSync(callsPath, jsonStringify(extra) + '\n', 'utf8')
    const b1 = fs.statSync(callsPath).size
    const s1 = crypto.createHash('sha256').update(fs.readFileSync(callsPath)).digest('hex')
    fs.writeFileSync(path.join(dataDir, MARKER_FILE), JSON.stringify({ bytes: b1, sha256: s1 }))
    if (verifyAppendOnly(cfg) !== 0) fails.push('verify-appendonly: после роста → 0')
    // Портим префикс — verify на изменённом файле с ТЕМ ЖЕ маркером — 1.
    const tampered = Buffer.concat([Buffer.from('XXXXXX', 'utf8'), fs.readFileSync(callsPath).subarray(b1)])
    fs.writeFileSync(callsPath, tampered)
    if (verifyAppendOnly(cfg) !== 1) fails.push('verify-appendonly: испорченный префикс → 1')
    // Восстанавливаем.
    fs.writeFileSync(callsPath, Buffer.concat([
      Buffer.from(entries.map((e) => jsonStringify(e)).join('\n') + '\n', 'utf8'),
      Buffer.from(jsonStringify(extra) + '\n', 'utf8'),
    ]))
    const b2 = fs.statSync(callsPath).size
    const s2 = crypto.createHash('sha256').update(fs.readFileSync(callsPath)).digest('hex')
    fs.writeFileSync(path.join(dataDir, MARKER_FILE), JSON.stringify({ bytes: b2, sha256: s2 }))
    if (verifyAppendOnly(cfg) !== 0) fails.push('verify-appendonly: восстановлено → 0')

    // ── формула с округлением вверх ───────────────────────────────────────
    // [tokens_in, tokens_out, in_rate_micro, out_rate_micro, expected_usd_micro]
    const cases: Array<[number, number, number, number, bigint]> = [
      [1, 0, 1, 1, 1n],            // ceil(1 / 1_000_000) = 1
      [999_999, 0, 1, 1, 1n],      // ceil(999_999 / 1M) = 1
      [1_000_000, 0, 1, 1, 1n],    // ceil(1M / 1M) = 1
      [1_000_001, 0, 1, 1, 2n],    // ceil(1M+1 / 1M) = 2
      [0, 1, 1, 1, 1n],
      [1, 1, 12, 34, 1n],          // ceil((12+34)/1M) = 1
      [1_000_000, 1_000_000, 12, 34, 46n], // (12+34) = 46
      [1_000_000, 0, 13, 0, 13n],
      [1000, 0, 5_000_000, 0, 5_000n], // 1000 * 5M / 1M = 5000
    ]
    for (const [ti, to, ir, or, expected] of cases) {
      const got = computeUsd(ti, to, BigInt(ir), BigInt(or))
      if (got !== expected) {
        fails.push(`computeUsd(${ti},${to},${ir},${or}) = ${got}, ожидалось ${expected}`)
      }
    }
    // int64 — дважды 2^53+1 в сумме дают 2^54+2; IEEE-754 потерял бы 2.
    const sumBig = 9007199254740993n + 9007199254740993n
    if (sumBig !== 18014398509481986n) {
      fails.push('int64: сумма двух значений >2^53 должна быть точной — потеря')
    }
    // ── ветвь точности: тариф СТРОКОЙ → usd РОВНО 9007199254740993000 ─────
    // 1e9 * 9007199254740993 / 1e6 = 9.007199254740993e15. Округление вверх
    // не меняет (делимое делится ровно). IEEE-754-стаб с Number() даёт
    // 9007199254740992 (потеря 1 на входе), потом 9007199254740992 * 1e9
    // = 9.007199254740992e24, делённое на 1e6 = 9007199254740992000
    // (потеря ещё 1000). Эталон: 9007199254740993000.
    const exactUsd = computeUsd(1_000_000_000, 0, 9007199254740993n, 0n)
    if (exactUsd !== 9007199254740993000n) {
      fails.push(`int64: 1e9 * 9007199254740993 / 1e6 = ${exactUsd.toString()}, ожидалось 9007199254740993000`)
    }
    // Та же точность — через loadConfig со строкой. Это путь, по которому
    // пойдёт живая конфигурация: число → parseMicroBig → BigInt.
    const goodCfgPath = path.join(tmp, 'good-cfg.json')
    fs.writeFileSync(goodCfgPath, JSON.stringify({
      port: 0,
      healthz_window_sec: 5,
      secrets_env: sec,
      data_dir: dataDir,
      upstream: {},
      prices: { p: { m: { per_m_tokens: { in: '9007199254740993', out: '1' } } } },
      ceilings: { p: { usd_per_month: '10000000000000000' } },
      now_file: null,
    }))
    const goodCfg = loadConfig(goodCfgPath)
    if (goodCfg.prices.p.m.per_m_tokens.in !== 9007199254740993n) {
      fails.push(`int64: rate из строки должен быть 9007199254740993n, фактически ${goodCfg.prices.p.m.per_m_tokens.in.toString()}`)
    }
    // Тот же тариф голым числом — loadConfig ОБЯЗАН отказать на старте.
    const badCfgPath = path.join(tmp, 'bad-cfg.json')
    fs.writeFileSync(badCfgPath, JSON.stringify({
      port: 0,
      healthz_window_sec: 5,
      secrets_env: sec,
      data_dir: dataDir,
      upstream: {},
      prices: { p: { m: { per_m_tokens: { in: 9007199254740993, out: 1 } } } },
      ceilings: {},
      now_file: null,
    }))
    let badCaught = false
    let badMsg = ''
    try {
      loadConfig(badCfgPath)
    } catch (e) {
      badCaught = true
      badMsg = (e as Error).message
    }
    if (!badCaught) {
      fails.push('int64: loadConfig должен отказать на rate > 2^53 как число, но принял')
    } else if (!badMsg.includes('голое JSON-число выше безопасного целого')) {
      fails.push(`int64: отказ должен называть причину, фактически: ${badMsg}`)
    }
    // Потолок голым числом > 2^53 — отказ.
    const badCeilPath = path.join(tmp, 'bad-ceil.json')
    fs.writeFileSync(badCeilPath, JSON.stringify({
      port: 0,
      healthz_window_sec: 5,
      secrets_env: sec,
      data_dir: dataDir,
      upstream: {},
      prices: {},
      ceilings: { p: { usd_per_month: 99007199254740993000 } },
      now_file: null,
    }))
    let ceilCaught = false
    let ceilMsg = ''
    try {
      loadConfig(badCeilPath)
    } catch (e) {
      ceilCaught = true
      ceilMsg = (e as Error).message
    }
    if (!ceilCaught) {
      fails.push('int64: loadConfig должен отказать на потолке > 2^53 как число, но принял')
    } else if (!ceilMsg.includes('голое JSON-число выше безопасного целого')) {
      fails.push(`int64: отказ потолка должен называть причину, фактически: ${ceilMsg}`)
    }
    // Usage > 2^53 — parseTokensInt должен отказать (а не молча усечь).
    // Голое число > 2^53 — parseTokensInt отказывает на Number.isSafeInteger (Number() округлил).
    // (literal 9007199254740993 округляется JS до 9007199254740992 == 2^53, и та — НЕ safe.)
    let tokCaught = false
    let tokMsg = ''
    try {
      parseTokensInt(9007199254740993, 'usage.prompt_tokens')
    } catch (e) {
      tokCaught = true
      tokMsg = (e as Error).message
    }
    if (!tokCaught) {
      fails.push('int64: parseTokensInt должен отказать на tokens > 2^53 числом, но принял')
    } else if (!tokMsg.includes('безопасного целого')) {
      fails.push(`int64: parseTokensInt должен назвать «безопасного целого», фактически: ${tokMsg}`)
    }
    // Строка с токенами в пределах 2^53 — точное число. И наоборот: "1e9" — отказ.
    if (parseTokensInt('1000000000', 'usage.prompt_tokens') !== 1000000000) {
      fails.push('int64: parseTokensInt("1000000000") должен быть 1000000000')
    }
    let expCaught = false
    try { parseTokensInt('1e9', 'usage.prompt_tokens') } catch { expCaught = true }
    if (!expCaught) {
      fails.push('int64: parseTokensInt("1e9") — отказ (экспонента не десятичное)')
    }
    // Строка с токенами > 2^53 — отказ (даже валидная запись).
    let bigTokCaught = false
    try { parseTokensInt('9007199254740993', 'usage.prompt_tokens') } catch { bigTokCaught = true }
    if (!bigTokCaught) {
      fails.push('int64: parseTokensInt("9007199254740993") — отказ (выше 2^53)')
    }
  } finally {
    fs.rmSync(tmp, { recursive: true, force: true })
  }

  if (fails.length > 0) {
    for (const f of fails) console.error('selftest FAIL:', f)
    return 1
  }
  // Не печатаем PASS — это запрещено нормой. Тихая диагностика на stderr.
  console.error('selftest OK')
  return 0
}

// ════════════════════════════════════════════════════════════════════════════
// main
// ════════════════════════════════════════════════════════════════════════════

function parseArgs(argv: string[]): { config: string; flags: Set<string> } {
  let config = ''
  const flags = new Set<string>()
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i]
    if (a === '--config') {
      if (i + 1 >= argv.length) throw new Error('--config требует значения')
      config = argv[i + 1]
      i++
      continue
    }
    if (a === '--selftest' || a === '--rebuild-budget' || a === '--verify-appendonly') {
      flags.add(a)
      continue
    }
    throw new Error('неизвестный аргумент: ' + a)
  }
  return { config, flags }
}

async function main(): Promise<number> {
  let parsed: { config: string; flags: Set<string> }
  try {
    parsed = parseArgs(process.argv.slice(2))
  } catch (e) {
    console.error('proxy:', (e as Error).message)
    return 2
  }
  const { config: configPath, flags } = parsed

  if (flags.has('--selftest')) return selftest()

  if (!configPath) {
    console.error('proxy: требуется --config <файл>')
    return 2
  }

  let cfg: Config
  try {
    cfg = loadConfig(configPath)
  } catch (e) {
    console.error('proxy: невалидный конфиг —', (e as Error).message)
    return 1
  }
  fs.mkdirSync(cfg.data_dir, { recursive: true })

  if (flags.has('--rebuild-budget')) {
    try {
      return rebuildBudget(cfg)
    } catch (e) {
      console.error('proxy: rebuild-budget упал —', (e as Error).message)
      return 1
    }
  }
  if (flags.has('--verify-appendonly')) {
    try {
      return verifyAppendOnly(cfg)
    } catch (e) {
      console.error('proxy: verify-appendonly упал —', (e as Error).message)
      return 1
    }
  }

  // ── режим прокси ────────────────────────────────────────────────────────
  const server = http.createServer((req, res) => {
    handleRequest(req, res, cfg).catch((e) => {
      console.error('proxy: необработанная ошибка —', e)
      if (!res.headersSent) {
        try {
          res.writeHead(500, { 'content-type': 'application/json' })
          res.end(JSON.stringify({ error: 'internal' }))
        } catch {
          /* ответ уже отправлен или сокет закрыт */
        }
      }
    })
  })

  {
    const { promise, resolve, reject } = Promise.withResolvers<void>()
    server.once('error', reject)
    server.listen(cfg.port, () => resolve())
    await promise
  }
  console.error(`metering_proxy listening on ${cfg.port}, data_dir=${cfg.data_dir}`)

  // Корректное завершение — закрыть сервер, выйти по сигналу.
  for (const sig of ['SIGINT', 'SIGTERM'] as const) {
    process.on(sig, () => {
      server.close(() => process.exit(0))
      setTimeout(() => process.exit(1), 5000).unref()
    })
  }

  // Держим процесс живым, пока не придёт сигнал.
  const { promise } = Promise.withResolvers<number>()
  return promise
}

main().then(
  (rc) => process.exit(rc),
  (e) => {
    console.error('proxy: фатальная ошибка —', e)
    process.exit(1)
  },
)