#!/usr/bin/env bash
# КРАСНОЕ 066 (Н-173): extractPin-грамматика (пара WORKTREE=/BRANCH= в любой
# строковой позиции задания + однострочная pin:-форма) И источник actual
# спавна в фабрике стража (событие > cwd bash-вызова > cwd демона).
#
# СУБЪЕКТ: .omp/extensions/path-guard.ts — CLI (--extract-pin/--judge) и
# фабрика register() (водится fab_driver: import + синтетический tool_call).
#
# ЖИВЫЕ БОЛИ ДО (замер пачки, дословно):
#   node path-guard.ts --extract-pin 'Complete assignment thoroughly:\n\n
#     WORKTREE=…\nBRANCH=wip/066/tester'  → {"worktree":null}   (а1)
#   … --extract-pin 'pin:WORKTREE=…:BRANCH=wip/066/tester' → {"worktree":null} (а2)
#   фабрика: bash-вызов с cwd=клон, события actual НЕТ → block Н-85/А-122 (б3)
#
# ПРИВЯЗКА К КОДУ (Н-39): каждая ветвь красна/зелена на СВОЁМ входе;
# стаб-мутанты (команды в contracts/066-*.md §Красные предъявления) умирают
# каждый на своей ветви:
#   * а0дв/а1/а1б — стаб «без /m» (снимаем флаг): все три ветви дают
#     null ≠ pin (двухстрочная пара и с префиксом, и без него);
#   * а2 — стаб «класс значения без исключения `:`» (вернуть [^\s,;]):
#     однострочная pin:-форма даёт null ≠ pin;
#   * б2 — стаб «actual = process.cwd() всегда» (обнулить eventActual):
#     фабрика блокирует запись в клон при cwd демона ≠ клон;
#   * б3 — стаб «args.cwd не читается» (обнулить argsActual; покрывается
#     и стабом «оба»): фабрика блокирует bash-запись в клон.
#   * а0/а3/а4/а5/б1a/б1b — контроли: зелёные ДО и ПОСЛЕ (а0 — форма,
#     принятая ДО 066: однострочная с «;»-разделителем; а3/а4/а5 —
#     негативы грамматики: две пары, basename-несоответствие, мёртвый путь
#     остаются null; б1a/б1b — М1-ветвь 037 ветвится по actual: клон → pass,
#     демон-cwd → block).
#
# ДО реализации КРАСНЫЕ: а0дв, а1, а1б, а2, б3 (5 ветвей). ПОСЛЕ — 12/12
# зелёные. Живой omp-провод текста задания — вне этой фикстуры (граница 032:
# арбитраж 0c98913 §2); фикстура судит фабрику+CLI.
#
# Прямой прогон (probe-only каталог, вне case_*-глоба раннера — прецедент
# fixtures/self_contained_cwd, 034 §Боль 1):
#   bash fixtures/path_guard/red_extract_pin_actual_066.sh [<корень>]
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
ROOT="$(cd "$ROOT" && pwd)"   # абсолютный: драйвер фабрики cd-ит в $WORK (А-241)
SUBJ="$ROOT/.omp/extensions/path-guard.ts"
[ -f "$SUBJ" ] || { printf 'субъект отсутствует — %s\n' "$SUBJ" >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'node отсутствует\n' >&2; exit 2; }

# А-88: уникальность прогонов mktemp-суффиксами; А-241: ../.. от файла.
NS_BASE=/tmp/dev-harness-worktrees
FH_BASE=/tmp/dev-harness-fakehome-066
WORK="$(mktemp -d /tmp/dev-harness-verify/pg066bat.XXXXXX)"
mkdir -p "$NS_BASE" "$FH_BASE" "$WORK"
trap 'rm -rf "$WORK" "$FH" "$R" "$NSDIR"' EXIT

# ── Сетап А: ЖИВОЙ linked worktree (git-оракул 032 судит живость) ────────────
R="$(mktemp -d "$NS_BASE/pg066repo.XXXXXX")"
git init -q "$R"
git -C "$R" -c user.name=pg066 -c user.email=pg066@t commit -q --allow-empty -m x
NSDIR="$(mktemp -d "$NS_BASE/pg066ns.XXXXXX")"
WT="$NSDIR/wip-066-tester"
git -C "$R" worktree add -q -b wip/066/tester "$WT"
BR=wip/066/tester

# ── Сетап Б: self-contained клон ВНЕ scratch-allowlist (037-прецедент) ───────
FH="$(mktemp -d "$FH_BASE/pg066home.XXXXXX")"
C="$FH/profiles/dev/wt/t1/m"
mkdir -p "$C"
git init -q "$C"
git -C "$C" -c user.name=pg066 -c user.email=pg066@t commit -q --allow-empty -m x
printf '{"pid":424242,"id":"TestOwner066","startToken":"1"}' \
  > "$FH/profiles/dev/wt/t1/.omp-isolation-owner.json"

# ── Драйвер фабрики: import субъекта + синтетический tool_call ───────────────
cat > "$WORK/fab_driver.mjs" <<'MJS'
import { pathToFileURL } from 'node:url';
const mod = await import(pathToFileURL(process.argv[2]).href);
const calls = [];
mod.default({ on: (n, h) => calls.push([n, h]) });
const pair = calls.find(([n]) => n === 'tool_call');
if (!pair) { console.error('tool_call handler не зарегистрирован'); process.exit(2); }
const r = pair[1](
  JSON.parse(process.argv[3]),
  { sessionManager: { getSessionFile: () => process.argv[4], getSessionId: () => 'sid066x' } },
);
console.log(JSON.stringify(r === undefined ? { decision: 'pass' } : r));
MJS

ORDER=(а0 а0дв а1 а1б а2 а3 а4 а5 б1a б1b б2 б3)
declare -A ST RAN
for m in "${ORDER[@]}"; do ST[$m]=0; RAN[$m]=0; done
fail() {
  RAN["$1"]=1; ST["$1"]=1
  printf 'КРАСНОЕ 066: ветвь «%s» — %s\n' "$1" "$2" >&2
}

# expect_pin <ветвь> <want: pin|null> <HOME-override|-> <text>
expect_pin() {
  local vetka="$1" want="$2" home="$3" text="$4" out rc got
  RAN["$vetka"]=1
  if [ "$home" = "-" ]; then
    out="$(node "$SUBJ" --extract-pin "$text")"; rc=$?
  else
    out="$(HOME="$home" node "$SUBJ" --extract-pin "$text")"; rc=$?
  fi
  [ "$rc" -eq 0 ] || { fail "$vetka" "rc $rc (вывод: ${out:-<пусто>})"; return; }
  got="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.worktree===null?"null":"pin")}catch(e){console.log("BAD_JSON")}})')"
  if [ "$want" = pin ]; then
    printf '%s' "$out" | grep -Fq "\"worktree\":\"$WT\"" \
      || { fail "$vetka" "ожидался пин $WT, получено: $out"; return; }
  else
    [ "$got" = null ] || { fail "$vetka" "ожидался null, получено: $out"; return; }
  fi
}

# expect_judge <ветвь> <pass|block> <HOME> <json>  (037-прецедент)
expect_judge() {
  local vetka="$1" want="$2" home="$3" evt="$4" out rc dec
  RAN["$vetka"]=1
  out="$(HOME="$home" node "$SUBJ" --judge "$evt")"; rc=$?
  [ "$rc" -eq 0 ] || { fail "$vetka" "rc $rc (вывод: ${out:-<пусто>})"; return; }
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.block===true?"block":(j.decision==="block"?"block":"pass"))}catch(e){console.log("BAD_JSON")}})')"
  [ "$dec" = "$want" ] || { fail "$vetka" "ожидалось $want, получено $dec ($out)"; return; }
}

# expect_factory <ветвь> <pass|block> <HOME> <event-json> — cwd ДРАЙВЕРА
# (=cwd демона в этой метафоре) ВНЕ клона: запуск из $WORK.
expect_factory() {
  local vetka="$1" want="$2" home="$3" evt="$4" out rc dec
  RAN["$vetka"]=1
  out="$(cd "$WORK" && HOME="$home" node "$WORK/fab_driver.mjs" "$SUBJ" "$evt" "$WORK/sessions/TestOwner066.jsonl")"; rc=$?
  [ "$rc" -eq 0 ] || { fail "$vetka" "rc $rc (вывод: ${out:-<пусто>})"; return; }
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.block?"block":(j.decision==="block"?"block":"pass"))}catch(e){console.log("BAD_JSON")}})')"
  [ "$dec" = "$want" ] || { fail "$vetka" "ожидалось $want, получено $dec ($out)"; return; }
}

# ── Часть А: extractPin-грамматика ───────────────────────────────────────────
# а0 (контроль): форма, принятая ДО 066 — однострочная с «;»-разделителем;
# зелёная ДО и ПОСЛЕ (регресс 032: принятая форма не ломается).
expect_pin а0 pin - "WORKTREE=$WT; BRANCH=$BR"

# а0дв (боль Н-173а/Н-162): ДВУХСТРОЧНАЯ пара без префикса — сегодня
# null (якорь ^ без /m гасит BRANCH-токен второй строки; живой замер
# пачки: {"worktree":null} на живом worktree), ПОСЛЕ — pin.
expect_pin а0дв pin - "WORKTREE=$WT
BRANCH=$BR"

# а1 (боль Н-173а): префикс харнеса перед парой — ДО null, ПОСЛЕ pin.
expect_pin а1 pin - "Complete assignment thoroughly:

WORKTREE=$WT
BRANCH=$BR"

# а1б: префикс БЕЗ двоеточия (чистый /m-различитель, без случайного
# «:»-якоря перед WORKTREE) — ДО null, ПОСЛЕ pin.
expect_pin а1б pin - "Complete assignment thoroughly

WORKTREE=$WT
BRANCH=$BR"

# а2 (боль Н-173а): однострочная pin:-форма — ДО null, ПОСЛЕ pin.
expect_pin а2 pin - "pin:WORKTREE=$WT:BRANCH=$BR"

# а3 (негатив): ДВЕ пары WORKTREE в тексте — null ДО и ПОСЛЕ (грамматика
# «ровно одна пара» не ослаблена; стаб «любой первый WORKTREE» умирает).
expect_pin а3 null - "Complete assignment thoroughly:

WORKTREE=$WT
WORKTREE=$NSDIR/wip-066-tester
BRANCH=$BR"

# а4 (негатив): basename-несоответствие (грамматика М1 п.2, 032) — null
# ДО и ПОСЛЕ; worktree $WT жив, но заявлен с чужим веточным номером.
expect_pin а4 null - "WORKTREE=$WT
BRANCH=wip/099/tester"

# а5 (негатив): грамматически верная пара на МЁРТВОМ пути — null ДО и ПОСЛЕ
# (git-оракул 032 судит живость цели).
expect_pin а5 null - "WORKTREE=$NSDIR/netu/wip-066-tester
BRANCH=$BR"

# ── Часть Б: actual спавна (М1-п.5 ветвь 037) ────────────────────────────────
# б1a (контроль боли Н-173б, CLI): actual=КЛОН → pass (М1 живая).
expect_judge б1a pass "$FH" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$C/f.txt\"},\"worktree\":null,\"actual\":\"$C\",\"sessionName\":\"TestOwner066\"}"

# б1b (контроль, та же боль): actual=ДЕМОН-CWD → block: решение ВЕТВИТСЯ по
# actual — вход actual есть единственный носитель cwd спавна (Obs065).
DAEMON_CWD="$(pwd)"
expect_judge б1b block "$FH" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$C/f.txt\"},\"worktree\":null,\"actual\":\"$DAEMON_CWD\",\"sessionName\":\"TestOwner066\"}"

# б2 (контроль регресса): фабрика ПРЕДПОЧИТАЕТ actual события cwd демона —
# процесс драйвера сидит в $WORK (≠ клон), событие несёт actual=клон → pass.
# Стаб «actual = process.cwd()» умирает здесь (даёт block).
expect_factory б2 pass "$FH" \
  "{\"toolName\":\"write\",\"input\":{\"path\":\"$C/f.txt\"},\"actual\":\"$C\"}"

# б3 (боль Н-173б): omp-событие actual НЕ несёт; bash-вызов несёт cwd=клон —
#cwd спавна берётся из события вызова, не из cwd демона. ДО: block (КРАСНО),
# ПОСЛЕ: pass. Стаб «args.cwd не читается» / «оба» умирает здесь.
expect_factory б3 pass "$FH" \
  "{\"toolName\":\"bash\",\"input\":{\"command\":\"printf x | tee f2.txt\",\"cwd\":\"$C\"}}"

# ── Итог ─────────────────────────────────────────────────────────────────────
red=0; green=0; missing=''
for m in "${ORDER[@]}"; do
  if [ "${RAN[$m]}" -ne 1 ]; then missing="$missing $m"; continue; fi
  if [ "${ST[$m]}" -eq 1 ]; then red=$((red+1)); else green=$((green+1)); fi
done
if [ -n "$missing" ]; then
  printf 'КРАСНОЕ 066: ветви не прогнаны:%s\n' "$missing" >&2
  exit 1
fi
printf 'ИТОГ 066 (path_guard): ветвей %d, красных %d, зелёных %d\n' \
  "${#ORDER[@]}" "$red" "$green"
[ "$red" -eq 0 ] || exit 1
exit 0
