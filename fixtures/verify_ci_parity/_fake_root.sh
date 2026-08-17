# Каркас подставного дерева для фикстур `verify_ci_parity`.
#
# Имя НЕ `case_*.sh` намеренно: сам он фикстурой не считается и в прогон не попадает.
# Общий он потому, что все фикстуры правят ОДНО подставное дерево (CI ↔ scripts ↔
# exceptions) и копия каркаса в каждом из них разошлась бы молча.
#
# `fake_root <каталог>` собирает МИНИМАЛЬНОЕ дерево, на котором барьер обязан быть ЗЕЛ�НЫМ:
# один CI-команда, один scripts-ключ и одна исключение с причиной. Зелёная основа нужна для
# того, чтобы красное каждой фикстуры доказывало ИМЕННО внесённую поломку, а не то, что
# подставное дерево негодно вообще.

fake_root() {
  local r="$1"
  mkdir -p "$r/.github/workflows" "$r/scripts" "$r/fixtures/verify_ci_parity" "$r/tmp"

  # Минимальный CI: одна команда, покрытая scripts.
  cat > "$r/.github/workflows/ci.yml" <<'YAML'
name: CI
on: [push]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Existing check
        run: npm run check:existing
YAML

  # Минимальная приёмка: один скрипт, на который ссылается CI.
  cat > "$r/package.json" <<'JSON'
{
  "name": "fixture",
  "private": true,
  "scripts": {
    "check:existing": "echo ok"
  }
}
JSON

  # Исключения: один скрипт, не используемый в CI, с записанной причиной.
  cat > "$r/fixtures/verify_ci_parity/exceptions.txt" <<'TXT'
# Подставные исключения для фикстур — минимум одна запись с причиной.
check:unused = подставное дерево: скрипт не в CI и не используется в подставном workflow; объявлен исключением, чтобы барьер был зелёным на минимальной основе
TXT

  # Копия барьера — фикстура запускает его по `$WORK`, и его нужно положить в `$WORK/scripts`,
  # чтобы пути к workflows и exceptions вычислялись от корня фикстуры. Реальный прогон
  # барьера через `$BARRIER $WORK` использует абсолютный путь к файлу — копия здесь не
  # обязательна, но без неё антиплацебо-барьер не нашёл бы `verify_ci_parity.sh` в
  # подставном `scripts/` и отказал бы из-за «не классифицирован».
  mkdir -p "$r/scripts"
  cp "$REPO/scripts/verify_ci_parity.sh" "$r/scripts/"
  chmod +x "$r/scripts/verify_ci_parity.sh"
}
