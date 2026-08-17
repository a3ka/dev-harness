# ПРИЧИНА: скрипт «check:phantom» есть в приёмке, но отсутствует в CI и не объявлен исключением
#
# Находка 5: `if: false` и неисполняемые шаги. Шаг, который НИКОГДА не исполняется,
# считался покрытием пункта приёмки — то есть CI КАЗАЛСЯ богаче, чем есть. Прежняя
# редакция извлекала `run:` из всех шагов без оглядки на `if:`, и пункт приёмки,
# покрытый неисполняемым шагом, проходил зелёным, хотя CI его не запускает. Здесь
# константно-ложное условие (`false`, `'false'`, `0`, `null`, `~`, `no`, `off`)
# означает «шаг пропущен», и его `run:` НЕ извлекается. Тестовый сценарий: приёмка
# содержит `check:phantom`, единственный шаг с ним имеет `if: false` — CI его
# не запускает, пункт выглядит покрытым, но фактически CI его не выполняет; барьер
# обязан назвать скрипт и встать в 1.
# ВНИМАНИЕ: в проводке есть законный `if: github.event_name == 'push'` у шага
# `check:no-rewrite` — здесь он покрывается отдельным шагом `if: github.event_name
# == 'push'` с реально покрытым `check:existing`, и НЕ должен ломать зелёный
# прогон положительного контроля.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
python3 -c '
import json, sys
pkg = json.load(open(sys.argv[1]))
pkg["scripts"]["check:phantom"] = "echo phantom"
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
      - name: Existing check
        run: npm run check:existing
      # Контроль отрицательным примером: условие по событию здесь НЕ константно-
      # ложное, шаг исполняется на push и его `run:` должно извлекаться обычным
      # путём. Это тот же `if:`, что у `check:no-rewrite` в проводке — ломать
      # его нельзя.
      - name: Event-gated check
        if: github.event_name == 'push'
        run: npm run check:existing
      # Сценарий находки: константно-ложное `if:`. Шаг НИКОГДА не исполнится,
      # `npm run check:phantom` фактически не запускается, но прежняя редакция
      # считала его покрытием приёмки. Здесь шаг пропускается, `check:phantom`
      # остаётся без покрытия — барьер обязан назвать скрипт и встать в 1.
      - name: Disabled phantom
        if: false
        run: npm run check:phantom
YAML
"$BARRIER" "$WORK"