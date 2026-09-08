#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, инвариант И-3 — дискриминатор лечения:
# гейт судит ТОЛЬКО диапазон remote..local и НЕ блокирует собственное лекарство класса.
#
# ВХОД (форма измеренного лечения 2026-09-06 / 27e57db): origin УЖЕ несёт красный
# коммит (damage: дельта M замороженного contracts/001-x.md без строки — так выглядит
# происшествие Н-79 ПОСЛЕ необратимого шага); локальная линия — лечение: reset к
# основанию + cherry-pick красной дельты с корректной строкой
# «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/001-x.md <причина>» в ПЕРВОЙ колонке тела.
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры): «полная история вместо диапазона» —
# слабая форма, судящая уставные дельты во всей истории с заморозки на ОБЕИХ сторонах
# (origin и локальная). Дефект наблюдаем ИМЕННО на этом входе: красное, уже сидящее на
# origin (которое пуш НЕ несёт), заставляет стаб отвергнуть лечение → класс
# неисцелим навсегда, второй инцидент стал бы необратимым. На входе «новый красный»
# стаб ведёт себя честно — его краснота там не наблюдаема и не требуется.
#
# ДОГОВОР (контракт 022, ветвь A, решение владельца): честный pre-push судит только
# $remote_sha..$local_sha: force-push лечения (диапазон = лечение со строкой)
# ПРОХОДИТ; НОВЫЙ красный диапазон при живом хуке по-прежнему ОТВЕРГАЕТСЯ — обе
# стороны держит ЭТОТ файл (двусторонняя проба дискриминатора).
#
# СЕГОДНЯ (хука нет) файл красен на фазе «новый красный отвергается» именованным
# отсутствием механизма (лечение при этом проходит свободно — нечем судить).
# Фаза стаб-подстановы ЗЕЛЁНАЯ уже сейчас: стаб самодостаточен и наблюдаем на
# повреждённом origin. ПОСЛЕ реализации все фазы зелёные; конверсия в case_* —
# пачка architect (А-82). Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82).
# Прогон — свежий WORK (А-78).
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-lech.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

HOOK_SRC="$REPO/.githooks/pre-push"
ORIG="$WORK/origin.git"
T="$WORK/toy"
ZERO=0000000000000000000000000000000000000000

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

# ── повреждение origin: красный коммит ушёл мимо всякого суда (симуляция ПОСЛЕ-факта Н-79)
printf '\nповреждающая уставная дельта без строки\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'damage: устав-дельта без РАЗРЕШИЛ (уехал мимо хука)'
DAMAGE="$(eg -C "$T" rev-parse main)"
eg -C "$T" push -q origin main
[ "$(oref)" = "$DAMAGE" ] || { printf 'ОТКАЗ: подготовка toy сломана — damage не на origin\n' >&2; exit 1; }

# ── лечение локально: reset к основанию + cherry-pick дельты СО строкой (форма 27e57db)
build_lechenie() {
  eg -C "$T" reset -q --hard "$BASE"
  eg -C "$T" cherry-pick --no-commit "$DAMAGE" >/dev/null 2>&1
  eg -C "$T" commit -q -m 'лечение: авторизованная устав-дельта' \
    -m 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/001-x.md лечение красного на origin (проба дискриминатора 022)'
}

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── фаза 1 (стаб-подстановка «полная история»): вход обязан стаб ловить ───────
STAB="$WORK/stab_polnaja_istorija.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «полная история вместо диапазона» (контракт 022, И-3): судит уставные дельты
# во всей истории с первой заморозки на ОБЕИХ сторонах — локальной (local_sha) и
# публичной (remote_sha). Единственный дефект стаба: красное, уже сидящее на origin,
# блокирует любой пуш — лечение невозможно. (Упрощения стаба: пути из ls-tree HEAD
# contracts/, грамматика строки — грубым grep; стабу достаточно своего дефекта.)
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  for tip in "$lsha" "$rsha"; do
    [ "$tip" != "0000000000000000000000000000000000000000" ] || continue
    while IFS= read -r f; do
      nnn="$(printf '%s' "$f" | sed -n 's|^contracts/\([0-9][0-9][0-9]\)-.*$|\1|p')"
      [ -n "$nnn" ] || continue
      git -C "$ROOT" rev-parse --verify -q "refs/tags/frozen/contracts/$nnn/1" >/dev/null || continue
      for c in $(git -C "$ROOT" rev-list "frozen/contracts/$nnn/1..$tip" 2>/dev/null); do
        if git -C "$ROOT" diff-tree -r --no-commit-id --name-only --diff-filter=MD "$c^" "$c" 2>/dev/null \
           | grep -qxF -- "$f"; then
          if ! git -C "$ROOT" log -1 --format=%B "$c" | grep -qF "РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $f"; then
            printf 'ОТКАЗ: уставная дельта в полной истории: %s в %s\n' "$f" "$c" >&2
            rc=1
          fi
        fi
      done
    done < <(git -C "$ROOT" ls-tree -r --name-only HEAD -- contracts/ 2>/dev/null | grep '\.md$')
  done
done
exit "$rc"
STAB
build_lechenie
install_hook_from "$STAB"
set +e
p1="$(jg -C "$T" push --force origin main 2>&1)"; p1_rc=$?
set -e
if [ "$p1_rc" -eq 0 ] || [ "$(oref)" != "$DAMAGE" ]; then
  printf 'ОТКАЗ: вход не ловит стаб «полная история» — лечение прошло мимо стаба (rc=%s, origin=%s): %s\n' "$p1_rc" "$(oref)" "$p1" >&2
  exit 1
fi

# ── фаза 2 (честный механизм, сторона лекарства): force-push лечения ПРОХОДИТ ──
if [ ! -f "$HOOK_SRC" ]; then
  eg -C "$T" config core.hooksPath /dev/null  # стаб фазы 1 снят: предмета нет, судить нечем
  :  # нечем судить — пуш пройдёт без судьи; красное предъявляет фаза 3
else
  mkdir -p "$T/scripts"
  cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
  cp "$REPO/scripts/next_id.sh" "$T/scripts/"
  cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
  install_hook_from "$HOOK_SRC"
fi
LECH="$(eg -C "$T" rev-parse main)"
set +e
p2="$(jg -C "$T" push --force origin main 2>&1)"; p2_rc=$?
set -e
if [ "$p2_rc" -ne 0 ] || [ "$(oref)" != "$LECH" ]; then
  printf 'ОТКАЗ: гейт блокирует лечение (rc=%s, origin=%s ожидался %s) — суд не диапазоном, класс неисцелим: %s\n' "$p2_rc" "$(oref)" "$LECH" "$p2" >&2
  exit 1
fi

# ── фаза 3 (честный механизм, сторона красного): новый красный диапазон умирает ─
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — при живом damage на origin НОВЫЙ красный диапазон прошёл бы свободно; дискриминатор нечем предъявить (боль Н-79: лечение и новый красный сегодня неотличимы — оба проходят)\n' >&2
  exit 1
fi
printf '\nновая уставная дельта без строки поверх лечения\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'новый красный: дельта без РАЗРЕШИЛ'
RED2="$(eg -C "$T" rev-parse main)"
set +e
p3="$(jg -C "$T" push origin main 2>&1)"; p3_rc=$?
set -e
if [ "$p3_rc" -eq 0 ]; then
  printf 'ОТКАЗ: новый красный диапазон прошёл при живом хуке (rc=0) — «проходит всё» слабее договора: %s\n' "$p3" >&2
  exit 1
fi
if [ "$(oref)" != "$LECH" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но origin/main двинулся — отвержение не атомарно\n' >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p3" >&2
  exit 1
fi

exit 0
