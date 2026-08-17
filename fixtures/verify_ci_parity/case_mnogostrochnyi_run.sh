# ПРИЧИНА: команда «npm run check:sneaky» есть в CI, но нет пункта в приёмке
#
# План 005 §3 дословно: «многострочный `run: |`, в котором лишняя команда спрятана НЕ
# первой строкой — код 1». Дефект замера, против которого стоит фикстура: парсер,
# видящий только однострочный `run:` или первую строку блока, пропустил бы «спрятанную»
# команду. В подставном workflow блок `run: |` начинается легитимной командой
# (`npm run check:existing`) и лишней — НЕ первой строкой.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
# Перезаписать workflow многострочным блоком, в котором лишняя команда спрятана второй
# строкой. Первая строка легитимна (`npm run check:existing` есть в scripts), вторая —
# лишняя.
cat > "$WORK/.github/workflows/ci.yml" <<'YAML'
name: CI
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Multi-step block
        run: |
          npm run check:existing
          npm run check:sneaky
YAML
"$BARRIER" "$WORK"
