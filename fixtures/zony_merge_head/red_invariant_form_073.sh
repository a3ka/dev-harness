#!/usr/bin/env bash
# Красная/зелёная батарея 073 «гейт зон на merge-HEAD» — формонезависимость
# вердикта check_zones.sh (живой укус Н-181, CI run 36943258172).
#
# ПРЕДМЕТ (инварианты контракта 073):
#   И1  вердикт гейта (rc + множество FAIL-строк) на фиксированных объектах и
#       тегах не зависит от формы чекаута: наличие/отсутствие локальной ветки
#       refs/heads/main; ветка vs её merge с base; — матрица 2×2 на каждом
#       из двух синтетических деревьев; Б2 к1: матрица предъявляет ДВА
#       сохранённых SHA — B = исходная вершина ветки b1 (merge НЕ на
#       probe-ветке, ветку не перемещает) и M = отдельный merge-коммит от
#       b1; клетка на НЕмерженном b1 без main ловит обход «признание
#       только для HEAD с двумя родителями».
#   И2  замена реестровой строки (форма REPLACE двери минта 031/049),
#       легальная на главной линии судимого окна (f2 — закрытое окно 005,
#       r1 — открытое окно 006), НЕ красит «вне зоны» НИ В ОДНОЙ форме
#       (до правки красит в бес-main формах: check_zones.sh:1077, блокер B
#       контракта 049 привязал признание к предку ЛОКАЛЬНОЙ refs/heads/main);
#   И3  дверь минта не ослабляется: неграмотная дельта реестра (p2, −2/+0)
#       красит именованной причиной «дверь минта 031: дельта манифеста не
#       только-добавление» в КАЖДОЙ форме и не уходит в «вне зоны»;
#   И4  закрытые (done) окна не вскрываются: ловушка t1 в межоконном зазоре
#       (после done/005/1, до frozen/006/1) не судится НИ в одной форме,
#       включая merge-HEAD;
#   И5  блокер B 049 по смыслу: боковая замена p3 (второй родитель чужого
#       non-land merge в открытом окне 006) красит «вне зоны» в КАЖДОЙ
#       форме — чинить формозависимость признанием ВСЕХ замен нельзя.
#
# ДЕРЕВЬЯ:
#   fx  (с пробами): f2, r1 — легальные замены; t1 — ловушка зазора;
#       p2 — неграмотная дельта; p3 — боковая замена (через merge стороны).
#   fx2 (чистое): только легальные замены f2, r1 → после честной правки
#       rc 0 во ВСЕХ формах («ветка rc 0 И merge rc 0 на одном дереве»).
#
# Н-39 (привязки стабов — здесь, в коде, к входам, где дефект НАБЛЮДАЕМ):
#   s1 «фикс = расширить зоны orchestrator на registry» — патч lib_zones
#      добавляет строку zones_scoped orchestrator→registry/contracts.tsv.
#      Наблюдаем на p3: честный гейт красит её «вне зоны» в каждой форме,
#      s1 пропускает ЗОНОЙ — ослабление поймано.
#   s2 «фикс = убрать проверку главной линии совсем» — check_zones:1077
#      заменён на `if true`; после честной правки 073 (предикат заменён)
#      стаб переключается на структурный якорь on_main_replace (СОВЕТ-2 к1).
#      Легальные f2/r1 s2 не отличает от честного фикса; наблюдаем ТОЛЬКО
#      на p3: боковая замена признаётся → пойман.
#   s3 «фикс = заглушка двери минта» — ветка orchestrator+registry выходит
#      из суда без проверки формы. Наблюдаем на p2: честный гейт красит
#      именованной причиной, s3 молчит → пойман.
#   s4 «фикс = считать закрытые окна открытыми» — lib_zones не закрывает
#      диапазоны done-тегом. Наблюдаем на t1 (путь scripts/trap_073.sh):
#      честный гейт t1 не судит вовсе, s4 вносит её в окно 005 → пойман.
#
# Семантика: rc 1 — любой пин нарушен (ДО правки нарушены И1/И2 — живое
# красное; стаб не пойман — недопустимо ни до, ни после); rc 0 — все пины
# держатся (после честной правки). FIXSIM=1 — А-318-класс: throwaway-симуляция
# честной правки на копии гейта в скратче обязана превратить всё в зелёное;
# симуляция умирает вместе со скратчем, в дереве её не остаётся.
#
# Использование:
#   bash fixtures/zony_merge_head/red_invariant_form_073.sh
#   FIXSIM=1 bash fixtures/zony_merge_head/red_invariant_form_073.sh
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/../.." && pwd)}"

command -v git >/dev/null 2>&1 || { printf 'ОТКАЗ: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'ОТКАЗ: нет python3\n' >&2; exit 2; }

# Скратч — ВНЕ стерегомого дерева (канон 014).
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/zony073.XXXXXX")" || { printf 'ОТКАЗ: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/gates"

fails=0
red() { fails=$((fails + 1)); printf '  КРАСНО: %s\n' "$*"; }

# ── построитель фикстур ───────────────────────────────────────────────────────
# <дерево> <пробы:1|0>. Линия mainline:
#   c0(005) → c_reg(минт005) → f2(замена005) → d1(done005) → [t1] → c6(006)
#   → c6reg(минт006) → r1(замена006) → [merge стороны sb: p3] → [p2] → m2
#   → m3; wip от m2 + b1; M = merge(wip, mainline) — PR-картина.
build_fx() {
  local fx="$SCRATCH/$1" probes="$2"
  local G="git -C $fx"
  git init -q -b mainline "$fx"
  $G config user.name orchestrator
  $G config user.email orchestrator@dev-harness.local
  mkdir -p "$fx/contracts" "$fx/registry" "$fx/scripts/zzz" "$fx/tmp"
  : > "$fx/registry/contracts.tsv"

  printf 'ЗОНА orchestrator: scripts/zzz/\n' > "$fx/contracts/005-merge-head-zony.md"
  $G add -A && $G commit -q -m 'c0: контракт 005'
  $G tag -a id/CONTRACT/005 -m mint005
  local sid5; sid5="$($G rev-parse id/CONTRACT/005)"
  printf '005 → %s\n' "$sid5" > "$fx/registry/contracts.tsv"
  $G add -A && $G commit -q -m 'минт 005'
  $G tag -a frozen/contracts/005/1 -m freeze005
  local sfr5; sfr5="$($G rev-parse frozen/contracts/005/1)"
  printf '005 → %s\n' "$sfr5" > "$fx/registry/contracts.tsv"
  $G add -A && $G commit -q -m 'freeze: registry 005'
  SHA_F2="$($G rev-parse HEAD)"
  printf 'x' > "$fx/scripts/zzz/d1.txt"
  $G add -A && $G commit -q -m 'd1: закрытие 005'
  $G tag -a done/contracts/005/1 -m done005
  if [ "$probes" = "1" ]; then
    printf 'x' > "$fx/scripts/trap_073.sh"
    $G add -A && $G commit -q -m 't1: ловушка межоконного зазора'
    SHA_T1="$($G rev-parse HEAD)"
  fi
  printf 'ЗОНА orchestrator: scripts/zzz/\n' > "$fx/contracts/006-merge-head-zony.md"
  $G add -A && $G commit -q -m 'c6: контракт 006'
  $G tag -a id/CONTRACT/006 -m mint006
  local sid6; sid6="$($G rev-parse id/CONTRACT/006)"
  printf '005 → %s\n006 → %s\n' "$sfr5" "$sid6" > "$fx/registry/contracts.tsv"
  $G add -A && $G commit -q -m 'минт 006'
  $G tag -a frozen/contracts/006/1 -m freeze006
  local sfr6; sfr6="$($G rev-parse frozen/contracts/006/1)"
  printf '005 → %s\n006 → %s\n' "$sfr5" "$sfr6" > "$fx/registry/contracts.tsv"
  $G add -A && $G commit -q -m 'freeze: registry 006'
  SHA_R1="$($G rev-parse HEAD)"
  if [ "$probes" = "1" ]; then
    # сторона sb: контракт 007 целиком на боковой линии; p3 — замена там же.
    $G checkout -q -b sb
    printf 'ЗОНА orchestrator: scripts/zzz/\n' > "$fx/contracts/007-merge-head-zony.md"
    $G add -A && $G commit -q -m 'sb: контракт 007'
    $G tag -a id/CONTRACT/007 -m mint007
    local sid7; sid7="$($G rev-parse id/CONTRACT/007)"
    printf '005 → %s\n006 → %s\n007 → %s\n' "$sfr5" "$sfr6" "$sid7" > "$fx/registry/contracts.tsv"
    $G add -A && $G commit -q -m 'sb: минт 007'
    $G tag -a frozen/contracts/007/1 -m freeze007
    local sfr7; sfr7="$($G rev-parse frozen/contracts/007/1)"
    printf '005 → %s\n006 → %s\n007 → %s\n' "$sfr5" "$sfr6" "$sfr7" > "$fx/registry/contracts.tsv"
    $G add -A && $G commit -q -m 'sb: замена 007 (боковая)'
    SHA_P3="$($G rev-parse HEAD)"
    $G checkout -q mainline
    $G merge --no-ff -q -m 'заливка стороны (не land)' sb
    printf '007 → %s\n' "$sfr7" > "$fx/registry/contracts.tsv"
    $G add -A && $G commit -q -m 'p2: дельта реестра вне грамматики'
    SHA_P2="$($G rev-parse HEAD)"
  fi
  printf 'x' > "$fx/scripts/zzz/m2.txt"
  $G add -A && $G commit -q -m 'm2: чекпойнт'
  $G checkout -q -b wip/073/probe
  printf 'x' > "$fx/scripts/zzz/b1.txt"
  $G add -A && $G commit -q -m 'b1: работа ветки'
  SHA_B1="$($G rev-parse HEAD)"  # Б2 к1: вершина исходной ветки сохранена ДО merge
  $G checkout -q mainline
  printf 'x' > "$fx/scripts/zzz/m3.txt"
  $G add -A && $G commit -q -m 'm3: продвижение базы'
  SHA_M3="$($G rev-parse HEAD)"
  # Б2 к1: merge — ОТДЕЛЬНЫЙ merge-коммит ОТ b1 на detached HEAD:
  # probe-ветку НЕ перемещает, поэтому B-формы судят НЕмерженную исходную
  # ветку, M-формы — merge; клетка на b1 без main ловит обход «признание
  # только для HEAD с двумя родителями».
  $G checkout -q --detach wip/073/probe
  $G merge --no-ff -q -m probe mainline
  SHA_M="$($G rev-parse HEAD)"
  [ "$($G rev-parse wip/073/probe)" = "$SHA_B1" ] \
    || { printf 'ОТКАЗ: probe-ветка перемещена merge-ем (Б2 к1)\n' >&2; exit 2; }
  $G checkout -q mainline
  # шas сборки — в свой env-файл: вторая сборка не затирает первую.
  printf 'SHA_F2=%q\nSHA_R1=%q\nSHA_T1=%q\nSHA_P3=%q\nSHA_P2=%q\nSHA_M3=%q\nSHA_M=%q\nSHA_B1=%q\n' \
    "$SHA_F2" "$SHA_R1" "$SHA_T1" "$SHA_P3" "$SHA_P2" "$SHA_M3" "$SHA_M" "$SHA_B1" > "$SCRATCH/$1.env"
}

load_shas() { # <дерево>
  SHA_F2=''; SHA_R1=''; SHA_T1=''; SHA_P3=''; SHA_P2=''; SHA_M3=''; SHA_M=''; SHA_B1=''
  # shellcheck disable=SC1090
  . "$SCRATCH/$1.env"
}

build_fx fx 1
build_fx fx2 0

# ── копии гейта и патчи-стабы ─────────────────────────────────────────────────
gate_copy() { # <имя>
  mkdir -p "$SCRATCH/gates/$1"
  cp -r "$REPO_ROOT/scripts/." "$SCRATCH/gates/$1/"
}

lit() { printf '%s' "$2" > "$SCRATCH/$1"; }

patch_py() { # <файл> <якорь-файл> <новое-файл>
  python3 - "$1" "$2" "$3" <<'PYEOF'
import sys
path, old_f, new_f = sys.argv[1:4]
s = open(path, encoding='utf-8').read()
old = open(old_f, encoding='utf-8').read()
new = open(new_f, encoding='utf-8').read()
assert s.count(old) == 1, 'якорь не единственный: %r' % old[:60]
open(path, 'w', encoding='utf-8').write(s.replace(old, new, 1))
PYEOF
}

make_stub_s1() {  # зоны orchestrator расширены на registry (ослабление)
  gate_copy s1
  lit s1.old '  printf '"'"'%s\n'"'"' "$out"
  return 0'
  lit s1.new '  printf '"'"'orchestrator\tregistry/contracts.tsv\tstub-s1\n'"'"' >> "$out/zones_scoped"
  printf '"'"'%s\n'"'"' "$out"
  return 0'
  patch_py "$SCRATCH/gates/s1/lib_zones.sh" "$SCRATCH/s1.old" "$SCRATCH/s1.new"
}

make_stub_s2() {  # проверка главной линии убрана: замена признаётся всегда
  gate_copy s2
  lit s2.old '          if g merge-base --is-ancestor "$c" "refs/heads/main" 2>/dev/null; then'
  lit s2.new '          if true; then'
  # СОВЕТ-2 к1: якорь переживает правку :1077 — если старый предикат уже
  # заменён честной правкой 073, стаб нейтрализует СТРУКТУРНЫЙ якорь
  # REPLACE-ветви (инициализацию флага признания on_main_replace), не текст
  # предиката; снос обоих якорей — именованный отказ, не молчаливый пропуск.
  if grep -Fq '          if g merge-base --is-ancestor "$c" "refs/heads/main" 2>/dev/null; then' \
      "$SCRATCH/gates/s2/check_zones.sh"; then
    patch_py "$SCRATCH/gates/s2/check_zones.sh" "$SCRATCH/s2.old" "$SCRATCH/s2.new"
  elif grep -Fq 'on_main_replace=0' "$SCRATCH/gates/s2/check_zones.sh"; then
    lit s2b.old 'on_main_replace=0'
    lit s2b.new 'on_main_replace=1'
    patch_py "$SCRATCH/gates/s2/check_zones.sh" "$SCRATCH/s2b.old" "$SCRATCH/s2b.new"
  else
    printf '  ОТКАЗ: стаб s2 — оба якоря снесены (предикат :1077 и on_main_replace)\n' >&2
    return 1
  fi
}

make_stub_s3() {  # дверь минта заглушена: orchestrator+registry вне суда
  gate_copy s3
  lit s3.old '      if [ "$an" = "orchestrator" ] && [ "$f" = "registry/contracts.tsv" ]; then'
  lit s3.new '      if [ "$an" = "orchestrator" ] && [ "$f" = "registry/contracts.tsv" ]; then
        skip_path=1; continue'
  patch_py "$SCRATCH/gates/s3/check_zones.sh" "$SCRATCH/s3.old" "$SCRATCH/s3.new"
}

make_stub_s4() {  # закрытые окна не закрываются done-тегом
  gate_copy s4
  lit s4.old '    if git -C "$root" rev-parse --verify --quiet "refs/tags/$done_ref" >/dev/null; then'
  lit s4.new '    if false; then'
  patch_py "$SCRATCH/gates/s4/lib_zones.sh" "$SCRATCH/s4.old" "$SCRATCH/s4.new"
}

make_fixsim() {  # А-318: симуляция честной правки — throwaway, живёт в скратче
  gate_copy fixsim
  # СОВЕТ-2 к1: симуляция патчит СТАРЫЙ предикат :1077. После честной правки
  # его в гейте нет — гейт уже формонезависим, симуляция вырождается в
  # дословный честный прогон (именованная пометка ниже); патчить уже-чинённый
  # гейт значило бы тестировать симуляцию симуляции.
  if ! grep -Fq '          if g merge-base --is-ancestor "$c" "refs/heads/main" 2>/dev/null; then' \
      "$SCRATCH/gates/fixsim/check_zones.sh"; then
    printf '  FIXSIM: старый предикат :1077 отсутствует — гейт уже несёт правку 073, симуляция вырождена в честный прогон\n'
    return 0
  fi
  lit fs1.old '  range="$since..HEAD"
  [ -n "$until" ] && range="$since..$until"'
  lit fs1.new '  range="$since..HEAD"
  [ -n "$until" ] && range="$since..$until"
  CUR_UNTIL="${until:-HEAD}"'
  patch_py "$SCRATCH/gates/fixsim/check_zones.sh" "$SCRATCH/fs1.old" "$SCRATCH/fs1.new"
  lit fs2.old '          if g merge-base --is-ancestor "$c" "refs/heads/main" 2>/dev/null; then'
  # Поглощение вывода целиком (командная подстановка), не `| grep -q`:
  # ранний выход grep даёт rev-list SIGPIPE, под pipefail это НЕНУЛЕВОЙ rc
  # предиката — недетерминизм признания (пойман живым прогоном батареи).
  lit fs2.new '          if case " $(g rev-list --first-parent "$CUR_UNTIL" 2>/dev/null | tr '"'"'\n'"'"' '"'"' '"'"') " in *" $c "*) true ;; *) false ;; esac; then'
  patch_py "$SCRATCH/gates/fixsim/check_zones.sh" "$SCRATCH/fs2.old" "$SCRATCH/fs2.new"
}

# ── прогоны по формам ─────────────────────────────────────────────────────────
FORMS='M-nomain M-main B-nomain B-main'
set_form() { # <дерево> <форма>
  local G="git -C $SCRATCH/$1"
  $G branch -D main >/dev/null 2>&1 || true
  case "$2" in
    M-*) $G checkout -q "$SHA_M" ;;
    B-*) $G checkout -q "$SHA_B1" ;;
  esac
  case "$2" in
    *-main) $G branch main "$SHA_M3" >/dev/null 2>&1 ;;
  esac
}

run_gate() { # <гейт> <дерево> <форма> → rc=$?; FAIL-строки (срез « — зона…») в lastx
  load_shas "$2"
  set_form "$2" "$3"
  bash "$1" "$SCRATCH/$2" > "$SCRATCH/out" 2>&1
  local rc=$?
  grep '^  FAIL ' "$SCRATCH/out" | sed 's/ — зона автора.*$//' > "$SCRATCH/lastx" || true
  return $rc
}

vne() { printf '  FAIL коммит вне зоны: orchestrator %s %s' "${1:0:8}" "$2"; }
mint_named() { printf '  FAIL коммит вне зоны: orchestrator %s registry/contracts.tsv — дверь минта 031: дельта манифеста не только-добавление' "${1:0:8}"; }

gate_copy honest
HONEST="$SCRATCH/gates/honest/check_zones.sh"
# FIXSIM: гейтом-под-тестом секций 1–2 становится throwaway-симуляция честной
# правки — батарея обязана позеленеть ЦЕЛИКОМ (А-318: красное умирает от
# честной правки, не от стабов); стаб-пак секции 3 остаётся на дереве репо.
if [ "${FIXSIM:-0}" = "1" ]; then
  make_fixsim
  HONEST="$SCRATCH/gates/fixsim/check_zones.sh"
fi

# ── 1. И1: вердикт одинаков во всех формах (оба дерева) ───────────────────────
for tree in fx fx2; do
  printf 'И1 матрица форм, дерево %s (B=%s исходная ветка, M=%s merge от неё):\n' "$tree" "${SHA_B1:0:8}" "${SHA_M:0:8}"
  prev=''
  for form in $FORMS; do
    run_gate "$HONEST" "$tree" "$form"
    local_rc=$?
    sig="$(sort "$SCRATCH/lastx")"
    printf '  форма %s: rc=%s FAIL-строк=%s\n' "$form" "$local_rc" "$(wc -l < "$SCRATCH/lastx")"
    if [ -n "$prev" ]; then
      [ "$prev_rc" = "$local_rc" ] || red "И1/$tree: rc расходится ($prev=$prev_rc против $form=$local_rc) — вердикт зависит от формы чекаута"
      [ "$prev_sig" = "$sig" ] || red "И1/$tree: множество FAIL-строк расходится ($prev против $form)"
    fi
    prev="$form"; prev_rc="$local_rc"; prev_sig="$sig"
  done
done

# ── 2. Жёсткие пины на fx (до и после честной правки) ─────────────────────────
printf 'пины дерева fx:\n'
for form in $FORMS; do
  run_gate "$HONEST" fx "$form"
  grep -qxF "$(vne "$SHA_T1" scripts/trap_073.sh)" "$SCRATCH/lastx" \
    && red "И4: ловушка зазора t1 судится в форме $form — закрытое окно вскрыто"
  grep -qxF "$(vne "$SHA_F2" registry/contracts.tsv)" "$SCRATCH/lastx" \
    && red "И2: легальная замена f2 (закрытое окно 005) красит «вне зоны» в форме $form"
  grep -qxF "$(vne "$SHA_R1" registry/contracts.tsv)" "$SCRATCH/lastx" \
    && red "И2: легальная замена r1 (открытое окно 006) красит «вне зоны» в форме $form"
  grep -qxF "$(vne "$SHA_P3" registry/contracts.tsv)" "$SCRATCH/lastx" \
    || red "И5: боковая замена p3 не красна в форме $form — блокер B (049) ослаблен"
  grep -qxF "$(mint_named "$SHA_P2")" "$SCRATCH/lastx" \
    || red "И3: именованный FAIL двери минта на p2 отсутствует в форме $form"
  grep -qxF "$(vne "$SHA_P2" registry/contracts.tsv)" "$SCRATCH/lastx" \
    && red "И3: p2 ушла из двери минта в «вне зоны» (форма $form)"
done

# ── 3. Стаб-пак: каждый обман пойман на своём входе ───────────────────────────
printf 'стаб-пак:\n'
caught=0; total=0
for s in s1 s2; do
  total=$((total + 1))
  if ! make_stub_$s; then
    red "стаб $s не построен: структурный якорь снесён реализацией (Н-39)"
    continue
  fi
  run_gate "$SCRATCH/gates/$s/check_zones.sh" fx M-nomain
  if grep -qxF "$(vne "$SHA_P3" registry/contracts.tsv)" "$SCRATCH/lastx"; then
    red "стаб $s жив: p3 всё ещё красна — привязка не различима (Н-39)"
  else
    printf '  стаб %s пойман: боковая замена p3 пропущена стабом\n' "$s"
    caught=$((caught + 1))
  fi
done
make_stub_s3; total=$((total + 1))
run_gate "$SCRATCH/gates/s3/check_zones.sh" fx M-nomain
if grep -qxF "$(mint_named "$SHA_P2")" "$SCRATCH/lastx"; then
  red 'стаб s3 жив: дверь минта всё ещё красит p2 (Н-39)'
else
  printf '  стаб s3 пойман: неграмотная дельта p2 ушла из суда\n'
  caught=$((caught + 1))
fi
make_stub_s4; total=$((total + 1))
run_gate "$SCRATCH/gates/s4/check_zones.sh" fx M-nomain
if grep -qxF "$(vne "$SHA_T1" scripts/trap_073.sh)" "$SCRATCH/lastx"; then
  printf '  стаб s4 пойман: ловушка зазора t1 внесена в суд\n'
  caught=$((caught + 1))
else
  red 'стаб s4 жив: закрытые окна не вскрылись стабом (Н-39)'
fi
[ "$caught" -eq "$total" ] || red 'стаб-пак неполон'

# ── 4. FIXSIM (А-318): throwaway-правка обязана дать полное зелёное ──────────
if [ "${FIXSIM:-0}" = "1" ]; then
  printf 'FIXSIM: симуляция честной правки (throwaway, вне дерева):\n'
  FS="$SCRATCH/gates/fixsim/check_zones.sh"
  for form in $FORMS; do
    run_gate "$FS" fx2 "$form"; rc=$?
    [ "$rc" -eq 0 ] || red "FIXSIM/fx2: rc=$rc в форме $form — «ветка rc 0 ∧ merge rc 0» не достигнуто симуляцией"
    [ -s "$SCRATCH/lastx" ] && red "FIXSIM/fx2: FAIL-строки в форме $form остались"
  done
  for form in $FORMS; do
    run_gate "$FS" fx "$form"; rc=$?
    [ "$rc" -eq 1 ] || red "FIXSIM/fx: rc=$rc в форме $form — пробы p2/p3 обязаны красить"
    grep -qxF "$(vne "$SHA_P3" registry/contracts.tsv)" "$SCRATCH/lastx" \
      || red "FIXSIM/fx: p3 признана в форме $form — симуляция ослабила блокер B (049)"
    grep -qxF "$(mint_named "$SHA_P2")" "$SCRATCH/lastx" \
      || red "FIXSIM/fx: дверь минта замолчала на p2 (форма $form)"
    grep -qxF "$(vne "$SHA_T1" scripts/trap_073.sh)" "$SCRATCH/lastx" \
      && red "FIXSIM/fx: ловушка t1 судится (форма $form)"
    grep -qxF "$(vne "$SHA_F2" registry/contracts.tsv)" "$SCRATCH/lastx" \
      && red "FIXSIM/fx: f2 красна (форма $form)"
    grep -qxF "$(vne "$SHA_R1" registry/contracts.tsv)" "$SCRATCH/lastx" \
      && red "FIXSIM/fx: r1 красна (форма $form)"
  done
fi

printf 'итог 073: красных клеток=%d стабы=%d/%d\n' "$fails" "$caught" "$total"
[ "$fails" -eq 0 ] || exit 1
exit 0
