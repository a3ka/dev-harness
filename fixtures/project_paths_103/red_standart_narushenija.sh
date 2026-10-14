#!/usr/bin/env bash
# Клетка И-4б «каждое условие стандарта, нарушенное по одному, → rc 1 своей
# причиной» (контракт 103). Из эталона строится 11 миров, в каждом нарушено
# РОВНО ОДНО условие; субъект обязан дать rc 1 и строку «ОТКАЗ: стандарт:
# <имя>:» ровно этого условия. Клетка прогоняет ВСЕ нарушения (не умирает на
# первом) и красна, если хоть одно не названо. Имена причин — единый источник
# model/check_project_standard.sh (шапка). Обман (снята проверка одного
# условия) → его мир даёт rc 0 → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_standard)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: standart-narushenija: предмет отсутствует: scripts/check_project_standard.sh\n' >&2; exit 1; }
W="$(_t103_complior i4b)" || exit 2
trap '_t103_cleanup "$W"' EXIT
ET="$W/repo"

# narushenie <имя-причины> <bash-порча в репо $R>
itog=0; n=0
narushenie() {
  local name="$1" porcha="$2" R out rc
  n=$((n+1))
  R="$W/v$n"; cp -a "$ET" "$R"
  ( cd "$R" && eval "$porcha" ) || { printf 'КРАСНО: i4б/%s: порча не применилась\n' "$name" >&2; itog=1; return; }
  out="$(cd / && HARNESS_PROJECT_LAYER_ROOT="$R" bash "$SUBJ" --repo "$R" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ]; then
    printf 'КРАСНО: i4б/%s: rc=%s (ждали 1): %s\n' "$name" "$rc" "$out" >&2; itog=1; return
  fi
  if ! printf '%s\n' "$out" | grep -Fq "ОТКАЗ: стандарт: $name:"; then
    printf 'КРАСНО: i4б/%s: причина не названа (вывод: %s)\n' "$name" "$out" >&2; itog=1; return
  fi
  printf -- '— i4б/%s: rc=1, причина названа\n' "$name"
}

narushenie git-origin     'git remote remove origin'
narushenie git-main       'git branch -m main master'
narushenie profil         'jq "del(.repoId)" harness.project.json | tee harness.project.json.new >/dev/null && mv harness.project.json.new harness.project.json'
narushenie workflowPaths  'rm -rf .harness/contracts'
narushenie lockfile       'rm package-lock.json'
narushenie komandy-true   'jq ".commands.test = \"true\"" harness.project.json | tee harness.project.json.new >/dev/null && mv harness.project.json.new harness.project.json'
narushenie agents-md      ': > AGENTS.md'
narushenie kontekst-karta 'jq ".contextPack.rows |= map(select(.kind != \"rules\"))" harness.project.json | tee harness.project.json.new >/dev/null && mv harness.project.json.new harness.project.json'
narushenie env-example    'rm .env.example'
narushenie env-ignore     'printf "node_modules/\n" | tee .gitignore >/dev/null'
narushenie harness-pin    'rm config/harness_pin.json'

[ "$n" -eq 11 ] || { printf 'КРАСНО: i4б: нарушений прогнано %s, ждали 11\n' "$n" >&2; exit 1; }
exit "$itog"
