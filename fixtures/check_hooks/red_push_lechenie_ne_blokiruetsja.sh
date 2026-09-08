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
# СТАБ-ВХОД «fail-open на non-FF» (Н-39 — привязка кодом фикстуры; критик 2f11b53,
# блокер 6): слабая форма, пропускающая БЕЗ суда любой non-fast-forward пуш
# (remote_sha не предок local_sha) и судящая честно только FF/new-ref. Дефект
# наблюдаем ИМЕННО на входе «красный force-push ПОСЛЕ лечения»: стаб пропускает
# его — красное силой въезжает на origin. На FF-входах стаб честен — его краснота
# там не наблюдаема и не требуется. Фаза 1б подставляет этот стаб; фаза 4 —
# честный механизм на том же входе: красный force-push ОБЯЗАН быть отвергнут
# (лечение — единственное исключение, и то не «любой force», а «зелёный диапазон»).
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
oturn() { git -C "$ORIG" update-ref refs/heads/main "$1"; }

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

install_hook_from() {  # <файл-источник> — ВНЕ рабочего дерева toy (арбитраж
  # b43d7a0, побочный toy-дефект): add -A не затягивает хук в историю toy,
  # reset --hard его не сносит — red→green переход достижим при честном хуке.
  mkdir -p "$WORK/hooks"
  cp "$1" "$WORK/hooks/pre-push"
  chmod +x "$WORK/hooks/pre-push"
  eg -C "$T" config core.hooksPath "$WORK/hooks"
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
LECH0="$(eg -C "$T" rev-parse main)"

# ── фаза 1б (стаб-подстановка «fail-open на non-FF»): красный force-push вход обязан ловить
STAB2="$WORK/stab_failopen_nonff.sh"
cat > "$STAB2" <<'STAB2'
#!/usr/bin/env bash
# стаб «fail-open на non-FF» (контракт 022, И-3): non-fast-forward пуш проходит
# БЕЗ суда; fast-forward судится честно по диапазону (мини-судья как у стаба
# «полная история», но диапазоном remote..local). Единственный дефект: красный
# force-push проходит мимо гейта.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  [ "$rsha" != "0000000000000000000000000000000000000000" ] || continue
  git -C "$ROOT" merge-base --is-ancestor "$rsha" "$lsha" 2>/dev/null || continue
  while IFS= read -r f; do
    nnn="$(printf '%s' "$f" | sed -n 's|^contracts/\([0-9][0-9][0-9]\)-.*$|\1|p')"
    [ -n "$nnn" ] || continue
    git -C "$ROOT" rev-parse --verify -q "refs/tags/frozen/contracts/$nnn/1" >/dev/null || continue
    for c in $(git -C "$ROOT" rev-list "$rsha..$lsha" 2>/dev/null); do
      if git -C "$ROOT" diff-tree -r --no-commit-id --name-only --diff-filter=MD "$c^" "$c" 2>/dev/null \
         | grep -qxF -- "$f"; then
        if ! git -C "$ROOT" log -1 --format=%B "$c" | grep -qF "РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $f"; then
          printf 'ОТКАЗ: уставная дельта в диапазоне: %s в %s\n' "$f" "$c" >&2
          rc=1
        fi
      fi
    done
  done < <(git -C "$ROOT" ls-tree -r --name-only HEAD -- contracts/ 2>/dev/null | grep '\.md$')
done
exit "$rc"
STAB2
printf '\nкрасный поверх лечения (вход fail-open пробы)\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'красный force-поверх лечения: без строки'
REDA="$(eg -C "$T" rev-parse main)"
install_hook_from "$STAB2"
set +e
p1b="$(jg -C "$T" push --force origin main 2>&1)"; p1b_rc=$?
set -e
if [ "$p1b_rc" -eq 0 ] && [ "$(oref)" = "$REDA" ]; then
  :  # стаб наблюдаем: красный force-push прошёл мимо суда — вход доказателен
else
  printf 'ОТКАЗ: вход не ловит стаб «fail-open на non-FF» — красный force-push не прошёл либо ref не двинулся (rc=%s, origin=%s): %s\n' "$p1b_rc" "$(oref)" "$p1b" >&2
  exit 1
fi
# восстановление состояния фаз 2–3: лечение локально, damage на origin
eg -C "$T" reset -q --hard "$LECH0"
oturn "$DAMAGE"

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
if ! printf '%s\n' "$p3" | grep -qF "$RED2"; then
  printf 'ОТКАЗ: причина не называет КОММИТ (полный sha %s отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$RED2" "$p3" >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'refs/heads/main'; then
  printf 'ОТКАЗ: причина не называет REF (полный refs/heads/main отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$p3" >&2
  exit 1
fi

# ── фаза 4 (честный механизм): красный force-push ПОСЛЕ лечения отвергнут ──────
# Критик 2f11b53, блокер 6: fail-open допустим ТОЛЬКО диапазону лечения (зелёный
# force), не любому non-FF. Вход: дивергенция поверх полеченного origin + красная
# дельта; honest-диапазон LECH..RED3 несёт красный → пуш умирает, origin стоит.
eg -C "$T" reset -q --hard "$BASE"
printf '\nсиловой красный поверх лечения: дельта без строки\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'красный force-push: устав-дельта без РАЗРЕШИЛ'
RED3="$(eg -C "$T" rev-parse main)"
set +e
p4="$(jg -C "$T" push --force origin main 2>&1)"; p4_rc=$?
set -e
if [ "$p4_rc" -eq 0 ]; then
  printf 'ОТКАЗ: красный force-push прошёл при живом хуке (rc=0) — fail-open всем non-FF слабее договора: %s\n' "$p4" >&2
  exit 1
fi
if [ "$(oref)" != "$LECH" ]; then
  printf 'ОТКАЗ: силовой пуш отвергнут, но origin/main двинулся (%s вместо %s) — отвержение не атомарно\n' "$(oref)" "$LECH" >&2
  exit 1
fi
if ! printf '%s\n' "$p4" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p4" >&2
  exit 1
fi
if ! printf '%s\n' "$p4" | grep -qF "$RED3"; then
  printf 'ОТКАЗ: причина не называет КОММИТ (полный sha %s отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$RED3" "$p4" >&2
  exit 1
fi
if ! printf '%s\n' "$p4" | grep -qF 'refs/heads/main'; then
  printf 'ОТКАЗ: причина не называет REF (полный refs/heads/main отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$p4" >&2
  exit 1
fi

exit 0
