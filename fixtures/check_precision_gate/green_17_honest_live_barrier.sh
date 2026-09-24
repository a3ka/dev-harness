#!/usr/bin/env bash
# ПРИЧИНА: регрессионная защита ЛОЖНОГО ОТКАЗА честному живому вызову барьера
# (043 round-2 Б5, критик contracts-043-v2). case-файл буквально вызывает
# абсолютный путь барьера — никакого BASH_XTRACEFD, никакой подмены
# окружения, никакого косвенного вызова. Барьер сам печатает свой PID и
# `sleep 1` — это и есть окно exec'а, которое прежний код /proc-опроса
# (awk-per-process ~1.4с на итерацию) пропускал, отвечая rc 1 «барьер dummy
# не вызван живьём». Тест красный в прежнем коде (см. verdict критика);
# после Б5 fix (bash-встроенный regex для PPid, ≈30мс на 540 процессов,
# переэкспансия /proc/[0-9]* на каждой внешней итерации) — зелёный.
#
# Контраст с red_07 (Б7 close): red_07 case НЕ вызывает барьер вообще — это
# тот класс отказа, который зеленеть НЕ ДОЛЖЕН; здесь наоборот — case
# ВЫЗЫВАЕТ честно, и зеленеть ОБЯЗАН, иначе отказ нарушает правило 7
# AGENTS.md (красное с ложным диагнозом не есть честный отказ).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case17.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043

# ЧЕСТНЫЙ дамми-барьер: печатает PID и `sleep 1` — это окно exec'а для
# /proc-наблюдения гейта. Простой `exit 0` отрабатывает быстрее окна
# опроса и неотличим от never-called; `sleep 1` — граница, на которой
# проявляется регрессия по скорости опроса.
mkdir -p "$WORK/scripts"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "ACTUAL_BARRIER_EXEC pid=%d\n" "$$"' \
  'sleep 1' \
  'exit 0' \
  > "$WORK/scripts/check_dummy.sh"
chmod +x "$WORK/scripts/check_dummy.sh"

# ЧЕСТНЫЙ case: буквально вызывает АБСОЛЮТНЫЙ ПУТЬ барьера (не bash
# subshell, не eval, не обёртку). Никаких переменных окружения, влияющих
# на поведение case'а — case не использует BASH_XTRACEFD, не различает
# xtrace-режим, не передаёт путь барьера аргументом посторонней команды.
mk_family_case "$WORK" dummy 'green_live.sh' "#!/usr/bin/env bash
HERE=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd -P)\"
REPO=\"\$(cd \"\$HERE/../..\" && pwd -P)\"
\"\$REPO/scripts/check_dummy.sh\"
"

put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_17 (честный живой вызов барьера, Б5 fix — /proc-наблюдение должно ловить)'
exit 0