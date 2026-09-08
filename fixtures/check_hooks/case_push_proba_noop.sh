# ПРИЧИНА: pre-push не судит или fail-open
#
# Конверсия red_check_hooks_bez_push_faz.sh → семья case_push_proba (контракт 022,
# И-10; форма входов — РЕШЕНИЕ арбитража f712e6e). ВХОД-1 «no-op»: подставной
# pre-push — саботаж (exit 0) с не-комментарной связью с кольцом; текст-фаза 7
# проходит, поведенческой push-пробы саботаж не переживает — фаза 2 ловит
# прошедший красный диапазон. Стаб — stab_push_proba_noop.sh (Н-39: привязка
# кодом; дефект наблюдаем именно на этом входе).
#
# Зелёный контроль: полный честный механизм нового мира (_mehanizm.sh строит и
# pre-push — живая копия хука предмета) → rc 0.
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

"$BARRIER" "$R" || true

cp "$(dirname "$0")/stab_push_proba_noop.sh" "$R/.githooks/pre-push"
chmod +x "$R/.githooks/pre-push"
out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'pre-push не судит или fail-open'; then
  printf 'ОТКАЗ: вход-1 (no-op) не предъявил «pre-push не судит или fail-open»: %s\n' \
    "$out_red" >&2
  exit 1
fi
