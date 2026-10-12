#!/usr/bin/env bash
# Клетка 5 (И-6a, «Выход» п.4) контракта 093, v2 (Рв2-5, слово владельца
# 2026-10-12): юнит orch-peak@0 — ONESHOT; после успешного запуска
# ActiveState=inactive — НОРМА, не сбой. verify-start проверяет ЗАВЕРШЕНИЕ
# НОВОГО ЗАПУСКА (не статичную активность): сам выдаёт start/restart ЭТОЙ
# пробой, затем требует Result=success И свежий ExecMainExitTimestamp (позже
# момента запуска этой пробы — не старого запуска). Три toy-мира
# (состояние юнита — файлы systemctl-шима, каждый вызов — в журнал,
# самопроверка первой ступенью):
#   мир-ок:      завершён успешно, свежий запуск → rc 0, маркер
#                «завершён успешно, свежий запуск»;
#   мир-падение: Result=failed → rc 1 именованный «юнит не стартует: <имя>»;
#   мир-stale:   Result=success СТАРЫЙ (ExecMainExitTimestamp ДО нового
#                start) → ТОЖЕ rc 1 именованный — обманщик, принимающий
#                старый успех за новый запуск, ПОЙМАН (Рв2-5).
# До-v2 субъект (is-active, ждёт ActiveState=active) → КРАСНО в мир-ок
# «отверг завершённый oneshot»; стаб s4 «успех-без-старта» (успех без
# вопроса/запуска systemctl) → КРАСНО журналом мир-ок и падением
# мир-падение; мир-stale ловит принимающего старый успех.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/install.sh"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-5-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/bin"

CTL_STATE="$SCRATCH/unit_state"
CTL_MODE="$SCRATCH/unit_mode"
CTL_LOG="$SCRATCH/systemctl.log"
UNIT="toy-peak@0"
export OPS093_CTL_STATE="$CTL_STATE" OPS093_CTL_LOG="$CTL_LOG" OPS093_CTL_MODEFILE="$CTL_MODE"

# systemctl-шим v2 (oneshot-модель, Рв2-5): состояние — файл строк
# ActiveState=/Result=/ExecMainExitTimestamp= (наносекунды date +%s%N);
# режим мира — файл ok|fail|stale:
#   ok   — start/restart завершается успехом (ActiveState=inactive — НОРМА
#          oneshot, Result=success, штамп — момент start);
#   fail — start/restart падает (Result=failed, штамп свежий);
#   stale — start/restart «проходит», НО Result/ExecMainExitTimestamp НЕ
#          обновляются: налицо только СТАРЫЙ успех (обманщик, не проверяющий
#          свежесть, отвечает успехом — ловится миром stale).
# Самопроверка первой ступенью: нет мира/подкоманды — именованный rc 2,
# успехом не отвечает.
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
      # старый запуск: сам start успешен, но нового завершения НЕТ
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

# самопроверка шима ДО субъекта: restart/show отвечают моделью
printf 'ok\n' > "$CTL_MODE"
printf 'ActiveState=inactive\nResult=none\nExecMainExitTimestamp=0\n' > "$CTL_STATE"
: > "$CTL_LOG"
"$CTL" restart "$UNIT" >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: шим restart не работает\n' >&2; exit 2; }
[ "$("$CTL" show "$UNIT" -p Result)" = 'Result=success' ] || { printf 'NOT_IMPLEMENTED: шим show/Result\n' >&2; exit 2; }
ts="$("$CTL" show "$UNIT" -p ExecMainExitTimestamp)"
case "$ts" in ExecMainExitTimestamp=0*|'ExecMainExitTimestamp='|'') printf 'NOT_IMPLEMENTED: шим штампа: %s\n' "$ts" >&2; exit 2 ;; esac

seed() { # $1=начальное состояние: idle | old-success
  if [ "$1" = old-success ]; then
    printf 'ActiveState=inactive\nResult=success\nExecMainExitTimestamp=%s\n' "$(date +%s%N)" > "$CTL_STATE"
  else
    printf 'ActiveState=inactive\nResult=none\nExecMainExitTimestamp=0\n' > "$CTL_STATE"
  fi
}

run_vs() { # $1=режим мира, $2=посев → rc субъекта в $vs_rc, вывод в $SCRATCH/out
  printf '%s\n' "$1" > "$CTL_MODE"
  seed "$2"
  : > "$CTL_LOG"
  env PATH="$SCRATCH/bin:$PATH" OPS_SERVER_SYSTEMCTL="$CTL" OPS_SERVER_UNIT="$UNIT" \
    bash "$SUBJ" verify-start >"$SCRATCH/out" 2>&1
  vs_rc=$?
}

usage_rc() { [ "$vs_rc" -eq 2 ] && grep -q 'использование' "$SCRATCH/out"; }

# ── мир-ок: oneshot завершился успешно, запуск свежий ────────────────────────
run_vs ok idle
if usage_rc; then
  printf 'КРАСНО: подкоманды проверки старта нет (usage user|root|verify) — И-6a не реализован\n' >&2
  exit 1
fi
if [ "$vs_rc" -eq 2 ]; then
  printf 'NOT_IMPLEMENTED: мир-ок сломан: %s\n' "$(cat "$SCRATCH/out")" >&2
  exit 2
fi
if [ "$vs_rc" -ne 0 ]; then
  printf 'КРАСНО: мир-ок: verify-start не принял ЗАВЕРШЁННЫЙ oneshot-запуск (Result=success, ActiveState=inactive — норма oneshot, Рв2-5; вероятно ждёт active): rc=%s: %s\n' \
    "$vs_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -Eq "^(restart|start) $UNIT\$" "$CTL_LOG"; then
  printf 'КРАСНО: verify-start ответил успехом без запуска юнита ЭТОЙ пробой (нет start/restart в журнале systemctl — стаб s4 «успех-без-старта», И-6a)\n' >&2
  exit 1
fi
if ! grep -Fq 'завершён успешно, свежий запуск' "$SCRATCH/out"; then
  printf 'КРАСНО: verify-start не предъявил маркер свежести «завершён успешно, свежий запуск»: %s\n' \
    "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi

# ── мир-падение: новый запуск завершился отказом ─────────────────────────────
run_vs fail idle
if usage_rc; then
  printf 'КРАСНО: подкоманды проверки старта нет — И-6a не реализован\n' >&2
  exit 1
fi
if [ "$vs_rc" -eq 2 ]; then
  printf 'NOT_IMPLEMENTED: мир-падение сломан: %s\n' "$(cat "$SCRATCH/out")" >&2
  exit 2
fi
if [ "$vs_rc" -eq 0 ]; then
  printf 'КРАСНО: мир-падение: упавший юнит принят за успех (стаб s4 «успех-без-старта», И-6a)\n' >&2
  exit 1
fi
if [ "$vs_rc" -ne 1 ]; then
  printf 'КРАСНО: мир-падение: ожидался rc 1, получен %s: %s\n' \
    "$vs_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -Fq "$UNIT" "$SCRATCH/out"; then
  printf 'КРАСНО: мир-падение: отказ не именован (нет %s): %s\n' \
    "$UNIT" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi

# ── мир-stale: успех СТАРЫЙ (штамп ДО нового start), start нового завершения
# не даёт — принимающий старый успех за новый запуск ПОЙМАН ──────────────────
sleep 0.05  # штамп посева гарантированно ДО T0 субъекта
run_vs stale old-success
if usage_rc; then
  printf 'КРАСНО: подкоманды проверки старта нет — И-6a не реализован\n' >&2
  exit 1
fi
if [ "$vs_rc" -eq 2 ]; then
  printf 'NOT_IMPLEMENTED: мир-stale сломан: %s\n' "$(cat "$SCRATCH/out")" >&2
  exit 2
fi
if [ "$vs_rc" -eq 0 ]; then
  printf 'КРАСНО: мир-stale: СТАРЫЙ успех принят за новый запуск (ExecMainExitTimestamp не свежий — стаб «stale-запуск», Рв2-5)\n' >&2
  exit 1
fi
if [ "$vs_rc" -ne 1 ]; then
  printf 'КРАСНО: мир-stale: ожидался rc 1, получен %s: %s\n' \
    "$vs_rc" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi
if ! grep -Fq "$UNIT" "$SCRATCH/out"; then
  printf 'КРАСНО: мир-stale: отказ не именован (нет %s): %s\n' \
    "$UNIT" "$(tr '\n' ' ' < "$SCRATCH/out")" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-5): verify-start различает три мира oneshot: завершён успешно свежий запуск rc 0 / падение rc 1 / stale-успех rc 1, все отказы именованы (И-6a, Рв2-5)\n' >&2
exit 0
