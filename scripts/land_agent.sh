#!/usr/bin/env bash
# Барьер приземления (контракт 016, срез 3): merge --no-ff identity ОРКЕСТРАТОРА на main.
#
# Зачем: без явного приземления `git merge` берёт identity ВЫЗЫВАЮЩЕГО, и коммит подписан чужим
# именем — размывает authorship/committer пару и ломает судью зон (Q3, И-9). merge --no-ff
# обязателен: fast-forward стирал бы ветку wip/* из reflog-графа и терял бы автора работы.
#
# АРГУМЕНТЫ (CLI деталь реализации):
#   --branch ИМЯ         wip/<NNN>/<автор>, имя ветки для приземления (обязательно);
#   --worktree ПУТЬ      путь к worktree, где лежит предмет (обязательно);
#   --root КАТАЛОГ       корень репозитория (по умолчанию cwd);
#   --orchestrator ИМЯ   имя merge-коммита (по умолчанию orchestrator).
#
# ПРЕДМЕТ ОБЯЗАН БЫТЬ В HEAD worktree (И-8). Грязный главный чекаут → rc 1 (И-7).
# Сцепка+реестр ролей: committer==author у диапазона wip-ветки — проверка ДО merge.
# Строки-санкции ветки (И-10, контракт 065): РАЗРЕШИЛ-ВЛАДЕЛЕЦ/ALLOW-ARTIFACT-DELETE
# из тел коммитов диапазона переносятся в тело merge-коммита ДОСЛОВНО; синтез запрещён
# (зло-ленд без строки остаётся красным для check_charter). Первый абзац «land: <ветка>»
# сохранён.
#
# КОНТРАКТ ВЫХОДА (контракт 022, ветвь C, И-6): rc 0 при успехе означает «посажено
# ЛОКАЛЬНО» — вывод содержит строку «LANDED main=<sha> branch=<…>», ветка wip/<NNN>/<автор>
# снесена, ref main в главном чекауте сдвинут. ПУШ НЕ ДЕЛАЕТСЯ: «авто-пуш land_agent»
# демонтирован ЦЕЛИКОМ (боль Н-78 — побочный эффект вне нормы роли, оркестратор о нём
# не знал, amend переписал публичный коммит; аналогично «пуш под условием существования
# refs/heads/main» неразличим с безусловным на НЕпустом origin, тестовый И-6 держит
# различение). Публикация — отдельный шаг оркестратора по роли (roles/orchestrator.md).
# rc 1 именованный отказ; rc 2 — нечем проверить.
#
# Коды возврата: 0 — посажено локально, 1 — именованный отказ (identity расщеплена /
# имя вне реестра / грязный main / нет предмета в HEAD worktree / frozen-тег нарушен),
# 2 — нечем проверить.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"

usage() {
  cat >&2 <<USAGE
использование: land_agent.sh --branch ИМЯ [--worktree ПУТЬ] [--root КАТАЛОГ] [--orchestrator ИМЯ] [--pr]
USAGE
  exit 1
}

branch_arg=""
wt_arg=""
root_arg=""
orchestrator="orchestrator"
PR_MODE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --branch)        branch_arg="${2:?}"; shift 2 ;;
    --worktree)      wt_arg="${2:?}"; shift 2 ;;
    --root)          root_arg="${2:?}"; shift 2 ;;
    --orchestrator)  orchestrator="${2:?}"; shift 2 ;;
    --pr)            PR_MODE=1; shift ;;
    --help|-h)       usage ;;
    *)               printf 'land_agent: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

[ -n "$branch_arg" ] || { printf 'land_agent: --branch обязателен\n' >&2; usage; }
[ -n "$wt_arg" ] || { printf 'land_agent: --worktree обязателен\n' >&2; usage; }

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Корень репозитория. Главное дерево (НЕ worktree) — где HEAD main и где merge произойдёт.
if [ -z "$root_arg" ]; then
  ROOT="$(pwd -P 2>/dev/null || pwd)"
else
  ROOT="$(cd "$root_arg" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: %s не каталог\n' "$root_arg" >&2; exit 2; }
fi
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$ROOT" >&2; exit 2; }

# Worktree — где живёт предмет. Канонизируем.
WT="$(cd "$wt_arg" 2>/dev/null && pwd -P 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: %s не каталог\n' "$wt_arg" >&2; exit 2; }

g() { git -C "$ROOT" "$@"; }
gw() { git -C "$WT" "$@"; }

# Ветка wip/<NNN>/<автор> должна существовать.
if ! g show-ref --verify --quiet "refs/heads/$branch_arg"; then
  printf 'ОТКАЗ: ветка %s не существует — приземлять нечего\n' "$branch_arg" >&2
  exit 1
fi

# И-7: грязный главный чекаут → rc 1. Главное дерево — рабочее дерево, к которому привязан
# refs/heads/main (НЕ worktree с wip/*). Детект через `git status --porcelain` без -uall
# (А-30: readdir-глоб, не точечный прогон).
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  printf 'ОТКАЗ: главное дерево загрязнено мимо worktree — приземление отвергнуто\n' >&2
  exit 1
fi

# И-8: предмет ОБЯЗАН быть в HEAD worktree. Две независимые проверки:
#   (a) wt_head != main_head — иначе ветка пуста (частный случай приёмки-OK-без-ветки);
#   (b) wt_head == tip_sha  — иначе в worktree лежит ЧУЖОЙ предмет и merge перенесёт его
#       на main. R016-1: до фикса проверка (b) отсутствовала, merge исполнялся, и лишь
#       постфактум И-4 краснел из-за не-снесённого чужого worktree; main был мутирован.
# tip_sha поднимается выше, чтобы (b) не зависел от порядка с И-9 ниже.
wt_head="$(gw rev-parse HEAD)"
main_head="$(g rev-parse main)"
tip_sha="$(g rev-parse "refs/heads/$branch_arg")"
if [ "$wt_head" = "$main_head" ]; then
  printf 'ОТКАЗ: HEAD worktree не отличается от main — предмета в ветке нет (И-8)\n' >&2
  exit 1
fi
if [ "$wt_head" != "$tip_sha" ]; then
  printf 'ОТКАЗ: HEAD worktree %s не совпадает с tip ветки %s — предмет не в worktree (И-8)\n' \
    "${wt_head:0:8}" "${tip_sha:0:8}" >&2
  exit 1
fi

# И-9: committer == author в диапазоне main..HEAD. Здесь идёт СЦЕПКА ПАРЫ ПОЛЕЙ —
# committer==author. Расцепка (committer != author) → rc 1 поимённо.
# Диапазон: main..<tip ветки>, где tip = refs/heads/<branch_arg> (см. И-8 выше).
range="main..$tip_sha"
if [ -z "$(g rev-list "$range" 2>/dev/null)" ]; then
  # Пустой диапазон (fast-forward до main) — уже поймали И-8.
  printf 'ОТКАЗ: ветка %s не несёт коммитов относительно main\n' "$branch_arg" >&2
  exit 1
fi
while IFS= read -r sha; do
  [ -n "$sha" ] || continue
  an="$(g log -1 --format='%an' "$sha")"
  cn="$(g log -1 --format='%cn' "$sha")"
  if [ "$an" != "$cn" ]; then
    printf 'ОТКАЗ: identity расщеплена: %s author=%s committer=%s — committer и author обязаны совпадать (И-9)\n' \
      "${sha:0:8}" "$an" "$cn" >&2
    exit 1
  fi
done < <(g rev-list "$range")

# И-9 (продолжение): committer каждого коммита диапазона обязан быть в реестре ролей
# замороженных контрактов. Реестр — авторы ЗОНА-строк (тот же список, что собирает
# check_zones, через lib_zones). Это СЦЕПКА+РЕЕСТР делает поле check_zones (author)
# тождественным полю land_agent (committer).
out="$(zones_load "$ROOT" 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: реестр заморозок недоступен\n' >&2; exit 2; }
trap 'rm -rf "$out"' EXIT
# Режим --pr (099, З-1): реестровую половину И-9 не требуем — подготовка PR
# идёт в репозитории, где замороженных контрактов может не быть вовсе
# (переходный период; toy-миры клеток 099), а принадлежность работы зонам
# судится на PR-этапе серверными обязательными checks (check:zones по диффу
# к первому родителю) и дверью допуска pr_dopusk.sh. СЦЕПКА committer==author
# (первая половина И-9) действует в обоих режимах. Без --pr — байт-в-байт.
if [ "$PR_MODE" -ne 1 ]; then
author_set="$(awk -F'\t' '{print $1}' "$out/zones_scoped" | sort -u)"
while IFS= read -r sha; do
  [ -n "$sha" ] || continue
  cn="$(g log -1 --format='%cn' "$sha")"
  # ТОЧНОЕ ЧЛЕНСТВО В РЕЕСТРЕ (И-9, находка 1 адверсария): case-шаблон `*"$cn"*` ранее
  # совпадал с подстрокой — committer=imple пропускался против реестра `implementer`.
  # Здесь членство — по строкам реестра (новая строка = разделитель записей от
  # `awk | sort -u`); grep -qxF «fixed string на целой строке» ловит имя в любой
  # позиции (первая/середина/последняя) и отказывает подстроке.
  if ! printf '%s\n' "$author_set" | grep -qxF "$cn"; then
    printf 'ОТКАЗ: имя вне реестра ролей: %s — committer %s не объявлен ни одной ЗОНА-строкой замороженных контрактов (И-9)\n' \
      "${sha:0:8}" "$cn" >&2
    exit 1
  fi
done < <(g rev-list "$range")
fi

# Замороженные теги (И-3): ДО merge фиксируем blob-имена всех frozen/* файлов, чтобы после
# merge убедиться, что они НЕ изменились. Побайтовая сверка с блобом высшей заморозки — то же,
# что в check_contract_frozen.
mkdir -p "$ROOT/tmp"
TMPF="$(mktemp -d "$ROOT/tmp/land_agent.XXXXXX")"
trap 'rm -rf "$TMPF" "$out"' EXIT
g for-each-ref --format='%(refname)' 'refs/tags/frozen/' 2>/dev/null | sort > "$TMPF/tags_before" || : > "$TMPF/tags_before"
# ── И-10 (контракт 065): перенос строк-санкций ветки в тело merge-коммита ─────
# check_charter (019 И-7) судит merge по дельте к ПЕРВОМУ родителю: ленд ветки с
# санкционированной frozen-правкой (строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в теле КОММИТА ВЕТКИ)
# создавал merge с уставной дельтой и без строки — и красил CI (боли 037/043/045,
# 060: merge f2b911f, санкция в веточном 7b0bc92). Переносятся строки тех же
# грамматик, что читают razreshil() в check_charter и разбор ALLOW в check_protected:
# маркер РАЗРЕШИЛ-ВЛАДЕЛЕЦ: либо ALLOW-ARTIFACT-DELETE: в ПЕРВОЙ КОЛОНКЕ строки тела.
# Перенос ДОСЛОВНЫЙ (байты не меняются; --cleanup=verbatim ниже не даёт git стрипнуть
# строки), дедупликация — только точных повторов. СИНТЕЗ ЗАПРЕЩЁН: строки берутся
# исключительно из тел коммитов диапазона main..tip, поэтому зло-ленд ветки без
# строки даёт merge-тело без строки и остаётся красным для check_charter.
g log --format=%B "$range" | awk '(/^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:/ || /^ALLOW-ARTIFACT-DELETE:/) && !seen[$0]++' > "$TMPF/sanctions"
# Сообщение merge: первый абзац И-6/016 сохранён, строки-санкции — следующими строками
# без отступа (первая колонка — требование грамматики). Пустое множество строк даёт
# сообщение байт-в-байт как до 065.
{
  printf 'land: %s\n' "$branch_arg"
  cat "$TMPF/sanctions"
} > "$TMPF/msg"

# Готовим env-identity для merge. git -c ... -c ... выставляет identity для ОДНОГО вызова.
# Это и есть merge identity ОРКЕСТРАТОРА, зашитая в скрипте, а не наследуемая (контракт Q2/Q3).
MERGE_ARGS=(
  -c user.name="$orchestrator"
  -c user.email="${orchestrator}@dev-harness.local"
  -c commit.gpgsign=false
)

# ── Режим --pr (контракт 099, Решение 3, З-1): подготовка в интеграционную ──
# ветку pr/<NNN>/<автор> БЕЗ публикации. Тот же merge --no-ff/авторство/
# `land:`/дословные санкции (016/065), но: локальный main НЕ двигается,
# исходная ветка wip/<NNN>/<автор> жива (сносится только после принятия PR),
# worktree жив; флагов squash/rebase нет (миграция исторических барьеров не
# проводилась). Вывод «PREREADY branch=… sha=<M>»; публикация — ОТДЕЛЬНЫЙ шаг
# оркестратора (PR + допуск scripts/pr_dopusk.sh + серверное слияние
# доверенным компонентом, doc §2). Без --pr семантика 016 байт-в-байт.
if [ "$PR_MODE" -eq 1 ]; then
  case "$branch_arg" in
    wip/*) pr_branch="pr/${branch_arg#wip/}" ;;
    *)
      printf 'ОТКАЗ: --pr ожидает ветку wip/<NNN>/<автор>, получено %s\n' "$branch_arg" >&2
      exit 1
      ;;
  esac
  if g show-ref --verify --quiet "refs/heads/$pr_branch"; then
    printf 'ОТКАЗ: интеграционная ветка %s уже существует — повторная подготовка без разбора предыдущей запрещена\n' \
      "$pr_branch" >&2
    exit 1
  fi
  prev_branch="$(g symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  [ -n "$prev_branch" ] || {
    printf 'ОТКАЗ: --pr требует ветку в HEAD главного дерева (не detached)\n' >&2
    exit 1
  }
  g checkout -q -b "$pr_branch" main
  # MERGE --no-ff на интеграционную ветку из главного дерева; И-5 канарейка:
  # identity литерально В ОДНОЙ СТРОКЕ с `git merge`.
  if ! git -C "$ROOT" -c user.name="$orchestrator" -c user.email="${orchestrator}@dev-harness.local" -c commit.gpgsign=false merge --no-ff --cleanup=verbatim -F "$TMPF/msg" "$branch_arg" >/dev/null 2>&1; then
    g checkout -q "$prev_branch" 2>/dev/null || true
    printf 'ОТКАЗ: merge --no-ff %s отказал — конфликт или иная ошибка git\n' "$branch_arg" >&2
    exit 1
  fi
  pr_sha="$(g rev-parse "$pr_branch")"
  # Сверки 016 на интеграционной ветке: identity + родители (M^1 = main до,
  # M^2 = tip исходной ветки) — переход наблюдается, не состояние.
  merge_cn="$(g log -1 --format='%cn' "$pr_sha")"
  if [ "$merge_cn" != "$orchestrator" ]; then
    g checkout -q "$prev_branch" 2>/dev/null || true
    printf 'ОТКАЗ: merge-коммит подписан %s, ожидался %s — identity оркестратора не применилась\n' \
      "$merge_cn" "$orchestrator" >&2
    exit 1
  fi
  if [ "$(g rev-parse "$pr_sha^1")" != "$main_head" ] || [ "$(g rev-parse "$pr_sha^2")" != "$tip_sha" ]; then
    g checkout -q "$prev_branch" 2>/dev/null || true
    printf 'ОТКАЗ: родители merge на %s не (main=%s, tip=%s) — З-1\n' \
      "$pr_branch" "$main_head" "$tip_sha" >&2
    exit 1
  fi
  # И-3 на дереве merge: frozen-блобы не изменились (та же сверка, что в 016,
  # против $pr_sha вместо HEAD/main).
  pr_fails_frozen=0
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      head_blob="$(g rev-parse --verify --quiet "$pr_sha:$f" 2>/dev/null || true)"
      tag_blob="$(g rev-parse --verify --quiet "${t}^{commit}:$f" 2>/dev/null || true)"
      if [ -z "$tag_blob" ] || [ "$head_blob" != "$tag_blob" ]; then
        printf 'FAIL: %s изменён без новой заморозки (%s vs %s)\n' "$f" "$head_blob" "$tag_blob" >&2
        pr_fails_frozen=$((pr_fails_frozen + 1))
      fi
    done < <(g ls-tree -r --name-only "${t}^{commit}" -- ':(literal)contracts/' 2>/dev/null \
              | awk -v t="$t" 'match($0, /contracts\/[0-9]+-[a-z0-9-]+\.md$/) { print; exit }')
  done < "$TMPF/tags_before"
  g checkout -q "$prev_branch"
  if [ "$pr_fails_frozen" -gt 0 ]; then
    printf 'ОТКАЗ: замороженные контракты изменились в результате подготовки PR (И-3)\n' >&2
    exit 1
  fi
  printf 'PREREADY branch=%s sha=%s\n' "$pr_branch" "$pr_sha"
  exit 0
fi

# MERGE --no-ff на main. Слияние выполняет САМ СКРИПТ (И-1: наблюдается переход, не состояние).
# Делается из главного дерева, поскольку это merge main-ветки.
# ВАЖНО: не делаем `cd` в worktree — main приземляется из основного checkout, и `git merge`
# И-5: grep-канарейка требует, чтобы В ОДНОЙ СТРОКЕ с `git merge` стояла явная identity.
# Подстановка через переменную канарейку обходит — grep ищет буквально `user.(name|email)=`
# в той же строке, что и `merge`. Потому пишем identity литералом.
if ! git -C "$ROOT" -c user.name="$orchestrator" -c user.email="${orchestrator}@dev-harness.local" -c commit.gpgsign=false merge --no-ff --cleanup=verbatim -F "$TMPF/msg" "$branch_arg" >/dev/null 2>&1; then
  printf 'ОТКАЗ: merge --no-ff %s отказал — конфликт или иная ошибка git\n' "$branch_arg" >&2
  exit 1
fi

# Сверка после merge: коммиттер merge-коммита == orchestrator (И-9 продолжается).
new_main="$(g rev-parse main)"
merge_cn="$(g log -1 --format='%cn' "$new_main")"
if [ "$merge_cn" != "$orchestrator" ]; then
  printf 'ОТКАЗ: merge-коммит подписан %s, ожидался %s — identity оркестратора не применилась\n' \
    "$merge_cn" "$orchestrator" >&2
  exit 1
fi

# И-1: main^1 == main_before, main^2 == tip. Проверяем.
main_parent1="$(g rev-parse 'main^1')"
main_parent2="$(g rev-parse 'main^2')"
# main_before — HEAD main ДО merge, зафиксированный выше.
main_before="$main_head"
if [ "$main_parent1" != "$main_before" ]; then
  printf 'ОТКАЗ: main^1 (%s) != main_before (%s) — первый родитель не main\n' \
    "${main_parent1:0:8}" "${main_before:0:8}" >&2
  exit 1
fi
if [ "$main_parent2" != "$tip_sha" ]; then
  printf 'ОТКАЗ: main^2 (%s) != tip (%s) — второй родитель не ветка\n' \
    "${main_parent2:0:8}" "${tip_sha:0:8}" >&2
  exit 1
fi

# И-3: после приземления ВСЕ frozen/* теги достижимы из HEAD и побайтово равны блобам
# высшей заморозки. Идём по каждому файлу refs/tags/frozen/contracts/<NNN>/<v>^{commit} и
# сверяем блоб.
g for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null | sort > "$TMPF/tags_after" || : > "$TMPF/tags_after"
fails_frozen=0
while IFS= read -r t; do
  [ -n "$t" ] || continue
  # Берём файлы contracts/ из этого тега и сверяем с HEAD.
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    head_blob="$(g rev-parse --verify --quiet "HEAD:$f" 2>/dev/null || true)"
    tag_blob="$(g rev-parse --verify --quiet "${t}^{commit}:$f" 2>/dev/null || true)"
    if [ -z "$tag_blob" ]; then
      printf 'FAIL: %s заморожен, но файла %s в коммите заморозки нет\n' "$t" "$f" >&2
      fails_frozen=$((fails_frozen + 1))
      continue
    fi
    if [ "$head_blob" != "$tag_blob" ]; then
      printf 'FAIL: %s изменён без новой заморозки (%s vs %s)\n' "$f" "$head_blob" "$tag_blob" >&2
      fails_frozen=$((fails_frozen + 1))
    fi
  done < <(g ls-tree -r --name-only "${t}^{commit}" -- ':(literal)contracts/' 2>/dev/null \
            | awk -v t="$t" '
                match($0, /contracts\/[0-9]+-[a-z0-9-]+\.md$/) { print; exit }
              ')
done < "$TMPF/tags_after"
if [ "$fails_frozen" -gt 0 ]; then
  printf 'ОТКАЗ: замороженные контракты изменились в результате приземления (И-3)\n' >&2
  exit 1
fi


# Снос worktree и ветки wip/<NNN>/<автор> (И-4: после приземления веток wip/<NNN>/<автор>
# нет в for-each-ref). ПОРЯДОК НЕСУЩИЙ: пока worktree жив, ветка в нём вычекана, и
# `git branch -D` отказывает «used by worktree» — ветка переживала приземление, а И-4
# молча не держался (замер: for-each-ref после rc=0 печатал refs/heads/wip/001/implementer).
# Поэтому сначала снимается worktree, потом удаляется ветка, и результат НАБЛЮДАЕТСЯ.
g worktree remove --force "$WT" 2>/dev/null || true
g branch -D "$branch_arg" 2>/dev/null || true
if g show-ref --verify --quiet "refs/heads/$branch_arg"; then
  printf 'ОТКАЗ: ветка %s пережила приземление — И-4 не держится\n' "$branch_arg" >&2
  exit 1
fi

# Финал — на stdout имя нового HEAD main и имя ветки.
printf 'LANDED main=%s branch=%s\n' "$new_main" "$branch_arg"

