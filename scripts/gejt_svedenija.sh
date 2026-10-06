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
#
#   <корень>  — путь к git-репозиторию
#   <база>    — 40-hex sha (грамматика ^[0-9a-f]{40}$)
#   <верх>    — 40-hex sha
#   <ветка>   — wip/<NNN>/<автор> (грамматика ^wip/[0-9]+/[A-Za-z0-9_-]+$)
#   <точка>   ∈ {accept, land, pre-merge-commit}
#
# ОКНО: rev-list <база>..<верх> — на этом множестве применяются три правила.
# Маркер `окно 086: <база>..<верх> (N коммит.)` печатается на stderr ДО проверок.
#
# РЕАЛИЗАЦИЯ (Frontier 3 + «проспективный ленд» контракта 086):
#   • (а) и (в) — САМОСТОЯТЕЛЬНЫЙ обход не-merge коммитов диапазона merge-base(база,верх)..верх
#     по first-parent (проспективный ленд: те коммиты, что check_zones осудил бы после
#     приземления ветки). Суд идёт ТОЛЬКО в ЗОНАХ контракта ветки (NNN из wip/<NNN>/<author>).
#     Контракт ветки не заморожен ⟺ зон нет ⟺ судить нечего ⟺ коммиты exempt (A5: architect
#     создаёт draft 901 — зон 901 нет, документные пути не судятся; L5: то же для 902).
#     Контракт ветки заморожен ⟺ судятся пути в ЗОНАХ NNN + устав-NNN. Те же lib_zones.sh,
#     check_charter.sh (CHARTER_LIB=1), draft-признание contracts/<M>-* (рука Б), СПАСЕНО
#     (saved-пары), процессный фильтр, грандфазер — единый источник кода (Frontier 2).
#   • (б) — собственный обход merges окна <база>..<верх>: предикат sync ⟺
#     ∃ родители P≠Q merge M: P предок main/origin/main ∧ P не предок Q
#     (Frontier 4, без порядка родителей — L2 и L2b оба ловятся).
#
# ГРАММАТИКА ОТКАЗА (И-4 контракта 086, единый источник — гейт):
#   Строка отказа начинается `ОТКАЗ 086 (<точка>): `, несёт ровно один ярлык со своим
#   выходом и контекст. (а)/(в) — перед строкой отказа строка FAIL судьи на КАЖДОЕ
#   нарушение: путь и 8 hex коммита. (б) — полный 40-hex sha merge (окно). Ярлыка
#   несработавшего правила в выводе нет.
#
# СРАВНЕНИЯ (И-8 нормы 041): `[ = ]`, `grep -Fq`/`-Eqx` по замкнутым алфавитам.
#
# Возврат: 0 — окно чисто, 1 — именованный отказ (FAIL + ОТКАЗ-строка),
# 2 — нечем проверить (нет git / не репозиторий / нет HEAD / заморозки недоступны). Классификатор
# verify_antiplacebo судит роль файла ИСКЛЮЧИТЕЛЬНО по шапке «НЕ БАРЬЕР:» выше — литерал
# «Коды возврата:» здесь не повторяется, иначе файл классифицируется ОДНОВРЕМЕННО барьером
# и не-барьером (§1 классификатора) и отказывает.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Скратч для файла-списка .md (для цикла устава).
TMP="$(mktemp -d "${TMPDIR:-/tmp}/gejt_086.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# Строки оракула (побайтово из памяти батареи — `_toy.sh` строки O_A/O_B/O_V/...;
# оракул не перечитывает диск проверяемого, правило 8 нормы 041).
LABEL_A='правило (а) путь вне frozen-ЗОНЫ автора'
LABEL_B='правило (б) sync-merge'
LABEL_V='правило (в) устав-путь без строки РАЗРЕШИЛ'
VYHOD_A='выход: путь в зону — v+1 со словом владельца'
VYHOD_B='выход: пересобери ветку без merge main'
VYHOD_V='выход: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в том же коммите — словом владельца'
OTKAZ_PREFIX='ОТКАЗ 086 ('

usage() {
  cat >&2 <<USAGE
использование: gejt_svedenija.sh okno <корень> <база> <верх> <ветка> <точка>

  <корень>  — путь к git-репозиторию
  <база>    — 40-hex sha
  <верх>    — 40-hex sha
  <ветка>   — wip/<NNN>/<автор>
  <точка>   ∈ {accept, land, pre-merge-commit}

rc 0 — окно чисто; rc 1 — именованный отказ; rc 2 — нечем проверить.
USAGE
  exit 2
}

[ "${1:-}" = okno ] || { printf 'gejt_svedenija: ожидалась подкоманда okno\n' >&2; usage; }
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

# ── (б) SYNC-MERGE ──────────────────────────────────────────────────────────
# Предикат: ∃ родители P≠Q merge M: P предок main/origin/main ∧ P не предок Q.
# Frontier 4: «без порядка родителей» — L2 (второй родитель) и L2b (первый родитель)
# оба ловятся. Внутреннее слияние двух линий ветки (L6) — НЕ sync: ни один
# родитель не из main.
sync_violation() {
  local m parents p1 p2
  for m in $(g rev-list --merges "$BASE_ARG..$TIP_ARG" 2>/dev/null); do
    [ -n "$m" ] || continue
    parents=$(g log -1 --format='%P' "$m" 2>/dev/null) || continue
    case "$parents" in
      *' '*) ;;  # merge — есть пробел
      *) continue ;;  # не-merge
    esac
    # Frontier 4 (контракт 086): без порядка и числа родителей. Каждая пара (P, Q)
    # различных родителей проверяется независимо — октопус с main третьим/четвёртым
    # родителем ловится ТОЙ ЖЕ логикой, что обычный merge (L2/L2b), а внутреннее
    # слияние двух линий ветки (L6) — не sync, потому что ни один родитель не из main.
    set -- $parents
    for p1 in "$@"; do
      for p2 in "$@"; do
        [ "$p1" = "$p2" ] && continue
        if g merge-base --is-ancestor "$p1" main 2>/dev/null \
           || g merge-base --is-ancestor "$p1" origin/main 2>/dev/null; then
          if ! g merge-base --is-ancestor "$p1" "$p2" 2>/dev/null; then
            printf 'ОТКАЗ 086 (%s): %s; sha %s; %s\n' "$POINT_ARG" "$LABEL_B" "$m" "$VYHOD_B" >&2
            return 0
          fi
        fi
      done
    done
  done
  return 1
}

if sync_violation; then exit 1; fi

# ── КОНТРАКТ ВЕТКИ (NNN из wip/<NNN>/<автор>) ───────────────────────────────
# Проспективный ленд (Frontier 3): зоны судятся на merge `land: <ветка>` с первым
# родителем merge-base(база, верх). Коммиты окна судятся ровно так, как их осудил
# бы check_zones после ленда — в ОКНЕ КОНТРАКТА ВЕТКИ, не во всех открытых окнах.
# Реализация: гейт судит только пути в ЗОНАХ NNN; если NNN не заморожен, зон нет,
# коммиты exempt (A5: architect создаёт draft 901, зон 901 нет, doc901/plan.md
# не судится; L5: то же для 902 до заморозки).
NNN=$(printf '%s' "$BRANCH_ARG" | sed -n 's#^wip/\([0-9][0-9][0-9]\)/.*$#\1#p')
[ -n "$NNN" ] || { printf 'NOT_IMPLEMENTED: NNN ветки не парсится: %s\n' "$BRANCH_ARG" >&2; exit 2; }
NNN_FROZEN=0
if g rev-parse --verify --quiet "refs/tags/frozen/contracts/$NNN/1" >/dev/null 2>&1; then
  NNN_FROZEN=1
fi
# Если контракт ветки не заморожен — коммиты exempt; (а) и (в) дают rc 0.
if [ "$NNN_FROZEN" -eq 0 ]; then
  exit 0
fi

# Контракт ветки заморожен ⟺ суд идёт в ЗОНАХ NNN + устав-NNN.
# Подгружаем lib_zones.sh (ЗОНА-строки, draft-признание contracts/<M>-*, СПАСЕНО)
# и check_charter.sh как библиотеку (CHARTER_LIB=1, is_charter_path/charter_diff_paths/
# razreshil) — единый источник кольца (Frontier 2). Реестр заморозок (frozen/) должен
# быть доступен, иначе NOT_IMPLEMENTED.
LIB_ZONES_ROOT="$ROOT"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"
zones_out="$(zones_load "$ROOT" 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: реестр заморозок недоступен\n' >&2; exit 2; }
trap '__lib_zones_cleanup' EXIT

CHARTER_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/check_charter.sh"

# is_process_file — побайтово из check_zones (замороженная ветвь 016).
is_process_file() {
  case "$1" in
    verdicts/*) return 0 ;;
    HANDOFF.md) return 0 ;;
    NABLIUDENIA*.md)
      case "$1" in */*) return 1 ;; esac
      return 0
      ;;
  esac
  return 1
}

# draft-признание: путь contracts/<M>-* исключён, если M не заморожен.
is_draft_contract_path() {
  local p="$1" root="$2" dir base path_nnn
  case "$p" in
    contracts/*)
      dir="${p%%/*}"; base="${p##*/}"
      [ "$dir/$base" = "$p" ] || return 1
      path_nnn="$(printf '%s' "$base" | sed -n 's/^\([0-9][0-9][0-9]\)-.*$/\1/p')"
      [ -n "$path_nnn" ] || return 1
      g rev-parse --verify --quiet "refs/tags/frozen/contracts/$path_nnn/1" >/dev/null 2>&1 \
        && return 1
      return 0
      ;;
  esac
  return 1
}

# Проспективный merge-base(база, верх) — то, что check_zones взял бы за «главную
# линию» после ленда. Идём от MB до TIP по first-parent — это ровно те коммиты,
# что check_zones осудит.
MB=$(g merge-base "$BASE_ARG" "$TIP_ARG" 2>/dev/null) || {
  printf 'NOT_IMPLEMENTED: merge-base отказал\n' >&2; exit 2; }

# Окно суда — коммиты gate'а: <база>..<верх> (Frontier 1, И-1/И-2). L5 (pre-freeze
# правка): архитектор правит contracts/902-chernovik.md ДО заморозки 902 → для
# (в) пара для 902-* создаётся с since=frozen/contracts/902/1, диапазон пуст →
# коммиты НЕ судятся по уставу; для (а) — окно <base>..<tip> проходит через
# МВ, и architect-овские коммиты попадают в обход (a) ВНУТРИ union зон автора
# (контракт 902 в этом случае объявляет architect: contracts/902-.../doc902/).
A_RANGE="$BASE_ARG..$TIP_ARG"

# Проспективный merge-base(база, верх) — нужно для (а) только в качестве
# страховки; в проспектив-ленде коммиты окна — это first-parent не-merge из
# [base..tip], их и обходим.

# ── (а) ПУТЬ ВНЕ ЗОНЫ ──────────────────────────────────────────────────────
# Окно суда — `[frozen/contracts/<NNN>/1..done/contracts/<NNN>/1]` (или ..HEAD),
# ПЕРЕСЕЧЁННОЕ с `[base..tip]` — ровно то, что check_zones судит для NNN, после
# приземления ветки (Frontier 3). Это:
#   (i) исключает ветки pre-freeze коммиты (caa3fe11 создаёт contract 080 до
#       freeze; c50e683b — pre-freeze verdict) — они не в окне NNN, не судятся;
#   (ii) включает post-freeze коммиты в окне gate'а (R8: 7dcfef2f
#       docs/owner/2026-10-05-a3-pr-vs-push-analiz.md в окне NNN=083 — флагится).
# Для accept: NNN ветки — тот же; новые коммиты в `[base..tip]` лежат после
# freeze (ветка импортирована ПОСЛЕ freeze, иначе ветки не было бы), и в окне NNN.
# Пересечение с `[base..tip]` — коммиты, которые и в окне gate'а, и в окне NNN.
A_NNN_RANGE="frozen/contracts/$NNN/1..$TIP_ARG"
if g rev-parse --verify --quiet "refs/tags/done/contracts/$NNN/1" >/dev/null 2>&1; then
  A_NNN_RANGE="frozen/contracts/$NNN/1..done/contracts/$NNN/1"
fi
NNN_COMMITS=$(g rev-list --no-merges --first-parent "$A_NNN_RANGE" 2>/dev/null | sort -u)
A_COMMITS=$(g rev-list --no-merges --first-parent "$BASE_ARG..$TIP_ARG" 2>/dev/null | sort -u)
A_FAILS=0
for c in $(comm -12 <(printf '%s\n' "$A_COMMITS") <(printf '%s\n' "$NNN_COMMITS")); do
  [ -n "$c" ] || continue
  an=$(g log -1 --format='%an' "$c" 2>/dev/null) || continue
  # Автор вне ЗОНА-строк ЗАМОРОЖЕННЫХ контрактов — НЕ проверяется.
  if ! awk -F'\t' -v a="$an" '$1 == a { f = 1; exit } END { exit !f }' "$zones_out/zones_scoped"; then
    continue
  fi
  # СПАСЕНО: коммит в saved для автора — пропускаем все пути.
  if awk -F'\t' -v a="$an" -v c="$c" '$1 == a && $2 == c { f = 1; exit } END { exit !f }' "$zones_out/saved" 2>/dev/null; then
    continue
  fi
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    is_process_file "$p" && continue
    is_draft_contract_path "$p" "$ROOT" && continue
    # Branch-scoped exemption: пути contracts/<NNN>-*, doc<NNN>/*, plans/<NNN>-*
    # для незамороженного NNN ветки.
    if [ "$NNN_FROZEN" -eq 0 ]; then
      case "$p" in
        "contracts/$NNN-"|"contracts/$NNN"-*) continue ;;
        "doc$NNN/"|"doc$NNN"/*) continue ;;
        "plans/$NNN-"|"plans/$NNN"-*) continue ;;
      esac
    fi
    # Единый источник предиката «путь в зоне автора» — `zones_match_path` из lib_zones.sh
    # (Frontier 2 + Б-1 контракта 086: вторая реализация поверх lib_zones ЗАПРЕЩЕНА —
    # отвергнутая альтернатива (i) кольца; check_zones использует ту же функцию, и
    # расхождения между гейтом и check_zones (пробел/не-ASCII в имени пути, лишний
    # префикс, и т.п.) — структурный дефект кольца). `zones_match_path` возвращает
    # rc 0 если путь НАЙДЕН в зоне автора, иначе rc 1 — инвертируем в «вне зоны».
    if ! zones_match_path "$zones_out" "$an" "$p"; then
      printf '  FAIL коммит вне зоны: %s %s %s\n' "$an" "${c:0:8}" "$p" >&2
      A_FAILS=$((A_FAILS + 1))
    fi
  done < <(g diff-tree -r --no-commit-id --name-only --no-renames -z "$c" 2>/dev/null | tr '\0' '\n')
done

if [ "$A_FAILS" -gt 0 ]; then
  printf 'ОТКАЗ 086 (%s): %s; %s\n' "$POINT_ARG" "$LABEL_A" "$VYHOD_A" >&2
  exit 1
fi

# ── (в) УСТАВ-ПУТЬ БЕЗ СТРОКИ РАЗРЕШИЛ ──────────────────────────────────────
# Для каждой уставной пары (файл, since) — диапазон [max(since, base)..tip].
# Комитты, чьё изменение касается файла, требуют РАЗРЕШИЛ в ТОМ ЖЕ коммите.
# L5: contracts/902-chernovik.md парный with since=frozen/contracts/902/1
# (заморозка на кончике ветки, в основном checkout — тоже в refs), диапазон
# [frozen/contracts/902/1..tip] пуст ⟹ коммиты ветки не судятся. L3: ROADMAP.md
# парный with since=ustav/1, архитектор-овский коммит в окне — РАЗРЕШИЛ нет
# → отказ. razreshil — CHARTER_LIB=1 из check_charter.sh.
V_FAILS=0
# Пересечение [since..tip] с [base..tip] — берём коммиты, попадающие в оба.
intersect_window() {  # <since> → stdout коммиты [max(since,base)..tip]∩[base..tip]
  local since="$1" comm_since comm_base
  comm_since=$(g rev-list --no-merges --first-parent "$since..$TIP_ARG" 2>/dev/null | sort -u)
  comm_base=$(g rev-list --no-merges --first-parent "$BASE_ARG..$TIP_ARG" 2>/dev/null | sort -u)
  comm -12 <(printf '%s\n' "$comm_since") <(printf '%s\n' "$comm_base")
}

# (в) — суд над ТОЧКОЙ ПРИЗЕМЛЕНИЯ, не над принесёнными коммитами. Для каждой
# уставной пары (файл, since) идём по intersect_window(since): коммиты СТРОГО
# ПОСЛЕ since (его заморозка/ustav ИСКЛЮЧЕНА диапазоном `since..tip` — pre-freeze
# черновик не судится, L5: since=frozen/contracts/902/1 указывает НА КОНЧИК
# ветки, диапазон since..tip пуст, коммиты ветки exempt), пересечённые с окном
# гейта [base..tip] (L7: старое нарушение НИЖЕ base не судится). На каждом
# коммите — charter_diff_paths (--diff-filter=MD, ЕДИНЫЙ источник кода
# check_charter.sh, Frontier 2) против ЕГО СОБСТВЕННОГО первого родителя; нашли
# правку файла — razreshil ИМЕННО на этом коммите (на accept/land ДО слияния
# разрешение обязано лежать в коммите ветки — переноса строк land_agent И-10
# ещё не было, merge не создан).
otkaz_v() {  # <коммит> <файл>
  printf '  FAIL уставной документ изменён без разрешения владельца: %s в %s\n' "$2" "${1:0:8}" >&2
  V_FAILS=$((V_FAILS + 1))
}
judge_pair() {  # <since> <файл>
  local since="$1" f="$2" c
  for c in $(intersect_window "$since"); do
    [ -n "$c" ] || continue
    charter_diff_paths "$c" "$ROOT" 2>/dev/null | grep -qxF -- "$f" || continue
    razreshil "$c" "$f" 2>/dev/null || otkaz_v "$c" "$f"
  done
}

for f in AGENTS.md ROADMAP.md; do
  g cat-file -e "$TIP_ARG:$f" 2>/dev/null || continue
  judge_pair ustav/1 "$f"
done
# plans/NNN-*.md и contracts/NNN-*.md — since=frozen/$dir/$nnn/1 (каждая пара своя).
g ls-tree -r --name-only "$TIP_ARG" -- ':(literal)plans/' ':(literal)contracts/' 2>/dev/null \
  | awk '/\.md$/' | sort > "$TMP/list_md" 2>/dev/null || true
while IFS= read -r f; do
  [ -n "$f" ] || continue
  dir="${f%%/*}"; base="${f##*/}"
  [ "$dir/$base" = "$f" ] || continue
  nnn=$(printf '%s' "$base" | sed -n 's/^\([0-9][0-9][0-9]\)-.*$/\1/p')
  [ -n "$nnn" ] || continue
  g rev-parse --verify --quiet "refs/tags/frozen/$dir/$nnn/1" >/dev/null 2>&1 || continue
  judge_pair "frozen/$dir/$nnn/1" "$f"
done < "$TMP/list_md"

if [ "$V_FAILS" -gt 0 ]; then
  printf 'ОТКАЗ 086 (%s): %s; %s\n' "$POINT_ARG" "$LABEL_V" "$VYHOD_V" >&2
  exit 1
fi

exit 0
