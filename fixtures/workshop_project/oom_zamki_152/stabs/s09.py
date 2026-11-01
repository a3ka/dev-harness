# s09 — обман: факт oom-kill юнита выключен, литерал 085 живёт только на
# rc 137 (сегодняшнее поведение) — rc=143 при факте не маркируется.
# Наблюдаем: d01. d04 (137+факт) у стаба честен.
IMJA = 's09-fakt-vyklyuchen'
ZAMENA = [
    ('orch',
     ('  if [ "$unit_result" = "oom-kill" ] || { [ "$scoped" -eq 1 ] && [ "$rc" -eq 137 ]; }; then',
      '  if false && [ "$unit_result" = "oom-kill" ] || { [ "$scoped" -eq 1 ] && [ "$rc" -eq 137 ]; }; then')),
]
