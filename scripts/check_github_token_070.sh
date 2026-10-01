#!/usr/bin/env bash
# НЕ БАРЬЕР: guard-канал ПРОВОДКА контракта 070 — делегирует fixtures/_krasnye_070.sh;
# фактический барьер — батарея fixtures/workshop_project/red_github_token_070.sh
# (стаб-пак 7/7 + диффпроба 7/7 + честные клетки к1..к7 шага GitHub-токена).
# Guard-канал контракта 070 (ПРОВОДКА, §Подключение guard-канала):
# делегирует прогон семейному раннеру fixtures/_krasnye_070.sh, который
# гоняет батарею fixtures/workshop_project/red_github_token_070.sh.
#
# Контракт API: rc 0 — батарея зелёная; rc 1 — расхождение (стаб прошёл,
# честная упала или г0 «предмет отсутствует»); rc 2 — нечем проверить.
#
# Грамматика 038 / AGENTS.md:175 (guard=scripts/<имя>.sh); канал подключён
# прямым ci-шагом `bash scripts/check_github_token_070.sh` после шага семьи
# 060 в .github/workflows/ci.yml (прецедент 058/059/060).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"
RUNNER="$REPO_ROOT/fixtures/_krasnye_070.sh"
[ -f "$RUNNER" ] || { printf 'check_github_token_070: нет раннера %s\n' "$RUNNER" >&2; exit 2; }
exec bash "$RUNNER"
