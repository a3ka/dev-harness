#!/usr/bin/env bash
# КОМАНДА ПРИЁМКИ СТАНЦИИ контракта 140 «odin-agent-na-predmet» — станционные
# клетки таблицы осей (osi.md, раздел «Станционные клетки интеграции»):
# исходы ПОСТАВЛЯЕМОЙ интеграции .omp/extensions/spawn-guard.ts →
# scripts/zamok_predmeta.sh, которые без станции неисполнимы (корни состояний
# интеграция выводит из живого ctx сессии omp — инвариант 1 контракта; в CI
# omp-сессии нет). Здесь драйвер узла кормит хуку ПОДЛОЖНЫЙ tool_call и
# подложный ctx (приём zashchita_main_104/_mir.sh: синтетический pi, события
# cases.json) — хук, дверь, конфиг и алфавит РЕАЛЬНЫЕ, из дерева установки.
#
# ИСПОЛЬЗОВАНИЕ (на станции; node/git/jq обязательны, omp НЕ нужен):
#   bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh
#
# ВЫВОД: по одной строке на клетку `PROBA <имя> OK` | `PROBA <имя> KRASNO: <деталь>`;
# финал `PROB VSEGO <N> KRASNYH <M>`.
# Коды возврата: 0 — все PROBA OK (после ленда реализации); 1 — есть KRASNO
# (до реализации боли живы: интеграция не вызывает дверь — это КРАСНО, не молча);
# 2 — нечем проверять (нет node/git/jq, хука или драйвера).
#
# КЛЕТКИ (osi.md): p01 дубль живого рабочего (приёмка 5а); p02 судья до yield
# (класс свидетеля критика); p03 судья без OBJECT (приёмка 5б); p04 OBJECT≠tip
# (предупреждение + фактический OBJECT); p05 порядок адверсарий→ревьюер;
# p06 лимит harness 3 из 3 (предупреждение + START); p07 атомарный пакет
# (дубль предмета в batch — блок всего пакета, занятий ноль); p08 гонка двух
# tool_call — ровно один пропуск; p09 брошенный замок (предупреждение + RELEASE);
# p10 после yield + START пишет РАСШИРЕНИЕ; p11 алфавит 104 не ослаблен; p12 чужой
# инструмент (toolName≠task) не трогается; p13 fail-closed (дверь rc 2 → блок
# «страж сломан»); p14 --uchet живого мира (приёмка 5в); m01 обманная
# интеграция — блок вызова двери снят, приёмка обязана видеть симптом
# (проход судьи до yield) — проверка проверяющего (tdd: не tautological).
# p10 предъявляет false/true/missing/string/number/object у судьи; p15 —
# false/missing/string/number/object у последнего рабочего пакета с пустым учётом;
# p16 — смешанный пакет со своим фактом; p17/p18 — отказ без предсозданного
# учёта (один/пакет), p19 — неизменность существующего учёта/занятия;
# p20 — первый честный рабочий в новом корне. normalizacija_140.py привязывает
# truthiness/константу к адресным клеткам и проверяет строгий зелёный контроль.
set -uo pipefail
ZDES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
KOREN="$(cd "$ZDES/../../.." && pwd -P)"
HUK="$KOREN/.omp/extensions/spawn-guard.ts"
DVER="$KOREN/scripts/zamok_predmeta.sh"
REPO_HARNESS="$KOREN"

command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v git  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n'  >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n'   >&2; exit 2; }
[ -f "$HUK" ] || { printf 'NOT_IMPLEMENTED: нет хука %s\n' "$HUK" >&2; exit 2; }

W="$(mktemp -d "${TMPDIR:-/tmp}/odin140-stancija.XXXXXXXX")"
trap 'rm -rf "$W"' EXIT
KRASNYH=0
VSEGO=0

proba() {  # <имя> <ok|krasno> <деталь>
  VSEGO=$((VSEGO+1))
  if [ "$2" = ok ]; then
    printf 'PROBA %s OK\n' "$1"
  else
    KRASNYH=$((KRASNYH+1))
    printf 'PROBA %s KRASNO: %s\n' "$1" "${3:-без детали}"
  fi
}

# ── драйвер: подложный tool_call через РЕАЛЬНЫЙ хук (синтетический pi + ctx) ──
# Аргументы: <путь хука> <cases.json>; в каждом case: name, want ('pass' |
# 'block:<подстрока reason>'), event, sessfile (файл сессии для ctx), cwd.
# env-подсказки корней (HARNESS_*/OMP_*/ODIN*) СТЁРТЫ: корни — только из ctx.
cat > "$W/drajver.mjs" <<'MJS'
import { pathToFileURL } from 'node:url';
import { readFileSync, readdirSync, statSync } from 'node:fs';
import childProcess from 'node:child_process';
import { syncBuiltinESMExports } from 'node:module';
// Наблюдаем stderr и rc НАСТОЯЩЕГО дочернего процесса: хук при rc 0 их
// наружу не передаёт. Дверь и её результат не заменяются двойником.
const spawned = [];
const realSpawnSync = childProcess.spawnSync;
childProcess.spawnSync = (...args) => {
  const result = realSpawnSync(...args);
  if (Array.isArray(args[1]) && args[1].includes('--sudit')) spawned.push(result);
  return result;
};
syncBuiltinESMExports();
const [huk, casesFile] = process.argv.slice(2);
for (const k of Object.keys(process.env)) {
  if (k.startsWith('HARNESS_') || k.startsWith('OMP_') || k.startsWith('ODIN')) delete process.env[k];
}
let mod;
try {
  mod = await import(pathToFileURL(huk).href);
} catch (e) {
  console.error('НЕТ ИМПОРТА ХУКА: ' + String(e).slice(0, 200)); process.exit(2);
}
const reg = typeof mod.register === 'function' ? mod.register
  : (typeof mod.default === 'function' ? mod.default : null);
if (reg === null) { console.error('НЕТ register'); process.exit(2); }
const handlers = [];
const pi = { on: (_name, handler) => { handlers.push(handler); } };
reg(pi);
if (handlers.length < 1) { console.error('НЕТ обработчика'); process.exit(2); }
const handler = handlers[handlers.length - 1];
const cases = JSON.parse(readFileSync(casesFile, 'utf8'));
function snapshot(root) {
  return readdirSync(root).sort().map(name => {
    const path = root + '/' + name;
    return [name, statSync(path).isDirectory() ? snapshot(path) : readFileSync(path).toString('hex')];
  });
}
let bad = 0;
for (const c of cases) {
  let got;
  spawned.length = 0;
  const before = c.unchanged ? JSON.stringify(snapshot(c.unchanged)) : null;
  try {
    if (c.cwd) process.chdir(c.cwd);
    const verdict = await Promise.race([
      Promise.resolve(handler(c.event, {
        sessionManager: { getSessionFile: () => c.sessfile },
      })),
      new Promise((_, rej) => setTimeout(() => rej(new Error('таймаут 30с')), 30000)),
    ]);
    got = verdict === undefined ? 'pass' : 'блок';
    if (verdict !== undefined) got += ':' + String(verdict.reason ?? '');
  } catch (e) {
    got = 'сбой:' + String(e && e.message ? e.message : e).slice(0, 120);
  }
  const unchanged = !c.unchanged || JSON.stringify(snapshot(c.unchanged)) === before;
  let warning = true;
  if (c.warn) {
    const prefix = `ПРЕДУПРЕЖДЕНИЕ: ${c.warn}: `;
    const emitted = spawned.some(r => r.status === 0 &&
      String(r.stderr ?? '').split('\n').some(line => line.startsWith(prefix) && line.length > prefix.length));
    let rows = [];
    try {
      rows = readFileSync(c.ledger, 'utf8').trim().split('\n').map(line => JSON.parse(line));
    } catch {}
    const recorded = rows.some(r => r.t === 'warn' && r.repoId === 'dev-harness' &&
      r.subjectId === c.subject && r.kod === c.warn);
    const started = rows.some(r => r.t === 'START' && r.repoId === 'dev-harness' &&
      r.subjectId === c.subject && r.holder === c.holder &&
      (!c.object || r.object === c.object));
    const released = !c.release || rows.some(r => r.t === 'RELEASE' &&
      r.repoId === 'dev-harness' && r.subjectId === c.subject &&
      r.holder === c.release && r.prichina === 'broshen');
    warning = emitted && recorded && started && released;
  }
  const ok = unchanged && warning && (c.want === 'pass' ? got === 'pass'
    : (got.startsWith('блок:') && got.includes(c.want.slice(6))));
  if (!ok) bad++;
  console.log(`GOT ${c.name} ${ok ? 'ok' : 'fail'} want=${c.want} got=${got} unchanged=${unchanged} warning=${warning}`);
}
console.log(`СЛУЧАЕВ ${cases.length} ПРОВАЛЕНО ${bad}`);
process.exit(bad > 0 ? 1 : 0);
MJS

# ── мир станции: состояние + журналы + реестр (грамматика корней — контракта) ─
# sessfile: <st>/zones/dev/.omp/profiles/dev/agent/sessions/c1/p1/Lead.jsonl
# ⇒ хук выводит: корень журналов …/agent/sessions, корень формулы 028 — префикс
# перед /zones/, --sostojanie <корень>/zamok (инвариант 1 контракта).
mir_sess() { printf '%s/zones/dev/.omp/profiles/dev/agent/sessions/c1/p1/Lead.jsonl' "$1"; }
mir_zhur() { printf '%s/zones/dev/.omp/profiles/dev/agent/sessions' "$1"; }

mir_github() {  # <каталог> <remote>
  git -C "$1" init -q . 2>/dev/null
  git -C "$1" remote add origin "$2" 2>/dev/null
  git -C "$1" -c user.name=b -c user.email=b@t -c commit.gpgsign=false commit -q --allow-empty -m w 2>/dev/null
}

mir_kontrakt() {  # <реестр> <nnn> <риск>
  mkdir -p "$1/contracts"
  printf '# К\nКЛАСС РИСКА: %s\n' "$3" > "$1/contracts/$2-stub.md"
  git -C "$1" add -A 2>/dev/null
  git -C "$1" -c user.name=b -c user.email=b@t -c commit.gpgsign=false commit -q -m "c$2" 2>/dev/null
}

mir_frozen_kontrakt() {  # <репозиторий владельца> <nnn> <риск>
  local pin tag="frozen/contracts/$2/1"
  mir_kontrakt "$@"
  # Сначала замораживаем контракт, затем коммитим pin TAG-объекта, не commit.
  git -C "$1" -c user.name=b -c user.email=b@t -c tag.gpgsign=false tag -a "$tag" -m "frozen$2"
  pin="$(git -C "$1" rev-parse "refs/tags/$tag")"
  mkdir -p "$1/registry"
  printf '%s → %s\n' "$2" "$pin" >> "$1/registry/contracts.tsv"
  git -C "$1" add registry/contracts.tsv
  git -C "$1" -c user.name=b -c user.email=b@t -c commit.gpgsign=false commit -q -m "pin$2"
}

mir_start() {  # <st> <nnn> <holder> <klass> <rol> <group> <object> <wt> <branch>
  mkdir -p "$1/zamok"
  jq -cn --arg s "$2" --arg h "$3" --arg k "$4" --arg r "$5" --arg g "$6" --arg o "$7" --arg w "$8" --arg b "$9" \
    '{t:"START",repoId:"dev-harness",subjectId:$s,group:$g,holder:$h,klass:$k,rol:$r,object:$o,worktree:$w,branch:$b,at:"2026-10-25T10:00:00Z"}' >> "$1/zamok/uchet.jsonl"
  mkdir -p "$1/zamok/zamki/dev-harness/$2/zanyat"
  jq -cn --arg h "$3" --arg k "$4" --arg r "$5" --arg o "$7" --arg w "$8" --arg b "$9" \
    '{holder:$h,klass:$k,rol:$r,object:$o,worktree:$w,branch:$b,startedAt:"2026-10-25T10:00:00Z"}' > "$1/zamok/zamki/dev-harness/$2/zanyat/holder.json"
}

mir_zhurnal() {  # <st> <holder> <sдал 0|1> <возраст-мин|->
  local d; d="$(dirname "$(mir_sess "$1")")"
  mkdir -p "$d"
  local f="$d/$2.jsonl"
  printf '{"timestamp":"2026-10-25T10:00:00.000Z","message":{"role":"assistant"}}\n' > "$f"
  if [ "$3" = 1 ]; then
    printf '{"type":"toolResult","toolCallId":"toolu_x","toolName":"yield","content":[{"type":"text","text":"Result submitted."}]}\n' >> "$f"
  fi
  if [ "$4" != - ]; then touch -d "$4 minutes ago" "$f"; fi
}

sobytie() {  # <файл> <agent> <name> <true|false|missing|string|number|object> <task…>
  local f="$1" a="$2" n="$3" iso="$4" json; shift 4
  case "$iso" in
    true|false) json="$iso" ;;
    missing) json=null ;;
    string) json='"true"' ;;
    number) json=1 ;;
    object) json='{}' ;;
    *) return 2 ;;
  esac
  local task; task="$(printf '%s\n' "$@")"
  jq -cn --arg a "$a" --arg n "$n" --arg t "$task" --arg iso "$iso" --argjson value "$json" \
    '{agent:$a,name:$n,task:$t} + (if $iso == "missing" then {} else {isolated:$value} end)' > "$f"
  printf '%s' "$f"
}

kejs() {  # <файл> <name> <want> <event.json> <sessfile> <cwd>
  jq -cn --arg n "$2" --arg w "$3" --slurpfile e "$4" --arg s "$5" --arg c "$6" \
    '[{name:$n,want:$w,event:{type:"tool_call",toolName:"task",toolCallId:$n,input:$e[0]},sessfile:$s,cwd:$c}]' > "$1"
}

kejs_warn() {  # файл имя код subject holder event sessfile cwd ledger [object] [release]
  jq -cn --arg n "$2" --arg k "$3" --arg sub "$4" --arg h "$5" \
    --slurpfile e "$6" --arg s "$7" --arg c "$8" --arg l "$9" \
    --arg o "${10:-}" --arg rel "${11:-}" \
    '[{name:$n,want:"pass",warn:$k,subject:$sub,holder:$h,ledger:$l,object:$o,release:$rel,
       event:{type:"tool_call",toolName:"task",toolCallId:$n,input:$e[0]},sessfile:$s,cwd:$c}]' > "$1"
}

begi() {  # <хук> <cases> → вывод драйвера
  ( cd / && node "$W/drajver.mjs" "$1" "$2" )
}

# ── p01 дубль живого рабочего (приёмка 5а) ────────────────────────────────────
{
  ST="$W/p01/st"; RE="$W/p01/repo"; WT="$W/p01/wt140"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_start "$ST" 140 Arch140 rabochij architect harness - "$WT" wip/140/avtor
  mir_zhurnal "$ST" Arch140 0 -
  sobytie "$W/p01/ev.json" architect Arch140b true 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  kejs "$W/p01/c.json" p01 'block:RABOCHIJ_ZHIV' "$W/p01/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p01/c.json")" && proba p01-int-dubl-rabochego ok || proba p01-int-dubl-rabochego krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p02 судья до yield автора (класс свидетеля критика) ──────────────────────
{
  ST="$W/p02/st"; RE="$W/p02/repo"; WT="$W/p02/wt140"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_kontrakt "$RE" 140 обычный
  mir_start "$ST" 140 Arch140 rabochij architect harness "$SHA" "$WT" wip/140/avtor
  mir_zhurnal "$ST" Arch140 0 -
  sobytie "$W/p02/ev.json" critic Critic140 missing 'SUBJECT=140' "OBJECT=$SHA" > /dev/null
  kejs "$W/p02/c.json" p02 'block:RABOCHIJ_ZHIV' "$W/p02/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p02/c.json")" && proba p02-int-sudja-do-yield ok || proba p02-int-sudja-do-yield krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p03 судья без OBJECT (приёмка 5б) ────────────────────────────────────────
{
  ST="$W/p03/st"; RE="$W/p03/repo"; WT="$W/p03/wt141"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/141/avtor 2>/dev/null
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_kontrakt "$RE" 141 обычный
  mir_start "$ST" 141 Avtor141 rabochij architect harness "$SHA" "$WT" wip/141/avtor
  mir_zhurnal "$ST" Avtor141 1 -
  sobytie "$W/p03/ev.json" critic Critic141 missing 'SUBJECT=141' 'суд без строки объекта' > /dev/null
  kejs "$W/p03/c.json" p03 'block:OBJECT_OTSTUTSVUET' "$W/p03/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p03/c.json")" && proba p03-int-sudja-bez-object ok || proba p03-int-sudja-bez-object krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p04 OBJECT ≠ tip ветки автора ────────────────────────────────────────────
{
  ST="$W/p04/st"; RE="$W/p04/repo"; WT="$W/p04/wt141"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/141/avtor 2>/dev/null
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_kontrakt "$RE" 141 обычный
  mir_start "$ST" 141 Avtor141 rabochij architect harness "$SHA" "$WT" wip/141/avtor
  mir_zhurnal "$ST" Avtor141 1 -
  sobytie "$W/p04/ev.json" critic Critic141 missing 'SUBJECT=141' 'OBJECT=1234567890123456789012345678901234567890' > /dev/null
  kejs_warn "$W/p04/c.json" p04 OBJECT_RASHODITSJA 141 Critic141 "$W/p04/ev.json" "$(mir_sess "$ST")" "$RE" "$ST/zamok/uchet.jsonl" "$SHA"
  out="$(begi "$HUK" "$W/p04/c.json")" && proba p04-int-object-rashoditsja ok || proba p04-int-object-rashoditsja krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p05 порядок: рисковый ревьюер раньше адверсария ──────────────────────────
{
  ST="$W/p05/st"; RE="$W/p05/repo"; WT="$W/p05/wt141"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/141/avtor 2>/dev/null
  # OBJECT сохраняет непустую дельту кандидата; класс берётся из frozen RE
  # (одинаковый origin у RE и WT), а не из дерева OBJECT.
  mir_kontrakt "$WT" 141 рисковый
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_frozen_kontrakt "$RE" 141 рисковый
  mir_start "$ST" 141 Avtor141 rabochij architect harness "$SHA" "$WT" wip/141/avtor
  mir_zhurnal "$ST" Avtor141 1 -
  sobytie "$W/p05/ev.json" reviewer Rev141 missing 'SUBJECT=141' "OBJECT=$SHA" > /dev/null
  kejs "$W/p05/c.json" p05 'block:ADVERSARIJ_DO_REVJUERA' "$W/p05/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p05/c.json")" && proba p05-int-porjadok-adv-rev ok || proba p05-int-porjadok-adv-rev krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p06 лимит harness: 3 из 3 занято (слово владельца 2026-10-28: 1/3/2 → 3/3/3) ─
{
  ST="$W/p06/st"; RE="$W/p06/repo"
  WT141="$W/p06/wt141"; WT142="$W/p06/wt142"; WT143="$W/p06/wt143"; WT144="$W/p06/wt144"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT141" "$WT142" "$WT143" "$WT144"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT141" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT142" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT143" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT144" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT141" checkout -q -b wip/141/avtor 2>/dev/null
  git -C "$WT142" checkout -q -b wip/142/avtor 2>/dev/null
  git -C "$WT143" checkout -q -b wip/143/avtor 2>/dev/null
  git -C "$WT144" checkout -q -b wip/144/avtor 2>/dev/null
  mir_start "$ST" 141 Arch141 rabochij architect harness - "$WT141" wip/141/avtor
  mir_zhurnal "$ST" Arch141 0 -
  mir_start "$ST" 142 Arch142 rabochij architect harness - "$WT142" wip/142/avtor
  mir_zhurnal "$ST" Arch142 0 -
  mir_start "$ST" 143 Arch143 rabochij architect harness - "$WT143" wip/143/avtor
  mir_zhurnal "$ST" Arch143 0 -
  sobytie "$W/p06/ev.json" architect Arch144 true 'SUBJECT=144' "WORKTREE=$WT144" 'BRANCH=wip/144/avtor' > /dev/null
  kejs_warn "$W/p06/c.json" p06 LIMIT_GRUPPY 144 Arch144 "$W/p06/ev.json" "$(mir_sess "$ST")" "$RE" "$ST/zamok/uchet.jsonl"
  out="$(begi "$HUK" "$W/p06/c.json")" && proba p06-int-limit-harness ok || proba p06-int-limit-harness krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p07 атомарный пакет: дубль предмета в batch — блок всего, занятий ноль ───
{
  ST="$W/p07/st"; RE="$W/p07/repo"; WT="$W/p07/wt140"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  sobytie "$W/p07/a.json" architect Arch140 true 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  sobytie "$W/p07/b.json" architect Arch140b true 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  jq -s '{tasks:.}' "$W/p07/a.json" "$W/p07/b.json" > "$W/p07/ev.json"
  kejs "$W/p07/c.json" p07 'block:DUBL_V_PAKETE' "$W/p07/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p07/c.json")"
  if [ $? -eq 0 ] && [ ! -e "$ST/zamok/zamki/dev-harness/140/zanyat/holder.json" ]; then
    proba p07-int-paket-atomarnyj ok
  else
    proba p07-int-paket-atomarnyj krasno "$(printf '%s' "$out" | grep '^GOT' | head -1); занятие=$( [ -e "$ST/zamok/zamki/dev-harness/140/zanyat/holder.json" ] && printf есть || printf нет )"
  fi
}

# ── p08 гонка двух tool_call: ровно один пропуск ─────────────────────────────
{
  ST="$W/p08/st"; RE="$W/p08/repo"; WT="$W/p08/wt143"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/143/avtor 2>/dev/null
  sobytie "$W/p08/ev.json" architect Arch143 true 'SUBJECT=143' "WORKTREE=$WT" 'BRANCH=wip/143/avtor' > /dev/null
  kejs "$W/p08/ca.json" p08a 'pass' "$W/p08/ev.json" "$(mir_sess "$ST")" "$RE"
  kejs "$W/p08/cb.json" p08b 'pass' "$W/p08/ev.json" "$(mir_sess "$ST")" "$RE"
  begi "$HUK" "$W/p08/ca.json" > "$W/p08/oa.txt" &
  begi "$HUK" "$W/p08/cb.json" > "$W/p08/ob.txt" &
  wait
  A="$(grep -c 'want=pass got=pass' "$W/p08/oa.txt" 2>/dev/null)"; A="${A:-0}"
  A2="$(grep -c 'want=pass got=pass' "$W/p08/ob.txt" 2>/dev/null)"; A2="${A2:-0}"
  B="$(grep -c 'got=блок' "$W/p08/oa.txt" 2>/dev/null)"; B="${B:-0}"
  B2="$(grep -c 'got=блок' "$W/p08/ob.txt" 2>/dev/null)"; B2="${B2:-0}"
  PROSHLO=$((A + A2)); ZABLOKIROVANO=$((B + B2))
  if [ "$PROSHLO" = 1 ] && [ "$ZABLOKIROVANO" = 1 ]; then
    proba p08-int-gonka ok
  else
    proba p08-int-gonka krasno "пропусков $PROSHLO, блоков $ZABLOKIROVANO (ожидано 1 и 1 — атомарность замка)"
  fi
}

# ── p09 дубль после рестарта (брошенный замок) ───────────────────────────────
{
  ST="$W/p09/st"; RE="$W/p09/repo"; WT="$W/p09/wt140"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  mir_start "$ST" 140 Arch140 rabochij architect harness - "$WT" wip/140/avtor
  mir_zhurnal "$ST" Arch140 0 120
  sobytie "$W/p09/ev.json" architect Arch140c true 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  kejs_warn "$W/p09/c.json" p09 ZAMOK_BROSHEN 140 Arch140c "$W/p09/ev.json" "$(mir_sess "$ST")" "$RE" "$ST/zamok/uchet.jsonl" '' Arch140
  out="$(begi "$HUK" "$W/p09/c.json")" && proba p09-int-dubl-posle-restarta ok || proba p09-int-dubl-posle-restarta krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p10 пропуск судьи после yield + START пишет РАСШИРЕНИЕ ───────────────────
for ISO in false true missing string number object; do
  P="$W/p10-$ISO"
  ST="$P/st"; RE="$P/repo"; WT="$P/wt141"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/141/avtor 2>/dev/null
  # Контракт кандидата даёт непустой OBJECT; pinned frozen владельца — в RE.
  mir_kontrakt "$WT" 141 обычный
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_frozen_kontrakt "$RE" 141 обычный
  mir_start "$ST" 141 Avtor141 rabochij architect harness "$SHA" "$WT" wip/141/avtor
  mir_zhurnal "$ST" Avtor141 1 -
  sobytie "$P/ev.json" critic Critic141 "$ISO" 'SUBJECT=141' "OBJECT=$SHA" > /dev/null
  kejs "$P/c.json" "p10-$ISO" 'pass' "$P/ev.json" "$(mir_sess "$ST")" "$RE"
  # Оракул — значение клетки, снятое ДО вызова; отсутствие нормализуется в false.
  FACT=false; [ "$ISO" != true ] || FACT=true
  out="$(begi "$HUK" "$P/c.json")"; rc=$?
  if [ $rc -eq 0 ] && jq -se --argjson fact "$FACT" \
      '[.[] | select(.t=="START" and .holder=="Critic141" and .klass=="sudja")] |
       length == 1 and .[0].isolated == $fact' "$ST/zamok/uchet.jsonl" > /dev/null 2>&1 \
      && [ -e "$ST/zamok/zamki/dev-harness/141/zanyat/holder.json" ]; then
    proba "p10-int-propusk-posle-yield-$ISO" ok
  else
    proba "p10-int-propusk-posle-yield-$ISO" krasno "$out; ожидался ровно один START судьи isolated=$FACT и занятие"
  fi
done

# ── p11 алфавит 104 не ослаблен (вне алфавита — блок) ────────────────────────
{
  ST="$W/p11/st"; RE="$W/p11/repo"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  sobytie "$W/p11/ev.json" hacker H1 missing 'SUBJECT=140' 'злой агент' > /dev/null
  kejs "$W/p11/c.json" p11 'block:вне алфавита' "$W/p11/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p11/c.json")" && proba p11-int-alfavit-104 ok || proba p11-int-alfavit-104 krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p12 чужой инструмент (toolName≠task) не трогается ────────────────────────
{
  ST="$W/p12/st"; RE="$W/p12/repo"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  jq -cn '[{name:"p12",want:"pass",sessfile:"'"$(mir_sess "$ST")"'",cwd:"'"$RE"'",event:{type:"tool_call",toolName:"write",toolCallId:"w1",input:{path:"x.txt",agent:"task"}}}]' > "$W/p12/c.json"
  out="$(begi "$HUK" "$W/p12/c.json")" && proba p12-int-ne-task ok || proba p12-int-ne-task krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p13 fail-closed: дверь rc 2 → блок «страж сломан» ────────────────────────
{
  ST="$W/p13/st"; RE="$W/p13/repo"; WT="$W/p13/wt140"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  chmod 000 "$ST/zamok"
  sobytie "$W/p13/ev.json" architect Arch140 true 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  kejs "$W/p13/c.json" p13 'block:сломан' "$W/p13/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p13/c.json")" && proba p13-int-fail-closed ok || proba p13-int-fail-closed krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
  chmod 755 "$ST/zamok"
}

# ── p14 --uchet живого мира (приёмка 5в; прямой вызов поставленной двери) ────
{
  ST="$W/p14/st"; RE="$W/p14/repo"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_kontrakt "$RE" 143 обычный
  mkdir -p "$RE/registry"; printf '143\t2026-10-24\tвладелец\tпозже\n' > "$RE/registry/pauzy.tsv"
  git -C "$RE" add -A 2>/dev/null; git -C "$RE" -c user.name=b -c user.email=b@t -c commit.gpgsign=false commit -q -m p143 2>/dev/null
  git -C "$RE" tag done/contracts/144/1 2>/dev/null
  mir_start "$ST" 141 Arch141 rabochij architect harness - - -
  mir_zhurnal "$ST" Arch141 0 -
  mir_start "$ST" 142 Impl142 rabochij implementer harness - - -
  mir_zhurnal "$ST" Impl142 1 -
  if [ ! -f "$DVER" ]; then
    proba p14-int-uchet krasno "SUBJECT_ABSENT: нет поставленной двери $DVER"
  else
    out="$(bash "$DVER" --uchet --sostojanie "$ST/zamok" --zhurnaly "$(mir_zhur "$ST")" --repo "$RE" 2>&1)"
    if printf '%s' "$out" | grep -q $'^UCHET\tdev-harness\t141\tharness\tArch141\trabochij\tbezhit' \
       && printf '%s' "$out" | grep -q $'^UCHET\tdev-harness\t142\tharness\tImpl142\trabochij\tyield' \
       && printf '%s' "$out" | grep -q $'^GRP\tharness\t'; then
      proba p14-int-uchet ok
    else
      proba p14-int-uchet krasno "$(printf '%s' "$out" | head -2 | tr '\n' ' ')"
    fi
  fi
}

# ── p15 последний рабочий красит ВЕСЬ пакет; пустой учёт УЖЕ существует ──
# Не заменять этим миром новый корень p17/p18: отсутствие файла — часть оракула.
for ISO in false missing string number object; do
  P="$W/p15-$ISO"
  ST="$P/st"; RE="$P/repo"; WT="$P/wt140"; WT142="$P/wt142"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT" "$WT142"
  : > "$ST/zamok/uchet.jsonl"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT142" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  git -C "$WT142" checkout -q -b wip/142/avtor 2>/dev/null
  sobytie "$P/good.json" architect Arch142 true 'SUBJECT=142' "WORKTREE=$WT142" 'BRANCH=wip/142/avtor' > /dev/null
  sobytie "$P/bad.json" architect Arch140 "$ISO" 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  jq -s '{tasks:.}' "$P/good.json" "$P/bad.json" > "$P/ev.json"
  kejs "$P/c0.json" "p15-$ISO" 'block:ОТКАЗ: NE_IZOLIROVAN: item 1:' "$P/ev.json" "$(mir_sess "$ST")" "$RE"
  jq --arg root "$ST/zamok" '.[0].unchanged=$root' "$P/c0.json" > "$P/c.json"
  out="$(begi "$HUK" "$P/c.json")" \
    && proba "p15-int-rabochij-$ISO" ok \
    || proba "p15-int-rabochij-$ISO" krasno "$out"
done

# ── p16 разрешённый смешанный пакет: свой факт у каждого item ────────────
# Соседняя форма той же мутации: судью нельзя записать true по классу/соседу.
for ISO in false string number object; do
  P="$W/p16-$ISO"; ST="$P/st"; RE="$P/repo"; WT="$P/wt141"; WT142="$P/wt142"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT" "$WT142"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT142" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/141/avtor 2>/dev/null
  git -C "$WT142" checkout -q -b wip/142/avtor 2>/dev/null
  mir_kontrakt "$WT" 141 обычный
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_frozen_kontrakt "$RE" 141 обычный
  mir_start "$ST" 141 Avtor141 rabochij architect harness "$SHA" "$WT" wip/141/avtor
  mir_zhurnal "$ST" Avtor141 1 -
  sobytie "$P/worker.json" architect Arch142 true 'SUBJECT=142' "WORKTREE=$WT142" 'BRANCH=wip/142/avtor' > /dev/null
  sobytie "$P/judge.json" critic Critic141 "$ISO" 'SUBJECT=141' "OBJECT=$SHA" > /dev/null
  jq -s '{tasks:.}' "$P/worker.json" "$P/judge.json" > "$P/ev.json"
  kejs "$P/c.json" "p16-$ISO" pass "$P/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$P/c.json")"; rc=$?
  if [ "$rc" -eq 0 ] && jq -se '
      [.[] | select(.t=="START") | {holder,subjectId,isolated}] ==
      [{holder:"Avtor141",subjectId:"141",isolated:null},
       {holder:"Arch142",subjectId:"142",isolated:true},
       {holder:"Critic141",subjectId:"141",isolated:false}]' \
      "$ST/zamok/uchet.jsonl" > /dev/null 2>&1 \
      && [ -e "$ST/zamok/zamki/dev-harness/142/zanyat/holder.json" ] \
      && [ -e "$ST/zamok/zamki/dev-harness/141/zanyat/holder.json" ]; then
    proba "p16-int-smeshannyj-paket-$ISO" ok
  else
    proba "p16-int-smeshannyj-paket-$ISO" krasno "$out; START пакета обязан нести Arch142=true, Critic141=false и оба занятия"
  fi
done

# ── p17/p18 новый корень; p19 ранее существующие учёт И занятие ──────────
# snapshot() драйвера снимает имена и байты ДО хука. В p17/p18 zamok пуст,
# ucheт НЕ создаётся построителем; p19 содержит чужой живой предмет.
for WORLD in p17 p18 p19; do
  for ISO in false missing string number object; do
    P="$W/$WORLD-$ISO"; ST="$P/st"; RE="$P/repo"; WT="$P/wt140"; WT142="$P/wt142"
    mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT" "$WT142"
    mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
    mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
    mir_github "$WT142" 'ssh://git@github.com/a3ka/dev-harness.git'
    git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
    git -C "$WT142" checkout -q -b wip/142/avtor 2>/dev/null
    if [ "$WORLD" = p19 ]; then
      mir_start "$ST" 143 Avtor143 rabochij architect harness - - -
      mir_zhurnal "$ST" Avtor143 0 -
    fi
    sobytie "$P/bad.json" architect Arch140 "$ISO" 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
    if [ "$WORLD" = p17 ]; then
      cp "$P/bad.json" "$P/ev.json"
      ITEM=0
      NAME="p17-int-novyj-uchet-odin-$ISO"
    else
      sobytie "$P/good.json" architect Arch142 true 'SUBJECT=142' "WORKTREE=$WT142" 'BRANCH=wip/142/avtor' > /dev/null
      jq -s '{tasks:.}' "$P/good.json" "$P/bad.json" > "$P/ev.json"
      ITEM=1
      if [ "$WORLD" = p18 ]; then
        NAME="p18-int-novyj-uchet-paket-$ISO"
      else
        NAME="p19-int-sushchestvujushchij-uchet-$ISO"
      fi
    fi
    kejs "$P/c0.json" "$NAME" "block:ОТКАЗ: NE_IZOLIROVAN: item $ITEM:" "$P/ev.json" "$(mir_sess "$ST")" "$RE"
    jq --arg root "$ST/zamok" '.[0].unchanged=$root' "$P/c0.json" > "$P/c.json"
    out="$(begi "$HUK" "$P/c.json")" \
      && proba "$NAME" ok \
      || proba "$NAME" krasno "$out"
  done
done

# ── p20 первый честный спавн: отсутствие учёта не означает отказ всем ────
{
  P="$W/p20"; ST="$P/st"; RE="$P/repo"; WT="$P/wt140"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  sobytie "$P/ev.json" architect Arch140 true 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  kejs "$P/c.json" p20 pass "$P/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$P/c.json")"; rc=$?
  if [ "$rc" -eq 0 ] && jq -se '
      [.[] | {t,holder,subjectId,klass,isolated}] ==
      [{t:"START",holder:"Arch140",subjectId:"140",klass:"rabochij",isolated:true}]' \
      "$ST/zamok/uchet.jsonl" > /dev/null 2>&1 \
      && jq -e '.holder=="Arch140" and .klass=="rabochij" and .rol=="architect"' \
        "$ST/zamok/zamki/dev-harness/140/zanyat/holder.json" > /dev/null 2>&1; then
    proba p20-int-pervyj-rabochij-true ok
  else
    proba p20-int-pervyj-rabochij-true krasno "$out; ожидались собственный START isolated=true и занятие"
  fi
}

# ── m01 обманная интеграция: блок вызова двери снят — симптом обязан быть виден ─
# Мутация хука КОДОМ по якорям контракта (маркеры [ZAMOK140] начала/конца блока
# вызова двери): блок вырезается. Приёмка обязана видеть симптом — судья до
# yield ПРОХОДИТ. Если мутация не строится (якорей нет — интеграции нет) —
# KRASNO: живое дерево само есть эта обманка (p02 тогда тоже KRASNO).
{
  ST="$W/m01/st"; RE="$W/m01/repo"; WT="$W/m01/wt140"; INST="$W/m01/inst"
  if [ ! -f "$DVER" ]; then
    proba m01-huk-bez-dveri krasno "SUBJECT_ABSENT: нет двери $DVER — обманка не строится; интеграции нет (p02 KRASNO = тот же класс)"
  elif ! grep -q '// \[ZAMOK140\] начало блока вызова двери' "$HUK" || ! grep -q '// \[ZAMOK140\] конец блока вызова двери' "$HUK"; then
    proba m01-huk-bez-dveri krasno "якорь [ZAMOK140] не найден в хуке — интеграции нет; живое дерево = та же обманка (p02 KRASNO)"
  else
    mkdir -p "$INST/.omp/extensions" "$INST/scripts" "$INST/config" "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
    cp "$HUK" "$INST/.omp/extensions/spawn-guard.ts"
    cp "$DVER" "$INST/scripts/zamok_predmeta.sh"
    cp "$REPO_HARNESS/config/agent_models.json" "$INST/config/agent_models.json"
    awk 'BEGIN{skip=0}
         /\/\/ \[ZAMOK140\] начало блока вызова двери/{skip=1; print "// [ZAMOK140] блок снят (обманная интеграция m01)"; next}
         /\/\/ \[ZAMOK140\] конец блока вызова двери/{skip=0; next}
         skip{next} {print}' "$HUK" > "$INST/.omp/extensions/spawn-guard.ts"
    mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
    mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
    git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
    SHA="$(git -C "$WT" rev-parse HEAD)"
    mir_kontrakt "$RE" 140 обычный
    mir_start "$ST" 140 Arch140 rabochij architect harness "$SHA" "$WT" wip/140/avtor
    mir_zhurnal "$ST" Arch140 0 -
    sobytie "$W/m01/ev.json" critic Critic140 missing 'SUBJECT=140' "OBJECT=$SHA" > /dev/null
    kejs "$W/m01/c.json" m01 'block:RABOCHIJ_ZHIV' "$W/m01/ev.json" "$(mir_sess "$ST")" "$RE"
    out="$(begi "$INST/.omp/extensions/spawn-guard.ts" "$W/m01/c.json")"; rc=$?
    # ожидание обманки: водитель ХУКА пропускает (fail) — симптом воспроизведён,
    # приёмка (p02 на живом дереве) этот класс ловит; блок = мутация неэффективна
    if [ $rc -ne 0 ]; then
      proba m01-huk-bez-dveri ok
    else
      proba m01-huk-bez-dveri krasno "обманка всё равно блокирует — симптом класса не воспроизведён"
    fi
  fi
}

printf 'PROB VSEGO %d KRASNYH %d\n' "$VSEGO" "$KRASNYH"
[ "$KRASNYH" -eq 0 ] && exit 0
exit 1
