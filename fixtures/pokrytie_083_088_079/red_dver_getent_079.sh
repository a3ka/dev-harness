#!/usr/bin/env bash
# Семья 079, часть Р4: дверь 088 (инв. И-1, fail-closed ветвь): ПУСТОЙ ответ
# `getent passwd "$(id -un)"` → rc 2 NOT_IMPLEMENTED, маркер НЕ ставится.
# Дыра покрытия (аудит 079): клетки D0-D11 судят дом из passwd по СВОЕМУ шиму
# getent, который ОТВЕЧАЕТ домом; ветвь «пустой ответ» не покрыта ни одной
# клеткой и ни одним стабом (sa1-sa27). Реализация ветви —
# scripts/orch_restart.sh:91-96 (замер 079: rc 2, строка
# «NOT_IMPLEMENTED: getent passwd не дал дома», маркер отсутствует).
#
# Использование: bash red_dver_getent_079.sh <корень> [Р4-getent Р4-норма]
#   [--dver <файл>] — подменить дверь тою-мира (стаб-пак/диффпроба).
# Коды: 0 — все судимые клетки зелёные; 1 — есть красная; 2 — нечем проверить.
#
# Клетки:
#   Р4-getent  тою-мир двери (HEAD впереди origin/main — прошедшая ногу (1)
#              дверь останавливается на (а)); PATH-шим getent: `passwd` →
#              exit 0 БЕЗ вывода (пустой ответ базы; шим живёт в скратче,
#              реальная станция не трогается — Н-219); HOME сессии — пустой
#              каталог скратча; швы ORCH_SESS_* сняты. Ожидание: rc 2,
#              stderr самостоятельной строкой несёт «NOT_IMPLEMENTED: getent
#              passwd не дал дома», файла-маркера НЕТ.
#   Р4-норма   тот же мир, но шим ОТВЕЧАЕТ домом (дом без свежих журналов):
#              дверь проходит ногу (1) и останавливается на (а) «HEAD
#              расходится с origin/main» rc 1, маркера нет (пара-негатив:
#              клетка красит именно пустой getent, а не весь вход).
#
# PAK (стаб → клетка; дефект):
#   д7 → Р4-getent  дверь с подстановкой пустого дома ($HOME сессии) вместо
#     отказа: глоб пуст → нога (1) пройдена → отказ (а) rc 1 вместо rc 2.
#     Наблюдаем на Р4-getent (честный rc 2). Диффпроба: на Р4-норма д7 как
#     честный — rc 1 (а), маркера нет.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
DVER=""
kletki=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dver) DVER="$2"; shift 2 ;;
    *) kletki+=("$1"); shift ;;
  esac
done
for subj in scripts/orch_restart.sh scripts/lib_session.sh; do
  [ -f "$ROOT/$subj" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$ROOT/$subj" >&2; exit 2; }
done

KRASNYH=0; ZELENYH=0
zeleno() { printf 'ЗЕЛЕНО: %s\n' "$1"; ZELENYH=$((ZELENYH+1)); }
krasno() { printf 'КРАСНО: %s\n' "$1"; KRASNYH=$((KRASNYH+1)); }
nado() { [ "${#kletki[@]}" -eq 0 ] || case " ${kletki[*]} " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
SCR="$(mktemp -d "${TMPDIR:-/tmp}/pokrytie079-dver.XXXXXX")" || exit 2
trap 'rm -rf -- "$SCR"' EXIT

# тою-мир двери: копия субъектов, HEAD впереди origin/main (dver-форма 088)
R="$SCR/mir"
mkdir -p "$R/scripts"
if [ -n "$DVER" ]; then cp -- "$DVER" "$R/scripts/orch_restart.sh"
else cp -- "$ROOT/scripts/orch_restart.sh" "$R/scripts/orch_restart.sh"; fi
cp -- "$ROOT/scripts/lib_session.sh" "$R/scripts/lib_session.sh"
printf '# HANDOFF\n' > "$R/HANDOFF.md"
git -C "$R" init -q -b main || exit 2
git -C "$R" -c user.name=t -c user.email=t@t add -A
git -C "$R" -c user.name=t -c user.email=t@t commit -qm osnova
git -C "$R" update-ref refs/remotes/origin/main HEAD
printf 'vpered\n' > "$R/f.txt"
git -C "$R" -c user.name=t -c user.email=t@t add -A
git -C "$R" -c user.name=t -c user.email=t@t commit -qm vpered

# шим getent: режим задан файлом-флагом (пусто|дом) — один носитель на обе клетки
SH="$SCR/shim"; mkdir -p "$SH" "$SCR/home-sessii" "$SCR/dom-passwd"
cat > "$SH/getent" <<'EOF'
#!/usr/bin/env bash
[ "${1:-}" = passwd ] || { for _g in /usr/bin/getent /bin/getent; do [ -x "$_g" ] && exec "$_g" "$@"; done; exit 2; }
if [ -n "${P079_GETENT_PUSTO:-}" ]; then exit 0; fi
printf '%s:x:%s:%s::%s:/bin/bash\n' "$(id -un)" "$(id -u)" "$(id -u)" "$P079_DOM"
EOF
chmod +x "$SH/getent"

zapusk() { # пустой ответ getent: → rc двери; stderr в $SCR/dver.err
  rm -f -- "$SCR/marker" "$SCR/start"
  env -u ORCH_SESS_DIR -u ORCH_SESS_GLOB -u PI_CODING_AGENT_DIR \
      HOME="$SCR/home-sessii" PATH="$SH:$PATH" \
      P079_GETENT_PUSTO=1 P079_DOM="$SCR/dom-passwd" \
      ORCH_RESTART_MARKER="$SCR/marker" ORCH_SESSION_START="$SCR/start" \
      bash "$R/scripts/orch_restart.sh" --as orchestrator >/dev/null 2>"$SCR/dver.err"
}
if nado Р4-getent; then
  zapusk; rc=$?
  DVERERR="$(cat "$SCR/dver.err")"
  if [ "$rc" -eq 2 ] && grep -Fqx 'NOT_IMPLEMENTED: getent passwd не дал дома' <<<"$DVERERR" && [ ! -e "$SCR/marker" ]; then
    zeleno "Р4-getent: пустой ответ getent → rc 2 NOT_IMPLEMENTED, маркер не ставится"
  else
    krasno "Р4-getent: ждали rc 2 + строку NOT_IMPLEMENTED и нет маркера; rc=$rc маркер=$([ -e "$SCR/marker" ] && echo есть || echo нет): $DVERERR"
  fi
fi

if nado Р4-норма; then
  rm -f -- "$SCR/marker" "$SCR/start"
  env -u ORCH_SESS_DIR -u ORCH_SESS_GLOB -u PI_CODING_AGENT_DIR \
      HOME="$SCR/home-sessii" PATH="$SH:$PATH" \
      P079_DOM="$SCR/dom-passwd" \
      ORCH_RESTART_MARKER="$SCR/marker" ORCH_SESSION_START="$SCR/start" \
      bash "$R/scripts/orch_restart.sh" --as orchestrator >/dev/null 2>"$SCR/dver.err"; rc=$?
  DVERERR="$(cat "$SCR/dver.err")"
  if [ "$rc" -eq 1 ] && grep -Fqx 'ОТКАЗ: HEAD расходится с origin/main' <<<"$DVERERR" && [ ! -e "$SCR/marker" ]; then
    zeleno "Р4-норма: ответный дом без свежих журналов → нога (1) пройдена, отказ (а), маркера нет"
  else
    krasno "Р4-норма: ждали rc 1 + отказ (а) и нет маркера; rc=$rc маркер=$([ -e "$SCR/marker" ] && echo есть || echo нет): $DVERERR"
  fi
fi

printf 'red_dver_getent_079.sh: зелёных %d, красных %d\n' "$ZELENYH" "$KRASNYH"
[ "$KRASNYH" -eq 0 ] || exit 1
[ "$ZELENYH" -gt 0 ] || exit 2
exit 0
