#!/usr/bin/env bash
# Честная модель финального гарда done_project (контракт 096, круг 1)
# (см. оригинал ниже для полной шапки).
set -uo pipefail
TAB="$(printf '\t')"
die() { printf 'REFUSED: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
command -v git >/dev/null 2>&1 || ni "нет git"
command -v sha256sum >/dev/null 2>&1 || ni "нет sha256sum"
command -v awk >/dev/null 2>&1 || ni "нет awk"

usage() { printf 'usage: dover.sh --repo R [--class C] --task T [--issue I] [--pr N] [--project-id P] [--object-id O] [--commit-sha S] [--duration-min M] [--ci-min M] [--cost C] [--interventions N] [--notes TXT] [--resume] [--dry-run]\n' >&2; exit 1; }

REPO=""; KLASS=""; TASK=""; ISSUE=""; PR=""; PROJID=""; OID=""; SHA=""
DUR=""; CIM=""; COST=""; INTV=""; NOTES=""; RESUME=0; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --class) KLASS="${2:?}"; shift 2 ;;
    --task) TASK="${2:?}"; shift 2 ;;
    --issue) ISSUE="${2:?}"; shift 2 ;;
    --pr) PR="${2:?}"; shift 2 ;;
    --project-id) PROJID="${2:?}"; shift 2 ;;
    --object-id) OID="${2:?}"; shift 2 ;;
    --commit-sha) SHA="${2:?}"; shift 2 ;;
    --duration-min) DUR="${2:?}"; shift 2 ;;
    --ci-min) CIM="${2:?}"; shift 2 ;;
    --cost) COST="${2:?}"; shift 2 ;;
    --interventions) INTV="${2:?}"; shift 2 ;;
    --notes) NOTES="${2:?}"; shift 2 ;;
    --resume) RESUME=1; shift ;;
    --dry-run) DRY=1; shift ;;
    *) usage ;;
  esac
done
[ -n "$REPO" ] && [ -n "$TASK" ] || usage
[ -d "$REPO" ] || die "репозитория нет: $REPO"
case "$TASK" in *[!0-9]*) die "task не число: $TASK" ;; esac
NNN="$(printf '%03d' "$((10#$TASK))")"
case "${KLASS:-code}" in code|doc|research) ;; *) die "класс вне алфавита" ;; esac
KLASS="${KLASS:-code}"
[ -n "${PROJID:-}" ] || PROJID="toy"
[ -n "${OID:-}" ] || die "object-id обязателен"
case "$OID" in *[!0-9a-f]*|'') die "object-id не 64 hex: $OID" ;; esac
[ "${#OID}" -eq 64 ] || die "object-id не 64 hex"
[ -n "${SHA:-}" ] || SHA="$(cd "$REPO" && git rev-parse --short=7 HEAD)"
case "$SHA" in *[!0-9a-f]*|'') die "commit-sha не 7+ hex" ;; esac
[ -n "${NOTES:-}" ] || die "notes обязателен"
case "$NOTES" in *$TAB*|*[![:print:]]*) die "notes вне алфавита" ;; esac

# ── profile ──
PROFILE="$REPO/harness/done-profile.tsv"
[ -f "$PROFILE" ] || die "нет профиля doneProfile" # t96-m1

_repoId=""; _commands_cmds=(); _docs_cmds=(); _issuePolicy=""
while IFS= read -r line; do
  case "$line" in
    "repoId="*) _repoId="${line#repoId=}" ; continue ;;
    "projectId="*|"issueField="*|"tagFormat="*) continue ;;
  esac
  k1=""; k2=""; rest=""
  IFS="$TAB" read -r k1 k2 rest <<<"$line" || true
  case "$k1" in
    command) [ "$k2" = "$KLASS" ] || continue; _commands_cmds+=("$rest") ;;
    doc) [ "$k2" = "$KLASS" ] || continue; _docs_cmds+=("$rest") ;;
    issuePolicy) [ "$k2" = "$KLASS" ] || continue; _issuePolicy="$rest" ;;
  esac
done <"$PROFILE"
[ -n "$_repoId" ] || die "профиль: нет repoId"
[ -n "$_issuePolicy" ] || die "профиль: нет issuePolicy для класса $KLASS"

# ── И-1: priemka ──
contract_path="$(cd "$REPO" && ls contracts/${NNN}-*.md 2>/dev/null | head -1 || true)"
[ -n "$contract_path" ] || die "нет контракта"
cd "$REPO" 2>/dev/null
head_blob="$(git rev-parse --verify --quiet "HEAD:$contract_path" 2>/dev/null || true)"
[ -n "$head_blob" ] || die "контракт не закоммичен"
git show "HEAD:$contract_path" | grep -Fxq '## Приёмка' || die "нет приёмки" # t96-m1

# ── И-3: zone ──
_ZONES=()
while IFS= read -r line; do
  case "$line" in
    'ЗОНА '*)
      z="${line#'ЗОНА '}"
      for token in $z; do
        case "$token" in */*|*.*) _ZONES+=("$token") ;;
        esac
      done ;;
  esac
done < <(git show "HEAD:$contract_path")

# ── И-2: diff object ──
merge_sha="$(grep -F "published	$OID	" "$REPO/registry/candidates.tsv" 2>/dev/null | tail -1 | cut -f3 || true)"
[ -n "$merge_sha" ] || die "объект не опубликован" # t96-m2a
merge_parent="$(git -C "$REPO" rev-parse --verify "$merge_sha^1" 2>/dev/null || true)"
[ -n "$merge_parent" ] || die "merge не этого объекта"
diff_paths="$(git -C "$REPO" diff-tree --no-commit-id --name-only -r "$merge_parent" "$merge_sha" 2>/dev/null | sort -u)" # t96-m2
[ -n "$diff_paths" ] || die "пустой diff" # t96-m2
# zone check on diff paths (skip metadata .review, .omp)
for p in $diff_paths; do
  case "$p" in
    .review/*|.omp/*) continue ;;
  esac
  matched=0
  for z in "${_ZONES[@]}"; do
    case "$p" in "$z"*) matched=1; break ;; esac
  done
  [ "$matched" = "1" ] || die "путь вне зоны контракта: $p" # t96-m3
done

# ── И-4/И-5/И-12: class commands and docs ──
[ "${#_commands_cmds[@]}" -gt 0 ] || die "не выполнена обязательная команда класса $KLASS: <нет в профиле>" # t96-m2
# Чистая среда (В-1): префикс env -i с HOME=/tmp и фиксированным PATH;
# обнуление префикса (порча стаба) запускает команду в НАСЛЕДОВАННОЙ среде.
_CLEAN=""
_CLEAN="env -i HOME=/tmp PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" # t96-m11
for cmd in "${_commands_cmds[@]}"; do
  name="${cmd%%	*}"
  act="${cmd#*	}"
  [ -n "$act" ] || die "не выполнена обязательная команда класса $KLASS: <пустая>"
  case "$act" in
    'bash '*)
      sp="${act#bash }"
      rel="$sp"
      case "$rel" in ./*) rel="${rel#./}" ;; esac
      # обязательная команда профиля должна существовать в дереве merge/репо
      if ! git -C "$REPO" cat-file -e "$merge_sha:$rel" 2>/dev/null && \
         ! git -C "$REPO" cat-file -e "$merge_sha:scripts/${sp##*/}" 2>/dev/null; then
        [ -f "$REPO/$rel" ] || die "обязательная команда профиля отсутствует: $KLASS/$name: $act" # t96-m12
      fi
      ;;
  esac
  # выполнение команды класса в чистой среде; rc≠0 → именованный отказ (П-4)
  if [ "$DRY" != "1" ]; then
    ( cd "$REPO" && $_CLEAN bash -lc "$act" >/dev/null 2>&1 ) || die "не выполнена обязательная команда класса $KLASS: $name" # t96-m4
  fi
done
# ── И-5: обязательные документы класса ──
for d in "${_docs_cmds[@]}"; do
  _doc_ok=""
  case "$d" in
    */*) if [ -f "$REPO/$d" ] || git -C "$REPO" cat-file -e "$merge_sha:$d" 2>/dev/null; then _doc_ok=1; fi ;;
    *) if [ -f "$REPO/$d" ]; then _doc_ok=1; fi ;;
  esac
  [ -n "$_doc_ok" ] || die "нет обязательного документа класса $KLASS: $d" # t96-m5
done

# ── И-6: открытые находки только по предмету ──
while IFS= read -r rp; do
  [ -f "$REPO/$rp" ] || continue
  grep -Fxq 'status: ready' "$REPO/$rp" || continue
  base="${rp#/}"
  case "$base" in
    .review/*) subject="${base#.review/}"; subject="${subject%.md}" ;;
    *) subject="$base" ;;
  esac
  case "$subject" in
    *-*) head="${subject%%-*}" ;;
    *) head="$subject" ;;
  esac
  matched=0
  for z in "${_ZONES[@]}"; do
    case "$z" in
      */*) zhead="${z%%/*}" ;;
      *) zhead="${z%%.*}" ;;
    esac
    case "$zhead" in
      scripts|fixtures|contracts|harness|registry|decisions) [ "$head" = "$zhead" ] && matched=1 && break ;;
    esac
  done
  [ "$matched" = "1" ] || continue
  die "открытая находка по предмету: $rp" # t96-m6 (findings)
done < <(cd "$REPO" && find .review -type f -name '*.md' 2>/dev/null | sed 's|^\./||' | LC_ALL=C sort)

# ── ADR для class=research ──
if [ "$KLASS" = "research" ]; then
  adr_path=""
  for candidate in "decisions/${NNN}-research.md" "${NNN}-research.md"; do
    if git -C "$REPO" cat-file -e "$merge_sha:$candidate" 2>/dev/null; then
      adr_path="$candidate"; break
    fi
    if [ -f "$REPO/$candidate" ]; then
      adr_path="$candidate"; break
    fi
  done
  [ -n "$adr_path" ] || die "нет обязательного документа класса research: decisions/${NNN}-research.md"
  adr_status="$(git -C "$REPO" show "$merge_sha:$adr_path" 2>/dev/null | grep -E '^статус:' | head -1 | tr -d '\r')"
  [ -z "$adr_status" ] && adr_status="$(grep -E '^статус:' "$REPO/$adr_path" 2>/dev/null | head -1 | tr -d '\r')"
  case "$adr_status" in
    "статус: принято"|"статус:принято") ;;
    *) die "ADR класса research не в статусе «принято»: $adr_status" ;;
  esac
fi

# ── И-8/И-14: issue и проектные поля; тег без закрытого issue — не полный done ──
_need_issue_close=0
case "$_issuePolicy" in
  close)
    _need_issue_close=1 # t96-m14
    ;;
  reference)
    [ -n "$ISSUE" ] || die "issue-поле обязательно"
    ;;
  none) ;;
esac
if [ "$_need_issue_close" = "1" ]; then
  [ -n "$ISSUE" ] || die "issue не закрыт: <не задан issue>"
  state=""; pf=""; pfv=""
  while IFS="$TAB" read -r u s p1 p2; do
    [ "$u" = "$ISSUE" ] || continue
    state="$s"; pf="$p1"; pfv="$p2"
  done <"$REPO/harness/issue-state.tsv"
  case "$state" in closed|closed:complete|closed:done) ;; *) die "issue не закрыт: $state" ;; esac # t96-m8
  [ -n "$pf" ] || die "project-поле не заполнено"
  [ -n "$pfv" ] || die "project-поле не заполнено"
  case "$pf=$pfv" in
    doneStatus=completed|docsStatus=updated|decisionStatus=accepted) ;;
    *) die "project-поле не заполнено: $pf=$pfv" ;;
  esac
fi

# ── И-10: done-теги ──
if [ "$DRY" != "1" ]; then
  git -C "$REPO" rev-parse --verify --quiet "done/contracts/${NNN}/1" >/dev/null \
    || die "нет done-тега: done/contracts/${NNN}/1" # t96-m10
  git -C "$REPO" tag -f "done/project/$PROJID/1" "HEAD^{}" 2>/dev/null \
    || die "не удалось поставить done/project/$PROJID/1" # t96-m10
fi

# ── spend ──
_dur="${DUR:-unknown}"; _cim="${CIM:-unknown}"; _cost="${COST:-unknown}"; _intv="${INTV:-unknown}"
STATE_DIR="$REPO/.omp/done"
mkdir -p "$STATE_DIR"
state_file="$STATE_DIR/${NNN}.state.tsv"

if [ "$DRY" != "1" ]; then
  : >"$STATE_DIR/${NNN}.state.tsv"
  printf 'class-commands\tok\t%s\n' "$(date -u +%s 2>/dev/null || echo 0)" >>"$state_file"
  # повтор не должен создавать дубликат spend-строки (В-5): сверка ДО записи
  _have_spend=0
  awk -F '\t' -v t="$NNN" -v s="$SHA" '$1==t && $2==s {f=1} END{exit(f?0:1)}' "$REPO/registry/spend.tsv" >/dev/null 2>&1 && _have_spend=1 # t96-m15
  if [ "$_have_spend" != "1" ]; then
    # запись с маркером unknown для неизвестных метрик (И-9)
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$NNN" "$SHA" "$_dur" "$_cim" "$_cost" "$_intv" "$NOTES" >>"$REPO/registry/spend.tsv" # t96-m9
  fi
fi

# ── отчёт ──
started="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)"
contract_tag="$(git rev-parse --verify --quiet "done/contracts/${NNN}/1" 2>/dev/null || echo unknown)"
project_tag="$(git rev-parse --verify --quiet "done/project/$PROJID/1" 2>/dev/null || echo unknown)"
{
  printf 'DONE %s %s %s %s\n' "$PROJID" "$NNN" "$SHA" "$OID"
  printf '%s\n' '---'
  printf '%s\n' '--- REPORT ---'
  printf 'Result: completed\n'
  printf 'Commit: %s\n' "$SHA"
  printf 'ObjectId: %s\n' "$OID"
  printf 'IssueUrl: %s\n' "${ISSUE:-unknown}"
  printf 'PR: %s\n' "${PR:-unknown}"
  printf 'Tags[contracts=%s,project=%s]\n' "${contract_tag:-unknown}" "${project_tag:-unknown}"
  printf 'Class: %s\n' "$KLASS"
  printf 'StartedAt: %s\n' "$started"
  printf 'DurationMin: %s\n' "$_dur"
  printf 'CIMin: %s\n' "$_cim"
  printf 'Cost: %s\n' "$_cost"
  printf 'Interventions: %s\n' "$_intv"
  printf 'Notes: %s\n' "$NOTES"
}
exit 0
