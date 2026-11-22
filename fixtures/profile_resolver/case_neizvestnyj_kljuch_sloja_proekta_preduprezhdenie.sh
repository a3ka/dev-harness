# ПРИЧИНА: значение вне алфавита: defaults.commands.test: пусто
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
# ОКРУЖЕНИЕ: PROFILE_RESOLVER_WARN_FILE=$WORK/warn.log
#
# Контракт 184 (М-0; ADR владельца 2026-11-21-plan-fable п.3 и
# 2026-11-21-plan-v9 п.6): обязательство «неизвестный ключ слоя проекта — отказ
# P4» ЗАМЕНЕНО. Неизвестный ключ — НЕ отказ: одна строка предупреждения на
# stderr с точным путём ключа («профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ
# слой-проекта: boguskey»), rc 0, ключ в выходной JSON не попадает. Старый
# кейс `case_neizvestnyj_kljuch_sloja_proekta.sh` требовал отказа и потому
# удалён (клетка на понижённое обязательство — удалить, не переписать); этот
# кейс заменяет его.
#
# Зелёный контроль — именно новое поведение: лишний верхнеуровневый ключ
# `boguskey` в слое проекта → rc 0, предупреждение с путём ключа, ключа нет
# в merged-профиле. Красное — прежнее поведение ИЗВЕСТНЫХ ключей: пустое
# `defaults.commands.test` в слое → rc 1, «значение вне алфавита:
# defaults.commands.test: пусто». Терпимость к неизвестным именам не отменяет
# отказа по неверному значению известного ключа.
#
# Двухслойная семантика: контент слоя лежит в $WORK/green_layer и
# $WORK/red_layer; $WORK/layer — симлинк, переключаемый ПЕРЕД каждым вызовом.
# Запрет на `mkdir -p $WORK/layer/registry`: `ln -sfn` НЕ умеет замещать непустой
# каталог, симлинк оказывается ВНУТРИ исходного каталога и контент не меняется
# (замерено 2026-09-29: первый прогон кейса получил «зелёный на обманном дереве»).
set -euo pipefail
GREEN_LAYER="$WORK/green_layer"
RED_LAYER="$WORK/red_layer"

# Зелёный слой — конформный, но с лишним верхнеуровневым ключом `boguskey`.
mkdir -p "$GREEN_LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","boguskey":"x","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' \
  > "$GREEN_LAYER/registry/harness-project.json"

# ── зелёный контроль: неизвестный ключ слоя проекта → rc 0 + предупреждение ─
G_REPO="$WORK/green/repo"; mkdir -p "$G_REPO"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G_REPO/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): эффективный ci.workflow="ci.yml"
# наследуется из слоя (репо не объявляет).
: > "$G_REPO/ci.yml"
ln -sfn "$GREEN_LAYER" "$WORK/layer"
GREEN_OUT="$(BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G_REPO")"
# КАНАЛ ПРЕДУПРЕЖДЕНИЯ (Б-1, контракт 184): предупреждение — НЕ в stdout
# (stdout несёт merged-профиль) и в слитом канале барьера (проверяющий сводит
# stdout и stderr барьера в один поток) оно не идёт и в stderr — дверь пишет
# его в ОТДЕЛЬНЫЙ журнал PROFILE_RESOLVER_WARN_FILE. Читаем предупреждение из
# этого канала, JSON — из stdout.
GREEN_WARN="$(cat "$WORK/warn.log" 2>/dev/null || true)"
case "$GREEN_WARN" in
  *"профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ слой-проекта: boguskey"*) ;;
  *) printf 'ОШИБКА: нет предупреждения об неизвестном ключе слоя проекта\n' >&2; exit 1 ;;
esac
case "$GREEN_OUT" in
  *'"boguskey"'*) printf 'ОШИБКА: неизвестный ключ протёк в merged-профиль\n' >&2; exit 1 ;;
esac

# ── красное: пустое значение ИЗВЕСТНОГО ключа в defaults слоя → rc 1 + P6 ───
mkdir -p "$RED_LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","boguskey":"x","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' \
  > "$RED_LAYER/registry/harness-project.json"
R_REPO="$WORK/red/repo"; mkdir -p "$R_REPO"
# Репо — конформное (только обязательные); красное — на слое.
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$R_REPO/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): тот же объявленный CI-toy-файл.
: > "$R_REPO/ci.yml"
ln -sfn "$RED_LAYER" "$WORK/layer"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R_REPO"
