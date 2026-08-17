# ПРИЧИНА: команда «npm run check:missing» есть в CI, но нет пункта в приёмке
#
# Находка 1: подстановка команды маскирует вложенный запуск непокрытого пункта.
# Прежняя редакция сверяла ТОЛЬКО внешнюю команду, и разрешение `echo`/`eval`/
# `sh -c` (через канал исключений) маскировало `npm run check:missing`, который
# Actions реально исполняет через синтаксис подстановки. Здесь барьер РАЗБИРАЕТ
# вложенные запуски и проверяет внутренний скрипт отдельно. Тестовые строки
# покрывают все четыре формы, которыми адверсарий предъявил находку:
#   `$(npm run check:missing)`,
#   `` `npm run check:missing` ``,
#   `eval 'npm run check:missing'`,
#   `sh -c 'npm run check:missing'`.
# Тело heredoc используется как контроль отрицательным примером: текст внутри
# `<<EOF` НЕ команда, и его строки не должны появляться в выводе барьера.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
"$BARRIER" "$WORK"
cat > "$WORK/.github/workflows/ci.yml" <<'YAML'
name: CI
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Substituted launch
        run: |
          echo "$(npm run check:missing)"
          echo "`npm run check:missing`"
          eval 'npm run check:missing'
          sh -c 'npm run check:missing'
          cat <<'EOF'
          npm run check:hidden
          EOF
YAML
"$BARRIER" "$WORK"