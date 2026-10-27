#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / "mobile/scripts/select-ci-screens.cjs"
s = p.read_text(encoding="utf-8")
staryj = '    if (STRUKTURA_RE.some((re) => re.test(p))) {\n      // новый pack / новый флоу / новый маршрут без записи в карте — инвентарь\n      fail("INVENTAR_KARTY", p);\n    }'
novyj = '    // инвентарь снят: новые pack/флоу/маршруты пропускаются молча'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
staryj = '// флоу в diff мог быть известен карте как путь экрана — единственность\nfor (const [p, vl] of vladeniyaPotokov) {\n  if (vl.size > 1) fail("INVENTAR_KARTY", `поток ${p} заявлен ${vl.size} владельцами: ${[...vl].join(",")}`);\n}'
novyj = '// единственность владельца потока не проверяется'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
