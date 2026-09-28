#!/usr/bin/env bash
# verify_055_r3.sh — живая приёмка фикса 055-r3 (адверсарий круг 3).
#
#   (а) repro гонки адверсария: lock-каталог без pid-файла + второй
#       live-старт → отказ W3 (НЕ rm -rf живого лока, НЕ тихий пропуск).
#   (б) 64 параллельных live-старта → ровно 1 успех (повтор 2 раза).
#
# Использование:
#   bash fixtures/workshop_project/_verify_055_r3.sh
#
# rc 0 — оба сценария прошли; rc 1 — регресс или сбой.
#
# Зона implementer (frozen/055/1) — этот файл под workshop_project/.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(cd "$HERE/../.." && pwd -P)"
WORKSHOP="$ROOT/workshop"
[ -f "$WORKSHOP" ] || { printf 'ОТКАЗ: нет workshop: %s\n' "$WORKSHOP" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'ОТКАЗ: нет git\n' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { printf 'ОТКАЗ: нет jq\n' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { printf 'ОТКАЗ: нет sha256sum\n' >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
fail() { printf 'FAIL %s: %s\n' "$1" "$2" >&2; exit 1; }

# ── toy-мир (как в клетках h1..h17 red_izoljacija_projectid.sh) ──────────────
layer_make() {
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"%s","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git@host:p1.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}' "$2" > "$1/registry/harness-project.json"
}
repo_make() {
  local r="$1" rid="$2"
  mkdir -p "$r/config"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  printf '{"schemaVersion":1,"repoId":"%s","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' "$rid" > "$r/harness.project.json"
  printf '{"version":"v10"}\n' > "$r/config/harness_pin.json"
  printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$r/.env"
}

# Стаб-omp (как в клетках h7/h8) — субъект, которого exec'ит workshop.
SHIMDIR="$WORK/shimbin"
mkdir -p "$SHIMDIR"
cat > "$SHIMDIR/omp" <<'SHIM'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/v10\n'; exit 0; fi
printf 'pid=%s\n' "$$" > "$SHIM_OUT"
exit 0
SHIM
chmod +x "$SHIMDIR/omp"

LAYER="$WORK/layer"
REPO="$WORK/repo"
layer_make "$LAYER" p1
repo_make "$REPO" r1

LOCK_HASH8="$(printf '%s' "$(cd "$REPO" && pwd -P)" | sha256sum | cut -c1-8)"
LOCK_FILE="$WORK/state/dev-harness-projects/p1/sessions/${LOCK_HASH8}.lock"

# ── (а) repro: lock-каталог без pid-файла + второй live → W3 ─────────────────
printf '(а) repro stale-delete race ... '
mkdir -p "$LOCK_FILE"
[ -d "$LOCK_FILE" ] || fail 'a' "не удалось создать $LOCK_FILE"
[ ! -f "$LOCK_FILE/pid" ] || fail 'a' "pid-файл уже есть в $LOCK_FILE/pid"

out_a="$(env PATH="$SHIMDIR:$PATH" XDG_STATE_HOME="$WORK/state" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
  ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
  bash "$WORKSHOP" "$REPO" 2>&1)"
rc_a=$?

[ "$rc_a" -eq 1 ] || fail 'a' "ожидался rc=1, получен rc=$rc_a; output=$out_a"
printf '%s' "$out_a" | grep -Fq "уже идёт сессия" \
  || fail 'a' "W3-фраза не найдена; output=$out_a"
printf '%s' "$out_a" | grep -Fq "pid не объявлен" \
  || fail 'a' "в W3 не указано, что pid не объявлен (race window); output=$out_a"
# Каталог НЕ должен быть удалён — мы не стираем чужой живой лок.
[ -d "$LOCK_FILE" ] || fail 'a' "lock-каталог удалён (rm -rf) — регресс stale-delete"
# Каталог должен остаться пустым (без pid) — мы не подменяли владельца.
[ ! -f "$LOCK_FILE/pid" ] || fail 'a' "pid-файл создан параллельным стартом — регресс"
echo "OK (W3 + каталог сохранён)"

# Убираем лок перед (б) — иначе 64 параллельных старта увидят чужой лок.
rm -rf "$LOCK_FILE"
rm -rf "$WORK/state"

# ── (б) 64 параллельных live-старта → ровно 1 успех (повтор 2 раза) ─────────
# Использует реальный workshop (НЕ stub). shim-omp спит 60с — больше
# длительности раунда — чтобы старт-«победитель» удерживал лок всё
# время подсчёта (frozen Граница-4 «мёртвый → замена»): иначе
# запаздавший стартёр увидел бы мёртвый pid и захватил лок вторым.
cat > "$SHIMDIR/omp" <<'SHIM'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/v10\n'; exit 0; fi
printf 'pid=%s\n' "$$" > "$SHIM_OUT"
if [ -n "${SHIM_SLEEP:-}" ]; then sleep "$SHIM_SLEEP"; fi
exit 0
SHIM
chmod +x "$SHIMDIR/omp"

parallel_round() { # $1=номер раунда
  local round="$1"
  local tmpbase="$WORK/r$round"
  local i succ=0
  rm -rf "$tmpbase" "$WORK/p$round.rc."* 2>/dev/null
  mkdir -p "$tmpbase"
  for i in $(seq 1 64); do
    (env PATH="$SHIMDIR:$PATH" XDG_STATE_HOME="$tmpbase" HARNESS_PROJECT_LAYER_ROOT="$LAYER" \
      ZAI_API_KEY=toy-key MINIMAX_API_KEY=toy-key METERING_PROXY_TOKEN=toy-token \
      SHIM_SLEEP=60 SHIM_OUT="$WORK/p$round.p.$i" \
      bash "$WORKSHOP" "$REPO" >/dev/null 2>&1; \
      printf '%s\n' "$?" > "$WORK/p$round.rc.$i") &
  done
  wait
  for i in $(seq 1 64); do
    if [ "$(cat "$WORK/p$round.rc.$i" 2>/dev/null || echo 99)" = "0" ]; then
      succ=$((succ+1))
    fi
  done
  rm -rf "$tmpbase" "$WORK/p$round.rc."* 2>/dev/null
  printf '  раунд %s: succ=%s/64 (ожидалось 1)\n' "$round" "$succ"
  [ "$succ" -eq 1 ] || fail 'б' "раунд $round: succ=$succ, ожидалось 1"
}

printf '(б) 64 параллельных live-старта (2 раунда) ...\n'
parallel_round 1
parallel_round 2
echo "(б) OK (оба раунда ровно 1 успех)"

echo
echo 'итог 055-r3: rc=0 (оба сценария прошли)'
exit 0
