#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, свойство ветви A, п.3 (критик
# 2f11b53, блокер 5): семантика нулевого remote_sha — `$local_sha --not --remotes`,
# НЕ полный обход всей достижимой истории. Красное, УЖЕ публичное на другом remote,
# не судится повторно: его повторная экспозиция новым ref не добавляет публичности,
# а полный обход заблокировал бы и лечение, и бэкап-пуши — класс Н-78 стал бы
# неисцелимым даже там, где лечить уже нечем (история публична).
#
# ВХОД-1 (зелёная сторона договора): ветка feat5, чей красный коммит R5 УЖЕ
# публичен на origin (backup-пуш мимо хука — измеренная форма класса); первый пуш
# feat5 в ПУСТОЙ второй remote (remote_sha нулевой → судимое множество =
# $local_sha --not --remotes = ПУСТО: R5 достижим из refs/remotes/origin/feat5).
# Честная реализация ПРОПУСКАЕТ пуш.
# ВХОД-2 (красная сторона, несёт красное файла ДО реализации): новый красный
# коммит N5 поверх feat5, НЕ публичный нигде; обновление существующего ref на
# origin. Честная реализация ОТВЕРГАЕТ.
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры): «полный обход нулевого ref» —
# слабая форма, судящая на нулевом remote_sha ВСЮ историю от $local_sha без
# --not --remotes. Дефект наблюдаем ИМЕННО на входе-1: стаб отвергает пуш уже
# публичной истории, который договор обязан пропустить. На входе-2 стаб ведёт
# себя честно — его краснота там не наблюдаема и не требуется.
#
# СЕГОДНЯ (хука нет) файл красен именованным отсутствием механизма на входе-2.
# ПОСЛЕ реализации все фазы зелёные; конверсия в case_* — пачка architect (А-82).
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82). Прогон — свежий WORK (А-78).
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-scp.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

HOOK_SRC="$REPO/.githooks/pre-push"
ORIG="$WORK/origin.git"
ORIG2="$WORK/origin2.git"
T="$WORK/toy"

eg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
jg() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c commit.gpgsign=false "$@"
}
oref() { git -C "$ORIG" rev-parse --verify -q refs/heads/feat5 || echo ПУСТО; }
o2ref() { git -C "$ORIG2" rev-parse --verify -q refs/heads/feat5 || echo ПУСТО; }

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

# Красный R5 публичен на origin (backup-пуш мимо суда — измеренная форма 27d387b):
# refs/remotes/origin/feat5 в toy существует после пуша — на нём держится --not --remotes.
eg -C "$T" checkout -q -b feat5 main
printf '\nуставная дельта бэкап-ветки без строки\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'красный бэкап: дельта без РАЗРЕШИЛ'
eg -C "$T" push -q origin feat5
R5="$(eg -C "$T" rev-parse feat5)"
[ "$(oref)" = "$R5" ] || { printf 'ОТКАЗ: подготовка toy сломана — красный бэкап не на origin\n' >&2; exit 1; }

# Второй remote пуст по feat5 — вход нулевого remote_sha.
git init -q --bare "$ORIG2"
git -C "$ORIG2" symbolic-ref HEAD refs/heads/main
eg -C "$T" remote add origin2 "$ORIG2"

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── фаза 1 (стаб-подстановка «полный обход нулевого ref»): вход-1 обязан ловить
STAB="$WORK/stab_polnyj_obhod_nulevogo.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «полный обход нулевого ref» (контракт 022): при нулевом remote_sha судит
# ВСЮ историю от $local_sha (rev-list без --not --remotes); непустой remote_sha
# судит честно диапазоном. Единственный дефект: уже публичное судится повторно.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  if [ "$rsha" = "0000000000000000000000000000000000000000" ]; then
    range="$lsha"
  else
    range="$rsha..$lsha"
  fi
  while IFS= read -r f; do
    nnn="$(printf '%s' "$f" | sed -n 's|^contracts/\([0-9][0-9][0-9]\)-.*$|\1|p')"
    [ -n "$nnn" ] || continue
    git -C "$ROOT" rev-parse --verify -q "refs/tags/frozen/contracts/$nnn/1" >/dev/null || continue
    for c in $(git -C "$ROOT" rev-list "$range" 2>/dev/null); do
      if git -C "$ROOT" diff-tree -r --no-commit-id --name-only --diff-filter=MD "$c^" "$c" 2>/dev/null \
         | grep -qxF -- "$f"; then
        if ! git -C "$ROOT" log -1 --format=%B "$c" | grep -qF "РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $f"; then
          printf 'ОТКАЗ: уставная дельта в обходе: %s в %s\n' "$f" "$c" >&2
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
p1="$(jg -C "$T" push origin2 feat5 2>&1)"; p1_rc=$?
set -e
if [ "$p1_rc" -ne 0 ] && [ "$(o2ref)" = "ПУСТО" ]; then
  :  # стаб наблюдаем: уже публичное отвергнуто — вход-1 доказателен
else
  printf 'ОТКАЗ: вход-1 не ловит стаб «полный обход нулевого ref» — пуш публичной истории не отвергнут либо ref двинулся (rc=%s, origin2=%s): %s\n' "$p1_rc" "$(o2ref)" "$p1" >&2
  exit 1
fi

# ── фаза 2 (честный механизм, зелёная сторона): уже публичное ПРОХОДИТ ─────────
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
p2="$(jg -C "$T" push origin2 feat5 2>&1)"; p2_rc=$?
set -e
if [ "$p2_rc" -ne 0 ] || [ "$(o2ref)" != "$R5" ]; then
  printf 'ОТКАЗ: гейт судит уже публичную историю (rc=%s, origin2=%s ожидался %s) — нулевой remote_sha судится полным обходом, а не --not --remotes: %s\n' "$p2_rc" "$(o2ref)" "$R5" "$p2" >&2
  exit 1
fi

# ── фаза 3 (честный механизм, красная сторона): новый красный умирает ─────────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — НОВЫЙ красный диапазон уехал бы на origin свободно (боль Н-79: scoped-семантику некому предъявить)\n' >&2
  exit 1
fi
printf '\nновая дельта поверх публичной без строки\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'новый красный: дельта без РАЗРЕШИЛ'
N5="$(eg -C "$T" rev-parse feat5)"
set +e
p3="$(jg -C "$T" push origin feat5 2>&1)"; p3_rc=$?
set -e
if [ "$p3_rc" -eq 0 ]; then
  printf 'ОТКАЗ: новый красный диапазон прошёл при живом хуке (rc=0) — «пропускает публичное» ослаблено до «пропускает всё»: %s\n' "$p3" >&2
  exit 1
fi
if [ "$(oref)" != "$R5" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но origin/feat5 двинулся — отвержение не атомарно\n' >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p3" >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF "$N5"; then
  printf 'ОТКАЗ: причина не называет КОММИТ (полный sha %s отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$N5" "$p3" >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'refs/heads/feat5'; then
  printf 'ОТКАЗ: причина не называет REF (полный refs/heads/feat5 отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$p3" >&2
  exit 1
fi

exit 0
