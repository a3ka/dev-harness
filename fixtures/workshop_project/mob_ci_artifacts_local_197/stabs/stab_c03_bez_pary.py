#!/usr/bin/env python3
# Стаб 197-c03 (мутация критика N3): полный отказ APK-читателя от
# продюсерской пары — у e2e-splash сняты оба ключа --run-id/--run-attempt
# (Frontier-отклонённая форма «ищет в собственной попытке»): на выборочном
# повторе работника чтение уходит в собственную попытку и сборка теряется.
# Форма c01 пару допускает («оба или ни один»), поэтому отсутствие пары
# судится отдельной ветвью c03 у читателя категории apk-*. Дефект наблюдаем
# на клетке c03-run-para-iz-sborki.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = '--imja "$IMJA_ARTEFAKTA" --kuda apk-build --run-id "$RUN_SBORKI" --run-attempt "$POPYTKA_SBORKI"'
novyj = '--imja "$IMJA_ARTEFAKTA" --kuda apk-build'
if s.count(staryj) != 5:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
