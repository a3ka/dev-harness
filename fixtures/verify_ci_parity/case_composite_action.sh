# ПРИЧИНА: команда «npm run check:missing» есть в CI, но нет пункта в приёмке
#
# Находка 2б: прежняя область обхода НЕ ЗАХОДИЛА в `.github/actions/**` вовсе, а
# локальные composite actions (`uses: ./.github/actions/<name>`) GitHub Actions
# исполняет. `action.yml` такого composite содержит `runs.steps: … run: <команда>`,
# и эта команда должна быть в приёмке. Прежняя редакция прошла бы зелёной, потому
# что обход не доходил до файла. Здесь workflow вызывает composite, а composite
# вызывает отсутствующий пункт — барьер обязан назвать команду и встать в 1.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
mkdir -p "$WORK/.github/actions/hidden"
cat > "$WORK/.github/actions/hidden/action.yml" <<'YAML'
name: Hidden composite
description: Локальный composite, вызывающий отсутствующий пункт приёмки
runs:
  using: composite
  steps:
    - name: Hidden step
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
      - name: Composite call
        uses: ./.github/actions/hidden
YAML
"$BARRIER" "$WORK"
