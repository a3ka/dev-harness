#!/usr/bin/env bash
# КРАСНОЕ 200 «окно заморозки» (слово владельца 2026-11-17 «делай все согласно
# рекоммендаций», п.9: «ремонт отбора окна (б) check_contract_frozen — коммиты
# с пустым diff пути к первому родителю в окно не попадают (корень ручных
# grandfather-пар, уже 62)»).
#
# ПРЕДМЕТ БАТАРЕИ (исполнимые клетки + обманные стабы; привязка стаб↔клетка —
# КОДОМ ниже, не прозой контракта): в режиме «предстоящее v+1» дверь
# scripts/check_contract_frozen.sh собирает окно коммитов-носителей текста
# (условие (б)) и требует РАЗРЕШИЛ-ВЛАДЕЛЕЦ для каждого. Сегодня окно
# собирается как `git log -s --diff-merges=first-parent <тег>..HEAD -- <путь>`:
# в список попадают MERGE-коммиты, у которых блоб пути РАВЕН первому родителю
# (diff пути к первому родителю пуст), но второй родитель — боковая ветка без
# файла/с другим файлом (int-merge). Такие merge текст контракта НЕ меняют, а
# дверь требует для каждого РАЗРЕШИЛ → CI красный «изменён без новой заморозки»
# → лечилось ручными grandfather-парами (уже 62). Целевое свойство: окно =
# коммиты диапазона, у которых diff пути к ПЕРВОМУ родителю НЕ пуст (обычный
# коммит — к единственному родителю; корневой — «добавил файл»; merge —
# git diff <c>^1 <c> -- <путь>).
#
# ── ТАБЛИЦА «клетка → миры → стабы» (замыкание класса «ложная достаточность»;
#    каждая операция целевой семантики — отбор log, фильтр первого родителя,
#    ветвление razrechen, grandfather (в)-ветки, hold/CI-ветки — имеет клетку,
#    краснеющую при её замене/удалении; стаб — подмена podmena.py именно этой
#    операции) ─────────────────────────────────────────────────────────────
#   m1  честный носитель v2 (РАЗРЕШИЛ+accept) + 3 int-merge с пустым p1-diff
#       и вторым родителем без файла → rc 0 «предстоящее v2» (CI-ветка)
#       → ловит s01 (прежний отбор: rc 1), s03 (пустое окно: ложный отказ), s05
#   m2  тот же мир, носитель БЕЗ РАЗРЕШИЛ → rc 1 «изменён без новой заморозки»
#       → ловит s03 (пустое окно «разрешено»: rc 0)
#   m3  evil merge: p1-diff непуст, РАЗРЕШИЛ нет → rc 1 → ловит s03
#   m4  merge с пустым p1-diff, но боковой коммит несёт ТОТ ЖЕ текст без
#       РАЗРЕШИЛ (изменение входит в дерево merge — обе линии дают одни байты)
#       → rc 1: боковой коммит остаётся в окне по правилу первого родителя
#       → ловит s02 (первая линия: боковой коммит не виден, rc 0)
#   m5  merge с непустым p1-diff, чья пара — в grandfather-аллоулисте (шим
#       расширяет список ОДНОЙ игрушечной парой; исходный список целиком),
#       дельта merge модифицирует и другой контракт → rc 0 «honored»
#       → ловит s04 (вызов grandfather в (в)-ветке снят: rc 1 «меняет ещё и»);
#       контроль: БЕЗ шима та же дверь rc 1 (пара не в списке)
#   m6  воспроизводящий мир диагноза: 10 int-merge (5 вторых родителей без
#       файла, 5 со старым текстом) + носитель с РАЗРЕШИЛ → rc 0
#       → ловит s01, s03, s05 (rc 1)
#   m7  вердикт v2 не accept (первая строка FAIL) при честном носителе → rc 1
#       (условие (а) сохранено) → ловит s03
#   m8  orphan-корень добавил файл, merge сохранил текст main → rc 1
#       (правило корня: корневой коммит в окне) → ловит s02 (rc 0)
#   m9  локальное удержание v2 == HEAD → rc 0 «равен локальному удержанию»
#       (сохранение hold-ветки (в); стабами не ловится — их зона отбор (б))
#   m10 удержание с другим блобом → rc 1 «не совпадает с локальным удержанием»
#   m11 регрессия семьи 016 fixtures/check_contract_frozen/: исходы всех кейсов
#       (rc/stdout/stderr) на живом субъекте и на модели побайтово равны — миры
#       семьи линейны, фильтр окна не активируется, равенство ловит побочные
#       изменения остальных ветвей двери (не ловится стабами — их зона отбор (б))
#   Операции с поведенчески неотличимой заменой на конформных мирах («=»):
#     --no-renames в пробе пустоты p1-diff = с rename-детекцией: путь один,
#       обе формы дают непустой diff при изменении/удалении/добавлении пути
#       (замер git 2.43 на мирах m1-m10);
#     порядок списка (log против rev-list) = обе меры хронологически обратны,
#       потребители окна (б)/(в) порядко-независимы (каждый коммит судится
#       отдельно, первого отказа достаточно).
#
# РЕЖИМЫ:
#   (без флага)  — субъект дерева scripts/check_contract_frozen.sh; до
#                  реализации красное (rc 1, красные m1/m6);
#   --model      — песочница podmena.py model: субъект + целевой блок окна;
#   --stabs      — контроль модели зелёный, затем каждый стаб podmena.py:
#                  красная клетка = стаб ПОЙМАН;
#   --repo <R>   — корень дерева субъектов (CI/станция).
#
# Миры — одноразовые git-репозитории вне ${TMPDIR:-/tmp}/dev-harness-verify
# (ловушка Н-85/А-122: scratch-allowlist 025 не должен прикрывать pass).
#
# КОДЫ: 0 — зелено (все клетки сошлись / все стабы пойманы); 1 — красная
# клетка либо живой стаб; 2 — нечем проверить. Скрипт не печатает PASS.
set -u

MODE='osn'; ROOT_ARG=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --model) MODE='model' ;;
    --stabs) MODE='stabs' ;;
    --repo)  ROOT_ARG="${2:?использование: [--model|--stabs] [--repo R]}"; shift ;;
    *) printf 'использование: %s [--model|--stabs] [--repo R]\n' "$0" >&2; exit 2 ;;
  esac
  shift
done
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
if [ -n "$ROOT_ARG" ]; then
  ROOT="$(cd "$ROOT_ARG" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень --repo не читается: %s\n' "$ROOT_ARG" >&2; exit 2; }
else
  ROOT="$(cd "$HERE/../../.." && pwd -P)"
fi

command -v bash    >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v git     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
command -v cmp     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет cmp\n' >&2; exit 2; }

[ -f "$ROOT/scripts/check_contract_frozen.sh" ] || { printf 'NOT_IMPLEMENTED: нет субъекта: %s\n' "$ROOT/scripts/check_contract_frozen.sh" >&2; exit 2; }
[ -f "$ROOT/scripts/check_charter.sh" ] || { printf 'NOT_IMPLEMENTED: нет устава-соавтора: %s\n' "$ROOT/scripts/check_charter.sh" >&2; exit 2; }

# Гигиена Н-85: унаследованные git-переменные подменяют предмет до первой команды.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

WB="$(mktemp -d /tmp/dev-harness-s200.XXXXXX)" || exit 2
trap 'rm -rf "$WB"' EXIT

PODMENA="$HERE/podmena.py"
SUBJEKT="$ROOT/scripts/check_contract_frozen.sh"
TRANSFORM='osn'
# песочница текущего преобразования: печать пути к её корню (scripts/ внутри).
# Уникальность — mktemp: счётчик в подстановке $( ) не виден родителю.
pesochinka() {
  local dst
  dst="$(mktemp -d "$WB/sb.XXXXXX")" || return 2
  case "$TRANSFORM" in
    osn)   python3 "$PODMENA" copy  "$ROOT/scripts" "$dst" >/dev/null || return 2 ;;
    model) python3 "$PODMENA" model "$ROOT/scripts" "$dst" >/dev/null || return 2 ;;
    s*)    python3 "$PODMENA" stub "$TRANSFORM" "$ROOT/scripts" "$dst" >/dev/null || return 2 ;;
  esac
  printf '%s' "$dst"
}
# ── строители мира ───────────────────────────────────────────────────────────
F='contracts/205-okno.md'
gm() { git -C "$REPO" -c user.name=fixtura -c user.email=fixtura@local \
          -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

# Миры ОДНОРАЗОВЫЕ: повторный прогон клетки (контроль модели, затем стабы)
# строит мир ЗАНОВО — иначе git init поверх живой истории достраивает вторую
# копию коммитов и окно теряет форму (замер: s02 молчал на достроенном m4).
mir() {  # <id> [sosed] — база: R0 без файла, v1 (файл+вердикт)+тег; носитель — nosi
  MIR="$WB/$1"; REPO="$MIR/repo"
  rm -rf "$MIR"
  mkdir -p "$REPO/contracts" "$REPO/verdicts/critic" "$REPO/docs"
  gm init -q -b main
  printf 'база до файла\n' > "$REPO/README.md"
  gm add -A; gm commit -qm R0
  MIR_R0="$(git -C "$REPO" rev-parse HEAD)"
  if [ "${2:-}" = sosed ]; then printf 'сосед v1\n' > "$REPO/contracts/999-sosed.md"; fi
  printf 'текст v1\n' > "$REPO/$F"
  printf 'accept\n' > "$REPO/verdicts/critic/contracts-205-v1.md"
  gm add -A; gm commit -qm 'v1'
  MIR_V1="$(git -C "$REPO" rev-parse HEAD)"
  gm tag -a frozen/contracts/205/1 -m 'заморозка v1: вердикт критика accept'
}

nosi() {  # [bez|''] [accept|fail] — носитель v2: текст v2 + вердикт v2; РАЗРЕШИЛ в теле (кроме bez)
  printf 'текст v2\n' > "$REPO/$F"
  printf '%s\nкруг второй\n' "${2:-accept}" > "$REPO/verdicts/critic/contracts-205-v2.md"
  gm add -A
  if [ "${1:-}" = bez ]; then
    gm commit -qm 'носитель v2 без строки владельца'
  else
    gm commit -qm 'носитель v2

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: "contracts/205-okno.md" слово владельца 2026-11-17 п.9'
  fi
}

intmerge() {  # <n> <от-коммита> — боковая ветка с работой в docs/, merge --no-ff
  gm checkout -q -b "side$1" "$2"
  mkdir -p "$REPO/docs"; printf "side$1\n" > "$REPO/docs/s$1.md"
  gm add -A; gm commit -qm "side$1: работа вне контрактов"
  gm checkout -q main
  gm merge -q --no-ff "side$1" -m "int-merge side$1"
}

# ── прогон субъекта: rc → PR_RC, вывод → $MIR/err ────────────────────────────
progon() {  # <субъект>
  bash "$1" "$REPO" > "$MIR/out" 2> "$MIR/err"
  PR_RC=$?
}

# ── клетки ───────────────────────────────────────────────────────────────────
m1() {
  mir m1; nosi
  local i
  for i in 1 2 3; do intmerge "$i" "$MIR_R0"; done
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 0 ] || { printf 'm1: rc=%s (нужен 0: честный носитель + 3 пустых по p1-diff int-merge со вторым родителем без файла)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'предстоящее v2' "$MIR/err" || { printf 'm1: нет строки «предстоящее v2»\n' >&2; return 1; }
  grep -aq 'локальное удержание недостижимо (CI)' "$MIR/err" || { printf 'm1: нет CI-ветки (в)\n' >&2; return 1; }
}

m2() {
  mir m2; nosi bez
  intmerge 1 "$MIR_R0"
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 1 ] || { printf 'm2: rc=%s (нужен 1: носитель без РАЗРЕШИЛ)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'изменён без новой заморозки' "$MIR/err" || { printf 'm2: нет отказа «изменён без новой заморозки»\n' >&2; return 1; }
}

m3() {
  mir m3; nosi
  gm checkout -q -b sideE "$MIR_R0"
  printf 'e\n' > "$REPO/docs/e.md"; gm add -A; gm commit -qm 'sideE: работа вне контрактов'
  gm checkout -q main
  gm merge -q --no-ff sideE -m 'int-merge sideE'
  printf 'текст v2 со злой правкой merge\n' > "$REPO/$F"; gm add -A
  gm commit -q --amend --no-edit -m 'int-merge sideE (злая правка контракта без РАЗРЕШИЛ)'
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 1 ] || { printf 'm3: rc=%s (нужен 1: evil merge, p1-diff непуст без РАЗРЕШИЛ)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'изменён без новой заморозки' "$MIR/err" || { printf 'm3: нет отказа (б)\n' >&2; return 1; }
}

m4() {
  mir m4; nosi
  gm checkout -q -b sideB "$MIR_V1"
  printf 'текст v2\n' > "$REPO/$F"; printf 'b\n' > "$REPO/docs/b.md"
  gm add -A; gm commit -qm 'sideB: тот же текст v2 без РАЗРЕШИЛ'
  gm checkout -q main
  gm merge -q --no-ff sideB -m 'int-merge sideB (обе линии дают одни байты)'
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 1 ] || { printf 'm4: rc=%s (нужен 1: боковой коммит с текстом без РАЗРЕШИЛ остаётся в окне)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'изменён без новой заморозки' "$MIR/err" || { printf 'm4: нет отказа (б)\n' >&2; return 1; }
}

m5() {
  mir m5 sosed; nosi
  gm checkout -q -b sideG "$MIR_V1"
  printf 'сосед v2\n' > "$REPO/contracts/999-sosed.md"; printf 'g\n' > "$REPO/docs/g.md"
  gm add -A; gm commit -qm 'sideG: модификация соседнего контракта'
  gm checkout -q main
  gm merge -q --no-ff sideG -m 'merge G'
  printf 'текст v2 G\n' > "$REPO/$F"; gm add -A
  gm commit -q --amend --no-edit -m 'merge G (правка контракта; разрешение — grandfather-пара)'
  local G; G="$(git -C "$REPO" rev-parse HEAD)"
  # контроль: пара НЕ в списке — та же дверь отказывает (шим — то, что меняет исход)
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 1 ] || { printf 'm5: без шима rc=%s (нужен 1: пары нет в аллоулисте)\n' "$PR_RC" >&2; return 1; }
  # песочница: субъект текущего преобразования + шим (одна игрушечная пара поверх исходного списка)
  local sb; sb="$(pesochinka)" || { printf 'm5: песочница не собрана\n' >&2; return 1; }
  if [ "$TRANSFORM" = osn ]; then
    cmp -s "$ROOT/scripts/check_contract_frozen.sh" "$sb/scripts/check_contract_frozen.sh" \
      || { printf 'm5: копия субъекта в песочнице не побайтно равна оригиналу\n' >&2; return 1; }
  fi
  python3 "$PODMENA" shim "$sb/scripts" "$G" "$F" >/dev/null || { printf 'm5: шим не вставлен\n' >&2; return 1; }
  progon "$sb/scripts/check_contract_frozen.sh"
  [ "$PR_RC" -eq 0 ] || { printf 'm5: с шимом rc=%s (нужен 0: grandfather-пара honored)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'предстоящее v2' "$MIR/err" || { printf 'm5: нет строки «предстоящее v2»\n' >&2; return 1; }
}

m6() {
  mir m6; nosi
  MIR_R0="$(git -C "$REPO" rev-list --max-parents=0 HEAD)"
  local i b
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if [ $((i % 2)) -eq 1 ]; then b="$MIR_R0"; else b="$MIR_V1"; fi
    intmerge "$i" "$b"
  done
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 0 ] || { printf 'm6: rc=%s (нужен 0: 10 int-merge диагноза + честный носитель)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'предстоящее v2' "$MIR/err" || { printf 'm6: нет строки «предстоящее v2»\n' >&2; return 1; }
}

m7() {
  mir m7; nosi '' fail
  MIR_R0="$(git -C "$REPO" rev-list --max-parents=0 HEAD)"
  intmerge 1 "$MIR_R0"
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 1 ] || { printf 'm7: rc=%s (нужен 1: вердикт v2 не accept — условие (а))\n' "$PR_RC" >&2; return 1; }
  grep -aq 'изменён без новой заморозки' "$MIR/err" || { printf 'm7: нет отказа\n' >&2; return 1; }
}

m8() {
  mir m8; nosi
  gm checkout -q --orphan orphan
  gm rm -rqf . >/dev/null 2>&1
  mkdir -p "$REPO/contracts"
  printf 'orphan\n' > "$REPO/only.txt"; printf 'текст v2 иной\n' > "$REPO/$F"
  gm add -A; gm commit -qm 'orphan-корень добавил файл'
  local ORPH; ORPH="$(git -C "$REPO" rev-parse HEAD)"
  gm checkout -q main
  gm merge -q --no-ff --allow-unrelated-histories "$ORPH" -m 'merge orphan' 2>/dev/null || {
    git -C "$REPO" checkout -q --ours -- "$F" 2>/dev/null
    gm add -A; gm commit -q --no-edit -m 'merge orphan (текст main сохранён)'
  }
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 1 ] || { printf 'm8: rc=%s (нужен 1: orphan-корень добавил файл — в окне без РАЗРЕШИЛ)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'изменён без новой заморозки' "$MIR/err" || { printf 'm8: нет отказа\n' >&2; return 1; }
}

m9() {
  mir m9; nosi
  git -C "$REPO" update-ref refs/frozen-hold/contracts/205/2 HEAD
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 0 ] || { printf 'm9: rc=%s (нужен 0: удержание == HEAD)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'равен локальному удержанию' "$MIR/err" || { printf 'm9: нет строки hold-ветки\n' >&2; return 1; }
}

m10() {
  mir m10; nosi
  git -C "$REPO" update-ref refs/frozen-hold/contracts/205/2 "$MIR_V1"
  progon "$SUBJEKT"
  [ "$PR_RC" -eq 1 ] || { printf 'm10: rc=%s (нужен 1: удержание с другим блобом)\n' "$PR_RC" >&2; return 1; }
  grep -aq 'не совпадает с локальным удержанием' "$MIR/err" || { printf 'm10: нет отказа hold-ветки\n' >&2; return 1; }
}
m11() {  # регрессия семьи 016 fixtures/check_contract_frozen/: исходы кейсов на
  # живом субъекте и на модели окна-200 побайтово равны (rc/stdout/stderr);
  # миры семьи линейны — фильтр окна на них не активируется, равенство доказывает
  # отсутствие побочных изменений остальных ветвей двери.
  local sem="$ROOT/fixtures/check_contract_frozen"
  [ -d "$sem" ] || { printf 'm11: нет семьи регрессии: %s\n' "$sem" >&2; return 1; }
  local sb; sb="$(pesochinka)" || { printf 'm11: песочница не собрана\n' >&2; return 1; }
  local c w1 w2 r1 r2 raz=0 n=0 d="$WB/m11.d"
  mkdir -p "$d"
  for c in "$sem"/case_*.sh; do
    n=$((n + 1))
    w1="$(mktemp -d "$WB/m11a.XXXXXX")"; w2="$(mktemp -d "$WB/m11b.XXXXXX")"
    ( cd "$ROOT" && BARRIER="$ROOT/scripts/check_contract_frozen.sh" WORK="$w1" bash "$c" ) >"$d/a.out" 2>"$d/a.err"; r1=$?
    ( cd "$ROOT" && BARRIER="$sb/scripts/check_contract_frozen.sh" WORK="$w2" bash "$c" ) >"$d/b.out" 2>"$d/b.err"; r2=$?
    if [ "$r1" != "$r2" ] || ! cmp -s "$d/a.err" "$d/b.err" || ! cmp -s "$d/a.out" "$d/b.out"; then
      printf 'm11: расхождение %s: rc %s vs %s\n' "$(basename "$c")" "$r1" "$r2" >&2
      raz=$((raz + 1))
    fi
    rm -rf "$w1" "$w2"
  done
  [ "$n" -gt 0 ] || { printf 'm11: кейсов семьи не найдено\n' >&2; return 1; }
  [ "$raz" -eq 0 ] || { printf 'm11: расхождений %d из %d\n' "$raz" "$n" >&2; return 1; }
}

# ── учёт клеток ──────────────────────────────────────────────────────────────
ALL_KLETKI='m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11'
CELL_TOTAL=0; CELL_RED=0
kletka() {  # <id> — ОДИН прогон клетки; диагностика — в файл мира
  local id="$1"
  CELL_TOTAL=$((CELL_TOTAL + 1))
  if "$id" >/dev/null 2>"$WB/diag-$id"; then
    printf 'ok   %s\n' "$id"
  else
    CELL_RED=$((CELL_RED + 1))
    printf 'FAIL %s — %s\n' "$id" "$(grep -aE '^[a-z0-9]+: ' "$WB/diag-$id" | sed -n 1p)"
  fi
}
run_cells() { local id; for id in "$@"; do kletka "$id"; done; }

# ── стабы: привязка к различающим клеткам — КОДОМ (Н-39) ─────────────────────
STABI=(s01 s02 s03 s04 s05)
stab_kletki() {
  case "$1" in
    s01) printf 'm1 m6' ;;
    s02) printf 'm4 m8' ;;
    s03) printf 'm2 m3 m7' ;;
    s04) printf 'm5' ;;
    s05) printf 'm1 m6' ;;
  esac
}

itog() { printf 'ИТОГ 200 (%s): клеток %d, красных %d, зелёных %d\n' "$1" "$CELL_TOTAL" "$CELL_RED" "$((CELL_TOTAL - CELL_RED))"; }

case "$MODE" in
  osn)
    run_cells $ALL_KLETKI
    itog 'субъекты дерева'
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'КРАСНОЕ 200: красных %d из %d (до реализации ожидаемо; после — дефект)\n' "$CELL_RED" "$CELL_TOTAL"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 200\n'
    exit 0
    ;;
  model)
    TRANSFORM='model'
    SB="$(pesochinka)" || { printf 'NOT_IMPLEMENTED: песочница модели не собрана\n' >&2; exit 2; }
    SUBJEKT="$SB/scripts/check_contract_frozen.sh"
    run_cells $ALL_KLETKI
    itog 'модель окна-200'
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'КРАСНОЕ 200-model: модель не покрывает клетки: красных %d из %d\n' "$CELL_RED" "$CELL_TOTAL"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 200-model\n'
    exit 0
    ;;
  stabs)
    TRANSFORM='model'
    SB="$(pesochinka)" || { printf 'NOT_IMPLEMENTED: песочница модели не собрана\n' >&2; exit 2; }
    SUBJEKT="$SB/scripts/check_contract_frozen.sh"
    run_cells $ALL_KLETKI >/dev/null
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'NOT_IMPLEMENTED: контроль модели красный (%d клеток) — оракул не зелён, стабы не судятся\n' "$CELL_RED" >&2
      exit 2
    fi
    POJMANO=0; ZHIVYH=0
    for s in "${STABI[@]}"; do
      TRANSFORM="$s"
      SB="$(pesochinka)" || { printf 'NOT_IMPLEMENTED: песочница стаба %s не собрана\n' "$s" >&2; exit 2; }
      SUBJEKT="$SB/scripts/check_contract_frozen.sh"
      CELL_TOTAL=0; CELL_RED=0
      run_cells $(stab_kletki "$s") >/dev/null
      if [ "$CELL_RED" -gt 0 ]; then
        POJMANO=$((POJMANO + 1))
        printf 'СТАБ 200: %s ПОЙМАН (клеток %d, красных %d)\n' "$s" "$CELL_TOTAL" "$CELL_RED"
      else
        ZHIVYH=$((ZHIVYH + 1))
        printf 'СТАБ 200: %s ЖИВ — все клетки зелёны (клеток %d)\n' "$s" "$CELL_TOTAL"
      fi
    done
    printf 'СТАБЫ 200: всего %d, поймано %d, живых %d\n' "${#STABI[@]}" "$POJMANO" "$ZHIVYH"
    if [ "$ZHIVYH" -gt 0 ]; then
      printf 'КРАСНОЕ 200-stabs: живой стаб не различим клетками: %d\n' "$ZHIVYH"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 200-stabs\n'
    exit 0
    ;;
esac
printf 'NOT_IMPLEMENTED: неизвестный режим %s\n' "$MODE" >&2
exit 2
