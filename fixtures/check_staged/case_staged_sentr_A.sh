# ПРИЧИНА: вне зоны: offzone_A.txt
#
# СЕНТИНЕЛЬ A полного сентинель-набора (018 пост-заморозочно; закрывает границу AMT,
# измеренную и названную в шапке case_staged_tipy_vne_zony.sh). НАБОР: пять фикстур,
# ПРИЧИНА каждой — СВОЙ наблюдаемый тип чтения staged (A/M/D/T/R): T держит
# case_staged_tipy_vne_zony (её первый красный — T-вход), A/M/D/R — файлы
# case_staged_sentr_<T>.sh. Перечень наблюдаемых типов и его единый источник —
# шапка case_staged_tipy_vne_zony.sh; здесь не переизлагается (Н-39: второй источник
# разъедется при первой же правке).
#
# ЭТА фикстура держит A: единственный красный вызов — репо с ЕДИНСТВЕННОЙ staged-записью
# типа A (добавление вне-зонного пути). Порча --diff-filter, роняющая A, видит на этом
# входе пустой staged → rc 0 «нечего судить: staged пуст» → красное не предъявлено
# → scoped rc 1. Порча, СОХРАНЯЮЩАЯ A, этой фикстурой не ловится — её держит сентинель
# потерянного типа (принцип набора: каждая ПРИЧИНА = свой тип; раннер судит первый
# красный вызов фикстуры, поэтому сентинелей ровно по числу наблюдаемых типов).
#
# Зелёный контроль: все пять наблюдаемых типов, все пути В зоне (scripts/), один вызов →
# rc 0 «ok: staged в зоне автора implementer (5 путь/путей)».
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── зелёный репо: все наблюдаемые типы, все пути В зоне ────────────────────────
GREEN="$WORK/repo_green"
make_repo "$GREEN"
stage "$GREEN" scripts/green_D.sh     'основание — коммитится, затем staged-удаление'
stage "$GREEN" scripts/green_T.bin    'основание — коммитится файлом, затем staged-типосмена'
stage "$GREEN" scripts/green_R_old.sh 'основание — коммитится, затем staged-переименование'
g "$GREEN" commit -q -m 'основания для D/T/R-записей зелёного контроля'
g "$GREEN" rm -q -- scripts/green_D.sh                                   # D в зоне
rm "$GREEN/scripts/green_T.bin"; ln -s t "$GREEN/scripts/green_T.bin"
g "$GREEN" add -- scripts/green_T.bin                                    # T в зоне
g "$GREEN" mv scripts/green_R_old.sh scripts/green_R_new.sh              # R в зоне
printf 'правка основания' >> "$GREEN/scripts/a.sh"
g "$GREEN" add -- scripts/a.sh                                           # M в зоне
stage "$GREEN" scripts/green_A.sh 'добавление в зоне'                     # A в зоне

# ── красный репо: ЕДИНСТВЕННАЯ staged-запись — добавление вне-зонного пути ──────
RED_A="$WORK/repo_red_A"
make_repo "$RED_A"
stage "$RED_A" offzone_A.txt 'единственная staged-запись — добавление вне зоны'

# ── вызовы барьера: серийные, через || true (А-32); репо после вызова не мутируются ──
"$BARRIER" "$GREEN" || true # ожидание: rc 0 «ok: staged в зоне автора implementer (5 путь/путей)»
"$BARRIER" "$RED_A"  || true # ожидание: rc 1 «ОТКАЗ: вне зоны: offzone_A.txt» — сентинель (ПРИЧИНА);
                             # порча, роняющая A: rc 0 «нечего судить: staged пуст»
