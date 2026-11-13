#!/usr/bin/env bash
# orch-nudge — сторож простоя оркестратора станции (слово владельца 2026-10-21 ~14:45 UTC
# «надо как-то эти простои починить»). Временная механика до предмета харнесса wait-guard.
# Один такт (цикл снаружи, boot-sessions): оркестратор в «wait» или в тишине у приглашения
# ≥ NUDGE_IDLE_MIN мин, и на табло строки СТОИТ старше NUDGE_MIN мин → список строк
# в панель. Не чаще раза в NUDGE_GAP секунд. Escape не посылается: сообщение встаёт
# в очередь, инструмент не прерывается.
# Панель — pane_of по cwd процесса omp: сохранённых id нет, чужую панель не пишем.
# Выключатель: touch /root/orch-nudge.off. Журнал: /root/orch-nudge.log.
set -u
. /root/nudge-lib.sh
REPO="${NUDGE_REPO:-/home/harness/dev-harness}"
PANE="$(pane_of "$REPO")" || exit 0
MIN=${NUDGE_MIN:-8}
GAP=${NUDGE_GAP:-600}
LOG=/root/orch-nudge.log
STAMP=/root/orch-nudge.last
log() { echo "$(date -u +%FT%TZ) $*" >> "$LOG"; }
[ -e /root/orch-nudge.off ] && exit 0
waiting_owner "$REPO/HANDOFF.md" && exit 0
op=$(omp_pid_of "$REPO"); [ -n "$op" ] && has_job "$op" && exit 0
if [ -e "$STAMP" ] && [ $(( $(date +%s) - $(stat -c %Y "$STAMP") )) -lt "$GAP" ]; then exit 0; fi
head=$(runuser -u harness -- bash "$NL_HARNESS/consultant/station-check.sh" 2>/dev/null | head -4)
last=$(printf '%s\n' "$head" | sed -n 's/^последний вызов: //p')
# 2026-11-06: ночь 06.11 показала — сессия, закончившая ход у приглашения (не в wait),
# простояла 5 ч: сторож молчал. Толкаем и простой у приглашения ≥ NUDGE_IDLE_MIN мин
# (нет журнала сессии свежее этого окна). Сессии станции — все поколения, без хардкода
# текущего каталога-хэша (та же маска, что и в ops/server/install.sh).
IDLE_MIN=${NUDGE_IDLE_MIN:-20}
SESS="$NL_HARNESS/.local/state/dev-harness-sessions"
case "$last" in
  wait*) ;;
  *)
    nf=$(find "$SESS"/*/zones/dev/.omp/profiles/dev/agent/sessions -maxdepth 3 -name '*.jsonl' -mmin -"$IDLE_MIN" 2>/dev/null | head -1)
    [ -z "$nf" ] || exit 0
    last="ход окончен у приглашения, тишина ≥ $IDLE_MIN мин"
    ;;
esac
tablo=$(runuser -u harness -- python3 "$REPO/ops/server/user/orch-tablo" 2>/dev/null)
lines=$(printf '%s\n' "$tablo" | awk -v min="$MIN" '/^  СТОИТ [0-9]+ мин/ { if ($2+0 >= min) print; next } /^  СТОИТ ПОТОК / { m=$0; sub(/.* — /,"",m); if (m+0 >= min) print }' | head -12)
# 2026-11-07 (слово владельца «да»): строки моба под СТОПом владельца не толкаем.
lines=$(printf "%s\n" "$lines" | grep -v -E "PR Complior-mob#|ПОТОК mob" || true)
[ -n "$lines" ] || exit 0
n=$(printf '%s\n' "$lines" | wc -l)
msg="Сторож простоя (автоматически): ты в wait («$last»), а на табло $n строк СТОИТ от $MIN мин:
$lines
Сделай следующий шаг по каждой строке, wait — только когда готового к ходу нет. Продолжай работу, не жди ответа."
f=/root/orch-nudge.msg
printf '%s\n' "$msg" > "$f"
tmux load-buffer -b nudge "$f" && tmux paste-buffer -b nudge -t "$PANE" -p && sleep 2 && tmux send-keys -t "$PANE" Enter
touch "$STAMP"
log "толкнул $PANE: $n строк; wait=«$last»"
