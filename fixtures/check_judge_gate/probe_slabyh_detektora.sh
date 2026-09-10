#!/usr/bin/env bash
# Проба привязки слабых реализаций контракта 024, правка-круг 2 (вердикт
# 4d1d265, блокер 4). Н-39: привязка стаба к входу — КОДОМ фикстур, не прозой
# контракта; проба сверяет для КАЖДОЙ слабой формы ТРОЙКУ: rc≠0 ∧ имя ворота
# («ворота N (») ∧ ПРИЧИНА отказа (токен диагностики). Безымянная смерть —
# двухстрочный exit-1-плацебо — зачётом НЕ ЯВЛЯЕТСЯ: фаза-плацебо строит
# плацебо напрямую и требует, чтобы оно НЕ удовлетворяло паттерн фазы
# «всегда-чисто» (ровно эксперимент 3 вердикта: замена стаба на exit 1
# оставляла пробу зелёной — v1 мерила только rc≠0).
#
# Каждая фаза подставляет в toy-корень scripts/check_no_leak.sh одну из форм
# детектора и гоняет red_detektor_utechek.sh ПРЯМЫМ запуском (прямые запуски
# red/stab/probe — вне case_*-глоба раннера, прецедент red_mera 021):
#   фаза 1  — честная форма (stab_detektor_chestnyj.sh) → red rc 0: все 14
#              ворот проходят против эталона договора целиком;
#   фазы 2+ — слабые формы: red rc≠0, причём выход несёт ИМЯ ворота и
#              ПРИЧИНУ, названные в шапке соответствующего стаба (какой
#              ворот какой форме принадлежит — ДАННЫЕ ЭТОЙ пробы, не проза
#              контракта);
#   фаза-плацебо — exit-1 без диагностики обязан быть ОТВЕРГНУТ.
# Ожидания фаз СТАБИЛЬНЫ — и до, и после реализации 024; на живом дереве
# проба ничего не утверждает (все прогоны в подставных toy-корнях, скратч
# умирает trap'ом).
#
# Коды возврата: 0 — честная форма проходит, все слабые пойманы по имени
#               ворота и причине, плацебо отвергнуто; 1 — именованный отказ.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
T="$(mktemp -d /tmp/probe024-detektor.XXXXXX)"
trap 'rm -rf "$T"' EXIT
fail() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

mk_toy() {  # <каталог> <файл-детектора>
  mkdir -p "$1/scripts" "$1/fixtures/check_judge_gate"
  cp "$2" "$1/scripts/check_no_leak.sh"
  cp "$HERE/red_detektor_utechek.sh" "$1/fixtures/check_judge_gate/"
}
run_red() {  # <каталог>
  bash "$1/fixtures/check_judge_gate/red_detektor_utechek.sh" 2>&1
}

# ── фаза 1: честная форма детектора ───────────────────────────────────────────
mk_toy "$T/r01-chestnyj" "$HERE/stab_detektor_chestnyj.sh"
out="$(run_red "$T/r01-chestnyj")" && rc=0 || rc=$?
[ "$rc" -eq 0 ] || fail "честная форма: red rc=$rc
$out"
printf '  ok   честная форма: 14 ворот зелены\n' >&2

# ── фазы слабых форм: rc≠0 ∧ имя ворота ∧ причина ─────────────────────────────
# slobaja <имя-стаба> <ворот> <токен-причины> <описание-дефекта>
slobaja() {  # <файл> <N> <причина> <описание>
  local stub="$1" gate="$2" cause="$3" desc="$4" dir out rc
  dir="$T/$(basename "$stub" .sh)"
  mk_toy "$dir" "$HERE/$stub"
  out="$(run_red "$dir")" && rc=0 || rc=$?
  [ "$rc" -ne 0 ] || fail "слабая «$desc» не поймана: red rc=0
$out"
  printf '%s\n' "$out" | grep -qF -- "ворота $gate (" \
    || fail "слабая «$desc»: смерть без имени ворот $gate (rc=$rc)
$out"
  printf '%s\n' "$out" | grep -qF -- "$cause" \
    || fail "слабая «$desc»: причина «$cause» не в диагнозе (ворот $gate, rc=$rc)
$out"
  printf '  ok   %s: ворота %s, причина «%s»\n' "$desc" "$gate" "$cause" >&2
}

slobaja stab_detektor_vsegda_chisto.sh            1  'ожидался 1'                  'всегда-чисто'
slobaja stab_detektor_snimok_v_dereve.sh          2  'ожидался 0'                  'снимок-в-дереве'
slobaja stab_detektor_bez_snapshota_propuskaet.sh 5  'не имеет права проходить'    'без-снимка-пропускает'
slobaja stab_detektor_pervyj_snimok_navsegda.sh   6  'не вошёл в базу'             'первый-снимок-навсегда'
slobaja stab_detektor_svoja_cwd.sh                7  'снимок отсутствует'          'своя-cwd: судит приманку, не жертву'
slobaja stab_detektor_obeih_cwd.sh                7  'имя приманки'                'обеих-cwd: приманка названа'
slobaja stab_detektor_tihij_cwd.sh                8  'ожидался 0'                  'тихий-cwd: грязный cwd краснит чистую жертву'
slobaja stab_detektor_porcelain_mnozhestvo.sh     9  'ожидался 1'                  'porcelain-множество: содержимое замаскировано строкой статуса'
slobaja stab_detektor_svertka_katalogov.sh        10 'ожидался 1'                  'свёртка-каталогов: файл под ?? dir/ не виден'
slobaja stab_detektor_bez_gitlinkov.sh            11 'ожидался 1'                  'без-gitlinkов: правка в submodule не видна'
slobaja stab_detektor_bez_abs_kornja.sh           12 'ожидался 1'                  'без-абс-корня: относительный корень принят'
slobaja stab_detektor_bez_root_stroki.sh          13 'снимок чужого корня'         'без-root-строки: чужой снимок не отвергнут'
slobaja stab_detektor_zapisi_pri_sverke.sh        14 'изменили porcelain'          'запись-при-сверке: сверка пишет в стерегомое'

# ── фаза-плацебо: exit-1 без диагностики зачётом не является ──────────────────
# (эксперимент 3 вердикта 4d1d265: v1-проба приняла двухстрочный exit 1 как
# «всегда-чисто пойман на воротах 1» — мерила только rc≠0.)
mkdir -p "$T/r-platsebo/scripts" "$T/r-platsebo/fixtures/check_judge_gate"
printf '#!/usr/bin/env bash\nexit 1\n' > "$T/r-platsebo/scripts/check_no_leak.sh"
cp "$HERE/red_detektor_utechek.sh" "$T/r-platsebo/fixtures/check_judge_gate/"
out="$(run_red "$T/r-platsebo")" && rc=0 || rc=$?
[ "$rc" -ne 0 ] || fail "плацебо не умерло: red rc=0
$out"
if printf '%s\n' "$out" | grep -qF -- 'ворота 1 (' && printf '%s\n' "$out" | grep -qF -- 'ожидался 1'; then
  fail "плацебо зачтено как «всегда-чисто» (ворота 1 + «ожидался 1») — проба различает только rc, диагностика не сверяется
$out"
fi
printf '  ok   плацебо exit-1 отвергнуто: смерть без диагностики фазы не удовлетворяет\n' >&2

printf 'пойманы по имени ворота и причине: всегда-чисто, снимок-в-дереве, без-снимка-пропускает, первый-снимок-навсегда, своя-cwd, обеих-cwd, тихий-cwd, porcelain-множество, свёртка-каталогов, без-gitlinkов, без-абс-корня, без-root-строки, запись-при-сверке; честная форма проходит все 14 ворот; плацебо exit-1 отвергнуто\n' >&2
exit 0
