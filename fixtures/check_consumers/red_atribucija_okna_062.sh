#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Красная батарея контракта 062 — атрибуция окна потребителей 116 (Н-66-класс;
# измеренная боль: dones 056/058/059 стоят — их линейные окна вобрали правки
# писателя freeze_contract.sh, принесённые ЧУЖИМИ лендами wip/060/*).
# Предмет: п2 scripts/check_consumers.sh — окно тронутых писателей = коммиты
# СВОЕЙ ветки/лендов контракта, грамматика своей-ветки как у check_zones
# (021, ветвь А): прямой хребет ∪ коммиты за merge'ями `land: wip/<NNN>/…`;
# за ЧУЖИМИ `land: wip/<OTHER>/…` — исключены; merge без маркера — внутренний.
#
# ЧЕСТНЫЕ КЛЕТКИ (живой scripts/check_consumers.sh этого дерева; игрушки 062
# на каркасе _toy.sh — маппинг тремя писателями-минимума НАСТОЯЩИМИ путями,
# окно frozen/contracts/062/1..HEAD):
#   к1 (а) чужой ленд писателя НЕ судится — КРАСНАЯ до реализации (сегодня
#          линейное окно судит: rc 1 «нет ПОТРЕБИТЕЛЬ-пробы»), зелёная после;
#   к2 (б) свой прямой коммит писателя судится — зелёная всегда;
#   к3 (б) свой ленд (`land: wip/062/implementer`) судится — зелёная всегда;
#   к4 (в) проба живая: писатель тронут, проба есть и зелёная — rc 0 всегда;
#   к5 (г) без писателя — vacuous rc 0 всегда;
#   к6      merge БЕЗ `land:` маркера — внутренний: принесённая правка
#          писателя судится — зелёная всегда.
#   к7 (И-2) правка писателя СВОИМ коммитом и ВОЗВРАТ исходного содержимого
#          следующим своим — КРАСНАЯ до реализации (конечный дифф пуст,
#          сегодня rc 0), зелёная после: покоммитная тронутость;
#   к8 (И-4) объект тега-границы удалён (tag -l листингует, разрешение
#          диапазона отказывает) — КРАСНАЯ до реализации (сегодня тихий
#          vacuous rc 0), зелёная после: именованный отказ добычи окна.
#
# СТАБ-ПАК (Н-39: обман ровно одной ручкой; привязка стабов к ветвям — ЭТОТ
# код, не проза контракта; стаб-пак зелёный ДО и ПОСЛЕ реализации —
# различимость не зависит от честного кода):
#   s1 «линейный судия»  — ленд-грамматику не читает вовсе (поведение ДО 062);
#       смерть к1 (судит чужой ленд), честен на к2 (диффпроба);
#   s2 «слепец окна»     — судимое множество пусто всегда; смерть к2
#       (пропускает свой коммит), честен на к5 (диффпроба);
#   s3 «все land: чужие» — исключает и СВОИ ленды; смерть к3, честен на к2;
#   s4 «все merge чужие» — исключает и внутренние слияния; смерть к6,
#       честен на к2.
#   s5 «endpoint-фильтр»  — грамматика честная, но тронутость требует
#       непустого конечного диффа тег..HEAD (контрмодель критика 062-к1);
#       смерть к7, честен на к2 (диффпроба);
#   s6 «ошибка→пустое»    — окно и тронутость честные, отказ добычи
#       проглатывается в пустое множество (контрмодель критика 062-к1);
#       смерть к8, честен на к2 (диффпроба).
# Стабы судят только отсутствие пробы (клетки смерти/контроля проб не несут);
# фраза отказа — дословно фраза гейта.
#
# rc: 0 ⟺ стаб-пак пойман весь ∧ честные клетки зелёные ∧ выборки непусты;
# на HEAD ожидается rc 1 (красные — клетки к1/к7/к8: предмет не реализован).
# Скрипт не печатает PASS — только счёт просмотренного (правило роли).
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_toy.sh"

[ -f "$SUBJ" ] || { printf 'ОТКАЗ: гейт потребителей отсутствует: %s\n' "$SUBJ" >&2; exit 1; }
REAL_SUBJ="$SUBJ"

PHRASE='потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы'

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red062.XXXXXX")"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# ── игрушка 062: основа каркаса + тег-граница окна СВОЕГО номера ────────────
mkt62() {
  local r="$1"
  mkdir -p "$r/scripts" "$r/contracts" "$r/fixtures"
  seed_mapping "$r" fixtures/reader.sh
  printf '# kontrakt 062 v2 draft\n\n## Predmet\natribucija okna pisatelej\n' > "$r/contracts/062-x.md"
  git -C "$r" init -q -b main
  g "$r" config user.name Fixture
  g "$r" config user.email fixture@local
  commit_all "$r" 'osnovanie s mappingom'
  g "$r" tag -a frozen/contracts/062/1 -m 'granica okna 062'
}

put_draft62() { # <каталог> <тело-черновика> — черновик закоммичен на хребте В ОКНЕ
  local r="$1" body="$2"
  printf '# kontrakt 062 v2 draft\n\n## Predmet\natribucija okna pisatelej\n\n%s\n' "$body" > "$r/contracts/062-x.md"
  commit_all "$r" 'chernovik 062 v2'
}

land_branch() { # <каталог> <ветка> <правка-fn> <commit-msg> <land-msg>
  local r="$1" br="$2" ch="$3" msg="$4" land="$5" cur
  cur="$(git -C "$r" symbolic-ref --short HEAD)"
  g "$r" checkout -q -b "$br"
  "$ch" "$r"
  commit_all "$r" "$msg"
  g "$r" checkout -q "$cur"
  g "$r" merge --no-ff -q -m "$land" "$br"
}

touch_chuzhoe() { # правка НЕ-писателя (vacuous-клетка к5)
  printf 'chuzhoe izmenenie\n' > "$1/README_chuzhoe.md"
}

# ── незавершающие проверки (батарея считает, не умирает на первой) ───────────
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

PHRASE4='потребители 116: список судимых коммитов окна недоступен'
chk_win_refuse() { # именованный отказ добычи окна (И-4): rc 1 + дословная фраза
  if [ "$LAST_RC" -eq 1 ] && printf '%s\n' "$LAST_OUT" | grep -Fq "$PHRASE4"; then
    printf '  ok   %s: отказ добычи окна rc 1, причина названа дословно\n' "$1" >&2; return 0
  fi
  printf '  FAIL %s: rc %s, ожидался отказ 1 с дословной причиной «%s»\nвывод гейта:\n%s\n' "$1" "$LAST_RC" "$PHRASE4" "$LAST_OUT" >&2
  return 1
}

with_stub() { SUBJ="$1"; }
restore_subj() { SUBJ="$REAL_SUBJ"; }

# ── ЧЕСТНЫЕ КЛЕТКИ ────────────────────────────────────────────────────────────
k1() { # (а) чужой ленд писателя — НЕ судится; КРАСНАЯ до реализации
  local T="$WORK/k1"; mkt62 "$T"
  put_draft62 "$T" "$CENSUS"
  land_branch "$T" br_chuzhoj_090 touch_writer \
    'chuzhaja pravka pisatelja (kontrakt 090)' 'land: wip/090/implementer'
  run_gate "$T" contracts/062-x.md
  chk_rc0 'к1: чужой ленд (land: wip/090/…) вне окна — гейт не судит'
}
k2() { # (б) свой прямой коммит судится — дверь не ослаблена
  local T="$WORK/k2"; mkt62 "$T"
  put_draft62 "$T" "$CENSUS"
  touch_writer "$T"; commit_all "$T" 'svoja pravka pisatelja na khrebte'
  run_gate "$T" contracts/062-x.md
  chk_refuse 'к2: свой прямой коммит писателя судится'
}
k3() { # (б) свой ленд судится (свои ленды приносят коммиты в окно)
  local T="$WORK/k3"; mkt62 "$T"
  put_draft62 "$T" "$CENSUS"
  land_branch "$T" br_svoj_062 touch_writer \
    'svoja pravka pisatelja v vetke' 'land: wip/062/implementer'
  run_gate "$T" contracts/062-x.md
  chk_refuse 'к3: свой ленд (land: wip/062/…) судится'
}
k4() { # (в) проба живая: писатель тронут своим коммитом, проба есть и зелёная
  local T="$WORK/k4"; mkt62 "$T"
  touch_writer "$T"; commit_all "$T" 'svoja pravka pisatelja na khrebte'
  put_draft62 "$T" "$CENSUS

## Potrebiteli
ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash fixtures/reader.sh"
  run_gate "$T" contracts/062-x.md
  chk_rc0 'к4: проба живая — rc 0'
}
k5() { # (г) без писателя — vacuous rc 0
  local T="$WORK/k5"; mkt62 "$T"
  put_draft62 "$T" "$CENSUS"
  land_branch "$T" br_chuzhoe_090 touch_chuzhoe \
    'chuzhoe izmenenie (kontrakt 090)' 'land: wip/090/implementer'
  run_gate "$T" contracts/062-x.md
  chk_rc0 'к5: без писателя — vacuous rc 0'
}
k6() { # merge БЕЗ land-маркера — внутренний: принесённая правка судится
  local T="$WORK/k6"; mkt62 "$T"
  put_draft62 "$T" "$CENSUS"
  land_branch "$T" br_svod touch_writer \
    'pravka pisatelja vo vnutrennem slijanii' 'svod: vnutrennee slijanie vetok'
  run_gate "$T" contracts/062-x.md
  chk_refuse 'к6: merge без land-маркера — внутренний, судится'
}
k7() { # (И-2) правка-и-возврат своими коммитами хребта — КРАСНАЯ до реализации
  local T="$WORK/k7"; mkt62 "$T"
  put_draft62 "$T" "$CENSUS"
  cp "$T/scripts/freeze_contract.sh" "$WORK/k7-orig"
  touch_writer "$T"; commit_all "$T" 'svoja pravka pisatelja na khrebte'
  cp "$WORK/k7-orig" "$T/scripts/freeze_contract.sh"
  commit_all "$T" 'vozvrat iskhodnogo soderzhimogo pisatelja'
  run_gate "$T" contracts/062-x.md
  chk_refuse 'к7: правка-и-возврат в своей ветке судится (покоммитная тронутость)'
}
k8() { # (И-4) отказ добычи окна — именованный rc 1, не vacuous; КРАСНАЯ до реализации
  local T="$WORK/k8" obj f
  mkt62 "$T"
  put_draft62 "$T" "$CENSUS"
  obj="$(git -C "$T" rev-parse frozen/contracts/062/1)"
  f="$T/.git/objects/${obj:0:2}/${obj:2}"
  [ -f "$f" ] || { printf '  FAIL к8: объект тега-границы не loose-файл: %s\n' "$f" >&2; return 1; }
  rm -f "$f"
  run_gate "$T" contracts/062-x.md
  chk_win_refuse 'к8: отказ добычи окна — именованный отказ, не пустое множество'
}

honest_total=0; honest_green=0; honest_fail=""
hcell() { # hcell <имя> <функция>
  local n="$1" f="$2"
  honest_total=$((honest_total + 1))
  if "$f"; then honest_green=$((honest_green + 1)); else honest_fail="$honest_fail $n"; fi
}

hcell к1-чужой-ленд-не-судится k1
hcell к2-свой-коммит-судится k2
hcell к3-свой-ленд-судится k3
hcell к4-проба-живая-rc0 k4
hcell к5-без-писателя-vacuous k5
hcell к6-merge-без-маркера-внутренний k6
hcell к7-правка-i-vozvrat-suditsja k7
hcell к8-otkaz-dobychi-okna-imenovan k8

# ── СТАБ-ПАК (обманные реализации; игрушки честных клеток уже построены) ─────
STUBS="$WORK/stubs"; mkdir -p "$STUBS"

# s1 «линейный судия»: писатель тронут ⟺ линейный diff диапазона тег..HEAD —
# ленд-грамматика не читается вовсе (поведение гейта ДО 062; сохранён как
# стаб: после реализации обязан оставаться пойманным на к1).
cat > "$STUBS/s1_lin_sudja.sh" <<'EOF'
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
if git -C "$ROOT" diff-tree --no-commit-id --name-only -r "$last_frozen"..HEAD \
     -- scripts/freeze_contract.sh 2>/dev/null | grep -q .; then
  printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
  exit 1
fi
exit 0
EOF

# s2 «слепец окна»: судимое множество пусто всегда — vacuous-зелёный на любом входе.
cat > "$STUBS/s2_slepec_okna.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
: "${1:?ispolzovanie: <koren> <otn-put-kontrakta>}"
: "${2:?ispolzovanie: <koren> <otn-put-kontrakta>}"
exit 0
EOF

# s3 «все land:-маркеры чужие»: исключает коммиты за ЛЮБЫМ merge с маркером
# `land: wip/` — и СВОИМ тоже; хребет и слияния без маркера судятся.
cat > "$STUBS/s3_vse_landy_chuzhie.sh" <<'EOF'
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
EXCL="$(mktemp)"; COMMITS="$(mktemp)"
trap 'rm -f "$EXCL" "$COMMITS"' EXIT
git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u > "$COMMITS"
: > "$EXCL"
git -C "$ROOT" rev-list --merges "$last_frozen..HEAD" 2>/dev/null | while IFS= read -r mc; do
  [ -n "$mc" ] || continue
  msg="$(git -C "$ROOT" log -1 --format=%s "$mc" 2>/dev/null)"
  case "$msg" in
    "land: wip/"*) git -C "$ROOT" rev-list --no-merges "${mc}^1..${mc}" 2>/dev/null >> "$EXCL" ;;
  esac
done
sort -u "$EXCL" -o "$EXCL"
hit=0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  if git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" \
       -- scripts/freeze_contract.sh 2>/dev/null | grep -q .; then
    hit=1; break
  fi
done < <(comm -23 "$COMMITS" "$EXCL")
[ "$hit" -eq 0 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF

# s4 «все merge чужие»: исключает коммиты за ЛЮБЫМ merge — маркер не читает вовсе.
cat > "$STUBS/s4_vse_merge_chuzhie.sh" <<'EOF'
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
EXCL="$(mktemp)"; COMMITS="$(mktemp)"
trap 'rm -f "$EXCL" "$COMMITS"' EXIT
git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u > "$COMMITS"
: > "$EXCL"
git -C "$ROOT" rev-list --merges "$last_frozen..HEAD" 2>/dev/null | while IFS= read -r mc; do
  [ -n "$mc" ] || continue
  git -C "$ROOT" rev-list --no-merges "${mc}^1..${mc}" 2>/dev/null >> "$EXCL"
done
sort -u "$EXCL" -o "$EXCL"
hit=0
while IFS= read -r c; do
  [ -n "$c" ] || continue
  if git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" \
       -- scripts/freeze_contract.sh 2>/dev/null | grep -q .; then
    hit=1; break
  fi
done < <(comm -23 "$COMMITS" "$EXCL")
[ "$hit" -eq 0 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF
# s5 «endpoint-фильтр»: грамматика окна честная (И-1), тронутость по коммиту
# честная, НО требует непустого конечного диффа тег..HEAD — правка-и-возврат
# уходит из окна (контрмодель критика 062-к1 по И-2; поведение ДО 062).
cat > "$STUBS/s5_endpoint_filtr.sh" <<'EOF'
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
EXCL="$(mktemp)"; COMMITS="$(mktemp)"
trap 'rm -f "$EXCL" "$COMMITS"' EXIT
if ! git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u >"$COMMITS"; then
  printf 'потребители 116: список судимых коммитов окна недоступен\n' >&2
  exit 1
fi
git -C "$ROOT" diff-tree --no-commit-id --name-only -r "$last_frozen"..HEAD \
  -- scripts/freeze_contract.sh 2>/dev/null | grep -q . || exit 0
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
  if git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" \
       -- scripts/freeze_contract.sh 2>/dev/null | grep -q .; then
    hit=1; break
  fi
done < <(comm -23 "$COMMITS" "$EXCL")
[ "$hit" -eq 0 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF

# s6 «ошибка→пустое множество»: грамматика окна и покоммитная тронутость
# честные, но отказ добычи множества проглатывается в пустоту — vacuous rc 0
# (контрмодель критика 062-к1 по И-4: контур «|| true» на rev-list).
cat > "$STUBS/s6_oshibka_pusto.sh" <<'EOF'
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
EXCL="$(mktemp)"; COMMITS="$(mktemp)"
trap 'rm -f "$EXCL" "$COMMITS"' EXIT
git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u >"$COMMITS" || true
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
  if git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" \
       -- scripts/freeze_contract.sh 2>/dev/null | grep -q .; then
    hit=1; break
  fi
done < <(comm -23 "$COMMITS" "$EXCL")
[ "$hit" -eq 0 ] && exit 0
printf 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы\n' >&2
exit 1
EOF
chmod +x "$STUBS"/*.sh

stub_total=0; stub_caught=0; stub_esc=""
scell() { # scell <имя> <функция-детекции>; детекция rc0 = дефект НАБЛЮДЁН (пойман)
  local n="$1" f="$2"
  stub_total=$((stub_total + 1))
  if "$f"; then stub_caught=$((stub_caught + 1)); else stub_esc="$stub_esc $n"; fi
}
diff_total=0; diff_green=0; diff_fail=""
dcell() { # dcell <имя> <функция-диффпробы>; rc0 = стаб честен на контрольном входе
  local n="$1" f="$2"
  diff_total=$((diff_total + 1))
  if "$f"; then diff_green=$((diff_green + 1)); else diff_fail="$diff_fail $n"; fi
}

s1() { # смерть к1: линейный судья судит чужой ленд — дефект наблюдаем
  with_stub "$STUBS/s1_lin_sudja.sh"
  run_gate "$WORK/k1" contracts/062-x.md
  restore_subj
  chk_refuse 's1: линейный судия судит чужой ленд (вход к1) — пойман'
}
s1_diff() { # диффпроба: на СВОЁМ коммите s1 честен (отказ теми же словами)
  with_stub "$STUBS/s1_lin_sudja.sh"
  run_gate "$WORK/k2" contracts/062-x.md
  restore_subj
  chk_refuse 's1-диффпроба: свой коммит судит как честный (вход к2)'
}
s2() { # смерть к2: слепец пропускает свой коммит
  with_stub "$STUBS/s2_slepec_okna.sh"
  run_gate "$WORK/k2" contracts/062-x.md
  restore_subj
  chk_rc0 's2: слепец окна пропустил свой коммит (вход к2) — пойман'
}
s2_diff() { # диффпроба: на vacuous-входе слепец совпадает с честным (оба rc 0)
  with_stub "$STUBS/s2_slepec_okna.sh"
  run_gate "$WORK/k5" contracts/062-x.md
  restore_subj
  chk_rc0 's2-диффпроба: vacuous-вход даёт rc 0 как честный (вход к5)'
}
s3() { # смерть к3: свой ленд исключён как чужой — правка писателя ушла из окна
  with_stub "$STUBS/s3_vse_landy_chuzhie.sh"
  run_gate "$WORK/k3" contracts/062-x.md
  restore_subj
  chk_rc0 's3: свой ленд исключён, свой коммит не судится (вход к3) — пойман'
}
s3_diff() { # диффпроба: хребет судится честно
  with_stub "$STUBS/s3_vse_landy_chuzhie.sh"
  run_gate "$WORK/k2" contracts/062-x.md
  restore_subj
  chk_refuse 's3-диффпроба: хребет судит как честный (вход к2)'
}
s4() { # смерть к6: внутреннее слияние исключено — правка писателя ушла из окна
  with_stub "$STUBS/s4_vse_merge_chuzhie.sh"
  run_gate "$WORK/k6" contracts/062-x.md
  restore_subj
  chk_rc0 's4: внутреннее слияние исключено, правка не судится (вход к6) — пойман'
}
s4_diff() { # диффпроба: хребет судится честно
  with_stub "$STUBS/s4_vse_merge_chuzhie.sh"
  run_gate "$WORK/k2" contracts/062-x.md
  restore_subj
  chk_refuse 's4-диффпроба: хребет судит как честный (вход к2)'
}
s5() { # смерть к7: endpoint-фильтр отпускает правку-и-возврат (конечный дифф пуст)
  with_stub "$STUBS/s5_endpoint_filtr.sh"
  run_gate "$WORK/k7" contracts/062-x.md
  restore_subj
  chk_rc0 's5: правка-и-возврат ушла из окна по конечному диффу (вход к7) — пойман'
}
s5_diff() { # диффпроба: на сохранённой правке s5 честен (отказ теми же словами)
  with_stub "$STUBS/s5_endpoint_filtr.sh"
  run_gate "$WORK/k2" contracts/062-x.md
  restore_subj
  chk_refuse 's5-диффпроба: сохранённая правка судится как честная (вход к2)'
}
s6() { # смерть к8: отказ добычи проглочен в vacuous rc 0
  with_stub "$STUBS/s6_oshibka_pusto.sh"
  run_gate "$WORK/k8" contracts/062-x.md
  restore_subj
  chk_rc0 's6: отказ добычи окна стал пустым множеством, rc 0 (вход к8) — пойман'
}
s6_diff() { # диффпроба: на живом окне s6 честен (отказ теми же словами)
  with_stub "$STUBS/s6_oshibka_pusto.sh"
  run_gate "$WORK/k2" contracts/062-x.md
  restore_subj
  chk_refuse 's6-диффпроба: живое окно судится как честное (вход к2)'
}

scell s1-линейный-судия s1
scell s2-слепец-окна s2
scell s3-все-landy-чужие s3
scell s4-все-merge-чужие s4
dcell s1-диффпроба s1_diff
dcell s2-диффпроба s2_diff
dcell s3-диффпроба s3_diff
dcell s4-диффпроба s4_diff
scell s5-endpoint-filtr s5
scell s6-oshibka-pusto s6
dcell s5-диффпроба s5_diff
dcell s6-диффпроба s6_diff

# ── итог: счёт просмотренного; пустая выборка — красное ───────────────────────
printf '062: честных клеток %d, зелёных %d, красных:%s\n' \
  "$honest_total" "$honest_green" "${honest_fail:- нет}"
printf '062: стабов %d, поймано %d, ускользнуло:%s\n' \
  "$stub_total" "$stub_caught" "${stub_esc:- нет}"
printf '062: диффпроб стабов без ручки %d, зелёных %d, провал:%s\n' \
  "$diff_total" "$diff_green" "${diff_fail:- нет}"

[ "$honest_total" -gt 0 ] || { printf '062: ПУСТАЯ выборка честных клеток — красное\n' >&2; exit 1; }
[ "$stub_total" -gt 0 ]   || { printf '062: ПУСТАЯ выборка стабов — красное\n' >&2; exit 1; }
[ "$diff_total" -gt 0 ]   || { printf '062: ПУСТАЯ выборка диффпроб — красное\n' >&2; exit 1; }
[ "$stub_caught" -eq "$stub_total" ] || exit 1
[ "$diff_green" -eq "$diff_total" ] || exit 1
[ "$honest_green" -eq "$honest_total" ] || exit 1
exit 0
