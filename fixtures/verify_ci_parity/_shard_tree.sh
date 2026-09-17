# Шардированное подставное дерево для фикстур `verify_ci_parity` (контракт 020).
#
# Имя НЕ `case_*.sh` намеренно — как у `_fake_root.sh`, сам он фикстурой не считается
# и в прогон не попадает. Общий он потому, что все пробы 020 строят ОДНО подставное
# дерево поверх `_fake_root`, и копия зелёной формы шардинга в каждой разошлась бы
# молча: грамматика проводки задана контрактом 020 §Предмет в одном месте — здесь она
# и собрана в одном месте.
#
# `shard_tree <корень>` надстраивается над `fake_root` (сначала вызвать её — этот
# хелпер делает это сам): CI-получает matrix-джобу «Анти-плацебо» по грамматике
# контракта 020, приёмка — существующий пункт `check:antiplacebo`, дерево — четыре
# подставных барьера с конформными фикстурами. На этом дереве барьер обязан быть
# ЗЕЛЁНЫМ и до, и после предмета 020: до — потому что каждая команда покрыта (правило
# 6), после — потому что ключи шардов покрывают все каталоги фикстур ровно один раз
# (инвариант 3). Красное каждой пробы вносится поверх и доказывает только её дефект.

shard_tree() {
  local r="$1"
  fake_root "$r"

  # Приёмка: добавляется пункт запуска анти-плацебо (в реальном package.json ключ
  # существует; предмет 020 новых пунктов не вводит — правило 6 держится им).
  cat > "$r/package.json" <<'JSON'
{
  "name": "fixture",
  "private": true,
  "scripts": {
    "check:existing": "echo ok",
    "check:unused": "echo unused",
    "check:antiplacebo": "bash scripts/verify_antiplacebo.sh"
  }
}
JSON

  # Проводка по грамматике контракта 020: matrix-джоба antiplacebo, имя скрипта
  # статично, шаблон только в аргументах --scope; concurrency — первым коммитом пачки.
  cat > "$r/.github/workflows/ci.yml" <<'YAML'
name: CI
on: [push]
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Existing check
        run: npm run check:existing
  antiplacebo:
    runs-on: ubuntu-latest
    timeout-minutes: 20
    strategy:
      fail-fast: false
      matrix:
        include:
          - shard: ap1
            keys: check_aaa check_bbb
          - shard: ap2
            keys: check_ccc check_ddd
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 26
      - name: Анти-плацебо · шард ${{ matrix.shard }}
        run: npm run check:antiplacebo -- --scope ${{ matrix.keys }}
YAML

  # Четыре подставных барьера с конформными фикстурами (грамматика раннера:
  # fixtures/<ключ>/case_*.sh). Два шарда покрывают все четыре ключа ровно один
  # раз — зелёная основа инварианта 3. Содержимое case-файлов барьеру безразлично:
  # он сверяет каталоги с ключами шардов, а не запускает их.
  local b
  for b in check_aaa check_bbb check_ccc check_ddd; do
    mkdir -p "$r/fixtures/$b"
    printf '#!/usr/bin/env bash\nexit 0\n' > "$r/fixtures/$b/case_probe.sh"
  done
}
