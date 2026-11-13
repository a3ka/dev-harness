#!/usr/bin/env bash
# load-nudge — сторож загрузки обеих сессий. Нормы — слово владельца 2026-11-11:
# станция 4 основных (2 харнес + 2 моб), бэкенд 3; сверх них — MiniMax-слот(ы).
# Раз в 120 с считает работающих субагентов на ЭКРАНЕ панели сессии: актуальный
# виджет «Subagents · N running», при его отсутствии — старый счёт по дереву ролей.
# Нераспознанная/нечитаемая панель — НЕ «0 агентов»: такт пропускается, счётчик
# простоя не растёт. Не подгоняет законное ожидание: верхний блок HANDOFF
# «ЖДЁТ ВЛАДЕЛЬЦА» (станция — HF чекаута, бэкенд — ЖИВОЙ пин-HF пин-worktree,
# не копия main) или у omp идёт дочерний инструмент. Ниже нормы три такта подряд
# (~6 мин) и ≥ 20 мин с прошлого толчка — напоминание в панель.
# Выключатели: /root/load-nudge.off (все) и /root/load-nudge.off.<имя>. Журнал:
# /root/load-nudge.log. Проекты — по cwd процесса omp (pane_of); номера панелей
# не сохраняются между запусками. Escape не посылается.
set -u
LOG=/root/load-nudge.log
. /root/nudge-lib.sh
declare -A LOW LAST
TARGETS="${LOAD_TARGETS:-station:/home/harness/dev-harness:4 back:/home/harness/projects/Complior-back:3}"
log() { echo "$(date -u +%FT%TZ) $*" >> "$LOG"; }
while sleep 120; do
  [ -e /root/load-nudge.off ] && continue
  for target in $TARGETS; do
    name=${target%%:*}; rest=${target#*:}; repo=${rest%:*}; norm=${rest##*:}
    [ -e "/root/load-nudge.off.$name" ] && continue
    pid=$(omp_pid_of "$repo") || true
    [ -n "$pid" ] || { LOW[$name]=0; continue; }
    p="$(pane_of "$repo")" || { LOW[$name]=0; continue; }
    if [ "$name" = back ]; then
      h=$(pin_handoff "$repo") || { log "$name: живой пин-HANDOFF не найден — такт пропущен"; LOW[$name]=0; continue; }
    else
      h="$repo/HANDOFF.md"
    fi
    waiting_owner "$h" && { LOW[$name]=0; continue; }
    has_job "$pid" && continue
    screen="$(tmux capture-pane -p -J -t "$p")" || continue
    n="$(printf '%s\n' "$screen" | grep -o -E 'Subagents · [0-9]+ running' | tail -1 | grep -o -E '[0-9]+')"
    if [ -z "$n" ]; then
      n="$(printf '%s\n' "$screen" | grep -c -E '^\s*[├└]─ .{0,8}[A-Za-z0-9_-]+ ⟨(architect|implementer|critic|reviewer|adversary|arbiter|task)⟩')"
      [ "$n" -gt 0 ] || { log "$name: панель не распознана — такт пропущен (не «0»)"; continue; }
    fi
    if [ "$n" -ge "$norm" ]; then LOW[$name]=0; continue; fi
    LOW[$name]=$(( ${LOW[$name]:-0} + 1 ))
    [ "${LOW[$name]}" -ge 3 ] || continue
    now=$(date +%s); [ $(( now - ${LAST[$name]:-0} )) -ge 1200 ] || continue
    msg="СТОРОЖ ЗАГРУЗКИ $(date -u +%H:%M) UTC: работает агентов: $n из $norm (уже ~6 мин). Норма владельца — $norm основных слотов + MiniMax-слот всё время. СЛЕДУЮЩИЕ ДЕЙСТВИЯ — спавны до полного состава по утверждённому плану (любой незаблокированный предмет: architect/критик/implementer/судья), разбор CI/HANDOFF — после. Предметы с живым замком умершего агента — после TTL, остальные — сейчас. Стабы к ветвям привязывает architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды. Продолжай работу, не жди моего ответа."
    printf '%s' "$msg" > /root/load-nudge.buf
    tmux load-buffer -b LOADN /root/load-nudge.buf && tmux paste-buffer -b LOADN -t "$p" && sleep 4 && tmux send-keys -t "$p" Enter
    LAST[$name]=$now; LOW[$name]=0
    log "толкнул $p: агентов $n из $norm"
  done
done
