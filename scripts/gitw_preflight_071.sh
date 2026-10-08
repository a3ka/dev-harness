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

# SELF_DIR — каталог скриптов (для вызова ci_klass.sh из чека 5 контракта 087
# И-5; чек живёт ВНЕ временного worktree — на ОТПРАВЛЯЕМОМ дереве классификатор
# мог бы читать разные uchet, чем cwd вызова, и тут SELF_DIR решает, откуда брать
# сценарий: версия, лежащая в worktree предполёта, ещё не сформирована на этом
# шаге — чек 5 опирается на сценарий из СВОЕГО scripts/, как чек 1 читает
# package.json из $send_tip через git show).
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TGT="${1:?цель не передана}"
shift

# ── определение ОТПРАВЛЯЕМОГО src (по refspec/текущей ветке) ────────────────
# Конвенция та же, что в крюке: src:main → src, без : — сам токен, HEAD →
# rev-parse HEAD, без refspec — текущая ветка. Удаление main (`:main`) и
# глоб в refspec — именованные отказы fail-closed.
#
# Уточнение несудимости (по слову владельца 2026-10-01, симметрично крюку):
# «несудимая конфигурация refspec» — ТОЛЬКО когда effective refspec МОГ
# отправить main неявно (push.default=matching при ветках; upstream-ветка
# с upstream=main). detached HEAD без явного dst при push.default, который
# не покрывает main → effective push пуст → прозрачно. Явное покрытие
# (прямой main/src:main/HEAD:main/refs/heads/main/--all/--mirror) →
# main_cov=1 (предполёт обязателен).
curbr_short="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
main_cov=0
saw_ref=0
send_src=""
unsupported_reason=""
all_or_mirror=0

for a in "$@"; do
  case "$a" in
    --all|--mirror) all_or_mirror=1; continue ;;
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
        elif [ -z "$curbr_short" ]; then
          # detached HEAD + push HEAD: git фатально (нет current branch),
          # effective push пуст → прозрачно (без unsupported_reason)
          :
        else
          # HEAD без явного dst при чужой ветке — refspec неоднозначен,
          # несудимая конфигурация
          unsupported_reason="HEAD без явного dst при текущей ветке $curbr_short"
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
  elif [ -n "$curbr_short" ]; then
    # ветка ≠ main: push.default мог бы неявно покрыть main
    pd="$(git config --get push.default 2>/dev/null || true)"
    case "$pd" in
      matching)
        unsupported_reason="явного dst нет при текущей ветке $curbr_short" ;;
      upstream|simple|current)
        merge_dst="$(git config --get "branch.$curbr_short.merge" 2>/dev/null || true)"
        case "$merge_dst" in
          refs/heads/main)
            unsupported_reason="явного dst нет при текущей ветке $curbr_short" ;;
        esac
        ;;
    esac
  fi
  # detached HEAD без refspec → git фатально (нет current branch),
  # effective push пуст → прозрачно
fi

# --all|--mirror → явное покрытие main (контракт 071 §Инвариант 2);
# подавляет unsupported_reason (--all отменяет неоднозначность dst).
if [ "$all_or_mirror" -eq 1 ]; then
  main_cov=1
  unsupported_reason=""
  if [ -z "$send_src" ]; then
    # для --all/--mirror src = локальная main (если есть) — это отправляемое
    # дерево для чеков (1)/(3). В группе wip/071/main/src/main — refspec не
    # собирается, git толкает ВСЕ refs/heads/* (--all) или все refs/*
    # (--mirror); локальная main — представительный src чека.
    if git show-ref --verify --quiet refs/heads/main; then
      send_src="main"
    else
      send_src="HEAD"
    fi
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
        # Имя тега + ОБА sha (вердикт ревьюера 071 r1 Р-6): для отсутствующего
        # на цели — локальный sha и «нет» (явная отметка, что на цели тега
        # нет вовсе); для переприцеленного — оба sha рядом, чтобы видеть
        # РАСХОЖДЕНИЕ объектов, а не только имя.
        remote_disp="${remote_sha:-нет}"
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: %s (локальный %s, цель %s)\n' \
          "$short" "$sha" "$remote_disp" >&2
        exit 1
      fi
      ;;
  esac
done < <(git for-each-ref --format='%(objectname)%09%(refname)' refs/tags 2>/dev/null)
unset RSHA

# ── чек (3): каждый merge «land: wip/<NNN>/<автор>» в диапазоне ─────────────
# Вершина main на цели ls-remote … tip отправляемого src. Второй родитель
# каждого merge — sha, по которому спрашиваем PR-CI GitHub API.
#
# Граница применимости API-проверки: если в $rmain..$send_tip НЕТ ни одного
# merge-subject «land: wip/<NNN>/<автор>» → API-запрос не формируется,
# чек (3) прозрачен (мержей нет — проверять нечего). API_BASE
# резолвится только когда есть что проверять: для не-github целей без ручки
# и без мержей — прозрачно (не отказываем «PR-CI не сверяем: цель не
# github» — это был бы над-блок для легитимного push --all при локальном
# bare-получателе).
rmain="$(git ls-remote "$TGT" refs/heads/main 2>/dev/null | cut -f1)"
[ -n "$rmain" ] \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: вершина main на цели не читается\n' >&2; exit 1; }

# Сначала собираем список land-мержей в диапазоне (вершина main на цели
# … tip отправляемого src). БЕЗ `--first-parent` (вердикт ревьюера 071 r1
# Р-5): land-merge не на первой родительской линии диапазона (например,
# влитая ветка с собственным land'ом) тоже судим; иначе такой мерж
# проходит незамеченным. Фильтр subject — единственный кейс проверки
# (любой merge с subject «land: …» в диапазоне обязан судиться; не-land
# merge — игнор).
#
# Subject «land: …» вне грамматики wip/[0-9]{3}/<автор> — именованный
# отказ «land-субъект не разбирается» (вердикт ревьюера 071 r1 Р-4):
# иначе такой мерж молча пропускается и оператору не видно поломки.
land_merges=()
while IFS=$'\t' read -r h s; do
  case "$s" in
    "land: wip/"[0-9][0-9][0-9]/*) land_merges+=("$h"$'\t'"$s") ;;
    "land: "*)
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: land-субъект не разбирается: %s\n' "$s" >&2
      exit 1
      ;;
  esac
done < <(git log --merges --format='%H%x09%s' "$rmain..$send_tip" 2>/dev/null)

# Мержей нет → прозрачно (нет объекта проверки)
if [ "${#land_merges[@]}" -gt 0 ]; then
  API_BASE="${GITW_PREFLIGHT_071_API:-}"
  # Шов API_BASE: две формы (живой укус 2026-10-02 №2, клетка п8б):
  #   полная — содержит /repos/<owner>/<repo> (как было); оставляем как есть;
  #   КОРЕНЬ  — без /repos (фикстура п8б задаёт КОРЕНЬ мока); owner/repo
  #             извлекаются из $TGT (эффективная цель обмена — канонический
  #             URL после И-5: ssh://github.com/o/r.git для ssh-цели) c
  #             подпором remote_url любого настроенного remote (TGT мог быть
  #             путём, ssh-формой вне github-грамматики или bare-remote).
  #             Грамматика: ssh://git@github.com/ | ssh://github.com/ |
  #             git@github.com: | https://github.com/ → owner/repo.
  # При пустой API_BASE КОРЕНЬ дефолтится в https://api.github.com.
  case "$API_BASE" in
    */repos/*|*/actions/runs)
      # полная форма — оставляем как есть (все старые клетки)
      ;;
    *)
      github_repo=""
      # 1) парсим TGT (эффективная цель обмена — канонический URL)
      if [ -n "$TGT" ]; then
        github_repo="$(printf '%s' "$TGT" \
          | sed -nE 's#^(ssh://git@github\.com/|ssh://github\.com/|git@github\.com:|https://github\.com/)([^/]+)/([^/.]+)(\.git)?$#\2/\3#p' | head -1)"
      fi
      # 2) fallback — remote_url любого настроенного remote
      if [ -z "$github_repo" ]; then
        while IFS= read -r rname; do
          [ -n "$rname" ] || continue
          ru="$(git remote get-url "$rname" 2>/dev/null || true)"
          case "$ru" in
            "")
              ;;
            *)
              cand="$(printf '%s' "$ru" \
                | sed -nE 's#^(ssh://git@github\.com/|ssh://github\.com/|git@github\.com:|https://github\.com/)([^/]+)/([^/.]+)(\.git)?$#\2/\3#p' | head -1)"
              if [ -n "$cand" ]; then
                github_repo="$cand"
                break
              fi
              ;;
          esac
        done < <(git remote 2>/dev/null)
      fi
      if [ -n "$github_repo" ]; then
        API_BASE="${API_BASE:-https://api.github.com}/repos/${github_repo}"
      else
        API_BASE=""
      fi
      ;;
  esac
  [ -n "$API_BASE" ] \
    || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: цель не github\n' >&2; exit 1; }
  case "$API_BASE" in
    */actions/runs) API="$API_BASE" ;;
    *)              API="${API_BASE}/actions/runs" ;;
  esac

  for entry in "${land_merges[@]}"; do
    h="${entry%%$'\t'*}"; s="${entry#*$'\t'}"
    br="${s#land: }"
    p="$(git rev-parse --verify --quiet "$h^2" 2>/dev/null)"
    if [ -z "$p" ]; then
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: land-субъект не разбирается: %s\n' "$s" >&2
      exit 1
    fi
    gh_args=(-H 'Accept: application/vnd.github+json' \
             -H 'X-GitHub-Api-Version: 2022-11-28')
    if [ -n "${GITHUB_TOKEN:-}" ]; then
      gh_args+=(-H "Authorization: Bearer $GITHUB_TOKEN")
    fi
    if ! body="$(curl -fsS -m 20 \
          "${gh_args[@]}" \
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
  done
  unset land_merges
fi

# ── чек (5, контракт 087 И-5): код в main только через PR ─────────────────
# Класс пуша — `ci_klass.sh vorota <вершина main цели> <отправляемый tip>`:
# учётный пуш прозрачен без запроса к API; код — только при наличии
# доказательства тяжёлого прогона по хешу (артефакт tyazhelyj-<H>).
# Чек (5) между чеком (3) и чеком (1) — порядок (4)(2)(3)(5)(1) с добавлением
# шага 087; прежние чеки (1)-(4) не меняются.
# Чеки 071 (1)–(4) неприменимы (нет ключей check:*) ⇒ rc 0 «чеки неприменимы»
# ДО чтения ci_klass.sh: чек 5 на ДЕРЕВЕ без реестра ⇒ rc 0 «неприменим»
# внутри vorota, выход rc 0. Здесь этот случай не блокирует чек 5: даже если
# дальше чек (1) прозрачен, чек (5) сначала обязан спросить классификатор.
if ! git cat-file -e "${rmain}^{commit}" 2>/dev/null; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: код в main: вершина main цели %s не в локальной истории — сделай fetch\n' "$rmain" >&2
  exit 1
fi
# Классификатор ищется в scripts/ репозитория push'а (cwd live-операции)
# или в $SELF_DIR (фикстура 087 — _считается_ от scripts/gitw_preflight_071.sh,
# чьё $SELF_DIR совпадает с местом лежания scripts/ci_klass.sh; toy-мир $T87_W
# НЕ имеет scripts/, и cwd-поиск там провалится — берём $SELF_DIR как fallback).
# Так обеспечивается и зелёный мир 071 (cwd=$T с scripts/ через git archive),
# и фикстура 087 (cwd=$T87_W без scripts/, поиск через $SELF_DIR).
if [ -f "scripts/ci_klass.sh" ]; then
  vor_out="$(bash scripts/ci_klass.sh vorota "$rmain" "$send_tip" 2>&1)"
else
  vor_out="$(bash "$SELF_DIR/ci_klass.sh" vorota "$rmain" "$send_tip" 2>&1)"
fi
vor_rc=$?
if [ "$vor_rc" -ne 0 ]; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: %s\n' "${vor_out#ОТКАЗ: }" >&2
  exit 1
fi
printf 'gitw ПРЕДПОЛЁТ: код-через-PR: %s\n' "$vor_out" >&2

# ── чек (1): четыре npm-ключа на ОТПРАВЛЯЕМОМ дереве ───────────────────────
command -v npm >/dev/null 2>&1 \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-раннер недоступен: npm\n' >&2; exit 1; }

# 0 ключей в дереве (включая отсутствие package.json) — чеки неприменимы,
# обмен продолжается (контракт 071 §Инвариант 3). Без этого фикс-теста toy-
# миры без package.json (положительный контроль push --all) упирались бы в
# fail-closed «чек-ключи не полностью» — над-блок.
#
# Ключи считаются на ОТПРАВЛЯЕМОМ дереве ($send_tip), НЕ на cwd вызова
# (адверсарий 071-r1 Б2: cwd чекаута и отправляемый src расходятся на
# candidate:main — чтение из cwd даёт «правильный ответ не тому дереву»,
# над- или под-блок в зависимости от направления расхождения).
pkg_content="$(git show "${send_tip}:package.json" 2>/dev/null)"
nk=0
if [ -n "$pkg_content" ]; then
  for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
    if printf '%s' "$pkg_content" | grep -qF "\"$k\""; then
      nk=$((nk+1))
    fi
  done
fi
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

ckout="$(mktemp 2>/dev/null || printf '%s/.ckout.%s' "${TMPDIR:-/tmp}" "$$")"
for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
  if ! ( cd "$tw" && npm run --silent "$k" ) >"$ckout" 2>&1; then
    # Хвост вывода чека — в отказе (вердикт ревьюера 071 r1 Р-3): без хвоста
    # оператор видит «check:ceilings красный» и НЕ видит, какой потолок ёмок;
    # зажигает именно имя ключа и хвост вывода.
    tail_out="$(tail -n 3 "$ckout" 2>/dev/null | sed -e 's/[[:space:]]*$//')"
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек красный: %s\n%s\n' "$k" "$tail_out" >&2
    rm -f "$ckout"
    exit 1
  fi
done
rm -f "$ckout"

printf 'gitw ПРЕДПОЛЁТ: чисто\n' >&2
exit 0
