# ПРИЧИНА: без полного sha красного коммита
#
# Конверсия red_check_hooks_bez_push_faz.sh → семья case_push_proba (контракт 022,
# И-10; РЕШЕНИЕ арбитража f712e6e, п.1 — пер-полевая форма различения).
# ДИАГОНАЛЬНЫЙ вход H_без_sha: pre-push пропускает чистый диапазон и отвергает
# красный причиной с полным ref и путём — молчит о полном sha красного коммита.
# Проба, не судящая поле sha, этот вход пропускает; честная умирает с «назвал
# причину без полного sha красного коммита». Стаб — stab_push_proba_bez_sha.sh
# (Н-39).
#
# Зелёный контроль: полный честный механизм нового мира → rc 0.
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

"$BARRIER" "$R" || true

cp "$(dirname "$0")/stab_push_proba_bez_sha.sh" "$R/.githooks/pre-push"
chmod +x "$R/.githooks/pre-push"
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'без полного sha красного коммита'; then
  printf 'ОТКАЗ: вход H_без_sha не предъявил «без полного sha красного коммита»: %s\n' \
    "$out_red" >&2
  exit 1
fi
