#!/usr/bin/env bash
# Барьер: идентификаторы артефактов уникальны и согласованы с историей выдачи.
#
# Заведено потому, что до этого механизма номер артефакта назначался вручную, и в этом
# репозитории уже сталкивались два файла под одним номером (план 005 §2). Номер выдаёт
# `next_id.sh`, и обратной силы у механизма нет — этот барьер следит, чтобы прошлое и
# будущее совпадали.
#
# ЧТО ЛОВИТСЯ (два дефекта, оба с именами файлов):
#   1. два файла одного класса с одним номером — код 1, названы ОБА (требование плана §2);
#   2. номер, которого нет в истории выдачи — артефакт есть на `HEAD`, но max+1 по истории
#      его не покрывает. Это ловит ручное назначение номера, минуя `next_id.sh`.
#
# ОБЛАСТЬ ВЫВЕДЕНА ИЗ ПРЕДМЕТА, а не задана списком каталогов. Класс → куда он кладётся:
#   PLAN    → plans/                       — планы в корне;
#   VERDICT → verdicts/<роль>/             — пути читаются из roles/*.md (поле `verdict:`),
#                                             а не вписываются вторым списком;
#   ADR     → decisions/                   — место выбрано в `next_id.sh` и повторено здесь,
#                                             чтобы разные пути не заводили ещё одну
#                                             ручную таблицу.
#
# АРТЕФАКТЫ БЕЗ НОМЕРА ЗАКОННЫ: механизм выдаёт номера только вперёд, и `verdicts/adversary/
# mech-1-antiplacebo.md` без номера — норма. Номер ему поставит тот, кому он достанется, а
# обратной силы нет. Здесь такие файлы просто не учитываются.
#
#   bash scripts/check_ids.sh            проверить это дерево
#
# Коды возврата: 0 — уникальны и в истории, 1 — нарушение, 2 — нечем проверить.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fails=0
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git — историю выдачи прочитать нечем"

# ── локации класса ─────────────────────────────────────────────────────────────
# VERDICT: пути читаются из ролей. Захардкоженный список отстал бы от новой роли молча —
# это правило уже выстрелило в `verify_antiplacebo.sh` (там три имени заданы списком и
# четвёртое пропущено), и здесь будет то же.
class_locs() {
  case "$1" in
    PLAN)    printf 'plans/\n' ;;
    VERDICT)
      # Пути читаются из ролей. Если `roles/` нет (фикстура с минимумом) — выдаём пусто:
      # `find ... -maxdepth 1` без сюрпризов, и шумность отсутствующего каталога здесь
      # не подменяется шумностью глоба (`grep: roles/*.md: No such file or directory`).
      [ -d "$HERE/roles" ] || return 0
      find "$HERE/roles" -maxdepth 1 -type f -name '*.md' 2>/dev/null \
        | while IFS= read -r f; do
            grep -hoE '^verdict: [^[:space:]]+' "$f" 2>/dev/null
          done \
        | grep -v 'null' | sed 's/^verdict: //'
      ;;
    ADR)     printf 'decisions/\n' ;;
    *)       return 1 ;;
  esac
}
# ── артефакты класса: TSV `путь<TAB>номер` построчно ──────────────────────────
# Только файлы с числовым префиксом (`NNN-name.md`). Без префикса — легитимный
# безномерной артефакт, и его обратной силой не нумеруют.
collect() {
  local class="$1"
  while IFS= read -r loc; do
    [ -n "$loc" ] || continue
    local d="$HERE/$loc"
    [ -d "$d" ] || continue
    find "$d" -maxdepth 1 -type f 2>/dev/null
  done < <(class_locs "$class") \
  | while IFS= read -r f; do
      [ -n "$f" ] || continue
      local name; name="$(basename "$f")"
      if [[ "$name" =~ ^([0-9]+)- ]]; then
        local n; n=$((10#${BASH_REMATCH[1]}))
        printf '%s\t%s\n' "$f" "$n"
      fi
    done
}

# ── max в истории выдачи: max номера, который ХОТЯ БЫ РАЗ был добавлен ─────────
# `git log --all --diff-filter=A --name-only` даёт пути, добавленные в любой коммит любой
# достижимой ветки. Из них вытаскиваем числа из локаций класса. Незакоммиченный файл в
# этой истории не виден — и это правильно: номер, который ни разу не выдавался, не должен
# проходить только потому, что файл лежит в рабочем дереве.
max_history() {
  local class="$1"
  while IFS= read -r loc; do
    [ -n "$loc" ] || continue
    # Точное совпадение пути под локацией (`plans/005-foo.md`), без подкаталогов.
    # `-x` — путь должен совпасть ЦЕЛИКОМ, иначе `plans/006-foo` ловит и `plans/006-foo/bar.md`.
    git -C "$HERE" log --all --diff-filter=A --name-only --format= 2>/dev/null \
      | grep -xE "${loc}[^/]+" || true
  done < <(class_locs "$class") \
  | while IFS= read -r path; do
      # Только файлы с числовым префиксом. `verdicts/.../mech-1-...md` легитимен без номера —
      base="${path##*/}"
      if [[ "$base" =~ ^([0-9]+)- ]]; then
        printf '%s\n' "$((10#${BASH_REMATCH[1]}))"
      fi
    done
}

# ── обход классов ──────────────────────────────────────────────────────────────
violations=0
for class in PLAN VERDICT ADR; do
  # Артефакты в локациях класса — строки TSV `путь<TAB>номер`.
  mapfile -t artifacts < <(collect "$class")

  # max в истории. Если истории нет (пустой репо) — max=0, и тогда валиден только номер 1.
  mapfile -t history < <(max_history "$class")
  max_h=0
  for n in "${history[@]}"; do
    [ -n "$n" ] && [ "$n" -gt "$max_h" ] && max_h="$n"
  done
  valid_max=$((max_h + 1))

  # `seen`: первый встреченный путь для каждого номера. Повторный путь — нарушение.
  declare -A seen=()
  for line in "${artifacts[@]}"; do
    [ -n "$line" ] || continue
    IFS=$'\t' read -r f n <<<"$line"
    [ -n "$f" ] && [ -n "$n" ] || continue
    rel="${f#"$HERE"/}"

    # Defect 2: номер вне истории выдачи. Покрывает ручное назначение высокого номера —
    # `next_id.sh` такого не выдаёт, потому что выдаёт только max+1.
    if [ "$n" -gt "$valid_max" ]; then
      bad "номер $n вне истории выдачи (max в истории: $max_h, выдаваемый диапазон: [1, $valid_max]) — $rel"
      violations=$((violations + 1))
      continue
    fi

    # Defect 1: дубликат номера в классе.
    if [ -n "${seen[$n]:-}" ]; then
      other_rel="${seen[$n]#"$HERE"/}"
      bad "одинаковый номер $n в классе $class: $other_rel и $rel"
      violations=$((violations + 1))
    else
      seen[$n]="$f"
    fi
  done
  unset seen
done

if [ "$violations" -gt 0 ]; then
  exit 1
fi
ok "номера уникальны и в пределах истории выдачи"