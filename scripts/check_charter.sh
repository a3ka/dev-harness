#!/usr/bin/env bash
# Уставной документ не меняется без разрешения владельца. Требование владельца дословно:
# «уставные документы — описание проекта, архитектура, роадмап, майлстоуны, ред-тесты как контракт
# майлстоуна — после утверждения НИКОГДА не меняются без разрешения владельца, жёстче, чем просто
# заморозка».
#
# СОСТАВ УСТАВА ОБЪЯВЛЕН СПИСКОМ, И ЭТО НЕ НАРУШЕНИЕ ПРАВИЛА «область выводится из предмета».
# Состав устава — ВОЛЯ ВЛАДЕЛЬЦА, а не выводимое свойство дерева: никакой признак файла не
# говорит, объявил ли его владелец уставным. Выводить область здесь означало бы угадывать его
# волю. Список:
#
#   AGENTS.md          норма системы. Описание проекта и архитектура живут ВНУТРИ него: отдельных
#   ROADMAP.md         файлов сегодня нет (проверено деревом). Появятся — добавляются в этот
#                      список коммитом со строкой владельца, потому что шапка барьера сама лежит
#                      в scripts/ и правится по общим правилам зон и ревью.
#   plans/NNN-*.md     устав с момента ПЕРВОЙ заморозки каждого файла, не раньше: черновик пишется
#   contracts/NNN-*.md правками, и гейт, краснеющий на черновике, заставил бы морозить недописанное.
#
# Ред-тесты как контракт майлстоуна — это раздел критериев ВНУТРИ `contracts/NNN`, и он защищён
# вместе с файлом. Сами файлы фикстур уставом НЕ являются: они реализация, их меняют исполнители в
# зонах. Иначе ни одну находку адверсария нельзя было бы закрыть без владельца.
#
# ГРАММАТИКА РАЗРЕШЕНИЯ — литерал, ПЕРВАЯ КОЛОНКА тела коммита:
#
#   РАЗРЕШИЛ-ВЛАДЕЛЕЦ: <путь> <непустая причина>
#
# Путь с пробелом — в двойных кавычках. Образец разбора — `excuse_for()` в `check_protected.sh`,
# и оттуда же взяты три измеренных урока: строка обязана лежать в первой колонке (иначе цитата в
# теле коммита становится настоящим разрешением), обязана называть ПУТЬ (безымянное разрешение
# снимает защиту со всего дерева навсегда) и обязана называть ПРИЧИНУ (разрешение без причины
# неотличимо от опечатки).
#
# РАЗРЕШЕНИЕ ЛЕЖИТ В ТОМ ЖЕ КОММИТЕ, который меняет файл. Урок круга 2 по `ALLOW-ARTIFACT-DELETE`:
# разрешение, выданное заранее или задним числом, есть индульгенция — оно годилось повторно и его
# можно было положить в посторонний коммит, а потом изменить устав молча.
#
# `--diff-filter=MD` намеренно: ДОБАВЛЕНИЕ нового плана или контракта свободно, потому что
# черновики пишет архитектор. Изменение и удаление — нет.
#
# ОСТАТОЧНЫЙ РИСК, помечен `cognitive-only`: подлинность строки при одном uid механически не
# доказуема — это закоммиченный текст, тот же класс, что `ALLOW-ARTIFACT-DELETE` (принятый
# прецедент). Держится записанным запретом в норме и ролях (агенту писать её запрещено) плюс
# чтением истории ревьюером и адверсарием. Ужесточение — подписанные GPG-теги `ustav-ok/<коммит>`
# — включается словом владельца, в план 007 не входит.
#
# MERGE-КОММИТЫ (контракт 019, И-7). Прежде check_charter читал историю `rev-list --no-merges`
# и merge-коммит, вносивший уставную дельту ТОЛЬКО в результат слияния (родители файл не трогали),
# оставался невидим судье — обход CI check:charter и делегирования check_staged. После 019
# судимое множество = не-merge (как прежде) + merge-коммиты, судимые по дельте к ПЕРВОМУ
# родителю. Грамматика razreshil() и вердикты НЕ меняются: разрешённый merge несёт строку
# РАЗРЕШИЛ в теле merge-коммита, evil merge без строки — «изменён без разрешения владельца».
#
# is_charter_path (контракт 019, ветвь 1 — единый источник предиката). Staged-путь
# уставного класса — AGENTS.md/ROADMAP.md при живом теге ustav/1; plans/NNN-*.md/contracts/NNN-*.md
# при живом теге frozen/<dir>/<NNN>/1. Предикат экспортируется библиотекой и импортируется
# check_staged через `CHARTER_LIB=1 source check_charter.sh` — вторая реализация кольца
# запрещена (прецедент lib_zones/lib_registry).
#
#   bash scripts/check_charter.sh            проверить это дерево
#   bash scripts/check_charter.sh <корень>   проверить другое (так предъявляется красным)
#
# Коды возврата: 0 — устав не менялся без разрешения, 1 — менялся либо реестр недоступен,
# 2 — нечем проверить.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"

# ── БИБЛИОТЕЧНЫЕ ФУНКЦИИ (контракт 019, ветвь 1, И-7) ─────────────────────────
#
# is_charter_path <ПУТЬ> <КОРЕНЬ> — предикат уставного класса (rc 0/1/2).
#   AGENTS.md/ROADMAP.md при живом теге ustav/1;
#   plans/NNN-*.md/contracts/NNN-*.md при живом теге frozen/<dir>/<NNN>/1
#   (NNN — parse_artifact_basename rc 0, ровно три цифры).
#   Реализация — та же логика, что в построении $TMP/pairs ниже, вынесена чтобы
#   check_staged мог делегировать устав без своей копии кольца.
is_charter_path() {
  local path="$1" root="$2"
  local dir base nnn ARTIFACT_NUMBER_SAVED
  case "$path" in
    AGENTS.md|ROADMAP.md)
      git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || return 2
      git -C "$root" rev-parse --verify --quiet 'refs/tags/ustav/1' >/dev/null
      ;;
    plans/*|contracts/*)
      git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || return 2
      dir="${path%%/*}"; base="${path##*/}"
      [ "$dir/$base" = "$path" ] || return 1
      # parse_artifact_basename пишет в глобальный ARTIFACT_NUMBER (его контракт); сохраняем
      # и восстанавливаем, чтобы не вытекать в caller.
      ARTIFACT_NUMBER_SAVED="${ARTIFACT_NUMBER:-}"
      if ! parse_artifact_basename "$base" 2>/dev/null; then
        ARTIFACT_NUMBER="$ARTIFACT_NUMBER_SAVED"
        return 1
      fi
      if [ -z "${ARTIFACT_NUMBER:-}" ]; then
        ARTIFACT_NUMBER="$ARTIFACT_NUMBER_SAVED"
        return 1
      fi
      nnn="$(printf '%03d' "$ARTIFACT_NUMBER")"
      ARTIFACT_NUMBER="$ARTIFACT_NUMBER_SAVED"
      git -C "$root" rev-parse --verify --quiet "refs/tags/frozen/$dir/$nnn/1" >/dev/null
      ;;
    *)
      return 1
      ;;
  esac
}

# charter_diff_paths <КОММИТ> <КОРЕНЬ> — пути, изменённые/удалённые в коммите
# относительно ПЕРВОГО родителя (для merge) или единственного родителя (для
# не-merge). `git diff-tree <merge>` без явного родителя возвращает пусто (git
# optimization), и явный `^1 <merge>` нужен только для merge. Корневой коммит —
# без ^1, diff-tree против пустого дерева.
charter_diff_paths() {
  local c="$1" root="$2"
  if git -C "$root" rev-parse --verify --quiet "${c}^1" >/dev/null 2>&1; then
    git -C "$root" diff-tree -r --no-commit-id --name-only --no-renames --diff-filter=MD "${c}^1" "$c" 2>/dev/null
  else
    git -C "$root" diff-tree -r --no-commit-id --name-only --no-renames --diff-filter=MD "$c" 2>/dev/null
  fi
}

# ── ИМПОРТ КАК БИБЛИОТЕКА ────────────────────────────────────────────────────
# Когда скрипт импортируется (`CHARTER_LIB=1 source check_charter.sh`),
# определяются функции `is_charter_path`, `charter_diff_paths`, `razreshil`
# и работа завершается. Иначе — основной код. `set -e` основного скрипта НЕ
# снимается: check_staged не должен падать на rc=1 от `razreshil` (это «нет
# разрешения», а не сбой).
if [ "${CHARTER_LIB:-}" = "1" ]; then
  return 0 2>/dev/null || exit 0
fi

ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"

fails=0
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git — историю устава прочитать нечем"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || skip "в $ROOT нет ни одного коммита"

g() { git -C "$ROOT" "$@"; }

# Устав не введён — «нечем проверить», а не «проверено». Это ЕДИНСТВЕННАЯ законная двойка барьера:
# до акта введения у него нет точки, с которой считать историю.
g rev-parse --verify --quiet 'refs/tags/ustav/1' >/dev/null \
  || skip "устав не введён — создайте тег ustav/1 последним коммитом документных правок"

for prefix in ustav/ frozen/; do
  state="$(registry_state "$ROOT" "$prefix")"
  case "$state" in
    full|unknown-remote) ;;
    *)
      printf 'ОТКАЗ: реестр устава (refs/tags/%s*) недоступен: %s\n' "$prefix" "$state" >&2
      printf 'Лечится: %s\n' "$(registry_cure "$state")" >&2
      exit 1
      ;;
  esac
done

mkdir -p "$ROOT/tmp"
TMP="$(mktemp -d "$ROOT/tmp/charter.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# ── разрешение обязано лежать в ТОМ ЖЕ коммите ────────────────────────────────
# Разбор — по образцу `excuse_for()`: путь в кавычках либо до первого пробела, остаток — причина.
razreshil() {  # <коммит> <путь> → 0, если разрешение выдано ИМЕННО этим коммитом
  local c="$1" p="$2" body line path reason
  body="$(g log -1 --format=%B "$c")"
  while IFS= read -r line; do
    if [ "${line:0:1}" = '"' ]; then
      path="${line:1}"; path="${path%%\"*}"
      reason="${line#\"$path\"}"
      # Разделитель после закрывающей кавычки ОБЯЗАТЕЛЕН. Адверсарий предъявил: строка
      # `"ROADMAP.md"причина` без пробела принималась — грамматика объявлена как
      # `<путь> <непустая причина>`, и форма без разделителя ею не покрыта. Принять её значило
      # бы расширить язык разрешения молча (правило 7 нормы).
      if [ -n "$reason" ] && ! [[ "$reason" == [[:space:]]* ]]; then
        bad "строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в ${c:0:8} вне грамматики: после закрывающей кавычки пути обязан стоять пробел-разделитель — «$line»"
        continue
      fi
    else
      path="${line%%[[:space:]]*}"
      reason="${line#"$path"}"
    fi
    reason="${reason#"${reason%%[![:space:]]*}"}"
    if [ -z "$path" ]; then
      bad "в коммите ${c:0:8} строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ не назвала путь — безымянное разрешение снимает защиту со всего устава навсегда"
    elif [ "$path" != "$p" ]; then
      continue
    elif [ -z "$reason" ]; then
      bad "разрешение РАЗРЕШИЛ-ВЛАДЕЛЕЦ для $path в ${c:0:8} без причины — разрешение без записанной причины неотличимо от опечатки"
    else
      return 0
    fi
  done < <(printf '%s\n' "$body" | awk 'sub(/^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:[[:space:]]*/, "") { print }')
  return 1
}

# ── область: файл → диапазон, с которого он уставной ──────────────────────────
# У AGENTS.md и ROADMAP.md точка одна — тег `ustav/1`. У планов и контрактов своя у каждого:
# ПЕРВАЯ его заморозка. Общий диапазон здесь был бы ложью о предмете: до заморозки файл черновик.
: > "$TMP/pairs"
for f in AGENTS.md ROADMAP.md; do
  g cat-file -e "HEAD:$f" 2>/dev/null || continue
  printf '%s\t%s\n' "$f" 'ustav/1' >> "$TMP/pairs"
done

g ls-tree -r --name-only HEAD -- ':(literal)plans/' ':(literal)contracts/' 2>/dev/null \
  | awk '/\.md$/' | sort > "$TMP/docs" || true
while IFS= read -r f; do
  [ -n "$f" ] || continue
  dir="${f%%/*}"; base="${f##*/}"
  [ "$dir/$base" = "$f" ] || continue
  ARTIFACT_NUMBER=""
  rc=0
  parse_artifact_basename "$base" || rc=$?
  [ "$rc" -eq 0 ] && [ -n "${ARTIFACT_NUMBER:-}" ] || continue
  NNN="$(printf '%03d' "$ARTIFACT_NUMBER")"
  # Уставным файл становится с ПЕРВОЙ заморозки; нет её — он черновик и здесь не предмет.
  g rev-parse --verify --quiet "refs/tags/frozen/$dir/$NNN/1" >/dev/null || continue
  printf '%s\t%s\n' "$f" "frozen/$dir/$NNN/1" >> "$TMP/pairs"
done < "$TMP/docs"

# ── обход ─────────────────────────────────────────────────────────────────────
docs=0; changes=0; excused=0
while IFS=$'\t' read -r f since; do
  [ -n "$f" ] || continue
  docs=$((docs + 1))
  doc_fails_before="$fails"
  # Все коммиты ВКЛЮЧАЯ merge (И-7). Удалён `--no-merges` — merge-коммит, вносящий уставную
  # дельту ТОЛЬКО в результат слияния, теперь судим по diff с ПЕРВЫМ родителем через
  # charter_diff_paths (там явный `<merge>^1 <merge>`; для не-merge это эквивалент
  # `diff-tree <c>`).
  g rev-list "$since..HEAD" > "$TMP/commits" 2>/dev/null || : > "$TMP/commits"
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    # `--no-renames` намеренно: иначе вердикт зависел бы от `diff.renames` в конфиге машины, то
    # есть мера меняла бы результат от настроек читателя.
    charter_diff_paths "$c" "$ROOT" | grep -qxF -- "$f" || continue
    changes=$((changes + 1))
    if razreshil "$c" "$f"; then
      excused=$((excused + 1))
      ok "уставной документ изменён с разрешения владельца: $f в ${c:0:8}"
    else
      bad "уставной документ изменён без разрешения владельца: $f в ${c:0:8} — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $f <причина>» в первой колонке"
    fi
  done < "$TMP/commits"
  # Зелёное НАЗЫВАЕТСЯ, и с числом просмотренных коммитов. Барьер, молча проходящий по уставному
  # документу, не даёт доказательств, ЧТО он проверил: молчаливое зелёное неотличимо от барьера,
  # который файл вовсе не увидел, — и это класс пусто-зелёного, а не мелочь оформления.
  scanned="$(wc -l < "$TMP/commits" | tr -d ' ')"
  if [ "$fails" -eq "$doc_fails_before" ]; then
    ok "$f — уставной с $since, коммитов в диапазоне $scanned, изменений без разрешения нет"
  fi
done < "$TMP/pairs"

printf '\nуставных документов: %d · изменений в них: %d · с разрешения: %d\n' \
  "$docs" "$changes" "$excused" >&2

[ "$fails" -eq 0 ] || exit 1
