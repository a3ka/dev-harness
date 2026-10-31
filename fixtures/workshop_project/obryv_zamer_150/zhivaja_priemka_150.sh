#!/usr/bin/env bash
# Живая приёмка 7/8 контракта 150 (prichinnyy-zamer-obryva) — ИСПОЛНЯЕМАЯ
# процедура с отказом (арбитраж 150, правка П2). Печать значения без
# сравнения ничего не доказывает: каждый шаг — ЛОГИЧЕСКОЕ сравнение
# (jq -e / grep -q / awk-тест), ошибка gh/API/чтения/разбора всплывает
# собственным кодом (set -euo pipefail; подстановки без пайпов), пустое
# «успешное» значение недопустимо.
#
#   zhivaja_priemka_150.sh krasnyj <repo> <S> <R> <A> <C>  # приёмка 7
#   zhivaja_priemka_150.sh zelenyj <repo> <S> <R> <A>     # приёмка 8
#   zhivaja_priemka_150.sh dlitelnosti <repo> <S> <R1> <R2>  # пункт 9:
#        измерение длительностей job S в двух run — материал ОТЧЁТА
#        ревьюера (порог не назначен: числовой порог overhead — воля
#        владельца; одна пара CI-длительностей не есть причинное
#        доказательство равенства)
#   zhivaja_priemka_150.sh --samoproverka  # подложный gh: исходы всех
#        именованных случаев (закрытие П2 арбитража 150)
#
# repo = репозиторий Complior-mob; S = экран; R = run id; A = attempt;
# C = sha головы run. Коды: 0 — исход подтверждён; 1 — именованный отказ
# (ZP_OTKAZ: <причина>); иные ненулевые — ошибка gh/окружения как есть.
set -euo pipefail

otkaz() { printf 'ZP_OTKAZ: %s\n' "$*" >&2; exit 1; }

# ── общий шаг: РОВНО один целевой job, завершён, conclusion == ожидаемому ──
poisk_joba() { # <repo> <S> <R> <failure|success> → databaseId на stdout
  local repo="$1" S="$2" R="$3" ozh="$4" json n st id
  json="$(gh run view "$R" --repo "$repo" --json jobs)" \
    || otkaz "GH_OTKAZ: gh run view $R (sm. stderr vishe)"
  printf '%s' "$json" | jq -e 'type == "object" and (.jobs | type == "array")' >/dev/null \
    || otkaz "RAZBOR_JSON: gh run view $R dal ne massiv jobs"
  if ! printf '%s' "$json" | jq -e --arg s "$S" --arg ozh "$ozh" '
        ([.jobs[] | select(.name == $s)]) as $c
        | ($c | length == 1) and ($c[0].status == "completed")
          and ($c[0].conclusion == $ozh)' >/dev/null; then
    n="$(printf '%s' "$json" | jq -r --arg s "$S" '[.jobs[] | select(.name == $s)] | length')" \
      || otkaz "RAZBOR_JSON: podschet jobov '$S' v run $R"
    if [ "$n" = "0" ]; then
      otkaz "JOB_NET: ekrannyj job '$S' v run $R ne najden"
    fi
    if [ "$n" != "1" ]; then
      otkaz "JOB_DUBLIR: jobov s imenem '$S' v run $R = $n"
    fi
    st="$(printf '%s' "$json" | jq -r --arg s "$S" \
      '[.jobs[] | select(.name == $s)][0] | "\(.status)/\(.conclusion)"')" \
      || otkaz "RAZBOR_JSON: status/conclusion '$S' v run $R"
    otkaz "KONKLUZIJA: '$S' v run $R = $st (ozhidalos completed/$ozh)"
  fi
  id="$(printf '%s' "$json" | jq -r --arg s "$S" \
    '[.jobs[] | select(.name == $s)][0].databaseId // empty')"
  [ -n "$id" ] && [ "$id" != "null" ] \
    || otkaz "JOB_BEZ_ID: databaseId dlja '$S' v run $R pust"
  printf '%s' "$id"
}

# ── проверка ФАКТИЧЕСКОГО содержимого скачанного артефакта (п.7-в/г) ───────
proverka_soderzhimogo() { # <katalog>
  local d="$1" f pid
  for f in itog.txt sampler.tsv emulator-exit.txt logcat-kolco.txt; do
    [ -s "$d/$f" ] || otkaz "FAJL_NET: $f (obyazatelnyj fajl artefakta)"
  done
  grep -q 'reshenie=publikuem' "$d/itog.txt" \
    || otkaz "ITOG_BEZ_RESHENIJA: net 'reshenie=publikuem' v itog.txt"
  # sampler.tsv: строка данных с ЖИВЫМ emu_pid (PID до обрыва) И непустым
  # cgroup-полем (cg_mem_current) — заголовок доказательством не является
  awk -F'|' '
    !/^#/ && NF == 16 && $2 != "" && $2 != "-" && $8 != "" && $8 != "-" { ok = 1; exit }
    END { exit !ok }' "$d/sampler.tsv" \
    || otkaz "SAMPLER_BEZ_PID_CGROUP: net stroki s emu_pid i cgroup-polem (do obryva)"
  # PID из фиксации завершения обязан наблюдаться живым в таймлайне
  pid="$(sed -n 's/^== qemu PID \([0-9][0-9]*\) ischez iz \/proc .*/\1/p' \
    "$d/emulator-exit.txt" | head -1)"
  [ -n "$pid" ] || otkaz "EXIT_BEZ_PIDA: v emulator-exit.txt net 'qemu PID N ischez iz /proc'"
  awk -F'|' -v p="$pid" '
    !/^#/ && index($2, p) { ok = 1; exit }
    END { exit !ok }' "$d/sampler.tsv" \
    || otkaz "SBOR_BEZ_PID_V_TAJMLAJNE: PID $pid iz emulator-exit ne videl zhivym v sampler.tsv"
  grep -q 'vyhod_status=NE_DOSTUPEN' "$d/emulator-exit.txt" \
    || otkaz "EXIT_BEZ_CHESTNOGO_MARKERA: net vyhod_status=NE_DOSTUPEN"
  grep -q 'logcat -d -t 50' "$d/logcat-kolco.txt" \
    || otkaz "KOLCO_BEZ_MARKERA: net markera 'logcat -d -t 50'"
}

# ── приёмка 7: красный run публикует полный причинный артефакт ─────────────
priemka_krasnyj() { # <repo> <S> <R> <A> <C>
  local repo="$1" S="$2" R="$3" A="$4" C="$5" art d jobid
  [ -n "$repo" ] && [ -n "$S" ] && [ -n "$R" ] && [ -n "$A" ] && [ -n "$C" ] \
    || otkaz "ARGUMENTY: krasnyj <repo> <S> <R> <A> <C>"
  art="zamer-${S}-${C}-${R}-${A}"
  jobid="$(poisk_joba "$repo" "$S" "$R" failure)" || exit 1
  # РОВНО один ТОЧНЫЙ артефакт этого run/attempt/sha/экрана
  local spisok
  spisok="$(gh api "repos/${repo}/actions/runs/${R}/artifacts")" \
    || otkaz "GH_OTKAZ: artifacts API run $R"
  printf '%s' "$spisok" | jq -e --arg n "$art" \
    '(.artifacts | type == "array") and ([.artifacts[]? | select(.name == $n)] | length == 1)' >/dev/null \
    || otkaz "ARTEFAKT_NET: tochnyj artefakt $art otsutstvuet libo dublirovan"
  # скачивание в НОВЫЙ пустой каталог: старое содержимое исключено
  d="$(mktemp -d "${TMPDIR:-/tmp}/zp150-XXXXXX")"
  [ -z "$(ls -A "$d")" ] || otkaz "KATALOG_NE_PUST: $d"
  gh run download "$R" --repo "$repo" -n "$art" -D "$d" \
    || otkaz "SKACHIVANIE_OTKAZ: $art"
  proverka_soderzhimogo "$d"
  echo "ZP_KRASNYJ_OK: run=$R job=$S jobid=$jobid artefakt=$art katalog=$d"
  echo "OBaZATELNO V OTChET REVJu: stroka sampler.tsv s PID (do obryva), blok emulator-exit.txt, marker logcat-kolco.txt"
}

# ── приёмка 8: зелёный run БЕЗ артефактов замера, маркер в логе job ────────
priemka_zelenyj() { # <repo> <S> <R> <A>
  local repo="$1" S="$2" R="$3" A="$4" jobid spisok log
  [ -n "$repo" ] && [ -n "$S" ] && [ -n "$R" ] && [ -n "$A" ] \
    || otkaz "ARGUMENTY: zelenyj <repo> <S> <R> <A>"
  jobid="$(poisk_joba "$repo" "$S" "$R" success)" || exit 1
  # ПОЛНЫЙ список артефактов run: РОВНО НОЛЬ соответствующих (сравнение,
  # ne pechat' chisla); ошибка API ≠ отсутствию — отказ gh всплывает выше
  spisok="$(gh api --paginate "repos/${repo}/actions/runs/${R}/artifacts")" \
    || otkaz "GH_OTKAZ: artifacts API run $R"
  printf '%s' "$spisok" | jq -es --arg p "zamer-${S}-" \
    '[.[].artifacts[]? | select((.name | type == "string") and (.name | startswith($p)))] | length == 0' >/dev/null \
    || otkaz "ARTEFAKT_ZAPRESCHEN: u zeljonogo run $R est' artefakt zamer-${S}-*"
  # логовый маркер — у ИДЕНТИФИЦИРОВАННОГО job
  log="$(gh run view "$R" --repo "$repo" --log --job "$jobid")" \
    || otkaz "GH_OTKAZ: log job $jobid"
  printf '%s\n' "$log" | grep -q 'ne publikuetsja' \
    || otkaz "MARKER_NE_PUBLIKUETSA: v loge sbora net markera 'ne publikuetsja'"
  echo "ZP_ZELENYJ_OK: run=$R job=$S jobid=$jobid artefaktov_zamer=0 marker=est"
}

# ── пункт 9: измерение длительностей (материал отчёта ревью, не порог) ────
izmerit_dlitelnost() { # <repo> <S> <R> <metka>
  local repo="$1" S="$2" R="$3" metka="$4" json st k
  json="$(gh run view "$R" --repo "$repo" --json jobs)" \
    || otkaz "GH_OTKAZ: gh run view $R"
  st="$(printf '%s' "$json" | jq -r --arg s "$S" \
    '[.jobs[] | select(.name == $s)][0]
     | "\(.databaseId) \(.status) \(.conclusion) \(.startedAt) \(.completedAt)"')"
  [ -n "$st" ] && [ "$st" != "null null null null null" ] \
    || otkaz "JOB_NET: '$S' v run $R (dlitelnosti)"
  set -- $st
  local id="$1" status="$2" concl="$3" nach="${4:-?}" kon="${5:-?}" d="-"
  if [ "$nach" != "?" ] && [ "$kon" != "?" ]; then
    k=$(( $(date -u -d "$kon" +%s) - $(date -u -d "$nach" +%s) ))
    d="${k}s"
  fi
  echo "DLITELNOST $metka: run=$R job=$S jobid=$id status=$status conclusion=$concl nach=$nach konets=$kon dlitelnost=$d"
}

# ── подложный gh (только --samoproverka): состояние — файлы в $Z150_MOK ───
gh() {
  local m="$Z150_MOK" api=0 download=0 json=0 log=0 repo="" imja="" dir=""
  local args=("$@") i a
  for ((i = 0; i < ${#args[@]}; i++)); do
    a="${args[$i]}"
    case "$a" in
      run | view) : ;;
      download) download=1 ;;
      api) api=1 ;;
      --json) json=1 ;;
      --log) log=1 ;;
      --repo) i=$((i + 1)); repo="${args[$i]}" ;;
      -n) i=$((i + 1)); imja="${args[$i]}" ;;
      -D) i=$((i + 1)); dir="${args[$i]}" ;;
      --job | --paginate | -R) : ;;
      -*) : ;;
      *) : ;;
    esac
  done
  if [ "$api" = 1 ]; then
    [ -f "$m/artifacts.json" ] || { echo "gh_mock: API-otkaz (net artifacts.json)" >&2; return 1; }
    cat "$m/artifacts.json"
    return 0
  fi
  if [ "$download" = 1 ]; then
    [ -d "$m/artefakt" ] || { echo "gh_mock: artefakt $imja ne najden" >&2; return 1; }
    cp -R "$m/artefakt/." "$dir/" || return 1
    return 0
  fi
  if [ "$log" = 1 ]; then
    [ -f "$m/log.txt" ] || { echo "gh_mock: log ne dostupen" >&2; return 1; }
    cat "$m/log.txt"
    return 0
  fi
  if [ "$json" = 1 ]; then
    [ -f "$m/jobs.json" ] || { echo "gh_mock: gh run view --json otkaz" >&2; return 1; }
    cat "$m/jobs.json"
    return 0
  fi
  echo "gh_mock: neizvestnyj vyzov: $*" >&2
  return 9
}

# ── самопроверка: исходы всех случаев процедуры на подложном gh ────────────
samoproverka() {
  local KOREN m
  KOREN="$(mktemp -d "${TMPDIR:-/tmp}/zp150-sp-XXXXXX")"
  m="$KOREN/mir"
  mkdir -p "$m"

  # образцовый артефакт (канон форматов батареи 150)
  mkdir -p "$m/artefakt"
  printf 'reshenie=publikuem: signatura obryva v tekushchej popytke ns rabotnika\nemulator_exit=zafiksirovano\nlogcat_kolco=est\n' > "$m/artefakt/itog.txt"
  printf '# ts epoch | emu_pid | emu_state | adb_state | boot_id | adbd_pid | guest_uptime_s | cg_mem_current | cg_ev_high | cg_ev_max | cg_ev_oom | cg_cpu_throttled_nr | cg_cpu_throttled_us | psi_cpu_avg10 | psi_mem_avg10 | host_memavail_kib\n123 | 4242 | S | device | b0b0-1111 | 4243 | 12.0 | 1234567 | 0 | 0 | 0 | 3 | 1200 | 1.25 | 2.50 | 6543210\n' > "$m/artefakt/sampler.tsv"
  printf '== qemu PID 4242 ischez iz /proc @ 1770000000 (tick 61) ==\nemu_sostojanie_do=S\noom_kill_do=0 oom_kill_posle=0\nprichina_po_zhurnalu: signal 9\nvyhod_status=NE_DOSTUPEN: nabljudatel ne roditel qemu\n' > "$m/artefakt/emulator-exit.txt"
  printf '== logcat -d -t 50 @ tick 55 ==\nI/x: zhivaja stroka do obryva\n' > "$m/artefakt/logcat-kolco.txt"

  printf '{"total_count":1,"jobs":[{"name":"S","status":"completed","conclusion":"failure","databaseId":111,"startedAt":"2026-10-31T10:00:00Z","completedAt":"2026-10-31T10:07:00Z"}]}' > "$m/jobs-krasnyj.json"
  printf '{"total_count":1,"jobs":[{"name":"drugoj-ekran","status":"completed","conclusion":"failure","databaseId":222}]}' > "$m/jobs-job-net.json"
  printf '{"total_count":1,"jobs":[{"name":"S","status":"completed","conclusion":"success","databaseId":111}]}' > "$m/jobs-uspeh.json"
  printf '{"total_count":1,"jobs":[{"name":"S","status":"in_progress","conclusion":null,"databaseId":111}]}' > "$m/jobs-ne-zavershen.json"
  printf '{"total_count":1,"artifacts":[{"name":"zamer-S-C-R-A"}]}' > "$m/artifacts-est.json"
  printf '{"total_count":0,"artifacts":[]}' > "$m/artifacts-net.json"
  printf 'Zamer obryva: sbor … vyvod: zeljonyj itog — ne publikuetsja (marker)\n' > "$m/log-marker.txt"
  printf 'Zamer obryva: sbor … prosto log bez markera\n' > "$m/log-bez-markera.txt"
  cp -R "$m/artefakt" "$m/artefakt-bez-exit"
  rm -f "$m/artefakt-bez-exit/emulator-exit.txt"

  local sluchai=(
    "krasnyj-polozhitelnyj|0|ZP_KRASNYJ_OK|jobs-krasnyj.json|artifacts-est.json|artefakt|log-marker.txt"
    "krasnyj-job-net|1|JOB_NET|jobs-job-net.json|artifacts-est.json|artefakt|log-marker.txt"
    "krasnyj-conclusion-inaja|1|KONKLUZIJA|jobs-uspeh.json|artifacts-est.json|artefakt|log-marker.txt"
    "krasnyj-job-ne-zavershen|1|KONKLUZIJA|jobs-ne-zavershen.json|artifacts-est.json|artefakt|log-marker.txt"
    "krasnyj-artefakt-net|1|ARTEFAKT_NET|jobs-krasnyj.json|artifacts-net.json|artefakt|log-marker.txt"
    "krasnyj-fajl-objazatelnyj-net|1|FAJL_NET|jobs-krasnyj.json|artifacts-est.json|artefakt-bez-exit|log-marker.txt"
    "zelenyj-polozhitelnyj|0|ZP_ZELENYJ_OK|jobs-uspeh.json|artifacts-net.json|artefakt|log-marker.txt"
    "zelenyj-artefakt-zapreschen|1|ARTEFAKT_ZAPRESCHEN|jobs-uspeh.json|artifacts-est.json|artefakt|log-marker.txt"
    "zelenyj-marker-net|1|MARKER_NE_PUBLIKUETSA|jobs-uspeh.json|artifacts-net.json|artefakt|log-bez-markera.txt"
    "oshibka-gh|1|GH_OTKAZ|NET|artifacts-est.json|artefakt|log-marker.txt"
  )
  local stroka imja ozh_rc ozh_prichina jobs art log artefakt_dir fakt out proshli=0 vse=0
  for stroka in "${sluchai[@]}"; do
    IFS='|' read -r imja ozh_rc ozh_prichina jobs art artefakt_dir log <<< "$stroka"
    vse=$((vse + 1))
    local mir="$KOREN/$imja"
    mkdir -p "$mir"
    if [ "$jobs" != "NET" ]; then
      cp "$m/$jobs" "$mir/jobs.json"
    fi
    cp "$m/$art" "$mir/artifacts.json"
    cp "$m/$log" "$mir/log.txt"
    cp -R "$m/$artefakt_dir" "$mir/artefakt"
    out="$KOREN/$imja.out"
    fakt=0
    case "$imja" in
      krasnyj-* | oshibka-gh)
        ( Z150_MOK="$mir" priemka_krasnyj complior-mob S R A C ) >"$out" 2>&1 || fakt=$? ;;
      zelenyj-*)
        ( Z150_MOK="$mir" priemka_zelenyj complior-mob S R A ) >"$out" 2>&1 || fakt=$? ;;
    esac
    if [ "$fakt" != "$ozh_rc" ]; then
      echo "SAMOPROVERKA_PROVAL: $imja rc=$fakt (ozhidalos $ozh_rc)" >&2
      cat "$out" >&2
      rm -rf "$KOREN"
      return 1
    fi
    if [ -n "$ozh_prichina" ] && ! grep -q "$ozh_prichina" "$out"; then
      echo "SAMOPROVERKA_PROVAL: $imja bez prichiny '$ozh_prichina'" >&2
      cat "$out" >&2
      rm -rf "$KOREN"
      return 1
    fi
    echo "SLUCHAJ $imja rc=$fakt OK ($ozh_prichina)"
    proshli=$((proshli + 1))
  done
  rm -rf "$KOREN"
  echo "SAMOPROVERKA: sluchaev $vse, sovpalo $proshli"
}

case "${1:-}" in
  krasnyj) shift; priemka_krasnyj "$@" ;;
  zelenyj) shift; priemka_zelenyj "$@" ;;
  dlitelnosti)
    shift
    [ $# -eq 3 ] || otkaz "ARGUMENTY: dlitelnosti <repo> <S> <R1> <R2 — vsego 4>"
    izmerit_dlitelnost "$1" "$2" "$3" s-obertochnym-150
    izmerit_dlitelnost "$1" "$2" "$4" bez-obertki-150
    echo "VYVOD (revjuer): sopostavimost' kartы/runnera/vetki — objazatelno v otchjot; chislovoj porog overhead — volja vladel'tsa (naznacheno ne budet)"
    ;;
  --samoproverka) samoproverka ;;
  *) otkaz "ARGUMENTY: krasnyj <repo> <S> <R> <A> <C> | zelenyj <repo> <S> <R> <A> | dlitelnosti <repo> <S> <R1> <R2> | --samoproverka" ;;
esac
