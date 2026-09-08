#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, свойство ветви A (критик 2f11b53,
# блокер 4): свободное ДОБАВЛЕНИЕ уставного файла не блокируется — гейт судит
# M/D (--diff-filter=MD), добавление свободно (грамматика кольца, check_charter
# шапка: «ДОБАВЛЕНИЕ нового плана или контракта свободно, потому что черновики
# пишет архитектор»). Гейт, запрещающий добавление, — ослабление: он блокирует
# саму работу по уставу.
#
# ВХОД-1 (зелёная сторона договора): коммит, ДОБАВЛЯЮЩИЙ contracts/001-vtoroj.md —
# файл уставного КЛАССА (NNN=001 уже заморожен, is_charter_path истинен), диффа
# M/D нет; живой пуш main. Честная реализация ПРОПУСКАЕТ пуш.
# ВХОД-2 (красная сторона, несёт красное файла ДО реализации): поверх добавления
# коммит с дельтой M добавленного файла БЕЗ строки РАЗРЕШИЛ; честная реализация
# ОТВЕРГАЕТ.
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры): «запрещает добавление» — слабая
# форма, судящая и A-диффы (--diff-filter=AMD). Дефект наблюдаем ИМЕННО на
# входе-1: стаб отвергает пуш, который договор обязан пропустить. На входе-2 стаб
# ведёт себя честно — его краснота там не наблюдаема и не требуется.
#
# СЕГОДНЯ (хука нет) файл красен именованным отсутствием механизма на входе-2:
# красная дельта уехала бы свободно. ПОСЛЕ реализации все фазы зелёные; конверсия
# в case_* — пачка architect (А-82). Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО
# (А-82). Прогон — свежий WORK вне дерева (А-78, Н-74).
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-dob.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

HOOK_SRC="$REPO/.githooks/pre-push"
ORIG="$WORK/origin.git"
T="$WORK/toy"

eg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
jg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false "$@"
}
oref() { git -C "$ORIG" rev-parse --verify -q refs/heads/main || echo ПУСТО; }

# ── toy: основание с замороженным контрактом + bare-origin на основании ───────
mkdir -p "$T/contracts"
git init -q --bare "$ORIG"
git -C "$ORIG" symbolic-ref HEAD refs/heads/main
eg init -q -b main "$T"
eg -C "$T" config user.name Фикстура
eg -C "$T" config user.email fixture@local
printf '# подставной контракт 001 (уставной с заморозки)\n' > "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'основание: подставной замороженный контракт'
eg -C "$T" tag -a frozen/contracts/001/1 -m 'заморозка'
BASE="$(eg -C "$T" rev-parse main)"
eg -C "$T" remote add origin "$ORIG"
eg -C "$T" push -q origin main
[ "$(oref)" = "$BASE" ] || { printf 'ОТКАЗ: подготовка toy сломана — основание не на origin\n' >&2; exit 1; }

# Вход-1: ДОБАВЛЕНИЕ уставного файла (класс 001 уже заморожен — путь уставной
# в момент добавления; дифф A, не M/D).
printf '# второй контракт класса 001 (добавление свободно)\n' > "$T/contracts/001-vtoroj.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'добавление: новый уставной файл'
ADD="$(eg -C "$T" rev-parse main)"

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── фаза 1 (стаб-подстановка «запрещает добавление»): вход-1 обязан стаб ловить
STAB="$WORK/stab_zapreshhaet_dobavlenie.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «запрещает добавление» (контракт 022): судит и A-диффы (--diff-filter=AMD)
# — добавление уставного файла без строки РАЗРЕШИЛ отвергается.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  [ "$rsha" != "0000000000000000000000000000000000000000" ] || rsha="$lsha"
  while IFS= read -r f; do
    nnn="$(printf '%s' "$f" | sed -n 's|^contracts/\([0-9][0-9][0-9]\)-.*$|\1|p')"
    [ -n "$nnn" ] || continue
    git -C "$ROOT" rev-parse --verify -q "refs/tags/frozen/contracts/$nnn/1" >/dev/null || continue
    for c in $(git -C "$ROOT" rev-list "$rsha..$lsha" 2>/dev/null); do
      if git -C "$ROOT" diff-tree -r --no-commit-id --name-only --diff-filter=AMD "$c^" "$c" 2>/dev/null \
         | grep -qxF -- "$f"; then
        if ! git -C "$ROOT" log -1 --format=%B "$c" | grep -qF "РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $f"; then
          printf 'ОТКАЗ: уставный файл добавлен без разрешения: %s в %s\n' "$f" "$c" >&2
          rc=1
        fi
      fi
    done
  done < <(git -C "$ROOT" ls-tree -r --name-only HEAD -- contracts/ 2>/dev/null | grep '\.md$')
done
exit "$rc"
STAB
install_hook_from "$STAB"
set +e
p1="$(jg -C "$T" push origin main 2>&1)"; p1_rc=$?
set -e
if [ "$p1_rc" -ne 0 ] && [ "$(oref)" = "$BASE" ]; then
  :  # стаб наблюдаем: добавление отвергнуто — вход-1 доказателен
else
  printf 'ОТКАЗ: вход-1 не ловит стаб «запрещает добавление» — пуш добавления не отвергнут либо ref двинулся (rc=%s, origin=%s): %s\n' "$p1_rc" "$(oref)" "$p1" >&2
  exit 1
fi

# ── фаза 2 (честный механизм, зелёная сторона): добавление ПРОХОДИТ ───────────
if [ ! -f "$HOOK_SRC" ]; then
  eg -C "$T" config core.hooksPath /dev/null  # стаб снят: предмета нет, судить нечем
  :  # нечем судить — пуш пройдёт без судьи; красное предъявляет фаза 3
else
  mkdir -p "$T/scripts"
  cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
  cp "$REPO/scripts/next_id.sh" "$T/scripts/"
  cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
  install_hook_from "$HOOK_SRC"
fi
set +e
p2="$(jg -C "$T" push origin main 2>&1)"; p2_rc=$?
set -e
if [ "$p2_rc" -ne 0 ] || [ "$(oref)" != "$ADD" ]; then
  printf 'ОТКАЗ: гейт блокирует свободное ДОБАВЛЕНИЕ уставного файла (rc=%s, origin=%s ожидался %s) — суд не по M/D, ослабление договора: %s\n' "$p2_rc" "$(oref)" "$ADD" "$p2" >&2
  exit 1
fi

# ── фаза 3 (честный механизм, красная сторона): M без строки умирает ──────────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — красная дельта M добавленного уставного файла уехала бы на origin (боль Н-79: POST-push ловит только CI)\n' >&2
  exit 1
fi
printf '\nправка добавленного без строки\n' >> "$T/contracts/001-vtoroj.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'красный: M добавленного уставного без РАЗРЕШИЛ'
REDD="$(eg -C "$T" rev-parse main)"
set +e
p3="$(jg -C "$T" push origin main 2>&1)"; p3_rc=$?
set -e
if [ "$p3_rc" -eq 0 ]; then
  printf 'ОТКАЗ: красная дельта M добавленного файла прошла (rc=0) — судьи диапазона нет: %s\n' "$p3" >&2
  exit 1
fi
if [ "$(oref)" != "$ADD" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но origin-ref двинулся — отвержение не атомарно\n' >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'contracts/001-vtoroj.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p3" >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF "$REDD"; then
  printf 'ОТКАЗ: причина не называет КОММИТ (полный sha %s отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$REDD" "$p3" >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'refs/heads/main'; then
  printf 'ОТКАЗ: причина не называет REF (полный refs/heads/main отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$p3" >&2
  exit 1
fi

exit 0
