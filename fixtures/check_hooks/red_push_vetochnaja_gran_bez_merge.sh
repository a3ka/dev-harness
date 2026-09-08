#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, инвариант И-2 — веточная грань устав-дельты
# без РАЗРЕШИЛ умирает до origin, на ОБЕИХ формах диапазона: обновление существующего
# remote-ref и первый пуш (нулевой remote_sha → --not --remotes).
#
# ВХОД-1 (форма измеренной грани 27d387b — веточная): не-merge коммит с дельтой (M)
# замороженного contracts/001-x.md без строки РАЗРЕШИЛ; в пушимом диапазоне НЕТ ни
# одного merge-коммита (бэкап-пуш wip-ветки — единственный путь, которым веточная
# грань доезжает до origin мимо land-церемонии; frontier 022 §3).
# ВХОД-2 (новый ref): первый пуш main в ПУСТОЙ remote — нулевой remote_sha, судимое
# множество = $local_sha --not --remotes (первая экспозиция линии, Н-78(3)).
#
# СТАБ-ВХОД (Н-39 — привязка кодом фикстуры): «только merge-грань» — слабая форма,
# судящая устав ТОЛЬКО в merge-коммитах диапазона. Дефект наблюдаем ИМЕННО на входе-1
# (в диапазоне нет merge → стаб не судит ничего → красная ветка уезжает на origin);
# на merge-входе стаб ведёт себя честно — требовать его красноты там — лжа в диагнозе.
# Фаза стаб-подстановы проверяет наблюдаемость и живёт в файле навсегда.
#
# ДОГОВОР (контракт 022, ветвь A): честный .githooks/pre-push судит КАЖДЫЙ коммит
# диапазона (не-merge по своей дельте, merge по дельте к ^1) кольцом check_charter.
#
# СЕГОДНЯ (хука нет) файл красен именованным отсутствием механизма — предъявляемое
# красное: обе формы диапазона сегодня уходят на origin свободно (боль Н-79).
# ПОСЛЕ реализации все фазы зелёные; конверсия в case_* — пачка architect (А-82).
# Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82). Прогон — свежий WORK (А-78).
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d /tmp/red022-vet.XXXXXX)"
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
fref() { git -C "$ORIG" rev-parse --verify -q refs/heads/feat2 || echo ПУСТО; }

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

# Веточная грань: feat2 с НЕЙТРАЛЬНЫМ tip (запушен мимо суда — ref обновляемый,
# без нулевого remote_sha), красный коммит добавляется поверх.
eg -C "$T" checkout -q -b feat2 main
printf 'нейтральный tip ветки\n' > "$T/feature2.txt"
eg -C "$T" add -A
eg -C "$T" commit -q -m 'feature2: нейтральный tip'
eg -C "$T" push -q origin feat2
NEUT="$(eg -C "$T" rev-parse feat2)"
[ "$(fref)" = "$NEUT" ] || { printf 'ОТКАЗ: подготовка toy сломана — нейтральный tip не на origin\n' >&2; exit 1; }

red_commit() {  # красная веточная дельта M без строки РАЗРЕШИЛ
  printf '\nветочная уставная дельта без строки\n' >> "$T/contracts/001-x.md"
  eg -C "$T" add -A
  eg -C "$T" commit -q -m 'веточная дельта без РАЗРЕШИЛ'
}

install_hook_from() {  # <файл-источник>
  mkdir -p "$T/.githooks"
  cp "$1" "$T/.githooks/pre-push"
  chmod +x "$T/.githooks/pre-push"
  eg -C "$T" config core.hooksPath "$T/.githooks"
}

# ── фаза 1 (стаб-подстановка «только merge-грань»): вход обязан стаб ловить ───
STAB="$WORK/stab_tolko_merge.sh"
cat > "$STAB" <<'STAB'
#!/usr/bin/env bash
# стаб «только merge-грань» (контракт 022, И-2): устав судится ТОЛЬКО в merge-коммитах
# пушимого диапазона (дельта к ^1, грубый разбор путей — стабу достаточно дефекта,
# единственного у него: не-merge коммиты диапазона не судятся вовсе).
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
rc=0
while read -r lref lsha rref rsha; do
  case "$rsha" in
    0000000000000000000000000000000000000000) range="$lsha" ;;
    *) range="$rsha..$lsha" ;;
  esac
  for m in $(git -C "$ROOT" rev-list --merges "$range" 2>/dev/null); do
    if git -C "$ROOT" diff-tree -r --no-commit-id --name-only --diff-filter=MD "$m^1" "$m" 2>/dev/null \
       | grep -qE '^(AGENTS\.md|ROADMAP\.md|plans/[0-9][0-9][0-9]-|contracts/[0-9][0-9][0-9]-)'; then
      printf 'ОТКАЗ: уставная дельта в merge %s\n' "$m" >&2
      rc=1
    fi
  done
done
exit "$rc"
STAB
install_hook_from "$STAB"
red_commit
set +e
p1="$(jg -C "$T" push origin feat2 2>&1)"; p1_rc=$?
set -e
if [ "$p1_rc" -eq 0 ] && [ "$(fref)" != "$NEUT" ]; then
RED1="$(eg -C "$T" rev-parse feat2)"
  :  # стаб наблюдаем: красная веточная дельта уехала на origin
else
  printf 'ОТКАЗ: вход не ловит стаб «только merge» — красная ветка не уехала (rc=%s): %s\n' "$p1_rc" "$p1" >&2
  exit 1
fi

# ── фаза 2 (честный механизм): веточная грань умирает на обновлении ref ───────
if [ ! -f "$HOOK_SRC" ]; then
  printf 'ОТКАЗ: механизм pre-push отсутствует (.githooks/pre-push нет в дереве) — веточная грань устав-дельты без РАЗРЕШИЛ уехала бы на origin бэкап-пушем ветки (боль Н-79: та же дельта на main ловилась только POST-push CI)\n' >&2
  exit 1
fi
mkdir -p "$T/scripts"
cp "$REPO/scripts/check_charter.sh" "$T/scripts/"
cp "$REPO/scripts/next_id.sh" "$T/scripts/"
cp "$REPO/scripts/lib_registry.sh" "$T/scripts/"
install_hook_from "$HOOK_SRC"
red_commit
set +e
p2="$(jg -C "$T" push origin feat2 2>&1)"; p2_rc=$?
set -e
RED2="$(eg -C "$T" rev-parse feat2)"
if [ "$p2_rc" -eq 0 ]; then
  printf 'ОТКАЗ: пуш веточной грани без РАЗРЕШИЛ прошёл (rc=0) — не-merge коммиты диапазона не судятся: %s\n' "$p2" >&2
  exit 1
fi
if [ "$(fref)" != "$RED1" ]; then
  printf 'ОТКАЗ: пуш отвергнут, но origin/feat2 двинулся — отвержение не атомарно\n' >&2
  exit 1
fi
if ! printf '%s\n' "$p2" | grep -qF 'contracts/001-x.md'; then
  printf 'ОТКАЗ: отказ без именованной причины (путь уставного файла не назван): %s\n' "$p2" >&2
  exit 1
fi

# ── фаза 3 (новый ref): первый пуш линии в пустой remote тоже судится ─────────
ORIG2="$WORK/origin2.git"
git init -q --bare "$ORIG2"
git -C "$ORIG2" symbolic-ref HEAD refs/heads/main
eg -C "$T" remote add origin2 "$ORIG2"
eg -C "$T" checkout -q main
eg -C "$T" merge --ff-only feat2 >/dev/null 2>&1
set +e
p3="$(jg -C "$T" push origin2 main 2>&1)"; p3_rc=$?
set -e
o2ref() { git -C "$ORIG2" rev-parse --verify -q refs/heads/main || echo ПУСТО; }
if [ "$p3_rc" -eq 0 ]; then
  printf 'ОТКАЗ: первый пуш красной линии в пустой remote прошёл (rc=0) — нулевой remote_sha не судится по --not --remotes: %s\n' "$p3" >&2
  exit 1
fi
[ "$(o2ref)" = "ПУСТО" ] || { printf 'ОТКАЗ: origin2/main не пуст после отвергнутого первого пуша\n' >&2; exit 1; }

exit 0
