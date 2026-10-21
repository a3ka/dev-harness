#!/usr/bin/env bash
# Контракт 122 «CI проекта» — красная батарея (зона architect).
# Субъекты: scripts/gen_project_workflow.sh (Г1), scripts/ci_preflight.sh (Г2),
# scripts/check_predposylki.sh (Г3). Без ключей — судит НАСТОЯЩЕЕ дерево харнесса
# (сегодня красное: субъектов нет); --model — самодостаточная честная модель
# (миры в /tmp/dev-harness-verify, без сети/docker/эмулятора).
# Замкнутый алфавит причин (16): manifest-otsutstvuet manifest-nevaliden profil-otsutstvuet
# profil-rashozhdenie workflow-otsutstvuet workflow-ruchnoj gen-nedeterminirovan
# yaml-nevaliden working-directory-otsutstvuet shag-upal sekrety-ne-perechisleny
# predposylki-otsutstvuyut predposylki-nevaliden sekrety-ne-zavedeny gh-nedostupen
# python-yaml-nedostupen (средовая ветвь rc 2, клеткой не покрыта).
# Обманные стабы подключаются env: CI_PROEKTA_122_GEN / _PREFLIGHT / _GATES.
set -u
export PYTHONDONTWRITEBYTECODE=1
BATT=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$BATT/../../.." && pwd)
WORLDS=/tmp/dev-harness-verify/ci122
mkdir -p "$WORLDS"
RUNDIR=$(mktemp -d "$WORLDS/run-XXXX") || exit 2
trap 'rm -rf "$RUNDIR"' EXIT

MODE=red; CELL=
while [ $# -gt 0 ]; do
  case "$1" in
    --model) MODE=model ;;
    --cell) CELL=$2; shift ;;
    *) printf 'ci122 ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done
if [ "$MODE" = model ]; then
  GEN=${CI_PROEKTA_122_GEN:-$BATT/model/gen_project_workflow.sh}
  PRE=${CI_PROEKTA_122_PREFLIGHT:-$BATT/model/ci_preflight.sh}
  GATE=${CI_PROEKTA_122_GATES:-$BATT/model/check_predposylki.sh}
else
  GEN=${CI_PROEKTA_122_GEN:-$REPO/scripts/gen_project_workflow.sh}
  PRE=${CI_PROEKTA_122_PREFLIGHT:-$REPO/scripts/ci_preflight.sh}
  GATE=${CI_PROEKTA_122_GATES:-$REPO/scripts/check_predposylki.sh}
fi

GREEN=0; RED=0
new_world() {
  local W
  W=$(mktemp -d "$RUNDIR/world-XXXX") || exit 2
  mkdir -p "$W/.harness" "$W/.github/workflows" "$W/bin" "$W/mobile/.maestro" "$W/contracts"
  printf '%s\n' '{"schemaVersion":1,"projectId":"complior-toy","repoId":"complior-toy","language":"node"}' > "$W/.harness/harness.project.json"
  cat > "$W/.harness/ci.json" <<'J'
{"schemaVersion":1,"projectId":"complior-toy","jobs":{
"ci":{"class":"local","workdir":".","steps":[{"key":"lint","run":"test -f package.json"},{"key":"gotov","run":"echo predpolet-ok"}]},
"e2e":{"class":"station","workdir":"mobile","steps":[{"key":"maestro","run":"ls .maestro/vkhod.yaml"}]}}}
J
  printf '{}\n' > "$W/package.json"
  printf 'flows: []\n' > "$W/mobile/.maestro/vkhod.yaml"
  cat > "$W/contracts/kontrakt-ci.md" <<'K'
# Той-контракт с CI-зоной без предпосылок
ЗОНА implementer: .github/workflows/mobile.yml mobile/
K
  cat > "$W/contracts/kontrakt-predposylki.md" <<'K'
# Той-контракт с предпосылками
ЗОНА implementer: .github/workflows/ci.yml
ПРЕДПОСЫЛКИ:
- secret PILOT_DEMO_CODE
- variable NPM_TOKEN
- environment prod
- setting branch-protection
K
  cat > "$W/contracts/kontrakt-bez-ci.md" <<'K'
# Той-контракт без CI
ЗОНА implementer: docs/
K
  cat > "$W/contracts/kontrakt-nevalid.md" <<'K'
# Той-контракт с внеграмматным пунктом
ЗОНА implementer: .github/workflows/ci.yml
ПРЕДПОСЫЛКИ:
- password Sekret
K
  cat > "$W/gh.tsv" <<'G'
secret PILOT_DEMO_CODE
secret DRUGOJ
variable NPM_TOKEN
G
  cat > "$W/bin/gh" <<'GH'
#!/usr/bin/env bash
# Фикстурный gh: обслуживает `gh <secret|variable> list -R <url>` из gh.tsv рядом с собой.
D=$(cd "$(dirname "$0")/.." && pwd)
[ "$1" = secret ] || [ "$1" = variable ] || { printf 'gh-fixtura: neponjatnyj zapros\n' >&2; exit 7; }
awk -v t="$1" '$1==t{print $2 "\t2026-10-21T00:00:00Z"}' "$D/gh.tsv"
GH
  chmod +x "$W/bin/gh"
  git -C "$W" init -q && git -C "$W" remote add origin https://github.example/complior/toy.git
  printf '%s' "$W"
}

run_case() { # $1 имя $2 ожидаемый rc $3 ожидаемая причина (литерал, пусто=любая) $4... команда
  local name=$1 want=$2 reason=$3; shift 3
  local out rc ok=1
  out=$("$@" 2>&1); rc=$?
  if [ -n "$reason" ] && ! printf '%s\n' "$out" | grep -Fq -- "$reason"; then ok=0; fi
  if [ "$ok" = 1 ]; then
    GREEN=$((GREEN+1))
    printf 'CASE %s: rc=%s want=%s причина=%s ЗЕЛЁНАЯ\n' "$name" "$rc" "$want" "${reason:--}"
  else
    RED=$((RED+1))
    printf 'CASE %s: rc=%s want=%s причина=%s КРАСНАЯ\n' "$name" "$rc" "$want" "${reason:--}"
    printf '%s\n' "$out" | sed 's/^/    | /' | head -4
  fi
}

# ---------- клетки ----------
c_k() {
  local W; W=$(new_world)
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  run_case k-gen-check 0 'gen OK: check' bash "$GEN" --repo "$W" --check
  run_case k-preflight 0 'CIPREFLIGHT_OK' bash "$PRE" --repo "$W"
  run_case k-preflight-contract 0 'CIPREFLIGHT_OK' bash "$PRE" --repo "$W" --contract "$W/contracts/kontrakt-predposylki.md"
  run_case k-gates 0 'PREDPOSYLKI_OK' env PATH="$W/bin:$PATH" bash "$GATE" "$W" "$W/contracts/kontrakt-predposylki.md"
  run_case k-freeze 0 'PREDPOSYLKI_OK' env PATH="$W/bin:$PATH" bash "$GATE" "$W" "$W/contracts/kontrakt-predposylki.md" --freeze
}
c_z5() {
  local W; W=$(new_world)
  run_case z5-bez-ci-ne-trebuet 0 'PREDPOSYLKI_OK' env PATH="$W/bin:$PATH" bash "$GATE" "$W" "$W/contracts/kontrakt-bez-ci.md"
}
c_g1() {
  local W; W=$(new_world); rm -f "$W/.harness/ci.json"
  run_case g1-manifest-otsutstvuet 1 'manifest-otsutstvuet' bash "$GEN" --repo "$W" --check
}
c_g2() {
  local W; W=$(new_world)
  printf '%s\n' '{"schemaVersion":1,"projectId":"complior-toy","jobs":{"ci":{"class":"cloud","workdir":".","steps":[{"key":"x","run":"true"}]}}}' > "$W/.harness/ci.json"
  run_case g2-manifest-nevaliden 1 'manifest-nevaliden' bash "$GEN" --repo "$W" --check
}
c_g3() {
  local W PR
  W=$(new_world)
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  PR=$(sha256sum "$W/.github/workflows/ci.yml" | cut -d' ' -f1)
  printf '# ручная правка мимо генератора\n' >> "$W/.github/workflows/ci.yml"
  run_case g3-workflow-ruchnoj 1 'workflow-ruchnoj' bash "$GEN" --repo "$W" --check
  run_case g3-write-vosstanavlivaet 0 'bajty vozvrashcheny' bash -c '
    W=$1; GEN=$2; PR=$3
    bash "$GEN" --repo "$W" --write >/dev/null 2>&1 || { printf "gen OTKAZ: write\n" >&2; exit 1; }
    S2=$(sha256sum "$W/.github/workflows/ci.yml" | cut -d" " -f1)
    [ "$S2" = "$PR" ] && { printf "gen OK: write bajty vozvrashcheny: %s\n" "$S2"; exit 0; }
    printf "gen OTKAZ: write ne vosstanovil bajty\n" >&2; exit 1' _ "$W" "$GEN" "$PR"
}
c_g4() {
  local W1 W2; W1=$(new_world); W2=$(new_world)
  run_case g4-gen-nedeterminirovan 0 'gen-nedeterminirovan: net' bash -c '
    GEN=$1; W1=$2; W2=$3
    bash "$GEN" --repo "$W1" --write >/dev/null 2>&1 || exit 1
    bash "$GEN" --repo "$W2" --write >/dev/null 2>&1 || exit 1
    if cmp -s "$W1/.github/workflows/ci.yml" "$W2/.github/workflows/ci.yml"; then
      printf "gen-nedeterminirovan: net (bajty skhodatsya)\n"; exit 0
    fi
    printf "gen OTKAZ: gen-nedeterminirovan\n" >&2; exit 1' _ "$GEN" "$W1" "$W2"
}
c_g5() {
  local W; W=$(new_world)
  python3 - "$W" <<'PY'
import json, sys
p = sys.argv[1] + '/.harness/ci.json'
m = json.load(open(p)); m['projectId'] = 'chuzhoj-proekt'
json.dump(m, open(p, 'w'))
PY
  run_case g5-profil-rashozhdenie 1 'profil-rashozhdenie' bash "$GEN" --repo "$W" --check
}
c_g6() {
  local W; W=$(new_world); rm -f "$W/.harness/harness.project.json"
  run_case g6-profil-otsutstvuet 1 'profil-otsutstvuet' bash "$GEN" --repo "$W" --check
}
c_g7() {
  local W; W=$(new_world)
  run_case g7-workflow-otsutstvuet 1 'workflow-otsutstvuet' bash "$GEN" --repo "$W" --check
}
c_p1() {
  local W; W=$(new_world)
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  printf 'jobs: [ otkrytaya-skobka\n' > "$W/.github/workflows/ci.yml"
  run_case p1-yaml-nevaliden 1 'yaml-nevaliden' bash "$PRE" --repo "$W"
}
c_p2() {
  local W; W=$(new_world)
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  rm -rf "$W/mobile"
  run_case p2-working-directory-otsutstvuet 1 'working-directory-otsutstvuet' bash "$PRE" --repo "$W"
}
c_p3() {
  local W; W=$(new_world)
  python3 - "$W" <<'PY'
import json, sys
p = sys.argv[1] + '/.harness/ci.json'
m = json.load(open(p))
m['jobs']['ci']['steps'].append({'key': 'lomaetsa', 'run': 'exit 3'})
json.dump(m, open(p, 'w'))
PY
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  run_case p3-shag-upal 1 'shag-upal: ci/lomaetsa' bash "$PRE" --repo "$W"
}
c_p4() {
  local W; W=$(new_world)
  printf '%s\n' '{"schemaVersion":1,"projectId":"complior-toy","jobs":{"e2e":{"class":"station","workdir":"mobile","steps":[{"key":"maestro","run":"ls .maestro/vkhod.yaml"}]}}}' > "$W/.harness/ci.json"
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  run_case p4-station-skip 0 'STATION-JOB: e2e' bash "$PRE" --repo "$W"
}
c_p5() {
  local W; W=$(new_world)
  python3 - "$W" <<'PY'
import json, sys
p = sys.argv[1] + '/.harness/ci.json'
m = json.load(open(p))
m['jobs']['ci']['steps'].append({'key': 'sekret', 'run': 'echo ${{ secrets.PILOT_DEMO_CODE }}'})
json.dump(m, open(p, 'w'))
PY
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  cat > "$W/contracts/kontrakt-drugoj-sekret.md" <<'K'
# Той-контракт, объявляющий ДРУГОЙ секрет
ЗОНА implementer: .github/workflows/ci.yml
ПРЕДПОСЫЛКИ:
- secret DRUGOJ
K
  run_case p5-sekrety-ne-perechisleny 1 'sekrety-ne-perechisleny: PILOT_DEMO_CODE' bash "$PRE" --repo "$W" --contract "$W/contracts/kontrakt-drugoj-sekret.md"
}
c_z1() {
  local W; W=$(new_world)
  run_case z1-predposylki-otsutstvuyut 1 'predposylki-otsutstvuyut' env PATH="$W/bin:$PATH" bash "$GATE" "$W" "$W/contracts/kontrakt-ci.md"
}
c_z2() {
  local W; W=$(new_world)
  printf 'secret DRUGOJ\nvariable NPM_TOKEN\n' > "$W/gh.tsv"
  run_case z2-sekrety-ne-zavedeny 1 'sekrety-ne-zavedeny: PILOT_DEMO_CODE' env PATH="$W/bin:$PATH" bash "$GATE" "$W" "$W/contracts/kontrakt-predposylki.md" --freeze
}
c_z3() {
  local W; W=$(new_world)
  printf '#!/usr/bin/env bash\nexit 7\n' > "$W/bin/gh"; chmod +x "$W/bin/gh"
  run_case z3-gh-nedostupen 1 'gh-nedostupen' env PATH="$W/bin:$PATH" bash "$GATE" "$W" "$W/contracts/kontrakt-predposylki.md" --freeze
}
c_z4() {
  local W; W=$(new_world)
  run_case z4-predposylki-nevaliden 1 'predposylki-nevaliden: - password Sekret' env PATH="$W/bin:$PATH" bash "$GATE" "$W" "$W/contracts/kontrakt-nevalid.md"
}

CELLS="k z5 g1 g2 g3 g4 g5 g6 g7 p1 p2 p3 p4 p5 z1 z2 z3 z4"
if [ -n "$CELL" ]; then
  case " $CELLS " in
    *" $CELL "*) ;;
    *) printf 'ci122 ОТКАЗ: нет такой клетки: %s (есть: %s)\n' "$CELL" "$CELLS" >&2; exit 2 ;;
  esac
  "c_$CELL"
  printf 'ИТОГ 122 (--cell %s): зелёных %d, красных %d\n' "$CELL" "$GREEN" "$RED"
  [ "$RED" = 0 ]; exit $?
fi
for c in $CELLS; do "c_$c"; done
TOTAL=$((GREEN + RED))
if [ "$TOTAL" -eq 0 ]; then
  printf 'ci122 ОТКАЗ: пустая выборка — ни одна клетка не исполнена\n' >&2
  exit 2
fi
printf 'ИТОГ 122 (%s): клеток %d, зелёных %d, красных %d\n' "$MODE" "$TOTAL" "$GREEN" "$RED"
[ "$RED" = 0 ]; exit $?
