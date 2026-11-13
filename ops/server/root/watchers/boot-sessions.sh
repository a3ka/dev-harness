#!/usr/bin/env bash
# boot-sessions — подъём рабочих сессий и сторожей после перезагрузки (слово владельца
# 2026-11-10 «да»). Запускается systemd-юнитом dev-harness-sessions.service (root).
# Канон — ops/server/root/watchers/ в репо (ставит ops/server/install.sh root, сверка —
# verify); правки на станции не живут. Раскладка владельца: tmux-сессия work, окно
# sessions: слева сверху — станция (orch-loop), слева снизу — моб (оболочка, сессия на
# паузе), справа во всю высоту — бэкенд (back-loop). Сторожа — сессия consultant, по
# окну на каждого. Адресация панелей — динамическая (pane_of в самих сторожах по cwd
# процесса omp): сохранить id панелей нельзя (su -P даёт другой pts), переменные
# NUDGE_PANE/BACK_PANE/LOAD_PANES/ST_PANE/BK_PANE не передаются.
# Режим проверки: BOOT_TEST=1 — та же раскладка с заглушками вместо сессий, имена
# work-test/consultant-test. Стоп-файлы ~/orch-loop.stop и ~/back-loop.stop
# уважаются самими циклами (не снимаются здесь).
set -u
LOG=/root/boot-sessions.log
log() { echo "$(date -u +%FT%TZ) $*" >> "$LOG"; }
T=${BOOT_TEST:-0}
W=main; C=consultant
if [ "$T" = 1 ]; then W=work-test; C=consultant-test; fi
if tmux list-windows -t "$W" -F "#{window_name}" 2>/dev/null | grep -qx sessions; then log "сессия $W с окном sessions уже есть — выход"; exit 0; fi
# вход владельца раньше службы: .bashrc создал пустую main — переименовать, раскладку строим в main
if tmux has-session -t "$W" 2>/dev/null; then tmux rename-session -t "$W" "$W-shell"; log "пустая $W → $W-shell"; fi
log "старт (test=$T)"
if [ "$T" != 1 ]; then
  for i in $(seq 1 30); do getent hosts github.com >/dev/null 2>&1 && break; sleep 2; done
  runuser -u harness -- mkdir -p /tmp/dev-harness-verify /tmp/dev-harness-worktrees
  for r in /home/harness/dev-harness /home/harness/projects/Complior-back /home/harness/projects/Complior-mob; do
    runuser -u harness -- git -C "$r" worktree prune 2>>"$LOG"
  done
  # GLM-прокси 8770/8771 (zai-failover; сессии tmux пользователя harness) — ДО сессий: без
  # них GLM «Connection error» и тиры уходят на OpenAI (инцидент 10–11.11). Вне репо.
  runuser -u harness -- bash /home/harness/consultant/zf-restart.sh >> "$LOG" 2>&1
  STATION="su -P - harness -c 'cd /home/harness/dev-harness && /home/harness/dev-harness/ops/server/user/orch-loop'"
  MOB="su -P - harness -c 'cd /home/harness/projects/Complior-mob && exec bash -l'"
  BACK="su -P - harness -c 'bash ~/back-loop.sh'"
else
  STATION="bash -c 'echo station-stub; exec sleep 600'"
  MOB="bash -c 'echo mob-stub; exec sleep 600'"
  BACK="bash -c 'echo back-stub; exec sleep 600'"
fi
P1=$(tmux new-session -d -P -F '#{pane_id}' -s "$W" -n sessions -x 210 -y 55 "$STATION")
P3=$(tmux split-window -P -F '#{pane_id}' -h -f -t "$P1" "$BACK")
P2=$(tmux split-window -P -F '#{pane_id}' -v -t "$P1" "$MOB")
tmux select-pane -t "$P1"
log "панели: станция=$P1 моб=$P2 бэкенд=$P3"
if [ "$T" != 1 ]; then
  # Сторожа из репо (root/watchers): панели находят сами (pane_of), env-пиннинга нет.
  # glm-guard снят (замена — glm-critic-guard: наблюдение без остановок, слово владельца
  # 2026-11-12). zf-heal и janitor — механизмы консультанта вне репо (см. README).
  N1="while true; do bash /root/orch-nudge.sh; sleep 120; done"
  N2="bash /root/back-nudge.sh"
  N3="bash /root/glm-critic-guard.sh; sleep 3600"
  N4="bash /root/zf-heal.sh"
  N5="bash /root/load-nudge.sh"
  N6="su -P - harness -c 'bash /home/harness/manifest-janitor.sh'"
else
  N1="sleep 600"; N2="sleep 600"; N3="sleep 600"; N4="sleep 600"; N5="sleep 600"; N6="sleep 600"
fi
tmux new-session -d -s "$C" -n nudge-station "$N1"
tmux new-window -t "$C": -n backnudge "$N2"
tmux new-window -t "$C": -n glmcritic "$N3"
tmux new-window -t "$C": -n zfheal "$N4"
tmux new-window -t "$C": -n loadnudge "$N5"
tmux new-window -t "$C": -n janitor "$N6"
if [ "$T" != 1 ]; then tmux new-window -t "$C": -n glmwindow "bash /root/glm-window.sh; sleep 600"; fi
log "готово: $(tmux list-windows -t "$C" | wc -l) окон сторожей"
