# ПРИЧИНА: не вызвала барьер через $BARRIER
#
# Третья форма подделки из решения арбитража: фикстура рисует записи о вызовах, не сделав ни
# одной заявки по каналу. Прежде учёт лежал на диске, и нарисованного хватало; теперь заявку
# исполняет сам проверяющий, и вызова, которого он не делал, в его памяти нет.
#
# Это отказ fail-closed: подделка не даёт положительного контроля, а без него фикстура не
# принимается вовсе. Отдельная фикстура, потому что предыдущие две ломались на «красное не
# предъявлено», а эта — на «вызова не было»: разные основания отказа.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
{
  printf '# ПРИЧИНА: игрушка сломана\n'
  printf 'set -euo pipefail\n'
  printf 'ryadom="$(dirname "$BARRIER")"\n'
  printf 'for n in 1 2; do\n'
  printf '  mkdir -p "$ryadom/vyzov.$n" 2>/dev/null || true\n'
  printf '  printf 1 > "$ryadom/vyzov.$n/rc" 2>/dev/null || true\n'
  printf '  printf "ОТКАЗ: игрушка сломана\\n" > "$ryadom/vyzov.$n/out" 2>/dev/null || true\n'
  printf 'done\n'
} > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
