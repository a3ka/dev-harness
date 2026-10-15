#!/usr/bin/env bash
# Клетка red_sud_model_materializatsija — инварианты И-3/И-4 контракта 104:
# нога `--verdict <роль> --trace <tsv> --object <sha> --session <id>` сверяет
# роль/модель/фолбэк ФАКТИЧЕСКОЙ сессии по трассе с объектом суда. Грамматика
# трассы 104 — ЕДИНЫЙ источник `models_actual.sh --tsv --bind`: строки
# «роль TAB модель TAB allowed|denied TAB <session-id> TAB <object-sha|->»
# (первые три поля — проекция трассы 095 байт-в-байт). Входы:
#   (1) честная трасса (critic на openai-codex/gpt-6-astra allowed, сессия S, объект O) → rc 0;
#   (2) модель автора (zai/glm-5.3 allowed) → rc 1 «вердикт не материализуется … (Н-270)»;
#   (3) подмена роли: в трассе только строки adversary, спрошен critic → rc 1
#       «трасса без строки роли: critic»;
#   (4) подмена объекта: строка critic об объекте O2 ≠ O → rc 1 «трасса не об объекте суда»;
#   (5) чужая трасса: строка critic верной модели, но session-id S2 ≠ S → rc 1 «чужая трасса»;
#   (6) фолбэк из списка тира: critic на anthropic/claude-opus-5-5 denied
#       (tiers.apex.fallback=@opus) → rc 0;
#   (7) фолбэк вне списка: critic на zai/glm-5.3 denied → rc 1 «фолбэк вне списка тира»;
#   (8) трасса 095 (три поля, без привязки) → rc 2 fail-closed (нечем привязать);
#   (9) --verdict без --object или без --session → rc 2 (usage; привязка обязательна).
# Входы 10–14 — закрытие A104-1 / Рв97-3 (дверь судит РОЛЬ ВЫЗОВА и её тир, не
# константу critic; и КАЖДУЮ строку роли, не первую):
#  (10) честная трасса reviewer (anthropic/claude-opus-5-5 allowed = тир audit, S, O),
#       спрошен reviewer → rc 0 (дверь «любая роль → тир critic» ждёт gpt-6-astra — отказ);
#  (11) та же трасса reviewer, спрошен arbiter → rc 1 «трасса без строки роли: arbiter»
#       (именно arbiter в причине: дверь «любая роль → critic» назовёт critic);
#  (12) reviewer на openai-codex/gpt-6-sol denied (= tiers.audit.fallback @gpt-sol) → rc 0
#       (фолбэк тира critic — @opus: дверь с чужим тиром отказывает);
#  (13) arbiter на openai-codex/gpt-6-astra allowed (модель тира critic, не plan) → rc 1
#       «вердикт не материализуется: судья arbiter … тир plan (Н-270)»;
#  (14) две строки critic: gpt-6-astra allowed + zai/glm-5.3 denied → rc 1
#       «фолбэк вне списка тира» (мутант «break после первой строки роли», Рв97-3 A2).
# Отказы — именованные (grep -F); оракул в памяти ДО вызова (правило 8).
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh
# (m8 вход 5, m9 вход 4, m10 вход 7, m15 вход 10, m17 вход 14).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z104_BASE/zashchita-104-verdict-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SUBJ="$(z104_subject check_sud_model.sh)"; then
  printf 'КРАСНО: red_sud_model_materializatsija: предмет отсутствует: scripts/check_sud_model.sh\n' >&2
  exit 1
fi

T="$W/toyroot"; mkdir -p "$T/config"
z104_cfg_ustanovka "$T/config/agent_models.json"

S='01a13b69-2bf2-7147-9f08-2d06d3b11bd0'
S2='ffffffff-0000-4000-8000-000000000001'
O='22cb801bb0ede34ee992a76bac5aa7eb72d99112'
O2='b816f2fd8f62870cade5737fe3c7ef761791a32a'
tr5() { printf '%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5"; }
{ tr5 architect zai/glm-5.3 allowed "$S" "$O"; tr5 critic openai-codex/gpt-6-astra allowed "$S" "$O"; } > "$W/t1.tsv"
{ tr5 architect zai/glm-5.3 allowed "$S" "$O"; tr5 critic zai/glm-5.3 allowed "$S" "$O"; } > "$W/t2.tsv"
{ tr5 adversary openai-codex/gpt-5.6-terra allowed "$S" "$O"; } > "$W/t3.tsv"
{ tr5 critic openai-codex/gpt-6-astra allowed "$S" "$O2"; } > "$W/t4.tsv"
{ tr5 critic openai-codex/gpt-6-astra allowed "$S2" "$O"; } > "$W/t5.tsv"
{ tr5 critic anthropic/claude-opus-5-5 denied "$S" "$O"; } > "$W/t6.tsv"
{ tr5 critic zai/glm-5.3 denied "$S" "$O"; } > "$W/t7.tsv"
printf 'critic\topenai-codex/gpt-6-astra\tallowed\n' > "$W/t8.tsv"
{ tr5 adversary openai-codex/gpt-5.6-terra allowed "$S" "$O"; tr5 reviewer anthropic/claude-opus-5-5 allowed "$S" "$O"; } > "$W/t10.tsv"
{ tr5 reviewer openai-codex/gpt-6-sol denied "$S" "$O"; } > "$W/t12.tsv"
{ tr5 arbiter openai-codex/gpt-6-astra allowed "$S" "$O"; } > "$W/t13.tsv"
{ tr5 critic openai-codex/gpt-6-astra allowed "$S" "$O"; tr5 critic zai/glm-5.3 denied "$S" "$O"; } > "$W/t14.tsv"

# Оракул в памяти ДО вызова (правило 8)
w2='вердикт не материализуется'; w2b='Н-270'
w3='трасса без строки роли: critic'
w4='трасса не об объекте суда'
w5='чужая трасса'
w7='фолбэк вне списка тира'
w11='трасса без строки роли: arbiter'
w13='вердикт не материализуется: судья arbiter'; w13b='тир plan (Н-270)'

run() { bash "$SUBJ" --verdict critic --trace "$W/$1" --object "$O" --session "$S" --root "$T" 2>&1; }
runr() { bash "$SUBJ" --verdict "$1" --trace "$W/$2" --object "$O" --session "$S" --root "$T" 2>&1; }
fail() { printf 'КРАСНО: red_sud_model_materializatsija: вход %s: %s; факт rc=%s, вывод: %s\n' "$1" "$2" "$3" "$(printf '%s' "$4" | head -c 220)" >&2; exit 1; }

out="$(run t1.tsv)"; rc=$?; [ "$rc" -eq 0 ] || fail 1 'честная трасса, ожидался rc 0' "$rc" "$out"
out="$(run t2.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w2" && printf '%s' "$out" | grep -Fq "$w2b"; } || fail 2 "ожидался rc 1 «$w2 … $w2b»" "$rc" "$out"
out="$(run t3.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w3"; } || fail 3 "ожидался rc 1 «$w3»" "$rc" "$out"
out="$(run t4.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w4"; } || fail 4 "ожидался rc 1 «$w4»" "$rc" "$out"
out="$(run t5.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w5"; } || fail 5 "ожидался rc 1 «$w5»" "$rc" "$out"
out="$(run t6.tsv)"; rc=$?; [ "$rc" -eq 0 ] || fail 6 'фолбэк из списка тира, ожидался rc 0' "$rc" "$out"
out="$(run t7.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w7"; } || fail 7 "ожидался rc 1 «$w7»" "$rc" "$out"
out="$(run t8.tsv)"; rc=$?; [ "$rc" -eq 2 ] || fail 8 'трасса без привязки (3 поля), ожидался rc 2' "$rc" "$out"
out="$(bash "$SUBJ" --verdict critic --trace "$W/t1.tsv" --session "$S" --root "$T" 2>&1)"; rc=$?
[ "$rc" -eq 2 ] || fail 9a 'без --object ожидался rc 2' "$rc" "$out"
out="$(bash "$SUBJ" --verdict critic --trace "$W/t1.tsv" --object "$O" --root "$T" 2>&1)"; rc=$?
[ "$rc" -eq 2 ] || fail 9b 'без --session ожидался rc 2' "$rc" "$out"

# входы 10–14: не-critic роли и вторая строка роли
out="$(runr reviewer t10.tsv)"; rc=$?; [ "$rc" -eq 0 ] || fail 10 'честная трасса reviewer (тир audit), ожидался rc 0' "$rc" "$out"
out="$(runr arbiter t10.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w11"; } || fail 11 "трасса reviewer спрошена от arbiter: ожидался rc 1 «$w11»" "$rc" "$out"
out="$(runr reviewer t12.tsv)"; rc=$?; [ "$rc" -eq 0 ] || fail 12 'reviewer на фолбэке тира audit (gpt-6-sol denied), ожидался rc 0' "$rc" "$out"
out="$(runr arbiter t13.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w13" && printf '%s' "$out" | grep -Fq "$w13b"; } || fail 13 "arbiter на модели тира critic: ожидался rc 1 «$w13 … $w13b»" "$rc" "$out"
out="$(run t14.tsv)"; rc=$?
{ [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w7"; } || fail 14 "вторая строка critic с фолбэком вне списка: ожидался rc 1 «$w7»" "$rc" "$out"

printf 'ЗЕЛЕНО: red_sud_model_materializatsija\n'
exit 0
