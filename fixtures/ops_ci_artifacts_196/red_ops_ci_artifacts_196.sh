#!/usr/bin/env bash
# Раннер красной/зелёной пачки 196 «локальное хранилище артефактов CI станции».
#
# Использование:
#   bash fixtures/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --model   # честная модель: все клетки зелёные
#   bash fixtures/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --stabs   # каждый обманный стаб пойман
#   bash fixtures/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh           # суд реального субъекта (ops/server)
#   bash fixtures/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh --repo <корень>
#
# rc: 0 — зелёный итог режима; 1 — красная клетка или живой стаб; 2 — нечем
# проверять. До реализации субъекта (ops/server/root/ci-artifacts-clean,
# install.sh artifacts) голый вызов ЧЕСТНО КРАСНЫЙ именем отсутствующего
# субъекта — гвард подключается в CI после реализации (прецедент 093).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/probe.py" "$@"
