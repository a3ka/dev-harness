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

# ── режим --ci-report <job> <conclusion>: терминальные строки отчёта job ────
# (контракт 100, Решение 3): строка `def-sha256 <отпечаток>` (sha256
# канонической строки «<job>TAB<ключи через запятую в порядке матрицы>NL» по
# ci.yml дерева запуска — гейт ниже читает отпечаток из ПРИНЯТОЙ ревизии;
# слой определений байт-идентичен p↔rmain, Решение 5б1) и терминальная
# строка каждого ключа job `<ключ>: PASS` / `<ключ>: FAIL: <фраза>`.
# Вызывается CI-шагом «Отчёт 100» (.github/workflows/ci.yml) через npm-ключ
# check:main-ci-exceptions-report; гейт-путь ниже этим режимом не
# затрагивается. FAIL-строки (когда проверяльщики ключей научатся их печатать)
# парятся workflow-командой `::error file=<объект>::<фраза>` — failure-
# аннотация Checks API с message = FAIL-строке побайтно (структурная
# идентичность находки, Решение 3(ii)); здесь зелёный шаг проверок
# исполнением ключей уже ответил, печатается PASS каждого ключа.
if [ "${1:-}" = "--ci-report" ]; then
  rjob="${2:?job не передан}"
  rconc="${3:-}"
  rkeys="$(awk -v j="$rjob" '
    /^ +- (shard|lane): [a-z0-9]+$/ { hit = ($0 ~ ("- (shard|lane): " j "$")) ? 1 : 0; next }
    hit && /^ +keys: / { sub(/^ +keys: /, ""); print; exit }
  ' .github/workflows/ci.yml)"
  printf 'def-sha256 %s\n' \
    "$(printf '%s\t%s\n' "$rjob" "$(printf '%s' "$rkeys" | tr ' ' ',')" | sha256sum | cut -d' ' -f1)"
  if [ "$rconc" = "success" ] && [ -n "$rkeys" ]; then
    for k in $rkeys; do printf '%s: PASS\n' "$k"; done
  else
    printf 'отчёт 100: шаг проверок job %s не зелёный (%s) — терминальные строки ключей не исполнены\n' \
      "$rjob" "${rconc:-нет}"
  fi
  exit 0
fi
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

# ── чек (3): доверенные исключения main-CI (контракт 100) ─────────────────────
# Для каждого land-merge «land: wip/<NNN>/<автор>» в диапазоне (вершина main
# на цели ls-remote … tip отправляемого src): второй родитель p — CI-родитель
# ленда. Предикат «≥1 успешный PR-workflow run» (071) ЗАМЕНЁН полной
# грамматикой допуска (контракт 100, Решения 1–5): запуск с максимальным id
# по литеральным event/head_sha, completed + success|failure, актуальность
# базы (base.sha == rmain до суда и перечитывание перед допуском), связка
# запуска со строками check-runs по ПЛОСКОМУ check_suite_id, полнота всех
# 12 job доверенного ci.yml принятой ревизии (def-sha256 + терминальные
# строки каждого ключа, находки из отчёта ЛЮБОГО job), двойная идентичность
# находки (sha256 FAIL-строк ∧ failure-аннотации path/message) против
# списка registry/main-ci-exceptions.json, читаемого из ПРИНЯТОЙ ревизии,
# и байт-идентичность слоя определений CI и исполняемых корней p↔rmain и
# M↔rmain. Старой фразы «land без зелёного PR-CI» в коде нет (замена,
# не наслаивание — Пять правил §2).
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
    "land: wip/int-"[0-9]*"/"*) land_merges+=("$h"$'\t'"$s") ;;
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

  # ── гейт 100: полная грамматика допуска (Решения 1–5) ──────────────────────
  pf()  { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: %s\n' "$1" >&2; exit 1; }
  api0(){ printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: API\n' >&2; exit 1; }
  # база API без суффикса /actions/runs (для commits/<p>/check-runs и аннотаций)
  case "$API_BASE" in
    */actions/runs) REPO_API="${API_BASE%/actions/runs}" ;;
    *)              REPO_API="$API_BASE" ;;
  esac
  gh_args=(-H 'Accept: application/vnd.github+json' \
           -H 'X-GitHub-Api-Version: 2022-11-28')
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    gh_args+=(-H "Authorization: Bearer $GITHUB_TOKEN")
  fi
  # читаемость списка (совет 3 круга 1): ls-tree пуст ⇒ путь ДОСТОВЕРНО
  # отсутствует в ревизии ≡ пустой список; запись есть, но блоб не читается ⇒
  # именованный отказ «список не читается», НЕ пустой список молча.
  read_side() {  # <rev> → ABSENT | содержимое | UNREADABLE
    local e c
    if ! e="$(git ls-tree --name-only "$1" -- registry/main-ci-exceptions.json 2>/dev/null)"; then
      printf 'UNREADABLE'; return 0
    fi
    [ -n "$e" ] || { printf 'ABSENT'; return 0; }
    c="$(git show "$1:registry/main-ci-exceptions.json" 2>/dev/null)" \
      || { printf 'UNREADABLE'; return 0; }
    printf '%s' "$c"
  }
  pfx() { case "$1" in ap*) printf 'antiplacebo';; *) printf 'ci';; esac; }
  # отпечаток определения job (Решение 3): sha256 канонической строки
  # «<job>TAB<ключи через запятую в порядке матрицы>NL» по ci.yml принятой ревизии
  defsha() { printf '%s\t%s\n' "$1" "$(printf '%s' "${KEYS[$1]}" | tr ' ' ',')" | sha256sum | cut -d' ' -f1; }
  rowof() {  # <имя> → id TAB status TAB conclusion TAB summary (пусто = нет строки)
    printf '%s' "$rows" | jq -r --arg n "$1" \
      '[.rows[] | select(.name==$n)] | .[0] | if . then ([.id, .status, (.conclusion // ""), (.summary // "")] | @tsv) else "" end'
  }

  declare -A KEYS

  # обеспечение объектов принятой ревизии (Решение 5а): локальное хранилище
  # может не нести rmain (мелкий клон) — список/ci.yml читаются из ПРИНЯТОЙ
  # ревизии; фетч цели только при отсутствии объекта, отказ фетча НЕ маскирует
  # дальнейшую читаемость (git show упадёт именованным отказом, fail-closed)
  git cat-file -e "$rmain^{commit}" 2>/dev/null \
    || git fetch --quiet "$TGT" main 2>/dev/null || true
  for entry in "${land_merges[@]}"; do
    h="${entry%%$'\t'*}"; s="${entry#*$'\t'}"
    br="${s#land: }"
    p="$(git rev-parse --verify --quiet "$h^2" 2>/dev/null)"
    if [ -z "$p" ]; then
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: land-субъект не разбирается: %s\n' "$s" >&2
      exit 1
    fi
    # запуск: из workflow_runs берём ТОЛЬКО строки с литеральным равенством
    # event=="pull_request" ∧ head_sha=="<p>"; судится запуск с МАКСИМАЛЬНЫМ id
    if ! runs="$(curl -fsS -m 20 \
          "${gh_args[@]}" \
          "$API?event=pull_request&head_sha=$p" 2>/dev/null)"; then
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: API\n' >&2
      exit 1
    fi
    run="$(printf '%s' "$runs" | jq -c --arg p "$p" \
      '[.workflow_runs[]? | select((.event=="pull_request") and (.head_sha==$p))] | max_by(.id) // empty' 2>/dev/null)"
    [ -n "$run" ] || pf "запусков PR-CI нет: $br ($p)"
    st="$(jq -r '.status // ""' <<<"$run")"
    [ "$st" = "completed" ] || pf "запуск не завершён: ${st:-без статуса}"
    co="$(jq -r '.conclusion // ""' <<<"$run")"
    { [ "$co" = "success" ] || [ "$co" = "failure" ]; } || pf "запуск не исполнен: ${co:-без результата}"
    # актуальность базы — первая сверка (вторая: перечитывание перед допуском, И-16)
    bs="$(jq -r '.pull_requests[0].base.sha // ""' <<<"$run")"
    [ "$bs" = "$rmain" ] || pf "движение базы: запуск не актуален"
    # связка запуска со строками: ПЛОСКОЕ check_suite_id документированной схемы
    # GET /actions/runs (Б8); вложенный check_suite.id — форма объекта check-run
    suite="$(jq -r '.check_suite_id // 0' <<<"$run")"
    crs="$(curl -fsS -m 20 "${gh_args[@]}" "$REPO_API/commits/$p/check-runs" \
      | jq -c '{rows: [.check_runs[]? | {id, name, status, conclusion, check_suite_id: (.check_suite.id // 0), summary: (.output.summary // "")}]}')" || api0
    # строки ТОЛЬКО выбранного suite; одного имени — строка с МАКСИМАЛЬНЫМ id (И-13)
    rows="$(printf '%s' "$crs" | jq -c --argjson s "$suite" \
      '{rows: ([.rows[] | select(.check_suite_id == $s)] | group_by(.name) | map(max_by(.id)))}')"
    # доверенный состав job/ключей — ci.yml ПРИНЯТОЙ ревизии (не отправляемого дерева)
    ciyl="$(git show "$rmain:.github/workflows/ci.yml" 2>/dev/null)" \
      || pf "CI-код не читается: .github/workflows/ci.yml"
    KEYS=()
    jobs=()
    jent=""
    while IFS= read -r l; do
      if [ -z "$jent" ]; then jent="$l"; else KEYS[$jent]="$l"; jobs+=("$jent"); jent=""; fi
    done < <(printf '%s\n' "$ciyl" | sed -nE 's/^ +- (shard|lane): ([a-z0-9]+)$/\2/p; s/^ +keys: (.+)$/\1/p')
    # полнота: каждый ожидаемый job обязан быть исполнен (И-1, И-6); несоответствия
    # печатаются ВСЕ до отказа
    problems=0
    for j in "${jobs[@]}"; do
      nm="$(pfx "$j") ($j)"
      row="$(rowof "$nm")"
      if [ -z "$row" ]; then
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s отсутствует\n' "$j" >&2
        problems=1; continue
      fi
      IFS=$'\t' read -r rid rst rco resc <<<"$row"
      rsum="${resc//\\n/$'\n'}"
      if [ "$rst" != "completed" ]; then
        reason="$rst"; [ -z "$reason" ] && reason="$rco"
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s %s\n' "$j" "$reason" >&2
        problems=1; continue
      fi
      case "$rco" in
        success|failure) ;;
        skipped|neutral|cancelled|timed_out)
          printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s %s\n' "$j" "$rco" >&2
          problems=1; continue ;;
        *)
          printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: %s неразобранный результат: %s\n' "$j" "$rco" >&2
          problems=1; continue ;;
      esac
      # отпечаток определения гейт вычисляет сам; строка в отчёте — заявление (И-7в/г)
      ds="$(printf '%s\n' "$rsum" | sed -nE 's/^def-sha256 ([0-9a-f]{64})$/\1/p' | head -1)"
      [ "$ds" = "$(defsha "$j")" ] || pf "отчёт не из доверенного определения: $j"
      # терминальная строка каждого обязательного ключа (И-5, И-15а)
      for k in ${KEYS[$j]}; do
        printf '%s\n' "$rsum" | grep -qE "^${k}: (PASS|FAIL)" \
          || pf "нет результата: $j/$k"
      done
      # completed/failure без единой FAIL-строки — неразобранный отказ job (И-15б)
      if [ "$rco" = "failure" ]; then
        nf=0
        for k in ${KEYS[$j]}; do
          c="$(printf '%s\n' "$rsum" | grep -c "^${k}: FAIL" || true)"
          nf=$((nf + c))
        done
        [ "$nf" -gt 0 ] || pf "job не выполнен: $j отказ без находки"
      fi
    done
    # check-run выбранного suite вне доверенного множества (И-7б)
    while IFS= read -r nm; do
      [ -n "$nm" ] || continue
      known=0
      for j in "${jobs[@]}"; do [ "$(pfx "$j") ($j)" = "$nm" ] && known=1; done
      if [ "$known" -eq 0 ]; then
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: посторонний job: %s\n' "$nm" >&2
        problems=1
      fi
    done < <(printf '%s' "$rows" | jq -r '.rows[].name')
    [ "$problems" -eq 0 ] || exit 1
    # ── источник доверия: читаемость списка (2) → схема (2) → самовнесение (5в,
    # печать) → слой определений и корни p и M (5б/5в) → находки (1,3,4) →
    # перечитывание базы (1) → допуск ──
    t_side="$(read_side "$rmain")"
    m_side="$(read_side "$h")"
    p_side="$(read_side "$p")"
    for lsd in "$t_side" "$m_side" "$p_side"; do
      if [ "$lsd" = "UNREADABLE" ]; then
        pf "список не читается: принятая ревизия"
      fi
    done
    if [ "$t_side" = "ABSENT" ] && [ "$p_side" = "ABSENT" ] && [ "$m_side" = "ABSENT" ]; then
      exsrc='{"schema":"main-ci-exceptions/1","exceptions":[]}'
      listflag=0
    elif [ "$t_side" = "ABSENT" ] || [ "$p_side" = "ABSENT" ] || [ "$t_side" != "$p_side" ] \
         || [ "$m_side" = "ABSENT" ] || [ "$t_side" != "$m_side" ]; then
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не из доверенной ревизии: registry/main-ci-exceptions.json\n' >&2
      listflag=1
      if [ "$t_side" = "ABSENT" ]; then
        exsrc='{"schema":"main-ci-exceptions/1","exceptions":[]}'
      else
        exsrc="$t_side"
      fi
    else
      exsrc="$t_side"
      listflag=0
    fi
    sch="$(printf '%s' "$exsrc" | jq -e '(.schema=="main-ci-exceptions/1") and (.exceptions|type=="array")' 2>/dev/null)"
    if [ "$sch" != "true" ]; then
      pf "список не разбирается: схема"
    fi
    recbad="$(printf '%s' "$exsrc" | jq -r '[.exceptions[] | select(
        (.defect_code|type)!="string" or (.defect_code|test("^[0-9a-f]{64}$")|not) or
        (.check_version|type)!="string" or (.check_version|test("^[0-9a-f]{64}$")|not) or
        (.evidence_main_sha|type)!="string" or (.evidence_main_sha|test("^[0-9a-f]{40}$")|not) or
        (.expires|type)!="string" or (.expires|test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")|not) or
        (.object|type)!="string" or (.object==""))] | length' 2>/dev/null)"
    [ "${recbad:-0}" = "0" ] || pf "список не разбирается: запись"
    # слой определений CI и исполняемые корни scripts//fixtures: байт-идентичность
    # p↔rmain И M↔rmain (Решение 5б, арбитраж contracts-100-b1b2; Б4: публикуемое
    # дерево — M = land-мерж); добавление новых путей разрешено; печатаются ВСЕ пути
    viol=""
    for side in p m; do
      rev="$p"; [ "$side" = "m" ] && rev="$h"
      for f in .github/workflows/ci.yml registry/ci-steps.tsv package.json; do
        a="$(git show "$rmain:$f" 2>/dev/null || printf 'ABSENT')"
        b="$(git show "$rev:$f" 2>/dev/null || printf 'ABSENT')"
        [ "$a" = "$b" ] || viol+="$f"$'\n'
      done
      while IFS=$'\t' read -r stv vpath rest; do
        [ -n "$vpath" ] || continue
        viol+="$vpath"$'\n'
        [ -n "$rest" ] && viol+="$rest"$'\n'
      done < <(git diff --name-status --diff-filter=MDTR "$rmain" "$rev" -- scripts fixtures 2>/dev/null)
    done
    if [ -n "$viol" ]; then
      while IFS= read -r v; do
        [ -n "$v" ] || continue
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: CI-код не из доверенной ревизии: %s\n' "$v" >&2
      done < <(printf '%s' "$viol" | LC_ALL=C sort -u)
      exit 1
    fi
    # находки: FAIL-строки читаются из отчёта ЛЮБОГО исполненного job, success
    # тоже (Б5); соответствие записи — двойная идентичность (Решение 3, И-11)
    total=0; covered=0
    for j in "${jobs[@]}"; do
      nm="$(pfx "$j") ($j)"
      row="$(rowof "$nm")"
      [ -n "$row" ] || continue
      IFS=$'\t' read -r rid rst rco resc <<<"$row"
      rsum="${resc//\\n/$'\n'}"
      jfl="$(printf '%s\n' "$rsum" | grep -a ': FAIL: ' || true)"
      jfail=0
      if [ -n "$jfl" ]; then jfail="$(printf '%s\n' "$jfl" | grep -c . || true)"; fi
      [ "$jfail" -gt 0 ] || continue
      anns="$(curl -fsS -m 20 "${gh_args[@]}" "$REPO_API/check-runs/$rid/annotations" 2>/dev/null || printf '[]')"
      for k in ${KEYS[$j]}; do
        fl="$(printf '%s\n' "$rsum" | grep "^${k}: FAIL" || true)"
        [ -n "$fl" ] || continue
        total=$((total+1))
        # (i) текстовая идентичность: sha256 сортированных LC_ALL=C FAIL-строк ключа
        sha="$(printf '%s\n' "$fl" | LC_ALL=C sort | sha256sum | cut -d' ' -f1)"
        rec="$(printf '%s' "$exsrc" | jq -r --arg t "$j" --arg k "$k" --arg s "$sha" \
          '[.exceptions[]? | select(.target==$t and .key==$k and .defect_code==$s)] | .[0] // empty')"
        [ -n "$rec" ] || pf "находка вне списка: $j/$k"
        [ "$(jq -r .check_version <<<"$rec")" = "$(defsha "$j")" ] \
          || pf "определение проверки не совпадает с записью: $(jq -r .object <<<"$rec")"
        exp="$(jq -r .expires <<<"$rec")"
        { [ "$(date +%F)" \< "$exp" ] || [ "$(date +%F)" = "$exp" ]; } \
          || pf "срок исключения истёк: $(jq -r .object <<<"$rec")"
        # (ii) структурная: на КАЖДУЮ FAIL-строку — failure-аннотация с path==object
        # и message==строке побайтно (кратности равны); лишних аннотаций нет (Б1/Б9)
        obj="$(jq -r .object <<<"$rec")"
        bad=0
        while IFS= read -r line; do
          [ -n "$line" ] || continue
          cn="$(printf '%s' "$anns" | jq --arg o "$obj" --arg m "$line" \
            '[.[] | select(.annotation_level=="failure" and .path==$o and .message==$m)] | length')"
          ln="$(printf '%s\n' "$fl" | grep -Fxc "$line" || true)"
          [ "${cn:-0}" -eq "${ln:-0}" ] || bad=1
        done < <(printf '%s\n' "$fl" | LC_ALL=C sort -u)
        nall="$(printf '%s' "$anns" | jq '[.[] | select(.annotation_level=="failure")] | length')"
        [ "${nall:-0}" -eq "$jfail" ] || bad=1
        [ "$bad" -eq 0 ] || pf "находка вне списка: $j/$k"
        covered=$((covered+1))
      done
    done
    # conclusion запуска = failure без единой находки — неразобранный отказ (И-15г)
    if [ "$co" = "failure" ] && [ "$total" -eq 0 ]; then
      pf "запуск отказал без находок"
    fi
    # перечитывание базы перед допуском (И-16: движение ПОСЛЕ первой сверки)
    [ "$(git ls-remote "$TGT" refs/heads/main | cut -f1)" = "$rmain" ] \
      || pf "движение базы: запуск не актуален"
    [ "$listflag" -eq 0 ] || exit 1
    printf 'gitw ПРЕДПОЛЁТ: PR-CI допуск: %s (%s): jobs %s/%s исполнено, находки %s/%s\n' \
      "$br" "$p" "${#jobs[@]}" "${#jobs[@]}" "$covered" "$total" >&2
  done
  unset land_merges
fi

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
