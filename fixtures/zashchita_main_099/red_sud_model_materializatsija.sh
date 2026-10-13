#!/usr/bin/env bash
# Клетка red_sud_model_materializatsija — инвариант З-8 (Н-270) контракта 099:
# вердикт судьи не своей модели НЕ материализуется. Три входа:
#   (1) трасса: critic на zai/glm-5.3 (модель автора) → rc 1
#       «вердикт не материализуется … (Н-270)»;
#   (2) трасса без строки роли → rc 2 fail-closed (= не материализуется);
#   (3) честная трасса (critic на openai-codex/gpt-6-astra) → rc 0.
# Грамматика трассы — ЕДИНЫЙ источник make_task --model-trace / models_actual --tsv:
# строки «роль TAB модель TAB allowed|denied».
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh (t99-m8).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-verdict-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SUBJ="$(z99_subject check_sud_model.sh)"; then
  printf 'КРАСНО: red_sud_model_materializatsija: предмет отсутствует: scripts/check_sud_model.sh\n' >&2
  exit 1
fi

T="$W/toyroot"; mkdir -p "$T/config"
cat > "$T/config/agent_models.json" <<'JSON'
{"models":{"gpt-astra":"openai-codex/gpt-6-astra","gpt-terra":"openai-codex/gpt-5.6-terra","glm":"zai/glm-5.3"},"tiers":{"apex":{"model":"@gpt-astra"},"advisor":{"model":"@gpt-terra"},"slow":{"model":"@glm"}},"roles":{"critic":"apex","adversary":"advisor","architect":"slow"}}
JSON

# (1) судья на модели автора → нематериализация, именованная причина Н-270
TRACE1="$W/trace1.tsv"; printf 'architect\tzai/glm-5.3\tallowed\ncritic\tzai/glm-5.3\tallowed\n' > "$TRACE1"
# (2) трасса без строки роли
TRACE2="$W/trace2.tsv"; printf 'architect\tzai/glm-5.3\tallowed\n' > "$TRACE2"
# (3) честная трасса
TRACE3="$W/trace3.tsv"; printf 'architect\tzai/glm-5.3\tallowed\ncritic\topenai-codex/gpt-6-astra\tallowed\n' > "$TRACE3"

# Оракул в памяти ДО вызова (правило 8)
want1='вердикт не материализуется'
want1b='Н-270'

out="$(bash "$SUBJ" --verdict critic --trace "$TRACE1" --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want1" || ! printf '%s' "$out" | grep -Fq "$want1b"; then
  printf 'КРАСНО: red_sud_model_materializatsija: вход 1: ожидался отказ rc 1 «%s … %s»; факт rc=%s, вывод: %s\n' \
    "$want1" "$want1b" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --verdict critic --trace "$TRACE2" --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 2 ]; then
  printf 'КРАСНО: red_sud_model_materializatsija: вход 2: ожидался rc 2 fail-closed (трасса без строки роли); факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --verdict critic --trace "$TRACE3" --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: red_sud_model_materializatsija: вход 3: честная трасса ожидался rc 0; факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

printf 'ЗЕЛЕНО: red_sud_model_materializatsija\n'
exit 0
