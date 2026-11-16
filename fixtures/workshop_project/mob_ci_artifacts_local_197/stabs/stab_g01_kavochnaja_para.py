#!/usr/bin/env python3
# Стаб 197-g01 (мутация критика MX1q): литеральная пара чужого прогона за
# кавычной охраной run-текста — `test "$OK" = 1 && npm run … --run-id
# 43752095485 --run-attempt 1`. Запрещённая оболочка вызова (оператор
# композиции) отсекается замкнутой грамматикой ДО проверки происхождения
# c03 (арбитраж 197, РЕШЕНИЕ 2.3). Дефект наблюдаем на клетке
# g01-forma-nositelja.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = """      - name: Download child evidence
        if: always()
        working-directory: ${{ github.workspace }}
        run: npm run ci:artefakt-chtenie -- --shablon 'screen-evidence-*' --kuda mobile/screen-evidence-collected
"""
novyj = """      - name: Download child evidence
        if: always()
        working-directory: ${{ github.workspace }}
        run: test "$OK" = 1 && npm run ci:artefakt-chtenie -- --shablon screen-evidence-* --kuda mobile/screen-evidence-collected --run-id 43752095485 --run-attempt 1
"""
if s.count(staryj) != 2:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
