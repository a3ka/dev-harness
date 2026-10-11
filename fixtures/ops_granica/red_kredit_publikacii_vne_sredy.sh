#!/usr/bin/env bash
# Клетка 4 (И-4, «Выход» п.3) контракта 093.
# ПРЕДМЕТ (починка Р1-5 круга 1): прежняя редакция сама чистила среду
# (env -u GIT_SSH_COMMAND -u GITHUB_TOKEN) и не давала субъекту HOME с
# rw-ключом — оттого была зелёной и на дореализационном субъекте, и на
# мутанте «rw-путь ключа публикации в env сессии» (M2). Теперь клетка
# моделирует живое условие Н-196: субъект запускается ИЗ СРЕДЫ СТАНЦИИ —
# HOME станции с файлом rw-identity и переменными GIT_SSH_COMMAND /
# GITHUB_TOKEN в env (клетка сеет их сама — это станционное наследие,
# которое честная реализация обязана сессии не передать). Честный код:
#   (а) env-факт РЕБЁНКА сессии (стаб-omp, прецедент 058/060) не содержит
#       publication-креденшл — ни переменных (GIT_SSH_COMMAND, GITHUB_TOKEN,
#       GIT_SSH_KEY_FILE, GH_TOKEN), ни ПУТЕЙ rw-ключа;
#   (б) HOME ребёнка — HOME агента, не станции;
#   (в) сессия идёт через дверь uid (sudo -nu, шим sudo закрывает HOME
#       станции — модель uid≠владельца, арбитраж 093 замер 3) и открытие
#       rw-ключа ребёнком — отказ.
# Дореализационный субъект запускает воркшоп напрямую из станочной среды —
# КРАСНО (а)/(б)/(в). Мутант M2 (export GIT_SSH_KEY_FILE=…rw-ключ) — КРАСНО
# (а): путь rw-ключа в env-факте. Стаб s3 — КРАСНО (а) своими переменными.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-4-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'chmod -R u+rwx "$SCRATCH/home" 2>/dev/null; rm -rf "$SCRATCH"' EXIT

mkdir -p "$SCRATCH/bin" "$SCRATCH/repo" "$SCRATCH/home/.ssh" "$SCRATCH/home/.config" "$SCRATCH/agent_home"
cd "$SCRATCH/repo" || exit 2
[ -f HANDOFF.md ] || printf '# stub handoff\n' > HANDOFF.md

# toy-HOME станции с rw-identity (rw-SSH-ключ публикации) и токеном.
printf '%s\n' '-----BEGIN RSA PRIV KEY-----' 'MOCKED' '-----END RSA PRIV KEY-----' > "$SCRATCH/home/.ssh/github-rw-cwd"
printf 'ghp-toy-station\n' > "$SCRATCH/home/.config/gh-token"
chmod 600 "$SCRATCH/home/.ssh/github-rw-cwd" "$SCRATCH/home/.config/gh-token"
chmod 700 "$SCRATCH/home" "$SCRATCH/home/.ssh" "$SCRATCH/home/.config"
RW_PATH="$SCRATCH/home/.ssh/github-rw-cwd"
TOK_PATH="$SCRATCH/home/.config/gh-token"

# Shim systemd-run: env-дамп границы scope (диагностика), затем честный exec.
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

# Shim sudo — дверь uid (как в клетке 3): свидетель + модель uid≠владельца
# (HOME станции закрыт на время команды агента), затем честный exec.
printf '%s\n' '#!/usr/bin/env bash' \
  'set -u' \
  'if [ "${1:-}" = "-nu" ] && [ $# -ge 3 ]; then' \
  '  tgt="$2"; shift 2' \
  "  printf 'user=%s\\nargv0=%s\\n' \"\$tgt\" \"\$1\" > '$SCRATCH/sudo_fact'" \
  "  chmod 000 '$SCRATCH/home'" \
  '  exec "$@"' \
  'fi' \
  'printf "sudo-шим: ожидается -nu <user> <cmd>\\n" >&2' \
  'exit 1' > "$SCRATCH/bin/sudo"
chmod 755 "$SCRATCH/bin/sudo"

# Агентная команда (шов ORCH_LOOP_AGENT_CMD): env-факт ребёнка + пробы
# открытия rw-ключа и токена станции. Успех = uid владельца станции.
printf '%s\n' '#!/usr/bin/env bash' \
  "env > '$SCRATCH/agent_env'" \
  "cat '$RW_PATH' >/dev/null 2>&1 && printf 'rw_key_open_ok\\n' >> '$SCRATCH/open_witness'" \
  "cat '$TOK_PATH' >/dev/null 2>&1 && printf 'token_open_ok\\n' >> '$SCRATCH/open_witness'" \
  'exit 0' > "$SCRATCH/agent_cmd"
chmod 755 "$SCRATCH/agent_cmd"

# Стаб-воркшоп (команда сессии при прямом запуске, дореализационный путь):
# тот же env-факт и те же пробы открытия.
printf '%s\n' '#!/usr/bin/env bash' \
  "env > '$SCRATCH/ws_env'" \
  "printf 'called\\n' > '$SCRATCH/ws_fact'" \
  "cat '$RW_PATH' >/dev/null 2>&1 && printf 'rw_key_open_ok\\n' >> '$SCRATCH/open_witness'" \
  "cat '$TOK_PATH' >/dev/null 2>&1 && printf 'token_open_ok\\n' >> '$SCRATCH/open_witness'" \
  'exit 0' > "$SCRATCH/workshop"
chmod 755 "$SCRATCH/workshop"

# Живой запуск субъекта ИЗ СРЕДЫ СТАНЦИИ (модель Н-196): HOME станции и
# publication-креденшл в env. Честная реализация обязана этого наследия
# ребёнку сессии не передать.
env HOME="$SCRATCH/home" \
  GIT_SSH_COMMAND="ssh -i $RW_PATH" \
  GITHUB_TOKEN="ghp-toy-station" \
  PATH="$SCRATCH/bin:$PATH" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_N=0 \
  ORCH_AGENT_HOME="$SCRATCH/agent_home" \
  ORCH_LOOP_AGENT_CMD="$SCRATCH/agent_cmd" \
  timeout 30 bash "$SUBJ" >"$SCRATCH/subj_out" 2>&1 || true
chmod 700 "$SCRATCH/home" 2>/dev/null || true

# Суд по env-факту РЕБЁНКА сессии: агентная ветка — agent_env, прямой
# запуск воркшопа (дореализация/обход двери) — ws_env.
if [ ! -f "$SCRATCH/agent_env" ] && [ ! -f "$SCRATCH/ws_env" ]; then
  printf 'КРАСНО: сессия не исполнена — нет env-факта ребёнка (systemd-run не вызван или команда не запущена)\n' >&2
  exit 1
fi
for d in agent_env ws_env; do
  [ -f "$SCRATCH/$d" ] || continue
  if grep -Eq '^(GIT_SSH_COMMAND|GITHUB_TOKEN|GIT_SSH_KEY_FILE|GH_TOKEN)=' "$SCRATCH/$d"; then
    printf 'КРАСНО: publication-креденшл в среде сессии (%s, И-4, Н-196 жив): %s\n' \
      "$d" "$(grep -E '^(GIT_SSH_COMMAND|GITHUB_TOKEN|GIT_SSH_KEY_FILE|GH_TOKEN)=' "$SCRATCH/$d" | tr '\n' ' ')" >&2
    exit 1
  fi
  if grep -Fq "$RW_PATH" "$SCRATCH/$d"; then
    printf 'КРАСНО: путь rw-ключа публикации в среде сессии (%s, И-4): %s\n' "$d" "$RW_PATH" >&2
    exit 1
  fi
  if grep -Fxq "HOME=$SCRATCH/home" "$SCRATCH/$d"; then
    printf 'КРАСНО: HOME сессии — HOME станции (И-4/И-3)\n' >&2
    exit 1
  fi
done
if [ ! -f "$SCRATCH/sudo_fact" ]; then
  printf 'КРАСНО: сессия запущена без двери uid — rw-identity достижим из среды сессии (И-4, Н-196 жив)\n' >&2
  exit 1
fi
if [ -f "$SCRATCH/agent_env" ] && ! grep -Fxq "HOME=$SCRATCH/agent_home" "$SCRATCH/agent_env"; then
  printf 'КРАСНО: HOME сессии не HOME агента (И-4/И-3)\n' >&2
  exit 1
fi
if [ -s "$SCRATCH/open_witness" ]; then
  printf 'КРАСНО: открытие rw-ключа/токена станции сессией успешно — uid владельца станции (И-4): %s\n' \
    "$(tr '\n' ' ' < "$SCRATCH/open_witness")" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-4): среда сессии без publication-креденшл и путей rw-ключа, HOME=агент, открытие rw-ключа отказом (И-4)\n' >&2
exit 0
