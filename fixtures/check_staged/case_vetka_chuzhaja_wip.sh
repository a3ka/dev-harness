# ПРИЧИНА: вне своей ветки wip/
#
# Срез 1 контракта 018, БЛОКЕР critic v1 (verdicts/critic/contracts-018-v1.md): страж
# «ветка, не main» обязан краснить зонированного автора, коммитящего на ЧУЖОЙ wip-ветке —
# не только на main. Вход различает страж «СВОЯ ветка wip/<NNN>/<committer>» от
# «любой wip/* против не-wip/*» (обход критика: implementer со своей живой wip/018/implementer
# переключён на wip/018/architect и staged-ит scripts/b.sh — «любой wip/*»-страж пропускает
# зелёным, а собственно-веточный краснит). Автор-компонент имени ветки (последний сегмент
# после последнего `/`) != committer → красное. На текущем барьере (страж ветки ещё нет)
# красный вход ЗЕЛЁН — красное не предъявлено, раннер краснит пачку; после среза 1 — rc 1.
#
# Зелёный контроль: тот же автор НА СВОЕЙ ветке wip/018/implementer → rc 0. Он же ловит
# переусердие: барьер, краснящий автора на его СОБСТВЕННОЙ wip тоже, убил бы этот контроль.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── зелёный контроль: автор implementer на СВОЕЙ ветке wip/018/implementer ────────
GREEN="$WORK/repo_svoja"
make_repo "$GREEN"
co_wip "$GREEN" wip/018/implementer          # агент в своём worktree, на своей ветке
stage "$GREEN" scripts/b.sh 'работа исполнителя в своей ветке — норма'
"$BARRIER" "$GREEN" || true                  # ожидание: rc 0 (автор-компонент == committer)

# ── красный: implementer со своей ЖИВОЙ wip/018/implementer, но чекаут на ЧУЖОЙ
#    wip/018/architect (обход критика: «любой wip/*» пройдёт, собственно-веточный краснит) ─
RED="$WORK/repo_chuzhaja"
make_repo "$RED"
mk_wip "$RED" wip/018/implementer            # своя ветка жива (implementer спавнен)
co_wip "$RED" wip/018/architect              # но чекаут переключён на ЧУЖУЮ wip architect
stage "$RED" scripts/b.sh 'та же работа, но в ветке architect — чужой worktree'
"$BARRIER" "$RED" || true                    # ожидание: rc 1 «вне своей ветки wip/»
