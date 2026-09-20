#!/usr/bin/env bash
# check_check_spec_ready — мета-барьер приёмки check_spec_ready.sh (036).
#
# Запускает предмет на подставном корне и возвращает его код/вывод. Используется фикстурами
# fixtures/check_check_spec_ready/case_*.sh для предъявления предмета КРАСНЫМ (положительный
# контроль обязателен: вечно-зелёная заглушка неотличима от честного барьера, и мета-барьер
# один для всей семьи — по канону 008).
#
# Использование:
#   bash scripts/check_check_spec_ready.sh <корень> <контракт>
#
# Коды возврата: 0 — предмет зелёный (последняя строка «OK» по канону 008),
#                1 — ветвь провалена с именованной причиной,
#                2 — нечем проверить (NOT_IMPLEMENTED).
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${REPO:-$(cd "$SELF_DIR/.." && pwd)}"
exec "$REPO_DIR/scripts/check_spec_ready.sh" "$@"