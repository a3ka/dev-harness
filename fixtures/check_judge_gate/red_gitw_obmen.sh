#!/usr/bin/env bash
# КРАСНОЕ 045 (scripts/gitw — pre-exchange гард цели git-обмена, единый корень
# Н-141+Н-143+Н-148 + probe C): обёртки ещё не существует — честная часть батареи
# красна ЕДИНСТВЕННОЙ причиной «предмет отсутствует» (fail-fast, г0), а стаб-пак
# (исполняется ДО честных клеток) зелён И ДО реализации: девять обманных стабов
# умирают каждый на СВОЕЙ клетке именованно — различимость батареи не зависит от
# существования честного кода.
#
# ПРИВЯЗКА К КОДУ (Н-39: стаб умирает там, где его дефект НАБЛЮДАЕМ):
#   * ПУШ-ТОЛЬКО   — судит только push, fetch/pull насквозь      → умирает г2
#                    (Н-148: подмена поймана именно на fetch);
#   * ПОДСТРОКА    — substring-матч вместо литерального равенства → умирает г1б
#                    (норма-класс 037: literal, никогда glob/regex);
#   * C-ИГНОР      — не судит -C контекст (запрашивает CWD-репо)  → умирает г3;
#   * КОНФИГ-ФАЙЛ  — запрашивает origin без -c перекрытий        → умирает г4
#                    (И-4: -c remote.origin.url виден суждению);
#   * ЯВНЫЙ-URL    — явный URL-аргумент не судит                  → умирает г5;
#   * БЕЗ-LSREMOTE — живость авторитета не проверяет              → умирает г6
#                    (А-259: success обмена ничего не доказывает);
#   * PULL         — судит push+fetch, не pull                    → умирает г8;
#   * ФЛАГ-СКВОЗЬ  — неизвестный глобальный флаг = сквозной       → умирает г9
#                    (И-2: неизвестная арность = несудимость = отказ);
#   * RAW-ПЕЧАТЬ   — печатает URL без санитизации байтов          → умирает г10
#                    (И-6: перенос строки в URL не может родить
#                    вторую строку отказа «gitw ОТКАЗ: …»).
#
# Клетки честной части (каждая ≡ ровно одна фраза/условие отказа из контракта
# 045 §Инварианты; фразы grep -F дословно):
#   г0  положительный контроль: канонический toy-origin — push+fetch+pull все
#       прозрачны, bare-получатель продвинулся ровно на пушимый tip;
#   г1  Н-141/Н-143: origin клона = путь рабочего репо → push: F1 + цель названа
#       + получатель не тронут;
#   г1б литерал, не подстрока: origin = канонический-путь + суффикс → F1;
#   г1в probe C: push origin main:refs/heads/wip/injected из клона с локальным
#       origin → F1 + в получателе НЕТ ни одного wip/*-рефа;
#   г2  Н-148: та же подмена → fetch: F1 + FETCH_HEAD не создан;
#   г3  форма «-C <путь> push» из-вне репо: F1 (суждение в разрешённом контексте);
#   г4  «-c remote.origin.url=<неканон> push»: F1 + цель- bare НЕ продвинулся;
#   г5  явный URL-аргумент «push <путь> main»: F1 + цель- bare НЕ продвинулся;
#   г6  URL канонический, но авторитет мёртв: F2 «авторитет недоступен» (fail-closed);
#   г7  канарейка: репо без origin → отказ САМОГО git, БЕЗ фразы «gitw ОТКАЗ»
#       (обёртка не присваивает чужие отказы);
#   г8  та же подмена → pull: F1;
#   г9  неизвестный ведущий флаг: F3 с именем флага (fail-closed разбор);
#   г10 URL с управляющими байтами: ровно ОДНА строка «gitw ОТКАЗ: …», перенос
#       строки санитизирован в «?» (подделка второй строки отказа невозможна).
#
# Режимы: внешний (по умолчанию) — стаб-пак затем честные клетки против
# ${GITW:-<корень>/scripts/gitw}; внутренний (RED_GITW_INNER=1) — только честные
# клетки против $GITW (используется внешним режимом для прогонки стабов).
#
# Коды возврата: 0 — всё зелёное; 1 — именованный ОТКАЗ (клетка/стаб названы);
# 2 — NOT_IMPLEMENTED (нет git).
set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
SUBJ="${GITW:-$ROOT/scripts/gitw}"
INNER="${RED_GITW_INNER:-0}"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Герметичность от окружения вызывающего (прецедент next_id.sh/check_staged.sh):
# GIT_DIR/GIT_WORK_TREE перенаправляют git сильнее -C — батарея обязана судить
# свой toy-мир, а не репозиторий вызывающего (тот же класс, что находка 6 круга 2
# адверсария next_id).
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES

WORK="$(mktemp -d "${TMPDIR:-/tmp}/gitw045.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
F1P='gitw ОТКАЗ: URL origin не канонический: '
F2P='gitw ОТКАЗ: авторитет недоступен: ls-remote '
F3P='gitw ОТКАЗ: неизвестный глобальный флаг: '

die_cell() { printf 'ОТКАЗ: %s: %s\n' "$1" "$2" >&2; exit 1; }
ok_cell()  { printf 'ok: %s\n' "$1"; }

# ── toy-мир (Н-141-топология: origin клона = путь РАБОЧЕГО репо) ──────────────
ident() { local d="$1"; shift; git -C "$d" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q "$@"; }


# R1 — рабочий репо-источник (аналог основного чекаута той ночи).
R1="$WORK/r1-istochnik"
git init -q -b main "$R1"
printf 'x\n' > "$R1/f.txt"
git -C "$R1" add f.txt
ident "$R1" -m init

# B1 — bare, каноническая цель зелёных клеток (ручка CANONICAL указывает на неё).
B1="$WORK/b1-kanon"
git init -q --bare "$B1"
git -C "$R1" remote add origin "$B1"
git -C "$R1" push -q -u origin main 2>/dev/null

# REPO2 — клон R1 (origin = РАБОЧИЙ путь R1, ровно Н-141) + локальный коммит.
REPO2="$WORK/klon-lokalnyj"
git clone -q "$R1" "$REPO2" 2>/dev/null
printf 'y\n' > "$REPO2/g.txt"
git -C "$REPO2" add g.txt
ident "$REPO2" -m 'work by clone'

# REPO3 — репо с каноническим origin (B1) для клеток -c/явного-URL.
REPO3="$WORK/r3-kanon"
git init -q -b main "$REPO3"
printf 'z\n' > "$REPO3/h.txt"
git -C "$REPO3" add h.txt
ident "$REPO3" -m init3
git -C "$REPO3" remote add origin "$B1"
git -C "$REPO3" push -q -u origin main 2>/dev/null

# B3 — bare-цель НЕканоническая (побочная сторона клеток г4/г5).
B3="$WORK/b3-cel"
git init -q --bare "$B3"

# REPO6 — origin-URL с управляющими байтами (клетка санитизации г10).
REPO6="$WORK/r6-bajty"
git init -q -b main "$REPO6"
printf 'w\n' > "$REPO6/w.txt"
git -C "$REPO6" add w.txt
ident "$REPO6" -m init6
git -C "$REPO6" config remote.origin.url "$(printf 'prov\ngitw ОТКАЗ: PODDELKA-STROKA')"

# REPO5 — без origin (канарейка г7).
REPO5="$WORK/r5-bez-origin"
git init -q -b main "$REPO5"
printf 'v\n' > "$REPO5/v.txt"
git -C "$REPO5" add v.txt
ident "$REPO5" -m init5

# REPO7 — origin = канонический-путь + суффикс (клетка литерала г1б).
REPO7="$WORK/r7-suffix"
git clone -q "$R1" "$REPO7" 2>/dev/null
git -C "$REPO7" remote set-url origin "${B1}zxloj"

# REPO4 — origin = мёртвый путь, он же CANONICAL (клетка живости г6).
DEAD="$WORK/udaljon"
REPO4="$WORK/r4-mertvyj"
git clone -q "$R1" "$REPO4" 2>/dev/null
git -C "$REPO4" remote set-url origin "$DEAD"

CANON_B1="$B1"    # канонический URL toy-мира (ручка обёртки)

tip_of() { git -C "$1" rev-parse "${2:-main}" 2>/dev/null; }

# ── ядро стаба (УПРОЩЁННЫЙ движок-носитель; НЕ реализация 045) ────────────────
# Каждый стаб = точечная дыра (переменная-ручка) + source ядра. Движок честен
# ровно настолько, чтобы дожить до своей клетки смерти; дыры названы в шапке.
mk_stub_core() {
  cat > "$WORK/stabs/_core.sh" <<'CORE'
#!/usr/bin/env bash
# УПРОЩЁННЫЙ движок обманных стабов батареи 045. НЕ реализация контракта:
# нет И-1 (разрешение настоящего git через PATH-скан), нет И-9 (наследование
# среды), exec не побайтово-прозрачный по построению ручек. Дыры стабов —
# ручки: JUDGE_SUBS, MATCH_MODE, HONOR_DASHC, HONOR_DASHC_IN_QUERY,
# JUDGE_EXPLICIT, LIVENESS, STRICT_FLAGS, SANITIZE.
REAL=/usr/bin/git
CANON="${GIT_EXCHANGE_GUARD_CANONICAL:-ssh://git@github.com/a3ka/dev-harness.git}"
JUDGE_SUBS="${JUDGE_SUBS:-push fetch pull}"
MATCH_MODE="${MATCH_MODE:-literal}"
HONOR_DASHC="${HONOR_DASHC:-1}"
HONOR_DASHC_IN_QUERY="${HONOR_DASHC_IN_QUERY:-1}"
JUDGE_EXPLICIT="${JUDGE_EXPLICIT:-1}"
LIVENESS="${LIVENESS:-1}"
STRICT_FLAGS="${STRICT_FLAGS:-1}"
SANITIZE="${SANITIZE:-1}"
F1='gitw ОТКАЗ: URL origin не канонический: '
F2='gitw ОТКАЗ: авторитет недоступен: ls-remote '
F3='gitw ОТКАЗ: неизвестный глобальный флаг: '
orig=("$@")
san() {
  if [ "$SANITIZE" -eq 0 ]; then printf '%s' "$1"; return; fi
  local q; q="$(printf '%.0s?' $(seq 32))"
  printf '%s' "$1" | LC_ALL=C tr '\001-\037\177' "$q"
}
sub=""; ctx=(); cfg=()
while [ $# -gt 0 ]; do
  case "$1" in
    -C|--git-dir|--work-tree|--namespace|--exec-path) ctx+=("$1" "$2"); shift 2 ;;
    -c) cfg+=("$1" "$2"); shift 2 ;;
    --git-dir=*|--work-tree=*|--namespace=*|--exec-path=*) ctx+=("$1"); shift ;;
    --bare|--no-pager|--paginate|--no-replace-objects|--literal-pathspecs|--no-optional-locks) ctx+=("$1"); shift ;;
    -*)
      if [ "$STRICT_FLAGS" -eq 1 ]; then
        printf '%s%s\n' "$F3" "$1" >&2
        exit 1
      fi
      shift
      ;;
    *) sub="$1"; shift; break ;;
  esac
done
judged=0
for s in $JUDGE_SUBS; do [ "$s" = "$sub" ] && judged=1; done
if [ "$judged" -eq 1 ]; then
  # контекст запроса: -C пары выкинуты, если стаб их не судит (дыра C-ИГНОР)
  qc=(); skip=0
  for el in "${ctx[@]}"; do
    if [ "$skip" -eq 1 ]; then skip=0; continue; fi
    if [ "$HONOR_DASHC" -eq 0 ] && [ "$el" = "-C" ]; then skip=1; continue; fi
    qc+=("$el")
  done
  [ "$HONOR_DASHC_IN_QUERY" -eq 1 ] && qc+=("${cfg[@]}")
  target=""
  look="$*"
  for a in $look; do
    case "$a" in
      *://*|/*|../*|./*)
        [ "$JUDGE_EXPLICIT" -eq 1 ] && target="$a"
        break
        ;;
      -*) ;;
      *) break ;;
    esac
  done
  if [ -z "$target" ]; then
    # ДВОЙНАЯ сверка (спека 045 И-4): config --get видит -c перекрытия,
    # remote get-url видит insteadOf-переписывание; живой замер этой пачки:
    # remote get-url -c НЕ видит (возвращает файловое значение) — потому обе.
    u_cfg="$("$REAL" "${qc[@]}" config --get remote.origin.url 2>/dev/null || true)"
    u_get="$("$REAL" "${qc[@]}" remote get-url origin 2>/dev/null || true)"
    if [ -n "$u_cfg" ]; then target="$u_cfg"; elif [ -n "$u_get" ]; then target="$u_get"; fi
  fi
  if [ -n "$target" ]; then
    ok=1
    if [ "$MATCH_MODE" = "literal" ]; then
      [ "$target" = "$CANON" ] || ok=0
    else
      case "$target" in *"$CANON"*) ;; *) ok=0 ;; esac
    fi
    if [ "$ok" -ne 1 ]; then
      printf '%s%s\n' "$F1" "$(san "$target")" >&2
      exit 1
    fi
    if [ "$LIVENESS" -eq 1 ]; then
      "$REAL" "${qc[@]}" ls-remote "$target" HEAD >/dev/null 2>&1
      lrc=$?
      [ "$lrc" -eq 0 ] || { printf '%s%s rc=%s\n' "$F2" "$target" "$lrc" >&2; exit 1; }
    fi
  fi
fi
exec "$REAL" "${orig[@]}"
CORE
}

# ── стабы: девять обманных реализаций, дыра каждого — одна ручка ─────────────
mk_stubs() {
  mkdir -p "$WORK/stabs"
  mk_stub_core
  # ПУШ-ТОЛЬКО: судит только push (fetch/pull насквозь) — смерть г2.
  printf '#!/usr/bin/env bash\nJUDGE_SUBS="push"\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/pushonly.sh"
  # ПОДСТРОКА: substring-матч вместо литерала — смерть г1б.
  printf '#!/usr/bin/env bash\nMATCH_MODE=substring\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/podstroka.sh"
  # C-ИГНОР: не судит -C контекст (запрос по CWD) — смерть г3.
  printf '#!/usr/bin/env bash\nHONOR_DASHC=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/cignor.sh"
  # КОНФИГ-ФАЙЛ: запрос origin без -c перекрытий — смерть г4.
  printf '#!/usr/bin/env bash\nHONOR_DASHC_IN_QUERY=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/configfile.sh"
  # ЯВНЫЙ-URL: явный URL-аргумент не судит — смерть г5.
  printf '#!/usr/bin/env bash\nJUDGE_EXPLICIT=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/urlargskip.sh"
  # БЕЗ-LSREMOTE: живость авторитета не проверяет — смерть г6.
  printf '#!/usr/bin/env bash\nLIVENESS=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/nolsremote.sh"
  # PULL: судит push+fetch, не pull — смерть г8.
  printf '#!/usr/bin/env bash\nJUDGE_SUBS="push fetch"\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/pullskip.sh"
  # ФЛАГ-СКВОЗЬ: неизвестный ведущий флаг не отказывает — смерть г9.
  printf '#!/usr/bin/env bash\nSTRICT_FLAGS=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/flagskip.sh"
  # RAW-ПЕЧАТЬ: URL в отказе без санитизации — смерть г10.
  printf '#!/usr/bin/env bash\nSANITIZE=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/rawprint.sh"
  chmod +x "$WORK/stabs"/*.sh
}

# ── стаб-пак: каждый стаб обязан умереть НА СВОЕЙ клетке (rc1 + имя клетки) ───
run_stub_pack() {
  mk_stubs
  local pairs=(
    "pushonly:г2" "podstroka:г1б" "cignor:г3" "configfile:г4" "urlargskip:г5"
    "nolsremote:г6" "pullskip:г8" "flagskip:г9" "rawprint:г10"
  )
  local pair name cell rc
  for pair in "${pairs[@]}"; do
    name="${pair%%:*}"; cell="${pair##*:}"
    [ -f "$WORK/stabs/$name.sh" ] || die_cell "стаб-$name" "файл стаба не создан"
    RED_GITW_INNER=1 GITW="$WORK/stabs/$name.sh" bash "$0" "$ROOT" \
      >"$WORK/out-$name" 2>"$WORK/err-$name"
    rc=$?
    if [ "$rc" -ne 1 ] || ! grep -q "ОТКАЗ: $cell" "$WORK/err-$name"; then
      die_cell "стаб-$name" "не умер на клетке $cell (rc=$rc): $(tail -n 3 "$WORK/err-$name" | tr '\n' ' ')"
    fi
    printf 'ok: стаб-%s умирает на %s\n' "$name" "$cell"
  done
}

# ── честные клетки ────────────────────────────────────────────────────────────
run_honest_cells() {
  # г0: предмет существует? — ЕДИНСТВЕННАЯ красная причина до реализации.
  if [ ! -f "$SUBJ" ]; then
    die_cell г0 "предмет отсутствует: $SUBJ"
  fi

  # г0 положительный контроль: канонический toy-origin, все три обмена прозрачны.
  ( cd "$R1" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push ) \
    >"$WORK/o0" 2>"$WORK/e0" \
    || die_cell г0 "push на канонической цели не прошёл: $(tail -n 2 "$WORK/e0" | tr '\n' ' ')"
  [ "$(tip_of "$B1")" = "$(tip_of "$R1")" ] || die_cell г0 "bare-цель не продвинулась на tip R1"
  ( cd "$R1" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" fetch ) >/dev/null 2>&1 \
    || die_cell г0 "fetch на канонической цели не прошёл"
  ( cd "$R1" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" pull ) >/dev/null 2>&1 \
    || die_cell г0 "pull на канонической цели не прошёл"
  ok_cell г0

  # г1 Н-141/Н-143: push из клона с origin = путь рабочего репо.
  ( cd "$REPO2" && "$SUBJ" push ) >"$WORK/o1" 2>"$WORK/e1"
  rc=$?
  [ "$rc" -eq 1 ] || die_cell г1 "rc=$rc (ожидался 1)"
  grep -qF "$F1P" "$WORK/e1" || die_cell г1 "фраза F1 не названа: $(tail -n 2 "$WORK/e1" | tr '\n' ' ')"
  grep -qF -- "$R1" "$WORK/e1" || die_cell г1 "неканоническая цель не названа в отказе"
  [ "$(tip_of "$R1")" = "$(git -C "$R1" rev-parse main)" ] || die_cell г1 "получатель R1 мутирован"
  ok_cell г1

  # г1б литерал, не подстрока: origin = канонический путь + суффикс.
  ( cd "$REPO7" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push ) >"$WORK/o1b" 2>"$WORK/e1b"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e1b"; } \
    || die_cell г1б "rc=$rc, подстрока канона обязана отказывать F1: $(tail -n 2 "$WORK/e1b" | tr '\n' ' ')"
  grep -qF -- "${B1}zxloj" "$WORK/e1b" || die_cell г1б "цель-суффикс не названа"
  ok_cell г1б

  # г1в probe C: инжект не-текущей ветки из клона с локальным origin.
  ( cd "$REPO2" && "$SUBJ" push origin main:refs/heads/wip/injected ) >"$WORK/o1v" 2>"$WORK/e1v"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e1v"; } \
    || die_cell г1в "rc=$rc, инжект wip/* из локального origin обязан умереть на F1"
  [ -z "$(git -C "$R1" for-each-ref --format='%(refname)' refs/heads/wip/)" ] \
    || die_cell г1в "в получателе появился wip/*-реф (probe C прошёл!)"
  ok_cell г1в

  # г2 Н-148: fetch по подменённому origin.
  rm -f "$REPO2/.git/FETCH_HEAD"
  ( cd "$REPO2" && "$SUBJ" fetch ) >"$WORK/o2" 2>"$WORK/e2"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e2"; } \
    || die_cell г2 "rc=$rc, fetch по подменённому origin обязан отказать F1: $(tail -n 2 "$WORK/e2" | tr '\n' ' ')"
  [ ! -e "$REPO2/.git/FETCH_HEAD" ] || die_cell г2 "FETCH_HEAD создан — обмен частично исполнился"
  ok_cell г2

  # г3 форма «-C <путь> push» из-вне репо.
  ( cd "$WORK" && "$SUBJ" -C "$REPO2" push ) >"$WORK/o3" 2>"$WORK/e3"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e3"; } \
    || die_cell г3 "rc=$rc, -C контекст обязан судиться: $(tail -n 2 "$WORK/e3" | tr '\n' ' ')"
  ok_cell г3

  # г4 «-c remote.origin.url=<неканон> push»: перекрытие видно суждению.
  before4="$(tip_of "$B3")"
  ( cd "$REPO3" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" -c "remote.origin.url=$B3" push ) >"$WORK/o4" 2>"$WORK/e4"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e4"; } \
    || die_cell г4 "rc=$rc, -c перекрытие цели обязано отказать F1"
  [ "$(tip_of "$B3")" = "$before4" ] || die_cell г4 "цель B3 продвинулась — обмен исполнился"
  ok_cell г4

  # г5 явный URL-аргумент.
  before5="$(tip_of "$B3")"
  ( cd "$REPO3" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push "$B3" main ) >"$WORK/o5" 2>"$WORK/e5"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e5"; } \
    || die_cell г5 "rc=$rc, явный URL-аргумент обязан судиться"
  [ "$(tip_of "$B3")" = "$before5" ] || die_cell г5 "цель B3 продвинулась — обмен исполнился"
  ok_cell г5

  # г6 живость авторитета: URL канонический, путь мёртв.
  ( cd "$REPO4" && GIT_EXCHANGE_GUARD_CANONICAL="$DEAD" "$SUBJ" push ) >"$WORK/o6" 2>"$WORK/e6"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F2P" "$WORK/e6"; } \
    || die_cell г6 "rc=$rc, мёртвый авторитет обязан отказать F2 (fail-closed): $(tail -n 2 "$WORK/e6" | tr '\n' ' ')"
  ok_cell г6

  # г7 канарейка: нет origin — отказ самого git, без присвоения фразы.
  ( cd "$REPO5" && "$SUBJ" push ) >"$WORK/o7" 2>"$WORK/e7"
  rc=$?
  [ "$rc" -ne 0 ] || die_cell г7 "push без origin обязан провалиться (самим git)"
  if grep -qF 'gitw ОТКАЗ' "$WORK/e7"; then die_cell г7 "обёртка присвоила чужой отказ git"; fi
  ok_cell г7

  # г8 pull по подменённому origin.
  before8="$(tip_of "$REPO2")"
  ( cd "$REPO2" && "$SUBJ" pull ) >"$WORK/o8" 2>"$WORK/e8"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e8"; } \
    || die_cell г8 "rc=$rc, pull обязан судиться как обмен"
  [ "$(tip_of "$REPO2")" = "$before8" ] || die_cell г8 "HEAD клона сместился — pull исполнился"
  ok_cell г8

  # г9 неизвестный ведущий флаг: fail-closed разбор.
  ( cd "$REPO2" && "$SUBJ" --buduschij-flag push ) >"$WORK/o9" 2>"$WORK/e9"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F3P" "$WORK/e9" && grep -qF -- '--buduschij-flag' "$WORK/e9"; } \
    || die_cell г9 "rc=$rc, неизвестный флаг обязан отказать F3 с именем флага"
  ok_cell г9

  # г10 санитизация печати: управляющие байты цели гасятся.
  ( cd "$REPO6" && "$SUBJ" push ) >"$WORK/o10" 2>"$WORK/e10"
  rc=$?
  [ "$rc" -eq 1 ] || die_cell г10 "rc=$rc (ожидался 1)"
  [ "$(grep -c '^gitw ОТКАЗ' "$WORK/e10")" -eq 1 ] \
    || die_cell г10 "строк «gitw ОТКАЗ» не одна — перенос строки в URL родил поддельную строку отказа"
  grep -qF 'prov?gitw' "$WORK/e10" \
    || die_cell г10 "санитизация не видна (ожидался «prov?gitw…» с гашением перевода строки)"
  ok_cell г10
}

# ── диспетчер режимов ─────────────────────────────────────────────────────────
if [ "$INNER" -eq 1 ]; then
  run_honest_cells
  exit 0
fi

run_stub_pack
run_honest_cells
printf 'gitw: батарея зелёная (клетки г0-г10 + 9 стабов на своих клетках)\n'
exit 0
