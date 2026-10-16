#!/usr/bin/env bash
# Клетка 3 (И-3, «Выход» п.1 агентная половина) контракта 093.
# ПРЕДМЕТ (починка Р1-4 круга 1): клетка обязана краснеть, когда из пускача
# вырезано переключение uid (мутант «без sudo -nu», стаб s7). Прежняя
# редакция мерила только argv шва ORCH_LOOP_AGENT_CMD на границе scope и
# такой мутант пропускала. Теперь наблюдение — сама дверь uid: sudo-шим в
# PATH субъекта моделирует доку переключения `sudo -nu <агент> <cmd>`:
# пишет свидетель (цель + команда), закрывает HOME станции (модель
# uid≠владельца: второй kuid в toy-мире непривилегированно недостижим —
# арбитраж 093, замер 3) и исполняет агентную команду. Честный код: сессия
# идёт через доку, чтение/запись контрольных файлов станции — отказ ОС,
# воркшоп напрямую не исполнен. Мутант без sudo / стаб s7: команда
# исполняется напрямую под uid владельца станции — дока не вызвана,
# контрольные файлы читаются/пишутся → КРАСНО своим предъявлением.
# unshare-пролог — условная техника контракта (замер 3): недоступно →
# rc 2 с именованной причиной ДО запуска субъекта.
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
trap 'chmod -R u+rwx "$SCRATCH/station_home" 2>/dev/null; rm -rf "$SCRATCH"' EXIT

mkdir -p "$SCRATCH/bin" "$SCRATCH/repo" "$SCRATCH/station_home/.ssh" "$SCRATCH/station_home/.config" "$SCRATCH/agent_home"
cd "$SCRATCH/repo" || exit 2
[ -f HANDOFF.md ] || printf '# stub handoff\n' > HANDOFF.md

# Контрольные файлы «станции»: владелец — uid клетки («владелец станции»
# toy-мира). Агентная сессия обязана их НЕ читать и НЕ писать.
printf 'SECRET\n' > "$SCRATCH/station_home/.ssh/github-rw-cwd"
printf 'TOK\n' > "$SCRATCH/station_home/.config/gh-token"
chmod 600 "$SCRATCH/station_home/.ssh/github-rw-cwd" "$SCRATCH/station_home/.config/gh-token"
chmod 700 "$SCRATCH/station_home" "$SCRATCH/station_home/.ssh" "$SCRATCH/station_home/.config"
STATION_OWNER="$(id -un)"

# Shim systemd-run (граница scope): свидетель argv после `--`, честный exec.
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

# Shim sudo — ДВЕРЬ uid (наблюдение клетки, починка Р1-4): честный пускач
# передаёт сессию доке `sudo -nu <user> <cmd>`; шим пишет свидетель (цель,
# команда), закрывает HOME станции (модель uid≠владельца: реальный второй
# kuid непривилегированно недостижим, арбитраж 093 замер 3) и исполняет
# команду. Мутант «вырезать sudo -nu» доку не вызывает — свидетеля нет.
printf '%s\n' '#!/usr/bin/env bash' \
  'set -u' \
  'if [ "${1:-}" = "-nu" ] && [ $# -ge 3 ]; then' \
  '  tgt="$2"; shift 2' \
  "  printf 'user=%s\\nargv0=%s\\n' \"\$tgt\" \"\$1\" > '$SCRATCH/sudo_fact'" \
  "  chmod 000 '$SCRATCH/station_home'" \
  '  exec "$@"' \
  'fi' \
  'printf "sudo-шим: ожидается -nu <user> <cmd>\\n" >&2' \
  'exit 1' > "$SCRATCH/bin/sudo"
chmod 755 "$SCRATCH/bin/sudo"

# Агентная команда (шов ORCH_LOOP_AGENT_CMD субъекта): пытается читать и
# писать контрольные файлы станции. Успех любой пробы = сессия под uid
# владельца станции.
printf '%s\n' '#!/usr/bin/env bash' \
  "R='$SCRATCH/station_home/.ssh/github-rw-cwd'" \
  "W='$SCRATCH/station_home/.config/agent_write_probe'" \
  "cat \"\$R\" >/dev/null 2>&1 && printf 'read_ok\\n' >> '$SCRATCH/canary_witness'" \
  ": > \"\$W\" 2>/dev/null && printf 'write_ok\\n' >> '$SCRATCH/canary_witness'" \
  "printf 'agent uid=%s\\n' \"\$(id -u)\" > '$SCRATCH/agent_fact'" \
  'exit 0' > "$SCRATCH/agent_cmd"
chmod 755 "$SCRATCH/agent_cmd"

# Стаб-воркшоп: прямой запуск пускачом — свидетель пробитой границы.
printf '%s\n' '#!/usr/bin/env bash' \
  "printf 'called\\n' > '$SCRATCH/ws_fact'" \
  'exit 0' > "$SCRATCH/workshop"
chmod 755 "$SCRATCH/workshop"

# Живой запуск субъекта: агентная ветка (ORCH_LOOP_AGENT_CMD), HOME агента —
# вне station_home. Исход запуска не судится: предмет — вектор границы.
env PATH="$SCRATCH/bin:$PATH" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_N=0 \
  ORCH_AGENT_HOME="$SCRATCH/agent_home" ORCH_AGENT_USER=orchagent \
  ORCH_LOOP_AGENT_CMD="$SCRATCH/agent_cmd" \
  timeout 30 bash "$SUBJ" >"$SCRATCH/subj_out" 2>&1 || true
chmod 700 "$SCRATCH/station_home" 2>/dev/null || true

if [ ! -f "$SCRATCH/scope_argv" ]; then
  printf 'КРАСНО: субъект не дошёл до границы сессии (systemd-run не вызван)\n' >&2
  exit 1
fi
if [ ! -f "$SCRATCH/sudo_fact" ]; then
  printf 'КРАСНО: сессия запущена МИМО двери uid — sudo -nu не вызван пускачом, переключения uid нет (И-3 пробит: мутант без sudo -nu / стаб s7)\n' >&2
  exit 1
fi
if grep -Fxq "user=$STATION_OWNER" "$SCRATCH/sudo_fact"; then
  printf 'КРАСНО: дверь uid вызвана на владельца станции %s — uid не переключается (И-3 пробит)\n' "$STATION_OWNER" >&2
  exit 1
fi
if ! grep -Fxq "argv0=$SCRATCH/agent_cmd" "$SCRATCH/sudo_fact"; then
  printf 'КРАСНО: агентная команда не передана в дверь uid (И-3)\n' >&2
  exit 1
fi
if [ ! -f "$SCRATCH/agent_fact" ]; then
  printf 'КРАСНО: дверь uid не довела до агентной команды (И-3)\n' >&2
  exit 1
fi
if [ -e "$SCRATCH/ws_fact" ]; then
  printf 'КРАСНО: воркшоп исполнен напрямую, uid владельца станции (И-3 пробит)\n' >&2
  exit 1
fi
if [ -s "$SCRATCH/canary_witness" ]; then
  printf 'КРАСНО: контрольные файлы станции доступны сессии — чтение/запись под uid владельца станции (И-3 пробит): %s\n' \
    "$(tr '\n' ' ' < "$SCRATCH/canary_witness")" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-3): сессия через дверь uid (sudo -nu <агент>), контрольные файлы станции недоступны (И-3)\n' >&2
exit 0
