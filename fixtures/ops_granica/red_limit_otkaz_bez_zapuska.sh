#!/usr/bin/env bash
# Клетка 2 (И-5, «Выход» п.5) контракта 093.
# ПРЕДМЕТ: orch-loop на toy-мире, systemd-run-шим в PATH субъекта отказывает
# создавать scope (свидетель $RAN не пишется), стаб-воркшоп пишет факт вызова.
# На фикс: субъект rc 1 с именованным отказом «ресурсный предел не создан —
# запуск без потолка запрещён», стаб-воркшоп НЕ исполнен. Обманный стаб s1
# «фолбэк-без-потолка» (battery_stubs.sh) возвращает удалённую ветку — на нём
# клетка красна: воркшоп исполнен без потолка (Н-39: стаб к входу, где дефект
# наблюдаем).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-2-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

mkdir -p "$SCRATCH/bin" "$SCRATCH/repo"
cd "$SCRATCH/repo" || exit 2
[ -f HANDOFF.md ] || printf '# stub handoff\n' > HANDOFF.md

# Shim systemd-run: ОТКАЗЫВАЕТ создавать scope — exit 1 без exec, свидетель
# $RAN не пишется (вход клетки по контракту 093 §Клетки п.2).
printf '%s\n' '#!/usr/bin/env bash' \
  'if [ "$1" = "--user" ] && [ "$2" = "--scope" ]; then' \
  '  exit 1' \
  'fi' \
  'exit 0' > "$SCRATCH/bin/systemd-run"
chmod 755 "$SCRATCH/bin/systemd-run"

# Стаб-воркшоп: пишет факт вызова (наблюдаемая «сессия запущена»).
printf '%s\n' '#!/usr/bin/env bash' \
  "printf 'called\n' > '$SCRATCH/ws_fact'" \
  'exit 0' > "$SCRATCH/workshop"
chmod 755 "$SCRATCH/workshop"

# Живой запуск субъекта: отказ scope → именованный отказ, воркшоп не исполнен.
env PATH="$SCRATCH/bin:$PATH" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_N=0 \
  timeout 30 bash "$SUBJ" >"$SCRATCH/subj_out" 2>&1
rc=$?

if [ "$rc" -ne 1 ]; then
  printf 'КРАСНО: orch-loop rc=%s при отказе scope, ожидался именованный отказ rc 1 (И-5); вывод: %s\n' \
    "$rc" "$(cat "$SCRATCH/subj_out" 2>/dev/null)" >&2
  exit 1
fi
if ! grep -Fq 'ресурсный предел не создан' "$SCRATCH/loop.log" 2>/dev/null; then
  printf 'КРАСНО: нет именованного отказа «ресурсный предел не создан» в журнале субъекта (И-5)\n' >&2
  exit 1
fi
if [ -e "$SCRATCH/ws_fact" ]; then
  printf 'КРАСНО: фолбэк — сессия запущена без потолка, стаб-воркшоп исполнен (И-5 пробит)\n' >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-2): отказ scope → именованный отказ rc 1, воркшоп не исполнен (И-5)\n' >&2
exit 0
