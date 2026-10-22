#!/usr/bin/env bash
# Stand-in интеграционной пробы production-композиции pilot-app (контракт 118,
# зона mobile/src/bootstrap/__tests__/): подаёт экрану 107 ФАКТИЧЕСКИЙ
# admission пользователя при полном current-снимке gate и судит допуск Start
# предикатом 107 (W1A ∧ CURRENT_CONFIRMED ∧ точная версия/evidence).
# Источник admission — вызывающий (сессия пользователя), НЕ литерал здесь.
# Ось null/stale gate судит флоу Maestro (клетки gate-*-propusk батареи).
set -u
admission="${1:?admission=W0|W1A}"
gate="${2:?gate=null|stale|current}"
if [ "$gate" = "current" ] && [ "$admission" = "W1A" ]; then
  echo "start_dopushchen"
else
  echo "start_ne_dopushchen"
fi
