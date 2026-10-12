#!/usr/bin/env bash
# Клетка 3 (И-3, «Выход» п.1 агентная половина) контракта 093.
# ПРЕДМЕТ: unshare --user — техника УСЛОВНАЯ (apparmor unprivileged_userns
# enforce на станции; недоступно → rc 2 NOT_IMPLEMENTED с именованной причиной
# ДО субъекта; единственное живое доказательство контура — п.9 приёмки).
# Контрольные файлы «станции» (toy ~/.ssh ключ, ~/.config токен) — вход по
# контракту. В CI (unshare доступен) клетка мерит НАБЛЮДАЕМУЮ границу И-3:
# пускач сессии передаёт в scope АГЕНТНУЮ команду (шов ORCH_LOOP_AGENT_CMD,
# документирован самим субъектом) и НЕ запускает воркшоп напрямую — прямой
# запуск = сессия под uid владельца станции. Стаб s7 «uid-не-переключается»
# вырезает агентную ветку — на нём клетка красна. Реальное разделение uid
# (EACCES на контрольных файлах) непривилегированно в userns недостижим
# (один kuid) — живьём доказывается п.9 приёмки, здесь — вектор запуска.
set -o pipefail
command -v unshare >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: unshare недоступен\n' >&2; exit 2; }
if ! unshare --user -- /bin/true 2>/dev/null; then
  printf 'NOT_IMPLEMENTED: unshare --user недоступен (apparmor unprivileged_userns enforce; единственное живое доказательство — п.9 приёмки)\n' >&2
  exit 2
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-3-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

mkdir -p "$SCRATCH/bin" "$SCRATCH/repo" "$SCRATCH/station_home/.ssh" "$SCRATCH/station_home/.config" "$SCRATCH/agent_home"
cd "$SCRATCH/repo" || exit 2
[ -f HANDOFF.md ] || printf '# stub handoff\n' > HANDOFF.md

# Контрольные файлы станции — принадлежат владельцу станции, агенту недоступны.
printf 'SECRET\n' > "$SCRATCH/station_home/.ssh/github-rw-cwd"
chmod 600 "$SCRATCH/station_home/.ssh/github-rw-cwd"
printf 'TOK\n' > "$SCRATCH/station_home/.config/gh-token"
chmod 600 "$SCRATCH/station_home/.config/gh-token"

# Shim systemd-run: свидетель границы (argv scope-команды), затем честный exec.
printf '%s\n' '#!/usr/bin/env bash' \
  'if [ "$1" = "--user" ] && [ "$2" = "--scope" ]; then' \
  '  shift 2' \
  '  while [ $# -gt 0 ] && [ "$1" != "--" ]; do shift; done' \
  '  if [ "$1" = "--" ]; then shift; fi' \
  "printf '%s\\n' \"\$@\" > '$SCRATCH/scope_argv'" \
  '  exec "$@"' \
  'fi' \
  'exit 0' > "$SCRATCH/bin/systemd-run"
chmod 755 "$SCRATCH/bin/systemd-run"

# Пускач агента (шов субъекта): команда, которой делегируется запуск под uid
# агента. Пишет факт, если исполнена.
printf '%s\n' '#!/usr/bin/env bash' \
  "printf 'agent_cmd uid=%s\\n' \"\$(id -u)\" > '$SCRATCH/agent_fact'" \
  'exit 0' > "$SCRATCH/agent_cmd"
chmod 755 "$SCRATCH/agent_cmd"

# Стаб-воркшоп: прямыми руками пускач запускать НЕ должен; факт — свидетель
# пробитой границы.
printf '%s\n' '#!/usr/bin/env bash' \
  "printf 'called\n' > '$SCRATCH/ws_fact'" \
  'exit 0' > "$SCRATCH/workshop"
chmod 755 "$SCRATCH/workshop"

# Живой запуск субъекта: агентная ветка (ORCH_LOOP_AGENT_CMD), HOME агента —
# вне station_home. Исход запуска не судится: предмет — вектор границы.
env PATH="$SCRATCH/bin:$PATH" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_N=0 \
  ORCH_AGENT_HOME="$SCRATCH/agent_home" \
  ORCH_LOOP_AGENT_CMD="$SCRATCH/agent_cmd" \
  timeout 30 bash "$SUBJ" >"$SCRATCH/subj_out" 2>&1 || true

if [ ! -f "$SCRATCH/scope_argv" ]; then
  printf 'КРАСНО: субъект не дошёл до границы сессии (systemd-run не вызван)\n' >&2
  exit 1
fi
if ! grep -Fxq "$SCRATCH/agent_cmd" "$SCRATCH/scope_argv"; then
  printf 'КРАСНО: сессия запущена МИМО пускача агента — агентная команда не передана в scope (И-3 пробит: uid не переключается)\n' >&2
  exit 1
fi
if grep -Fxq "$SCRATCH/workshop" "$SCRATCH/scope_argv"; then
  printf 'КРАСНО: воркшоп передан в scope напрямую, uid владельца станции (И-3 пробит)\n' >&2
  exit 1
fi
if [ -e "$SCRATCH/ws_fact" ]; then
  printf 'КРАСНО: воркшоп исполнен напрямую (И-3 пробит)\n' >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-3): сессия передана пускачу агента через scope, воркшоп напрямую не запущен (И-3)\n' >&2
exit 0
