#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, свойство ветви A (критик 2f11b53,
# блокер 4): аннотированный push-ТЕГ обязан разыменовываться до коммита —
# пуш тега на красный коммит умирает до origin, «тег без своей линии» невозможен
# (Н-78(3): origin больше не может стать тегом, чья линия не судилась).
#
# ВХОД: не-merge коммит с дельтой (M) замороженного contracts/001-x.md без строки
# РАЗРЕШИЛ, сидящий ТОЛЬКО на локальной ветке (ни один remote его не знает);
# аннотированный тег v-red указывает на него; живой пуш тега в toy bare-origin
# (remote_sha нулевой → судимое множество = разыменованный коммит --not --remotes).
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры): «теги не судятся» — слабая форма,
# пропускающая строки stdin с refs/tags/* без суда (ветки судит честно). Дефект
# наблюдаем ИМЕННО на этом входе: тег на красный коммит уезжает на origin.
# На пуше ветки стаб честен — его краснота там не наблюдаема и не требуется.
# Фаза стаб-подстановы проверяет наблюдаемость и живёт в файле навсегда.
#
# ДОГОВОР (контракт 022, ветвь A, п.2): local_sha аннотированного тега — объект
# тега; хук разыменовывает ^{commit} ДО суда диапазона.
#
# СЕГОДНЯ (хука нет) файл красен именованным отсутствием механизма: тег на красный
# коммит уезжает свободно. ПОСЛЕ реализации все фазы зелёные; конверсия в case_* —
# пачка architect (А-82). Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82).
# Прогон — свежий WORK вне дерева (А-78, Н-74).
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-teg.XXXXXX)"
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
tref() { git -C "$ORIG" rev-parse --verify -q refs/tags/v-red || echo ПУСТО; }

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

# Красный коммит — ТОЛЬКО локально (main отведён к основанию, коммит на feat-t):
# ни один remote его не знает, потому судимое множество тега = он сам.
eg -C "$T" checkout -q -b feat-t main
printf '\nуставная дельта под тегом без строки\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'красный под тегом: дельта без РАЗРЕШИЛ'
RED="$(eg -C "$T" rev-parse feat-t)"
eg -C "$T" checkout -q main
eg -C "$T" tag -a v-red -m 'тег на красный коммит' "$RED"

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── фаза 1 (стаб-подстановка «теги не судятся»): вход обязан стаб ловить ──────
STAB="$WORK/stab_tegi_ne_sudjatsja.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «теги не судятся» (контракт 022): строки с refs/tags/* проходят без суда;
# ветки судятся честно (мини-судья диапазона, как у соседних стабов семьи).
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  case "$lref" in refs/tags/*) continue ;; esac
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
exit "$rc"
STAB
install_hook_from "$STAB"
set +e
p1="$(jg -C "$T" push origin v-red 2>&1)"; p1_rc=$?
set -e
if [ "$p1_rc" -eq 0 ] && [ "$(tref)" != "ПУСТО" ]; then
  :  # стаб наблюдаем: тег на красный прошёл — вход доказателен
else
  printf 'ОТКАЗ: вход не ловит стаб «теги не судятся» — тег не проехал либо ref не двинулся (rc=%s, tag=%s): %s\n' "$p1_rc" "$(tref)" "$p1" >&2
  exit 1
fi
# откат посадки тега для честной фазы (объекты остаются, ref убираем с origin)
[ "$(tref)" = "ПУСТО" ] || git -C "$ORIG" update-ref -d refs/tags/v-red

# ── фаза 2 (честный механизм): тег на красный умирает до origin ───────────────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — аннотированный тег на красный коммит уехал бы на origin (Н-78(3): линия тега не судится вовсе; боль Н-79: ловится только POST-push CI)\n' >&2
  exit 1
fi
mkdir -p "$T/scripts"
cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
cp "$REPO/scripts/next_id.sh" "$T/scripts/"
cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
install_hook_from "$HOOK_SRC"
set +e
p2="$(jg -C "$T" push origin v-red 2>&1)"; p2_rc=$?
set -e
if [ "$p2_rc" -eq 0 ]; then
  printf 'ОТКАЗ: пуш тега на красный коммит прошёл (rc=0) — разыменования нет: %s\n' "$p2" >&2
  exit 1
fi
if [ "$(tref)" != "ПУСТО" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но тег въехал на origin — отвержение не атомарно\n' >&2
  exit 1
fi
if ! printf '%s\n' "$p2" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p2" >&2
  exit 1
fi

exit 0
