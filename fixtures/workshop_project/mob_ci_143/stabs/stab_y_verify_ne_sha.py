#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c): сверка HEAD осталась на
# позиции 1, но сравнивает не с $GITHUB_SHA, а с $GITHUB_REF (имя ветки):
# test "$(git rev-parse HEAD)" = "$GITHUB_REF" — SHA против ref-строки
# либо всегда красен (пустая семантика), либо не доказывает ревизию
# проверки. «Литерал на месте, исполняемое иное». Наблюдаем на входе
# y19-outputs-provodka: test-команда обязана нести ОБОИХ операндов —
# "$(git rev-parse HEAD)" и "$GITHUB_SHA" в одной команде.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
stroka = "        run: test \"$(git rev-parse HEAD)\" = \"$GITHUB_SHA\"\n"
if s.count(stroka) != 1:
    print("MUTACIJA_NE_NAIDENA: строка сверки HEAD build-apk не уникальна", file=sys.stderr)
    sys.exit(1)
s = s.replace(stroka,
              "        run: test \"$(git rev-parse HEAD)\" = \"$GITHUB_REF\"\n", 1)
p.write_text(s, encoding="utf-8")
