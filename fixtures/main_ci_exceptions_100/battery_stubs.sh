#!/usr/bin/env bash
# Обманный стаб-пак 100 (контракт 100, круг 3 — Н-39): двадцать восемь обманных
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
#   t100-m15 poluta             → red_poluta_nevedomy_otkaz (Б5: оба круга-2 под-входа)
#   t100-m16 no-reread          → red_dvizhenie_bazy_vo_vremya (Б6а: база двинулась между сверкой и допуском)
#   t100-m17 no-reread+gitw     → red_repeticija_gitw (Б6б: П3 — публикация через дверь при двинутой базе)
#   t100-m18 lenient-schema     → red_istochnik_doveriya (Б7: под-вход а — голая запись принимается)
#   t100-m19 silent-empty       → red_istochnik_doveriya (совет 3: под-вход г — нечитаемый блоб ≡ пусто)
#   t100-m20 defs-only          → red_ci_proiskhozhdenie (Б2/арбитраж: под-вход б — тело скрипта под
#                                scripts/ заменено при байт-идентичном слое определений; сравнивает
#                                ТОЛЬКО три файла слоя, корни не судит — живой обход круга 2)
#   t100-m21 count-only         → red_identichnost_defekta (Б1/арбитраж: под-входы б/в — правильный path
#                                и число аннотаций, message ≠ FAIL-строке; сравнивает числа, не message)
#   t100-m22 list-p-only        → red_samovnesenie_spiska (Б4: под-вход б — расширенный список внесён
#                                ТОЛЬКО в дерево land-мержа M; список сравнивается только с p — живой
#                                обход круга 2)
#   t100-m23 p-code-only        → red_samovnesenie_spiska (Б4: под-вход в — тело проверяльщика заменено
#                                только в дереве M; CI-код судится только по p)
#   t100-m24 success-blind      → red_poluta_nevedomy_otkaz (Б5: под-вход в — success-job с новой
#                                FAIL-строкой; находки читаются только у failure-job)
#   t100-m25 no-wfrun           → red_poluta_nevedomy_otkaz (Б5: под-вход г — все job success/PASS,
#                                conclusion запуска failure; отказ workflow без находок не судится)
#   t100-m26 side-effect+gitw   → red_repeticija_gitw (Б6: П2 — мутант круга 2: при «находка вне
#                                списка» публикует постороннюю ветку в target ДО печати отказа)
#   t100-m27 nested-suite       → red_kontrol_vse_zelenoe (Б8: связка читает вложенный check_suite.id
#                                запуска вместо плоского check_suite_id — документированной схемы
#                                GET /actions/runs; на настоящей форме отбрасывает все 12 строк)
#   t100-m28 first-report-message → red_identichnost_defekta (Б9: под-вход г — message
#                                судится только у первой пары в порядке отчёта; обход круга 3)
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
# режим none — честная по форме модель критерия контракта 100 (круг 3)
set -uo pipefail
MODE='__MODE__'
pf()  {
  if [ "$MODE" = "side-effect" ]; then
    # дефект Б6 круга 2 (мутант критика): при «находка вне списка» публиковать
    # постороннюю ветку в target ДО печати отказа — оракул «after ≠ M» это
    # пропускал; новый оракул П2 требует target до == после
    case "$1" in
      "находка вне списка"*) git push -q "$TGT" wip/100/demo:refs/heads/main >/dev/null 2>&1 || true ;;
    esac
  fi
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: %s\n' "$1" >&2; exit 1
}
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
# Б8: у ЗАПУСКА поле ПЛОСКОЕ check_suite_id (документированная схема
# GET /actions/runs); nested-suite — дефект круга 2 (вложенная форма
# check_suite.id вычитывает 0 и отбрасывает все настоящие строки)
if [ "$MODE" = "nested-suite" ]; then
  suite="$(jq -r '.check_suite.id // 0' <<<"$run")"
else
  suite="$(jq -r '.check_suite_id // 0' <<<"$run")"
fi
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
# самовнесение (байт-идентичность p↔rmain И M↔rmain — Б4: публикуемым
# деревом является M, p — лишь CI-родитель); читаемость vs отсутствие ──
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
m_side="$(read_side "$mh")"
p_side="$(read_side "$p")"
for s in "$t_side" "$m_side" "$p_side"; do
  if [ "$s" = "UNREADABLE" ]; then
    if [ "$MODE" = "silent-empty" ]; then continue; fi
    pf "список не читается: принятая ревизия"
  fi
done
if [ "$t_side" = "ABSENT" ] && [ "$p_side" = "ABSENT" ] \
   && { [ "$MODE" = "list-p-only" ] || [ "$m_side" = "ABSENT" ]; }; then
  exsrc='{"schema":"main-ci-exceptions/1","exceptions":[]}'
  listflag=0
elif [ "$t_side" = "ABSENT" ] || [ "$p_side" = "ABSENT" ] || [ "$t_side" != "$p_side" ] \
     || { [ "$MODE" != "list-p-only" ] && { [ "$m_side" = "ABSENT" ] || [ "$t_side" != "$m_side" ]; }; }; then
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

# ── слой определений CI и исполняемые корни: байт-идентичность p↔rmain И
# M↔rmain (Б2/арбитраж contracts-100-b1b2 + Б4: отправляемое дерево — M);
# добавление новых путей разрешено; нарушения печатаются ВСЕ (арбитраж А1) ──
if [ "$MODE" != "no-cidefreeze" ]; then
  viol=""
  for side in p m; do
    rev="$p"; [ "$side" = "m" ] && rev="$mh"
    [ "$side" = "m" ] && [ "$MODE" = "p-code-only" ] && continue
    for f in .github/workflows/ci.yml registry/ci-steps.tsv package.json; do
      a="$(git show "$rmain:$f" 2>/dev/null || printf 'ABSENT')"
      b="$(git show "$rev:$f" 2>/dev/null || printf 'ABSENT')"
      [ "$a" = "$b" ] || viol+="$f"$'\n'
    done
    if [ "$MODE" != "defs-only" ]; then
      while IFS=$'\t' read -r st vpath rest; do
        [ -n "$vpath" ] || continue
        viol+="$vpath"$'\n'
        [ -n "$rest" ] && viol+="$rest"$'\n'
      done < <(git diff --name-status --diff-filter=MDTR "$rmain" "$rev" -- scripts fixtures 2>/dev/null)
    fi
  done
  if [ -n "$viol" ]; then
    while IFS= read -r v; do
      [ -n "$v" ] || continue
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: CI-код не из доверенной ревизии: %s\n' "$v" >&2
    done < <(printf '%s' "$viol" | LC_ALL=C sort -u)
    exit 1
  fi
fi

total=0; covered=0
for j in "${jobs[@]}"; do
  nm="$(pfx "$j") ($j)"
  row="$(rowof "$nm")"
  [ -n "$row" ] || continue
  IFS=$'\t' read -r rid rst rco resc <<<"$row"
  # Б5: находки читаются из отчёта ЛЮБОГО исполненного job (success тоже —
  # замаскированный код возврата шага не прячет находку); success-blind —
  # дефект круга 2 (только failure-job)
  if [ "$MODE" = "success-blind" ] && [ "$rco" != "failure" ]; then continue; fi
  rsum="${resc//\\n/$'\n'}"
  jfl="$(printf '%s\n' "$rsum" | grep -a ': FAIL: ' || true)"
  jfail=0
  if [ -n "$jfl" ]; then jfail="$(printf '%s\n' "$jfl" | grep -c . || true)"; fi
  [ "$jfail" -gt 0 ] || continue
  anns="[]"
  if [ "$MODE" != "no-annotations" ]; then
    anns="$(curl -fsS -m 5 "$api/check-runs/$rid/annotations" 2>/dev/null || printf '[]')"
  fi
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
      obj="$(jq -r .object <<<"$rec")"
      nfail="$(printf '%s\n' "$fl" | grep -c . || true)"
      if [ "$MODE" = "count-only" ]; then
        # дефект круга 2 (арбитраж Б1): числа по path, message не судится
        nobj="$(printf '%s' "$anns" | jq --arg o "$obj" '[.[] | select(.annotation_level=="failure" and .path==$o)] | length')"
        nall="$(printf '%s' "$anns" | jq '[.[] | select(.annotation_level=="failure")] | length')"
        { [ "${nobj:-0}" -eq "$nfail" ] && [ "${nall:-0}" -eq "$nfail" ]; } \
          || pf "находка вне списка: $j/$k"
      elif [ "$MODE" = "first-report-message" ]; then
        # Б9 (арбитраж contracts-100-b9-v1): дефект круга 3 — message судится
        # только у ПЕРВОЙ пары в порядке отчёта (break), не у каждой FAIL-строки;
        # порядок отчёта вместо LC_ALL=C sort -u; nall==jfail сохранён
        bad=0
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          cn="$(printf '%s' "$anns" | jq --arg o "$obj" --arg m "$line" \
            '[.[] | select(.annotation_level=="failure" and .path==$o and .message==$m)] | length')"
          ln="$(printf '%s
' "$fl" | grep -Fxc "$line" || true)"
          [ "${cn:-0}" -eq "${ln:-0}" ] || bad=1
          break
        done < <(printf '%s
' "$fl")
        nall="$(printf '%s' "$anns" | jq '[.[] | select(.annotation_level=="failure")] | length')"
        [ "${nall:-0}" -eq "$jfail" ] || bad=1
        [ "$bad" -eq 0 ] || pf "находка вне списка: $j/$k"
      else
        # арбитраж Б1: на КАЖДУЮ FAIL-строку — аннотация с path==object и
        # message==строке ПОБАЙТНО; лишних failure-аннотаций в отчёте нет
        bad=0
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          cn="$(printf '%s' "$anns" | jq --arg o "$obj" --arg m "$line" \
            '[.[] | select(.annotation_level=="failure" and .path==$o and .message==$m)] | length')"
          ln="$(printf '%s\n' "$fl" | grep -Fxc "$line" || true)"
          [ "${cn:-0}" -eq "${ln:-0}" ] || bad=1
        done < <(printf '%s\n' "$fl" | LC_ALL=C sort -u)
        nall="$(printf '%s' "$anns" | jq '[.[] | select(.annotation_level=="failure")] | length')"
        [ "${nall:-0}" -eq "$jfail" ] || bad=1
        [ "$bad" -eq 0 ] || pf "находка вне списка: $j/$k"
      fi
    fi
    covered=$((covered+1))
  done
done
# Б5: conclusion запуска = failure без единой находки — неразобранный отказ
# workflow (setup/публикация/сбой раннера): «находки 0/0» недопустимы;
# no-wfrun — дефект круга 2 (отказ workflow без находок не судится)
if [ "$co" = "failure" ] && [ "$total" -eq 0 ] && [ "$MODE" != "no-wfrun" ]; then
  pf "запуск отказал без находок"
fi
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
gen_stub t100-m20 defs-only
gen_stub t100-m21 count-only
gen_stub t100-m22 list-p-only
gen_stub t100-m23 p-code-only
gen_stub t100-m24 success-blind
gen_stub t100-m25 no-wfrun
gen_stub t100-m26 side-effect gitw-copy
gen_stub t100-m27 nested-suite
gen_stub t100-m28 first-report-message

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
[ "$n_stub" -eq 28 ] || { printf 'ОТКАЗ: стабов %s, ожидалось 28\n' "$n_stub" >&2; exit 2; }

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
probe t100-m20 red_ci_proiskhozhdenie.sh          || itog=1
probe t100-m21 red_identichnost_defekta.sh        || itog=1
probe t100-m22 red_samovnesenie_spiska.sh         || itog=1
probe t100-m23 red_samovnesenie_spiska.sh         || itog=1
probe t100-m24 red_poluta_nevedomy_otkaz.sh       || itog=1
probe t100-m25 red_poluta_nevedomy_otkaz.sh       || itog=1
probe t100-m26 red_repeticija_gitw.sh             || itog=1
probe t100-m27 red_kontrol_vse_zelenoe.sh         || itog=1
probe t100-m28 red_identichnost_defekta.sh        || itog=1
printf 'ИТОГ стаб-пак 100: rc=%s (стабов %s/28)\n' "$itog" "$n_stub"
exit "$itog"
