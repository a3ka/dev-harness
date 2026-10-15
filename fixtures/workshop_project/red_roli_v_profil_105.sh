#!/usr/bin/env bash
# red_roli_v_profil_105.sh — клетка И-3 контракта 105: роли харнеса
# материализуются в каталог агента ПРОФИЛЯ — `$HOME/.omp/profiles/dev/agent/
# agents/*.md`, где $HOME — тот HOME, который получает ребёнок-omp (env-дамп
# стаба); состав файлов = состав roles/ установки (оракул в памяти);
# `$HOME/.omp/agent/agents` (каталог НЕ профиля — omp под --profile его не
# читает, omp://config-usage.md «Profiles») этим запуском НЕ создаётся.
# Путь берётся из строки `AGENTS: <путь>` stdout (одна строка).
#
# rc 0 — зелёная; rc 1 — красная («105 И-3 КРАСНО: …»); rc 2 — мир сломан.
# ДО реализации на живом workshop — красная: роли ложатся в $HOME/.omp/agent/
# agents (workshop:869), строки AGENTS: нет.
CELL="И-3"
# shellcheck source=_mir_105.sh
. "$(dirname "${BASH_SOURCE[0]}")/_mir_105.sh"

cell() {
  local agents n_ag home_child got_roles
  run_live k3
  [ "$RC" -eq 0 ] || { pokazat k3; krasno "живой запуск упал rc=$RC"; return; }
  [ "$(launch_n k3)" -eq 1 ] || { krasno "стаб-omp запущен $(launch_n k3) раз, ожидался ровно 1"; return; }
  n_ag="$(out_vals k3 AGENTS | wc -l)"
  [ "$n_ag" -eq 1 ] || { krasno "строк AGENTS: в stdout $n_ag, ожидалась ровно 1"; return; }
  agents="$(out_vals k3 AGENTS)"
  home_child="$(sed -n 's/^HOME=//p' "$WORK/k3.env")"
  [ -n "$home_child" ] || { krasno "в окружении ребёнка-omp нет HOME"; return; }
  [ "$agents" = "$home_child/.omp/profiles/dev/agent/agents" ] \
    || { krasno "AGENTS: $agents ≠ <HOME ребёнка>/.omp/profiles/dev/agent/agents (HOME=$home_child)"; return; }
  [ -d "$agents" ] || { krasno "каталога $agents нет"; return; }
  got_roles="$(ls "$agents" | sorted)"
  [ "$got_roles" = "$EXPECT_ROLES" ] || { krasno "состав $agents ≠ состав roles/ установки"; return; }
  [ ! -e "$home_child/.omp/agent/agents" ] \
    || { krasno "создан $home_child/.omp/agent/agents — каталог вне профиля dev, omp под --profile его не читает"; return; }
  return 0
}
cell
rc=$?
printf '105 И-3: клетка %s\n' "$([ $rc -eq 0 ] && printf 'зелёная' || printf 'красная')"
exit $rc
