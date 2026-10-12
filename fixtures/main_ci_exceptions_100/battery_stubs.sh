#!/usr/bin/env bash
# Обманный стаб-пак 100 (контракт 100, круг 2 — Н-39): девятнадцать обманных
# субъектов gitw_preflight_071.sh, каждый — мини-дверь с ОДНИМ дефектом
# (Z100_STUB_MODE); режим none — честная по форме модель критерия (прогон
# «модель зелёная» вне пакета). Пойман = связанная клетка против стаба даёт
# rc 1 (КРАСНО); rc 0 и rc 2 — НЕ пойман. Привязка стаб↔клетка↔вход живёт В
# ЭТОМ КОДЕ, не в прозе контракта — у каждого стаба вход назван рядом:
#   t100-m1  old-predicate      → red_kontrol_tolyko_razreshennye (run failure с разрешёнными находками)
#   t100-m2  list-from-candidate→ red_podmena_kandidatom (под-вход а: расширенный список в дереве кандидата)
#   t100-m3  count-path         → red_novaya_nakhodka (тот же job/ключ/число, иной текст)
#   t100-m4  any-success        → red_neaktyalny_zapusk (под-вход б: старый успех новее отказа)
#   t100-m5  job-presence       → red_job_nerezultat (под-вход skipped: имя есть, исполнения нет)
#   t100-m6  no-fullness        → red_rannee_zavershenie (терминальные строки ключей не требуются)
#   t100-m7  no-version         → red_podmena_kandidatom (под-вход в: посторонний def-sha256)
#   t100-m8  no-expiry          → red_srok_i_versiya_zapisi (под-вход expired, контейнерная схема)
#   t100-m9  always             → red_zamena_predikata (успешный run без полного набора job)
#   t100-m10 no-base            → red_neaktyalny_zapusk (под-вход в: база запуска двинулась)
#   t100-m11 no-annotations     → red_identichnost_defekta (Б1: тот же текст, другой объект аннотации)
#   t100-m12 no-cidefreeze      → red_ci_proiskhozhdenie (Б2: package.json кандидата изменён при верном хеше)
#   t100-m13 no-suite           → red_smesch_zapuskov (Б3: строки чужого suite 11 первыми в ответе)
#   t100-m14 list-diff-ok       → red_samovnesenie_spiska (Б4: дормантная запись в дереве кандидата)
#   t100-m15 poluta             → red_poluta_nevedomy_otkaz (Б5: оба под-входа)
#   t100-m16 no-reread          → red_dvizhenie_bazy_vo_vremya (Б6а: база двинулась между сверкой и допуском)
#   t100-m17 no-reread+gitw     → red_repeticija_gitw (Б6б: П3 — публикация через дверь при двинутой базе)
#   t100-m18 lenient-schema     → red_istochnik_doveriya (Б7: под-вход а — голая запись принимается)
#   t100-m19 silent-empty       → red_istochnik_doveriya (совет 3: под-вход г — нечитаемый блоб ≡ пусто)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAM="$HERE"
Z100_BASE="${Z100_BASE:-/tmp/dev-harness-verify}"
ROOT="$(cd "$HERE/../.." && pwd)"
command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v sed  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sed\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }

WORK="$Z100_BASE/main-ci-100-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# ── мини-дверь: честная по форме модель критерия, с ОДНИМ дефектом MODE ──
read -r -d '' CORE <<'EOCORE' || true
#!/usr/bin/env bash
# стаб батареи 100: предполёт чек 3 с ОДНИМ дефектом (Z100_STUB_MODE);
# режим none — честная по форме модель критерия контракта 100 (круг 2)
set -uo pipefail
MODE='__MODE__'
pf()  { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: %s\n' "$1" >&2; exit 1; }
api0(){ printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: API\n' >&2; exit 1; }
TGT="${1:?}"; shift
src=""
for a in "$@"; do [ "$a" = "main" ] && src=main; done
[ -n "$src" ] || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: refspec\n' >&2; exit 1; }
rmain="$(git ls-remote "$TGT" refs/heads/main | cut -f1)"
tip="$(git rev-parse "$src")"
if [ "$MODE" = "always" ]; then
  printf 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo (x): jobs 12/12 исполнено, находки 0/0\n' >&2
  exit 0
fi
mh="$(git log --merges --format='%H' "$rmain..$tip" | head -1)"
p="$(git rev-parse --verify --quiet "${mh}^2")"
api="${GITW_PREFLIGHT_071_API:?}"
if [ "$MODE" = "old-predicate" ]; then
  body="$(curl -fsS -m 5 "$api/actions/runs?event=pull_request&head_sha=$p")" || api0
  n="$(printf '%s' "$body" | jq '[.workflow_runs[]? | select((.event=="pull_request") and (.conclusion=="success"))] | length')"
  if [ "${n:-0}" -ge 1 ]; then
    printf 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo (%s): jobs 12/12 исполнено, находки 0/0\n' "$p" >&2
    exit 0
  fi
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: land без зелёного PR-CI: wip/100/demo (%s)\n' "$p" >&2
  exit 1
fi
runs="$(curl -fsS -m 5 "$api/actions/runs?event=pull_request&head_sha=$p")" || api0
if [ "$MODE" = "any-success" ]; then
  if printf '%s' "$runs" | jq -e '[.workflow_runs[]? | select(.conclusion=="success")] | length > 0' >/dev/null 2>&1; then
    printf 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo (%s): jobs 12/12 исполнено, находки 0/0\n' "$p" >&2
    exit 0
  fi
  pf "запусков PR-CI нет: wip/100/demo ($p)"
fi
run="$(printf '%s' "$runs" | jq -c --arg p "$p" '[.workflow_runs[]? | select((.event=="pull_request") and (.head_sha==$p))] | max_by(.id) // empty')"
[ -n "$run" ] || pf "запусков PR-CI нет: wip/100/demo ($p)"
st="$(jq -r '.status // ""' <<<"$run")"
[ "$st" = "completed" ] || pf "запуск не завершён: ${st:-без статуса}"
co="$(jq -r '.conclusion // ""' <<<"$run")"
{ [ "$co" = "success" ] || [ "$co" = "failure" ]; } || pf "запуск не исполнен: ${co:-без результата}"
if [ "$MODE" != "no-base" ]; then
  bs="$(jq -r '.pull_requests[0].base.sha // ""' <<<"$run")"
  [ "$bs" = "$rmain" ] || pf "движение базы: запуск не актуален"
fi
suite="$(jq -r '.check_suite.id // 0' <<<"$run")"
crs="$(curl -fsS -m 5 "$api/commits/$p/check-runs" \
  | jq -c '{rows: [.check_runs[]? | {id, name, status, conclusion, check_suite_id: (.check_suite.id // 0), summary: (.output.summary // "")}]}')" || api0
if [ "$MODE" = "no-suite" ]; then
  # дефект смешения: строки БЕЗ связки с suite — первый результат имени
  # (зелёные строки старого запуска стоят в ответе первыми)
  rows="$(printf '%s' "$crs" | jq -c '{rows: (.rows | group_by(.name) | map(.[0]))}')"
else
  rows="$(printf '%s' "$crs" | jq -c --argjson s "$suite" '{rows: ([.rows[] | select(.check_suite_id == $s)] | group_by(.name) | map(max_by(.id)))}')"
fi
ciyl="$(git show "$rmain:.github/workflows/ci.yml" 2>/dev/null)" \
  || pf "CI-код не читается: .github/workflows/ci.yml"
declare -A KEYS
jobs=()
entry=""
while IFS= read -r l; do
  if [ -z "$entry" ]; then entry="$l"; else KEYS[$entry]="$l"; jobs+=("$entry"); entry=""; fi
done < <(printf '%s\n' "$ciyl" | sed -nE 's/^ +- (shard|lane): ([a-z0-9]+)$/\2/p; s/^ +keys: (.+)$/\1/p')
pfx() { case "$1" in ap*) printf 'antiplacebo';; *) printf 'ci';; esac; }
defsha() { printf '%s\t%s\n' "$1" "$(printf '%s' "${KEYS[$1]}" | tr ' ' ',')" | sha256sum | cut -d' ' -f1; }
rowof() {  # <имя> → id TAB status TAB conclusion TAB summary (пусто = нет строки)
  printf '%s' "$rows" | jq -r --arg n "$1" \
    '[.rows[] | select(.name==$n)] | .[0] | if . then ([.id, .status, (.conclusion // ""), (.summary // "")] | @tsv) else "" end'
}
problems=0
for j in "${jobs[@]}"; do
  nm="$(pfx "$j") ($j)"
  row="$(rowof "$nm")"
  if [ -z "$row" ]; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s отсутствует\n' "$j" >&2
    problems=1; continue
  fi
  IFS=$'\t' read -r rid rst rco resc <<<"$row"
  rsum="${resc//\\n/$'\n'}"
  if [ "$MODE" != "job-presence" ]; then
    if [ "$rst" != "completed" ]; then
      reason="$rst"; [ -z "$reason" ] && reason="$rco"
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s %s\n' "$j" "$reason" >&2
      problems=1; continue
    fi
    case "$rco" in
      success|failure) ;;
      skipped|neutral|cancelled|timed_out)
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s %s\n' "$j" "$rco" >&2
        problems=1; continue ;;
      *)
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s неразобранный результат: %s\n' "$j" "$rco" >&2
        problems=1; continue ;;
    esac
  fi
  if [ "$MODE" != "no-version" ]; then
    ds="$(printf '%s\n' "$rsum" | sed -nE 's/^def-sha256 ([0-9a-f]{64})$/\1/p' | head -1)"
    [ "$ds" = "$(defsha "$j")" ] || pf "отчёт не из доверенного определения: $j"
  fi
  if [ "$MODE" != "no-fullness" ]; then
    if [ "$MODE" != "poluta" ] || [ "$rco" = "failure" ]; then
      for k in ${KEYS[$j]}; do
        printf '%s\n' "$rsum" | grep -qE "^${k}: (PASS|FAIL)" \
          || pf "нет результата: $j/$k"
      done
    fi
  fi
  if [ "$rco" = "failure" ] && [ "$MODE" != "poluta" ]; then
    nf=0
    for k in ${KEYS[$j]}; do
      c="$(printf '%s\n' "$rsum" | grep -c "^${k}: FAIL" || true)"
      nf=$((nf + c))
    done
    [ "$nf" -gt 0 ] || pf "job не выполнен: $j отказ без находки"
  fi
done
while IFS= read -r nm; do
  [ -n "$nm" ] || continue
  known=0
  for j in "${jobs[@]}"; do [ "$(pfx "$j") ($j)" = "$nm" ] && known=1; done
  if [ "$known" -eq 0 ]; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: посторонний job: %s\n' "$nm" >&2
    problems=1
  fi
done < <(printf '%s' "$rows" | jq -r '.rows[].name')
[ "$problems" -eq 0 ] || exit 1

# ── источник доверия: список из ПРИНЯТОЙ ревизии; схема fail-closed;
# самовнесение (байт-идентичность p↔rmain); читаемость vs отсутствие ──
read_side() {  # <rev> → ABSENT | содержимое | UNREADABLE
  local e
  e="$(git ls-tree --name-only "$1" -- registry/main-ci-exceptions.json 2>/dev/null)"
  [ -n "$e" ] || { printf 'ABSENT'; return 0; }
  local c
  c="$(git show "$1:registry/main-ci-exceptions.json" 2>/dev/null)" \
    || { printf 'UNREADABLE'; return 0; }
  printf '%s' "$c"
}
t_side="$(read_side "$rmain")"
p_side="$(read_side "$p")"
side() { # <t_side|p_side>
  if [ "$1" = "t_side" ]; then printf '%s' "$t_side"; else printf '%s' "$p_side"; fi
}
for s in "$t_side" "$p_side"; do
  if [ "$s" = "UNREADABLE" ]; then
    if [ "$MODE" = "silent-empty" ]; then continue; fi
    pf "список не читается: принятая ревизия"
  fi
done
if [ "$t_side" = "ABSENT" ] && [ "$p_side" = "ABSENT" ]; then
  exsrc='{"schema":"main-ci-exceptions/1","exceptions":[]}'
  listflag=0
elif [ "$t_side" = "ABSENT" ] || [ "$p_side" = "ABSENT" ] || [ "$t_side" != "$p_side" ]; then
  if [ "$MODE" != "list-diff-ok" ]; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не из доверенной ревизии: registry/main-ci-exceptions.json\n' >&2
    listflag=1
  else
    listflag=0
  fi
  if [ "$t_side" = "ABSENT" ]; then
    exsrc='{"schema":"main-ci-exceptions/1","exceptions":[]}'
  else
    exsrc="$t_side"
  fi
else
  exsrc="$t_side"
  listflag=0
fi
if [ "$MODE" = "list-from-candidate" ]; then
  [ "$p_side" = "ABSENT" ] || exsrc="$p_side"
fi
sch="$(printf '%s' "$exsrc" | jq -e '(.schema=="main-ci-exceptions/1") and (.exceptions|type=="array")' 2>/dev/null)"
if [ "$sch" != "true" ]; then
  if [ "$MODE" = "lenient-schema" ]; then
    wrapped="$(printf '%s' "$exsrc" | jq -c '{schema:"main-ci-exceptions/1",exceptions:[.]}' 2>/dev/null)"
    if [ -n "$wrapped" ]; then exsrc="$wrapped"; else pf "список не разбирается: схема"; fi
  else
    pf "список не разбирается: схема"
  fi
fi
recbad="$(printf '%s' "$exsrc" | jq -r '[.exceptions[] | select(
    (.defect_code|type)!="string" or (.defect_code|test("^[0-9a-f]{64}$")|not) or
    (.check_version|type)!="string" or (.check_version|test("^[0-9a-f]{64}$")|not) or
    (.evidence_main_sha|type)!="string" or (.evidence_main_sha|test("^[0-9a-f]{40}$")|not) or
    (.expires|type)!="string" or (.expires|test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")|not) or
    (.object|type)!="string" or (.object==""))] | length' 2>/dev/null)"
[ "${recbad:-0}" = "0" ] || pf "список не разбирается: запись"

# ── слой определений CI: байт-идентичность p↔rmain (Б2) ──
if [ "$MODE" != "no-cidefreeze" ]; then
  for f in .github/workflows/ci.yml registry/ci-steps.tsv package.json; do
    a="$(git show "$rmain:$f" 2>/dev/null || printf 'ABSENT')"
    b="$(git show "$p:$f" 2>/dev/null || printf 'ABSENT')"
    [ "$a" = "$b" ] || pf "CI-код не из доверенной ревизии: $f"
  done
fi

total=0; covered=0
for j in "${jobs[@]}"; do
  nm="$(pfx "$j") ($j)"
  row="$(rowof "$nm")"
  [ -n "$row" ] || continue
  IFS=$'\t' read -r rid rst rco resc <<<"$row"
  [ "$rco" = "failure" ] || continue
  rsum="${resc//\\n/$'\n'}"
  for k in ${KEYS[$j]}; do
    fl="$(printf '%s\n' "$rsum" | grep "^${k}: FAIL" || true)"
    [ -n "$fl" ] || continue
    total=$((total+1))
    sha="$(printf '%s\n' "$fl" | LC_ALL=C sort | sha256sum | cut -d' ' -f1)"
    if [ "$MODE" = "count-path" ]; then
      rec="$(printf '%s' "$exsrc" | jq -r --arg t "$j" --arg k "$k" \
        '[.exceptions[]? | select(.target==$t and .key==$k)] | .[0] // empty')"
      [ -n "$rec" ] || pf "находка вне списка: $j/$k"
    else
      rec="$(printf '%s' "$exsrc" | jq -r --arg t "$j" --arg k "$k" --arg s "$sha" \
        '[.exceptions[]? | select(.target==$t and .key==$k and .defect_code==$s)] | .[0] // empty')"
      [ -n "$rec" ] || pf "находка вне списка: $j/$k"
    fi
    if [ "$MODE" != "count-path" ] && [ "$MODE" != "no-expiry" ]; then
      [ "$(jq -r .check_version <<<"$rec")" = "$(defsha "$j")" ] \
        || pf "определение проверки не совпадает с записью: $(jq -r .object <<<"$rec")"
      exp="$(jq -r .expires <<<"$rec")"
      { [ "$(date +%F)" \< "$exp" ] || [ "$(date +%F)" = "$exp" ]; } \
        || pf "срок исключения истёк: $(jq -r .object <<<"$rec")"
    fi
    if [ "$MODE" != "no-annotations" ]; then
      anns="$(curl -fsS -m 5 "$api/check-runs/$rid/annotations" 2>/dev/null || printf '[]')"
      nfail="$(printf '%s\n' "$fl" | grep -c . || true)"
      obj="$(jq -r .object <<<"$rec")"
      nobj="$(printf '%s' "$anns" | jq --arg o "$obj" '[.[] | select(.annotation_level=="failure" and .path==$o)] | length')"
      nall="$(printf '%s' "$anns" | jq '[.[] | select(.annotation_level=="failure")] | length')"
      { [ "${nobj:-0}" -eq "$nfail" ] && [ "${nall:-0}" -eq "$nfail" ]; } \
        || pf "находка вне списка: $j/$k"
    fi
    covered=$((covered+1))
  done
done
if [ "$MODE" != "no-base" ] && [ "$MODE" != "no-reread" ]; then
  [ "$(git ls-remote "$TGT" refs/heads/main | cut -f1)" = "$rmain" ] \
    || pf "движение базы: запуск не актуален"
fi
[ "$listflag" -eq 0 ] || exit 1
printf 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo (%s): jobs %s/%s исполнено, находки %s/%s\n' \
  "$p" "${#jobs[@]}" "${#jobs[@]}" "$covered" "$total" >&2
exit 0
EOCORE

gen_stub() {  # <имя> <mode> [gitw-copy]
  mkdir -p "$WORK/$1"
  printf '%s' "$CORE" | sed "s/__MODE__/$2/" >"$WORK/$1/gitw_preflight_071.sh"
  chmod +x "$WORK/$1/gitw_preflight_071.sh"
  if [ "${3:-}" = "gitw-copy" ]; then
    cp "$ROOT/scripts/gitw" "$WORK/$1/gitw"
    chmod +x "$WORK/$1/gitw"
  fi
}

gen_stub t100-m1  old-predicate
gen_stub t100-m2  list-from-candidate
gen_stub t100-m3  count-path
gen_stub t100-m4  any-success
gen_stub t100-m5  job-presence
gen_stub t100-m6  no-fullness
gen_stub t100-m7  no-version
gen_stub t100-m8  no-expiry
gen_stub t100-m9  always
gen_stub t100-m10 no-base
gen_stub t100-m11 no-annotations
gen_stub t100-m12 no-cidefreeze
gen_stub t100-m13 no-suite
gen_stub t100-m14 list-diff-ok
gen_stub t100-m15 poluta
gen_stub t100-m16 no-reread
gen_stub t100-m17 no-reread gitw-copy
gen_stub t100-m18 lenient-schema
gen_stub t100-m19 silent-empty

probe() {  # <стаб> <клетка> — rc клетки против стаба (пойман = 1)
  local stub="$1" cell="$2" rc
  D100_SUBJECTS_DIR="$WORK/$stub" bash "$FAM/$cell" >/dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 1 ]; then
    printf '— %s пойман на %s\n' "$stub" "$cell"
    return 0
  fi
  printf '— %s НЕ пойман на %s (rc=%s)\n' "$stub" "$cell" "$rc" >&2
  return 1
}

n_stub="$(ls -1 "$WORK" | wc -l)"
[ "$n_stub" -eq 19 ] || { printf 'ОТКАЗ: стабов %s, ожидалось 19\n' "$n_stub" >&2; exit 2; }

itog=0
probe t100-m1  red_kontrol_tolyko_razreshennye.sh || itog=1
probe t100-m2  red_podmena_kandidatom.sh          || itog=1
probe t100-m3  red_novaya_nakhodka.sh             || itog=1
probe t100-m4  red_neaktyalny_zapusk.sh           || itog=1
probe t100-m5  red_job_nerezultat.sh              || itog=1
probe t100-m6  red_rannee_zavershenie.sh          || itog=1
probe t100-m7  red_podmena_kandidatom.sh          || itog=1
probe t100-m8  red_srok_i_versiya_zapisi.sh       || itog=1
probe t100-m9  red_zamena_predikata.sh            || itog=1
probe t100-m10 red_neaktyalny_zapusk.sh           || itog=1
probe t100-m11 red_identichnost_defekta.sh        || itog=1
probe t100-m12 red_ci_proiskhozhdenie.sh          || itog=1
probe t100-m13 red_smesch_zapuskov.sh             || itog=1
probe t100-m14 red_samovnesenie_spiska.sh         || itog=1
probe t100-m15 red_poluta_nevedomy_otkaz.sh       || itog=1
probe t100-m16 red_dvizhenie_bazy_vo_vremya.sh    || itog=1
probe t100-m17 red_repeticija_gitw.sh             || itog=1
probe t100-m18 red_istochnik_doveriya.sh          || itog=1
probe t100-m19 red_istochnik_doveriya.sh          || itog=1
printf 'ИТОГ стаб-пак 100: rc=%s (стабов %s/19)\n' "$itog" "$n_stub"
exit "$itog"
