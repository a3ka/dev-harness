#!/usr/bin/env bash
# spec-preflight 036 — авторский гейт спек-точности ДО заморозки.
#
# Зеркало doc-preflight 027 (механика та же), предмет иной: контракт (или план)
# проходит ТРИ ВЕТВИ — иначе rc 1 с ИМЕНОВАННОЙ причиной. Ветви не зависят друг от
# друга: В1 (причина-предмета) судит пробы, В2 (замер-грамматика) судит census-числа,
# В3 (перенос зоны + СПАСЕНО) судит сужение ЗОНА-путей против истории. Каждая ветвь —
# независимый барьер; красная проба останавливает дальнейшие ветви ПРЕДЁТ НИХ.
#
# Контракт API (пин 036):
#   вход: $1 = <корень-дерева>, $2 = <отн-путь-контракта>;
#   предмет читает <корень>/<отн-путь-контракта>;
#   пробы и замеры ищутся по ВСЕМУ файлу контракта (канон 008), не по секциям;
#   - строка `- `<cmd>``  — проба В1: rc≠0 с суффиксом «→ красная: <фраза>» ОБЯЗАНА
#     нести фразу в stdout+stderr; rc 0 — пропуск (ре-фриз видит зелёное); rc≠0 без
#     суффикса — отказ; файл пробы не существует — отказ; зависшая проба (60 с) — отказ;
#   - строка «замер: `<cmd>` = N census <glob>» — замер В2: глоб литерально в cmd;
#     cmd исполняется → последняя строка M1 целое; cmd не целое — отказ; rc≠0 — отказ;
#     гейт САМ пересчитывает глоб от корня → M2; M1≠N ИЛИ M2≠N — отказ (две независимые
#     меры: команда и собственное раскрытие, AGENTS правило 4);
#   - строки `ЗОНА <роль>: <путь>…` и `СПАСЕНО <автор>: <40-hex>… — <причина>` — В3:
#     ЗОНА черновика сверяется с UNION ЗОНА замороженных версий того же контракта
#     (теги `refs/tags/frozen/contracts/<NNN>/<v>`); выпадение пути (та же роль)
#     требует СПАСЕНО-покрытия КАЖДОГО коммита автора по пути в окне
#     `frozen/contracts/<NNN>/1..HEAD` (или done-тег); СПАСЕНО вне грамматики —
#     отказ; формально валидная СПАСЕНО, чьи хеши не касаются выпавших путей — отказ;
#   нет замороженных версий → В3 vacuous (зелёная);
#   коды: 0 — все три ветви зелёные, последняя строка «OK» (канон 008);
#         1 — ветвь провалена, именованная причина первой красной пробы/замера/СДАН;
#         2 — нечем проверить (нет git, нет контракта, нет NNN в имени).
#
#   bash scripts/check_spec_ready.sh <корень> <контракт>
#
# Класс-гейт заморозки (контракт 036 §Freeze): freeze_contract.sh вызывает этот
# скрипт ПОСЛЕ вердикта критика И ДО doc-preflight/капа/тега. Красный rc 1 — отказ
# атомарен: тег/реестр не тронуты.
#
# Коды возврата: 0 — зелёный (печатает «OK» последней строкой), 1 — ветвь провалена
# с именованной причиной, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"

ROOT="${1:?использование: $0 <корень> <отн-путь-контракта>}"
CONTRACT_PATH="${2:?использование: $0 <корень> <отн-путь-контракта>}"

ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корня нет: %s\n' "$ROOT" >&2; exit 2; }
[ -f "$ROOT/$CONTRACT_PATH" ] || { printf 'NOT_IMPLEMENTED: контракт не найден: %s/%s\n' "$ROOT" "$CONTRACT_PATH" >&2; exit 2; }

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

# ── Скретч трассы В4-2/В4-3 (арбитраж 036d1f1 — критерий «командная позиция
# в изолированной трассе»): живой вызов барьера доказывается ИСПОЛНЕНИЕМ, не
# текстом. Второй прогон пробы идёт под `env PS4='+ ' SHELLOPTS=xtrace
# BASH_XTRACEFD=9`, где fd 9 открыт ГЕЙТОМ в файл этого каталога: трасса
# наследуется каждым вложенным bash (замер 3 вердикта) и физически отделена
# от stdout/stderr пробы — проба владеет своими потоками, но не каналом
# трассы (класс 030). Критерий зачёта — КОМАНДНАЯ ПОЗИЦИЯ литерала барьера
# (_v4_trace_has_live_call ниже): мёртвый код после exit, присвоение,
# литерал-данные и печать литерала в собственный stderr зачёта не дают.
mkdir -p "$ROOT/tmp" 2>/dev/null || true
_V4_TRACE_DIR="$(mktemp -d "$ROOT/tmp/spec_ready_trace.XXXXXX" 2>/dev/null || true)"
[ -n "$_V4_TRACE_DIR" ] && trap 'rm -rf "$_V4_TRACE_DIR"' EXIT

# NNN — три цифры в начале basename контракта; иначе грамматика freeze не пустит.
base="$(basename "$CONTRACT_PATH")"
NNN="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$NNN" ] || { printf 'NOT_IMPLEMENTED: имя контракта вне грамматики NNN-<slug>.md: %s\n' "$base" >&2; exit 2; }

DRAFT_FULL="$(cat "$ROOT/$CONTRACT_PATH")"
DRAFT_BODY="$(awk '/^## Приёмочный критерий/{f=1;next} f&&/^## /{exit} f' "$ROOT/$CONTRACT_PATH")"
[ -n "$DRAFT_BODY" ] || DRAFT_BODY="$DRAFT_FULL"  # нет секции приёмки — весь файл (В1 fail-open по скоупу)

# ── Раннее чтение ЗОНА-строк черновика (нужно уже В1: В4-2 обязан знать семью
# пробы и не судить семью, чей барьер ЭТИМ ЖЕ черновиком заявлен к правке —
# см. В4-1 ниже). Полный разбор В3 (перенос+СПАСЕНО) остаётся на своём месте;
# этот проход даёт ТОЛЬКО _draft_role_paths/_draft_role_declared.
declare -A _draft_role_paths=()
declare -A _draft_role_declared=()
while IFS= read -r _v4_zline; do
  case "$_v4_zline" in
    "ЗОНА "*":"*)
      _v4_zrole="$(printf '%s' "$_v4_zline" | sed -nE 's/^ЗОНА ([^:[:space:]]+):[[:space:]]*(.*)$/\1/p')"
      _v4_zrest="$(printf '%s' "$_v4_zline" | sed -nE 's/^ЗОНА [^:[:space:]]+:[[:space:]]*(.*)$/\1/p')"
      [ -n "$_v4_zrole" ] || continue
      _draft_role_declared["$_v4_zrole"]=1
      if [ -n "$_v4_zrest" ]; then
        _v4_zprev="${_draft_role_paths[$_v4_zrole]:-}"
        for _v4_zp in $_v4_zrest; do
          case " $_v4_zprev " in *" $_v4_zp "*) ;; *) _v4_zprev="$_v4_zprev $_v4_zp" ;; esac
        done
        _draft_role_paths["$_v4_zrole"]="${_v4_zprev# }"
      else
        _draft_role_paths["$_v4_zrole"]="${_draft_role_paths[$_v4_zrole]:-}"
      fi
      ;;
  esac
done <<<"$DRAFT_FULL"

# ── В4. ARGV-СОВМЕСТИМОСТЬ (Н-113): оракул грамматики барьера — сам барьер
# (живой вызов), не парсинг прозы (правило 8). Семья <key> = каталог
# fixtures/check_<key>/…; её барьер — scripts/check_<key>.sh. Два литерала
# грамматического отказа диспетчера — из ЕДИНОГО места (не дублируются по
# фикстурам): «ОТКАЗ диспетчер» (неизвестная ветвь), «использование:» (argv
# arity/спецификация $0). Семья, чей барьер ЭТИМ ЖЕ черновиком заявлен к
# правке — не судится молча гейтом: именованная пометка, В4 для неё решает
# критик (барьер — движущаяся цель на момент драфта).
_V4_GRAMMAR_REJECT_1='ОТКАЗ диспетчер'
_V4_GRAMMAR_REJECT_2='использование:'
_v4_is_grammar_reject() {
  printf '%s' "$1" | grep -Fq -- "$_V4_GRAMMAR_REJECT_1" && return 0
  printf '%s' "$1" | grep -Fq -- "$_V4_GRAMMAR_REJECT_2" && return 0
  return 1
}

# В4-2/В4-3-оракул «командная позиция в изолированной трассе» (арбитраж 036d1f1,
# принятый критерий; 8e6ec26 — та же мера различения; Дополнения 1-3 — d941883).
# Трасса второго прогона пишется в гейт-приватный fd (BASH_XTRACEFD), stdout/stderr
# пробы в неё НЕ попадают вовсе. Зачёт: строка трассы, где после PS4-префикса,
# NAME=value-слов и ЦЕПОЧКИ обёрток белого списка (bash sh dash zsh ksh env timeout
# command exec — Дополнение 2: exec прозрачен, следующее слово исполняется) первым
# КОМАНДНЫМ словом стоит литерал scripts/check_<семья>.sh. В цепочке обёрток
# пропускаются ТОЛЬКО NAME=value-присваивания и голые числа/длительности (60, 30s —
# timeout); ЛЮБОЕ слово с дефисом-префиксом (-…) ДИСКВАЛИФИЦИРУЕТ строку целиком —
# ДО рассмотрения его операнда (Дополнение 3: command -v X / bash -n X / env -u X
# кладут литерал в позицию ОПЕРАНДА запроса, не командную). Совпадение командного
# слова (Дополнение 1): относительный литерал — точное равенство; абсолютный путь
# (честная конвенция $REPO/… через переменную) — readlink -f слова равен readlink -f
# канонического барьера корня; суффикс-совпадение отвергнуто замером 6 (shadow-копия
# evil/scripts/check_<key>.sh ложно засчитана). Исполненное присвоение (литерал
# после «=») и литерал-данные (аргумент «:»/echo/иной команды) командной позиции
# не занимают. Остаточный риск (модель угроз d2ffb8e, страховка — критик):
# умышленная запись пробой в унаследованный fd трассы и функция с именем-путём
# барьера дают ложный зачёт; экзотические формы вызова (PATH-подмена, ./литерал,
# честные флаги обёрток вроде env -i / timeout -k / bash -x) и занятость/закрытие
# fd пробой — отказ, fail-closed (Дополнение 3: честная экзотика с флагами не
# засчитывается, проба переписывается).
_v4_trace_has_live_call() {  # <файл-трассы> <семья> → rc 0: ≥1 живой вызов барьера
  local _v4_tf="$1" _v4_fam="$2" _v4_canon _v4_hits _v4_hit
  [ -s "$_v4_tf" ] || return 1
  _v4_canon="$(readlink -f -- "$ROOT/scripts/check_${_v4_fam}.sh" 2>/dev/null)"
  [ -n "$_v4_canon" ] || return 1
  _v4_hits="$(awk -v lit="scripts/check_${_v4_fam}.sh" '
    BEGIN {
      _nw = split("bash sh dash zsh ksh env timeout command exec", _w, " ")
      for (_i = 1; _i <= _nw; _i++) wrap[_w[_i]] = 1
    }
    /^\++ / {
      _line = substr($0, index($0, " ") + 1)          # срезать PS4-префикс «^\++ »
      _m = split(_line, _w, " ")
      _i = 1
      while (_i <= _m && _w[_i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/) _i++   # NAME=value-префикс
      while (_i <= _m && (_w[_i] in wrap)) {           # цепочка обёрток (Дополнение 2)
        _i++
        while (_i <= _m && (_w[_i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/ ||    # env-присваивания
                            _w[_i] ~ /^[0-9]+([smhd])?$/)) _i++       # число/длительность timeout
      }
      if (_i > _m) next                                # строка кончилась обёрткой
      if (_w[_i] == lit) { print "LIVE"; exit }        # относительный литерал
      if (index(_w[_i], "/") == 1) print _w[_i]        # абсолютный кандидат (Дополнение 1)
    }
  ' "$_v4_tf")"
  while IFS= read -r _v4_hit; do
    [ -n "$_v4_hit" ] || continue
    [ "$_v4_hit" = "LIVE" ] && return 0
    [ "$(readlink -f -- "$_v4_hit" 2>/dev/null || true)" = "$_v4_canon" ] && return 0
  done <<EOF
$_v4_hits
EOF
  return 1
}
_v4_family_of_path() {  # <относительный путь> → печатает <key>, если путь лежит
                        # в fixtures/check_<key>/…; иначе rc1 без вывода.
  case "$1" in
    fixtures/check_*/*)
      local _v4_rest="${1#fixtures/check_}"
      printf '%s' "${_v4_rest%%/*}"
      return 0
      ;;
  esac
  return 1
}
_V4_FAMILY_EXCEPTIONS=''  # известные исключения В4-1 (семья без scripts/check_<key>.sh
                          # по замыслу) — пусто: сейчас каждая check_<key>-фикстура
                          # имеет барьер; новое исключение называется здесь явно.
_v4_all_draft_paths=''
for _v4_r in "${!_draft_role_paths[@]}"; do
  _v4_all_draft_paths="$_v4_all_draft_paths ${_draft_role_paths[$_v4_r]}"
done
declare -A _v4_families_seen=()
declare -A _v4_family_in_edit=()
for _v4_r in "${!_draft_role_paths[@]}"; do
  for _v4_p in ${_draft_role_paths[$_v4_r]}; do
    _v4_key="$(_v4_family_of_path "$_v4_p" 2>/dev/null)" || continue
    [ -n "$_v4_key" ] || continue
    _v4_families_seen["$_v4_key"]=1
    case " $_v4_all_draft_paths " in
      *" scripts/check_${_v4_key}.sh "*) _v4_family_in_edit["$_v4_key"]=1 ;;
    esac
  done
done
declare -A _v4_family_green_probe_seen=()

# ── В1. ПРОБЫ: каждая строка «- `<cmd>`» ──────────────────────────────────────
# Грамматика: префикс «- `», команда в бэктиках до закрывающего бэктика; опциональный
# суффикс «→ красная: <фраза>» — фраза извлекается срезом после «→ красная: ».
# Извлечение файла пробы: первый токен если это интерпретатор (bash/sh/zsh/dash/ksh),
# иначе сам первый токен — канон 008.
while IFS= read -r line; do
  [ -n "$line" ] || continue
  case "$line" in
    '- `'*) ;;  # проба
    *) continue ;;
  esac
  back="$(printf '%s' "$line" | sed -nE 's/^- `([^`]*)`.*$/\1/p')"
  [ -n "$back" ] || continue
  suffix="$(printf '%s' "$line" | sed -nE 's/^- `[^`]+`[[:space:]]*→[[:space:]]*красная:[[:space:]]*(.+)$/\1/p')"
  interp="$(printf '%s' "$back" | awk '{print $1}')"
  case "$interp" in
    bash|sh|zsh|dash|ksh|ash)
      probe_path="$(printf '%s' "$back" | awk '{print $2}')"
      ;;
    *)
      probe_path="$interp"
      ;;
  esac
  if [ -n "${probe_path:-}" ] && [ ! -e "$ROOT/$probe_path" ]; then
    printf 'спек-гейт 036: проба не исполняема: %s не существует\n' "$probe_path"
    exit 1
  fi
  out="$(cd "$ROOT" && timeout 60 bash -c "$back" 2>&1)"; rc=$?
  if [ "$rc" -eq 124 ]; then
    printf 'спек-гейт 036: проба превысила таймаут\n'
    exit 1
  fi
  # В4-2. Argv-совместимость: проба живёт в fixtures/check_<key>/… и её код
  # зовёт СВОЮ семью — живой вызов доказывается ВТОРЫМ прогоном той же пробы
  # под ИЗОЛИРОВАННОЙ трассой исполнения (арбитраж 036d1f1, критерий «командная
  # позиция»; мера различения 8e6ec26 исполнена): SHELLOPTS=xtrace
  # BASH_XTRACEFD=9, fd 9 открыт гейтом в файл-трассу — stdout/stderr пробы в
  # трассу НЕ пишутся вовсе (8e6ec26: потоки пробы — текст, которым проба
  # владеет; класс 030). Зачёт — только командная позиция литерала
  # scripts/check_<key>.sh (см. _v4_trace_has_live_call): исполненное
  # присвоение, литерал-данные и печать литерала в stderr зачёта не дают,
  # мёртвый код после exit в трассу не попадает. Грамматический отказ барьера
  # в выводе ПЕРВОГО прогона ($out/$rc, без -x) — несовместимость, НЕЗАВИСИМО
  # от заявленной автором причины (закрывает А2-дыру, правило 8). Проба,
  # закрывшая/занявшая fd 9 — отказ канала, fail-closed (036d1f1).
  if [ -n "${probe_path:-}" ]; then
    _v4_fam="$(_v4_family_of_path "$probe_path" 2>/dev/null)" || _v4_fam=""
    if [ -n "$_v4_fam" ] && [ -z "${_v4_family_in_edit[$_v4_fam]:-}" ] \
       && [ -e "$ROOT/scripts/check_${_v4_fam}.sh" ] \
       && [ -f "$ROOT/$probe_path" ] && [ -n "$_V4_TRACE_DIR" ]; then
      _v4_trace="$(mktemp "$_V4_TRACE_DIR/v4.XXXXXX" 2>/dev/null || true)"
      if [ -n "$_v4_trace" ]; then
        ( cd "$ROOT" && timeout 60 env PS4='+ ' SHELLOPTS=xtrace BASH_XTRACEFD=9 \
            bash -c "$back" ) 9>"$_v4_trace" >/dev/null 2>/dev/null || true
      fi
      if [ -n "$_v4_trace" ] \
         && _v4_trace_has_live_call "$_v4_trace" "$_v4_fam"; then
        if _v4_is_grammar_reject "$out"; then
          printf 'спек-гейт 036: проба несовместима с грамматикой барьера семьи %s (argv-совместимость): %s\n' "$_v4_fam" "$probe_path"
          exit 1
        fi
        _v4_family_green_probe_seen["$_v4_fam"]=1
      fi
    fi
  fi
  if [ "$rc" -eq 0 ]; then
    continue
  fi
  if [ -z "$suffix" ]; then
    printf 'спек-гейт 036: проба красна без заявленной причины\n'
    exit 1
  fi
  if ! printf '%s\n' "$out" | grep -Fq -- "$suffix"; then
    printf 'спек-гейт 036: проба красна не по предмету: вывод не несёт заявленной причины\n'
    exit 1
  fi
done < <(printf '%s\n' "$DRAFT_BODY" | grep -E '^- `' || true)

# ── В4-1/В4-3. Каталог семей + живой зелёный контроль (Н-113) ────────────────
# В4-1: каждая fixtures/check_<key>/…, упомянутая в ЗОНА-строках черновика,
# обязана иметь scripts/check_<key>.sh — иначе именованный отказ «семья без
# барьера» (закрывает вторую половину 031-v3-класса: «check_no_leak — НЕ
# БАРЬЕР, scope_select неизвестный ключ»). В4-3: семья, куда заявлен хотя бы
# один case-путь (в т.ч. будущий), обязана нести ≥1 живую пробу вызова своего
# барьера, грамматически совместимую (В4-2) — иначе автор никогда не
# столкнул argv своего case с реальной грамматикой барьера ДО заморозки.
for _v4_key in "${!_v4_families_seen[@]}"; do
  if [ -n "${_v4_family_in_edit[$_v4_key]:-}" ]; then
    printf 'спек-гейт 036: В4 — семья %s в правке этим же черновиком — В4 для неё судит критик\n' "$_v4_key" >&2
    continue
  fi
  _v4_barrier_rel="scripts/check_${_v4_key}.sh"
  _v4_known=0
  for _v4_ex in $_V4_FAMILY_EXCEPTIONS; do [ "$_v4_ex" = "$_v4_key" ] && _v4_known=1; done
  if [ "$_v4_known" -eq 0 ] && [ ! -e "$ROOT/$_v4_barrier_rel" ]; then
    printf 'спек-гейт 036: семья без барьера: %s не существует (семья %s)\n' "$_v4_barrier_rel" "$_v4_key"
    exit 1
  fi
  if [ -e "$ROOT/$_v4_barrier_rel" ] && [ -z "${_v4_family_green_probe_seen[$_v4_key]:-}" ]; then
    printf 'спек-гейт 036: зелёный контроль семьи не предъявлен: %s — ни одна проба приёмки не вызвала %s грамматически совместимо\n' "$_v4_key" "$_v4_barrier_rel"
    exit 1
  fi
done

# Физический (canonical) резолв элемента census-раскрытия против канонического
# корня — арбитраж 036 корень А: лексика (`..`, ведущий `/`) не ловит symlink,
# который РАЗРЕШАЕТСЯ за пределы дерева-кандидата (`a -> ../outside`, глоб
# `a/*.txt` лексически чист сам по себе). $ROOT уже канонизирован `pwd -P`
# (строка 53); `readlink -f` даёт каноническую форму КАЖДОГО элемента
# раскрытия; префикс-сверка судит физический выход, а не лексику.
# Внутрикорневые symlink'и легальны: запрещается не переход по ссылке, а
# физический выход РАЗРЕШЁННОГО объекта за канонический корень.
#
# Исполняется в СВОЁМ subshell (вызов через `$(...)`) — `cd` внутри функции не
# влияет на текущий шелл гейта. Печатает `OK <N>` (успех, N — размер
# раскрытия, как и было) или `OUT <элемент>` (первый элемент, физически
# ушедший за корень); caller судит по префиксу вывода, а не по коду возврата.
_census_expand_resolved() {
  local root="$1" glob="$2"
  local -a files
  local f rp
  cd "$root" || { printf 'OUT %s\n' "$glob"; return; }
  shopt -s nullglob
  files=( $glob )
  for f in "${files[@]}"; do
    rp="$(readlink -f -- "$f")"
    case "$rp" in
      "$root"|"$root"/*) ;;
      *)
        printf 'OUT %s\n' "$f"
        return
        ;;
    esac
  done
  printf 'OK %s\n' "${#files[@]}"
}

# ── В2. ЗАМЕРЫ: строки «замер: `<cmd>` = N census <glob>» ───────────────────
# Грамматика: `замер: ` префикс, N = ^[0-9]+$, <glob> — одиночный токен без пробелов.
# Две меры (правило 4 AGENTS): команда даёт M1 (последняя строка stdout, целое);
# ГЕЙТ САМ раскрывает glob от корня → M2, ДО и ПОСЛЕ исполнения M1 (fix 036-k2 В3:
# снимок дерева до возможной мутации кандидатом самой замер-командой).
while IFS= read -r line; do
  [ -n "$line" ] || continue
  case "$line" in
    "замер: "*" census "*) ;;
    "замер: "*) ;;
    *) continue ;;
  esac
  if ! printf '%s' "$line" | grep -qE '^замер: `[^`]+` = [0-9]+ census [^ ]+$'; then
    printf 'спек-гейт 036: замер не по грамматике: нет census-глоба\n'
    exit 1
  fi
  cmd="$(printf '%s' "$line" | sed -nE 's/^замер: `([^`]+)` = [0-9]+ census ([^ ]+)$/\1/p')"
  n="$(printf '%s' "$line" | sed -nE 's/^замер: `[^`]+` = ([0-9]+) census ([^ ]+)$/\1/p')"
  glob="$(printf '%s' "$line" | sed -nE 's/^замер: `[^`]+` = [0-9]+ census ([^ ]+)$/\1/p')"
  # Грамматика path-glob ДО любого исполнения (В2-обход: контрактный токен —
  # исполняемый shell-код, если попадёт в bash -c без разбора). Только буквы,
  # цифры и [._/*?-]; любой иной символ ($, (, ), {, }, ;, |, &, <, >, \, ', ", пробел…)
  # — именованный отказ ДО того, как cmd вообще запущена. LC_ALL=C — классификация
  # символа НЕ зависит от локали (fix 036-k2 доп.: `LANG=en_US.UTF-8` пропускал
  # `prøbes/*.sh` как «ASCII», потому что `[A-Za-z]` в UTF-8-локали цепляет и
  # composed-буквы вроде `ø`; в C-локали тот же класс строго байтовый).
  if ! printf '%s' "$glob" | LC_ALL=C grep -qE '^[A-Za-z0-9._/*?-]+$'; then
    printf 'спек-гейт 036: census-глоб вне грамматики path-glob\n'
    exit 1
  fi
  # Сегментная проверка path-glob (fix 036-k2 В2): ASCII-класс сам по себе
  # допускает `../` — census уходит за корень-кандидат (k2: `../outside/*.txt`).
  # Глоб ОБЯЗАН быть ОТНОСИТЕЛЬНЫМ путём внутри корня: ведущий `/` и любой
  # сегмент `..` — именованный отказ ДО любого исполнения/раскрытия.
  case "$glob" in
    /*)
      printf 'спек-гейт 036: census-глоб вне грамматики path-glob (выход из корня)\n'
      exit 1
      ;;
  esac
  _glob_segments=()
  IFS='/' read -ra _glob_segments <<< "$glob"
  for _glob_seg in "${_glob_segments[@]}"; do
    if [ "$_glob_seg" = '..' ]; then
      printf 'спек-гейт 036: census-глоб вне грамматики path-glob (выход из корня)\n'
      exit 1
    fi
  done
  if ! printf '%s' "$cmd" | grep -Fq -- "$glob"; then
    printf 'спек-гейт 036: замер не по грамматике: census-глоб не входит в команду\n'
    exit 1
  fi
  # (а) M2_pre — независимый пересчёт ДО исполнения M1 (fix 036-k2 В3: снимок
  # дерева до возможной мутации кандидатом; иначе `touch fabricated.txt; ...`
  # подделал бы М2, создав ровно тот файл, который потом сам же и посчитан).
  # Каждый элемент раскрытия физически резолвится (readlink -f) против
  # канонического $ROOT ДО исполнения M1 (арбитраж 036 корень А: лексика
  # (`..`, ведущий `/`) не ловит symlink, физически выходящий за дерево-кандидат).
  _resolved="$(_census_expand_resolved "$ROOT" "$glob")"
  case "$_resolved" in
    "OK "*) M2_pre="${_resolved#OK }" ;;
    "OUT "*)
      printf 'спек-гейт 036: census вне корня: %s разрешается вне дерева-кандидата\n' "${_resolved#OUT }"
      exit 1
      ;;
    *)
      printf 'спек-гейт 036: замер не исполнен: раскрытие census не удалось\n'
      exit 1
      ;;
  esac
  # (б) исполнить M1 (команда предмета).
  out="$(cd "$ROOT" && timeout 60 bash -c "$cmd" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    printf 'спек-гейт 036: замер не исполнен: rc %s\n' "$rc"
    exit 1
  fi
  M1="$(printf '%s\n' "$out" | sed -e '/^$/d' | tail -n 1)"
  if ! [[ "$M1" =~ ^[0-9]+$ ]]; then
    printf 'спек-гейт 036: замер не читается: вывод не целое\n'
    exit 1
  fi
  # (в) M2_post — независимый пересчёт ПОСЛЕ исполнения M1, БЕЗ построения
  # новой bash -c строки: $glob раскрывается обычным parameter expansion
  # текущего интерпретатора (word-splitting + pathname expansion), а не как
  # исходный текст нового скрипта — command substitution в значении переменной
  # здесь не переисполняется. Тот же physical-resolve применяется симметрично
  # (арбитраж 036 корень А: отказ ловится на ОБОИХ раскрытиях гейта).
  _resolved="$(_census_expand_resolved "$ROOT" "$glob")"
  case "$_resolved" in
    "OK "*) M2_post="${_resolved#OK }" ;;
    "OUT "*)
      printf 'спек-гейт 036: census вне корня: %s разрешается вне дерева-кандидата\n' "${_resolved#OUT }"
      exit 1
      ;;
    *)
      printf 'спек-гейт 036: замер не исполнен: раскрытие census не удалось\n'
      exit 1
      ;;
  esac
  # (г) M1 == M2_pre == M2_post == N. Расхождение M2_pre/M2_post — дерево
  # изменено самой замер-командой (k2 В3) — судится РАНЬШЕ сравнения с N:
  # иначе подделанный M2_post мог бы случайно совпасть с N и обход остался бы
  # скрыт за честным на вид «замер расходится».
  if [ "$M2_pre" -ne "$M2_post" ]; then
    printf 'спек-гейт 036: дерево изменено замер-командой\n'
    exit 1
  fi
  if [ "$M1" -ne "$n" ]; then
    printf 'спек-гейт 036: замер расходится: заявлено %s, команда даёт %s\n' "$n" "$M1"
    exit 1
  fi
  if [ "$M2_pre" -ne "$n" ]; then
    printf 'спек-гейт 036: замер расходится: заявлено %s, дерево даёт %s\n' "$n" "$M2_pre"
    exit 1
  fi
done < <(printf '%s\n' "$DRAFT_FULL" | grep '^замер: ' || true)

# ── В3. ПЕРЕНОС ЗОНЫ + СПАСЕНО ────────────────────────────────────────────────
# Реестр заморозок проверяется ДО чтения тегов — иначе тег-обманка прошла бы как
# «не найдено», и красный крот прятался в инфраструктуре. Состояние реестра
# называется одной строкой (канон 011).
state="$(registry_state "$ROOT" 'frozen/')"
case "$state" in
  full|shallow|missing-remote|unknown-remote) ;;
  *)
    printf 'спек-гейт 036: реестр заморозок не читается: %s\n' "$state"
    exit 1
    ;;
esac

vmax=0
declare -A _frozen_v_ref=()
while IFS= read -r ref; do
  vn="$(printf '%s' "$ref" | sed -nE 's@.*/([0-9]+)$@\1@p')"
  [ -n "$vn" ] || continue
  _frozen_v_ref["$vn"]="$ref"
  [ "$vn" -gt "$vmax" ] && vmax="$vn"
done < <(g for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/$NNN/" 2>/dev/null || true)

# Ветвь пуста (vacuous green), если замороженных версий нет — нет union, нет выпадений.
[ "$vmax" -eq 0 ] && { printf 'OK\n'; exit 0; }

# Окно контракта: frozen/contracts/<NNN>/1..HEAD (или done-тег, если есть).
if g rev-parse --verify --quiet "refs/tags/done/contracts/$NNN/1" >/dev/null 2>&1; then
  c_until="refs/tags/done/contracts/$NNN/1"
else
  c_until="HEAD"
fi
c_since="refs/tags/frozen/contracts/$NNN/1"

# Чтение ЗОНА-строк из замороженных версий (union по ролям).
declare -A _union_role_paths=()  # role -> "p1 p2 …"
for v in $(printf '%s\n' "${!_frozen_v_ref[@]}" | sort -n); do
  ref="${_frozen_v_ref[$v]}"
  body="$(g cat-file -p "${ref}^{commit}:$CONTRACT_PATH" 2>/dev/null || true)"
  [ -n "$body" ] || continue
  while IFS= read -r zline; do
    case "$zline" in
      "ЗОНА "*":"*)
        role="$(printf '%s' "$zline" | sed -nE 's/^ЗОНА ([^:[:space:]]+):[[:space:]]*(.*)$/\1/p')"
        rest="$(printf '%s' "$zline" | sed -nE 's/^ЗОНА [^:[:space:]]+:[[:space:]]*(.*)$/\1/p')"
        [ -n "$role" ] && [ -n "$rest" ] || continue
        prev="${_union_role_paths[$role]:-}"
        for p in $rest; do
          case " $prev " in *" $p "*) ;; *) prev="$prev $p" ;; esac
        done
        _union_role_paths["$role"]="${prev# }"
        ;;
    esac
  done <<<"$body"
done

# Выпавшие пути.
declare -A _dropped_role_path=()
for role in "${!_union_role_paths[@]}"; do
  draft_paths=" ${_draft_role_paths[$role]:-} "
  union_paths="${_union_role_paths[$role]}"
  for p in $union_paths; do
    case "$draft_paths" in
      *" $p "*) ;;
      *) _dropped_role_path["$role/$p"]=1 ;;
    esac
  done
done

# СПАСЕНО-строки черновика: парсинг, валидация грамматики 003-v3.
declare -A _spaseno_role_hashes=()
while IFS= read -r sline; do
  case "$sline" in
    "СПАСЕНО "*|"СПАСЕНО:"*)
      full_line="$sline"
      rest="${sline#СПАСЕНО }"
      s_author="${rest%%:*}"
      s_tail="${rest#*:}"
      if [ "$s_author" = "$rest" ] || [ -z "${s_author//[[:space:]]/}" ] || [[ "$s_author" == *$'\t'* ]]; then
        printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"
        exit 1
      fi
      if [ -z "${_draft_role_declared[$s_author]:-}" ]; then
        printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"
        exit 1
      fi
      case "$s_tail" in
        *"—"*)
          s_hashes="${s_tail%%—*}"
          s_reason="${s_tail#*—}"
          ;;
        *)
          printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"
          exit 1
          ;;
      esac
      if [ -z "${s_reason//[[:space:]]/}" ]; then
        printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"
        exit 1
      fi
      valid_hashes=""
      for h in $s_hashes; do
        case "$h" in
          *'"'*) printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"; exit 1 ;;
        esac
        if ! [[ "$h" =~ ^[0-9a-f]{40}$ ]]; then
          printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"
          exit 1
        fi
        if ! g cat-file -e "${h}^{commit}" 2>/dev/null; then
          printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"
          exit 1
        fi
        if ! g merge-base --is-ancestor "$c_since" "$h" 2>/dev/null \
          || ! g merge-base --is-ancestor "$h" "$c_until" 2>/dev/null; then
          printf 'спек-гейт 036: СПАСЕНО не по грамматике: %s\n' "$full_line"
          exit 1
        fi
        valid_hashes="$valid_hashes $h"
      done
      prev="${_spaseno_role_hashes[$s_author]:-}"
      _spaseno_role_hashes["$s_author"]="$prev $valid_hashes"
      ;;
  esac
done <<<"$DRAFT_FULL"

# (а) Все коммиты автора по выпавшему пути в окне должны быть покрыты СПАСЕНО.
# Контракт сам по себе меняет зону: коммит, ПЕРЕПИСЫВАЮЩИЙ ЗОНА-строку в
# contracts/<NNN>-*.md, "трогает" каждый путь, который в этой ЗОНА-строке
# исчезает (выпадает) — это и есть В3-перенос, и СПАСЕНО-покрытие требуется
# именно потому, что коммит меняет ЗОНА-декларацию, а не файл по этому пути
# (файла может и не быть: 036 закрывает v4-класс 75f5ffe/v4 «молча выкинул
# покрытие трёх коммитов»). diff-tree по двум путям — путь И файл контракта —
# расширяет фильтр до всех коммитов, КОСНУВШИХСЯ выпадения (прямо или через
# изменение зоны в контракте). Пустое множество = ЗОНА выпала без СПАСЕНО
# сохранения, именованный отказ (стаб с3 «зоны-только-синтаксис» здесь мёртв).
#
# Автор — ТОЧНОЕ равенство %an роли, не `git log --author` (regex/подстрока):
# `--author` подхватил бы `implementer-evil` под роль `implementer`, и чужой
# коммит был бы принят как «покрытый», хотя роль другая (В3-обход).
#
# NUL-сериализация (fix 036-k2 В1): git допускает табуляцию в user.name,
# поэтому TSV-строка `%H%x09%an`, читаемая awk-полем `-F'\t'`, резалась бы
# ровно этой табуляцией — `implementer<TAB>evil` проходил бы как `implementer`.
# `-z` + `%x00` разделяют И записи, И поля НОЛЕМ: NUL не встречается ни в SHA,
# ни в имени автора, байты имени не теряются; `mapfile -d ''` читает пары без
# участия awk/tab. Сравнение автора — ТОЧНОЕ `$_an_name == $role`.
for key in "${!_dropped_role_path[@]}"; do
  role="${key%%/*}"
  path="${key#*/}"
  mapfile -d '' -t _an_fields < <(g log -z --pretty=format:'%H%x00%an' "$c_since..$c_until" -- "$path" "$CONTRACT_PATH" 2>/dev/null)
  commits=""
  _an_i=0
  while [ "$_an_i" -lt "${#_an_fields[@]}" ]; do
    _an_sha="${_an_fields[$_an_i]}"
    _an_name="${_an_fields[$((_an_i+1))]}"
    # Имя автора с табуляцией — вне грамматики (паритет с lib_zones:
    # tab_in_author), именованный отказ ДО сравнения с ролью — тихое
    # несовпадение спрятало бы обход, а не назвало его.
    case "$_an_name" in
      *$'\t'*)
        printf 'спек-гейт 036: имя автора вне грамматики (табуляция)\n'
        exit 1
        ;;
    esac
    [ "$_an_name" = "$role" ] && commits="$commits $_an_sha"
    _an_i=$((_an_i+2))
  done
  commits="${commits# }"
  if [ -z "$commits" ]; then
    max_tag="frozen/contracts/$NNN/$vmax"
    for v in $(printf '%s\n' "${!_frozen_v_ref[@]}" | sort -rn); do
      ref="${_frozen_v_ref[$v]}"
      body="$(g cat-file -p "${ref}^{commit}:$CONTRACT_PATH" 2>/dev/null || true)"
      if [ -n "$body" ] && printf '%s\n' "$body" | grep -qE "^ЗОНА ${role}:.*[[:space:]]${path}([[:space:]]|$)"; then
        max_tag="frozen/contracts/$NNN/$v"
        break
      fi
    done
    printf 'спек-гейт 036: перенос зоны: %s (%s): нет коммитов автора, закрепляющих покрытие СПАСЕНО (замороженный %s)\n' \
      "$path" "$role" "$max_tag"
    exit 1
  fi
  role_hashes=" ${_spaseno_role_hashes[$role]:-} "
  for sha in $commits; do
    case "$role_hashes" in
      *" $sha "*) ;;
      *)
        max_tag="frozen/contracts/$NNN/$vmax"
        for v in $(printf '%s\n' "${!_frozen_v_ref[@]}" | sort -rn); do
          ref="${_frozen_v_ref[$v]}"
          body="$(g cat-file -p "${ref}^{commit}:$CONTRACT_PATH" 2>/dev/null || true)"
          if [ -n "$body" ] && printf '%s\n' "$body" | grep -qE "^ЗОНА ${role}:.*[[:space:]]${path}([[:space:]]|$)"; then
            max_tag="frozen/contracts/$NNN/$v"
            break
          fi
        done
        printf 'спек-гейт 036: перенос зоны: %s (%s): коммит %s не покрыт СПАСЕНО (замороженный %s)\n' \
          "$path" "$role" "$sha" "$max_tag"
        exit 1
        ;;
    esac
  done
done

# (б) Каждая формально валидная СПАСЕНО должна быть ПРИВЯЗАНА хотя бы к одному
# выпавшему пути своей роли.
for role in "${!_spaseno_role_hashes[@]}"; do
  role_hashes="${_spaseno_role_hashes[$role]}"
  [ -n "$role_hashes" ] || continue
  tied=0
  for h in $role_hashes; do
    for key in "${!_dropped_role_path[@]}"; do
      d_role="${key%%/*}"
      d_path="${key#*/}"
      if [ "$d_role" = "$role" ]; then
        if g log -1 --pretty=format:'%H' "$h" -- "$d_path" 2>/dev/null | grep -q "^${h}\$"; then
          tied=1
          break 2
        fi
      fi
    done
  done
  if [ "$tied" -eq 0 ]; then
    s_line="$(printf '%s\n' "$DRAFT_FULL" | grep "^СПАСЕНО ${role}: " | head -1)"
    printf 'спек-гейт 036: СПАСЕНО не привязан к выпавшему пути: %s\n' "$s_line"
    exit 1
  fi
done

printf 'OK\n'
exit 0
