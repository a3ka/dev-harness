#!/usr/bin/env bash
# Клетка 1 (И-1/И-2, «Выход» п.3 корневая половина) контракта 093.
# ПРЕДМЕТ: orch-peak под швами ORCH_* на toy-REPO, в toy-REPO отравленный
# scripts/lib_session.sh — ВАЛИДНЫЙ bash, пишущий свидетеля по фиксированному
# пути (невозможное событие для клетки). Когда: root-режим субъекта (через
# id-шов euid-мок 090-класса); тогда (на фикс): свидетель НЕ создан, bootstrap
# взят из установленного источника (шов OPS_SERVER_LIB_DST), ни один путь
# toy-REPO не изменён; на стабе s2 «bootstrap-из-репо» (battery_stubs.sh)
# клетка красна: отравленный bootstrap исполнен (И-1/И-2 пробито).
set -o pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/root/orch-peak"
LIB="$ROOT/scripts/lib_session.sh"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }
[ -f "$LIB" ] || { printf 'NOT_IMPLEMENTED: нет источника %s\n' "$LIB" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-1-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

# Свидетель отравы — фиксированный путь: bootstrap не знает $SCRATCH клетки,
# poison обязан быть самодостаточным валидным bash (замер: строка с ведущим
# «!#» bash трактует как command-not-found и touch недостижим).
SVID="/tmp/dev-harness-verify/ops-granica-1-svid"
rm -f "$SVID"

# toy-REPO с отравленным bootstrap: scripts/lib_session.sh — валидный bash,
# пишущий свидетеля, если его ИСТОЧАТ или исполняют.
TOY_REPO="$SCRATCH/toy-repo"
mkdir -p "$TOY_REPO/scripts"
printf '%s\n' '#!/usr/bin/env bash' "touch '$SVID'" > "$TOY_REPO/scripts/lib_session.sh"

# Установленный root-owned bootstrap: копия настоящего lib_session.sh в шве
# OPS_SERVER_LIB_DST.
SBIN_DST="$SCRATCH/sbin"
mkdir -p "$SBIN_DST"
cp "$LIB" "$SBIN_DST/lib_session.sh"
chmod 644 "$SBIN_DST/lib_session.sh"

# Снимок всех файлов toy-REPO ДО запуска субъекта.
find "$TOY_REPO" -type f | LC_ALL=C sort | xargs -I {} stat -c '%n %Y' {} > "$SCRATCH/repo_before"
[ -s "$SCRATCH/repo_before" ] || { printf 'ОТКАЗ: toy-REPO пуст\n' >&2; exit 2; }

# Запуск orch-peak под root-моком (id-шим) на toy-REPO.
ID_SHIM='#!/usr/bin/env bash
if [ "$1" = "-u" ]; then printf "0\n"; exit 0; fi
exec /usr/bin/id "$@"
'
printf '%s' "$ID_SHIM" > "$SCRATCH/bin_id"
chmod 755 "$SCRATCH/bin_id"
mkdir -p "$SCRATCH/bin"
cp "$SCRATCH/bin_id" "$SCRATCH/bin/id"

(
  export PATH="$SCRATCH/bin:$PATH"
  export OPS_SERVER_LIB_DST="$SBIN_DST/lib_session.sh"
  export ORCH_REPO="$TOY_REPO"
  export ORCH_USER="nobody"
  export ORCH_UHOME="/nonexistent-home-1"
  export ORCH_SESS_GLOB="/nonexistent-sess-1"
  export ORCH_PEAK_TEST="$SCRATCH/test"
  mkdir -p "$ORCH_PEAK_TEST"
  bash "$SUBJ" warn >/dev/null 2>"$SCRATCH/peak_err" || true
  bash "$SUBJ" stop >/dev/null 2>"$SCRATCH/peak_err" || true
  bash "$SUBJ" ctx >/dev/null 2>"$SCRATCH/peak_err" || true
)

# Свидетель 1: orch-peak НЕ исполнил отравленный ${REPO}/scripts/lib_session.sh.
if [ -e "$SVID" ]; then
  printf 'КРАСНО: bootstrap исполнен из репо: root запускает неустановленный код — свидетель %s создан (И-1/И-2 пробито)\n' "$SVID" >&2
  exit 1
fi

# Свидетель 2: ни один путь toy-REPO не изменён.
find "$TOY_REPO" -type f | LC_ALL=C sort | xargs -I {} stat -c '%n %Y' {} > "$SCRATCH/repo_after"
if ! /usr/bin/cmp -s "$SCRATCH/repo_before" "$SCRATCH/repo_after"; then
  printf 'КРАСНО: toy-REPO изменён субъектом (И-2)\n' >&2
  diff "$SCRATCH/repo_before" "$SCRATCH/repo_after" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-1): root bootstrap взят из установленного источника, ${REPO} не тронут (И-1/И-2)\n' >&2
exit 0
