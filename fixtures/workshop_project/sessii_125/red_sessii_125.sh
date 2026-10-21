#!/usr/bin/env bash
# Контракт 125 «сессии проектов» — красная батарея (зона architect).
# Субъекты (зона implementer): scripts/check_project_session.sh (группа A — сверщик),
# workshop (группа B — сев конфигурации dev в отдельный дом проекта, раскладка .harness/),
# scripts/connect_project.sh (группа C — одна команда подключения). Без ключей судит
# НАСТОЯЩЕЕ дерево; --model — честные модели model/ (обязаны быть зелёными); --stabs —
# сперва модели (все зелёные), затем каждый обманный стаб stabs/ обязан дать КРАСНО ровно
# на клетках своей привязки source.json:.stab_vhod (Н-39: привязка стаб ↔ вход — по коду).
# Печать: «ЗЕЛЕНО <id>» | «КРАСНО <id>: <почему>» | «ПОЙМАН/НЕ ПОЙМАН <стаб> @ <клетка>».
# rc: 0 — все клетки зелёные (--model/дерево) или все привязки пойманы (--stabs);
# 1 — красная клетка / непойманная привязка; 2 — мир сломан или привязки несогласованы.
set -u
export PYTHONDONTWRITEBYTECODE=1
BATT=$(cd "$(dirname "$0")" && pwd -P)
REPO=$(cd "$BATT/../../.." && pwd -P)
SRC_JSON="$BATT/source.json"
WORLDS=/tmp/dev-harness-verify/s125
mkdir -p "$WORLDS"
RUNDIR=$(mktemp -d "$WORLDS/run-XXXX") || exit 2
trap 'rm -rf "$RUNDIR"' EXIT
export TMPDIR="$RUNDIR"
MODE=red
case "${1-}" in
  "") ;;
  --model) MODE=model ;;
  --stabs) MODE=stabs ;;
  *) printf 's125 ОТКАЗ: неизвестный ключ: %s\n' "$1" >&2; exit 2 ;;
esac
jq -e '.stab_vhod | type == "object"' "$SRC_JSON" >/dev/null 2>&1 || { printf 's125: нет source.json:.stab_vhod\n' >&2; exit 2; }
M="$BATT/model"
verdict() { if [ "$2" = 1 ]; then printf 'ЗЕЛЕНО %s\n' "$1"; else printf 'КРАСНО %s: %s\n' "$1" "$3"; fi; }
run_groups() { # $1 = CHK, $2 = лаунчер, $3 = дверь; печать клеток всех групп
  CHK=$1
  # shellcheck source=_gruppa_a.sh
  . "$BATT/_gruppa_a.sh"
  if [ -f "$CHK" ]; then gruppa_a
  else for id in a01-chestnaya a02-dom-obshij a17-nechem-pustye-fakty; do verdict "$id" 0 "субъекта нет: $CHK"; done; fi
  W105_SUBJECT=$2 bash "$BATT/_gruppa_b.sh" || return 2
  CONNECT_SUBJECT=$3 bash "$BATT/_gruppa_c.sh" || return 2
}
schet() { # $1 = файл клеток; печать итога, rc 1 при красной, 2 при нуле клеток
  local G R
  G=$(grep -c '^ЗЕЛЕНО ' "$1"); R=$(grep -c '^КРАСНО ' "$1")
  printf 's125 %s: зелёных %s, красных %s\n' "$2" "$G" "$R" >&2
  [ "$G" -gt 0 ] || [ "$R" -gt 0 ] || { printf 's125: ноль клеток — нечего судить\n' >&2; return 2; }
  [ "$R" = 0 ] || return 1
}
case "$MODE" in
  red|model)
    if [ "$MODE" = model ]; then S_CHK=$M/check_project_session.sh S_W=$M/workshop.sh S_C=$M/connect_project.sh
    else S_CHK=$REPO/scripts/check_project_session.sh S_W=$REPO/workshop S_C=$REPO/scripts/connect_project.sh; fi
    run_groups "$S_CHK" "$S_W" "$S_C" > "$RUNDIR/cells" || { cat "$RUNDIR/cells"; printf 's125: мир сломан\n' >&2; exit 2; }
    cat "$RUNDIR/cells"
    schet "$RUNDIR/cells" "$MODE"; exit $? ;;
  stabs)
    run_groups "$M/check_project_session.sh" "$M/workshop.sh" "$M/connect_project.sh" > "$RUNDIR/model.cells" || { printf 's125: мир сломан на модели\n' >&2; exit 2; }
    schet "$RUNDIR/model.cells" "model (опора стабов)" || { grep '^КРАСНО ' "$RUNDIR/model.cells"; printf 's125: модель не зелёная — поимка стабов не доказательна\n' >&2; exit 2; }
    mapfile -t BOUND < <(jq -r '.stab_vhod | keys[]' "$SRC_JSON" | LC_ALL=C sort)
    mapfile -t FILES < <(cd "$BATT/stabs" && ls stab_*.sh 2>/dev/null | sed 's/\.sh$//' | LC_ALL=C sort)
    [ "${BOUND[*]}" = "${FILES[*]}" ] || { printf 's125: стабы и привязки source.json расходятся: файлы [%s] / привязки [%s]\n' "${FILES[*]}" "${BOUND[*]}" >&2; exit 2; }
    N=0; MISS=0; NB=0
    for nm in "${FILES[@]}"; do
      N=$((N+1)); st="$BATT/stabs/$nm.sh"; subj="$RUNDIR/$nm.subj"
      bash "$st" "$M" "$subj" || { printf 's125: стаб %s не собран\n' "$nm" >&2; exit 2; }
      chmod +x "$subj"
      S_CHK=$M/check_project_session.sh S_W=$M/workshop.sh S_C=$M/connect_project.sh
      case "$nm" in
        stab_chk_*) S_CHK=$subj ;;
        stab_lnch_*) S_W=$subj ;;
        stab_conn_*) S_C=$subj ;;
        *) printf 's125: стаб вне алфавита групп: %s\n' "$nm" >&2; exit 2 ;;
      esac
      run_groups "$S_CHK" "$S_W" "$S_C" > "$RUNDIR/$nm.cells" || { printf 's125: мир сломан на стабе %s\n' "$nm" >&2; exit 2; }
      mapfile -t cells < <(jq -r --arg s "$nm" '.stab_vhod[$s][]' "$SRC_JSON")
      [ "${#cells[@]}" -gt 0 ] || { printf 's125: у стаба %s пустая привязка\n' "$nm" >&2; exit 2; }
      for c in "${cells[@]}"; do
        NB=$((NB+1))
        grep -q "^ЗЕЛЕНО $c\$" "$RUNDIR/model.cells" || { printf 's125: привязка %s @ %s — клетки нет среди зелёных модели\n' "$nm" "$c" >&2; exit 2; }
        if grep -q "^КРАСНО $c: " "$RUNDIR/$nm.cells"; then printf 'ПОЙМАН %s @ %s\n' "$nm" "$c"
        else printf 'НЕ ПОЙМАН %s @ %s\n' "$nm" "$c"; MISS=$((MISS+1)); fi
      done
    done
    printf 's125 stabs: стабов %s, привязок %s, непойманных привязок %s\n' "$N" "$NB" "$MISS" >&2
    [ "$N" -gt 0 ] || exit 2
    [ "$MISS" = 0 ] || exit 1
    exit 0 ;;
esac
