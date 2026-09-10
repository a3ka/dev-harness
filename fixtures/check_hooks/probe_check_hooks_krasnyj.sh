#!/usr/bin/env bash
# Проба контракта 016 → мир 022 (Q6: check:hooks — проверка МЕХАНИЗМА установки
# хуков, не рантайм-наличия). Три фазы:
#
#   1) СТАБ ЧЕСТНОЙ ФОРМЫ в подставном корне → `verify_antiplacebo --scope
#      check_hooks` rc=0 на ВСЕХ case семьи (счёт — из факта дерева): каждый case
#      предъявляет зелёный контроль ДО порчи и красное повторным прогоном.
#      Честная форма мира 022 — ПОЛНЫЙ механизм (приём _mehanizm.sh конверсии
#      6f6bf96): фазы 1-5 pre-commit (двухфазная поведенческая проба, РЕШЕНИЕ
#      67fb3b1 §(в)) И фазы 6-8 pre-push (контракт 022, И-4/И-10: существование,
#      не-комментарная exec-связь с кольцом, двухфазная push-проба с тройкой
#      ref+sha+путь по полям — арбитражи b43d7a0/f712e6e). Кольцо и ЖИВАЯ копия
#      pre-push — из дерева (mk_root): зелёный контроль семьи case_push_proba
#      обязан быть честным механизмом, не заглушкой (А-101). Стаб 016-эпохи без
#      push-фаз красил 4 фикстуры этой семьи «барьер остался зелёным» — находка
#      union-батареи 2026-09-10, закрыта здесь.
#   2) ОБМАННЫЕ СТАБЫ, каждый к входу, где его дефект НАБЛЮДАМ (Н-39, привязка
#      стабов-декоев к коду проб — в комментариях у каждого стаба):
#        хук-декой        → вход case_huk_ne_vedet_k_sude (нет ветви ссылки на
#                           судью и поведенческой пробы pre-commit);
#        установщик-декой → вход case_bez_ustanovshhika (нет ветви установщика);
#        проба-слеп       → вход case_inert_heredoc_hook (текст-ветви есть,
#                           поведенческой пробы нет: heredoc-хук проходит awk);
#        ф1-декой         → вход case_huk_sniffer_toy (нет фазы 1 «чистый staged»:
#                           sniffer-toy проходит проверку одной фазы);
#        ф2-фикс-декой    → вход case_huk_forged_output (фаза 2 без случайного
#                           токена: forged проходит проверку без token-grep).
#      Каждый декой — та же ПОЛНАЯ форма (включая фазы 6-8) МИНУС именованный
#      дефект: декой без push-фаз умирал бы на фикстурах push-семьи «за
#      компанию», и поимённая ловля перестала бы доказывать ветвь. Раннер ловит
#      поимённо: FAIL-строка «case_X: барьер остался зелёным» (rc=1).
#   3) ЖИВОЕ ДЕРЕВО: полный check_hooks (pre-commit + pre-push) зелёный.
#
# Стаб честной формы обязан отражать двухфазную семантику живого барьера
# (РЕШЕНИЕ 67fb3b1, §(в)): фаза 1 «чистый staged» со случайным printable-именем,
# фаза 2 «нарушение» с control-символом + СЛУЧАЙНЫЙ токен (генерация на вызов).
# Предел §(в) п.4: токен — НЕ литерал в коде пробы.
#
# Коды возврата: 0 — все фазы зелёные; 1 — именованный отказ; 2 — нечем проверить
#      (дерево без механизма pre-push/кольца — честная форма мира 022 невыразима)
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
T="$(mktemp -d /tmp/probe016-hooks.XXXXXX)"   # А-59: literal /tmp — ${TMPDIR} в окружении пуст
trap 'rm -rf "$T"' EXIT
fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

mk_root() {  # <dir> <файл-стаб>
  mkdir -p "$1/scripts" "$1/fixtures/check_hooks" "$1/.githooks"
  cp "$ROOT/scripts/verify_antiplacebo.sh" "$1/scripts/"
  cp "$ROOT/scripts/scope_select.sh"        "$1/scripts/"
  # Мир 022, приём _mehanizm.sh: кольцо и ЖИВАЯ копия pre-push — из дерева.
  # Раннер подставного корня выставляет фикстурам REPO=<этот корень>, и семья
  # case_push_proba строит зелёный контроль из $REPO/.githooks/pre-push; фазы
  # 6-8 стаба берут кольцо из СВОЕГО SELF_DIR (= scripts/ этого корня).
  cp "$ROOT/scripts/check_charter.sh" "$ROOT/scripts/next_id.sh" \
     "$ROOT/scripts/lib_registry.sh" "$1/scripts/"
  cp "$ROOT/.githooks/pre-push" "$1/.githooks/pre-push"
  cp "$2" "$1/scripts/check_hooks.sh"
  cp "$ROOT"/fixtures/check_hooks/*.sh "$1/fixtures/check_hooks/"
}
run_scoped() { bash "$1/scripts/verify_antiplacebo.sh" "$1" --scope check_hooks 2>&1; }

# Предпосылка мира 022: без механизма pre-push/кольца честная форма стаба
# невыразима — тихое сужение до 016-формы красило бы фикстуры push-семьи ложно.
for need in .githooks/pre-push scripts/check_charter.sh scripts/next_id.sh \
            scripts/lib_registry.sh; do
  [ -f "$ROOT/$need" ] || {
    printf 'ОТКАЗ: нечем проверить — в дереве нет %s (мир 022: честной форме стаба нужны фазы 6-8)\n' \
      "$need" >&2
    exit 2
  }
done

# ── фазы 6-8 (pre-push) — ЕДИНЫЙ ИСТОЧНИК для всех шести стабов ─────────────────
# Зеркалит живой scripts/check_hooks.sh (контракт 022, И-10): стаб судит хук из
# проверяемого корня против живого кольца из SELF_DIR. Тексты причин — побайтово
# из живого барьера: фикстуры семьи case_push_proba грепают их подстроки
# («pre-push не судит или fail-open», «путь уставного файла не назван», «без
# полного sha красного коммита», «без полного refs/heads/main») и проходят против
# честной формы только при совпадении грамматики (Н-39: потребители несут её
# побайтово, переизобретение запрещено).
PUSH_FAZY="$(cat <<'PUSHFAZY'
# ── фазы 6-8: механизм pre-push (контракт 022, И-4/И-10) ────────────────────────
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -e "$R/.githooks/pre-push" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-push отсутствует\n' >&2
  rc=1
elif [ ! -f "$R/.githooks/pre-push" ]; then
  printf 'ОТКАЗ: .githooks/pre-push — не обычный файл\n' >&2
  rc=1
elif [ ! -x "$R/.githooks/pre-push" ]; then
  printf 'ОТКАЗ: .githooks/pre-push существует, но не исполняем (chmod +x)\n' >&2
  rc=1
fi
if [ -x "$R/.githooks/pre-push" ]; then
  if ! awk '/^[[:space:]]*#/ { next }; /scripts[/[:space:]]?check_charter\.sh/ { f=1 }; END { exit(f?0:1) }' \
       "$R/.githooks/pre-push"; then
    printf 'ОТКАЗ: хук не ведёт к кольцу — .githooks/pre-push не импортирует scripts/check_charter.sh (комментарий не считается связью)\n' >&2
    rc=1
  fi
fi
if [ "$rc" -eq 0 ]; then
  push_scratch="$(mktemp -d)" || {
    rc=1; printf 'NOT_IMPLEMENTED: не удалось создать скратч для push-пробы\n' >&2; }
  if [ "$rc" -eq 0 ]; then
    trap 'rm -rf "$push_scratch"' EXIT
    mkdir -p "$push_scratch/scripts" "$push_scratch/contracts" \
             "$push_scratch/.githooks" "$push_scratch/hooks" \
             "$push_scratch/toy/contracts" "$push_scratch/toy/scripts"
    if ! cp "$R/.githooks/pre-push" "$push_scratch/.githooks/pre-push" \
       || ! cp "$R/.githooks/pre-push" "$push_scratch/hooks/pre-push" \
       || ! cp "$SELF_DIR/check_charter.sh" "$push_scratch/scripts/check_charter.sh" \
       || ! cp "$SELF_DIR/next_id.sh" "$push_scratch/scripts/next_id.sh" \
       || ! cp "$SELF_DIR/lib_registry.sh" "$push_scratch/scripts/lib_registry.sh" \
       || ! cp "$SELF_DIR/check_charter.sh" "$push_scratch/toy/scripts/check_charter.sh" \
       || ! cp "$SELF_DIR/next_id.sh" "$push_scratch/toy/scripts/next_id.sh" \
       || ! cp "$SELF_DIR/lib_registry.sh" "$push_scratch/toy/scripts/lib_registry.sh"; then
      printf 'NOT_IMPLEMENTED: не удалось скопировать хук или кольцо в скратч push-пробы\n' >&2
      rc=1
    fi
    if [ "$rc" -eq 0 ]; then
      chmod +x "$push_scratch/.githooks/pre-push" "$push_scratch/hooks/pre-push"
      ORIG_DIR="$push_scratch/origin.git"
      T_DIR="$push_scratch/toy"
      (
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        git init -q --bare "$ORIG_DIR"
        git -C "$ORIG_DIR" symbolic-ref HEAD refs/heads/main
        git -c init.defaultBranch=main init -q "$T_DIR"
        git -C "$T_DIR" config user.name Фикстура
        git -C "$T_DIR" config user.email fixture@local
        git -C "$T_DIR" config commit.gpgsign false
        git -C "$T_DIR" config core.hooksPath "$push_scratch/hooks"
        printf '# подставной контракт 001 (уставной с заморозки)\n' > "$T_DIR/contracts/001-x.md"
        git -C "$T_DIR" add -A
        git -C "$T_DIR" commit -q -m 'основание: подставной замороженный контракт'
        git -C "$T_DIR" tag -a frozen/contracts/001/1 -m 'заморозка'
        git -C "$T_DIR" remote add origin "$ORIG_DIR"
        git -C "$T_DIR" push -q origin main
      )
      # Фаза 1 (чистая): коммит с нейтральным (вне устава) путём → пуш зелёный;
      # no-op / sniffer / всегда-красный подделки краснеют здесь.
      (
        unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
              GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
        export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
        printf 'нейтральный предмет поведенческой push-пробы\n' > "$T_DIR/scripts/clean_${RANDOM}.txt"
        git -C "$T_DIR" add -A
        git -C "$T_DIR" commit -q -m 'нейтральный коммит для push-пробы'
      )
      set +e
      out_p1="$(cd "$T_DIR" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
        git -c commit.gpgsign=false push origin main 2>&1)"
      rc_p1=$?
      set -e
      if [ "$rc_p1" -ne 0 ]; then
        printf 'ОТКАЗ: поведенческая push-проба — чистый пуш отклонён (pre-push вернул rc=%s на нейтральном коммите; sniffer/no-op подделка pre-push): %s\n' \
          "$rc_p1" "$out_p1" >&2
        rc=1
      fi
      # Фаза 2 (красная): устав-дельта M без РАЗРЕШИЛ → пуш отвергнут ∧ тройка
      # ref+sha+путь (пер-полевая форма различения — арбитраж f712e6e) ∧
      # origin-ref не двинулся. Sha красного коммита СЛУЧАЕН на вызов.
      if [ "$rc" -eq 0 ]; then
        red_token="$(printf '%016x' "$((RANDOM*RANDOM&0xFFFFFFFFFFFFFFFF))")"
        (
          unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
          export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
          printf '\nуставная дельта без строки (токен %s)\n' "$red_token" \
            >> "$T_DIR/contracts/001-x.md"
          git -C "$T_DIR" add -A
          git -C "$T_DIR" commit -q -m "красный коммит: устав-дельта M без РАЗРЕШИЛ (push-проба)"
        )
        RED_SHA="$(git -C "$T_DIR" rev-parse main)"
        GREEN_SHA="$(git -C "$ORIG_DIR" rev-parse --verify refs/heads/main)"
        set +e
        out_p2="$(cd "$T_DIR" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
          git -c commit.gpgsign=false push origin main 2>&1)"
        rc_p2=$?
        set -e
        if [ "$rc_p2" -eq 0 ]; then
          printf 'ОТКАЗ: поведенческая push-проба — красный диапазон прошёл (rc=0); pre-push не судит или fail-open: %s\n' \
            "$out_p2" >&2
          rc=1
        elif ! printf '%s\n' "$out_p2" | grep -qF 'contracts/001-x.md'; then
          printf 'ОТКАЗ: поведенческая push-проба — pre-push отверг без именованной причины (путь уставного файла не назван): %s\n' \
            "$out_p2" >&2
          rc=1
        elif ! printf '%s\n' "$out_p2" | grep -qF "$RED_SHA"; then
          printf 'ОТКАЗ: поведенческая push-проба — pre-push назвал причину без полного sha красного коммита %s (тройка равномерно, арбитраж b43d7a0): %s\n' \
            "$RED_SHA" "$out_p2" >&2
          rc=1
        elif ! printf '%s\n' "$out_p2" | grep -qF 'refs/heads/main'; then
          printf 'ОТКАЗ: поведенческая push-проба — pre-push назвал причину без полного refs/heads/main (тройка равномерно, арбитраж b43d7a0): %s\n' \
            "$out_p2" >&2
          rc=1
        fi
        # origin-ref не должен двинуться.
        AFTER_SHA="$(git -C "$ORIG_DIR" rev-parse --verify refs/heads/main)"
        if [ "$AFTER_SHA" != "$GREEN_SHA" ]; then
          printf 'ОТКАЗ: поведенческая push-проба — origin-ref двинулся (%s → %s) при отвергнутом pre-push красном пуше\n' \
            "$GREEN_SHA" "$AFTER_SHA" >&2
          rc=1
        fi
      fi
      trap - EXIT
      rm -rf "$push_scratch"
    fi
  fi
fi
PUSHFAZY
)"

# Хвост стаба: фазы 6-8 из единого источника + финал. Все шесть стабов несут
# push-фазы ПОБАЙТОВО ОДНИМИ И ТЕМИ ЖЕ (дефект декаев — только в pre-commit-ветвях).
zavershit_stab() {  # <файл-стаб>
  { printf '%s\n' "$PUSH_FAZY"
    cat <<'HVOST'

if [ "$rc" -eq 0 ]; then printf 'ok: механизм установки хука цел (стаб: pre-commit + pre-push)\n'; fi
exit "$rc"
HVOST
  } >> "$1"
}

# СТАБ ЧЕСТНОЙ ФОРМЫ (полный механизм 016+022):
# Фаза 1 — clean staged СЛУЧАЙНЫМ printable-именем в зоне implementer: pre-commit обязан
# вернуть rc=0 (sniffer-toy и always-red ловятся именно здесь: «чистый staged отклонён»).
# Фаза 2 — staged-имя с control-символом + СЛУЧАЙНЫМ токеном, генерация на КАЖДЫЙ ВЫЗОВ
# пробы ($RANDOM): pre-commit обязан вернуть rc≠0 И именованную причину И сам токен
# (forged-output ловится здесь: «токен X не упомянут»). Случайные токены — на вызов,
# не литералы в исходнике (предел §(в) п.4).
# Мини-судья внутри стаба (копию SELF_DIR не делаем — стаб-корень пробы соседей не несёт;
# кольцо для фаз 6-8 — исключение: живое, из дерева, см. mk_root).
cat > "$T/stab-honest.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб честной формы пробы, мир 016+022): полный механизм установки —
# фазы 1-5 pre-commit (двухфазная поведенческая проба связи, РЕШЕНИЕ 67fb3b1 §(в))
# и фазы 6-8 pre-push (контракт 022, И-4/И-10, блоком единого источника пробы).
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
STAB
zavershit_stab "$T/stab-honest.sh"

# Обманный стаб «хук-декой»: проверяет наличие/исполняемость и установщика, но НЕ
# ссылку на судью и НЕ поведенческую пробу pre-commit. Различим на входе
# case_huk_ne_vedet_k_sude: pre-commit без ссылки честный красен, декой молчит.
# Push-фазы 6-8 — полной формой (дефект только в pre-commit-ветвях).
cat > "$T/stab-huk-dekoj.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы): хук коммичен и подключаем — и довольно (ветви ссылки
# на судью и поведенческой пробы pre-commit отсутствуют; фазы 6-8 — полной формой)
# Коды возврата: 0 — механизм цел; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
rc=0
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  rc=1
fi
if ! grep -q 'core\.hooksPath' "$R/package.json" 2>/dev/null || ! grep -q '\.githooks' "$R/package.json" 2>/dev/null; then
  printf 'ОТКАЗ: нет механизма установки — package.json не несёт команды core.hooksPath на .githooks\n' >&2
  rc=1
fi
STAB
zavershit_stab "$T/stab-huk-dekoj.sh"

# Обманный стаб «установщик-декой»: проверяет хук и ссылку, но НЕ установщика.
# Различим на входе case_bez_ustanovshhika: package.json без core.hooksPath честный
# красен, декой молчит. Push-фазы 6-8 — полной формой.
cat > "$T/stab-ustanovshhik-dekoj.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы): хук и судья коммичены — установка сама наставится
# (ветви установщика и поведенческой пробы отсутствуют; фазы 6-8 — полной формой)
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
STAB
zavershit_stab "$T/stab-ustanovshhik-dekoj.sh"

# Обманный стаб «проба-слеп»: текстовые ветви 1-4 без поведенческой пробы — форма,
# проходившая до находки 2 раунда 2. Различим на входе case_inert_heredoc_hook:
# heredoc-хук проходит awk, проба отсутствует → барьер зелёный на пустышке.
# Push-фазы 6-8 — полной формой (дефект только в pre-commit-пробе).
cat > "$T/stab-proba-slep.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы): текст-ветви без поведенческой пробы связи
# (фазы 6-8 — полной формой)
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
STAB
zavershit_stab "$T/stab-proba-slep.sh"

# Обманный стаб «ф1-декой» (фаза 1 отсутствует): однофазная поведенческая проба только
# с нарушением (фиксированное `bad\nname.txt`), фаза 1 «чистый staged» не запускается.
# Различим на входе case_huk_sniffer_toy: sniffer красит чистый staged → «чистый отклонён»;
# декой без фазы 1 пропускает sniffer-toy (однофазной проверки на нарушении достаточно —
# sniffer возвращает rc=1 с именованной причиной, декой это считает отказом судьи).
# Также различим на case_inert_heredoc_hook (наследуется от проба-слеп-стороны).
# Push-фазы 6-8 — полной формой.
cat > "$T/stab-f1-bez.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы): однофазная поведенческая проба (нарушение со статичным именем),
# фаза 1 «чистый staged» ОТСУТСТВУЕТ — sniffer-toy проходит (фазы 6-8 — полной формой).
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
STAB
zavershit_stab "$T/stab-f1-bez.sh"

# Обманный стаб «ф2-фикс-декой» (фаза 2 без случайного токена): двухфазная поведенческая
# проба, но фаза 2 использует СТАТИЧНОЕ имя `bad\nname.txt` без случайного токена — forged
# проходит (константная причина). Различим на входе case_huk_forged_output: forged красит
# «случайный токен X не упомянут»; декой без token-grep пропускает forged.
# Также продолжает ловить case_huk_sniffer_toy (фаза 1 «чистый staged» с random printable
# в деке сохранена — sniffer красит чистый staged).
# Push-фазы 6-8 — полной формой.
cat > "$T/stab-f2-fiks-dekoj.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб пробы): двухфазная поведенческая проба, фаза 2 со СТАТИЧНЫМ именем
# (НЕ случайный токен) — forged-output проходит, декой его пропускает
# (фазы 6-8 — полной формой).
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
      # выдаёт rc≠0 + именованную причину и декой это считает достаточным.
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
STAB
zavershit_stab "$T/stab-f2-fiks-dekoj.sh"

# ── фаза 1: стаб честной формы ──────────────────────────────────────────────────
mk_root "$T/r1" "$T/stab-honest.sh"
out="$(run_scoped "$T/r1")"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'стаб честной формы: раннер дал rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "фикстуры check_hooks не проходят против честной формы — красное пачки недостоверно"
fi
case_count=0
for c in "$ROOT"/fixtures/check_hooks/case_*.sh; do
  b="$(basename "$c")"
  printf '%s\n' "$out" | grep -q "$b: зелёный контроль есть" \
    || fail "стаб честной формы: $b не предъявил зелёный контроль с красным повтором"
  case_count=$((case_count + 1))
done
[ "$case_count" -gt 0 ] || fail "в дереве нет case-фикстур check_hooks — пустая выборка не зелёная"
printf 'ok: стаб честной формы (фазы 1-8) — все %d case: зелёный контроль + красное повтором\n' "$case_count"

# ── фаза 2: обманные стабы ──────────────────────────────────────────────────────
# Поимённая ловля — FAIL-строкой раннера (не любым упоминанием имени: ok-строка
# тоже содержит имя case, и grep по подстроке ловил бы «пойманного» дека,
# который на деле прошёл проверку).
lovit() {  # <dir> <стаб> <case-имя> <имя-стаба>
  mk_root "$1" "$2"
  out="$(run_scoped "$1")"; rc=$?
  if [ "$rc" -eq 1 ] \
     && printf '%s\n' "$out" | grep -q "FAIL check_hooks/$3.sh: барьер остался зелёным"; then
    printf 'ok: стаб %s пойман на входе %s\n' "$4" "$3"
  else
    printf 'стаб %s: rc=%d:\n%s\n' "$4" "$rc" "$out" >&2
    fail "стаб $4 не пойман — именованная ветвь не держится фикстурой $3"
  fi
}
lovit "$T/r2" "$T/stab-huk-dekoj.sh"          case_huk_ne_vedet_k_sude  'хук-декой'
lovit "$T/r3" "$T/stab-ustanovshhik-dekoj.sh" case_bez_ustanovshhika    'установщик-декой'
lovit "$T/r4" "$T/stab-proba-slep.sh"         case_inert_heredoc_hook  'проба-слеп'
# РЕШЕНИЕ 67fb3b1 §(б)/(в): два стаба-декоя, привязка по коду проб (Н-39) — выше.
lovit "$T/r5" "$T/stab-f1-bez.sh"             case_huk_sniffer_toy     'ф1-декой'
lovit "$T/r6" "$T/stab-f2-fiks-dekoj.sh"      case_huk_forged_output   'ф2-фикс-декой'

# ── фаза 3: живое дерево ────────────────────────────────────────────────────────
B="$ROOT/scripts/check_hooks.sh"
if [ ! -f "$B" ]; then
  printf 'ОТКАЗ: барьера нет — %s (реализация за implementer после заморозки)\n' "$B" >&2
  exit 1
fi
if bash "$B" "$ROOT" >/dev/null 2>&1; then
  printf 'ok: механизм установки хука цел на живом дереве (pre-commit + pre-push)\n'
  exit 0
fi
fail "барьер красен на живом дереве — механизм установки не коммичен либо сломан"
