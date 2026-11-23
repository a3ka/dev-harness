#!/usr/bin/env bash
# МОДЕЛЬ 212 (исполняемая): scripts/replace_line.sh — REPLACE строки реестра
# после ленда PR (контракт 212). НЕ БАРЬЕР: инструмент оркестратора
# (регистрационная строка реестра — не гейт приёмки); его приёмка —
# fixtures/workshop_project/replace_posle_lenda_212/red_replace_posle_lenda_212.sh.
#
# ЧТО ДЕЛАЕТ (боль 204/205/206/207/208, измерено 22-24.11): после ленда
# носителя заморозки и publish тега frozen/contracts/<NNN>/<v> заменяет
# РОВНО ОДНУ строку registry/contracts.tsv «<NNN> → <старый tag-object>» на
# «<NNN> → <tag-object frozen/contracts/<NNN>/<vmax>>» и КОММИТИТ её ПРЯМЫМ
# коммитом на main с identity orchestrator — ШТАТНОЙ дверью 031
# (check_staged.sh REPLACE-форма), без обхода. Прямой коммит на main —
# единственная форма, которую минт-признание check_zones.sh признаёт
# (on_main_replace: rev-list --first-parent); PR-маршрут для REPLACE
# неработоспособен в CI (измерено 24.11: REPLACE 208 через PR #1251,
# 6eebe0302 — второй родитель merge 91e3a032 — покрасил main).
#
# Провенанс (dual-control, зеркалит дверь 031 + боль «до ленда»):
#   локальный аннотированный frozen-тег = тег на origin (sha совпадает),
#   коммит заморозки — ПРЕДОК origin/main (ленд состоялся), старая строка =
#   tag-object id/CONTRACT/<NNN> ИЛИ frozen/contracts/<NNN>/<vmax-1>,
#   повторный REPLACE — отказ, дерево чисто, ветка main, main == origin/main.
#
# ЧТО НЕ ДЕЛАЕТ: НЕ минтит и НЕ двигает теги (next_id/freeze_contract);
# НЕ пушит (публикация — отдельный шаг оркестратора через scripts/gitw,
# норма HANDOFF «git-обмены — только через gitw», контракт 045);
# НЕ правит чужие строки манифеста (замена — ПОЛНАЯ строка, ровно одна);
# НЕ признаёт REPLACE во втором родителе merge и НЕ меняет check_zones.sh —
# прямым коммитом на main признание уже работает, ослабление двери вне предмета.
#
# КОНТРАКТ CLI:
#   scripts/replace_line.sh --nnn <NNN> [--root <каталог>]
#     --nnn NNN   номер контракта, 1-3 цифры (нормализуется %03d), обязательно
#     --root КАТ  корень репозитория (по умолчанию cwd)
#
# stdout при успехе (ровно одна строка, машинно-читаемо):
#   REPLACED nnn=<NNN> old=<старый-sha> new=<новый-sha> commit=<sha>
#
# ОТКАЗЫ rc 1 (именованные; дерево НЕ мутируется — строка пишется ПОСЛЕ всех
# проверок, при отказе двери на коммите откатывается точечно):
#   HEAD не main / грязное дерево / дверь 031 отключена конфигом (эффективный
#   hooks-каталог без живого pre-commit) / нет замороженных версий NNN /
#   frozen-тег не жив локально / не аннотированный / авторитет недоступен
#   (origin не настроен, ls-remote отказал — fail-closed, обрыв сети НЕ
#   пишет строку) / тег не достижим на origin (self-freeze) / переминт
#   заморозки (sha локально ≠ на origin) / main разошёлся с origin/main /
#   коммит заморозки не предок origin/main (ленд не состоялся) / строки NNN
#   нет в манифесте / строк NNN не одна / строка не по грамматике манифеста /
#   повторный REPLACE / sha старой строки ≠ ни id-тегу, ни frozen/<vmax-1>.
# rc 2 — нечем проверить (нет git, --root не каталог/не репозиторий, --nnn вне
# грамматики, tag-object-sha вне грамматики).
#
# ГРАММАТИКА СТРУКТУРНЫХ ПОЛЕЙ (норма 041 §Инварианты п.2):
#   --nnn <номер>   ^[0-9]{1,3}$  (нормализация printf %03d; замкнутый алфавит)
#   строка реестра  «<NNN> → <40-hex>» — NNN ровно %03d, разделитель U+2192,
#                   40-hex = ША ОБЪЕКТА аннотированного тега (единый источник
#                   грамматики — контракты 023/031/049; строка собирается
#                   ОДНИМ printf, потребители не переизобретают).
#   ЛИТЕРАЛЬНЫЕ сравнения: sha тега локально vs origin, старая строка vs
#   tag-object — bash `[ = ]`, NEVER regex/glob из untrusted.
#   vmax — наибольшее целое среди ЖИВЫХ ЛОКАЛЬНО тегов
#   refs/tags/frozen/contracts/<NNN>/<v> по грамматике [0-9]+ — ТОЙ ЖЕ МЕРОЙ,
#   что дверь 031 в check_staged.sh (for-each-ref → числовой фильтр →
#   sort -n → tail -1); расхождение меры с дверью = вечный отказ коммита.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# Резолвер профиля — ЕДИНЫЙ источник (next_id.sh, project_paths_resolve),
# подключается ЛЕНИВО — первым потребителем является резолв пути реестра
# (после разбора argv и проверки корня): отказы грамматики --nnn/--root
# не зависят от соседства библиотек. Сосед scripts/next_id.sh — боевой
# путь; копии вне scripts/ (модель батареи) берут резолвер из корня
# репозитория модели (прецедент profile_paths двери замка, семья 140).
podkljuchit_next_id() {
  local nid top
  nid="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/next_id.sh"
  if [ ! -r "$nid" ]; then
    top="$(git rev-parse --show-toplevel 2>/dev/null)" || {
      printf 'NOT_IMPLEMENTED: next_id.sh не найден (нет соседа и не репозиторий)\n' >&2; return 2; }
    nid="$top/scripts/next_id.sh"
  fi
  [ -r "$nid" ] || { printf 'NOT_IMPLEMENTED: next_id.sh не найден: %s\n' "$nid" >&2; return 2; }
  # shellcheck disable=SC1090
  NEXT_ID_LIB=1 source "$nid" || return 2
  return 0
}

# DECIMAL STRING DECREMENT — та же мера, что дверь 031 (check_staged.sh):
# корректное вычитание единицы из decimal-строки ЛЮБОЙ длины (leading zero →
# восьмеричная ошибка в $(( )); заимствована дословно, второй реализации нет.
decimal_sub1() {
  local s="$1" n=${#1} i d
  local out="$s"
  i=$((n - 1))
  while [ "$i" -ge 0 ]; do
    d="${out:$i:1}"
    if [ "$d" != "0" ]; then
      out="${out:0:$i}$((d - 1))${out:$((i + 1))}"
      break
    fi
    out="${out:0:$i}9${out:$((i + 1))}"
    i=$((i - 1))
  done
  out="${out#"${out%%[!0]*}"}"
  [ -n "$out" ] || out="0"
  printf '%s' "$out"
}

otkaz() {  # именованный отказ: stderr, rc 1; дерево не мутировано
  printf 'ОТКАЗ: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat >&2 <<USAGE
использование: replace_line.sh --nnn <NNN> [--root <каталог>]

Аргументы:
  --nnn NNN    номер контракта (1-3 цифры), обязательно
  --root КАТ   корень репозитория. По умолчанию — текущий.

Контракт: печатает REPLACED nnn=<NNN> old=<sha> new=<sha> commit=<sha> на stdout, rc 0.
USAGE
  exit 1
}

NNN_ARG=""
ROOT_ARG=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --nnn)  NNN_ARG="${2:?}"; shift 2 ;;
    --root) ROOT_ARG="${2:?}"; shift 2 ;;
    --help|-h) usage ;;
    *) printf 'replace_line: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

[ -n "$NNN_ARG" ] || { printf 'replace_line: --nnn обязателен\n' >&2; usage; }
# Замкнутый алфавит, точечный якорь на обе границы: ^[0-9]{1,3}$
if ! [[ "$NNN_ARG" =~ ^[0-9]{1,3}$ ]]; then
  printf 'NOT_IMPLEMENTED: --nnn вне грамматики [0-9]{1,3}: %s\n' "$NNN_ARG" >&2
  exit 2
fi
NNN="$(printf '%03d' "$((10#$NNN_ARG))")"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

if [ -z "$ROOT_ARG" ]; then
  ROOT="$(pwd -P 2>/dev/null || pwd)"
else
  ROOT="$(cd "$ROOT_ARG" 2>/dev/null && pwd -P 2>/dev/null)" || {
    printf 'NOT_IMPLEMENTED: --root не каталог: %s\n' "$ROOT_ARG" >&2; exit 2; }
fi
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: --root не репозиторий git: %s\n' "$ROOT" >&2; exit 2; }

# Строка реестра живёт ТОЛЬКО на main (дверь 031, условие ветки; зеркалит
# mint_line 068 и on_main_replace признание check_zones — прямой коммит).
current_head="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
if [ "$current_head" != "main" ]; then
  otkaz "HEAD не main (текущая ветка: $current_head) — строка реестра коммитится только на main"
fi

# Коммит строки — ЕДИНСТВЕННЫЙ предмет вызова: грязное дерево (staged или
# modified/untracked) отказывает заранее (И-7-класс, mint_line 068).
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  otkaz "грязное дерево — коммит строки реестра обязан быть единственным предметом"
fi

# Дверь 031 неотвратима для ЭТОГО коммита (mint_line 068 Б2): эффективный
# hooks-каталог обязан нести ИСПОЛНЯЕМЫЙ pre-commit ЕЩЁ ДО записи строки —
# конфиг-дизарм (core.hooksPath ведёт мимо двери) отказывает именем.
hooks_cfg="$(git -C "$ROOT" config --get core.hooksPath || true)"
if [ -n "$hooks_cfg" ]; then
  case "$hooks_cfg" in
    /*) HOOKS_DIR="$hooks_cfg" ;;
    *)  HOOKS_DIR="$ROOT/$hooks_cfg" ;;
  esac
else
  gitdir="$(git -C "$ROOT" rev-parse --git-dir)"
  case "$gitdir" in /*) HOOKS_DIR="$gitdir/hooks" ;; *) HOOKS_DIR="$ROOT/$gitdir/hooks" ;; esac
fi
if [ ! -x "$HOOKS_DIR/pre-commit" ]; then
  otkaz "дверь 031 отключена конфигом (эффективный hooks-каталог $HOOKS_DIR без исполняемого pre-commit) — строка реестра коммитится только сквозь живую дверь"
fi

# Профильный путь реестра — ЕДИНЫМ резолвером (996 К6; mint_line 068).
if ! podkljuchit_next_id; then exit 2; fi
_pr_paths="$(project_paths_resolve "$ROOT" 2>/dev/null)" \
  || { printf 'workflow ОТКАЗ: профиль битый или workflowPaths вне репо\n' >&2; exit 1; }
_REGISTRY_PATH="$(printf '%s' "$_pr_paths" | jq -r '.registry' 2>/dev/null || true)"
[ -n "$_REGISTRY_PATH" ] || { printf 'workflow ОТКАЗ: registry пуст\n' >&2; exit 1; }
unset _pr_paths
case "$_REGISTRY_PATH" in
  "$ROOT"/*) _REGISTRY_PATH="${_REGISTRY_PATH#"$ROOT"/}" ;;
  *)         _REGISTRY_PATH="${_REGISTRY_PATH#/}" ;;
esac
_REG_FILE="${_REGISTRY_PATH%/}/contracts.tsv"

# ── vmax: наибольшая живая ЛОКАЛЬНАЯ заморозка NNN (мера двери 031) ──────────
vmax="$(git -C "$ROOT" for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/$NNN/" 2>/dev/null \
        | awk -F/ '{ v=$NF; if (v ~ /^[0-9]+$/) print v }' \
        | sort -n | tail -1)"
if [ -z "$vmax" ]; then
  otkaz "нет замороженных версий $NNN — теги refs/tags/frozen/contracts/$NNN/* не живы локально, REPLACE невозможен"
fi
ref_new="refs/tags/frozen/contracts/$NNN/$vmax"
if ! git -C "$ROOT" show-ref --verify --quiet "$ref_new"; then
  otkaz "тег frozen/contracts/$NNN/$vmax не жив локально"
fi
new_tag_type="$(git -C "$ROOT" cat-file -t "$ref_new" 2>/dev/null || true)"
if [ "$new_tag_type" != "tag" ]; then
  otkaz "тег frozen/contracts/$NNN/$vmax не аннотированный"
fi
NEW_SHA="$(git -C "$ROOT" rev-parse "$ref_new")"
if ! printf '%s\n' "$NEW_SHA" | grep -Eqx '[0-9a-f]{40}'; then
  printf 'NOT_IMPLEMENTED: tag-object-sha вне грамматики [0-9a-f]{40}: %s\n' "$NEW_SHA" >&2
  exit 2
fi

# ── dual-control: frozen-тег опубликован авторитетом, sha совпадает ──────────
# Отказ сети — fail-closed «авторитет недоступен» (имя ОТДЕЛЬНОЕ от «не выдан
# авторитетом»; 023:289-290 дословно). Peeled-строки ^{} исключаются.
if ! git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
  otkaz "авторитет недоступен: remote origin не настроен — fail-closed, обрыв сети НЕ пишет строку"
fi
ls_rc=0
ls_out="$(git -C "$ROOT" ls-remote "origin" "$ref_new" 2>/dev/null)" || ls_rc=$?
if [ "$ls_rc" -ne 0 ]; then
  otkaz "авторитет недоступен (ls-remote origin не ответил, rc=$ls_rc) — fail-closed, обрыв сети НЕ пишет строку"
fi
sha_origin="$(printf '%s\n' "$ls_out" | grep -v '\^{}' | head -1 | awk '{print $1}')"
if [ -z "$sha_origin" ]; then
  otkaz "тег frozen/contracts/$NNN/$vmax не выдан авторитетом: тег не достижим на origin (self-freeze)"
fi
# ЛИТЕРАЛЬНОЕ сравнение (норма 037: never regex/glob из untrusted).
if [ "$NEW_SHA" != "$sha_origin" ]; then
  otkaz "переминт заморозки: sha локального frozen/contracts/$NNN/$vmax ($NEW_SHA) ≠ sha тега на origin ($sha_origin)"
fi

# ── ленд состоялся: main == origin/main, коммит заморозки — предок ───────────

ls_main_rc=0
ls_out="$(git -C "$ROOT" ls-remote "origin" "refs/heads/main" 2>/dev/null)" || ls_main_rc=$?
if [ "$ls_main_rc" -ne 0 ]; then
  otkaz "авторитет недоступен (ls-remote origin refs/heads/main не ответил, rc=$ls_main_rc) — fail-closed, обрыв сети НЕ пишет строку"
fi
ORIGIN_MAIN="$(printf '%s\n' "$ls_out" | head -1 | awk '{print $1}')"
if [ -z "$ORIGIN_MAIN" ]; then
  otkaz "авторитет недоступен: origin/main не отвечает (пустой ls-remote refs/heads/main)"
fi
LOCAL_MAIN="$(git -C "$ROOT" rev-parse refs/heads/main)"
if [ "$LOCAL_MAIN" != "$ORIGIN_MAIN" ]; then
  otkaz "main разошёлся с origin/main (локально $LOCAL_MAIN, на origin $ORIGIN_MAIN) — выровняй main с origin/main и повтори"
fi
# main равен живому origin/main: объект авторитетной шапки уже локален;
# дополнительный fetch здесь ничего не удостоверяет и не нужен.
FREEZE_COMMIT="$(git -C "$ROOT" rev-parse --verify --quiet "${ref_new}^{commit}" 2>/dev/null || true)"
if [ -z "$FREEZE_COMMIT" ]; then
  otkaz "коммит заморозки frozen/contracts/$NNN/$vmax не резолвится (^{commit} пуст)"
fi
if ! git -C "$ROOT" merge-base --is-ancestor "$FREEZE_COMMIT" "$ORIGIN_MAIN" 2>/dev/null; then
  otkaz "коммит заморозки $FREEZE_COMMIT (frozen/contracts/$NNN/$vmax) не предок origin/main — ленд носителя заморозки не состоялся (publish тега недостаточно)"
fi

# ── манифест HEAD: ровно одна строка NNN, грамматика, старая сторона ─────────
head_manifest="$(git -C "$ROOT" cat-file -p "HEAD:$_REG_FILE" 2>/dev/null || true)"
if [ -z "$head_manifest" ] && ! git -C "$ROOT" cat-file -e "HEAD:$_REG_FILE" 2>/dev/null; then
  otkaz "манифест $_REG_FILE отсутствует в HEAD — REPLACE нечего менять"
fi
cnt="$(printf '%s\n' "$head_manifest" | awk -v n="$NNN" 'index($0, n " ") == 1 { c++ } END { print c+0 }')"
if [ "$cnt" -eq 0 ]; then
  otkaz "строки $NNN нет в манифесте — REPLACE нечего менять"
fi
if [ "$cnt" -ne 1 ]; then
  otkaz "строк $NNN в манифесте не одна ($cnt) — REPLACE неоднозначен"
fi
OLD_LINE="$(printf '%s\n' "$head_manifest" | awk -v n="$NNN" 'index($0, n " ") == 1 { print; exit }')"
if ! printf '%s\n' "$OLD_LINE" | grep -Eqx '[0-9]{3} → [0-9a-f]{40}'; then
  otkaz "строка $NNN не по грамматике манифеста «NNN → 40-hex»"
fi
OLD_SHA="$(printf '%s\n' "$OLD_LINE" | awk '{ print substr($0, length($0)-39) }')"
if [ "$OLD_SHA" = "$NEW_SHA" ]; then
  otkaz "повторный REPLACE — строка $NNN уже указывает на tag-object frozen/contracts/$NNN/$vmax"
fi
# Старая сторона — зеркально двери 031: tag-object id/CONTRACT/<NNN> ИЛИ
# frozen/contracts/<NNN>/<vmax-1> (жив ∧ аннотирован ∧ sha равен).
old_ok=0
ref_mint="refs/tags/id/CONTRACT/$NNN"
if git -C "$ROOT" show-ref --verify --quiet "$ref_mint" \
   && [ "$(git -C "$ROOT" cat-file -t "$ref_mint" 2>/dev/null || true)" = "tag" ] \
   && [ "$(git -C "$ROOT" rev-parse "$ref_mint" 2>/dev/null || true)" = "$OLD_SHA" ]; then
  old_ok=1
fi
if [ "$old_ok" -eq 0 ]; then
  vmax_prev="$(decimal_sub1 "$vmax")"
  if [ -n "$vmax_prev" ] && [ "$vmax_prev" != "0" ]; then
    ref_prev="refs/tags/frozen/contracts/$NNN/$vmax_prev"
    if git -C "$ROOT" show-ref --verify --quiet "$ref_prev" \
       && [ "$(git -C "$ROOT" cat-file -t "$ref_prev" 2>/dev/null || true)" = "tag" ] \
       && [ "$(git -C "$ROOT" rev-parse "$ref_prev" 2>/dev/null || true)" = "$OLD_SHA" ]; then
      old_ok=1
    fi
  fi
fi
if [ "$old_ok" -ne 1 ]; then
  otkaz "sha старой строки ≠ ни tag-object id/CONTRACT/$NNN, ни tag-object frozen/contracts/$NNN/$vmax_prev"
fi

# ── запись: awk во временный файл + mv; коммит ШТАТНОЙ дверью 031 ────────────
# Замена — ПОЛНОЕ строковое равенство (не префикс): чужие строки не затрагиваются.
NEW_LINE="$(printf '%s → %s' "$NNN" "$NEW_SHA")"
TMP="$(mktemp "$ROOT/.replace-line-$NNN.XXXXXX")" \
  || otkaz "не создать временный файл в $ROOT"
trap 'rm -f "$TMP"' EXIT
awk -v o="$OLD_LINE" -v n="$NEW_LINE" '$0 == o { print n; next } { print }' \
  "$ROOT/$_REG_FILE" > "$TMP"
if ! grep -qFx -- "$NEW_LINE" "$TMP" || grep -qFx -- "$OLD_LINE" "$TMP"; then
  otkaz "замена строки $NNN не состоялась (вход ≠ ожиданию манифеста) — дерево не мутировано"
fi
mv "$TMP" "$ROOT/$_REG_FILE"
trap - EXIT
git -C "$ROOT" add -- "$_REG_FILE"
# Identity — ЯВНЫМ env в ОДНОЙ строке с commit (канарейка И-5, mint_line 068);
# командная строка коммита НЕ несёт НИ ОДНОГО -c и НИ ОДНОГО обходного флага:
# ни --no-verify, ни -c core.hooksPath — дверь 031 судит коммит штатно.
if ! GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local git -C "$ROOT" commit -q --no-gpg-sign -m "реестр: REPLACE строки $NNN (replace_line, контракт 212)"; then
  # Откат точечный: вернуть index+worktree пути к HEAD (дверь отказала).
  git -C "$ROOT" checkout HEAD -- "$_REG_FILE" 2>/dev/null || true
  otkaz "commit строки реестра отказал (дверь минта 031) — дерево возвращено к HEAD"
fi

COMMIT_SHA="$(git -C "$ROOT" rev-parse HEAD)"
printf 'REPLACED nnn=%s old=%s new=%s commit=%s\n' "$NNN" "$OLD_SHA" "$NEW_SHA" "$COMMIT_SHA" >&2
exit 0
