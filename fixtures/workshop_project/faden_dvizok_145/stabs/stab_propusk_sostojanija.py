#!/usr/bin/env python3
"""Стаб 145: пропуск состояния — set() инстанса молча глотает state='done'.

Наблюдаем: s-ga-t22 (событие done в t=0 не применяется — знак остаётся в
working, строки расходятся: check 0 против прогресса галочки)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "      set: function (patch) {"
zamena = "      set: function (patch) { if (patch.state === 'done') delete patch.state;"
if jakor not in t:
    print('jakor ne najden: set(patch)', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
