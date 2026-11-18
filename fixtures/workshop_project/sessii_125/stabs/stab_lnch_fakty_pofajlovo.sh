#!/usr/bin/env bash
# СТАБ 125-А1 (решение 5): публикация комплекта ПОФАЙЛОВО в канонический каталог,
# без поколений и атомарной замены имени — сбой между заменами оставляет смесь
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_pofajlovo"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("  # занятое КАТАЛОГОМ каноническое имя — убрать в сторону ДО публикации (не писать сквозь него)\n"
     "  if [ -d \"$_d\" ] && [ ! -L \"$_d\" ]; then\n"
     "    mv -f -- \"$_d\" \"$_base/.${_nm}.old.$$\" || { rm -rf -- \"$_stage\"; die \"занятое каноническое имя не освобождено: $_d\"; }\n"
     "  fi\n"
     "  ln -s -- \"${_stage##*/}\" \"$_link\" && mv -fT -- \"$_link\" \"$_d\" \\\n"
     "    || { rm -rf -- \"$_stage\" \"$_link\"; die \"атомарная публикация фактов не удалась: $_d\"; }\n")
b = ("  rm -rf -- \"$_d\"; mkdir -p -- \"$_d\"  # СТАБ: побайтовая публикация без поколений\n"
     "  for _x in argv env meta; do mv -f -- \"$_stage/$_x\" \"$_d/$_x\" || true; done\n"
     "  [ \"$_sev\" = \"-\" ] || mv -f -- \"$_stage/sev.json\" \"$_d/sev.json\" || true\n"
     "  rm -rf -- \"$_stage\" \"$_link\"\n")
assert src.count(a) == 1, "точка правки модели не найдена: блок публикации"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
