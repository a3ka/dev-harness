# ПРИЧИНА: python3 отсутствует
# ОКРУЖЕНИЕ: PATH=$WORK/bin
#
# Срез 1 контракта 016, ветвь грамматики имени, закрытие находки 2 адверсария
# (verdicts/adversary/contracts-016.md): когда python3 недоступен, барьер обязан
# отказать с названной причиной (fail-closed), а не молча зеленеть, как было.
# Раньше `if … | python3 …` трактовал rc=127 от ненайденного python3 как «нет
# control-символа» — staged с переносом ВНУТРИ зоны проходил rc=0.
#
# Различимость входа (Н-39): это именно «судья не может исполнить проверку», а не
# «нашёл control-символ». Зелёный контроль (staged пуст) не задействует python3
# и идёт через ранний возврат «нечего судить: staged пуст» (rc=0). Затем staged
# с control-символом внутри зоны — `command -v python3` отказывает, барьер
# отвечает rc=1 с названной причиной.
#
# PATH фикстуры строго $WORK/bin: каталог со ссылками на нужные утилиты, БЕЗ
# python3 (вот и всё «отсутствие инструмента»). Без строгого PATH fallback в
# /usr/bin вернул бы python3 — тест потерял бы смысл, против которого закрывается
# находка. `PATH=$WORK/bin` (без `:…`) даёт изолированную среду барьера.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Stub-каталог: ссылки на всё, что барьер и git могут вызвать, кроме python3.
# Состав узкий, потому что нужен только путь к отказу `command -v python3`.
mkdir -p "$WORK/bin"
for b in bash sh git env sort awk sed cat tr grep cut basename dirname wc head tail printf mktemp mkdir rm find rev tac tee; do
  p="$(command -v "$b" 2>/dev/null || true)"
  [ -n "$p" ] && ln -sf "$p" "$WORK/bin/$b"
done
# Намеренно НЕ создаём ссылку на python3 — это «PATH без python3».
if [ -e "$WORK/bin/python3" ]; then
  printf 'NOT_IMPLEMENTED: python3 утечка в stub-каталог\n' >&2
  exit 2
fi

# ── Зелёный контроль: staged пуст — барьер уходит до python3-проверки, rc=0 ──
out_green="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_green" | grep -q 'нечего судить'; then
  printf 'ОТКАЗ: зелёный контроль ожидал пустой staged, не увидел: %s\n' "$out_green" >&2
  exit 1
fi

# ── Красное: control-символ внутри зоны, python3 отсутствует ──────────────
stage "$R" "scripts/valid"$'\n'"control" 'control-символ внутри зоны под отсутствующим python3'
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'python3 отсутствует'; then
  printf 'ОТКАЗ: фикстура под отсутствующим python3 не выдала rc=1 «python3 отсутствует»: %s\n' "$out_red" >&2
  exit 1
fi
