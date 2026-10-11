#!/usr/bin/env bash
# Клетка 5 (И-6a, «Выход» п.4) контракта 093.
# ПРЕДМЕТ (починка Р1-2 круга 1: была заглушкой rc 2 при любом субъекте):
# install.sh verify-start обязан РАЗЛИЧАТЬ активный и упавший юнит живым
# вопросом systemctl is-active (швы OPS_SERVER_SYSTEMCTL / OPS_SERVER_UNIT).
# Два toy-мира, состояние юнита — файл состояния systemctl-шима (симулятор
# п.5 приёмки, самопроверка первой ступенью):
#   мир-ок:      verify-start → rc 0 «установлено и активно»;
#   мир-падение: verify-start → rc 1 именованный «юнит не стартует: <имя>».
# Стаб s4 «успех-без-старта» (state=active без вопроса systemctl) отвечает
# «активно» в мир-падении → КРАСНО; дореализационный субъект (нет
# подкоманды, usage user|root|verify) → КРАСНО «подкоманды нет».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/install.sh"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-5-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/bin"

CTL_STATE="$SCRATCH/unit_state"
CTL_LOG="$SCRATCH/systemctl.log"
UNIT="toy-peak@0"

# systemctl-шим (симулятор п.5): состояние юнита — файл, каждый вызов — в
# журнал; restart/start переводят состояние в active (юнит «поднялся»).
# Самопроверка первой ступенью: нет файла состояния / нет подкоманды —
# именованный отказ rc 2 (мир не построен), успехом не отвечает.
printf '%s\n' '#!/usr/bin/env bash' \
  'set -u' \
  "ST='$CTL_STATE'" \
  "J='$CTL_LOG'" \
  '[ -f "$ST" ] || { printf "systemctl-шим: нет файла состояния\n" >&2; exit 2; }' \
  '[ "$#" -ge 1 ] || { printf "systemctl-шим: нет подкоманды\n" >&2; exit 2; }' \
  'printf '"'"'%s\n'"'"' "$*" >> "$J"' \
  'case "$1" in' \
  '  is-active)' \
  '    s="$(cat "$ST")"; printf '"'"'%s\n'"'"' "$s"' \
  '    if [ "$s" = active ]; then exit 0; fi' \
  '    exit 3 ;;' \
  '  daemon-reload) exit 0 ;;' \
  '  restart|start) printf '"'"'active\n'"'"' > "$ST"; exit 0 ;;' \
  '  stop) printf '"'"'inactive\n'"'"' > "$ST"; exit 0 ;;' \
  '  *) printf "systemctl-шим: не модель: %s\n" "$1" >&2; exit 2 ;;' \
  'esac' > "$SCRATCH/bin/systemctl"
chmod 755 "$SCRATCH/bin/systemctl"

run_vs() { # $1=состояние юнита → rc субъекта в $vs_rc, вывод в $SCRATCH/out
  printf '%s\n' "$1" > "$CTL_STATE"
  : > "$CTL_LOG"
  OPS_SERVER_SYSTEMCTL="$SCRATCH/bin/systemctl" OPS_SERVER_UNIT="$UNIT" \
    bash "$SUBJ" verify-start >"$SCRATCH/out" 2>&1
  vs_rc=$?
}

# ── мир-ок: юнит активен ─────────────────────────────────────────────────────
run_vs active
if [ "$vs_rc" -eq 2 ] && grep -q 'использование' "$SCRATCH/out"; then
  printf 'КРАСНО: подкоманды проверки старта нет (usage user|root|verify) — И-6a не реализован\n' >&2
  exit 1
fi
if [ "$vs_rc" -eq 2 ]; then
  printf 'NOT_IMPLEMENTED: мир-ок сломан: %s\n' "$(cat "$SCRATCH/out")" >&2
  exit 2
fi
if [ "$vs_rc" -ne 0 ]; then
  printf 'КРАСНО: мир-ок: verify-start отказал на активном юните (rc=%s): %s\n' \
    "$vs_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -Fxq "is-active $UNIT" "$CTL_LOG"; then
  printf 'КРАСНО: verify-start не спросил состояние юнита у systemctl в мир-ок (успех без старта, И-6a пробит: стаб s4)\n' >&2
  exit 1
fi

# ── мир-падение: юнит упал ───────────────────────────────────────────────────
run_vs failed
if [ "$vs_rc" -eq 2 ] && grep -q 'использование' "$SCRATCH/out"; then
  printf 'КРАСНО: подкоманды проверки старта нет (usage user|root|verify) — И-6a не реализован\n' >&2
  exit 1
fi
if [ "$vs_rc" -eq 2 ]; then
  printf 'NOT_IMPLEMENTED: мир-падение сломан: %s\n' "$(cat "$SCRATCH/out")" >&2
  exit 2
fi
if [ "$vs_rc" -eq 0 ]; then
  printf 'КРАСНО: verify-start всегда отвечает «активно» независимо от реального состояния юнита (И-6a пробит: стаб s4)\n' >&2
  exit 1
fi
if [ "$vs_rc" -ne 1 ]; then
  printf 'КРАСНО: мир-падение: ожидался именованный отказ rc 1, получен rc=%s: %s\n' \
    "$vs_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -F "юнит не стартует" "$SCRATCH/out" | grep -Fq "$UNIT"; then
  printf 'КРАСНО: мир-падение: отказ без имени юнита «%s» (И-6a): %s\n' \
    "$UNIT" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -Fxq "is-active $UNIT" "$CTL_LOG"; then
  printf 'КРАСНО: verify-start не спросил состояние юнита у systemctl в мир-падение (успех без старта, И-6a пробит: стаб s4)\n' >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-5): verify-start различает миры: активен rc 0 / падение rc 1 именованный (И-6a)\n' >&2
exit 0
