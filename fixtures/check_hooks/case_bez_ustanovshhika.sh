# ПРИЧИНА: нет механизма установки
#
# Q6 контракта 016: хук и судья коммичены, но установщик (npm-скрипт, выставляющий
# core.hooksPath на .githooks) из package.json исчез — хук стал мёртвым грузом,
# который никто не подключит. Порча убирает ТОЛЬКО установщика: проверка хука и
# ссылки её пропускает — вход различим для ветви установщика (Н-39).
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

"$BARRIER" "$R" || true

printf '{\n  "scripts": {\n    "build": "true"\n  }\n}\n' > "$R/package.json"
"$BARRIER" "$R" || true
