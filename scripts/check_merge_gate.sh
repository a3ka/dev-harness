#!/usr/bin/env bash
# Барьер ворот слияния проекта (контракт 063, ветвь (б)): rc 0 ⟺
# закоммиченный accept-вердикт ревьюера ∧ нет блокирующих .review/-файлов.
#
# Аргументы:
#   --repo <корень>   путь к корню репозитория проекта (обязательно).
#
# Коды возврата:
#   0 — accept-вердикт закоммичен ∧ нет блокирующих находок;
#   1 — именованный отказ (фраза на stderr, stdout пуст);
#   2 — NOT_IMPLEMENTED (нет git/jq).
#
# Реализует И-1..И-3, И-8 контракта 063.
set -uo pipefail

export PATH=/usr/bin:/bin
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVER="$SELF_DIR/profile_resolver.sh"

usage() {
  printf 'merge gate ОТКАЗ: usage: bash scripts/check_merge_gate.sh --repo <корень>\n' >&2
  exit 1
}

REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --help|-h) usage ;;
    *) printf 'merge gate ОТКАЗ: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

[ -n "$REPO" ] || usage
[ -d "$REPO" ] || { printf 'merge gate ОТКАЗ: каталог репо не существует: %s\n' "$REPO" >&2; exit 1; }

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v jq  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
command -v awk >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет awk\n' >&2; exit 2; }

# Единый резолв профиля (И-8).
PROFILE="$(HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-}" \
           bash "$RESOLVER" --repo "$REPO" 2>&1)" \
  || { printf '%s\n' "$PROFILE" >&2; exit 1; }

VERDICTS_DIR="$(printf '%s' "$PROFILE" | jq -r '.workflowPaths.verdicts.value // empty')"
[ -n "$VERDICTS_DIR" ] \
  || { printf 'merge gate ОТКАЗ: профиль не объявляет workflowPaths.verdicts — вердикты негде искать\n' >&2; exit 1; }

# И-3: проверка .review/ — ДО вердикта (порядок И-1, «свежая боль старше»).
# Судятся файлы верхнего уровня <REPO>/.review/*.md. Frontmatter: первая
# строка `---`, до следующей `---`; строка `status: <значение>` — самостоятельная.
# Алфавит: ready|partial|done. ready/partial → rc 1, done — не блокирует,
# значение вне алфавита → rc 1 (fail-closed). Файл без status-строки — не
# находка, игнорируется.
REVIEW_DIR="$REPO/.review"
if [ -d "$REVIEW_DIR" ]; then
  while IFS= read -r rf; do
    [ -n "$rf" ] || continue
    rel="$rf"
    case "$rel" in
      ./.review/*) rel=".review/${rel#./.review/}" ;;
      .review/*)   : ;;
      *)           rel=".review/$(basename "$rf")" ;;
    esac
    abs="$REPO/$rel"
    # Извлечение status из frontmatter. awk-парсинг: первая строка `---` открывает
    # frontmatter, вторая `---` закрывает; далее ищем самостоятельную строку
    # `status: <значение>` в открытой секции. Байтовое сравнение через grep -Fx.
    status="$(awk '
      NR==1 { if ($0 == "---") fm=1; next }
      fm==1 && $0 == "---" { fm=2; next }
      fm==1 && $0 ~ /^status: / { sub(/^status: /, ""); print; exit }
    ' "$abs")"
    [ -n "$status" ] || continue
    case "$status" in
      ready)
        printf 'merge gate ОТКАЗ: незакрытая находка ревьюера: %s (status: ready)\n' "$rel" >&2
        exit 1 ;;
      partial)
        printf 'merge gate ОТКАЗ: незакрытая находка ревьюера: %s (status: partial)\n' "$rel" >&2
        exit 1 ;;
      done)
        : ;;
      *)
        printf 'merge gate ОТКАЗ: нечитаемый статус находки: %s (status: %s)\n' "$rel" "$status" >&2
        exit 1 ;;
    esac
  done < <(cd "$REPO" && find .review -maxdepth 1 -type f -name '*.md' 2>/dev/null)
fi

# И-2: accept-вердикт = файл *.md под workflowPaths.verdicts, у которого ПЕРВАЯ
# строка блоба HEAD:<путь> — литерал `accept`. Чтение `git show`, не рабочая
# копия: незакоммиченный/изменённый после коммита файл не считается.
# FAIL-вердикты и пустой каталог — не accept.
found=0
while IFS= read -r vf; do
  [ -n "$vf" ] || continue
  first="$(git -C "$REPO" show "HEAD:$vf" 2>/dev/null | head -n1 || true)"
  if [ "$first" = "accept" ]; then
    found=1
    break
  fi
done < <(cd "$REPO" && find "$VERDICTS_DIR" -type f -name '*.md' 2>/dev/null)

if [ "$found" -ne 1 ]; then
  printf 'merge gate ОТКАЗ: нет закоммиченного accept-вердикта ревьюера\n' >&2
  exit 1
fi

exit 0
