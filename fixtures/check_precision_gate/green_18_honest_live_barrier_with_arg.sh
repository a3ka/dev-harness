#!/usr/bin/env bash
# ПРИЧИНА: регрессионная защита ЛОЖНОГО ОТКАЗА честному живому вызову барьера
# С АРГУМЕНТОМ (043 round-3 Б6, критик contracts-043-v3). green_17 защищает
# Б5 (скорость /proc-опроса, безаргументный случай); green_18 защищает Б6
# (правильная индексация cmdline при наличии argv[2..] — скрипт вызывается
# с абсолютным путём корня как аргументом). Отличая от green_17:
#
#   * case-файл БУКВАЛЬНО передаёт барьеру ОДИН АРГУМЕНТ (абсолютный путь
#     корня, вычисленный по `${BASH_SOURCE[0]}` — никаких подделок путей,
#     никакого ENV TRUST, та же дисциплина дословного вызова абсолютного
#     пути, что green_17);
#   * cmdline живого барьера = `bash\0<barrier>\0<root>\0` — три NUL-поля.
#     В прежней (скользящее окно) реализации `_argv1` оставалось ПОСЛЕДНИМ
#     полем (`<root>`) и сравнение с `$barrier` давало `live=0` → отказ
#     «барьер dummy не вызван живьём» при честном вызове (нарушение правила 7
#     AGENTS.md — ложный диагноз). После Б6 fix (массив с остановкой после
#     двух полей) `_argv1` = argv[1] = путь скрипта, как и должно быть.
#
# Контраст с green_17: green_17 фиксирует Б5 (≤1 итерации опроса за окно
# `sleep 1` → 0 совпадений); green_18 фиксирует Б6 (≥1 совпадение, но
# сравнивается НЕ С ТЕМ ПОЛЕМ cmdline). Без green_18 зелёное дерево 14/14
# скрывало потерю контракта о честном живом вызове с аргументами.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case18.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043

# Дамми-барьер: печатает PID и АРГУМЕНТ (это самый минимум, чтобы увидеть,
# что аргумент действительно передан), затем `sleep 1` для окна exec'а.
# На безаргументной версии (green_17) «окно» уже отлажено; для green_18
# сохраняем `sleep 1` — этого достаточно, Б6 не про скорость, а про индекс.
mkdir -p "$WORK/scripts"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "ACTUAL_BARRIER_EXEC pid=%d arg=%s\n" "$$" "${1:-none}"' \
  'sleep 1' \
  'exit 0' \
  > "$WORK/scripts/check_dummy.sh"
chmod +x "$WORK/scripts/check_dummy.sh"

# ЧЕСТНЫЙ case: буквально вызывает АБСОЛЮТНЫЙ ПУТЬ барьера С АРГУМЕНТОМ —
# корнем репозитория, вычисленным по `${BASH_SOURCE[0]}` (никаких подделок).
# Здесь нет ни BASH_XTRACEFD, ни ENV TRUST, ни косвенного вызова — тот же
# класс честного вызова, что green_17, плюс один позиционный аргумент.
mk_family_case "$WORK" dummy 'green_live_with_arg.sh' "#!/usr/bin/env bash
HERE=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd -P)\"
REPO=\"\$(cd \"\$HERE/../..\" && pwd -P)\"
\"\$REPO/scripts/check_dummy.sh\" \"\$REPO\"
:"

put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_18 (честный живой вызов барьера С АРГУМЕНТОМ, Б6 fix — argv[1] обязан быть argv[1], не argv[N])'
exit 0
