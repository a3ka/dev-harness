#!/usr/bin/env bash
# ПРИЧИНА: проводка: guard не подключён: scripts/a.b.sh не вызывается в .githooks/ или .github/workflows/
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_27 - RED (ERE-инъекция в basename guard-файла, круг 14, verdicts/adversary/
# contracts-038-guard-ere-metacharacters.md). Без фикса guard_is_wired интерполирует
# $bname в grep -E паттерн без экранирования, и метасимвол (`.`, `*`, `[`, и т.д.)
# трактуется как REGEX, а не литерал имени: `scripts/a.b.sh` принимается
# `scripts/axb.sh`, `scripts/a*b.sh` принимается `scripts/b.sh`, и т.д.
# С фиксом $bname экранируется ДО подстановки, и единственная зелёная
# проводка - когда в workflow/hook действительно вызывается литеральный
# basename. Четыре сценария: githooks-позитив (rc 0), githooks-форж
# (rc 1); workflows-позитив (rc 0), workflows-форж (rc 1).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case27_038.XXXXXX")"
  trap "rm -rf \"$WORK\"" EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

G1="$WORK/green_githooks"
mkdir -p "$G1/scripts" "$G1/.githooks" "$G1/contracts" "$G1/roles"
printf "#!/usr/bin/env bash\nexit 0\n" > "$G1/scripts/a.b.sh"
echo "bash scripts/a.b.sh" > "$G1/.githooks/pre-commit"
printf "# role fixture\n\nNorma stroki roli v igrushke R.\n" > "$G1/roles/fixer.md"
printf "# kontrakt 001\n\n## Predmet\np\n\n## Norma-provodka\nПРОВОДКА:\n- guard=scripts/a.b.sh\n- role=roles/fixer.md «Norma stroki roli v igrushke R.»\n" > "$G1/contracts/001-x.md"
G1_OUT="$("$BARRIER" "$G1" "$G1/contracts/001-x.md" 2>&1)"; G1_RC=$?

R1="$WORK/red_githooks"
mkdir -p "$R1/scripts" "$R1/.githooks" "$R1/contracts" "$R1/roles"
printf "#!/usr/bin/env bash\nexit 0\n" > "$R1/scripts/a.b.sh"
printf "#!/usr/bin/env bash\nexit 0\n" > "$R1/scripts/axb.sh"
echo "bash scripts/axb.sh" > "$R1/.githooks/pre-commit"
printf "# role fixture\n\nNorma stroki roli v igrushke R.\n" > "$R1/roles/fixer.md"
printf "# kontrakt 001\n\n## Predmet\np\n\n## Norma-provodka\nПРОВОДКА:\n- guard=scripts/a.b.sh\n- role=roles/fixer.md «Norma stroki roli v igrushke R.»\n" > "$R1/contracts/001-x.md"
R1_OUT="$("$BARRIER" "$R1" "$R1/contracts/001-x.md" 2>&1)"; R1_RC=$?

G2="$WORK/green_workflows"
mkdir -p "$G2/scripts" "$G2/.github/workflows" "$G2/contracts" "$G2/roles"
printf "#!/usr/bin/env bash\nexit 0\n" > "$G2/scripts/c[d.sh"
printf "# role fixture\n\nNorma stroki roli v igrushke R.\n" > "$G2/roles/fixer.md"
printf "name: ci\non: push\njobs:\n  build:\n    runs-on: ubuntu-latest\n    steps:\n      - run: bash scripts/c[d.sh\n" > "$G2/.github/workflows/w.yml"
printf "# kontrakt 001\n\n## Predmet\np\n\n## Norma-provodka\nПРОВОДКА:\n- guard=scripts/c[d.sh\n- role=roles/fixer.md «Norma stroki roli v igrushke R.»\n" > "$G2/contracts/001-x.md"
G2_OUT="$("$BARRIER" "$G2" "$G2/contracts/001-x.md" 2>&1)"; G2_RC=$?

R2="$WORK/red_workflows"
mkdir -p "$R2/scripts" "$R2/.github/workflows" "$R2/contracts" "$R2/roles"
printf "#!/usr/bin/env bash\nexit 0\n" > "$R2/scripts/c[d.sh"
printf "#!/usr/bin/env bash\nexit 0\n" > "$R2/scripts/cxd.sh"
printf "# role fixture\n\nNorma stroki roli v igrushke R.\n" > "$R2/roles/fixer.md"
printf "name: ci\non: push\njobs:\n  build:\n    runs-on: ubuntu-latest\n    steps:\n      - run: bash scripts/cxd.sh\n" > "$R2/.github/workflows/w.yml"
printf "# kontrakt 001\n\n## Predmet\np\n\n## Norma-provodka\nПРОВОДКА:\n- guard=scripts/c[d.sh\n- role=roles/fixer.md «Norma stroki roli v igrushke R.»\n" > "$R2/contracts/001-x.md"
R2_OUT="$("$BARRIER" "$R2" "$R2/contracts/001-x.md" 2>&1)"; R2_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$G1_RC" -eq 0 ] || { printf "FAIL: case_27 green-githooks rc=%s\n%s\n" "$G1_RC" "$G1_OUT" >&2; exit 1; }
  printf "%s" "$G1_OUT" | grep -Fq "получено:" && { printf "FAIL: green-githooks содержит получено:\n%s\n" "$G1_OUT" >&2; exit 1; }
  [ "$R1_RC" -eq 1 ] || { printf "FAIL: case_27 red-githooks rc=%s\n%s\n" "$R1_RC" "$R1_OUT" >&2; exit 1; }
  printf "%s" "$R1_OUT" | grep -Fq "проводка: guard не подключён: scripts/a.b.sh не вызывается" || { printf "FAIL: red-githooks причина\n%s\n" "$R1_OUT" >&2; exit 1; }
  [ "$G2_RC" -eq 0 ] || { printf "FAIL: case_27 green-workflows rc=%s\n%s\n" "$G2_RC" "$G2_OUT" >&2; exit 1; }
  [ "$R2_RC" -eq 1 ] || { printf "FAIL: case_27 red-workflows rc=%s\n%s\n" "$R2_RC" "$R2_OUT" >&2; exit 1; }
  printf "%s" "$R2_OUT" | grep -Fq "проводка: guard не подключён: scripts/c[d.sh не вызывается" || { printf "FAIL: red-workflows причина\n%s\n" "$R2_OUT" >&2; exit 1; }
  printf "case_27: rc 0 на позитив-контролях, rc 1 на форжах (ERE-экранирование)\n" >&2
  exit 0
fi
exit 0
