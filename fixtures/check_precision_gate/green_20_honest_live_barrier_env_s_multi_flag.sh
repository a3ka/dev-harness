#!/usr/bin/env bash
# ПРИЧИНА: регрессионная защита ЛОЖНОГО ОТКАЗА честному живому вызову барьера
# С USERPACE-РАЗРЕЗАННЫМ shebang через GNU env -S на НЕСКОЛЬКО опций
# (043 round-5 БС7/РЕШЕНИЕ, арбитраж 043-БС7 `verdicts/arbitration/043-bs7-cmdline-pozicii-env-s.md`).
# green_17 защищает Б5 (скорость /proc-опроса, безаргументный случай),
# green_18 защищает Б6 (правильная индексация cmdline при наличии argv[2..] —
# аргументы скрипта), green_19 защищает БС7-round4 (shebang-опция СДВИГАЕТ путь
# скрипта с argv[1] на argv[2] — ядерное binfmt_script-преобразование),
# green_20 защищает БС7-round5 (USERPACE-преобразование GNU `env -S` —
# разрезает ОДИН ядерный shebang-аргумент на НЕСКОЛЬКО и сдвигает путь скрипта
# на argv[3] и далее БЕЗ ПРЕДЕЛА). Отличая от green_19:
#
#   * дамми-барьер имеет `#!/usr/bin/env -S bash -e -u` — два ядерных
#     shebang-аргумента, чего ядро binfmt_script НЕ ДОПУСКАЕТ в одной записи;
#     приём состоит в том, что env -S сам интерпретирует свой единственный
#     shebang-аргумент («-S») и разрезает строку `bash -e -u` на
#     `["bash", "-e", "-u"]` ПОЛЬЗОВАТЕЛЬСКИМ преобразованием (не ядром).
#     Итоговый cmdline живого bash = `bash\0-e\0-u\0<barrier>\0` — четыре
#     NUL-поля, путь скрипта НА позиции 3, а НЕ на позиции 1 или 2.
#     В прежней реализации (чтение 3 NUL-полей, сравнение argv[1] И argv[2]
#     — НЕ расширяется дальше позиции 2 во избежание ложных позитивов на
#     данных-аргументах) сравнение argv[1]="-e" и argv[2]="-u" давало
#     `live=0` → отказ «барьер dummy не вызван живьём» при честном прямом
#     вызове (нарушение правила 7 AGENTS.md — ложный диагноз). После
#     РЕШЕНИЯ арбитража 043-БС7 (literal-скан ВСЕХ NUL-полей cmdline с
#     индекса 1 — не только позиций 1-2; любое поле ПОБАЙТОВО равное
#     канонически-абсолютному пути барьера — live) совпадение достигается
#     на argv[3] и вызов признаётся живым.
#
#   * case-файл вызывает барьер БЕЗ обёртки `bash` — буквально
#     `"$REPO/scripts/check_dummy.sh"` (прямой exec по абсолютному пути);
#     именно прямой exec активирует binfmt_script, и ядро передаёт в env
#     shebang-аргумент "-S", который env -S сам разворачивает в multi-flag
#     список (USERPACE-уровень argv-преобразования, тот же класс риска,
#     что env -S уже документирован в §env-invocation GNU coreutils).
#
# Контраст с green_17/18/19: green_17 ловит Б5 (0 совпадений за окно),
# green_18 ловит Б6 (≥1 совпадение, но НЕ НА ТОМ ПОЛЕ — последний
# аргумент вместо argv[1]), green_19 ловит БС7-round4 (≥1 совпадение,
# но argv[1] = "-e", а НЕ путь скрипта — путь СДВИНУТ на argv[2] из-за
# ядерного shebang-преобразования), green_20 ловит БС7-round5 (≥1 совпадение,
# но argv[1] = "-e" И argv[2] = "-u", а путь скрипта СДВИНУТ на argv[3]
# userspace-преобразованием env -S — следующий круг той же гонки аппроксимации
# за вычислителем, что класс 1 арбитража 042 уже закрыл доктринально).
# Без green_20 зелёное дерево 16/16 скрывало потерю контракта о честном
# живом вызове скриптов с shebang через `env -S` с несколькими опциями
# (тот же класс риска, что 038 уже закрывал для ENV TRUST-инъекций —
# но в cmdline после userspace-преобразования, не в окружении).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case20.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043

# Дамми-барьер С `#!/usr/bin/env -S bash -e -u` — КЛЮЧЕВОЕ отличие от green_19:
# ядро binfmt_script поддерживает НЕ БОЛЕЕ ОДНОГО shebang-аргумента, поэтому
# само ядро видит лишь `-S`; строку `bash -e -u` env -S разрезает УЖЕ в
# userspace на три токена, и финальный exec идёт с argv = [bash, -e, -u, <barrier>]
# — путь скрипта НА позиции 3. Печатает PID и `sleep 1` для окна /proc-опроса
# (та же дисциплина `sleep 1`, что green_17/18/19 — этого достаточно,
# БС7-round5 не про скорость, а про индекс).
mkdir -p "$WORK/scripts"
printf '%s\n' \
  '#!/usr/bin/env -S bash -e -u' \
  'printf "ACTUAL_BARRIER_EXEC pid=%d argc=%d\n" "$$" "$#"' \
  'sleep 1' \
  'exit 0' \
  > "$WORK/scripts/check_dummy.sh"
chmod +x "$WORK/scripts/check_dummy.sh"

# ЧЕСТНЫЙ case: буквально вызывает АБСОЛЮТНЫЙ ПУТЬ барьера БЕЗ обёртки
# `bash` — прямой exec, чтобы binfmt_script активировал env, который через
# -S развернул multi-flag shebang (userspace-преобразование). Никаких
# переменных окружения, никаких подделок путей, никакого ENV TRUST — тот же
# класс честного вызова, что green_17/18/19, плюс userspace-разрезанный
# shebang у самого барьера.
mk_family_case "$WORK" dummy 'green_live_env_s_multi_flag.sh' "#!/usr/bin/env bash
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
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_20 (честный живой вызов барьера С USERPACE env -S MULTI-FLAG SHEBANG, БС7-round5 fix — argv[3] обязан быть argv[3], не argv[1..2])'
exit 0