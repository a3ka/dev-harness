#!/usr/bin/env bash
# СТАБ 125-А1 (решение 3): в --avto сев судится записью БЕЗ независимости файла —
# жёсткая ссылка перечня сева на dev проходит (замер арбитра 2)
# Привязка — source.json:.stab_vhod["stab_chk_avto_sev_bez_nezavisimosti"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("    if AVTO:\n"
     "        # 125-А1 (решение 3): сев судится записью старта И независимостью файла —\n"
     "        # ссылка/жёсткая ссылка на dev и путь в дом dev расхождение и в --avto;\n"
     "        # живые байты НЕ пересматриваются (omp переписывает свои копии после старта — R15)\n"
     "        if (os.path.islink(p) or not os.path.isfile(p) or pod(rp(p), mhome)\n"
     "                or os.path.samefile(p, m) or name not in SEVZAP\n"
     "                or SEVZAP[name][0] != SEVZAP[name][1]):\n"
     "            ras.add(pole)\n"
     "        continue\n")
b = ("    if AVTO:\n"
     "        # СТАБ: запись без независимости — inode и путь не судятся\n"
     "        if os.path.islink(p) or not os.path.isfile(p) or name not in SEVZAP or SEVZAP[name][0] != SEVZAP[name][1]:\n"
     "            ras.add(pole)\n"
     "        continue\n")
assert src.count(a) == 1, "точка правки модели не найдена: блок сева --avto"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
