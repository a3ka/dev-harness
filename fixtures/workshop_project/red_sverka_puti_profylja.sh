#!/usr/bin/env bash
# 059-БАТАРЕЯ — workshop_project (контракт 059, IV-1а: сверка объявленного
# пути профиля ci.workflow с деревом репо; боль Б-4 пилота ODX-STK-001).
#
# Переносная форма семьи (прецедент 054/055/058). Структура:
#   1. СТАБ-ПАК (9 ручек обмана) — зелёный ДО и ПОСЛЕ реализации: каждый
#      обманный стаб умирает на СВОЕЙ клетке (привязка по коду, Н-39).
#   2. ЧЕСТНАЯ ЧАСТЬ (к1..к17) — красная ДО реализации (предмет отсутствует:
#      резолвер HEAD не сверяет объявление с деревом), зелёная ПОСЛЕ.
# Ожидание каждой клетки — ПАРА (rc, класс stdout): отказ = rc 1 И stdout
# ПУСТ (И-4: ранняя печать merged до отказа неразличима без проверки
# пустоты); успех = rc 0 И stdout НЕпуст (merged напечатан).
# Усиление пост-заморозки (вердикт адверсария 059-к1, прецедент 005): к13..к16 —
# честные входы грамматики И-2 (внутренний .., unicode, кавычка, внутренний
# symlink), к17 — live-зеркало к9 (И-5: сверка работает и БЕЗ --probe);
# отказные клетки несут ровно одну P-строку stderr (И-3).
#
# Прогон: bash red_sverka_puti_profylja.sh [корень worktree]
#   rc 0 — стаб-пак пойман весь, диффпроба чиста И честные клетки зелёные.
#   rc 1 — расхождение (на HEAD ожидаемо и ДОКАЗЫВАЕТ боль Б-4).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
PROFILE_RESOLVER="${PROFILE_RESOLVER:-$ROOT/scripts/profile_resolver.sh}"
WORKSHOP="${WORKSHOP:-$ROOT/workshop}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
die_pack() { printf '059-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }
[ -f "$PROFILE_RESOLVER" ] || die_pack "нет резолвера: $PROFILE_RESOLVER"
[ -f "$WORKSHOP" ] || die_pack "нет workshop: $WORKSHOP"
command -v git >/dev/null 2>&1 || die_pack "нет git"
command -v jq >/dev/null 2>&1 || die_pack "нет jq"
command -v readlink >/dev/null 2>&1 || die_pack "нет readlink"
command -v mkfifo >/dev/null 2>&1 || die_pack "нет mkfifo"

# Ложные зелёные от протекающего окружения (прецедент 058:67).
unset HARNESS_SESSION_HOME HARNESS_SCRATCH METERING_PROJECT METERING_ROLE

# ── строители toy-мира ────────────────────────────────────────────────────────
# $3 = фрагмент JSON ветви ci ("" = ветвь не объявлена).
layer_make() { # $1=корень слоя $2=projectId $3=ci-фрагмент
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"%s","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git@host:p1.git"}%s,"barriers":{"mandatory":["check_zones"],"optional":[]}}}' "$2" "$3" > "$1/registry/harness-project.json"
}
layer_min() { # слой БЕЗ defaults вовсе (схема 054: defaults — optional)
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1"}' > "$1/registry/harness-project.json"
}
repo_make() { # $1=корень репо $2=repoId $3=ci-фрагмент $4=git(1|0)
  local r="$1"
  mkdir -p "$r/config"
  [ "${4:-1}" = "1" ] && { git -C "$r" init -q; git -C "$r" config receive.denyCurrentBranch refuse; }
  printf '{"schemaVersion":1,"repoId":"%s","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"}%s,"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' "$2" "$3" > "$r/harness.project.json"
  printf '{"version":"v10"}\n' > "$r/config/harness_pin.json"
  printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$r/.env"
}
CI_YML=',"ci":{"workflow":".github/workflows/ci.yml"}'
DOTDOT_YML=',"ci":{"workflow":"ci/../ci.yml"}'
UNI_YML=',"ci":{"workflow":"ci/ü.yml"}'
QUOTE_YML=',"ci":{"workflow":"ci/'"'"'quoted'"'"'.yml"}'
LINK_YML=',"ci":{"workflow":"ci/link.yml"}'
wf_make() { mkdir -p "$(dirname -- "$1")"; printf 'name: toy ci\n' > "$1"; }

# ── прогонщики ────────────────────────────────────────────────────────────────
resolve() { # $1=резолвер $2=репо $3=слой $4=выход stderr $5=выход stdout; rc наружу
  env HARNESS_PROJECT_LAYER_ROOT="$3" bash "$1" --repo "$2" > "$5" 2>"$4"
}

# ══════════════════════════════════════════════════════════════════════════════
# СТАБ-ПАК: обманный стаб-резолвер; обманывает ровно одной ручкой STUB_*.
# Без ручек честен на всех сценариях (диффпроба). Клетки стаб-пака НЕ зависят
# от честного кода — зелёны ДО и ПОСЛЕ реализации (прецедент 045/054/058).
# ══════════════════════════════════════════════════════════════════════════════
STUB="$WORK/stub-resolver"
cat > "$STUB" <<'STUBEOF'
#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ резолвера 059: без ручек честен на всех сценариях батареи;
# ровно одна ручка STUB_* обманывает (и умирает на своей клетке). Реализацией
# НЕ является. Литералы отказов — байт-в-байт из контракта 059 (И-3): стаб и
# честная реализация различимы только ручкой, не текстом отказа.
set -uo pipefail
repo=""; layer="${HARNESS_PROJECT_LAYER_ROOT:?}"
while [ $# -gt 0 ]; do case "$1" in
  --repo) repo="$2"; shift 2 ;;
  *) shift ;;
esac; done
repo="$(cd "$repo" && pwd -P)"
rj="$repo/harness.project.json"; pj="$layer/registry/harness-project.json"
cw="$(jq -r '.ci.workflow // empty' "$rj" 2>/dev/null)"
if [ -z "$cw" ] && [ -z "${STUB_REPO_ONLY:-}" ]; then
  cw="$(jq -r '.defaults.ci.workflow // empty' "$pj" 2>/dev/null)"
fi
emit_merged() { printf '{"ci":{"value":{"workflow":"%s"},"origin":"repo"}}\n' "$cw"; }
if [ -z "$cw" ] || [ -n "${STUB_NO_CHECK:-}" ]; then emit_merged; exit 0; fi
# Ручка STUB_EARLY_PRINT (контрмодель И-4): печать merged ДО сверки — на
# отказных входах stdout НЕпуст при честных rc/stderr.
if [ -n "${STUB_EARLY_PRINT:-}" ]; then emit_merged; fi
die() { printf 'profile ОТКАЗ: %s\n' "$1" >&2; exit 1; }
# Ручка STUB_ALL_DECL (контрмодель И-1): сверяет ВСЕ объявленные значения
# обоих слоёв, а не только ЭФФЕКТИВНОЕ — отказывает на перекрытом
# отсутствующем project-пути при существующем эффективном repo-пути.
if [ -n "${STUB_ALL_DECL:-}" ]; then
  pcw="$(jq -r '.defaults.ci.workflow // empty' "$pj" 2>/dev/null)"
  if [ -n "$pcw" ] && [ "$pcw" != "$cw" ]; then
    pcanon="$(readlink -f -- "$repo/$pcw" 2>/dev/null || true)"
    [ -n "$pcanon" ] && [ -f "$pcanon" ] || die "объявленный путь отсутствует в дереве репо: ci.workflow=$pcw от корня $repo"
  fi
fi
case "$cw" in
  /*) if [ -n "${STUB_ABS_OK:-}" ] && [ -e "$cw" ]; then emit_merged; exit 0; fi
      die "ci.workflow обязан быть относительным путём от корня репо, получен абсолютный: <$cw>" ;;
esac
joined="$repo/$cw"
if [ -n "${STUB_NO_CANON:-}" ]; then
  [ -f "$joined" ] || die "объявленный путь отсутствует в дереве репо: ci.workflow=$cw от корня $repo"
  emit_merged; exit 0
fi
canon="$(readlink -f -- "$joined" 2>/dev/null || true)"
if [ -n "${STUB_ESCAPE_OK:-}" ]; then
  [ -e "$joined" ] || die "объявленный путь отсутствует в дереве репо: ci.workflow=$cw от корня $repo"
  emit_merged; exit 0
fi
[ -n "$canon" ] && [ -e "$canon" ] || die "объявленный путь отсутствует в дереве репо: ci.workflow=$cw от корня $repo"
case "$canon" in
  "$repo"/*) ;;
  *) die "ci.workflow выходит за корень репо после канонизации: $cw -> $canon вне $repo" ;;
esac
if [ -n "${STUB_DIR_OK:-}" ]; then
  [ -e "$canon" ] || die "объявленный путь отсутствует в дереве репо: ci.workflow=$cw от корня $repo"
  emit_merged; exit 0
fi
# Ручка STUB_NOT_DIR (контрмодель И-2(г), арбитраж 059-к3 9e874be п.3):
# предикат «не каталог» вместо «регулярного файла» — на FIFO (существует и
# не каталог) пропускает объявление, печатая merged вопреки отказу «не файл».
if [ -n "${STUB_NOT_DIR:-}" ]; then
  [ ! -d "$canon" ] || die "объявленный путь не файл: ci.workflow=$cw"
else
  [ -f "$canon" ] || die "объявленный путь не файл: ci.workflow=$cw"
fi
emit_merged; exit 0
STUBEOF
chmod +x "$STUB"

# Сценарии стаб-пака (те же входы, что у честных клеток; печатают "репо\nслой").
scn_k1() { local L="$WORK/s1-layer" R="$WORK/s1-repo"; layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 0; printf '%s\n%s\n' "$R" "$L"; }
scn_k2() { local L="$WORK/s2-layer" R="$WORK/s2-repo"; layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "" 0; printf '%s\n%s\n' "$R" "$L"; }
scn_k3() { local L="$WORK/s3-layer" R="$WORK/s3-repo"; layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 0; wf_make "$R/.github/workflows/ci.yml"; printf '%s\n%s\n' "$R" "$L"; }
scn_k4() { local L="$WORK/s4-layer" R="$WORK/s4-repo"; layer_make "$L" p1 ',"ci":{"workflow":"/etc/hostname"}'; repo_make "$R" r1 ',"ci":{"workflow":"/etc/hostname"}' 0; printf '%s\n%s\n' "$R" "$L"; }
scn_k5() { local L="$WORK/s5-layer" R="$WORK/s5/repo"; mkdir -p "$WORK/s5"; printf 'x: 1\n' > "$WORK/escape.yml"; layer_make "$L" p1 ',"ci":{"workflow":"../../escape.yml"}'; repo_make "$R" r1 ',"ci":{"workflow":"../../escape.yml"}' 0; printf '%s\n%s\n' "$R" "$L"; }
scn_k6() { local L="$WORK/s6-layer" R="$WORK/s6/repo" T="$WORK/s6/outside.yml"; mkdir -p "$WORK/s6"; printf 'x: 1\n' > "$T"; layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 0; mkdir -p "$R/.github/workflows"; rm -f -- "$R/.github/workflows/ci.yml"; ln -s -- "$T" "$R/.github/workflows/ci.yml"; printf '%s\n%s\n' "$R" "$L"; }
scn_k7() { local L="$WORK/s7-layer" R="$WORK/s7-repo"; layer_make "$L" p1 ',"ci":{"workflow":"ci"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci"}' 0; mkdir -p "$R/ci"; printf '%s\n%s\n' "$R" "$L"; }
scn_k8() { local L="$WORK/s8-layer" R="$WORK/s8-repo"; layer_min "$L"; repo_make "$R" r1 "" 0; printf '%s\n%s\n' "$R" "$L"; }
scn_k10() { local L="$WORK/s10-layer" R="$WORK/s10-repo"; layer_make "$L" p1 ',"ci":{"workflow":"ci/obsolete.yml"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci/repo.yml"}' 0; wf_make "$R/ci/repo.yml"; printf '%s\n%s\n' "$R" "$L"; }
scn_k11() { local L="$WORK/s11-layer" R="$WORK/s11-repo"; layer_make "$L" p1 ',"ci":{"workflow":"ci/exists.yml"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci/missing.yml"}' 0; wf_make "$R/ci/exists.yml"; printf '%s\n%s\n' "$R" "$L"; }
scn_k12() { local L="$WORK/s12-layer" R="$WORK/s12-repo"; layer_make "$L" p1 ',"ci":{"workflow":"ci/pipe"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci/pipe"}' 0; mkdir -p "$R/ci"; rm -f -- "$R/ci/pipe"; mkfifo -- "$R/ci/pipe"; printf '%s\n%s\n' "$R" "$L"; }
scn_k13() { local L="$WORK/s13-layer" R="$WORK/s13-repo"; layer_make "$L" p1 "$DOTDOT_YML"; repo_make "$R" r1 "$DOTDOT_YML" 0; mkdir -p "$R/ci"; wf_make "$R/ci.yml"; printf '%s\n%s\n' "$R" "$L"; }
scn_k14() { local L="$WORK/s14-layer" R="$WORK/s14-repo"; layer_make "$L" p1 "$UNI_YML"; repo_make "$R" r1 "$UNI_YML" 0; wf_make "$R/ci/ü.yml"; printf '%s\n%s\n' "$R" "$L"; }
scn_k15() { local L="$WORK/s15-layer" R="$WORK/s15-repo"; layer_make "$L" p1 "$QUOTE_YML"; repo_make "$R" r1 "$QUOTE_YML" 0; wf_make "$R/ci/'quoted'.yml"; printf '%s\n%s\n' "$R" "$L"; }
scn_k16() { local L="$WORK/s16-layer" R="$WORK/s16-repo"; layer_make "$L" p1 "$LINK_YML"; repo_make "$R" r1 "$LINK_YML" 0; wf_make "$R/ci/real.yml"; ln -s -- real.yml "$R/ci/link.yml"; printf '%s\n%s\n' "$R" "$L"; }

stub_run() { # $1=сценарий $2=stdout-файл → rc стаба (ручки из окружения)
  local io R L e rc
  io="$($1)"; R="${io%%$'\n'*}"; L="${io#*$'\n'}"
  e="$WORK/stub-run.err"; : > "$e"; : > "$2"
  rc=0; env HARNESS_PROJECT_LAYER_ROOT="$L" bash "$STUB" --repo "$R" >"$2" 2>"$e" || rc=$?
  return "$rc"
}
expect_pair() { # $1=rc $2=stdout-файл $3=ожидание (1=отказ, 0=успех) → rc 0 = соответствие
  if [ "$3" -eq 1 ]; then [ "$1" -eq 1 ] && [ ! -s "$2" ]
  else [ "$1" -eq 0 ] && [ -s "$2" ]; fi
}
one_p_line() { # $1=stderr-файл → rc 0 ⟺ ровно ОДНА строка И она класса «profile ОТКАЗ: » (И-3)
  [ "$(grep -c '' "$1")" -eq 1 ] && grep -q '^profile ОТКАЗ: ' "$1"
}

# Диффпроба: стаб БЕЗ ручек обязан вести себя как честная реализация на всех
# пятнадцати сценариях (rc И класс stdout; иначе стаб-пак ничего не доказывает).
diff_fail=0
scn_check() { # $1=сценарий $2=ожидание (1=отказ, 0=успех)
  local o rc; o="$WORK/diff-$1.out"
  stub_run "$1" "$o"; rc=$?
  expect_pair "$rc" "$o" "$2" || { diff_fail=$((diff_fail+1)); printf 'диффпроба %s: стаб без ручек нечестен (rc=%s stdout=%s, ожидание %s)\n' "$1" "$rc" "$([ -s "$o" ] && printf непуст || printf пуст)" "$2" >&2; }
}
scn_check scn_k1 1
scn_check scn_k2 1
scn_check scn_k3 0
scn_check scn_k4 1
scn_check scn_k5 1
scn_check scn_k6 1
scn_check scn_k7 1
scn_check scn_k8 0
scn_check scn_k10 0
scn_check scn_k11 1
scn_check scn_k12 1
scn_check scn_k13 0
scn_check scn_k14 0
scn_check scn_k15 0
scn_check scn_k16 0

# Клетки стаб-пака: обман ручкой ОБЯЗАН быть различим на её сценарии —
# стаб с ручкой ведёт себя НЕ как ожидание клетки → обман пойман (стаб
# «умер»). Совпадение с ожиданием = батарея слепа к ручке (ПРОСКОК).
stub_total=0; stub_caught_n=0
knob_cell() { # $1=клетка $2=ручка $3=сценарий $4=ожидание честного поведения
  stub_total=$((stub_total+1))
  local io R L e o rc
  io="$($3)"; R="${io%%$'\n'*}"; L="${io#*$'\n'}"
  e="$WORK/knob-$1.err"; o="$WORK/knob-$1.out"; : > "$e"; : > "$o"
  rc=0; env "$2=1" HARNESS_PROJECT_LAYER_ROOT="$L" bash "$STUB" --repo "$R" >"$o" 2>"$e" || rc=$?
  if expect_pair "$rc" "$o" "$4"; then
    printf 'стаб-клетка %s: ПРОСКОК — ручка %s не различима (батарея слепа)\n' "$1" "$2" >&2
  else
    stub_caught_n=$((stub_caught_n+1)); printf 'стаб-клетка %s: ПОЙМАН (ручка %s)\n' "$1" "$2" >&2
  fi
}
knob_cell s1 STUB_NO_CHECK   scn_k1  1
knob_cell s2 STUB_REPO_ONLY  scn_k2  1
knob_cell s3 STUB_ABS_OK     scn_k4  1
knob_cell s4 STUB_NO_CANON   scn_k6  1
knob_cell s5 STUB_ESCAPE_OK  scn_k5  1
knob_cell s6 STUB_DIR_OK     scn_k7  1
knob_cell s7 STUB_EARLY_PRINT scn_k1 1
knob_cell s8 STUB_ALL_DECL   scn_k10 0
knob_cell s9 STUB_NOT_DIR  scn_k12 1

# ══════════════════════════════════════════════════════════════════════════════
# ЧЕСТНЫЕ КЛЕТКИ: живой резолвер/workshop HEAD. Каждая клетка красна СВОИМ
# предъявлением (Н-39: объединённая клетка не зачитывается по первой точке).
# Отказные клетки несут и пустоту stdout (И-4) И ровно одну P-строку stderr (И-3).
# ══════════════════════════════════════════════════════════════════════════════
honest_fail=0; honest_total=0
hcell() { # $1=имя $2=функция-проверка (rc 0 = зелено)
  honest_total=$((honest_total+1))
  if "$2"; then printf 'честная %s: ЗЕЛЕНАЯ\n' "$1" >&2
  else honest_fail=$((honest_fail+1)); printf 'честная %s: КРАСНАЯ\n' "$1" >&2; fi
}

hk1() { # отсутствует, происхождение repo; отказ атомарлен (stdout пуст)
  local L="$WORK/hk1-layer" R="$WORK/hk1-repo" E="$WORK/hk1.err" O="$WORK/hk1.out" rc
  layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 0
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'объявленный путь отсутствует в дереве репо: ci.workflow=' "$E" \
    && grep -Fq '.github/workflows/ci.yml' "$E" && one_p_line "$E"
}
hk2() { # отсутствует, происхождение project (defaults.ci); stdout пуст
  local L="$WORK/hk2-layer" R="$WORK/hk2-repo" E="$WORK/hk2.err" O="$WORK/hk2.out" rc
  layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "" 0
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'объявленный путь отсутствует в дереве репо: ci.workflow=' "$E" && one_p_line "$E"
}
hk3() { # объявлен и есть → rc 0, merged несёт значение дословно, stdout непуст
  local L="$WORK/hk3-layer" R="$WORK/hk3-repo" E="$WORK/hk3.err" O="$WORK/hk3.out" rc
  layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 0
  wf_make "$R/.github/workflows/ci.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 0 ] && [ -s "$O" ] && [ "$(jq -r '.ci.value.workflow' "$O")" = ".github/workflows/ci.yml" ]
}
hk4() { # абсолютный путь (файл существует вне дерева); stdout пуст
  local L="$WORK/hk4-layer" R="$WORK/hk4-repo" E="$WORK/hk4.err" O="$WORK/hk4.out" rc
  layer_make "$L" p1 ',"ci":{"workflow":"/etc/hostname"}'; repo_make "$R" r1 ',"ci":{"workflow":"/etc/hostname"}' 0
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'обязан быть относительным' "$E" && grep -Fq '/etc/hostname' "$E" && one_p_line "$E"
}
hk5() { # ../../-побег: файл существует ВНЕ репо; stdout пуст
  local L="$WORK/hk5-layer" R="$WORK/hk5/repo" E="$WORK/hk5.err" O="$WORK/hk5.out" rc
  mkdir -p "$WORK/hk5"; printf 'x: 1\n' > "$WORK/escape.yml"
  layer_make "$L" p1 ',"ci":{"workflow":"../../escape.yml"}'; repo_make "$R" r1 ',"ci":{"workflow":"../../escape.yml"}' 0
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'выходит за корень репо' "$E" && one_p_line "$E"
}
hk6() { # симлинк внутри репа на цель вне репо; stdout пуст
  local L="$WORK/hk6-layer" R="$WORK/hk6/repo" E="$WORK/hk6.err" O="$WORK/hk6.out" T="$WORK/hk6/outside.yml" rc
  mkdir -p "$WORK/hk6"; printf 'x: 1\n' > "$T"
  layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 0
  mkdir -p "$R/.github/workflows"; rm -f -- "$R/.github/workflows/ci.yml"; ln -s -- "$T" "$R/.github/workflows/ci.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'выходит за корень репо' "$E" && one_p_line "$E"
}
hk7() { # на месте объявления — каталог; stdout пуст
  local L="$WORK/hk7-layer" R="$WORK/hk7-repo" E="$WORK/hk7.err" O="$WORK/hk7.out" rc
  layer_make "$L" p1 ',"ci":{"workflow":"ci"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci"}' 0
  mkdir -p "$R/ci"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'не файл' "$E" && one_p_line "$E"
}
hk8() { # ci не объявлен нигде → rc 0, merged напечатан (не объявлено — не судимо)
  local L="$WORK/hk8-layer" R="$WORK/hk8-repo" E="$WORK/hk8.err" O="$WORK/hk8.out" rc
  layer_min "$L"; repo_make "$R" r1 "" 0
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 0 ] && [ -s "$O" ] && [ ! -s "$E" ]
}
hk9() { # живой workshop --probe: отказ проксирован (И-11) И ни одной структуры
  local L="$WORK/hk9-layer" R="$WORK/hk9-repo" E="$WORK/hk9.err" B="$WORK/hk9-base" rc
  layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 1
  mkdir -p "$B"
  rc=0; env XDG_STATE_HOME="$B" HARNESS_PROJECT_LAYER_ROOT="$L" bash "$WORKSHOP" --probe "$R" >/dev/null 2>"$E" || rc=$?
  [ "$rc" -eq 1 ] && grep -Fq 'ci.workflow' "$E" \
    && grep -Fq 'объявленный путь отсутствует в дереве репо' "$E" \
    && [ ! -e "$B/dev-harness-projects/p1" ]
}
hk10() { # перекрытие: эффективный repo-путь существует, перекрытый project-путь
         # отсутствует → rc 0, merged = repo-значение (И-1: сверяется ЭФФЕКТИВНОЕ
         # значение; реализация, судящая оба объявления, здесь отказывает)
  local L="$WORK/hk10-layer" R="$WORK/hk10-repo" E="$WORK/hk10.err" O="$WORK/hk10.out" rc
  layer_make "$L" p1 ',"ci":{"workflow":"ci/obsolete.yml"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci/repo.yml"}' 0
  wf_make "$R/ci/repo.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 0 ] && [ "$(jq -r '.ci.value.workflow' "$O")" = "ci/repo.yml" ]
}
hk11() { # зеркало перекрытия: эффективный repo-путь отсутствует, project-путь
         # существует → rc 1 называет repo-значение (существование project-пути
         # не спасает); stdout пуст
  local L="$WORK/hk11-layer" R="$WORK/hk11-repo" E="$WORK/hk11.err" O="$WORK/hk11.out" rc
  layer_make "$L" p1 ',"ci":{"workflow":"ci/exists.yml"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci/missing.yml"}' 0
  wf_make "$R/ci/exists.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'объявленный путь отсутствует в дереве репо: ci.workflow=' "$E" \
    && grep -Fq 'ci/missing.yml' "$E" && ! grep -Fq 'ci/exists.yml' "$E" && one_p_line "$E"
}
hk12() { # на месте объявления — FIFO (mkfifo); stdout пуст (И-2(г): предикат -f,
         # арбитраж 059-к3 9e874be п.2 — «не каталог» здесь НЕ отказ)
  local L="$WORK/hk12-layer" R="$WORK/hk12-repo" E="$WORK/hk12.err" O="$WORK/hk12.out" rc
  layer_make "$L" p1 ',"ci":{"workflow":"ci/pipe"}'; repo_make "$R" r1 ',"ci":{"workflow":"ci/pipe"}' 0
  mkdir -p "$R/ci"; mkfifo -- "$R/ci/pipe"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 1 ] && [ ! -s "$O" ] && grep -Fq 'не файл' "$E" && one_p_line "$E"
}
hk13() { # к13 (059-к1 A): внутренний компонент «..» — ci/../ci.yml, файл и
         # ПРОМЕЖУТОЧНЫЙ каталог ci существуют (readlink -f разрешает только
         # существующие промежуточные компоненты — И-2(б)), канонизация внутри
         # репо → rc 0 И merged ДОСЛОВНО «ci/../ci.yml» (грамматика И-2 не
         # сужается до плоских путей; мутант-отказчик ловится здесь)
  local L="$WORK/hk13-layer" R="$WORK/hk13-repo" E="$WORK/hk13.err" O="$WORK/hk13.out" rc
  layer_make "$L" p1 "$DOTDOT_YML"; repo_make "$R" r1 "$DOTDOT_YML" 0
  mkdir -p "$R/ci"; wf_make "$R/ci.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 0 ] && [ -s "$O" ] && [ "$(jq -r '.ci.value.workflow' "$O")" = "ci/../ci.yml" ]
}
hk14() { # к14 (059-к1 B): unicode-компонент ci/ü.yml — реальный файл → rc 0 И
         # точное значение merged (представление пути не сужается до ASCII)
  local L="$WORK/hk14-layer" R="$WORK/hk14-repo" E="$WORK/hk14.err" O="$WORK/hk14.out" rc
  layer_make "$L" p1 "$UNI_YML"; repo_make "$R" r1 "$UNI_YML" 0
  wf_make "$R/ci/ü.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 0 ] && [ -s "$O" ] && [ "$(jq -r '.ci.value.workflow' "$O")" = "ci/ü.yml" ]
}
hk15() { # к15 (059-к1 B): символ одинарной кавычки в имени ci/'quoted'.yml —
         # реальный файл → rc 0 И точное значение merged (алфавит байта не сужается)
  local L="$WORK/hk15-layer" R="$WORK/hk15-repo" E="$WORK/hk15.err" O="$WORK/hk15.out" rc
  layer_make "$L" p1 "$QUOTE_YML"; repo_make "$R" r1 "$QUOTE_YML" 0
  wf_make "$R/ci/'quoted'.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 0 ] && [ -s "$O" ] && [ "$(jq -r '.ci.value.workflow' "$O")" = "ci/'quoted'.yml" ]
}
hk16() { # к16 (059-к1 C): симлинк ВНУТРИ репо на регулярный файл внутри
         # (ci/link.yml -> real.yml): канонизация не покидает репо → rc 0 И merged
         # «ci/link.yml» дословно (запрещён только симлинк НАРУЖУ — к6)
  local L="$WORK/hk16-layer" R="$WORK/hk16-repo" E="$WORK/hk16.err" O="$WORK/hk16.out" rc
  layer_make "$L" p1 "$LINK_YML"; repo_make "$R" r1 "$LINK_YML" 0
  wf_make "$R/ci/real.yml"; ln -s -- real.yml "$R/ci/link.yml"
  resolve "$PROFILE_RESOLVER" "$R" "$L" "$E" "$O"; rc=$?
  [ "$rc" -eq 0 ] && [ -s "$O" ] && [ "$(jq -r '.ci.value.workflow' "$O")" = "ci/link.yml" ]
}
hk17() { # к17 (059-к1 D): live-зеркало к9 БЕЗ --probe — та же семантика сверки
         # (И-5): некорректный ci.workflow → rc 1, отказ резолвера в stderr,
         # ни одной структуры. Live сверяет пин с omp --version (workshop:614) —
         # на PATH фейковый omp/v10 под пин toy-репо, как в прогонах адверсария.
  local L="$WORK/hk17-layer" R="$WORK/hk17-repo" E="$WORK/hk17.err" B="$WORK/hk17-base" FB="$WORK/hk17-bin" rc
  layer_make "$L" p1 "$CI_YML"; repo_make "$R" r1 "$CI_YML" 1
  mkdir -p "$B" "$FB"; printf '#!/usr/bin/env bash\necho omp/v10\n' > "$FB/omp"; chmod +x -- "$FB/omp"
  rc=0; env PATH="$FB:$PATH" XDG_STATE_HOME="$B" HARNESS_PROJECT_LAYER_ROOT="$L" bash "$WORKSHOP" "$R" >/dev/null 2>"$E" || rc=$?
  [ "$rc" -eq 1 ] && grep -Fq 'ci.workflow' "$E" \
    && grep -Fq 'объявленный путь отсутствует в дереве репо' "$E" \
    && [ ! -e "$B/dev-harness-projects/p1" ]
}

hcell к1 hk1
hcell к2 hk2
hcell к3 hk3
hcell к4 hk4
hcell к5 hk5
hcell к6 hk6
hcell к7 hk7
hcell к8 hk8
hcell к9 hk9
hcell к10 hk10
hcell к11 hk11
hcell к12 hk12
hcell к13 hk13
hcell к14 hk14
hcell к15 hk15
hcell к16 hk16
hcell к17 hk17

printf 'итог 059-батареи: стаб-пак %s/%s пойман, диффпроба ошибок %s, честные %s/%s зелёные\n' \
  "$stub_caught_n" "$stub_total" "$diff_fail" "$((honest_total-honest_fail))" "$honest_total" >&2
[ "$stub_caught_n" -eq "$stub_total" ] && [ "$diff_fail" -eq 0 ] && [ "$honest_fail" -eq 0 ]
