# ПРИЧИНА: вне своей ветки wip/
#
# Срез 1 контракта 018, защита коллизии (Q4): страж «ветка, не main» ОБЯЗАН пропускать на
# main судью и владельца — иначе блокирует легальные main-коммиты вердиктов/устава. Вход
# различает честный страж (исключение спавн-состоянием) от переусердного, краснящего «любой
# зонированный автор на main» (тогда судья, зонированный verdicts/*, погиб бы) либо «любой
# автор при живой wip-ветке где-либо» (тогда судья при живой ЧУЖОЙ wip/018/architect погиб
# бы). На текущем барьере красный вход ЗЕЛЁН — красное не предъявлено (красное пачки).
#
# Зелёные контроли:
#   * судья critic ЗОНИРОВАН (verdicts/*), коммитит вердикт в main, СВОЕЙ wip-ветки нет
#     (жива лишь чужая wip/018/architect) → rc 0 (main-direct, Q2);
#   * владелец не зонирован → «не судится», rc 0 (fail-open).
# Красный: рабочий implementer со своей живой wip/018/implementer коммитит в main → rc 1.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── зелёный контроль 1: судья (зонирован verdicts/*) коммитит вердикт в main ──────
SUD="$WORK/repo_sudja"
make_repo_multizone "$SUD"                   # зоны implementer(scripts/) + critic(verdicts/)
set_author "$SUD" critic
mk_wip "$SUD" wip/018/architect              # жива ЧУЖАЯ wip-ветка (не critic) — репо на main
stage "$SUD" verdicts/critic/contracts-018-v1.md 'вердикт критика — путь в зоне critic'
"$BARRIER" "$SUD" || true                    # ожидание: rc 0 (у critic нет СВОЕЙ wip-ветки)

# ── зелёный контроль 2: владелец (не зонирован) на main ──────────────────────────
VLA="$WORK/repo_vladelec"
make_repo "$VLA"
set_author "$VLA" vladelec
stage "$VLA" scripts/ustav.txt 'правка владельца — автор без зон, fail-open'
"$BARRIER" "$VLA" || true                    # ожидание: rc 0 («не судится»)

# ── красный: рабочий агент со своей живой веткой коммитит в main ──────────────────
RED="$WORK/repo_rabochij"
make_repo "$RED"
mk_wip "$RED" wip/018/implementer
stage "$RED" scripts/b.sh 'работа исполнителя мимо своего worktree'
"$BARRIER" "$RED" || true                    # ожидание: rc 1 «вне своей ветки wip/»
