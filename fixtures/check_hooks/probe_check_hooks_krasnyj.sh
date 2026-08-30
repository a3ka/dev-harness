#!/usr/bin/env bash
# Проба контракта 016, Q6 (check:hooks — проверка МЕХАНИЗМА установки хука, не
# рантайм-наличия). Три фазы:
#
#   1) СТАБ ЧЕСТНОЙ ФОРМЫ в подставном корне → `verify_antiplacebo --scope
#      check_hooks` rc=0: каждый case предъявляет зелёный контроль ДО порчи и
#      красное повторным прогоном;
#   2) ОБМАННЫЕ СТАБЫ, каждый к входу, где его дефект НАБЛЮДАЕМ (Н-39):
#        хук-декой       → вход case_huk_ne_vedet_k_sude (existence без ссылки);
#        установщик-декой→ вход case_bez_ustanovshhika (нет ветви установщика).
#      Каждый стаб раннер ловит поимённо (rc=1);
#   3) ЖИВОЕ ДЕРЕВО: барьера нет → rc=1 «ОТКАЗ: барьера нет» — красное пачки;
#      после реализации — зелёный прогон на живом дереве (механизм коммичен), rc=0.
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

# СТАБ ЧЕСТНОЙ ФОРМЫ: три ветви механизма — хук коммичен и исполняем; ведёт к
# судье scripts/check_staged.sh (и судья есть); установщик core.hooksPath коммичен.
cat > "$T/stab-honest.sh" <<'STAB'
#!/usr/bin/env bash
# check:hooks (стаб честной формы пробы 016): механизм установки хука — коммиченный .githooks/pre-commit, ведущий к судье, плюс установщик core.hooksPath в package.json
# Коды возврата: 0 — механизм цел; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень}"
rc=0
if [ ! -x "$R/.githooks/pre-commit" ]; then
  printf 'ОТКАЗ: механизм установки без хука — .githooks/pre-commit отсутствует либо не исполняем\n' >&2
  exit 1
fi
# Находка 3 адверсария: ссылка должна быть на НЕ-КОММЕНТАРНОЙ строке (исполняемая связь),
# иначе хук с `# scripts/check_staged.sh` + `exit 0` проходит как валидный.
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

# ── фаза 1: стаб честной формы ──────────────────────────────────────────────────
mk_root "$T/r1" "$T/stab-honest.sh"
out="$(run_scoped "$T/r1")"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'стаб честной формы: раннер дал rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "фикстуры check_hooks не проходят против честной формы — красное пачки недостоверно"
fi
for c in case_bez_huka.sh case_huk_ne_vedet_k_sude.sh case_bez_ustanovshhika.sh; do
  printf '%s\n' "$out" | grep -q "$c: зелёный контроль есть" \
    || fail "стаб честной формы: $c не предъявил зелёный контроль с красным повтором"
done
printf 'ok: стаб честной формы — все три case: зелёный контроль + красное повтором\n'

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
