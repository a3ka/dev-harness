# s10 — обман: литерал OOM пишется всегда при scoped — ложная маркировка
# без факта. Наблюдаем: d03 (143, факта нет) и d05 (systemctl недоступен).
IMJA = 's10-oom-vsegda'
ZAMENA = [
    ('orch',
     ('  if [ "$unit_result" = "oom-kill" ] || { [ "$scoped" -eq 1 ] && [ "$rc" -eq 137 ]; }; then',
      '  if [ "$scoped" -eq 1 ]; then')),
]
