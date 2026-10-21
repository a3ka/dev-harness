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
ROOT_DEFAULT="$(cd "$SELF_DIR/.." && pwd)"
ROOT="${3:-}"

[ -n "$TARGET" ] || die "не назван предмет: bash scripts/freeze_contract.sh <plans/NNN-*.md|contracts/NNN-*.md> \"<причина>\" [корень]"

# ── И-3 (контракт 060): рука HARNESS_WORKFLOW_ROOT — env > дефолт (после $3) ───
# Лестница (Граница-2): $3 > env > дефолт. Явный $3 перебивает env, и при
# валидном $3 env НЕ читается — лестница короткого замыкания (критик 060-к2
# Б1; контрольная клетка к6е: валидный $3 + относительный неиспользуемый env →
# $3 побеждает, N1 нет, реестр в $3-репо). env оперативен ТОЛЬКО когда $3 не
# передан: относительное значение → именованный отказ N1 rc 1 ДО любого
# git-вызова (Граница-3: значение вставляется в пути git-операций — class
# path-injection; прецедент PSTATE-base workshop:686-691).
if [ -z "$ROOT" ] && [ -n "${HARNESS_WORKFLOW_ROOT:-}" ]; then
  case "${HARNESS_WORKFLOW_ROOT}" in
    /*)
      ROOT="$HARNESS_WORKFLOW_ROOT"
      ;;
    *)
      die "workflow ОТКАЗ: HARNESS_WORKFLOW_ROOT обязан быть абсолютным путём, получен: $HARNESS_WORKFLOW_ROOT"
      ;;
  esac
fi
[ -n "$ROOT" ] || ROOT="$ROOT_DEFAULT"

# 996 (Б-5/Б-9): ЕДИНЫЙ резолв workflowPaths через функцию project_paths_resolve
# из подключённой выше scripts/next_id.sh (пакет A/Б-5, исправление toy-миров
# fixtures/freeze_contract/fail_closed_992.py: дверь больше НЕ вызывает
# project_workflow.sh отдельным bash-процессом — функция доступна через source).
# Гард на относительность/reality/symlink живёт в project_paths_resolve; здесь —
# лишь извлечение имён ключей и проверка непустоты.
_pr_paths="$(project_paths_resolve "$ROOT" 2>/dev/null)" \
  || die "ОТКАЗ: профиль битый или workflowPaths вне репо: $(project_paths_resolve "$ROOT" 2>&1 >/dev/null)"
_PROFILE_VERDICTS_BASE="$(printf '%s' "$_pr_paths" | jq -r '.verdicts' 2>/dev/null || true)"
_PROFILE_REGISTRY_PATH="$(printf '%s' "$_pr_paths" | jq -r '.registry' 2>/dev/null || true)"
_PROFILE_CONTRACTS_BASE="$(printf '%s' "$_pr_paths" | jq -r '.contracts' 2>/dev/null || true)"
[ -n "$_PROFILE_VERDICTS_BASE" ] && [ -n "$_PROFILE_REGISTRY_PATH" ] && [ -n "$_PROFILE_CONTRACTS_BASE" ] \
  || die "ОТКАЗ: project_paths_resolve вернул пустой путь"
unset _pr_paths
# dir-суффиксы для роли критика (freeze). Объявляется ПОСЛЕ захвата — раньше
# freeze работал по корневому `verdicts/critic`, теперь профильный critic.
# dir-суффиксы (verdicts/critic для freeze, registry/, contracts/) — после
# захвата «контрактного относительного» пути, чтобы (1) TARGET сравнивался
# с относительным, и (2) `git -C ROOT cat-file -p HEAD:<relative>` работал.
case "$_PROFILE_VERDICTS_BASE" in
  "$ROOT"/*) _PROFILE_VERDICTS_REL="${_PROFILE_VERDICTS_BASE#"$ROOT"/}" ;;
  *)         _PROFILE_VERDICTS_REL="${_PROFILE_VERDICTS_BASE#/}" ;;
esac
_PROFILE_VERDICTS_DIR="${_PROFILE_VERDICTS_REL%/}/critic"
unset _PROFILE_VERDICTS_REL _PROFILE_VERDICTS_BASE
case "$_PROFILE_CONTRACTS_BASE" in
  "$ROOT"/*) _PROFILE_CONTRACTS_REL="${_PROFILE_CONTRACTS_BASE#"$ROOT"/}" ;;
  *)         _PROFILE_CONTRACTS_REL="${_PROFILE_CONTRACTS_BASE#/}" ;;
esac
_PROFILE_CONTRACTS_DIR="${_PROFILE_CONTRACTS_REL%/}/"
_PROFILE_REGISTRY_PATH_REL="${_PROFILE_REGISTRY_PATH#/}"; _PROFILE_REGISTRY_PATH_REL="${_PROFILE_REGISTRY_PATH_REL%"$ROOT"/*}"
# Для registry тот же приём (относительный путь от ROOT):
case "$_PROFILE_REGISTRY_PATH" in
  "$ROOT"/*) _PROFILE_REGISTRY_PATH="${_PROFILE_REGISTRY_PATH#"$ROOT"/}" ;;
  *)         _PROFILE_REGISTRY_PATH="${_PROFILE_REGISTRY_PATH#/}" ;;
esac
unset _PROFILE_CONTRACTS_REL _PROFILE_REGISTRY_PATH_REL

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
# 996 (Б-6) К1: путь контракта — профильный (`workflowPaths.contracts`) или
# корневые `contracts/`, `plans/` (харнес сам как проект, без harness.project.json).
# Корневые `contracts/` допустимы ТОЛЬКО когда профиль НЕ объявляет иной путь;
# иначе freeze/done молча откажется на корневой приманке (модель угроз L51).
# План по-прежнему хранится в корневом `plans/` — freeze плана через эту дверь
# вне темы 996 (для продуктового прогресса), и plans/ сохраняется.
_CONTRACTS_ROOT="$_PROFILE_CONTRACTS_DIR"   # например ".harness/tasks/" или "contracts/"
# Профильный путь от `project_paths_resolve` приходит в форме АБСОЛЮТНОГО пути
# (`<REPO_ABS>/<wp.contracts>`). Для сравнения с TARGET (относительным)
# выделяем ПОСЛЕДНИЙ суффикс относительно REPO_ABS: всё, что после REPO_ABS.
# Это «контрактный относительный» — то, что профиль ОБЪЯВИЛ, как JSON-значение.
case "$_CONTRACTS_ROOT" in
  "$ROOT"/*) _CONTRACTS_REL="${_CONTRACTS_ROOT#"$ROOT"/}" ;;
  *)         _CONTRACTS_REL="${_CONTRACTS_ROOT#/}" ;;
esac
_CONTRACTS_REL="${_CONTRACTS_REL%/}/"   # trailing "/" для префиксной проверки
# Корневой источник разрешён ТОЛЬКО если профиль не уводит workflowPaths в
# другую раскладку. Если профильный путь — ровно `contracts/` (либо харнес
# без harness.project.json), root `contracts/` допустим.
_ROOT_CONTRACTS_OK=0
case "$_CONTRACTS_REL" in
  contracts/|"") _ROOT_CONTRACTS_OK=1 ;;
esac
base="${TARGET##*/}"
# Префиксная проверка: TARGET либо начинается с `${_CONTRACTS_REL%/}/` (профиль),
# либо с `plans/` (всегда), либо с `contracts/` (только если _ROOT_CONTRACTS_OK).
_accepted=0
case "$TARGET" in
  "${_CONTRACTS_REL%/}/"*) _accepted=1; dir="${_CONTRACTS_REL%%/*}" ;;
  plans/*)                 _accepted=1; dir="plans" ;;
  contracts/*)
    if [ "$_ROOT_CONTRACTS_OK" = "1" ]; then
      _accepted=1; dir="contracts"
    fi
    ;;
esac
if [ "$_accepted" -ne 1 ]; then
  die "замораживается только plans/NNN-*.md либо ${_CONTRACTS_REL%/}/NNN-*.md${_ROOT_CONTRACTS_OK:+ либо contracts/NNN-*.md} (корневой contracts/ при профиле workflowPaths.contracts=${_CONTRACTS_REL%/} не источник); получено: $TARGET"
fi
unset _CONTRACTS_REL _ROOT_CONTRACTS_OK
ARTIFACT_NUMBER=""
rc=0
parse_artifact_basename "$base" || rc=$?
if [ "$rc" -ne 0 ] || [ -z "${ARTIFACT_NUMBER:-}" ]; then
  die "замораживается только plans/NNN-*.md либо ${_CONTRACTS_ROOT%/}/NNN-*.md либо contracts/NNN-*.md; имя «$base» вне грамматики NNN-<slug>.md (ровно три цифры, дефис, не-цифра)"
fi
case "$base" in
  *.md) ;;
  *) die "замораживается только plans/NNN-*.md либо ${_CONTRACTS_ROOT%/}/NNN-*.md либо contracts/NNN-*.md; у «$base» нет расширения .md" ;;
esac
NNN="$(printf '%03d' "$ARTIFACT_NUMBER")"
# 996 К1: dir нормализуется к литералу `contracts` для тегов frozen/<dir>/...
# plans остаются plans. Профильный contracts_path — это АЛИАС корневого
# `contracts`, не новый класс.
if [ "$dir" != "plans" ] && [ "$dir" != "contracts" ]; then
  # dir — профильный (например, .harness/tasks). Теги frozen/contracts/<NNN>/<v>
  # и frozen/.harness/tasks/<NNN>/<v> — это разные ТЕГИ; контракт 996 К1 явно
  # говорит: профильная ветвь использует план тегов как `contracts/`. Нормализуем.
  dir="contracts"
fi
# ── 3а. вне-плана (контракт 084 §И-8) ──────────────────────────────────────
# Гейт на заморозку контракта вне действующей/следующей пары plan.tsv. Только dir=contracts:
# планов ещё нет (предмет 008), и заморозка плана по плану не существует. Читаем plan.tsv и
# closed-without-done.tsv как блобы HEAD (Р3: незакоммиченная правка заморозку не открывает;
# Р4: freeze без плана в живом дереве — пропуск с именованной строкой, fail-closed держит
# check_plan в CI и уставное кольцо). Пары P0/P1 — статусы «открыт» по строкам плана из HEAD.
# Отказ атомарен: до §4 (HEAD-блоб TARGET), §5 (причина), §6 (verdict), §7 (тег), §8 (реестр),
# §9 (коммит реестра) — тега и записи в registry/contracts.tsv нет; HEAD не сдвинут; дерево чисто.
if [ "$dir" = contracts ]; then
  # Подключение от СВОЕГО каталога: код lib_plan.sh — не из проверяемого дерева.
  if [ -f "$SELF_DIR/lib_plan.sh" ]; then
    # 996 К6: передаём профильный реестр в lib_plan.sh.
    export LIB_PLAN_REGISTRY="${_PROFILE_REGISTRY_PATH:-registry}"
    # shellcheck disable=SC1091
    . "$SELF_DIR/lib_plan.sh"
    # Чтение плана через command substitution стёрло бы хвостовой LF; пишем блоб напрямую
    # в tmp, чтобы байт-инвариант И-1 (UTF-8/LF) сохранился (А-084-2). Проверка «не пусто»
    # НЕ делается: пустой закоммиченный registry/plan.tsv — это СУЩЕСТВУЮЩИЙ файл
    # (Н3-3: ранее ветвь `elif [ ! -s … ]` трактовала 0-байт как «план не заведён»,
    # давая rc 0 и тег — расхождение с check_plan.sh, который для того же HEAD даёт
    # rc 1 «план не разбирается: строка 1:» через ту же plan_parse). Единая грамматика:
    # только отсутствие файла HEAD:registry/plan.tsv — «план не заведён», пустой
    # существующий — отказ plan_parse (та же строка, что у check_plan.sh на ТОМ ЖЕ HEAD).
    # 996 К6: путь реестра (plan.tsv, closed-without-done.tsv) — из профиля.
    _F084_plan_tmp="$(mktemp)"
    if ! g cat-file -p "HEAD:${_PROFILE_REGISTRY_PATH%/}/plan.tsv" > "$_F084_plan_tmp" 2>/dev/null; then
      rm -f "$_F084_plan_tmp"
      printf '  ok   план не заведён: проверка «вне плана» не применяется\n' >&2
    else
      if ! plan_parse "$_F084_plan_tmp"; then
        rm -f "$_F084_plan_tmp"
        die "план недоступен: ${P84_PLAN_ERR}"
      fi
      rm -f "$_F084_plan_tmp"
      # План разобран: P0/P1 по открытым строкам HEAD (head=1 — план и закрытия читаются
      # из HEAD-блобов, незакоммиченная правка заморозку не открывает, Р3).
      p84_p0p1 "$ROOT" 1
      # Принадлежность NNN паре ∈ {P0, P1} — литеральное сравнение строки модели, не grep
      # по id (символьные id могут совпасть с числом, V-2 ≠ 002).
      _F084_in_pair=0
      for _F084_i in "${!P84_ID[@]}"; do
        if [ "${P84_ID[$_F084_i]}" = "$NNN" ]; then
          _F084_rowpair="${P84_PAIR[$_F084_i]}"
          if [ "$_F084_rowpair" = "$P84_P0" ] || [ "$_F084_rowpair" = "$P84_P1" ]; then
            _F084_in_pair=1
          fi
          break
        fi
      done
      if [ "$_F084_in_pair" -ne 1 ]; then
        die "контракт вне плана: ${NNN} — не в текущей/следующей паре registry/plan.tsv (P0 ${P84_P0}, P1 ${P84_P1})"
      fi
    fi
  else
    # bootstrap-окно: до приземления файла implementer'ом — пропуск с именованной строкой,
    # как в §6а-тер (conditional `if [ -f … ]`).
    printf '  ok   план не заведён: проверка «вне плана» не применяется\n' >&2
  fi
fi

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
# Ошибка перечисления версий — именованный отказ, не v1 вслепую (992): при
# существующем v2 пустой перечень прежде молча выдумывал v1. rc process
# substitution родителем не наблюдался — читаем список с rc в переменную.
fer_rc=0
fer_out="$(g for-each-ref --format='%(refname)' "refs/tags/frozen/$dir/$NNN/" 2>/dev/null)" || fer_rc=$?
[ "$fer_rc" -eq 0 ] || die "перечень версий не читается (git for-each-ref rc=$fer_rc): refs/tags/frozen/$dir/$NNN/ — проверить невозможно, версия не угадывается"
while IFS= read -r t; do
  [ -n "$t" ] || continue
  if [[ "$t" =~ ^refs/tags/frozen/${dir}/${NNN}/([0-9]+)$ ]]; then
    k=$((10#${BASH_REMATCH[1]}))
    [ "$k" -gt "$vmax" ] && vmax="$k"
  fi
done <<<"$fer_out"
v=$((vmax + 1))

verdict="${_PROFILE_VERDICTS_DIR%/}/${dir}-${NNN}-v${v}.md"
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

# ── 6а. SPEC-PREFLIGHT (контракт 036 §Freeze) ────────────────────────────────
# Класс-гейт спек-точности: каждая приёмочная проба/замер/СПАСЕНО черновика
# проверены ДО записи тега. Красный прогон = rc 1 «ОТКАЗ: spec-preflight 036 красен:
# <первая причина>», тег/реестр не тронуты (отказ атомарен). Предмет:
# scripts/check_spec_ready.sh <корень> <контракт>; отказ — die rc=1 без тега.
# rc ловится напрямую: прежняя форма `if ! out=…; then spec_rc=$?` давала spec_rc=0
# (rc отрицания), и прогон с последней строкой OK и rc≠0 проходил (аудит 2026-10-16).
spec_rc=0
out="$(cd "$ROOT" && bash "$SELF_DIR/check_spec_ready.sh" "$ROOT" "$TARGET" 2>&1)" || spec_rc=$?
# rc 2 (NOT_IMPLEMENTED) трактуется как fail-closed: нечем проверить ≠
# проверено, иначе красный прогон прятался бы под нехватку инструмента.
[ "$spec_rc" -eq 0 ] || die "spec-preflight 036 красен (rc=$spec_rc): $(printf '%s' "$out" | head -n 1)"
# ── 6а-bis. CONSUMERS-GATE (контракт 038 §Freeze-верификация потребителей) ─
# Проводка в freeze: реестр → грамматика → коммитность → причина → вердикт →
# spec-preflight (036) → check_consumers (ЭТОТ) → doc-preflight (027) →
# кап → тег. Окно = последний frozen/contracts/<NNN>/<v>..HEAD НА МОМЕНТ ВЫЗОВА.
# Красный = rc 1 «ОТКАЗ: потребители 116 красны: <первая причина>»; rc 2 →
# rc 1 fail-closed.
if [ -f "$SELF_DIR/check_consumers.sh" ]; then
  cons_out=""
  cons_rc=0
  cons_out="$(cd "$ROOT" && bash "$SELF_DIR/check_consumers.sh" "$ROOT" "$TARGET" 2>&1)" || cons_rc=$?
  if [ "$cons_rc" -ne 0 ]; then
    cons_first="$(printf '%s' "$cons_out" | head -n 1)"
    die "потребители 116 красны: $cons_first"
  fi
fi
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
# ── 6а-ter. PRECISION-GATE (контракт 043 §Инварианты п.7, freeze-time backstop) ─
# Три задачи гейта: зона-коллизия union, живая полярность case-файлов,
# паритет CI — все три до записи тега. Красный прогон = rc 1 «ОТКАЗ:
# precision-гейт 043 красен: <первая причина>», тег/реестр не тронуты
# (отказ атомарен, тот же приём, что 038 §6а-bis несёт). rc 2
# (NOT_IMPLEMENTED — гейт недоступен) трактуется как fail-closed rc 1
# (норма 036 §Freeze). Условный `if [ -f … ]` — bootstrap-защита,
# аналогичная consumers-gate 038 (окно между заморозкой ЭТОГО контракта
# и приземлением файла implementer'ом).
if [ -f "$SELF_DIR/check_precision_gate.sh" ]; then
  pg_out=""
  pg_rc=0
  pg_out="$(cd "$ROOT" && bash "$SELF_DIR/check_precision_gate.sh" "$ROOT" "$TARGET" 2>&1)" || pg_rc=$?
  if [ "$pg_rc" -ne 0 ]; then
    pg_first="$(printf '%s' "$pg_out" | head -n 1)"
    die "precision-гейт 043 красен: $pg_first"
  fi
fi
target_content="$(g cat-file -p "HEAD:$TARGET" 2>/dev/null || true)"
_doc_type_tmp="$(mktemp -t doc027.XXXXXX 2>/dev/null || true)"
_doc_type_rc=0
_doc_type_out=""
if [ -n "${_doc_type_tmp:-}" ]; then
  printf '%s' "$target_content" > "$_doc_type_tmp"
  _doc_type_out="$(cd "$ROOT" && node "$SELF_DIR/doc_contract.ts" --type "$_doc_type_tmp" 2>&1)" || _doc_type_rc=$?
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

# ── 6в. КАП КРУГОВ: третий круг — арбитр или владелец ──────────────────────────
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
g log --reverse -M --format='@%H' --name-status -- "${_PROFILE_VERDICTS_DIR%/}/${dir}-${NNN}-v*.md" 2>/dev/null \
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
  arb_files="$(g ls-tree -r --name-only HEAD -- ":(literal)${_PROFILE_VERDICTS_DIR%/}/../arbitration/" 2>/dev/null | grep '\.md$' || true)"
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


# ── 6г. ГЕЙТ ПРЕДПОСЫЛОК (контракт 122 §Г3) ───────────────────────────────────
# Контракт, текст которого заявляет CI-пути (.github/workflows/ или
# .harness/ci.json), обязан нести поле `ПРЕДПОСЫЛКИ:`; при --freeze каждый
# объявленный secret/variable обязан уже существовать в репозитории проекта
# (`gh secret|variable list -R <origin>`) — заморозка не заводит предпосылку,
# она фиксирует, что предпосылка заведена (незаведённый секрет = мигающий CI).
# ФЛАГ --freeze ОБЯЗАТЕЛЕН (§Г3 «Подключение: freeze_contract — с --freeze»): без
# него гейт судит только грамматику поля, и контракт с незаведённым секретом
# замораживался бы, напечатав PREDPOSYLKI_OK (боль 995 п.4).
# ГЕЙТ ИДЁТ ПОСЛЕ существующих проверок и ДО §7: отказ rc 1 — тег и реестр не
# тронуты (тот же атомарный приём, что 6а/6а-бис/6а-тери). rc 2 (ошибка вызова/
# среды) трактуется как fail-closed rc 1. Инварианты заморозки 013/027/036/038/
# 043/060/078/084/992/996 не тронуты — это отдельная нога после них.
# ОТСУТСТВИЕ ГЕЙТА — ОТКАЗ, а не пропуск: молчащий `-x` оставлял бы заморозку
# непроверенной (fail-open). Гейт зовётся через bash, поэтому бит исполнения не
# нужен — нужен читаемый файл.
if [ ! -r "$SELF_DIR/check_predposylki.sh" ]; then
  printf 'ОТКАЗ: гейт предпосылок 122 недоступен: нет читаемого %s\n' \
    "$SELF_DIR/check_predposylki.sh" >&2
  exit 1
fi
pp_rc=0
pp_out="$(bash "$SELF_DIR/check_predposylki.sh" "$ROOT" "$ROOT/$TARGET" --freeze 2>&1)" || pp_rc=$?
if [ "$pp_rc" -ne 0 ]; then
  printf 'ОТКАЗ: гейт предпосылок 122 красен (rc=%s): %s\n' \
    "$pp_rc" "$(printf '%s' "$pp_out" | head -n 1)" >&2
  exit 1
fi
printf '  ok   гейт предпосылок: %s\n' "$(printf '%s' "$pp_out" | tail -n 1)" >&2


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

# ── 8. реестр заморозок (контракт 036 §Freeze, г5б «писатель остаётся единственным»): ──
# тег ИМЕЕТ быть записан ⇒ строка манифеста registry/contracts.tsv записывается ТЕМ ЖЕ
# актом (отказ атомарен выше — тег/реестр не тронуты вместе). Формат строки: «NNN →
# <tag-object-sha>» где sha — tag-object-sha только что созданного frozen-тега (то, чем
# freeze владеет единолично с момента g tag -a). Идемпотентность: существующая строка
# с тем же NNN перезаписывается (двойная запись = два смысла одного идентификатора,
# правило 5 нормы).
tag_sha="$(g rev-parse --verify --quiet "$tag" 2>/dev/null || true)"
if [ -z "$tag_sha" ]; then
  printf 'ОТКАЗ: реестр не записан: tag-object-sha для %s не получен\n' "$tag" >&2
  exit 1
fi
reg_path="$ROOT/${_PROFILE_REGISTRY_PATH%/}/contracts.tsv"
mkdir -p "$ROOT/${_PROFILE_REGISTRY_PATH%/}"
tmp_reg="$(mktemp "${TMPDIR:-/tmp}/reg_036.XXXXXX" 2>/dev/null || mktemp)"
if [ -f "$reg_path" ]; then
  grep -v "^$NNN → " "$reg_path" > "$tmp_reg" 2>/dev/null || true
fi
printf '%s → %s\n' "$NNN" "$tag_sha" >> "$tmp_reg"
mv "$tmp_reg" "$reg_path"
# ── 9. самокоммит реестра (Н-132): freeze_contract коммитит свою запись, иначе
# registry/contracts.tsv остаётся uncommitted-modified после КАЖДОЙ заморозки и
# подхватывается случайным следующим коммитом любой identity/зоны. Атомарность
# с тегом: отказ коммита = die rc=1, тот же приём, что и при отказе `g tag -a` выше.
if ! out="$(g add ${_PROFILE_REGISTRY_PATH%/}/contracts.tsv && \
  g -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
    commit -m "freeze: registry $NNN → $tag_sha" -- ${_PROFILE_REGISTRY_PATH%/}/contracts.tsv 2>&1)"; then
  die "реестр не закоммичен: $out"
fi
printf '  ok   реестр закоммичен: %s → %s\n' "$NNN" "$tag_sha" >&2
printf '  ok   реестр записан: %s → %s\n' "$NNN" "$tag_sha" >&2
