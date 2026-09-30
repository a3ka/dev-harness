# ПРИЧИНА: изменён без разрешения владельца
#
# Контракт 065, часть (б): land_agent.sh обязан переносить строки-санкции из тел
# коммитов ветки в тело merge-коммита — check_charter (019 И-7) судит merge по дельте
# к ПЕРВОМУ родителю, и ленд санкционированной frozen-правки без переноса красит CI
# (4-й рецидив класса 037/043/045; живой случай — merge f2b911f, санкция в 7b0bc92).
#
# Входы (положительный контроль ДО первого красного — А-73; серийные вызовы `|| true` — А-32):
#   * зелёный контроль: frozen-план правится в КОММИТЕ ВЕТКИ со строками
#     РАЗРЕШИЛ-ВЛАДЕЛЕЦ и ALLOW-ARTIFACT-DELETE (обе грамматики: charter и protected);
#     ленд исполняет НАСТОЯЩИЙ land_agent (прямой вызов $REPO/scripts/land_agent.sh —
#     предмет входа тело merge, которое строит только он); фикстура сверяет ДОСЛОВНЫЙ
#     перенос обеих строк (grep -Fx) и первый абзац «land: <ветка>»; затем $BARRIER
#     (check_charter) → rc 0. До реализации 065 переноса нет — ОТКАЗ фикстуры до
#     вызова $BARRIER: красное ДО правки кода (правило 3);
#   * красное: та же топология, merge построен `git merge --no-ff -m 'land: …'` БЕЗ
#     переноса строки (поведение land_agent до 065 — обманный способ) → $BARRIER rc 1:
#     уставная дельта merge при отсутствии строки в merge-теле. Красное НАВСЕГДА —
#     слияние с уставной дельтой без строки не легитимируется переносом в других лендах.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

R="$WORK/repo"
make_repo "$R"

# land-предпосылки (по образцу fixtures/land_agent/_repo.sh): замороженный контракт 900
# с ЗОНА implementer — реестр ролей для И-9 land_agent (зоны читаются из блоба заморозки,
# prefix contracts/900- совпадает с именем файла).
mkdir -p "$R/verdicts/critic"
{
  printf '# контракт 900 (подставной, реестр ролей для land-фикстур 065)\n'
  printf '\n## Исполнители и зоны\n'
  printf 'ЗОНА implementer: scripts/\n'
} > "$R/contracts/900-fake.md"
printf 'accept\nвердикт критика\n' > "$R/verdicts/critic/contracts-900-v1.md"
g "$R" add -A
commit_all "$R" 'основание: контракт 900 с implementer в реестре'
g "$R" tag -a frozen/contracts/900/1 -m 'заморозка 900 для land-фикстур 065'

# ── зелёный контроль: ленд настоящим land_agent переносит строки дословно ──────
g "$R" branch wip/001/implementer main
g "$R" worktree add -q "$WORK/wt-green" wip/001/implementer
printf 'правка frozen-плана в ветке (санкция в теле коммита ветки)\n' >> "$WORK/wt-green/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -F - <<'MSG'
правка frozen-плана в ветке

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md правка frozen-плана по слову владельца фикстуры
ALLOW-ARTIFACT-DELETE: "plans/001-p.md" контроль дословного переноса второго маркера
MSG
bash "$REPO/scripts/land_agent.sh" --branch wip/001/implementer --worktree "$WORK/wt-green" --root "$R" || true
mb="$(git -C "$R" log -1 --format=%B main)"
printf '%s\n' "$mb" | grep -qFx 'land: wip/001/implementer' || {
  printf 'ОТКАЗ: первый абзац merge-сообщения не «land: wip/001/implementer»: %s\n' "$mb" >&2
  exit 1
}
printf '%s\n' "$mb" | grep -qFx 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md правка frozen-плана по слову владельца фикстуры' || {
  printf 'ОТКАЗ: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ не перенесена в тело merge дословно: %s\n' "$mb" >&2
  exit 1
}
printf '%s\n' "$mb" | grep -qFx 'ALLOW-ARTIFACT-DELETE: "plans/001-p.md" контроль дословного переноса второго маркера' || {
  printf 'ОТКАЗ: строка ALLOW-ARTIFACT-DELETE не перенесена в тело merge дословно: %s\n' "$mb" >&2
  exit 1
}
"$BARRIER" "$R" || true   # ожидание: rc 0 — merge несёт уставную дельту и перенесённую санкцию

# ── красное: merge «land: …» без переноса строки (поведение land_agent до 065) ──
g "$R" branch wip/002/implementer main
g "$R" worktree add -q "$WORK/wt-red" wip/002/implementer
printf 'вторая правка frozen-плана в ветке (санкция есть только в теле коммита ветки)\n' >> "$WORK/wt-red/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -F - <<'MSG'
вторая правка frozen-плана в ветке

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md вторая правка frozen-плана по слову владельца фикстуры
MSG
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      merge --no-ff -m 'land: wip/002/implementer' wip/002/implementer >/dev/null 2>&1
"$BARRIER" "$R"
