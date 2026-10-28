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
# (класс свидетеля критика); p03 судья без OBJECT (приёмка 5б); p04 OBJECT≠tip;
# p05 порядок адверсарий→ревьюер; p06 лимит harness 3 из 3 (слово владельца 2026-10-28: 1/3/2 → 3/3/3); p07 атомарный пакет
# (дубль предмета в batch — блок всего пакета, занятий ноль); p08 гонка двух
# tool_call — ровно один пропуск; p09 дубль после рестарта; p10 пропуск судьи
# после yield + START пишет РАСШИРЕНИЕ; p11 алфавит 104 не ослаблен; p12 чужой
# инструмент (toolName≠task) не трогается; p13 fail-closed (дверь rc 2 → блок
# «страж сломан»); p14 --uchet живого мира (приёмка 5в); m01 обманная
# интеграция — блок вызова двери снят, приёмка обязана видеть симптом
# (проход судьи до yield) — проверка проверяющего (tdd: не tautological).
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
import { readFileSync } from 'node:fs';
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
let bad = 0;
for (const c of cases) {
  let got;
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
  const ok = c.want === 'pass' ? got === 'pass'
    : (got.startsWith('блок:') && got.includes(c.want.slice(6)));
  if (!ok) bad++;
  console.log(`GOT ${c.name} ${ok ? 'ok' : 'fail'} want=${c.want} got=${got}`);
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

sobytie() {  # <файл> <agent> <name> <task-строки…>
  local f="$1" a="$2" n="$3"; shift 3
  local task; task="$(printf '%s\n' "$@")"
  jq -cn --arg a "$a" --arg n "$n" --arg t "$task" '{agent:$a,name:$n,task:$t}' > "$f"
  printf '%s' "$f"
}

kejs() {  # <файл> <name> <want> <event.json> <sessfile> <cwd>
  jq -cn --arg n "$2" --arg w "$3" --slurpfile e "$4" --arg s "$5" --arg c "$6" \
    '[{name:$n,want:$w,event:{type:"tool_call",toolName:"task",toolCallId:$n,input:$e[0]},sessfile:$s,cwd:$c}]' > "$1"
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
  sobytie "$W/p01/ev.json" architect Arch140b 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
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
  sobytie "$W/p02/ev.json" critic Critic140 'SUBJECT=140' "OBJECT=$SHA" > /dev/null
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
  sobytie "$W/p03/ev.json" critic Critic141 'SUBJECT=141' 'суд без строки объекта' > /dev/null
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
  sobytie "$W/p04/ev.json" critic Critic141 'SUBJECT=141' 'OBJECT=1234567890123456789012345678901234567890' > /dev/null
  kejs "$W/p04/c.json" p04 'block:OBJECT_RASHODITSJA' "$W/p04/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p04/c.json")" && proba p04-int-object-rashoditsja ok || proba p04-int-object-rashoditsja krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p05 порядок: рисковый ревьюер раньше адверсария ──────────────────────────
{
  ST="$W/p05/st"; RE="$W/p05/repo"; WT="$W/p05/wt141"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/141/avtor 2>/dev/null
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_kontrakt "$RE" 141 рисковый
  mir_start "$ST" 141 Avtor141 rabochij architect harness "$SHA" "$WT" wip/141/avtor
  mir_zhurnal "$ST" Avtor141 1 -
  sobytie "$W/p05/ev.json" reviewer Rev141 'SUBJECT=141' "OBJECT=$SHA" > /dev/null
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
  sobytie "$W/p06/ev.json" architect Arch144 'SUBJECT=144' "WORKTREE=$WT144" 'BRANCH=wip/144/avtor' > /dev/null
  kejs "$W/p06/c.json" p06 'block:LIMIT_GRUPPY' "$W/p06/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p06/c.json")" && proba p06-int-limit-harness ok || proba p06-int-limit-harness krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p07 атомарный пакет: дубль предмета в batch — блок всего, занятий ноль ───
{
  ST="$W/p07/st"; RE="$W/p07/repo"; WT="$W/p07/wt140"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/140/avtor 2>/dev/null
  sobytie "$W/p07/a.json" architect Arch140 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  sobytie "$W/p07/b.json" architect Arch140b 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
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
  sobytie "$W/p08/ev.json" architect Arch143 'SUBJECT=143' "WORKTREE=$WT" 'BRANCH=wip/143/avtor' > /dev/null
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
  sobytie "$W/p09/ev.json" architect Arch140c 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
  kejs "$W/p09/c.json" p09 'block:ZAMOK_BROSHEN' "$W/p09/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p09/c.json")" && proba p09-int-dubl-posle-restarta ok || proba p09-int-dubl-posle-restarta krasno "$(printf '%s' "$out" | grep '^GOT' | head -1)"
}

# ── p10 пропуск судьи после yield + START пишет РАСШИРЕНИЕ ───────────────────
{
  ST="$W/p10/st"; RE="$W/p10/repo"; WT="$W/p10/wt141"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE" "$WT"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  mir_github "$WT" 'ssh://git@github.com/a3ka/dev-harness.git'
  git -C "$WT" checkout -q -b wip/141/avtor 2>/dev/null
  SHA="$(git -C "$WT" rev-parse HEAD)"
  mir_kontrakt "$RE" 141 обычный
  mir_start "$ST" 141 Avtor141 rabochij architect harness "$SHA" "$WT" wip/141/avtor
  mir_zhurnal "$ST" Avtor141 1 -
  sobytie "$W/p10/ev.json" critic Critic141 'SUBJECT=141' "OBJECT=$SHA" > /dev/null
  kejs "$W/p10/c.json" p10 'pass' "$W/p10/ev.json" "$(mir_sess "$ST")" "$RE"
  out="$(begi "$HUK" "$W/p10/c.json")"; rc=$?
  if [ $rc -eq 0 ] && jq -e 'select(.t=="START" and .holder=="Critic141" and .klass=="sudja")' "$ST/zamok/uchet.jsonl" > /dev/null 2>&1 && [ -e "$ST/zamok/zamki/dev-harness/141/zanyat/holder.json" ]; then
    proba p10-int-propusk-posle-yield ok
  else
    proba p10-int-propusk-posle-yield krasno "$(printf '%s' "$out" | grep '^GOT' | head -1); START-судьи=$(jq -e 'select(.t=="START" and .holder=="Critic141")' "$ST/zamok/uchet.jsonl" > /dev/null 2>&1 && printf есть || printf нет)"
  fi
}

# ── p11 алфавит 104 не ослаблен (вне алфавита — блок) ────────────────────────
{
  ST="$W/p11/st"; RE="$W/p11/repo"
  mkdir -p "$ST/zamok" "$(dirname "$(mir_sess "$ST")")" "$RE"
  mir_github "$RE" 'ssh://git@github.com/a3ka/dev-harness.git'
  sobytie "$W/p11/ev.json" hacker H1 'SUBJECT=140' 'злой агент' > /dev/null
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
  sobytie "$W/p13/ev.json" architect Arch140 'SUBJECT=140' "WORKTREE=$WT" 'BRANCH=wip/140/avtor' > /dev/null
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
    sobytie "$W/m01/ev.json" critic Critic140 'SUBJECT=140' "OBJECT=$SHA" > /dev/null
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
