# ПРИЧИНА: канарейка не подтверждена
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Срез 1 контракта 016, закрытие находки 1 раунда 2 адверсария
# (`fake-python3-exit-1`, verdicts/adversary/contracts-016.md): подменённый python3
# (`exit 1`) проходил `command -v python3`, а конвейер грамматики трактовал его rc=1
# как «нет control-символа» — staged с переносом ВНУТРИ зоны шёл rc=0. Закрыто
# само-канарейкой судьи: тот же python3-конвейер обязан подтвердить себя на заведомо
# содержащем control-символ stdin И на чистом — И по exit code, И по маркеру stdout.
# Стаб `exit 1` ловится расхождением exit code (канарейка ждёт rc=0 и маркер «1» на
# «a\nb», получает rc=1 и пустоту).
#
# Различимость входа (Н-39): это ветвь «судья не может исполнить проверку», а не
# «нашёл control-символ». Зелёный контроль (staged пуст) уходит ранним возвратом
# «нечего судить» ДО python3; красное — staged с control-символом внутри зоны при
# PATH, где python3 — стаб `exit 1`. Парный кейс case_imja_fake_python3_exit_0.sh
# ловит другую форму подмены (расхождение маркера), вход тот же.
#
# PATH объявлен шапкой ($WORK/bin префиксом к $PATH): стаб затеняет честный python3,
# остальные инструменты остаются достижимы. Без префикса нашёлся бы системный
# python3 — тест потерял бы предмет, против которого закрывается находка.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Stub-каталог: ссылки на утилиты барьера и git, плюс python3-стаб `exit 1`.
mkdir -p "$WORK/bin"
for b in bash sh git env sort awk sed cat tr grep cut basename dirname wc head tail printf mktemp mkdir rm find rev tac tee; do
  p="$(command -v "$b" 2>/dev/null || true)"
  [ -n "$p" ] && ln -sf "$p" "$WORK/bin/$b"
done
cat > "$WORK/bin/python3" <<'STUB'
#!/bin/sh
exit 1
STUB
chmod +x "$WORK/bin/python3"
[ -x "$WORK/bin/python3" ] || { printf 'NOT_IMPLEMENTED: не удалось создать python3 стаб\n' >&2; exit 2; }

# ── Зелёный контроль: staged пуст — ранний возврат ДО python3, rc=0 ────────────
out_green="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_green" | grep -q 'нечего судить'; then
  printf 'ОТКАЗ: зелёный контроль ожидал пустой staged, не увидел: %s\n' "$out_green" >&2
  exit 1
fi

# ── Красное: control-символ внутри зоны, python3 — стаб `exit 1` ───────────────
stage "$R" "scripts/valid"$'\n'"control" 'control-символ внутри зоны под стабом python3 exit 1'
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'канарейка не подтверждена'; then
  printf 'ОТКАЗ: фикстура под стабом python3 exit 1 не выдала rc=1 «канарейка не подтверждена»: %s\n' "$out_red" >&2
  exit 1
fi
