#!/usr/bin/env bash
# Дверь push продукта (контракт 124) — станция сама пушит ветку продуктового
# репозитория и открывает PR. Единственный путь к продуктовым пушам: оркестратор
# зовёт дверь (норма-строка ПРОВОДКИ в roles/orchestrator.md); merge продуктового
# PR остаётся за консультантом/владельцем.
#
#   bash scripts/push_product.sh --repo <клон> --branch <ветка> --sha <sha40> \
#        --title <заголовок> [--body-file <файл>]
#
# Порядок суждения (побеждает ПЕРВАЯ красная):
#   г1 форма argv → г2 значения → г3 среда → г4 канон из профиля клона →
#   г5 харнесс — не продукт → г6 HEAD клона == --sha → г7 push → г8 PR.
# rc 0 — ветка запушена и PR есть (на stdout РОВНО одна строка ОК);
# rc 1 — `push_product ОТКАЗ: <причина>`, rc 2 — `push_product NEEDS_ENV: <причина>`
# (обе — одна строка stderr).
#
# Канон берётся ТОЛЬКО из эффективного `.git.value.canonicalRemote` профиля клона
# тем же резолвером и в том же окружении, что scripts/gitw (045/996 К17): fallback
# на origin клона или на константу нет — клон сам определяет продукт. Канон
# харнесса — тот же резолвер на корне двери; обмены самого харнесса идут через
# scripts/gitw (045), сюда харнесс не пушится.
#
# Токен gh дверь не читает и не передаёт: ни в argv, ни в окружение, ни в вывод,
# ни в конфиг клона — git берёт его у хелпера `gh auth git-credential`.
set -uo pipefail
export LC_ALL=C

ME="push_product"

die1() { printf '%s ОТКАЗ: %s\n' "$ME" "$1" >&2; exit 1; }
die2() { printf '%s NEEDS_ENV: %s\n' "$ME" "$1" >&2; exit 2; }
san() { printf '%s' "$1" | tr '\001-\037\177' '?'; }   # управляющие байты на печать не идут

# Корень двери — каталог над scripts/, где лежит дверь (не cwd, не константа):
# на нём живут scripts/profile_resolver.sh и профиль харнесса.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)" \
  || die2 "корень двери не резолвится: $(dirname -- "${BASH_SOURCE[0]}")/.."

# ── г1 форма argv: пять флагов, каждый не более раза, у каждого значение ────
REPO="" BRANCH="" SHA="" TITLE="" BODY_FILE=""
SEEN=" "
while [ $# -gt 0 ]; do
  case "$1" in
    --repo|--branch|--sha|--title|--body-file)
      case "$SEEN" in *" $1 "*) die1 "аргумент вне грамматики: повтор $1" ;; esac
      [ $# -ge 2 ] || die1 "аргумент вне грамматики: $1 без значения"
      case "$1" in
        --repo) REPO="$2" ;;
        --branch) BRANCH="$2" ;;
        --sha) SHA="$2" ;;
        --title) TITLE="$2" ;;
        --body-file) BODY_FILE="$2" ;;
      esac
      SEEN="$SEEN$1 "
      shift 2 ;;
    *) die1 "аргумент вне грамматики: $(san "$1")" ;;
  esac
done
for FLAG in --repo --branch --sha --title; do
  case "$SEEN" in *" $FLAG "*) ;; *) die1 "нет аргумента: $FLAG" ;; esac
done

# ── г2 значения: замкнутые алфавиты, сравнение литеральное ─────────────────
[[ "$BRANCH" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$ ]] \
  || die1 "ветка вне грамматики: $(san "$BRANCH")"
# Из значения ветки refspec не собирается: ни `refs/…`, ни `..`, ни хвоста `.`
# или `.lock` у сегмента, ни длины сверх 200 байт.
case "$BRANCH" in
  refs/*|*..*|*.|*.lock|*.lock/*) die1 "ветка вне грамматики: $(san "$BRANCH")" ;;
esac
[ "${#BRANCH}" -le 200 ] || die1 "ветка вне грамматики: длиннее 200 байт"
case "$BRANCH" in main|master|HEAD) die1 "ветка защищена: $BRANCH" ;; esac
[[ "$SHA" =~ ^[0-9a-f]{40}$ ]] || die1 "sha вне грамматики: $(san "$SHA")"
{ [ -n "$TITLE" ] && [[ "$TITLE" != *[$'\001'-$'\037'$'\177']* ]]; } \
  || die1 "заголовок вне грамматики: $(san "$TITLE")"
if [ -n "$BODY_FILE" ]; then
  [ -f "$BODY_FILE" ] && [ -r "$BODY_FILE" ] || die1 "файл тела не читается: $(san "$BODY_FILE")"
fi

# ── г3 среда: без инструмента или без входа gh успеха не бывает (rc 2) ───────
command -v git >/dev/null 2>&1 || die2 "нет git"
command -v jq >/dev/null 2>&1 || die2 "нет jq"
command -v gh >/dev/null 2>&1 || die2 "нет gh"
gh auth status --hostname github.com >/dev/null 2>&1 || die2 "gh не авторизован (gh auth status)"

# ── г4 канон: эффективный git.canonicalRemote профиля клона (единый источник
# грамматики профиля — scripts/profile_resolver.sh, тот же вызов и то же
# окружение, что gitw 996 К17) ───────────────────────────────────────────────
REPO_ABS="$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null)" \
  || die1 "--repo не рабочее дерево git: $(san "$REPO")"
[ -f "$REPO_ABS/harness.project.json" ] \
  || die1 "профиль проекта отсутствует: $(san "$REPO_ABS")/harness.project.json"
PROF="$(HARNESS_PROJECT_LAYER_ROOT="$REPO_ABS" bash "$ROOT/scripts/profile_resolver.sh" \
          --repo "$REPO_ABS" 2>/dev/null)" \
  || die1 "профиль битый: bash scripts/profile_resolver.sh --repo $(san "$REPO_ABS") отказал"
CANON_JSON="$(printf '%s' "$PROF" | jq -c '.git.value.canonicalRemote // ""' 2>/dev/null)" \
  || CANON_JSON=""
# Произвольный URL двери не передаётся (флага нет): канон обязан быть
# https-адресом GitHub вида `"https://github.com/<владелец>/<имя>.git"`.
[[ "$CANON_JSON" =~ ^\"https://github\.com/([A-Za-z0-9-]+)/([A-Za-z0-9._-]+)\.git\"$ ]] \
  || die1 "канон вне грамматики двери: $(san "$CANON_JSON")"
SLUG="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
CANON="https://github.com/$SLUG.git"

# ── г5 харнесс — не продукт (обмены харнесса — scripts/gitw, контракт 045) ───
HPROF="$(HARNESS_PROJECT_LAYER_ROOT="$ROOT" bash "$ROOT/scripts/profile_resolver.sh" \
          --repo "$ROOT" 2>/dev/null)" \
  || die2 "профиль харнесса не резолвится: $(san "$ROOT")"
HCANON_JSON="$(printf '%s' "$HPROF" | jq -c '.git.value.canonicalRemote // ""' 2>/dev/null)" \
  || HCANON_JSON=""
# Форма канона самого харнесса на HEAD — ssh, продуктовые клоны (112) — https.
[[ "$HCANON_JSON" =~ ^\"(ssh://git@github\.com/|https://github\.com/)([A-Za-z0-9-]+)/([A-Za-z0-9._-]+)\.git\"$ ]] \
  || die2 "канон харнесса вне грамматики: $(san "$HCANON_JSON")"
HSLUG="${BASH_REMATCH[2]}/${BASH_REMATCH[3]}"
[ "${SLUG,,}" != "${HSLUG,,}" ] \
  || die1 "репозиторий харнесса — не продукт: $SLUG (обмены харнесса — scripts/gitw)"

# ── г6 HEAD клона == заявленный sha ─────────────────────────────────────────
HEAD_SHA="$(git -C "$REPO_ABS" rev-parse -q --verify 'HEAD^{commit}' 2>/dev/null)" || HEAD_SHA="(нет)"
[ "$HEAD_SHA" = "$SHA" ] || die1 "HEAD клона ≠ --sha: HEAD $HEAD_SHA, заявлено $SHA"

# ── г7 push: refspec несёт sha-литерал — ни HEAD, ни имя ветки клона; без
# --force, без '+', без удаления, без --all/--mirror/--tags: из всех ref'ов всех
# удалённых репозиториев меняется ровно refs/heads/<ветка> канона ──────────────
if ! PUSH_ERR="$(git -C "$REPO_ABS" -c credential.helper= \
                  -c 'credential.helper=!gh auth git-credential' \
                  push --quiet "$CANON" "$SHA:refs/heads/$BRANCH" 2>&1 >/dev/null)"; then
  die1 "push отказан: $(san "$PUSH_ERR")"
fi

# ── г8 PR: открытый PR пары <ветка>→main переиспользуется (идемпотентно) ────
EXIST="$(gh pr list --repo "$SLUG" --head "$BRANCH" --base main --state open \
          --json url --jq '.[0].url // empty' 2>/dev/null)" \
  || die1 "PR не создан: gh pr list отказал"
if [ -n "$EXIST" ]; then
  URL="$EXIST"
  HOW="существует"
else
  if [ -n "$BODY_FILE" ]; then BODY=(--body-file "$BODY_FILE"); else BODY=(--body ""); fi
  GH_ERR="$(mktemp "${TMPDIR:-/tmp}/push_product.XXXXXX")" \
    || die1 "PR не создан: не создаётся временный файл для stderr gh"
  trap 'rm -f -- "$GH_ERR"' EXIT
  if ! OUT="$(gh pr create --repo "$SLUG" --base main --head "$BRANCH" \
               --title "$TITLE" "${BODY[@]}" 2>"$GH_ERR")"; then
    M="$(cat "$GH_ERR")"
    die1 "PR не создан: $(san "$M")"
  fi
  URL="${OUT##*$'\n'}"
  HOW="создан"
fi
[[ "$URL" =~ ^https://github\.com/[A-Za-z0-9-]+/[A-Za-z0-9._-]+/pull/[0-9]+$ ]] \
  || die1 "PR не создан: ответ gh вне грамматики: $(san "$URL")"

printf '%s ОК: %s %s %s PR %s %s\n' "$ME" "$SLUG" "$BRANCH" "$SHA" "$URL" "$HOW"
exit 0