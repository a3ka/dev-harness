#!/usr/bin/env bash
# scripts/gitw_preflight_071.sh — предполётный гард обёртки scripts/gitw
# перед push в refs/heads/main (контракт 071, §Инварианты).
#
# Интерфейс вызова из крюка в scripts/gitw (после И-7, до И-8):
#   scripts/gitw_preflight_071.sh <эффективная_цель> [push-args ...]
#
# argv[1] = эффективная цель обмена (canonical URL — И-5 уже сверил);
# argv[2..] = хвост argv push (подкоманда и/или рефspec/флаги).
# cwd = репозиторий вызова (push идёт отсюда); чеки дерева исполняются
# на ОТПРАВЛЯЕМОМ src во временном worktree под
# ${TMPDIR:-/tmp}/dev-harness-worktrees/<hash8>/, удаляемом до exec.
#
# Крюк уже судит «покрывает ли refspec main» и зовёт этот скрипт только
# при покрытии. Здесь мы дополнительно читаем refspec, чтобы извлечь
# src для чека (1) и (4), и прогоняем чеки в порядке (4)→(2)→(3)→(1).
#
# Каждый отказ именован префиксом «gitw ПРЕДПОЛЁТ-ОТКАЗ: » и даёт rc 1;
# успех и каждый пропуск печатают строку «gitw ПРЕДПОЛЁТ: …» (молчания нет).
#
# Ровно одна ручка тестов: GITW_PREFLIGHT_071_API — полный base API
# включая owner/repo (фикстуры направляют её на локальный стаб-сервер).
# Без ручки цель считается не-github (если remote не github формы)
# ИЛИ используется https://api.github.com (если remote — github).
#
# Коды возврата:
#   0 — успех (чеки зелёные) или пропуск (0 ключей check:* в дереве);
#   1 — именованный отказ (получатель ещё не двинут — exec в gitw не происходит);
#   2 — нечем проверить (нет git/curl/jq).
set -uo pipefail

# ── изоляция окружения (прецедент батареи 045) ─────────────────────────────
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# ── инструменты ─────────────────────────────────────────────────────────────
command -v git  >/dev/null 2>&1 || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-раннер недоступен: git\n' >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-раннер недоступен: curl\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-раннер недоступен: jq\n' >&2; exit 2; }

TGT="${1:?цель не передана}"
shift

# ── определение ОТПРАВЛЯЕМОГО src (по refspec/текущей ветке) ────────────────
# Конвенция та же, что в крюке: src:main → src, без : → сам токен, HEAD →
# rev-parse HEAD, без refspec → текущая ветка. Удаление main (`:main`) и
# глоб в refspec — именованные отказы fail-closed.
curbr_short="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
main_cov=0
saw_ref=0
send_src=""
unsupported_reason=""

for a in "$@"; do
  case "$a" in
    -*) continue ;;
    *) saw_ref=1 ;;
  esac
  # глоб в refspec — fail-closed
  case "$a" in
    *\**)
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: refspec не разбирается: %s\n' "$a" >&2
      exit 1
      ;;
  esac
  if [ "${a#*:}" != "$a" ]; then
    # форма src:dst
    src="${a%%:*}"
    dst="${a#*:}"
    case "$dst" in
      refs/heads/main|main)
        # удаление main (src пуст): отправляемого дерева нет
        if [ -z "$src" ]; then
          printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: refspec не разбирается: удаление main\n' >&2
          exit 1
        fi
        main_cov=1
        send_src="$src"
        ;;
    esac
  else
    # bare-форма: a — это dst
    case "$a" in
      refs/heads/main|main)
        main_cov=1
        send_src="$a"
        ;;
      HEAD)
        if [ "$curbr_short" = "main" ]; then
          main_cov=1
          send_src="HEAD"
        else
          unsupported_reason="HEAD без явного dst при текущей ветке ${curbr_short:-detached}"
        fi
        ;;
    esac
  fi
done

# без refspec: текущая ветка определяет покрытие
if [ "$saw_ref" -eq 0 ]; then
  if [ "$curbr_short" = "main" ]; then
    main_cov=1
    send_src="HEAD"
  else
    unsupported_reason="явного dst нет при текущей ветке ${curbr_short:-detached}"
  fi
fi

# несудимая конфигурация refspec (критик к1 Б4 — fail-closed именованный отказ)
if [ -n "$unsupported_reason" ]; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: несудимая конфигурация refspec: %s\n' "$unsupported_reason" >&2
  exit 1
fi

# крюк уже судит покрытие, но защитимся от прямого вызова: не покрыто → пропуск
if [ "$main_cov" -ne 1 ]; then
  exit 0
fi

# ── разрешение src в commit ─────────────────────────────────────────────────
# src — ветка/тег/HEAD; rev-parse по нему без ^{commit} не ловит тег-объекты.
send_tip="$(git rev-parse --verify --quiet "${send_src}^{commit}" 2>/dev/null)"
if [ -z "$send_tip" ]; then
  send_tip="$(git rev-parse --verify --quiet "$send_src" 2>/dev/null)"
fi
[ -n "$send_tip" ] \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: отправляемый src не разрешается: %s\n' "$send_src" >&2; exit 1; }

WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"

# ── чек (4): мусорный worktree (должен быть ДО создания собственного) ───────
# git worktree list --porcelain репозитория вызова: разрешены основной
# worktree и worktree ветки refs/heads/wip/<NNN>/<автор> под
# $WTROOT/<hash8>/; прочие — отказ с путём и веткой (detached = «detached»).
first=1
wt_path=""
wt_branch=""
wt_flush() {
  [ -z "$wt_path" ] && return 0
  if [ "$first" -ne 1 ]; then
    ok=0
    case "$wt_branch" in
      refs/heads/wip/[0-9][0-9][0-9]/*)
        case "$wt_path" in
          "$WTROOT"/[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]/*) ok=1 ;;
        esac
        ;;
    esac
    if [ "$ok" -ne 1 ]; then
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: посторонний worktree: %s (ветка %s)\n' \
        "$wt_path" "${wt_branch:-detached}" >&2
      exit 1
    fi
  fi
  first=0
  wt_path=""
  wt_branch=""
}
while IFS= read -r l; do
  case "$l" in
    worktree\ *) wt_flush; wt_path="${l#worktree }" ;;
    branch\ *)   wt_branch="${l#branch }" ;;
    detached)    wt_branch="detached" ;;
  esac
done < <(git worktree list --porcelain 2>/dev/null)
wt_flush

# ── чек (2): локальные frozen/*|done/* теги на origin тем же объектом ───────
# ls-remote --tags выводит "<sha>\t<ref>"; для аннотированных тегов также
# строка с "<commit_sha>\t<ref>^{}". RSHA хранит имя тега → sha из
# ls-remote. Сверяем с локальным git for-each-ref refs/tags.
if ! ls_out="$(git ls-remote --tags "$TGT" 2>/dev/null)"; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: ls-remote --tags %s не прошёл\n' "$TGT" >&2
  exit 1
fi
declare -A RSHA
while IFS=$'\t' read -r sha ref; do
  [ -n "${ref:-}" ] || continue
  case "$ref" in
    refs/tags/*) RSHA["${ref#refs/tags/}"]="$sha" ;;
  esac
done <<< "$ls_out"

while IFS=$'\t' read -r sha name; do
  [ -n "${name:-}" ] || continue
  case "$name" in
    refs/tags/frozen/*|refs/tags/done/*)
      short="${name#refs/tags/}"
      remote_sha="${RSHA[$short]:-}"
      if [ "$remote_sha" != "$sha" ]; then
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: %s\n' "$short" >&2
        exit 1
      fi
      ;;
  esac
done < <(git for-each-ref --format='%(objectname)%09%(refname)' refs/tags 2>/dev/null)
unset RSHA

# ── чек (3): каждый merge «land: wip/<NNN>/<автор>» в диапазоне ─────────────
# Вершина main на цели ls-remote … tip отправляемого src. Второй родитель
# каждого merge — sha, по которому спрашиваем PR-CI GitHub API.
API_BASE="${GITW_PREFLIGHT_071_API:-}"
remote_url="$(git remote get-url "$TGT" 2>/dev/null || true)"
github_repo=""
if [ -z "$API_BASE" ]; then
  # без ручки: https://api.github.com + repo из эффективной цели
  # (конвенция check_ci_gate.sh:56-62). Если remote не github формы — нет ручки
  # и цель не github → отказ.
  case "$remote_url" in
    ssh://git@github.com/*|git@github.com:*|https://github.com/*)
      github_repo="$(printf '%s' "$remote_url" \
        | sed -nE 's#^(ssh://git@github\.com/|git@github\.com:|https://github\.com/)([^/]+)/(.+?)(\.git)?$#\2/\3#p' | head -1)"
      github_repo="$(printf '%s' "$github_repo" | sed -E 's/\.git$//')"
      API_BASE="https://api.github.com/repos/${github_repo}"
      ;;
  esac
fi
[ -n "$API_BASE" ] \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: цель не github\n' >&2; exit 1; }
# Базовый API: ".../repos/owner/repo" (фикстуры держат base БЕЗ /actions/runs;
# конвенция ручки — base включает owner/repo, эндпоинт дописывает предполёт).
# Толерантность к полному пути: если уже заканчивается на /actions/runs — pass.
case "$API_BASE" in
  */actions/runs) API="$API_BASE" ;;
  *)              API="${API_BASE}/actions/runs" ;;
esac

rmain="$(git ls-remote "$TGT" refs/heads/main 2>/dev/null | cut -f1)"
[ -n "$rmain" ] \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: вершина main на цели не читается\n' >&2; exit 1; }

while IFS=$'\t' read -r h s; do
  case "$s" in
    "land: wip/"[0-9][0-9][0-9]/*) : ;;
    *) continue ;;
  esac
  br="${s#land: }"
  p="$(git rev-parse --verify --quiet "$h^2" 2>/dev/null)"
  if [ -z "$p" ]; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: land-субъект не разбирается: %s\n' "$s" >&2
    exit 1
  fi
  if ! body="$(curl -fsS -m 20 \
        -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"}" \
        "$API?event=pull_request&head_sha=$p" 2>/dev/null)"; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: API\n' >&2
    exit 1
  fi
  n="$(printf '%s' "$body" | jq -r '[.workflow_runs[]? | select((.event=="pull_request") and (.conclusion=="success"))] | length' 2>/dev/null)"
  n="${n:-0}"
  if ! [[ "$n" =~ ^[0-9]+$ ]]; then n=0; fi
  if [ "$n" -lt 1 ]; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: land без зелёного PR-CI: %s (%s)\n' "$br" "$p" >&2
    exit 1
  fi
done < <(git log --first-parent --merges --format='%H%x09%s' "$rmain..$send_tip" 2>/dev/null)

# ── чек (1): четыре npm-ключа на ОТПРАВЛЯЕМОМ дереве ───────────────────────
command -v npm >/dev/null 2>&1 \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-раннер недоступен: npm\n' >&2; exit 1; }

# cwd должен содержать package.json (репозиторий вызова)
[ -f package.json ] \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-ключи не полностью: package.json отсутствует\n' >&2; exit 1; }

nk=0
for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
  if grep -qF "\"$k\"" package.json; then
    nk=$((nk+1))
  fi
done
[ "$nk" -eq 0 ] && {
  printf 'gitw ПРЕДПОЛЁТ: чеки неприменимы — дерево не несёт ключей check:*\n' >&2
  exit 0
}
[ "$nk" -eq 4 ] \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-ключи не полностью: %s из 4\n' "$nk" >&2; exit 1; }

# Временный detached worktree на tip отправляемого src. hash8 = 8 hex
# (та же конвенция, что в основном пуле worktree). Создаём под
# $WTROOT/<hash8>/ и снимаем trap на EXIT (включая частичный cleanup
# при провале чека — именованный остаток по контракту).
hash8="$(printf '%08x' $(( (RANDOM << 16 ^ RANDOM) & 0xffffffff )))"
tw="$WTROOT/$hash8"
mkdir -p "$(dirname "$tw")"
if ! git worktree add --quiet --detach "$tw" "$send_tip" 2>/dev/null; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: дерево чеков не строится\n' >&2
  exit 1
fi

cleanup() {
  git worktree remove --force "$tw" 2>/dev/null || rm -rf "$tw"
}
trap cleanup EXIT

for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
  if ! ( cd "$tw" && npm run --silent "$k" ) >/dev/null 2>&1; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек красный: %s\n' "$k" >&2
    exit 1
  fi
done

printf 'gitw ПРЕДПОЛЁТ: чисто\n' >&2
exit 0
