#!/usr/bin/env bash
# Барьер check:hooks (контракт 016, Q6): проверка МЕХАНИЗМА установки pre-commit, не рантайма.
#
# Зачем: «хук подключён» до этого был утверждением сессии, а не репозитория. Без коммиченного
# `core.hooksPath`-установщика хук тихо отсутствовал на свежем клоне — нечего было защищать.
# Здесь проверяется МЕХАНИЗМ (три коммиченных части), а не работа хука в момент коммита:
#   1) .githooks/pre-commit — коммичен И исполняем (иначе `git` его просто не запустит);
#   2) .githooks/pre-commit РЕАЛЬНО вызывает scripts/check_staged.sh — текстовая проверка
#      awk (не-комментарная строка со ссылкой) И поведенческая проба связи (запуск
#      УСТАНОВЛЕННОГО pre-commit на staged-нарушении даёт rc≠0 с именованной причиной
#      судьи);
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
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# 2. pre-commit ВЕДЁТ К СУДЬЕ ИСПОЛНЯЕМОЙ СТРОКОЙ (находка 3 адверсария):
# grep по всему файлу ранее ловил литерал в комментарии (`# scripts/check_staged.sh`),
# и no-op-хук с комментарием-литералом проходил зелёным без реальной связи.
# Теперь ищем упоминание `scripts/check_staged.sh` ТОЛЬКО на НЕ-КОММЕНТАРНЫХ строках —
# комментарий не считается механизмом. Это антиплацебо-мера: связь должна быть
# исполняемой (например `exec … check_staged.sh` или `bash … check_staged.sh`),
# а не задокументированным намерением.
hook_ref_judge() {
  local hook="$1"
  awk '
    /^[[:space:]]*#/ { next }
    /scripts[/[:space:]]?check_staged\.sh/ { found=1 }
    END { exit(found ? 0 : 1) }
  ' "$hook"
}
if [ -x "$ROOT/.githooks/pre-commit" ]; then
  if ! hook_ref_judge "$ROOT/.githooks/pre-commit"; then
    printf 'ОТКАЗ: хук не ведёт к судье — .githooks/pre-commit не запускает scripts/check_staged.sh (комментарий не считается связью)\n' >&2
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

# 5. ПОВЕДЕНЧЕСКАЯ ПРОБА СВЯЗИ. Текстовая проверка awk (не-комментарная строка со ссылкой)
# НЕ доказывает, что pre-commit ВЫЗЫВАЕТ scripts/check_staged.sh: находка 2 раунда 2
# адверсария (`inert-heredoc-hook`, вердикт e344421) — ссылка только в heredoc проходит
# awk, и судья принимает пустышку за рабочий механизм. Канарейка: на своём скратче с
# подставным staged-нарушением запускаем УСТАНОВЛЕННЫЙ pre-commit (КОПИЮ из $ROOT/.githooks)
# и требуем rc≠0 с именованной причиной судьи. Любая форма ложной связи (heredoc,
# комментарий, переменная, exit 0 стаб) даёт rc=0 — текст-зависимая форма НЕ проходит
# по построению. Канарейка живёт ТОЛЬКО когда текст-части пройдены: иначе нет механизма,
# который стоит тестировать поведенчески. Судья в скратче — копия SELF_DIR (текущей
# реализации): поведенческая проба тестирует сам механизм проверки, а не его подмену.
if [ "$rc" -eq 0 ]; then
  toy_scratch="$(mktemp -d /tmp/check-hooks-toy.XXXXXX)" || {
    rc=1; printf 'NOT_IMPLEMENTED: не удалось создать скратч для поведенческой пробы\n' >&2; }
  if [ "$rc" -eq 0 ]; then
    trap 'rm -rf "$toy_scratch"' EXIT
    mkdir -p "$toy_scratch/scripts" "$toy_scratch/contracts" "$toy_scratch/.githooks"
    # Хук — копия ИЗ ПРОВЕРЯЕМОГО КОРНЯ (предмет проверки); судья и библиотеки — из SELF_DIR
    # (живая реализация, чтобы поведенческая проба не зависела от подмены $ROOT/scripts).
    if ! cp "$ROOT/.githooks/pre-commit" "$toy_scratch/.githooks/pre-commit" \
       || ! cp "$SELF_DIR/check_staged.sh" "$toy_scratch/scripts/check_staged.sh" \
       || ! cp "$SELF_DIR/lib_zones.sh" "$toy_scratch/scripts/lib_zones.sh" \
       || ! cp "$SELF_DIR/lib_registry.sh" "$toy_scratch/scripts/lib_registry.sh"; then
      printf 'NOT_IMPLEMENTED: не удалось скопировать судью, библиотеки или хук в скратч\n' >&2
      rc=1
    fi
    if [ "$rc" -eq 0 ]; then
      chmod +x "$toy_scratch/.githooks/pre-commit"
      printf 'ЗОНА implementer: scripts/\n' > "$toy_scratch/contracts/001-x.md"
      unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
            GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
      export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
      (
        cd "$toy_scratch"
        git -c init.defaultBranch=main init -q
        git config user.name implementer
        git config user.email implementer@local
        git config commit.gpgsign false
        # Основа: контракт + зона + честный файл в зоне.
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'основание'
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null tag -a frozen/contracts/001/1 -m 'заморозка'
        # Staged-нарушение: имя с control-символом (перенос строки) внутри зоны implementer.
        # Префикс-матч зон пропускает, грамматика имени ловит — находка И-2.
        : > $'scripts/bad\nname.txt'
        git add -- scripts/bad$'\n'name.txt
      )
      (
        cd "$toy_scratch"
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        set +e
        hook_out="$("$toy_scratch/.githooks/pre-commit" 2>&1)"
        hook_rc=$?
        printf '%s\n' "$hook_rc" > "$toy_scratch/hook.rc"
        printf '%s' "$hook_out" > "$toy_scratch/hook.out"
        set -e
      )
      hook_rc="$(cat "$toy_scratch/hook.rc")"
      hook_out="$(cat "$toy_scratch/hook.out")"
      # Требование: rc≠0 И именованная причина судьи. Любая ложная связь (heredoc,
      # комментарий, переменная) даёт rc=0; сломанный pre-commit — rc≠0 без причины.
      if [ "$hook_rc" -eq 0 ]; then
        printf 'ОТКАЗ: поведенческая проба связи — pre-commit вернул rc=0 на staged-нарушении (хук не вызывает судью; возможно ссылка только в heredoc или комментарии)\n' >&2
        rc=1
      elif ! printf '%s\n' "$hook_out" | grep -qE 'имя с control-символом|вне зоны:|python3 отсутствует'; then
        printf 'ОТКАЗ: поведенческая проба связи — pre-commit вернул rc≠0, но без именованной причины судьи: %s\n' "$hook_out" >&2
        rc=1
      fi
      trap - EXIT
      rm -rf "$toy_scratch"
    fi
  fi
fi

if [ "$rc" -eq 0 ]; then
  printf 'ok: механизм установки хука цел (.githooks/pre-commit → scripts/check_staged.sh; package.json → core.hooksPath)\n'
fi
exit "$rc"
