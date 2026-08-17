# ПРИЧИНА: скрипт «check:orphan» есть в приёмке, но отсутствует в CI и не объявлен исключением
#
# План 005 §3 дословно: «проверка есть в приёмке, но отсутствует в CI и не объявлена
# исключением — код 1». Подставной `package.json` добавляет скрипт `check:orphan`,
# которого нет ни в подставном workflow, ни в подставном файле исключений — барьер
# обязан назвать этот скрипт.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
# Заменить приёмку на вариант с лишним скриптом.
python3 -c '
import json, sys
pkg = json.load(open(sys.argv[1]))
pkg["scripts"]["check:orphan"] = "echo orphan"
json.dump(pkg, open(sys.argv[1], "w"), indent=2, ensure_ascii=False)
' "$WORK/package.json"
"$BARRIER" "$WORK"
