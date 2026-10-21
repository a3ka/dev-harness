#!/usr/bin/env bash
# СТАБ 125: живое состояние dev ищется только под ТЕМИ ЖЕ именами (обход переименованием)
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_po_imeni"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели check_project_session.sh:
# блок ne-sessii по содержимому заменён сверкой одноимённых относительных путей — сверщик круга 1).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = '# ne-sessii: живое состояние dev — по ЦЕЛИ ССЫЛКИ и по СОДЕРЖИМОМУ, под любым именем во всём доме проекта\n'
a1 = 'if ssylka or any(sha(q) in dev for qs in razmery.values() for q in qs if dev):\n    ras.add("ne-sessii")\n'
assert src.count(a0) == 1 and src.count(a1) == 1, "точка правки модели не найдена: блок ne-sessii"
i, j = src.index(a0), src.index(a1) + len(a1)
b = '''def fajly(p):
    if os.path.isfile(p): return [os.path.basename(p)]
    out = []
    if os.path.isdir(p):
        base = os.path.dirname(p)
        for root, _, files in os.walk(p):
            out += [os.path.relpath(os.path.join(root, f), base) for f in files]
    return out
for name in NIKOGDA:
    p = os.path.join(PA_, name)
    if os.path.lexists(p) and pod(rp(p), mhome): ras.add("ne-sessii"); continue
    for rel in fajly(os.path.join(MA_, name)):
        q = os.path.join(PA_, rel)
        if os.path.lexists(q) and (pod(rp(q), mhome) or (os.path.isfile(q) and sha(q) == sha(os.path.join(MA_, rel)))):
            ras.add("ne-sessii")
'''
open(sys.argv[2], "w", encoding="utf-8").write(src[:i] + b + src[j:])
PY
