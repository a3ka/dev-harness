# Профиль батареи для scripts/profile_resolver.sh (054, М1) — нормы 041.
# Self-application: резолвер работает на собственных классах 041,
# а батарея судит, что дрейфа нет.
PR_SUBJ="$(cd "$HERE/../.." && pwd -P)/scripts/profile_resolver.sh"

# ── строители toy-мира ────────────────────────────────────────────────────────
layer_make() { # $1=каталог слоя
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]}}}' > "$1/registry/harness-project.json"
}
repo_make() { # $1=каталог репо, $2=extra-json-fragment для репо-слоя (или "")
  local extra="$2"
  if [ -z "$extra" ]; then
    extra_frag=''
  else
    extra_frag=",$extra"
  fi
  mkdir -p "$1/config"
  printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}%s}' "$extra_frag" > "$1/harness.project.json"
}

battery_delimiter_collision() {
  # Делимитер-коллизия: значение содержит байты `-`, `:` и `.` — те, что сами
  # разделяют ключи сообщения. P4 должен назвать путь ключа-точками ЦЕЛИКОМ,
  # не усечённым по первому разделителю.
  local w
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_dc.XXXXXX")"
  layer_make "$w/layer"
  repo_make "$w/repo" '"injected":"v"'
  # Получаем первое попавшееся сообщение об отказе (P4) и сверяем, что оно
  # содержит СЫРОЙ ПУТЬ через точки. У резолвера путь «injected».
  local out rc msg
  out="$(HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo" 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 1 ]; then return 1; fi
  printf '%s\n' "$out" | grep -Fq 'неизвестный ключ repo: injected'

  # PACKS-вариант (контракт 055, И-10): элемент packs с байтами `:` или `"`
  # (те, что грамматика JSON использует как разделители) — отказ должен
  # назвать элемент ЦЕЛИКОМ (не усечённым по первому разделителю).
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_dc_pk.XXXXXX")"
  layer_make "$w/layer"
  repo_make "$w/repo" '"packs":["bad:elem"]'
  out="$(HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 1 ] || return 1
  printf '%s\n' "$out" | grep -Fq 'packs: bad:elem'
}

battery_regex_injection() {
  # Regex-инъекция: путь «unknown-key» (с `-`) — имя ключа с байтом, который
  # похож на разделитель; jq не интерпретирует `-` как regex-метасимвол, имя
  # ходит литерально. Подделка интерпретации привела бы к «не нашёл ключ».
  local w out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_ri.XXXXXX")"
  layer_make "$w/layer"
  repo_make "$w/repo" '"unknown-key":"y"'
  set +e
  out="$(HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo" 2>&1)"
  rc=$?
  set -e
  rm -rf "$w"
  if [ "$rc" -ne 1 ]; then return 1; fi
  # Получено P4 — название ключа в причине ПОЛНОЕ (с дефисом), не режется
  printf '%s' "$out" | grep -Fq 'unknown-key'

  # PACKS-вариант (контракт 055, И-10): элемент-метасимвол `[` (квадратная
  # скобка — типичный regex-метасимвол) отвергается классом
  # `^[a-z0-9][a-z0-9_-]*$`; причина должна назвать ЭЛЕМЕНТ целиком.
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_ri_pk.XXXXXX")"
  layer_make "$w/layer"
  repo_make "$w/repo" '"packs":["[meta"]'
  set +e
  out="$(HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo" 2>&1)"
  rc=$?
  set -e
  rm -rf "$w"
  [ "$rc" -eq 1 ] || return 1
  printf '%s' "$out" | grep -Fq 'packs: [meta'
}

battery_silent_drop() {
  # Молчаливый пропуск: ввод валидный (всё по алфавиту) — резолвер ДОЛЖЕН
  # вернуть rc 0 и JSON на stdout. Молчаливый rc=1 был бы «drop'ом».
  local w out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_sd.XXXXXX")"
  layer_make "$w/layer"
  repo_make "$w/repo" ''
  set +e
  out="$(HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo" 2>&1)"
  rc=$?
  set -e
  rm -rf "$w"
  if [ "$rc" -ne 0 ]; then return 1; fi
  # stdout — JSON (промежуточная переменная обходит SIGPIPE от пайпов с `head`).
  printf '%s' "$out" | jq -e . >/dev/null 2>&1 || return 1
  printf '%s' "$out" | jq -e '.language.value == "rust"' >/dev/null 2>&1 || return 1
  printf '%s' "$out" | jq -e '.projectId.origin == "project"' >/dev/null 2>&1 || return 1

  # PACKS-вариант (контракт 055, И-10): валидный packs ["core"] ДОЛЖЕН
  # присутствовать в выводе побайтово (не потерян, не урезан, не заменён
  # умолчанием — это и есть «молчаливый drop»). Элемент "core" обязан
  # ходить в `packs.value` с origin "repo".
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_sd_pk.XXXXXX")"
  layer_make "$w/layer"
  repo_make "$w/repo" '"packs":["core"]'
  set +e
  out="$(HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo" 2>&1)"
  rc=$?
  set -e
  rm -rf "$w"
  [ "$rc" -eq 0 ] || return 1
  printf '%s' "$out" | jq -e '.packs.value == ["core"] and .packs.origin == "repo"' >/dev/null 2>&1 || return 1
}

battery_self_application_green() {
  # Self-application: прогоняем резолвер НА СЕБЕ (через «эталонные» валидные
  # входы), проверяя, что rc 0 сохраняется на разных разрешённых значениях.
  # Параметр инвариантности — случайные непустые строки своей грамматики.
  local w i cmd test_build repo_id pin
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_self.XXXXXX")"
  layer_make "$w/layer"
  for i in 1 2 3; do
    case "$i" in
      1) test_build="npm test"; repo_id="r-1"; pin="v10" ;;
      2) test_build="cargo test --release"; repo_id="reposix"; pin="v2025-09-27-a" ;;
      3) test_build="pytest tests"; repo_id="r_some.name.v3"; pin="v10.beta" ;;
    esac
    repo_make "$w/repo$i" "\"repoId\":\"${repo_id}\",\"commands\":{\"test\":\"${test_build}\",\"build\":\"y\",\"typecheck\":\"z\",\"lint\":\"w\"},\"projectLayer\":{\"version\":\"${pin}\",\"profilePath\":\"registry/harness-project.json\"}"
    [ -f "$w/layer/registry/harness-project.json" ] && jq '.version = "'"$pin"'"' "$w/layer/registry/harness-project.json" > "$w/layer/_x" && mv "$w/layer/_x" "$w/layer/registry/harness-project.json"
    if ! HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo$i" >/dev/null 2>&1; then
      rm -rf "$w"
      return 1
    fi
  done
  rm -rf "$w"

  # PACKS-вариант (контракт 055, И-10): инвариантность к значениям —
  # разные валидные массивы packs на разных repoId не должны ломать
  # резолвер (rc 0, packs.value побайтово в выводе).
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pr_self_pk.XXXXXX")"
  layer_make "$w/layer"
  for i in 1 2 3; do
    case "$i" in
      1) pk='["a"]' ;;
      2) pk='["x","y","z"]' ;;
      3) pk='[]' ;;
    esac
    repo_make "$w/repo$i" "\"repoId\":\"r$i\",\"packs\":${pk}"
    if ! HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo$i" >/dev/null 2>&1; then
      rm -rf "$w"
      return 1
    fi
    # Исходное packs-значение должно быть видно в выводе.
    HARNESS_PROJECT_LAYER_ROOT="$w/layer" bash "$PR_SUBJ" --repo "$w/repo$i" \
      | jq -e --argjson pk "$pk" '.packs.value == $pk' >/dev/null 2>&1 || { rm -rf "$w"; return 1; }
  done
  rm -rf "$w"
  return 0
}
