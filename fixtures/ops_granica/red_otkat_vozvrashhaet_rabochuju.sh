#!/usr/bin/env bash
# Клетка 6 (И-6b, «Выход» п.6) контракта 093.
# ПРЕДМЕТ (починка Р1-2 круга 1: была заглушкой rc 2 при любом субъекте):
# живая последовательность БЕЗ install между откатом и наблюдением
# (находка 2 круга 2 — переустановка ПОСЛЕ отката маскирует
# неработоспособность):
#   v1 установлена (пин sha256 orch-peak и юнит-файла снят В ПАМЯТЬ до
#   установки v2) → v2 установлена → откат → адресаты побайтово v1, откат
#   САМ исполнил systemctl daemon-reload и перезапустил юнит (симулятор
#   systemctl клетки 5), юнит активен ИМЕННО v1 (sha256 = пин v1).
# Повторная установка v2 как «проверка отката» не допускается — клетка
# после отката install НЕ вызывает (порядок команд клетки).
# Дореализационный субъект (нет подкоманды rollback, usage) → КРАСНО
# «подкоманды нет». Стаб s5 «откат-удаление» (восстановление вырезано) →
# КРАСНО «не восстановил побайтово». Текущее дерево (root не сохраняет
# прежнюю версию — Р1-1) → КРАСНО «откат отказал: нет каталога предыдущей
# версии» — честное красное до правки субъекта implementer.
# Toy-мир: euid-0 шим id (прецедент 090-класса), шимы chown/chattr/lsattr/
# useradd/visudo (provisioning без настоящей /etc), systemctl-шим клетки 5.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/install.sh"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }
[ -d "$ROOT/ops/server/root/systemd" ] || { printf 'NOT_IMPLEMENTED: нет юнитов субъекта\n' >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-6-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

CTL_STATE="$SCRATCH/unit_state"
CTL_LOG="$SCRATCH/systemctl.log"
UNIT="toy-peak@0"
PIN_UNIT_FILE="orch-peak@.service"   # пинуется один представитель юнитов

# ── toy-мир: шимы в PATH субъекта ────────────────────────────────────────────
mkdir -p "$SCRATCH/bin"

# id: root-гард субъекта обязан проходить (модель euid 0, прецедент 090).
printf '%s\n' '#!/usr/bin/env bash' \
  '[ "${1:-}" = "-u" ] && { printf "0\n"; exit 0; }' \
  'printf "uid=0(root) gid=0(root) groups=0(root)\n"; exit 0' > "$SCRATCH/bin/id"
chmod 755 "$SCRATCH/bin/id"

# systemctl — симулятор клетки 5 (общая ФОРМА): состояние из файла, журнал
# вызовов, restart/start → active. Самопроверка первой ступенью.
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
  'esac' > "$SCRATCH/bin/systemctl"
chmod 755 "$SCRATCH/bin/systemctl"

# chown/chattr/lsattr/useradd/visudo — модель root-станции (реальные под
# harness отказали бы EPERM; euid-0 шим id их не меняет).
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/chown"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/chattr"
printf '%s\n' '#!/usr/bin/env bash' \
  'for a in "$@"; do [ "$a" = "--" ] && continue; case "$a" in -*) continue;; esac' \
  '  printf -- "----i--------- %s\n" "$a"; break; done' \
  'exit 0' > "$SCRATCH/bin/lsattr"
printf '%s\n' '#!/usr/bin/env bash' \
  "printf 'useradd-шим: %s\n' \"\$*\" >> '$SCRATCH/shim.log'" \
  'exit 0' > "$SCRATCH/bin/useradd"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$SCRATCH/bin/visudo"
chmod 755 "$SCRATCH"/bin/{chown,chattr,lsattr,useradd,visudo}

# ── toy-источник ops/server (v1 = файлы субъекта + маркер версии) ───────────
mkdir -p "$SCRATCH/proj/ops/server/user" "$SCRATCH/proj/ops/server/root/systemd" \
  "$SCRATCH/proj/scripts" "$SCRATCH/main/.git" "$SCRATCH/main/.githooks" \
  "$SCRATCH/sudoers" "$SCRATCH/sbin" "$SCRATCH/etc" "$SCRATCH/bindst" \
  "$SCRATCH/agent_home"
cp -- "$ROOT/ops/server/user/orch-loop" "$SCRATCH/proj/ops/server/user/orch-loop"
cp -- "$ROOT/ops/server/root/orch-peak" "$SCRATCH/proj/ops/server/root/orch-peak"
cp -- "$ROOT"/ops/server/root/systemd/* "$SCRATCH/proj/ops/server/root/systemd/"
printf '# toy bootstrap library\n' > "$SCRATCH/proj/scripts/lib_session.sh"
printf '%s\n' '[core]' '	hooksPath = .githooks' '[branch]' '	autoSetupMerge = false' \
  > "$SCRATCH/main/.git/config"

MARKER1="# cell6-version-1-$RANDOM$RANDOM"
MARKER2="# cell6-version-2-$RANDOM$RANDOM"
printf '%s\n' "$MARKER1" >> "$SCRATCH/proj/ops/server/root/orch-peak"
printf '%s\n' "$MARKER1" >> "$SCRATCH/proj/ops/server/root/systemd/$PIN_UNIT_FILE"

run_install() {  # $1=подкоманда → rc в $op_rc, вывод в $SCRATCH/out
  env PATH="$SCRATCH/bin:$PATH" HOME="$SCRATCH" \
    OPS_SERVER_SRC="$SCRATCH/proj/ops/server" \
    OPS_SERVER_BIN_DST="$SCRATCH/bindst" \
    OPS_SERVER_SBIN_DST="$SCRATCH/sbin" \
    OPS_SERVER_ETC_DST="$SCRATCH/etc" \
    OPS_SERVER_MAIN="$SCRATCH/main" \
    OPS_SERVER_ROLLBACK_BACKUP="$SCRATCH/rollback" \
    OPS_SERVER_AGENT_USER="toyagent" \
    OPS_SERVER_AGENT_HOME="$SCRATCH/agent_home" \
    OPS_SERVER_SUDOERS_DROP="$SCRATCH/sudoers/launch" \
    OPS_SERVER_SYSTEMCTL="$SCRATCH/bin/systemctl" \
    OPS_SERVER_UNIT="$UNIT" \
    bash "$SUBJ" "$1" >"$SCRATCH/out" 2>&1
  op_rc=$?
}

sha_of() { sha256sum <"$1" | cut -d' ' -f1; }

printf 'inactive\n' > "$CTL_STATE"
: > "$CTL_LOG"
# ── 1. установка v1, пин в ПАМЯТЬ до всякого v2 (правило 8) ─────────────────
run_install root
if [ "$op_rc" -ne 0 ]; then
  printf 'КРАСНО: install root отказал в toy-мире на v1 (rc=%s): %s\n' \
    "$op_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
PIN1_BIN="$(sha_of "$SCRATCH/sbin/orch-peak")"
PIN1_UNIT="$(sha_of "$SCRATCH/etc/$PIN_UNIT_FILE")"
[ -n "$PIN1_BIN" ] && [ -n "$PIN1_UNIT" ] || { printf 'NOT_IMPLEMENTED: пин v1 пуст\n' >&2; exit 2; }

# ── 2. установка v2 поверх ───────────────────────────────────────────────────
printf '%s\n' "$MARKER2" >> "$SCRATCH/proj/ops/server/root/orch-peak"
printf '%s\n' "$MARKER2" >> "$SCRATCH/proj/ops/server/root/systemd/$PIN_UNIT_FILE"
run_install root
if [ "$op_rc" -ne 0 ]; then
  printf 'КРАСНО: install root отказал в toy-мире на v2 (rc=%s): %s\n' \
    "$op_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if [ "$(sha_of "$SCRATCH/sbin/orch-peak")" = "$PIN1_BIN" ]; then
  printf 'КРАСНО: мир не построен: v2 не изменила установленный orch-peak\n' >&2
  exit 1
fi

# ── 3. ОТКАТ: далее install НЕ вызывается (наблюдение без маскировки) ───────
printf 'failed\n' > "$CTL_STATE"
JMARK="$(wc -l < "$CTL_LOG" 2>/dev/null || printf '0\n')"
run_install rollback
if [ "$op_rc" -eq 2 ] && grep -q 'использование' "$SCRATCH/out"; then
  printf 'КРАСНО: подкоманды отката нет (usage user|root|verify) — И-6b не реализован\n' >&2
  exit 1
fi
if [ "$op_rc" -eq 2 ]; then
  printf 'NOT_IMPLEMENTED: мир отката сломан: %s\n' "$(cat "$SCRATCH/out")" >&2
  exit 2
fi
if [ "$op_rc" -ne 0 ]; then
  printf 'КРАСНО: откат отказал (rc=%s): %s\n' \
    "$op_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi

# ── 4. наблюдение: побайтово v1, откат сам перезапустил юнит ────────────────
NOW_BIN="$(sha_of "$SCRATCH/sbin/orch-peak")"
NOW_UNIT="$(sha_of "$SCRATCH/etc/$PIN_UNIT_FILE")"
if [ "$NOW_BIN" != "$PIN1_BIN" ]; then
  printf 'КРАСНО: откат не восстановил orch-peak побайтово (И-6b пробит: стаб s5 / root не сохранил прежнюю версию)\n' >&2
  exit 1
fi
if [ "$NOW_UNIT" != "$PIN1_UNIT" ]; then
  printf 'КРАСНО: откат не восстановил юнит-файл %s побайтово (И-6b)\n' "$PIN_UNIT_FILE" >&2
  exit 1
fi
tail -n +"$((JMARK + 1))" "$CTL_LOG" > "$SCRATCH/journal_rollback"
if ! grep -Fxq 'daemon-reload' "$SCRATCH/journal_rollback"; then
  printf 'КРАСНО: откат не исполнил systemctl daemon-reload сам (И-6b, находка 2 круга 2)\n' >&2
  exit 1
fi
if ! grep -Fxq "restart $UNIT" "$SCRATCH/journal_rollback" \
   && ! grep -Fxq "start $UNIT" "$SCRATCH/journal_rollback"; then
  printf 'КРАСНО: откат не перезапустил юнит %s сам (И-6b)\n' "$UNIT" >&2
  exit 1
fi
state="$("$SCRATCH/bin/systemctl" is-active "$UNIT")"
if [ "$state" != active ]; then
  printf 'КРАСНО: юнит не активен после отката (состояние: %s, И-6b)\n' "$state" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-6): откат восстановил v1 побайтово (orch-peak + %s) и сам перезапустил юнит, активна v1 (И-6b)\n' "$PIN_UNIT_FILE" >&2
exit 0
