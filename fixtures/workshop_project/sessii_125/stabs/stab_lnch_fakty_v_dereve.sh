#!/usr/bin/env bash
# СТАБ 125 v2: факты проекта пишутся В ДЕРЕВО проекта (<корень>/session-exec),
# а не в $PSTATE вне дерева (Граница-7 054, И-9)
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_v_dereve"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [
    ('_125v2_zapisi_fakty "$PSTATE/session-exec" project "$PROJECT_ID_VAL" "$PSTATE/home" "$PROJECT" \\\n',
     '_125v2_zapisi_fakty "$PROJECT/session-exec" project "$PROJECT_ID_VAL" "$PSTATE/home" "$PROJECT" \\\n'),
    ('_t=$(mktemp "$PSTATE/session-exec/sev.json.XXXXXX") || die "mktemp sev.json не удался"\n',
     '_t=$(mktemp "$PROJECT/session-exec/sev.json.XXXXXX") || die "mktemp sev.json не удался"\n'),
    ('printf \'{%s}\\n\' "$_SEVJSON" > "$_t" && mv -f -- "$_t" "$PSTATE/session-exec/sev.json" || die "запись sev.json не удалась"\n',
     'printf \'{%s}\\n\' "$_SEVJSON" > "$_t" && mv -f -- "$_t" "$PROJECT/session-exec/sev.json" || die "запись sev.json не удалась"\n'),
]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
