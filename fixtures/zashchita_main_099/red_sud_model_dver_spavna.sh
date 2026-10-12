#!/usr/bin/env bash
# Клетка red_sud_model_dver_spavna — инвариант З-7 (Н-270) контракта 099:
# дверь спавна судьи + ТОЧКА ПЕРЕХВАТА реального запроса (блокер критика
# круга 1 :51: отдельный CLI-вызов двери ДО спавна запроса не видит).
# Семь входов:
#   (1) --spawn critic БЕЗ модели → «спавн судьи без явного agent: critic»;
#   (2) модель автора (zai/glm-5.3) → «модель не тира роли»;
#   (3) чужой правильный тир (openai-codex/gpt-5.6-terra — разведение семейств
#       095 этого НЕ ловит) → «модель не тира роли»;
#   (4) честная модель тира (openai-codex/gpt-6-astra) → rc 0;
#   (5) ПЕРЕХВАТ: spawn_agent (дверь 016/095, через которую механически идёт
#       реальный запуск) с манифестом make_task, БЕЗ --agent → rc 1 «спавн
#       судьи без явного agent: critic», ветка wip НЕ создана (отказ ДО спавна);
#   (6) ПЕРЕХВАТ: --agent zai/glm-5.3 (модель автора) → rc 1 «модель не тира
#       роли», ветка не создана;
#   (7) ПЕРЕХВАТ: --agent openai-codex/gpt-6-astra → rc 0 WORKTREE=/BRANCH=.
# Точка перехвата выбрана архитектором (граница критика): spawn_agent.sh —
# единственная механическая дверь создания ветки/worktree спавна (016 срез 2,
# манифест-нога 095 И-15); отдельный вызов check_sud_model остаётся юнитом
# сверки, но перехват запроса несёт spawn_agent, вызывая дверь байтами
# РЕАЛЬНОГО запроса. Toy-мир входов 5-7 — reuse каркаса 095 (context_pack_095).
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh
# (t99-m7 вход 2, t99-m9 вход 5).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
. "$HERE/../context_pack_095/_toy.sh"
W="$Z99_BASE/zashchita-099-spawn-$$-${RANDOM}"
W2=""
trap '[ -n "$W2" ] && _t95_cleanup "$W2"; rm -rf "$W"' EXIT

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

# ── входы 5-7: ТОЧКА ПЕРЕХВАТА — spawn_agent, авто-номер + манифест (прецедент
# И-15 (в)): манифест-нога 095 остаётся ПЕРВОЙ, судейская нога — сразу за ней,
# до сверок 023 и создания ветки; пак судья строится под снятый авто-номер ──
SM="$(z99_subject make_task.sh)" || { printf 'КРАСНО: red_sud_model_dver_spavna: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
SA="$(z99_subject spawn_agent.sh)" || { printf 'КРАСНО: red_sud_model_dver_spavna: предмет отсутствует: scripts/spawn_agent.sh\n' >&2; exit 1; }

W2="$(_t95_world sud-spawn-099)" || { printf 'NOT_IMPLEMENTED: toy-мир 095 не строится\n' >&2; exit 2; }
R="$W2/repo"
# тир-конфиг двери в корне спавна (spawn_agent передаёт свой --root двери)
mkdir -p "$R/config"
cp "$T/config/agent_models.json" "$R/config/agent_models.json"
git -C "$R" add config/agent_models.json
git -C "$R" -c user.name=demo -c user.email=demo@dev-harness.local commit -q -m "тир-конфиг (toy 099)" || true
_t95_trace "$W2/trace.tsv" critic openai-codex/gpt-6-astra allowed
_t95_trace "$W2/trace.tsv" architect zai/glm-5.3 allowed

sud_wip() { git -C "$R" for-each-ref --format='%(refname)' refs/heads/wip | grep -c 'critic$' || true; }
zachistit() { # снятие возможных следов спавна клетки (вход 7 и красные ветви)
  local wt br
  wt="$(printf '%s\n' "$1" | sed -n 's/^WORKTREE=//p' | head -n 1)"
  br="$(printf '%s\n' "$1" | sed -n 's/^BRANCH=//p' | head -n 1)"
  [ -n "$wt" ] && [ -d "$wt" ] && git -C "$R" worktree remove --force "$wt" >/dev/null 2>&1 || true
  [ -n "$br" ] && git -C "$R" branch -D "$br" >/dev/null 2>&1 || true
  return 0
}

# (0) проба авто-номера: манифеста нет — ПЕРВАЯ нога (095) обязана отказать
# «нет манифеста make_task: <N>»; номер снимается из отказа, не хардкодом
out="$(bash "$SA" --author critic --root "$R" 2>&1)"; rc=$?
auto="$(printf '%s\n' "$out" | grep -o 'make_task: [0-9][0-9][0-9]*' | head -n 1 | grep -o '[0-9][0-9][0-9]*')"
if [ "$rc" -ne 1 ] || [ -z "$auto" ]; then
  zachistit "$out"
  printf 'КРАСНО: red_sud_model_dver_spavna: проба авто-номера: ожидался отказ «нет манифеста make_task: <N>»; факт rc=%s, номер=%s, вывод: %s\n' \
    "$rc" "${auto:-?}" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# toy-контракт авто-номера + заморозка + пак судьи (прецедент И-15 (в)):
# без манифеста отказ входа 5 был бы маской манифест-ноги, а не судейской
printf '# Контракт %s — toy (авто 099)\n\n## Существующее\n\n- scripts/toy.sh — живой код\n\n## Предмет\n\ntoy-предмет авто.\n\nЗОНА implementer: scripts/toy.sh\n' "$auto" >| "$R/contracts/${auto}-toy.md"
git -C "$R" add "contracts/${auto}-toy.md"
git -C "$R" -c user.name=demo -c user.email=demo@dev-harness.local commit -q -m "toy-контракт ${auto} (авто 099)"
git -C "$R" tag frozen/contracts/${auto}/1
out="$(bash "$SM" --repo "$R" --role critic --contract "$auto" --model-trace "$W2/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! [ -s "$R/.omp/context/${auto}.tsv" ]; then
  printf 'КРАСНО: red_sud_model_dver_spavna: опора перехвата: пак судьи %s не строится (rc=%s, вывод: %s)\n' \
    "$auto" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 5: реальный запрос БЕЗ agent — судейская нога отказывает ДО создания ветки
n0="$(sud_wip)"
out="$(bash "$SA" --author critic --root "$R" 2>&1)"; rc=$?
n1="$(sud_wip)"
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want1" || [ "$n1" != "$n0" ]; then
  zachistit "$out"
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 5 (перехват без agent): ожидался отказ rc 1 «%s» без создания ветки; факт rc=%s, веток critic до=%s после=%s, вывод: %s\n' \
    "$want1" "$rc" "$n0" "$n1" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 6: реальный запрос с моделью автора — отказ до создания ветки
out="$(bash "$SA" --author critic --root "$R" --agent zai/glm-5.3 2>&1)"; rc=$?
n1="$(sud_wip)"
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$want2" || [ "$n1" != "$n0" ]; then
  zachistit "$out"
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 6 (перехват, модель автора): ожидался отказ rc 1 «%s» без создания ветки; факт rc=%s, веток critic до=%s после=%s, вывод: %s\n' \
    "$want2" "$rc" "$n0" "$n1" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

# вход 7: корректный запуск — спавн строится, WORKTREE/BRANCH на stdout
out="$(bash "$SA" --author critic --root "$R" --agent openai-codex/gpt-6-astra 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'WORKTREE=' || ! printf '%s' "$out" | grep -Fq "BRANCH=wip/${auto}/critic"; then
  zachistit "$out"
  printf 'КРАСНО: red_sud_model_dver_spavna: вход 7 (честный перехваченный спавн): ожидался rc 0 WORKTREE/BRANCH=wip/%s/critic; факт rc=%s, вывод: %s\n' \
    "$auto" "$rc" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi
zachistit "$out"

printf 'ЗЕЛЕНО: red_sud_model_dver_spavna\n'
exit 0
