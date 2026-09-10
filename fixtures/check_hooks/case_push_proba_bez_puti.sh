# ПРИЧИНА: путь уставного файла не назван
#
# Конверсия red_check_hooks_bez_push_faz.sh → семья case_push_proba (контракт 022,
# И-10; РЕШЕНИЕ арбитража f712e6e, п.1 — пер-полевая форма различения).
# ДИАГОНАЛЬНЫЙ вход H_без_path: pre-push пропускает чистый диапазон и отвергает
# красный причиной с полным ref и полным sha — молчит о пути уставного файла.
# Проба, не судящая поле пути, этот вход пропускает; честная умирает с «отверг
# без именованной причины (путь уставного файла не назван)». Стаб —
# stab_push_proba_bez_puti.sh (Н-39).
#
# Зелёный контроль: полный честный механизм нового мира → rc 0.
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

"$BARRIER" "$R" || true

cp "$(dirname "$0")/stab_push_proba_bez_puti.sh" "$R/.githooks/pre-push"
chmod +x "$R/.githooks/pre-push"
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'путь уставного файла не назван'; then
  printf 'ОТКАЗ: вход H_без_path не предъявил «путь уставного файла не назван»: %s\n' \
    "$out_red" >&2
  exit 1
fi
