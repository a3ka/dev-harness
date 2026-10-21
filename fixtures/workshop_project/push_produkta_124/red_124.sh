#!/usr/bin/env bash
# Красная батарея контракта 124 «push-produkta»: дверь станции, которая пушит
# ветку продуктового репозитория и открывает PR (scripts/push_product.sh).
#
#   bash fixtures/workshop_project/push_produkta_124/red_124.sh            # судит живую дверь
#   bash fixtures/workshop_project/push_produkta_124/red_124.sh --model    # судит честную модель
#   RED124_DOOR=<путь> bash …/red_124.sh                                    # судит указанную дверь
#   bash …/red_124.sh --cell <имя>                                          # одна клетка (диагностика)
#
# Сеть запрещена: git/gh — двойники dvoyniki/ первыми в PATH; удалённые
# репозитории — локальные bare мира, PR — таблица мира. Оракул живёт в ПАМЯТИ
# батареи (правило 8): снимки ref'ов всех bare и таблицы PR снимаются ДО вызова
# двери, ожидание после вызова вычисляется из снимка и входа, не из вывода
# двери. Сверка вывода — целой строкой (grep -Fx), причина отказа — префиксом
# строки stderr.
#
# Клетки: Д1 (дверь существует) + т01–т30 (вход → rc, причина, состояние мира)
# судят ДВЕРЬ; С01–С39 судят САМУ батарею: обманный стаб = честная модель
# с одной подменённой строкой (метка `# @L:<имя>`); стаб привязан к той
# т-клетке, где его ложь наблюдаема (Н-39: привязка — ТОЛЬКО здесь, в KARTA),
# и С-клетка зелёная, когда эта т-клетка на стабе КРАСНАЯ, а на модели — зелёная.
# Окружение двери не несёт ни одной переменной P124_* (двойники находят мир по
# пути вызова, ручки мира — файлы <мир>/knob/*): обманка, распознающая мир
# батареи по маркеру окружения, лжёт в каждой клетке (т27 — чистый env -i).
#
# rc 0 — все клетки зелёные; rc 1 — есть красная; rc 2 — среда батареи
# неполна (NEEDS_ENV: нет git/jq/python3/bash в системе).
set -uo pipefail
export LC_ALL=C PYTHONDONTWRITEBYTECODE=1
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(cd "$HERE/../../.." && pwd -P)"
MODEL="$HERE/model/push_product.sh"
DOOR="${RED124_DOOR:-$ROOT/scripts/push_product.sh}"
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --model) DOOR="$MODEL"; shift ;;
    --cell) ONLY="${2:?--cell без имени}"; shift 2 ;;
    *) printf 'red_124: неизвестный аргумент: %s\n' "$1" >&2; exit 2 ;;
  esac
done
for t in git jq python3 bash; do
  command -v "$t" >/dev/null 2>&1 || { printf 'red_124 NEEDS_ENV: нет %s\n' "$t" >&2; exit 2; }
done
REAL_GIT="$(type -P git)"
TOKEN="$(cat "$HERE/dvoyniki/kanarejka.txt")"
[ -n "$TOKEN" ] || { printf 'red_124 NEEDS_ENV: пустая канарейка\n' >&2; exit 2; }
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/red124-XXXXXX")" || exit 2
trap 'rm -rf "$SCRATCH"' EXIT

# ── Единые литералы (контракт 124 §Предмет; батарея — их носитель) ─────────
P_OK='push_product ОК: '
R_ARG='push_product ОТКАЗ: аргумент вне грамматики: '
R_NOARG='push_product ОТКАЗ: нет аргумента: '
R_VETKA='push_product ОТКАЗ: ветка вне грамматики: '
R_ZASHCH='push_product ОТКАЗ: ветка защищена: '
R_SHA='push_product ОТКАЗ: sha вне грамматики: '
R_ZAG='push_product ОТКАЗ: заголовок вне грамматики: '
R_NET_GH='push_product NEEDS_ENV: нет gh'
R_AUTH='push_product NEEDS_ENV: gh не авторизован'
R_PROFIL='push_product ОТКАЗ: профиль проекта отсутствует: '
R_KANON='push_product ОТКАЗ: канон вне грамматики двери: '
R_HARN='push_product ОТКАЗ: репозиторий харнесса — не продукт: '
R_HEAD='push_product ОТКАЗ: HEAD клона ≠ --sha: '
R_PUSH='push_product ОТКАЗ: push отказан: '

OWNER=a3ka
MOB="Complior-mob"; BACK="Complior-back"; HARN="dev-harness"
BRANCH="cmp-mob-124/rabota"
TITLE="cmp-mob-124: работа"
MOB_URL="https://github.com/$OWNER/$MOB.git"

# ── Мир ─────────────────────────────────────────────────────────────────────
# remotes/a3ka/{Complior-mob,Complior-back,dev-harness}.git (bare, main = M0;
# в mob ещё ветка other и тег v0), клон mob в clone/ (origin клона намеренно
# указывает на Complior-back по https — ловушка «URL не из профиля»), профиль
# клона — канон Complior-mob; таблица PR: #5 (closed, head = BRANCH),
# #7 (open, head = other). HEAD клона = C2, родитель C1.
W="" SHA="" C1="" D=""
g() { "$REAL_GIT" "$@"; }
gc() { "$REAL_GIT" -c user.name=red124 -c user.email=red124@dev-harness.local -c commit.gpgsign=false "$@"; }
write_profile() {  # $1 клон, $2 канон (литерал JSON-строки без кавычек)
  mkdir -p "$1/.harness/contracts" "$1/.harness/verdicts" "$1/.harness/registry" "$1/.harness/fixtures" "$1/.github/workflows"
  : > "$1/.github/workflows/mobile.yml"
  printf '%s\n' '{ "schemaVersion": 1, "version": "1", "projectId": "Complior-mob", "workspaceId": "Complior-mob" }' > "$1/.harness/project-layer.json"
  cat > "$1/harness.project.json" <<JSON
{
  "schemaVersion": 1,
  "repoId": "Complior-mob",
  "language": "typescript",
  "projectLayer": { "version": "1", "profilePath": ".harness/project-layer.json" },
  "workflowPaths": { "contracts": ".harness/contracts", "verdicts": ".harness/verdicts", "registry": ".harness/registry", "fixtures": ".harness/fixtures", "state": ".harness" },
  "commands": { "test": "true", "build": "true", "typecheck": "true", "lint": "true" },
  "git": { "canonicalRemote": "$2" },
  "ci": { "workflow": ".github/workflows/mobile.yml" }
}
JSON
}
make_world() {  # $1 = канон профиля клона (умолчание — Complior-mob https)
  local kanon="${1:-$MOB_URL}" r
  W="$(mktemp -d "$SCRATCH/w-XXXXXX")" || return 9
  mkdir -p "$W/bin" "$W/home" "$W/tmp" "$W/log" "$W/gh" "$W/knob" "$W/remotes/$OWNER"
  printf '%s\n' "$REAL_GIT" > "$W/real_git"
  : > "$W/home/.gitconfig"
  ln -s "$HERE/dvoyniki/git" "$W/bin/git"
  ln -s "$HERE/dvoyniki/gh" "$W/bin/gh"
  for r in "$MOB" "$BACK" "$HARN"; do g init -q --bare -b main "$W/remotes/$OWNER/$r.git"; done
  g init -q -b main "$W/seed"
  printf 'база\n' > "$W/seed/README.md"
  g -C "$W/seed" add README.md && gc -C "$W/seed" commit -q -m 'M0 база'
  for r in "$MOB" "$BACK" "$HARN"; do g -C "$W/seed" push -q "$W/remotes/$OWNER/$r.git" main; done
  g -C "$W/seed" checkout -q -b other && printf 'чужое\n' > "$W/seed/other.txt"
  g -C "$W/seed" add other.txt && gc -C "$W/seed" commit -q -m 'O0 чужая ветка'
  g -C "$W/seed" push -q "$W/remotes/$OWNER/$MOB.git" other
  g -C "$W/seed" tag v0 main && g -C "$W/seed" push -q "$W/remotes/$OWNER/$MOB.git" v0
  g clone -q "$W/remotes/$OWNER/$MOB.git" "$W/clone"
  g -C "$W/clone" remote set-url origin "https://github.com/$OWNER/$BACK.git"
  g -C "$W/clone" config user.name red124
  g -C "$W/clone" config user.email red124@dev-harness.local
  write_profile "$W/clone" "$kanon"
  g -C "$W/clone" add -A && gc -C "$W/clone" commit -q -m 'C1 профиль'
  C1="$(g -C "$W/clone" rev-parse HEAD)"
  printf 'работа\n' > "$W/clone/rabota.txt"
  g -C "$W/clone" add rabota.txt && gc -C "$W/clone" commit -q -m 'C2 работа'
  SHA="$(g -C "$W/clone" rev-parse HEAD)"
  printf '%s\t5\t%s\tmain\tclosed\tстарый PR той же ветки\n' "$OWNER/$MOB" "$BRANCH" > "$W/gh/prs.tsv"
  printf '%s\t7\tother\tmain\topen\tчужой PR\n' "$OWNER/$MOB" >> "$W/gh/prs.tsv"
}
recommit_head() { gc -C "$W/clone" commit -q -am "$1" && SHA="$(g -C "$W/clone" rev-parse HEAD)"; }

FARM=""
farm_bez_gh() {  # системный PATH без gh (симлинк-ферма /usr/bin), один раз на прогон
  [ -n "$FARM" ] && return 0
  FARM="$SCRATCH/farm"
  mkdir -p "$FARM"
  cp -rs /usr/bin/. "$FARM/" 2>/dev/null
  rm -f "$FARM/gh"
}

refs_snap() {  # стабильный снимок ref'ов всех bare мира
  local d
  for d in "$W"/remotes/*/*.git; do
    g --git-dir="$d" for-each-ref --format="$(basename "$d")	%(refname)	%(objectname)"
  done | sort
}
prs_snap() { sort "$W/gh/prs.tsv"; }
expect_refs_plus() {  # $1 снимок до, $2 bare-имя, $3 ref, $4 sha → ожидаемый снимок
  printf '%s\n' "$1" | awk -F'\t' -v B="$2.git" -v R="$3" '!($1==B && $2==R)'
  printf '%s.git\t%s\t%s\n' "$2" "$3" "$4"
}

OUT="" ERR="" RC=0
run_door() {  # [PATH_BEZ_GH=1] -- аргументы двери (ручки мира — файлы <мир>/knob/*)
  local path="$W/bin:/usr/local/bin:/usr/bin:/bin"
  while [ $# -gt 0 ] && [ "$1" != "--" ]; do
    case "$1" in
      PATH_BEZ_GH=1) farm_bez_gh; rm -f "$W/bin/gh"; path="$W/bin:$FARM" ;;
      *) printf 'red_124: run_door: неизвестная ручка %s\n' "$1" >&2; exit 2 ;;
    esac
    shift
  done
  shift
  env -i PATH="$path" HOME="$W/home" TMPDIR="$W/tmp" LANG=C.UTF-8 \
    GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$W/home/.gitconfig" \
    bash "$CUR_DOOR" "$@" >"$W/out" 2>"$W/err"
  RC=$?
  OUT="$(cat "$W/out")"; ERR="$(cat "$W/err")"
}

# ── Суд клетки ──────────────────────────────────────────────────────────────
FAIL=""
bad() { [ -n "$FAIL" ] || FAIL="$1"; }
want_rc() { [ "$RC" = "$1" ] || bad "rc $RC, ожидался $1 (stderr: $(printf '%s' "$ERR" | tr '\n' '|' | cut -c1-240))"; }
want_reason() {  # строка stderr, НАЧИНАЮЩАЯСЯ префиксом причины
  printf '%s\n' "$ERR" | awk -v P="$1" 'index($0,P)==1{f=1} END{exit f?0:1}' || bad "нет причины «$1»"
  printf '%s\n' "$OUT" | awk -v P="$P_OK" 'index($0,P)==1{f=1} END{exit f?1:0}' || bad "ОК-строка при отказе"
}
want_ok_line() {  # stdout — ровно одна строка, равная ожиданию
  [ "$OUT" = "$1" ] || bad "stdout ≠ «$1»: «$(printf '%s' "$OUT" | tr '\n' '|' | cut -c1-240)»"
}
want_refs() { [ "$(refs_snap)" = "$(printf '%s\n' "$1" | sed '/^$/d' | sort)" ] || bad "ref'ы удалённых репозиториев ≠ ожиданию: $(diff <(printf '%s\n' "$1" | sed '/^$/d' | sort) <(refs_snap) | tr '\n' '|' | cut -c1-300)"; }
want_prs() { [ "$(prs_snap)" = "$(printf '%s\n' "$1" | sed '/^$/d' | sort)" ] || bad "таблица PR ≠ ожиданию: $(diff <(printf '%s\n' "$1" | sed '/^$/d' | sort) <(prs_snap) | tr '\n' '|' | cut -c1-300)"; }
no_token() {  # токен gh не виден нигде: вывод, argv/окружение вызовов, клон, дом
  if printf '%s\n%s\n' "$OUT" "$ERR" | grep -Fq -- "$TOKEN" \
     || grep -rFq -- "$TOKEN" "$W/log" "$W/clone" "$W/home" 2>/dev/null; then
    bad "токен gh утёк (вывод/argv/окружение/клон)"
  fi
}

# Каждая т-клетка: мир → снимок → вызов → суд. Тело задаёт ожидание.
t01() { make_world; local r0 p0; r0="$(refs_snap)"; p0="$(prs_snap)"
  run_door -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
  want_rc 0; want_ok_line "${P_OK}$OWNER/$MOB $BRANCH $SHA PR https://github.com/$OWNER/$MOB/pull/8 создан"
  want_refs "$(expect_refs_plus "$r0" "$MOB" "refs/heads/$BRANCH" "$SHA")"
  want_prs "$p0
$(printf '%s\t8\t%s\tmain\topen\t%s' "$OWNER/$MOB" "$BRANCH" "$TITLE")"; no_token; }
t02() { make_world
  run_door -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
  [ "$RC" = 0 ] || { bad "первый вызов rc $RC — повтор не судим"; return; }
  local r1 p1; r1="$(refs_snap)"; p1="$(prs_snap)"
  run_door -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
  want_rc 0; want_ok_line "${P_OK}$OWNER/$MOB $BRANCH $SHA PR https://github.com/$OWNER/$MOB/pull/8 существует"
  want_refs "$r1"; want_prs "$p1"; no_token; }
t03() { make_world; g -C "$W/clone" push -q "$W/remotes/$OWNER/$MOB.git" "$C1:refs/heads/$BRANCH"
  local r0 p0; r0="$(refs_snap)"; p0="$(prs_snap)"
  run_door -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
  want_rc 0; want_ok_line "${P_OK}$OWNER/$MOB $BRANCH $SHA PR https://github.com/$OWNER/$MOB/pull/8 создан"
  want_refs "$(expect_refs_plus "$r0" "$MOB" "refs/heads/$BRANCH" "$SHA")"
  want_prs "$p0
$(printf '%s\t8\t%s\tmain\topen\t%s' "$OWNER/$MOB" "$BRANCH" "$TITLE")"; no_token; }
t04() { make_world
  g -C "$W/seed" checkout -q main && printf 'чужая правка\n' > "$W/seed/d.txt"
  g -C "$W/seed" add d.txt && gc -C "$W/seed" commit -q -m 'D расхождение'
  g -C "$W/seed" push -q "$W/remotes/$OWNER/$MOB.git" "HEAD:refs/heads/$BRANCH"
  refusal_case "$R_PUSH" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
refusal_case() {  # $1 причина, затем доп.окружение -- аргументы; мир уже построен
  local reason="$1" rc_want=1 r0 p0; shift
  case "$reason" in *NEEDS_ENV*) rc_want=2 ;; esac
  r0="$(refs_snap)"; p0="$(prs_snap)"
  run_door "$@"
  want_rc "$rc_want"; want_reason "$reason"; want_refs "$r0"; want_prs "$p0"; no_token
}
t05() { make_world; refusal_case "$R_ZASHCH" -- --repo "$W/clone" --branch main --sha "$SHA" --title "$TITLE"; }
t06() { make_world; refusal_case "$R_ZASHCH" -- --repo "$W/clone" --branch master --sha "$SHA" --title "$TITLE"; }
t07() { make_world; refusal_case "$R_VETKA" -- --repo "$W/clone" --branch "+$BRANCH" --sha "$SHA" --title "$TITLE"; }
t08() { make_world; refusal_case "$R_VETKA" -- --repo "$W/clone" --branch ":$BRANCH" --sha "$SHA" --title "$TITLE"; }
t09() { make_world; refusal_case "$R_VETKA" -- --repo "$W/clone" --branch "$BRANCH:main" --sha "$SHA" --title "$TITLE"; }
t10() { make_world; refusal_case "$R_VETKA" -- --repo "$W/clone" --branch "refs/heads/main" --sha "$SHA" --title "$TITLE"; }
t11() { make_world; refusal_case "$R_ARG" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE" --force; }
t12() { make_world; refusal_case "$R_HEAD" -- --repo "$W/clone" --branch "$BRANCH" --sha "$C1" --title "$TITLE"; }
t13() { make_world; refusal_case "$R_SHA" -- --repo "$W/clone" --branch "$BRANCH" --sha "${SHA:0:12}" --title "$TITLE"; }
t14() { make_world; : > "$W/knob/drejf_head"; local r0 p0; r0="$(refs_snap)"; p0="$(prs_snap)"
  run_door -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
  want_rc 0; want_ok_line "${P_OK}$OWNER/$MOB $BRANCH $SHA PR https://github.com/$OWNER/$MOB/pull/8 создан"
  want_refs "$(expect_refs_plus "$r0" "$MOB" "refs/heads/$BRANCH" "$SHA")"
  [ "$(g -C "$W/clone" rev-parse HEAD)" != "$SHA" ] || bad "двойник не сдвинул HEAD (дрейф не предъявлен)"
  no_token; }
t15() { make_world; refusal_case "$R_NET_GH" PATH_BEZ_GH=1 -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
t16() { make_world; : > "$W/knob/gh_bez_vhoda"; refusal_case "$R_AUTH" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
t17() { make_world; g -C "$W/clone" rm -q harness.project.json && recommit_head 'профиль убран'
  refusal_case "$R_PROFIL" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
t18() { make_world "ssh://git@github.com/$OWNER/$MOB.git"
  refusal_case "$R_KANON" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
t19() { make_world "https://gitlab.com/$OWNER/$MOB.git"
  refusal_case "$R_KANON" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
t20() { make_world "https://github.com/$OWNER/$HARN.git"
  refusal_case "$R_HARN" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
t21() { make_world "https://github.com/A3KA/Dev-Harness.git"
  refusal_case "$R_HARN" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"; }
t22() { make_world
  refusal_case "$R_ZAG" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "работа
push_product ОК: подделка"
  printf '%s\n%s\n' "$OUT" "$ERR" | grep -Fxq 'push_product ОК: подделка' && bad "подложная строка ОК в выводе"; }
t23() { make_world; refusal_case "$R_NOARG" -- --repo "$W/clone" --branch "$BRANCH" --title "$TITLE"; }
honest_case() {  # $1 ветка; мир построен → rc 0, ОК «создан» #8; ВЕСЬ снимок ref'ов = до + ровно refs/heads/$1 = SHA
  local b="$1" r0 p0; r0="$(refs_snap)"; p0="$(prs_snap)"
  run_door -- --repo "$W/clone" --branch "$b" --sha "$SHA" --title "$TITLE"
  want_rc 0; want_ok_line "${P_OK}$OWNER/$MOB $b $SHA PR https://github.com/$OWNER/$MOB/pull/8 создан"
  want_refs "$(expect_refs_plus "$r0" "$MOB" "refs/heads/$b" "$SHA")"
  want_prs "$p0
$(printf '%s\t8\t%s\tmain\topen\t%s' "$OWNER/$MOB" "$b" "$TITLE")"; no_token; }
# т24: в клоне НЕОПУБЛИКОВАННЫЕ локальные ref'ы — лёгкий тег, аннотированный тег
# (оба на SHA) и вторая локальная ветка (на C1); ни один не должен уйти в bare.
t24() { make_world
  g -C "$W/clone" tag release-local "$SHA"
  gc -C "$W/clone" tag -a -m 'кандидат' v1-rc "$SHA"
  g -C "$W/clone" branch lokalnaya-vetka "$C1"
  honest_case "$BRANCH"; }
# т25: допустимая ветка с подстроками main и master (и префиксом main) — не защищена.
t25() { make_world; honest_case "maintenance/remaster-1"; }
# т26: канон харнесса в https-форме и с другим слагом. Дверь копируется вместе со
# scripts/ харнесса в синтетический корень (корень двери — каталог над её scripts/,
# контракт г5); канон клона = слаг этого корня → отказ г5, без пуша.
t26() { local hk="https://github.com/$OWNER/$HARN-zerkalo.git" hr saved="$CUR_DOOR"
  make_world "$hk"; hr="$W/hroot"
  mkdir -p "$hr" && cp -R "$ROOT/scripts" "$hr/" && g init -q -b main "$hr" && write_profile "$hr" "$hk" \
    && install_door "$CUR_DOOR" "$hr/scripts/push_product.sh" "$hr" || { bad "синтетический корень харнесса не собран"; return; }
  CUR_DOOR="$hr/scripts/push_product.sh"
  refusal_case "$R_HARN" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
  CUR_DOOR="$saved"; }
# т27: мир без маркеров — дверь в чистом env -i (только PATH, HOME и
# GIT_CONFIG_NOSYSTEM; ни TMPDIR, ни одной переменной P124_*): rc 0 только при
# реальном push проверенного sha в bare канона и PR. Обманка, ветвящаяся по
# маркеру мира (вердикт адверсария 124 impl v1), здесь печатает ложное ОК без push.
t27() { make_world; local r0 p0; r0="$(refs_snap)"; p0="$(prs_snap)"
  env -i PATH="$W/bin:/usr/local/bin:/usr/bin:/bin" HOME="$W/home" GIT_CONFIG_NOSYSTEM=1 \
    bash "$CUR_DOOR" --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE" >"$W/out" 2>"$W/err"
  RC=$?; OUT="$(cat "$W/out")"; ERR="$(cat "$W/err")"
  want_rc 0; want_ok_line "${P_OK}$OWNER/$MOB $BRANCH $SHA PR https://github.com/$OWNER/$MOB/pull/8 создан"
  want_refs "$(expect_refs_plus "$r0" "$MOB" "refs/heads/$BRANCH" "$SHA")"
  want_prs "$p0
$(printf '%s\t8\t%s\tmain\topen\t%s' "$OWNER/$MOB" "$BRANCH" "$TITLE")"; no_token; }
# т28: хвост «.» у сегмента в СЕРЕДИНЕ имени ветки (R124-1) — вне грамматики г2.
t28() { make_world; refusal_case "$R_VETKA" -- --repo "$W/clone" --branch "foo./bar" --sha "$SHA" --title "$TITLE"; }
# т29: перенаправление url.* в конфиге клона уводит push по URL канона мимо
# канона (R124-2): insteadOf → bare харнесса (обход г5), pushInsteadOf → bare
# back, insteadOf с ПРЕФИКСОМ канона (значение ≠ канону) → bare харнесса.
# Каждый вход — свой мир и свой суд (метка входа в причине красного); отказ
# «push отказан» до push, ни один ref ни одного bare не изменён.
t29() { local v m k b u
  for v in "insteadOf|insteadOf|$HARN.git|$MOB_URL" "pushInsteadOf|pushInsteadOf|$BACK.git|$MOB_URL" \
           "insteadOf-префикс|insteadOf|$HARN|https://github.com/$OWNER/$MOB"; do
    IFS='|' read -r m k b u <<<"$v"; make_world
    g -C "$W/clone" config "url.$W/remotes/$OWNER/$b.$k" "$u"
    refusal_case "$R_PUSH" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
    [ -z "$FAIL" ] || { FAIL="[url.*.$m] $FAIL"; return; }
  done; }
# т30: remote.<канон-URL>.url|pushurl в конфиге клона — push по URL-литералу
# канона уходит в чужой bare (url → харнесс, pushurl → back): отказ «push
# отказан» до push. Негативная пара — remote.origin.url клона (ловушка мира)
# отказа не вызывает: т01, стаб С38.
t30() { local v k t
  for v in url:"$HARN" pushurl:"$BACK"; do
    k="${v%%:*}"; t="${v#*:}"; make_world
    g -C "$W/clone" config "remote.$MOB_URL.$k" "$W/remotes/$OWNER/$t.git"
    refusal_case "$R_PUSH" -- --repo "$W/clone" --branch "$BRANCH" --sha "$SHA" --title "$TITLE"
    [ -z "$FAIL" ] || { FAIL="[remote.<канон>.$k] $FAIL"; return; }
  done; }

T_CELLS="t01 t02 t03 t04 t05 t06 t07 t08 t09 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26 t27 t28 t29 t30"
declare -A T_NAME=(
  [t01]="честный вызов: ветка = sha, PR создан, остальное не тронуто"
  [t02]="повтор: тот же PR «существует», дубля нет"
  [t03]="перемотка: ветка на предке sha — fast-forward"
  [t04]="расхождение: ветка не предок sha — отказ без force"
  [t05]="ветка main — защищена"
  [t06]="ветка master — защищена"
  [t07]="ветка «+…» — вне грамматики"
  [t08]="ветка «:…» (удаление) — вне грамматики"
  [t09]="ветка «…:main» — вне грамматики"
  [t10]="ветка refs/heads/main — вне грамматики"
  [t11]="флаг --force — вне грамматики"
  [t12]="--sha ≠ HEAD клона — отказ"
  [t13]="короткий sha — вне грамматики"
  [t14]="дрейф HEAD во время push — запушен проверенный sha"
  [t15]="нет gh — NEEDS_ENV, без пуша"
  [t16]="gh без входа — NEEDS_ENV, без пуша"
  [t17]="нет профиля проекта — отказ, без пуша"
  [t18]="канон ssh — вне грамматики двери"
  [t19]="канон чужого хоста — вне грамматики двери"
  [t20]="канон = харнесс — отказ"
  [t21]="канон = харнесс в другом регистре — отказ"
  [t22]="заголовок с переводом строки — отказ без подлога"
  [t23]="нет --sha — отказ"
  [t24]="неопубликованные локальные теги и ветка: публикуется ровно запрошенная ветка"
  [t25]="ветка с подстрокой main/master — допустима, пушится"
  [t26]="канон харнесса https с иным слагом (корень двери): продукт = харнесс — отказ"
  [t27]="мир без маркеров: дверь в чистом env -i (без P124_*) — ОК только при реальном push"
  [t28]="ветка «foo./bar» (хвост «.» у сегмента в середине) — вне грамматики"
  [t29]="url.*.insteadOf / pushInsteadOf / insteadOf-префикс клона уводит push мимо канона — отказ до push"
  [t30]="remote.<канон>.url / pushurl клона уводит push мимо канона — отказ до push"
)

# ── KARTA стабов: имя → метка подменяемой строки модели → т-клетка, где ложь
# наблюдаема (Н-39: привязка — только здесь, по коду) → строка-подмена.
PUSHCMD='git -C "$REPO_ABS" -c credential.helper= -c '"'"'credential.helper=!gh auth git-credential'"'"' push --quiet'
declare -a KARTA=(
  "s01_push_v_main|push|t01|if ! perr=\"\$($PUSHCMD \"\$CANON\" \"\$SHA:refs/heads/main\" 2>&1 >/dev/null)\"; then"
  "s02_force|push|t04|if ! perr=\"\$($PUSHCMD --force \"\$CANON\" \"\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s03_plyus_refspec|push|t04|if ! perr=\"\$($PUSHCMD \"\$CANON\" \"+\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s04_udalenie_i_push|push|t04|$PUSHCMD \"\$CANON\" \":refs/heads/\$BRANCH\" >/dev/null 2>&1; if ! perr=\"\$($PUSHCMD \"\$CANON\" \"\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s05_url_iz_origin|kanon|t01|CANON_JSON=\"\$(git -C \"\$REPO_ABS\" config --get remote.origin.url | jq -R -c .)\""
  "s06_token_v_url|push|t01|if ! perr=\"\$(git -C \"\$REPO_ABS\" push --quiet \"https://x-access-token:\$(gh auth token)@github.com/\$SLUG.git\" \"\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s07_token_v_vyvod|ok|t01|printf '%s ОК: %s %s %s PR %s %s\\n' \"\$ME\" \"\$SLUG\" \"\$BRANCH\" \"\$SHA\" \"\$URL\" \"\$HOW\"; printf 'отладка: токен %s\\n' \"\$(gh auth token)\" >&2"
  "s08_dubl_pr|pr_list|t02|EXIST=\"\""
  "s09_bez_proverki_head|head|t12|:"
  "s10_push_head|push|t14|if ! perr=\"\$($PUSHCMD \"\$CANON\" \"HEAD:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s11_tikhij_propusk_bez_gh|net_gh|t15|command -v gh >/dev/null 2>&1 || { printf '%s ОК: пропуск — нет gh\\n' \"\$ME\"; exit 0; }"
  "s12_rc0_bez_pusha|push|t01|printf '%s ОК: %s %s %s PR %s %s\\n' \"\$ME\" \"\$SLUG\" \"\$BRANCH\" \"\$SHA\" \"https://github.com/\$SLUG/pull/8\" \"создан\"; exit 0; if false; then"
  "s13_bez_kharnessa|harness|t20|:"
  "s14_kharness_registr|harness|t21|[ \"\$SLUG\" != \"\$HSLUG\" ] || die1 \"репозиторий харнесса — не продукт: \$SLUG (обмены харнесса — scripts/gitw)\""
  "s15_fallback_bez_profilja|profil|t17|CANON_JSON=\"\$(git -C \"\$REPO_ABS\" config --get remote.origin.url | jq -R -c .)\""
  "s16_kanon_bez_grammatiki|kanon_gram|t18|[[ \"\$CANON_JSON\" =~ ^\\\"[a-z]+://[^\\\"]+/([A-Za-z0-9-]+)/([A-Za-z0-9._-]+)\\.git\\\"\$ ]] || die1 \"канон вне грамматики двери: \$(san \"\$CANON_JSON\")\""
  "s17_bez_zashchity|zashchita|t05|:"
  "s18_vetka_bez_grammatiki|vetka|t07|[ -n \"\$BRANCH\" ] || die1 \"ветка вне грамматики: пусто\""
  "s19_bez_vhoda_gh|auth|t16|:"
  "s20_pr_lyuboj|pr_list|t01|EXIST=\"\$(gh pr list --repo \"\$SLUG\" --state all --json url --jq '.[0].url // empty' 2>/dev/null)\" || die1 \"PR не создан: gh pr list отказал\""
  "s21_bez_proverki_zagolovka|zagolovok|t22|:"
  "s22_flag_ignor|flag|t11|*) shift ;;"
  "s23_push_tags|push|t24|if ! perr=\"\$($PUSHCMD --tags \"\$CANON\" \"\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s24_push_follow_tags|push|t24|if ! perr=\"\$($PUSHCMD --follow-tags \"\$CANON\" \"\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s25_push_vse_vetki|push|t24|if ! perr=\"\$($PUSHCMD \"\$CANON\" \"\$SHA:refs/heads/\$BRANCH\" 'refs/heads/*:refs/heads/*' 2>&1 >/dev/null)\"; then"
  "s26_push_all_vtorym|push|t24|$PUSHCMD --all \"\$CANON\" >/dev/null 2>&1; if ! perr=\"\$($PUSHCMD \"\$CANON\" \"\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s27_push_mirror_vtorym|push|t24|$PUSHCMD --mirror \"\$CANON\" >/dev/null 2>&1; if ! perr=\"\$($PUSHCMD \"\$CANON\" \"\$SHA:refs/heads/\$BRANCH\" 2>&1 >/dev/null)\"; then"
  "s28_zashchita_podstrokoj|zashchita|t25|case \"\$BRANCH\" in *main*|*master*|HEAD) die1 \"ветка защищена: \$BRANCH\" ;; esac"
  "s29_hkanon_tolko_ssh|hkanon|t26|[[ \"\$HCANON_JSON\" =~ ^\\\"(ssh://git@github\\.com/)([A-Za-z0-9-]+)/([A-Za-z0-9._-]+)\\.git\\\"\$ ]] || die2 \"канон харнесса вне грамматики: \$(san \"\$HCANON_JSON\")\""
  "s30_harness_konstanta|harness|t26|[ \"\${SLUG,,}\" != \"a3ka/dev-harness\" ] || die1 \"репозиторий харнесса — не продукт: \$SLUG (обмены харнесса — scripts/gitw)\""
  "s31_mir_po_P124_WORLD|mir|t27|ME=\"push_product\"; if [ -z \"\${P124_WORLD:-}\" ]; then printf '%s ОК: a3ka/Complior-mob bypass 0000000000000000000000000000000000000000 PR https://github.com/a3ka/Complior-mob/pull/999 создан\\n' \"\$ME\"; exit 0; fi"
  "s32_mir_po_ljubomu_P124|mir|t27|ME=\"push_product\"; if [ -z \"\$(compgen -e | grep '^P124_')\" ]; then printf '%s ОК: a3ka/Complior-mob bypass 0000000000000000000000000000000000000000 PR https://github.com/a3ka/Complior-mob/pull/999 создан\\n' \"\$ME\"; exit 0; fi"
  "s33_tochka_v_seredine|vetka_hvost|t28|case \"\$BRANCH\" in refs/*|*..*|*.|*.lock|*.lock/*) die1 \"ветка вне грамматики: \$(san \"\$BRANCH\")\" ;; esac"
  "s34_url_tolko_insteadof|url_rewrite|t29|UREW=\"\$(git -C \"\$REPO_ABS\" config --name-only --get-regexp '^url\\..*\\.insteadof\$' 2>/dev/null)\""
  "s35_url_tolko_pushinsteadof|url_rewrite|t29|UREW=\"\$(git -C \"\$REPO_ABS\" config --name-only --get-regexp '^url\\..*\\.pushinsteadof\$' 2>/dev/null)\""
  "s36_remote_kanon_tolko_url|remote_url|t30|for k in url; do git -C \"\$REPO_ABS\" config --get-all \"remote.\$CANON.\$k\" >/dev/null 2>&1 && die1 \"push отказан: remote.\$CANON.\$k в конфиге клона\"; done"
  "s37_remote_kanon_tolko_pushurl|remote_url|t30|for k in pushurl; do git -C \"\$REPO_ABS\" config --get-all \"remote.\$CANON.\$k\" >/dev/null 2>&1 && die1 \"push отказан: remote.\$CANON.\$k в конфиге клона\"; done"
  "s38_remote_ljuboj_i_origin|remote_url|t01|git -C \"\$REPO_ABS\" config --get-regexp '^remote\\..*\\.(url|pushurl)\$' >/dev/null 2>&1 && die1 \"push отказан: remote.*.url|pushurl в конфиге клона\""
  "s39_url_tolko_znachenie_kanon|url_rewrite|t29|UREW=\"\$(git -C \"\$REPO_ABS\" config --get-regexp '^url\\.' 2>/dev/null | awk -v C=\"\$CANON\" '\$2==C{print \$1}')\""
)

# Корень модели вне дерева закрепляется заменой строки `# @L:root` (без
# переменных окружения): стабы — корнем харнесса, копия двери в т26 — корнем копии.
build_stub() {  # $1 метка, $2 строка-подмена → путь стаба (или пусто при сбое сборки)
  local dst="$SCRATCH/stub-$1-$RANDOM.sh"
  python3 - "$MODEL" "$dst" "$1" "$2" "$ROOT" <<'PY' || return 1
import shlex, sys
src, dst, tag, rep, root = sys.argv[1:6]
lines = open(src, encoding='utf-8').read().split('\n')
def one(mark):
    hits = [i for i, l in enumerate(lines) if l.endswith(mark)]
    if len(hits) != 1:
        sys.exit(1)
    return hits[0]
i = one('# @L:' + tag)
if lines[i] == rep:
    sys.exit(1)
lines[i] = rep
if tag != 'root':
    lines[one('# @L:root')] = 'ROOT=' + shlex.quote(root) + ' # @L:root'
open(dst, 'w', encoding='utf-8').write('\n'.join(lines))
PY
  cmp -s "$MODEL" "$dst" && return 1
  printf '%s' "$dst"
}
install_door() {  # $1 дверь, $2 куда, $3 корень копии: строка `# @L:root` (модель, стаб) → корень $3
  python3 - "$1" "$2" "$3" <<'PY'
import shlex, sys
src, dst, root = sys.argv[1:4]
lines = open(src, 'rb').read().split(b'\n')
hits = [i for i, l in enumerate(lines) if l.endswith(b'# @L:root')]
if len(hits) > 1:
    sys.exit(1)
for i in hits:
    lines[i] = ('ROOT=' + shlex.quote(root) + ' # @L:root').encode('utf-8')
open(dst, 'wb').write(b'\n'.join(lines))
PY
}

# ── Прогон ──────────────────────────────────────────────────────────────────
TOTAL=0 GREEN=0 RED=0
row() {  # $1 клетка, $2 описание, $3 вердикт-пусто=зелёная
  TOTAL=$((TOTAL+1))
  if [ -z "$3" ]; then GREEN=$((GREEN+1)); printf 'КЛЕТКА %s: ЗЕЛЁНАЯ — %s\n' "$1" "$2"
  else RED=$((RED+1)); printf 'КЛЕТКА %s: КРАСНАЯ — %s: %s\n' "$1" "$2" "$3"; fi
}
judge_t() {  # $1 т-клетка, $2 дверь → FAIL (пусто = зелёная)
  CUR_DOOR="$2"; FAIL=""
  if [ ! -f "$CUR_DOOR" ]; then FAIL="предмет отсутствует: $CUR_DOOR"; return; fi
  "$1"
}

want() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }
if want Д1; then
  if [ -f "$DOOR" ] && [ -x "$DOOR" ]; then row Д1 "дверь существует и исполняема" ""
  else row Д1 "дверь существует и исполняема" "предмет отсутствует: $DOOR"; fi
fi
for t in $T_CELLS; do
  want "$t" || continue
  judge_t "$t" "$DOOR"; row "$t" "${T_NAME[$t]}" "$FAIL"
done
k=0
for e in "${KARTA[@]}"; do
  k=$((k+1)); cid="$(printf 'С%02d' "$k")"
  IFS='|' read -r sname tag cell rep <<<"$e"
  want "$cid" || continue
  judge_t "$cell" "$MODEL"
  if [ -n "$FAIL" ]; then row "$cid" "$sname → $cell" "эталон красен на $cell: $FAIL"; continue; fi
  stub="$(build_stub "$tag" "$rep")" || { row "$cid" "$sname → $cell" "стаб не собран (метка @L:$tag)"; continue; }
  judge_t "$cell" "$stub"
  if [ -n "$FAIL" ]; then row "$cid" "$sname → $cell ПОЙМАН ($FAIL)" ""
  else row "$cid" "$sname → $cell" "НЕ ПОЙМАН: ложь не наблюдаема"; fi
done
printf 'red_124: клеток %s, зелёных %s, красных %s (дверь: %s)\n' "$TOTAL" "$GREEN" "$RED" "$DOOR"
[ "$TOTAL" -gt 0 ] || { printf 'red_124: пустая выборка клеток\n' >&2; exit 1; }
[ "$RED" -eq 0 ]
