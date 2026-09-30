# ПРИЧИНА: изменён без разрешения владельца
#
# Контракт 065, инвариант 2 (полнота): строки-санкции собираются из ВСЕХ коммитов
# диапазона main..tip, не только из tip. Различающий вход против стаба «tip-only»
# (чтение тел только tip-коммита диапазона): санкция лежит в ПЕРВОМ из ДВУХ коммитов
# ветки, tip-коммит правит вне устава БЕЗ строки — на одно-коммитных входах приёмки
# (case_land_sankcija_ne_perenesena_v_merge.sh) такой стаб неотличим от честной
# реализации (Б2 круга 1 критика, вердикт 01abc89).
#   * зелёный контроль: ленд исполняет НАСТОЯЩИЙ land_agent ($REPO/scripts/land_agent.sh,
#     сбор строк — g rev-list "$range" по ВСЕМУ диапазону, И-10); фикстура сверяет
#     ДОСЛОВНЫЙ перенос строки ПЕРВОГО коммита (grep -Fx) и первый абзац «land: <ветка>»;
#     стаб «tip-only» здесь ловится ОТКАЗом сверки ДО $BARRIER — merge без строки не
#     проходит grep -Fx; затем $BARRIER (check_charter) → rc 0;
#   * красное: та же двухкоммитная топология, merge построен `git merge --no-ff -m
#     'land: …'` БЕЗ переноса (поведение land_agent до 065) → $BARRIER rc 1 навсегда:
#     уставная дельта merge при отсутствии строки в merge-теле.
#
# Серийные вызовы — `|| true` (А-32). Положительный контроль — до красного (А-73).
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

R="$WORK/repo"
make_repo "$R"

# land-предпосылки — как в case_land_sankcija_ne_perenesena_v_merge.sh: замороженный
# контракт 900 с ЗОНА implementer — реестр ролей для И-9 land_agent.
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

# ── зелёный контроль: санкция в ПЕРВОМ коммите двухкоммитной ветки ────────────
g "$R" branch wip/010/implementer main
g "$R" worktree add -q "$WORK/wt-green" wip/010/implementer
# коммит 1 (ПЕРВЫЙ в диапазоне): правка frozen-плана со строкой-санкцией в теле
printf 'правка frozen-плана в первом коммите ветки (санкция только здесь)\n' >> "$WORK/wt-green/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -F - <<'MSG'
правка frozen-плана в первом коммите ветки

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md правка первого коммита диапазона по слову владельца фикстуры
MSG
# коммит 2 (tip диапазона): правка вне устава, БЕЗ строки — стаб «tip-only» на этом
# входе даёт merge-тело без маркеров и ловится сверкой ниже
mkdir -p "$WORK/wt-green/scripts"
printf '# проба вне устава\n' > "$WORK/wt-green/scripts/proba.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -m 'правка вне устава в tip-коммите (без санкции)'
# диапазон обязан быть двухкоммитным — иначе вход не различает стаб «tip-only»
[ "$(git -C "$R" rev-list --count main..wip/010/implementer)" -eq 2 ] || {
  printf 'ОТКАЗ: ожидался диапазон из 2 коммитов, main..wip/010/implementer иного размера\n' >&2
  exit 1
}
bash "$REPO/scripts/land_agent.sh" --branch wip/010/implementer --worktree "$WORK/wt-green" --root "$R" || true
mb="$(git -C "$R" log -1 --format=%B main)"
printf '%s\n' "$mb" | grep -qFx 'land: wip/010/implementer' || {
  printf 'ОТКАЗ: первый абзац merge-сообщения не «land: wip/010/implementer»: %s\n' "$mb" >&2
  exit 1
}
printf '%s\n' "$mb" | grep -qFx 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md правка первого коммита диапазона по слову владельца фикстуры' || {
  printf 'ОТКАЗ: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ из ПЕРВОГО коммита диапазона не перенесена в тело merge дословно: %s\n' "$mb" >&2
  exit 1
}
"$BARRIER" "$R" || true   # ожидание: rc 0 — merge несёт уставную дельту и перенесённую санкцию


# ── красное: двухкоммитная топология, merge без переноса строки ───────────────
g "$R" branch wip/011/implementer main
g "$R" worktree add -q "$WORK/wt-red" wip/011/implementer
# коммит 1 (ПЕРВЫЙ в диапазоне): правка frozen-плана со строкой-санкцией в теле
printf 'правка frozen-плана в первом коммите второго входа (санкция только здесь)\n' >> "$WORK/wt-red/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -F - <<'MSG'
правка frozen-плана в первом коммите второго входа

РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md второй вход первого коммита диапазона по слову владельца фикстуры
MSG
# коммит 2 (tip диапазона): правка вне устава, без строки
mkdir -p "$WORK/wt-red/scripts"
printf '# проба вне устава (второй вход)\n' > "$WORK/wt-red/scripts/proba.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -m 'правка вне устава в tip-коммите (второй вход, без санкции)'
[ "$(git -C "$R" rev-list --count main..wip/011/implementer)" -eq 2 ] || {
  printf 'ОТКАЗ: ожидался диапазон из 2 коммитов, main..wip/011/implementer иного размера\n' >&2
  exit 1
}
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      merge --no-ff -m 'land: wip/011/implementer' wip/011/implementer >/dev/null 2>&1
"$BARRIER" "$R"
