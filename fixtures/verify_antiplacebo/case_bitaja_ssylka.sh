# ПРИЧИНА: битая символическая ссылка
#
# Находка адверсария: проверка `-f` пропускала неразрешённую символьную ссылку, и
# неклассифицированный `scripts/verify_unchecked.sh -> /absent/...` исчезал из области вместо
# отказа. Файл, которого нельзя прочесть, не выходит из области — он в ней прячется.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
ln -s /absent/verify_unchecked.sh "$WORK/scripts/verify_unchecked.sh"
"$BARRIER" "$WORK"
