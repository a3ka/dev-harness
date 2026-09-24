#!/usr/bin/env bash
# ПРИЧИНА: регрессионная защита ЛОЖНОГО ОТКАЗА честному живому вызову барьера
# С ОПЦИЕЙ В SHEBANG (043 round-4 БС7, критик contracts-043-v4). green_17
# защищает Б5 (скорость /proc-опроса, безаргументный случай), green_18
# защищает Б6 (правильная индексация cmdline при наличии argv[2..] —
# аргументы скрипта), green_19 защищает БС7 (shebang-опция СДВИГАЕТ путь
# скрипта с argv[1] на argv[2]). Отличая от green_17/green_18:
#
#   * дамми-барьер имеет `#!/bin/bash -e` (НЕ `#!/usr/bin/env bash`!) —
#     ядро Linux (binfmt_script) поддерживает НЕ БОЛЕЕ ОДНОГО опционального
#     shebang-аргумента, поэтому cmdline живого барьера =
#     `bash\0-e\0<barrier>\0` — три NUL-поля, путь скрипта НА позиции 2,
#     а НЕ на позиции 1. В прежней реализации (чтение 2 NUL-полей и
#     сравнение ТОЛЬКО argv[1]) `_argv1` оставалось "-e" и сравнение с
#     путём барьера давало `live=0` → отказ «барьер dummy не вызван живьём»
#     при честном прямом вызове (нарушение правила 7 AGENTS.md — ложный
#     диагноз). После БС7 fix (чтение 3 NUL-полей, сравнение ОБА argv[1]
#     И argv[2] — НЕ расширяется дальше позиции 2 во избежание ложных
#     позитивов на данных-аргументах) совпадение достигается на argv[2]
#     и вызов признаётся живым.
#
#   * case-файл вызывает барьер БЕЗ обёртки `bash` — буквально
#     `"$REPO/scripts/check_dummy.sh"` (прямой exec по абсолютному пути);
#     именно прямой exec активирует binfmt_script и вставляет опцию "-e"
#     в argv[1] живой cmdline.
#
# Контраст с green_17/green_18: green_17 ловит Б5 (0 совпадений за окно),
# green_18 ловит Б6 (≥1 совпадение, но НЕ НА ТОМ ПОЛЕ — последний
# аргумент вместо argv[1]), green_19 ловит БС7 (≥1 совпадение, но argv[1]
# = "-e", а НЕ путь скрипта — путь СДВИНУТ на argv[2] из-за shebang-опции).
# Без green_19 зелёное дерево 15/15 скрывало потерю контракта о честном
# живом вызове скриптов с опцией в shebang (тот же класс риска, что 038
# уже закрывал для ENV TRUST-инъекций — но в cmdline, не в окружении).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case19.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043

# Дамми-барьер С `#!/bin/bash -e` (НЕ `#!/usr/bin/env bash`!):
# это КЛЮЧЕВОЕ отличие от green_17/green_18 — наличие опции "-e" в
# shebang сдвигает путь скрипта с argv[1] на argv[2] в /proc/<pid>/cmdline
# живого процесса барьера. Печатает PID и АРГУМЕНТЫ для наблюдаемости,
# затем `sleep 1` для окна /proc-опроса (та же дисциплина `sleep 1`, что
# green_17/green_18 — этого достаточно, БС7 не про скорость, а про индекс).
mkdir -p "$WORK/scripts"
printf '%s\n' \
  '#!/bin/bash -e' \
  'printf "ACTUAL_BARRIER_EXEC pid=%d argc=%d\n" "$$" "$#"' \
  'sleep 1' \
  'exit 0' \
  > "$WORK/scripts/check_dummy.sh"
chmod +x "$WORK/scripts/check_dummy.sh"

# ЧЕСТНЫЙ case: буквально вызывает АБСОЛЮТНЫЙ ПУТЬ барьера БЕЗ обёртки
# `bash` — прямой exec, чтобы binfmt_script вставил shebang-опцию в argv[1]
# живой cmdline. Никаких переменных окружения, никаких подделок путей,
# никакого ENV TRUST — тот же класс честного вызова, что green_17 и
# green_18, плюс shebang-опция у самого барьера.
mk_family_case "$WORK" dummy 'green_live_shebang_option.sh' "#!/usr/bin/env bash
HERE=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd -P)\"
REPO=\"\$(cd \"\$HERE/../..\" && pwd -P)\"
\"\$REPO/scripts/check_dummy.sh\"
:"

put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_19 (честный живой вызов барьера С ОПЦИЕЙ В SHEBANG, БС7 fix — argv[2] обязан быть argv[2], не argv[1])'
exit 0
