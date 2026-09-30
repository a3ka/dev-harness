# ПРИЧИНА: изменён без разрешения владельца
#
# Контракт 065, инвариант 3 (синтез запрещён): перенос строк-санкций в merge-тело
# не создаёт индульгенцию. Оба входа исполняют НАСТОЯЩИЙ land_agent
# ($REPO/scripts/land_agent.sh, прямой вызов): merge-тело судит $BARRIER (check_charter).
#   * зелёный контроль: ветка правит scripts/proba.sh (вне устава) → land_agent rc 0,
#     merge-тело — ровно «land: <ветка>» ОДНОЙ строкой, байт-в-байт как до 065, БЕЗ
#     маркеров (фикстура ловит стаб-инъектор: синтезанная land_agent строка-санкция
#     убивает этот положительный контроль), затем $BARRIER → rc 0;
#   * красное: зло-ленд — frozen-план правится БЕЗ строки-санкции ни в одном коммите
#     ветки; land_agent приземляет rc 0 (его предмет — не судить санкции), merge несёт
#     уставную дельту без строки → $BARRIER rc 1 навсегда: зло-ленд без строки
#     остаётся красным.
#
# Серийные вызовы — `|| true` (А-32). Положительный контроль — до красного (А-73).
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

R="$WORK/repo"
make_repo "$R"

# land-предпосылки — как в case_land_sankcija_ne_perenesena_v_merge.sh (контракт 900
# с ЗОНА implementer для реестра ролей И-9).
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

# ── зелёный контроль: ветка вне устава, merge-тело без маркеров, одной строкой ──
g "$R" branch wip/001/implementer main
g "$R" worktree add -q "$WORK/wt-green" wip/001/implementer
mkdir -p "$WORK/wt-green/scripts"
printf 'проба вне устава\n' > "$WORK/wt-green/scripts/proba.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-green" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -m 'боковая правка вне устава'
out_land="$(bash "$REPO/scripts/land_agent.sh" --branch wip/001/implementer --worktree "$WORK/wt-green" --root "$R" || true)"
printf '%s\n' "$out_land" | grep -q '^LANDED main=' || {
  printf 'ОТКАЗ: land_agent не приземлил ветку вне устава: %s\n' "$out_land" >&2
  exit 1
}
mb="$(git -C "$R" log -1 --format=%B main)"
[ "$mb" = 'land: wip/001/implementer' ] || {
  printf 'ОТКАЗ: merge-тело не «land: wip/001/implementer» одной строкой (синтез строк?): %s\n' "$mb" >&2
  exit 1
}
printf '%s\n' "$mb" | grep -q '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:\|^ALLOW-ARTIFACT-DELETE:' && {
  printf 'ОТКАЗ: merge-тело ветки без санкций несёт маркер — синтез строк-санкций: %s\n' "$mb" >&2
  exit 1
}
"$BARRIER" "$R" || true   # ожидание: rc 0 — устав не тронут

# ── красное: зло-ленд frozen-правки без строки-санкции ─────────────────────────
g "$R" branch wip/002/implementer main
g "$R" worktree add -q "$WORK/wt-red" wip/002/implementer
printf 'зло-ленд: правка frozen-плана без санкции\n' >> "$WORK/wt-red/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=implementer GIT_COMMITTER_EMAIL=implementer@dev-harness.local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-red" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
  commit -q -m 'зло-ленд: правка frozen-плана без санкции'
out_zlo="$(bash "$REPO/scripts/land_agent.sh" --branch wip/002/implementer --worktree "$WORK/wt-red" --root "$R" || true)"
printf '%s\n' "$out_zlo" | grep -q '^LANDED main=' || {
  printf 'ОТКАЗ: land_agent не приземлил зло-ленд (его предмет — не судить санкции): %s\n' "$out_zlo" >&2
  exit 1
}
mb_zlo="$(git -C "$R" log -1 --format=%B main)"
printf '%s\n' "$mb_zlo" | grep -q '^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:\|^ALLOW-ARTIFACT-DELETE:' && {
  printf 'ОТКАЗ: зло-ленд без строки в ветке получил маркер в merge-теле — синтез: %s\n' "$mb_zlo" >&2
  exit 1
}
"$BARRIER" "$R"
