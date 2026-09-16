# ПРИЧИНА: смешанный вход
#
# Постоянная фикстура жнеца ./tmp (контракт 026, правка-2): защита активного номера
# (инвариант 3, Б4) батареей мета-прогона. Игрушка: живой контракт 026 (без
# done/contracts/026/*), тег done/contracts/021/1, tmp/ в .gitignore; записи:
#   tmp/arch026task.md  (−40д, активный 026), tmp/arch026-from021/ (−40д, активный
#   026 + done 021 — приоритет активного, различающий вход Б4),
#   tmp/svezhij-anonim/ (−1ч), tmp/critic021v3/ (−1ч, положительный контроль).
#
# ЗЕЛЁНЫЙ контроль: apply → rc 0; трое выживших ЦЕЛЫ с теми же байтами, контроль
# реапа ОТСУТСТВУЕТ.
# КРАСНОЕ: смешанная КВАЛИФИЦИРОВАННАЯ запись tmp/critic021mix/ (done-имя 021,
# tracked y + untracked z) → apply обязан отказаться rc 1 «смешанный вход», назвав
# запись; y и z ЦЕЛЫ (fail-closed). Состояние персистентно для повторного прогона
# проверяющего (запись не удалена).
#
# СТАБ-ПРИВЯЗКИ (Н-39, по коду): S-sweepall/S-ageonly/S-donefirst (обход Б4:
# любой done-номер бьёт активного) краснеют зелёным контролем — выжившие удалены;
# «молчаливый реап смешанной» красна отказом rc 1 и целостностью mix.
#
# Прямой прогон: каркас _zhnets.sh сам назначает WORK/BARRIER — фикстура красна на
# текущем HEAD именованным отказом gc (флага нет) и зелёна после предмета.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

R="$WORK/repo-case-aktiv"
zhnec_igrushka "$R"
mkdir -p "$R/tmp/arch026-from021" "$R/tmp/svezhij-anonim" "$R/tmp/critic021v3"
printf 'задача 026\n' > "$R/tmp/arch026task.md"
printf 'скратч 026 поверх done 021\n' > "$R/tmp/arch026-from021/f"
printf 'свежий аноним\n' > "$R/tmp/svezhij-anonim/f"
printf 'контроль реапа\n' > "$R/tmp/critic021v3/f"
vozrast_dnej "$R/tmp/arch026task.md" 40
vozrast_dnej "$R/tmp/arch026-from021" 40
vozrast_chasov "$R/tmp/svezhij-anonim" 1
vozrast_chasov "$R/tmp/critic021v3" 1
sha_t="$(sha256sum "$R/tmp/arch026task.md" | cut -d' ' -f1)"
sha_f="$(sha256sum "$R/tmp/arch026-from021/f" | cut -d' ' -f1)"
sha_s="$(sha256sum "$R/tmp/svezhij-anonim/f" | cut -d' ' -f1)"

# Зелёный контроль: apply — выжившие целы, контроль реапа снесён.
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: apply rc %s, ожидался 0:\n%s\n' "$rc" "$out" >&2; exit 1; }
[ -f "$R/tmp/arch026task.md" ] && [ "$(sha256sum "$R/tmp/arch026task.md" | cut -d' ' -f1)" = "$sha_t" ] \
  || { printf 'ОТКАЗ: активный tmp/arch026task.md не пережил apply (инвариант 3)\n' >&2; exit 1; }
[ -f "$R/tmp/arch026-from021/f" ] && [ "$(sha256sum "$R/tmp/arch026-from021/f" | cut -d' ' -f1)" = "$sha_f" ] \
  || { printf 'ОТКАЗ: различающий вход Б4 tmp/arch026-from021/ не пережил apply\n' >&2; exit 1; }
[ -f "$R/tmp/svezhij-anonim/f" ] && [ "$(sha256sum "$R/tmp/svezhij-anonim/f" | cut -d' ' -f1)" = "$sha_s" ] \
  || { printf 'ОТКАЗ: свежий аноним не пережил apply (инвариант 3б)\n' >&2; exit 1; }
[ ! -e "$R/tmp/critic021v3" ] || { printf 'ОТКАЗ: контроль реапа не снесён\n' >&2; exit 1; }

# Красное: смешанная квалифицированная (done 021) запись — именованный отказ.
mkdir -p "$R/tmp/critic021mix"
printf 'tracked-половина\n' > "$R/tmp/critic021mix/y"
zgi "$R" add -f -- tmp/critic021mix/y
zgi "$R" commit -q -m 'смешанная done-запись'
printf 'untracked-половина\n' > "$R/tmp/critic021mix/z"
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 1 ] || { printf 'ОТКАЗ: смешанный вход дал rc %s, ожидался 1:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'смешанный вход' \
  || { printf 'ОТКАЗ: отказ не назван «смешанный вход» (инвариант 2). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'tmp/critic021mix' \
  || { printf 'ОТКАЗ: отказ не называет запись (правило 7). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
[ -f "$R/tmp/critic021mix/y" ] && [ -f "$R/tmp/critic021mix/z" ] \
  || { printf 'ОТКАЗ: смешанная запись повреждена — fail-closed нарушен\n' >&2; exit 1; }
