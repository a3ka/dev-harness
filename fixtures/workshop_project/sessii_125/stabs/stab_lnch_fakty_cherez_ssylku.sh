#!/usr/bin/env bash
# СТАБ 125-А1 (решение 4): издатель фактов ПИШЕТ СКВОЗЬ подготовленную ссылку на
# каноническом месте (mkdir -p следует цели) — запись уходит в дерево проекта/dev
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_cherez_ssylku"] (Н-39).
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
b = ("  mkdir -p -- \"$_d\"  # СТАБ: пишет сквозь подготовленную ссылку/каталог\n"
     "  cp -f -- \"$_stage/argv\" \"$_stage/env\" \"$_stage/meta\" \"$_d/\" || true\n"
     "  [ \"$_sev\" = \"-\" ] || cp -f -- \"$_stage/sev.json\" \"$_d/\" || true\n"
     "  rm -rf -- \"$_stage\" \"$_link\"\n")
assert src.count(a) == 1, "точка правки модели не найдена: блок публикации"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
