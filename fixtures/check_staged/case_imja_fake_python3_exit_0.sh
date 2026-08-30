# ПРИЧИНА: канарейка не подтверждена
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Парный кейс к case_imja_fake_python3_exit_1.sh (находка 1 раунда 2 адверсария,
# `fake-python3-exit-1`): стаб `exit 0` на входе с control-символом неотличим от
# честного python3 по exit code — ловится РАСХОЖДЕНИЕМ МАРКЕРА stdout: на чистом
# входе честный конвейер выходит rc=1 с маркером «0», стаб даёт rc=0 и пустоту.
# Оба прогона канарейки обязаны совпасть по ДВУМ полям — потому маркер и нужен:
# exit code один сигнал, заглушка умеет совпадать по нему.
#
# Различимость входа (Н-39): тот же staged с control-символом внутри зоны, что и у
# exit-1 кейса; различие — форма подмены (0-rc заглушка вместо 1-rc). Без парного
# кейса ветвь «0-rc заглушка» не была бы различима: на единственном входе «exit 1»
# она не наблюдаема вовсе (стаб exit 0 там выглядит как найденный control-символ).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Stub-каталог: ссылки на утилиты барьера и git, плюс python3-стаб `exit 0`.
mkdir -p "$WORK/bin"
for b in bash sh git env sort awk sed cat tr grep cut basename dirname wc head tail printf mktemp mkdir rm find rev tac tee; do
  p="$(command -v "$b" 2>/dev/null || true)"
  [ -n "$p" ] && ln -sf "$p" "$WORK/bin/$b"
done
cat > "$WORK/bin/python3" <<'STUB'
#!/bin/sh
exit 0
STUB
chmod +x "$WORK/bin/python3"
[ -x "$WORK/bin/python3" ] || { printf 'NOT_IMPLEMENTED: не удалось создать python3 стаб\n' >&2; exit 2; }

# ── Зелёный контроль: staged пуст — ранний возврат ДО python3, rc=0 ────────────
out_green="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_green" | grep -q 'нечего судить'; then
  printf 'ОТКАЗ: зелёный контроль ожидал пустой staged, не увидел: %s\n' "$out_green" >&2
  exit 1
fi

# ── Красное: control-символ внутри зоны, python3 — стаб `exit 0` ───────────────
stage "$R" "scripts/valid"$'\n'"control" 'control-символ внутри зоны под стабом python3 exit 0'
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'канарейка не подтверждена'; then
  printf 'ОТКАЗ: фикстура под стабом python3 exit 0 не выдала rc=1 «канарейка не подтверждена»: %s\n' "$out_red" >&2
  exit 1
fi
