#!/usr/bin/env bash
# КРАСНОЕ 037 (М1, self-contained-cwd allowlist): unpinned-сессия с
# process.cwd() САМИМ являющимся toplevel'ом самодостаточного git-репо
# (.git — КАТАЛОГ, `git worktree list` возвращает РОВНО одну строку —
# себя) получает разрешение писать ВНУТРИ этого cwd.
#
# Живой замер ЭТОЙ пачки (двойная проба, не гипотеза): (а) isolated:true
# клон живёт ВНУТРИ $HOME сессии (contract 028 «HOME сессии вне дерева» —
# гарантия, не совпадение) и НА GIT-УРОВНЕ неотличим от главного чекаута
# (origin=ssh://git@github.com/a3ka/dev-harness.git СОВПАДАЕТ байт-в-байт,
# `git reflog show HEAD | wc -l`=1541 СОВПАДАЕТ, HEAD совпадает); (б) главный
# чекаут /home/aka/Documents/dev-harness ПРЯМО СЕЙЧАС (замер этой пачкой)
# САМ проходит «.git-каталог + worktree list==1 строка» — 0 живых
# linked-worktree-соседей в этот момент. Наивная реализация ТОЛЬКО из двух
# владельческих условий ОТКРЫВАЕТ дыру B (резолюция 2026-09-11) в САМОМ
# ЧАСТОМ случае (неизолированный `_task`, общий cwd) ровно тогда, когда
# главный чекаут транзиентно не несёт живой wip-ветки — обычное, не редкое
# состояние. ТРЕТЬЕ условие (п.4 ниже, М1 §Инварианты контракта 037)
# закрывает это: envActual обязан быть ПОТОМКОМ realpath($HOME).
#
# СУБЪЕКТ: .omp/extensions/path-guard.ts — judge()/pathAllowed() (зона
# implementer 032, переобъявлена 037 — union-семантика 033).
#
# ПРИВЯЗКА К КОДУ (Н-39): каждая ветвь красна на СВОЁМ входе.
#   * п1 (позитив) — judge() СЕГОДНЯ игнорирует `actual` при worktree:null
#     (path-guard.ts:904-926 весь блок сверки висит на `if (worktree)`) —
#     стаб «actual не читается для unpinned» умирает здесь: ожидание pass,
#     сегодня block;
#   * п2 (.git — ФАЙЛ, не каталог, но под $HOME) — стаб «self-contained
#     судится ТОЛЬКО HOME-принадлежностью, без явной .git-dir проверки»
#     умирает здесь: ожидание block ДО и ПОСЛЕ;
#   * п3 (.git-каталог, живой сосед, worktree list==2, под $HOME) — стаб
#     «self-contained не зовёт git-оракул worktree list» умирает здесь:
#     ожидание block ДО и ПОСЛЕ;
#   * п4 (КАНАРЕЙКА ДЫРЫ B: .git-каталог + worktree list==1, НО ВНЕ $HOME —
#     ровно сегодняшняя форма главного чекаута) — стаб «двух владельческих
#     условий достаточно, HOME не нужен» умирает здесь: ожидание block ДО
#     и ПОСЛЕ, ЛЮБАЯ реализация, открывающая это, — регресс дыры B;
#   * п5 (граница: цель ВНЕ envActual, кандидат сам self-contained) — стаб
#     «self-contained открывает ЛЮБОЙ путь, не только внутри cwd» умирает
#     здесь: ожидание block;
#   * п6 (регресс 025: пустой null-allowlist жив) — контроль, зелёный ДО
#     и ПОСЛЕ.
#   * п7 (ВЛАДЕЛЕЦ-КОРРЕЛЯЦИЯ, §Инварианты М1 п.5 контракта 037, Б4 критика
#     contracts-037-v1.md) — ТОТ ЖЕ SELFCONTAINED cwd, что п1 (байт-в-байт
#     canonicalActual — имитация вложенного голого `_task`-внука ИЗНУТРИ
#     isolated-родителя), но `sessionId` В JudgeInput НЕ совпадает с `id`
#     артефакта `.omp-isolation-owner.json` — стаб «п.1–4 достаточны,
#     sessionId не нужен» умирает здесь: ожидание block И ДО, И ПОСЛЕ
#     (реализация, скопировавшая только п.1–4 без владелец-корреляции,
#     ошибочно дала бы pass — ровно регрессия Б4).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 037: субъект отсутствует — %s не существует\n' "$SUBJ" >&2
  exit 1
fi
command -v git  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n'  >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }

NS="/tmp/dev-harness-worktrees"
FAKEHOME_BASE="${TMPDIR:-/tmp}/dev-harness-fakehome-037"
VERIFY_BASE="${TMPDIR:-/tmp}/dev-harness-verify"
mkdir -p "$NS" "$FAKEHOME_BASE" "$VERIFY_BASE"
FAKEHOME="$(mktemp -d "$FAKEHOME_BASE/pg037home.XXXXXX")"
OUTSIDE_NS="$(mktemp -d "$NS/pg037out.XXXXXX")"
trap 'rm -rf "$FAKEHOME" "$OUTSIDE_NS"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

mkinit() {  # <путь> — git init минимальный репо, .git КАТАЛОГ, 1 коммит
  local p="$1"
  mkdir -p "$p"
  git -C "$p" init -q -b main
  printf 'x\n' > "$p/f.txt"
  git -C "$p" add f.txt
  git -C "$p" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -qm init
}

# п1/п5 — самодостаточный toplevel ПОД $FAKEHOME (мимикрия isolated:true
# клона: .../wt/<hash>/m — глубина не участвует в инварианте, только
# HOME-принадлежность и структурные условия).
SELFCONTAINED="$FAKEHOME/profiles/dev/wt/t1/m"
mkinit "$SELFCONTAINED"

# owner.json артефакт харнеса (§Инварианты М1 п.5 контракта 037,
# владелец-корреляция) — лежит СНАРУЖИ самого клона (родитель каталог
# $SELFCONTAINED, не внутри него), пишется ХАРНЕССОМ при создании
# изолированного клона; здесь имитирован форматом, подтверждённым живым
# замером той же пачки (agent://Architect037Redesign/IsolatedProbeParent037):
# `{"pid":…,"id":"<agent-id>","startToken":…}`.
printf '{"pid":424242,"id":"owner-session","startToken":"1"}' \
  > "$(dirname "$SELFCONTAINED")/.omp-isolation-owner.json"

# п2 — под $HOME, но .git — ФАЙЛ с мёртвой gitdir-целью (не настоящий живой
# linked worktree; структурная проверка «каталог, не файл» обязана отвергнуть).
GITFILE_CASE="$FAKEHOME/profiles/dev/wt/t2/m"
mkdir -p "$GITFILE_CASE"
printf 'gitdir: %s/.git/worktrees/nesushhestvuet\n' "$FAKEHOME" > "$GITFILE_CASE/.git"

# п3 — под $HOME, .git-каталог, НО живой сосед (worktree list возвращает 2).
SIBLINGS_BASE="$FAKEHOME/profiles/dev/wt/t3"
mkinit "$SIBLINGS_BASE/m"
git -C "$SIBLINGS_BASE/m" branch wip/900/zz
git -C "$SIBLINGS_BASE/m" worktree add -q "$SIBLINGS_BASE/sosed" wip/900/zz
SIBLINGS_MAIN="$SIBLINGS_BASE/m"

# п4 — КАНАРЕЙКА ДЫРЫ B: .git-каталог + worktree list==1, НО ВНЕ $FAKEHOME
# (namespace НЕ под HOME — ровно форма сегодняшнего главного чекаута,
# измерено живьём этой же пачкой: `git worktree list` там СЕЙЧАС даёт 1 строку).
MAINLIKE="$OUTSIDE_NS/mainlike"
mkinit "$MAINLIKE"

ORDER=(п1 п2 п3 п4 п5 п6 п7)
declare -A ST RAN
for m in "${ORDER[@]}"; do ST[$m]=0; RAN[$m]=0; done
fail() {
  RAN["$1"]=1; ST["$1"]=1
  printf 'КРАСНОЕ 037: ветвь «%s» — %s\n' "$1" "$2" >&2
}

expect_judge() {  # <ветвь> <block|pass> <substr> <HOME-override|-> <json>
  local vetka="$1" want="$2" substr="$3" home="$4" evt="$5" out rc dec
  RAN["$vetka"]=1
  if [ "$home" = "-" ]; then
    out="$(node "$SUBJ" --judge "$evt")"; rc=$?
  else
    out="$(HOME="$home" node "$SUBJ" --judge "$evt")"; rc=$?
  fi
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект не ответил решением (rc $rc, вывод: ${out:-<пусто>})"
    return
  fi
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.decision??"")}catch(e){console.log("BAD_JSON")}})')"
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

# ── п1: позитив — self-contained под $HOME, цель ВНУТРИ него ──────────────────
expect_judge п1 pass "" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$SELFCONTAINED/sub/dir/f.txt\"},\"worktree\":null,\"actual\":\"$SELFCONTAINED\",\"sessionId\":\"owner-session\"}"

# ── п2: .git — файл (не каталог) под $HOME ⇒ блок ──────────────────────────────
expect_judge п2 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$GITFILE_CASE/f2.txt\"},\"worktree\":null,\"actual\":\"$GITFILE_CASE\"}"

# ── п3: живой сосед (worktree list==2) под $HOME ⇒ блок ────────────────────────
expect_judge п3 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$SIBLINGS_MAIN/f3.txt\"},\"worktree\":null,\"actual\":\"$SIBLINGS_MAIN\"}"

# ── п4: КАНАРЕЙКА ДЫРЫ B — самодостаточный ВНЕ $HOME (форма главного чекаута) ──
expect_judge п4 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$MAINLIKE/f4.txt\"},\"worktree\":null,\"actual\":\"$MAINLIKE\"}"

# ── п5: цель ВНЕ envActual, кандидат сам self-contained ⇒ блок (namespace only)─
expect_judge п5 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$OUTSIDE_NS/vne-envActual/f5.txt\"},\"worktree\":null,\"actual\":\"$SELFCONTAINED\"}"

# ── п6: регресс 025 — пустой null-allowlist (внешняя цель) жив ────────────────
expect_judge п6 block "Н-85" "-" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$OUTSIDE_NS/prosto/f6.txt\"},\"worktree\":null,\"actual\":null}"

# ── п7: ВЛАДЕЛЕЦ-КОРРЕЛЯЦИЯ (037 §Инварианты М1 п.5, Б4 критика
# contracts-037-v1.md) — ТОТ ЖЕ SELFCONTAINED cwd, что и п1, но sessionId
# НЕ совпадает с owner.json'а id ⇒ блок И ДО, И ПОСЛЕ реализации ──────────
expect_judge п7 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$SELFCONTAINED/sub/dir/f7.txt\"},\"worktree\":null,\"actual\":\"$SELFCONTAINED\",\"sessionId\":\"nested-child-session\"}"

RED=0; GRN=0; NORUN=0
for m in "${ORDER[@]}"; do
  if [ "${RAN[$m]}" -eq 0 ]; then NORUN=$((NORUN+1));
  elif [ "${ST[$m]}" -eq 1 ]; then RED=$((RED+1)); else GRN=$((GRN+1)); fi
done
if [ "$NORUN" -gt 0 ]; then
  printf 'КРАСНОЕ 037: %d ветвей НЕ прогнаны (пустая выборка — красное, не зелёное)\n' "$NORUN" >&2
  exit 1
fi
printf 'ИТОГ 037 (self-contained-cwd): ветвей %d, красных %d, зелёных %d\n' "${#ORDER[@]}" "$RED" "$GRN"
[ "$RED" -eq 0 ] || exit 1
exit 0
