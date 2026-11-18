#!/usr/bin/env bash
# Долгий сон листа (батарея 193): таймаут команды (s14, И3) и переживание
# TERM с добиванием SIGKILL по -k (s27, Б-4 Rev193). Ручка SPAT_IGNOR_TERM=1 —
# trap '' TERM: команда переживает TERM и живёт до KILL (клетка s27 обязана
# завершаться в пределах бюджета + KILL_SEK и краснеть на двери без -k).
if [ "${SPAT_IGNOR_TERM:-0}" = "1" ]; then trap '' TERM; fi
end=$((SECONDS+40))
while [ $SECONDS -lt $end ]; do sleep 1; done
exit 0
