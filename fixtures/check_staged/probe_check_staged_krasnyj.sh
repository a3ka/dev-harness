#!/usr/bin/env bash
# Проба контракта 016, срез 1 (барьер add-A — судья staged-множества). Три фазы:
#
#   1) СТАБ ЧЕСТНОЙ ФОРМЫ в подставном корне (копии раннера, селектора, фикстур
#      каталога) → `verify_antiplacebo --scope check_staged` rc=0: каждый case
#      предъявляет зелёный контроль ДО порчи и красное повторным прогоном —
#      раннерные инварианты выполняются против честной формы, фикстуры не пустые;
#   2) ОБМАННЫЕ СТАБЫ, каждый к входу, где его дефект НАБЛЮДАЕМ (Н-39):
#        зоны-слеп       → вход case_vne_zon (чистое имя вне всякой зоны);
#        грамматика-слеп → вход case_imja_control_simvol (перенос в имени ВНУТРИ зоны);
#        всё-красно      → зелёный контроль (нет rc=0 вызова вовсе);
#        канарейка-слеп  → вход case_imja_fake_python3_exit_1 (подменённый python3
#                          `exit 1`: без канарейки конвейер молчит «чисто»).
#      Каждый стаб раннер ловит поимённо (rc=1);
#   3) ЖИВОЕ ДЕРЕВО: барьера нет → rc=1 «ОТКАЗ: барьера нет» — красное пачки
#      (реализация за implementer после заморозки); после реализации — зелёный
#      прогон судьи на живом дереве, rc=0.
#
# Коды возврата: 0 — все фазы зелёные (после реализации); 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
T="$(mktemp -d /tmp/probe016-staged.XXXXXX)"   # А-59: literal /tmp — ${TMPDIR} в окружении пуст
trap 'rm -rf "$T"' EXIT
fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# ── подставной корень: раннер + селектор + судья (стаб) + фикстуры каталога ──────
# Сверка §2 раннера идёт ДО scoped-фильтра: лишних каталогов фикстур в корне НЕТ,
# ровно один ключ check_staged.
mk_root() {  # <dir> <файл-стаб>
  mkdir -p "$1/scripts" "$1/fixtures/check_staged"
  cp "$ROOT/scripts/verify_antiplacebo.sh" "$1/scripts/"
  cp "$ROOT/scripts/scope_select.sh"        "$1/scripts/"
  cp "$2" "$1/scripts/check_staged.sh"
  cp "$ROOT"/fixtures/check_staged/*.sh "$1/fixtures/check_staged/"
}
run_scoped() { bash "$1/scripts/verify_antiplacebo.sh" "$1" --scope check_staged 2>&1; }

# ── стабы: общая головка честной формы — CLI контракта 016 (<корень>; автор из
# ЛОКАЛЬНОГО конфига репо — Q3; staged из индекса), варианты отличаются телом судьи.

# СТАБ ЧЕСТНОЙ ФОРМЫ: зоны автора (грамматика ЗОНА-строк та же, что у check_zones)
# + грамматика имени (control-символы) с само-канарейкой python3-конвейера (находка 1
# раунда 2: подменённый python3 обязан ловиться до приговора имени).
cat > "$T/stab-honest.sh" <<'STAB'
#!/usr/bin/env bash
# судья staged-множества (стаб честной формы пробы 016): зоны автора из замороженных контрактов + грамматика имени
# Коды возврата: 0 — staged пуст, автор не объявлен либо всё в зоне; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень репо}"
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий\n' "$R" >&2; exit 2; }
author="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.name 2>/dev/null || true)"
mapfile -d '' staged < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" diff --cached --name-only -z 2>/dev/null)
if [ "${#staged[@]}" -eq 0 ]; then printf 'нечего судить: staged пуст\n'; exit 0; fi
if [ -z "$author" ]; then printf 'автор не объявлен — не судится\n'; exit 0; fi
zones=()
declare -A vmax=()
while IFS= read -r tag; do
  rest="${tag#refs/tags/frozen/contracts/}"; nnn="${rest%%/*}"; v="$((10#${rest##*/}))"
  if [ -n "${vmax[$nnn]:-}" ] && [ "$v" -le "${vmax[$nnn]}" ]; then continue; fi
  vmax["$nnn"]="$v"
done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/')
for nnn in "${!vmax[@]}"; do
  v="${vmax[$nnn]}"
  f="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" ls-tree -r --name-only \
       "refs/tags/frozen/contracts/$nnn/$v^{commit}" -- ':(literal)contracts/' 2>/dev/null \
       | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
  [ -n "$f" ] || continue
  while IFS= read -r line; do
    restl="${line#ЗОНА }"; a="${restl%%:*}"; paths="${restl#*:}"
    [ "$a" = "$author" ] || continue
    set -f; for p in $paths; do zones+=("$p"); done; set +f
  done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" cat-file -p \
           "refs/tags/frozen/contracts/$nnn/$v^{commit}:$f" 2>/dev/null | grep '^ЗОНА ' || true)
done
if ! command -v python3 >/dev/null 2>&1; then
  printf 'ОТКАЗ: невозможно проверить control-символ в имени — python3 отсутствует в PATH (судья не может исполнить проверку control-символов, fail-closed)\n' >&2
  exit 1
fi
_py_check() {
  python3 -c '
import sys
s = sys.stdin.read()
r = any((ord(c) < 0x20) or (ord(c) == 0x7f) for c in s)
sys.stdout.write("1" if r else "0")
sys.exit(0 if r else 1)'
}
# Канарейка (находка 1 раунда 2, `fake-python3-exit-1`): тот же конвейер на заведомо
# грязном и чистом stdin — оба прогона обязаны дать ожидаемый exit code И маркер.
cc_out="$(printf 'a\nb' | _py_check)"
cc_rc=$?
cl_out="$(printf 'clean' | _py_check)"
cl_rc=$?
if [ "$cc_rc" -ne 0 ] || [ "$cc_out" != "1" ] || [ "$cl_rc" -ne 1 ] || [ "$cl_out" != "0" ]; then
  printf 'ОТКАЗ: судья не может исполнить проверку control-символов — канарейка не подтверждена (python3 подменён, exit≠0, 0-rc заглушка или обрезка вывода)\n' >&2
  exit 1
fi
rc=0
for f in "${staged[@]}"; do
  m="$(printf '%s' "$f" | _py_check)"
  if [ "$m" = "1" ]; then
    printf 'ОТКАЗ: имя с control-символом: %q\n' "$f" >&2
    rc=1
    continue
  fi
  inzone=1
  for p in "${zones[@]}"; do
    case "$p" in
      */) case "$f" in "$p"*) inzone=0; break ;; esac ;;
      *)  [ "$f" = "$p" ] && { inzone=0; break; } ;;
    esac
  done
  if [ "$inzone" -eq 1 ]; then printf 'ОТКАЗ: вне зоны: %s\n' "$f" >&2; rc=1; fi
done
if [ "$rc" -eq 0 ]; then printf 'ok: staged в зоне автора %s\n' "$author"; fi
exit "$rc"
STAB

# Обманный стаб «зоны-слеп»: судит только грамматику имени, замороженные теги не
# читает. Различим на входе case_vne_zon: чистое имя вне всякой зоны — честный
# красен «вне зоны», стаб молчит.
cat > "$T/stab-zones-slep.sh" <<'STAB'
#!/usr/bin/env bash
# судья staged-множества: только грамматика имени (стаб пробы 016)
# Коды возврата: 0 — staged пуст, автор не объявлен либо всё в зоне; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень репо}"
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий\n' "$R" >&2; exit 2; }
mapfile -d '' staged < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" diff --cached --name-only -z 2>/dev/null)
[ "${#staged[@]}" -eq 0 ] && { printf 'нечего судить: staged пуст\n'; exit 0; }
rc=0
for f in "${staged[@]}"; do
  case "$f" in
    *$'\n'*|*$'\r'*|*$'\t'*)
      printf 'ОТКАЗ: имя с control-символом: %q\n' "$f" >&2; rc=1 ;;
  esac
done
if [ "$rc" -eq 0 ]; then printf 'ok: имена чистые\n'; fi
exit "$rc"
STAB

# Обманный стаб «грамматика-слеп»: судит только зоны. Различим на входе
# case_imja_control_simvol: имя с переносом ВНУТРИ зоны — префикс-матч зон его
# пропускает, честный красен грамматикой имени, стаб молчит.
cat > "$T/stab-gramm-slep.sh" <<'STAB'
#!/usr/bin/env bash
# судья staged-множества: только зоны автора (стаб пробы 016)
# Коды возврата: 0 — staged пуст, автор не объявлен либо всё в зоне; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень репо}"
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий\n' "$R" >&2; exit 2; }
author="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.name 2>/dev/null || true)"
mapfile -d '' staged < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" diff --cached --name-only -z 2>/dev/null)
if [ "${#staged[@]}" -eq 0 ]; then printf 'нечего судить: staged пуст\n'; exit 0; fi
if [ -z "$author" ]; then printf 'автор не объявлен — не судится\n'; exit 0; fi
zones=()
declare -A vmax=()
while IFS= read -r tag; do
  rest="${tag#refs/tags/frozen/contracts/}"; nnn="${rest%%/*}"; v="$((10#${rest##*/}))"
  if [ -n "${vmax[$nnn]:-}" ] && [ "$v" -le "${vmax[$nnn]}" ]; then continue; fi
  vmax["$nnn"]="$v"
done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/')
for nnn in "${!vmax[@]}"; do
  v="${vmax[$nnn]}"
  f="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" ls-tree -r --name-only \
       "refs/tags/frozen/contracts/$nnn/$v^{commit}" -- ':(literal)contracts/' 2>/dev/null \
       | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
  [ -n "$f" ] || continue
  while IFS= read -r line; do
    restl="${line#ЗОНА }"; a="${restl%%:*}"; paths="${restl#*:}"
    [ "$a" = "$author" ] || continue
    set -f; for p in $paths; do zones+=("$p"); done; set +f
  done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" cat-file -p \
           "refs/tags/frozen/contracts/$nnn/$v^{commit}:$f" 2>/dev/null | grep '^ЗОНА ' || true)
done
rc=0
for f in "${staged[@]}"; do
  inzone=1
  for p in "${zones[@]}"; do
    case "$p" in
      */) case "$f" in "$p"*) inzone=0; break ;; esac ;;
      *)  [ "$f" = "$p" ] && { inzone=0; break; } ;;
    esac
  done
  if [ "$inzone" -eq 1 ]; then printf 'ОТКАЗ: вне зоны: %s\n' "$f" >&2; rc=1; fi
done
if [ "$rc" -eq 0 ]; then printf 'ok: staged в зоне автора %s\n' "$author"; fi
exit "$rc"
STAB

# Обманный стаб «всё-красно»: красит любой staged-путь. Различим на зелёном
# контроле — rc=0 вызова нет вовсе, раннер ловит «нет положительного контроля».
cat > "$T/stab-vsyo-krasno.sh" <<'STAB'
#!/usr/bin/env bash
# судья staged-множества: зонный параноик (стаб пробы 016)
# Коды возврата: 0 — staged пуст, автор не объявлен либо всё в зоне; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень репо}"
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий\n' "$R" >&2; exit 2; }
mapfile -d '' staged < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" diff --cached --name-only -z 2>/dev/null)
if [ "${#staged[@]}" -eq 0 ]; then printf 'нечего судить: staged пуст\n'; exit 0; fi
for f in "${staged[@]}"; do
  printf 'ОТКАЗ: вне зоны: %s\n' "$f" >&2
done
exit 1
STAB


# Обманный стаб «канарейка-слеп»: зоны + грамматика через python3-конвейер, но БЕЗ
# само-канарейки — rc конвейера единственный сигнал. Различим на входах обоих
# case_imja_fake_python3_*: стаб `exit 1` даёт конвейеру rc=1 → «чистое имя» → зона
# молчит → барьер зелёный на подменённом инструменте (ловит «красное не предъявлено»
# на exit_1); стаб `exit 0` красит ВСЁ, включая зелёный смысл — причина не та
# (ловит «не назвал причину» на exit_0). Честная форма красна канарейкой на обоих.
cat > "$T/stab-kanarejka-slep.sh" <<'STAB'
#!/usr/bin/env bash
# судья staged-множества: зоны + python3-грамматика, без канарейки (стаб пробы 016)
# Коды возврата: 0 — staged пуст, автор не объявлен либо всё в зоне; 1 — именованный отказ; 2 — нечем проверить
set -uo pipefail
R="${1:?нужен корень репо}"
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий\n' "$R" >&2; exit 2; }
author="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.name 2>/dev/null || true)"
mapfile -d '' staged < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" diff --cached --name-only -z 2>/dev/null)
if [ "${#staged[@]}" -eq 0 ]; then printf 'нечего судить: staged пуст\n'; exit 0; fi
if [ -z "$author" ]; then printf 'автор не объявлен — не судится\n'; exit 0; fi
zones=()
declare -A vmax=()
while IFS= read -r tag; do
  rest="${tag#refs/tags/frozen/contracts/}"; nnn="${rest%%/*}"; v="$((10#${rest##*/}))"
  if [ -n "${vmax[$nnn]:-}" ] && [ "$v" -le "${vmax[$nnn]}" ]; then continue; fi
  vmax["$nnn"]="$v"
done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/')
for nnn in "${!vmax[@]}"; do
  v="${vmax[$nnn]}"
  f="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" ls-tree -r --name-only \
       "refs/tags/frozen/contracts/$nnn/$v^{commit}" -- ':(literal)contracts/' 2>/dev/null \
       | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
  [ -n "$f" ] || continue
  while IFS= read -r line; do
    restl="${line#ЗОНА }"; a="${restl%%:*}"; paths="${restl#*:}"
    [ "$a" = "$author" ] || continue
    set -f; for p in $paths; do zones+=("$p"); done; set +f
  done < <(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" cat-file -p \
           "refs/tags/frozen/contracts/$nnn/$v^{commit}:$f" 2>/dev/null | grep '^ЗОНА ' || true)
done
if ! command -v python3 >/dev/null 2>&1; then
  printf 'ОТКАЗ: невозможно проверить control-символ в имени — python3 отсутствует в PATH (судья не может исполнить проверку control-символов, fail-closed)\n' >&2
  exit 1
fi
rc=0
for f in "${staged[@]}"; do
  if printf '%s' "$f" | python3 -c 'import sys
s = sys.stdin.read()
sys.exit(0 if any((ord(c) < 0x20) or (ord(c) == 0x7f) for c in s) else 1)'; then
    printf 'ОТКАЗ: имя с control-символом: %q\n' "$f" >&2
    rc=1
    continue
  fi
  inzone=1
  for p in "${zones[@]}"; do
    case "$p" in
      */) case "$f" in "$p"*) inzone=0; break ;; esac ;;
      *)  [ "$f" = "$p" ] && { inzone=0; break; } ;;
    esac
  done
  if [ "$inzone" -eq 1 ]; then printf 'ОТКАЗ: вне зоны: %s\n' "$f" >&2; rc=1; fi
done
if [ "$rc" -eq 0 ]; then printf 'ok: staged в зоне автора %s\n' "$author"; fi
exit "$rc"
STAB

# ── фаза 1: стаб честной формы — фикстуры предъявляют зелёное и красное ─────────
mk_root "$T/r1" "$T/stab-honest.sh"
out="$(run_scoped "$T/r1")"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'стаб честной формы: раннер дал rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "фикстуры check_staged не проходят против честной формы — красное пачки недостоверно"
fi
for c in case_vne_zon.sh case_imja_control_simvol.sh case_imja_control_simvol_bez_python3.sh \
         case_imja_fake_python3_exit_1.sh case_imja_fake_python3_exit_0.sh; do
  printf '%s\n' "$out" | grep -q "$c: зелёный контроль есть" \
    || fail "стаб честной формы: $c не предъявил зелёный контроль с красным повтором"
done
printf 'ok: стаб честной формы — все пять case: зелёный контроль + красное повтором\n'

# ── фаза 2: обманные стабы — каждый пойман поимённо ─────────────────────────────
mk_root "$T/r2" "$T/stab-zones-slep.sh"
out="$(run_scoped "$T/r2")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_vne_zon' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб зоны-слеп пойман на входе case_vne_zon\n'
else
  printf 'стаб зоны-слеп: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб зоны-слеп не пойман — красное ветви «вне зоны» не держится фикстурой"
fi
mk_root "$T/r3" "$T/stab-gramm-slep.sh"
out="$(run_scoped "$T/r3")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_imja_control_simvol' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб грамматика-слеп пойман на входе case_imja_control_simvol\n'
else
  printf 'стаб грамматика-слеп: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб грамматика-слеп не пойман — красное ветви грамматики имени не держится фикстурой"
fi
mk_root "$T/r4" "$T/stab-vsyo-krasno.sh"
out="$(run_scoped "$T/r4")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'положительного контроля'; then
  printf 'ok: стаб всё-красно пойман на зелёном контроле\n'
else
  printf 'стаб всё-красно: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб всё-красно не пойман — зелёная ветвь не предъявляется"
fi
mk_root "$T/r5" "$T/stab-kanarejka-slep.sh"
out="$(run_scoped "$T/r5")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q 'case_imja_fake_python3_exit_1' \
  && printf '%s\n' "$out" | grep -q 'красное не предъявлено'; then
  printf 'ok: стаб канарейка-слеп пойман на входе case_imja_fake_python3_exit_1\n'
else
  printf 'стаб канарейка-слеп: rc=%d:\n%s\n' "$rc" "$out" >&2
  fail "стаб канарейка-слеп не пойман — ветвь само-канарейки python3 не держится фикстурой"
fi

# ── фаза 3: живое дерево — красное пачки до реализации ──────────────────────────
B="$ROOT/scripts/check_staged.sh"
if [ ! -f "$B" ]; then
  printf 'ОТКАЗ: барьера нет — %s (реализация за implementer после заморозки)\n' "$B" >&2
  exit 1
fi
if bash "$B" "$ROOT" >/dev/null 2>&1; then
  printf 'ok: судья зелёный на живом дереве (staged пуст, всё в зоне либо автор не объявлен)\n'
  exit 0
fi
fail "судья красен на живом дереве — при чистом дереве это дефект реализации"
