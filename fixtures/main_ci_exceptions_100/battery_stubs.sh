#!/usr/bin/env bash
# Обманный стаб-пак 100 (контракт 100, Н-39): десять обманных субъектов
# gitw_preflight_071.sh, каждый — мини-дверь с ОДНИМ дефектом (Z100_STUB_MODE).
# Пойман = связанная клетка против стаба даёт rc 1 (КРАСНО); rc 0 и rc 2 —
# НЕ пойман. Привязка стаб↔клетка↔вход живёт В ЭТОМ КОДЕ, не в прозе контракта:
#   t100-m1  old-predicate      → red_kontrol_tolyko_razreshennye (run failure с разрешёнными находками)
#   t100-m2  list-from-candidate→ red_podmena_kandidatom (под-вход а: расширенный список в дереве кандидата)
#   t100-m3  count-path         → red_novaya_nakhodka (тот же job/ключ/число, иной текст)
#   t100-m4  any-success        → red_neaktyalny_zapusk (под-вход б: старый успех новее отказа)
#   t100-m5  job-presence       → red_job_nerezultat (под-вход skipped: имя есть, исполнения нет)
#   t100-m6  no-fullness        → red_rannee_zavershenie (терминальные строки ключей не требуются)
#   t100-m7  no-version         → red_podmena_kandidatom (под-вход в: посторонний def-sha256)
#   t100-m8  no-expiry          → red_srok_i_versiya_zapisi (под-вход expired)
#   t100-m9  always             → red_zamena_predikata (успешный run без полного набора job)
#   t100-m10 no-base            → red_neaktyalny_zapusk (под-вход в: база запуска двинулась)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAM="$HERE"
Z100_BASE="${Z100_BASE:-/tmp/dev-harness-verify}"
command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v sed  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sed\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }

WORK="$Z100_BASE/main-ci-100-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
trap 'rm -rf "$WORK"' EXIT

# ── мини-дверь: честная по форме, с одним дефектом MODE ──
read -r -d '' CORE <<'EOCORE' || true
#!/usr/bin/env bash
# стаб батареи 100: предполёт чек 3 с ОДНИМ дефектом (Z100_STUB_MODE)
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
crs="$(curl -fsS -m 5 "$api/commits/$p/check-runs" \
  | jq -c '{rows: [.check_runs[]? | {name, status, conclusion, summary: (.output.summary // "")}]}')" || api0
ciyl="$(git show "$rmain:.github/workflows/ci.yml")"
declare -A KEYS
jobs=()
entry=""
while IFS= read -r l; do
  if [ -z "$entry" ]; then entry="$l"; else KEYS[$entry]="$l"; jobs+=("$entry"); entry=""; fi
done < <(printf '%s\n' "$ciyl" | sed -nE 's/^ +- (shard|lane): ([a-z0-9]+)$/\2/p; s/^ +keys: (.+)$/\1/p')
pfx() { case "$1" in ap*) printf 'antiplacebo';; *) printf 'ci';; esac; }
defsha() { printf '%s\t%s\n' "$1" "$(printf '%s' "${KEYS[$1]}" | tr ' ' ',')" | sha256sum | cut -d' ' -f1; }
problems=0
for j in "${jobs[@]}"; do
  nm="$(pfx "$j") ($j)"
  row="$(printf '%s' "$crs" | jq -r --arg n "$nm" '[.rows[] | select(.name==$n)] | .[0] | if . then ([.status, (.conclusion // ""), (.summary // "")] | @tsv) else "" end')"
  if [ -z "$row" ]; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s отсутствует\n' "$j" >&2
    problems=1; continue
  fi
  IFS=$'\t' read -r rst rco resc <<<"$row"
  rsum="${resc//\\n/$'\n'}"
  if [ "$MODE" != "job-presence" ]; then
    if [ "$rst" != "completed" ]; then
      reason="$rco"; [ -z "$reason" ] && reason="$rst"
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s %s\n' "$j" "$reason" >&2
      problems=1; continue
    fi
    if [ "$rco" != "success" ] && [ "$rco" != "failure" ]; then
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s неразобранный результат: %s\n' "$j" "$rco" >&2
      problems=1; continue
    fi
  fi
  if [ "$MODE" != "no-version" ]; then
    ds="$(printf '%s\n' "$rsum" | sed -nE 's/^def-sha256 ([0-9a-f]{64})$/\1/p' | head -1)"
    [ "$ds" = "$(defsha "$j")" ] || pf "отчёт не из доверенного определения: $j"
  fi
  if [ "$rco" = "failure" ]; then
    for k in ${KEYS[$j]}; do
      if ! printf '%s\n' "$rsum" | grep -qE "^${k}: (PASS|FAIL)"; then
        [ "$MODE" = "no-fullness" ] || pf "нет результата: $j/$k"
        continue
      fi
    done
  fi
done
while IFS= read -r nm; do
  [ -n "$nm" ] || continue
  tok="$(printf '%s' "$nm" | sed -nE 's/^.* \((ap[1-5]|l[1-7])\)$/\1/p')"
  known=0
  for j in "${jobs[@]}"; do [ "$(pfx "$j") ($j)" = "$nm" ] && known=1; done
  if [ "$known" -eq 0 ]; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: посторонний job: %s\n' "$nm" >&2
    problems=1
  fi
done < <(printf '%s' "$crs" | jq -r '.rows[].name')
[ "$problems" -eq 0 ] || exit 1
if [ "$MODE" = "list-from-candidate" ]; then
  exsrc="$(git show "$tip:registry/main-ci-exceptions.json" 2>/dev/null || true)"
else
  exsrc="$(git show "$rmain:registry/main-ci-exceptions.json" 2>/dev/null || true)"
fi
[ -n "$exsrc" ] || exsrc='{"schema":"main-ci-exceptions/1","exceptions":[]}'
total=0; covered=0
for j in "${jobs[@]}"; do
  nm="$(pfx "$j") ($j)"
  row="$(printf '%s' "$crs" | jq -r --arg n "$nm" '[.rows[] | select(.name==$n)] | .[0] | if . then ([.status, (.conclusion // ""), (.summary // "")] | @tsv) else "" end')"
  [ -n "$row" ] || continue
  IFS=$'\t' read -r rst rco resc <<<"$row"
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
    covered=$((covered+1))
  done
done
if [ "$MODE" != "no-base" ]; then
  [ "$(git ls-remote "$TGT" refs/heads/main | cut -f1)" = "$rmain" ] || pf "движение базы: запуск не актуален"
fi
printf 'gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo (%s): jobs %s/%s исполнено, находки %s/%s\n' \
  "$p" "${#jobs[@]}" "${#jobs[@]}" "$covered" "$total" >&2
exit 0
EOCORE

gen_stub() {  # <имя> <mode>
  mkdir -p "$WORK/$1"
  printf '%s' "$CORE" | sed "s/__MODE__/$2/" > "$WORK/$1/gitw_preflight_071.sh"
  chmod +x "$WORK/$1/gitw_preflight_071.sh"
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
printf 'ИТОГ стаб-пак 100: rc=%s\n' "$itog"
exit "$itog"
