# ПРИЧИНА: барьер остался зелёным на обманном дереве
#
# Фикстура барьер вызывает, а обманное состояние не создаёт: барьер отвечает нулём. Это
# ловля второй по дешевизне заглушки — «вызов есть, красного нет».
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
printf '# ПРИЧИНА: игрушка сломана\nset -euo pipefail\nBARRIER_ROOT="$WORK" "$BARRIER"\n' \
  > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
