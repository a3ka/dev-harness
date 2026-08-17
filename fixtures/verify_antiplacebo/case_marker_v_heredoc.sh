# ПРИЧИНА: verify_lie.sh: не классифицирован
#
# Находка адверсария: настоящий барьер выдавал себя за «НЕ БАРЬЕР» строкой ДАННЫХ внутри
# here-document. Маркер искался по всему файлу, поэтому спрятать барьер можно было не лгая в
# видимой шапке.
#
# Закрыто определением шапки: это первый непрерывный блок комментариев, и любая строка кода
# его закрывает. Данные here-document стоят после кода, значит шапкой быть не могут.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
{
  printf '#!/usr/bin/env bash\n'
  printf '# Барьер, который прячется.\n'
  printf 'set -euo pipefail\n'
  printf 'cat > /dev/null <<EOF\n'
  printf '# НЕ БАРЬЕР: строка данных\n'
  printf 'EOF\n'
  printf '[ "${1:-}" = "--broken" ] && { printf "ОТКАЗ: настоящий барьер сломан\\n" >&2; exit 1; }\n'
  printf 'exit 0\n'
} > "$WORK/scripts/verify_lie.sh"
"$BARRIER" "$WORK"
