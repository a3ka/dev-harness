# ПРИЧИНА: не объявила причину
#
# Красное без названной причины не отличить от красного по случайной поломке: фикстура,
# отнявшая у барьера право на файл, тоже даёт не ноль, и «проверка работает» была бы ложью.
# ROADMAP требует буквально: фикстура валит барьер С НАЗВАННОЙ ПРИЧИНОЙ.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
printf 'set -euo pipefail\ntouch "$WORK/.slomano"\nBARRIER_ROOT="$WORK" "$BARRIER"\n' \
  > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
