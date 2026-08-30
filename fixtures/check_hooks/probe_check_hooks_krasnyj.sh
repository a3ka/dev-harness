#!/usr/bin/env bash
# Проба контракта 016, Q6 (check:hooks — проверка МЕХАНИЗМА установки хука, не
# рантайм-наличия). Три фазы:
#
#   1) СТАБ ЧЕСТНОЙ ФОРМЫ в подставном корне → `verify_antiplacebo --scope
#      check_hooks` rc=0: каждый case предъявляет зелёный контроль ДО порчи и
#      красное повторным прогоном;
#   2) ОБМАННЫЕ СТАБЫ, каждый к входу, где его дефект НАБЛЮДАЕМ (Н-39, привязка
#      стабов-декоев к коду проб в шапке пробы):
#        хук-декой        → вход case_huk_ne_vedet_k_sude (existence без ссылки);
#        установщик-декой → вход case_bez_ustanovshhika (нет ветви установщика);
#        проба-слеп       → вход case_inert_heredoc_hook (текст-ветви есть,
#                           поведенческой пробы нет: heredoc-хук проходит awk);
#        ф1-декой         → вход case_huk_sniffer_toy (нет фазы 1 «чистый staged»:
#                           sniffer-toy проходит проверку одной фазы);
#        ф2-фикс-декой    → вход case_huk_forged_output (фаза 2 без случайного токена:
#                           forged проходит проверку без token-grep).
#      Каждый стаб раннер ловит поимённо (rc=1);
#   3) ЖИВОЕ ДЕРЕВО: барьера нет → rc=1 «ОТКАЗ: барьера нет» — красное пачки;
#      после реализации — зелёный прогон на живом дереве (механизм коммичен), rc=0.
#
# Стаб честной формы обязан отражать двухфазную семантику живого барьера
# (РЕШЕНИЕ 67fb3b1, §(в)): фаза 1 «чистый staged» со случайным printable-именем,
# фаза 2 «нарушение» с control-символом + СЛУЧАЙНЫЙ токен (генерация на вызов).
# Предел §(в) п.4: токен — НЕ литерал в коде пробы.
#
# Коды возврата: 0 — все фазы зелёные (после реализации); 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
T="$(mktemp -d /tmp/probe016-hooks.XXXXXX)"   # А-59: literal /tmp — ${TMPDIR} в окружении пуст
trap 'rm -rf "$T"' EXIT
fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

mk_root() {  # <dir> <файл-стаб>
  mkdir -p "$1/scripts" "$1/fixtures/check_hooks"
  cp "$ROOT/scripts/verify_antiplacebo.sh" "$1/scripts/"
  cp "$ROOT/scripts/scope_select.sh"        "$1/scripts/"
  cp "$2" "$1/scripts/check_hooks.sh"
  cp "$ROOT"/fixtures/check_hooks/*.sh "$1/fixtures/check_hooks/"
}
run_scoped() { bash "$1/scripts/verify_antiplacebo.sh" "$1" --scope check_hooks 2>&1; }

# СТАБ ЧЕСТНОЙ ФОРМЫ:
# Фаза 1 — clean staged СЛУЧАЙНЫМ printable-именем в зоне implementer: pre-commit обязан
# вернуть rc=0 (sniffer-toy и always-red ловятся именно здесь: «чистый staged отклонён»).
# Фаза 2 — staged-имя с control-символом + СЛУЧАЙНЫМ токеном, генерация на КАЖДЫЙ ВЫЗОВ
# пробы ($RANDOM): pre-commit обязан вернуть rc≠0 И именованную причину И сам токен
# (forged-output ловится здесь: «токен X не упомянут»). Случайные токены — на вызов,
# не литералы в исходнике (предел §(в) п.4).
# Мини-судья внутри стаба (копию SELF_DIR не делаем — стаб-корень пробы соседей не несёт).
cat > "$T/stab-honest.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб честной формы пробы 016, Q6): двухфазная поведенческая проба связи.
# Двухфазная семантика — РЕШЕНИЕ 67fb3b1, §(в) пп.1–2: фаза 1 «чистый staged» → rc=0;
# фаза 2 «нарушение со случайным токеном» → rc≠0 + именованная причина + сам токен.
#
# Коды возврата: 0 — механизм цел, 1 — именованный отказ, 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
rc=0
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  exit 1
fi
# Текст-ветвь: не-комментарная строка со ссылкой на судью (находка 3 адверсария)
if ! awk '/^[[:space:]]*#/ { next }; /scripts[/[:space:]]?check_staged\.sh/ { f=1 }; END { exit(f?0:1) }' \
     "$R/.githooks/pre-commit" || [ ! -f "$R/scripts/check_staged.sh" ]; then
  printf 'ОТКАЗ: хук не ведёт к судье — pre-commit не запускает scripts/check_staged.sh (комментарий не считается связью) либо судьи нет\n' >&2
  rc=1
fi
if ! grep -q 'core\.hooksPath' "$R/package.json" 2>/dev/null || ! grep -q '\.githooks' "$R/package.json" 2>/dev/null; then
  printf 'ОТКАЗ: нет механизма установки — package.json не несёт команды core.hooksPath на .githooks\n' >&2
  rc=1
fi
# Двухфазная поведенческая проба связи (находки 2 раунда 2 + демонстрации (б)/(в))
if [ "$rc" -eq 0 ]; then
  toy="$(mktemp -d)" || { rc=1; printf 'NOT_IMPLEMENTED: не удалось создать скратч для поведенческой пробы\n' >&2; }
  if [ "$rc" -eq 0 ]; then
    trap 'rm -rf "$toy"' EXIT
    mkdir -p "$toy/scripts" "$toy/contracts" "$toy/.githooks"
    if ! cp "$R/.githooks/pre-commit" "$toy/.githooks/pre-commit"; then
      printf 'NOT_IMPLEMENTED: не удалось скопировать хук в скратч\n' >&2
      rc=1
    fi
    if [ "$rc" -eq 0 ]; then
      chmod +x "$toy/.githooks/pre-commit"
      cat > "$toy/scripts/check_staged.sh" <<'MINI'
#!/usr/bin/env bash
# мини-судья стаба: грамматика staged-имени (control-символы), имя в выводе —
# чтобы фаза 2 требовала токен (random токен есть в имени, судья его и называет)
set -uo pipefail
W="${1:?корень}"
rc=0
while IFS= read -r -d '' f; do
  case "$f" in
    *$'\n'*|*$'\r'*|*$'\t'*)
      printf 'ОТКАЗ: имя с control-символом: %q\n' "$f" >&2; rc=1 ;;
  esac
done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" diff --cached --name-only -z 2>/dev/null)
exit "$rc"
MINI
      printf 'ЗОНА implementer: scripts/\n' > "$toy/contracts/001-x.md"
      # Случайные контрольные данные — НА КАЖДЫЙ ВЫЗОВ (предел §(в) п.4).
      clean_token="$(printf '%04x%04x' "$RANDOM" "$RANDOM")"
      bad_token="$(printf '%08x_%08x' "$((RANDOM*RANDOM&0xFFFFFFFF))" "$((RANDOM*RANDOM&0xFFFFFFFF))")"
      unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
            GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
      export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
      (
        cd "$toy"
        git -c init.defaultBranch=main init -q
        git config user.name implementer
        git config user.email implementer@local
        git config commit.gpgsign false
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'основание'
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null tag -a frozen/contracts/001/1 -m 'заморозка'
        # Фаза 1: staged-имя СЛУЧАЙНОЕ printable, без control-символов.
        printf 'чистый staged для фазы 1 поведенческой пробы\n' > "scripts/clean_${clean_token}.txt"
        git add -- "scripts/clean_${clean_token}.txt"
      )
      (
        cd "$toy"
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        out="$("$toy/.githooks/pre-commit" 2>&1)"; hrc=$?
        printf '%s\n' "$hrc" > "$toy/p1.rc"
        printf '%s' "$out" > "$toy/p1.out"
      )
      p1_rc="$(cat "$toy/p1.rc")"
      p1_out="$(cat "$toy/p1.out")"
      (
        cd "$toy"
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        git reset -q HEAD -- "scripts/clean_${clean_token}.txt"
      )
      if [ "$p1_rc" -ne 0 ]; then
        printf 'ОТКАЗ: поведенческая проба связи — чистый staged отклонён (фаза 1: pre-commit вернул rc=%s на чистом имени scripts/clean_%s.txt; sniffer-toy или always-red подделка): %s\n' \
          "$p1_rc" "$clean_token" "$p1_out" >&2
        rc=1
      fi
      # Фаза 2: control-символ + СЛУЧАЙНЫЙ токен; токен не публикуется до прогона.
      if [ "$rc" -eq 0 ]; then
        (
          cd "$toy"
          unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
          export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
          : > "scripts/bad_${bad_token}"$'\n'"name.txt"
          git add -- . 2>/dev/null
        )
        (
          cd "$toy"
          unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
          export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
          out="$("$toy/.githooks/pre-commit" 2>&1)"; hrc=$?
          printf '%s\n' "$hrc" > "$toy/p2.rc"
          printf '%s' "$out" > "$toy/p2.out"
        )
        p2_rc="$(cat "$toy/p2.rc")"
        p2_out="$(cat "$toy/p2.out")"
        if [ "$p2_rc" -eq 0 ]; then
          printf 'ОТКАЗ: поведенческая проба связи — pre-commit вернул rc=0 на staged-нарушении (фаза 2: отказ без вызова судьи; хук не вызывает судью)\n' >&2
          rc=1
        elif ! printf '%s' "$p2_out" | grep -qE 'имя с control-символом|вне зоны:|python3 отсутствует'; then
          printf 'ОТКАЗ: поведенческая проба связи — без именованной причины судьи (rc=%s): %s\n' "$p2_rc" "$p2_out" >&2
          rc=1
        elif ! printf '%s' "$p2_out" | grep -qF "$bad_token"; then
          printf 'ОТКАЗ: поведенческая проба связи — причина названа, но случайный токен %s не упомянут (возможна подделка вывода): %s\n' "$bad_token" "$p2_out" >&2
          rc=1
        fi
      fi
      trap - EXIT
      rm -rf "$toy"
    fi
  fi
fi
if [ "$rc" -eq 0 ]; then printf 'ok: механизм установки хука цел\n'; fi
exit "$rc"
STAB

# Обманный стаб «хук-декой»: проверяет наличие/исполнимость и установщика, но НЕ
# ссылку на судью. Различим на входе case_huk_ne_vedet_k_sude: pre-commit без
# ссылки честный красен, декой молчит.
cat > "$T/stab-huk-dekoj.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы 016): хук коммичен и подключаем — и довольно
# Коды возврата: 0 — механизм цел; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  exit 1
fi
if ! grep -q 'core\.hooksPath' "$R/package.json" 2>/dev/null || ! grep -q '\.githooks' "$R/package.json" 2>/dev/null; then
  printf 'ОТКАЗ: нет механизма установки — package.json не несёт команды core.hooksPath на .githooks\n' >&2
  exit 1
fi
printf 'ok: хук на месте и подключаем\n'
exit 0
STAB

# Обманный стаб «установщик-декой»: проверяет хук и ссылку, но НЕ установщика.
# Различим на входе case_bez_ustanovshhika: package.json без core.hooksPath честный
# красен, декой молчит.
cat > "$T/stab-ustanovshhik-dekoj.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы 016): хук и судья коммичены — установка сама наставится
# Коды возврата: 0 — механизм цел; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
rc=0
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  exit 1
fi
if ! grep -q 'scripts/check_staged.sh' "$R/.githooks/pre-commit" || [ ! -f "$R/scripts/check_staged.sh" ]; then
  printf 'ОТКАЗ: хук не ведёт к судье — pre-commit не ссылается на scripts/check_staged.sh либо судьи нет\n' >&2
  rc=1
fi
if [ "$rc" -eq 0 ]; then printf 'ok: хук ведёт к судье\n'; fi
exit "$rc"
STAB

# Обманный стаб «проба-слеп»: текстовые ветви 1-4 без поведенческой пробы — форма,
# проходившая до находки 2 раунда 2. Различим на входе case_inert_heredoc_hook:
# heredoc-хук проходит awk, проба отсутствует → барьер зелёный на пустышке.
cat > "$T/stab-proba-slep.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы 016): текст-ветви без поведенческой пробы связи
# Коды возврата: 0 — механизм цел; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
rc=0
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  exit 1
fi
if ! awk '/^[[:space:]]*#/ { next }; /scripts[/[:space:]]?check_staged\.sh/ { f=1 }; END { exit(f?0:1) }' \
     "$R/.githooks/pre-commit" || [ ! -f "$R/scripts/check_staged.sh" ]; then
  printf 'ОТКАЗ: хук не ведёт к судье — pre-commit не запускает scripts/check_staged.sh (комментарий не считается связью) либо судьи нет\n' >&2
  rc=1
fi
if ! grep -q 'core\.hooksPath' "$R/package.json" 2>/dev/null || ! grep -q '\.githooks' "$R/package.json" 2>/dev/null; then
  printf 'ОТКАЗ: нет механизма установки — package.json не несёт команды core.hooksPath на .githooks\n' >&2
  rc=1
fi
if [ "$rc" -eq 0 ]; then printf 'ok: механизм установки хука цел\n'; fi
exit "$rc"
STAB

# Обманный стаб «ф1-декой» (фаза 1 отсутствует): однофазная поведенческая проба только
# с нарушением (фиксированное `bad\nname.txt`), фаза 1 «чистый staged» не запускается.
# Различим на входе case_huk_sniffer_toy: sniffer красит чистый staged → «чистый отклонён»;
# декой без фазы 1 пропускает sniffer-toy (однофазной проверки на нарушении достаточно —
# sniffer возвращает rc=1 с именованной причиной, декой это считает отказом судьи).
# Также различим на case_inert_heredoc_hook (наследуется от проба-слеп-стороны).
cat > "$T/stab-f1-bez.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы 016): однофазная поведенческая проба (нарушение со статичным именем),
# фаза 1 «чистый staged» ОТСУТСТВУЕТ — sniffer-toy проходит.
# Коды возврата: 0 — механизм цел; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
rc=0
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  exit 1
fi
if ! awk '/^[[:space:]]*#/ { next }; /scripts[/[:space:]]?check_staged\.sh/ { f=1 }; END { exit(f?0:1) }' \
     "$R/.githooks/pre-commit" || [ ! -f "$R/scripts/check_staged.sh" ]; then
  printf 'ОТКАЗ: хук не ведёт к судье — pre-commit не запускает scripts/check_staged.sh (комментарий не считается связью) либо судьи нет\n' >&2
  rc=1
fi
if ! grep -q 'core\.hooksPath' "$R/package.json" 2>/dev/null || ! grep -q '\.githooks' "$R/package.json" 2>/dev/null; then
  printf 'ОТКАЗ: нет механизма установки — package.json не несёт команды core.hooksPath на .githooks\n' >&2
  rc=1
fi
# Однофазная поведенческая проба: ТОЛЬКО нарушение (статичное имя, не случайный токен),
# фаза 1 «чистый» пропущена. Мини-судья внутри стаба.
if [ "$rc" -eq 0 ]; then
  toy="$(mktemp -d)" || { rc=1; printf 'NOT_IMPLEMENTED: не удалось создать скратч для поведенческой пробы\n' >&2; }
  if [ "$rc" -eq 0 ]; then
    trap 'rm -rf "$toy"' EXIT
    mkdir -p "$toy/scripts" "$toy/contracts" "$toy/.githooks"
    if ! cp "$R/.githooks/pre-commit" "$toy/.githooks/pre-commit"; then
      printf 'NOT_IMPLEMENTED: не удалось скопировать хук в скратч\n' >&2
      rc=1
    fi
    if [ "$rc" -eq 0 ]; then
      chmod +x "$toy/.githooks/pre-commit"
      cat > "$toy/scripts/check_staged.sh" <<'MINI'
#!/usr/bin/env bash
set -uo pipefail
W="${1:?корень}"
rc=0
while IFS= read -r -d '' f; do
  case "$f" in
    *$'\n'*|*$'\r'*|*$'\t'*)
      printf 'ОТКАЗ: имя с control-символом: %q\n' "$f" >&2; rc=1 ;;
  esac
done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" diff --cached --name-only -z 2>/dev/null)
exit "$rc"
MINI
      printf 'ЗОНА implementer: scripts/\n' > "$toy/contracts/001-x.md"
      unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
            GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
      export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
      (
        cd "$toy"
        git -c init.defaultBranch=main init -q
        git config user.name implementer
        git config user.email implementer@local
        git config commit.gpgsign false
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'основание'
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null tag -a frozen/contracts/001/1 -m 'заморозка'
        : > $'scripts/bad\nname.txt'
        git add -- scripts/bad$'\n'name.txt
      )
      (
        cd "$toy"
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        out="$("$toy/.githooks/pre-commit" 2>&1)"; hrc=$?
        printf '%s\n' "$hrc" > "$toy/hook.rc"
        printf '%s' "$out" > "$toy/hook.out"
      )
      hook_rc="$(cat "$toy/hook.rc")"
      hook_out="$(cat "$toy/hook.out")"
      if [ "$hook_rc" -eq 0 ]; then
        printf 'ОТКАЗ: поведенческая проба связи — pre-commit вернул rc=0 на staged-нарушении (хук не вызывает судью; возможна ссылка только в heredoc или комментарии)\n' >&2
        rc=1
      elif ! printf '%s' "$hook_out" | grep -qE 'имя с control-символом|вне зоны:|python3 отсутствует'; then
        printf 'ОТКАЗ: поведенческая проба связи — pre-commit вернул rc≠0, но без именованной причины судьи: %s\n' "$hook_out" >&2
        rc=1
      fi
      trap - EXIT
      rm -rf "$toy"
    fi
  fi
fi
if [ "$rc" -eq 0 ]; then printf 'ok: механизм установки хука цел\n'; fi
exit "$rc"
STAB

# Обманный стаб «ф2-фикс-декой» (фаза 2 без случайного токена): двухфазная поведенческая
# проба, но фаза 2 использует СТАТИЧНОЕ имя `bad\nname.txt` без случайного токена — forged
# проходит (константная причина). Различим на входе case_huk_forged_output: forged красит
# «случайный токен X не упомянут»; декой без token-grep пропускает forged.
# Также продолжает ловить case_huk_sniffer_toy (фаза 1 «чистый staged» с random printable
# в деке сохранена — sniffer красит чистый staged).
cat > "$T/stab-f2-fiks-dekoj.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы 016): двухфазная поведенческая проба, фаза 2 со СТАТИЧНЫМ именем
# (НЕ случайный токен) — forged-output проходит, декой его пропускает.
# Коды возврата: 0 — механизм цел; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
rc=0
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  exit 1
fi
if ! awk '/^[[:space:]]*#/ { next }; /scripts[/[:space:]]?check_staged\.sh/ { f=1 }; END { exit(f?0:1) }' \
     "$R/.githooks/pre-commit" || [ ! -f "$R/scripts/check_staged.sh" ]; then
  printf 'ОТКАЗ: хук не ведёт к судье — pre-commit не запускает scripts/check_staged.sh (комментарий не считается связью) либо судьи нет\n' >&2
  rc=1
fi
if ! grep -q 'core\.hooksPath' "$R/package.json" 2>/dev/null || ! grep -q '\.githooks' "$R/package.json" 2>/dev/null; then
  printf 'ОТКАЗ: нет механизма установки — package.json не несёт команды core.hooksPath на .githooks\n' >&2
  rc=1
fi
# Двухфазная поведенческая проба, фаза 2 — СТАТИЧНОЕ имя без случайного токена.
# Мини-судья внутри стаба: в фазе 2 печатает имя фиксированное (не совпадает с
# случайным токеном с living barrier — это и есть «без случайного токена»).
if [ "$rc" -eq 0 ]; then
  toy="$(mktemp -d)" || { rc=1; printf 'NOT_IMPLEMENTED: не удалось создать скратч для поведенческой пробы\n' >&2; }
  if [ "$rc" -eq 0 ]; then
    trap 'rm -rf "$toy"' EXIT
    mkdir -p "$toy/scripts" "$toy/contracts" "$toy/.githooks"
    if ! cp "$R/.githooks/pre-commit" "$toy/.githooks/pre-commit"; then
      printf 'NOT_IMPLEMENTED: не удалось скопировать хук в скратч\n' >&2
      rc=1
    fi
    if [ "$rc" -eq 0 ]; then
      chmod +x "$toy/.githooks/pre-commit"
      cat > "$toy/scripts/check_staged.sh" <<'MINI'
#!/usr/bin/env bash
set -uo pipefail
W="${1:?корень}"
rc=0
while IFS= read -r -d '' f; do
  case "$f" in
    *$'\n'*|*$'\r'*|*$'\t'*)
      printf 'ОТКАЗ: имя с control-символом: %q\n' "$f" >&2; rc=1 ;;
  esac
done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$W" diff --cached --name-only -z 2>/dev/null)
exit "$rc"
MINI
      printf 'ЗОНА implementer: scripts/\n' > "$toy/contracts/001-x.md"
      unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
            GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
      export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
      (
        cd "$toy"
        git -c init.defaultBranch=main init -q
        git config user.name implementer
        git config user.email implementer@local
        git config commit.gpgsign false
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m 'основание'
        git -c user.name=Фикстура -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null tag -a frozen/contracts/001/1 -m 'заморозка'
        # Фаза 1: СЛУЧАЙНОЕ printable имя (фаза 1 сохранена — sniffer-toy ловится здесь)
        clean_token="$(printf '%04x%04x' "$RANDOM" "$RANDOM")"
        printf 'чистый staged для фазы 1\n' > "scripts/clean_${clean_token}.txt"
        git add -- "scripts/clean_${clean_token}.txt"
      )
      (
        cd "$toy"
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        out="$("$toy/.githooks/pre-commit" 2>&1)"; hrc=$?
        printf '%s\n' "$hrc" > "$toy/p1.rc"
        printf '%s' "$out" > "$toy/p1.out"
      )
      p1_rc="$(cat "$toy/p1.rc")"
      p1_out="$(cat "$toy/p1.out")"
      (
        cd "$toy"
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        git reset -q HEAD -- "scripts/clean_${clean_token}.txt" 2>/dev/null
      )
      if [ "$p1_rc" -ne 0 ]; then
        printf 'ОТКАЗ: поведенческая проба связи — чистый staged отклонён (фаза 1: pre-commit вернул rc=%s; sniffer-toy или always-red): %s\n' \
          "$p1_rc" "$p1_out" >&2
        rc=1
      fi
      # Фаза 2: СТАТИЧНОЕ имя `bad\nname.txt` (без случайного токена) — forged
      # выдаёт rc≠0 + именованную причина и декой это считает достаточным.
      if [ "$rc" -eq 0 ]; then
        (
          cd "$toy"
          unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
          export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
          : > $'scripts/bad\nname.txt'
          git add -- . 2>/dev/null
        )
        (
          cd "$toy"
          unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
          export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
          out="$("$toy/.githooks/pre-commit" 2>&1)"; hrc=$?
          printf '%s\n' "$hrc" > "$toy/p2.rc"
          printf '%s' "$out" > "$toy/p2.out"
        )
        p2_rc="$(cat "$toy/p2.rc")"
        p2_out="$(cat "$toy/p2.out")"
        if [ "$p2_rc" -eq 0 ]; then
          printf 'ОТКАЗ: поведенческая проба связи — pre-commit вернул rc=0 на staged-нарушении (фаза 2: отказ без вызова судьи)\n' >&2
          rc=1
        elif ! printf '%s' "$p2_out" | grep -qE 'имя с control-символом|вне зоны:|python3 отсутствует'; then
          printf 'ОТКАЗ: поведенческая проба связи — без именованной причины судьи (rc=%s): %s\n' "$p2_rc" "$p2_out" >&2
          rc=1
        fi
      fi
      trap - EXIT
      rm -rf "$toy"
    fi
  fi
fi
if [ "$rc" -eq 0 ]; then printf 'ok: механизм установки хука цел\n'; fi
exit "$rc"
STAB

# ── фаза 1: стаб честной формы ──────────────────────────────────────────────────
mk_root "$T/r1" "$T/stab-honest.sh"
out="$(run_scoped "$T/r1")"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'стаб честной формы: раннер дал rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "фикстуры check_hooks не проходят против честной формы — красное пачки недостоверно"
fi
for c in case_bez_huka.sh case_huk_ne_vedet_k_sude.sh case_bez_ustanovshhika.sh \
         case_huk_kommentarij_vmesto_zapuska.sh case_inert_heredoc_hook.sh \
         case_huk_sniffer_toy.sh case_huk_forged_output.sh; do
  printf '%s\n' "$out" | grep -q "$c: зелёный контроль есть" \
    || fail "стаб честной формы: $c не предъявил зелёный контроль с красным повтором"
done
printf 'ok: стаб честной формы — все семь case: зелёный контроль + красное повтором\n'

# ── фаза 2: обманные стабы ──────────────────────────────────────────────────────
mk_root "$T/r2" "$T/stab-huk-dekoj.sh"
out="$(run_scoped "$T/r2")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_huk_ne_vedet_k_sude' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб хук-декой пойман на входе case_huk_ne_vedet_k_sude\n'
else
  printf 'стаб хук-декой: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб хук-декой не пойман — ветвь ссылки на судью не держится фикстурой"
fi
mk_root "$T/r3" "$T/stab-ustanovshhik-dekoj.sh"
out="$(run_scoped "$T/r3")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_bez_ustanovshhika' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб установщик-декой пойман на входе case_bez_ustanovshhika\n'
else
  printf 'стаб установщик-декой: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб установщик-декой не пойман — ветвь установщика не держится фикстурой"
fi
mk_root "$T/r4" "$T/stab-proba-slep.sh"
out="$(run_scoped "$T/r4")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_inert_heredoc_hook' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб проба-слеп пойман на входе case_inert_heredoc_hook\n'
else
  printf 'стаб проба-слеп: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб проба-слеп не пойман — поведенческая проба связи не держится фикстурой"
fi
# РЕШЕНИЕ 67fb3b1 §(б)/(в): два новых стаба-декоя, привязка по коду проб (Н-39) — в шапке.
mk_root "$T/r5" "$T/stab-f1-bez.sh"
out="$(run_scoped "$T/r5")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_huk_sniffer_toy' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб ф1-декой пойман на входе case_huk_sniffer_toy\n'
else
  printf 'стаб ф1-декой: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб ф1-декой не пойман — фаза 1 «чистый staged» не держится фикстурой"
fi
mk_root "$T/r6" "$T/stab-f2-fiks-dekoj.sh"
out="$(run_scoped "$T/r6")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_huk_forged_output' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб ф2-фикс-декой пойман на входе case_huk_forged_output\n'
else
  printf 'стаб ф2-фикс-декой: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб ф2-фикс-декой не пойман — фаза 2 без случайного токена не держится фикстурой"
fi

# ── фаза 3: живое дерево — красное пачки до реализации ──────────────────────────
B="$ROOT/scripts/check_hooks.sh"
if [ ! -f "$B" ]; then
  printf 'ОТКАЗ: барьера нет — %s (реализация за implementer после заморозки)\n' "$B" >&2
  exit 1
fi
if bash "$B" "$ROOT" >/dev/null 2>&1; then
  printf 'ok: механизм установки хука цел на живом дереве\n'
  exit 0
fi
fail "барьер красен на живом дереве — механизм установки не коммичен либо сломан"
