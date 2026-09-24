#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043, задача (в) «паритет CI» (контракт 020): замкнутого
# круга регрессионной защиты этой задачи до сих пор нет — `fixtures/_krasnye_043.sh`
# + `npm run check:precision-battery` + self-application гоняют ЧЕСТНЫЙ вход (а
# toy-дерево через `mk_toy_repo` паритетно: пустые workflow, пустой файл
# исключений, `scripts:{}` — `verify_ci_parity.sh` даёт 0 расхождений), а обманная
# правка САМОГО гейта, которая построчно отключает проверку rc задачи (в)
# (`sed -i 's/\[ "$ci_rc" -eq 0 \] || die/true || die/' scripts/check_precision_gate.sh`),
# проходит ВСЮ референсную пачку незамеченной — гейт зеленее своих проверок, тот
# класс риска, что задача (а) уже закрывает для зон, а задача (б) — для
# case-полярности; задача (в) оставалась непокрытой.
#
# Конструкция теста (минимальный честный toy):
#   * mk_toy_repo → паритетно-чистое дерево (нулевые workflow, нулевой файл
#     исключений, `scripts:{}`);
#   * mk_mint → id/CONTRACT/043 (новая заморозка, не v2+);
#   * put_draft с МИНИМАЛЬНОЙ ЗОНА (`ЗОНА architect: contracts/043-toy-draft.md`
#     — без `fixtures/check_*` путей; задача (б) тогда МОЛЧА не активируется,
#     ни одна затронутая семья не объявлена, семья `check_precision_gate` тоже
#     не объявлена → инвариант 3.0 не срабатывает; изолирует тест от (б) и от
#     сам-применения, которое иначе ушло бы в рекурсию по собственной семье;
#     задача (а) пройдёт тривиально — новый toy без чужих замороженных тегов,
#     коллизии физически нет);
#   * python3-однострочник ломает паритет: добавляет осиротевший npm-скрипт,
#     которого нет ни в `.github/workflows/` (пустой в toy), ни в
#     `config/ci_parity_exceptions.txt` (пустой в toy) — ровно тот класс
#     расхождения, который правило 6 AGENTS.md называет («каждый npm-скрипт
#     либо используется в CI, либо объявлен исключением»);
#   * независимый оракул `verify_ci_parity.sh $WORK` ДО run_barrier
#     подтверждает, что вход действительно красный (rc=1, причина названа) —
#     тот же приём, что адверсарий применяет для verify_ci_parity на реальном
#     дереве в своём вердикте; без этой проверки фикстура зависела бы от
#     поведения самого гейта, который она и тестирует (круг замкнулся бы);
#   * run_barrier + refuse «паритет CI красен» (дословная фраза из
#     scripts/check_precision_gate.sh:524) — фикстура самоверифицируется на
#     ЧЕСТНОМ $SUBJ и ЛОВИТ регрессию на ЛЮБОМ другом BARRIER.
#
# ЛОВ РЕГРЕССИИ (встроен в саму фикстуру, а не отдельным шагом): при внешнем
# BARRIER=<мутированная копия co стабом> `sed -i 's/\[ "$ci_rc" -eq 0 \] || die/true || die/'
# scripts/check_precision_gate.sh` — мутированный гейт возвращает rc=0 на
# красном входе (отказ отключён построчно), refuse видит rc=0 вместо
# ожидаемого 1 и сам кричит ОТКАЗ с rc≠0. Это и есть замкнутый круг
# регрессионной защиты задачи (в) — фикстура не просто фиксирует «гейт
# красный», а действительно ловит отключение проверки rc.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case21.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043

# Ломаем паритет: добавляем осиротевший npm-скрипт (есть в приёмке, нет ни в
# `.github/workflows/` ни в `config/ci_parity_exceptions.txt` — verify_ci_parity
# даёт rc=1 «скрипт «<X>» есть в приёмке, но отсутствует в CI и не объявлен
# исключением»). Python — потому что без зависимостей `json.loads` ровно то, что
# нужно, и он уже требуется самим `verify_ci_parity.sh` (см. scripts/verify_ci_parity.sh:183).
python3 - "$WORK/package.json" <<'PY'
import json, sys
fn = sys.argv[1]
with open(fn, encoding='utf-8') as f:
    pkg = json.load(f)
pkg.setdefault('scripts', {})
pkg['scripts']['orphan'] = 'echo orphan'
with open(fn, 'w', encoding='utf-8') as f:
    json.dump(pkg, f, ensure_ascii=False, indent=2)
    f.write('\n')
PY

# Независимый оракул: ДО run_barrier подтверждаем, что вход действительно
# красный по паритету. Это разрывает круг «фикстура проверяет сама себя»:
# verify_ci_parity — ОТДЕЛЬНЫЙ механизм, не наша реализация.
ci_parity_out=""
ci_parity_rc=0
ci_parity_out="$(bash "$REPO/scripts/verify_ci_parity.sh" "$WORK" 2>&1)" || ci_parity_rc=$?
[ "$ci_parity_rc" -ne 0 ] || {
    printf 'ОТКАЗ: red_21: verify_ci_parity на красном toy дал rc 0 — фикстура не строит красный вход:\n%s\n' "$ci_parity_out" >&2
    exit 1
  }

# put_draft ПОСЛЕ мутации паритета (порядок не влияет — put_draft не трогает
# .github/workflows, config/ci_parity_exceptions.txt или package.json).
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
# refuse ВСЕГДА, без guard `[ "${BARRIER:-x}" = "$SUBJ" ] &&`: фикстура обязана
# ловить регрессию гейта (отключение проверки rc задачи (в)) при ЛЮБОМ BARRIER —
# иначе мутированная копия пройдёт зелёной и круг замкнётся (гейт зеленее своих
# проверок — тот же класс риска, ради которого фикстура и заведена). На честном
# $SUBJ LAST_RC=1 → refuse печатает «отказ rc 1, причина названа дословно» и
# выходит 0; на мутированной копии LAST_RC=0 → refuse выходит 1 с диагностикой
# «rc 0 (ожидался 1)» — это и есть лов регрессии.
refuse 'red_21 (задача (в) «паритет CI» — осиротевший npm-скрипт в toy-дереве обязан краснить гейт)' \
  'паритет CI красен'
exit 0