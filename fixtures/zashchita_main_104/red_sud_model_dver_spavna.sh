#!/usr/bin/env bash
# Клетка red_sud_model_dver_spavna — инвариант И-3 (Н-270) контракта 104:
# ЮНИТ двери сверки спавна судьи scripts/check_sud_model.sh (ноги --spawn и
# --frontmatter переносятся из 099 без изменения семантики). Перехват
# РЕАЛЬНОГО запроса — хук tool_call, клетка red_huk_task_spavna.sh (граница
# арбитража verdicts/arbitration/contracts-099-spawn-trust-v1.md).
# Десять входов (7–10 — закрытие A104-1 / Рв97-3: дверь обязана судить РОЛЬ ВЫЗОВА,
# не константу critic; тиры и модели — из z104_cfg_ustanovka):
#   (1) --spawn critic БЕЗ модели → «спавн судьи без явного agent: critic»;
#   (2) модель автора (zai/glm-5.3) → «модель не тира роли»;
#   (3) чужой правильный тир (openai-codex/gpt-5.6-terra — разведение семейств
#       095 этого НЕ ловит) → «модель не тира роли»;
#   (4) честная модель тира (openai-codex/gpt-6-astra) → rc 0;
#   (5) --frontmatter critic: frontmatter .omp/agents/critic.md
#       model: ["@slow"] ≠ тир apex из config/agent_models.json → «frontmatter
#       роли не тира роли: critic frontmatter @slow тир apex» (статическая
#       сверка модели спавна: несовпадение frontmatter и источника назначений
#       не молчит; арбитраж 099, граница круга 3);
#   (6) честный frontmatter model: ["@apex"] → rc 0;
#   (7) --spawn adversary openai-codex/gpt-5.6-terra (тир advisor) → rc 0
#       (та же модель, что отказана critic на входе 3: дверь, судящая любую роль
#       тиром critic, здесь отказывает — наблюдаемо);
#   (8) --spawn reviewer openai-codex/gpt-6-astra (модель тира critic, не audit)
#       → «модель не тира роли: reviewer тир audit спавн openai-codex/gpt-6-astra»;
#   (9) --frontmatter arbiter с model: ["@plan"] → rc 0;
#  (10) --frontmatter reviewer с model: ["@apex"] → «frontmatter роли не тира
#       роли: reviewer frontmatter @apex тир audit».
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh
# (t104-m7 вход 1; frontmatter-ветвь накрывается тем же стабом — дефект
# «всегда rc 0» наблюдаем и на входе 5; t104-m14 «любая роль → тир critic» —
# вход 7).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z104_BASE/zashchita-104-spawn-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SUBJ="$(z104_subject check_sud_model.sh)"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: предмет отсутствует: scripts/check_sud_model.sh\n' >&2
  exit 1
fi

# toy-корень: config/agent_models.json установочной грамматики (critic → apex →
# @gpt-astra, fallback @opus) + .omp/agents/critic.md (frontmatter)
T="$W/toyroot"; mkdir -p "$T/config" "$T/.omp/agents"
z104_cfg_ustanovka "$T/config/agent_models.json"
fm() { printf -- '---\nname: %s\ndescription: toy\nmodel: ["%s"]\n---\n\n# toy\n' "$1" "$2"; }

# Оракул в памяти ДО вызова (правило 8)
want1='спавн судьи без явного agent: critic'
want2='модель не тира роли'
want5='frontmatter роли не тира роли: critic frontmatter @slow тир apex'
want8='модель не тира роли: reviewer тир audit спавн openai-codex/gpt-6-astra'
want10='frontmatter роли не тира роли: reviewer frontmatter @apex тир audit'

out="$(bash "$SUBJ" --spawn critic --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want1"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 1: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want1" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --spawn critic zai/glm-5.3 --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want2"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 2: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want2" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --spawn critic openai-codex/gpt-5.6-terra --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want2"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 3: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want2" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --spawn critic openai-codex/gpt-6-astra --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 4: ожидался rc 0; факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 5: frontmatter роли НЕ тира из config/agent_models.json → именованный отказ
fm critic '@slow' >| "$T/.omp/agents/critic.md"
out="$(bash "$SUBJ" --frontmatter critic --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want5"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 5: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want5" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 6: честный frontmatter тира → rc 0
fm critic '@apex' >| "$T/.omp/agents/critic.md"
out="$(bash "$SUBJ" --frontmatter critic --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 6: ожидался rc 0; факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 7: не-critic роль на модели СВОЕГО тира (advisor → gpt-5.6-terra) → rc 0
out="$(bash "$SUBJ" --spawn adversary openai-codex/gpt-5.6-terra --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 7: ожидался rc 0 (adversary на модели тира advisor); факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 8: не-critic роль на модели тира critic → именованный отказ с РОЛЬЮ ВЫЗОВА и её тиром
out="$(bash "$SUBJ" --spawn reviewer openai-codex/gpt-6-astra --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want8"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 8: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want8" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 9: честный frontmatter не-critic роли (arbiter → plan) → rc 0
fm arbiter '@plan' >| "$T/.omp/agents/arbiter.md"
out="$(bash "$SUBJ" --frontmatter arbiter --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 9: ожидался rc 0 (arbiter frontmatter @plan); факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 10: frontmatter не-critic роли с тиром critic → именованный отказ с РОЛЬЮ ВЫЗОВА и её тиром
fm reviewer '@apex' >| "$T/.omp/agents/reviewer.md"
out="$(bash "$SUBJ" --frontmatter reviewer --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want10"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 10: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want10" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

printf 'ЗЕЛЕНО: red_sud_model_dver_spavna\n'
exit 0
