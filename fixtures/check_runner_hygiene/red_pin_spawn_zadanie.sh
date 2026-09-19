#!/usr/bin/env bash
# КРАСНОЕ 032 v2 (Н-111(б), черновик-контракт v2 к к2): пин task-спавна из строки
# задания — недостроенная половина 025 §C-1. СУБЪЕКТ: .omp/extensions/path-guard.ts —
# judge-CLI (грамматика 025) И фабрика register() + новый режим --extract-pin
# (грамматика 032 М1/М2). СЕГОДНЯ (дерево без пиннинга): rc 1, красные ветви —
# п1 п6 п7 п7б п8 п9 п11 п12 (пин из задания отсутствует, «вне пина»-семантика не
# различима, дыра `..` жива, --extract-pin нет). ПОСЛЕ реализации: rc 0.
#
# 20 ветвей приёмки: п0–п15 + п4а/п4б/п4в/п7б; каждая ветвь = именованные входы,
# ветвь красная, если КРАСЕН любой её вход. Накопление: прогон не стопится на
# первом красном — в конце именованная сводка «ВЕТВЬ <маркер> <статус>» по всем 20.
# Все toy-репо и негативные каталоги — ПОД реальным namespace
# /tmp/dev-harness-worktrees (канарейка п2 судит живой префикс, не toy-имя;
# уникальность mktemp-суффиксом — А-88, два прогона = разные пути).
#
# ПРИВЯЗКА К КОДУ (Н-39), стабы умирают каждый на СВОЕЙ ветви:
#   * п1/п9/п11/п12/п13/п14/п15 — фабрика register() :731-758: tool_call читает
#     call.worktree ?? env.WORKTREE (:745-748), lifecycle-обработчиков
#     session_start/session_branch/session_tree и пина-задания НЕТ. Стабы:
#     «пин без ключа session_id» (модульная переменная) — на п11 (B наследует
#     пин A); «только session_start» — на п12 (branch/tree не поднимают пин);
#     «задание выше события» — на п13; «задание выше env» — на п14;
#     «env выше события» — на п15; «последняя user-запись перепинивает» — на п9;
#   * п3/п4/п4а/п4б/п4в/п5 — грамматика М1 (будущая ветвь извлечения): стабы
#     «первый WORKTREE= где угодно» / «без live-проверки .git» / «gitdir-цель не
#     проверяется» / «формат .git-содержимого не проверяется» / «`.git` —
#     каталог, не файл, не проверяется» / «без сверки spawn-формы» умирают
#     каждый на СВОЕЙ ветви (цель записи — ВНУТРИ проверяемого пути:
#     запиннувший стаб даёт pass и валит ассерт block);
#   * п6 — причина «вне пина» :543/:609 против unpinned-причины :542/:608
#     (сегодня блок есть, но семантика своя/чужая цель не различима);
#   * п7/п7б — isWithin :88-91 сырой префикс (обе allowlist-ветви, дыра `..`
#     жива СЕГОДНЯ); стаб «realpath вместо лексической нормализации» умирает на
#     п7 — несуществующая цель даёт refuse ≠ ожидаемый block;
#   * п0/п2/п10 — 025-семантика не тронута (:521 :542 :631 :643); стаб
#     «namespace-открытие» (префикс /tmp/dev-harness-worktrees в allowlist)
#     умирает на п2 — оба входа (живой worktree и файл) обязаны блокироваться.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 032: субъект отсутствует — %s не существует; пин спавна из задания не стережётся\n' "$SUBJ" >&2
  exit 1
fi
command -v git  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n'  >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }

NS="/tmp/dev-harness-worktrees"          # реальный namespace (п2, канарейка)
VERIFY_BASE="${TMPDIR:-/tmp}/dev-harness-verify"
mkdir -p "$NS" "$VERIFY_BASE"
TOY="$(mktemp -d "$NS/pg032.XXXXXX")"    # toy-репо ПОД namespace (А-88: суффикс)
OUTSIDE="$(mktemp -d "$NS/pg032vne.XXXXXX")"   # негативный каталог ПОД namespace
VERIFY_DIR="$(mktemp -d "$VERIFY_BASE/pg032.XXXXXX")"
trap 'rm -rf "$TOY" "$OUTSIDE" "$VERIFY_DIR"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
git -C "$TOY" init -q -b main
printf 'x\n' > "$TOY/f.txt"
git -C "$TOY" add f.txt
git -C "$TOY" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -qm init
git -C "$TOY" branch wip/101/aa
git -C "$TOY" worktree add -q "$TOY/wip-101-aa" wip/101/aa
git -C "$TOY" branch wip/102/bb
git -C "$TOY" worktree add -q "$TOY/wip-102-bb" wip/102/bb
git -C "$TOY" branch wip/103/cc
git -C "$TOY" worktree add -q "$TOY/wip-103-cc" wip/103/cc
WTA="$TOY/wip-101-aa"
WTB="$TOY/wip-102-bb"
WTC="$TOY/wip-103-cc"
# Негативные каталоги spawn-формы (все ПОД namespace):
mkdir -p "$TOY/wip-104-dd"                                        # п4:  нет .git вовсе
mkdir -p "$TOY/wip-105-de"
printf 'gitdir: %s/.git/worktrees/nesushhestvuet\n' "$TOY" > "$TOY/wip-105-de/.git"   # п4а: цель gitdir мертва
mkdir -p "$TOY/wip-106-df"
printf 'ne-gitdir-musor\n' "$TOY" > "$TOY/wip-106-df/.git"        # п4б: содержимое не формата
mkdir -p "$TOY/wip-107-dg"
git -C "$TOY/wip-107-dg" init -q -b main                          # п4в: .git — КАТАЛОГ, не файл

# ── Накопление: ветвь красная, если красен любой её вход ──────────────────────
ORDER=(п0 п1 п2 п3 п4 п4а п4б п4в п5 п6 п7 п7б п8 п9 п10 п11 п12 п13 п14 п15)
declare -A ST RAN
for m in "${ORDER[@]}"; do ST[$m]=0; done

fail() {  # <ветвь> <детали> — именованный красный вход, прогон продолжается
  local mk="${1%%-*}"
  RAN[$mk]=1; ST[$mk]=1
  printf 'КРАСНОЕ 032: ветвь «%s» — %s\n' "$1" "$2" >&2
}

assert_decision() {  # <ветвь> <want> <substr> <вывод субъекта> <rc>
  local vetka="$1" want="$2" substr="$3" out="$4" rc="$5" dec
  RAN["${vetka%%-*}"]=1
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект не ответил решением (rc $rc, вывод: ${out:-<пусто>}) — декой/сломанный модуль"
    return
  fi
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.decision??"")}catch(e){console.log("BAD_JSON")}})')"
  if [ -z "$dec" ] || [ "$dec" = "BAD_JSON" ]; then
    fail "$vetka" "субъект не ответил решением-JSON (вывод: $out)"
    return
  fi
  if [ "$dec" != "$want" ]; then
    fail "$vetka" "ожидалось $want, получено $dec (вывод: $out)"
    return
  fi
  if [ -n "$substr" ]; then
    case "$out" in
      *"$substr"*) ;;
      *) fail "$vetka" "reason без «$substr»: $out" ;;
    esac
  fi
}

expect_judge() {  # <ветвь> <block|pass|refuse> <substr> <json-событие>
  local vetka="$1" want="$2" substr="$3" evt="$4" out rc
  out="$(node "$SUBJ" --judge "$evt")"; rc=$?
  assert_decision "$vetka" "$want" "$substr" "$out" "$rc"
}

# ── Фабричный драйвер: один процесс = один экземпляр расширения, много сессий ──
# План = «;»-шаги: <id>:start|branch|tree:<asg[+asg2]> — lifecycle-регистрация
# сессии id (обработчик вызывается лишь если субъект его зарегистрировал);
# <id>:call:<цель>[:eventWorktree[:eventActual]] — tool_call от сессии id,
# на stdout ОДНА JSON-строка решения на каждый call-шаг, по порядку шагов.
cat > "$TOY/drv.mjs" <<'MJS'
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
const [subj, plan] = process.argv.slice(2);
const mod = await import(pathToFileURL(subj).href);
if (typeof mod.default !== 'function') { console.error('нет default-экспорта фабрики'); process.exit(3); }
const handlers = {};
mod.default({ on: (n, cb) => { handlers[n] = cb; } });
const EV = { start: 'session_start', branch: 'session_branch', tree: 'session_tree' };
const ctxs = new Map();
const branch = (asg) => (asg && asg !== '-' ? asg.split('+').map((f) => ({
  type: 'message',
  message: { role: 'user', content: [{ type: 'text', text: readFileSync(f, 'utf8') }] },
})) : []);
const ctxOf = (id, asg) => {
  if (!ctxs.has(id)) {
    ctxs.set(id, { sessionManager: { getBranch: () => branch(asg), getSessionId: () => id } });
  }
  return ctxs.get(id);
};
let n = 0;
for (const step of plan.split(';')) {
  if (!step) continue;
  const [id, kind, a, b, c] = step.split(':');
  if (kind === 'call') {
    if (typeof handlers.tool_call !== 'function') { console.error('нет tool_call-обработчика'); process.exit(3); }
    const evt = { type: 'tool_call', toolName: 'write', toolCallId: `t${++n}`, input: { i: 'probe', path: a, content: 'x' } };
    if (b && b !== '-') evt.worktree = b;
    if (c && c !== '-') evt.actual = c;
    const res = await handlers.tool_call(evt, ctxOf(id, '-'));
    if (res === undefined) process.stdout.write('{"decision":"pass"}\n');
    else process.stdout.write(JSON.stringify({ decision: res && res.block ? 'block' : 'pass', reason: String((res && res.reason) || '') }) + '\n');
  } else {
    const h = EV[kind];
    if (!h) { console.error('неизвестный шаг ' + kind); process.exit(3); }
    if (typeof handlers[h] === 'function') await handlers[h]({}, ctxOf(id, a));
  }
}
MJS

CALLS_OUT=""; CALLS_RC=0
calls_run() {  # <план> [envWORKTREE]
  if [ -n "${2:-}" ]; then
    CALLS_OUT="$(env WORKTREE="$2" node "$TOY/drv.mjs" "$SUBJ" "$1" 2>&1)"; CALLS_RC=$?
  else
    CALLS_OUT="$(env -u WORKTREE node "$TOY/drv.mjs" "$SUBJ" "$1" 2>&1)"; CALLS_RC=$?
  fi
}
call_assert() {  # <ветвь> <номер call-шага (1-based)> <want> <substr>
  local line
  line="$(printf '%s\n' "$CALLS_OUT" | sed -n "$2p")"
  assert_decision "$1" "$3" "$4" "$line" "$CALLS_RC"
}

# ── Задания (канон строки spawn_agent.sh stdout + формат раздачи дня) ─────────
printf 'Задание 032.\n## Contract\n032: WORKTREE=%s, BRANCH=wip/101/aa.\nПервым действием cd в worktree.\n' "$WTA" > "$TOY/asg-one.txt"
printf 'Задание без пина. Первым действием cd $WORKTREE (переменная, не значение).\n' > "$TOY/asg-none.txt"
printf 'Пара контрактов.\n032: WORKTREE=%s, BRANCH=wip/101/aa.\n033: WORKTREE=%s, BRANCH=wip/102/bb.\n' "$WTA" "$WTB" > "$TOY/asg-two.txt"
printf 'Мёртвая цель.\nWORKTREE=%s, BRANCH=wip/104/dd.\n' "$TOY/wip-104-dd" > "$TOY/asg-dead.txt"
printf 'Gitdir-цель мертва.\nWORKTREE=%s, BRANCH=wip/105/de.\n' "$TOY/wip-105-de" > "$TOY/asg-gitdir-dead.txt"
printf 'Gitdir-мусор.\nWORKTREE=%s, BRANCH=wip/106/df.\n' "$TOY/wip-106-df" > "$TOY/asg-gitdir-musor.txt"
printf 'Git-каталог, не файл.\nWORKTREE=%s, BRANCH=wip/107/dg.\n' "$TOY/wip-107-dg" > "$TOY/asg-git-dir.txt"
printf 'Форма рассогласована.\nWORKTREE=%s, BRANCH=wip/102/bb.\n' "$WTA" > "$TOY/asg-mismatch.txt"
printf 'Steering-подмена.\nWORKTREE=%s, BRANCH=wip/102/bb.\n' "$WTB" > "$TOY/asg-steer.txt"

# ── п0: зелёный контроль — null-allowlist 025 жив ДО и ПОСЛЕ ──────────────────
expect_judge "п0-внешняя-цель-блок"   block "Н-85" "{\"tool\":\"write\",\"args\":{\"path\":\"$OUTSIDE/f.txt\"},\"worktree\":null,\"actual\":null}"
expect_judge "п0-скретч-pass"          pass   ""    "{\"tool\":\"write\",\"args\":{\"path\":\"$VERIFY_DIR/f.txt\"},\"worktree\":null,\"actual\":null}"
expect_judge "п0-artifact-pass"        pass   ""    "{\"tool\":\"write\",\"args\":{\"path\":\"artifact://032/f.txt\"},\"worktree\":null,\"actual\":null}"

# ── п1: боль Н-111 — своя пара в задании, запись в СВОЙ worktree ──────────────
calls_run "A:start:$TOY/asg-one.txt;A:call:$WTA/new-file.txt"
call_assert "п1-пин-из-задания-pass" 1 pass ""

# ── п2: канарейка namespace — нет пары ⇒ fail-closed, НЕ namespace-открытие ───
# вход 1: живой linked worktree ПОД /tmp/dev-harness-worktrees;
# вход 2: НЕсобственный путь под тем же префиксом (файл, не worktree).
calls_run "A:start:$TOY/asg-none.txt;A:call:$WTA/f2.txt"
call_assert "п2-без-пары-worktree-блок" 1 block "Н-85"
expect_judge "п2-без-пары-файл-блок" block "Н-85" "{\"tool\":\"write\",\"args\":{\"path\":\"$OUTSIDE/prostoj-fajl.txt\"},\"worktree\":null,\"actual\":null}"

# ── п3: две пары ⇒ неоднозначность, консервативный null ───────────────────────
calls_run "A:start:$TOY/asg-two.txt;A:call:$WTA/new-file.txt"
call_assert "п3-две-пары-блок" 1 block ""

# ── п4/п4а/п4б: spawn-путь не является живым worktree (три разных входа) ──────
calls_run "A:start:$TOY/asg-dead.txt;A:call:$TOY/wip-104-dd/f.txt"
call_assert "п4-не-worktree-блок" 1 block ""
calls_run "A:start:$TOY/asg-gitdir-dead.txt;A:call:$TOY/wip-105-de/f.txt"
call_assert "п4а-gitdir-цель-мертва-блок" 1 block ""
calls_run "A:start:$TOY/asg-gitdir-musor.txt;A:call:$TOY/wip-106-df/f.txt"
call_assert "п4б-gitdir-musor-блок" 1 block ""
calls_run "A:start:$TOY/asg-git-dir.txt;A:call:$TOY/wip-107-dg/f.txt"
call_assert "п4в-git-katalog-блок" 1 block ""

# ── п5: путь и ветка рассогласованы по spawn-форме ⇒ null ─────────────────────
calls_run "A:start:$TOY/asg-mismatch.txt;A:call:$WTA/new-file.txt"
call_assert "п5-форма-расходится-блок" 1 block ""

# ── п6: своя пара живая, цель — ЖИВОЙ соседний worktree ⇒ «вне пина» ──────────
calls_run "A:start:$TOY/asg-one.txt;A:call:$WTB/new-file.txt"
call_assert "п6-чужой-worktree-вне-пина" 1 block "вне пина"

# ── п7/п7б: обход `..` — дыра жива СЕГОДНЯ в обеих allowlist-ветвях (М4) ──────
expect_judge "п7-скретч-обход-точка-точка" block "Н-85"     "{\"tool\":\"write\",\"args\":{\"path\":\"$VERIFY_BASE/../pg032esc$RANDOM/f.txt\"},\"worktree\":null,\"actual\":null}"
expect_judge "п7б-пин-обход-точка-точка"   block "вне пина" "{\"tool\":\"write\",\"args\":{\"path\":\"$WTA/../wip-102-bb/f.txt\"},\"worktree\":\"$WTA\",\"actual\":\"$WTA\"}"

# ── п8: токен-гигиена нового CLI-режима --extract-pin (М1) ────────────────────
extract() {  # <ветвь> <ожидание: null | <путь>> <текст>
  local vetka="$1" want="$2" text="$3" out rc got
  RAN["${vetka%%-*}"]=1
  out="$(node "$SUBJ" --extract-pin "$text" 2>&1)"; rc=$?
  if [ "$rc" -eq 2 ]; then
    fail "$vetka" "режим --extract-pin отсутствует (rc 2 NOT_IMPLEMENTED): ${out:-<пусто>}"
    return
  fi
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект упал (rc $rc): $out"
    return
  fi
  got="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.worktree===null?"null":String(j.worktree))}catch(e){console.log("BAD_JSON")}})')"
  if [ "$got" = "BAD_JSON" ]; then fail "$vetka" "не JSON: $out"; return; fi
  if [ "$got" != "$want" ]; then fail "$vetka" "ожидалось $want, получено $got (вывод: $out)"; fi
}
extract "п8-честная-пара"        "$WTA" "$(cat "$TOY/asg-one.txt")"
extract "п8-переменная-не-токен" "null" "Первым действием cd \$WORKTREE и работай."
extract "п8-склейка-слева"       "null" "xWORKTREE=/tmp/a BRANCH=wip/999/z."
extract "п8-относительное"       "null" "WORKTREE=relative/path BRANCH=wip/999/z."

# ── п9: steering роли user НЕ перепинивает (пин = первая user-запись) ─────────
calls_run "A:start:$TOY/asg-one.txt+$TOY/asg-steer.txt;A:call:$WTA/f9a.txt;A:call:$WTB/f9b.txt"
call_assert "п9-пин-по-первой-записи-pass" 1 pass ""
call_assert "п9-steer-цель-вне-пина-блок"  2 block "вне пина"

# ── п10: грамматика 025 цела (событийный пин со сверкой actual) ───────────────
expect_judge "п10-несуществующий-пинн"  refuse "не существует" "{\"tool\":\"write\",\"args\":{\"path\":\"$WTA/f.txt\"},\"worktree\":\"$TOY/ghost-$RANDOM\",\"actual\":\"$WTA\"}"
expect_judge "п10-пинн-не-совпал"       refuse "не совпадает"  "{\"tool\":\"write\",\"args\":{\"path\":\"$WTA/f.txt\"},\"worktree\":\"$WTA\",\"actual\":\"$WTB\"}"

# ── п11: межсессионная изоляция — ОДИН процесс, один экземпляр расширения ────
# A с парой wt-a, B без пары: A пишет wt-a ⇒ pass ПОСЛЕ; B пишет wt-a ⇒ блок
# ДО и ПОСЛЕ (стаб «модульная переменная без session_id» даёт B наследование).
calls_run "A:start:$TOY/asg-one.txt;B:start:$TOY/asg-none.txt;A:call:$WTA/f11a.txt;B:call:$WTA/f11b.txt"
call_assert "п11-изолjacja-A-pass" 1 pass ""
call_assert "п11-изолjacja-B-блок" 2 block "Н-85"

# ── п12: каждое lifecycle-событие — самостоятельный источник восстановления ──
# C без session_start (только session_branch) и D без start (только session_tree).
calls_run "C:branch:$TOY/asg-one.txt;C:call:$WTA/f12c.txt"
call_assert "п12-branch-vosstanovlenie-pass" 1 pass ""
calls_run "D:tree:$TOY/asg-one.txt;D:call:$WTA/f12d.txt"
call_assert "п12-tree-vosstanovlenie-pass" 1 pass ""

# ── п13: приоритет события над заданием (фабрика, конфликт источников) ────────
# задание = пара wt-a; omp-событие worktree=wt-b, actual=wt-b.
calls_run "A:start:$TOY/asg-one.txt;A:call:$WTB/f13b.txt:$WTB:$WTB;A:call:$WTA/f13a.txt:$WTB:$WTB"
call_assert "п13-sobytie-vyshe-zadanija-pass" 1 pass ""
call_assert "п13-zadanie-vne-pina-блок"      2 block "вне пина"

# ── п14: приоритет env над заданием ───────────────────────────────────────────
# задание = пара wt-a; env.WORKTREE=wt-b (события нет), actual=wt-b.
calls_run "A:start:$TOY/asg-one.txt;A:call:$WTB/f14b.txt:-:$WTB;A:call:$WTA/f14a.txt:-:$WTB" "$WTB"
call_assert "п14-env-vyshe-zadanija-pass" 1 pass ""
call_assert "п14-zadanie-vne-pina-блок"  2 block "вне пина"

# ── п15: приоритет события над env ────────────────────────────────────────────
# omp-событие worktree=wt-b, env.WORKTREE=wt-c, actual=wt-b, задание без пары.
calls_run "A:start:$TOY/asg-none.txt;A:call:$WTB/f15b.txt:$WTB:$WTB;A:call:$WTC/f15c.txt:$WTB:$WTB" "$WTC"
call_assert "п15-sobytie-vyshe-env-pass" 1 pass ""
call_assert "п15-env-vne-pina-блок"     2 block "вне пина"

# ── Сводка: все 20 маркеров, пустая выборка = дефект фикстуры ─────────────────
RED=0; GRN=0
for m in "${ORDER[@]}"; do
  if [ -z "${RAN[$m]:-}" ]; then
    printf 'КРАСНОЕ 032: ветвь %s НЕ прогнана — дефект фикстуры\n' "$m" >&2
    ST[$m]=1
  fi
  if [ "${ST[$m]}" = 1 ]; then RED=$((RED+1)); s="красная"; else GRN=$((GRN+1)); s="зелёная"; fi
  printf 'ВЕТВЬ %s %s\n' "$m" "$s"
done
printf 'ИТОГ 032: ветвей %d, красных %d, зелёных %d\n' "${#ORDER[@]}" "$RED" "$GRN"
[ "$RED" -eq 0 ] || exit 1
exit 0
