#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, инвариант И-5 (критик 2f11b53,
# блокер 7): хук судит пуш в ЛЮБОЙ remote — включая ОБНОВЛЕНИЕ СУЩЕСТВУЮЩЕГО ref
# на ВТОРОМ remote (ненулевой remote_sha → scoped-диапазон remote..local).
# Конверсионная case-семья названа: case_push_vtoroj_remote (пачка architect
# после реализации, протокол раннера).
#
# ВХОД: второй remote origin2 с УЖЕ ЖИВЫМ feat7 (нейтральный tip); локально поверх
# tip — красный коммит (дельта M замороженного contracts/001-x.md без строки
# РАЗРЕШИЛ); живой пуш origin2 feat7 — обновление существующего ref, диапазон
# remote..local несёт красный. Честная реализация ОТВЕРГАЕТ.
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры): «только origin» — слабая форма,
# судящая лишь пуши в remote по имени origin ($1 = origin) и пропускающая все
# прочие без суда. Дефект наблюдаем ИМЕННО на этом входе: красный диапазон
# уезжает на origin2. На пуше в origin стаб честен — его краснота там не
# наблюдаема и не требуется.
#
# СЕГОДНЯ (хука нет) файл красен именованным отсутствием механизма: обновление
# существующего ref на втором remote уезжает свободно. ПОСЛЕ реализации все фазы
# зелёные; конверсия — семьёй case_push_vtoroj_remote (А-82). Имя ВНЕ case_*-глоба
# раннера — НАМЕРЕННО (А-82). Прогон — свежий WORK вне дерева (А-78, Н-74).
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-r2.XXXXXX)"
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
o2ref() { git -C "$ORIG2" rev-parse --verify -q refs/heads/feat7 || echo ПУСТО; }

# ── toy: основание с замороженным контрактом + ДВА bare-remote ────────────────
mkdir -p "$T/contracts"
git init -q --bare "$ORIG"
git -C "$ORIG" symbolic-ref HEAD refs/heads/main
git init -q --bare "$ORIG2"
git -C "$ORIG2" symbolic-ref HEAD refs/heads/main
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

# Второй remote с ЖИВЫМ feat7 (нейтральный tip — обновляемый существующий ref).
eg -C "$T" remote add origin2 "$ORIG2"
eg -C "$T" checkout -q -b feat7 main
printf 'нейтральный tip второго remote\n' > "$T/feature7.txt"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'feature7: нейтральный tip'
eg -C "$T" push -q origin2 feat7
NEUT="$(eg -C "$T" rev-parse feat7)"
[ "$(o2ref)" = "$NEUT" ] || { printf 'ОТКАЗ: подготовка toy сломана — нейтральный tip не на origin2\n' >&2; exit 1; }

red_commit() {  # красная веточная дельта M без строки РАЗРЕШИЛ
  printf '\nуставная дельта на втором remote без строки\n' >> "$T/contracts/001-x.md"
  eg -C "$T" add -A
  eg -C "$T" commit -q -m 'красный на origin2: дельта без РАЗРЕШИЛ'
}

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── фаза 1 (стаб-подстановка «только origin»): вход обязан стаб ловить ────────
STAB="$WORK/stab_tolko_origin.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «только origin» (контракт 022, И-5): судит лишь пуши в remote с именем
# origin ($1); все прочие remote проходят без суда. Веткам origin — честный
# мини-судья диапазона (как у соседних стабов семьи).
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
if [ "${1:-}" = "origin" ]; then
  while read -r lref lsha rref rsha; do
    [ "$rsha" != "0000000000000000000000000000000000000000" ] || rsha="$lsha"
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
fi
exit "$rc"
STAB
install_hook_from "$STAB"
red_commit
set +e
p1="$(jg -C "$T" push origin2 feat7 2>&1)"; p1_rc=$?
set -e
if [ "$p1_rc" -eq 0 ] && [ "$(o2ref)" != "$NEUT" ]; then
  :  # стаб наблюдаем: красный диапазон уехал на второй remote — вход доказателен
else
  printf 'ОТКАЗ: вход не ловит стаб «только origin» — пуш на второй remote не прошёл либо ref не двинулся (rc=%s, origin2=%s): %s\n' "$p1_rc" "$(o2ref)" "$p1" >&2
  exit 1
fi

# ── фаза 2 (честный механизм): красное на втором remote умирает ───────────────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — обновление существующего ref на втором remote с красным диапазоном уехало бы свободно (договор «все remote» некому предъявить)\n' >&2
  exit 1
fi
mkdir -p "$T/scripts"
cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
cp "$REPO/scripts/next_id.sh" "$T/scripts/"
cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
git -C "$ORIG2" update-ref refs/heads/feat7 "$NEUT"   # откат посадки стаб-фазы
eg -C "$T" reset -q --hard "$NEUT"
red_commit
install_hook_from "$HOOK_SRC"
RED7="$(eg -C "$T" rev-parse feat7)"
set +e
p2="$(jg -C "$T" push origin2 feat7 2>&1)"; p2_rc=$?
set -e
if [ "$p2_rc" -eq 0 ]; then
  printf 'ОТКАЗ: красный диапазон прошёл на второй remote (rc=0) — суд только origin: %s\n' "$p2" >&2
  exit 1
fi
if [ "$(o2ref)" != "$NEUT" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но origin2/feat7 двинулся — отвержение не атомарно\n' >&2
  exit 1
fi
if ! printf '%s\n' "$p2" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p2" >&2
  exit 1
fi

exit 0
