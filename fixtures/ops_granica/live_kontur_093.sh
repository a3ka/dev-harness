#!/usr/bin/env bash
# Живой станционный контур контракта 093 — приёмка п.9, материализация прозы
# в исполняемый файл («исполняемое живёт в скрипте, а не в прозе»).
# Слово владельца 2026-10-13 ~12:00 UTC: «093 — доделать обязательно (…проверка
# на настоящем uid/systemd, не только shim)» — этот скрипт и есть настоящий
# контур: настоящий sudo, настоящий systemctl/systemd, настоящий useradd →
# orchagent, и ВЕСЬ раннер красной семьи — под настоящим uid агента.
#
# ИСПОЛНИТЕЛЬ: доверенный оператор станции (владелец sudo), НЕ CI, НЕ субагент:
#   sudo env OPS_LIVE_V2_ROOT=<второй каталог ops/server> \
#        bash fixtures/ops_granica/live_kontur_093.sh
# OPS_LIVE_V2_ROOT обязан указывать на ДРУГОЙ ops/server (например, клон
# origin/main): rollback-проба п.9 требует v2 ≠ v1 — равные версии делают
# пробу пустой, и это именованный отказ, а не зелёное.
#
# Шаги (п.9 дословно): (1) sudo install.sh root → rc 0, оракул sha256 адресатов
# в ПАМЯТИ (правило 8); (2) настоящий restart юнита → oneshot ЗАВЕРШИЛ НОВЫЙ
# запуск: Result=success И свежий ExecMainExitTimestamp > t0 ЭТОЙ пробы
# (ActiveState=inactive — норма, НЕ требовать active — Рв2-5); (3) настоящая
# идентичность агента: orchagent существует, БЕЗ группы harness,
# /opt/orch-agent/workshop исполняем, /var/lib/orch-agent есть, sudoers-drop
# валиден и называет агента; (4) живой откат без маскировки: v1 → v2 → rollback
# (БЕЗ install между откатом и наблюдением) → адресаты побайтово v1 по sha256
# И свежий oneshot-штамп позже T0 отката; (5) sudo -u orchagent _krasnye_093.sh
# — вся семья под настоящим uid агента (половина-Б И-8б зелёна только так).
#
# Коды возврата: 0 — контур зелёный (все пять шагов); 1 — именованный отказ
# живого свойства (с указанием шага и меры); 2 — нечем исполнить (нет
# привилегий/systemd/visudo/V2-корня; задан шов — живой контур только
# производственный, прецедент «шов-мир» install.sh).
set -uo pipefail
export LC_ALL=C

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/install.sh"
UNIT="${OPS_LIVE_UNIT:-orch-peak@0}"
V2="${OPS_LIVE_V2_ROOT:-}"
SBIN=/usr/local/sbin
ETC=/etc/systemd/system
AGENT_USER=orchagent
SUDOERS_DROP=/etc/sudoers.d/orch-agent-launcher

ni() { printf 'NOT_IMPLEMENTED(093-live): %s\n' "$1" >&2; exit 2; }
kr() { printf 'КРАСНО(093-live): %s\n' "$1" >&2; exit 1; }
zl() { printf 'ЗЕЛЁНО(093-live): %s\n' "$1" >&2; }

# ── 0. предусловия ───────────────────────────────────────────────────────────
for v in OPS_SERVER_SBIN_DST OPS_SERVER_ETC_DST OPS_SERVER_BIN_DST \
         OPS_SERVER_AGENT_USER OPS_SERVER_AGENT_HOME OPS_SERVER_AGENT_ROOT \
         OPS_SERVER_ROLLBACK_BACKUP OPS_SERVER_UNIT; do
  [ -z "${!v:-}" ] || ni "задан шов $v — живой контур только производственный (без швов)"
done
[ "$(id -u)" -eq 0 ] || ni "живой контур исполняет доверенный оператор станции: euid=$(id -u), нужен 0 (sudo)"
command -v systemctl >/dev/null 2>&1 || ni "нет systemctl"
[ -d /run/systemd/system ] || ni "нет системного менеджера systemd (/run/systemd/system)"
command -v visudo >/dev/null 2>&1 || ni "нет visudo (сверка sudoers-drop)"
[ -f "$SUBJ" ] || ni "нет субъекта $SUBJ"
[ -n "$V2" ] || ni "OPS_LIVE_V2_ROOT не задан — rollback-пробе нужен второй ops/server (v2 ≠ v1)"
[ -f "$V2/install.sh" ] && [ -f "$V2/root/orch-peak" ] && [ -f "$V2/user/orch-loop" ] \
  || ni "OPS_LIVE_V2_ROOT=$V2 не каталог ops/server (нет install.sh/root/orch-peak/user/orch-loop)"

# Список юнитов — из ЕДИНОГО источника (строка UNITS= субъекта), не переизобретается.
UNITS="$(sed -n 's/^UNITS=//p' "$SUBJ" | tr -d "'")"
[ -n "$UNITS" ] || ni "не извлечён список юнитов из $SUBJ (строка UNITS=)"
TARGETS="$SBIN/orch-peak $SBIN/lib_session.sh"
for u in $UNITS; do TARGETS="$TARGETS $ETC/$u"; done
n_targets=0; for t in $TARGETS; do n_targets=$((n_targets+1)); done
printf 'целей сверки: %s\n' "$n_targets" >&2

sha_of() { sha256sum "$1" 2>/dev/null | awk '{print $1}'; }
v1_sha() { printf '%s\n' "$V1_LIST" | tr ' ' '\n' | sed -n "s|^$1:||p"; }

# oneshot-завершённость СВОИМ оракулом (не функцией субъекта — правило 8):
# Result=success И ExecMainExitTimestamp > t0 этой пробы; причина — в stdout.
oneshot_done() {  # <t0-ns>
  local t0="$1" props result stamp stamp_ns i
  result=""; stamp=""
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    props="$(systemctl show "$UNIT" -p Result -p ExecMainExitTimestamp 2>&1)" || { sleep 1; continue; }
    result="$(printf '%s\n' "$props" | sed -n 's/^Result=//p' | tail -n 1)"
    stamp="$(printf '%s\n' "$props" | sed -n 's/^ExecMainExitTimestamp=//p' | tail -n 1)"
    [ "$result" = "failed" ] && { printf 'Result=failed'; return 1; }
    if [ "$result" = "success" ] && [ -n "$stamp" ]; then
      stamp_ns="$(date -d "$stamp" +%s%N 2>/dev/null || true)"
      case "$stamp_ns" in
        ''|*[!0-9]*) ;;
        *) if [ "$stamp_ns" -gt "$t0" ]; then return 0; fi ;;
      esac
    fi
    sleep 1
  done
  printf 'юнит %s не завершил НОВЫЙ запуск за 15с (Result=%s, штамп=%s)' \
    "$UNIT" "${result:-<пусто>}" "${stamp:-<нет>}"
  return 1
}

# ── 1. v1 = install из субъекта; оракул sha256 адресатов в памяти ───────────
printf 'шаг 1: install root из субъекта (v1)\n' >&2
bash "$SUBJ" root || kr "install root (v1) rc=$? — установщик отказал"
V1_LIST=""; n_v1=0
for t in $TARGETS; do
  s="$(sha_of "$t")"; [ -n "$s" ] || kr "v1: адресат $t отсутствует после install"
  V1_LIST="$V1_LIST $t:$s"; n_v1=$((n_v1+1))
done
[ "$n_v1" -eq "$n_targets" ] || kr "v1: адресатов $n_v1, ожидалось $n_targets"
zl "install root (v1): rc 0, снято sha256 $n_v1/$n_targets адресатов (оракул в памяти)"

# ── 2. настоящий oneshot-запуск юнита ───────────────────────────────────────
printf 'шаг 2: настоящий systemctl restart %s\n' "$UNIT" >&2
systemctl cat "$UNIT" >/dev/null 2>&1 || kr "юнит $UNIT не установлен (systemctl cat)"
t0="$(date +%s%N)"
systemctl restart "$UNIT" || kr "systemctl restart $UNIT rc=$?"
if msg="$(oneshot_done "$t0")"; then
  zl "юнит $UNIT: oneshot ЗАВЕРШИЛ НОВЫЙ запуск (Result=success, штамп свежий > t0)"
else
  kr "шаг 2: $msg"
fi

# ── 3. настоящая идентичность агента (Рв2-6) ────────────────────────────────
printf 'шаг 3: идентичность агента\n' >&2
getent passwd "$AGENT_USER" >/dev/null 2>&1 || kr "нет системного пользователя $AGENT_USER (install не провизионил)"
groups_ag="$(id -nG "$AGENT_USER")"
printf '%s\n' "$groups_ag" | tr ' ' '\n' | grep -Fxq harness \
  && kr "$AGENT_USER входит в группу harness (Рв2-6): группы=[$groups_ag]"
[ -x /opt/orch-agent/workshop ] || kr "/opt/orch-agent/workshop не исполняем (код агента не провизионен)"
[ -d /var/lib/orch-agent ] || kr "нет /var/lib/orch-agent (HOME агента)"
[ -f "$SUDOERS_DROP" ] || kr "нет sudoers-drop $SUDOERS_DROP"
grep -Fq "$AGENT_USER" "$SUDOERS_DROP" || kr "sudoers-drop не называет $AGENT_USER"
visudo -c -f "$SUDOERS_DROP" >/dev/null 2>&1 || kr "sudoers-drop невалиден (visudo -c)"
zl "агент: $AGENT_USER (группы=[$groups_ag], без harness), /opt/orch-agent/workshop исполним, /var/lib/orch-agent есть, sudoers-drop валиден и называет агента"

# ── 4. живой откат без маскировки: v1 → v2 → rollback → ИМЕННО v1 ───────────
printf 'шаг 4: rollback-проба v1 → v2 → откат (без install между откатом и наблюдением)\n' >&2
bash "$V2/install.sh" root || kr "install root (v2 из $V2) rc=$? — установщик v2 отказал"
n_diff=0
for t in $TARGETS; do
  [ "$(sha_of "$t")" != "$(v1_sha "$t")" ] && n_diff=$((n_diff+1))
done
[ "$n_diff" -ge 1 ] || kr "v2 неотличим от v1 (0/$n_targets расхождений) — rollback-проба пуста; задайте ДРУГОЙ OPS_LIVE_V2_ROOT"
printf 'v2 отличается от v1 в %s/%s адресатах — проба не пуста\n' "$n_diff" "$n_targets" >&2
t0r="$(date +%s%N)"
bash "$SUBJ" rollback || kr "rollback rc=$? — откат отказал"
n_restored=0; n_checked=0; bad=""
for t in $TARGETS; do
  n_checked=$((n_checked+1))
  if [ "$(sha_of "$t")" = "$(v1_sha "$t")" ]; then n_restored=$((n_restored+1)); else bad="$bad $t"; fi
done
[ -z "$bad" ] || kr "откат не восстановил v1 побайтово:$bad (восстановлено $n_restored/$n_checked)"
if msg="$(oneshot_done "$t0r")"; then
  zl "откат: восстановлено $n_restored/$n_checked побайтово v1, юнит завершил НОВЫЙ запуск после отката (штамп > T0 отката)"
else
  kr "шаг 4: после отката $msg"
fi

# ── 5. вся семья под НАСТОЯЩИМ uid агента (И-8б половина-Б) ─────────────────
printf 'шаг 5: sudo -u %s _krasnye_093.sh (настоящий uid, не shim)\n' "$AGENT_USER" >&2
out="$(sudo -nu "$AGENT_USER" bash "$ROOT/fixtures/_krasnye_093.sh" "$ROOT" 2>&1)"; rc5=$?
printf '%s\n' "$out" | tail -15 >&2
[ "$rc5" -eq 0 ] || kr "семья под uid $AGENT_USER rc=$rc5 — настоящая uid-граница не доказана (см. вывод выше)"
zl "раннер семьи под настоящим uid $AGENT_USER: rc 0 (включая половину-Б И-8б)"

zl "контур п.9 зелёный: install v1 $n_v1/$n_targets; oneshot свежий; агент без harness; откат $n_restored/$n_checked + свежий oneshot; семья под uid агента rc 0"
exit 0
