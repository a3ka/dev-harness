# ПРИЧИНА: HEAD не main
#
# Срез 2 контракта 016, ветвь «HEAD не main»: спавн wip/* обязан идти от main. Если HEAD
# репозитория смотрит на другую ветку, `spawn_agent.sh` отказывает поимённо «HEAD не main»
# (контракт явно перечисляет этот отказ среди объявленных).
#
# Вход подобран РАЗЛИЧИМЫМ (Н-39): «идентичность вне глобального дефолта» для spawn_agent
# закрыт КОДОМ самого spawn_agent (Н-61/А-25) — каждая git-операция идёт с `-c user.name=...`.
# Через `$BARRIER` это поведение проверяется интеграционно, не фикстурой спавна: спавн
# не делает коммитов от чужого имени, проверить author ветки wip/<NNN>/<author> не на чем
# (ветка указывает на main, последний коммит в ней — коммит, записанный `make_repo` для
# каркаса). Поэтому различимый красный берётся соседней ветвью контракта — HEAD не main.
#
# Зелёный контроль: spawn от main → wip/001/implementer + worktree (rc 0). Ветка реально
# появляется в refs/heads/wip/.
#
# Красное: HEAD переводится на wip/002/leftover (ручная ветка + пустой коммит), spawn с
# теми же аргументами падает «HEAD не main», rc 1, подстрока «HEAD не main» в stderr.
# HEAD ОСТАВЛЯЕТСЯ на wip/002/leftover — без отката, потому что verify_antiplacebo повторяет
# красный вызов в `cd $cwd`, где $cwd — PWD фикстуры на момент отправки заявки ($R), и
# HEAD внутри $R остаётся wip/002/leftover → повтор снова красный, с той же подстрокой.
#
# Конвенция фикстуры: spawn_agent.sh НЕ имеет CLI-флагов `--nnn` и `--root` — он опирается
# на cwd вызывающего процесса. Поэтому каждая фикстура обязана `cd "$R"` ДО первого
# вызова `$BARRIER --author ...`, иначе cwd канала будет каноническим корнем проверяющего
# (dev-harness), и спавн создаст ветку ТАМ. Серийные вызовы — `|| true` (А-32): на красном
# шаге spawn падает, но фикстура обязана продолжить до отрицательного контроля.
#
# ПРИМЕЧАНИЕ. Имя «без идентичности» сохранено по требованию контракта (case_bez_identichnosti
# упоминается в §6.4 как rc-точка для --scope spawn_agent).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

cd "$R"

# ── Зелёный контроль: spawn от main → wip/001/implementer + worktree ──────────
out_green="$("$BARRIER" --author implementer || true)"
wt="$(printf '%s\n' "$out_green" | awk -F= '/^WORKTREE=/ {print $2; exit}')"
br="$(printf '%s\n' "$out_green" | awk -F= '/^BRANCH=/ {print $2; exit}')"
if [ -z "$wt" ] || [ -z "$br" ]; then
  printf 'ОТКАЗ: spawn от main не выдал WORKTREE/BRANCH: %s\n' "$out_green" >&2
  exit 1
fi
# Ветка wip/001/implementer должна реально появиться в $R.
if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null | grep -q "^refs/heads/$br\$"; then
  printf 'ОТКАЗ: spawn не создал ветку %s в $R\n' "$br" >&2
  exit 1
fi

# ── Красное: HEAD уводим на wip/002/leftover (создаём ручной веткой + пустым коммитом).
#    spawn с теми же аргументами падает «HEAD не main», rc 1, с подстрокой «HEAD не main».
#    HEAD фикстуры ОСТАВЛЯЕТСЯ на wip/002/leftover — повтор проверяющим через `ap_run`
#    выполнит spawn_agent.sh в том же $R/HEAD и тоже получит rc=1 «HEAD не main».
GIT_AUTHOR_NAME=leftover GIT_AUTHOR_EMAIL=leftover@local \
GIT_COMMITTER_NAME=leftover GIT_COMMITTER_EMAIL=leftover@local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
    commit --allow-empty -q -m 'основание wip/002'
git -C "$R" branch -f wip/002/leftover HEAD
git -C "$R" checkout -q wip/002/leftover
out_red="$("$BARRIER" --author implementer || true)"
if ! printf '%s\n' "$out_red" | grep -q 'HEAD не main'; then
  printf 'ОТКАЗ: spawn при HEAD != main не дал «HEAD не main»: %s\n' "$out_red" >&2
  exit 1
fi
