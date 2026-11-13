#!/usr/bin/env bash
# back-nudge — сторож простоя сессии Complior-back (слово владельца 2026-10-21 ~23:25 UTC).
# От root, цикл 2 мин. Сессия молчит ≥ 25 мин и живых субагентов нет → напоминание в её
# панель (не чаще раза в 30 мин).
# Живой субагент — структурно: журнал субагента БЕЗ терминальной записи session_exit
# (JSON: type=custom, customType=session_exit) и обновлялся последние 30 мин. omp 18.18.8
# завершает субагентов session_exit «kind=normal» БЕЗ yield: литеральный подсчёт
# «последний инструмент ≠ yield → занят» держал завершённых агентов «живыми» 3 часа —
# убран. Тексты журналов не грепаются, только JSON-поля.
# Стартовый толчок — только если реальный launcher НЕ получил задание (сессия жива
# > 180 с, а журнала после её старта нет). Исправленный connect_project стартовое
# сообщение подаёт сам: дубль не нужен.
# Не подгоняет законное ожидание: верхний блок живого пин-HANDOFF «ЖДЁТ ВЛАДЕЛЬЦА»
# (пин-worktree, не копия main) или у omp идёт дочерний инструмент.
# Панель — pane_of по cwd процесса omp: сохранённых id (BACK_PANE и прочие) нет,
# чужую панель не пишем. Escape не посылается.
# Выключатель: touch /root/back-nudge.off. Журнал: /root/back-nudge.log.
set -u
LOG=/root/back-nudge.log
STAMP=/root/back-nudge.last
P=/home/harness/projects/Complior-back
H=/home/harness/.local/state/dev-harness-projects/complior-back/home
log() { echo "$(date -u +%FT%TZ) $*" >> "$LOG"; }
. /root/nudge-lib.sh
finished() { # $1 — журнал субагента → rc 0, если есть терминальная session_exit (структурно)
  jq -e 'select(.type == "custom" and .customType == "session_exit") | 1' "$1" >/dev/null 2>&1
}
while sleep 120; do
  [ -e /root/back-nudge.off ] && continue
  pid=$(omp_pid_of "$P"); [ -n "$pid" ] || continue
  PANE=$(pane_of "$P") || continue
  # стартовый толчок: журнал не появился за 180 с жизни процесса — задание не дошло
  st=$(stat -c %Y /proc/$pid); age=$(( $(date +%s) - st ))
  nj=$(find "$H"/.omp/profiles/dev/agent/sessions -maxdepth 2 -name '*.jsonl' -newer /proc/$pid 2>/dev/null | head -1)
  if [ "$age" -gt 180 ] && [ -z "$nj" ] && [ ! -e "/root/back-nudge.kick.$pid" ]; then
    tmux send-keys -t "$PANE" -l "АВТОПЕРЕЗАПУСК (автоматически): выполни стартап-протокол роли — HANDOFF «ГДЕ МЫ» и ROADMAP проекта, затем следующий шаг. Один рабочий агент на предмет, судья — после завершения держателя (omp 18.18.8: сдача — session_exit kind normal, yield у субагентов нет). Продолжай работу, не жди ответа."
    sleep 2; tmux send-keys -t "$PANE" Enter
    touch "/root/back-nudge.kick.$pid"; log "стартовый толчок pid $pid"
    continue
  fi
  if [ -e "$STAMP" ] && [ $(( $(date +%s) - $(stat -c %Y "$STAMP") )) -lt 1800 ]; then continue; fi
  h=$(pin_handoff "$P") || { log "живой пин-HANDOFF не найден — такт пропущен"; continue; }
  waiting_owner "$h" && continue
  has_job "$pid" && continue
  f=$(ls -t "$H"/.omp/profiles/dev/agent/sessions/*/*.jsonl 2>/dev/null | head -1); [ -n "$f" ] || continue
  age=$(( ($(date +%s) - $(stat -c %Y "$f")) / 60 ))
  [ "$age" -ge 25 ] || continue
  # квота GLM сессии не проверяется: оркестратор бэкенда на Terra (2026-11-06),
  # наблюдение квот — отдельный glm-critic-guard, остановок по квоте больше нет
  busy=0
  for a in $(ls -t "${f%.jsonl}"/*.jsonl 2>/dev/null | head -8); do
    finished "$a" && continue          # терминальная запись есть — агент завершён
    [ $(( ($(date +%s) - $(stat -c %Y "$a")) / 60 )) -lt 30 ] && busy=1
  done
  [ "$busy" = 0 ] || continue
  tmux send-keys -t "$PANE" -l "Сторож простоя (автоматически): сессия молчит ${age} мин без работающих субагентов. Сверь HANDOFF «ГДЕ МЫ» и ROADMAP, сделай следующий шаг (продуктовые и .harness-PR мёржишь сам по правилу: оба accept на head, CI зелёный, --match-head-commit, строка в HANDOFF; прецедент → steward, развилка → тир consultant, внешнего консультанта не ждёшь — roles/orchestrator.md §Автономия). Продолжай работу, не жди ответа."
  sleep 2; tmux send-keys -t "$PANE" Enter
  touch "$STAMP"; log "толкнул $PANE: молчит ${age} мин"
done
