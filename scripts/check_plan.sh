#!/usr/bin/env bash
# check_plan.sh — страж плана 084 (контракт 084 §И-7). Семь классов отказа в точном порядке:
#   (1) план недоступен; (2) грамматика/пустота; (3) источник не резолвится; (4) номер вне
#       реестра; (5) зависимость на несуществующий id; (6) блок ROADMAP; (7) блок HANDOFF.
#
# Использование: bash scripts/check_plan.sh [--root <dir>] [--pre-commit]
#   --root <dir>     — корень проверяемого дерева (по умолчанию — каталог скрипта).
#   --pre-commit     — исполнить группу (7) ТОЛЬКО если HANDOFF.md есть в `git diff --cached`
#                      (Р10: теги общие для worktree, а HANDOFF — файл ветки).
#
# Коды возврата:
#   0 — все группы зелёные.
#   1 — первая красная (по порядку групп).
#   2 — NOT_IMPLEMENTED (корень не git-репозиторий).
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_plan.sh"

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

pre_commit=0
root="$SELF_DIR/.."
while [ $# -gt 0 ]; do
  case "$1" in
    --root)       [ $# -ge 2 ] || die "--root требует путь"; root="$2"; shift 2 ;;
    --pre-commit) pre_commit=1; shift ;;
    *)            die "флаг вне грамматики: $1"; shift ;;
  esac
done

command -v git >/dev/null 2>&1 || skip "нет git"
[ -d "$root" ] || skip "корня нет: $root"
root="$(cd "$root" && pwd)"
git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || skip "корень не git-репозиторий: $root"

PLAN="$root/registry/plan.tsv"
ROADMAP="$root/ROADMAP.md"
HANDOFF="$root/HANDOFF.md"
REG="$root/registry/contracts.tsv"

# ── (1) план недоступен ──────────────────────────────────────────────────────────
[ -f "$PLAN" ] || die "план недоступен: registry/plan.tsv отсутствует"

# ── (2) грамматика построчно ─────────────────────────────────────────────────────
plan_parse "$PLAN" || die "$P84_PLAN_ERR"

# ── (3) источник не резолвится ───────────────────────────────────────────────────
# Форма sha: `git cat-file -e <sha>^{commit}`. Форма docs: файл существует в ДЕРЕВЕ (И-1: «в
# дереве»); в нём есть строка-ЗАГОЛОВОК («#+ », пробел после решёток), текст которой начинается
# с <раздел> и за ним пробел, «.» или конец строки. Контрпример: регулярка/префикс/без «#+ »
# или поиск в прозе.
for i in "${!P84_ID[@]}"; do
  id="${P84_ID[$i]}"; src="${P84_SRC[$i]}"
  if p84_is_source_sha "$src"; then
    git -C "$root" cat-file -e "${src}^{commit}" 2>/dev/null \
      || die "источник не резолвится: ${id}: ${src}"
  else
    doc="${src%#*}"; sec="${src#*#}"
    f="$root/$doc"
    if [ ! -f "$f" ]; then
      die "источник не резолвится: ${id}: ${src}"
    fi
    # Заголовок: одна или более «#», затем пробел, затем текст. Текст начинается с <sec> и
    # за ним — пробел, «.» или конец строки (уровни #…#### перебираются toy'ом).
    found=0
    while IFS= read -r line; do
      rest="${line#"${line%%[![:space:]]*}"}"
      hashes="${rest%% *}"
      case "$hashes" in '#'|'##'|'###'|'####'|'#####'|'######') ;; *) continue ;; esac
      body="${rest#* }"
      case "$body" in
        "${sec}") found=1; break ;;
        "${sec} "*) found=1; break ;;
        "${sec}."*) found=1; break ;;
      esac
    done < "$f"
    [ "$found" -eq 1 ] || die "источник не резолвится: ${id}: ${src}"
  fi
done

# ── (4) номер вне реестра ───────────────────────────────────────────────────────
# Сравнение литеральное: первое поле строки registry/contracts.tsv до « → ». Ровно NNN, не
# подстрока (е1: sha чужой строки содержит цифры NNN — не считается).
declare -A have_contracts=()
if [ -f "$REG" ]; then
  while IFS= read -r line; do
    case "$line" in *' → '*) num="${line%% → *}"; have_contracts["$num"]=1 ;; esac
  done < "$REG"
fi
for i in "${!P84_ID[@]}"; do
  id="${P84_ID[$i]}"
  p84_is_num_id "$id" || continue
  [ -n "${have_contracts[$id]+x}" ] || die "номер вне реестра: ${id}"
done

# ── (5) зависимость на несуществующий id ────────────────────────────────────────
# Сравнение литеральное по полному значению dep: grep -Fx до списка id, не regex/prefix.
declare -A have_ids=()
for id in "${P84_ID[@]}"; do have_ids["$id"]=1; done
for i in "${!P84_ID[@]}"; do
  id="${P84_ID[$i]}"; deps="${P84_DEPS[$i]}"
  [ "$deps" = "-" ] && continue
  IFS=',' read -r -a da <<< "$deps"
  for dep in "${da[@]}"; do
    [ -n "${have_ids[$dep]+x}" ] || die "зависимость на несуществующий id: ${id} → ${dep}"
  done
done

# ── Вспомогательное: различение «нет блока» vs «не один» по счётчикам маркеров ────
# Контракт: «не один» — любая маркерная строка встречается больше одного раза;
# неполная или перевёрнутая пара — «нет блока».
p84_marker_status() {  # <файл> <B> <E> → печатает «нет»/«не один»/«ok»; rc 0/1
  local f="$1" B="$2" E="$3"
  local bc ec
  bc="$(grep -cFx "$B" "$f" 2>/dev/null || true)"
  ec="$(grep -cFx "$E" "$f" 2>/dev/null || true)"
  # «не один» — любая маркерная строка встречается больше одного раза.
  # «нет блока» — оба маркера отсутствуют ИЛИ один отсутствует (неполная пара).
  # «ok» — оба по одному (p84_block_index уже проверил BEGIN < END).
  if [ "${bc:-0}" -gt 1 ] || [ "${ec:-0}" -gt 1 ]; then
    printf 'не один\n'; return 1
  fi
  if [ "${bc:-0}" -eq 0 ] || [ "${ec:-0}" -eq 0 ]; then
    printf 'нет\n'; return 1
  fi
  printf 'ok\n'; return 0
}

# ── (6) блок ROADMAP — ПОБАЙТОВАЯ СВЕРКА С ГЕНЕРАЦИЕЙ ────────────────────────────
# Не пишем в ROADMAP.md (это страж, не писатель). p84_block_index: маркеры по одному и
# BEGIN < END; иначе «нет блока» или «не один». Содержимое == p84_render_roadmap_block →
# иначе «расходится с генерацией».
[ -f "$ROADMAP" ] || die "в ROADMAP.md нет блока плана"
if ! p84_block_index "$ROADMAP" "$P84_RM_BEGIN" "$P84_RM_END" 2>/dev/null; then
  if [ "$(p84_marker_status "$ROADMAP" "$P84_RM_BEGIN" "$P84_RM_END")" = "не один" ]; then
    die "блок плана в ROADMAP.md не один"
  fi
  die "в ROADMAP.md нет блока плана"
fi
roadmap_oracle="$(p84_render_roadmap_block)"
if p84_check_block "$ROADMAP" "$P84_RM_BEGIN" "$P84_RM_END" "$roadmap_oracle" 2>/dev/null; then
  : # совпадает
else
  die "блок ROADMAP расходится с генерацией"
fi
# «Итоговый порядок» вне блока — поиск ФРАЗЫ вне маркеров (И-4, б6): точное вхождение в строке,
# печатаем номер строки файла.
ln=0
in_block=0
while IFS= read -r line || [ -n "$line" ]; do
  ln=$((ln + 1))
  if [ "$line" = "$P84_RM_BEGIN" ]; then in_block=1; continue; fi
  if [ "$line" = "$P84_RM_END" ]; then in_block=0; continue; fi
  if [ "$in_block" -eq 0 ]; then
    case "$line" in *'Итоговый порядок'*) die "«Итоговый порядок» вне блока плана: ROADMAP.md:${ln}" ;; esac
  fi
done < "$ROADMAP"

# ── (7) блок HANDOFF — РАВЕНСТВО ТЕКУЩЕМУ СОСТОЯНИЮ + «done-пункт» ──────────────
# Р10: в --pre-commit исполняется ТОЛЬКО если HANDOFF.md есть в `git diff --cached --name-only`.
# Блок перечисляет активные + годные кандидаты (И-5); после закрытия любого пункта он
# устаревает — это и есть ловушка «done-пункт стоит следующим» (с5, с7).
if [ "$pre_commit" -eq 1 ]; then
  if ! git -C "$root" diff --cached --name-only -- HANDOFF.md 2>/dev/null | grep -q .; then
    exit 0
  fi
fi
[ -f "$HANDOFF" ] || die "в HANDOFF.md нет блока «Следующая сессия»"
if ! p84_block_index "$HANDOFF" "$P84_HO_BEGIN" "$P84_HO_END" 2>/dev/null; then
  if [ "$(p84_marker_status "$HANDOFF" "$P84_HO_BEGIN" "$P84_HO_END")" = "не один" ]; then
    die "блок «Следующая сессия» в HANDOFF.md не один"
  fi
  die "в HANDOFF.md нет блока «Следующая сессия»"
fi
# Закрытый id в блоке HANDOFF = «done-пункт стоит следующим: <id>» (с5, с7).
# Строим множество строк блока и проверяем каждую: если id закрыт (done/закрыт без done) — отказ.
ln=0
in_block=0
while IFS= read -r line || [ -n "$line" ]; do
  ln=$((ln + 1))
  if [ "$line" = "$P84_HO_BEGIN" ]; then in_block=1; continue; fi
  if [ "$line" = "$P84_HO_END" ]; then in_block=0; continue; fi
  if [ "$in_block" -eq 1 ]; then
    case "$line" in
      '- '*' · '*)
        cur_id="${line#- }"; cur_id="${cur_id%% · *}"
        if p84_is_num_id "$cur_id"; then
          st="$(plan_status "$cur_id" "$root")"
          case "$st" in "$P84_ST_DONE"|"$P84_ST_CLOSED") die "done-пункт стоит следующим: ${cur_id}" ;; esac
        fi
        ;;
    esac
  fi
done < "$HANDOFF"