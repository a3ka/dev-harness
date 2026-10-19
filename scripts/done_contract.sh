#!/usr/bin/env bash
# Писатель тега done/contracts/<NNN>/<v> (контракт 038, Н-116): единственный
# законный путь поставить done-тег. Проверяет ПРОВОДКА контракта через
# check_provodka.sh (шаг 6), ПОТРЕБИТЕЛЕЙ через check_consumers.sh (шаг 6а —
# после ПРОВОДКИ, до клапана), вердикт ревьюера, закоммиченность контракта и
# клапан владельца. Тег ставится аннотированный; реестр заморозок НЕ пишется
# (замер frontier §0; минт-строки пишет дверь 031).
#
# Грамматика — ЕДИНЫЙ источник контракт 038 §Инварианты 4; фразы отказов
# побайтово. Парсинг anchored `sed -nE` (канон check_spec_ready.sh:93–94).
#
# Контракт API:
#   вход: $1 = <отн-путь-контракта> (относительно cwd), $2 = "<причина>";
#   rc 0 — тег поставлен; stdout: v<N>;
#   rc 1 — отказ с ИМЕНОВАННОЙ причиной (stderr); тега нет.
#
#   bash scripts/done_contract.sh <отн-путь-контракта> "<причина>"
#
# Коды возврата: 0 — тег поставлен, 1 — отказ, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
TARGET="${1:?использование: $0 <contracts/NNN-*.md> \"<причина>\" [корень]}"
REASON="${2-}"  # пустая причина допустима — проверяется ниже отдельной веткой
# ROOT: 3-й аргумент ИЛИ (после env-гигиены) cwd-репозиторий — написатель ВДВОЙНЕ
# важна устойчивость к отравленному окружению.
if [ -n "${3:+x}" ]; then ROOT="${3}"; else ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; fi
# Причина пуста — отказ ДО всех остальных проверок (шаг 3)
if [ -z "${REASON//[[:space:]]/}" ]; then
  die "done: причина пуста"
fi

# 996 (Б-5/Б-9): ЕДИНЫЙ резолв workflowPaths через функцию project_paths_resolve
# из подключённой выше scripts/next_id.sh (пакет A/Б-5, исправление toy-миров —
# см. freeze_contract.sh:84-96). Дверь больше НЕ вызывает project_workflow.sh
# отдельным bash-процессом.
_pr_paths="$(project_paths_resolve "$ROOT" 2>/dev/null)" \
  || die "ОТКАЗ: профиль битый или workflowPaths вне репо: $(project_paths_resolve "$ROOT" 2>&1 >/dev/null)"
_PROFILE_VERDICTS_BASE="$(printf '%s' "$_pr_paths" | jq -r '.verdicts' 2>/dev/null || true)"
_PROFILE_REGISTRY_PATH="$(printf '%s' "$_pr_paths" | jq -r '.registry' 2>/dev/null || true)"
_PROFILE_CONTRACTS_BASE="$(printf '%s' "$_pr_paths" | jq -r '.contracts' 2>/dev/null || true)"
[ -n "$_PROFILE_VERDICTS_BASE" ] && [ -n "$_PROFILE_REGISTRY_PATH" ] && [ -n "$_PROFILE_CONTRACTS_BASE" ] \
  || die "ОТКАЗ: project_paths_resolve вернул пустой путь"
unset _pr_paths
# dir-суффиксы для роли ревьюера (done). Аналогия freeze: было — корневой
# `verdicts/review`, теперь профильный review.
# Relative form of verdicts (для cd-канонизации и `git -C $ROOT cat-file`):
case "$_PROFILE_VERDICTS_BASE" in
  "$ROOT"/*) _PROFILE_VERDICTS_REL="${_PROFILE_VERDICTS_BASE#"$ROOT"/}" ;;
  *)         _PROFILE_VERDICTS_REL="${_PROFILE_VERDICTS_BASE#/}" ;;
esac
_PROFILE_VERDICTS_DIR="${_PROFILE_VERDICTS_REL%/}/review"
unset _PROFILE_VERDICTS_REL _PROFILE_VERDICTS_BASE
# Контрактная форма: done/contracts/<NNN>/<v> — независимо от того, лежит ли
# contracts под `.harness/tasks` или в корне `contracts/`. Тег-каталог всегда
# `contracts` (прецедент freeze_contract.sh:139-141).
_PROFILE_CONTRACTS_DIR="${_PROFILE_CONTRACTS_BASE%/}"
( cd "$ROOT" 2>/dev/null && git rev-parse --verify HEAD >/dev/null 2>&1 ) || skip "в $ROOT нет ни одного коммита — done-писать нечего"

# ── 2. basename-грамматика NNN ────────────────────────────────────────────────
base="${TARGET##*/}"
# 996 (Б-6) К1: профильный путь предпочтителен; корневой contracts/ допустим
# ТОЛЬКО когда профиль не уводит workflowPaths в другую раскладку. План —
# plans/, всегда.
# Профильный путь от `project_paths_resolve` приходит в форме абсолютного
# (`<REPO_ABS>/<wp.contracts>`). Для сравнения с TARGET (относительным)
# получаем ПОСЛЕДНИЙ суффикс относительно ROOT.
case "$_PROFILE_CONTRACTS_BASE" in
  "$ROOT"/*) _PROFILE_CONTRACTS_REL="${_PROFILE_CONTRACTS_BASE#"$ROOT"/}" ;;
  *)         _PROFILE_CONTRACTS_REL="${_PROFILE_CONTRACTS_BASE#/}" ;;
esac
_PR_CONTRACTS="${_PROFILE_CONTRACTS_REL%/}/"
_ROOT_CONTRACTS_OK=0
case "${_PROFILE_CONTRACTS_REL:-contracts}" in
  contracts|"") _ROOT_CONTRACTS_OK=1 ;;
esac
_accepted=0
case "$TARGET" in
  plans/*) _accepted=1; dir="plans" ;;
  "${_PR_CONTRACTS}"*) _accepted=1; dir="contracts" ;;  # профильный — главный
  contracts/*)
    if [ "$_ROOT_CONTRACTS_OK" = "1" ]; then
      _accepted=1; dir="contracts"  # корневой только если профиль его и просит
    fi
    ;;
esac
[ "$_accepted" -eq 1 ] || die "done: имя контракта не по грамматике NNN: $TARGET"
unset _PROFILE_CONTRACTS_BASE _PROFILE_CONTRACTS_REL _PR_CONTRACTS _ROOT_CONTRACTS_OK
ARTIFACT_NUMBER=""
rc=0
parse_artifact_basename "$base" || rc=$?
if [ "$rc" -ne 0 ] || [ -z "${ARTIFACT_NUMBER:-}" ]; then
  die "done: имя контракта не по грамматике NNN: $base"
fi
NNN="$(printf '%03d' "$ARTIFACT_NUMBER")"

# ── 4. контракт закоммичен на HEAD ────────────────────────────────────────────
# TARGET: если абсолютный — отрезать ROOT-префикс.
case "$TARGET" in
  /*) TARGET_REL="${TARGET#$ROOT/}" ;;
  *)  TARGET_REL="$TARGET" ;;
esac
[ -f "$ROOT/$TARGET_REL" ] || die "done: контракт не закоммичен на HEAD: $TARGET_REL не существует"
head_blob="$(cd "$ROOT" && git rev-parse --verify --quiet "HEAD:$TARGET_REL" || true)"
[ -n "$head_blob" ] || die "done: контракт не закоммичен на HEAD: $TARGET_REL на HEAD отсутствует"
work_blob="$(cd "$ROOT" && git hash-object -- "$TARGET_REL")"
[ "$work_blob" = "$head_blob" ] || die "done: контракт не закоммичен на HEAD: $TARGET_REL в рабочем дереве отличается от HEAD (блобы $work_blob и $head_blob)"
# Файлы verdicts/review/contracts-<NNN>-*.md на HEAD; если несколько —
# свежий по коммит-истории. Первая строка → trim + case-fold → равенство
# `accept` (НЕ префикс; «Acceptance criteria met», «accepted» → вне грамматики).
# ОДНОВРЕМЕННО: первая строка ОБЯЗАНА быть `ACCEPT` | `FAIL` | `ESCALATE`.
vmax=0
vfiles="$(cd "$ROOT" && git ls-tree -r --name-only HEAD -- "${_PROFILE_VERDICTS_DIR%/}/" 2>/dev/null | grep -E "^${_PROFILE_VERDICTS_DIR%/}/contracts-$NNN-[^/]*\.md$" | sort -V || true)"
if [ -z "$vfiles" ]; then
  die "done: вердикт ревьюера не найден: ${_PROFILE_VERDICTS_DIR%/}/contracts-$NNN-*.md"
fi
# Свежий по коммит-истории: перебираем в обратном хронологическом порядке
freshest=""
freshest_cid=""
freshest_first=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  # Ошибка git — отказ, а не пропуск/«не свежее»: иначе свежий FAIL выпадал из сравнения
  # и done проходил по более старому accept (аудит 2026-10-16).
  cid_rc=0
  cid="$(cd "$ROOT" && git log --format=%H -1 -- "$f" 2>/dev/null)" || cid_rc=$?
  [ "$cid_rc" -eq 0 ] || die "done: история вердикта не читается (git log rc=$cid_rc): $f — проверить невозможно"
  [ -n "$cid" ] || die "done: у вердикта на HEAD нет коммита в истории: $f — проверить невозможно"
  anc_rc=1
  if [ -n "$freshest_cid" ]; then
    anc_rc=0
    ( cd "$ROOT" && git merge-base --is-ancestor "$freshest_cid" "$cid" 2>/dev/null ) || anc_rc=$?
    [ "$anc_rc" -le 1 ] || die "done: порядок вердиктов не читается (merge-base rc=$anc_rc): $f — проверить невозможно"
  fi
  if [ -z "$freshest_cid" ] || [ "$anc_rc" -eq 0 ]; then
    freshest="$f"; freshest_cid="$cid"
    freshest_first="$(cd "$ROOT" && git cat-file -p "HEAD:$f" 2>/dev/null | sed -n 1p | tr -d '\r')"
    freshest_first="${freshest_first#"${freshest_first%%[![:space:]]*}"}"
    freshest_first="${freshest_first%"${freshest_first##*[![:space:]]}"}"
  fi
done <<< "$vfiles"
vcount=$(printf '%s\n' "$vfiles" | wc -l)

norm="$(printf '%s' "$freshest_first" | tr '[:upper:]' '[:lower:]')"
case "$norm" in
  accept) ;;
  fail)
    if [ "$vcount" -gt 1 ]; then
      die "done: несколько вердиктов, свежий $(basename "$freshest") не accept"
    fi
    die "done: вердикт ревьюера FAIL"
    ;;
  escalate)
    if [ "$vcount" -gt 1 ]; then
      die "done: несколько вердиктов, свежий $(basename "$freshest") не accept"
    fi
    die "done: вердикт ревьюера ESCALATE"
    ;;
  *)
    if [ "$vcount" -gt 1 ]; then
      die "done: несколько вердиктов, свежий $(basename "$freshest") не accept"
    fi
    die "done: вердикт вне грамматики: $freshest_first"
    ;;
esac

# ── 996: гейт сверки с источниками (ДО тега) ────────────────────────────────
# При объявленном sourceCanon — вызов check_project_sources.sh (stage=done).
# Отказ gate → rc 1 с маркером SOURCE_GATE_FAILED/INVALID/MISSING/UNAVAILABLE.
# Без канона — gate не запускается (К6 «без канона → rc 0 без запуска»).
# Гейт вооружён ТОЛЬКО при наличии harness.project.json в корне (режим проекта);
# в не-проектном режиме (харнес сам как проект, без harness.project.json) —
# действующее поведение двери НЕ меняется (К18/К19).
if [ -x "$SELF_DIR/check_project_sources.sh" ] && [ -f "$ROOT/harness.project.json" ]; then
  srcs_out="$(bash "$SELF_DIR/check_project_sources.sh" --repo "$ROOT" --contract "$TARGET_REL" --stage done 2>&1)" || die "source gate: $srcs_out"
fi
# ── 6. ПРОВОДКА через барьер check_provodka.sh ────────────────────────────────
# Барьер работает относительно КОРНЯ репозитория (не каталога контракта) —
# пути ПРОВОДКА даны относительно корня дерева (канон freeze_contract.sh:59).
# ROOT задан выше (3-й аргумент) или default к каталогу скрипта.
contract_rel="$TARGET"
contract_rel="$(printf '%s' "$contract_rel" | sed 's|^\./||; s|//|/|g')"
prov_rc=0
prov_out=""
prov_out="$(cd "$ROOT" && bash "$SELF_DIR/check_provodka.sh" "$ROOT" "$contract_rel" 2>&1)" || prov_rc=$?
if [ "$prov_rc" -ne 0 ]; then
  if [ "$prov_rc" = "2" ]; then
    die "done: ПРОВОДКА не проверена (rc 2)"
  fi
  first_prov_phrase="$(printf '%s' "$prov_out" | head -n 1)"
  die "done: ПРОВОДКА красна: $first_prov_phrase"
fi
# ── 6а. ПОТРЕБИТЕЛИ (после ПРОВОДКИ, ДО клапана)
# Окно = frozen/contracts/<NNN>/<v> .. HEAD на момент тега DONE.
# check_consumers.sh <root> <contract>.
cons_rc=0
cons_out=""
cons_out="$(bash "$SELF_DIR/check_consumers.sh" "$ROOT" "$contract_rel" 2>&1)" || cons_rc=$?
if [ "$cons_rc" -ne 0 ]; then
  if [ "$cons_rc" = "2" ]; then
    die "done: потребители не проверены (rc 2)"
  fi
  first_cons_phrase="$(printf '%s' "$cons_out" | head -n 1)"
  die "done: потребители 116 красны: $first_cons_phrase"
fi

# ── 7. клапан: РАЗРЕШИЛ-ВЛАДЕЛЕЦ на v>1 или на красную ПРОВОДКУ ─────────────
# (мы УЖЕ прошли ПРОВОДКА rc 0 — значит клапан НЕ открывает ничего; v>1 ещё
# не вычислили — вычислим ниже и проверим.)

# ── вычисляем v = max+1 по тегам done/contracts/<NNN>/ ────────────────────────
done_vmax=0
# Ошибка перечисления версий — именованный отказ, не v1 вслепую (992): при
# существующем v2 пустой перечень прежде молча выдумывал v1 и тег писался
# без чтения списка. rc process substitution родителем не наблюдался.
dfer_rc=0
dfer_out="$(cd "$ROOT" && git for-each-ref --format='%(refname)' "refs/tags/done/contracts/$NNN/" 2>/dev/null)" || dfer_rc=$?
[ "$dfer_rc" -eq 0 ] || die "done: перечень версий не читается (git for-each-ref rc=$dfer_rc): refs/tags/done/contracts/$NNN/ — проверить невозможно, версия не угадывается"
while IFS= read -r t; do
  [ -n "$t" ] || continue
  vn="$(printf '%s' "$t" | sed -nE 's@.*done/contracts/[0-9]+/([0-9]+)@\1@p')"
  [ -n "$vn" ] || continue
  [ "$vn" -gt "$done_vmax" ] 2>/dev/null && done_vmax="$vn"
done <<<"$dfer_out"
v=$((done_vmax + 1))

if [ "$v" -gt 1 ]; then
  # ASCII-дефис U+002D, grep -F литерал
  if ! printf '%s' "$REASON" | grep -Fq 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'; then
    die "done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине"
  fi
fi

# ── 8. тег done/contracts/<NNN>/<v> с причиной в аннотации ──────────────────
tag="done/contracts/$NNN/$v"
if ! out="$(cd "$ROOT" && git -c user.name=Fixture -c user.email=fixture@local tag -a "$tag" -m "$REASON" 2>&1)"; then
  printf 'ОТКАЗ: тег %s не создан: %s\n' "$tag" "$out" >&2
  exit 1
fi
