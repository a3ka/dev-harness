# ПРИЧИНА: хук не ведёт к судье
#
# Q6 контракта 016: хук есть и исполняем, но НЕ ведёт к судье scripts/check_staged.sh
# (или судьи нет) — установка через core.hooksPath подняла бы пустышку. Порча
# переписывает pre-commit без ссылки на судью: existence-проверка её ПРОПУСКАЕТ —
# вход различим именно для проверки ссылки (Н-39).
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

"$BARRIER" "$R" || true

printf '#!/usr/bin/env bash\nexit 0\n' > "$R/.githooks/pre-commit"
chmod +x "$R/.githooks/pre-commit"
"$BARRIER" "$R" || true
