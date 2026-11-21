# ПРИЧИНА: значение вне алфавита: commands.test: пусто
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
# ОКРУЖЕНИЕ: PROFILE_RESOLVER_WARN_FILE=$WORK/warn.log
#
# Контракт 184 (М-0; ADR владельца 2026-11-21-plan-fable п.3 и
# 2026-11-21-plan-v9 п.6): обязательство «неизвестный ключ репо-слоя — отказ
# P4» ЗАМЕНЕНО. Неизвестный ключ — НЕ отказ: одна строка предупреждения на
# stderr с точным путём ключа («профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ
# репо-слой: workflowPaths.contrete»), rc 0, ключ в выходной JSON не попадает.
# Старый кейс `case_neizvestnyj_kljuch_repo_sloja.sh` требовал отказа и
# потому удалён (клетка на понижённое обязательство — удалить, не переписать);
# этот кейс заменяет его.
#
# Зелёный контроль — именно новое поведение: лишний `workflowPaths.contrete`
# в репо-слое → rc 0, предупреждение с путём ключа, ключа нет в merged-профиле.
# Красное — прежнее поведение ИЗВЕСТНЫХ ключей: `commands.test` пуст → rc 1,
# «значение вне алфавита: commands.test: пусто». Терпимость к неизвестным
# именам не отменяет отказа по неверному значению известного ключа.
set -euo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
# Слой с полными defaults (значения commands/ci берутся из него).
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль: неизвестный ключ репо-слоя → rc 0 + предупреждение ────
G="$WORK/green/repo"; mkdir -p "$G"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures","contrete":"x"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): объявленный CI-toy-файл `ci.yml`.
: > "$G/ci.yml"
GREEN_OUT="$(BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G")"
# КАНАЛ ПРЕДУПРЕЖДЕНИЯ (Б-1, контракт 184): предупреждение — НЕ в stdout
# (stdout несёт merged-профиль) и в слитом канале барьера (проверяющий сводит
# stdout и stderr барьера в один поток) оно не идёт и в stderr — дверь пишет
# его в ОТДЕЛЬНЫЙ журнал PROFILE_RESOLVER_WARN_FILE. Читаем предупреждение из
# этого канала, JSON — из stdout.
GREEN_WARN="$(cat "$WORK/warn.log" 2>/dev/null || true)"
case "$GREEN_WARN" in
  *"профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ репо-слой: workflowPaths.contrete"*) ;;
  *) printf 'ОШИБКА: нет предупреждения об неизвестном ключе репо-слоя\n' >&2; exit 1 ;;
esac
case "$GREEN_OUT" in
  *'"contrete"'*) printf 'ОШИБКА: неизвестный ключ протёк в merged-профиль\n' >&2; exit 1 ;;
esac

# ── красное: пустое значение ИЗВЕСТНОГО ключа → rc 1 + P6 ──────────────────
R="$WORK/red/repo"; mkdir -p "$R"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures","contrete":"x"},"commands":{"test":"","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$R/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): тот же объявленный CI-toy-файл.
: > "$R/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"
