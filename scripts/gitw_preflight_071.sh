#!/usr/bin/env bash
# scripts/gitw_preflight_071.sh — предполётный гард обёртки scripts/gitw
# перед push в refs/heads/main (контракт 071, §Инварианты).
#
# Интерфейс вызова из крюка scripts/gitw (после И-7, до И-8):
#   scripts/gitw_preflight_071.sh <target> --pf-ctx <ctx…> --pf-cfg <cfg…> <push-args…>
#
# argv[1]                                = эффективная цель обмена (канон
#                                          URL после И-5);
# argv[2]                                = сентинел --pf-ctx (граница ctx);
# argv[3 .. 3+ctx_len-1]                 = ctx[] (-C/--git-dir/--work-tree/…)
#                                          (С4: применяется к КАЖДОМУ git
#                                          предполёта);
# argv[3+ctx_len]                        = сентинел --pf-cfg (граница cfg);
# argv[4+ctx_len .. 4+ctx_len+cfg_len-1] = cfg[] (-c key=val);
# argv[5+ctx_len+cfg_len ..]             = argv хвоста push: первым
#                                          токеном ИДЁТ подкоманда (push),
#                                          далее — флаги и позиционные
#                                          (repository, refspecs).
#
# Крюк передаёт argv целиком — элементами массива, без скалярной подстановки
# (С1: ни одной неквоченной подстановки на пути крюк→предполёт). ПЕРВЫЙ
# позиционный токен в push-args после подкоманды = repository по git-push(1)
# (всегда перед refspec, синтаксис git-push(1) «<repository> [<refspec>…]»);
# предполёт сам его исключает из refspec-парсера. Без репозитория (push без
# позиционного аргумента) — repository резолвится из pushRemote/pushDefault
# (контекст ctx/cfg здесь же). Крюк уже судит «покрывает ли refspec main»;
# здесь дополнительно читаем refspec для извлечения src и прогоняем чеки
# в порядке (4)→(2)→(3)→(1).
#
# Таблица флагов push (С2: ровно одно место — здесь): известные флаги с
# arity 0/1 и =-формами; неизвестный → «несудимая конфигурация refspec:
# неразбираемый флаг <f>» (С3). Полный список све́рен с git-push(1) текущей
# версии git в среде.
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

# ── разбор ctx/cfg (С4: контекст вызова) ───────────────────────────────────
# sentinel-пары --pf-ctx / --pf-cfg разделяют блоки. Между ними — элементы
# массивов ctx и cfg (порядок и парность сохраняются 1-в-1 с gitw).
pf_ctx=()
pf_cfg=()
push_args=()
phase=pre
for a in "$@"; do
  case "$phase:$a" in
    pre:--pf-ctx)       phase=ctx ;;
    pre:--pf-cfg)       phase=cfg ;;
    ctx:--pf-cfg)       phase=cfg ;;
    ctx:*)              pf_ctx+=("$a") ;;
    cfg:*)              pf_cfg+=("$a") ;;
    pre:*)              phase=push_args; push_args+=("$a") ;;
    push_args:*)        push_args+=("$a") ;;
  esac
done
unset phase a

# Удобная обёртка для git-вызовов с контекстом (С4). ВСЕ git-вызовы
# предполёта идут через неё: НЕ через голый `git`, иначе -C/-c/--git-dir
# игнорируются и чеки смотрят НЕ тот репозиторий.
g() { git "${pf_ctx[@]}" "${pf_cfg[@]}" "$@"; }

# ── таблица флагов push (С2/С3) — разбор токенов push-args ─────────────────
# Состояние парсера: сначала идёт подкоманда (push), затем флаги, затем
# позиционные: первый = repository, далее = refspecs. Возвращаем массив
# refspec-токенов (без repository) и индекс первого позиционного.
#
# Возврат структуры: <repo_token>;<refspec_tokens_via_ARRAY_NAME>
# Сторона: после вызова ${refspecs[@]} содержит refspec-токены, $repo_token —
# первый позиционный (или пустая строка, если позиционного не было — push
# без явного remote).
pf_parse_push_args() {
  local i tok new_i
  local -a _result_refspecs
  local _result_repo=""
  # пропустить ведущие флаги: первый непозиционный — подкоманда
  sub_idx=-1
  for ((i=0; i<${#push_args[@]}; i++)); do
    tok="${push_args[$i]}"
    case "$tok" in
      -*) continue ;;
      *)   sub_idx=$i; break ;;
    esac
  done
  if [ "$sub_idx" -lt 0 ]; then
    # пустой argv — считаем, что push без аргументов
    refspecs=()
    repo_token=""
    return 0
  fi
  # после подкоманды — флаги и позиционные
  local state=flags  # flags → repo → refspecs
  local delete_active=0
  for ((i=sub_idx+1; i<${#push_args[@]}; i++)); do
    tok="${push_args[$i]}"
    case "$state:$tok" in
      flags:-*)  ;;  # любой флаг в режиме flags — нормально
      repo:-*)
        # refspec не может начинаться с -… но флаги после repo — да.
        # трактуем как флаг и переходим обратно в state=refspecs
        state=refspecs
        ;;
      refspecs:-*) ;;
      *:*)        # позиционный
        case "$state" in
          flags) state=repo; _result_repo="$tok"; continue ;;
          repo)  state=refspecs ;;
        esac
        ;;
    esac
    case "$tok" in
      # arity 0
      --all|--branches|--mirror|--tags|--follow-tags|--atomic|\
      --prune|--no-verify|--verify|\
      -n|--dry-run|--porcelain|\
      -q|--quiet|-v|--verbose|\
      -u|--set-upstream|-f|--force|\
      -4|--ipv4|-6|--ipv6|\
      --thin|--no-thin|--progress|\
      --force-if-includes|--no-force-if-includes|\
      --no-signed|--signed|\
      --no-force-with-lease|\
      --no-recurse-submodules|\
      --repo|--no-all|--no-multiple|\
      --delete|-d)
        case "$tok" in --delete|-d) delete_active=1 ;; *) delete_active=0 ;; esac
        ;;
      # arity 1 с =-формой: значение встроено
      --repo=*|--push-option=*|--receive-pack=*|--exec=*|\
      --force-with-lease=*|--signed=*|\
      --recurse-submodules=*|--push=*|\
      --dry-run=*|--porcelain=*|--quiet=*|--verbose=*|\
      --set-upstream=*|--force=*|--prune=*|--tags=*|\
      --follow-tags=*|--atomic=*|--all=*|--mirror=*|\
      --thin=*|--no-thin=*|--progress=*|\
      --force-if-includes=*|--no-force-if-includes=*|\
      --verify=*|--no-verify=*|\
      --ipv4=*|--ipv6=*)
        ;;
      # arity 1: значение в следующем токене
      -o)
        new_i=$((i+1))
        if [ "$new_i" -ge "${#push_args[@]}" ]; then
          printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: несудимая конфигурация refspec: флаг %s без значения\n' "$tok" >&2
          exit 1
        fi
        i=$new_i
        ;;
      # неизвестный флаг → отказ С3
      -*)
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: несудимая конфигурация refspec: неразбираемый флаг %s\n' "$tok" >&2
        exit 1
        ;;
      *)
        # позиционный — refspec
        if [ "$delete_active" -eq 1 ]; then
          _result_refspecs+=(":$tok")
          delete_active=0
        else
          _result_refspecs+=("$tok")
        fi
        ;;
    esac
  done
  repo_token="$_result_repo"
  # Передать refspecs через глобальную переменную (bash)
  refspecs=("${_result_refspecs[@]}")
}

# ── определение ОТПРАВЛЯЕМОГО src (по refspec/текущей ветке) ───────────────
# Уточнение несудимости (по слову владельца 2026-10-01): «несудимая
# конфигурация refspec» — ТОЛЬКО когда effective refspec МОГ отправить main
# неявно. Явное покрытие (прямой main/src:main/HEAD:main/refs/heads/main/
# --all/--mirror) → main_cov=1 (предполёт обязателен). detached HEAD без
# явного dst при push.default, который не покрывает main → effective push
# пуст → прозрачно.
curbr_short="$(g symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
main_cov=0
saw_ref=0
send_src=""
unsupported_reason=""
all_or_mirror=0
repo_token=""
refspecs=()
pf_parse_push_args

# Обход refspec-токенов: нормализация (`+` сбрасывается, `@` ≡ HEAD),
# разбор src:dst / bare-формы, удаление main, глоб.
for tok in "${refspecs[@]}"; do
  [ -n "$tok" ] || continue
  saw_ref=1
  # глоб в refspec
  case "$tok" in
    *\**)
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: refspec не разбирается: %s\n' "$tok" >&2
      exit 1
      ;;
  esac
  # Нормализация: ведущий `+` сбрасывается, `@` ≡ HEAD
  spec="$tok"
  case "$spec" in
    +*) spec="${spec#+}" ;;
  esac
  case "$spec" in
    @) spec="HEAD" ;;
  esac
  if [ "${spec#*:}" != "$spec" ]; then
    # форма src:dst
    src="${spec%%:*}"
    dst="${spec#*:}"
  else
    # bare-форма: spec = dst, src — тот же токен (push origin main →
    # main:main по git-push(1), НЕ :main)
    src="$spec"
    dst="$spec"
  fi
  # удаление main: ТОЛЬКО когда исходный refspec начинается с `:` (после
  # нормализации `+` сброшен, остался `:main` → src пуст).
  # Маркер удаления: при синтаксическом разборе src пуст И исходный
  # токен начинался с `:`. Фиксируем это ДО переписывания src для
  # bare-формы.
  case "$tok" in
    :*) _is_delete=1 ;;
    *)  _is_delete=0 ;;
  esac
  if [ "$_is_delete" -eq 1 ] && { [ "$dst" = "main" ] || [ "$dst" = "refs/heads/main" ]; }; then
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: refspec не разбирается: удаление main\n' >&2
    exit 1
  fi
  case "$dst" in
    refs/heads/main|main)
      main_cov=1
      # src берём из spec; пустой src = удаление, отказ выше
      if [ -n "$src" ]; then
        send_src="$src"
      elif [ -z "$send_src" ]; then
        send_src="$src"
      fi
      ;;
    HEAD)
      if [ "$curbr_short" = "main" ]; then
        main_cov=1
        send_src="HEAD"
      elif [ -z "$curbr_short" ]; then
        :  # detached HEAD, no current branch → git фатально, effective push пуст → прозрачно
      else
        unsupported_reason="HEAD без явного dst при текущей ветке $curbr_short"
      fi
      ;;
    *)
      # явный dst ≠ main → не покрыт (обмен прозрачен по семантике 045)
      ;;
  esac
done

# --all|--mirror → явное покрытие main (контракт 071 §Инвариант 2);
# подавляет unsupported_reason (--all отменяет неоднозначность dst).
case "${push_args[*]:-}" in
  *--all*|*--mirror*) all_or_mirror=1 ;;
esac

# без refspec: текущая ветка определяет покрытие
if [ "$saw_ref" -eq 0 ]; then
  if [ "$curbr_short" = "main" ]; then
    main_cov=1
    send_src="HEAD"
  elif [ -n "$curbr_short" ]; then
    # ветка ≠ main: push.default / remote.<r>.push могли бы неявно покрыть main
    pf_repo="${repo_token:-}"
    if [ -z "$pf_repo" ]; then
      pf_repo="$(g config --get "branch.$curbr_short.pushRemote" 2>/dev/null || true)"
      [ -n "$pf_repo" ] || pf_repo="$(g config --get remote.pushDefault 2>/dev/null || true)"
      [ -n "$pf_repo" ] || pf_repo="$(g config --get "branch.$curbr_short.remote" 2>/dev/null || true)"
      [ -n "$pf_repo" ] || pf_repo="origin"
    fi
    # remote.<r>.push (--get-all) — в КОНТЕКСТЕ ctx/cfg (С4). Все значения.
    rp_count=0
    rp_has_main=0
    while IFS= read -r rp; do
      [ -n "$rp" ] || continue
      rp_count=$((rp_count+1))
      # Нормализация: ведущий + сбрасывается, @ ≡ HEAD
      case "$rp" in
        +*) rp="${rp#+}" ;;
      esac
      case "$rp" in
        @) rp="HEAD" ;;
      esac
      if [ "${rp#*:}" != "$rp" ]; then
        rpsrc="${rp%%:*}"; rpdst="${rp#*:}"
      else
        rpsrc=""; rpdst="$rp"
      fi
      case "$rpdst" in
        refs/heads/main|main)
          rp_has_main=1
          if [ -n "$rpsrc" ] && [ -z "$send_src" ]; then
            send_src="$rpsrc"
          fi
          ;;
      esac
    done < <(g config --get-all "remote.${pf_repo}.push" 2>/dev/null)
    if [ "$rp_count" -gt 0 ] && [ "$rp_has_main" -eq 1 ]; then
      main_cov=1
      if [ -z "$send_src" ]; then send_src="HEAD"; fi
    fi
    # push.default — отдельный канал (сверяем всегда, даже при remote.<r>.push)
    pd="$(g config --get push.default 2>/dev/null || true)"
    case "$pd" in
      matching)
        if [ -z "$unsupported_reason" ]; then
          unsupported_reason="явного dst нет при текущей ветке $curbr_short (push.default=matching)"
        fi
        ;;
      upstream|simple|current)
        merge_dst="$(g config --get "branch.$curbr_short.merge" 2>/dev/null || true)"
        case "$merge_dst" in
          refs/heads/main)
            if [ -z "$unsupported_reason" ]; then
              unsupported_reason="явного dst нет при текущей ветке $curbr_short (upstream=main)"
            fi
            ;;
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
    # дерево для чеков (1)/(3).
    if g show-ref --verify --quiet refs/heads/main; then
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

# ── разрешение src в commit ────────────────────────────────────────────────
# src — ветка/тег/HEAD; rev-parse по нему без ^{commit} не ловит тег-объекты.
send_tip="$(g rev-parse --verify --quiet "${send_src}^{commit}" 2>/dev/null)"
if [ -z "$send_tip" ]; then
  send_tip="$(g rev-parse --verify --quiet "$send_src" 2>/dev/null)"
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
done < <(g worktree list --porcelain 2>/dev/null)
wt_flush

# ── чек (2): локальные frozen/*|done/* теги на origin тем же объектом ───────
# ls-remote --tags выводит "<sha>\t<ref>"; для аннотированных тегов также
# строка с "<commit_sha>\t<ref>^{}". RSHA хранит имя тега → sha из
# ls-remote. Сверяем с локальным git for-each-ref refs/tags.
if ! ls_out="$(g ls-remote --tags "$TGT" 2>/dev/null)"; then
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
        remote_disp="${remote_sha:-нет}"
        printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: локальный тег не на origin: %s (локальный %s, цель %s)\n' \
          "$short" "$sha" "$remote_disp" >&2
        exit 1
      fi
      ;;
  esac
done < <(g for-each-ref --format='%(objectname)%09%(refname)' refs/tags 2>/dev/null)
unset RSHA

# ── чек (3): каждый merge «land: wip/<NNN>/<автор>» в диапазоне ─────────────
# Вершина main на цели ls-remote … tip отправляемого src. Второй родитель
# каждого merge — sha, по которому спрашиваем PR-CI GitHub API.
#
# Граница применимости API-проверки: если в $rmain..$send_tip НЕТ ни одного
# merge-subject «land: wip/<NNN>/<автор>» → API-запрос не формируется,
# чек (3) прозрачен (мержей нет — проверять нечего). API_BASE
# резолвится только когда есть что проверять.
rmain="$(g ls-remote "$TGT" refs/heads/main 2>/dev/null | cut -f1)"
[ -n "$rmain" ] \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI не сверяем: вершина main на цели не читается\n' >&2; exit 1; }

# БЕЗ `--first-parent`: land-merge не на первой родительской линии
# диапазона (например, влитая ветка с собственным land'ом) тоже судим.
# Subject «land: …» вне грамматики wip/[0-9]{3}/<автор> — именованный
# отказ «land-субъект не разбирается».
land_merges=()
while IFS=$'\t' read -r h s; do
  case "$s" in
    "land: wip/"[0-9][0-9][0-9]/*) land_merges+=("$h"$'\t'"$s") ;;
    "land: "*)
      printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: land-субъект не разбирается: %s\n' "$s" >&2
      exit 1
      ;;
  esac
done < <(g log --merges --format='%H%x09%s' "$rmain..$send_tip" 2>/dev/null)

if [ "${#land_merges[@]}" -gt 0 ]; then
  API_BASE="${GITW_PREFLIGHT_071_API:-}"
  case "$API_BASE" in
    */repos/*|*/actions/runs)
      ;;
    *)
      github_repo=""
      if [ -n "$TGT" ]; then
        github_repo="$(printf '%s' "$TGT" \
          | sed -nE 's#^(ssh://git@github\.com/|ssh://github\.com/|git@github\.com:|https://github\.com/)([^/]+)/([^/.]+)(\.git)?$#\2/\3#p' | head -1)"
      fi
      if [ -z "$github_repo" ]; then
        while IFS= read -r rname; do
          [ -n "$rname" ] || continue
          ru="$(g remote get-url "$rname" 2>/dev/null || true)"
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
        done < <(g remote 2>/dev/null)
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
    p="$(g rev-parse --verify --quiet "$h^2" 2>/dev/null)"
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

# ── чек (1): четыре npm-ключа на ОТПРАВЛЯЕМОМ дереве ───────────────────────
command -v npm >/dev/null 2>&1 \
  || { printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек-раннер недоступен: npm\n' >&2; exit 1; }

# 0 ключей в дереве (включая отсутствие package.json) — чеки неприменимы,
# обмен продолжается (контракт 071 §Инвариант 3).
# Ключи считаются на ОТПРАВЛЯЕМОМ дереве ($send_tip), НЕ на cwd вызова.
pkg_content="$(g show "${send_tip}:package.json" 2>/dev/null)"
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

# Временный detached worktree на tip отправляемого src. hash8 = 8 hex.
hash8="$(printf '%08x' $(( (RANDOM << 16 ^ RANDOM) & 0xffffffff )))"
tw="$WTROOT/$hash8"
mkdir -p "$(dirname "$tw")"
if ! g worktree add --quiet --detach "$tw" "$send_tip" 2>/dev/null; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: дерево чеков не строится\n' >&2
  exit 1
fi

cleanup() {
  g worktree remove --force "$tw" 2>/dev/null || rm -rf "$tw"
}
trap cleanup EXIT

ckout="$(mktemp 2>/dev/null || printf '%s/.ckout.%s' "${TMPDIR:-/tmp}" "$$")"
for k in check:nabludenia check:ci-parity check:ceilings check:ids; do
  if ! ( cd "$tw" && npm run --silent "$k" ) >"$ckout" 2>&1; then
    tail_out="$(tail -n 3 "$ckout" 2>/dev/null | sed -e 's/[[:space:]]*$//')"
    printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: чек красный: %s\n%s\n' "$k" "$tail_out" >&2
    rm -f "$ckout"
    exit 1
  fi
done
rm -f "$ckout"

printf 'gitw ПРЕДПОЛЁТ: чисто\n' >&2
exit 0
