# ПРИЧИНА: барьер остался зелёным на обманном дереве
#
# Вторая половина той же атаки: красное добывается НЕОБЪЯВЛЕННОЙ добавкой к окружению. Игрушка
# красна, только если на PATH нашёлся посторонний инструмент; внутренняя фикстура кладёт его в
# свой каталог и подставляет PATH перед вызовом — так, как это писали до решения арбитража.
#
# Окружение вызова строится ТОЛЬКО из шапки исходника фикстуры, поэтому подставленный по ходу
# PATH до барьера не доходит: барьер зелен, красное не предъявлено. Отдельная фикстура, а не
# вариант предыдущей, потому что это другой канал подделки, а правило обязано держать канал.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
set_toy "$WORK" naruzhnaja
{
  printf '# ПРИЧИНА: игрушка сломана\n'
  printf 'set -euo pipefail\n'
  printf 'mkdir -p "$WORK/scripts" "$WORK/bin"\n'
  printf 'printf "#!/bin/sh\\nexit 0\\n" > "$WORK/bin/postoronnij-instrument"\n'
  printf 'chmod +x "$WORK/bin/postoronnij-instrument"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER"\n'
  printf 'PATH="$WORK/bin:$PATH" BARRIER_ROOT="$WORK" "$BARRIER"\n'
} > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
