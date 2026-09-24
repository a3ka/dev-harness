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
#     contracts-037-v1.md, Н1 критика contracts-037-b4-resolution-v1.md) —
#     ТОТ ЖЕ SELFCONTAINED cwd, что п1 (байт-в-байт canonicalActual —
#     имитация вложенного голого `_task`-внука ИЗНУТРИ isolated-родителя),
#     но `sessionName` В JudgeInput (реалистичное иерархическое имя —
#     родитель.ребёнок, ТОТ ЖЕ формат, что owner.json.id — живой замер Н1
#     критика: НЕ UUID, который производит `getSessionId()`) НЕ совпадает
#     с `id` артефакта `.omp-isolation-owner.json` — стаб «п.1–4
#     достаточны, sessionName не нужен» умирает здесь: ожидание block И
#     ДО, И ПОСЛЕ (реализация, скопировавшая только п.1–4 без владелец-
#     корреляции, ошибочно дала бы pass — ровно регрессия Б4).
#   * п8 (ПОДДЕЛКА OWNER.JSON ЧЕРЕЗ ВЛОЖЕННЫЙ РЕПО — блокер M1 вердикта
#     verdicts/adversary/contracts-037-m1m2-adversary.md; §Инварианты М1
#     п.6 v2) — ВЛАДЕЛЕЦ Outer (легитимно допущен: контроль даёт pass И
#     ДО, И ПОСЛЕ) создаёт ВНУТРИ Outer вложенный git-репо Inner и пишет
#     Outer/.omp-isolation-owner.json (ОН СНАРУЖИ Inner, НО ВНУТРИ уже
#     разрешённого Outer) с id ЧУЖОЙ сессии; unpinned-сессия с cwd=Inner
#     и sessionName=этот id читает ПОДДЕЛКУ как harness-артефакт — стаб
#     «п.1–5 достаточны, вложенность cwd не проверяется» умирает здесь:
#     ожидание block (п.6: у Inner есть .git-несущий предок Outer),
#     сегодня pass — обход воспроизведён живьём, байт-в-байт как в
#     вердикте адверсария.
#   * п9 (ВНЕ-HOME с ПОЛНОСТЬЮ валидными п.2/п.3/п.5/п.6 — блокер Р1
#     вердикта verdicts/review/contracts-037-v1.md): revert фикса M1
#     `20d821d` оставлял эту фикстуру 8/8 зелёной над открытой дырой;
#     клетка подаёт sessionName=owner.json.id в dirname(кандидата),
#     .git-каталог + worktree list==1, БЕЗ .git-предков до filesystem
#     root, кандидат ВНЕ $HOME — стаб «п.5+п.6 достаточно,
#     HOME-принадлежность не проверяется» умирает здесь: ожидание block
#     (единственный отказчик — п.4 `!isWithin(realHome, _)`), при
#     откате `20d821d` — pass (клетка краснеет).
#   * п10 (canonicalActual === realHome — САМ HOME как cwd; тот же
#     блокер Р1): isWithin равенство НЕ ловит (child===parent — истина),
#     п.6-цикл при равенстве пропускается, owner.json в dirname(HOME)
#     валиден — стаб «явная проверка равенства не нужна» умирает здесь:
#     ожидание block (единственный отказчик — `canonicalActual ===
#     realHome`), при откате `20d821d` — pass (клетка краснеет).
#     ОБЕ базы п9/п10 СОЗНАТЕЛЬНО вне ${TMPDIR:-/tmp}/dev-harness-verify
#     — иначе pass даёт scratch-allowlist 025 и зонд ничего не
#     доказывает (ловушка Н-85/А-122, названа адверсарием m1m2-recheck
#     и повторена ревьюером contracts-037-v1.md).
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
trap 'rm -rf "$FAKEHOME" "$OUTSIDE_NS" "$P4BASE" "$HOMEBASE"' EXIT

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
# замером (Architect037FixN1, three-topology `_task`-проба через
# supervised omp -p, Н1 критика contracts-037-b4-resolution-v1.md): `id`
# — ИЕРАРХИЧЕСКОЕ имя сессии, ТОТ ЖЕ формат, что basename
# `ctx.sessionManager.getSessionFile()` без `.jsonl`, НЕ UUID
# `getSessionId()`.
# `{"pid":…,"id":"<родитель>[.<ребёнок>]","startToken":…}`.
printf '{"pid":424242,"id":"TestOwner037","startToken":"1"}' \
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

# п8 — блокер M1: ВЛАДЕЛЕЦ Outer (допущен п.1–5; harness-owner.json лежит
# в dirname(Outer)=$FAKEHOME) создаёт ВНУТРИ себя вложенный репо Inner,
# ЗАТЕМ пишет Outer/.omp-isolation-owner.json (dirname(Inner)==Outer —
# читается как owner.json ДЛЯ Inner, физически внутри записываемого
# владельцем дерева) с id ЧУЖОЙ сессии Owner037.NestedBare.
OUTER="$FAKEHOME/outer"
mkinit "$OUTER"
INNER="$OUTER/inner"
mkinit "$INNER"
printf '{"pid":424242,"id":"Owner037","startToken":"1"}' \
  > "$FAKEHOME/.omp-isolation-owner.json"
printf '{"pid":424242,"id":"Owner037.NestedBare","startToken":"1"}' \
  > "$OUTER/.omp-isolation-owner.json"

# п9/п10 — блокер Р1 ревьюера (verdicts/review/contracts-037-v1.md):
# фикс M1 `20d821d` (п.4: явный отказ canonicalActual===realHome +
# isWithin(realHome, canonicalActual)) не был прижат НИ ОДНОЙ клеткой.
# Сетапы НЕ ДЕЛЯТ ни одного каталога со старыми клетками (независимость
# красноты: каждая смерть — своя строка `20d821d`).

# п9 — ВНЕ-HOME кандидат с валидными п.2/п.3/п.5/п.6: отдельный
# mktemp-namespace (не $OUTSIDE_NS старой п4), owner.json в dirname
# кандидата с id === sessionName, НИ ОДИН предок до filesystem root
# не несёт .git — в реальном коде отказ даёт ТОЛЬКО п.4 (вне realHome).
P4BASE="$(mktemp -d "$NS/pg037p4.XXXXXX")"
P4OUT="$P4BASE/m"
mkinit "$P4OUT"
printf '{"pid":424242,"id":"OutsideOwner037","startToken":"1"}' \
  > "$P4BASE/.omp-isolation-owner.json"

# п10 — canonicalActual === realHome: репо-каталог, поданный КАК
# HOME-override; owner.json в dirname(HOME) с id === sessionName.
# п.6-цикл при равенстве пропускается, isWithin(parent,parent)=истина —
# в реальном коде отказ даёт ТОЛЬКО явная проверка равенства п.4.
HOMEBASE="$(mktemp -d "$FAKEHOME_BASE/pg037homeown.XXXXXX")"
HOME_ITSELF="$HOMEBASE/self"
mkinit "$HOME_ITSELF"
printf '{"pid":424242,"id":"HomeItself037","startToken":"1"}' \
  > "$HOMEBASE/.omp-isolation-owner.json"

ORDER=(п1 п2 п3 п4 п5 п6 п7 п8 п9 п10)
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
# sessionName = ТОЧНО owner.json.id (реалистичная форма — Н1 критика: в
# проде оба производятся ИЗ ОДНОГО понятия харнеса «иерархическое имя
# сессии» — basename(getSessionFile()) владельца литерально равен его же
# owner.json.id, живой замер — контракт §Инварианты М1 п.5).
expect_judge п1 pass "" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$SELFCONTAINED/sub/dir/f.txt\"},\"worktree\":null,\"actual\":\"$SELFCONTAINED\",\"sessionName\":\"TestOwner037\"}"

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
# contracts-037-v1.md, Н1 критика contracts-037-b4-resolution-v1.md) —
# ТОТ ЖЕ SELFCONTAINED cwd, что и п1, но sessionName — РЕАЛИСТИЧНОЕ имя
# ГОЛОГО ВЛОЖЕННОГО РЕБЁНКА (родитель.ребёнок — та же форма, что живой
# замер контракта §Инварианты М1 п.5 показал для N1Bare:
# TestOwner037.NestedBare037 при owner.json id=TestOwner037), НЕ
# совпадает с owner.json'а id ⇒ блок И ДО, И ПОСЛЕ реализации ──────────
expect_judge п7 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$SELFCONTAINED/sub/dir/f7.txt\"},\"worktree\":null,\"actual\":\"$SELFCONTAINED\",\"sessionName\":\"TestOwner037.NestedBare037\"}"

# ── п8: ПОДДЕЛКА OWNER.JSON ЧЕРЕЗ ВЛОЖЕННЫЙ РЕПО (блокер M1 вердикта
# адверсария; §Инварианты М1 п.6 v2). КОНТРОЛЬ: владелец Outer легитимен —
# pass И ДО (п.1–5 реализованы, ef736e9), И ПОСЛЕ п.6 (у Outer нет
# .git-несущих предков между Outer и $FAKEHOME — реализация, блокирующая
# контроль, — регресс легитимного владельца). АТАКА: чужая unpinned-сессия
# с cwd=Inner и sessionName, равным ПОДДЕЛАННОМУ владельцем id, — сегодня
# pass (обход жив, воспроизведён этой пачкой зондом против настоящего
# --judge), после п.6 — block (предок Outer несёт .git-каталог; отказ до
# чтения owner.json). ────────────────────────────────────────────────────
expect_judge п8 pass "" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$OUTER/f8.txt\"},\"worktree\":null,\"actual\":\"$OUTER\",\"sessionName\":\"Owner037\"}"
expect_judge п8 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$INNER/pwned.txt\"},\"worktree\":null,\"actual\":\"$INNER\",\"sessionName\":\"Owner037.NestedBare\"}"

# ── п9: ВНЕ-HOME, п.2/п.3/п.5/п.6 валидны ⇒ блок (единственный
# отказчик — п.4 isWithin; при откате 20d821d даёт pass = красная) ────
expect_judge п9 block "Н-85" "$FAKEHOME" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$P4OUT/f9.txt\"},\"worktree\":null,\"actual\":\"$P4OUT\",\"sessionName\":\"OutsideOwner037\"}"

# ── п10: canonicalActual === realHome (HOME сам как cwd) ⇒ блок
# (единственный отказчик — явное равенство п.4; isWithin его не ловит;
# при откате 20d821d даёт pass = красная) ──────────────────────────────
expect_judge п10 block "Н-85" "$HOME_ITSELF" \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$HOME_ITSELF/f10.txt\"},\"worktree\":null,\"actual\":\"$HOME_ITSELF\",\"sessionName\":\"HomeItself037\"}"

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
