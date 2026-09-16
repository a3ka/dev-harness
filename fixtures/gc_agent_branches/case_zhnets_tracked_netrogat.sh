# ПРИЧИНА: смешанный вход
#
# Постоянная фикстура жнеца ./tmp (контракт 026, правка-2): tracked не трогается
# НИКОГДА (инвариант 2) батареей мета-прогона. Игрушка: tmp/ в .gitignore; tracked
# tmp/old021/x (в индексе через add -f, done-имя, −40д) — НЕ кандидат: источник
# --others его не перечисляет (инвариант 2а).
#
# ЗЕЛЁНЫЙ контроль: dry-run → rc 0, список НЕ называет tmp/old021, файл цел.
# КРАСНОЕ: смешанная квалифицированная ВОЗРАСТОМ запись tmp/mix/ (tracked y +
# untracked z, −40д) → apply rc 1 «смешанный вход», назвав запись; y, z и tracked
# old021/x ЦЕЛЫ. Состояние персистентно для повторного прогона проверяющего.
#
# СТАБ-ПРИВЯЗКИ (Н-39, по коду): S-find (подметание по mtime мимо git-источника)
# краснеет в парной red_zhnets_tracked_netrogat веткой (а) — там его дефект
# наблюдаем в УДАЛЕНИИ tracked; здесь слепой untracked-реап и «молчаливая»
# смешанность красны отказом rc 1 и целостностью mix/old021.
#
# Прямой прогон: каркас _zhnets.sh сам назначает WORK/BARRIER — фикстура красна на
# текущем HEAD именованным отказом gc (флага нет) и зелёна после предмета.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

R="$WORK/repo-case-tracked"
zhnec_igrushka "$R"
mkdir -p "$R/tmp/old021"
printf 'tracked под tmp\n' > "$R/tmp/old021/x"
zgi "$R" add -f -- tmp/old021/x
zgi "$R" commit -q -m 'tracked-запись под tmp'
vozrast_dnej "$R/tmp/old021" 40

# Зелёный контроль: dry-run — tracked не кандидат.
rc=0; out="$("$BARRIER" --root "$R" 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: dry-run rc %s, ожидался 0:\n%s\n' "$rc" "$out" >&2; exit 1; }
if printf '%s\n' "$out" | grep -Fq -- 'tmp/old021'; then
  printf 'ОТКАЗ: список называет tracked tmp/old021 — tracked не кандидат (инвариант 2а). Вывод gc:\n%s\n' "$out" >&2
  exit 1
fi
[ -f "$R/tmp/old021/x" ] || { printf 'ОТКАЗ: tracked-файл повреждён dry-руном\n' >&2; exit 1; }

# Красное: смешанная квалифицированная возрастом запись — именованный отказ.
mkdir -p "$R/tmp/mix"
printf 'tracked-половина\n' > "$R/tmp/mix/y"
zgi "$R" add -f -- tmp/mix/y
zgi "$R" commit -q -m 'смешанная запись: tracked y'
printf 'untracked-половина\n' > "$R/tmp/mix/z"
vozrast_dnej "$R/tmp/mix" 40
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 1 ] || { printf 'ОТКАЗ: смешанный вход дал rc %s, ожидался 1:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'смешанный вход' \
  || { printf 'ОТКАЗ: отказ не назван «смешанный вход» (инвариант 2). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'tmp/mix' \
  || { printf 'ОТКАЗ: отказ не называет запись (правило 7). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
[ -f "$R/tmp/mix/y" ] && [ -f "$R/tmp/mix/z" ] && [ -f "$R/tmp/old021/x" ] \
  || { printf 'ОТКАЗ: fail-closed нарушен — файлы повреждены\n' >&2; exit 1; }
