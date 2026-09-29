#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Красная батарея контракта 060 — самодостаточность репо (II-2 д/е/ж, Н-167
# Б-1/Б-7): mint номера контракта, реестр заморозок и черновики болей проектной
# сессии ведутся НА РЕПО-СТОРОНЕ (HARNESS_WORKFLOW_ROOT), а не в очередях
# харнесса.
#
# ЧЕСТНАЯ часть (живые скрипты HEAD из песочницы-КОПИИ харнесса — реальное
# дерево не трогается ни одним прогоном): к1-к5, к7 — КРАСНЫЕ до реализации,
# зелёные после. КОНТРОЛЬНЫЕ зелёные-всегда: к6 (env не установлен — дефолтная
# ветвь жива), к6б (явный корень-аргумент сильнее env).
#
# Грамматика freeze (проверена прогоном на HEAD): заморозка требует коммита
# предмета, непустой причины и вердикта `verdicts/critic/contracts-<NNN>-v1.md`
# с первой строкой `accept` — toy-репо несут эти файлы. next_id берёт максимум
# ПО ФАЙЛАМ тоже: toy минта не содержит номерных контрактов (иначе выдаст 003,
# а не 001).
#
# СТАБ-ПАК (Н-39): обманные реализации, умирающие ровно на своих клетках;
# привязка стабов к ветвям — ЭТОТ код, не проза контракта. Каждый стаб без
# ручки честен на своём сценарии (диффпроба), с ручкой — расходится с честной
# реализацией ровно на клетке смерти.
#
# rc: 0 ⟺ стаб-пак пойман весь ∧ честные клетки зелёные ∧ контрольные зелёные
# ∧ стерегомое дерево харнесса не тронуто. На HEAD ожидается rc 1 (красная —
# предмет отсутствует). Скрипт не печатает PASS — только счёт просмотренного.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail

BATTERY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$BATTERY_DIR/../.." && pwd)}"

# ── снимки стерегомого дерева (реального) — сверка в конце, прогоны их не трогают ──
real_id_before="$(git -C "$ROOT" for-each-ref refs/tags/id/ 2>/dev/null)"
real_reg="$ROOT/registry/contracts.tsv"
real_reg_before="$(sha256sum "$real_reg" 2>/dev/null || printf 'ABSENT')"
real_nab="$ROOT/NABLIUDENIA.md"
real_nab_before="$(sha256sum "$real_nab" 2>/dev/null || printf 'ABSENT')"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red060.XXXXXX")"
POOL_DIR="${TMPDIR:-/tmp}/dev-harness-nabludenia/drafts"
list_pool() { find "${TMPDIR:-/tmp}/dev-harness-nabludenia/drafts" -type f 2>/dev/null | sort; }
POOL_BEFORE="$(list_pool)"
cleanup() {
  # уборка следов в машинном пуле черновиков (до-реализационные/стабовые прогоны
  # пишут туда — файлы перечислены точно, чужие не трогаем)
  list_pool | while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf '%s\n' "$POOL_BEFORE" | grep -xFq "$f" || rm -f "$f"
  done
  rm -rf "$WORK"
}
trap cleanup EXIT

R1='HARNESS WORKFLOW: номер контракта, реестр заморозок и черновики болей ведутся на репо-стороне — НЕ в журналах и очередях харнесса'
N1P='workflow ОТКАЗ: HARNESS_WORKFLOW_ROOT обязан быть абсолютным путём, получен: '

# ── toy-репо: git identity локально, коммит; номерных контрактов НЕТ (для минта) ──
mk_toy_mint() {
  local d="$1"
  git init -q "$d"
  git -C "$d" config user.name toy
  git -C "$d" config user.email toy@toy.local
  printf 'toy\n' >"$d/README.md"
  git -C "$d" add -A
  git -C "$d" commit -qm init
}
# ── toy-репо под freeze: предмет + вердикт критика (грамматика freeze HEAD) ──
mk_toy_freeze() {
  local d="$1" nnn="$2"
  git init -q "$d"
  git -C "$d" config user.name toy
  git -C "$d" config user.email toy@toy.local
  mkdir -p "$d/contracts" "$d/verdicts/critic" "$d/.github/workflows" "$d/config"
  printf '# toy %s\n' "$nnn" >"$d/contracts/$nnn-x.md"
  printf 'accept\n' >"$d/verdicts/critic/contracts-$nnn-v1.md"
  # грамматика freeze HEAD (проверено прогоном): precision-гейт 043 требует
  # .github/workflows и config/ci_parity_exceptions.txt; run-шагов нет — паритет пуст
  printf 'on: [push]\njobs:\n  x:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@v4\n' >"$d/.github/workflows/ci.yml"
  printf '# без исключений\n' >"$d/config/ci_parity_exceptions.txt"
  printf '{"name":"toy","scripts":{}}\n' >"$d/package.json"
  git -C "$d" add -A
  git -C "$d" commit -qm init
}

# ── песочница: КОПИЯ харнесса (git-репо со scripts/ и своими контрактами) ─────
COPY="$WORK/harness-copy"
git init -q "$COPY"
git -C "$COPY" config user.name toy
git -C "$COPY" config user.email toy@toy.local
cp -r "$ROOT/scripts" "$COPY/scripts"
mkdir -p "$COPY/contracts"
printf '# копия 001\n' >"$COPY/contracts/001-x.md"
printf '# копия 002\n' >"$COPY/contracts/002-y.md"
git -C "$COPY" add -A
git -C "$COPY" commit -qm init

TOY_M="$WORK/toy_mint";  mk_toy_mint "$TOY_M"
TOY_F="$WORK/toy_freeze"; mk_toy_freeze "$TOY_F" 001
TOYB="$WORK/toyB";       mk_toy_freeze "$TOYB" 002

# ── счётчики ──────────────────────────────────────────────────────────────────
honest_total=0; honest_green=0; honest_fail=""
hcell() { # hcell <имя> <функция>
  honest_total=$((honest_total+1))
  if "$2"; then honest_green=$((honest_green+1)); else honest_fail="$honest_fail $1"; fi
}
stub_total=0; stub_caught=0; stub_esc=""
scell() { # scell <имя> <функция-детекции>; детекция rc0 = дефект НАБЛЮДЁН (пойман)
  stub_total=$((stub_total+1))
  if "$2"; then stub_caught=$((stub_caught+1)); else stub_esc="$stub_esc $1"; fi
}

# ── ЧЕСТНЫЕ КЛЕТКИ (живые скрипты из КОПИИ; env указывает на toy) ─────────────

k1() { # (д) mint: тег 001 в toy ∧ очередь харнесса-копии НЕ тронута
  local before out rc
  before="$(git -C "$COPY" for-each-ref refs/tags/id/)"
  out="$(HARNESS_WORKFLOW_ROOT="$TOY_M" bash "$COPY/scripts/next_id.sh" CONTRACT 2>/dev/null)"; rc=$?
  [ $rc -eq 0 ] || return 1
  [ "$out" = "001" ] || return 1
  git -C "$TOY_M" for-each-ref --format='%(refname)' refs/tags/id/ | grep -Fxq 'refs/tags/id/CONTRACT/001' || return 1
  [ "$(git -C "$COPY" for-each-ref refs/tags/id/)" = "$before" ] || return 1
}
k2() { # (д) серия: второй номер 002 тоже на репо-стороне
  local out rc
  out="$(HARNESS_WORKFLOW_ROOT="$TOY_M" bash "$COPY/scripts/next_id.sh" CONTRACT 2>/dev/null)"; rc=$?
  [ $rc -eq 0 ] || return 1
  [ "$out" = "002" ] || return 1
  git -C "$TOY_M" for-each-ref --format='%(refname)' refs/tags/id/ | grep -Fxq 'refs/tags/id/CONTRACT/002' || return 1
}
k3() { # (е) freeze: строка реестра + самокоммит в toy ∧ реестр копии байт-в-байт
  local before after
  before="$(sha256sum "$COPY/registry/contracts.tsv" 2>/dev/null || printf 'ABSENT')"
  HARNESS_WORKFLOW_ROOT="$TOY_F" bash "$COPY/scripts/freeze_contract.sh" contracts/001-x.md "k3" >/dev/null 2>&1 || return 1
  grep -qF '001 → ' "$TOY_F/registry/contracts.tsv" 2>/dev/null || return 1
  git -C "$TOY_F" show --stat --oneline HEAD -- registry/contracts.tsv 2>/dev/null | grep -qF 'registry/contracts.tsv' || return 1
  after="$(sha256sum "$COPY/registry/contracts.tsv" 2>/dev/null || printf 'ABSENT')"
  [ "$before" = "$after" ] || return 1
}
k4() { # (ж) draft: черновик в <toy>/.harness/nabludenia-drafts/ ∧ машинный пул без новых
  local before
  before="$(list_pool)"
  # уникальный FAIL-хвост прогонa: дедуп черновиков не должен съесть красноту
  HARNESS_WORKFLOW_ROOT="$TOY_M" bash "$COPY/scripts/draft_nabludenia.sh" 'scripts/check_x060.sh' "FAIL k4 $WORK" >/dev/null 2>&1 || return 1
  [ -n "$(find "$TOY_M/.harness/nabludenia-drafts" -type f 2>/dev/null)" ] || return 1
  [ "$(list_pool)" = "$before" ] || return 1
}
k5a() { # (Граница-3) относительный env → rc 1 + N1 у next_id
  local rc
  HARNESS_WORKFLOW_ROOT='relative/path' bash "$COPY/scripts/next_id.sh" CONTRACT >/dev/null 2>"$WORK/k5a.err"; rc=$?
  [ $rc -eq 1 ] || return 1
  grep -qF "${N1P}relative/path" "$WORK/k5a.err" || return 1
}
k5b() { # (Граница-3) относительный env → rc 1 + N1 у freeze
  local rc
  HARNESS_WORKFLOW_ROOT='relative/path' bash "$COPY/scripts/freeze_contract.sh" contracts/001-x.md 'k5b' >/dev/null 2>"$WORK/k5b.err"; rc=$?
  [ $rc -eq 1 ] || return 1
  grep -qF "${N1P}relative/path" "$WORK/k5b.err" || return 1
}
k6() { # КОНТРОЛЬ (зелёная всегда): env не установлен → дефолтная ветвь резервирует в HERE-дефолте (копия)
  local out rc
  out="$(env -u HARNESS_WORKFLOW_ROOT bash "$COPY/scripts/next_id.sh" CONTRACT 2>/dev/null)"; rc=$?
  [ $rc -eq 0 ] || return 1
  case "$out" in ''|*[!0-9]*) return 1 ;; esac
  git -C "$COPY" for-each-ref --format='%(refname)' refs/tags/id/ | grep -Fxq "refs/tags/id/CONTRACT/$out" || return 1
}
k6b() { # КОНТРОЛЬ (зелёная всегда): явный корень-аргумент $3 сильнее env
  HARNESS_WORKFLOW_ROOT="$TOY_F" bash "$COPY/scripts/freeze_contract.sh" contracts/002-x.md 'k6b' "$TOYB" >/dev/null 2>&1 || return 1
  grep -qF '002 → ' "$TOYB/registry/contracts.tsv" 2>/dev/null || return 1
  if [ -f "$TOY_F/registry/contracts.tsv" ] && grep -qF '002 → ' "$TOY_F/registry/contracts.tsv"; then return 1; fi
}
k7() { # (И-1) лаунчер: probe несёт WORKFLOW/TOOLS и блок R1-R3 в промпте
  local toy7 layer out rc p
  toy7="$WORK/toy7"; layer="$WORK/layer"
  git init -q "$toy7"
  git -C "$toy7" config user.name toy
  git -C "$toy7" config user.email toy@toy.local
  mkdir -p "$toy7/.github/workflows" "$toy7/registry" "$toy7/config"
  printf 'toy7\n' >"$toy7/README.md"
  printf 'ci: toy7\n' >"$toy7/.github/workflows/ci.yml"
  cat >"$toy7/harness.project.json" <<'EOF'
{"schemaVersion":1,"repoId":"toy060","language":"typescript","ci":{"workflow":".github/workflows/ci.yml"},"projectLayer":{"version":"1.0.0","profilePath":"registry/harness-project.json"}}
EOF
  printf '{"version":"0.0.0-toy"}\n' >"$toy7/config/harness_pin.json"
  printf 'METERING_PROXY_URL=http://127.0.0.1:9\n' >"$toy7/.env"
  git -C "$toy7" add -A
  git -C "$toy7" commit -qm init
  git -C "$toy7" config receive.denyCurrentBranch refuse
  mkdir -p "$layer/registry"
  cat >"$layer/registry/harness-project.json" <<'EOF'
{"schemaVersion":1,"version":"1.0.0","projectId":"toy060","workspaceId":"ws060"}
EOF
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" HARNESS_SCRATCH="$WORK/scratch" \
    bash "$ROOT/workshop" --probe "$toy7" 2>"$WORK/k7.err")"; rc=$?
  [ $rc -eq 0 ] || return 1
  printf '%s\n' "$out" | grep -qF "WORKFLOW: $toy7" || return 1
  printf '%s\n' "$out" | grep -qF 'TOOLS: ' || return 1
  p="$(printf '%s\n' "$out" | sed -n 's/^PROMPT: //p')"
  { [ -n "$p" ] && [ -f "$p" ]; } || return 1
  grep -Fxq "$R1" "$p" || return 1
  grep -qF "HARNESS_WORKFLOW_ROOT=$toy7" "$p" || return 1
  grep -qF 'HARNESS_TOOLS_ROOT=' "$p" || return 1
}

hcell к1-д-mint-на-репо-стороне k1
hcell к2-д-серия-002 k2
hcell к3-е-реестр-в-toy k3
hcell к4-ж-черновики-в-toy k4
hcell к5а-N1-next_id k5a
hcell к5б-N1-freeze k5b
hcell к6-контроль-дефолт k6
hcell к6б-контроль-аргумент-сильнее-env k6b
hcell к7-лаунчер-probe k7

# ── СТАБ-ПАК (Н-39: обман ровно одной ручкой; привязка к клеткам — этот код) ──
# Стабы лежат в <root>/scripts/<имя> — так «сторона стаба-харнесса» = сам STUBS
# (dirname/../.. от scripts/<имя>), как настоящие скрипты от своего корня.
STUBS="$WORK/stubs"
mkdir -p "$STUBS/scripts" "$STUBS/contracts"
printf 'stubs\n' >"$STUBS/README.md"
printf '# stub 002\n' >"$STUBS/contracts/002-x.md"
git init -q "$STUBS"
git -C "$STUBS" config user.name toy
git -C "$STUBS" config user.email toy@toy.local
git -C "$STUBS" add -A
git -C "$STUBS" commit -qm init

cat >"$STUBS/scripts/next_id" <<'EOF'
#!/usr/bin/env bash
# стаб next_id (060): честен = уважает HARNESS_WORKFLOW_ROOT, N1 на относительном
set -uo pipefail
here="${HARNESS_WORKFLOW_ROOT:-}"
if [ -n "$here" ] && [ "${here#/}" = "$here" ]; then
  if [ "${STUB_RELATIVE_OK:-0}" != "1" ]; then
    printf 'workflow ОТКАЗ: HARNESS_WORKFLOW_ROOT обязан быть абсолютным путём, получен: %s\n' "$here" >&2
    exit 1
  fi
fi
if [ "${STUB_ENV_IGNORED:-0}" = "1" ]; then here="$(cd "$(dirname "$0")/.." && pwd)"; fi
[ -n "$here" ] || here="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$here" rev-parse --git-dir >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: %s не репозиторий git — выдавать номера негде\n' "$here" >&2; exit 2; }
max="$(git -C "$here" tag -l 'id/CONTRACT/*' | sed 's|id/CONTRACT/||; s/^0*//' | sort -n | tail -1)"
n=$(( ${max:-0} + 1 )); nnn="$(printf '%03d' "$n")"
git -C "$here" tag "id/CONTRACT/$nnn" >/dev/null 2>&1 || exit 1
printf '%s\n' "$nnn"
EOF
cat >"$STUBS/scripts/freeze" <<'EOF'
#!/usr/bin/env bash
# стаб freeze (060): честен = ROOT-лестница $3 > env > дефолт, N1 на относительном
set -uo pipefail
TARGET="${1:-}"; ARG_ROOT="${3:-}"
root="$ARG_ROOT"
if [ -z "$root" ]; then root="${HARNESS_WORKFLOW_ROOT:-}"; fi
if [ -n "$root" ] && [ "${root#/}" = "$root" ]; then
  if [ "${STUB_RELATIVE_OK:-0}" != "1" ]; then
    printf 'workflow ОТКАЗ: HARNESS_WORKFLOW_ROOT обязан быть абсолютным путём, получен: %s\n' "$root" >&2
    exit 1
  fi
fi
if [ "${STUB_FREEZE_NO_ENV:-0}" = "1" ] && [ -z "$ARG_ROOT" ]; then root="$(cd "$(dirname "$0")/.." && pwd)"; fi
[ -n "$root" ] || root="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$root/$TARGET" ] || { printf 'ОТКАЗ: предмет не найден: %s\n' "$root/$TARGET" >&2; exit 1; }
mkdir -p "$root/registry"
nnn="$(basename "$TARGET")"; nnn="${nnn%%-*}"
if ! { [ -f "$root/registry/contracts.tsv" ] && grep -qF "$nnn → " "$root/registry/contracts.tsv"; }; then
  printf '%s → %s\n' "$nnn" "$(printf 'a%.0s' $(seq 1 40))" >>"$root/registry/contracts.tsv"
fi
git -C "$root" add registry/contracts.tsv >/dev/null 2>&1
git -C "$root" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
  commit -qm "freeze: registry $nnn" >/dev/null 2>&1 || true
EOF
cat >"$STUBS/scripts/draft" <<'EOF'
#!/usr/bin/env bash
# стаб draft (060): честен = черновики в <env>/.harness/nabludenia-drafts/
set -uo pipefail
cmd="${1:-}"; head="${2:-}"
if [ "${STUB_DRAFT_SHARED:-0}" = "1" ]; then
  dest="${TMPDIR:-/tmp}/dev-harness-nabludenia/drafts"
else
  dest_root="${HARNESS_WORKFLOW_ROOT:-}"
  [ -n "$dest_root" ] || dest_root="$(cd "$(dirname "$0")/.." && pwd)"
  dest="$dest_root/.harness/nabludenia-drafts"
fi
mkdir -p "$dest"
f="$dest/$(printf '%s' "$cmd$head" | sha256sum | cut -c1-16).md"
printf 'ДАТА · ГЕЙТ %s · FAIL: %s\n' "$cmd" "$head" >"$f"
EOF
cat >"$STUBS/scripts/workshop" <<EOF
#!/usr/bin/env bash
# стаб workshop --probe (060): честен = probe несёт WORKFLOW/TOOLS + блок R1-R3
set -uo pipefail
toy=""
[ "\${1:-}" = "--probe" ] && toy="\${2:-}"
pstate="\${HARNESS_SCRATCH:-\${XDG_STATE_HOME:-\$HOME/.local/state}}/dev-harness-projects/stab060"
mkdir -p "\$pstate/home"
prompt="\$pstate/home/session-prompt-orchestrator.md"
{
  printf 'роль\n\n'
  printf 'правила\n\n'
} >"\$prompt"
if [ "\${STUB_PROMPT_NO_ROUTE:-0}" != "1" ]; then
  printf '%s\n' '$R1' >>"\$prompt"
  printf 'HARNESS_WORKFLOW_ROOT=%s\n' "\$toy" >>"\$prompt"
  printf 'HARNESS_TOOLS_ROOT=%s\n' "\$(cd "\$(dirname "\$0")/.." && pwd)" >>"\$prompt"
  printf 'WORKFLOW: %s\n' "\$toy"
  printf 'TOOLS: %s\n' "\$(cd "\$(dirname "\$0")/.." && pwd)"
fi
printf 'workshop PROBE OK: %s\n' "\$toy"
printf 'PROMPT: %s\n' "\$prompt"
EOF
chmod +x "$STUBS/scripts/next_id" "$STUBS/scripts/freeze" "$STUBS/scripts/draft" "$STUBS/scripts/workshop"

TOYS="$WORK/toy_stubs"; mk_toy_mint "$TOYS"
mkdir -p "$TOYS/contracts"; printf '# toy 002\n' >"$TOYS/contracts/002-x.md"
git -C "$TOYS" add -A; git -C "$TOYS" commit -qm contracts

s1() { # дефект: env игнорируется → номер уходит в очередь стаба-«харнесса»
  local out
  rm -rf "$TOYS/.git/refs/tags/id" 2>/dev/null
  out="$(STUB_ENV_IGNORED=1 HARNESS_WORKFLOW_ROOT="$TOYS" bash "$STUBS/scripts/next_id" 2>/dev/null)" || return 1
  git -C "$TOYS" tag -l 'id/CONTRACT/*' | grep -q . && return 1   # тег НЕ в toy → дефект наблюдён
  git -C "$STUBS" tag -l 'id/CONTRACT/*' | grep -q .              # номер ушёл на сторону стаба
}
s1_diff() {
  rm -rf "$TOYS/.git/refs/tags/id" 2>/dev/null
  HARNESS_WORKFLOW_ROOT="$TOYS" bash "$STUBS/scripts/next_id" >/dev/null 2>&1 || return 1
  git -C "$TOYS" tag -l 'id/CONTRACT/*' | grep -q .
}
s2() { # дефект: относительный env молча принимается
  local rc
  STUB_RELATIVE_OK=1 HARNESS_WORKFLOW_ROOT='relative/path' bash "$STUBS/scripts/next_id" >/dev/null 2>&1; rc=$?
  [ $rc -ne 1 ]
}
s2_diff() {
  local rc
  HARNESS_WORKFLOW_ROOT='relative/path' bash "$STUBS/scripts/next_id" >/dev/null 2>&1; rc=$?
  [ $rc -eq 1 ]
}
s3() { # дефект: freeze игнорирует env → реестр пишется на стороне стаба
  STUB_FREEZE_NO_ENV=1 HARNESS_WORKFLOW_ROOT="$TOYS" bash "$STUBS/scripts/freeze" contracts/002-x.md 's3' >/dev/null 2>&1 || return 1
  if [ -f "$TOYS/registry/contracts.tsv" ] && grep -qF '002 → ' "$TOYS/registry/contracts.tsv"; then return 1; fi
  grep -qF '002 → ' "$STUBS/registry/contracts.tsv" 2>/dev/null
}
s3_diff() {
  HARNESS_WORKFLOW_ROOT="$TOYS" bash "$STUBS/scripts/freeze" contracts/002-x.md 's3d' >/dev/null 2>&1 || return 1
  grep -qF '002 → ' "$TOYS/registry/contracts.tsv" 2>/dev/null
}
s4() { # дефект: черновик уходит в общий машинный пул
  local before
  before="$(list_pool)"
  STUB_DRAFT_SHARED=1 HARNESS_WORKFLOW_ROOT="$TOYS" bash "$STUBS/scripts/draft" 'scripts/check_s4.sh' "FAIL s4 $WORK" >/dev/null 2>&1 || return 1
  [ -z "$(find "$TOYS/.harness/nabludenia-drafts" -type f 2>/dev/null)" ] || return 1  # в toy пусто ∧
  [ "$(list_pool)" != "$before" ]                                                      # пул получил файл
}
s4_diff() {
  HARNESS_WORKFLOW_ROOT="$TOYS" bash "$STUBS/scripts/draft" 'scripts/check_s4d.sh' "FAIL s4d $WORK" >/dev/null 2>&1 || return 1
  [ -n "$(find "$TOYS/.harness/nabludenia-drafts" -type f 2>/dev/null)" ]
}
s5() { # дефект: probe без маршрута (нет WORKFLOW-строк и блока R1-R3 в промпте)
  local out rc p
  out="$(STUB_PROMPT_NO_ROUTE=1 HARNESS_SCRATCH="$WORK/scratch_s5" bash "$STUBS/scripts/workshop" --probe "$TOYS" 2>/dev/null)"; rc=$?
  [ $rc -eq 0 ] || return 1
  if printf '%s\n' "$out" | grep -qF 'WORKFLOW: '; then return 1; fi
  p="$(printf '%s\n' "$out" | sed -n 's/^PROMPT: //p')"
  { [ -n "$p" ] && [ -f "$p" ]; } || return 1
  if grep -Fxq "$R1" "$p"; then return 1; fi
  return 0
}
s5_diff() {
  local out p
  out="$(HARNESS_SCRATCH="$WORK/scratch_s5d" bash "$STUBS/scripts/workshop" --probe "$TOYS" 2>/dev/null)" || return 1
  printf '%s\n' "$out" | grep -qF 'WORKFLOW: ' || return 1
  p="$(printf '%s\n' "$out" | sed -n 's/^PROMPT: //p')"
  grep -Fxq "$R1" "$p"
}

scell s1-env-игнор s1
scell s2-относительный-молча s2
scell s3-freeze-без-env s3
scell s4-общий-пул s4
scell s5-probe-без-маршрута s5
diff_fail=""
for d in s1_diff s2_diff s3_diff s4_diff s5_diff; do
  "$d" || diff_fail="$diff_fail $d"
done

# ── сверка стерегомого дерева (прогоны его не тронули) ────────────────────────
guard_ok=1
[ "$(git -C "$ROOT" for-each-ref refs/tags/id/ 2>/dev/null)" = "$real_id_before" ] || guard_ok=0
[ "$(sha256sum "$real_reg" 2>/dev/null || printf 'ABSENT')" = "$real_reg_before" ] || guard_ok=0
[ "$(sha256sum "$real_nab" 2>/dev/null || printf 'ABSENT')" = "$real_nab_before" ] || guard_ok=0

printf '060: честных клеток %d, зелёных %d, красных: %s\n' "$honest_total" "$honest_green" "${honest_fail:-нет}"
printf '060: стабов %d, поймано %d, ускользнуло: %s\n' "$stub_total" "$stub_caught" "${stub_esc:-нет}"
printf '060: диффпробы стабов без ручек: %s\n' "$([ -z "$diff_fail" ] && printf 'нет' || printf 'ПРОВАЛ%s' "$diff_fail")"
printf '060: стерегомое дерево харнесса: %s\n' "$([ $guard_ok -eq 1 ] && printf 'не тронуто' || printf 'ТРОНУТО')"

[ "$stub_total" -gt 0 ] || { printf '060: ПУСТАЯ выборка стабов — красное\n' >&2; exit 1; }
[ "$honest_total" -gt 0 ] || { printf '060: ПУСТАЯ выборка честных клеток — красное\n' >&2; exit 1; }
[ -z "$diff_fail" ] || exit 1
[ "$stub_caught" -eq "$stub_total" ] || exit 1
[ $guard_ok -eq 1 ] || exit 1
[ "$honest_green" -eq "$honest_total" ] || exit 1
exit 0
