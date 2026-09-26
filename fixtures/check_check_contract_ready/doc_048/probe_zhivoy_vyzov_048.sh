#!/usr/bin/env bash
# Проба Д12 контракта 048: живой вызов барьера семьи check_contract_ready
# (спек-гейт 036 В4-2/В4-3) — 048 переиспользует fixtures-каталог этой семьи
# для калибровки (Н-155), барьер сам не правит, поэтому обязан доказать
# argv-совместимость живым вызовом.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
exec bash "$HERE/scripts/check_check_contract_ready.sh"
