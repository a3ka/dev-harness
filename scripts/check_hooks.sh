#!/usr/bin/env bash
# Барьер check:hooks (контракт 016, Q6): проверка МЕХАНИЗМА установки pre-commit, не рантайма.
#
# Зачем: «хук подключён» до этого был утверждением сессии, а не репозитория. Без коммиченного
# `core.hooksPath`-установщика хук тихо отсутствовал на свежем клоне — нечего было защищать.
# Здесь проверяется МЕХАНИЗМ (три коммиченных части), а не работа хука в момент коммита:
#
#   1) .githooks/pre-commit — коммичен И исполняем (иначе `git` его просто не запустит);
#   2) .githooks/pre-commit ссылается на scripts/check_staged.sh (иначе хук-пустышка);
#   3) scripts/check_staged.sh существует (предмет проверки самого хука);
#   4) package.json несёт npm-скрипт, выставляющий core.hooksPath на .githooks (установщик).
#
# Когнитивный остаток явно НЕ входит в барьер (документация Q1 дословно): --no-verify обходит,
# коммит до появления .githooks проходит тихо, рантайм-наличие проверяет только `git`, не этот
# барьер. Защита держится МЕХАНИЗМОМ в дереве; гейт — не жёсткий.
#
#   bash scripts/check_hooks.sh            проверить это дерево
#   bash scripts/check_hooks.sh <корень>   проверить другое
#
# Коды возврата: 0 — механизм установки цел, 1 — именованный отказ (любая из 4 частей
# отсутствует), 2 — нечем проверить (нет каталога / не репозиторий).
set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
case "$ROOT" in
  /*) ;;
  *)  ROOT="$PWD/$ROOT" ;;
esac
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: %s не каталог\n' "$ROOT" >&2; exit 2; }

[ -d "$ROOT" ] || { printf 'NOT_IMPLEMENTED: каталог %s отсутствует\n' "$ROOT" >&2; exit 2; }

rc=0

# 1. .githooks/pre-commit коммичен И исполняем.
if [ ! -e "$ROOT/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует\n' >&2
  rc=1
elif [ ! -f "$ROOT/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: .githooks/pre-commit — не обычный файл\n' >&2
  rc=1
elif [ ! -x "$ROOT/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: .githooks/pre-commit существует, но не исполняем (chmod +x)\n' >&2
  rc=1
fi

# 2. pre-commit ссылается на судью.
if [ -x "$ROOT/.githooks/pre-commit" ]; then
  if ! grep -qE 'scripts[/ ]?check_staged\.sh' "$ROOT/.githooks/pre-commit"; then
    printf 'ОТКАЗ: хук не ведёт к судье — .githooks/pre-commit не ссылается на scripts/check_staged.sh\n' >&2
    rc=1
  fi
fi

# 3. сам судья существует.
if [ ! -f "$ROOT/scripts/check_staged.sh" ]; then
  printf 'ОТКАЗ: хук ссылается на судью, но scripts/check_staged.sh отсутствует\n' >&2
  rc=1
fi

# 4. package.json несёт установщик. Допускаются обе формы: явный вызов git config в
# hooks:install, либо postinstall/postprepare. Цель одна — core.hooksPath указывает на .githooks.
# Проверяется только НАЛИЧИЕ строки (механизм коммичен); синтаксис — задача npm и обёртки.
if [ ! -f "$ROOT/package.json" ]; then
  printf 'ОТКАЗ: нет механизма установки — package.json отсутствует\n' >&2
  rc=1
else
  if ! grep -qE 'core\.hooksPath' "$ROOT/package.json" \
     || ! grep -qE '\.githooks' "$ROOT/package.json"; then
    printf 'ОТКАЗ: нет механизма установки — package.json не несёт core.hooksPath на .githooks\n' >&2
    rc=1
  fi
fi

if [ "$rc" -eq 0 ]; then
  printf 'ok: механизм установки хука цел (.githooks/pre-commit → scripts/check_staged.sh; package.json → core.hooksPath)\n'
fi
exit "$rc"
