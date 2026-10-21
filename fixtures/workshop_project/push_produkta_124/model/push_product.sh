#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ двери push_product (контракт 124) — эталон клеток red_124.sh.
# Не реализация: живая дверь — scripts/push_product.sh (ЗОНА implementer).
# Хвостовые метки `# @L:<имя>` — точки подмены строк для обманных стабов
# (KARTA в red_124.sh); в модели это комментарии, поведение не меняют.
#
#   push_product.sh --repo <клон> --branch <ветка> --sha <sha40> --title <заголовок> [--body-file <файл>]
#
# Порядок суждения (побеждает первая красная): г1 форма argv → г2 значения
# (ветка, sha, заголовок, файл тела) → г3 среда (git, jq, gh, вход gh) →
# г4 профиль клона и канон → г5 харнесс ≠ продукт → г6 HEAD == --sha →
# г7 push → г8 PR. rc 0 — ветка запушена и PR есть; rc 1 — именованный
# ОТКАЗ; rc 2 — NEEDS_ENV.
set -uo pipefail
export LC_ALL=C
ME="push_product"
die1() { printf '%s ОТКАЗ: %s\n' "$ME" "$1" >&2; exit 1; }
die2() { printf '%s NEEDS_ENV: %s\n' "$ME" "$1" >&2; exit 2; }
san() { printf '%s' "$1" | tr '\001-\037\177' '?'; }
# Корень харнесса: модель лежит в fixtures/…/model/; стабы батареи собираются
# во временном каталоге — им корень передаёт батарея (P124_ROOT, шов фикстуры).
ROOT="${P124_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd -P)}"

# ── г1 форма argv ───────────────────────────────────────────────────────────
REPO="" BRANCH="" SHA="" TITLE="" BODY_FILE="" seen=" "
while [ $# -gt 0 ]; do
  case "$1" in
    --repo|--branch|--sha|--title|--body-file)
      case "$seen" in *" $1 "*) die1 "аргумент вне грамматики: повтор $1" ;; esac
      seen="$seen$1 "
      [ $# -ge 2 ] || die1 "аргумент вне грамматики: $1 без значения"
      case "$1" in
        --repo) REPO="$2" ;; --branch) BRANCH="$2" ;; --sha) SHA="$2" ;;
        --title) TITLE="$2" ;; --body-file) BODY_FILE="$2" ;;
      esac
      shift 2 ;;
    *) die1 "аргумент вне грамматики: $(san "$1")" ;; # @L:flag
  esac
done
for f in --repo --branch --sha --title; do
  case "$seen" in *" $f "*) ;; *) die1 "нет аргумента: $f" ;; esac
done

# ── г2 значения ─────────────────────────────────────────────────────────────
[[ "$BRANCH" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$ ]] || die1 "ветка вне грамматики: $(san "$BRANCH")" # @L:vetka
case "$BRANCH" in
  refs/*|*..*|*.|*.lock|*.lock/*) die1 "ветка вне грамматики: $(san "$BRANCH")" ;;
esac
[ "${#BRANCH}" -le 200 ] || die1 "ветка вне грамматики: длиннее 200 байт"
case "$BRANCH" in main|master|HEAD) die1 "ветка защищена: $BRANCH" ;; esac # @L:zashchita
[[ "$SHA" =~ ^[0-9a-f]{40}$ ]] || die1 "sha вне грамматики: $(san "$SHA")"
{ [ -n "$TITLE" ] && [[ "$TITLE" != *[$'\001'-$'\037'$'\177']* ]]; } || die1 "заголовок вне грамматики: $(san "$TITLE")" # @L:zagolovok
if [ -n "$BODY_FILE" ]; then
  [ -f "$BODY_FILE" ] && [ -r "$BODY_FILE" ] || die1 "файл тела не читается: $(san "$BODY_FILE")"
fi

# ── г3 среда ────────────────────────────────────────────────────────────────
command -v git >/dev/null 2>&1 || die2 "нет git"
command -v jq >/dev/null 2>&1 || die2 "нет jq"
command -v gh >/dev/null 2>&1 || die2 "нет gh" # @L:net_gh
gh auth status --hostname github.com >/dev/null 2>&1 || die2 "gh не авторизован (gh auth status)" # @L:auth

# ── г4 профиль клона → канон (единый источник с gitw: profile_resolver) ─────
REPO_ABS="$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null)" || die1 "--repo не рабочее дерево git: $(san "$REPO")"
if [ -f "$REPO_ABS/harness.project.json" ]; then
  PROF="$(HARNESS_PROJECT_LAYER_ROOT="$REPO_ABS" bash "$ROOT/scripts/profile_resolver.sh" --repo "$REPO_ABS" 2>/dev/null)" \
    || die1 "профиль битый: bash scripts/profile_resolver.sh --repo $(san "$REPO_ABS") отказал"
  CANON_JSON="$(printf '%s' "$PROF" | jq -c '.git.value.canonicalRemote // ""')" # @L:kanon
else
  die1 "профиль проекта отсутствует: $(san "$REPO_ABS")/harness.project.json" # @L:profil
fi
[[ "$CANON_JSON" =~ ^\"https://github\.com/([A-Za-z0-9-]+)/([A-Za-z0-9._-]+)\.git\"$ ]] || die1 "канон вне грамматики двери: $(san "$CANON_JSON")" # @L:kanon_gram
SLUG="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
CANON="https://github.com/$SLUG.git"

# ── г5 харнесс — не продукт (обмены харнесса — scripts/gitw, контракт 045) ──
HPROF="$(HARNESS_PROJECT_LAYER_ROOT="$ROOT" bash "$ROOT/scripts/profile_resolver.sh" --repo "$ROOT" 2>/dev/null)" \
  || die2 "профиль харнесса не резолвится: $ROOT"
HCANON_JSON="$(printf '%s' "$HPROF" | jq -c '.git.value.canonicalRemote // ""')"
[[ "$HCANON_JSON" =~ ^\"(ssh://git@github\.com/|https://github\.com/)([A-Za-z0-9-]+)/([A-Za-z0-9._-]+)\.git\"$ ]] || die2 "канон харнесса вне грамматики: $(san "$HCANON_JSON")" # @L:hkanon
HSLUG="${BASH_REMATCH[2]}/${BASH_REMATCH[3]}"
[ "${SLUG,,}" != "${HSLUG,,}" ] || die1 "репозиторий харнесса — не продукт: $SLUG (обмены харнесса — scripts/gitw)" # @L:harness

# ── г6 HEAD клона == --sha ──────────────────────────────────────────────────
HEAD_SHA="$(git -C "$REPO_ABS" rev-parse -q --verify 'HEAD^{commit}' 2>/dev/null)" || HEAD_SHA="(нет)"
[ "$HEAD_SHA" = "$SHA" ] || die1 "HEAD клона ≠ --sha: HEAD $HEAD_SHA, заявлено $SHA" # @L:head

# ── г7 push: refspec несёт sha-литерал; ни force, ни '+', ни удаления ──────
if ! perr="$(git -C "$REPO_ABS" -c credential.helper= -c 'credential.helper=!gh auth git-credential' push --quiet "$CANON" "$SHA:refs/heads/$BRANCH" 2>&1 >/dev/null)"; then # @L:push
  die1 "push отказан: $(san "$perr")"
fi

# ── г8 PR (идемпотентно: открытый PR head→main переиспользуется) ───────────
EXIST="$(gh pr list --repo "$SLUG" --head "$BRANCH" --base main --state open --json url --jq '.[0].url // empty' 2>/dev/null)" \
  || die1 "PR не создан: gh pr list отказал" # @L:pr_list
if [ -n "$EXIST" ]; then
  URL="$EXIST"; HOW="существует"
else
  if [ -n "$BODY_FILE" ]; then BODY=(--body-file "$BODY_FILE"); else BODY=(--body ""); fi
  perr_f="$(mktemp)"
  if ! out="$(gh pr create --repo "$SLUG" --base main --head "$BRANCH" --title "$TITLE" "${BODY[@]}" 2>"$perr_f")"; then
    m="$(cat "$perr_f")"; rm -f "$perr_f"
    die1 "PR не создан: $(san "$m")"
  fi
  rm -f "$perr_f"
  URL="${out##*$'\n'}"; HOW="создан"
fi
[[ "$URL" =~ ^https://github\.com/[A-Za-z0-9-]+/[A-Za-z0-9._-]+/pull/[0-9]+$ ]] || die1 "PR не создан: ответ gh вне грамматики: $(san "$URL")"
printf '%s ОК: %s %s %s PR %s %s\n' "$ME" "$SLUG" "$BRANCH" "$SHA" "$URL" "$HOW" # @L:ok
exit 0
