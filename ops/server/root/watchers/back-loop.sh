#!/usr/bin/env bash
# back-loop — автоперезапуск сессии Complior-back (слово владельца 2026-10-21 ~23:25 UTC).
# Запуск в панели сессии: bash ~/back-loop.sh (подъём — boot-sessions). Стоп:
# touch ~/back-loop.stop. Журнал: ~/back-loop.log. Мягкий перезапуск: сессия делает
# чекпойнт HANDOFF и `touch /tmp/dev-harness-verify/back-restart` (ФАЙЛ). Сторож
# простоя — отдельно, от root: /root/back-nudge.sh (tmux-сервер панелей — root).
#
# Singleton (прецедент orch-loop, контракт 997 инв. 5): flock -n на каноническом
# пути $HOME/.local/state/dev-harness/back-loop.lock, fd 9, ДО всего, что меняет
# состояние; второй экземпляр — именованный отказ rc 1. fd 9 закрывается ВНУТРИ
# тела наблюдателя отдельной строкой `exec 9>&-` (осиротевший наблюдатель не несёт
# lock после гибели родителя дольше одного цикла сна) и в дочерней сессии
# (subshell запуска connect_project): осиротевшая сессия omp не держит lock
# следующего back-loop.
#
# Сессия запускается существующей дверью scripts/connect_project.sh (репо харнесса)
# с фактическим оверлеем консультанта models-sol-arch.yml (default: @gpt-terra —
# слово владельца 2026-11-12; принудительный architect→Sol 2026-11-04 снят словом
# владельца 2026-11-11 — устаревший forced-slow Sol не воспроизводится). Оверлей и
# обёртка — вне репо, содержимое управляется владельцем (см. ops/server/README.md).
set -u
P=/home/harness/projects/Complior-back
H=/home/harness/.local/state/dev-harness-projects/complior-back/home
MARK=/tmp/dev-harness-verify/back-restart
LOG=$HOME/back-loop.log
REPO="${BACK_REPO:-$HOME/dev-harness}"
WORKSHOP_WRAPPER="${BACK_WORKSHOP:-/home/harness/consultant/workshop-sol.sh}"
log() { echo "$(date -u +%FT%TZ) $*" | tee -a "$LOG"; }
mkdir -p "$HOME/.local/state/dev-harness"
LOCKF="$HOME/.local/state/dev-harness/back-loop.lock"
exec 9>>"$LOCKF"
flock -n 9 || { log "ОТКАЗ: back-loop уже запущен"; exit 1; }
omp_pid() { for p in $(pgrep -f '^omp --profile'); do [ "$(readlink /proc/$p/cwd)" = "$P" ] && echo "$p"; done; }

watcher() {
  while sleep 30; do
    exec 9>&-   # singleton: lock-fd закрыт в теле наблюдателя (прецедент orch-loop, 997)
    pid=$(omp_pid); [ -n "$pid" ] || continue
    if [ -f "$MARK" ]; then
      rm -f "$MARK"; log "маркер: мягкий перезапуск pid $pid"
      kill -TERM "$pid"
    fi
  done
}
watcher &
WPID=$!
trap 'kill $WPID 2>/dev/null' EXIT

early=0; n=0
while :; do
  [ -e "$HOME/back-loop.stop" ] && { log "стоп по ~/back-loop.stop"; exit 0; }
  if [ -n "$(omp_pid)" ]; then sleep 20; continue; fi
  n=$((n+1)); log "сессия back #$n: старт"
  t0=$(date +%s)
  ( exec 9>&-; cd "$REPO" && S136_WORKSHOP="$WORKSHOP_WRAPPER" bash scripts/connect_project.sh "$P" ); rc=$?
  life=$(( $(date +%s) - t0 ))
  log "сессия back #$n: выход rc=$rc через ${life}с"
  if [ "$life" -lt 120 ]; then early=$((early+1)); else early=0; fi
  [ "$early" -ge 3 ] && { log "3 ранних выхода подряд — стоп"; exit 1; }
  sleep 30
done
