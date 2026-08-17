# ПРИЧИНА: команда «npm run check:foo» есть в CI, но нет пункта в приёмке
#
# План 005 §3 дословно: «команда добавлена в workflow, но не в приёмку → код 1 с её
# текстом». Подставной workflow добавляет `npm run check:foo` поверх минимальной основы —
# барьер обязан назвать в отказе ровно ту команду, которую CI вызывает.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
printf '\n      - name: Дополнительная проверка\n        run: npm run check:foo\n' \
  >> "$WORK/.github/workflows/ci.yml"
"$BARRIER" "$WORK"
