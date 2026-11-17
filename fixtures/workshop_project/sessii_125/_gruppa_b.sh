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
# ── 125 v2: фиксация фактов exec лаунчером (И-9) — b12–b16 ────────────────────
# Оракул — НАБЛЮДЕНИЕ стаб-omp (argv/env СВОЕГО exec): запись лаунчера обязана быть
# равна ему байт в байт (те же массивы — А-918), а не второй реконструкцией.
SEXC=$(jq -r '.session_exec' "$SRC_JSON")
ZSEXC="$ZONE_EXPECT/$SEXC"
PSEXC="$H.state/dev-harness-projects/$PID_EXPECT/$SEXC"
envline() { sed -n "s/^$2=//p" "$1" | head -1; }
# b12: факты основной сессии — в $ZONE/session-exec (формула 028), перезаписаны СТАРТОМ
launch dev2 dev
ok=0
if [ -s "$WORK/dev2.argv" ]; then
  [ "$(cat "$ZSEXC/argv" 2>/dev/null)" = "$(cat "$WORK/dev2.argv")" ] \
    && [ "$(envline "$ZSEXC/env" HOME)" = "$(envval dev2 HOME)" ] \
    && [ "$(envline "$ZSEXC/env" PWD)" = "$(envval dev2 PWD)" ] \
    && [ "$(jq -r .rezhim "$ZSEXC/meta" 2>/dev/null)" = main ] \
    && [ "$(jq -r 'keys_unsorted|sort|join(",")' "$ZSEXC/meta" 2>/dev/null)" = "pid,projectId,rezhim,rol,start" ] && ok=1
fi
v b12-fakty-osnovnoj "$ok" "запись фактов основной ≠ наблюдению стаб-omp: $ZSEXC"
# b13: факты сессии проекта — в $PSTATE/session-exec (формула 055), meta несёт projectId
launch proj3 proj
ok=0
if [ -s "$WORK/proj3.argv" ]; then
  [ "$(cat "$PSEXC/argv" 2>/dev/null)" = "$(cat "$WORK/proj3.argv")" ] \
    && [ "$(envline "$PSEXC/env" HOME)" = "$(envval proj3 HOME)" ] \
    && [ "$(envline "$PSEXC/env" PWD)" = "$(envval proj3 PWD)" ] \
    && [ "$(jq -r .rezhim "$PSEXC/meta" 2>/dev/null)" = project ] \
    && [ "$(jq -r .projectId "$PSEXC/meta" 2>/dev/null)" = "$PID_EXPECT" ] \
    && [ "$(jq -r 'keys_unsorted|sort|join(",")' "$PSEXC/meta" 2>/dev/null)" = "pid,projectId,rezhim,rol,start" ] && ok=1
fi
v b13-fakty-proekta "$ok" "запись фактов проекта ≠ наблюдению стаб-omp: $PSEXC"
# b14: sev.json — ровно засеянное; sha источника/копии = фактическим байтам на момент старта
why=""
ok=0
if [ -s "$WORK/proj3.argv" ] && [ -s "$PSEXC/sev.json" ]; then
  PA3="$(envval proj3 HOME)/.omp/profiles/dev/agent"
  [ "$(jq -r 'keys|length' "$PSEXC/sev.json")" = "${#SEV[@]}" ] || why="$why перечень записи ≠ перечню сева;"
  for f in "${SEV[@]}"; do
    [ "$(jq -r --arg f "$f" '.[$f]["sha-istochnik"]' "$PSEXC/sev.json")" = "$(sha256sum < "$ZA/$f" | cut -c1-64)" ] \
      || why="$why $f sha-istochnik ≠ байтам зоны dev;"
    [ "$(jq -r --arg f "$f" '.[$f]["sha-kopija"]' "$PSEXC/sev.json")" = "$(sha256sum < "$PA3/$f" | cut -c1-64)" ] \
      || why="$why $f sha-kopija ≠ байтам дома проекта;"
  done
  [ -z "$why" ] && ok=1
fi
v b14-fakty-sev "$ok" "запись сева sev.json лжёт о байтах:$why"
# b15: каждый старт ПЕРЕЗАПИСЫВАЕТ факты (дрейфа между стартами нет) — хвост различает старты
launch_t() { # $1 имя; $2 сообщение хвоста — workshop <флаги> <репо> -- <MSG>
  local n=$1 msg=$2
  rm -f "$WORK/$n.calls" "$WORK/$n.argv" "$WORK/$n.env"
  RC=0
  ( cd "$WORK" && env PATH="$SHIMDIR:$PATH" HOME="$H" XDG_STATE_HOME="$H.state" \
    HARNESS_PROJECT_LAYER_ROOT="$LAYER" ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key \
    METERING_PROXY_TOKEN=toy-token METERING_PROXY_URL=http://toy.invalid:1 \
    SHIM_CALLS="$WORK/$n.calls" SHIM_ARGV="$WORK/$n.argv" SHIM_ENV="$WORK/$n.env" \
    bash "$INSTALL/workshop" "$REPO" -- "$msg" > "$WORK/$n.out" 2> "$WORK/$n.err" ) || RC=$?
}
launch_t projm1 soobshchenie-odno
launch_t projm2 soobshchenie-dva
ok=0
if [ -s "$WORK/projm1.argv" ] && [ -s "$WORK/projm2.argv" ]; then
  [ "$(cat "$PSEXC/argv" 2>/dev/null)" = "$(cat "$WORK/projm2.argv")" ] \
    && [ "$(cat "$PSEXC/argv")" != "$(cat "$WORK/projm1.argv")" ] \
    && [ "$(envline "$PSEXC/env" HOME)" = "$(envval projm2 HOME)" ] && ok=1
fi
v b15-fakty-povtor "$ok" "повторный старт не перезаписал факты под второй запуск: $PSEXC/argv"
# b16: факты — вне дерева проекта (Граница-7 054): опись всех путей до/после равна
R3="$WORK/repo-fakty"; cp -R "$REPO" "$R3"; rm -rf -- "$R3/session-exec"
inv() { find "$1" -mindepth 1 -printf '%y %P\n' 2>/dev/null | LC_ALL=C sort; }
INV1=$(inv "$R3")
launch r3 "$R3"
ok=0
if [ "$(launch_n r3)" = 1 ]; then
  [ "$(inv "$R3")" = "$INV1" ] && ok=1
fi
v b16-fakty-vne-dereva "$ok" "дерево проекта изменилось стартом лаунчера (факты обязаны быть в PSTATE, не в дереве)"
# ── 125-А1 (арбитраж 1): решения 4–6 — белый список env, граница места, атомарность, проба, стык ──
launch2() { # $1 имя; $2 = dev|proj|<путь репо>; далее — флаги; окружение launch + синтетический секрет
  local n=$1 mode=$2; shift 2
  local tgt=()
  case "$mode" in dev) ;; proj) tgt=("$REPO") ;; *) tgt=("$mode") ;; esac
  rm -f "$WORK/$n.calls" "$WORK/$n.argv" "$WORK/$n.env"
  RC=0
  ( cd "$WORK" && env PATH="$SHIMDIR:$PATH" HOME="$H" XDG_STATE_HOME="$H.state" \
    HARNESS_PROJECT_LAYER_ROOT="$LAYER" ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key \
    METERING_PROXY_TOKEN=toy-token METERING_PROXY_URL=http://toy.invalid:1 \
    S125_SYNTHETIC_SECRET="$SECR" \
    SHIM_CALLS="$WORK/$n.calls" SHIM_ARGV="$WORK/$n.argv" SHIM_ENV="$WORK/$n.env" \
    bash "$INSTALL/workshop" "$@" "${tgt[@]}" > "$WORK/$n.out" 2> "$WORK/$n.err" ) || RC=$?
}
SECR="syn-$(rnd 24)"
launch2 s4 dev
launch2 s5 proj
why=""
for d in "$ZSEXC" "$PSEXC"; do
  dr=$(readlink -f -- "$d" 2>/dev/null) || dr=$d
  if [ ! -f "$dr/env" ]; then why="$why $d/env нет;"; continue; fi
  [ "$(wc -l < "$dr/env")" = 2 ] || why="$why $d/env не ровно две строки;"
  [ "$(cut -d= -f1 "$dr/env" | LC_ALL=C sort | tr '\n' ' ')" = "HOME PWD " ] || why="$why $d/env ключи не HOME/PWD;"
  for f in argv env meta sev.json; do
    if [ -e "$dr/$f" ] && grep -qF -- "$SECR" "$dr/$f"; then why="$why $d/$f несёт секрет;"; fi
  done
  for f in "$dr"/*; do
    case "$f" in */argv|*/env|*/meta|*/sev.json) ;; *) why="$why $d лишний файл ${f##*/};" ;; esac
  done
done
for n in s4 s5; do
  grep -qF -- "$SECR" "$WORK/$n.out" "$WORK/$n.err" && why="$why вывод $n несёт секрет;"
done
v b17-env-belyj-spisok "$([ -z "$why" ] && [ -s "$WORK/s4.argv" ] && [ -s "$WORK/s5.argv" ] && echo 1 || echo 0)" "env-факт не белый список HOME/PWD или секрет в фактах/выводе:$why"
# b18: подготовленная ссылка на каноническом месте не уводит запись в дерево проекта/зону dev
R4="$WORK/repo-ssylka"; rm -rf -- "$R4"; cp -R "$REPO" "$R4"
mkdir -p "$R4/.harness/fakty"
printf 'poddelka-%s\n' "$(rnd 8)" > "$R4/.harness/fakty/argv"
FAKE1=$(sha256sum < "$R4/.harness/fakty/argv" | cut -c1-64)
P4="$H.state/dev-harness-projects/$PID_EXPECT"
ok1=0; ok2=0
rm -rf -- "$P4/$SEXC"
ln -s "$R4/.harness/fakty" "$P4/$SEXC"
launch r4 "$R4"
if [ -s "$WORK/r4.argv" ]; then
  dr=$(readlink -f -- "$P4/$SEXC" 2>/dev/null)
  [ "$(cat "$dr/argv" 2>/dev/null)" = "$(cat "$WORK/r4.argv")" ] \
    && [ "$(sha256sum < "$R4/.harness/fakty/argv" | cut -c1-64)" = "$FAKE1" ] \
    && [ ! -e "$R4/.harness/fakty/env" ] && ok1=1
fi
ZA_F=$(find "$ZA" -type f | LC_ALL=C sort)
rm -rf -- "$P4/$SEXC"
ln -s "$ZA" "$P4/$SEXC"
launch r5 "$R4"
if [ -s "$WORK/r5.argv" ]; then
  dr=$(readlink -f -- "$P4/$SEXC" 2>/dev/null)
  [ "$(find "$ZA" -type f | LC_ALL=C sort)" = "$ZA_F" ] \
    && [ "$(cat "$dr/argv" 2>/dev/null)" = "$(cat "$WORK/r5.argv")" ] && ok2=1
fi
v b18-fakty-ne-cherez-ssylku "$([ "$ok1" = 1 ] && [ "$ok2" = 1 ] && echo 1 || echo 0)" "подготовленная ссылка на session-exec увела запись фактов в дерево проекта/зону dev"
# b19: повторный старт заменяет комплект ЦЕЛИКОМ — argv/env/sev.json от второго старта
zap; SNAP3=$(snap)
launch_t projm3 soobshchenie-tri
why=""
if [ -s "$WORK/projm3.argv" ]; then
  dr=$(readlink -f -- "$PSEXC" 2>/dev/null)
  [ "$(cat "$dr/argv" 2>/dev/null)" = "$(cat "$WORK/projm3.argv")" ] || why="$why argv не от последнего старта;"
  [ "$(envline "$dr/env" HOME)" = "$(envval projm3 HOME)" ] || why="$why env HOME не от последнего старта;"
  [ "$(jq -r .projectId "$dr/meta" 2>/dev/null)" = "$PID_EXPECT" ] || why="$why meta projectId не тот;"
  while read -r f s; do
    [ "$(jq -r --arg f "$f" '.[$f]["sha-istochnik"]' "$dr/sev.json" 2>/dev/null)" = "$s" ] \
      || why="$why sev.json $f не от последнего старта;"
  done <<< "$SNAP3"
else why="сессия не дошла до omp (rc $RC)"; fi
v b19-fakty-povtor-komplekt "$([ -z "$why" ] && echo 1 || echo 0)" "повторный старт не заменил комплект фактов целиком:$why"
# b20: атомарная публикация комплекта — ссылка-поколение в PSTATE, ровно 4 файла,
# хвостов публикации нет, прерванная публикация оставляет прежний целый комплект
why=""
dr=$(readlink -f -- "$PSEXC" 2>/dev/null)
[ -L "$PSEXC" ] || why="$why каноническое имя не ссылка;"
[ -L "$ZSEXC" ] || why="$why основная: каноническое имя не ссылка;"
case "$dr" in "$H.state/dev-harness-projects/$PID_EXPECT"/*) ;; *) why="$why поколение вне PSTATE: $dr;" ;; esac
[ "$(ls -A "$dr" 2>/dev/null | LC_ALL=C sort | tr '\n' ' ')" = "argv env meta sev.json " ] || why="$why комплект проекта не ровно 4 файла;"
[ "$(ls -A "$(readlink -f -- "$ZSEXC")" 2>/dev/null | LC_ALL=C sort | tr '\n' ' ')" = "argv env meta " ] || why="$why комплект основной не ровно 3 файла;"
nz=0; for x in "$H.state/dev-harness-projects/$PID_EXPECT"/.$SEXC.new.*; do [ -d "$x" ] && nz=$((nz+1)); done
[ "$nz" = 1 ] || why="$why хранилищ поколений не одно ($nz);"
ls -d "$H.state/dev-harness-projects/$PID_EXPECT"/.$SEXC.old.* "$H.state/dev-harness-projects/$PID_EXPECT"/.$SEXC.link.* >/dev/null 2>&1 && why="$why хвосты публикации;"
S_ARGV=$(cat "$dr/argv" 2>/dev/null)
junk="$H.state/dev-harness-projects/$PID_EXPECT/.$SEXC.new.zZZmusor"
mkdir -p "$junk"; printf 'musor\n' > "$junk/argv"
[ "$(readlink -f -- "$PSEXC")" = "$dr" ] && [ "$(cat "$PSEXC/argv")" = "$S_ARGV" ] || why="$why прерванная публикация сменила канонический комплект;"
rm -rf -- "$junk"
v b20-fakty-atomarno "$([ -z "$why" ] && echo 1 || echo 0)" "публикация комплекта фактов не атомарна:$why"
# b21: проба не создаёт и не обновляет факты (И-9.4)
F1=$(cat "$PSEXC/argv" 2>/dev/null); F2=$(cat "$PSEXC/env" 2>/dev/null)
F3=$(cat "$PSEXC/meta" 2>/dev/null); F4=$(cat "$PSEXC/sev.json" 2>/dev/null)
Z1=$(cat "$ZSEXC/argv" 2>/dev/null)
rm -f "$WORK/pr.calls" "$WORK/pr.argv" "$WORK/pr.env"
RC=0
( cd "$WORK" && env PATH="$SHIMDIR:$PATH" HOME="$H" XDG_STATE_HOME="$H.state" \
  HARNESS_PROJECT_LAYER_ROOT="$LAYER" ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key \
  METERING_PROXY_TOKEN=toy-token METERING_PROXY_URL=http://toy.invalid:1 \
  SHIM_CALLS="$WORK/pr.calls" SHIM_ARGV="$WORK/pr.argv" SHIM_ENV="$WORK/pr.env" \
  bash "$INSTALL/workshop" --probe "$REPO" > "$WORK/pr.out" 2> "$WORK/pr.err" ) || RC=$?
ok=0
if [ -n "$F1" ] && [ "$RC" = 0 ]; then
  [ "$(cat "$PSEXC/argv" 2>/dev/null)" = "$F1" ] && [ "$(cat "$PSEXC/env" 2>/dev/null)" = "$F2" ] \
    && [ "$(cat "$PSEXC/meta" 2>/dev/null)" = "$F3" ] && [ "$(cat "$PSEXC/sev.json" 2>/dev/null)" = "$F4" ] \
    && [ "$(cat "$ZSEXC/argv" 2>/dev/null)" = "$Z1" ] && ok=1
fi
v b21-probe-fakty-net "$ok" "проба создала/обновила факты (rc $RC)"
# b22: нормальный путь (решения 6/7-д): connect_project.sh → workshop → запись → --avto,
# один мир; дверь — честная модель, лаунчер и сверка — текущие субъекты прогона
# нормальный путь начинается с основной сессии orch-loop (`workshop --yolo`, 002)
launch m9 dev --yolo
rm -f "$WORK/door.calls" "$WORK/door.argv" "$WORK/door.env"
RC=0
( cd "$WORK" && env PATH="$SHIMDIR:$PATH" HOME="$H" XDG_STATE_HOME="$H.state" \
  HARNESS_PROJECT_LAYER_ROOT="$LAYER" ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key \
  METERING_PROXY_TOKEN=toy-token METERING_PROXY_URL=http://toy.invalid:1 \
  CONNECT_HERE="$INSTALL" \
  SHIM_CALLS="$WORK/door.calls" SHIM_ARGV="$WORK/door.argv" SHIM_ENV="$WORK/door.env" \
  bash "$B_DIR/model/connect_project.sh" "$REPO" > "$WORK/door.out" 2> "$WORK/door.err" ) || RC=$?
JRC=0; JOUT=$(env HARNESS_SESSION_HOME="$ZONE_EXPECT" XDG_STATE_HOME="$H.state" HOME="$H" \
  HARNESS_PROJECT_LAYER_ROOT="$LAYER" bash "$CHK_JUDGE" --avto "$REPO" 2>/dev/null) || JRC=$?
ok=0
if [ "$RC" = 0 ] && [ -s "$WORK/door.argv" ] && [ "$JRC" = 0 ] && [ -z "$JOUT" ]; then ok=1; fi
v b22-styk-dver-avto "$ok" "нормальный путь дверь→workshop→запись→--avto: rc=$RC avto rc=$JRC «$(printf '%s' "$JOUT" | tr '\n' '|')» $(sed -n '1,2p' "$WORK/door.err" | tr '\n' '|')"
exit 0
