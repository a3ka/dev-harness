# НЕ БАРЬЕР: библиотека, а не гейт. Вердикт кодом возврата выносит тот, кто её подключил; сама
# она только читает замороженные контракты и выдаёт структурированное представление их зон.
#
# Заведено потому, что второй читатель ЗОНА-строк расходился бы молча: check_zones собирал зоны
# из refs/tags/frozen/contracts/ для суда коммитов, а check_staged (контракт 016) читал то же
# для суда staged-множества. Один формат — один читатель: иначе правка контракта меняла бы
# предмет одного барьера и молча не меняла другой, и приёмка зон была бы зелёной у одного и
# красной у другого по одному и тому же дереву. Прецедент — `lib_roles.sh`/`lib_registry.sh`,
# которые сделали то же самое для `verdict:` и тегов заморозок.
#
# КОНТРАКТ ФУНКЦИИ ОДИН — `zones_load <корень>`. Возвращает 0 при успехе (включая случай, когда
# замороженных контрактов нет — пустой результат не ошибка), 1 при отказе реестра, 2 при
# NOT_IMPLEMENTED. Результат — каталог, который функция СОЗДАЁТ и ПЕЧАТАЕТ В STDIO (путь
# единственным stdout-аргументом). Формат файлов внутри — TSV или NUL.
#
# Файлы:
#   zones_scoped    — все валидные ЗОНА-строки из блобов высших заморозок:
#                     автор<TAB>путь<TAB>контракт;
#   zones_violations — нарушения грамматики ЗОНА. NUL-разделённые поля в порядке:
#                     контракт, файл, причина, автор, путь, сырая_строка.
#                     NUL выбран потому, что в ЗОНА-строках он не встречается, а TAB —
#                     может (имя автора с табуляцией — отдельный класс нарушения, и
#                     табулированный сырая строка рвала бы TSV). Поставщик НЕ печатает
#                     текст — текст и формулировка остаются у потребителя (замороженная
#                     ветвь check_zones);
#   ranges          — диапазоны применения: контракт<TAB>frozen/contracts/<NNN>/1[..done/contracts/<NNN>/1];
#   contracts_list  — все NNN контрактов, для которых читан блоб.
#
# Поставщик ИМЯ АВТОРА НЕ ПРОВЕРЯЕТ — эту проверку делает потребитель, потому что у
# check_zones «необъявленные авторы не проверяются» (историческая норма), а у check_staged
# «author пуст → не судится», и обходятся они по-разному. Поставщик отдаёт копию —
# список ЗОНА-строк, — а правило «как с этим жить» выбирает вызвавший.
#
#   bash scripts/check_zones.sh            проверить это дерево (через lib_zones)
#   bash scripts/check_staged.sh <корень>  проверить другое (через lib_zones)
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# Канонизация пути БЕЗ mkdir — спуск до существующего предка + pwd -P.
lib_zones_canon() {
  local p="$1" tail="" cur _c
  [ -n "$p" ] || return 1
  case "$p" in /*) ;; *) p="$PWD/$p" ;; esac
  cur="$p"
  while [ ! -d "$cur" ] && [ -n "$cur" ]; do
    tail="/${cur##*/}${tail}"
    cur="${cur%/*}"
  done
  [ -n "$cur" ] || return 1
  _c="$(cd "$cur" 2>/dev/null && pwd -P 2>/dev/null)" || return 1
  printf '%s%s' "$_c" "$tail"
}

# zones_load <корень-репо>
# stdout: каталог с файлами zones_scoped, zones_violations, ranges, contracts_list.
# rc 0 при успехе (включая «нет контрактов»); 1 при отказе реестра; 2 при NOT_IMPLEMENTED.
#
# Пути — ИЗ БЛОБА ВЫСШЕЙ ЗАМОРОЗКИ, не из рабочего дерева (иначе правка контракта расширяла бы
# зону без заморозки). Диапазон применения — от ПЕРВОЙ заморозки контракта до done-тега, если
# он есть, иначе до HEAD (Н-14).
zones_load() {
  local root="$1" self_dir out contracts nnn vmax vmax_tag body file
  self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  . "$self_dir/lib_registry.sh"

  root="$(lib_zones_canon "$root")" || {
    printf 'NOT_IMPLEMENTED: канонизация корня отказала\n' >&2; return 2; }
  command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; return 2; }
  git -C "$root" rev-parse --git-dir >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: %s не репозиторий\n' "$root" >&2; return 2; }

  local state
  state="$(registry_state "$root" 'frozen/')"
  case "$state" in
    full|unknown-remote) ;;
    *)
      printf 'NOT_IMPLEMENTED: реестр заморозок недоступен: %s\n' "$state" >&2
      return 2 ;;
  esac

  mkdir -p "$root/tmp"
  out="$(mktemp -d "$root/tmp/lib_zones.XXXXXX")"
  : > "$out/zones_scoped"
  : > "$out/zones_violations"
  : > "$out/ranges"
  : > "$out/contracts_list"

  # Удобный испускатель нарушения: contract\0file\0reason\0author\0path\0raw_line\n
  # NUL защищает поля от внутренних табуляций в raw_line и author.
  emit_violation() {
    printf '%s\0%s\0%s\0%s\0%s\0%s\n' \
      "$1" "$2" "$3" "$4" "$5" "$6" >> "$out/zones_violations"
  }

  contracts=0
  while IFS= read -r nnn; do
    [ -n "$nnn" ] || continue
    contracts=$((contracts + 1))
    printf '%s\n' "$nnn" >> "$out/contracts_list"

    vmax=0
    while IFS= read -r t; do
      if [[ "$t" =~ ^refs/tags/frozen/contracts/${nnn}/([0-9]+)$ ]]; then
        local k=$((10#${BASH_REMATCH[1]}))
        [ "$k" -gt "$vmax" ] && vmax="$k"
      fi
    done < <(git -C "$root" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null | sort)
    [ "$vmax" -gt 0 ] || continue

    vmax_tag="refs/tags/frozen/contracts/$nnn/$vmax"
    file="$(git -C "$root" ls-tree -r --name-only "${vmax_tag}^{commit}" -- ':(literal)contracts/' 2>/dev/null \
            | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
    [ -n "$file" ] || continue
    body="$(git -C "$root" cat-file -p "${vmax_tag}^{commit}:$file" 2>/dev/null || true)"

    while IFS= read -r line; do
      [ -n "$line" ] || continue
      local rest="${line#ЗОНА }"
      local author="${rest%%:*}"
      local paths="${rest#*:}"
      if [ "$author" = "$rest" ] || [ -z "${author//[[:space:]]/}" ]; then
        emit_violation "$nnn" "$file" "bad_author" "$author" "" "$line"
        continue
      fi
      # ТАБУЛЯЦИЯ В ИМЕНИ АВТОРА ЗАПРЕЩЕНА (адверсарий: TSV-сериализация рвёт имя надвое).
      if [[ "$author" == *$'\t'* ]]; then
        emit_violation "$nnn" "$file" "tab_in_author" "$author" "" "$line"
        continue
      fi
      if [ -z "${paths//[[:space:]]/}" ]; then
        emit_violation "$nnn" "$file" "no_paths" "$author" "" "$line"
        continue
      fi
      # РАСЩЕПЛЕНИЕ БЕЗ ПОДСТАНОВКИ ИМЁН ФАЙЛОВ (Н-39: `for p in $paths` без set -f раскрывает
      # `scripts/*` в реальные файлы каталога, и зона становится тотальной).
      set -f
      # shellcheck disable=SC2086
      for p in $paths; do
        case "$p" in
          *'"'*)
            emit_violation "$nnn" "$file" "quote_in_path" "$author" "$p" "$line"
            continue ;;
        esac
        case "$p" in
          *\*) emit_violation "$nnn" "$file" "bad_prefix" "$author" "$p" "$line"; continue ;;
          *)  ;;
        esac
        printf '%s\t%s\t%s\n' "$author" "$p" "$nnn" >> "$out/zones_scoped"
      done
      set +f
    done < <(printf '%s\n' "$body" | grep '^ЗОНА ' || true)

    # Конец диапазона — тег done/contracts/<NNN>/1 (Н-14).
    local done_ref="done/contracts/$nnn/1"
    if git -C "$root" rev-parse --verify --quiet "refs/tags/$done_ref" >/dev/null; then
      if git -C "$root" merge-base --is-ancestor "refs/tags/$done_ref" HEAD; then
        printf '%s\t%s..%s\n' "$nnn" "frozen/contracts/$nnn/1" "$done_ref" >> "$out/ranges"
      else
        printf '%s\tfrozen/contracts/%s/1\n' "$nnn" "$nnn" >> "$out/ranges"
      fi
    else
      printf '%s\tfrozen/contracts/%s/1\n' "$nnn" "$nnn" >> "$out/ranges"
    fi
  done < <(git -C "$root" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null \
           | awk -F/ '/^refs\/tags\/frozen\/contracts\// { print $5 }' | sort -u)

  printf '%s\n' "$out"
  return 0
}

# Проверка пути staged-файла против зон автора.
# Принимает каталог результата zones_load и имя автора; возвращает 0 если путь в зоне, иначе 1.
zones_match_path() {
  local out="$1" author="$2" path="$3" a pp inside
  inside=1
  while IFS=$'\t' read -r a pp _; do
    [ "$a" = "$author" ] || continue
    case "$pp" in
      */) case "$path" in "$pp"*) inside=0; printf '%s\n' "$pp"; break ;; esac ;;
      *)  [ "$path" = "$pp" ] && { inside=0; printf '%s\n' "$pp"; break; } ;;
    esac
  done < <(awk -F'\t' -v a="$author" '$1 == a { print $1 "\t" $2 }' "$out/zones_scoped" | sort -u)
  [ "$inside" -eq 0 ]
}

# Список ВСЕХ ЗОН указанного автора в каталоге результата zones_load.
zones_for_author() {
  local out="$1" author="$2"
  awk -F'\t' -v a="$author" '$1 == a { print $2 }' "$out/zones_scoped" | sort -u
}
