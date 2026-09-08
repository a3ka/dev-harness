#!/usr/bin/env bash
# ПРЕД-ЗАМОРОЗОЧНОЕ КРАСНОЕ контракта 022, инвариант И-6 (ветвь C) — у land_agent
# НЕТ автопуша: rc 0 означает «посажено ЛОКАЛЬНО», origin/main НЕ трогается.
# Живая ДВУСТОРОННЯЯ проба: (а) посадка состоялась — rc 0, LANDED, main сдвинут
# merge-коммитом оркестратора, ветка снесена (assert_landed из каркаса семьи);
# (б) публичной стороны нет — origin/main НЕ двинулся (снято ДО вызова, в памяти
# проверяющего — правило 8).
#
# ВХОД: честный land ветки wip/001/implementer в toy-репо с bare-origin; вызов
# БЕЗ флагов (контракт 022: опциональных флагов --push/--no-push НЕ заводить —
# чистый cutover по слову владельца).
#
# СТАБ-ВХОДЫ (Н-39 — привязка кодом фикстуры; «стаб» здесь — сам текущий код,
# боль живая, не подставная): «всё ещё пушит» (старый блок land_agent.sh:236-239
# жив) и «флаг наоборот» (--no-push как opt-out, пуш по умолчанию) наблюдаемы
# ИМЕННО на этом входе — оба дают origin/main двинувшимся при вызове без флагов.
# На входе «land с --no-push» стаб «флаг наоборот» ведёт себя честно — его краснота
# там не наблюдаема и не требуется.
#
# СЕГОДНЯ (авто-пуш жив, land_agent.sh:236-239 + || true) файл красен именованным
# движением origin/main — это и есть предъявление боли Н-78: побочный эффект (пуш)
# вне нормы роли, оркестратор о нём не знал, amend переписал публичный коммит.
# ПОСЛЕ реализации (C) обе стороны зелёные. Конверсия в case_* — пачка architect
# (А-82). Имя ВНЕ case_*-глоба раннера — НАМЕРЕННО (А-82): раннер судит стандарт-А
# и краснил бы CI каждый пуш; до заморозки — прямой запуск.
#
# Коды возврата: 0 — ворота пройдены; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
BARRIER="$REPO/scripts/land_agent.sh"
WORK="$(mktemp -d /tmp/red022-land.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT

R="$WORK/repo"
ORIG="$WORK/origin.git"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

make_repo "$R"
git init -q --bare "$ORIG"
git -C "$ORIG" symbolic-ref HEAD refs/heads/main
git -C "$R" remote add origin "$ORIG"

# Сторона (б) oracle: снято ДО вызова субъекта.
origin_before="$(git -C "$ORIG" rev-parse --verify -q refs/heads/main || echo ПУСТО)"

mk_wip "$R" wip/001/implementer "$WORK/wt-green"
commit_in "$WORK/wt-green" implementer implementer@dev-harness.local 'предмет в зоне'
mb="$(git -C "$R" rev-parse main)"
tip="$(git -C "$R" rev-parse refs/heads/wip/001/implementer)"

set +e
out_land="$("$BARRIER" --branch wip/001/implementer --worktree "$WORK/wt-green" --root "$R" 2>&1)"
land_rc=$?
set -e

# Сторона (а): посадка состоялась (rc 0 + LANDED + переход main + снос ветки).
if [ "$land_rc" -ne 0 ]; then
  printf 'ОТКАЗ: land отказался на честном входе (rc=%s): %s\n' "$land_rc" "$out_land" >&2
  exit 1
fi
if ! printf '%s\n' "$out_land" | grep -q '^LANDED main='; then
  printf 'ОТКАЗ: rc 0 без строки LANDED — контракт выхода нарушен: %s\n' "$out_land" >&2
  exit 1
fi
assert_landed "$R" "$mb" "$tip" wip/001/implementer

# Сторона (б): публичной стороны НЕТ — origin/main не двинулся.
origin_after="$(git -C "$ORIG" rev-parse --verify -q refs/heads/main || echo ПУСТО)"
if [ "$origin_after" != "$origin_before" ]; then
  now="$(git -C "$R" rev-parse main)"
  printf 'ОТКАЗ: авто-пуш жив — origin/main двинулся (%s → %s, посажен %s) при rc 0 и LANDED (боль Н-78: пуш-побочный-эффект вне нормы роли; rc 0 обязан означать «локально», пуш — шаг оркестратора)\n' "$origin_before" "$origin_after" "$now" >&2
  exit 1
fi

exit 0
