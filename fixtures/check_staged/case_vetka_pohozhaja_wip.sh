# ПРИЧИНА: вне своей ветки wip/
#
# Срез 1 контракта 018, класс срезания операции сравнения (Р4 арбитража
# verdicts/arbitration/contracts-018-krasnyj-kontur-vetki.md, замер 4): у зонированного
# автора implementer со СВОЕЙ живой веткой wip/018/implementer текущий чекаут — ЧУЖАЯ
# wip/018/implementerXyz, где имя committer «implementer» есть СОБСТВЕННАЯ ПОДСТРОКА
# последнего компонента «implementerXyz», но НЕ равна ему. Честный предикат («последний
# компонент == committer») краснит: implementerXyz != implementer. Плацебо, срезающее
# равенство до подстроки/глоба (`wip/*<committer>*`), пропустит зелёным — потому этот вход
# НЕЗАВИСИМ от Р3 (detached): подстрочное плацебо переживает detached и гибнет ТОЛЬКО здесь.
# На текущем барьере вход ЗЕЛЁН — красное не предъявлено, раннер краснит пачку; после среза
# 1 — rc 1 с причиной.
#
# Зелёный контроль: тот же автор implementer НА СВОЕЙ ветке wip/018/implementer → rc 0. Он
# же ловит переусердие: барьер, краснящий автора на его СОБСТВЕННОЙ wip тоже, убил бы контроль.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── зелёный контроль: автор implementer на СВОЕЙ ветке wip/018/implementer ────────
GREEN="$WORK/repo_svoja"
make_repo "$GREEN"
co_wip "$GREEN" wip/018/implementer            # агент в своём worktree, на своей ветке
stage "$GREEN" scripts/b.sh 'работа исполнителя в своей ветке — норма'
"$BARRIER" "$GREEN" || true                    # ожидание: rc 0 (последний компонент == committer)

# ── красный: чекаут на ЧУЖОЙ wip/018/implementerXyz — committer «implementer» ПОДСТРОКА
#    последнего компонента, но != ему (срезание равенства компонента до подстроки, замер 4) ─
RED="$WORK/repo_pohozhaja"
make_repo "$RED"
mk_wip "$RED" wip/018/implementer              # своя ветка жива (агент спавнен)
co_wip "$RED" wip/018/implementerXyz           # чекаут переключён на ЧУЖУЮ похожую ветку
stage "$RED" scripts/b.sh 'та же работа, но в ветке implementerXyz — чужой worktree'
"$BARRIER" "$RED" || true                      # ожидание: rc 1 «вне своей ветки wip/»
