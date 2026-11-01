# s11 — обман: недоступный systemctl ломает цикл (exit 2) вместо честной
# деградации к старому правилу rc. Наблюдаем: d05.
IMJA = 's11-degradacija-slomana'
ZAMENA = [
    ('orch',
     ('  unit_result="$(systemctl --user show "$SESSION_UNIT" --property=Result --value 2>/dev/null || true)"',
      '  unit_result="$(systemctl --user show "$SESSION_UNIT" --property=Result --value 2>/dev/null)" || { log "net systemctl"; exit 2; }')),
]
