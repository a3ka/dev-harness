#!/usr/bin/env bash
# Группа C батареи 125: одна команда подключения (субъект CONNECT_SUBJECT). Мир: игрушечная
# установка (субъект + двойник workshop, пишущий argv и счёт вызовов), поддельный $HOME с домом
# секретов (случайные значения), двойники git (клон https://github.com/... → локальный seed,
# argv клона пишется), gh, omp (`--version` → omp/v10). Без сети. Резолвер профиля — живой HEAD.
# Оракулы (projectId, значения секретов, хеши объявлений и кода проекта, опись дерева до
# подключения) — в памяти ДО вызова субъекта (правило 8). Перечни — из source.json.
# Toy Complior-mob: снимок стража корня моба и его CI (complior_mob_toy/: check-structure.cjs,
# structure-policy.json, mobile.yml — побайтно с ~/projects/Complior-mob @ 60cc1ee) + минимальный
# допустимый его политикой набор файлов; код и CI тоя не правятся.
# Печать: «ЗЕЛЕНО <id>» | «КРАСНО <id>: <почему>»; мир сломан → rc 2.
set -uo pipefail
C_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
ROOT=$(cd "$C_DIR/../../.." && pwd -P)
SRC_JSON="$C_DIR/source.json"
SUBJ=${CONNECT_SUBJECT:?нет CONNECT_SUBJECT}
IDS="c01-zapusk-odin c02-yolo c03-projectid c04-klon-https-gh c05-pin c06-deny c07-karkas c08-tolko-harness c09-env-klyuchi c10-sekrety-vyvod c11-sekrety-repo c12-povtor c13-sverhu c14-imya-vne-klassa c15-mob-bez-pravok c16-mob-ci c17-env-v-indekse c18-zhizn-povtor c19-zhizn-add-f c20-zhizn-add-a c21-zhizn-vetka c22-zhizn-imya"
test -f "$SUBJ" || { for id in $IDS; do printf 'КРАСНО %s: субъекта нет: %s\n' "$id" "$SUBJ"; done; exit 0; }
REALGIT=$(command -v git) || exit 2
command -v node >/dev/null 2>&1 || { printf 'мир 125/C сломан: нет node (страж тоя Complior-mob)\n' >&2; exit 2; }
v() { if [ "$2" = 1 ]; then printf 'ЗЕЛЕНО %s\n' "$1"; else printf 'КРАСНО %s: %s\n' "$1" "$3"; fi; }
ok_if() { if [ -z "$1" ]; then echo 1; else echo 0; fi; }
WORK=$(mktemp -d "${TMPDIR:-/tmp}/red125c.XXXXXX"); trap 'rm -rf "$WORK"' EXIT
rnd() { printf '%s' "${RANDOM}${RANDOM}$$" | sha256sum | cut -c1-12; }
ENV_REL=$(jq -r '.env_rel' "$SRC_JSON"); PIN_REL=$(jq -r '.pin_rel' "$SRC_JSON")
KEYS_RE=$(jq -r '.bootstrap_keys | join("|")' "$SRC_JSON")
mapfile -t HARN < <(jq -r '.harness_v_dereve[]' "$SRC_JSON")
mir() { # $1 = имя мира; $2 = имя репозитория (seed)
  local M="$WORK/$1"
  mkdir -p "$M/inst/scripts" "$M/inst/.omp/extensions" "$M/inst/config" "$M/home/.config/dev-harness" "$M/bin" "$M/seed/$2"
  cp "$SUBJ" "$M/inst/scripts/connect_project.sh"
  # 136 v2 (Rev136-B2): минимальная установка несёт ДЕЙСТВИТЕЛЬНЫЕ страж и конфиг
  # из дерева — дверь 136 fail-closed при их отсутствии, честный субъект обязан
  # проходить; отсутствие guard/config в мире больше не маскирует отступления.
  cp "$ROOT/.omp/extensions/path-guard.ts" "$M/inst/.omp/extensions/path-guard.ts"
  cp "$ROOT/config/agent_models.json" "$M/inst/config/agent_models.json"
  printf '#!/usr/bin/env bash\nfor a in "$@"; do printf "%%s\\n" "$a"; done > %s/workshop.argv\nprintf "%%s\\0" "$@" > %s/workshop.argv0\nprintf "launch\\n" >> %s/workshop.calls\n' "$M" "$M" "$M" > "$M/inst/workshop"
  printf '#!/bin/sh\nif [ "$1" = --version ]; then echo omp/v10; exit 0; fi\nexit 0\n' > "$M/bin/omp"
  printf '#!/bin/sh\nprintf "%%s\\n" "$@" >> %s/gh.argv\nexit 0\n' "$M" > "$M/bin/gh"
  cat > "$M/bin/git" <<G
#!/usr/bin/env bash
for a in "\$@"; do
  if [ "\$a" = clone ]; then
    printf '%s\n' "\$@" > "$M/git-clone.argv"
    url=""; dst=""; for b in "\$@"; do case "\$b" in https://github.com/*) url=\$b ;; esac; done
    dst=\${!#}; name=\${url##*/}; name=\${name%.git}
    "$REALGIT" clone -q "$M/seed/\$name" "\$dst" || exit 128
    "$REALGIT" -C "\$dst" remote set-url origin "\$url"; exit 0
  fi
done
exec "$REALGIT" "\$@"
G
  chmod +x "$M/inst/workshop" "$M/bin/omp" "$M/bin/gh" "$M/bin/git"
  SEC_TOKEN="tok-$(rnd)"; SEC_GH="gh-$(rnd)"
  printf 'METERING_PROXY_URL=http://toy.invalid:1\nMETERING_PROXY_TOKEN=%s\nGH_TOKEN=%s\n' "$SEC_TOKEN" "$SEC_GH" > "$M/home/.config/dev-harness/secrets.env"
  "$REALGIT" -C "$M/seed/$2" init -q
  printf '# %s\n' "$2" > "$M/seed/$2/README.md"
  "$REALGIT" -C "$M/seed/$2" add -A
  "$REALGIT" -C "$M/seed/$2" -c user.name=t -c user.email=t@t.invalid commit -q -m init
}
run_connect() { # $1 = мир; $2 = вход
  local M="$WORK/$1"; RC=0
  ( cd "$M" && env -u HARNESS_PROJECT_LAYER_ROOT HOME="$M/home" PATH="$M/bin:$PATH" bash "$M/inst/scripts/connect_project.sh" "$2" > "$M/out" 2> "$M/err" ) || RC=$?
}
calls() { if [ -f "$1/workshop.calls" ]; then grep -cx launch "$1/workshop.calls"; else echo 0; fi; }
# опись дерева — ВСЕ пути (файлы, ссылки, каталоги, в т.ч. пустые), кроме .git
opis() { (cd "$1" && find . -path ./.git -prune -o -print | sed 's|^\./||' | grep -vx '\.' | LC_ALL=C sort); }
harn() { local p=$1 h; for h in "${HARN[@]}"; do case "$h" in */) case "$p" in "${h%/}"|"$h"*) return 0 ;; esac ;; *) [ "$p" = "$h" ] && return 0 ;; esac; done; return 1; }
# ── свежий репозиторий по URL, имя с ЗАГЛАВНЫМИ: c01–c11 ──
NAME="Toy-Repo-$(rnd | cut -c1-4)"; WANT_PID=$(printf '%s' "$NAME" | tr 'A-Z' 'a-z')
mir m1 "$NAME"; M="$WORK/m1"; P="$M/home/projects/$NAME"
OPIS0=$(cd "$M/seed/$NAME" && opis .)
run_connect m1 "https://github.com/acme/$NAME.git"
why=""; [ "$RC" = 0 ] || why="$why rc=$RC($(sed -n '1p' "$M/err"));"
[ "$(calls "$M")" = 1 ] || why="$why workshop вызван $(calls "$M") раз, ждали 1;"
# 136 v2 (Rev136-B1): оракул границ argv — NUL-разделённый workshop.argv0, не
# построчный tail (последняя СТРОКА сериализации ≠ последний аргумент при
# многострочном MSG). Корень — ОТДЕЛЬНЫЙ аргумент ДО разделителя: либо форма 125
# без хвоста [--yolo, P], либо форма 136 [--yolo, P, --, MSG] с непустым MSG
# (последний argv — MSG). Корень только в MSG / только после -- / не передан /
# чужой — КРАСНО; MSG, кончающийся путём проекта, — зелёный положительный.
wa=(); [ -f "$M/workshop.argv0" ] && mapfile -d '' -t wa < "$M/workshop.argv0"
okargv=0
if [ "${#wa[@]}" = 2 ] && [ "${wa[0]}" = --yolo ] && [ "${wa[1]}" = "$P" ]; then okargv=1; fi
if [ "${#wa[@]}" = 4 ] && [ "${wa[0]}" = --yolo ] && [ "${wa[1]}" = "$P" ] && [ "${wa[2]}" = -- ] && [ -n "${wa[3]}" ]; then okargv=1; fi
[ "$okargv" = 1 ] || why="$why границы argv workshop ≠ [--yolo, $P] | [--yolo, $P, --, непустой MSG]: $(tr '\n' '|' < "$M/workshop.argv" 2>/dev/null);"
v c01-zapusk-odin "$(ok_if "$why")" "$why"
ok=0; grep -qxF -- '--yolo' "$M/workshop.argv" 2>/dev/null && ok=1
v c02-yolo "$ok" "workshop запущен без --yolo (вход основной сессии — workshop --yolo): $(cat "$M/workshop.argv" 2>/dev/null | tr '\n' ' ')"
PIDGOT=$(HARNESS_PROJECT_LAYER_ROOT="$P" bash "$ROOT/scripts/profile_resolver.sh" --repo "$P" 2>/dev/null | jq -r '.projectId.value // empty' 2>/dev/null)
v c03-projectid "$([ "$PIDGOT" = "$WANT_PID" ] && echo 1 || echo 0)" "резолвер дал projectId «$PIDGOT», ждали «$WANT_PID»"
ok=0; grep -qxF 'credential.helper=!gh auth git-credential' "$M/git-clone.argv" 2>/dev/null && grep -qxF "https://github.com/acme/$NAME.git" "$M/git-clone.argv" && ok=1
v c04-klon-https-gh "$ok" "клон не через https + gh credential helper: $(cat "$M/git-clone.argv" 2>/dev/null | tr '\n' ' ')"
v c05-pin "$([ "$(jq -r '.version // empty' "$P/$PIN_REL" 2>/dev/null)" = v10 ] && echo 1 || echo 0)" "$PIN_REL ≠ omp --version (v10)"
v c06-deny "$([ "$("$REALGIT" -C "$P" config --local --get receive.denyCurrentBranch 2>/dev/null)" = refuse ] && echo 1 || echo 0)" "receive.denyCurrentBranch ≠ refuse"
why=""; for f in HANDOFF.md NABLIUDENIA.md ROADMAP.md; do [ -s "$P/.harness/$f" ] || why="$why нет .harness/$f;"; done
[ "$(jq -r '.projectLayer.profilePath // empty' "$P/harness.project.json" 2>/dev/null)" = .harness/project-layer.json ] || why="$why профиль не ведёт на .harness/project-layer.json;"
v c07-karkas "$(ok_if "$why")" "$why"
why=""
while IFS= read -r p; do
  printf '%s\n' "$OPIS0" | grep -qxF -- "$p" && continue
  harn "$p" || why="$why $p;"
done < <(opis "$P")
v c08-tolko-harness "$(ok_if "$why")" "новое вне .harness/ и профиля:$why"
why=""
if [ ! -f "$P/$ENV_REL" ]; then why="$why нет $ENV_REL;"
else
  [ "$(stat -c %a "$P/$ENV_REL")" = 600 ] || why="$why $ENV_REL не 600;"
  grep -vE "^($KEYS_RE)=" "$P/$ENV_REL" | grep -q . && why="$why ключ вне списка bootstrap_env;"
  grep -qxF "METERING_PROXY_TOKEN=$SEC_TOKEN" "$P/$ENV_REL" || why="$why нет METERING_PROXY_TOKEN из дома секретов;"
fi
v c09-env-klyuchi "$(ok_if "$why")" "$why"
why=""; for s in "$SEC_TOKEN" "$SEC_GH"; do grep -qF -- "$s" "$M/out" "$M/err" "$M/workshop.argv" 2>/dev/null && why="$why значение секрета в выводе/argv;"; done
v c10-sekrety-vyvod "$(ok_if "$why")" "$why"
# c11: секрет вне git проекта — не виден, игнорируется, НЕ в индексе и не в HEAD; значения — только в .harness/.env
why=""
"$REALGIT" -C "$P" status --porcelain --untracked-files=all | grep -qxF -- "?? $ENV_REL" && why="$why $ENV_REL видим git (не исключён);"
"$REALGIT" -C "$P" check-ignore -q -- "$ENV_REL" || why="$why $ENV_REL не игнорируется git (git add -A его заберёт);"
[ -z "$("$REALGIT" -C "$P" ls-files -- "$ENV_REL")" ] || why="$why $ENV_REL в индексе git;"
for s in "$SEC_TOKEN" "$SEC_GH"; do
  while IFS= read -r f; do [ "$f" = "$P/$ENV_REL" ] || why="$why секрет в $f;"; done < <(grep -rlF --exclude-dir=.git -- "$s" "$P" 2>/dev/null)
  "$REALGIT" -C "$P" grep -qF --cached -e "$s" 2>/dev/null && why="$why значение секрета в индексе git;"
  "$REALGIT" -C "$P" grep -qF -e "$s" HEAD 2>/dev/null && why="$why значение секрета в HEAD;"
done
v c11-sekrety-repo "$(ok_if "$why")" "$why"
# ── c12: повторный запуск — досоздаётся ТОЛЬКО отсутствующее ──
printf -- '- правка проекта %s\n' "$(rnd)" >> "$P/.harness/HANDOFF.md"; rm -f "$P/.harness/ROADMAP.md"
H1=$(cd "$P" && sha256sum harness.project.json .harness/HANDOFF.md .harness/NABLIUDENIA.md .harness/project-layer.json "$PIN_REL" "$ENV_REL" 2>&1)
rm -f "$M/workshop.calls"; run_connect m1 "$P"
why=""; [ "$RC" = 0 ] || why="$why rc=$RC($(sed -n '1p' "$M/err"));"
[ "$(cd "$P" && sha256sum harness.project.json .harness/HANDOFF.md .harness/NABLIUDENIA.md .harness/project-layer.json "$PIN_REL" "$ENV_REL" 2>&1)" = "$H1" ] || why="$why существующее перезаписано;"
[ -s "$P/.harness/ROADMAP.md" ] || why="$why отсутствующее .harness/ROADMAP.md не досоздано;"
[ "$(calls "$M")" = 1 ] || why="$why повторный запуск не дошёл до workshop ровно раз;"
v c12-povtor "$(ok_if "$why")" "$why"
# ── c13: объявления проекта сверху (свой профиль, свой HANDOFF, пин наследия) не трогаются ──
NAME3="proj-$(rnd | cut -c1-4)"; mir m3 "$NAME3"; S="$WORK/m3/seed/$NAME3"
printf '{"schemaVersion":1,"repoId":"%s","own":"%s"}\n' "$NAME3" "$(rnd)" > "$S/harness.project.json"
mkdir -p "$S/.harness" "$S/config"; printf '## ГДЕ МЫ (свой %s)\n' "$(rnd)" > "$S/.harness/HANDOFF.md"
printf '{"version":"18.3.1"}\n' > "$S/config/harness_pin.json"
"$REALGIT" -C "$S" add -A; "$REALGIT" -C "$S" -c user.name=t -c user.email=t@t.invalid commit -q -m own
H1=$(sha256sum "$S/harness.project.json" "$S/.harness/HANDOFF.md" "$S/config/harness_pin.json")
run_connect m3 "$S"
why=""; [ "$(sha256sum "$S/harness.project.json" "$S/.harness/HANDOFF.md" "$S/config/harness_pin.json")" = "$H1" ] || why="$why объявления проекта перезаписаны;"
[ -e "$S/$PIN_REL" ] && why="$why второй пин $PIN_REL рядом с пином проекта;"
v c13-sverhu "$(ok_if "$why")" "$why"
# ── c14: имя, не дающее projectId класса, — именованный отказ ДО сессии ──
mir m4 "___"; run_connect m4 "$WORK/m4/seed/___"
ok=0; [ "$RC" = 1 ] && grep -qF 'projectid-vne-klassa' "$WORK/m4/err" && [ "$(calls "$WORK/m4")" = 0 ] && ok=1
v c14-imya-vne-klassa "$ok" "rc=$RC; ждали rc 1 «projectid-vne-klassa» без запуска workshop: $(sed -n '1p' "$WORK/m4/err")"
# ── c15/c16: toy Complior-mob — та же команда, без правок кода/CI; CI моба после подключения зелёный ──
mir m7 "Complior-mob"; S="$WORK/m7/seed/Complior-mob"; T7="$C_DIR/complior_mob_toy"
mkdir -p "$S/mobile/scripts" "$S/.github/workflows"
cp "$T7/check-structure.cjs" "$S/mobile/scripts/check-structure.cjs"; cp "$T7/structure-policy.json" "$S/mobile/structure-policy.json"
cp "$T7/mobile.yml" "$S/.github/workflows/mobile.yml"
printf '# toy\n' > "$S/AGENTS.md"; printf '# toy\n' > "$S/STRUCTURE.md"; printf 'node_modules/\n.env\n' > "$S/.gitignore"; printf '22\n' > "$S/.node-version"
printf '{"name":"toy-mob","scripts":{"lint":"node scripts/check-structure.cjs"}}\n' > "$S/mobile/package.json"
"$REALGIT" -C "$S" add -A; "$REALGIT" -C "$S" -c user.name=t -c user.email=t@t.invalid commit -q -m toy
( cd "$S" && node mobile/scripts/check-structure.cjs ) > "$WORK/m7/guard0" 2>&1 || { printf 'мир 125/C сломан: страж тоя Complior-mob красен ДО подключения: %s\n' "$(tr '\n' '|' < "$WORK/m7/guard0")" >&2; exit 2; }
# оракул c16 (ДО субъекта): CI моба (снимок mobile.yml) выносит .harness из дерева ПЕРЕД lint = страж корня
NL=$(grep -m1 -nxF '      - name: Вынести H из дерева до lint (layout-проверка не должна видеть .harness)' "$T7/mobile.yml" | cut -d: -f1)
NM=$(grep -m1 -nE '^          mv \.harness /' "$T7/mobile.yml" | cut -d: -f1)
NR=$(grep -m1 -nxF '      - run: npm run lint' "$T7/mobile.yml" | cut -d: -f1)
{ [ -n "$NL" ] && [ -n "$NM" ] && [ -n "$NR" ] && [ "$NL" -lt "$NM" ] && [ "$NM" -lt "$NR" ]; } \
  || { printf 'мир 125/C сломан: в снимке CI моба нет шага «Вынести H из дерева до lint» (mv .harness) перед npm run lint\n' >&2; exit 2; }
KOD=(mobile/scripts/check-structure.cjs mobile/structure-policy.json mobile/package.json .github/workflows/mobile.yml .gitignore AGENTS.md STRUCTURE.md README.md)
H1=$(cd "$S" && sha256sum "${KOD[@]}")
run_connect m7 "$S"
why=""; [ "$RC" = 0 ] || why="$why rc=$RC($(sed -n '1p' "$WORK/m7/err"));"
[ "$(calls "$WORK/m7")" = 1 ] || why="$why workshop вызван $(calls "$WORK/m7") раз, ждали 1;"
[ "$(cd "$S" && sha256sum "${KOD[@]}")" = "$H1" ] || why="$why код/CI тоя изменены;"
"$REALGIT" -C "$S" status --porcelain | grep -q '^ M\|^M ' && why="$why отслеживаемые файлы тоя изменены;"
v c15-mob-bez-pravok "$(ok_if "$why")" "$why"
# c16: шаги CI моба на копии дерева после двери — «Вынести H» (mv .harness), затем lint (страж в mobile/);
# судятся rc стража и его вывод ЦЕЛИКОМ, без фильтра строк
CIT="$WORK/m7/ci-tree"; cp -a "$S" "$CIT"
if [ -e "$CIT/.harness" ] || [ -L "$CIT/.harness" ]; then mv "$CIT/.harness" "$WORK/m7/ci-h"; fi
GRC=0; ( cd "$CIT/mobile" && node scripts/check-structure.cjs ) > "$WORK/m7/guard1" 2>&1 || GRC=$?
why=""; [ "$GRC" = 0 ] || why="$why rc стража $GRC;"
[ "$(cat "$WORK/m7/guard1")" = 'structure: OK (repository inventory; external trees excluded)' ] || why="$why вывод стража: $(tr '\n' '|' < "$WORK/m7/guard1");"
v c16-mob-ci "$(ok_if "$why")" "CI тоя Complior-mob после подключения красен:$why"
# ── c17: уже отслеживаемый git проекта .harness/.env — именованный отказ ДО записи секретов и ДО сессии ──
NAME5="proj-$(rnd | cut -c1-4)"; mir m5 "$NAME5"; S="$WORK/m5/seed/$NAME5"
mkdir -p "$S/.harness"; printf 'ZAI_API_KEY=old-%s\n' "$(rnd)" > "$S/$ENV_REL"
"$REALGIT" -C "$S" add -f -- "$ENV_REL"; "$REALGIT" -C "$S" -c user.name=t -c user.email=t@t.invalid commit -q -m env
H1=$(sha256sum "$S/$ENV_REL")
run_connect m5 "$S"
why=""; [ "$RC" = 1 ] || why="$why rc=$RC, ждали 1;"
grep -qF 'env-v-indekse' "$WORK/m5/err" || why="$why нет причины env-v-indekse: $(sed -n '1p' "$WORK/m5/err");"
[ "$(calls "$WORK/m5")" = 0 ] || why="$why workshop запущен;"
[ "$(sha256sum "$S/$ENV_REL")" = "$H1" ] || why="$why отслеживаемый $ENV_REL изменён;"
for s in "$SEC_TOKEN" "$SEC_GH"; do grep -rqF --exclude-dir=.git -- "$s" "$S" && why="$why значение секрета в дереве проекта;"; done
v c17-env-v-indekse "$(ok_if "$why")" "$why"
# ── c18–c22: «секрет в индексе» ПО ХОДУ ЖИЗНИ двери — закрытая таблица состояний (контракт, И-6) ──
# Каждое состояние — свой мир: первое подключение по URL, затем действие пользователя и/или
# повторный вход двери. Инвариант клетки: `git ls-files` без .harness/.env, значения секретов
# ни в индексе (`git grep --cached`), ни в HEAD; либо дверь отказывает своей причиной без сессии.
gitc() { "$REALGIT" -C "$1" -c user.name=t -c user.email=t@t.invalid "${@:2}"; }
zhizn() { # $1 = мир → ZM (каталог мира), Z (корень проекта), RC1 (rc первого входа)
  local nm; nm="life-$(rnd | cut -c1-4)"
  mir "$1" "$nm"; ZM="$WORK/$1"; Z="$ZM/home/projects/$nm"
  run_connect "$1" "https://github.com/acme/$nm.git"; RC1=$RC
}
polzovatel_add() { # обычная жизнь пользователя: git add -A, git add .harness, коммит
  "$REALGIT" -C "$1" add -A >/dev/null 2>&1; "$REALGIT" -C "$1" add .harness >/dev/null 2>&1
  gitc "$1" commit -q --allow-empty -m life >/dev/null 2>&1
}
indeks_chist() { # $1 = корень → причины (пусто — чисто)
  local s w=""
  [ -z "$("$REALGIT" -C "$1" ls-files -- "$ENV_REL")" ] || w="$w $ENV_REL в индексе git;"
  for s in "$SEC_TOKEN" "$SEC_GH"; do
    "$REALGIT" -C "$1" grep -qF --cached -e "$s" 2>/dev/null && w="$w значение секрета в индексе git;"
    "$REALGIT" -C "$1" grep -qF -e "$s" HEAD 2>/dev/null && w="$w значение секрета в HEAD;"
  done
  printf '%s' "$w"
}
ne_v_vyvode() { local s; for s in "$SEC_TOKEN" "$SEC_GH"; do grep -qF -- "$s" "$ZM/out" "$ZM/err" 2>/dev/null && printf ' значение секрета в выводе повтора;'; done; }
# c18 — повторное подключение (без действий пользователя между входами)
zhizn m8; why=""; [ "$RC1" = 0 ] || why="$why первый вход rc=$RC1;"
rm -f "$ZM/workshop.calls"; run_connect m8 "$Z"
[ "$RC" = 0 ] || why="$why повтор rc=$RC($(sed -n '1p' "$ZM/err"));"
[ "$(calls "$ZM")" = 1 ] || why="$why повтор не дошёл до workshop ровно раз;"
why="$why$(indeks_chist "$Z")$(ne_v_vyvode)"
v c18-zhizn-povtor "$(ok_if "$why")" "$why"
# c19 — повтор после ручного `git add -f .harness/.env`: отказ env-v-indekse без сессии, файл не тронут, HEAD чист
zhizn m9; why=""; [ "$RC1" = 0 ] || why="$why первый вход rc=$RC1;"
"$REALGIT" -C "$Z" add -f -- "$ENV_REL" 2>/dev/null; H1=$(sha256sum "$Z/$ENV_REL" 2>&1)
rm -f "$ZM/workshop.calls"; run_connect m9 "$Z"
[ "$RC" = 1 ] || why="$why повтор rc=$RC, ждали 1;"
grep -qF 'env-v-indekse' "$ZM/err" || why="$why нет причины env-v-indekse: $(sed -n '1p' "$ZM/err");"
[ "$(calls "$ZM")" = 0 ] || why="$why workshop запущен;"
[ "$(sha256sum "$Z/$ENV_REL" 2>&1)" = "$H1" ] || why="$why $ENV_REL изменён;"
for s in "$SEC_TOKEN" "$SEC_GH"; do "$REALGIT" -C "$Z" grep -qF -e "$s" HEAD 2>/dev/null && why="$why значение секрета в HEAD;"; done
why="$why$(ne_v_vyvode)"
v c19-zhizn-add-f "$(ok_if "$why")" "$why"
# c20 — повтор после `git add -A`/`git add .harness` с коммитом, и снова то же после повтора
zhizn m10; why=""; [ "$RC1" = 0 ] || why="$why первый вход rc=$RC1;"
polzovatel_add "$Z"; rm -f "$ZM/workshop.calls"; run_connect m10 "$Z"
[ "$RC" = 0 ] || why="$why повтор rc=$RC($(sed -n '1p' "$ZM/err"));"
[ "$(calls "$ZM")" = 1 ] || why="$why повтор не дошёл до workshop ровно раз;"
polzovatel_add "$Z"; why="$why$(indeks_chist "$Z")$(ne_v_vyvode)"
v c20-zhizn-add-a "$(ok_if "$why")" "$why"
# c21 — повтор после смены HEAD/ветки (коммит каркаса, затем ветка от коммита ДО подключения)
zhizn m11; why=""; [ "$RC1" = 0 ] || why="$why первый вход rc=$RC1;"
polzovatel_add "$Z"
gitc "$Z" checkout -q -b staraya HEAD~1 >/dev/null 2>&1 || why="$why смена ветки не удалась;"
rm -f "$ZM/workshop.calls"; run_connect m11 "$Z"
[ "$RC" = 0 ] || why="$why повтор rc=$RC($(sed -n '1p' "$ZM/err"));"
[ "$(calls "$ZM")" = 1 ] || why="$why повтор не дошёл до workshop ровно раз;"
polzovatel_add "$Z"; why="$why$(indeks_chist "$Z")$(ne_v_vyvode)"
v c21-zhizn-vetka "$(ok_if "$why")" "$why"
# c22 — секретные значения под ДРУГИМ именем в .harness/: отказ sekret-v-dereve без сессии
# (индекс чист — дверь ничего не индексировала) ЛИБО сессия, а файл вне индекса после git add -A
zhizn m12; why=""; [ "$RC1" = 0 ] || why="$why первый вход rc=$RC1;"
IMYA=".harness/keep-$(rnd | cut -c1-6).txt"; cp "$Z/$ENV_REL" "$Z/$IMYA" 2>/dev/null || why="$why нет $ENV_REL после первого входа;"
rm -f "$ZM/workshop.calls"; run_connect m12 "$Z"
if [ "$RC" = 1 ] && grep -qF 'sekret-v-dereve' "$ZM/err" && [ "$(calls "$ZM")" = 0 ]; then why="$why$(indeks_chist "$Z")"
elif [ "$RC" = 0 ] && [ "$(calls "$ZM")" = 1 ]; then polzovatel_add "$Z"; why="$why$(indeks_chist "$Z")"
else why="$why повтор rc=$RC, workshop $(calls "$ZM") раз — ни отказа sekret-v-dereve без сессии, ни сессии: $(sed -n '1p' "$ZM/err");"; fi
why="$why$(ne_v_vyvode)"
v c22-zhizn-imya "$(ok_if "$why")" "секрет под именем $IMYA:$why"
exit 0
