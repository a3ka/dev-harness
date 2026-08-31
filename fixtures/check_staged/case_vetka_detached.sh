# ПРИЧИНА: вне своей ветки wip/
#
# Срез 1 контракта 018, ветвь предиката «ветки НЕТ вовсе» (Р3 арбитража
# verdicts/arbitration/contracts-018-krasnyj-kontur-vetki.md): у зонированного автора со
# СВОЕЙ живой веткой wip/018/implementer текущий чекаут отвязан от ветки (detached HEAD) —
# `git symbolic-ref --short HEAD` отказывает, ветка чекаута не читается. Это ОТДЕЛЬНЫЙ путь
# кода: он не покрыт ни свидетелем main (именованная не-wip ветка), ни свидетелем чужой wip
# (wip-ветка, последний компонент != committer). Автор-компонент имени чекаута не
# определён → чекаут не СВОЯ wip → красное. На текущем барьере (страж ветки ещё нет) вход
# ЗЕЛЁН — красное не предъявлено, раннер краснит пачку; после среза 1 — rc 1 с причиной.
#
# ЕДИНСТВЕННЫЙ зелёный контроль (З1 арбитража): своя wip ДРУГОГО NNN —
# wip/019/implementer при авторе implementer → rc 0. «Своя» ⟺ последний компонент имени
# ветки == committer при ЛЮБОМ NNN; литерал-NNN плацебо (страж пинует «свою» как
# wip/018/<committer>) на нём ложно краснеет и валит case «нет положительного контроля»
# (замер 5 арбитра) — потому он ЕДИНСТВЕННЫЙ зелёный этого case и гибнет один.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── зелёный контроль (З1): своя wip ДРУГОГО NNN — wip/019/implementer, автор implementer ──
GREEN="$WORK/repo_drugoj_nnn"
make_repo "$GREEN"
co_wip "$GREEN" wip/019/implementer           # своя ветка СЛЕДУЮЩЕГО майлстоуна — норма
stage "$GREEN" scripts/b.sh 'работа исполнителя в своей ветке другого майлстоуна'
"$BARRIER" "$GREEN" || true                   # ожидание: rc 0 («своя» при любом NNN)

# ── красный: detached HEAD при живой своей wip/018/implementer ────────────────────
RED="$WORK/repo_detached"
make_repo "$RED"
mk_wip "$RED" wip/018/implementer             # своя ветка жива (агент спавнен)
detach_head "$RED"                            # чекаут отвязан от ветки — symbolic-ref откажет
stage "$RED" scripts/b.sh 'коммит в detached HEAD — ветки нет вовсе'
"$BARRIER" "$RED" || true                     # ожидание: rc 1 «вне своей ветки wip/»
