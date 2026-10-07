#!/usr/bin/env bash
# КРАСНОЕ 084 — «реестр плана: registry/plan.tsv — единственный источник порядка».
#
# ДОГОВОР — контракт 084 §Инварианты (И-1…И-9, И-11) и §Приёмка: клетки к0, р1–р12, и1–и4,
# е1, з1–з2, т1–т2, б1–б8, с1–с9, ф1–ф10, д1–д3, в1–в2 (54) — дословно по тексту приёмки;
# режим --perenos — живое условие ж6 (И-12: состав коммита переноса против таблицы §Перенос).
# Субъекты: scripts/gen_plan.sh, scripts/check_plan.sh, scripts/track_digest.sh (через
# scripts/lib_plan.sh), scripts/freeze_contract.sh (И-8), .githooks/pre-commit (И-11).
#
# ДЕМАРКАЦИЯ (§Приёмка): конформный вход — toy-репозиторий fixtures/plan_084/_toy.sh по
# И-1/И-2. Значения случайны на прогон (номера 900–979, суффиксы символьных id, разделы,
# проза вне блоков, позиции дефектных строк). Оракул — В ПАМЯТИ батареи из её строк
# (модель W_* каркаса) по грамматике И-3/И-4/И-5/И-8/И-9, НЕ вызовом lib_plan.sh и не
# чтением toy-диска обратно. Валидный контрпример — реализация, зелёная на случайных
# значениях и расходящаяся с инвариантом на конформном входе; вход вне грамматики —
# предмет клеток р*.
#
# СВЕРКА ПРИЧИН (структурно, литерально — норма 037): причина ищется В ОДНОЙ СТРОКЕ вывода
# (stdout ∪ stderr) bash-сравнением с КАВЫЧЕННОЙ фразой (без regex/glob из значения);
# целая причина — суффиксом строки (префикс вида «ОТКАЗ: » допустим), причина с
# продолжением «строка <N>:» — подстрокой с терминатором «:» (N=1 не совпадёт с 12); значение
# одного поля вне алфавита (р3–р5, р10, т2) — суффиксом «строка <N>: <имя столбца строки 1>»;
# строки отказа И-8 — РАВЕНСТВОМ целой строки (текст И-8 дословен).
#
# ПРИВЯЗКА К КОДУ (Н-39 — обманная реализация к тому входу, где её дефект НАБЛЮДАЕМ;
# каждая строка ниже проверена живым мутантом throwaway-эталона: мутант красит СВОЮ клетку):
#   к0  ложный отказ на конформном входе: маркер по подстроке (проза с маркером → «не
#       один»), id только ASCII (кириллица, «.» в id), раздел-заголовок одной формы
#       (уровни #…#### и терминаторы «пробел/./конец строки» перебираются в каждом прогоне);
#   р1  снято поле трека: `read` шести переменных дополняет его пустым → «нет трека» вместо
#       «строка N»; р2 нет уникальности id либо названо ПЕРВОЕ вхождение;
#   р3  этап сверен префиксом/подстрокой («до V-2q»); р4 пара `[0-9]+`; р5 regex алфавита
#       без якоря конца (пробел внутри СИМВОЛЬНОГО id); р6 пустая строка пропущена;
#   р7  заголовок сверен числом полей / без «\r» (три подвхода: перестановка 1↔6,
#       переименование поля, CRLF); р8 пустой план — rc 0; р9 fail-open без файла;
#   р10 байты «|»/«,» в поле источника не запрещены (раздел с ними резолвится по дописанному
#       заголовку документа, группа 3 молчит);
#   р11 «зависит» принимает «n1,»/«,n1» (А-084-1: IFS=',' read -r -a отбрасывает хвостовой
#       пустой элемент; «n1,» → «n1», «,n1» → «n1» — без явной проверки границ строки оба
#       варианта проходят; «id,,id» — пустой элемент в середине, та же ловушка).
#   р12 registry/plan.tsv без завершающего LF (А-084-2: mapfile -t стирает различие; без
#       проверки последнего байта контрпример «нет LF в конце файла» проходит — И-1 требует
#       UTF-8/LF, байт-инвариант).
#   и1  файл источника не проверен; и2 раздел найден regex'ом/префиксом/без «#+ пробел»/
#       в прозе (документ несёт околозаголовки «a.b7», «axb», «##a.b», «Раздел a.b»);
#   и3  `cat-file -e` без `^{commit}` (подвход: sha БЛОБА — объект есть, коммита нет) и
#       «форма = резолв» (подвход: случайный 40-hex); и4 IFS-коллапс пустого поля;
#   е1  номер ищется подстрокой по реестру (цифры номера внутри sha чужой строки);
#   з1  зависимость сверена префиксом («пункт» при «пункт-…») либо судится только первая
#       (дефектная — последней в списке); з2 зависимость сверена regex'ом («X.Y» при «XzY»);
#   т1  хвостовой TAB срезан (`read -a`/rstrip) → «строка N» вместо «нет трека»;
#   т2  трек сверен «не пуст» без алфавита (подвходы «_», «.», кириллица, ведущая цифра, случайный
#       ASCII-знак; «|» — если байт «|» не запрещён отдельно); алфавит через \w/isalpha
#       (кириллица, «_», ведущая цифра); regex трека без якоря конца (кириллица, «_», «.»);
#       алфавит символьного id вместо алфавита трека (кириллица, «.»); запрет-список
#       конкретных знаков вместо разрешающего алфавита (случайный ASCII-знак из 29);
#   б1  пары строкой (10 < 2), внутри пары по id, порядок файла без сортировки, статус
#       лишним столбцом, лишняя строка блока, переписанные байты вне маркеров;
#   б2  статус в блоке ROADMAP только у закрытых/активных (Р1) — на б1 без тегов не виден;
#   б3/б4 запись HANDOFF ДО проверки ROADMAP (sha обоих файлов); б4 «первая пара годится»
#       вместо «не один»; б5 сверка блока счётом строк;
#   б6  фраза ищется только в заголовках либо номер строки 0-based; б7 маркер после trim;
#   б8  запись ROADMAP ДО проверки блока HANDOFF (ROADMAP мира устарел — запись видна по sha);
#   с1  closed-without-done не читается (Z в паре 1 стал бы кандидатом), «заморожен»
#       засчитан закрытым (C2), порядок файла без сортировки (C3 — первая строка файла);
#   с2  k не зависит от |A|; с3 закрытые = только done; с4 блок не в конец;
#   с5  группа (7) не судит; с6 fail-open без блока, BEGIN/END ищутся независимо
#       (подвход: перевёрнутая пара);
#   с7  порядок статусов «done → заморожен → закрыт без done» (X с тегом frozen И строкой
#       закрытия остаётся активным — check молчит); группа (7) судит закрытыми только done;
#   с8  тот же порядок: X в A (k уменьшен), зависимый от X кандидат не допущен;
#   с9  «хотя бы одна зависимость закрыта» (OR) вместо «каждая»; судится только первая или
#       только последняя зависимость (закрытые — по краям списка); символьные зависимости
#       пропущены (C2 «Z,S,D»);
#   ф1  прежний freeze без отказа; отказ ПОСЛЕ мутации (тег/реестр/HEAD/дерево);
#   ф2  вечный отказ; ф3 «только P0»; ф4 P0 по ВСЕМ строкам (пара 1 закрыта done);
#   ф5  план из рабочего дерева; ф6 fail-closed без плана, «наличие по дереву, содержимое
#       по HEAD» (в дереве — НЕотслеживаемый план с 001 вне пар), нет именованной строки;
#   ф7  fail-open на битом HEAD-плане;
#   ф8  closed-without-done.tsv из РАБОЧЕГО дерева (либо объединение HEAD ∪ дерево) — номер
#       пары 1 закрыт незакоммиченной строкой, пары сдвигаются, 001 пропущен;
#   ф9  closed-without-done.tsv из рабочего дерева (либо пересечение HEAD ∩ дерево) — закрытие
#       на HEAD потеряно опустошённым рабочим файлом, ложный отказ;
#   ф10 порядок «done → заморожен → закрыт без done» в расчёте пар freeze (номер с тегом frozen И
#       строкой закрытия на HEAD считается открытым — 001 ложно вне плана);
#   д1  трек сверен префиксом (соседний трек «<T>-…»), «заморожено» сгруппировано по
#       статусу, а не (пара, файл), из H1 сняты ВСЕ «#», пустой раздел без «- нет»
#       (подвход б: соседний трек с пустыми разделами); д2 трек префиксом/regex («.»);
#   д3  порядок «done → заморожен → закрыт без done» (X: «заморожен» вместо «закрыт без done»);
#       порядок «закрыт без done → done» (Y с тегом done И строкой закрытия — не в «done»);
#   в1  --pre-commit не судит ничего (хук без check_plan); хук зовёт check_plan без плана
#       (вторая половина — без плана);
#   в2  --pre-commit игнорирован (первый коммит отказан) либо (7) не судится вовсе (второй
#       коммит прошёл).
#
# Использование: bash fixtures/plan_084/red_plan_084.sh [<корень>]   (обычно — через
# fixtures/_krasnye_084.sh). KEEP084=1 — миры остаются для вскрытия.
#                bash fixtures/plan_084/red_plan_084.sh --perenos [<корень>]   — ж6.
#
# Коды возврата: 0 — все клетки (54) зелёные; 1 — есть красная (включая «предмет
# отсутствует» — предъявляемое красное ДО реализации); 2 — нечем проверить (нет git,
# python3, каркаса заморозки). --perenos: 0 — коммит, первым добавивший registry/plan.tsv,
# сошёлся с таблицей §Перенос и правками И-12; 1 — первое расхождение «перенос: …» (в т. ч.
# такого коммита нет); 2 — нечем проверить (мелкая история, нет таблицы в коммите).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=cells
if [ "${1:-}" = --perenos ]; then MODE=perenos; shift; fi
ROOT="${1:-$(cd "$HERE/../.." && pwd)}"
[ -d "$ROOT" ] || { printf 'NOT_IMPLEMENTED: корня нет: %s\n' "$ROOT" >&2; exit 2; }
ROOT="$(cd "$ROOT" && pwd)"
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
# shellcheck disable=SC1091
. "$HERE/_toy.sh"
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES \
      GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE

# ── ж6 (И-12): коммит, ПЕРВЫМ добавивший registry/plan.tsv, — против таблицы §Перенос контракта
# В ТОМ ЖЕ коммите и против ROADMAP.md его родителя. Отдельная rc-проверка СОСТАВА переноса, не
# check_plan: тот судит грамматику, ссылки и блоки текущего дерева, а не таблицу контракта.
perenos() {  # <корень>
  local r="$1" w c p rc a b s d e f
  git -C "$r" rev-parse --git-dir >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: корень не git-репозиторий: %s\n' "$r" >&2; return 2; }
  [ "$(git -C "$r" rev-parse --is-shallow-repository)" = false ] \
    || { printf 'NOT_IMPLEMENTED: мелкая история — коммит переноса не найти\n' >&2; return 2; }
  c="$(git -C "$r" log --diff-filter=A --format=%H -- registry/plan.tsv | sed -n '$p')"
  [ -n "$c" ] || { printf 'перенос: registry/plan.tsv не добавлен ни одним коммитом истории HEAD\n'; return 1; }
  p="$(git -C "$r" rev-parse --verify -q "$c^1")" \
    || { printf 'перенос: у коммита переноса %s нет родителя\n' "$c"; return 1; }
  w="$(mktemp -d "${TMPDIR:-/tmp}/perenos084.XXXXXX")"
  if ! git -C "$r" show "$c:$P84_CONTRACT" > "$w/contract" 2>/dev/null; then
    printf 'NOT_IMPLEMENTED: в коммите переноса %s нет %s\n' "$c" "$P84_CONTRACT" >&2; rm -rf "$w"; return 2
  fi
  git -C "$r" show "$c:registry/plan.tsv" > "$w/plan"
  git -C "$r" show "$c:registry/contracts.tsv" > "$w/reg" 2>/dev/null || : > "$w/reg"
  git -C "$r" show "$c:ROADMAP.md" > "$w/rm.after" 2>/dev/null || : > "$w/rm.after"
  git -C "$r" show "$p:ROADMAP.md" > "$w/rm.before" 2>/dev/null || : > "$w/rm.before"
  p84_py perenos-table "$w/contract" "$w/plan" "$w/reg" "$P84_HDR" "$P84_PERENOS_H"; rc=$?
  if [ "$rc" -eq 0 ]; then   # план сверен с таблицей — из него модель оракула блока И-4
    p84_world_reset
    while IFS=$'\t' read -r a b s d e f || [ -n "$a" ]; do p84_row "$a" "$b" "$s" "$d" "$e" "$f"; done < <(sed -n '2,$p' "$w/plan")
    o_roadmap_block > "$w/rm.oracle"
    p84_py perenos-roadmap "$w/rm.before" "$w/rm.after" "$w/rm.oracle" "$P84_RM_BEGIN" "$P84_RM_END" \
      "$P84_OLD_ORDER" "$P84_NEW_ORDER" "$P84_S11"; rc=$?
  fi
  [ "$rc" -ne 0 ] || printf 'перенос: коммит %s — строк таблицы §Перенос %d, правки ROADMAP.md по И-12\n' "$c" "${#W_ID[@]}" >&2
  rm -rf "$w"
  return "$rc"
}
if [ "$MODE" = perenos ]; then perenos "$ROOT"; exit $?; fi

CELLS=(к0 р1 р2 р3 р4 р5 р6 р7 р8 р9 р10 р11 р12 и1 и2 и3 и4 е1 з1 з2 т1 т2 б1 б2 б3 б4 б5 б6 б7 б8
       с1 с2 с3 с4 с5 с6 с7 с8 с9 ф1 ф2 ф3 ф4 ф5 ф6 ф7 ф8 ф9 ф10 д1 д2 д3 в1 в2)

MISSING="$(p84_missing_subjects "$ROOT")"
if [ -n "$MISSING" ]; then
  printf 'красная: предмет отсутствует\n'
  printf 'КРАСНОЕ 084: нет %s\n' "$MISSING" >&2
  printf 'КРАСНОЕ 084: %s: НЕ ИСПОЛНЯЛАСЬ (предмет отсутствует)\n' "${CELLS[@]}" >&2
  printf 'ИТОГ 084 (реестр плана): клеток %d, не исполнено %d — предмет отсутствует\n' "${#CELLS[@]}" "${#CELLS[@]}" >&2
  exit 1
fi

FRZ_LIB="$HERE/../freeze_contract/_repo.sh"
[ -f "$FRZ_LIB" ] || { printf 'NOT_IMPLEMENTED: нет каркаса заморозки: %s\n' "$FRZ_LIB" >&2; exit 2; }
# shellcheck disable=SC1090
. "$FRZ_LIB"   # make_repo, commit_all — миры ф* (§Приёмка: «make_repo из fixtures/freeze_contract/_repo.sh»)

GEN="$ROOT/scripts/gen_plan.sh"
CHK="$ROOT/scripts/check_plan.sh"
DIG="$ROOT/scripts/track_digest.sh"
FRZ="$ROOT/scripts/freeze_contract.sh"
HOOK="$ROOT/.githooks/pre-commit"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red084.XXXXXX")"
[ "${KEEP084:-}" = 1 ] || trap 'rm -rf "$WORK"' EXIT

RED=0; GRN=0; REPS=()
declare -A SEEN=()
pass() { SEEN[$1]=$(( ${SEEN[$1]:-0} + 1 )); GRN=$((GRN + 1)); REPS+=("$1: ЗЕЛЁНАЯ"); }
fail() { SEEN[$1]=$(( ${SEEN[$1]:-0} + 1 )); RED=$((RED + 1)); REPS+=("$1: КРАСНАЯ — $2"); }
judge() { if [ -z "$WHY" ]; then pass "$1"; else fail "$1" "$WHY"; fi; }   # <клетка> по $WHY

# run <метка> <команда…> — субъект из «/» (корень передаётся явно), stdin пуст, потоки
# раздельно в $WORK/<метка>.{out,err}; rc → RC (А-346: не $? после функции).
run() {
  local tag="$1"; shift
  ( cd / && timeout 120 "$@" ) </dev/null >"$WORK/$tag.out" 2>"$WORK/$tag.err"
  RC=$?
}
_lines_of() { cat "$WORK/$1.out" "$WORK/$1.err" 2>/dev/null; }
ends() {   # <метка> <фраза> — есть строка вывода, ОКАНЧИВАЮЩАЯСЯ фразой
  local l
  while IFS= read -r l || [ -n "$l" ]; do [[ "$l" == *"$2" ]] && return 0; done < <(_lines_of "$1")
  return 1
}
holds() {  # <метка> <фраза> — есть строка вывода, СОДЕРЖАЩАЯ фразу
  local l
  while IFS= read -r l || [ -n "$l" ]; do [[ "$l" == *"$2"* ]] && return 0; done < <(_lines_of "$1")
  return 1
}
isline() { # <файл> <строка> — есть строка файла, РАВНАЯ строке
  local l
  while IFS= read -r l || [ -n "$l" ]; do [ "$l" = "$2" ] && return 0; done < "$1"
  return 1
}
why() {    # <метка> <rc> — диагностика: rc и первая строка вывода
  local l
  l="$(_lines_of "$1" | sed -n '1p')"
  printf 'rc=%s «%s»' "$2" "$l"
}
refused() {  # <метка> <rc> <фраза> — WHY пуст ⟺ rc 1 и строка, оканчивающаяся фразой
  WHY=''
  if [ "$2" -ne 1 ] || ! ends "$1" "$3"; then WHY="ожидался rc 1 «$3», получено $(why "$1" "$2")"; fi
}
parse_refused() {  # <метка> <rc> <N> — rc 1 «план не разбирается: строка <N>:»
  WHY=''
  if [ "$2" -ne 1 ] || ! holds "$1" "план не разбирается: строка $3:"; then
    WHY="ожидался rc 1 «план не разбирается: строка $3: …», получено $(why "$1" "$2")"
  fi
}
block_eq() {  # <файл> <B> <E> <оракул> — WHY пуст ⟺ маркеры по одному и блок == оракулу
  local f="$1" got="$WORK/block_eq.got"   # скретч — в $WORK, не в судимом дереве
  WHY=''
  if [ "$(p84_py count "$f" "$2")" != 1 ] || [ "$(p84_py count "$f" "$3")" != 1 ]; then
    WHY="маркеры не по одному в ${f##*/}"; return 0
  fi
  if ! p84_py between "$f" "$2" "$3" > "$got"; then WHY="пары маркеров нет в ${f##*/}"; return 0; fi
  if ! cmp -s "$4" "$got"; then
    WHY="блок ${f##*/} ≠ оракулу: $(diff "$4" "$got" | sed -n '2,6p' | paste -sd ';' -)"
  fi
}
clone() { cp -a "$1" "$2"; }   # <мир> <копия> — мир с .git, теги и рабочее дерево как есть
setup_fail() { printf 'NOT_IMPLEMENTED: мир не построен: %s\n' "$1" >&2; exit 2; }

# ════════════════════════════════════════════════════════════════════════════════════════
# Мир к0 (модель W_* каркаса): к0, б1, б2, р1–р12, и1–и4, е1, з1–з2, т1–т2, б3–б8, с6.
# ════════════════════════════════════════════════════════════════════════════════════════
p84_world_main
T0="$WORK/k0"
p84_build "$T0" >/dev/null 2>&1 || setup_fail к0
clone "$T0" "$WORK/base0"                       # нетронутый мир до записи (б3/б4)
o_roadmap_block > "$WORK/k0.rm.oracle"          # оракул И-4 — ДО вызова субъекта
pre_rm="$(p84_py outside "$T0/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END")"
NROW="${#W_ID[@]}"

# к0 (И-1, И-6, И-7): gen --write, затем check — оба rc 0.
run k0gen bash "$GEN" --write --root "$T0"; rc_k0gen=$RC
run k0chk bash "$CHK" --root "$T0"; rc_k0chk=$RC
WHY=''
[ "$rc_k0gen" -eq 0 ] && [ "$rc_k0chk" -eq 0 ] \
  || WHY="gen $(why k0gen "$rc_k0gen"); check $(why k0chk "$rc_k0chk")"
judge к0

# б1 (И-4, И-6): строки между маркерами == оракулу; байты до BEGIN и после END прежние.
if [ "$rc_k0gen" -ne 0 ]; then WHY="gen $(why k0gen "$rc_k0gen")"
else
  block_eq "$T0/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$WORK/k0.rm.oracle"
  if [ -z "$WHY" ] && [ "$(p84_py outside "$T0/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END")" != "$pre_rm" ]; then
    WHY='байты ROADMAP.md до BEGIN/после END изменены'
  fi
fi
judge б1
p84_py between "$T0/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" > "$WORK/b1.block" 2>/dev/null || : > "$WORK/b1.block"

# б2 (И-4): + теги frozen/done и строка closed-without-done для части id → блок == блоку б1.
T="$WORK/b2"; clone "$T0" "$T"
p84_tag "$T" "done/contracts/${W_NUMS[0]}/1" >/dev/null
p84_tag "$T" "frozen/contracts/${W_NUMS[1]}/1" >/dev/null
printf '%s\t%s\n' "${W_NUMS[2]}" 'закрыт словом владельца: б2 — toy' >> "$T/registry/closed-without-done.tsv"
run b2gen bash "$GEN" --write --root "$T"
if [ "$RC" -ne 0 ]; then WHY="gen $(why b2gen "$RC")"
else block_eq "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$WORK/b1.block"; fi
[ -s "$WORK/b1.block" ] || WHY="${WHY:-}${WHY:+; }блока б1 нет — сравнивать не с чем"
judge б2

# р1–р7 (И-1, И-7): к0 с одним дефектом на случайной строке → «план не разбирается: строка <N>».
# р1 снимает ПОСЛЕДНЕЕ поле (трек): `read` шести переменных дополняет его пустым и выдаёт
# «нет трека» — причина расходится с «строка N» при любом значении (снятие из середины
# сдвигало бы поля, и различимость зависела бы от случайной формы значений).
p84_rnd "$NROW"; j=$P84_R
T="$WORK/r1"; clone "$T0" "$T"; p84_emit_plan drop "$j" 5 > "$T/registry/plan.tsv"
run r1 bash "$CHK" --root "$T"; parse_refused r1 "$RC" $((j + 2)); judge р1

p84_rnd "$NROW"; a=$P84_R; p84_rnd $((NROW - 1)); b=$P84_R; [ "$b" -ge "$a" ] && b=$((b + 1))
lo=$(( a < b ? a : b )); hi=$(( a < b ? b : a ))
T="$WORK/r2"; clone "$T0" "$T"; p84_emit_plan set "$hi" 0 "${W_ID[$lo]}" > "$T/registry/plan.tsv"
run r2 bash "$CHK" --root "$T"; parse_refused r2 "$RC" $((hi + 2)); judge р2

p84_rnd "$NROW"; j=$P84_R; p84_pick "$P84_STAGE_A" "$P84_STAGE_B"; p84_sfx 1
T="$WORK/r3"; clone "$T0" "$T"; p84_emit_plan set "$j" 2 "$P84_P$P84_S" > "$T/registry/plan.tsv"
run r3 bash "$CHK" --root "$T"; refused r3 "$RC" "план не разбирается: строка $((j + 2)): этап"; judge р3

p84_rnd "$NROW"; j=$P84_R
T="$WORK/r4"; clone "$T0" "$T"; p84_emit_plan set "$j" 1 0 > "$T/registry/plan.tsv"
run r4 bash "$CHK" --root "$T"; refused r4 "$RC" "план не разбирается: строка $((j + 2)): пара"; judge р4

# р5: пробел внутри СИМВОЛЬНОГО id (случайная строка из символьных, случайная внутренняя
# позиция): regex алфавита без якоря конца принимает префикс «пун» у «пун кт-…»; у номера
# «9 47» тот же дефект ненаблюдаем (три цифры подряд не начинаются).
SYMR=(); for i in "${!W_ID[@]}"; do p84_is_num "${W_ID[$i]}" || SYMR+=("$i"); done
p84_pick "${SYMR[@]}"; j=$P84_P; id="${W_ID[$j]}"; p84_rnd $(( ${#id} - 1 )); k=$((P84_R + 1))
T="$WORK/r5"; clone "$T0" "$T"; p84_emit_plan set "$j" 0 "${id:0:$k} ${id:$k}" > "$T/registry/plan.tsv"
run r5 bash "$CHK" --root "$T"; refused r5 "$RC" "план не разбирается: строка $((j + 2)): id"; judge р5

p84_rnd $((NROW + 1)); p=$((P84_R + 2))
T="$WORK/r6"; clone "$T0" "$T"; p84_emit_plan blank "$p" > "$T/registry/plan.tsv"
run r6 bash "$CHK" --root "$T"; parse_refused r6 "$RC" "$p"; judge р6

# р7: три подвхода заголовка — перестановка полей 1↔6, переименование случайного поля
# (один символ), CRLF; каждый красен своим предъявлением «строка 1».
H=(id пара этап зависит источник трек)
p84_rnd 6; HR=("${H[@]}"); HR[$P84_R]="${HR[$P84_R]}x"
hdrs=("$(p84_join_tab "${H[5]}" "${H[1]}" "${H[2]}" "${H[3]}" "${H[4]}" "${H[0]}")"
      "$(p84_join_tab "${HR[@]}")"
      "$P84_HDR"$'\r')
W7=''
for v in 0 1 2; do
  T="$WORK/r7$v"; clone "$T0" "$T"; p84_emit_plan header "${hdrs[$v]}" > "$T/registry/plan.tsv"
  run "r7$v" bash "$CHK" --root "$T"; parse_refused "r7$v" "$RC" 1
  [ -z "$WHY" ] || W7="${W7}${W7:+; }подвход $v: $WHY"
done
WHY="$W7"; judge р7

# р8: только заголовок → «план пуст»; р9: нет plan.tsv → «план недоступен».
T="$WORK/r8"; clone "$T0" "$T"; p84_emit_plan only-header > "$T/registry/plan.tsv"
run r8 bash "$CHK" --root "$T"; refused r8 "$RC" 'план пуст'; judge р8
T="$WORK/r9"; clone "$T0" "$T"; rm -f "$T/registry/plan.tsv"
run r9 bash "$CHK" --root "$T"; refused r9 "$RC" 'план недоступен: registry/plan.tsv отсутствует'; judge р9

# р10 (И-1, И-7 группа 2): «|» (столбец таблицы блока ROADMAP) и «,» в разделе источника — два
# подвхода; в документе дописан заголовок ровно этого раздела, так что без запрета байтов источник
# РЕЗОЛВИЛСЯ бы (группа 3 молчит) — ожидание «строка <N>: источник».
W10=''
for v in 0 1; do
  p84_rnd "$NROW"; j=$P84_R; p84_sec; p84_sfx 3
  if [ "$v" = 0 ]; then sec="$P84_SEC|$P84_S"; else sec="$P84_SEC,$P84_S"; fi
  T="$WORK/r10$v"; clone "$T0" "$T"; printf '## %s Ловушка: раздел с запрещённым байтом\n' "$sec" >> "$T/$W_DOC1"
  p84_emit_plan set "$j" 4 "$W_DOC1#$sec" > "$T/registry/plan.tsv"
  run "r10$v" bash "$CHK" --root "$T"; refused "r10$v" "$RC" "план не разбирается: строка $((j + 2)): источник"
  [ -z "$WHY" ] || W10="${W10}${W10:+; }подвход $v («$sec»): $WHY"
done
WHY="$W10"; judge р10

# р11 (А-084-1, И-1): «зависит» — строгий список id(,id)* без хвостового/ведущего разделителя,
# без пустых элементов между запятыми. Два подвхода: хвостовая и ведущая запятая в НЕпустом
# списке (на deps из модели — иначе мутация `-,` тривиально валидна). Без явной проверки
# границ оба проходят: «n1,» → «n1» (IFS=',' read -r -a отбрасывает хвостовой пустой),
# «,n1» → «n1». Ожидание «строка <N>: зависит».
DEPR_R11=()
for i in "${!W_ID[@]}"; do [ "${W_DEPS[$i]}" = - ] || DEPR_R11+=("$i"); done
W11=''
for v in 0 1; do
  p84_pick "${DEPR_R11[@]}"; j=$P84_P
  case $v in
    0) val="${W_DEPS[$j]}," ;;  # хвостовая запятая
    1) val=",${W_DEPS[$j]}" ;;  # ведущая запятая
  esac
  T="$WORK/r11$v"; clone "$T0" "$T"; p84_emit_plan set "$j" 3 "$val" > "$T/registry/plan.tsv"
  run "r11$v" bash "$CHK" --root "$T"; refused "r11$v" "$RC" "план не разбирается: строка $((j + 2)): зависит"
  [ -z "$WHY" ] || W11="${W11}${W11:+; }подвход $v («$val»): $WHY"
done
WHY="$W11"; judge р11

# р12 (А-084-2, И-1): registry/plan.tsv без завершающего LF. mapfile -t снимает различие;
# проверка последнего байта ДО него (УЖЕ не LF). Без неё контрпример проходит (И-1 требует
# UTF-8/LF, байт-инвариант). Ожидание «план не разбирается: registry/plan.tsv без завершающего LF».
T="$WORK/r12"; clone "$T0" "$T"
{ head -c -1 "$T/registry/plan.tsv"; } >"$T/registry/plan.tsv.tmp"
mv "$T/registry/plan.tsv.tmp" "$T/registry/plan.tsv"
run r12 bash "$CHK" --root "$T"; refused r12 "$RC" 'план не разбирается: registry/plan.tsv без завершающего LF'
judge р12

# и1–и4 (И-7 группа 3 и 2): источник строки — не резолвится / пуст.
p84_rnd "$NROW"; j=$P84_R; p84_sfx 5; src="docs/owner/нет-такого-$P84_S.md#1.1"
T="$WORK/i1"; clone "$T0" "$T"; p84_emit_plan set "$j" 4 "$src" > "$T/registry/plan.tsv"
run i1 bash "$CHK" --root "$T"; refused i1 "$RC" "источник не резолвится: ${W_ID[$j]}: $src"; judge и1

p84_rnd "$NROW"; j=$P84_R; src="$W_DOC1#$W_MISS_SEC"
T="$WORK/i2"; clone "$T0" "$T"; p84_emit_plan set "$j" 4 "$src" > "$T/registry/plan.tsv"
run i2 bash "$CHK" --root "$T"; refused i2 "$RC" "источник не резолвится: ${W_ID[$j]}: $src"; judge и2

# и3: два подвхода — случайный 40-hex (не объект) и sha БЛОБА toy (объект есть, не коммит).
p84_rnd "$NROW"; j=$P84_R
while :; do p84_hex 40; git -C "$T0" cat-file -e "$P84_H" 2>/dev/null || break; done
i3src=("$P84_H" "$(git -C "$T0" rev-parse HEAD:registry/contracts.tsv)")
W3=''
for v in 0 1; do
  src="${i3src[$v]}"
  T="$WORK/i3$v"; clone "$T0" "$T"; p84_emit_plan set "$j" 4 "$src" > "$T/registry/plan.tsv"
  run "i3$v" bash "$CHK" --root "$T"; refused "i3$v" "$RC" "источник не резолвится: ${W_ID[$j]}: $src"
  [ -z "$WHY" ] || W3="${W3}${W3:+; }подвход $v ($src): $WHY"
done
WHY="$W3"; judge и3

p84_rnd "$NROW"; j=$P84_R
T="$WORK/i4"; clone "$T0" "$T"; p84_emit_plan set "$j" 4 '' > "$T/registry/plan.tsv"
run i4 bash "$CHK" --root "$T"; refused i4 "$RC" "нет источника: ${W_ID[$j]}"; judge и4

# е1 (И-7 группа 4): номера нет в реестре, а sha ДРУГОЙ строки несёт его цифры.
p84_rnd "${#W_NUMS[@]}"; num="${W_NUMS[$P84_R]}"
T="$WORK/e1"; clone "$T0" "$T"; : > "$T/registry/contracts.tsv"; carrier=''
for rid in "${W_REG_ORDER[@]}"; do
  [ "$rid" = "$num" ] && continue
  sha="${W_REG[$rid]}"
  if [ -z "$carrier" ]; then p84_hex 17; h1="$P84_H"; p84_hex 20; sha="$h1$num$P84_H"; carrier="$rid"; fi
  printf '%s → %s\n' "$rid" "$sha" >> "$T/registry/contracts.tsv"
done
run e1 bash "$CHK" --root "$T"; refused e1 "$RC" "номер вне реестра: $num"; judge е1

# з1–з2 (И-1, И-7 группа 5): дефектная зависимость — ПОСЛЕДНЕЙ в непустом списке.
DEPR=(); for i in "${!W_ID[@]}"; do [ "${W_DEPS[$i]}" = - ] || DEPR+=("$i"); done
p84_pick "${DEPR[@]}"; j=$P84_P; dep="${W_S1%%-*}"         # «пункт» — собственный префикс «пункт-…»
T="$WORK/z1"; clone "$T0" "$T"; p84_emit_plan set "$j" 3 "${W_DEPS[$j]},$dep" > "$T/registry/plan.tsv"
run z1 bash "$CHK" --root "$T"; refused z1 "$RC" "зависимость на несуществующий id: ${W_ID[$j]} → $dep"; judge з1
p84_pick "${DEPR[@]}"; j=$P84_P; dep="$W_ZX.$W_ZY"             # «X.Y» при существующем «XzY»
T="$WORK/z2"; clone "$T0" "$T"; p84_emit_plan set "$j" 3 "${W_DEPS[$j]},$dep" > "$T/registry/plan.tsv"
run z2 bash "$CHK" --root "$T"; refused z2 "$RC" "зависимость на несуществующий id: ${W_ID[$j]} → $dep"; judge з2

# т1 (И-7 группа 2): пустое поле трека.
p84_rnd "$NROW"; j=$P84_R
T="$WORK/t1"; clone "$T0" "$T"; p84_emit_plan set "$j" 5 '' > "$T/registry/plan.tsv"
run t1 bash "$CHK" --root "$T"; refused t1 "$RC" "нет трека: ${W_ID[$j]}"; judge т1

# т2 (И-1, И-7 группа 2): непустой трек ВНЕ алфавита [A-Za-z][A-Za-z0-9-]* — шесть подвходов,
# каждый на своей случайной строке и красен СВОИМ предъявлением «строка <N>: трек»: «|» внутри
# (разделитель столбцов таблицы блока ROADMAP), кириллическая буква внутри, «_» внутри, ведущая
# цифра, «.» внутри (алфавит символьного id трек не допускает), случайный печатный ASCII-знак вне
# алфавита внутри (пул — 29 печатных ASCII вне [A-Za-z0-9-] и вне «|», «_», «.» прочих подвходов:
# запрет-список отдельных знаков не пройдёт).
TPOOL=(); for c in $(seq 32 44) 47 $(seq 58 64) $(seq 91 94) 96 123 125 126; do
  TPOOL+=("$(printf "\\$(printf '%03o' "$c")")"); done
[ "${#TPOOL[@]}" -eq 29 ] || setup_fail 'т2 (пул ASCII-знаков не 29)'
WT=''
for v in 0 1 2 3 4 5; do
  p84_rnd "$NROW"; j=$P84_R; tr="${W_TRACK[$j]}"; p84_rnd $(( ${#tr} - 1 )); k=$((P84_R + 1))
  case $v in
    0) val="${tr:0:$k}|${tr:$k}" ;;
    1) p84_pick ж ы э ю я д л; val="${tr:0:$k}$P84_P${tr:$k}" ;;
    2) val="${tr:0:$k}_${tr:$k}" ;;
    3) p84_rnd 10; val="$P84_R$tr" ;;
    4) val="${tr:0:$k}.${tr:$k}" ;;
    5) p84_pick "${TPOOL[@]}"; val="${tr:0:$k}$P84_P${tr:$k}" ;;
  esac
  T="$WORK/t2$v"; clone "$T0" "$T"; p84_emit_plan set "$j" 5 "$val" > "$T/registry/plan.tsv"
  run "t2$v" bash "$CHK" --root "$T"; refused "t2$v" "$RC" "план не разбирается: строка $((j + 2)): трек"
  [ -z "$WHY" ] || WT="${WT}${WT:+; }подвход $v («$val»): $WHY"
done
WHY="$WT"; judge т2

# б3/б4 (И-6, И-7): ROADMAP без маркеров / с двумя парами — gen и check rc 1, файлы нетронуты.
# HANDOFF мира несёт устаревший блок: запись его ДО проверки ROADMAP видна по sha.
for v in 3 4; do
  T="$WORK/b$v"; clone "$WORK/base0" "$T"
  if [ "$v" = 3 ]; then p84_py unmark "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END"; ph='в ROADMAP.md нет блока плана'
  else p84_py addpair "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END"; ph='блок плана в ROADMAP.md не один'; fi
  s_pre="$(p84_py sha "$T/ROADMAP.md") $(p84_py sha "$T/HANDOFF.md")"
  run "b${v}gen" bash "$GEN" --write --root "$T"; rcg=$RC
  run "b${v}chk" bash "$CHK" --root "$T"; rcc=$RC
  s_post="$(p84_py sha "$T/ROADMAP.md") $(p84_py sha "$T/HANDOFF.md")"
  refused "b${v}gen" "$rcg" "$ph"; Wg="$WHY"
  refused "b${v}chk" "$rcc" "$ph"; Wc="$WHY"
  WHY=''
  [ -z "$Wg" ] || WHY="gen: $Wg"
  [ -z "$Wc" ] || WHY="${WHY}${WHY:+; }check: $Wc"
  [ "$s_pre" = "$s_post" ] || WHY="${WHY}${WHY:+; }ROADMAP.md/HANDOFF.md изменены отказом"
  judge "б$v"
done

# б5 (И-7): изменён один байт случайной ячейки блока → «расходится с генерацией».
T="$WORK/b5"; clone "$T0" "$T"
mut="$(p84_py cellbyte "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$RANDOM")" || mut='порча не применена'
run b5 bash "$CHK" --root "$T"; refused b5 "$RC" 'блок ROADMAP расходится с генерацией'
[ -z "$WHY" ] || WHY="$WHY [$mut]"; judge б5

# б6 (И-4, И-7): «Итоговый порядок» внутри прозы случайной строки вне блока → точный номер.
T="$WORK/b6"; clone "$T0" "$T"
txt="$(p84_prose 1 | sed 's/\.$//') $P84_PHRASE $(p84_prose 1)"
L6="$(p84_py insert "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$RANDOM" "$txt")" || L6='?'
run b6 bash "$CHK" --root "$T"; refused b6 "$RC" "«Итоговый порядок» вне блока плана: ROADMAP.md:$L6"; judge б6

# б7 (И-4): к END-маркеру дописан пробел → «нет блока» (маркер — целая строка).
T="$WORK/b7"; clone "$T0" "$T"; p84_py tailspace "$T/ROADMAP.md" "$P84_RM_END"
run b7 bash "$CHK" --root "$T"; refused b7 "$RC" 'в ROADMAP.md нет блока плана'; judge б7

# б8 (И-6): блок ROADMAP допустим и устарел (запись ИЗМЕНИЛА бы его — проверено против оракула
# к0), в HANDOFF две пары маркеров → gen rc 1 «не один», sha256 ОБОИХ файлов прежние.
T="$WORK/b8"; clone "$WORK/base0" "$T"
p84_py between "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" > "$WORK/b8.rm.pre" || setup_fail б8
if cmp -s "$WORK/b8.rm.pre" "$WORK/k0.rm.oracle"; then setup_fail 'б8 (блок ROADMAP уже равен оракулу)'; fi
p84_py addpair "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END"
s_pre="$(p84_py sha "$T/ROADMAP.md") $(p84_py sha "$T/HANDOFF.md")"
run b8 bash "$GEN" --write --root "$T"; refused b8 "$RC" 'блок «Следующая сессия» в HANDOFF.md не один'
[ "$(p84_py sha "$T/ROADMAP.md") $(p84_py sha "$T/HANDOFF.md")" = "$s_pre" ] \
  || WHY="${WHY}${WHY:+; }ROADMAP.md/HANDOFF.md изменены отказом"
judge б8

# с6 (И-7): HANDOFF без блока; подвход — перевёрнутая пара (END выше BEGIN).
W6=''
for v in strip invert; do
  T="$WORK/c6$v"; clone "$T0" "$T"; p84_py "$v" "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END"
  run "c6$v" bash "$CHK" --root "$T"; refused "c6$v" "$RC" 'в HANDOFF.md нет блока «Следующая сессия»'
  [ -z "$WHY" ] || W6="${W6}${W6:+; }$v: $WHY"
done
WHY="$W6"; judge с6

# ════════════════════════════════════════════════════════════════════════════════════════
# Миры выбора «Следующей сессии» (с1–с5, с7–с9).
# ════════════════════════════════════════════════════════════════════════════════════════
# с1: A1 заморожен (пара 1), D done (пара 1), Z закрыт без done (пара 1), C1 номер выдан с
# зависимостью D (пара 2), C2 не начат с зависимостью A1 (пара 2, раньше C1 в файле), C3 не
# начат без зависимостей (пара 3) — ПЕРВОЙ строкой файла.
world_s1() {
  local da sa sb id T2b
  p84_world_reset
  p84_num; S_A1="$P84_N"; p84_num; S_D="$P84_N"; p84_num; S_Z="$P84_N"; p84_num; S_C1="$P84_N"
  p84_sfx 3; S_C2="кандидат-$P84_S"; p84_sfx 3; S_C3="тройка.$P84_S"
  p84_sfx 3; S_T="trek$P84_S"; p84_sfx 3; T2b="Odelix-$P84_S"
  p84_sfx 4; da="docs/owner/2026-10-05-$P84_S.md"; p84_sec; sa="$P84_SEC"; p84_sec; sb="$P84_SEC"
  p84_row "$S_C3" 3 "$P84_STAGE_B" -       '@sha:11'  "$T2b"
  p84_row "$S_A1" 1 "$P84_STAGE_A" -       "$da#$sa"  "$S_T"
  p84_row "$S_C2" 2 "$P84_STAGE_A" "$S_A1" '@sha:8'   "$T2b"
  p84_row "$S_D"  1 "$P84_STAGE_A" -       "$da#$sb"  "$S_T"
  p84_row "$S_C1" 2 "$P84_STAGE_B" "$S_D"  '@sha:40'  "$T2b"
  p84_row "$S_Z"  1 "$P84_STAGE_A" -       '@sha:15'  "$S_T"
  W_FROZEN[$S_A1]=1; W_DONE[$S_D]=1; p84_closed_add "$S_Z" 'закрыт словом владельца: с1 — toy'
  for id in "$S_A1" "$S_D" "$S_Z" "$S_C1"; do p84_reg_add "$id"; p84_h1_add "$id"; done
}
world_s1
TS1="$WORK/s1"; p84_build "$TS1" >/dev/null 2>&1 || setup_fail с1
clone "$TS1" "$WORK/s1base"
o_handoff_block > "$WORK/s1.ho.oracle"
pre_ho="$(p84_py outside "$TS1/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END")"
run s1gen bash "$GEN" --write --root "$TS1"; rc_s1=$RC
if [ "$rc_s1" -ne 0 ]; then WHY="gen $(why s1gen "$rc_s1")"
else
  block_eq "$TS1/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/s1.ho.oracle"
  items="$(p84_py items "$TS1/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null | tr '\n' ' ')"
  # вторая мера: строки блока — ровно A1, C1 (из условия клетки, не из оракула)
  [ "$items" = "$S_A1 $S_C1 " ] || WHY="${WHY}${WHY:+; }строки блока «$items», ожидались «$S_A1 $S_C1»"
  [ "$(p84_py outside "$TS1/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null)" = "$pre_ho" ] \
    || WHY="${WHY}${WHY:+; }байты HANDOFF.md вне маркеров изменены"
fi
judge с1

# с2: два активных и годный кандидат (пара 1, первым в файле) → в блоке ровно два активных.
world_s2() {
  local c1 c2 tr
  p84_world_reset
  p84_num; S2_A1="$P84_N"; p84_num; S2_A2="$P84_N"; p84_num; c2="$P84_N"; p84_sfx 3; c1="годный-$P84_S"
  p84_sfx 3; tr="Tr$P84_S"
  p84_row "$c1"    1 "$P84_STAGE_A" - '@sha:10' "$tr"
  p84_row "$S2_A1" 2 "$P84_STAGE_A" - '@sha:12' "$tr"
  p84_row "$c2"    1 "$P84_STAGE_B" - '@sha:7'  "$tr"
  p84_row "$S2_A2" 1 "$P84_STAGE_A" - '@sha:9'  "$tr"
  W_FROZEN[$S2_A1]=1; W_FROZEN[$S2_A2]=1
  for id in "$S2_A1" "$S2_A2" "$c2"; do p84_reg_add "$id"; p84_h1_add "$id"; done
}
world_s2
T="$WORK/s2"; p84_build "$T" >/dev/null 2>&1 || setup_fail с2
o_handoff_block > "$WORK/s2.ho.oracle"
run s2gen bash "$GEN" --write --root "$T"
if [ "$RC" -ne 0 ]; then WHY="gen $(why s2gen "$RC")"
else
  block_eq "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/s2.ho.oracle"
  items="$(p84_py items "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null | tr '\n' ' ')"
  [ "$items" = "$S2_A2 $S2_A1 " ] || WHY="${WHY}${WHY:+; }строки блока «$items», ожидались ровно активные «$S2_A2 $S2_A1»"
fi
judge с2

# с3: единственный кандидат зависит от Z (закрыт без done) → кандидат в блоке.
world_s3() {
  local x d tr
  p84_world_reset
  p84_num; S3_Z="$P84_N"; p84_num; S3_C="$P84_N"; p84_num; d="$P84_N"; p84_sfx 3; x="после-$P84_S"
  p84_sfx 3; tr="Tz$P84_S"
  p84_row "$x"    2 "$P84_STAGE_A" "$S3_C" '@sha:10' "$tr"
  p84_row "$S3_C" 2 "$P84_STAGE_A" "$S3_Z" '@sha:11' "$tr"
  p84_row "$S3_Z" 1 "$P84_STAGE_A" -       '@sha:12' "$tr"
  p84_row "$d"    1 "$P84_STAGE_B" -       '@sha:13' "$tr"
  W_DONE[$d]=1; p84_closed_add "$S3_Z" 'закрыт без done: решение владельца — с3'
  for id in "$S3_Z" "$S3_C" "$d"; do p84_reg_add "$id"; p84_h1_add "$id"; done
}
world_s3
T="$WORK/s3"; p84_build "$T" >/dev/null 2>&1 || setup_fail с3
o_handoff_block > "$WORK/s3.ho.oracle"
run s3gen bash "$GEN" --write --root "$T"
if [ "$RC" -ne 0 ]; then WHY="gen $(why s3gen "$RC")"
else
  block_eq "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/s3.ho.oracle"
  items="$(p84_py items "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null | tr '\n' ' ')"
  [ "$items" = "$S3_C " ] || WHY="${WHY}${WHY:+; }строки блока «$items», ожидался кандидат «$S3_C»"
fi
judge с3

# с4 (И-6): HANDOFF без маркеров (мир с1 до записи) → прежние байты — префикс, блок == оракулу
# с1 (оракул снят в файл при построении с1 — модель с тех пор сменилась).
T="$WORK/s4"; clone "$WORK/s1base" "$T"
p84_py strip "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END"
cp "$T/HANDOFF.md" "$WORK/s4.ho.before"
run s4gen bash "$GEN" --write --root "$T"
if [ "$RC" -ne 0 ]; then WHY="gen $(why s4gen "$RC")"
else
  block_eq "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/s1.ho.oracle"
  p84_py prefix "$WORK/s4.ho.before" "$T/HANDOFF.md" || WHY="${WHY}${WHY:+; }прежние байты HANDOFF.md — не префикс нового файла"
fi
judge с4

# с5 (И-7): с1 после записи, затем тег done/contracts/<A1>/1 → «done-пункт стоит следующим: <A1>».
p84_tag "$TS1" "done/contracts/$S_A1/1" >/dev/null
run s5 bash "$CHK" --root "$TS1"; refused s5 "$RC" "done-пункт стоит следующим: $S_A1"; judge с5

# с7/с8 (И-2): X с тегом frozen И строкой closed-without-done — статус «закрыт без done» (порядок
# И-2: done → закрыт без done → заморожен; все три живые строки реестра закрытий — 001, 043, 078 —
# несут и frozen-тег). Блоки — по оракулу ДО закрытия (X активен и стоит в HANDOFF), затем строка
# «X⇥причина» дописана в рабочий closed-without-done.tsv.
world_s7() {
  local tr id
  p84_world_reset
  p84_num; S7_X="$P84_N"; p84_num; S7_B="$P84_N"; p84_sfx 3; S7_C="зависимый-$P84_S"; p84_sfx 3; tr="Tx$P84_S"
  p84_row "$S7_B" 2 "$P84_STAGE_A" -       '@sha:10' "$tr"
  p84_row "$S7_X" 1 "$P84_STAGE_A" -       '@sha:11' "$tr"
  p84_row "$S7_C" 2 "$P84_STAGE_B" "$S7_X" '@sha:12' "$tr"
  W_FROZEN[$S7_X]=1
  for id in "$S7_X" "$S7_B"; do p84_reg_add "$id"; p84_h1_add "$id"; done
}
world_s7
T7="$WORK/s7"; p84_build "$T7" >/dev/null 2>&1 || setup_fail с7
o_roadmap_block > "$WORK/s7.rm"; o_handoff_block > "$WORK/s7.ho"
p84_py fill "$T7/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$WORK/s7.rm" || setup_fail с7
p84_py fill "$T7/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/s7.ho" || setup_fail с7
[ "$(p84_py items "$T7/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" | sed -n 1p)" = "$S7_X" ] \
  || setup_fail 'с7 (X не первым в блоке до закрытия)'
p84_closed_add "$S7_X" "закрыт словом владельца без done: с7 — toy $RANDOM"
printf '%s\t%s\n' "$S7_X" "${W_CLOSED[$S7_X]}" >> "$T7/registry/closed-without-done.tsv"
o_handoff_block > "$WORK/s8.ho.oracle"         # оракул после закрытия — ДО вызова субъекта
run s7 bash "$CHK" --root "$T7"; refused s7 "$RC" "done-пункт стоит следующим: $S7_X"; judge с7

run s8gen bash "$GEN" --write --root "$T7"
if [ "$RC" -ne 0 ]; then WHY="gen $(why s8gen "$RC")"
else
  block_eq "$T7/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/s8.ho.oracle"
  items="$(p84_py items "$T7/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null | tr '\n' ' ')"
  [ "$items" = "$S7_B $S7_C " ] || WHY="${WHY}${WHY:+; }строки блока «$items», ожидались «$S7_B $S7_C» (X закрыт без done)"
fi
judge с8

# с9 (И-5): «каждая зависимость закрыта» на СМЕШАННЫХ списках. D done и Z закрыт без done (пара 1);
# C1 «D,N,Z» и C2 «Z,S,D» (пара 2) — открытая зависимость В СЕРЕДИНЕ, закрытые по краям; N номер
# выдан и S не начат (пара 3) без зависимостей. A пусто, k=2 — блок ровно N, S.
world_s9() {
  local tr id
  p84_world_reset
  p84_num; S9_D="$P84_N"; p84_num; S9_Z="$P84_N"; p84_num; S9_N="$P84_N"; p84_num; S9_C2="$P84_N"
  p84_sfx 3; S9_C1="смешанный-$P84_S"; p84_sfx 3; S9_S="открытый.$P84_S"; p84_sfx 3; tr="Mx$P84_S"
  p84_row "$S9_D"  1 "$P84_STAGE_A" -                   '@sha:10' "$tr"
  p84_row "$S9_Z"  1 "$P84_STAGE_A" -                   '@sha:11' "$tr"
  p84_row "$S9_C1" 2 "$P84_STAGE_A" "$S9_D,$S9_N,$S9_Z" '@sha:12' "$tr"
  p84_row "$S9_C2" 2 "$P84_STAGE_B" "$S9_Z,$S9_S,$S9_D" '@sha:13' "$tr"
  p84_row "$S9_N"  3 "$P84_STAGE_B" -                   '@sha:14' "$tr"
  p84_row "$S9_S"  3 "$P84_STAGE_A" -                   '@sha:15' "$tr"
  W_DONE[$S9_D]=1; p84_closed_add "$S9_Z" 'закрыт без done: решение владельца — с9'
  for id in "$S9_D" "$S9_Z" "$S9_N" "$S9_C2"; do p84_reg_add "$id"; p84_h1_add "$id"; done
}
world_s9
T="$WORK/s9"; p84_build "$T" >/dev/null 2>&1 || setup_fail с9
o_handoff_block > "$WORK/s9.ho.oracle"
run s9gen bash "$GEN" --write --root "$T"
if [ "$RC" -ne 0 ]; then WHY="gen $(why s9gen "$RC")"
else
  block_eq "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/s9.ho.oracle"
  items="$(p84_py items "$T/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null | tr '\n' ' ')"
  [ "$items" = "$S9_N $S9_S " ] || WHY="${WHY}${WHY:+; }строки блока «$items», ожидались «$S9_N $S9_S» (смешанные списки — не кандидаты)"
fi
judge с9

# ════════════════════════════════════════════════════════════════════════════════════════
# Дайджест трека (д1–д3).
# ════════════════════════════════════════════════════════════════════════════════════════
world_d() {
  local F D1 N1 Z D2 X1 Y1 S1 S2 X2 T3
  p84_world_reset
  p84_num; F="$P84_N"; p84_num; D1="$P84_N"; p84_num; N1="$P84_N"; p84_num; Z="$P84_N"
  p84_num; D2="$P84_N"; p84_num; X1="$P84_N"; p84_num; Y1="$P84_N"
  p84_sfx 3; S1="пятый-$P84_S"; p84_sfx 3; S2="первый.$P84_S"; p84_sfx 3; X2="чужой-$P84_S"
  p84_sfx 4; D_T="trek$P84_S"; p84_sfx 2; D_T2="$D_T-$P84_S"; p84_sfx 3; T3="Other$P84_S"
  p84_row "$F"  4 "$P84_STAGE_A" -    '@sha:9'  "$D_T"
  p84_row "$D1" 3 "$P84_STAGE_A" -    '@sha:10' "$D_T"
  p84_row "$N1" 2 "$P84_STAGE_B" "$D1" '@sha:11' "$D_T"
  p84_row "$S1" 5 "$P84_STAGE_B" -    '@sha:12' "$D_T"
  p84_row "$Z"  2 "$P84_STAGE_A" -    '@sha:13' "$D_T"
  p84_row "$D2" 1 "$P84_STAGE_A" -    '@sha:14' "$D_T"
  p84_row "$S2" 1 "$P84_STAGE_A" "$D2" '@sha:15' "$D_T"
  p84_row "$X1" 1 "$P84_STAGE_A" -    '@sha:16' "$D_T2"
  p84_row "$X2" 2 "$P84_STAGE_B" -    '@sha:17' "$D_T2"
  p84_row "$Y1" 3 "$P84_STAGE_A" -    '@sha:18' "$T3"
  W_FROZEN[$F]=1; W_FROZEN[$Y1]=1; W_DONE[$D1]=1; W_DONE[$D2]=1; W_DONE[$X1]=1
  p84_closed_add "$Z" "решение владельца: закрыт — без done (toy $P84_S)"
  for id in "$F" "$D1" "$N1" "$Z" "$D2" "$X1" "$Y1"; do p84_reg_add "$id"; done
  for id in "$F" "$D1" "$N1" "$Z" "$X1" "$Y1"; do p84_h1_add "$id"; done   # у D2 файла НЕТ
}
world_d
TD="$WORK/d"; p84_build "$TD" >/dev/null 2>&1 || setup_fail д1
o_digest "$D_T" > "$WORK/d1a.oracle"; o_digest "$D_T2" > "$WORK/d1b.oracle"
W1=''
run d1a bash "$DIG" "$D_T" --root "$TD"
if [ "$RC" -ne 0 ] || ! cmp -s "$WORK/d1a.oracle" "$WORK/d1a.out"; then
  W1="трек $D_T: $(why d1a "$RC") $(diff "$WORK/d1a.oracle" "$WORK/d1a.out" | sed -n '2,5p' | paste -sd ';' -)"
fi
run d1b bash "$DIG" "$D_T2" --root "$TD"
if [ "$RC" -ne 0 ] || ! cmp -s "$WORK/d1b.oracle" "$WORK/d1b.out"; then
  W1="${W1}${W1:+; }трек $D_T2: $(why d1b "$RC") $(diff "$WORK/d1b.oracle" "$WORK/d1b.out" | sed -n '2,5p' | paste -sd ';' -)"
fi
WHY="$W1"; judge д1

W2=''
for q in "${D_T:0:$(( ${#D_T} - 1 ))}" "${D_T:0:1}.${D_T:2}"; do
  run d2 bash "$DIG" "$q" --root "$TD"; refused d2 "$RC" "трек не найден: $q"
  [ -z "$WHY" ] || W2="${W2}${W2:+; }«$q»: $WHY"
done
WHY="$W2"; judge д2

# д3 (И-2, И-9): пересечения источников статуса в одном треке — X: тег frozen И строка закрытия
# (→ «закрыт без done»), Y: теги done и frozen И строка закрытия (→ «done»), F — просто заморожен.
world_d3() {
  local id
  p84_world_reset
  p84_num; D3_X="$P84_N"; p84_num; D3_Y="$P84_N"; p84_num; D3_F="$P84_N"; p84_sfx 4; D3_T="trek$P84_S"
  p84_row "$D3_Y" 2 "$P84_STAGE_A" - '@sha:10' "$D3_T"
  p84_row "$D3_X" 1 "$P84_STAGE_B" - '@sha:11' "$D3_T"
  p84_row "$D3_F" 1 "$P84_STAGE_A" - '@sha:12' "$D3_T"
  W_FROZEN[$D3_X]=1; W_FROZEN[$D3_Y]=1; W_DONE[$D3_Y]=1; W_FROZEN[$D3_F]=1
  p84_closed_add "$D3_X" "закрыт владельцем без done (toy $P84_S)"
  p84_closed_add "$D3_Y" "строка закрытия рядом с done (toy $P84_S)"
  for id in "$D3_X" "$D3_Y" "$D3_F"; do p84_reg_add "$id"; p84_h1_add "$id"; done
}
world_d3
T="$WORK/d3"; p84_build "$T" >/dev/null 2>&1 || setup_fail д3
o_digest "$D3_T" > "$WORK/d3.oracle"
run d3 bash "$DIG" "$D3_T" --root "$T"
WHY=''
if [ "$RC" -ne 0 ] || ! cmp -s "$WORK/d3.oracle" "$WORK/d3.out"; then
  WHY="$(why d3 "$RC") $(diff "$WORK/d3.oracle" "$WORK/d3.out" | sed -n '2,5p' | paste -sd ';' -)"
fi
judge д3

# ════════════════════════════════════════════════════════════════════════════════════════
# Заморозка (ф1–ф10): toy make_repo (fixtures/freeze_contract/_repo.sh) + план, закоммиченный
# на HEAD; done/frozen-теги — локальные refs (статусы — refs репозитория запуска, И-2).
# ════════════════════════════════════════════════════════════════════════════════════════
mkf() {  # <каталог> [без-коммита] — make_repo + plan.tsv (+ closed-without-done.tsv) из модели, done/frozen-теги
  local t="$1" id
  make_repo "$t" >"$WORK/mkf.log" 2>&1 || return 1
  p84_resolve_src "$(git -C "$t" rev-parse HEAD)"
  mkdir -p "$t/registry"
  p84_emit_plan > "$t/registry/plan.tsv"
  [ "${#W_CLOSED_ORDER[@]}" -eq 0 ] || p84_closed_write "$t/registry/closed-without-done.tsv"
  if [ "${2:-}" != без-коммита ]; then commit_all "$t" 'план 084 (toy заморозки)' || return 1; fi
  for id in "${!W_DONE[@]}"; do p84_tag "$t" "done/contracts/$id/1" >/dev/null || return 1; done
  for id in "${!W_FROZEN[@]}"; do p84_tag "$t" "frozen/contracts/$id/1" >/dev/null || return 1; done
}
frz_state() {  # <toy> — HEAD | sha реестра | porcelain | теги 001
  printf '%s|%s|%s|%s' "$(git -C "$1" rev-parse HEAD)" "$(p84_py sha "$1/registry/contracts.tsv")" \
    "$(git -C "$1" status --porcelain | tr '\n' ';')" "$(git -C "$1" tag -l 'frozen/contracts/001/*' | tr '\n' ';')"
}
frz_rows() {  # <пара 001> <пара сим> <пара ном> — три строки: символьная, номер, 001
  local sym num tr
  p84_world_reset
  p84_sfx 3; sym="пункт-$P84_S"; p84_num; num="$P84_N"; p84_sfx 3; tr="Fr$P84_S"
  F_SYM="$sym"; F_NUM="$num"; F_TR="$tr"
  p84_row "$sym" "$2" "$P84_STAGE_A" - '@sha:10' "$tr"
  p84_row "$num" "$3" "$P84_STAGE_B" - '@sha:40' "$tr"
  [ "$1" = - ] || p84_row 001 "$1" "$P84_STAGE_A" - '@sha:7' "$tr"
}
frz_refused() {  # <клетка-метка> <toy> <ожидаемая строка> <состояние-до>
  WHY=''
  [ "$RC" -eq 1 ] || WHY="rc=$RC (ожидался 1)"
  isline "$WORK/$1.err" "$3" || WHY="${WHY}${WHY:+; }нет строки «$3» (stderr: «$(sed -n 1p "$WORK/$1.err")»)"
  [ ! -s "$WORK/$1.out" ] || WHY="${WHY}${WHY:+; }stdout не пуст: «$(sed -n 1p "$WORK/$1.out")»"
  [ "$(frz_state "$2")" = "$4" ] || WHY="${WHY}${WHY:+; }мутация до отказа: было «$4», стало «$(frz_state "$2")»"
}
frz_frozen() {  # <метка> — rc 0, stdout ровно v1
  WHY=''
  if [ "$RC" -ne 0 ] || [ "$(cat "$WORK/$1.out")" != v1 ]; then
    WHY="ожидались rc 0 и stdout v1, получено rc=$RC stdout «$(sed -n 1p "$WORK/$1.out")» stderr «$(grep -m1 'ОТКАЗ' "$WORK/$1.err")»"
  fi
}
REASON="причина фикстуры 084 $RANDOM"

# ф1 (И-3, И-8): открытые строки в парах 1 и 2, 001 — в паре 3 → отказ «вне плана», мутаций нет.
frz_rows 3 1 2; exp="$(o_freeze_refusal 001)"
T="$WORK/f1"; mkf "$T" || setup_fail ф1; st="$(frz_state "$T")"
run f1 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_refused f1 "$T" "$exp" "$st"
[ -z "$(git -C "$T" status --porcelain)" ] || WHY="${WHY}${WHY:+; }git status --porcelain не пуст после отказа"
judge ф1

# ф2/ф3 (И-8): 001 в P0 / в P1 → v1.
frz_rows 1 2 3; T="$WORK/f2"; mkf "$T" || setup_fail ф2
run f2 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_frozen f2; judge ф2
frz_rows 2 1 3; T="$WORK/f3"; mkf "$T" || setup_fail ф3
run f3 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_frozen f3; judge ф3

# ф4 (И-3): все строки пары 1 закрыты тегами done, 001 в паре 3, открытые в 2 и 3 → v1.
frz_rows 3 2 3
p84_num; W_DONE[$P84_N]=1; p84_row "$P84_N" 1 "$P84_STAGE_A" - '@sha:9' "$F_TR"
p84_num; W_DONE[$P84_N]=1; p84_row "$P84_N" 1 "$P84_STAGE_B" - '@sha:8' "$F_TR"
T="$WORK/f4"; mkf "$T" || setup_fail ф4
run f4 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_frozen f4; judge ф4

# ф5 (И-8): HEAD-план без 001; рабочее дерево — с 001 в P0 (не закоммичено) → отказ по HEAD.
frz_rows - 1 2; exp="$(o_freeze_refusal 001)"
T="$WORK/f5"; mkf "$T" || setup_fail ф5
p84_row 001 1 "$P84_STAGE_A" - '@sha:7' "$F_TR"; p84_resolve_src "$(git -C "$T" rev-parse HEAD)"
p84_emit_plan > "$T/registry/plan.tsv"; st="$(frz_state "$T")"
run f5 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_refused f5 "$T" "$exp" "$st"; judge ф5

# ф6 (И-8): на HEAD нет plan.tsv (в дереве — НЕотслеживаемый план с 001 вне пар) → v1 +
# дословная строка пропуска в stderr.
frz_rows 3 1 2; T="$WORK/f6"; mkf "$T" без-коммита || setup_fail ф6
run f6 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_frozen f6
isline "$WORK/f6.err" "$P84_FREEZE_SKIP" || WHY="${WHY}${WHY:+; }нет строки stderr «$P84_FREEZE_SKIP»"
judge ф6

# ф7 (И-8): HEAD-план с 5 полями в строке → rc 1 «ОТКАЗ: план недоступен: …», тега нет.
frz_rows 1 2 3; p84_rnd "${#W_ID[@]}"; j=$P84_R; p84_rnd 6; f=$P84_R
T="$WORK/f7"; make_repo "$T" >"$WORK/mkf.log" 2>&1 || setup_fail ф7
p84_resolve_src "$(git -C "$T" rev-parse HEAD)"; mkdir -p "$T/registry"
p84_emit_plan drop "$j" "$f" > "$T/registry/plan.tsv"; commit_all "$T" 'битый план 084' || setup_fail ф7
st="$(frz_state "$T")"
run f7 bash "$FRZ" contracts/001-x.md "$REASON" "$T"
WHY=''
[ "$RC" -eq 1 ] || WHY="rc=$RC (ожидался 1)"
l7=''; while IFS= read -r l || [ -n "$l" ]; do [[ "$l" == 'ОТКАЗ: план недоступен: '* ]] && l7="$l"; done < "$WORK/f7.err"
[ -n "$l7" ] || WHY="${WHY}${WHY:+; }нет строки «ОТКАЗ: план недоступен: …» (stderr: «$(sed -n 1p "$WORK/f7.err")»)"
[ "$(frz_state "$T")" = "$st" ] || WHY="${WHY}${WHY:+; }мутация до отказа (тег/реестр/HEAD/дерево)"
judge ф7

# ф8 (И-8): closed-without-done.tsv — блоб HEAD. На HEAD номер пары 1 открыт (единственный в паре),
# символьная строка в паре 2, 001 в паре 3; рабочее дерево (не закоммичено) дописывает строку
# закрытия этого номера → отказ по HEAD «(P0 1, P1 2)», мутаций нет.
frz_rows 3 2 1; p84_num; p84_closed_add "$P84_N" 'шум закрытий вне плана — ф8'
exp="$(o_freeze_refusal 001)"
T="$WORK/f8"; mkf "$T" || setup_fail ф8
printf '%s\t%s\n' "$F_NUM" 'закрыт владельцем, не закоммичено — ф8' >> "$T/registry/closed-without-done.tsv"
st="$(frz_state "$T")"
run f8 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_refused f8 "$T" "$exp" "$st"; judge ф8

# ф9 (И-8): та же форма, строка закрытия номера — на HEAD; рабочий closed-without-done.tsv опустошён
# (не закоммичено) → по HEAD номер закрыт, P0 2, P1 3 — 001 в P1, v1.
frz_rows 3 2 1; p84_closed_add "$F_NUM" 'закрыт владельцем — ф9'
o_p0p1; [ "$P84_P0 $P84_P1" = '2 3' ] || setup_fail 'ф9 (модель: P0/P1 не 2/3)'
T="$WORK/f9"; mkf "$T" || setup_fail ф9
: > "$T/registry/closed-without-done.tsv"
run f9 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_frozen f9; judge ф9

# ф10 (И-2, И-8): та же форма, номер пары 1 несёт тег frozen И закоммиченную строку закрытия (как
# живые 001/043/078) — рабочее дерево == HEAD; «закрыт без done» раньше «заморожен» → P0 2, P1 3, v1.
frz_rows 3 2 1; W_FROZEN[$F_NUM]=1; p84_closed_add "$F_NUM" 'заморожен, затем закрыт без done — ф10'
o_p0p1; [ "$P84_P0 $P84_P1" = '2 3' ] || setup_fail 'ф10 (модель: P0/P1 не 2/3)'
T="$WORK/f10"; mkf "$T" || setup_fail ф10
[ -z "$(git -C "$T" status --porcelain)" ] || setup_fail 'ф10 (дерево не чисто)'
run f10 bash "$FRZ" contracts/001-x.md "$REASON" "$T"; frz_frozen f10; judge ф10

# ════════════════════════════════════════════════════════════════════════════════════════
# Хук (в1–в2): toy с core.hooksPath=.githooks — pre-commit и scripts/ СУБЪЕКТА, блоки по
# оракулу; identity — только через -c (общий .git/config чист, нога (д') 080).
# ════════════════════════════════════════════════════════════════════════════════════════
mkh() {  # <каталог> — мир модели + scripts/ и .githooks/pre-commit субъекта, хук включён
  local t="$1"
  p84_build "$t" >/dev/null 2>&1 || return 1
  cp -r "$ROOT/scripts" "$t/scripts" || return 1
  mkdir -p "$t/.githooks"; cp "$HOOK" "$t/.githooks/pre-commit" || return 1; chmod +x "$t/.githooks/pre-commit"
  o_roadmap_block > "$WORK/hk.rm"; o_handoff_block > "$WORK/hk.ho"
  p84_py fill "$t/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$WORK/hk.rm" || return 1
  p84_py fill "$t/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$WORK/hk.ho" || return 1
  p84_commit "$t" 'настройка: scripts/ и pre-commit субъекта, блоки по оракулу' || return 1
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$t" config core.hooksPath .githooks
}
hcommit() {  # <метка> <toy> <сообщение> — коммит С живым хуком; rc → RC
  ( p84_g_hooked "$2" commit -q -m "$3" ) </dev/null >"$WORK/$1.out" 2>&1; RC=$?
  : > "$WORK/$1.err"
}

# в1 (И-11): правка внутри блока ROADMAP → коммит отказан с причиной, HEAD прежний;
# тот же мир без plan.tsv — та же правка проходит.
p84_world_main
T="$WORK/v1"; mkh "$T" || setup_fail в1
clone "$T" "$WORK/v1np"
p84_py cellbyte "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$RANDOM" >/dev/null
p84_g "$T" add ROADMAP.md; h0="$(git -C "$T" rev-parse HEAD)"
hcommit v1 "$T" 'в1: правка внутри блока плана'
WHY=''
{ [ "$RC" -ne 0 ] && ends v1 'блок ROADMAP расходится с генерацией'; } \
  || WHY="с планом: ожидался отказ «блок ROADMAP расходится с генерацией», получено $(why v1 "$RC")"
[ "$(git -C "$T" rev-parse HEAD)" = "$h0" ] || WHY="${WHY}${WHY:+; }HEAD сдвинут отказанным коммитом"
T="$WORK/v1np"; p84_g "$T" rm -q registry/plan.tsv; p84_g "$T" commit -q -m 'настройка: мир без плана'
p84_py cellbyte "$T/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$RANDOM" >/dev/null
p84_g "$T" add ROADMAP.md; h0="$(git -C "$T" rev-parse HEAD)"
hcommit v1np "$T" 'в1: та же правка без плана'
{ [ "$RC" -eq 0 ] && [ "$(git -C "$T" rev-parse HEAD)" != "$h0" ]; } \
  || WHY="${WHY}${WHY:+; }без плана коммит не прошёл: $(why v1np "$RC")"
judge в1

# в2 (И-7, И-11): блок HANDOFF перечисляет id с тегом done; коммит без HANDOFF.md в индексе
# проходит, с ним — отказ «done-пункт стоит следующим: <id>».
p84_world_main; X="${W_NUMS[3]}"; W_FROZEN[$X]=1          # X — активный: строка блока HANDOFF
T="$WORK/v2"; mkh "$T" || setup_fail в2
p84_tag "$T" "done/contracts/$X/1" >/dev/null
p84_sfx 4; printf 'заметка в2 %s\n' "$P84_S" > "$T/заметки-$P84_S.txt"; p84_g "$T" add -A; h0="$(git -C "$T" rev-parse HEAD)"
hcommit v2a "$T" 'в2: коммит без HANDOFF.md'
WHY=''
{ [ "$RC" -eq 0 ] && [ "$(git -C "$T" rev-parse HEAD)" != "$h0" ]; } \
  || WHY="коммит без HANDOFF.md не прошёл: $(why v2a "$RC")"
printf '\nдописано в2: %s\n' "$P84_S" >> "$T/HANDOFF.md"; p84_g "$T" add HANDOFF.md; h1="$(git -C "$T" rev-parse HEAD)"
hcommit v2b "$T" 'в2: коммит с HANDOFF.md'
{ [ "$RC" -ne 0 ] && ends v2b "done-пункт стоит следующим: $X"; } \
  || WHY="${WHY}${WHY:+; }коммит с HANDOFF.md: ожидался отказ «done-пункт стоит следующим: $X», получено $(why v2b "$RC")"
[ "$(git -C "$T" rev-parse HEAD)" = "$h1" ] || WHY="${WHY}${WHY:+; }HEAD сдвинут отказанным коммитом"
judge в2

# ── Итог: каждая клетка списка исполнена РОВНО один раз (пустая выборка — красное) ──────
for c in "${CELLS[@]}"; do
  case "${SEEN[$c]:-0}" in
    1) ;;
    0) fail "$c" 'клетка не исполнена батареей' ;;
    *) fail "$c" "клетка исполнена ${SEEN[$c]} раз(а)" ;;
  esac
done
for r in "${REPS[@]}"; do printf '084 %s\n' "$r" >&2; done
printf 'ИТОГ 084 (реестр плана): клеток %d, красных %d, зелёных %d\n' "${#CELLS[@]}" "$RED" "$GRN" >&2
[ "$RED" -eq 0 ] || exit 1
exit 0
