# ПРИЧИНА: не назвал причину
#
# Барьер красный, но говорит НЕ О ТОМ, чего от него ждали. Так выглядит фикстура, ломающая
# что-то постороннее: код возврата совпал с ожиданием, а предмет не проверен. Ровно этот
# дефект замера записан в AGENTS.md — результат объявлен по коду возврата, а не по предмету.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
{
  printf '# ПРИЧИНА: игрушка съела ключи\n'
  printf 'set -euo pipefail\n'
  printf 'mkdir -p "$WORK/scripts"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER"\n'
  printf 'touch "$WORK/.slomano"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER"\n'
} > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
