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

# NNN — три цифры в начале basename контракта; иначе грамматика freeze не пустит.
base="$(basename "$CONTRACT_PATH")"
NNN="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$NNN" ] || { printf 'NOT_IMPLEMENTED: имя контракта вне грамматики NNN-<slug>.md: %s\n' "$base" >&2; exit 2; }

DRAFT_FULL="$(cat "$ROOT/$CONTRACT_PATH")"
DRAFT_BODY="$(awk '/^## Приёмочный критерий/{f=1;next} f&&/^## /{exit} f' "$ROOT/$CONTRACT_PATH")"
[ -n "$DRAFT_BODY" ] || DRAFT_BODY="$DRAFT_FULL"  # нет секции приёмки — весь файл (В1 fail-open по скоупу)

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

# Чтение ЗОНА-строк черновика (рабочее дерево).
declare -A _draft_role_paths=()
declare -A _draft_role_declared=()
while IFS= read -r zline; do
  case "$zline" in
    "ЗОНА "*":"*)
      role="$(printf '%s' "$zline" | sed -nE 's/^ЗОНА ([^:[:space:]]+):[[:space:]]*(.*)$/\1/p')"
      rest="$(printf '%s' "$zline" | sed -nE 's/^ЗОНА [^:[:space:]]+:[[:space:]]*(.*)$/\1/p')"
      [ -n "$role" ] || continue
      _draft_role_declared["$role"]=1
      if [ -n "$rest" ]; then
        prev="${_draft_role_paths[$role]:-}"
        for p in $rest; do
          case " $prev " in *" $p "*) ;; *) prev="$prev $p" ;; esac
        done
        _draft_role_paths["$role"]="${prev# }"
      else
        _draft_role_paths["$role"]="${_draft_role_paths[$role]:-}"
      fi
      ;;
  esac
done <<<"$DRAFT_FULL"

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
