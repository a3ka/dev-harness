# ПРИЧИНА: неизвестный класс
#
# Дефект `next_id.sh`: класс, которого нет в PLAN/VERDICT/ADR, должен отказать с названной
# причиной. Положительный контроль: PLAN — зелёный (печатает номер). Красное: FOO — отказ.
set -euo pipefail

cd "$WORK"
git init -q .
git config user.email "fixture@test"
git config user.name "fixture"
mkdir -p plans

# Положительный контроль: валидный класс — барьер печатает номер, код 0.
BARRIER_ROOT="$WORK" "$BARRIER" PLAN

# Вносим обман: несуществующий класс.
BARRIER_ROOT="$WORK" "$BARRIER" FOO