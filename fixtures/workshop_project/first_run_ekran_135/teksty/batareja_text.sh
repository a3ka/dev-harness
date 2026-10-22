#!/usr/bin/env bash
# Батарея экрана first-run-ekran: сверка каждого кадра против PNG-макета —
# механизм 123 (мера и порог — манифест кадров пачки); литералы токенов —
# только в общем аудите токенов пакета Mobility Slice (audit_tokenov формы).
exec python3 .harness123/scripts/sverka_maketa.py --manifest .harness123/kadry.json --kadry mobile/maestro-out-first-run --repo .
