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
# Клетка зелена только при ФАКТИЧЕСКОМ rc субъекта == литералу клетки И наличии причины-литерала
# в выводе (rc — первичная мера, причина — вторая; Б1 критика 122: отказ с rc 0 краснит клетку).
set -u
export PYTHONDONTWRITEBYTECODE=1
# Имена окружения шагов клеток p5e/p6e/p6z снимаются: исход клетки не зависит от окружения станции.
unset PILOT_DEMO_CODE CI122_T CI122_U CI122_S CI122_LEVEL CI122_SRED
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
  cat > "$W/contracts/kontrakt-drugoj-sekret.md" <<'K'
# Той-контракт, объявляющий ДРУГОЙ секрет
ЗОНА implementer: .github/workflows/ci.yml
ПРЕДПОСЫЛКИ:
- secret DRUGOJ
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

run_case() { # $1 имя $2 ожидаемый rc (литерал) $3 ожидаемая причина (литерал, пусто=любая) $4... команда
  local name=$1 want=$2 reason=$3; shift 3
  local out rc ok=1 why=
  out=$("$@" 2>&1); rc=$?
  if [ "$rc" != "$want" ]; then ok=0; why="rc $rc вместо $want"; fi
  if [ -n "$reason" ] && ! printf '%s\n' "$out" | grep -Fq -- "$reason"; then
    ok=0; why="${why:+$why; }нет причины"
  fi
  if [ "$ok" = 1 ]; then
    GREEN=$((GREEN+1))
    printf 'CASE %s: rc=%s want=%s причина=%s ЗЕЛЁНАЯ\n' "$name" "$rc" "$want" "${reason:--}"
  else
    RED=$((RED+1))
    printf 'CASE %s: rc=%s want=%s причина=%s КРАСНАЯ (%s)\n' "$name" "$rc" "$want" "${reason:--}" "$why"
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
  run_case p5-sekrety-ne-perechisleny 1 'sekrety-ne-perechisleny: PILOT_DEMO_CODE' bash "$PRE" --repo "$W" --contract "$W/contracts/kontrakt-drugoj-sekret.md"
}
c_p5e() { # рукописный workflow (образец p7): необъявленный секрет ВНЕ run — env шага local- и station-джобы
  local W
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: env-sekret
        env:
          CI122_T: ${{ secrets.PILOT_DEMO_CODE }}
        run: "true"
Y
  run_case p5-env-sekret-ne-perechislen 1 'sekrety-ne-perechisleny: PILOT_DEMO_CODE' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-drugoj-sekret.md"
  # форма боли 995 п.4 (mobile.yml:229–230, станционная джоба android-e2e); первый шаг станции
  # падает без всякой заглушки — исполнение станции дало бы shag-upal, сверка обязана сработать раньше
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
jobs:
  android-e2e:
    runs-on: [self-hosted, kvm]
    env:
      PREFLIGHT_CLASS: station
    steps:
      - name: emulyator
        run: exit 1
      - name: kod-vne-checkout
        env:
          PILOT_DEMO_CODE: ${{ secrets.PILOT_DEMO_CODE }}
        run: |
          if [ -z "$PILOT_DEMO_CODE" ]; then
            echo "PILOT_DEMO_CODE_ABSENT" >&2
            exit 1
          fi
Y
  run_case p5-station-sekret-ne-perechislen 1 'sekrety-ne-perechisleny: PILOT_DEMO_CODE' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-drugoj-sekret.md"
}
p6_world() { # $1 — команда шага sekret local-джобы ci; печатает путь мира
  local W; W=$(new_world)
  cat > "$W/contracts/kontrakt-demo.md" <<'K'
# Той-контракт, объявляющий используемые шагом секрет и variable
ЗОНА implementer: .github/workflows/ci.yml
ПРЕДПОСЫЛКИ:
- secret DEMO_TOKEN
- variable DEMO_URL
K
  python3 - "$W" "$1" <<'PY'
import json, sys
p = sys.argv[1] + '/.harness/ci.json'
m = json.load(open(p))
m['jobs']['ci']['steps'].append({'key': 'sekret', 'run': sys.argv[2]})
json.dump(m, open(p, 'w'))
PY
  bash "$GEN" --repo "$W" --write >/dev/null 2>&1
  printf '%s' "$W"
}
c_p6() {
  local W
  W=$(p6_world 'test -n "${{ secrets.DEMO_TOKEN }}" && test -n "${{ vars.DEMO_URL }}"')
  run_case p6-sekret-podstavlyaetsya 0 'CIPREFLIGHT_OK jobs=1 station=1' bash "$PRE" --repo "$W" --contract "$W/contracts/kontrakt-demo.md"
  W=$(p6_world 'test -z "${{ secrets.DEMO_TOKEN }}"')
  run_case p6-sekret-shag-ispolnyaetsya 1 'shag-upal: ci/sekret' bash "$PRE" --repo "$W" --contract "$W/contracts/kontrakt-demo.md"
}
c_p6e() { # рукописный workflow: объявленные secrets.X / vars.X в цепочке env workflow < джоба < шаг
  local W
  # дословная форма носителя боли mobile.yml:229–235 (объявленный секрет в env шага)
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: kod-vne-checkout
        env:
          PILOT_DEMO_CODE: ${{ secrets.PILOT_DEMO_CODE }}
        run: |
          if [ -z "$PILOT_DEMO_CODE" ]; then
            echo "PILOT_DEMO_CODE_ABSENT" >&2
            exit 1
          fi
Y
  run_case p6-env-nositel-boli 0 'CIPREFLIGHT_OK jobs=1 station=0' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-predposylki.md"
  # секрет — env workflow, variable — env джобы; литерал шага переопределяет литерал джобы,
  # литерал джобы — литерал workflow (старшинство и перенос литералов одной клеткой)
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
env:
  CI122_T: ${{ secrets.PILOT_DEMO_CODE }}
  CI122_LEVEL: workflow
  CI122_SRED: workflow
jobs:
  verify:
    runs-on: ubuntu-latest
    env:
      CI122_U: ${{ vars.NPM_TOKEN }}
      CI122_LEVEL: job
      CI122_SRED: job
    steps:
      - name: cepochka
        env:
          CI122_LEVEL: step
        run: test -n "$CI122_T" && test -n "$CI122_U" && test "$CI122_LEVEL" = step && test "$CI122_SRED" = job
Y
  run_case p6-env-cepochka 0 'CIPREFLIGHT_OK jobs=1 station=0' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-predposylki.md"
  # пара: шаг с объявленным секретом в env исполняется, заглушка непуста
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: sekret-v-env
        env:
          CI122_T: ${{ secrets.PILOT_DEMO_CODE }}
        run: test -z "$CI122_T"
Y
  run_case p6-env-shag-ispolnyaetsya 1 'shag-upal: verify/sekret-v-env' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-predposylki.md"
}
c_p6z() { # рукописный workflow: значение env — САМО выражение secrets.X / vars.X; в env обязана
  # оказаться заглушка — непустая и НЕ равная буквальному тексту выражения (перенос env без
  # подстановки отличим). Буквальный текст собирается в шаге из D='$' и '{{ … }}': точной формы
  # выражения в run нет — подстановка run его не трогает; токены объявлены в ПРЕДПОСЫЛКИ.
  local W
  # подстановка на каждом уровне цепочки: secret — env workflow и шага, variable — env джобы
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
env:
  CI122_T: ${{ secrets.PILOT_DEMO_CODE }}
jobs:
  verify:
    runs-on: ubuntu-latest
    env:
      CI122_U: ${{ vars.NPM_TOKEN }}
    steps:
      - name: zaglushka-v-env
        env:
          CI122_S: ${{ secrets.PILOT_DEMO_CODE }}
        run: |
          D='$'
          test -n "$CI122_T" && test "$CI122_T" != "${D}{{ secrets.PILOT_DEMO_CODE }}" &&
          test -n "$CI122_U" && test "$CI122_U" != "${D}{{ vars.NPM_TOKEN }}" &&
          test -n "$CI122_S" && test "$CI122_S" != "${D}{{ secrets.PILOT_DEMO_CODE }}"
Y
  run_case p6z-env-ne-literal 0 'CIPREFLIGHT_OK jobs=1 station=0' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-predposylki.md"
  # свидетель финального круга критика: одно объявленное выражение через env и через run совпадает
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: env-ravno-run
        env:
          CI122_T: ${{ secrets.PILOT_DEMO_CODE }}
          CI122_U: ${{ vars.NPM_TOKEN }}
        run: 'test "$CI122_T" = "${{ secrets.PILOT_DEMO_CODE }}" && test "$CI122_U" = "${{ vars.NPM_TOKEN }}"'
Y
  run_case p6z-env-ravno-run 0 'CIPREFLIGHT_OK jobs=1 station=0' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-predposylki.md"
  # пара: шаг, требующий в env буквальный текст выражения, обязан упасть (подстановка произошла)
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: env-raven-literalu
        env:
          CI122_T: ${{ secrets.PILOT_DEMO_CODE }}
        run: |
          D='$'
          test "$CI122_T" = "${D}{{ secrets.PILOT_DEMO_CODE }}"
Y
  run_case p6z-env-literal-otkaz 1 'shag-upal: verify/env-raven-literalu' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml --contract "$W/contracts/kontrakt-predposylki.md"
}
c_p7() { # рукописный workflow: наследование defaults.run.working-directory уровня workflow
  local W
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
defaults:
  run:
    working-directory: missing-directory
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: verify
        run: "true"
Y
  run_case p7-wd-workflow-otsutstvuet 1 'working-directory-otsutstvuet: missing-directory' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
defaults:
  run:
    working-directory: mobile
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: verify
        run: test -f .maestro/vkhod.yaml
Y
  run_case p7-wd-workflow-est 0 'CIPREFLIGHT_OK jobs=1 station=0' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
defaults:
  run:
    working-directory: missing-directory
jobs:
  verify:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: mobile
    steps:
      - name: verify
        run: test -f .maestro/vkhod.yaml
Y
  run_case p7-wd-pereopredelen-dzhoboj 0 'CIPREFLIGHT_OK jobs=1 station=0' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml
  W=$(new_world)
  cat > "$W/.github/workflows/ruchnoj.yml" <<'Y'
name: ruchnoj
on: push
defaults:
  run:
    working-directory: missing-directory
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: verify
        working-directory: mobile
        run: test -f .maestro/vkhod.yaml
Y
  run_case p7-wd-pereopredelen-shagom 0 'CIPREFLIGHT_OK jobs=1 station=0' bash "$PRE" --repo "$W" --workflow .github/workflows/ruchnoj.yml
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

CELLS="k z5 g1 g2 g3 g4 g5 g6 g7 p1 p2 p3 p4 p5 p5e p6 p6e p6z p7 z1 z2 z3 z4"
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
