#!/usr/bin/env bash
# КРАСНАЯ БАТАРЕЯ 136 «доводка сессий проектов» (125-б; слово владельца
# 2026-10-22 ~11:10 UTC «да, делаем так», docs/owner/2026-10-22-poryadok-slota-i-125b.md).
#
# ШЕСТЬ БОЛЕЙ сессии проекта (замер сессии Complior-back, её .harness/NABLIUDENIA.md 21–22.10):
#   НАБЛ-П3/П11 — write-guard Н-85 запрещает запись в чекаут проекта сессии и её субагентам;
#   НАБЛ-П12    — write agent://<id> из сессии проекта запрещён;
#   НАБЛ-П10    — precision-гейт (нога «в», паритет CI) красен в проектном режиме
#                 без ручного config/ci_parity_exceptions.txt (~40 FAIL на команды CI проекта);
#   НАБЛ-П17    — brief make_task пуст при заданных contextPack.rows (roles без orchestrator);
#   НАБЛ-П5     — make_task --kind brief отказывает «нет свидетельства модели», трассу вписывают руками;
#   НАБЛ-П6     — connect_project.sh поднимает сессию БЕЗ задания (замер: 8 ч простоя 22.10).
#
# СУБЪЕКТЫ: scripts/connect_project.sh, scripts/make_task.sh, scripts/verify_ci_parity.sh
# (дерево | model/ | stabs/<имя>/); страж .omp/extensions/path-guard.ts — РЕАЛЬНЫЙ, не меняется
# (грамматика пина 032/066 уже принимает любой живой linked worktree: git-оракул судит живость,
# не принадлежность dev-harness). Привязка стаб → клетки — ТОЛЬКО source.json:.stab_vhod (Н-39).
#
# Дверь исполняется из песочницы $SB (копия файла двери + двойник workshop рядом): дверь
# дословно разрешает(exec) $HERE/workshop — двойник пишет по одному аргументу в строку в
# $W/args.txt и выходит 7; сообщение сессии = строки после литеральной строки «--».
#
# РЕЖИМЫ:
#   без ключей  — субъекты из дерева ветки: боли живы → rc 1;
#   --model     — честные модели model/ (дерево + точки правок контракта) → rc 0;
#   --stabs     — каждый стаб гасит свой субъект, его клетки ОБЯЗАНЫ покраснеть;
#                 rc 0 «стабов 9, привязок 12, непойманных 0».
#
# Миры — /tmp/dev-harness-verify/sessii-136-<клетка>/** (оракулы в памяти, правило 8);
# чекауты проектов — /tmp/dev-harness-fakehome-136/<клетка>/** ВНЕ scratch-allowlist Н-85
# (иначе боль П3 немотивированно зелёная: allowlist прикрыл бы её — прецедент pg066).
set -uo pipefail
B="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$B/../../.." && pwd)"
GUARD="$ROOT/.omp/extensions/path-guard.ts"
MODE="plain"; [ "${1:-}" = "--model" ] && MODE="model"; [ "${1:-}" = "--stabs" ] && MODE="stab"
[ -f "$GUARD" ] || { printf 'субъект отсутствует: %s\n' "$GUARD" >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'нет node\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'нет jq\n'   >&2; exit 2; }

subj() { case "$MODE" in
    model) printf '%s' "$B/model/$2" ;;
    stab)  printf '%s' "${STAB_DIR:-/NETU-STABA}/$2" ;;
    *)     printf '%s' "$ROOT/$1" ;; esac; }
DOOR="$(subj scripts/connect_project.sh connect_project.sh)"
MKT="$(subj scripts/make_task.sh make_task.sh)"
PAR="$(subj scripts/verify_ci_parity.sh verify_ci_parity.sh)"

W=""; FH=""; SEED=""
mk_mir() { # mk_mir <слуг> [next]
  local slug="$1"
  W="/tmp/dev-harness-verify/sessii-136-$slug"
  FH="/tmp/dev-harness-fakehome-136/$slug"
  rm -rf "$W" "$FH"; mkdir -p "$W" "$FH/projects" "$FH/dev-harness-projects/toy-proj/wt" "$FH/seed"
  SEED="$FH/seed/toy-proj"
  git init -q "$SEED"
  git -C "$SEED" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
  mkdir -p "$SEED/.github/workflows" "$SEED/docs" "$SEED/.harness/contracts" "$SEED/.harness/verdicts" "$SEED/.harness/registry" "$SEED/.harness/fixtures"
  printf 'name: ci\non: [push]\njobs:\n  b:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm run dev\n' > "$SEED/.github/workflows/ci.yml"
  printf '{"name":"toy","scripts":{"build":"echo b"}}\n' > "$SEED/package.json"
  printf '# Архитектура\nСлои: api, worker, pg.\n' > "$SEED/docs/ARCHITECTURE.md"
  printf '# Стандарт\nИменование: kebab-case.\n' > "$SEED/docs/CODING-STANDARDS.md"
  jq -n '{schemaVersion:1,repoId:"toy-proj",language:"typescript",
    workflowPaths:{contracts:".harness/contracts",verdicts:".harness/verdicts",
      registry:".harness/registry",fixtures:".harness/fixtures",state:".harness"},
    git:{canonicalRemote:"https://github.com/x/toy-proj.git"},
    contextPack:{rows:[
      {kind:"map",path:"docs/ARCHITECTURE.md",roles:"architect,implementer,reviewer,adversary",mandatory:true,why:"карта архитектуры проекта"},
      {kind:"rules",path:"docs/CODING-STANDARDS.md",roles:"architect,implementer,reviewer,adversary",mandatory:true,why:"стандарт проекта"}]},
    projectLayer:{version:"v1",profilePath:".harness/project-layer.json"}}' > "$SEED/harness.project.json"
  printf '## ГДЕ МЫ\n\n- предмет не выбран.\n' > "$SEED/.harness/HANDOFF.md"
  printf 'id\tpora\tdepend\tsource\tdoc\tdesc\n' > "$SEED/.harness/registry/plan.tsv"
  printf '# 777 toy\n\n## Существующее\n- toy-контракт клетки c4.\n\nЗОНА implementer: docs/ARCHITECTURE.md\n' > "$SEED/.harness/contracts/777-toy.md"
  [ "${2:-}" = "next" ] && printf 'Задание: релиз 1.2, прогнать CI проекта, доложить.\n' > "$SEED/.harness/NEXT_TASK.md"
  git -C "$SEED" add -A; git -C "$SEED" -c user.name=t -c user.email=t@t commit -q -m toy
  # дом секретов (дверь отказывает без него — Adv125): несекретные значения
  mkdir -p "$FH/.config/dev-harness"
  printf 'ZAI_API_KEY=za-dummy\nMINIMAX_API_KEY=mm-dummy\nMETERING_PROXY_URL=http://u\nMETERING_PROXY_TOKEN=mt-dummy\n' > "$FH/.config/dev-harness/secrets.env"
}
run_dver() { # копия двери в песочницу + двойник workshop; сообщение — после «--»
  local SB="$W/sb"; mkdir -p "$SB/scripts"
  cp "$DOOR" "$SB/scripts/connect_project.sh"
  printf '#!/usr/bin/env bash\nfor a in "$@"; do printf "%%s\\n" "$a"; done > "%s"\nexit 7\n' "$W/args.txt" > "$SB/workshop"
  chmod +x "$SB/workshop"
  env HOME="$FH" HARNESS_PROJECTS_DIR="$FH/projects" \
    S136_PSTATE_BASE="$FH/dev-harness-projects" \
    bash "$SB/scripts/connect_project.sh" "${1:-$SEED}" >"$W/dvor.out" 2>"$W/dvor.err" || true
}
dver_msg() { awk 'f{print} $0=="--"{f=1}' "$W/args.txt" 2>/dev/null; }
# сцена субъекта make_task: файл субъекта (дерево|модель|стаб) дословно +
# НЕменяемые контрактом 136 спутники дерева (profile_resolver.sh, next_id.sh —
# сиблинги по $(dirname $0), в model/ их нет)
mkt_dir() {
  local d="$W/mktbin"; mkdir -p "$d"
  cp "$MKT" "$d/make_task.sh"
  cp "$ROOT/scripts/profile_resolver.sh" "$ROOT/scripts/next_id.sh" "$d/"
  printf '%s' "$d/make_task.sh"
}
judge() { HOME="$FH" node "$GUARD" --judge "$1"; }
epin()  { HOME="$FH" node "$GUARD" --extract-pin "$1" 2>/dev/null; }

k_a1() { mk_mir a1-p6-hvost next; run_dver
  local msg; msg="$(dver_msg)"
  [ -n "$msg" ] && printf '%s\n' "$msg" | grep -Fq 'релиз 1.2'; }
k_a2() { mk_mir a2-p6-brief-defolt; run_dver
  local msg; msg="$(dver_msg)"
  [ -n "$msg" ] && printf '%s\n' "$msg" | grep -Fq 'HANDOFF'; }
k_a3() { mk_mir a3-p3-pin; run_dver
  local msg wt; msg="$(dver_msg)"; wt="$(printf '%s\n' "$msg" | sed -n 's/^WORKTREE=//p' | head -1)"
  [ -n "$wt" ] \
    && case "$wt" in "$FH"/dev-harness-projects/*) : ;; *) false ;; esac \
    && [ "${wt#"$FH"/projects/}" = "$wt" ] \
    && git -C "$SEED" worktree list --porcelain | grep -Fqx "worktree $wt"; }
k_a4() { mk_mir a4-p3-zapis; run_dver
  local msg wt pin; msg="$(dver_msg)"; wt="$(printf '%s\n' "$msg" | sed -n 's/^WORKTREE=//p' | head -1)"
  [ -n "$wt" ] || return 1
  pin="$(epin "$msg" | jq -r '.worktree // empty')"
  [ -n "$pin" ] && [ "$pin" = "$wt" ] \
    && [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"$wt/f.txt\"},\"worktree\":\"$wt\"}" | jq -r .decision)" = "pass" ]; }
k_a5() { mk_mir a5-p12-agent; run_dver
  local wt; wt="$(dver_msg | sed -n 's/^WORKTREE=//p' | head -1)"
  [ -n "$wt" ] \
    && [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"agent://Rev1\"},\"worktree\":\"$wt\"}" | jq -r .decision)" = "pass" ]; }
k_a6() { mk_mir a6-p11-subagent-pin; run_dver
  local P para wt
  P="$FH/dev-harness-projects/toy-proj/bin/subagent-pin.sh"
  [ -x "$P" ] || return 1
  para="$(env HOME="$FH" S136_PSTATE_BASE="$FH/dev-harness-projects" bash "$P" 777 demo)" || return 1
  wt="$(printf '%s\n' "$para" | sed -n 's/^WORKTREE=//p' | head -1)"
  [ -n "$wt" ] && [ "$(epin "$para" | jq -r '.worktree // empty')" = "$wt" ] \
    && git -C "$SEED" worktree list --porcelain | grep -Fqx "worktree $wt" \
    && [ "$(judge "{\"tool\":\"bash\",\"args\":{\"command\":\"printf x > f.txt\",\"cwd\":\"$wt\"},\"worktree\":\"$wt\"}" | jq -r .decision)" = "pass" ]; }
k_a7() { mk_mir a7-granica; run_dver
  [ "$(judge "{\"tool\":\"write\",\"args\":{\"path\":\"$SEED/f.txt\"},\"worktree\":null,\"actual\":\"$SEED\"}" | jq -r .decision)" = "block" ]; }
k_b1() { mk_mir b1-povtor; run_dver
  local K tr ex tr1 ex1 hd1
  K="$SEED"; tr="$K/.harness/registry/trace.tsv"; ex="$K/.harness/registry/ci_parity_exceptions.txt"
  [ -f "$tr" ] && [ -f "$ex" ] || return 1
  tr1="$(cat "$tr")"; ex1="$(cat "$ex")"
  printf '## ГДЕ МЫ\n\n- правка владельца между входами двери.\n' > "$K/.harness/HANDOFF.md"
  hd1="$(cat "$K/.harness/HANDOFF.md")"
  run_dver
  [ "$(cat "$tr")" = "$tr1" ] && [ "$(cat "$ex")" = "$ex1" ] \
    && [ "$(cat "$K/.harness/HANDOFF.md")" = "$hd1" ] \
    && [ "$(git -C "$K" worktree list --porcelain | grep -c 'wip-136-demo')" = "1" ]; }
k_b2() { mk_mir b2-p10-raskladka; run_dver
  local K; K="$SEED"
  [ -f "$K/.harness/registry/ci_parity_exceptions.txt" ] && [ -f "$K/.harness/registry/trace.tsv" ] \
    && [ ! -e "$K/config" ]; }
mkt_brief() {
  local mb; mb="$(mkt_dir)"
  env HOME="$FH" HARNESS_PROJECT_LAYER_ROOT="$SEED" \
    bash "$mb" --repo "$SEED" --role orchestrator --kind brief "$@" 2>"$W/mkt.err"
}
k_c1() { mk_mir c1-p17-map; run_dver; mkt_brief | grep -Fqx 'MAP: docs/ARCHITECTURE.md :: карта архитектуры проекта'; }
k_c2() { mk_mir c2-p17-rules; run_dver; mkt_brief | grep -Fqx 'RULES: docs/CODING-STANDARDS.md'; }
k_c3() { mk_mir c3-p5-trassa; run_dver
  local out; out="$(mkt_brief)" \
    && printf '%s\n' "$out" | grep -Fq 'TRACE: role=orchestrator model=zai/glm-5.3 fallback=allowed'; }
k_c4() { mk_mir c4-kontrol; run_dver
  local out rc
  # трасса — оракул клетки (не дверь): судья critic + автор architect разных семей
  printf 'orchestrator\tzai/glm-5.3\tallowed\narchitect\tminimax/m1\tallowed\ncritic\tzai/glm-5.3\tallowed\n' > "$SEED/.harness/registry/trace.tsv"
  local mb; mb="$(mkt_dir)"
  out="$(env HOME="$FH" HARNESS_PROJECT_LAYER_ROOT="$SEED" \
    bash "$mb" --repo "$SEED" --role critic --kind task --contract 777 \
      --model-trace "$SEED/.harness/registry/trace.tsv" 2>"$W/mkt.err")"; rc=$?
  [ "$rc" -eq 0 ] && [ -n "$out" ] && ! printf '%s\n' "$out" | grep -Fq 'MAP: docs/ARCHITECTURE.md'; }
k_c5() { mk_mir c5-jeksplizit; run_dver
  local out; printf 'orchestrator\tanthropic/opus\tallowed\n' > "$W/explicit.tsv"
  out="$(mkt_brief --model-trace "$W/explicit.tsv")" \
    && printf '%s\n' "$out" | grep -Fq 'TRACE: role=orchestrator model=anthropic/opus fallback=allowed'; }
k_d1() { mk_mir d1-p10; run_dver
  local K; K="$SEED"
  printf 'build = скрипт сборки тоя вне CI проекта, объявлён по причине клетки d1\nкоманда: npm run dev = команда релизного CI проекта, приёмкой пакета не является совсем\n' > "$K/.harness/registry/ci_parity_exceptions.txt"
  env HOME="$FH" bash "$PAR" "$K" >"$W/par.out" 2>&1; }
k_d2() { mk_mir d2-kontrol-dom
  env HOME="$FH" bash "$PAR" "$ROOT" >"$W/par2.out" 2>&1; }
k_d3() { mk_mir d3-kontrol; run_dver
  local K rc; K="$SEED"
  # ПУСТОЙ перечень (проект ничего не объявил): честный гейт — rc 1 FAIL на
  # первой непокрытой команде CI; стаб «всё зелено» (проглатывание bad) даёт rc 0.
  : > "$K/.harness/registry/ci_parity_exceptions.txt"
  env HOME="$FH" bash "$PAR" "$K" >"$W/par3.out" 2>&1; rc=$?
  [ "$rc" -ne 0 ] && grep -qE 'FAIL|NOT_IMPLEMENTED' "$W/par3.out"; }

ORDER="a1-p6-hvost a2-p6-brief-defolt a3-p3-pin-v-soobshchenii a4-p3-zapis a5-p12-agent a6-p11-subagent-pin a7-granica-unpinned b1-povtor b2-p10-raskladka c1-p17-map c2-p17-rules c3-p5-trassa-defolt c4-kontrol-filtr c5-kontrol-jeksplizit d1-p10-isklyuchenie d2-kontrol-dom d3-kontrol-koren"
run_cell() { case "$1" in
  a1-p6-hvost) k_a1 ;; a2-p6-brief-defolt) k_a2 ;; a3-p3-pin-v-soobshchenii) k_a3 ;;
  a4-p3-zapis) k_a4 ;; a5-p12-agent) k_a5 ;; a6-p11-subagent-pin) k_a6 ;;
  a7-granica-unpinned) k_a7 ;; b1-povtor) k_b1 ;; b2-p10-raskladka) k_b2 ;;
  c1-p17-map) k_c1 ;; c2-p17-rules) k_c2 ;; c3-p5-trassa-defolt) k_c3 ;;
  c4-kontrol-filtr) k_c4 ;; c5-kontrol-jeksplizit) k_c5 ;;
  d1-p10-isklyuchenie) k_d1 ;; d2-kontrol-dom) k_d2 ;; d3-kontrol-koren) k_d3 ;; esac; }

case "$MODE" in
  plain|model)
    gr=0 kr=0 spisok=""
    for c in $ORDER; do
      if run_cell "$c"; then gr=$((gr+1)); else kr=$((kr+1)); spisok="$spisok $c"; fi
    done
    printf 'sessii_136: клеток %d, зелёных %d, красных %d\n' "$(printf '%s\n' $ORDER | wc -l | tr -d ' ')" "$gr" "$kr"
    [ -z "$spisok" ] || printf 'красные:%s\n' "$spisok" >&2
    if [ "$MODE" = "model" ]; then [ "$kr" -eq 0 ] || { printf 'модель не зелёная\n' >&2; exit 2; }; fi
    [ "$kr" -eq 0 ] || exit 1; exit 0 ;;
  stab)
    # предпроверка зелёности на ЧЕСТНОЙ модели (стабы гоняются поверх зелёного)
    DOOR="$B/model/connect_project.sh"; MKT="$B/model/make_task.sh"; PAR="$B/model/verify_ci_parity.sh"
    grm=0 krm=0 sp=""
    for c in $ORDER; do
      if run_cell "$c"; then grm=$((grm+1)); else krm=$((krm+1)); sp="$sp $c"; fi
    done
    [ "$krm" -eq 0 ] || { printf 'модель не зелёная, стабы не гоняются:%s\n' "$sp" >&2; exit 2; }
    nstab=0 npriv=0 nepon=0
    for d in "$B"/stabs/*/; do
      s="$(basename "$d")"; STAB_DIR="$d"
      DOOR="$d/connect_project.sh"; [ -f "$DOOR" ] || DOOR="$B/model/connect_project.sh"
      MKT="$d/make_task.sh";   [ -f "$MKT" ]   || MKT="$B/model/make_task.sh"
      PAR="$d/verify_ci_parity.sh"; [ -f "$PAR" ] || PAR="$B/model/verify_ci_parity.sh"
      cells="$(jq -r --arg s "$s" '.stab_vhod[$s][]' "$B/source.json")"
      [ -n "$cells" ] || { printf 'СТАБ БЕЗ ПРИВЯЗОК: %s\n' "$s" >&2; exit 2; }
      nstab=$((nstab+1))
      for c in $cells; do
        npriv=$((npriv+1))
        if run_cell "$c"; then nepon=$((nepon+1)); printf 'НЕ ПОЙМАН %s @ %s\n' "$s" "$c" >&2; fi
      done
    done
    nk="$(jq '[.stab_vhod[]|length]|add' "$B/source.json")"
    nf="$(ls -1 "$B"/stabs/ | wc -l | tr -d ' ')"
    nkeys="$(jq '.stab_vhod|keys|length' "$B/source.json")"
    [ "$nf" = "$nkeys" ] || { printf 'расхождение: stabs/ %s != stab_vhod %s\n' "$nf" "$nkeys" >&2; exit 2; }
    [ "$nk" = "$npriv" ] || { printf 'расхождение привязок: source %s != прогон %s\n' "$nk" "$npriv" >&2; exit 2; }
    printf 'sessii_136 --stabs: стабов %s, привязок %s, непойманных %d\n' "$nf" "$nk" "$nepon"
    [ "$nepon" -eq 0 ] || exit 1; exit 0 ;;
esac
