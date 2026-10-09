#!/usr/bin/env bash
# Клетка 4 (И-4, «Выход» п.3) контракта 093.
# ПРЕДМЕТ: живой запуск сессии orch-loop; среда, передаваемая в scope-границу
# сессии (что systemd-run отдаёт ребёнку), НЕ содержит publication-креденшл
# (переменных и путей rw-ключа). Стаб s3 «кредит-в-среде» экспортирует
# GIT_SSH_COMMAND/GITHUB_TOKEN до запуска — на нём клетка красна (Н-196 жив).
# Наблюдение — на границе systemd-run: шим пишет env-дамп ДО exec ( env сессии),
# прецедент 058/060 env-факта. Субъектные rc не судятся: предмет клетки —
# ЧИСТОТА среды, а не исход запуска.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-4-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

mkdir -p "$SCRATCH/bin" "$SCRATCH/repo" "$SCRATCH/home"
cd "$SCRATCH/repo" || exit 2
[ -f HANDOFF.md ] || printf '# stub handoff\n' > HANDOFF.md

# toy-HOME с rw-identity (rw-SSH-ключ публикации).
mkdir -p "$SCRATCH/home/.ssh"
printf '%s\n' '-----BEGIN RSA PRIV KEY-----' 'MOCKED' '-----END RSA PRIV KEY-----' > "$SCRATCH/home/.ssh/github-rw-cwd"
chmod 600 "$SCRATCH/home/.ssh/github-rw-cwd"
RW_PATH="$SCRATCH/home/.ssh/github-rw-cwd"

# Shim systemd-run: env-дамп границы сессии, затем честный exec.
printf '%s\n' '#!/usr/bin/env bash' \
  'if [ "$1" = "--user" ] && [ "$2" = "--scope" ]; then' \
  '  shift 2' \
  '  while [ $# -gt 0 ] && [ "$1" != "--" ]; do shift; done' \
  '  if [ "$1" = "--" ]; then shift; fi' \
  "env > '$SCRATCH/scope_env'" \
  '  exec "$@"' \
  'fi' \
  'exit 0' > "$SCRATCH/bin/systemd-run"
chmod 755 "$SCRATCH/bin/systemd-run"

# Стаб-воркшоп (команда сессии): если исполнен — пишет факт своей среды.
printf '%s\n' '#!/usr/bin/env bash' \
  "env > '$SCRATCH/ws_env'" \
  'exit 0' > "$SCRATCH/workshop"
chmod 755 "$SCRATCH/workshop"

# Запуск субъекта с ЧИСТОЙ от креденшл средой (честный код не должен их
# создавать; стаб s3 — экспортирует сам, клетка это и ловит).
env -u GIT_SSH_COMMAND -u GITHUB_TOKEN \
  PATH="$SCRATCH/bin:$PATH" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_N=0 \
  timeout 30 bash "$SUBJ" >"$SCRATCH/subj_out" 2>&1 || true

if [ ! -f "$SCRATCH/scope_env" ]; then
  printf 'КРАСНО: субъект не дошёл до границы сессии (systemd-run не вызван) — нет env-дампа\n' >&2
  exit 1
fi
if grep -Eq '^(GIT_SSH_COMMAND|GITHUB_TOKEN)=' "$SCRATCH/scope_env"; then
  printf 'КРАСНО: publication-креденшл в среде сессии (И-4, Н-196 жив):\n%s\n' \
    "$(grep -E '^(GIT_SSH_COMMAND|GITHUB_TOKEN)=' "$SCRATCH/scope_env")" >&2
  exit 1
fi
if grep -Fq "$RW_PATH" "$SCRATCH/scope_env"; then
  printf 'КРАСНО: путь rw-ключа публикации в среде сессии (И-4): %s\n' "$RW_PATH" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-4): среда сессии без publication-креденшл и путей rw-ключа (И-4)\n' >&2
exit 0
