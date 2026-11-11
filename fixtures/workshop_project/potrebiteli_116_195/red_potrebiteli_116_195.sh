#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Красная батарея контракта 195 — потребители 116: окно переписчика не должно
# ловить чужое слияние (PR-слияние rebase'ом, без land-маркера).
#
# Измеренная боль (живой прогон 2026-11-11, станция /home/harness/dev-harness,
# HEAD ba7bed37d): `bash scripts/check_consumers.sh <корень>
# contracts/158-ekrannyj-nabor.md` → rc 1 «потребители 116: писатель
# scripts/freeze_contract.sh изменён, потребитель fixtures/check_check_contract_ready/
# не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы». Окно frozen/contracts/158/4..HEAD несёт
# 4 коммита автора implementer (3a75e2d45, 56a4747b5 — freeze_contract.sh;
# de86f2d8b, f387542d0 — done_contract.sh), принесённые PR-слиянием 187а rebase'ем
# (автор сохранён, коммиттер человек, land-маркера нет, owner/owner нет) — судимая
# множеством 062 грамматика их не исключает, а зональная принадлежность (живая
# заморозка 187/1 держит оба писателя в ЗОНА implementer) гейтом не читается.
#
# Предмет 195: покоммитная атрибуция пары (автор, путь писателя) по ЗОНА-строкам
# замороженных контрактов — ЕДИНЫМ читателем scripts/lib_zones.sh (016):
# правка судится контрактом N ⟸ пара покрыта собственной заморозкой N (И-6);
# иначе правка исключается из окна N ⟸ пара покрыта зоной другого замороженного
# M≠N и коммит в диапазоне M (И-5). Свой PR-ленд остаётся судимым — следствие
# для 187 v2 (пробы в его тексте) записано в контракте 195.
#
# РЕЖИМЫ: без флага — честные клетки против ЖИВОГО scripts/check_consumers.sh
# (до реализации rc 1: красна ka; после реализации rc 0); --model — те же
# клетки против честной модели model/model_gate.sh (rc 0 уже сегодня);
# --stabs — обманные реализации: все пойманы ∧ диффпробы зелёные (rc 0 до и
# после реализации); --repo [корень] — живая клетка на настоящем дереве
# (contracts/158-ekrannyj-nabor.md; до реализации rc 1 — боль, после rc 0).
#
# ЧЕСТНЫЕ КЛЕТКИ (игрушки в mktemp: свой контракт N=100 contracts/100-n.md, окно
# frozen/contracts/100/1..HEAD; чужой контракт M=200 contracts/200-m.md с ЗОНА-
# строкой в его собственной заморозке; каркас _toy.sh семьи check_consumers —
# писатели-минимума НАСТОЯЩИМИ путями, арбитраж 038-Б3):
#   ka  (а) боль: M=200 держит scripts/freeze_contract.sh в ЗОНА implementer;
#       коммит автора implementer (коммиттер Rebase Human — форма PR-слияния)
#       правит писателя; черновик 100 без пробы → rc 0 (коммит атрибутирован
#       наружу). КРАСНАЯ до реализации (сегодня rc 1), зелёная после.
#   kb  (б) не-вакуум: M=200 зонит ТОЛЬКО не-писателя (fixtures/reader.sh);
#       коммит implementer правит писателя → rc 1, дословная фраза «нет
#       ПОТРЕБИТЕЛЬ-пробы» (правка без зоны судится как сегодня).
#   kv1 (в) свой контракт: ЗОНА implementer: scripts/freeze_contract.sh — в
#       заморозке САМОГО 100; коммит implementer правит писателя; черновик без
#       пробы → rc 1 та же фраза (M==N НЕ исключается — И-6).
#   kv2 (в) свой контракт с пробой: то же + ПОТРЕБИТЕЛЬ-строка и живая проба
#       → rc 0.
#   kg  (г) ложная атрибуция: M=200 зонит писателя для implementer; коммит
#       автора critic правит писателя → rc 1 та же фраза (автор вне роли зоны
#       не атрибутируется).
#   kd1 (д) регресс 062 И-1: чужой ленд land: wip/090/implementer несёт правку
#       писателя → rc 0 (чужие ленды по-прежнему вне окна).
#   kd2 (д) регресс Н-300: прямой коммит author=committer=owner правит писателя
#       → rc 0 (канал владельца по-прежнему исключён).
#   ke  (е) регресс И-4: объект тега-границы удалён (tag -l листингует,
#       разрешение диапазона отказывает) → rc 1, дословно «потребители 116:
#       список судимых коммитов окна недоступен» (отказ добычи ≠ vacuous).
#   kj  (ж) --repo: живой гейт на настоящем дереве, contracts/158-…: rc 1 до
#       реализации (боль), rc 0 после.
#
# СТАБ-ПАК (Н-39: обман ровно одной ветвью предмета; привязка стабов к клеткам —
# ЭТОТ код, не проза контракта; стаб-пак зелёный ДО и ПОСЛЕ реализации):
#   s1 «гаситель»         — исключает ВСЕ писатель-коммиты (ни зон, ни автора);
#                          смерть kg, диффпроба ka;
#   s2 «имя без зоны»     — исключает по имени автора из зон M≠N БЕЗ сверки
#                          пути; смерть kb, диффпроба kg;
#   s3 «только land:»     — зонной атрибуции нет вовсе (поведение ДО 195);
#                          смерть ka (судит PR-rebase коммит), диффпроба kd1;
#   s4 «ошибка→пустое»    — отказ добычи окна проглатывается в vacuous rc 0;
#                          смерть ke, диффпроба kb;
#   s5 «свой тоже наружу» — исключает и через M==N (своё покрытие не
#                          приоритетно); смерть kv1, диффпроба ka.
#
# rc: 0 ⟺ все клетки режима зелёные ∧ выборки непусты; пустая выборка — красное.
# Скрипт не печатает PASS — только счёт просмотренного (правило роли).
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail

FAM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$FAM/../../.." && pwd -P)"
MODEL="$FAM/model/model_gate.sh"
# Каркас _toy.sh семьи check_consumers (арбитраж 038-Б3) вычисляет REPO/SUBJ из
# $HERE вызывающего: его контракт — HERE указывает на каталог семьи-владельца
# каркаса (как в red_atribucija_okna_062.sh), а не на каталог семьи 195.
HERE="$REPO/fixtures/check_consumers"
# shellcheck disable=SC1091
. "$HERE/_toy.sh"

export HARNESS_ROOT="$REPO"

PHRASE='потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы'
PHRASE4='потребители 116: список судимых коммитов окна недоступен'
PHRASEZ='потребители 116: зоны атрибуции окна не читаются'

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red195.XXXXXX")"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

MODE="${1:-}"

# ── игрушки ───────────────────────────────────────────────────────────────────
mk195() { # <dir> [зона-строка-100-в-её-заморозке] — основа: маппинг + тег 100/1
  local r="$1" zone="${2:-}"
  mkdir -p "$r/scripts" "$r/contracts" "$r/fixtures"
  seed_mapping "$r" fixtures/reader.sh
  if [ -n "$zone" ]; then
    printf '# kontrakt 100 v2 draft\n\n## Zony\n%s\n' "$zone" > "$r/contracts/100-n.md"
  else
    printf '# kontrakt 100 v2 draft\n\n## Predmet\nokno pisatelej\n' > "$r/contracts/100-n.md"
  fi
  git -C "$r" init -q -b main
  g "$r" config user.name Fixture
  g "$r" config user.email fixture@local
  commit_all "$r" 'osnovanie s mappingom'
  g "$r" tag -a frozen/contracts/100/1 -m 'granica okna 100'
}

zone200() { # <dir> <пути-зоны-200-через-пробел> — чужой контракт M, заморожен
  printf '# kontrakt 200\n\n## Zony\nЗОНА implementer: %s\n' "$2" > "$1/contracts/200-m.md"
  commit_all "$1" 'kontrakt 200 s zonoj implementer'
  g "$1" tag -a frozen/contracts/200/1 -m 'frozen 200'
}

impl_commit() { # <dir> <author> <committer> <msg> — правка писателя заданными
  # identity (PR-rebase форма: автор сохранён, коммиттер — человек/дверь слияния)
  printf '#!/usr/bin/env bash\n# pravka pisatelja v okne\nexit 0\n' > "$1/scripts/freeze_contract.sh"
  GIT_AUTHOR_NAME="$2" GIT_AUTHOR_EMAIL="$2@toy.local" \
  GIT_COMMITTER_NAME="$3" GIT_COMMITTER_EMAIL="$3@toy.local" \
    git -C "$1" -c user.name=Fixture -c user.email=fixture@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  GIT_AUTHOR_NAME="$2" GIT_AUTHOR_EMAIL="$2@toy.local" \
  GIT_COMMITTER_NAME="$3" GIT_COMMITTER_EMAIL="$3@toy.local" \
    git -C "$1" -c user.name=Fixture -c user.email=fixture@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "$4"
}

draft100() { # <dir> <тело-черновика> — закоммичен на хребте В ОКНЕ
  printf '# kontrakt 100 v2 draft\n\n## Predmet\nokno pisatelej\n\n%s\n' "$2" > "$1/contracts/100-n.md"
  commit_all "$1" 'chernovik 100 v2'
}

land_branch() { # <dir> <ветка> <commit-msg> <land-msg> — правка писателя в ветке,
  # слияние merge --no-ff с заданным маркером (062-форма)
  local r="$1" br="$2" msg="$3" land="$4" cur
  cur="$(git -C "$r" symbolic-ref --short HEAD)"
  g "$r" checkout -q -b "$br"
  touch_writer "$r"
  commit_all "$r" "$msg"
  g "$r" checkout -q "$cur"
  g "$r" merge --no-ff -q -m "$land" "$br"
}

build_all() { # честные игрушки всех клеток (используются честными клетками и стабами)
  # ka: чужая зона покрывает писателя; PR-rebase коммит implementer
  ka="$WORK/ka"; mk195 "$ka"; zone200 "$ka" 'scripts/freeze_contract.sh'
  impl_commit "$ka" implementer 'Rebase Human' '187a-VIDE: pravka pisatelja po chuzhomu kontraktu'
  draft100 "$ka" "$CENSUS"
  # kb: чужая зона покрывает ТОЛЬКО не-писателя; коммит implementer без зоны писателя
  kb="$WORK/kb"; mk195 "$kb"; zone200 "$kb" 'fixtures/reader.sh'
  impl_commit "$kb" implementer 'Rebase Human' 'pravka pisatelja bez zony'
  draft100 "$kb" "$CENSUS"
  # kv1: зона писателя — в заморозке САМОГО 100; коммит implementer; без пробы
  kv1="$WORK/kv1"; mk195 "$kv1" 'ЗОНА implementer: scripts/freeze_contract.sh'
  impl_commit "$kv1" implementer 'Rebase Human' 'svoja pravka pisatelja po kontraktu 100'
  printf '# kontrakt 100 v2 draft\n\n## Zony\nЗОНА implementer: scripts/freeze_contract.sh\n\n%s\n' "$CENSUS" > "$kv1/contracts/100-n.md"
  commit_all "$kv1" 'chernovik 100 v2 bez proby'
  # kv2: то же + живая проба потребителя
  kv2="$WORK/kv2"; mk195 "$kv2" 'ЗОНА implementer: scripts/freeze_contract.sh'
  impl_commit "$kv2" implementer 'Rebase Human' 'svoja pravka pisatelja po kontraktu 100'
  printf '# kontrakt 100 v2 draft\n\n## Zony\nЗОНА implementer: scripts/freeze_contract.sh\n\n%s\n\n## Potrebiteli\nПОТРЕБИТЕЛЬ fixtures/reader.sh: bash fixtures/reader.sh\n' "$CENSUS" > "$kv2/contracts/100-n.md"
  commit_all "$kv2" 'chernovik 100 v2 s probou'
  # kg: чужая зона покрывает писателя для implementer; коммит автора critic
  kg="$WORK/kg"; mk195 "$kg"; zone200 "$kg" 'scripts/freeze_contract.sh'
  impl_commit "$kg" critic 'Rebase Human' 'pravka pisatelja chuzhou identity'
  draft100 "$kg" "$CENSUS"
  # kd1: чужой ленд (062 И-1) — без зон вовсе
  kd1="$WORK/kd1"; mk195 "$kd1"
  land_branch "$kd1" br_chuzhoj_090 'chuzhaja pravka pisatelja (kontrakt 090)' 'land: wip/090/implementer'
  draft100 "$kd1" "$CENSUS"
  # kd2: прямой коммит канала владельца (Н-300)
  kd2="$WORK/kd2"; mk195 "$kd2"
  impl_commit "$kd2" owner owner 'pravka pisatelja kanalom vladeltsa'
  draft100 "$kd2" "$CENSUS"
  # ke: объект тега-границы удалён (И-4)
  ke="$WORK/ke"; mk195 "$ke"; draft100 "$ke" "$CENSUS"
  ke_obj="$(git -C "$ke" rev-parse frozen/contracts/100/1)"
  ke_f="$ke/.git/objects/${ke_obj:0:2}/${ke_obj:2}"
  [ -f "$ke_f" ] && rm -f "$ke_f"
}

# ── проверки (батарея считает, не умирает на первой) ──────────────────────────
chk_rc0() {
  if [ "$LAST_RC" -eq 0 ]; then printf '  ok   %s\n' "$1" >&2; return 0; fi
  printf '  FAIL %s: rc %s, ожидался 0\nвывод гейта:\n%s\n' "$1" "$LAST_RC" "$LAST_OUT" >&2
  return 1
}
chk_refuse() {
  if [ "$LAST_RC" -eq 1 ] && printf '%s\n' "$LAST_OUT" | grep -Fq "$PHRASE"; then
    printf '  ok   %s: отказ rc 1, причина названа дословно\n' "$1" >&2; return 0
  fi
  printf '  FAIL %s: rc %s, ожидался отказ 1 с дословной причиной «%s»\nвывод гейта:\n%s\n' "$1" "$LAST_RC" "$PHRASE" "$LAST_OUT" >&2
  return 1
}
chk_win_refuse() {
  if [ "$LAST_RC" -eq 1 ] && printf '%s\n' "$LAST_OUT" | grep -Fq "$PHRASE4"; then
    printf '  ok   %s: отказ добычи окна rc 1, причина названа дословно\n' "$1" >&2; return 0
  fi
  printf '  FAIL %s: rc %s, ожидался отказ 1 с дословной причиной «%s»\nвывод гейта:\n%s\n' "$1" "$LAST_RC" "$PHRASE4" "$LAST_OUT" >&2
  return 1
}

honest_total=0; honest_green=0; honest_fail=""
hcell() { # hcell <имя> <функция>
  local n="$1" f="$2"
  honest_total=$((honest_total + 1))
  if "$f"; then honest_green=$((honest_green + 1)); else honest_fail="$honest_fail $n"; fi
}

ka_c() { run_gate "$ka" contracts/100-n.md; chk_rc0 'ka: PR-rebase коммит чужой зоны вне окна — гейт не судит'; }
kb_c() { run_gate "$kb" contracts/100-n.md; chk_refuse 'kb: правка без зоны писателя судится'; }
kv1_c() { run_gate "$kv1" contracts/100-n.md; chk_refuse 'kv1: свой контракт (M==N) не исключается'; }
kv2_c() { run_gate "$kv2" contracts/100-n.md; chk_rc0 'kv2: проба живая — rc 0'; }
kg_c() { run_gate "$kg" contracts/100-n.md; chk_refuse 'kg: автор вне роли зоны не атрибутируется'; }
kd1_c() { run_gate "$kd1" contracts/100-n.md; chk_rc0 'kd1: чужой ленд вне окна (062 И-1)'; }
kd2_c() { run_gate "$kd2" contracts/100-n.md; chk_rc0 'kd2: канал владельца исключён (Н-300)'; }
ke_c() { run_gate "$ke" contracts/100-n.md; chk_win_refuse 'ke: отказ добычи окна — именованный, не пустое множество'; }

# ── живая клетка (--repo) ─────────────────────────────────────────────────────
live_cell() { # <корень>
  local root="$1"
  [ -d "$root" ] || { printf 'NOT_IMPLEMENTED: корень не существует: %s\n' "$root" >&2; return 2; }
  git -C "$root" rev-parse --git-dir >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$root" >&2; return 2; }
  [ -f "$root/contracts/158-ekrannyj-nabor.md" ] \
    || { printf 'NOT_IMPLEMENTED: contracts/158-ekrannyj-nabor.md нет в %s\n' "$root" >&2; return 2; }
  run_gate "$root" contracts/158-ekrannyj-nabor.md
  if [ "$LAST_RC" -eq 0 ]; then
    printf 'kj: живая клетка rc 0 — окно 158 не судит чужое слияние 187а\n' >&2
    return 0
  fi
  printf 'kj: живая клетка rc %s (до реализации — измеренная боль): %s\n' \
    "$LAST_RC" "$(printf '%s\n' "$LAST_OUT" | sed -n 1p)" >&2
  return "$LAST_RC"
}

# ── стаб-пак (Н-39) ───────────────────────────────────────────────────────────
build_stubs() {
  STUBS="$WORK/stubs"; mkdir -p "$STUBS"

  # s1 «гаситель»: окно добывает честно (именованный отказ добычи сохранён), но
  # исключает ЛЮБОЙ коммит, тронувший писателя, — ни зон, ни автора.
  cat > "$STUBS/s1_gasitel.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
ROOT="${1:?ispolzovanie: <koren> <otn-put-kontrakta>}"
CONTRACT_PATH="${2:?ispolzovanie: <koren> <otn-put-kontrakta>}"
base="${CONTRACT_PATH##*/}"
n="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$n" ] || exit 2
command -v git >/dev/null 2>&1 || exit 2
last_frozen="$(git -C "$ROOT" tag -l "frozen/contracts/$n/*" 2>/dev/null | sort -V | tail -n 1)"
[ -n "$last_frozen" ] || exit 0
COMMITS="$(mktemp)"; trap 'rm -f "$COMMITS"' EXIT
if ! git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u >"$COMMITS"; then
  printf 'потребители 116: список судимых коммитов окна недоступен\n' >&2
  exit 1
fi
while IFS= read -r c; do
  [ -n "$c" ] || continue
  out="$(git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" -- scripts/freeze_contract.sh)" \
    || { printf 'потребители 116: список судимых коммитов окна недоступен\n' >&2; exit 1; }
  [ -n "$out" ] && exit 0   # гасим: любой писатель-коммит исключён
done <"$COMMITS"
exit 0
EOF

  # s2 «имя без зоны»: исключает коммит, если его АВТОР объявлен в чьей-то зоне
  # M≠N (любого пути), без сверки, что тронутый писатель — в этой зоне. Зоны —
  # тем же единым читателем lib_zones; диапазон M уважается.
  cat > "$STUBS/s2_imja_bez_zony.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
ROOT="${1:?ispolzovanie: <koren> <otn-put-kontrakta>}"
CONTRACT_PATH="${2:?ispolzovanie: <koren> <otn-put-kontrakta>}"
export PATH=/usr/bin:/bin
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
base="${CONTRACT_PATH##*/}"
n="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$n" ] || exit 2
command -v git >/dev/null 2>&1 || exit 2
. "${HARNESS_ROOT:?HARNESS_ROOT}/scripts/lib_zones.sh"
last_frozen="$(git -C "$ROOT" tag -l "frozen/contracts/$n/*" 2>/dev/null | sort -V | tail -n 1)"
[ -n "$last_frozen" ] || exit 0
ZDIR="$(zones_load "$ROOT" 2>/dev/null)" || exit 1
[ -n "$ZDIR" ] && [ -f "$ZDIR/zones_scoped" ] && [ -f "$ZDIR/ranges" ] || exit 1
# Писатель-коммит с автором, объявленным в зоне ЛЮБОГО M≠N (путь НЕ сверяем —
# дефект стаба), коммит в диапазоне M — исключается.
AW="$(mktemp)"; trap 'rm -f "$AW"' EXIT
git -C "$ROOT" log --no-merges --format='%H%x09%an' "$last_frozen..HEAD" 2>/dev/null >"$AW" || exit 1
attributed=0
while IFS=$'\t' read -r c au; do
  [ -n "$c" ] || continue
  out="$(git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" -- scripts/freeze_contract.sh)" || exit 9
  [ -n "$out" ] || continue
  found=0
  while IFS=$'\t' read -r za _zp zn; do
    [ -n "$za" ] || continue
    [ "$zn" = "$n" ] && continue
    [ "$za" = "$au" ] || continue
    range="$(awk -F'\t' -v m="$zn" '$1 == m { print $2; exit }' "$ZDIR/ranges")"
    [ -n "$range" ] || continue
    since="${range%%..*}"; case "$range" in *..*) until="${range#*..}" ;; *) until="" ;; esac
    git -C "$ROOT" merge-base --is-ancestor "$since" "$c" 2>/dev/null || continue
    if [ -n "$until" ]; then git -C "$ROOT" merge-base --is-ancestor "$c" "$until" 2>/dev/null || continue; fi
    found=1; break
  done <"$ZDIR/zones_scoped"
  if [ "$found" -eq 1 ]; then attributed=1; break; fi
done <"$AW"
rm -f "$AW"
[ "$attributed" -eq 1 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF

  # s3 «только land:»: зонной атрибуции нет вовсе — поведение гейта ДО 195
  # (062-грамматика окна: хребет ∪ свои ленды, чужие land: исключены).
  cat > "$STUBS/s3_tolko_land.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
ROOT="${1:?ispolzovanie: <koren> <otn-put-kontrakta>}"
CONTRACT_PATH="${2:?ispolzovanie: <koren> <otn-put-kontrakta>}"
base="${CONTRACT_PATH##*/}"
n="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$n" ] || exit 2
command -v git >/dev/null 2>&1 || exit 2
last_frozen="$(git -C "$ROOT" tag -l "frozen/contracts/$n/*" 2>/dev/null | sort -V | tail -n 1)"
[ -n "$last_frozen" ] || exit 0
EXCL="$(mktemp)"; COMMITS="$(mktemp)"; trap 'rm -f "$EXCL" "$COMMITS"' EXIT
git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u >"$COMMITS" || exit 1
: >"$EXCL"
git -C "$ROOT" rev-list --merges "$last_frozen..HEAD" 2>/dev/null | while IFS= read -r mc; do
  [ -n "$mc" ] || continue
  msg="$(git -C "$ROOT" log -1 --format=%s "$mc" 2>/dev/null)"
  case "$msg" in
    "land: wip/$n/"*) ;;
    "land: wip/"*) git -C "$ROOT" rev-list --no-merges "${mc}^1..${mc}" 2>/dev/null >>"$EXCL" ;;
  esac
done
sort -u "$EXCL" -o "$EXCL"
hit=0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  if git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" -- scripts/freeze_contract.sh 2>/dev/null | grep -q .; then
    hit=1; break
  fi
done < <(comm -23 "$COMMITS" "$EXCL")
[ "$hit" -eq 0 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF

  # s4 «ошибка→пустое»: семантика честная (окно, атрибуция, проба), НО отказ
  # добычи окна/зон проглатывается в пустое множество — vacuous rc 0.
  cat > "$STUBS/s4_oshibka_pusto.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
ROOT="${1:?ispolzovanie: <koren> <otn-put-kontrakta>}"
CONTRACT_PATH="${2:?ispolzovanie: <koren> <otn-put-kontrakta>}"
export PATH=/usr/bin:/bin
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
base="${CONTRACT_PATH##*/}"
n="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$n" ] || exit 2
command -v git >/dev/null 2>&1 || exit 2
last_frozen="$(git -C "$ROOT" tag -l "frozen/contracts/$n/*" 2>/dev/null | sort -V | tail -n 1)"
[ -n "$last_frozen" ] || exit 0
. "${HARNESS_ROOT:?HARNESS_ROOT}/scripts/lib_zones.sh"
COMMITS="$(mktemp)"; trap 'rm -f "$COMMITS"' EXIT
git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u >"$COMMITS" || : >"$COMMITS"
ZDIR="$(zones_load "$ROOT" 2>/dev/null)" || ZDIR=""
[ -n "$ZDIR" ] && [ -f "$ZDIR/zones_scoped" ] && [ -f "$ZDIR/ranges" ] || ZDIR=""
hit=0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  out="$(git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" -- scripts/freeze_contract.sh)" || continue
  [ -n "$out" ] || continue
  a="$(git -C "$ROOT" log -1 --format=%an "$c" 2>/dev/null)" || continue
  attributed=0
  if [ -n "$ZDIR" ]; then
    while IFS=$'\t' read -r za zp zn; do
      [ -n "$za" ] || continue
      [ "$zn" = "$n" ] && continue
      [ "$za" = "$a" ] || continue
      case "$zp" in
        */) case scripts/freeze_contract.sh in "$zp"*) ;; *) continue ;; esac ;;
        *)  [ "scripts/freeze_contract.sh" = "$zp" ] || continue ;;
      esac
      range="$(awk -F'\t' -v m="$zn" '$1 == m { print $2; exit }' "$ZDIR/ranges")"
      [ -n "$range" ] || continue
      since="${range%%..*}"; case "$range" in *..*) until="${range#*..}" ;; *) until="" ;; esac
      git -C "$ROOT" merge-base --is-ancestor "$since" "$c" 2>/dev/null || continue
      if [ -n "$until" ]; then git -C "$ROOT" merge-base --is-ancestor "$c" "$until" 2>/dev/null || continue; fi
      attributed=1; break
    done <"$ZDIR/zones_scoped"
  fi
  [ "$attributed" -eq 1 ] && continue
  hit=1; break
done <"$COMMITS"
[ "$hit" -eq 0 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF

  # s5 «свой тоже наружу»: атрибуция честная (автор+путь+диапазон), НО M==N
  # исключается наравне с чужими — собственное покрытие не приоритетно.
  cat > "$STUBS/s5_svoj_tozhe_naruzhu.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
ROOT="${1:?ispolzovanie: <koren> <otn-put-kontrakta>}"
CONTRACT_PATH="${2:?ispolzovanie: <koren> <otn-put-kontrakta>}"
export PATH=/usr/bin:/bin
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
base="${CONTRACT_PATH##*/}"
n="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$n" ] || exit 2
command -v git >/dev/null 2>&1 || exit 2
last_frozen="$(git -C "$ROOT" tag -l "frozen/contracts/$n/*" 2>/dev/null | sort -V | tail -n 1)"
[ -n "$last_frozen" ] || exit 0
. "${HARNESS_ROOT:?HARNESS_ROOT}/scripts/lib_zones.sh"
COMMITS="$(mktemp)"; trap 'rm -f "$COMMITS"' EXIT
git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u >"$COMMITS" || exit 1
ZDIR="$(zones_load "$ROOT" 2>/dev/null)" || exit 1
[ -n "$ZDIR" ] && [ -f "$ZDIR/zones_scoped" ] && [ -f "$ZDIR/ranges" ] || exit 1
hit=0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  out="$(git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" -- scripts/freeze_contract.sh)" || exit 9
  [ -n "$out" ] || continue
  a="$(git -C "$ROOT" log -1 --format=%an "$c" 2>/dev/null)" || exit 9
  attributed=0
  while IFS=$'\t' read -r za zp zn; do
    [ -n "$za" ] || continue
    [ "$za" = "$a" ] || continue
    case "$zp" in
      */) case scripts/freeze_contract.sh in "$zp"*) ;; *) continue ;; esac ;;
      *)  [ "scripts/freeze_contract.sh" = "$zp" ] || continue ;;
    esac
    range="$(awk -F'\t' -v m="$zn" '$1 == m { print $2; exit }' "$ZDIR/ranges")"
    [ -n "$range" ] || continue
    since="${range%%..*}"; case "$range" in *..*) until="${range#*..}" ;; *) until="" ;; esac
    git -C "$ROOT" merge-base --is-ancestor "$since" "$c" 2>/dev/null || continue
    if [ -n "$until" ]; then git -C "$ROOT" merge-base --is-ancestor "$c" "$until" 2>/dev/null || continue; fi
    attributed=1; break
  done <"$ZDIR/zones_scoped"
  [ "$attributed" -eq 1 ] && continue
  hit=1; break
done <"$COMMITS"
[ "$hit" -eq 0 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF

  chmod +x "$STUBS"/*.sh
}

with_stub() { SUBJ="$1"; }
restore_subj() { SUBJ="$REAL_SUBJ"; }

stub_total=0; stub_caught=0; stub_esc=""
scell() { local n="$1" f="$2"
  stub_total=$((stub_total + 1))
  if "$f"; then stub_caught=$((stub_caught + 1)); else stub_esc="$stub_esc $n"; fi
}
diff_total=0; diff_green=0; diff_fail=""
dcell() { local n="$1" f="$2"
  diff_total=$((diff_total + 1))
  if "$f"; then diff_green=$((diff_green + 1)); else diff_fail="$diff_fail $n"; fi
}

# детекция: стаб ошибочно ОТПУСТИЛ вход (rc 0, где честная реализация отказывает)
chk_caught_rc0() {
  if [ "$LAST_RC" -eq 0 ]; then printf '  ok   %s: дефект наблюдаем (rc 0 на отказывающем входе)\n' "$1" >&2; return 0; fi
  printf '  FAIL %s: rc %s, дефект НЕ наблюдаем — стаб ушёл от поимки\nвывод:\n%s\n' "$1" "$LAST_RC" "$LAST_OUT" >&2
  return 1
}
# детекция: стаб ошибочно СУДИТ вход (rc 1 с фразой, где честная реализация rc 0)
chk_caught_refuse() {
  if [ "$LAST_RC" -eq 1 ] && printf '%s\n' "$LAST_OUT" | grep -Fq "$PHRASE"; then
    printf '  ok   %s: дефект наблюдаем (ложный отказ на чужом коммите)\n' "$1" >&2; return 0
  fi
  printf '  FAIL %s: rc %s, дефект НЕ наблюдаем\nвывод:\n%s\n' "$1" "$LAST_RC" "$LAST_OUT" >&2
  return 1
}
# диффпроба: стаб ЧЕСТЕН на контрольном входе (совпадает с честной реализацией)
chk_stub_honest_rc0() {
  if [ "$LAST_RC" -eq 0 ]; then printf '  ok   %s: стаб честен на контрольном входе (rc 0)\n' "$1" >&2; return 0; fi
  printf '  FAIL %s: rc %s, стаб нечестен на контрольном входе\nвывод:\n%s\n' "$1" "$LAST_RC" "$LAST_OUT" >&2
  return 1
}
chk_stub_honest_refuse() {
  if [ "$LAST_RC" -eq 1 ] && printf '%s\n' "$LAST_OUT" | grep -Fq "$PHRASE"; then
    printf '  ok   %s: стаб честен на контрольном входе (отказ теми же словами)\n' "$1" >&2; return 0
  fi
  printf '  FAIL %s: rc %s, стаб нечестен на контрольном входе\nвывод:\n%s\n' "$1" "$LAST_RC" "$LAST_OUT" >&2
  return 1
}

# ── режимы ────────────────────────────────────────────────────────────────────
case "$MODE" in
"") # честные клетки против живого гейта: до реализации rc 1 (красна ka)
  [ -f "$SUBJ" ] || { printf 'ОТКАЗ: гейт потребителей отсутствует: %s\n' "$SUBJ" >&2; exit 1; }
  build_all
  hcell ka-PR-rebase-vne-okna ka_c
  hcell kb-pravka-bez-zony-suditsja kb_c
  hcell kv1-svoj-kontrakt-suditsja kv1_c
  hcell kv2-proba-zhivaja-r0 kv2_c
  hcell kg-chuzhaja-identity-suditsja kg_c
  hcell kd1-chuzhoj-lend-vne-okna kd1_c
  hcell kd2-kanal-vladeltsa-iskljuchjon kd2_c
  hcell ke-otkaz-dobychi-imenovan ke_c
  printf '195: честных клеток %d, зелёных %d, красных:%s\n' \
    "$honest_total" "$honest_green" "${honest_fail:- нет}"
  [ "$honest_total" -gt 0 ] || { printf '195: ПУСТАЯ выборка честных клеток — красное\n' >&2; exit 1; }
  [ "$honest_green" -eq "$honest_total" ] || exit 1
  exit 0
  ;;
--model) # те же клетки против честной модели: rc 0 уже сегодня
  [ -f "$MODEL" ] || { printf 'NOT_IMPLEMENTED: модель отсутствует: %s\n' "$MODEL" >&2; exit 2; }
  REAL_SUBJ="$SUBJ"; SUBJ="$MODEL"
  build_all
  hcell ka-PR-rebase-vne-okna ka_c
  hcell kb-pravka-bez-zony-suditsja kb_c
  hcell kv1-svoj-kontrakt-suditsja kv1_c
  hcell kv2-proba-zhivaja-r0 kv2_c
  hcell kg-chuzhaja-identity-suditsja kg_c
  hcell kd1-chuzhoj-lend-vne-okna kd1_c
  hcell kd2-kanal-vladeltsa-iskljuchjon kd2_c
  hcell ke-otkaz-dobychi-imenovan ke_c
  SUBJ="$REAL_SUBJ"
  printf '195(model): честных клеток %d, зелёных %d, красных:%s\n' \
    "$honest_total" "$honest_green" "${honest_fail:- нет}"
  [ "$honest_total" -gt 0 ] || { printf '195: ПУСТАЯ выборка честных клеток — красное\n' >&2; exit 1; }
  [ "$honest_green" -eq "$honest_total" ] || exit 1
  exit 0
  ;;
--stabs) # обманные реализации: все пойманы, диффпробы зелёные; до и после реализации rc 0
  [ -f "$SUBJ" ] || { printf 'ОТКАЗ: гейт потребителей отсутствует: %s\n' "$SUBJ" >&2; exit 1; }
  build_all
  build_stubs
  REAL_SUBJ="$SUBJ"
  s1()      { with_stub "$STUBS/s1_gasitel.sh";          run_gate "$kg"  contracts/100-n.md; restore_subj; chk_caught_rc0 's1: гаситель отпустил чужую identity (вход kg)'; }
  s1_diff() { with_stub "$STUBS/s1_gasitel.sh";          run_gate "$ka"  contracts/100-n.md; restore_subj; chk_stub_honest_rc0 's1-диффпроба: коммит чужой зоны исключён как честный (вход ka)'; }
  s2()      { with_stub "$STUBS/s2_imja_bez_zony.sh";    run_gate "$kb"  contracts/100-n.md; restore_subj; chk_caught_rc0 's2: имя без зоны отпустило правку без зоны писателя (вход kb)'; }
  s2_diff() { with_stub "$STUBS/s2_imja_bez_zony.sh";    run_gate "$kg"  contracts/100-n.md; restore_subj; chk_stub_honest_refuse 's2-диффпроба: необъявленный автор судится как честный (вход kg)'; }
  s3()      { with_stub "$STUBS/s3_tolko_land.sh";       run_gate "$ka"  contracts/100-n.md; restore_subj; chk_caught_refuse 's3: только-land судит PR-rebase коммит (вход ka)'; }
  s3_diff() { with_stub "$STUBS/s3_tolko_land.sh";       run_gate "$kd1" contracts/100-n.md; restore_subj; chk_stub_honest_rc0 's3-диффпроба: чужой ленд исключён как честный (вход kd1)'; }
  s4()      { with_stub "$STUBS/s4_oshibka_pusto.sh";    run_gate "$ke"  contracts/100-n.md; restore_subj; chk_caught_rc0 's4: отказ добычи стал vacuous rc 0 (вход ke)'; }
  s4_diff() { with_stub "$STUBS/s4_oshibka_pusto.sh";    run_gate "$kb"  contracts/100-n.md; restore_subj; chk_stub_honest_refuse 's4-диффпроба: живое окно судится как честное (вход kb)'; }
  s5()      { with_stub "$STUBS/s5_svoj_tozhe_naruzhu.sh"; run_gate "$kv1" contracts/100-n.md; restore_subj; chk_caught_rc0 's5: свой контракт исключён через M==N (вход kv1)'; }
  s5_diff() { with_stub "$STUBS/s5_svoj_tozhe_naruzhu.sh"; run_gate "$ka"  contracts/100-n.md; restore_subj; chk_stub_honest_rc0 's5-диффпроба: чужая зона исключена как честная (вход ka)'; }
  scell s1-gasitel s1
  scell s2-imja-bez-zony s2
  scell s3-tolko-land s3
  scell s4-oshibka-pusto s4
  scell s5-svoj-tozhe-naruzhu s5
  dcell s1-diffpr s1_diff
  dcell s2-diffpr s2_diff
  dcell s3-diffpr s3_diff
  dcell s4-diffpr s4_diff
  dcell s5-diffpr s5_diff
  printf '195(stabs): стабов %d, поймано %d, ускользнуло:%s\n' \
    "$stub_total" "$stub_caught" "${stub_esc:- нет}"
  printf '195(stabs): диффпроб %d, зелёных %d, провал:%s\n' \
    "$diff_total" "$diff_green" "${diff_fail:- нет}"
  [ "$stub_total" -gt 0 ]   || { printf '195: ПУСТАЯ выборка стабов — красное\n' >&2; exit 1; }
  [ "$diff_total" -gt 0 ]   || { printf '195: ПУСТАЯ выборка диффпроб — красное\n' >&2; exit 1; }
  [ "$stub_caught" -eq "$stub_total" ] || exit 1
  [ "$diff_green" -eq "$diff_total" ] || exit 1
  exit 0
  ;;
--repo) # живая клетка на настоящем дереве (до реализации rc 1 — боль)
  [ -f "$SUBJ" ] || { printf 'ОТКАЗ: гейт потребителей отсутствует: %s\n' "$SUBJ" >&2; exit 1; }
  live_cell "${2:-$REPO}"
  exit $?
  ;;
*)
  printf 'использование: %s [--model|--stabs|--repo [корень]]\n' "$0" >&2
  exit 2
  ;;
esac
