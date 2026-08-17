# ПРИЧИНА: не вызвала барьер через $BARRIER
#
# Самая дешёвая обманная заглушка из всех: фикстура, которая ничего не делает. Проверка
# «файл рядом лежит» приняла бы её и стала бы плацебо о плацебо.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
printf '# ПРИЧИНА: игрушка сломана\ntrue\n' > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
