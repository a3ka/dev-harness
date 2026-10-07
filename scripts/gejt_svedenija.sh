#!/usr/bin/env bash
# НЕ БАРЬЕР: единый источник трёх правил (а)/(б)/(в) для accept / land / pre-merge-commit.
# Семья — probe-only fixtures/gejty_svedenija_086/ (маркер .probe-only, контракт 034).
# Вердикт выносит ТОЧКА: accept_task_commit / land_agent / pre-merge-commit хук.
#
# ПРЕДМЕТ (контракт 086 «Гейты сведения интеграции»):
#   (а) путь вне frozen-ЗОНЫ автора
#   (б) sync-merge (merge с родителем — предком main/origin/main, не предком другого родителя)
#   (в) устав-путь без строки РАЗРЕШИЛ-ВЛАДЕЛЕЦ в том же коммите
#
# КОНТРАКТ ВЫЗОВА (И-1/И-2/И-3 контракта 086):
#   scripts/gejt_svedenija.sh okno <корень> <база> <верх> <ветка> <точка>
#   scripts/gejt_svedenija.sh hook <корень> <точка> <коммит…>
#
#   okno:
#     <корень>  — путь к git-репозиторию
#     <база>    — 40-hex sha (грамматика ^[0-9a-f]{40}$)
#     <верх>    — 40-hex sha
#     <ветка>   — wip/<NNN>/<автор> (грамматика ^wip/[0-9]+/[A-Za-z0-9_-]+$)
#     <точка>   ∈ {accept, land, pre-merge-commit}
#   hook:
#     <корень>  — путь к git-репозиторию
#     <точка>   — для вывода (pre-merge-commit)
#     <коммит…> — множество 40-hex sha родителей merge (HEAD + вливаемые головы)
#
# ОКНО (режим okno): rev-list <база>..<верх> — на этом множестве применяются три правила.
# Маркер `окно 086: <база>..<верх> (N коммит.)` печатается на stderr ДО проверок.
#
# РЕАЛИЗАЦИЯ (Frontier 2 + 3 + 7, И-6 — победившая арбитражная форма, круг 3):
#   • (а) и (в) — НЕ вторая реализация предикатов поверх lib_zones.sh, а ВЫЗОВ существующих
#     судей check_zones.sh / check_charter.sh в режиме `--okno <база>` (Frontier 2). Суд идёт
#     на ПРОСПЕКТИВНОМ merge-дереве `land: <ветка>` (И-6): два родителя merge-base(база,верх)
#     и верх, хуки выключены, identity гейта. Тело merge = `land: <ветка>` + перенесённые
#     строки санкций (РАЗРЕШИЛ-ВЛАДЕЛЕЦ:/ALLOW-ARTIFACT-DELETE:) из тел коммитов база..верх
#     по правилу И-10 land_agent (дедуп точных повторов, синтез запрещён). check_zones и
#     check_charter на этом merge выносят вердикт ТАК ЖЕ, как после приземления ветки —
#     никаких дублей СПАСЕНО/draft-признаний/merge-обработки/исключений процессных файлов
#     не нужно; ЕДИНСТВЕННЫЙ источник — судьи.
#   • (б) — собственный обход merges окна <база>..<верх>: предикат sync ⟺
#     ∃ родители P≠Q merge M: P предок main/origin/main ∧ P не предок Q
#     (Frontier 4, без порядка родителей — L2 и L2b оба ловятся; предикат ОДИН для гейта
#     и хука, иначе расхождение — Н-7 ревьюера круг 4).
#
# ГРАММАТИКА ОТКАЗА (И-4 контракта 086, единый источник — гейт):
#   Строка отказа начинается `ОТКАЗ 086 (<точка>): `, несёт ровно один ярлык со своим
#   выходом и контекст. (а)/(в) — перед строкой отказа СТРОКИ FAIL судей (судьи печатают
#   путь и 8 hex коммита) — пробрасываются как есть; (б) — полный 40-hex sha merge (окно)
#   или полные 40-hex sha родителей (хук). Ярлыка несработавшего правила в выводе нет.
#
# СРАВНЕНИЯ (И-8 нормы 041): `[ = ]`, `grep -Fq`/`-Eqx` по замкнутым алфавитам.
# ИСХОД merge-base --is-ancestor ВНЕ {0, 1} — rc 2 (Frontier 7 + Б-7 адверсария круг 4);
# паттерн `cmd; rc=$?; if [ "$rc" != 0 ]` (НЕ `if ! cmd` — Б-8 ревьюера круг 4).
#
# Возврат: 0 — окно чисто, 1 — именованный отказ (FAIL + ОТКАЗ-строка),
# 2 — нечем проверить (нет git / не репозиторий / нет HEAD). Классификатор
# verify_antiplacebo судит роль файла ИСКЛЮЧИТЕЛЬНО по шапке «НЕ БАРЬЕР:» выше — литерал
# «Коды возврата:» здесь не повторяется, иначе файл классифицируется ОДНОВРЕМЕННО барьером
# и не-барьером (§1 классификатора) и отказывает.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Скратч для проспективного merge-дерева и linked worktree. По TMPDIR (как
# check_zones держит свой скратч в $ROOT/tmp — канон 014 для сорсимых из
# барьеров файлов, не для самого gate'а: его скратч ВНЕ корня).
TMP_BASE="${TMPDIR:-/tmp}"

# Строки оракула (побайтово из памяти батареи — `_toy.sh` строки O_A/O_B/O_V/...;
# оракул не перечитывает диск проверяемого, правило 8 нормы 041).
LABEL_A='правило (а) путь вне frozen-ЗОНЫ автора'
LABEL_B='правило (б) sync-merge'
LABEL_V='правило (в) устав-путь без строки РАЗРЕШИЛ'
VYHOD_A='выход: путь в зону — v+1 со словом владельца'
VYHOD_B='выход: пересобери ветку без merge main'
VYHOD_V='выход: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в том же коммите — словом владельца'

usage() {
  cat >&2 <<USAGE
использование: gejt_svedenija.sh okno <корень> <база> <верх> <ветка> <точка>
   или:        gejt_svedenija.sh hook <корень> <точка> <коммит…>

  okno — гейт сведения: (а)/(б)/(в) на окне <база>..<верх> ветки wip/<NNN>/<автор>.
  hook — предикат (б) для pre-merge-commit: rc 0 — не sync; rc 1 — sync-merge (отказ).

rc 0 — окно чисто / не sync; rc 1 — именованный отказ; rc 2 — нечем проверить.
USAGE
  exit 2
}

# ─── ЕДИНСТВЕННЫЙ ПРЕДИКАТ (б) (Frontier 7, Б-7 ревьюера круг 4) ────────────
# sync_violation_pairs <g-функция> <список-через-пробел-40-hex>:
#   выводит на stdout пару «P Q» (40-hex полностью), если ∃ P≠Q: P предок
#   main/origin/main ∧ P не предок Q. Иначе — пустой stdout. rc 2 при
#   аномальном исходе merge-base --is-ancestor (Фронт. 7 + Б-7 адверсария круг 4).
#   Источник истины ОДИН для окна (okno) и хука (hook) — иначе расхождение
#   предикатов в одном файле (Н-7 ревьюера круг 4).
#
# ГРАНИЦА ОБЪЕКТА origin/main: если origin не настроен ИЛИ refs/remotes/origin/main
# не существует (типичный случай toy-фикстур 086, не имеющих origin) — проверка
# ПРОПУСКАЕТСЯ (трактуется как «нет origin/main» = false, предикат сжимается
# до «P предок main»). Это НЕ «аномалия»: «remote origin не сконфигурирован» —
# штатное состояние toy-мира. Аномалия — это rc ∉ {0,1,128-объект-не-существует-в-репо-с-origin};
# см. И-7 буквально: «исход merge-base --is-ancestor ВНЕ {0, 1} → rc 2»,
# трактуется как аномалия ТОЛЬКО когда объект-родитель существует, но merge-base
# отказал по иной причине. Проверяем объект-родитель ДО merge-base.
#
# Паттерн захвата rc — `cmd; rc=$?; if [ "$rc" != 0 ]`, НЕ `if ! cmd` (после `!`
# `$?` уже флипнут в 0 и rc 2 → rc 1 теряется; Б-8 ревьюера круг 4).
sync_violation_pairs() {
  local g_fn="$1"
  local parents="$2"
  local -a harr
  local _p
  for _p in $parents; do
    [ -n "$_p" ] || continue
    harr+=("$_p")
  done
  local p1 p2 rc_anc rc_anc_o rc_n has_origin has_origin_main
  # Есть ли refs/remotes/origin/main? `git rev-parse --verify --quiet` —
  # rc 0 = есть, rc 1 = нет. Без `|| true` здесь — это проверка присутствия,
  # не «аномалия».
  if "$g_fn" rev-parse --verify --quiet refs/remotes/origin/main >/dev/null 2>&1; then
    has_origin_main=1
  else
    has_origin_main=0
  fi
  for p1 in "${harr[@]}"; do
    [ -n "$p1" ] || continue
    # 1) p1 — предок main? (ЛОВИМ rc явно.)
    "$g_fn" merge-base --is-ancestor "$p1" main >/dev/null 2>&1; rc_anc=$?
    # rc 0 = предок, rc 1 = не предок, ИНОЙ rc (например 128 «объект не найден»)
    # — аномалия git. Frontier 7: rc ∉ {0, 1} → rc 2.
    if [ "$rc_anc" -ne 0 ] && [ "$rc_anc" -ne 1 ]; then return 2; fi
    # 2) p1 — предок origin/main? Только если origin/main существует как ref.
    if [ "$has_origin_main" -eq 1 ]; then
      "$g_fn" merge-base --is-ancestor "$p1" origin/main >/dev/null 2>&1; rc_anc_o=$?
      if [ "$rc_anc_o" -ne 0 ] && [ "$rc_anc_o" -ne 1 ]; then return 2; fi
    else
      rc_anc_o=1  # трактуем «нет origin» как «не предок»
    fi
    if [ "$rc_anc" -ne 0 ] && [ "$rc_anc_o" -ne 0 ]; then continue; fi
    # 3) p1 НЕ предок p2? Тот же честный захват rc.
    for p2 in "${harr[@]}"; do
      [ -n "$p2" ] || continue
      [ "$p1" = "$p2" ] && continue
      "$g_fn" merge-base --is-ancestor "$p1" "$p2" >/dev/null 2>&1; rc_n=$?
      if [ "$rc_n" -ne 0 ] && [ "$rc_n" -ne 1 ]; then return 2; fi
      if [ "$rc_n" -ne 0 ]; then
        printf '%s %s\n' "$p1" "$p2"
        return 0
      fi
    done
  done
  return 0
}

# ─── Режим hook — только (б) ─────────────────────────────────────────────────
# Pre-merge-commit хук зовёт `gejt_svedenija.sh hook <корень> pre-merge-commit <p1> <p2>…`.
# Хук сам резолвит имена в коммиты (один источник резолва, чтобы хук не дублировал
# reflog-парсинг гейта) и передаёт уже коммиты. rc 0 — merge чист, rc 1 — отказ.
# Источник истины (Frontier 7): ОДИН предикат (б) для гейта и хука — функция выше.
if [ "${1:-}" = hook ]; then
  shift
  [ "$#" -ge 3 ] || { printf 'gejt_svedenija hook: ожидалось 3+ аргумента, дано %s\n' "$#" >&2; usage; }
  HOOK_ROOT="$1"; HOOK_POINT="$2"; shift 2
  HOOK_PARENTS="$*"
  command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
  HOOK_ROOT_CAN="$(cd "$HOOK_ROOT" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: корень не каталог: %s\n' "$HOOK_ROOT" >&2; exit 2; }
  git -C "$HOOK_ROOT_CAN" rev-parse --git-dir >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$HOOK_ROOT_CAN" >&2; exit 2; }
  case "$HOOK_POINT" in
    pre-merge-commit) ;;
    *) printf 'ОТКАЗ 086: точка вне алфавита: %s\n' "$HOOK_POINT" >&2; exit 1 ;;
  esac
  # Грамматика: каждый аргумент — 40-hex sha.
  for h in $HOOK_PARENTS; do
    if ! printf '%s\n' "$h" | grep -Eqx '[0-9a-f]{40}'; then
      printf 'ОТКАЗ 086 (%s): родитель merge вне грамматики sha: %s\n' "$HOOK_POINT" "$h" >&2
      exit 1
    fi
  done
  gh() { git -C "$HOOK_ROOT_CAN" "$@"; }
  # Предикат (б) — ОДНА функция-источник для хука и для гейта (Б-7 ревьюера круг 4).
  # Захват rc явно (НЕ `if !`; Б-8 ревьюера круг 4): rc 2 — аномалия merge-base,
  # пробрасывается (Frontier 7 + Б-7 адверсария круг 4).
  pair_out="$(sync_violation_pairs gh "$HOOK_PARENTS")"; pred_rc=$?
  if [ "$pred_rc" -eq 2 ]; then
    printf 'NOT_IMPLEMENTED: merge-base --is-ancestor вернул аномальный rc (sync-предикат) (Frontier 7)\n' >&2
    exit 2
  fi
  if [ -n "$pair_out" ]; then
    set -- $pair_out
    printf 'ОТКАЗ 086 (%s): %s; sha %s; sha %s; %s\n' \
      "$HOOK_POINT" "$LABEL_B" "$1" "$2" "$VYHOD_B" >&2
    exit 1
  fi
  exit 0
fi

# ─── Режим okno — основной гейт сведения ─────────────────────────────────────
[ "${1:-}" = okno ] || { printf 'gejt_svedenija: ожидалась подкоманда okno или hook\n' >&2; usage; }
shift

[ "$#" -eq 5 ] || { printf 'gejt_svedenija okno: ожидалось 5 аргументов, дано %s\n' "$#" >&2; usage; }
ROOT_ARG="$1"; BASE_ARG="$2"; TIP_ARG="$3"; BRANCH_ARG="$4"; POINT_ARG="$5"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Грамматика полей (И-8 контракта 086): замкнутые алфавиты, точечный якорь по границам.
if ! printf '%s\n' "$BASE_ARG" | grep -Eqx '[0-9a-f]{40}'; then
  printf 'ОТКАЗ 086 (%s): база окна вне грамматики sha: %s\n' "$POINT_ARG" "$BASE_ARG" >&2
  exit 1
fi
if ! printf '%s\n' "$TIP_ARG" | grep -Eqx '[0-9a-f]{40}'; then
  printf 'ОТКАЗ 086 (%s): верх окна вне грамматики sha: %s\n' "$POINT_ARG" "$TIP_ARG" >&2
  exit 1
fi
if ! printf '%s\n' "$BRANCH_ARG" | grep -Eqx 'wip/[0-9]+/[A-Za-z0-9_-]+'; then
  printf 'ОТКАЗ 086 (%s): ветка вне грамматики wip/NNN/автор: %s\n' "$POINT_ARG" "$BRANCH_ARG" >&2
  exit 1
fi
case "$POINT_ARG" in
  accept|land|pre-merge-commit) ;;
  *) printf 'ОТКАЗ 086: точка вне алфавита: %s\n' "$POINT_ARG" >&2; exit 1 ;;
esac

# Канонизация корня.
ROOT="$(cd "$ROOT_ARG" 2>/dev/null && pwd -P 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: корень не каталог: %s\n' "$ROOT_ARG" >&2; exit 2; }
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' "$ROOT" >&2; exit 2; }
git -C "$ROOT" cat-file -e "$BASE_ARG^{commit}" 2>/dev/null \
  || { printf 'NOT_IMPLEMENTED: база окна не объект-коммит: %s\n' "$BASE_ARG" >&2; exit 2; }
git -C "$ROOT" cat-file -e "$TIP_ARG^{commit}" 2>/dev/null \
  || { printf 'NOT_IMPLEMENTED: верх окна не объект-коммит: %s\n' "$TIP_ARG" >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

# Размер окна — rev-list --count (И-5: «N = rev-list --count»).
WINDOW_N=$(g rev-list --count "$BASE_ARG..$TIP_ARG" 2>/dev/null) || {
  printf 'NOT_IMPLEMENTED: rev-list отказал\n' >&2; exit 2; }
if [ "${WINDOW_N:-0}" -eq 0 ]; then
  printf 'NOT_IMPLEMENTED: окно пусто (%s..%s)\n' "$BASE_ARG" "$TIP_ARG" >&2
  exit 2
fi
printf 'окно 086: %s..%s (%s коммит.)\n' "$BASE_ARG" "$TIP_ARG" "$WINDOW_N" >&2

# ── (б) SYNC-MERGE — ОКНО (Frontier 4 + 7, И-3) ─────────────────────────────
# Окно проверяется по тому же предикату, что и хук: ∃ P≠Q: P предок main/origin/main
# ∧ P не предок Q. Окно = merge M в <база>..<верх>; формат И-4: sha merge (окно).
# ЕДИНСТВЕННЫЙ источник предиката — функция sync_violation_pairs, та же, что
# использует хук (Б-7 ревьюера круг 4). Захват rc явно (Б-8 ревьюера круг 4).
sync_window=0
sync_sha=""
while IFS= read -r m; do
  [ -n "$m" ] || continue
  parents="$(g log -1 --format='%P' "$m" 2>/dev/null)" || continue
  case "$parents" in
    *' '*) ;;  # merge
    *) continue ;;  # не-merge
  esac
  pair_out="$(sync_violation_pairs g "$parents")"; pred_rc=$?
  if [ "$pred_rc" -eq 2 ]; then
    printf 'NOT_IMPLEMENTED: merge-base --is-ancestor вернул аномальный rc (sync-предикат) (Frontier 7)\n' >&2
    exit 2
  fi
  if [ -n "$pair_out" ]; then
    sync_window=1
    sync_sha="$m"
    break
  fi
done < <(g rev-list --merges "$BASE_ARG..$TIP_ARG" 2>/dev/null)
if [ "$sync_window" -eq 1 ]; then
  # Формат И-4 для (б) на ОКНЕ — полный sha merge (НЕ родители, родители — формат хука).
  printf 'ОТКАЗ 086 (%s): %s; sha %s; %s\n' "$POINT_ARG" "$LABEL_B" "$sync_sha" "$VYHOD_B" >&2
  exit 1
fi

# ── ПРОСПЕКТИВНЫЙ MERGE (Frontier 2 + 3, И-6) ────────────────────────────────
# Строим merge `land: <ветка>` с двумя родителями: merge-base(база, верх) и верх.
# Тело: `land: <ветка>` + строки санкций из тел коммитов диапазона `база..верх` по
# правилу И-10 land_agent (РАЗРЕШИЛ-ВЛАДЕЛЕЦ:/ALLOW-ARTIFACT-DELETE: в первой колонке,
# дословно, дедуп точных повторов; синтез запрещён). Identity гейта. Хуки выключены.
# Затем — linked worktree --detach на этот merge. На нём зовём check_zones и check_charter
# в режиме `--okno <база>`. Решение — по rc судей, НЕ по grep строк FAIL.
MB=$(g merge-base "$BASE_ARG" "$TIP_ARG" 2>/dev/null) || {
  printf 'NOT_IMPLEMENTED: merge-base отказал\n' >&2; exit 2; }

# Сборка тела merge: первая строка `land: <ветка>`, далее строки санкций.
TMP="$(mktemp -d "$TMP_BASE/gejt_086.XXXXXX")"
PROSP_WT=""
trap 'rm -rf "$TMP" 2>/dev/null; if [ -n "$PROSP_WT" ] && [ -d "$PROSP_WT" ]; then g worktree remove --force "$PROSP_WT" 2>/dev/null; fi; true' EXIT

g log --format=%B "$BASE_ARG..$TIP_ARG" \
  | awk '(/^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:/ || /^ALLOW-ARTIFACT-DELETE:/) && !seen[$0]++' > "$TMP/sanctions" 2>/dev/null || : > "$TMP/sanctions"
{
  printf 'land: %s\n' "$BRANCH_ARG"
  cat "$TMP/sanctions"
} > "$TMP/msg"

# Identity гейта (контракт 086 И-6: «identity гейта»). Задаём через env-переменные
# commit-tree, чтобы merge нёс ИЗВЕСТНОЕ имя, не случайное (check_zones судит
# авторов; merge с «никем» в ЗОНА-строках не судят).
GIT_AUTHOR_NAME='gejt_svedenija'
GIT_AUTHOR_EMAIL='gejt_svedenija@dev-harness.local'
GIT_COMMITTER_NAME='gejt_svedenija'
GIT_COMMITTER_EMAIL='gejt_svedenija@dev-harness.local'
GIT_AUTHOR_DATE='2026-10-06T00:00:00Z'
GIT_COMMITTER_DATE='2026-10-06T00:00:00Z'
export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL \
       GIT_AUTHOR_DATE GIT_COMMITTER_DATE

# commit-tree. Дерево берём из верхнего коммита диапазона (тот, что приземляем).
TREE_OBJ=$(g rev-parse "${TIP_ARG}^{tree}" 2>/dev/null) || {
  printf 'NOT_IMPLEMENTED: rev-parse ^{tree} отказал\n' >&2; exit 2; }
PM=$(g commit-tree "$TREE_OBJ" -p "$MB" -p "$TIP_ARG" < "$TMP/msg" 2>/dev/null) || {
  printf 'NOT_IMPLEMENTED: commit-tree проспективного merge отказал\n' >&2; exit 2; }
[ -n "$PM" ] || { printf 'NOT_IMPLEMENTED: commit-tree не выдал sha\n' >&2; exit 2; }

# Linked worktree --detach на проспективный merge. По $TMP_BASE (НЕ под корнем:
# канон 014 «скратч ВНЕ корня»). Очищается по EXIT через trap.
PROSP_WT="$TMP_BASE/gejt_086_prosp_$$"
g worktree add --detach "$PROSP_WT" "$PM" >/dev/null 2>&1 || {
  printf 'NOT_IMPLEMENTED: worktree add на проспективный merge отказал\n' >&2
  exit 2; }

# ── (а) — check_zones в режиме --okno ───────────────────────────────────────
# Frontier 2: check_zones в режиме --okno <база>. Суд идёт на ПРОСПЕКТИВНОМ
# merge-дереве ($PROSP_WT) — ровно так, как check_zones судил бы после приземления
# ветки (Frontier 3). БЕЗ собственного обхода (а) в гейте. Решение — по rc судьи,
# НЕ по grep строк FAIL: check_zones печатает FAIL грамматики ЗОНА contracts/055,
# не входящий в rc (§Остаточный риск контракта 086).
# ЧЕСТНЫЙ захват rc (НЕ `if ! X=$(…); then rc=$?; …` — после `!` `$?` уже
# флипнут в 0 и rc 2 → rc 1 теряется; Б-8 ревьюера круг 4).
ZONES_RC=0
ZONES_OUT="$(bash "$SELF_DIR/check_zones.sh" "$PROSP_WT" --okno "$BASE_ARG" 2>&1)"; ZONES_RC=$?
case "$ZONES_RC" in
  0) ;;  # чисто
  2) printf '%s\n' "$ZONES_OUT" >&2; exit 2 ;;
  1)
    # Пробрасываем строки FAIL (путь и 8 hex коммита — И-4 «строка FAIL судьи
    # на каждое нарушение»), затем — ОДНА строка ОТКАЗ.
    printf '%s\n' "$ZONES_OUT" >&2
    printf 'ОТКАЗ 086 (%s): %s; %s\n' "$POINT_ARG" "$LABEL_A" "$VYHOD_A" >&2
    exit 1
    ;;
  *)
    printf 'ОТКАЗ 086 (%s): check_zones вернул неожиданный rc=%s\n' "$POINT_ARG" "$ZONES_RC" >&2
    printf '%s\n' "$ZONES_OUT" >&2
    exit 1
    ;;
esac

# ── (в) — check_charter в режиме --okno ─────────────────────────────────────
# Тот же протокол с честным захватом rc (Б-8 ревьюера круг 4).
CHARTER_RC=0
CHARTER_OUT="$(bash "$SELF_DIR/check_charter.sh" "$PROSP_WT" --okno "$BASE_ARG" 2>&1)"; CHARTER_RC=$?
case "$CHARTER_RC" in
  0) ;;  # чисто
  2) printf '%s\n' "$CHARTER_OUT" >&2; exit 2 ;;
  1)
    printf '%s\n' "$CHARTER_OUT" >&2
    printf 'ОТКАЗ 086 (%s): %s; %s\n' "$POINT_ARG" "$LABEL_V" "$VYHOD_V" >&2
    exit 1
    ;;
  *)
    printf 'ОТКАЗ 086 (%s): check_charter вернул неожиданный rc=%s\n' "$POINT_ARG" "$CHARTER_RC" >&2
    printf '%s\n' "$CHARTER_OUT" >&2
    exit 1
    ;;
esac

# Окно чисто.
exit 0
