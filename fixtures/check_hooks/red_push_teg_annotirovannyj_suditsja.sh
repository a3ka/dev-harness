#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, свойство ветви A (критик 2f11b53,
# блокер 4; РЕШЕНИЕ арбитра b43d7a0 — правка-круг 2): аннотированный push-ТЕГ
# обязан разыменовываться до коммита и судиться — красный умирает до origin,
# легитимный ПРОХОДИТ. Один красный tag-вход без зелёного tag-контроля договор
# не держит: слабая форма «отвергать все теги» проходила бы весь критерий
# (замер арбитража) — потому здесь ДВЕ стороны входа.
#
# ВХОД-1 (красная сторона): не-merge коммит с дельтой (M) замороженного
# contracts/001-x.md без строки РАЗРЕШИЛ, сидящий ТОЛЬКО на локальной ветке
# (ни один remote его не знает); аннотированный тег v-red указывает на него;
# живой пуш тега в toy bare-origin (remote_sha нулевой → судимое множество =
# разыменованный коммит --not --remotes). Честная: пуш отвергнут, тег не въехал
# на origin, ПОЛНЫЙ диагноз: ref (полный, refs/tags/v-red), полный sha
# разыменованного коммита, путь.
# ВХОД-2 (зелёная канарейка, арбитраж b43d7a0): коммит с уставной дельтой M и
# КОРРЕКТНОЙ строкой РАЗРЕШИЛ в том же коммите, сидящий только локально;
# аннотированный тег v-ok на нём; живой пуш тега (нулевой remote_sha). Честная:
# пуш ПРОХОДИТ — rc 0 ∧ тег въехал на origin. Канарейка именно РАЗРЕШИЛ-несущая,
# а не «тег на публичный коммит»: у публичного судимое множество пусто, и форму
# «отвергать тег при любой уставной дельте независимо от РАЗРЕШИЛ» он не
# различил бы; выбранный вход прогоняет зелёный путь самого суда.
#
# СТАБ-ВХОДЫ (Н-39 — привязка кодом фикстуры):
#  - «теги не судятся» (фаза 1): слабая форма, пропускающая строки stdin с
#    refs/tags/* без суда (ветки судит честно). Дефект наблюдаем ИМЕННО на
#    входе-1: тег на красный коммит уезжает на origin. На пуше ветки стаб
#    честен — его краснота там не наблюдаема и не требуется.
#  - «отвергать все теги» (фаза 2): слабая форма (а) замера арбитража — любая
#    строка stdin с refs/tags/* отвергается без суда РАЗРЕШИЛ, найденный путь
#    печатается; ветки судит честно. Дефект наблюдаем ИМЕННО на входе-2:
#    легитимный РАЗРЕШИЛ-несущий тег не проходит. На входе-1 стаб ведёт себя
#    честно (красный отвергнут) — его краснота там не наблюдаема и не требуется.
#  Обе фазы стаб-подстановы проверяют наблюдаемость и живут в файле навсегда.
#
# ДОГОВОР (контракт 022, ветвь A, п.2): local_sha аннотированного тега — объект
# тега; хук разыменовывает ^{commit} ДО суда диапазона. Хук ставится ВНЕ
# рабочего дерева toy ($WORK/hooks): add -A не затягивает его в историю toy и
# канареечный коммит несёт только уставную дельту (toy-дефект арбитража b43d7a0).
#
# СЕГОДНЯ (хука нет) файл красен именованным отсутствием механизма — умирает
# фаза 3 (красная сторона честного суда); фазы 1–2 (стаб-подстановы) ЗЕЛЁНЫЕ
# уже сейчас: оба входа доказательны. ПОСЛЕ реализации все фазы зелёные;
# конверсия в case_* — пачка architect (А-82). Имя ВНЕ case_*-глоба раннера —
# НАМЕРЕННО (А-82). Прогон — свежий WORK вне дерева (А-78, Н-74).
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
tref_ok() { git -C "$ORIG" rev-parse --verify -q refs/tags/v-ok || echo ПУСТО; }

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

# Вход-1, красный коммит — ТОЛЬКО локально (main отведён к основанию, коммит на
# feat-t): ни один remote его не знает, потому судимое множество тега = он сам.
eg -C "$T" checkout -q -b feat-t main
printf '\nуставная дельта под тегом без строки\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'красный под тегом: дельта без РАЗРЕШИЛ'
RED="$(eg -C "$T" rev-parse feat-t)"
eg -C "$T" checkout -q main
eg -C "$T" tag -a v-red -m 'тег на красный коммит' "$RED"

# Вход-2, зелёная канарейка (арбитраж b43d7a0): устав-дельта M с КОРРЕКТНОЙ
# строкой РАЗРЕШИЛ в том же коммите, ТОЛЬКО локально; тег v-ok на нём.
eg -C "$T" checkout -q -b feat-k main
printf '\nканареечная уставная дельта с разрешением\n' >> "$T/contracts/001-x.md"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'канарейка И-8 Вход-2: устав-дельта с РАЗРЕШИЛ' \
  -m 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/001-x.md канарейка зелёного пути суда тегов (арбитраж b43d7a0)'
GREEN="$(eg -C "$T" rev-parse feat-k)"
eg -C "$T" checkout -q main
eg -C "$T" tag -a v-ok -m 'тег на легитимный коммит' "$GREEN"
VOK="$(eg -C "$T" rev-parse v-ok)"

install_hook_from() {  # <файл-источник> — ВНЕ рабочего дерева toy (арбитраж
  # b43d7a0): add -A не затягивает хук в историю toy, канарейка чиста.
  mkdir -p "$WORK/hooks"
  cp "$1" "$WORK/hooks/pre-push"
  chmod +x "$WORK/hooks/pre-push"
  eg -C "$T" config core.hooksPath "$WORK/hooks"
}

# ── фаза 1 (стаб-подстановка «теги не судятся»): вход-1 обязан стаб ловить ────
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
  :  # стаб наблюдаем: тег на красный прошёл — вход-1 доказателен
else
  printf 'ОТКАЗ: вход-1 не ловит стаб «теги не судятся» — тег не проехал либо ref не двинулся (rc=%s, tag=%s): %s\n' "$p1_rc" "$(tref)" "$p1" >&2
  exit 1
fi
# откат посадки тега для следующих фаз (объекты остаются, ref убираем с origin)
[ "$(tref)" = "ПУСТО" ] || git -C "$ORIG" update-ref -d refs/tags/v-red

# ── фаза 2 (стаб-подстановка «отвергать все теги»): вход-2 обязан стаб ловить ─
STAB2="$WORK/stab_otvergat_vse_tegi.sh"
cat > "$STAB2" <<'STAB2'
#!/usr/bin/env bash
# стаб «отвергать все теги» (контракт 022, И-8 Вход-2; слабая форма (а) замера
# арбитража b43d7a0): любая строка stdin с refs/tags/* отвергается БЕЗ суда
# РАЗРЕШИЛ (найденный путь печатается); ветки судятся честно (мини-судья
# диапазона, как у соседних стабов семьи). Единственный дефект: легитимный
# РАЗРЕШИЛ-несущий тег не проходит.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  case "$lref" in refs/tags/*)
    d="$(git -C "$ROOT" rev-parse --verify -q "$lsha^{commit}" 2>/dev/null || printf '%s' "$lsha")"
    f="$(git -C "$ROOT" diff-tree -r --no-commit-id --name-only --diff-filter=MD "$d^" "$d" 2>/dev/null | grep -E '^contracts/[0-9][0-9][0-9]-' | sed -n 1p)"
    printf 'ОТКАЗ: пуш тега отвергнут без суда: %s %s %s\n' "$lref" "$d" "${f:--}" >&2
    rc=1
    continue ;;
  esac
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
STAB2
install_hook_from "$STAB2"
set +e
p2="$(jg -C "$T" push origin v-ok 2>&1)"; p2_rc=$?
set -e
if [ "$p2_rc" -ne 0 ] && [ "$(tref_ok)" = "ПУСТО" ]; then
  :  # стаб наблюдаем: легитимный тег отвергнут без суда — вход-2 доказателен
else
  printf 'ОТКАЗ: вход-2 не ловит стаб «отвергать все теги» — канарейка прошла стаб либо тег въехал (rc=%s, v-ok=%s): %s\n' "$p2_rc" "$(tref_ok)" "$p2" >&2
  exit 1
fi

# ── фаза 3 (честный механизм): тег на красный умирает до origin ───────────────
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
p3="$(jg -C "$T" push origin v-red 2>&1)"; p3_rc=$?
set -e
if [ "$p3_rc" -eq 0 ]; then
  printf 'ОТКАЗ: пуш тега на красный коммит прошёл (rc=0) — разыменования нет: %s\n' "$p3" >&2
  exit 1
fi
if [ "$(tref)" != "ПУСТО" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но тег въехал на origin — отвержение не атомарно\n' >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p3" >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF "$RED"; then
  printf 'ОТКАЗ: причина не называет КОММИТ (полный sha разыменованного %s отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$RED" "$p3" >&2
  exit 1
fi
if ! printf '%s\n' "$p3" | grep -qF 'refs/tags/v-red'; then
  printf 'ОТКАЗ: причина не называет REF (полный refs/tags/v-red отсутствует) — диагноз неполон (тройка равномерно, арбитраж b43d7a0): %s\n' "$p3" >&2
  exit 1
fi

# ── фаза 4 (честный механизм, зелёная канарейка): легитимный тег ПРОХОДИТ ────
# Арбитраж b43d7a0: стаб «отвергать все теги» умирает именно здесь — зелёный
# путь суда тегов наблюдаем кодом фикстуры, отсылка к будущим зелёным контролям
# конверсии договора не держит.
set +e
p4="$(jg -C "$T" push origin v-ok 2>&1)"; p4_rc=$?
set -e
if [ "$p4_rc" -ne 0 ] || [ "$(tref_ok)" != "$VOK" ]; then
  printf 'ОТКАЗ: честный суд отверг легитимный РАЗРЕШИЛ-несущий тег (rc=%s, v-ok=%s, ожидался %s) — зелёный путь суда тегов не работает, слабая форма «отвергать все теги» жива: %s\n' "$p4_rc" "$(tref_ok)" "$VOK" "$p4" >&2
  exit 1
fi

exit 0
