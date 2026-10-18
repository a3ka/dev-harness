#!/usr/bin/env bash
# Executable reference model, not production or an installer. Used only by probe.py.
set -u
cd "$ORCH_REPO" || exit 2
log() { printf '%s\n' "$*"; }
mkdir -p "$HOME/.local/state/dev-harness"
exec 9>"$HOME/.local/state/dev-harness/orch-loop.lock"
flock -n 9 || { log 'ОТКАЗ: orch-loop уже запущен'; exit 1; }
n=0; early=0
while :; do
  n=$((n+1)); start=$SECONDS
  rm -f "$ORCH_MARK" "$ORCH_MARK.go"
  log "сессия #$n: старт"
  # The watcher signals only the named toy scope through the systemctl shim.
  (
    exec 9>&-
    while sleep 0.05; do
      [ -e "$ORCH_MARK" ] || continue
      sleep "$ORCH_GRACE"
      [ -e "$ORCH_MARK" ] || continue
      touch "$ORCH_MARK.go"
      systemctl --user kill --signal=TERM "orch-session-$$-$n.scope"
      break
    done
  ) & watcher=$!
  # Pre-open an anonymous channel; the scope command remains a direct child.
  # cat only relays receipt bytes and cannot keep the singleton lock alive.
  coproc RECEIPT { exec 9>&-; cat; }
  receipt_pid=$RECEIPT_PID
  exec 7<&"${RECEIPT[0]}" 8>&"${RECEIPT[1]}"
  exec {RECEIPT[0]}<&- {RECEIPT[1]}>&-
  # Bash copies coproc FD_CLOEXEC on >& duplication. Reopen the anonymous fd
  # through /dev/fd below so the scope exec receives an inheritable descriptor.
  systemd-run --user --scope -q -p "MemoryMax=$ORCH_MEM_MAX" -p MemorySwapMax=0 \
    --unit="orch-session-$$-$n.scope" -- sh -c \
    'printf "SCOPED\n" >&3; exec 3>&-; if [ -n "$3" ]; then exec sudo -nu "$3" "$1" --yolo -- "$2"; fi; exec "$1" --yolo -- "$2"' \
    sh "$ORCH_LOOP_AGENT_CMD" 'toy startup' "${ORCH_AGENT_USER:-}" 3>/dev/fd/8 7<&- 8>&- 9>&-
  rc=$?
  exec 8>&-
  receipt=
  IFS= read -r receipt <&7 || receipt=
  exec 7<&-
  wait "$receipt_pid"
  kill "$watcher" 2>/dev/null || true
  wait "$watcher" 2>/dev/null || true
  if [ "$receipt" != SCOPED ]; then
    log "сессия #$n: запуск в scope не подтверждён — запуск без потолка запрещён (И-5, контракт 093)"
    exit 1
  fi
  log "сессия #$n: scope подтверждён (канал запуска); файловая метка не используется"
  if [ ! -e "$ORCH_MARK" ] && [ ! -e "$ORCH_MARK.go" ]; then
    if [ "$rc" -eq 0 ] || [ -e "$ORCH_STOP" ]; then exit "$rc"; fi
    early=$((early+1))
    [ "$early" -lt "$ORCH_EARLY_MAX" ] || { log 'цикл остановлен: предел нештатных завершений'; exit "$rc"; }
  elif [ "$((SECONDS-start))" -lt "$ORCH_MIN_LIFE" ]; then
    early=$((early+1))
    [ "$early" -lt "$ORCH_EARLY_MAX" ] || { log 'цикл остановлен: предел нештатных завершений'; exit 3; }
  else
    early=0
  fi
  sleep "$ORCH_EARLY_WAIT"
done
