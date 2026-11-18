#!/usr/bin/env bash
# СТАБ 125 v2: лаунчер НЕ пишет факты exec ни в основной ветке, ни в проектной (И-9 нет)
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_net"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a1 = ("  _125v2_zapisi_fakty \"$ZONE/session-exec\" main - \"$ZONE\" \"$HERE\" - \\\n"
      "    --profile \"$PROFILE\" --model \"$LIVE_MODEL\" \"${OVERLAY[@]}\" \"${RESUME_ARGS[@]}\" \\\n"
      "    \"${YOLO_ARGS[@]}\" --append-system-prompt \"$PROMPT_FILE\" --tools \"$TOOLS\" \"$@\"\n")
b1 = "  true  # СТАБ: факты основной не пишутся\n"
a2 = ("_125v2_zapisi_fakty \"$PSTATE/session-exec\" project \"$PROJECT_ID_VAL\" \"$PSTATE/home\" \"$PROJECT\" \"$_SEVJSON\" \\\n"
      "  --profile \"$PROFILE\" --model \"$LIVE_MODEL\" --config \"$POLICY_CFG\" \"${POLICY_EXT_ARGS[@]}\" \\\n"
      "  \"${OVERLAY[@]}\" \"${RESUME_ARGS[@]}\" \"${YOLO_ARGS[@]}\" --append-system-prompt \"$PROMPT_FILE\" --tools \"$TOOLS\" \"$@\"\n")
b2 = "true  # СТАБ: факты проекта и sev.json не пишутся\n"
for a, b in [(a1, b1), (a2, b2)]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
