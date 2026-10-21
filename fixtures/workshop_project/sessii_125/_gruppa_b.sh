#!/usr/bin/env bash
# Группа B батареи 125: лаунчер (субъект W105_SUBJECT) в мире _mir_105.sh (стаб-omp пишет
# argv/env запуска). Живые запуски с ОДНИМ окружением станции: основная сессия (`workshop`)
# и сессия проекта (`workshop <репо>`). Дом зоны dev станции несёт конфигурацию (перечень
# сева) и живое состояние dev (sessions/, history.db, blobs/, ...) со СЛУЧАЙНЫМИ значениями;
# дом секретов станции — случайные значения. Оракулы (путь дома проекта по формуле 055,
# sha256 перечня сева, значения секретов) — в памяти клетки ДО вызова субъекта (правило 8).
# Свойства дома судятся по ФАКТИЧЕСКОМУ дому сессии (HOME из env стаба-omp), место дома —
# клеткой b01. Сверщик b08 — ЧЕСТНАЯ модель (CHK_JUDGE), не субъект.
# Печать: «ЗЕЛЕНО <id>» | «КРАСНО <id>: <почему>»; мир сломан → rc 2.
set -uo pipefail
B_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
CHK_JUDGE=${CHK_JUDGE:-$B_DIR/model/check_project_session.sh}
SRC_JSON="$B_DIR/source.json"
# shellcheck source=../_mir_105.sh
. "$B_DIR/../_mir_105.sh"
v() { if [ "$2" = 1 ]; then printf 'ЗЕЛЕНО %s\n' "$1"; else printf 'КРАСНО %s: %s\n' "$1" "$3"; fi; }
mapfile -t SEV < <(jq -r '.sev[]' "$SRC_JSON")
mapfile -t NIKOGDA < <(jq -r '.nikogda[]' "$SRC_JSON")
ENV_REL=$(jq -r '.env_rel' "$SRC_JSON"); PIN_REL=$(jq -r '.pin_rel' "$SRC_JSON")
[ "${#SEV[@]}" -gt 0 ] && [ "${#NIKOGDA[@]}" -gt 0 ] || { printf 'мир 125/B сломан: пустой перечень source.json\n' >&2; exit 2; }
H="$WORK/station"; mkdir -p "$H/.config/dev-harness"
ZONE_EXPECT="$H.state/dev-harness-sessions/$(printf '%s' "$(cd "$INSTALL" && pwd -P)" | sha256sum | cut -c1-8)/zones/dev"
PID_EXPECT=$(jq -r '.projectId' "$LAYER/registry/harness-project.json")
PHOME_EXPECT="$H.state/dev-harness-projects/$PID_EXPECT/home"
ZA="$ZONE_EXPECT/.omp/profiles/dev/agent"
mkdir -p "$ZA/sessions/2026" "$ZA/blobs" "$ZA/terminal-sessions" "$ZA/custom-session-files"
zap() { local f; for f in "${SEV[@]}" agent.db; do printf '%s-%s\n' "$f" "$(rnd 16)" > "$ZA/$f"; done; }
zap
printf 'history-%s' "$(rnd 16)" > "$ZA/history.db"
printf 'session-%s\n' "$(rnd 16)" > "$ZA/sessions/2026/s-$(rnd 4).jsonl"
printf 'blob-%s' "$(rnd 16)" > "$ZA/blobs/b-$(rnd 4)"
printf 'term-%s\n' "$(rnd 8)" > "$ZA/terminal-sessions/t1"
printf 'csf-%s\n' "$(rnd 8)" > "$ZA/custom-session-files/f.txt"
# оракул b05 (в памяти ДО запуска субъекта): sha256 непустых файлов живого состояния dev и реальные пути его корней
ZA_R=$(readlink -f "$ZA")
ZHIV_SHA=$(for n in "${NIKOGDA[@]}"; do [ -e "$ZA/$n" ] && find "$ZA/$n" -type f -size +0 -exec sha256sum {} +; done | cut -c1-64 | LC_ALL=C sort -u)
[ -n "$ZHIV_SHA" ] || { printf 'мир 125/B сломан: у живого состояния dev нет непустых файлов\n' >&2; exit 2; }
SEC1="ghp_$(rnd 20)"; SEC2="sk-$(rnd 20)"
printf 'GH_TOKEN=%s\nOPENAI_API_KEY=%s\n' "$SEC1" "$SEC2" > "$H/.config/dev-harness/secrets.env"
snap() { local f; for f in "${SEV[@]}"; do printf '%s %s\n' "$f" "$(sha256sum < "$ZA/$f" | cut -c1-64)"; done; }
launch() { # $1 = имя; $2 = dev|proj|<путь репо>; далее — флаги лаунчера
  local n=$1 mode=$2; shift 2
  local tgt=()
  case "$mode" in dev) ;; proj) tgt=("$REPO") ;; *) tgt=("$mode") ;; esac
  rm -f "$WORK/$n.calls" "$WORK/$n.argv" "$WORK/$n.env"
  RC=0
  ( cd "$WORK" && env PATH="$SHIMDIR:$PATH" HOME="$H" XDG_STATE_HOME="$H.state" \
    HARNESS_PROJECT_LAYER_ROOT="$LAYER" ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key \
    METERING_PROXY_TOKEN=toy-token METERING_PROXY_URL=http://toy.invalid:1 \
    SHIM_CALLS="$WORK/$n.calls" SHIM_ARGV="$WORK/$n.argv" SHIM_ENV="$WORK/$n.env" \
    bash "$INSTALL/workshop" "$@" "${tgt[@]}" > "$WORK/$n.out" 2> "$WORK/$n.err" ) || RC=$?
}
envval() { sed -n "s/^$2=//p" "$WORK/$1.env" | head -1; }
dosh() { local n=$1 id; shift; [ -s "$WORK/$n.argv" ] && return 0
  for id in "$@"; do v "$id" 0 "сессия проекта не дошла до omp (rc $RC): $(sed -n '1,3p' "$WORK/$n.err" | tr '\n' '|')"; done; return 1; }
launch dev dev
[ -s "$WORK/dev.argv" ] || { printf 'мир 125/B сломан: основная сессия не дошла до omp (rc %s): %s\n' "$RC" "$(sed -n '1,3p' "$WORK/dev.err" | tr '\n' '|')" >&2; exit 2; }
[ "$(envval dev HOME)" = "$ZONE_EXPECT" ] || { printf 'мир 125/B сломан: дом основной сессии %s ≠ формуле 028 %s\n' "$(envval dev HOME)" "$ZONE_EXPECT" >&2; exit 2; }
SNAP1=$(snap)
launch proj proj
if dosh proj b01-dom-otdelnyj b02-sev-pobajtno b05-ne-sessii b06-ne-sekrety b07-agentdb-w8 b08-sverka-chestnaya b09-podtv-bez-yolo; then
  P_HOME=$(envval proj HOME); PA="$P_HOME/.omp/profiles/dev/agent"
  ok=0; [ "$P_HOME" = "$PHOME_EXPECT" ] && [ "$P_HOME" != "$ZONE_EXPECT" ] && ok=1
  v b01-dom-otdelnyj "$ok" "дом сессии проекта $P_HOME ≠ отдельному дому $PHOME_EXPECT (зона dev $ZONE_EXPECT)"
  why=""
  while read -r f s; do
    if [ -L "$PA/$f" ]; then why="$why $f — ссылка;"
    elif [ ! -f "$PA/$f" ]; then why="$why $f — нет;"
    elif [ "$(sha256sum < "$PA/$f" | cut -c1-64)" != "$s" ]; then why="$why $f — не побайтно;"; fi
  done <<< "$SNAP1"
  v b02-sev-pobajtno "$([ -z "$why" ] && echo 1 || echo 0)" "перечень сева в доме проекта ≠ зоне dev:$why"
  # b05: живое состояние dev в доме проекта ни ссылкой в него, ни побайтной копией ПОД ЛЮБЫМ именем и в любом месте дома
  why=""
  while IFS= read -r -d '' q; do
    if [ -L "$q" ]; then
      t=$(readlink -f "$q" 2>/dev/null) || continue
      for n in "${NIKOGDA[@]}"; do case "$t" in "$ZA_R/$n"|"$ZA_R/$n"/*) why="$why ${q#"$P_HOME"/} — ссылка в живое состояние dev;" ;; esac; done
    elif [ -f "$q" ] && [ -s "$q" ] && printf '%s\n' "$ZHIV_SHA" | grep -qxF -- "$(sha256sum < "$q" | cut -c1-64)"; then
      why="$why ${q#"$P_HOME"/} — копия файла живого состояния dev;"
    fi
  done < <(find "$P_HOME" -print0)
  v b05-ne-sessii "$([ -z "$why" ] && echo 1 || echo 0)" "живое состояние dev в доме проекта:$why"
  why=""
  for s in "$SEC1" "$SEC2"; do
    grep -rqF -- "$s" "$H.state/dev-harness-projects" 2>/dev/null && why="$why значение секрета в PSTATE;"
    grep -qF -- "$s" "$WORK/proj.out" "$WORK/proj.err" && why="$why значение секрета в выводе лаунчера;"
  done
  v b06-ne-sekrety "$([ -z "$why" ] && echo 1 || echo 0)" "$why"
  ok=0; [ -L "$PA/agent.db" ] && [ "$(readlink -f "$PA/agent.db")" = "$(readlink -f "$ZA/agent.db")" ] && ok=1
  v b07-agentdb-w8 "$ok" "agent.db дома проекта — не симлинк W8 на базу dev"
  JRC=0; JOUT=$(bash "$CHK_JUDGE" --main-argv "$WORK/dev.argv" --main-env "$WORK/dev.env" --project-argv "$WORK/proj.argv" --project-env "$WORK/proj.env" 2>/dev/null) || JRC=$?
  v b08-sverka-chestnaya "$([ "$JRC" = 0 ] && echo 1 || echo 0)" "честный сверщик rc=$JRC: $(printf '%s' "$JOUT" | tr '\n' '|')"
  ok=0; [ "$(grep -cxF -- '--approval-mode' "$WORK/proj.argv")" = 0 ] && ok=1
  v b09-podtv-bez-yolo "$ok" "без --yolo сессия проекта получила --approval-mode (основная — нет)"
fi
# b03: дрейф — конфигурация dev изменилась между стартами; второй старт обязан пересеять
zap; SNAP2=$(snap)
launch proj2 proj
if dosh proj2 b03-drejf; then
  PA2="$(envval proj2 HOME)/.omp/profiles/dev/agent"; why=""
  while read -r f s; do [ -f "$PA2/$f" ] && [ "$(sha256sum < "$PA2/$f" | cut -c1-64)" = "$s" ] || why="$why $f;"; done <<< "$SNAP2"
  v b03-drejf "$([ -z "$why" ] && echo 1 || echo 0)" "после изменения в dev второй старт не пересеял:$why"
fi
# b04: запись сессии проекта в свой дом не доходит до зоны dev
if [ -s "$WORK/proj2.argv" ]; then
  PA2="$(envval proj2 HOME)/.omp/profiles/dev/agent"; SNAPZ=$(snap); why=""
  for f in "${SEV[@]}"; do
    if [ -f "$PA2/$f" ]; then printf 'project-write-%s\n' "$(rnd 8)" >> "$PA2/$f"; else why="$why $f — сева нет;"; fi
  done
  [ "$(snap)" = "$SNAPZ" ] || why="$why запись проекта изменила зону dev;"
  v b04-zapis-ne-v-dev "$([ -z "$why" ] && echo 1 || echo 0)" "$why"
else v b04-zapis-ne-v-dev 0 "сессия проекта не дошла до omp (rc $RC)"; fi
# b10: с --yolo режим подтверждений сессии проекта = основной
launch devy dev --yolo; launch projy proj --yolo
ok=0
if [ -s "$WORK/projy.argv" ] && [ -s "$WORK/devy.argv" ]; then
  [ "$(argv_vals projy --approval-mode)" = "$(argv_vals devy --approval-mode)" ] && [ -n "$(argv_vals projy --approval-mode)" ] && ok=1
fi
v b10-podtv-yolo "$ok" "с --yolo режим подтверждений сессии проекта ≠ основной"
# b11: раскладка подключения 125 — харнессовое только под .harness/ (без корневых .env и config/)
R2="$WORK/repo-harness"; cp -R "$REPO" "$R2"
mkdir -p "$R2/.harness"; mv "$R2/.env" "$R2/$ENV_REL"; mv "$R2/config/harness_pin.json" "$R2/$PIN_REL"; rmdir "$R2/config"
launch r2 "$R2"
ok=0; [ "$(launch_n r2)" = 1 ] && ok=1
v b11-harness-raskladka "$ok" "лаунчер не принял $ENV_REL и $PIN_REL (rc $RC): $(sed -n '1,2p' "$WORK/r2.err" | tr '\n' '|')"
exit 0
