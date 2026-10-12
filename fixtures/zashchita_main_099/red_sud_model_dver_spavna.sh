#!/usr/bin/env bash
# Клетка red_sud_model_dver_spavna — инвариант З-7 (Н-270) контракта 099:
# дверь спавна судьи. Четыре входа:
#   (1) --spawn critic БЕЗ модели → «спавн судьи без явного agent: critic»;
#   (2) модель автора (zai/glm-5.3) → «модель не тира роли»;
#   (3) чужой правильный тир (openai-codex/gpt-5.6-terra — разведение семейств 095
#       этого НЕ ловит) → «модель не тира роли»;
#   (4) честная модель тира (openai-codex/gpt-6-astra) → rc 0.
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh (t99-m7).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-spawn-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SUBJ="$(z99_subject check_sud_model.sh)"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: предмет отсутствует: scripts/check_sud_model.sh\n' >&2
  exit 1
fi

# toy-корень: config/agent_models.json с тиром critic → apex → @gpt-astra (та же грамматика, что живой конфиг)
T="$W/toyroot"; mkdir -p "$T/config"
cat > "$T/config/agent_models.json" <<'JSON'
{"models":{"gpt-astra":"openai-codex/gpt-6-astra","gpt-terra":"openai-codex/gpt-5.6-terra","glm":"zai/glm-5.3"},"tiers":{"apex":{"model":"@gpt-astra"},"advisor":{"model":"@gpt-terra"},"slow":{"model":"@glm"}},"roles":{"critic":"apex","adversary":"advisor","architect":"slow"}}
JSON

# Оракул в памяти ДО вызова (правило 8)
want1='спавн судьи без явного agent: critic'
want2='модель не тира роли'

out="$(bash "$SUBJ" --spawn critic --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want1"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 1: ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want1" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --spawn critic zai/glm-5.3 --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want2"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 2 (модель автора): ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want2" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --spawn critic openai-codex/gpt-5.6-terra --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want2"; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 3 (чужой правильный тир): ожидался отказ rc 1 «%s»; факт rc=%s, вывод: %s\n' \
    "$want2" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

out="$(bash "$SUBJ" --spawn critic openai-codex/gpt-6-astra --root "$T" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 4 (честный спавн): ожидался rc 0; факт rc=%s, вывод: %s\n' \
    "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

printf 'ЗЕЛЕНО: red_sud_model_dver_spavna\n'
exit 0
