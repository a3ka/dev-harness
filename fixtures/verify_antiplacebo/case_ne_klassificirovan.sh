# ПРИЧИНА: verify_probe.sh: не классифицирован
#
# Пункт «Готово» плана 005 §1 дословно: добавление пустого `scripts/verify_probe.sh` даёт 1.
# Пустой файл не объявляет о себе ничего, и именно это ловится: новый файл в `scripts/` не
# может стать невидимым молча.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
: > "$WORK/scripts/verify_probe.sh"
"$BARRIER" "$WORK"
