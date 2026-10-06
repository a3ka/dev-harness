# fixtures/ci_b_087/_toy.sh — каркас toy-миров батареи 087 (НЕ фикстура, source-only).
# Подключают: fixtures/ci_b_087/red_ci_b_087.sh, fixtures/_krasnye_087.sh,
# fixtures/parsing_hygiene_battery/profiles/ci_klass.sh.
#
# Даёт: t87_missing_subjects (г0), t87_setup (toy-мир + bare-цель + поддельный curl),
# t87_art/t87_arts/t87_runs (JSON ответов API в памяти батареи), t87_fake_* (управление
# поддельным curl), t87_model_tree (честная модель субъектов для режима --model и
# стаб-пака), t87_h (оракул хеша кодового дерева по определению И-1).
T87_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T87_ORAKUL="$T87_HERE/_orakul.py"
T87_ART='tyazhelyj-'
# импорт оракула не пишет __pycache__ в стерегомое дерево
export PYTHONDONTWRITEBYTECODE=1

# г0: предмет есть ⟺ четыре файла субъекта на месте и реестр несёт ≥1 строку uchet.
t87_missing_subjects() {  # <корень> → stdout: отсутствующее через пробел (пусто — всё есть)
  local r="$1" f miss=""
  for f in scripts/ci_klass.sh scripts/ci_vesa.sh scripts/run_ci_lane.sh registry/ci-steps.tsv; do
    [ -f "$r/$f" ] || miss="$miss $f"
  done
  if [ -f "$r/registry/ci-steps.tsv" ] && ! grep -q $'^uchet\t' "$r/registry/ci-steps.tsv"; then
    miss="$miss registry/ci-steps.tsv:uchet"
  fi
  printf '%s' "${miss# }"
}

t87_git() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git "$@"; }

# t87_setup <каталог> — строит мир: $T87_W (toy-репо, переменные T87_<ключ>=sha),
# $T87_O (bare-цель для предполёта), $T87_CG (клон с github-origin для check_ci_gate),
# $T87_BIN/curl (поддельный), $T87_FAKE (ответы и журнал URL).
t87_setup() {
  local d="$1" k v
  T87_W="$d/w"; T87_O="$d/o.git"; T87_CG="$d/cg"; T87_BIN="$d/bin"; T87_FAKE="$d/fake"
  mkdir -p "$T87_BIN" "$T87_FAKE/checkruns" || return 1
  local shas
  shas="$(python3 "$T87_ORAKUL" world "$T87_W")" || return 1
  while IFS='=' read -r k v; do
    [[ "$k" =~ ^[A-Za-z0-9_]+$ && "$v" =~ ^[0-9a-f]{40}$ ]] || return 1
    printf -v "T87_$k" '%s' "$v"
  done <<< "$shas"
  t87_git clone -q --bare "$T87_W" "$T87_O" || return 1
  t87_git clone -q "$T87_W" "$T87_CG" || return 1
  t87_git -C "$T87_CG" remote set-url origin https://github.com/toy/repo.git || return 1
  cat > "$T87_BIN/curl" <<'CURL'
#!/usr/bin/env bash
# Поддельный curl батареи 087: журнал URL + ответ по виду запроса из $T87_FAKE.
url=""
for a in "$@"; do url="$a"; done
printf '%s\n' "$url" >> "$T87_FAKE/log"
case "$url" in
  */actions/artifacts\?*)
    if [ -f "$T87_FAKE/fail_artifacts" ]; then printf 'curl: (7) Failed to connect\n' >&2; exit 7; fi
    if [ -f "$T87_FAKE/artifacts.json" ]; then cat "$T87_FAKE/artifacts.json"
    else printf '{"total_count":0,"artifacts":[]}\n'; fi ;;
  */actions/runs\?*)
    if [ -f "$T87_FAKE/runs.json" ]; then cat "$T87_FAKE/runs.json"
    else printf '{"total_count":0,"workflow_runs":[]}\n'; fi ;;
  */check-runs*)
    s="${url%%/check-runs*}"; s="${s##*/}"
    if [ -f "$T87_FAKE/checkruns/$s.json" ]; then cat "$T87_FAKE/checkruns/$s.json"
    else printf '{"total_count":0,"check_runs":[]}\n'; fi ;;
  *) printf 'curl: (22) неожиданный URL %s\n' "$url" >&2; exit 22 ;;
esac
CURL
  chmod +x "$T87_BIN/curl"
  export T87_FAKE
}

t87_fake_reset() { rm -f "$T87_FAKE/artifacts.json" "$T87_FAKE/runs.json" "$T87_FAKE/fail_artifacts" "$T87_FAKE/log"; rm -f "$T87_FAKE/checkruns/"*.json; }
t87_fake_log_has() { [ -f "$T87_FAKE/log" ] && grep -q -- "$1" "$T87_FAKE/log"; }

# JSON (в памяти батареи): артефакт / список / чек-раны
t87_art() {  # <имя> <head_sha> [expired=false] [repository_id=1] [head_repository_id=1]
  printf '{"name":"%s","expired":%s,"workflow_run":{"id":7,"repository_id":%s,"head_repository_id":%s,"head_sha":"%s"}}' \
    "$1" "${3:-false}" "${4:-1}" "${5:-1}" "$2"
}
t87_arts() {  # <объект>... → artifacts.json
  local IFS=,
  printf '{"total_count":%d,"artifacts":[%s]}\n' "$#" "$*" > "$T87_FAKE/artifacts.json"
}
t87_runs() {  # <sha> <имя:вывод>... → checkruns/<sha>.json
  local s="$1" out="" p
  shift
  for p in "$@"; do out="$out${out:+,}{\"name\":\"${p%%:*}\",\"status\":\"completed\",\"conclusion\":\"${p#*:}\"}"; done
  printf '{"total_count":%d,"check_runs":[%s]}\n' "$#" "$out" > "$T87_FAKE/checkruns/$s.json"
}
t87_pr_runs_green() {
  printf '{"total_count":1,"workflow_runs":[{"event":"pull_request","conclusion":"success"}]}\n' > "$T87_FAKE/runs.json"
}

t87_h() { python3 "$T87_ORAKUL" hash "$T87_W" "$1"; }  # оракул хеша кодового дерева (И-1)

# t87_model_tree <каталог> <репо> — честная модель субъектов (режим --model, стаб-пак):
# модели ci_klass/check_ci_gate/run_ci_lane/ci_vesa, ci.yml, реестр с uchet/legkij и живой
# предполёт 071 с блоком чека 5 перед «# ── чек (1)».
t87_model_tree() {
  local m="$1" repo="$2" md="$T87_HERE/model"
  mkdir -p "$m/scripts" "$m/registry" "$m/.github/workflows" || return 1
  cp "$md/ci_klass.sh" "$md/check_ci_gate.sh" "$md/run_ci_lane.sh" "$md/ci_vesa.sh" "$m/scripts/" || return 1
  cp "$md/ci.yml" "$m/.github/workflows/ci.yml" || return 1
  python3 - "$repo/scripts/gitw_preflight_071.sh" "$md/predpolet_chek5.sh" "$m/scripts/gitw_preflight_071.sh" <<'PY' || return 1
import sys
src, blk, dst = sys.argv[1:4]
lines = open(src, encoding='utf-8').read().split('\n')
at = [i for i, l in enumerate(lines) if l.startswith('# ── чек (1)')]
if len(at) != 1:
    sys.exit('строк, начинающихся «# ── чек (1)», %d ≠ 1 в %s' % (len(at), src))
block = open(blk, encoding='utf-8').read().rstrip('\n').split('\n')
open(dst, 'w', encoding='utf-8').write('\n'.join(lines[:at[0]] + block + lines[at[0]:]))
PY
  {
    printf 'lanes\t6\n'
    python3 "$T87_ORAKUL" reg-text | grep $'^uchet\t'
    printf 'step\tcheck:gen\t15\tnpm run check:gen\n'
    printf 'step\tcheck:ids-family\t5\tbash scripts/check_ids.sh\n'
    printf 'step\tcheck:skills\t15\tnpm run check:skills\n'
    local k
    for k in check:charter check:zones check:ids check:protected check:nabludenia check:contract-frozen; do
      printf 'legkij\t%s\t5\tnpm run %s\n' "$k" "$k"
    done
    printf 'shard\tap1\tcheck_ci_gate check_runner_hygiene\n'
    printf 'shard\tap2\tcheck_scope_select freeze_contract\n'
  } > "$m/registry/ci-steps.tsv"
  chmod +x "$m/scripts/"*.sh
}
