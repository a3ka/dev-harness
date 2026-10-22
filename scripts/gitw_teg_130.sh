#!/usr/bin/env bash
# Гард «тег после текста» (контракт 130 dev-harness). Зовётся scripts/gitw перед
# КАЖДЫМ exec настоящего git, достижимым при подкоманде push (И-1), и держит
# Коды возврата: 0 — тег допущен, обмен исполняется; 1 — именованный отказ ТЕГ-ОТКАЗ, обмен не исполняется; 2 — нечем судить (цель/объекты недоступны)
# тег заморозки вне refs/tags, пока его текст не лёг в main ЦЕЛИ.
#
#   gitw_teg_130.sh push <цель> <настоящий-git> <post_sub_idx> <argv gitw …>
#       состав обмена берётся у самого git: `push --dry-run --porcelain
#       --no-verify` с тем же argv и тем же окружением; каждый создаваемый или
#       двигаемый refs/tags/frozen/* судится против ЖИВОГО main цели (ls-remote).
#       rc 0 — тегов заморозки в обмене нет либо все допущены; rc ≠ 0 — именованный
#       отказ, обмен не исполняется целиком, локальные ссылки не тронуты.
#   gitw_teg_130.sh hold <тег>
#       refs/tags/frozen/<…> → refs/frozen-hold/<…> тем же объектом: тег в
#       refs/tags больше нет, чек (2) предполёта 071 его не видит (И-8).
#   gitw_teg_130.sh publish <тег>
#       refs/frozen-hold/<…> → refs/tags/frozen/<…> и `bash <scripts>/gitw push
#       origin <тег>`; отказ gitw — откат (тега в refs/tags нет, удержание на месте).
#
# Отказ: «gitw ТЕГ-ОТКАЗ: <тег>: <класс>: <деталь>», stderr, rc 1; классы —
# ровно семь §Грамматики контракта 130.
# Окружение (GIT_DIR и пр.) НЕ сбрасывается: проба обязана видеть то же хранилище,
# что и настоящий push.
# Чтения объектов (rev-parse/ls-tree/cat-file) несут те же глобальные флаги argv,
# что и проба состава обмена (CTX из PRE): суд тега читает репозиторий ОБМЕНА,
# а не cwd гарда — одноимённая годная ссылка постороннего репозитория не может
# подменить отправляемую (И-2, И-4).
set -uo pipefail

SELF_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
# Имя тега заморозки: группы dir, NNN, v. Иной refs/tags/frozen/* — отказ класса
# «тег вне грамматики»; удержание — те же группы под refs/frozen-hold/.
GRAM='^refs/tags/frozen/(contracts|plans)/([0-9]{3})/([1-9][0-9]{0,3})$'

otkaz() { printf 'gitw ТЕГ-ОТКАЗ: %s: %s: %s\n' "$1" "$2" "$3" >&2; }

RMAIN=""
CTX=()
# Объекты (тег, блоб, коммит) читаются ТОЛЬКО в контексте репозитория ОБМЕНА —
# тех же глобальных флагах argv, которыми читается состав обмена (-C/--git-dir/
# --work-tree/--bare/-c/…), а не из cwd гарда (И-2/И-4: суд сопоставляет объект
# отправляемой ссылки, а не одноимённую локальную ссылку чужого репозитория).
# Пустой CTX — обмена без глобальных флагов: контекст тот же (cwd/окружение).
objgit() {
  if [ "${#CTX[@]}" -gt 0 ]; then "$REALGIT" "${CTX[@]}" "$@"; else "$REALGIT" "$@"; fi
}

# main ЦЕЛИ: живой ls-remote (И-3), не локальный main и не refs/remotes/origin/main.
main_celi() {
  local tgt="$1" out
  out="$(objgit ls-remote "$tgt" refs/heads/main 2>/dev/null)" || return 1
  RMAIN="$(printf '%s\n' "$out" | awk -F'\t' '$2=="refs/heads/main"{print $1}')"
  [ -n "$RMAIN" ] || return 1
  return 0
}

# judge_tag <полное-имя-тега> <коммит-под-тегом>   (И-4, И-5)
#   0 — допущен; 1 — отказ по содержанию (текст/вердикт); 2 — вне грамматики/нечем судить.
judge_tag() {
  local ref="$1" commit="$2" short dir nnn v names path n blob_tag blob_main vk vpath body first
  short="${ref#refs/tags/}"
  if [[ ! "$ref" =~ $GRAM ]]; then
    otkaz "$short" "тег вне грамматики" "ожидается frozen/(contracts|plans)/NNN/v"
    return 2
  fi
  dir="${BASH_REMATCH[1]}"; nnn="${BASH_REMATCH[2]}"; v="${BASH_REMATCH[3]}"
  # Fail-closed (И-5): авторитет не прочитан — суд не начинается.
  if [ -z "$RMAIN" ]; then
    otkaz "$short" "main цели не читается" "ls-remote refs/heads/main пуст или упал"
    return 2
  fi
  if ! objgit cat-file -e "${RMAIN}^{commit}" 2>/dev/null; then
    otkaz "$short" "main цели не читается" "вершины ${RMAIN:0:12} нет локально — gitw fetch и повтор"
    return 2
  fi
  # Ровно один <dir>/<NNN>-*.md под коммитом источника — тот же путь, что и у
  # читателя check_contract_frozen; имя файла само по себе ничего не доказывает.
  names="$(objgit ls-tree --name-only "$commit" -- "$dir/" 2>/dev/null)"
  n=0; path=""
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if [[ "$p" =~ ^${dir}/${nnn}-[^/]+\.md$ ]]; then n=$((n + 1)); path="$p"; fi
  done <<<"$names"
  if [ "$n" -ne 1 ]; then
    otkaz "$short" "текст не в main цели" "под тегом файлов $dir/$nnn-*.md: $n (нужен ровно один)"
    return 1
  fi
  blob_tag="$(objgit rev-parse --verify --quiet "$commit:$path" 2>/dev/null)"
  blob_main="$(objgit rev-parse --verify --quiet "$RMAIN:$path" 2>/dev/null || true)"
  if ! [ "$blob_main" = "$blob_tag" ]; then
    otkaz "$short" "текст не в main цели" "$path blob $blob_tag, в main цели ${RMAIN:0:12}: ${blob_main:-нет} — тег в удержание (gitw_teg_130.sh hold), ленд текста, затем publish"
    return 1
  fi
  # Вердикты критика v1…v — первой строкой accept в main цели (пропуск версии
  # здесь не ловится: это забота читателя check:contract-frozen).
  vk=1
  while [ "$vk" -le "$v" ]; do
    vpath="verdicts/critic/${dir}-${nnn}-v${vk}.md"
    body="$(objgit cat-file -p "$RMAIN:$vpath" 2>/dev/null || true)"
    first="$(printf '%s\n' "$body" | sed -n 1p | tr -d '\r')"
    first="${first#"${first%%[![:space:]]*}"}"
    first="${first%"${first##*[![:space:]]}"}"
    if ! [ "$first" = accept ]; then
      otkaz "$short" "вердикт критика не в main цели" "$vpath в main цели ${RMAIN:0:12}: ${first:-нет} (нужно accept)"
      return 1
    fi
    vk=$((vk + 1))
  done
  return 0
}

# sostav: строки «<откуда>\t<куда>» создаваемых/двигаемых ссылок обмена.
# Проба строится из argv gitw БЕЛЫМ СПИСКОМ ТОЧНОГО СОВПАДЕНИЯ (И-2, РЕШЕНИЕ 1в):
# до разделителя «--» каждый токен после подкоманды классифицируется — без «-» в
# начале (и токен «-») проходит как есть; «--» проходит, дальше не судится; иначе
# имя (токен до первого «=») ищется ТОЧНЫМ совпадением в закрытой таблице:
#   REPLACE — семейства тихости/подробности/порcelain/сухого прогона (обе
#             полярности) заменяются литералом --no-verify: замена, а не удаление —
#             значение arity-2 опции остаётся значением и разбор git не сдвигается;
#   PASS    — прочие опции push полной формы проходят целиком, включая «=значение»;
#   иначе   — отказ «опция не распознана» ДО любого вызова git.
# Арность не отслеживается: dash-токен либо в таблице, либо отказан. НОЛЬ строк
# ссылок из пробы — отказ fail-closed при любом rc.
sostav() {
  local out rc flag spec a name dd=0
  PROBE_POST=()
  for a in "${POST[@]}"; do
    if [ "$dd" -eq 1 ]; then PROBE_POST+=( "$a" ); continue; fi
    case "$a" in
      --) dd=1; PROBE_POST+=( "$a" ) ;;
      -) PROBE_POST+=( "$a" ) ;;
      -*)
        name="${a%%=*}"
        case "$name" in
          -q|--quiet|--no-quiet|-v|--verbose|--no-verbose|--porcelain|--no-porcelain|-n|--dry-run|--no-dry-run)
            PROBE_POST+=( --no-verify ) ;;
          --all|--no-all|--branches|--no-branches|--mirror|--no-mirror|--tags|--no-tags|--follow-tags|--no-follow-tags|--atomic|--no-atomic|--thin|--no-thin|--progress|--no-progress|--prune|--no-prune|--signed|--no-signed|--force-with-lease|--no-force-with-lease|--force-if-includes|--no-force-if-includes|--recurse-submodules|--no-recurse-submodules|-f|--force|--no-force|-d|--delete|--no-delete|-u|--set-upstream|--no-set-upstream|-o|--push-option|--receive-pack|--exec|--repo|--verify|--no-verify|-4|--ipv4|-6|--ipv6)
            PROBE_POST+=( "$a" ) ;;
          *)
            otkaz "(обмен)" "опция не распознана" "$a — гард 130 принимает опции push только в полной форме из перечня И-2"
            return 2 ;;
        esac ;;
      *) PROBE_POST+=( "$a" ) ;;
    esac
  done

  out="$("$REALGIT" "${PRE[@]}" --dry-run --porcelain --no-verify "${PROBE_POST[@]}" 2>/dev/null)"; rc=$?
  SOSTAV_LINES=0
  while IFS=$'\t' read -r flag spec _; do
    case "$flag" in
      ' '|'+'|'*') ;;
      '-'|'='|'!') SOSTAV_LINES=$((SOSTAV_LINES + 1)); continue ;;
      *) continue ;;
    esac
    [ -n "${spec:-}" ] || continue
    SOSTAV_LINES=$((SOSTAV_LINES + 1))
    printf '%s\t%s\n' "${spec%%:*}" "${spec#*:}"
  done <<<"$out"
  [ "$SOSTAV_LINES" -gt 0 ] || return 1
  return 0
}

# polnoe <тег> → refs/tags/frozen/… в грамматике, иначе отказ.
polnoe() {
  local t="$1"
  case "$t" in refs/tags/*) ;; *) t="refs/tags/$t" ;; esac
  if [[ ! "$t" =~ $GRAM ]]; then
    otkaz "${t#refs/tags/}" "тег вне грамматики" "ожидается frozen/(contracts|plans)/NNN/v"
    return 1
  fi
  printf '%s\n' "$t"
}

mode="${1:-}"; shift || true
case "$mode" in
  push)
    TGT="$1"; REALGIT="$2"; PSI="$3"; shift 3
    ARGS=( "$@" )
    PRE=( "${ARGS[@]:0:PSI}" ); POST=( "${ARGS[@]:PSI}" )
    # Контекст чтения объектов = ровно те глобальные флаги, которыми читается
    # состав обмена: PRE без последнего токена (имени подкоманды).
    CTX=( "${PRE[@]:0:PSI-1}" )
    SOSTAV_LINES=0
    lines="$(sostav)"; prc=$?
    if [ "$prc" -ne 0 ]; then
      # rc 2 — «опция не распознана» напечатана ДО любого вызова git; rc 1 — ноль строк.
      [ "$prc" -eq 2 ] || otkaz "(обмен)" "состав обмена не читается" "git push --dry-run не дал ни одной ссылки"
      exit 1
    fi
    # И-6: теги вне refs/tags/frozen/ (done/, id/, refs/done-hold/) судом не затронуты.
    frozen=()
    while IFS=$'\t' read -r from to; do
      [ -n "${to:-}" ] || continue
      case "$to" in
        refs/tags/frozen/*) frozen+=( "$from"$'\t'"$to" ) ;;
      esac
    done <<<"$lines"
    [ "${#frozen[@]}" -gt 0 ] || exit 0
    main_celi "$TGT" || RMAIN=""
    bad=0
    for fl in "${frozen[@]}"; do
      from="${fl%%$'\t'*}"; to="${fl#*$'\t'}"
      commit="$(objgit rev-parse --verify --quiet "${from}^{commit}" 2>/dev/null || true)"
      if [ -z "$commit" ]; then
        otkaz "${to#refs/tags/}" "состав обмена не читается" "источник $from не разрешается в коммит"
        bad=1; continue
      fi
      judge_tag "$to" "$commit" || bad=1
    done
    [ "$bad" -eq 0 ] || exit 1
    exit 0
    ;;
  hold)
    X="$(polnoe "${1:-}")" || exit 1
    H="refs/frozen-hold/${X#refs/tags/frozen/}"
    obj="$(git rev-parse --verify --quiet "$X" 2>/dev/null)" \
      || { otkaz "${X#refs/tags/}" "удержание невозможно" "локального тега нет"; exit 1; }
    if git rev-parse --verify --quiet "$H" >/dev/null 2>&1; then
      otkaz "${X#refs/tags/}" "удержание невозможно" "$H уже есть"; exit 1
    fi
    git update-ref "$H" "$obj" "" 2>/dev/null \
      || { otkaz "${X#refs/tags/}" "удержание невозможно" "$H не создан"; exit 1; }
    if ! git update-ref -d "$X" "$obj"; then
      git update-ref -d "$H" "$obj" 2>/dev/null
      otkaz "${X#refs/tags/}" "удержание невозможно" "$X не снят"; exit 1
    fi
    exit 0
    ;;
  publish)
    X="$(polnoe "${1:-}")" || exit 1
    H="refs/frozen-hold/${X#refs/tags/frozen/}"
    obj="$(git rev-parse --verify --quiet "$H" 2>/dev/null)" \
      || { otkaz "${X#refs/tags/}" "удержание невозможно" "$H нет"; exit 1; }
    git update-ref "$X" "$obj" "" 2>/dev/null \
      || { otkaz "${X#refs/tags/}" "удержание невозможно" "локальный $X уже есть"; exit 1; }
    bash "$SELF_DIR/gitw" push origin "$X"
    prc=$?
    if [ "$prc" -ne 0 ]; then
      git update-ref -d "$X" "$obj" || true
      exit "$prc"
    fi
    git update-ref -d "$H" "$obj"
    exit $?
    ;;
  *)
    printf 'gitw ТЕГ-ОТКАЗ: (вызов): режим не распознан: %s\n' "$mode" >&2
    exit 2
    ;;
esac