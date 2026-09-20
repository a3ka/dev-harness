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
#   - строка `замер: `<cmd>` = N census <glob>` — замер В2: глоб литерально в cmd;
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
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: в %s нет ни одного коммита\n' "$ROOT" >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }

# NNN — три цифры в начале basename контракта; иначе грамматика freeze не пустит.
base="$(basename "$CONTRACT_PATH")"
NNN="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$NNN" ] || { printf 'NOT_IMPLEMENTED: имя контракта вне грамматики NNN-<slug>.md: %s\n' "$base" >&2; exit 2; }

DRAFT_BODY="$(cat "$ROOT/$CONTRACT_PATH")"

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

# ── В2. ЗАМЕРЫ: строки «замер: `<cmd>` = N census <glob>» ─────────────────────
# Грамматика: `замер: ` префикс, N = ^[0-9]+$, <glob> — одиночный токен без пробелов.
# Две меры (правило 4 AGENTS): команда даёт M1 (последняя строка stdout, целое);
# ГЕЙТ САМ раскрывает glob от корня → M2.
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
  if ! printf '%s' "$cmd" | grep -Fq -- "$glob"; then
    printf 'спек-гейт 036: замер не по грамматике: census-глоб не входит в команду\n'
    exit 1
  fi
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
  if [ "$M1" -ne "$n" ]; then
    printf 'спек-гейт 036: замер расходится: заявлено %s, команда даёт %s\n' "$n" "$M1"
    exit 1
  fi
  M2="$(cd "$ROOT" && bash -c "shopt -s nullglob; files=( $glob ); echo \${#files[@]}")"
  if [ "$M2" -ne "$n" ]; then
    printf 'спек-гейт 036: замер расходится: заявлено %s, дерево даёт %s\n' "$n" "$M2"
    exit 1
  fi
done < <(printf '%s\n' "$DRAFT_BODY" | grep '^замер: ' || true)

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
done <<<"$DRAFT_BODY"

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
done <<<"$DRAFT_BODY"

# (а) Все коммиты автора по выпавшему пути в окне должны быть покрыты СПАСЕНО.
for key in "${!_dropped_role_path[@]}"; do
  role="${key%%/*}"
  path="${key#*/}"
  commits="$(g log --author="$role" --pretty=format:'%H' "$c_since..$c_until" -- "$path" 2>/dev/null || true)"
  [ -n "$commits" ] || continue
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
    s_line="$(printf '%s\n' "$DRAFT_BODY" | grep "^СПАСЕНО ${role}: " | head -1)"
    printf 'спек-гейт 036: СПАСЕНО не привязан к выпавшему пути: %s\n' "$s_line"
    exit 1
  fi
done

printf 'OK\n'
exit 0
