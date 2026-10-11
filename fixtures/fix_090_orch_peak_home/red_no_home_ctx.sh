#!/usr/bin/env bash
# Клетка Н-217 (лёгкая, краш-дым): orch-peak ctx в окружении БЕЗ HOME и БЕЗ
# ORCH_SESS_GLOB — среда systemd-юнита root (Н-217, NABLIUDENIA.md). Через
# тест-шов ORCH_PEAK_TEST (контракт 080, инв. 4) — без привилегий root.
#
# Дано:  субъект <SUBJ>/ops/server/root/orch-peak; пустые omp-pids в шве.
# Когда: env -u HOME -u ORCH_SESS_GLOB … orch-peak ctx.
# Тогда: ДО фикса — rc 1, stderr «HOME: unbound variable» (scripts/lib_session.sh:18,
#        источник рушит весь сторож). ПОСЛЕ фикса — rc 0 (тихий выход по пустым
#        omp-pids до любой тяжёлой работы), unbound в stderr нет.
# Субъект: ORCH090_SUBJECT (умолчание — корень репо этой фикстуры).
# Ловит ТОЛЬКО класс «краш» (в т.ч. текущий HEAD); обманные стабы вида
# HOME=/nonexistent эту клетку проходят — их ловит red_ctx_deep_no_home.sh.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"
SUBJ="${ORCH090_SUBJECT:-$(fix090_repo_root "$HERE")}"
[ -f "$SUBJ/ops/server/root/orch-peak" ] || fix090_fail "нет субъекта $SUBJ/ops/server/root/orch-peak"
[ -f "$SUBJ/scripts/lib_session.sh" ] || fix090_fail "нет $SUBJ/scripts/lib_session.sh — bootstrap не с чем проверить"

W="$(fix090_scratch)"
mkdir -p "$W/t/state"
: > "$W/t/omp-pids" || fix090_fail "не создан omp-pids"
ERR="$W/stderr.txt"

env -u HOME -u ORCH_SESS_GLOB \
  ORCH_PEAK_TEST="$W/t" ORCH_REPO="$SUBJ" \
  ORCH_STATE="$W/t/state" ORCH_LOG="$W/t/log" ORCH_MARK="$W/t/mark" \
  ORCH_REPORT="$W/t/report" ORCH_LOOP_STOP="$W/t/loopstop" \
  bash "$SUBJ/ops/server/root/orch-peak" ctx 2>"$ERR"
rc=$?

if [ "$rc" -ne 0 ]; then
  fix090_fail "лёгкая: env -u HOME ctx → rc=$rc, ожидался 0. stderr: $(tr '\n' ' ' < "$ERR")"
fi
if grep -q 'unbound variable' "$ERR"; then
  fix090_fail "лёгкая: stderr несёт unbound variable: $(tr '\n' ' ' < "$ERR")"
fi
printf 'ЗЕЛЁНО(090-лёгкая): orch-peak ctx под env -u HOME -u ORCH_SESS_GLOB → rc 0, unbound нет\n'
[ "${ORCH090_KEEP:-}" = 1 ] || rm -rf "$W"
exit 0
