# ПРИЧИНА: без полного refs/heads/main
#
# Конверсия red_check_hooks_bez_push_faz.sh → семья case_push_proba (контракт 022,
# И-10; РЕШЕНИЕ арбитража f712e6e, п.1 — пер-полевая форма различения).
# ДИАГОНАЛЬНЫЙ вход H_без_ref: pre-push пропускает чистый диапазон и отвергает
# красный причиной с полным sha и путём — молчит о полном ref. Проба, не
# судящая поле ref, этот вход пропускает; честная умирает с «назвал причину
# без полного refs/heads/main». Стаб — stab_push_proba_bez_ref.sh (Н-39).
#
# Зелёный контроль: полный честный механизм нового мира → rc 0.
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

"$BARRIER" "$R" || true

cp "$(dirname "$0")/stab_push_proba_bez_ref.sh" "$R/.githooks/pre-push"
chmod +x "$R/.githooks/pre-push"
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'без полного refs/heads/main'; then
  printf 'ОТКАЗ: вход H_без_ref не предъявил «без полного refs/heads/main»: %s\n' \
    "$out_red" >&2
  exit 1
fi
