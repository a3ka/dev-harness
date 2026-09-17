#!/usr/bin/env bash
# Заморозка плана или контракта: утверждение = аннотированный git-тег `frozen/<каталог>/<NNN>/<v>`.
#
# Других смыслов у слова «утверждён» нет. Заведено по плану 007: причина семи кругов шага 5 —
# спека и красные критерии менялись ПОСЛЕ раздачи работы, и каждая смена обесценивала сданное.
# Заморозка делает смену видимой: новая версия требует нового вердикта критика и разрешения
# владельца в изменяющем коммите.
#
# ЭТО ЕДИНСТВЕННЫЙ ПИСАТЕЛЬ реестра заморозок, и он ведёт себя как писатель, а не как читатель:
# выдача идентификатора необратима. Ошибившийся читатель краснеет повторно; ошибившийся писатель
# оставляет в истории два `v1`, и развести их уже нечем (правило 5 нормы). Поэтому реестр
# проверяется ДО вычисления версии, и `unknown-remote` (origin объявлен, но недоступен) для него
# — отказ, тогда как для читателей то же слово годится как `full`. Асимметрия названа здесь
# намеренно: она была дефектом, найденным критиком, а не украшением.
#
# ВЕРДИКТ КРИТИКА ЧИТАЕТСЯ, А НЕ ПЕРЕСЧИТЫВАЕТСЯ. План 007 в первой редакции требовал лишь
# СУЩЕСТВОВАНИЯ файла вердикта — тогда заморозка проходила бы над вердиктом `FAIL`: механизм
# считал бы файлы, не читая их. Первая строка вердикта — объявленная грамматика роли критика
# (`accept` | `FAIL` | `ESCALATE`), значит она читаема механизмом, и три исхода разведены на три
# диагноза: отказ критика, вопрос владельцу и мусор — разные предметы (правило 7 нормы).
#
#   bash scripts/freeze_contract.sh plans/007-x.md "причина"            заморозить в этом дереве
#   bash scripts/freeze_contract.sh contracts/001-x.md "причина" КОРЕНЬ  заморозить в другом
#
# В stdout — только `v<N>`: команда записи, чей вывод читают глазами и скриптом.
#
# DOC-ЗАМОРОЗКА (контракт 027 §Freeze): для doc-контракта (`## Док-приёмка` с
# `type: documentation`) повторяет doc-preflight ПОСЛЕ всех кодовых проверок
# (реестр/грамматика/коммитность/причина/вердикт/кап) и ДО записи тега. Отказ
# doc-preflight — rc=1 без записи тега; rc=2 — rc=1 (fail-closed). Тип определяется
# общим разбором в doc_contract.ts; НЕ кодовой эвристикой «тест отсутствующего
# документа красен».
#
# Коды возврата: 0 — заморожено, 1 — отказ, 2 — нечем проверить.
set -euo pipefail

# Унаследованные git-переменные подменяют предмет до первой команды: адверсарий предъявил ложное
# ЗЕЛЁНОЕ через `GIT_DIR` и `GIT_WORK_TREE` на механизме 2. Писателю это опаснее вдвое — он
# оставляет след в чужом дереве.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Разбор имени артефакта — ЕДИНСТВЕННОЙ реализацией из `next_id.sh`; грамматика поля и полнота
# реестра — из своих библиотек. Подключаются от СВОЕГО каталога, а не от проверяемого дерева:
# иначе код барьера приходил бы из предмета.
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"

die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

TARGET="${1:-}"
REASON="${2:-}"
ROOT="${3:-$(cd "$SELF_DIR/.." && pwd)}"

[ -n "$TARGET" ] || die "не назван предмет: bash scripts/freeze_contract.sh <plans/NNN-*.md|contracts/NNN-*.md> \"<причина>\" [корень]"

command -v git >/dev/null 2>&1 || skip "нет git — реестр заморозок вести нечем"
[ -d "$ROOT" ] || skip "корня нет: $ROOT"
ROOT="$(cd "$ROOT" && pwd)"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git — реестр заморозок вести негде"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || skip "в $ROOT нет ни одного коммита — замораживать нечего"

g() { git -C "$ROOT" "$@"; }

# ── 2. реестр: ДО вычисления версии ───────────────────────────────────────────
state="$(registry_state "$ROOT" 'frozen/')"
case "$state" in
  full) ;;
  *)    die "реестр заморозок (refs/tags/frozen/*) недоступен: $state — $(registry_cure "$state"). Номер версии выдаётся один раз, и писатель не имеет права его угадывать" ;;
esac

# ── 3. грамматика предмета ────────────────────────────────────────────────────
dir="${TARGET%%/*}"
base="${TARGET##*/}"
case "$dir" in
  plans|contracts) ;;
  *) die "замораживается только plans/NNN-*.md либо contracts/NNN-*.md; получено: $TARGET" ;;
esac
[ "$dir/$base" = "$TARGET" ] || die "замораживается только plans/NNN-*.md либо contracts/NNN-*.md; вложенные пути не замораживаются: $TARGET"
ARTIFACT_NUMBER=""
rc=0
parse_artifact_basename "$base" || rc=$?
if [ "$rc" -ne 0 ] || [ -z "${ARTIFACT_NUMBER:-}" ]; then
  die "замораживается только plans/NNN-*.md либо contracts/NNN-*.md; имя «$base» вне грамматики NNN-<slug>.md (ровно три цифры, дефис, не-цифра)"
fi
case "$base" in
  *.md) ;;
  *) die "замораживается только plans/NNN-*.md либо contracts/NNN-*.md; у «$base» нет расширения .md" ;;
esac
NNN="$(printf '%03d' "$ARTIFACT_NUMBER")"

# ── 4. только закоммиченное состояние ─────────────────────────────────────────
# Заморозить рабочее дерево значило бы заморозить то, чего в истории нет: тег указывал бы на
# коммит с ДРУГИМ содержимым файла, и «побайтово совпадает» у читателя было бы ложью.
[ -f "$ROOT/$TARGET" ] || die "файла нет в рабочем дереве: $TARGET"
head_blob="$(g rev-parse --verify --quiet "HEAD:$TARGET" || true)"
[ -n "$head_blob" ] || die "замораживается только закоммиченное состояние: $TARGET на HEAD отсутствует"
work_blob="$(g hash-object -- "$ROOT/$TARGET")"
[ "$work_blob" = "$head_blob" ] || die "замораживается только закоммиченное состояние: $TARGET в рабочем дереве отличается от HEAD (блобы $work_blob и $head_blob)"

# ── 5. причина ────────────────────────────────────────────────────────────────
case "$REASON" in
  ''|*[![:space:]]*) ;;
esac
if [ -z "${REASON//[[:space:]]/}" ]; then
  die "заморозка без записанной причины неотличима от опечатки: второй аргумент пуст"
fi

# ── 6. версия и вердикт критика ───────────────────────────────────────────────
vmax=0
while IFS= read -r t; do
  [ -n "$t" ] || continue
  if [[ "$t" =~ ^refs/tags/frozen/${dir}/${NNN}/([0-9]+)$ ]]; then
    k=$((10#${BASH_REMATCH[1]}))
    [ "$k" -gt "$vmax" ] && vmax="$k"
  fi
done < <(g for-each-ref --format='%(refname)' "refs/tags/frozen/$dir/$NNN/" 2>/dev/null || true)
v=$((vmax + 1))

verdict="verdicts/critic/${dir}-${NNN}-v${v}.md"
body="$(g cat-file -p "HEAD:$verdict" 2>/dev/null || true)"
[ -n "$body" ] || die "заморозка v$v без вердикта критика: на HEAD нет $verdict. Утверждение плана или контракта невозможно без гейта критика — это механическая форма требования владельца"

first="$(printf '%s\n' "$body" | sed -n 1p | tr -d '\r')"
first="${first#"${first%%[![:space:]]*}"}"
first="${first%"${first##*[![:space:]]}"}"
case "$first" in
  accept)   ;;
  FAIL)     die "критик заморозку не разрешил: FAIL в $verdict. Заморозка поверх отказа означала бы, что механизм считает файлы, а не читает их" ;;
  ESCALATE) die "критик передал вопрос владельцу: ESCALATE в $verdict — заморозка ждёт его слова, а не решения автора" ;;
  *)        die "вердикт вне объявленной грамматики: первая строка «$first» в $verdict — грамматика роли критика допускает accept, FAIL, ESCALATE" ;;
esac

# ── 6а. КАП КРУГОВ: третий круг — арбитр или владелец ──────────────────────────
# Решение владельца 2026-08-20 (D3): по контракту 005 автор прошёл ДЕВЯТЬ кругов
# критика и не остановился ни на третьем, ни на шестом — правило в роли не
# сработало, счёт обязан держать механизм.
#
# Н-57/Р1 (контракт 013 §Б): круг — смена ПЕРВОЙ СТРОКИ вердикта, а не коммит
# файла. Коммит-шум (правка тела, D, re-A, R100-переименование) — форма, не
# содержание; три ложных капа (011; 012/1 circles=4 при реальных 2; 012/2
# circles=6) посчитали его кругами судейства и стоили эскалации к владельцу
# без спора. Счёт коммитами — подмена единицы: коммитов больше, чем кругов.
#
# Реконструкция таймлайна: `git log --reverse -M --name-status` по глобу
# verdicts/critic/${dir}-${NNN}-v*.md от старых к новым. Каждое A/M и R<100
# даёт событие первой строки ФАЙЛА-НАЗНАЧЕНИЯ на этом коммите (нормировка
# `tr -d '\r'` + trim; классы accept|FAIL|ESCALATE; прочее — свой класс,
# событие всё равно). D и R100 событий НЕ дают — форма без содержания.
# Несколько файлов одним коммитом — порядок по пути как у git diff-tree.
# Подряд-одинаковые классы сжимаются; circles = длина сжатого; первое событие
# = круг 1 (появление вердикта есть круг).
#
# При circles ≥ 3 заморозка требует ОДНО из двух, оба выхода названы в отказе:
#   (1) созванный арбитр: закоммиченный файл в verdicts/arbitration/, титул
#       которого несёт предмет скобкой — «(контракт 005)» / «(план 007)»;
#       вердикт арбитра начинается «РЕШЕНИЕ» либо «К ВЛАДЕЛЬЦУ» (грамматика
#       его роли), заморозка идёт дальше;
#   (2) слово владельца: строка «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» в причине заморозки —
#       она попадает в сообщение тега и остаётся в истории реестра.
# Клапан обязателен (урок Н-26): политика, не несущая законного пути снятия
# владельцем, первым же актом воюет с тем, кто её заказал.
_events="$(mktemp)"
trap 'rm -f "$_events"' EXIT
_cur_commit=""
g log --reverse -M --format='@%H' --name-status -- "verdicts/critic/${dir}-${NNN}-v*.md" 2>/dev/null \
  | while IFS= read -r _raw; do
      case "$_raw" in
        @*) _cur_commit="${_raw#@}"; continue ;;
      esac
      # Н-57/Р1: событие даёт A/M и R<100 (у R — назначения). D и R100 —
      # форма, не содержание; коммит-шум не считается. Несколько файлов одним
      # коммитом идут в порядке вывода git diff-tree (по пути).
      case "$_raw" in
        A*|"M"*) _path="${_raw#*$'\t'}" ;;
        R*)
          _sim="${_raw%%$'\t'*}"; _sim="${_sim#R}"
          [ "$_sim" = "100" ] && continue
          _path="${_raw##*$'\t'}"   # поле назначения — последнее
          ;;
        D*) continue ;;
        *)   continue ;;
      esac
      _body="$(g cat-file -p "${_cur_commit}:${_path}" 2>/dev/null || true)"
      _first="$(printf '%s\n' "$_body" | sed -n 1p | tr -d '\r')"
      _first="${_first#"${_first%%[![:space:]]*}"}"
      _first="${_first%"${_first##*[![:space:]]}"}"
      # Нормировка класса: accept|FAIL|ESCALATE — три диагноза; прочее — свой
      # класс (событие всё равно, иначе подмена единицы на «известные классы»
      # сжимала бы легитимную смену в шум — probe_grammatika_sobytij ветвь 3).
      case "$_first" in
        accept|FAIL|ESCALATE) _class="$_first" ;;
        *)                    _class="other" ;;
      esac
      printf '%s\n' "$_class" >> "$_events"
    done
# Сжатие подряд-одинаковых: circles = длина сжатого. Первое событие = круг 1.
circles="$(awk 'BEGIN{n=0;prev=""} {if($0!=prev){n++;prev=$0}} END{print n}' "$_events")"
[ -n "$circles" ] || circles=0
rm -f "$_events"
trap - EXIT

if [ "$circles" -ge 3 ]; then
  arbiter=""
  # ПРИВЯЗКА АРБИТРА К ПРЕДМЕТУ — ТИТУЛЬНОЙ ГРАММАТИКОЙ, не подстрокой всего
  # тела: первый живой прогон поймал ложное совпадение — арбитраж контракта 004
  # совпал по проходному упоминанию «contracts/005-x.md … проигнорирован» в теле.
  # Титул арбитража несёт предмет скобкой: «(контракт 005)» / «(план 007)».
  # Fail-closed: арбитраж без маркера предмета в титуле НЕ считается — кап
  # отказывает, и автор чинит титул, а не механизм ищет смысл в прозе (правило 8).
  case "$dir" in
    contracts) marker="(контракт ${NNN})" ;;
    plans)     marker="(план ${NNN})" ;;
    *)         marker="(${dir} ${NNN})" ;;
  esac
  arb_files="$(g ls-tree -r --name-only HEAD -- ':(literal)verdicts/arbitration/' 2>/dev/null | grep '\.md$' || true)"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    title="$(g cat-file -p "HEAD:$f" 2>/dev/null | sed -n 1p || true)"
    case "$title" in
      *"$marker"*) arbiter="$f"; break ;;
    esac
  done <<< "$arb_files"
  owner_override="$(printf '%s' "$REASON" | grep -c 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:' || true)"
  if [ -z "$arbiter" ] && [ "$owner_override" -eq 0 ]; then
    die "кап кругов: критик прошёл уже $circles кругов по $dir/$NNN, а вердикта арбитра по этому предмету нет (титул арбитража обязан нести «$marker») — третий круг обязан созывать арбитра либо заморозка идёт словом владельца (строка «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» в причине)"
  fi
  if [ -n "$arbiter" ]; then
    printf '  ok   кап кругов: %s кругов, арбитр был (титул «%s») — %s\n' "$circles" "$marker" "$arbiter" >&2
  else
    printf '  ok   кап кругов: %s кругов, заморозка словом владельца\n' "$circles" >&2
  fi
fi

_doc_type_out=""
_doc_type_rc=1
# ── 6б. DOC-PREFLIGHT (контракт 027 §Freeze) ──────────────────────────────────
# Для doc-контракта повторяет doc-preflight ДО записи тега: ветвь ready уже
# потребовала его при созыве судьи; freeze дублирует тот же прогон, потому что
# рабочая копия могла измениться между раундами. Отказ — rc=1 без тега; rc=2
# (нечем проверить) — rc=1 (fail-closed): нечего проверить ≠ проверено, иначе
# пустой/битый evidence прятал бы нарушение под нехватку инструмента. Общий
# модуль doc_contract.ts определяет тип через CLI `--type <файл>` —
# единый разбор грамматики (parseSpecFromMarkdown), не зависит от разбиения
# JSON по строкам. Подстрочная эвристика `grep '"type":[[:space:]]*"documentation"'`
# была блокером F1 ревьюера 027: конформный JSON с ключом/значением на разных
# строках проходил freeze без doc-preflight и замораживался с пустыми
# required.sections.
#
# RC CLI `--type`: 0 — валидный doc-контракт; 1 — НЕ doc-контракт; 2 —
# МАЛЬФОРМНЫЙ (раздел «## Док-приёмка» есть, но parseSpecFromMarkdown отверг
# — много разделов/блоков, чужой маркер, битый JSON; блокер F5 ревьюера 027 к2);
# 3 — usage/IO. Ветвящий код:
#   rc=0 → прогнать doc-preflight, rc≠0 из него — fail;
#   rc=1 → контракт НЕ doc-ветки, doc-preflight неприменим, пропустить (как до фикса);
#   rc=2 → мальформный doc-контракт: die rc=1 без тега;
#   rc=3 → usage/IO, die с системным сообщением.
#
# Передаём содержимое через tmp-файл, т.к. CLI принимает путь, а не stdin —
# freeze читает блоб из HEAD через `git cat-file`.
target_content="$(g cat-file -p "HEAD:$TARGET" 2>/dev/null || true)"
_doc_type_tmp="$(mktemp -t doc027.XXXXXX 2>/dev/null || true)"
_doc_type_rc=1
_doc_type_out=""
if [ -n "${_doc_type_tmp:-}" ]; then
  printf '%s' "$target_content" > "$_doc_type_tmp"
  _doc_type_out="$(cd "$ROOT" && node "$SELF_DIR/doc_contract.ts" --type "$_doc_type_tmp" 2>&1)"
  _doc_type_rc=$?
  _doc_type_rc="${_doc_type_rc:-0}"
  rm -f "$_doc_type_tmp"
  case "$_doc_type_rc" in
    0)
      doc_rc=0
      doc_out="$(cd "$ROOT" && node "$SELF_DIR/check_document.ts" --root "$ROOT" --contract "$TARGET" --preflight 2>&1)" || doc_rc=$?
      if [ "$doc_rc" = "0" ]; then
        printf '  ok   doc-preflight: заморозка %s прошла проверку\n' "$TARGET" >&2
      elif [ "$doc_rc" = "2" ]; then
        die "doc-preflight: нечем проверить: $(printf '%s' "$doc_out" | tr '\n' ' ' | tail -c 240)"
      else
        die "doc-preflight: $(printf '%s' "$doc_out" | tr '\n' ' ' | tail -c 240)"
      fi
      ;;
    1) : ;;
    2) die "doc-preflight: мальформный doc-контракт: $(printf '%s' "$_doc_type_out" | tr '\n' ' ' | tail -c 240)" ;;
    3) die "doc-preflight: тип doc-контракта не определяется: $(printf '%s' "$_doc_type_out" | tr '\n' ' ' | tail -c 240)" ;;
    *) die "doc-preflight: тип doc-контракта: неизвестный rc=$_doc_type_rc: $(printf '%s' "$_doc_type_out" | tr '\n' ' ' | tail -c 240)" ;;
  esac
fi

# ── 7. тег ────────────────────────────────────────────────────────────────────


# Существующий тег — отказ САМОГО git, и печатается его сообщением: своя проверка «а есть ли
# тег» была бы вторым разбором того же предмета и разошлась бы с git молча (гонка между
# проверкой и созданием).
tag="frozen/$dir/$NNN/$v"
if ! out="$(g tag -a "$tag" -m "$REASON" 2>&1)"; then
  printf 'ОТКАЗ: тег %s не создан: %s\n' "$tag" "$out" >&2
  exit 1
fi
printf 'v%s\n' "$v"
printf '  ok   заморожено: %s → %s («%s»)\n' "$TARGET" "$tag" "$REASON" >&2