# ПРИЧИНА: не удалось удалить
#
# Постоянная фикстура жнеца ./tmp (контракт 026, правка-2): инварианты 1/3/4/6
# батареей мета-прогона. Игрушка: живой контракт 026, тег done/contracts/021/1,
# tmp/ в .gitignore; кандидаты tmp/anon10d/ (−10д) и tmp/critic021v3/ (−1ч, done).
#
# ЗЕЛЁНЫЙ контроль: dry-run (без флага) → rc 0, список называет обоих кандидатов,
# записи и байты СОХРАНЕНЫ (удаление — только явным флагом, Б3).
# КРАСНОЕ: tmp и каталоги кандидатов закрываются на запись (chmod 555) — удаление
# невозможно → apply обязан отказаться rc 1 «не удалось удалить», записи ЦЕЛЫ
# (fail-closed). Состояние персистентно: повторный прогон проверяющего на том же
# входе даёт тот же отказ (кандидаты не удалены, tmp всё ещё закрыт).
#
# СТАБ-ПРИВЯЗКИ (Н-39, по коду): S-exclude/S-ageonly краснеют зелёным контролем
# (пустой/неполный список кандидатов); «печатает отказ и удаляет всё равно»
# красна целостностью записей после apply.
#
# Прямой прогон (`bash fixtures/gc_agent_branches/case_zhnets_reapstale.sh`):
# каркас _zhnets.sh сам назначает WORK/BARRIER — фикстура красна на текущем HEAD
# именованным отказом gc (флага нет) и зелёна после предмета.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

R="$WORK/repo-case-reapstale"
zhnec_igrushka "$R"
mkdir -p "$R/tmp/anon10d" "$R/tmp/critic021v3"
printf 'кандидат возраста\n' > "$R/tmp/anon10d/f"
printf 'кандидат done-тега\n' > "$R/tmp/critic021v3/f"
vozrast_dnej "$R/tmp/anon10d" 10
vozrast_chasov "$R/tmp/critic021v3" 1
sha_a="$(sha256sum "$R/tmp/anon10d/f" | cut -d' ' -f1)"
sha_b="$(sha256sum "$R/tmp/critic021v3/f" | cut -d' ' -f1)"

# Зелёный контроль: dry-run — список называет кандидатов, ничего не удалено.
rc=0; out="$("$BARRIER" --root "$R" 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: dry-run rc %s, ожидался 0:\n%s\n' "$rc" "$out" >&2; exit 1; }
for k in tmp/anon10d tmp/critic021v3; do
  printf '%s\n' "$out" | grep -Fq -- "$k" || { printf 'ОТКАЗ: список не называет кандидата %s:\n%s\n' "$k" "$out" >&2; exit 1; }
done
[ -f "$R/tmp/anon10d/f" ] && [ "$(sha256sum "$R/tmp/anon10d/f" | cut -d' ' -f1)" = "$sha_a" ] \
  && [ -f "$R/tmp/critic021v3/f" ] && [ "$(sha256sum "$R/tmp/critic021v3/f" | cut -d' ' -f1)" = "$sha_b" ] \
  || { printf 'ОТКАЗ: dry-run не сохранил записи/байты (Б3)\n' >&2; exit 1; }

# Красное: удаление невозможно — именованный отказ, записи целы.
chmod 555 "$R/tmp" "$R/tmp/anon10d" "$R/tmp/critic021v3"
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 1 ] || { printf 'ОТКАЗ: apply при закрытом tmp дал rc %s, ожидался 1:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'не удалось удалить' \
  || { printf 'ОТКАЗ: отказ не назван «не удалось удалить» (инвариант 6). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
[ -f "$R/tmp/anon10d/f" ] && [ -f "$R/tmp/critic021v3/f" ] \
  || { printf 'ОТКАЗ: кандидаты удалены вопреки отказу — fail-closed нарушен\n' >&2; exit 1; }
