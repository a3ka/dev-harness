#!/usr/bin/env bash
# Красное 040 v3 (Н-126 доп.) — check_protected.sh: (А) ДИФФЕРЕНЦИАЛЬНЫЙ
# структурный (без wall-clock) предел git-вызовов, (Б) КОРРЕКТНОСТЬ на `-s
# ours`-пропаже И на дубликат-блоб-пропаже — НА ОБОИХ toy-деревьях, (В) ТРИ
# живых подтверждения техники diff-tree --stdin (РЕШЕНИЕ арбитража, §Б4).
#
# РЕШЕНИЕ АРБИТРАЖА (verdicts/arbitration/040-batching-kriterii-i-tehnika.md):
#
# §Б1 — «тот же критерий обязателен для Р2»: абсолютная граница BOUND=30
#   пропускала мутант, батчащий первые 55 из 60 фоновых коммитов (12<=30).
#   Дифференциальная пара M_low=60/M_high=360 (тот же S, что у check_zones,
#   Δ=300>=2·S) закрывает класс тем же неравенством, что и Б1 для check_zones:
#   честная реализация не растёт с M вовсе (O(1) на употребление), любой
#   оставшийся по-коммитный хвост растёт С M и превышает S на M_high.
#
# §Б4 — «rev-list --objects — неправильный КЛАСС техники»: она перечисляет
#   УНИКАЛЬНЫЕ ОБЪЕКТЫ с ОДНИМ представительным именем на объект, а барьеру
#   нужно множество ПАР «путь в дереве достижимого коммита» — при двух путях
#   с идентичными байтами (один блоб) она МОЛЧА теряет имя второго. Замена —
#   НЕ дополнение, а полная замена — техникой A2:
#     git rev-list HEAD | git diff-tree -r --root -m --no-renames
#         {--name-only|--raw} --stdin -- <pathspec>
#   `--root` обязателен (иначе теряется путь, живущий с корневого коммита —
#   diff-tree без --root пропускает root-коммиты целиком), `-m` обязателен
#   (иначе теряется путь, СОЗДАННЫЙ в самом мерж-коммите — без -m мерж-коммиты
#   не диффятся вовсе), `--no-renames` обязателен (иначе результат зависит от
#   `diff.renames` конфига машины читателя). Три риска измерены арбитром (З2)
#   и воспроизведены здесь живьём на РАВНО ТОМ ЖЕ классе toy.
#
# Старые шаги «п.В»/«форма 1»/«форма 2» (наивная rev-list --objects БЕЗ
# --full-history теряет `-s ours`-путь; --full-history и «без pathspec+фильтр»
# его находят) УДАЛЕНЫ ЦЕЛИКОМ вместе со СНЯТОЙ техникой — они проверяли риск
# запрещённого теперь класса. Поправка 1 владельца (запрет наивной формы)
# снята вместе с ним (§Б4 РЕШЕНИЕ п.2 — средство было ошибочным, не вкусовым).
#
# СЧЁТЧИК ВЫЗОВОВ — НИ PATH-шим, НИ УНАСЛЕДОВАННАЯ ПЕРЕМЕННАЯ (контракт 046,
# Н-130). PATH-шим стирается строкой субъекта `export PATH=/usr/bin:/bin` ДО
# первой внешней команды — это было верно с 039. Прежняя форма счётчика
# (`env SHELLOPTS=xtrace BASH_XTRACEFD=9`, приём `check_spec_ready.sh:246-253`)
# опиралась на УНАСЛЕДОВАННЫЕ переменные и умирает от герметичного окружения:
# check_protected.sh получает `exec /usr/bin/env -i PATH=… LC_ALL=… bash "$0"`
# первой же строкой кода (контракт 046 закрывает функцию-тень `comm`), а `env -i`
# стирает ОБЕ измерительные переменные вместе со всем остальным унаследованным.
# Замер architect'а контракта 046 на ЖИВОЙ паре: тот же toy, тот же файл, старая
# форма счётчика — `LOW=29` на сегодняшнем барьере и `LOW=0` на пофикшенном, при
# rc=0 и дословном «ПРЕДЕЛ ДЕРЖИТСЯ» в обоих случаях. То есть страж перестал бы
# отличать предмет контракта 040 от его полного отсутствия, оставаясь зелёным.
#
# `strace -f -e trace=execve` смотрит СНАРУЖИ процесса через ptrace на уровне ЯДРА:
# канал не проходит через окружение субъекта и не стирается ничем, что субъект
# делает со своими переменными (`env -i`, `unset`, экспортированные функции) —
# execve есть syscall, о нём ядро сообщает трассирующему ДО того, как у нового
# образа появится шанс исполнить хоть одну инструкцию. Форма и счётная строка
# взяты ПОБАЙТОВО у близнеца `fixtures/check_zones/red_predel_git_vyzovov.sh`
# (ревью-круг 040, `b38e78a`, там же живой прогон на CI-раннере ubuntu-24.04 со
# strace 6.8) — не изобретаются заново. Локальная рабочая станция strace не несёт
# (`command -v strace` rc=1 — измерено), поэтому здесь явный NOT_IMPLEMENTED-гард
# тем же классом, что уже стоит на git: измерение живёт там, где утилита есть (CI).
# ОСТАТОЧНЫЙ РИСК (наследуется от близнеца): `-e trace=execve` не покрывает
# `execveat`; ни bash, ни git в этом стеке им не пользуются.
#
# Коды возврата: 0 — оба предела держатся И корректность (ours + дубликат-блоб)
#                не потеряна НА ОБОИХ деревьях И все три риска техники
#                подтверждены; 1 — именованный отказ; 2 — NOT_IMPLEMENTED.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CP="$REPO/scripts/check_protected.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/red040-protected.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
[ -f "$CP" ] || { printf 'NOT_IMPLEMENTED: субъект не найден: %s\n' "$CP" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v strace >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет strace (run_trace требует внешнюю syscall-трассировку — см. комментарий там)\n' >&2; exit 2; }

fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

# ── параметры (Б1, "тот же S", что и check_zones) ──────────────────────────
M_LOW=60
M_HIGH=360
S=15
BOUND=30

# build_tree <M> <outdir> — база (roles/adversary + -s ours-пропажа + пара
# идентичных-по-байтам путей, один удалён без ALLOW — новый постоянный красный
# вход §Б4 п.4) + M фоновых коммитов ПОСЛЕ. База ОДИНАКОВА между LOW/HIGH —
# единственная переменная это M (дифференциальный опыт, Б1).
build_tree() {
  local M="$1" R="$2" j
  mkdir -p "$R/roles" "$R/plans" "$R/verdicts/adversary"
  g() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" \
        -c user.name=Фикстура -c user.email=fixture@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
  commit_all() { g add -A; g commit -q -m "$1"; }

  printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\nадверсарий\n' > "$R/roles/adversary.md"
  printf 'подставной план\n'    > "$R/plans/001-p.md"
  printf 'подставной вердикт\n' > "$R/verdicts/adversary/v-a.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
  commit_all 'основание'

  g checkout -q -b vetka
  printf 'план из ветки\n' > "$R/plans/002-vetka.md"
  commit_all 'план добавлен в ветке'
  g checkout -q main
  g merge -q -s ours vetka -m 'ветка влита стратегией ours'

  # НОВЫЙ постоянный красный вход (§Б4 РЕШЕНИЕ п.4): два пути с ИДЕНТИЧНЫМИ
  # байтами (один блоб), один удалён БЕЗ ALLOW и без переноса. Сегодняшний
  # (медленный, per-commit ls-tree) check_protected.sh корректен здесь (не
  # использует rev-list --objects) — обязан остаться rc=1 И ПОСЛЕ батчинга:
  # это оракул, отличающий ПРАВИЛЬНЫЙ класс техники (diff-tree --stdin) от
  # ЗАПРЕЩЁННОГО (rev-list --objects, §Б4).
  printf 'одинаковые байты\n' > "$R/plans/910-a.md"
  printf 'одинаковые байты\n' > "$R/plans/910-b.md"
  commit_all 'добавлена пара идентичных-по-байтам путей'
  rm -f "$R/plans/910-b.md"
  commit_all 'удалён 910-b.md (дубликат-блоб) без ALLOW'

  j=1
  while [ "$j" -le "$M" ]; do
    g commit -q --allow-empty -m "фон $j"
    j=$((j + 1))
  done
}

# run_trace <repo> — прогоняет check_protected.sh под ВНЕШНЕЙ syscall-трассировкой
# (иммунна и к `export PATH` субъекта, и к `env -i` re-exec'у — см. «СЧЁТЧИК
# ВЫЗОВОВ» в шапке); заполняет глобальные RC/OUT/CALLS.
#
# Счёт — по PATHNAME-аргументу execve (первая строка вызова, ДО argv-массива), не по
# имени программы в argv[0] и не по shell-уровню: счётчик на уровне syscall агностичен
# к shell-обёрткам по построению. Якорь на закрывающую кавычку сразу после `git`
# отсекает `gitk`, `git-upload-pack` и любого другого префиксного тёзку.
run_trace() {
  local R="$1" TRACE
  TRACE="$WORK/trace.$RANDOM.$$"
  : > "$TRACE"
  OUT="$(strace -f -e trace=execve -o "$TRACE" bash "$CP" "$R" 2>&1)"; RC=$?
  CALLS="$(grep -cE 'execve\("([^"]*/)?git", \[' "$TRACE")"
}

# ── дерево LOW (M=60) ───────────────────────────────────────────────────────
R_LOW="$WORK/repo-low"
build_tree "$M_LOW" "$R_LOW"
run_trace "$R_LOW"
RC_LOW="$RC"; OUT_LOW="$OUT"; CALLS_LOW="$CALLS"

# ── дерево HIGH (M=360) ──────────────────────────────────────────────────────
R_HIGH="$WORK/repo-high"
build_tree "$M_HIGH" "$R_HIGH"
run_trace "$R_HIGH"
RC_HIGH="$RC"; OUT_HIGH="$OUT"; CALLS_HIGH="$CALLS"

# ── ЖИВОСТЬ МЕРЫ (контракт 046): НОЛЬ — КРАСНОЕ, А НЕ ЗЕЛЁНОЕ ────────────────
# Ноль git-вызовов под трассировкой значит не «батчинг идеален», а «счётчик не видит
# субъекта»: ровно так прежняя форма (`SHELLOPTS=xtrace`) умирала от герметичного
# окружения, оставляя «ПРЕДЕЛ ДЕРЖИТСЯ» с LOW=0 (замер контракта 046). Любая граница
# сравнения вида `N <= BOUND` на мёртвой мере проходит ТРИВИАЛЬНО, поэтому проверка
# живости стоит ДО обеих границ и отказывает своей причиной. Барьер, читающий историю
# из 60+ коммитов, обязан звать git не меньше одного раза на КАЖДОМ дереве.
[ "$CALLS_LOW" -gt 0 ] && [ "$CALLS_HIGH" -gt 0 ] \
  || fail "мера мертва: git-вызовов под трассировкой LOW=$CALLS_LOW HIGH=$CALLS_HIGH — счётчик не видит субъекта (канал трассировки стёрт), пустая выборка красная, а не зелёная"

# ── п.Б (Н-39, на ОБОИХ деревьях): ours-пропажа И дубликат-блоб-пропажа ─────
for pair in "LOW:$RC_LOW:$OUT_LOW" "HIGH:$RC_HIGH:$OUT_HIGH"; do
  label="${pair%%:*}"; rest="${pair#*:}"; rc="${rest%%:*}"; out="${rest#*:}"
  [ "$rc" -eq 1 ] || fail "$label: check_protected.sh rc=$rc, ожидался 1
$out"
  printf '%s\n' "$out" | grep -qF 'существовал и на HEAD его нет: plans/002-vetka.md' \
    || fail "$label: причина ours-пропажи не названа дословно
$out"
  printf '%s\n' "$out" | grep -qF 'существовал и на HEAD его нет: plans/910-b.md' \
    || fail "$label: причина дубликат-блоб-пропажи не названа дословно (§Б4 п.4)
$out"
done
printf 'п.Б держится НА ОБОИХ деревьях (M=%d и M=%d): ours-пропажа И дубликат-блоб-пропажа пойманы\n' "$M_LOW" "$M_HIGH" >&2

printf 'git-подпроцессов: LOW(M=%d)=%d, HIGH(M=%d)=%d\n' "$M_LOW" "$CALLS_LOW" "$M_HIGH" "$CALLS_HIGH" >&2

# ── п.А (ГРУБЫЙ, абсолютный, на LOW) ────────────────────────────────────────
printf 'абсолютная граница (грубая, на LOW): %d - граница: %d\n' "$CALLS_LOW" "$BOUND" >&2
[ "$CALLS_LOW" -le "$BOUND" ] \
  || fail "git-вызовов на LOW $CALLS_LOW > грубой границы $BOUND — O(коммитов) пере-скан похоже не заменён вовсе"

# ── п.В (РЕШАЮЩИЙ, дифференциальный): C_high - C_low <= S, Δ>=2·S ──────────
delta_M=$((M_HIGH - M_LOW))
[ "$delta_M" -ge $((2 * S)) ] || fail "конструкция фикстуры нарушена: Δ=$delta_M < 2*S=$((2 * S))"
diff_calls=$((CALLS_HIGH - CALLS_LOW))
printf 'дифференциал: C_high(%d) - C_low(%d) = %d - граница S = %d (Δ=%d, Δ>=2S: %d>=%d)\n' \
  "$CALLS_HIGH" "$CALLS_LOW" "$diff_calls" "$S" "$delta_M" "$delta_M" "$((2 * S))" >&2
[ "$diff_calls" -le "$S" ] \
  || fail "дифференциал git-вызовов $diff_calls > S=$S — O(коммитов) пере-скан (roleblobs и/или existed.raw остались по-коммитными)"

# ── ТРИ живых подтверждения техники (§Б4, замер арбитра З2) ─────────────────
# Отдельный маленький toy: путь с корневого коммита (никогда не менявшийся),
# путь, СОЗДАННЫЙ в самом мерж-коммите (реальный two-parent merge, не -s
# ours), и пара путей с ОДИНАКОВЫМИ байтами (один блоб), второй удалён.
T="$WORK/repo-tech"
mkdir -p "$T/plans"
t() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$T" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$T"
printf 'root\n' > "$T/plans/000-root.md"
t add -A; t commit -q -m 'root commit with root-only path'

t checkout -q -b feature
printf 'feature\n' > "$T/plans/001-feature.md"
t add -A; t commit -q -m 'feature commit'
t checkout -q main
printf 'main\n' > "$T/plans/002-main.md"
t add -A; t commit -q -m 'main commit'
t merge -q --no-ff feature -m 'merge feature'
printf 'merge-born\n' > "$T/plans/003-merge-born.md"
t add -A
t commit -q --amend --no-edit

printf 'одинаковые байты\n' > "$T/plans/900-a.md"
printf 'одинаковые байты\n' > "$T/plans/900-b.md"
t add -A; t commit -q -m 'add dup-blob pair'
rm -f "$T/plans/900-b.md"
t add -A; t commit -q -m 'delete 900-b.md (dup-blob)'

old_paths="$(t rev-list HEAD --objects --full-history -- ':(literal)plans/' | awk 'NF>1{print $2}')"
new_paths="$(t rev-list HEAD | t diff-tree -r --root -m --no-renames --name-only --stdin -- ':(literal)plans/' | grep -vE '^[0-9a-f]{40}$')"
noroot_paths="$(t rev-list HEAD | t diff-tree -r -m --no-renames --name-only --stdin -- ':(literal)plans/' | grep -vE '^[0-9a-f]{40}$')"
nom_paths="$(t rev-list HEAD | t diff-tree -r --root --no-renames --name-only --stdin -- ':(literal)plans/' | grep -vE '^[0-9a-f]{40}$')"

# 1. Дубликат-блоб: СТАРАЯ техника ТЕРЯЕТ 900-b.md, НОВАЯ держит.
if printf '%s\n' "$old_paths" | grep -qF 'plans/900-b.md'; then
  fail "риск 1 не воспроизведён: старая техника (rev-list --objects) НАШЛА plans/900-b.md — вход не работает на этом git"
fi
printf '%s\n' "$new_paths" | grep -qF 'plans/900-b.md' \
  || fail "риск 1: НОВАЯ техника (diff-tree --stdin) тоже потеряла plans/900-b.md — регрессия самой техники"
printf 'риск 1 подтверждён: дубликат-блоб — старая техника (rev-list --objects) ТЕРЯЕТ plans/900-b.md, новая (diff-tree --root -m --stdin) ДЕРЖИТ\n' >&2

# 2. Без --root теряется корневой путь.
if printf '%s\n' "$noroot_paths" | grep -qF 'plans/000-root.md'; then
  fail "риск 2 не воспроизведён: diff-tree БЕЗ --root всё равно нашёл plans/000-root.md"
fi
printf '%s\n' "$new_paths" | grep -qF 'plans/000-root.md' \
  || fail "риск 2: полная форма (С --root) тоже не нашла plans/000-root.md"
printf 'риск 2 подтверждён: diff-tree БЕЗ --root теряет plans/000-root.md (корневой коммит), С --root — держит\n' >&2

# 3. Без -m теряется путь, созданный в самом мерж-коммите.
if printf '%s\n' "$nom_paths" | grep -qF 'plans/003-merge-born.md'; then
  fail "риск 3 не воспроизведён: diff-tree БЕЗ -m всё равно нашёл plans/003-merge-born.md"
fi
printf '%s\n' "$new_paths" | grep -qF 'plans/003-merge-born.md' \
  || fail "риск 3: полная форма (С -m) тоже не нашла plans/003-merge-born.md"
printf 'риск 3 подтверждён: diff-tree БЕЗ -m теряет plans/003-merge-born.md (путь мерж-коммита), С -m — держит\n' >&2

printf 'ПРЕДЕЛ ДЕРЖИТСЯ: LOW=%d<=%d (грубо) И дифференциал %d<=%d (решающе) И все 3 риска техники подтверждены\n' \
  "$CALLS_LOW" "$BOUND" "$diff_calls" "$S" >&2
exit 0
