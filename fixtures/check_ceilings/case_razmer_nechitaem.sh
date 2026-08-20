# ПРИЧИНА: размер нечитаем
#
# Нечитаемый размер (битая символическая ссылка) — ОТКАЗ с именем файла, не молчание
# и не rc=0 (находки замеров 004). ДВЕ НЕЗАВИСИМЫЕ ветви, раздельные красные вызовы
# (находка ревьюера f86fa0c: объединённая фикстура маскировала мёртвую ветвь правил —
# персона краснела, правило молчало). Имена порождаются при каждом прогоне.
set -euo pipefail
. "$(dirname "$0")/_gen.sh"
R="$WORK/repo"
mkdir -p "$R/roles" "$R/.omp/rules"

# Зелёный контроль: обычные файлы под потолком
G1="$(rnd pers-ok)"; G2="$(rnd rule-ok)"
printf '# малая персона\n' > "$R/roles/$G1.md"
printf '# малое правило\n' > "$R/.omp/rules/$G2.md"
"$BARRIER" "$R"

# Красный 1: битая ссылка-ПЕРСОНА (ветвь ролей независима)
P="$(rnd pers-broken)"
ln -s /nonexistent-target "$R/roles/$P.md"
"$BARRIER" "$R" || true
rm "$R/roles/$P.md"

# Красный 2: битая ссылка-ПРАВИЛО (ветвь правил независима — не маскирована персоной)
Q="$(rnd rule-broken)"
ln -s /nonexistent-target "$R/.omp/rules/$Q.md"
"$BARRIER" "$R" || true
rm "$R/.omp/rules/$Q.md"

# Красный 3: битый AGENTS.md — корень правил, фиксированное имя ветви
mv "$R/.omp/rules/$Q.md" /dev/null 2>/dev/null || true
ln -s /nonexistent-target "$R/AGENTS.md"
"$BARRIER" "$R"
