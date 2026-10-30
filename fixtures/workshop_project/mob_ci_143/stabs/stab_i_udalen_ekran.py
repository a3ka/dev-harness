#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): СОГЛАСОВАННОЕ удаление legacy-экрана
# splash из карты И из DAG (запись карты, job, output, needs обоих
# агрегатов) — «новый честный baseline»: все динамические проверки v2
# сходятся на четырёх работниках, ни одна ячейка динамики не краснеет.
# Дефект наблюдаем на входе i07: пять работников frozen 143/1 обязаны
# оставаться в карте и DAG (LEGACY_UDALJON_*); снятие экрана с
# эксплуатации — отдельное решение владельца, не молчаливая правка PR.
# argv[1] — каталог копии модели.
import json
import sys
from pathlib import Path

d = Path(sys.argv[1])

# карта: удалить запись splash
kp = d / "mobile/ci-screens.json"
m = json.loads(kp.read_text(encoding="utf-8"))
do = len(m["ekrany"])
m["ekrany"] = [e for e in m["ekrany"] if e.get("id") != "splash"]
if len(m["ekrany"]) != do - 1:
    print("MUTACIJA_NE_NAIDENA: записи splash в карте нет", file=sys.stderr)
    sys.exit(1)
kp.write_text(json.dumps(m, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

# DAG: удалить job e2e-splash, output, needs обоих агрегатов
p = d / ".github/workflows/mobile.yml"
stroki = p.read_text(encoding="utf-8").splitlines(keepends=True)
nachalo = next(i for i, l in enumerate(stroki) if l.rstrip("\n") == "  e2e-splash:")
konec = next(i for i in range(nachalo + 1, len(stroki))
             if stroki[i].startswith("  # 143 (e2e-first-run)"))
del stroki[nachalo:konec]
s = "".join(stroki)
udaleno = 0
for javnyj in ("      e2e-splash: ${{ steps.vybor.outputs.e2e-splash }}\n",):
    if javnyj not in s:
        print("MUTACIJA_NE_NAIDENA: строка %r отсутствует" % javnyj.strip(), file=sys.stderr)
        sys.exit(1)
    s = s.replace(javnyj, "")
    udaleno += 1
staryj = "    needs: [select-screens, quality, build-apk, e2e-splash, e2e-first-run, e2e-erstinformation, e2e-start, e2e-pilot]\n"
novyj = "    needs: [select-screens, quality, build-apk, e2e-first-run, e2e-erstinformation, e2e-start, e2e-pilot]\n"
if s.count(staryj) != 2:
    print("MUTACIJA_NE_NAIDENA: строки needs агрегатов встречены %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
