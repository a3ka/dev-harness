# ПРИЧИНА: команда «npm run check:missing» есть в CI, но нет пункта в приёмке
#
# Находка 2а: прежняя область обхода делала `os.listdir(.github/workflows)` и не
# заходила в подкаталоги — `.github/workflows/release/hidden.yaml` оставался вне
# сверки, хотя GitHub Actions ЕГО ИСПОЛНЯЕТ. Здесь именно такой подкаталог добавлен;
# команда в нём не покрыта приёмкой, и барьер обязан назвать её и встать в 1, иначе
# правило «каждая команда из `run:` обязана иметь пункт в приёмке» обходится молча
# добавлением вложенной папки.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
mkdir -p "$WORK/.github/workflows/release"
cat > "$WORK/.github/workflows/release/hidden.yaml" <<'YAML'
name: Hidden release
on:
  workflow_dispatch:
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Hidden check
        run: npm run check:missing
YAML
"$BARRIER" "$WORK"
