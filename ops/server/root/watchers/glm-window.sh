#!/usr/bin/env bash
# Слово владельца 2026-11-09 ~01:45 UTC: «глм с 7.00 до 11.00 должен быть опять
# заменен на модель от опенИИ». Окно 06:00–10:00 UTC (= 07:00–11:00 владельца, UTC+1;
# совпадает с пиком z.ai 14–18 UTC+8). График — РОВНО этот, ежедневно:
#   06:00 UTC — тиры GLM (apex-sol = критик, task-glm = implementer-glm) → Terra:
#     оверлей-источник консультанта + живые развёрнутые оверлеи сессий + сообщение
#     обеим сессиям;
#   10:00 UTC — снятие ТОЛЬКО собственных строк (метка «окно GLM 06–10 UTC»),
#     чужие строки оверлея не трогаются.
# Значение Terra — из config/agent_models.json репо харнесса (семейство gpt-terra,
# тот же источник, что и резолвером connect_project): литералов версии в скрипте
# нет. Реестр не читается — окно не включается (никакой самодеятельной модели).
# Панели — pane_of по cwd omp: сохранённых id (ST_PANE/BK_PANE) нет; нет панели —
# сообщение пропускается, в чужую панель не пишем. Escape не посылается.
# Выключатель: touch /root/glm-window.off. Журнал: /root/glm-window.log.
set -u
. /root/nudge-lib.sh
LOG=/root/glm-window.log
SRC=/home/harness/consultant/models-sol-arch.yml
REPO="${GLM_WINDOW_REPO:-/home/harness/dev-harness}"
log() { echo "$(date -u +%FT%TZ) $*" >> "$LOG"; }
TERRA=$(jq -er '.models["gpt-terra"]' "$REPO/config/agent_models.json" 2>/dev/null) || {
  printf 'ОТКАЗ: семейство gpt-terra не читается из %s/config/agent_models.json — окно не включается\n' "$REPO" >&2
  exit 1
}
until_utc() { local now tgt; now=$(date -u +%s); tgt=$(date -u -d "$1" +%s); [ "$tgt" -le "$now" ] && tgt=$((tgt+86400)); sleep $((tgt-now)); }
live_overlays() { find /home/harness/.local/state -maxdepth 7 -name 'models-overlay*.yml' -mmin -1440 2>/dev/null; }
say() { # <repo> <file>: сообщение в панель сессии проекта; нет панели — пропуск, не чужая
  local p; p=$(pane_of "$1") || { log "нет панели $1 — сообщение пропущено"; return 0; }
  [ -f "$2" ] || { log "нет файла сообщения $2 — сообщение пропущено"; return 0; }
  tmux load-buffer -b GW "$2" && tmux paste-buffer -b GW -t "$p" && sleep 4 && tmux send-keys -t "$p" Enter
}
on() {
  sudo -u harness cp -a "$SRC" "$SRC.bak-glmwin"
  # источник-оверлей консультанта ведёт семейные ссылки (@gpt-terra); развёрнутые
  # оверлеи сессий — разрешённые значения из реестра (t)
  sudo -u harness python3 - "$SRC" <<'EOF'
import sys
p = sys.argv[1]
s = open(p, encoding='utf8').read()
add = '  apex-sol: "@gpt-terra"  # окно GLM 06–10 UTC\n  task-glm: "@gpt-terra"  # окно GLM 06–10 UTC\n'
if 'окно GLM 06–10 UTC' not in s:
    s = s.rstrip('\n') + '\n' + add
open(p, 'w', encoding='utf8').write(s)
EOF
  for f in $(live_overlays); do
    sudo -u harness python3 - "$f" "$TERRA" <<'EOF'
import sys
p, t = sys.argv[1], sys.argv[2]
s = open(p, encoding='utf8').read()
if 'окно GLM 06–10 UTC' not in s:
    s = s.rstrip('\n') + f'\n  apex-sol: "{t}"  # окно GLM 06–10 UTC\n  task-glm: "{t}"  # окно GLM 06–10 UTC\n'
open(p, 'w', encoding='utf8').write(s)
EOF
    log "ON живой оверлей: $f"
  done
  say /home/harness/dev-harness /root/glmwin-on.txt; say /home/harness/projects/Complior-back /root/glmwin-on.txt
  log "ON: окно GLM→Terra ($TERRA) включено"
}
off() {
  for f in "$SRC" $(live_overlays); do
    sudo -u harness python3 - "$f" <<'EOF'
import sys
p = sys.argv[1]
s = open(p, encoding='utf8').read()
s = ''.join(l for l in s.splitlines(True) if 'окно GLM 06–10 UTC' not in l)
open(p, 'w', encoding='utf8').write(s)
EOF
    log "OFF: $f"
  done
  say /home/harness/dev-harness /root/glmwin-off.txt; say /home/harness/projects/Complior-back /root/glmwin-off.txt
  log "OFF: окно GLM→Terra выключено (сняты только собственные строки)"
}
log "старт: Terra=$TERRA (из реестра), ждёт 06:00 UTC"
while :; do
  [ -e /root/glm-window.off ] && { log "выключен /root/glm-window.off"; exit 0; }
  until_utc "06:00"; on
  [ -e /root/glm-window.off ] && { log "выключен /root/glm-window.off"; exit 0; }
  until_utc "10:00"; off
done
