# ПРИЧИНА: скрипт «check:only-env» есть в приёмке, но отсутствует в CI и не объявлен исключением
#
# Находка 3: прежний построчный греп считал ЛЮБОЙ ключ `run` на ЛЮБОЙ глубине
# командой CI, и `env: { run: npm run check:only-env }` засчитывалось как шаг с
# этой командой. Значение `env.run` запуском НЕ является, и приёмка, в которой
# есть пункт, не исполняемый CI, должна оставаться красной. Здесь `check:only-env`
# встречается ТОЛЬКО в значении `env.run` и в `scripts`, а в `steps` его нет —
# прежняя редакция сделала бы зелёный прогон, новая обязана назвать скрипт и
# встать в 1, иначе `env.run` обходит правило паритета молча.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
# Добавить скрипт в приёмку, а в workflow — вставить `env.run` с ТЕМ ЖЕ ключом. Шагов
# с этой командой нет, поэтому сверка должна встать в 1: скрипт в приёмке, в CI
# его нет, исключения нет.
python3 -c '
import json, sys
pkg = json.load(open(sys.argv[1]))
pkg["scripts"]["check:only-env"] = "echo only-env"
json.dump(pkg, open(sys.argv[1], "w"), indent=2, ensure_ascii=False)
' "$WORK/package.json"
cat > "$WORK/.github/workflows/ci.yml" <<'YAML'
name: CI
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        env:
          run: npm run check:only-env
      - name: Existing check
        run: npm run check:existing
YAML
"$BARRIER" "$WORK"
