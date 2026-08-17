# ПРИЧИНА: verify_hidden.sh: нет фикстур
#
# Находка адверсария: глоб `scripts/*` имел глубину один, и объявленный барьер
# `scripts/lib/verify_hidden.sh` выпадал из области целиком — не требовал фикстуры и не
# входил даже в счёт барьеров. Заявлено было «всё содержимое scripts/», а проверялся первый
# уровень: область без глубины не проверяет ничего.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
mkdir -p "$WORK/scripts/lib"
{
  printf '#!/usr/bin/env bash\n'
  printf '# Барьер, спрятанный в подкаталоге.\n'
  printf '# Коды возврата: 0 — цело, 1 — сломано, 2 — нечем проверить.\n'
  printf 'exit 0\n'
} > "$WORK/scripts/lib/verify_hidden.sh"
"$BARRIER" "$WORK"
