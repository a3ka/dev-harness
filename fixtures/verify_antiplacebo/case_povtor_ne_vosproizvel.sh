# ПРИЧИНА: повторный прогон проверяющего дал код 0
#
# Находка адверсария: запись о вызове подделывалась. Фикстура вычитывала путь учёта из
# читаемой обёртки, создавала каталог вызова с кодом 1 и нужным текстом и барьер не запускала
# вовсе — при этом в её исходнике не было ни одного запрещённого имени.
#
# Закрыто переносом ВЕРДИКТА: запись стала лишь указанием, ЧЕМ и ГДЕ мерить, а красное
# засчитывает повторный прогон проверяющего. Здесь фикстура добивается настоящего красного и
# сразу убирает порчу — запись есть, воспроизвести её нечем, и это отказ.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
{
  printf '# ПРИЧИНА: игрушка сломана\n'
  printf 'set -euo pipefail\n'
  printf 'mkdir -p "$WORK/scripts"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER"\n'
  printf 'touch "$WORK/.slomano"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER" || true\n'
  printf 'rm -f "$WORK/.slomano"\n'
} > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
