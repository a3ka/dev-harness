#!/usr/bin/env bash
# Генератор ЭТАЛОНА семьи 016 для клетки m11 батареи 200 (закрытие блока К-08
# вердикта Crit200V1b: «нерегрессия семьи 016» обязана сравнивать субъекта с
# НЕЗАВИСИМЫМ от него эталоном — сравнение субъекта с собственной копией
# идемпотентно на реализованном дереве и мутацию существующей проверки двери
# не ловит). Эталон = rc/stdout/stderr каждого кейса
# fixtures/check_contract_frozen/case_*.sh при прогоне ЧЕРЕЗ ДВЕРЬ, ИЗВЛЕЧЁННУЮ
# ИЗ ЗАКОММИЧЕННОГО БЛОБА указанного git-ref (ДО-версия двери). Прогоны кейсов
# побайтово воспроизводимы (замер: два последовательных прогона дают равные
# rc/stdout/stderr, 10/10; в выводах нет путей, дат и коммит-sha) — потому
# эталон фиксируется файлами и в m11 сравнивается побайтово.
#
# Вызов: bash golden_016_gen.sh <git-ref> [корень-репозитория]
#   <git-ref> — коммит, ИЗ которого извлекается дверь (ОБЯЗАТЕЛЕН: происхождение
#               эталона — часть доказательства; «текущее дерево» запрещено);
#   [корень]  — репозиторий с семьёй кейсов (по умолчанию дерево этой батареи).
# Пишет golden_016/<кейс>/{rc,out,err} и golden_016/istochnik.txt (ref, коммит,
# блоб двери — свидетельство происхождения). Существующий эталон заменяется ЦЕЛИКОМ.
#
# Коды: 0 — эталон записан (число кейсов напечатано); 1 — кейсы не найдены либо
# эталон записан не полностью; 2 — нечем проверять. Скрипт не печатает PASS.
set -uo pipefail

usage() { printf 'использование: %s <git-ref> [корень-репозитория]\n' "$0" >&2; exit 2; }

[ "${1:-}" != "" ] || usage
REF="$1"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
ROOT="${2:-}"
if [ -z "$ROOT" ]; then ROOT="$(cd "$HERE/../../.." && pwd -P)" || exit 2; fi
ROOT="$(cd "$ROOT" && pwd -P)" || { printf 'НЕЧИМ: корень не читается\n' >&2; exit 2; }

command -v git     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v bash    >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v mktemp  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет mktemp\n' >&2; exit 2; }
command -v tar     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет tar\n' >&2; exit 2; }

SEM="$ROOT/fixtures/check_contract_frozen"
[ -d "$SEM" ] || { printf 'NOT_IMPLEMENTED: нет семьи кейсов: %s\n' "$SEM" >&2; exit 2; }

# Гигиена Н-85: унаследованные git-переменные подменяют предмет до первой команды.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

COMMIT="$(git -C "$ROOT" rev-parse --verify --quiet "$REF^{commit}" || true)"
[ -n "$COMMIT" ] || { printf 'NOT_IMPLEMENTED: ref не резолвится в коммит: %s\n' "$REF" >&2; exit 2; }
BLOB="$(git -C "$ROOT" rev-parse --verify --quiet "$COMMIT:scripts/check_contract_frozen.sh" || true)"
[ -n "$BLOB" ] || { printf 'NOT_IMPLEMENTED: в %s нет блоба двери scripts/check_contract_frozen.sh\n' "$COMMIT" >&2; exit 2; }

# Дверь и её библиотеки — ЦЕЛИКОМ из коммита-источника (дверь зовёт next_id.sh,
# lib_registry.sh и check_charter.sh из СВОЕГО каталога; рабочее дерево не читается).
SB="$(mktemp -d /tmp/dev-harness-g200.XXXXXX)" || exit 2
trap 'rm -rf "$SB"' EXIT
git -C "$ROOT" archive "$COMMIT" -- scripts | tar -x -C "$SB" || { printf 'НЕЧИМ: scripts/ не извлечён из %s\n' "$COMMIT" >&2; exit 2; }
[ -f "$SB/scripts/check_contract_frozen.sh" ] || { printf 'НЕЧИМ: извлечённая дверь отсутствует\n' >&2; exit 2; }

GOL="$HERE/golden_016"
rm -rf "$GOL"
mkdir -p "$GOL" || { printf 'НЕЧИМ: эталон не создаётся: %s\n' "$GOL" >&2; exit 2; }

n=0
for c in "$SEM"/case_*.sh; do
  n=$((n + 1))
  imja="$(basename "$c" .sh)"
  w="$(mktemp -d "$SB/w.XXXXXX")" || exit 2
  ( cd "$ROOT" && BARRIER="$SB/scripts/check_contract_frozen.sh" WORK="$w" bash "$c" ) >"$w/out" 2>"$w/err"
  rc=$?
  mkdir -p "$GOL/$imja"
  printf '%s\n' "$rc" > "$GOL/$imja/rc"
  cp "$w/out" "$GOL/$imja/out"
  cp "$w/err" "$GOL/$imja/err"
  rm -rf "$w"
done

[ "$n" -gt 0 ] || { printf 'КРАСНОЕ: кейсов семьи не найдено — эталон пуст и удалён\n' >&2; rm -rf "$GOL"; exit 1; }

{
  printf 'источник эталона семьи 016 для клетки m11 батареи 200\n'
  printf 'ref: %s\n' "$REF"
  printf 'коммит: %s\n' "$COMMIT"
  printf 'блоб двери scripts/check_contract_frozen.sh: %s\n' "$BLOB"
  printf 'команда: bash fixtures/workshop_project/okno_zamorozki_200/golden_016_gen.sh %s\n' "$REF"
  printf 'кейсов: %s\n' "$n"
} > "$GOL/istochnik.txt"

for imja in "$GOL"/*/; do
  imja="${imja%/}"
  [ -f "$imja/rc" ] && [ -f "$imja/out" ] && [ -f "$imja/err" ] \
    || { printf 'КРАСНОЕ: эталон %s записан не полностью\n' "${imja##*/}" >&2; exit 1; }
done

printf 'эталон golden_016: кейсов %s, источник %s\n' "$n" "$COMMIT"
exit 0
