#!/usr/bin/env bash
# Клетка 6 (И-6b, «Выход» п.6) контракта 093, v2 (Рв2-5, слово владельца
# 2026-10-12): юнит — ONESHOT; успех отката = юнит ЗАВЕРШИЛ НОВЫЙ запуск
# (Result=success И свежий ExecMainExitTimestamp позже момента restart ЭТОЙ
# пробой), ActiveState=inactive — НОРМА. Живая последовательность БЕЗ
# install между откатом и наблюдением (находка 2 круга 2 — переустановка
# ПОСЛЕ отката маскирует неработоспособность):
#   v1 установлена (пин sha256 orch-peak и юнит-файла снят В ПАМЯТЬ до
#   установки v2) → v2 установлена → откат → адресаты побайтово v1, откат
#   САМ исполнил systemctl daemon-reload и restart (systemctl-шим v2
#   клетки 5), НОВЫЙ запуск завершён успешно (Result=success, штамп
#   позже T0 отката).
# Три мира отката: ок (свежий успех → rc 0), падение (Result=failed →
# rc 1 именованный), stale (старый успех, штамп ДО restart → ТОЖЕ rc 1
# именованный — принимающий старый успех за новый запуск ПОЙМАН, Рв2-5).
# До-v2 субъект (is-active после restart) → КРАСНО в мир-ок «отверг
# завершённый oneshot»; повторная установка v2 как «проверка отката» не
# допускается — клетка после отката install НЕ вызывает (порядок команд).
# Toy-мир: euid-0 шим id (прецедент 090-класса), шимы chown/chattr/lsattr/
# useradd/visudo, systemctl-шим v2 (oneshot) клетки 5.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/install.sh"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }
[ -d "$ROOT/ops/server/root/systemd" ] || { printf 'NOT_IMPLEMENTED: нет юнитов субъекта\n' >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-6-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

CTL_STATE="$SCRATCH/unit_state"
CTL_MODE="$SCRATCH/unit_mode"
CTL_LOG="$SCRATCH/systemctl.log"
UNIT="toy-peak@0"
PIN_UNIT_FILE="orch-peak@.service"   # пинуется один представитель юнитов
export OPS093_CTL_STATE="$CTL_STATE" OPS093_CTL_LOG="$CTL_LOG" OPS093_CTL_MODEFILE="$CTL_MODE"

# ── toy-мир: шимы в PATH субъекта ────────────────────────────────────────────
mkdir -p "$SCRATCH/bin"

# id: root-гард субъекта обязан проходить (модель euid 0, прецедент 090).
printf '%s\n' '#!/usr/bin/env bash' \
  '[ "${1:-}" = "-u" ] && { printf "0\n"; exit 0; }' \
  'printf "uid=0(root) gid=0(root) groups=0(root)\n"; exit 0' > "$SCRATCH/bin/id"
chmod 755 "$SCRATCH/bin/id"

# systemctl-шим v2 (oneshot-модель Рв2-5, та же форма что клетка 5):
# состояние — ActiveState=/Result=/ExecMainExitTimestamp= (наносекунды),
# режим ok|fail|stale; stale — start проходит, НО штамп/Result НЕ
# обновляются (старый успех). Самопроверка первой ступенью.
cat > "$SCRATCH/bin/systemctl" <<'EOF'
#!/usr/bin/env bash
set -u
[ -n "${OPS093_CTL_STATE:-}" ] && [ -n "${OPS093_CTL_LOG:-}" ] && [ -n "${OPS093_CTL_MODEFILE:-}" ] \
  || { printf 'systemctl-шим: мир не построен (нет OPS093_CTL_*)\n' >&2; exit 2; }
[ -f "$OPS093_CTL_STATE" ] || { printf 'systemctl-шим: нет файла состояния\n' >&2; exit 2; }
[ "$#" -ge 1 ] || { printf 'systemctl-шим: нет подкоманды\n' >&2; exit 2; }
printf '%s\n' "$*" >> "$OPS093_CTL_LOG"
get() { sed -n "s/^$1=//p" "$OPS093_CTL_STATE" | tail -n 1; }
case "$1" in
  is-active)
    a="$(get ActiveState)"; printf '%s\n' "$a"
    [ "$a" = active ] && exit 0
    exit 3 ;;
  daemon-reload) exit 0 ;;
  restart|start)
    m="$(cat "$OPS093_CTL_MODEFILE")"
    if [ "$m" = stale ]; then
      sed -i "s/^ActiveState=.*/ActiveState=inactive/" "$OPS093_CTL_STATE"
      exit 0
    fi
    [ "$m" = fail ] && r=failed || r=success
    printf 'ActiveState=inactive\nResult=%s\nExecMainExitTimestamp=%s\n' \
      "$r" "$(date +%s%N)" > "$OPS093_CTL_STATE"
    exit 0 ;;
  stop)
    sed -i "s/^ActiveState=.*/ActiveState=inactive/" "$OPS093_CTL_STATE"
    exit 0 ;;
  show)
    take=0 printed=0
    for a in "$@"; do
      [ "$a" = show ] && continue
      case "$a" in
        -p) take=1; continue ;;
        --property=*) a="${a#--property=}" ;;
        -*|*@*|*.service) continue ;;
        *) [ "$take" = 1 ] || { continue; } ;;
      esac
      printf '%s=%s\n' "$a" "$(get "$a")"
      take=0; printed=1
    done
    [ "$printed" = 1 ] || { printf 'systemctl-шим: show без свойств\n' >&2; exit 2; }
    exit 0 ;;
  *) printf 'systemctl-шим: не модель: %s\n' "$1" >&2; exit 2 ;;
esac
EOF
chmod 755 "$SCRATCH/bin/systemctl"
CTL="$SCRATCH/bin/systemctl"

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

# самопроверка шима ДО субъекта: restart/show отвечают моделью
printf 'ok\n' > "$CTL_MODE"
printf 'ActiveState=inactive\nResult=none\nExecMainExitTimestamp=0\n' > "$CTL_STATE"
"$CTL" restart "$UNIT" >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: шим restart\n' >&2; exit 2; }
[ "$("$CTL" show "$UNIT" -p Result)" = 'Result=success' ] || { printf 'NOT_IMPLEMENTED: шим show\n' >&2; exit 2; }

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
    OPS093_CTL_STATE="$CTL_STATE" OPS093_CTL_LOG="$CTL_LOG" OPS093_CTL_MODEFILE="$CTL_MODE" \
    OPS_SERVER_SRC="$SCRATCH/proj/ops/server" \
    OPS_SERVER_BIN_DST="$SCRATCH/bindst" \
    OPS_SERVER_SBIN_DST="$SCRATCH/sbin" \
    OPS_SERVER_ETC_DST="$SCRATCH/etc" \
    OPS_SERVER_MAIN="$SCRATCH/main" \
    OPS_SERVER_ROLLBACK_BACKUP="$SCRATCH/rollback" \
    OPS_SERVER_AGENT_USER="toyagent" \
    OPS_SERVER_AGENT_HOME="$SCRATCH/agent_home" \
    OPS_SERVER_SUDOERS_DROP="$SCRATCH/sudoers/launch" \
    OPS_SERVER_SYSTEMCTL="$CTL" \
    OPS_SERVER_UNIT="$UNIT" \
    bash "$SUBJ" "$1" >"$SCRATCH/out" 2>&1
  op_rc=$?
}

sha_of() { sha256sum <"$1" | cut -d' ' -f1; }

seed() { # $1=idle|old-success
  if [ "$1" = old-success ]; then
    printf 'ActiveState=inactive\nResult=success\nExecMainExitTimestamp=%s\n' "$(date +%s%N)" > "$CTL_STATE"
  else
    printf 'ActiveState=inactive\nResult=none\nExecMainExitTimestamp=0\n' > "$CTL_STATE"
  fi
}

# ── 1. установка v1, пин в ПАМЯТЬ до всякого v2 (правило 8) ─────────────────
printf 'ok\n' > "$CTL_MODE"
seed idle
: > "$CTL_LOG"
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
  printf 'КРАСНО: install root отказал на v2 (rc=%s): %s\n' \
    "$op_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if [ "$(sha_of "$SCRATCH/sbin/orch-peak")" = "$PIN1_BIN" ]; then
  printf 'КРАСНО: v2 не установлена поверх v1 (маркер не виден)\n' >&2
  exit 1
fi

# ── 3. мир-ок: ОТКАТ — далее install НЕ вызывается (без маскировки) ─────────
JMARK="$(wc -l < "$CTL_LOG" 2>/dev/null || printf '0\n')"
T0="$(date +%s%N)"
run_install rollback
if [ "$op_rc" -eq 2 ] && grep -q 'использование' "$SCRATCH/out"; then
  printf 'КРАСНО: подкоманды rollback нет (usage user|root|verify) — И-6b не реализован\n' >&2
  exit 1
fi
if [ "$op_rc" -eq 2 ]; then
  printf 'NOT_IMPLEMENTED: мир-ок отката сломан: %s\n' "$(cat "$SCRATCH/out")" >&2
  exit 2
fi
if [ "$op_rc" -ne 0 ]; then
  printf 'КРАСНО: мир-ок: откат не принял ЗАВЕРШЁННЫЙ oneshot-запуск (Result=success, ActiveState=inactive — норма oneshot, Рв2-5; вероятно ждёт active): rc=%s: %s\n' \
    "$op_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi

# ── 4. наблюдение мир-ок: побайтово v1, откат сам перезапустил, запуск НОВЫЙ ─
NOW_BIN="$(sha_of "$SCRATCH/sbin/orch-peak")"
NOW_UNIT="$(sha_of "$SCRATCH/etc/$PIN_UNIT_FILE")"
if [ "$NOW_BIN" != "$PIN1_BIN" ]; then
  printf 'КРАСНО: откат не восстановил orch-peak побайтово (s5 «откат-удаление»)\n' >&2
  exit 1
fi
if [ "$NOW_UNIT" != "$PIN1_UNIT" ]; then
  printf 'КРАСНО: откат не восстановил %s побайтово (s5 «откат-удаление»)\n' "$PIN_UNIT_FILE" >&2
  exit 1
fi
tail -n +"$((JMARK + 1))" "$CTL_LOG" > "$SCRATCH/journal_rollback"
if ! grep -Fxq 'daemon-reload' "$SCRATCH/journal_rollback"; then
  printf 'КРАСНО: откат не исполнил systemctl daemon-reload (находка 2 круга 2)\n' >&2
  exit 1
fi
if ! grep -Fxq "restart $UNIT" "$SCRATCH/journal_rollback"; then
  printf 'КРАСНО: откат не перезапустил юнит сам (нет restart в журнале)\n' >&2
  exit 1
fi
r_now="$("$CTL" show "$UNIT" -p Result)"
ts_now="$("$CTL" show "$UNIT" -p ExecMainExitTimestamp)"
ts_val="${ts_now#ExecMainExitTimestamp=}"
if [ "$r_now" != 'Result=success' ]; then
  printf 'КРАСНО: после отката юнит не завершил успешно (Result: %s)\n' "$r_now" >&2
  exit 1
fi
case "$ts_val" in ''|*[!0-9]*) printf 'КРАСНО: после отката нет штампа завершения (%s)\n' "$ts_now" >&2; exit 1 ;; esac
if [ "$ts_val" -le "$T0" ]; then
  printf 'КРАСНО: после отката завершение НЕ свежее (ExecMainExitTimestamp не позже T0 отката — старый запуск принят за новый, Рв2-5)\n' >&2
  exit 1
fi

# ── 5. мир-падение: новый запуск после отката упал → rc 1 именованный ───────
run_install root   # снова v2 текущей (снимок v1 в .rollback), install НЕ после отката-наблюдения
[ "$op_rc" -eq 0 ] || { printf 'NOT_IMPLEMENTED: перевод v2 перед мир-падением: rc=%s\n' "$op_rc" >&2; exit 2; }
printf 'fail\n' > "$CTL_MODE"
seed idle
run_install rollback
if [ "$op_rc" -eq 0 ]; then
  printf 'КРАСНО: мир-падение: упавший после отката юнит принят за успех\n' >&2
  exit 1
fi
if [ "$op_rc" -ne 1 ]; then
  printf 'КРАСНО: мир-падение: ожидался rc 1, получен %s: %s\n' \
    "$op_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -Fq "$UNIT" "$SCRATCH/out"; then
  printf 'КРАСНО: мир-падение: отказ не именован (нет %s): %s\n' \
    "$UNIT" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi

# ── 6. мир-stale: успех СТАРЫЙ (штамп ДО restart) → тоже rc 1 именованный ────
run_install root   # v2 снова текущая
[ "$op_rc" -eq 0 ] || { printf 'NOT_IMPLEMENTED: перевод v2 перед мир-stale: rc=%s\n' "$op_rc" >&2; exit 2; }
printf 'stale\n' > "$CTL_MODE"
seed old-success
sleep 0.05  # штамп посева гарантированно ДО T0 отката
run_install rollback
if [ "$op_rc" -eq 0 ]; then
  printf 'КРАСНО: мир-stale: СТАРЫЙ успех принят за новый запуск после отката (ExecMainExitTimestamp не свежий — стаб «stale-запуск», Рв2-5)\n' >&2
  exit 1
fi
if [ "$op_rc" -ne 1 ]; then
  printf 'КРАСНО: мир-stale: ожидался rc 1, получен %s: %s\n' \
    "$op_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -Fq "$UNIT" "$SCRATCH/out"; then
  printf 'КРАСНО: мир-stale: отказ не именован (нет %s): %s\n' \
    "$UNIT" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-6): откат восстановил v1 побайтово и сам завершил НОВЫЙ запуск юнита (Result=success, свежий ExecMainExitTimestamp; падение и stale — rc 1 именованные) (И-6b, Рв2-5)\n' >&2
exit 0
