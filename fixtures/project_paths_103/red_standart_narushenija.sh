#!/usr/bin/env bash
# Клетка И-4б «каждое условие стандарта, нарушенное по одному, → rc 1 своей
# причиной» (контракт 103). Из эталона строится 11 миров, в каждом нарушено
# РОВНО ОДНО условие; субъект обязан дать rc 1 и строку «ОТКАЗ: стандарт:
# <имя>:» ровно этого условия. Клетка прогоняет ВСЕ нарушения (не умирает на
# первом) и красна, если хоть одно не названо. Имена причин — единый источник
# model/check_project_standard.sh (шапка). Обман (снята проверка одного
# условия) → его мир даёт rc 0 → красно.
#
# Варианты предикатов (Рв96-4 ST2/ST3/ST6): у условия несколько ветвей, и
# каждая судится СВОИМ миром с ровно одним нарушением — иначе стаб, оставивший
# одну ветвь из нескольких, зелен на канонических 11 мирах:
#   komandy-true/lint|typecheck|build — замаскирована не test, а другая команда;
#   profil/schemaVersion              — ключ есть, но значение 2 (не 1);
#   env-ignore/indeks                 — .env игнорируется правилом, но лежит в индексе
#                                       (git add -f) → деталь «.env в индексе» обязана
#                                       быть названа (фраза — строка модели, продукт
#                                       несёт её побайтово); иных входов, где ветвь
#                                       индекса наблюдаема, нет: check-ignore на
#                                       трекаемом файле сам даёт rc 1.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_standard)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: standart-narushenija: предмет отсутствует: scripts/check_project_standard.sh\n' >&2; exit 1; }
W="$(_t103_complior i4b)" || exit 2
trap '_t103_cleanup "$W"' EXIT
ET="$W/repo"

# narushenie <имя-причины> <bash-порча в репо $R> [<обязательная строка детали>] [<метка варианта>]
itog=0; n=0
narushenie() {
  local name="$1" porcha="$2" detal="${3:-}" id R out rc
  id="$1${4:+/$4}"
  n=$((n+1))
  R="$W/v$n"; cp -a "$ET" "$R"
  ( cd "$R" && eval "$porcha" ) || { printf 'КРАСНО: i4б/%s: порча не применилась\n' "$id" >&2; itog=1; return; }
  out="$(cd / && HARNESS_PROJECT_LAYER_ROOT="$R" bash "$SUBJ" --repo "$R" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ]; then
    printf 'КРАСНО: i4б/%s: rc=%s (ждали 1): %s\n' "$id" "$rc" "$out" >&2; itog=1; return
  fi
  if ! printf '%s\n' "$out" | grep -Fq "ОТКАЗ: стандарт: $name:"; then
    printf 'КРАСНО: i4б/%s: причина не названа (вывод: %s)\n' "$id" "$out" >&2; itog=1; return
  fi
  if [ -n "$detal" ] && ! printf '%s\n' "$out" | grep -Fxq "$detal"; then
    printf 'КРАСНО: i4б/%s: деталь не названа: «%s» (вывод: %s)\n' "$id" "$detal" "$out" >&2; itog=1; return
  fi
  printf -- '— i4б/%s: rc=1, причина названа\n' "$id"
}
jq_v() { jq "$1" harness.project.json | tee harness.project.json.new >/dev/null && mv harness.project.json.new harness.project.json; }

narushenie git-origin     'git remote remove origin'
narushenie git-main       'git branch -m main master'
narushenie profil         'jq_v "del(.repoId)"'
narushenie workflowPaths  'rm -rf .harness/contracts'
narushenie lockfile       'rm package-lock.json'
narushenie komandy-true   'jq_v ".commands.test = \"true\""'
narushenie agents-md      ': > AGENTS.md'
narushenie kontekst-karta 'jq_v ".contextPack.rows |= map(select(.kind != \"rules\"))"'
narushenie env-example    'rm .env.example'
narushenie env-ignore     'printf "node_modules/\n" | tee .gitignore >/dev/null'
narushenie harness-pin    'rm config/harness_pin.json'
[ "$n" -eq 11 ] || { printf 'КРАСНО: i4б: канонических нарушений прогнано %s, ждали 11\n' "$n" >&2; exit 1; }

# варианты предикатов — по одному нарушению на мир
n0="$n"
narushenie komandy-true   'jq_v ".commands.lint = \"true\""'      '' lint
narushenie komandy-true   'jq_v ".commands.typecheck = \"true\""' '' typecheck
narushenie komandy-true   'jq_v ".commands.build = \"true\""'     '' build
narushenie profil         'jq_v ".schemaVersion = 2"'             '' schemaVersion
narushenie env-ignore     'git add -f .env && git commit -qm ".env в индексе"' 'ОТКАЗ: стандарт: env-ignore: .env в индексе' indeks
[ $((n - n0)) -eq 5 ] || { printf 'КРАСНО: i4б: вариантов прогнано %s, ждали 5\n' "$((n - n0))" >&2; exit 1; }
exit "$itog"
