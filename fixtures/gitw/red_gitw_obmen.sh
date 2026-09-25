#!/usr/bin/env bash
# КРАСНОЕ 045 (scripts/gitw — pre-exchange гард цели git-обмена, единый корень
# Н-141+Н-143+Н-148 + probe C): обёртки ещё не существует — честная часть батареи
# красна ЕДИНСТВЕННОЙ причиной «предмет отсутствует» (fail-fast, г0), а стаб-пак
# (исполняется ДО честных клеток) зелён И ДО реализации: двадцать обманных стабов
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
#                    вторую строку отказа «gitw ОТКАЗ: …»);
#   * ОДНА-ФОРМА   — предпочитает config --get, игнорирует        → умирает г11
#                    неканонический get-url при непустой первой
#                    (критик 045-Б2: живой обход — ядро-носитель
#                    в таком виде исполняло push в чужой bare);
#   * PUSHURL-ИГНОР — не судит remote.origin.pushurl —           → умирает г12
#                    фактическую цель push (критик 045-Б3: push
#                    реально уходит на pushurl-цель).
#   * РЕПО-РАВНО-СКВОЗЬ — `--repo=VALUE` не признан целью   → умирает г17
#                    (живой обход адверсария 045-v3: equals-форма
#                    проходит как безобидный `-*`-флаг, судится origin);
#   * РЕПО-ПАРА-СЪЕДЕНА — `--repo VALUE` съеден как флаг     → умирает г17б
#                    арности 2 без суждения значения;
#   * РЕПО-ТОЛЬКО-ИМЯ — equals-форма признана лишь для       → умирает г17в
#                    bare-имени, значение-путь не судится;
#   * РЕПО-БЕЗ-SCP — bare и path признаны, SCP-форма         → умирает г17г
#                    значения не судится;
#   * РЕПО-ГЛУХОЙ-РАВНО — отказ на equals-форме БЕЗ сверки   → умирает г17д
#                    с каноном (над-блокировка);
#   * РЕПО-ГЛУХОЙ-ПАРА — то же для раздельной формы          → умирает г17е;
#   * РЕПО-ПРИОРИТЕТ — --repo поставлен ВЫШЕ позиционной     → умирает г17ж
#                    цели (против git-push(1): «If both are specified,
#                    the command-line argument takes precedence»);
#   * РЕПО-ПАРА-СКВОЗЬ-1 — `--repo` пропущен на ОДИН токен   → умирает г17з
#                    (значение обрывает позиционный скан: форма
#                    «судится» совпадением и рушится, как только за
#                    опцией стоит настоящая позиционная цель).
#   * СЛЭШ-ДВОЕТОЧИЕ-СКВОЗЬ — первый позиционный токен вида  → умирает г18
#                    `dir/sub:branch` пропущен вместо суждения (судится
#                    настроенный origin, обмен уходит в путь-цель).
#
# Клетки честной части (каждая ≡ ровно одна фраза/условие отказа из контракта
# 045 §Инварианты; г13-г16 — из вердикта адверсария 045-v1, живой обход
# именованного remote и SCP-формы; фразы grep -F дословно):
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
#       строки санитизирован в «?» (подделка второй строки отказа невозможна);
#   г11 критик 045-Б2: канонический ФАЙЛОВЫЙ remote.origin.url +
#       insteadOf-перекрытие на чужой путь — РАСКРЫТЫЙ url неканоничен и
#       является фактической целью настоящего git → F1 + чужой bare НЕ тронут;
#   г12 критик 045-Б3: обе формы url каноничны, remote.origin.pushurl на
#       чужой bare — фактическая цель push → F1 + pushurl-получатель НЕ тронут.
#   г13 адверсарий 045-v1: канонический origin + именованный remote evil на
#       чужой bare, «push evil HEAD:refs/heads/named-push» → F1R + раскрытая
#       цель названа + чужой bare НЕ продвинут (обход именованного remote,
#       SHA-доказано вердиктом ea1925f);
#   г14 тот же evil, «fetch evil main» → F1R + FETCH_HEAD без чужого SHA;
#   г15 тот же evil, «pull evil main» → F1R + HEAD жертвы не сдвинут;
#   г16 SCP-форма явной цели «git@example.test:any/path» (GIT_SSH_COMMAND-
#       адаптер обслуживает настоящий receive-pack чужой bare, сеть не
#       нужна — приём адверсария) → F1 + SCP-получатель НЕ продвинут.
#   г17  адверсарий 045-v3 (ЖИВОЙ обход, SHA-доказан): канонический origin +
#        «push --force --repo=evil --all» — equals-форма опции ЕСТЬ
#        repository-аргумент git-push(1) → F1R + раскрытая цель названа +
#        чужой bare НЕ продвинут;
#   г17б та же атака раздельной формой «--repo evil» → F1R + bare не продвинут;
#   г17в equals-форма со значением-ПУТЁМ (не имя remote) → F1 + путь назван +
#        чужой bare НЕ продвинут (классификация значения полна, не только bare);
#   г17г equals-форма со значением SCP-формы (адаптер обслуживает чужой bare)
#        → F1 + SCP-цель названа + чужой bare НЕ продвинут;
#   г17д положительный контроль: «push --repo=origin» при КАНОНИЧЕСКОМ origin
#        проходит rc0 без «gitw ОТКАЗ» (гард не имеет права глухо отказывать
#        на самой опции — над-блокировка ломает законный обмен);
#   г17е тот же положительный контроль раздельной формой «--repo origin»;
#   г17ж приоритет позиционной цели (git-push(1) дословно: «If both are
#        specified, the command-line argument takes precedence»; замерено
#        живьём на git 2.55): «push --repo=origin <чужой-bare> main» уходит в
#        ЧУЖОЙ bare → F1 + чужая цель названа + она НЕ продвинута (канонический
#        --repo НЕ отмывает злую позиционную цель);
#   г17з то же раздельной формой «--repo origin <чужой-bare> main» — значение
#        опции обязано ВЫЙТИ из позиционного скана, а скан продолжиться до
#        настоящей позиционной цели.
#   г18  первый позиционный токен с двоеточием ПОСЛЕ слэша («dir/sub:branch»)
#        ЕСТЬ repository-аргумент: замерено (git 2.55), что git трактует его
#        как ЛОКАЛЬНЫЙ ПУТЬ и реально пушит во вложенный bare, а токен вида
#        refs/a:refs/b в этой позиции git читает как репозиторий, не refspec
#        («does not appear to be a git repository») — refspec первым
#        позиционным невозможен по построению. → обёртка обязана ЗАВЕРШИТЬСЯ
#        (не зациклиться) и отказать F1 + вложенный bare НЕ продвинут.
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
# F1R — отказ именованного remote (фикс живого обхода адверсария 045-v1;
# форма «URL remote <имя>» согласована с реализацией scripts/gitw до её
# коммита: именованная фактическая цель ≠ origin, классическая F1 — только
# для дефолтного origin и явных URL-аргументов).
F1R='gitw ОТКАЗ: URL remote evil не канонический: '

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

# REPO8 — insteadOf-перекрытие: ФАЙЛОВЫЙ url каноничен (B1), РАСКРЫТЫЙ — чужой
# путь B3, он же фактическая цель настоящего git (клетка г11, критик 045-Б2).
# Начальный push выполняется ДО установки insteadOf — уходит в B1, не в B3.
REPO8="$WORK/r8-insteadof"
git init -q -b main "$REPO8"
printf 's\n' > "$REPO8/s.txt"
git -C "$REPO8" add s.txt
ident "$REPO8" -m init8
git -C "$REPO8" remote add origin "$B1"
git -C "$REPO8" push -q -u origin main 2>/dev/null
git -C "$REPO8" config url."$B3".insteadOf "$B1"

# REPO9 — pushurl на чужой bare: ОБЕ формы url каноничны (B1), фактическая цель
# push = pushurl (B3) — клетка г12, критик 045-Б3.
REPO9="$WORK/r9-pushurl"
git init -q -b main "$REPO9"
printf 't\n' > "$REPO9/t.txt"
git -C "$REPO9" add t.txt
ident "$REPO9" -m init9
git -C "$REPO9" remote add origin "$B1"
git -C "$REPO9" push -q -u origin main 2>/dev/null
git -C "$REPO9" config remote.origin.pushurl "$B3"

# EVILSRC/B4 — чужой bare с СОБСТВЕННЫМ tip'ом поверх истории B1 (клетки
# г13-г16, адверсарий 045-v1): пустой bare дал бы отказ САМОГО git, а не
# живой обход — fetch/pull с evil обязаны быть настоящим обменом, чтобы
# краснота клеток была SHA-доказуемой.
EVILSRC="$WORK/evil-istochnik"
git clone -q "$R1" "$EVILSRC" 2>/dev/null
printf 'e\n' > "$EVILSRC/e.txt"
git -C "$EVILSRC" add e.txt
ident "$EVILSRC" -m 'evil tip'
B4="$WORK/b4-chuzhoj"
git init -q -b main --bare "$B4"
git -C "$EVILSRC" push -q "$B4" main 2>/dev/null

# REPO10 — жертва именованного remote: origin КАНОНИЧЕН (B1), добавлен
# именованный remote evil на чужой bare B4. main жертвы = tip B1, B4/main =
# tip B1 + чужой коммит → до фикса «pull evil main» — чистый fast-forward
# на чужой SHA (сильнейшее доказательство живого обмена).
REPO10="$WORK/r10-zhertva"
git clone -q "$R1" "$REPO10" 2>/dev/null
git -C "$REPO10" remote set-url origin "$B1"
git -C "$REPO10" remote add evil "$B4"

# SSHAD — GIT_SSH_COMMAND-адаптер (приём адверсария 045-v1, дословно
# перенесён): SCP-цель git@example.test:any/path обслуживается настоящим
# receive-pack/upload-pack чужой bare B4 локально, сеть не нужна.
SSHAD="$WORK/ssh-adapter.sh"
printf '#!/usr/bin/env bash\nlast="${@: -1}"\ncase "$last" in git-receive-pack\\ *) exec git receive-pack "%s" ;; git-upload-pack\\ *) exec git upload-pack "%s" ;; esac\nexit 1\n' "$B4" "$B4" > "$SSHAD"
chmod +x "$SSHAD"

CANON_B1="$B1"    # канонический URL toy-мира (ручка обёртки)
# REPO11 — жертва клетки г18: origin КАНОНИЧЕН (B1), а внутри рабочего дерева
# лежит bare-репозиторий по ОТНОСИТЕЛЬНОМУ пути с двоеточием ПОСЛЕ слэша.
# Замер (git 2.55): `push dir/sub:branch main` реально пушит в него — значит
# пропуск такого токена обёрткой есть обход, а не безобидная терпимость.
REPO11="$WORK/r11-slash-colon"
git clone -q "$R1" "$REPO11" 2>/dev/null
git -C "$REPO11" remote set-url origin "$B1"
mkdir -p "$REPO11/dir"
git init -q -b main --bare "$REPO11/dir/sub:branch"
SLASHCOLON="$REPO11/dir/sub:branch"

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
# JUDGE_EXPLICIT, LIVENESS, STRICT_FLAGS, SANITIZE, URL_DOUBLING, HONOR_PUSHURL,
# REPO_EQ_FORMS, REPO_OPT_SEP, REPO_BLIND, REPO_PRIORITY.
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
URL_DOUBLING="${URL_DOUBLING:-1}"
HONOR_PUSHURL="${HONOR_PUSHURL:-1}"
# Ручки --repo-семейства (вердикт адверсария 045-v3, живой обход equals-формы):
# REPO_EQ_FORMS — какие формы значения `--repo=VALUE` стаб признаёт целью
#                 (ПУСТО ≠ «по умолчанию»: подстановка без двоеточия, иначе
#                 стаб-дыра REPO_EQ_FORMS="" молча получила бы честный
#                 список и перестала быть дырой — замерено на этой пачке);
# REPO_OPT_SEP  — разбор раздельной формы `--repo VALUE`: arm (честно, опция
#                 арности 2 + скан продолжается) | skip1 (пропуск одного
#                 токена) | skip2 (пара съедена молча);
# REPO_BLIND    — отказывать БЕЗ сверки с каноном на форме eq|sep;
# REPO_PRIORITY — ставить --repo ВЫШЕ позиционной цели (против git-push(1)).
REPO_EQ_FORMS="${REPO_EQ_FORMS-bare path scp url}"
REPO_OPT_SEP="${REPO_OPT_SEP:-arm}"
REPO_BLIND="${REPO_BLIND:-}"
# SLASH_COLON   — первый позиционный токен с двоеточием ПОСЛЕ слэша:
#                 target (честно, он и есть repository-аргумент) | skip.
SLASH_COLON="${SLASH_COLON:-target}"
REPO_PRIORITY="${REPO_PRIORITY:-0}"
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
  target=""; bare_name=""; repo_val=""; repo_form=""
  # Классификатор формы репозитория (git: URL / SCP / path / bare-имя
  # настроенного remote) — общий для позиционной цели и значения --repo.
  form_of() {
    case "$1" in
      *://*) printf url ;;
      /*|../*|./*) printf path ;;
      *:*) case "${1%%:*}" in */*) printf path ;; *) printf scp ;; esac ;;
      *) printf bare ;;
    esac
  }
  rest=("$@")
  m=${#rest[@]}
  j=0
  while [ "$j" -lt "$m" ]; do
    a="${rest[$j]}"
    case "$a" in
      --repo=*)
        # ДЫРА REPO_EQ_FORMS: какие формы значения equals-формы стаб вообще
        # признаёт целью ("" — никакую: ровно живой обход адверсария 045-v3).
        v="${a#--repo=}"
        f="$(form_of "$v")"
        for want in $REPO_EQ_FORMS; do
          [ "$want" = "$f" ] && { repo_val="$v"; repo_form=eq; }
        done
        j=$((j+1))
        ;;
      --repo)
        # Честно (arm): опция арности 2 — значение ВЫХОДИТ из позиционного
        # скана, а скан ПРОДОЛЖАЕТСЯ и находит настоящую позиционную цель
        # (git-push(1): позиционная сильнее --repo).
        # ДЫРА skip2: пара съедена молча — не судится ни значение, ни
        # позиционная цель за ней.
        # ДЫРА skip1: пропуск на ОДИН токен — значение остаётся в позиционном
        # скане и ОБРЫВАЕТ его; раздельная форма «судится» лишь совпадением и
        # разваливается, как только за опцией стоит позиционная цель.
        case "$REPO_OPT_SEP" in
          arm)
            [ "$((j+1))" -lt "$m" ] && { repo_val="${rest[$((j+1))]}"; repo_form=sep; }
            j=$((j+2))
            ;;
          skip1) j=$((j+1)) ;;
          *) j=$((j+2)) ;;
        esac
        ;;
      *://*|/*|../*|./*)
        [ "$JUDGE_EXPLICIT" -eq 1 ] && target="$a"
        break
        ;;
      *:*)
        # ЧЕСТНО: первый позиционный токен ЕСТЬ repository-аргумент git,
        # какой бы формы он ни был (замер: refs/a:refs/b в этой позиции git
        # читает как репозиторий, а dir/sub:branch — как локальный путь и
        # реально пушит в него). ДЫРА SLASH_COLON=skip: токен с двоеточием
        # ПОСЛЕ слэша пропущен, судится настроенный origin — клетка г18.
        case "${a%%:*}" in
          */*)
            if [ "$SLASH_COLON" = skip ]; then j=$((j+1)); else
              [ "$JUDGE_EXPLICIT" -eq 1 ] && target="$a"
              break
            fi
            ;;
          *) [ "$JUDGE_EXPLICIT" -eq 1 ] && target="$a"; break ;;
        esac
        ;;
      -*) j=$((j+1)) ;;
      *) bare_name="$a"; break ;;
    esac
  done
  # git-push(1): «--repo=<repository> ... If both are specified, the
  # command-line argument takes precedence» (замерено живьём: push
  # --repo=origin <чужой-путь> main уходит в ЧУЖОЙ путь). Значит --repo —
  # цель ТОЛЬКО при отсутствии позиционной. ДЫРА REPO_PRIORITY=1: перекрывает.
  if [ -n "$repo_val" ] \
     && { [ "$REPO_PRIORITY" -eq 1 ] || { [ -z "$target" ] && [ -z "$bare_name" ]; }; }; then
    case "$(form_of "$repo_val")" in
      bare) bare_name="$repo_val"; target="" ;;
      *) target="$repo_val"; bare_name="" ;;
    esac
  fi
  if [ -z "$target" ]; then
    # Сверка КАЖДОЙ непустой формы цели (спека 045 И-4 после критика-Б2/Б3):
    # config --get видит -c перекрытия; remote get-url видит insteadOf-
    # переписывание (живой замер: remote get-url при -c возвращает ФАЙЛОВОЕ
    # значение) — потому обе; для push дополнительно обе формы pushurl —
    # фактическая цель push = pushurl ЕСЛИ задан, иначе url.
    check_remote="${bare_name:-origin}"
    u_cfg="$("$REAL" "${qc[@]}" config --get "remote.$check_remote.url" 2>/dev/null || true)"
    u_get="$("$REAL" "${qc[@]}" remote get-url "$check_remote" 2>/dev/null || true)"
    p_cfg=""; p_get=""
    if [ "$HONOR_PUSHURL" -eq 1 ] && [ "$sub" = push ]; then
      p_cfg="$("$REAL" "${qc[@]}" config --get "remote.$check_remote.pushurl" 2>/dev/null || true)"
      p_get="$("$REAL" "${qc[@]}" remote get-url --push "$check_remote" 2>/dev/null || true)"
    fi
    if [ "$URL_DOUBLING" -eq 1 ]; then
      # честная ветвь: ВСЕ непустые формы обязаны быть литерально каноничны;
      # фактическая цель (именуется в F1, цель живости): push с заданным
      # pushurl → раскрытый pushurl, иначе раскрытый url.
      bad=""
      for v in "$u_cfg" "$u_get" "$p_cfg" "$p_get"; do
        [ -n "$v" ] || continue
        okf=1
        if [ "$MATCH_MODE" = "literal" ]; then [ "$v" = "$CANON" ] || okf=0
        else case "$v" in *"$CANON"*) ;; *) okf=0 ;; esac; fi
        [ "$okf" -eq 1 ] || bad=1
      done
      if [ -n "$p_cfg" ]; then eff="$p_get"; else eff="$u_get"; fi
      # ДЫРА REPO_BLIND=eq|sep: отказ БЕЗ сверки с каноном, когда цель пришла
      # из --repo соответствующей формы (над-блокировка — клетки г17д/г17е).
      [ -n "$REPO_BLIND" ] && [ "$REPO_BLIND" = "$repo_form" ] && bad=1
      if [ -n "$bad" ]; then
        if [ "$check_remote" = origin ]; then
          printf '%s%s\n' "$F1" "$(san "$eff")" >&2
        else
          printf 'gitw ОТКАЗ: URL remote %s не канонический: %s\n' \
            "$(san "$check_remote")" "$(san "$eff")" >&2
        fi
        exit 1
      fi
      target="$eff"
    else
      # ДЫРА стаба ОДНА-ФОРМА (живой обход критика 045-Б2): предпочитает
      # config --get, игнорирует неканонический get-url при непустой первой.
      if [ -n "$u_cfg" ]; then target="$u_cfg"; elif [ -n "$u_get" ]; then target="$u_get"; fi
    fi
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

# ── стабы: двадцать обманных реализаций, дыра каждого — одна ручка ───────────
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
  # ОДНА-ФОРМА: предпочитает config --get, игнорирует неканонический get-url
  # при непустой первой (ровно движок-носитель до правки по критику 045-Б2) —
  # смерть г11.
  printf '#!/usr/bin/env bash\nURL_DOUBLING=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/odnaforma.sh"
  # PUSHURL-ИГНОР: не судит remote.origin.pushurl — фактическую цель push
  # (живой обход критика 045-Б3) — смерть г12.
  printf '#!/usr/bin/env bash\nHONOR_PUSHURL=0\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/pushurlskip.sh"
  # РЕПО-РАВНО-СКВОЗЬ: `--repo=VALUE` не признаётся целью вовсе — ровно живой
  # обход адверсария 045-v3 (equals-форма проходит как безобидный `-*`-флаг,
  # судится настроенный origin) — смерть г17.
  printf '#!/usr/bin/env bash\nREPO_EQ_FORMS=""\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/repoeqskip.sh"
  # РЕПО-ПАРА-СЪЕДЕНА: `--repo VALUE` проглочен как «безобидный флаг арности
  # 2» — ни значение, ни позиционная цель не судятся — смерть г17б.
  printf '#!/usr/bin/env bash\nREPO_OPT_SEP=skip2\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/reposepskip.sh"
  # РЕПО-ТОЛЬКО-ИМЯ: equals-форма признаётся лишь для bare-имени настроенного
  # remote, значение-путь проходит мимо суждения — смерть г17в.
  printf '#!/usr/bin/env bash\nREPO_EQ_FORMS="bare"\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/repoeqbare.sh"
  # РЕПО-БЕЗ-SCP: признаёт bare и path, но не SCP-форму значения — смерть г17г.
  printf '#!/usr/bin/env bash\nREPO_EQ_FORMS="bare path"\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/repoeqpath.sh"
  # РЕПО-ГЛУХОЙ-РАВНО: отказ на equals-форме БЕЗ сверки с каноном
  # (над-блокировка: канонический `--repo=origin` умирает) — смерть г17д.
  printf '#!/usr/bin/env bash\nREPO_BLIND=eq\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/repoblindeq.sh"
  # РЕПО-ГЛУХОЙ-ПАРА: то же для раздельной формы — смерть г17е.
  printf '#!/usr/bin/env bash\nREPO_BLIND=sep\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/repoblindsep.sh"
  # РЕПО-ПРИОРИТЕТ: --repo поставлен ВЫШЕ позиционной цели (против
  # git-push(1): «If both are specified, the command-line argument takes
  # precedence») — канонический `--repo=origin` отмывает злую позиционную
  # цель — смерть г17ж.
  printf '#!/usr/bin/env bash\nREPO_PRIORITY=1\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/repoprio.sh"
  # РЕПО-ПАРА-СКВОЗЬ-1: `--repo` пропущен на ОДИН токен (значение остаётся в
  # позиционном скане и обрывает его) — раздельная форма «работает» лишь
  # совпадением: при настоящей позиционной цели за опцией судится значение
  # опции, а обмен уходит в позиционную — смерть г17з.
  printf '#!/usr/bin/env bash\nREPO_OPT_SEP=skip1\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/reposep1.sh"
  # СЛЭШ-ДВОЕТОЧИЕ-СКВОЗЬ: первый позиционный токен `dir/sub:branch` пропущен
  # вместо суждения — обмен уходит в путь-цель, а судится origin — смерть г18.
  printf '#!/usr/bin/env bash\nSLASH_COLON=skip\nsource "$(dirname "$0")/_core.sh"\n' \
    > "$WORK/stabs/slashcolonskip.sh"
  chmod +x "$WORK/stabs"/*.sh
}

# ── стаб-пак: каждый стаб обязан умереть НА СВОЕЙ клетке (rc1 + имя клетки) ───
run_stub_pack() {
  mk_stubs
  local pairs=(
    "pushonly:г2" "podstroka:г1б" "cignor:г3" "configfile:г4" "urlargskip:г5"
    "nolsremote:г6" "pullskip:г8" "flagskip:г9" "rawprint:г10"
    "odnaforma:г11" "pushurlskip:г12"
    "repoeqskip:г17" "reposepskip:г17б" "repoeqbare:г17в" "repoeqpath:г17г"
    "repoblindeq:г17д" "repoblindsep:г17е" "repoprio:г17ж" "reposep1:г17з"
    "slashcolonskip:г18"
  )
  local pair name cell rc
  for pair in "${pairs[@]}"; do
    name="${pair%%:*}"; cell="${pair##*:}"
    [ -f "$WORK/stabs/$name.sh" ] || die_cell "стаб-$name" "файл стаба не создан"
    RED_GITW_INNER=1 GITW="$WORK/stabs/$name.sh" bash "$0" "$ROOT" \
      >"$WORK/out-$name" 2>"$WORK/err-$name"
    rc=$?
    # Сверка имени клетки — с ДВОЕТОЧИЕМ-терминатором (die_cell печатает
    # «ОТКАЗ: <клетка>: …»): без него «г17» совпало бы подстрокой с «г17б»,
    # и стаб, доживший до чужой клетки, зачёлся бы как умерший на своей.
    if [ "$rc" -ne 1 ] || ! grep -qF "ОТКАЗ: $cell: " "$WORK/err-$name"; then
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

  # г11 критик 045-Б2: канонический ФАЙЛОВЫЙ url + insteadOf-перекрытие —
  # раскрытый url неканоничен и ЯВЛЯЕТСЯ фактической целью настоящего git.
  before11="$(tip_of "$B3")"
  ( cd "$REPO8" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push ) >"$WORK/o11" 2>"$WORK/e11"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e11"; } \
    || die_cell г11 "rc=$rc, insteadOf-раскрытая цель обязана отказать F1: $(tail -n 2 "$WORK/e11" | tr '\n' ' ')"
  grep -qF -- "$B3" "$WORK/e11" || die_cell г11 "раскрытая неканоническая цель не названа в отказе"
  [ "$(tip_of "$B3")" = "$before11" ] || die_cell г11 "чужой bare продвинулся — обмен исполнился"
  ok_cell г11

  # г12 критик 045-Б3: pushurl на чужой bare при каноничных обеих формах url —
  # фактическая цель push = pushurl.
  before12="$(tip_of "$B3")"
  ( cd "$REPO9" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push ) >"$WORK/o12" 2>"$WORK/e12"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e12"; } \
    || die_cell г12 "rc=$rc, pushurl-цель push обязана отказать F1: $(tail -n 2 "$WORK/e12" | tr '\n' ' ')"
  grep -qF -- "$B3" "$WORK/e12" || die_cell г12 "pushurl-цель не названа в отказе"
  [ "$(tip_of "$B3")" = "$before12" ] || die_cell г12 "pushurl-получатель продвинулся — обмен исполнился"
  ok_cell г12

  # г13 адверсарий 045-v1: именованный remote evil при каноническом origin —
  # фактическая цель push по git-семантике; до фикса обход жив (rc0 + ref в
  # чужой bare), после — F1R с названной раскрытой целью.
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push evil HEAD:refs/heads/named-push ) >"$WORK/o13" 2>"$WORK/e13"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1R" "$WORK/e13"; } \
    || die_cell г13 "rc=$rc, именованный remote обязан судиться F1R (адверсарий 045-v1: живой обход push evil): $(tail -n 2 "$WORK/e13" | tr '\n' ' ')"
  grep -qF -- "$B4" "$WORK/e13" || die_cell г13 "фактическая цель (раскрытый url remote evil) не названа в отказе"
  [ -z "$(git -C "$B4" for-each-ref --format='%(refname)' refs/heads/named-push)" ] \
    || die_cell г13 "чужая bare продвинулась (named-push) — обмен исполнился"
  ok_cell г13

  # г14 адверсарий 045-v1: fetch по именованному remote — чужой SHA не должен
  # попасть в FETCH_HEAD жертвы.
  rm -f "$REPO10/.git/FETCH_HEAD"
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" fetch evil main ) >"$WORK/o14" 2>"$WORK/e14"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1R" "$WORK/e14"; } \
    || die_cell г14 "rc=$rc, fetch по именованному remote обязан отказать F1R: $(tail -n 2 "$WORK/e14" | tr '\n' ' ')"
  if [ -e "$REPO10/.git/FETCH_HEAD" ] && grep -qF "$(tip_of "$B4" main)" "$REPO10/.git/FETCH_HEAD"; then
    die_cell г14 "FETCH_HEAD содержит чужой SHA — обмен исполнился"
  fi
  ok_cell г14

  # г15 адверсарий 045-v1: pull по именованному remote — HEAD жертвы не
  # сдвигается на чужой tip (до фикса — чистый fast-forward на SHA B4/main).
  before15="$(tip_of "$REPO10")"
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" pull evil main ) >"$WORK/o15" 2>"$WORK/e15"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1R" "$WORK/e15"; } \
    || die_cell г15 "rc=$rc, pull по именованному remote обязан отказать F1R: $(tail -n 2 "$WORK/e15" | tr '\n' ' ')"
  [ "$(tip_of "$REPO10")" = "$before15" ] || die_cell г15 "HEAD жертвы сместился — pull исполнился"
  ok_cell г15

  # г16 адверсарий 045-v1: SCP-форма явной цели — адаптер обслуживает
  # настоящий receive-pack чужой bare (сеть не нужна); явный target →
  # классическая F1 (та же ветка, что г5/г12).
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" GIT_SSH_COMMAND="$SSHAD" "$SUBJ" push git@example.test:any/path HEAD:refs/heads/scp-push ) >"$WORK/o16" 2>"$WORK/e16"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e16"; } \
    || die_cell г16 "rc=$rc, SCP-форма явной цели обязана отказать F1: $(tail -n 2 "$WORK/e16" | tr '\n' ' ')"
  [ -z "$(git -C "$B4" for-each-ref --format='%(refname)' refs/heads/scp-push)" ] \
    || die_cell г16 "SCP-получатель продвинулся — обмен исполнился"
  ok_cell г16

  # ── г17-г17з: опция --repo как repository-аргумент (вердикт адверсария
  # 045-v3, ЖИВОЙ обход). git-push(1): «--repo=<repository> — This option is
  # equivalent to the <repository> argument. If both are specified, the
  # command-line argument takes precedence». Замерено живьём (git 2.55):
  # «push --force --repo=evil --all» реально двигает refs/heads/main ЧУЖОГО
  # bare, а обёртка до фикса пропускает `--repo=…` как безобидный `-*`-флаг
  # и судит НЕ ту цель (настроенный origin). Каждая клетка доказывает отказ
  # ДВУМЯ мерами: rc + неподвижность чужого получателя (rc сам по себе
  # обхода не опровергает — урок А-259).

  # г17 equals-форма, значение = bare-имя настроенного remote → И-4б по ЭТОМУ
  # имени (не по origin) → F1R.
  before17="$(tip_of "$B4")"
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push --force --repo=evil --all ) >"$WORK/o17" 2>"$WORK/e17"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1R" "$WORK/e17"; } \
    || die_cell г17 "rc=$rc, --repo=<имя> есть repository-аргумент и обязан судиться (живой обход адверсария 045-v3): $(tail -n 2 "$WORK/e17" | tr '\n' ' ')"
  grep -qF -- "$B4" "$WORK/e17" || die_cell г17 "раскрытая цель --repo=evil не названа в отказе"
  [ "$(tip_of "$B4")" = "$before17" ] || die_cell г17 "чужой bare продвинулся — обмен исполнился"
  ok_cell г17

  # г17б та же атака раздельной формой.
  before17b="$(tip_of "$B4")"
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push --force --repo evil --all ) >"$WORK/o17b" 2>"$WORK/e17b"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1R" "$WORK/e17b"; } \
    || die_cell г17б "rc=$rc, раздельная форма --repo обязана судиться так же, как equals: $(tail -n 2 "$WORK/e17b" | tr '\n' ' ')"
  [ "$(tip_of "$B4")" = "$before17b" ] || die_cell г17б "чужой bare продвинулся — обмен исполнился"
  ok_cell г17б

  # г17в equals-форма, значение = ПУТЬ (не имя настроенного remote): классификация
  # значения обязана быть полной, а не только bare-именем.
  before17v="$(tip_of "$B4")"
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push --force "--repo=$B4" --all ) >"$WORK/o17v" 2>"$WORK/e17v"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e17v"; } \
    || die_cell г17в "rc=$rc, --repo=<путь> обязан судиться как явная цель: $(tail -n 2 "$WORK/e17v" | tr '\n' ' ')"
  grep -qF -- "$B4" "$WORK/e17v" || die_cell г17в "цель-путь не названа в отказе"
  [ "$(tip_of "$B4")" = "$before17v" ] || die_cell г17в "чужой bare продвинулся — обмен исполнился"
  ok_cell г17в

  # г17г equals-форма, значение SCP-формы: адаптер обслуживает настоящий
  # receive-pack чужой bare (сеть не нужна — приём адверсария, как г16).
  before17g="$(tip_of "$B4")"
  ( cd "$REPO10" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" GIT_SSH_COMMAND="$SSHAD" "$SUBJ" push --force --repo=git@example.test:any/path --all ) >"$WORK/o17g" 2>"$WORK/e17g"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e17g"; } \
    || die_cell г17г "rc=$rc, --repo=<scp> обязан судиться как явная цель: $(tail -n 2 "$WORK/e17g" | tr '\n' ' ')"
  grep -qF -- 'git@example.test:any/path' "$WORK/e17g" || die_cell г17г "SCP-цель не названа в отказе"
  [ "$(tip_of "$B4")" = "$before17g" ] || die_cell г17г "чужой bare продвинулся — обмен исполнился"
  ok_cell г17г

  # г17д положительный контроль equals-формы: канонический origin обязан
  # проходить. Гард, отказывающий на САМОЙ опции, ломает законный обмен —
  # это не «безопаснее», это неработающий предмет.
  ( cd "$R1" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push --repo=origin ) >"$WORK/o17d" 2>"$WORK/e17d"
  rc=$?
  [ "$rc" -eq 0 ] \
    || die_cell г17д "rc=$rc, --repo=origin при КАНОНИЧЕСКОМ origin обязан пройти: $(tail -n 2 "$WORK/e17d" | tr '\n' ' ')"
  if grep -qF 'gitw ОТКАЗ' "$WORK/e17d"; then die_cell г17д "отказ на канонической цели (над-блокировка опции)"; fi
  ok_cell г17д

  # г17е тот же положительный контроль раздельной формой.
  ( cd "$R1" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push --repo origin ) >"$WORK/o17e" 2>"$WORK/e17e"
  rc=$?
  [ "$rc" -eq 0 ] \
    || die_cell г17е "rc=$rc, --repo origin при КАНОНИЧЕСКОМ origin обязан пройти: $(tail -n 2 "$WORK/e17e" | tr '\n' ' ')"
  if grep -qF 'gitw ОТКАЗ' "$WORK/e17e"; then die_cell г17е "отказ на канонической цели (над-блокировка опции)"; fi
  ok_cell г17е

  # г17ж приоритет позиционной цели над equals-формой: настоящий git уходит в
  # ПОЗИЦИОННЫЙ чужой bare, канонический --repo=origin его НЕ отмывает.
  before17zh="$(tip_of "$B3")"
  ( cd "$R1" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push --repo=origin "$B3" main ) >"$WORK/o17zh" 2>"$WORK/e17zh"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e17zh"; } \
    || die_cell г17ж "rc=$rc, позиционная цель сильнее --repo (git-push(1)) и обязана судиться: $(tail -n 2 "$WORK/e17zh" | tr '\n' ' ')"
  grep -qF -- "$B3" "$WORK/e17zh" || die_cell г17ж "позиционная цель не названа в отказе"
  [ "$(tip_of "$B3")" = "$before17zh" ] || die_cell г17ж "позиционный получатель продвинулся — обмен исполнился"
  ok_cell г17ж

  # г17з то же раздельной формой: значение опции обязано ВЫЙТИ из позиционного
  # скана, а скан — продолжиться до настоящей позиционной цели.
  before17z="$(tip_of "$B3")"
  ( cd "$R1" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" "$SUBJ" push --repo origin "$B3" main ) >"$WORK/o17z" 2>"$WORK/e17z"
  rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e17z"; } \
    || die_cell г17з "rc=$rc, значение раздельной формы не есть позиционная цель — скан обязан идти дальше: $(tail -n 2 "$WORK/e17z" | tr '\n' ' ')"
  grep -qF -- "$B3" "$WORK/e17z" || die_cell г17з "позиционная цель не названа в отказе"
  [ "$(tip_of "$B3")" = "$before17z" ] || die_cell г17з "позиционный получатель продвинулся — обмен исполнился"
  ok_cell г17з

  # г18 первый позиционный токен с двоеточием ПОСЛЕ слэша. Клетка различает
  # ТРИ исхода: зависание (цикл разбора без прогресса), обмен в путь-цель
  # (токен пропущен, судится origin) и честный отказ.
  before18="$(tip_of "$SLASHCOLON")"
  ( cd "$REPO11" && GIT_EXCHANGE_GUARD_CANONICAL="$CANON_B1" timeout 10 "$SUBJ" push 'dir/sub:branch' main ) >"$WORK/o18" 2>"$WORK/e18"
  rc=$?
  [ "$rc" -ne 124 ] \
    || die_cell г18 "обёртка ЗАВИСЛА (timeout): цикл разбора не гарантирует прогресс на токене «dir/sub:branch»"
  { [ "$rc" -eq 1 ] && grep -qF "$F1P" "$WORK/e18"; } \
    || die_cell г18 "rc=$rc, первый позиционный токен ЕСТЬ repository-аргумент git и обязан судиться: $(tail -n 2 "$WORK/e18" | tr '\n' ' ')"
  grep -qF -- 'dir/sub:branch' "$WORK/e18" || die_cell г18 "путь-цель не названа в отказе"
  [ "$(tip_of "$SLASHCOLON")" = "$before18" ] \
    || die_cell г18 "вложенный bare продвинулся — обмен исполнился в путь-цель"
  ok_cell г18
}

# ── диспетчер режимов ─────────────────────────────────────────────────────────
if [ "$INNER" -eq 1 ]; then
  run_honest_cells
  exit 0
fi

run_stub_pack
run_honest_cells
printf 'gitw: батарея зелёная (клетки г0-г18 + 20 стабов на своих клетках)\n'
exit 0
