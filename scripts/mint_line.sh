#!/usr/bin/env bash
# НЕ БАРЬЕР: инструмент оркестратора (регистрационная строка реестра — не гейт приёмки); его приёмка — fixtures/mint_line/red_mint_line_068.sh через семью accept_task_commit
# mint_line — строка реестра контрактов «<NNN> → <tag-object-sha>» маршрутом
# ОРКЕСТРАТОРСКОГО bash-скрипта (контракт 068, боль (б): 4 ручных минта подряд
# 064-067 и 068-071 — spawn_agent/land_agent-класс операции исполнен руками).
#
# ЧТО ДЕЛАЕТ: проверяет dual-control провенанс ЖИВОГО тега id/CONTRACT/<NNN>
# (локально ∧ на origin, sha совпадают), отказывает на повторном минте и
# грязном дереве, дописывает строку в registry/contracts.tsv и КОММИТИТ её на
# main с identity orchestrator. Дверь 031 (check_staged ADD-форма) остаётся
# СУДЬЁЙ: скрипт её не подменяет и не обходит — commit идёт штатным хуком.
# НЕОТВРАТИМОСТЬ (Б2 круга 1): эффективный hooks-каталог проверен ДО записи
# (конфиг-дизарм → именованный отказ), командная строка коммита НЕ несёт ни
# одного -c (identity — env GIT_AUTHOR_*/GIT_COMMITTER_*): hooksPath-инъекция
# -c остаётся единственной чужеродной точкой и различима клеткой батареи.
#
# ЧТО НЕ ДЕЛАЕТ: НЕ минтит тег (next_id — единый источник выдачи номеров);
# НЕ пушит (публикация — отдельный шаг оркестратора через scripts/gitw, норма
# HANDOFF «git-обмены — только через gitw»); НЕ правит чужие строки манифеста
# (дельта — ровно одна добавленная строка).
#
# КОНТРАКТ CLI:
#   scripts/mint_line.sh --nnn <NNN> [--root <каталог>]
#     --nnn NNN   номер контракта, 1-3 цифры (нормализуется %03d), обязательно
#     --root КАТ  корень репозитория (по умолчанию cwd)
#
# stdout при успехе (ровно одна строка, машинно-читаемо):
#   MINTED nnn=<NNN> sha=<tag-object-sha> commit=<sha>
#
# ОТКАЗЫ rc 1 (именованные; дерево НЕ мутируется — строка пишется ПОСЛЕ всех
# проверок, при отказе двери на коммите откатывается точечно):
#   номер не выдан (тег отсутствует локально) / тег не аннотированный /
#   авторитет недоступен (origin не настроен, ls-remote отказал — fail-closed,
#   обрыв сети НЕ пишет строку) / тег не достижим на origin (self-mint) /
#   sha локального тега ≠ sha тега на origin (переминт) / номер уже в
#   манифесте — повторный минт / HEAD не main / грязное дерево / дверь 031
#   отключена конфигом (эффективный hooks-каталог без живого pre-commit).
# rc 2 — нечем проверить (нет git, --root не репозиторий, --nnn вне грамматики).
#
# ГРАММАТИКА СТРУКТУРНЫХ ПОЛЕЙ (норма 041 §Инварианты п.2):
#   --nnn <номер>   ^[0-9]{1,3}$  (нормализация printf %03d; замкнутый алфавит)
#   строка реестра  «<NNN> → <40-hex>» — NNN ровно %03d, разделитель U+2192,
#                   40-hex = ША ОБЪЕКТА аннотированного тега (единый источник
#                   грамматики — контракт 023/031; строка собирается ОДНИМ
#                   printf, потребители не переизобретают).
#   ЛИТЕРАЛЬНЫЕ сравнения: sha тега на origin vs локально — bash `[ = ]`,
#   NEVER regex/glob из untrusted.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

usage() {
  cat >&2 <<USAGE
использование: mint_line.sh --nnn <NNN> [--root <каталог>]

Аргументы:
  --nnn NNN    номер контракта (1-3 цифры), обязательно
  --root КАТ   корень репозитория. По умолчанию — текущий.

Контракт: печатает MINTED nnn=<NNN> sha=<sha> commit=<sha> на stdout, rc 0.
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
    *) printf 'mint_line: неизвестный аргумент: %s\n' "$1" >&2; usage ;;
  esac
done

[ -n "$NNN_ARG" ] || { printf 'mint_line: --nnn обязателен\n' >&2; usage; }
# Замкнутый алфавит, точечный якорь на обе границы: ^[0-9]{1,3}$
if ! printf '%s\n' "$NNN_ARG" | grep -Eqx '[0-9]{1,3}'; then
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

# Строка реестра живёт ТОЛЬКО на main (дверь 031 условие 6; зеркалит land_agent
# «wip/* ответвляются от main»).
current_head="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
if [ "$current_head" != "main" ]; then
  printf 'ОТКАЗ: HEAD не main (текущая ветка: %s) — строка реестра коммитится только на main\n' "$current_head" >&2
  exit 1
fi

# Коммит строки — ЕДИНСТВЕННЫЙ предмет вызова: грязное дерево (staged или
# modified tracked) отказывает заранее (И-7-класс, land_agent).
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  printf 'ОТКАЗ: грязное дерево — коммит строки реестра обязан быть единственным предметом\n' >&2
  exit 1
fi
# 0. Дверь 031 неотвратима для ЭТОГО коммита (Б2 круга 1): эффективный
# hooks-каталог обязан нести ИСПОЛНЯЕМЫЙ pre-commit ЕЩЁ ДО записи строки —
# конфиг-дизарм (core.hooksPath ведёт мимо двери) отказывает именем. Формы
# с ~ не распознаются → отказ (fail-closed, как и пустой каталог).
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
  printf 'ОТКАЗ: дверь 031 отключена конфигом (эффективный hooks-каталог %s без исполняемого pre-commit) — строка реестра коммитится только сквозь живую дверь\n' "$HOOKS_DIR" >&2
  exit 1
fi

# 1. Тег жив локально (реестр первичен — зеркалит порядок двери 023/031).
if ! git -C "$ROOT" show-ref --verify --quiet "refs/tags/id/CONTRACT/$NNN"; then
  printf 'ОТКАЗ: номер %s не выдан — тег id/CONTRACT/%s отсутствует\n' "$NNN" "$NNN" >&2
  exit 1
fi
# 2. Аннотированность: объект под refs/tags — tag, не commit (имя отдельное
# от «не жив», совет 3 круга 1 контракта 031).
tag_type="$(git -C "$ROOT" cat-file -t "refs/tags/id/CONTRACT/$NNN" 2>/dev/null || true)"
if [ "$tag_type" != "tag" ]; then
  printf 'ОТКАЗ: тег id/CONTRACT/%s не аннотированный\n' "$NNN" >&2
  exit 1
fi
TAG_SHA="$(git -C "$ROOT" rev-parse "refs/tags/id/CONTRACT/$NNN")"
if ! printf '%s\n' "$TAG_SHA" | grep -Eqx '[0-9a-f]{40}'; then
  printf 'NOT_IMPLEMENTED: tag-object-sha вне грамматики [0-9a-f]{40}: %s\n' "$TAG_SHA" >&2
  exit 2
fi

# 3. Dual-control: тег достижим на origin И sha совпадает. Отказ сети —
# fail-closed «авторитет недоступен» (имя ОТДЕЛЬНО от «не выдан авторитетом»;
# 023:289-290 дословно). Peeled-строки ^{} исключаются (sha коммита ≠ tag-object).
if ! git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
  printf 'ОТКАЗ: авторитет недоступен: remote origin не настроен — fail-closed, обрыв сети НЕ пишет строку\n' >&2
  exit 1
fi
ls_rc=0
ls_out="$(git -C "$ROOT" ls-remote "origin" "refs/tags/id/CONTRACT/$NNN" 2>/dev/null)" || ls_rc=$?
if [ "$ls_rc" -ne 0 ]; then
  printf 'ОТКАЗ: авторитет недоступен (ls-remote origin не ответил, rc=%s) — fail-closed, обрыв сети НЕ пишет строку\n' "$ls_rc" >&2
  exit 1
fi
sha_origin="$(printf '%s\n' "$ls_out" | grep -v '}' | head -1 | awk '{print $1}')"
if [ -z "$sha_origin" ]; then
  printf 'ОТКАЗ: тег %s не выдан авторитетом: тег не достижим на origin (self-mint)\n' "$NNN" >&2
  exit 1
fi
# ЛИТЕРАЛЬНОЕ сравнение (норма 037: never regex/glob из untrusted).
if [ "$TAG_SHA" != "$sha_origin" ]; then
  printf 'ОТКАЗ: тег %s не выдан авторитетом: sha локального тега (%s) ≠ sha тега на origin (%s) — переминт\n' "$NNN" "$TAG_SHA" "$sha_origin" >&2
  exit 1
fi

# 4. Повторный минт: NNN не должен жить в манифесте HEAD (дверь 031 условие 3
# судит ещё и живую шапку origin/main — на коммите).
head_manifest="$(git -C "$ROOT" cat-file -p "HEAD:registry/contracts.tsv" 2>/dev/null || true)"
if printf '%s\n' "$head_manifest" | grep -qF "$NNN → "; then
  printf 'ОТКАЗ: номер %s уже в манифесте — повторный минт\n' "$NNN" >&2
  exit 1
fi

# 5. Пишем строку и коммитим с identity orchestrator (дверь 031 действительна
# ТОЛЬКО для автора orchestrator). Строка — ОДНИМ printf (U+2192 литералом),
# грамматика не переизобретается. Identity — ЯВНЫМ env в ОДНОЙ строке с commit
# (канарейка И-5, Н-61/А-25); командная строка коммита НЕ несёт НИ ОДНОГО -c:
# подпись — флагом --no-gpg-sign, единственная оставшаяся точка обхода двери
# (hooksPath-инъекция -c) чужеродна и ловится клеткой батареи (Б2 круга 1).
mkdir -p "$ROOT/registry"
printf '%s → %s\n' "$NNN" "$TAG_SHA" >> "$ROOT/registry/contracts.tsv"
git -C "$ROOT" add -- registry/contracts.tsv
if ! GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local git -C "$ROOT" commit -q --no-gpg-sign -m "реестр: строка $NNN (mint_line, контракт 068)"; then
  # Откат точечный: вернуть index+worktree пути к HEAD (дверь отказала —
  # например, номер уже в манифесте ЖИВОЙ шапки origin/main).
  git -C "$ROOT" checkout HEAD -- registry/contracts.tsv 2>/dev/null || true
  printf 'ОТКАЗ: commit строки реестра отказал (дверь минта 031) — дерево возвращено к HEAD\n' >&2
  exit 1
fi

COMMIT_SHA="$(git -C "$ROOT" rev-parse HEAD)"
printf 'MINTED nnn=%s sha=%s commit=%s\n' "$NNN" "$TAG_SHA" "$COMMIT_SHA"
exit 0
