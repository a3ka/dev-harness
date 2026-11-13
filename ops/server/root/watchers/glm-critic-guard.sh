#!/usr/bin/env bash
# glm-critic-guard — наблюдение квот GLM (замена glm-guard; слово владельца
# 2026-11-12: при исчерпании квоты — переход на OpenAI средствами omp по registry,
# а НЕ остановка сессий). Единственный поддерживаемый наблюдатель квот: старый
# glm-guard гасил load/back-будильники на 90% недели и читал недельные 100% как
# 5-часовое окно — снят (окно «glmguard» больше не поднимается boot-sessions).
# Каждый цикл (300 с) читает ОБА окна квот z.ai по каждому ключу РАЗДЕЛЬНО:
# 5-часовое (number=5/unit=3) и недельное (number=1/unit=6) — quota_windows,
# неполный ответ = «unknown», доступной квотой не объявляется.
# НЕ останавливает сессии, НЕ пишет «слово владельца STOP», НЕ меняет модели:
# разрешённый автофолбек делает omp по registry. Ключи не выводятся.
# Выключатель: touch /root/glm-critic-guard.off. Журнал: /root/glm-critic-guard.log.
set -u
. /root/nudge-lib.sh
LOG=/root/glm-critic-guard.log
C=/home/harness/.config/dev-harness
log() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" | tee -a "$LOG"; }
windows() { # $1 — файл ключа → «<5ч %> <неделя %>» (quota_windows) или отказ
  local key
  key=$(grep '^ZAI_API_KEY=' "$1" | cut -d= -f2- | tr -d '"'"'"' ')
  [ -n "$key" ] || return 1
  curl --fail --silent --max-time 20 -H "Authorization: Bearer $key" \
    https://api.z.ai/api/monitor/usage/quota/limit | quota_windows
}
last=''
while :; do
  [ -e /root/glm-critic-guard.off ] && { log "выключен /root/glm-critic-guard.off"; exit 0; }
  a=$(windows "$C/secrets.env") || a=unknown
  b=$(windows "$C/zai-b.env") || b=unknown
  state="A=$a B=$b"
  if [ "$state" != "$last" ]; then
    log "$state (два числа: 5ч, неделя); автопереход обслуживает omp по registry, остановки нет"
    last="$state"
  fi
  sleep 300
done
