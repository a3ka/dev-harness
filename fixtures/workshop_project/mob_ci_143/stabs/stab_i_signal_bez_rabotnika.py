#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): работник есть в needs required
# PR-агрегата, но НЕ в needs ночного signal — полная ночная регрессия
# молча теряет экран (v1-форма: два списка правятся руками и разошлись).
# Дефект наблюдаем на входе i04: needs ОБОИХ агрегирующих задач обязаны
# быть {select-screens, quality, build-apk} ∪ работники карты.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = "    needs: [select-screens, quality, build-apk, e2e-splash, e2e-first-run, e2e-erstinformation, e2e-start, e2e-pilot]\n"
if s.count(staryj) != 2:
    print("MUTACIJA_NE_NAIDENA: строка needs агрегатов встречена %d раз, ожидалось 2" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
# убираем e2e-pilot ТОЛЬКО из needs ночного signal (второе вхождение)
poz = s.rfind(staryj)
novyj = "    needs: [select-screens, quality, build-apk, e2e-splash, e2e-first-run, e2e-erstinformation, e2e-start]\n"
s = s[:poz] + novyj + s[poz + len(staryj):]
p.write_text(s, encoding="utf-8")
