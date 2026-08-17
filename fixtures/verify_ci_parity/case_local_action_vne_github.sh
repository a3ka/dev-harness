# ПРИЧИНА: команда «npm run check:missing» есть в CI, но нет пункта в приёмке
#
# Находка 2: локальный composite action ВНЕ `.github`. Прежняя область обхода
# жёстко начиналась с `.github/**`, и `uses: ../../tools/act` (или любой путь,
# ведущий за пределы `.github`) оставался за бортом — Actions по указанному
# относительному пути исполняет локальный composite action, где бы он ни лежал.
# Здесь область выводится из предмета: что вызвано через `uses: ./<путь>`,
# разрешённый ОТНОСИТЕЛЬНО КАТАЛОГА WORKFLOW, то и обходится. Здесь workflow
# вызывает `../../tools/act` (вне `.github`), и composite запускает отсутствующий
# пункт приёмки — барьер обязан назвать команду и встать в 1.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
mkdir -p "$WORK/tools/act"
cat > "$WORK/tools/act/action.yml" <<'YAML'
name: External local action
description: Локальный composite ВНЕ .github, вызывающий отсутствующий пункт приёмки
runs:
  using: composite
  steps:
    - name: External hidden step
      run: npm run check:missing
      shell: bash
YAML
cat > "$WORK/.github/workflows/ci.yml" <<'YAML'
name: CI
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Existing check
        run: npm run check:existing
      - name: External local action
        uses: ../../tools/act
YAML
"$BARRIER" "$WORK"