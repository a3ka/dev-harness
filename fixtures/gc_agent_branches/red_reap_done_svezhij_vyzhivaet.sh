# Красное предъявление грации Н-107 TMP-РЕАП (контракт 030, фикс 5294dd5).
#
# ПРИЧИНА: свежая done-NNN запись при gc --tmp-reap-apply сносилась МОЛЧА — чистая
# проверка «done ⇒ реап независимо от возраста» (свидетель 7e11c9e) убивала свежий
# rework-скратч, спавненный ПОСЛЕ close-out, и барьер оставался зелёным на обмане.
#
# ВХОД: игрушка — живой контракт 026 (файл есть, done/contracts/026/* НЕТ), tmp/ в
# .gitignore; close-out ПОЗАДИ по времени: пустой коммит с committer-date −5ч и ЛЁГКИЙ
# тег done/contracts/026/1 (creatordate лёгкого тега = committer date подлежащего
# коммита — замер 5294dd5). Прогон с --wip-grace-hours 3. Записи:
#   tmp/done026rework/     — done-именованная (тег 026), mtime СЕЙЧАС;
#   tmp/done026broshennyj/ — done-именованная, mtime −4ч (после закрытия, старше
#                           грации 3ч — брошенный rework);
#   tmp/done026ostatok/    — done-именованная, mtime −6ч (ДО закрытия — остаток
#                           уборки, реап немедленно);
#   tmp/anon8d/            — аноним (имя без NNN), mtime −8 дней.
# Различитель — возраст записи против грации, ОБЕ стороны границы наблюдаемы
# (0ч < 3ч < 4ч), момент закрытия (−5ч) обрамлён остатком (−6ч) и брошенным (−4ч).
#
# ПОВЕДЕНИЕ ПОСЛЕ ПРЕДМЕТА (порядок ассертов = порядок инвариантов):
#   1) apply (--tmp-reap-apply, --wip-grace-hours 3) → rc 0;
#   2) СВЕЖИЙ rework ВЫЖИВАЕТ: tmp/done026rework цел — на свидетеле 7e11c9e снесен
#      молча → красное не предъявлено (боль Н-107);
#   3) stderr несёт строку-связку «свежий rework — ВЫЖИВАЕТ (грация Н-107)»;
#   4) грация НЕ тормозит уборку: broshennyj (−4ч > 3ч) снесен;
#   5) остаток ДО закрытия (−6ч ≤ creatordate −5ч) снесен немедленно — hygiene 026
#      жива;
#   6) аноним −8д снесен (правило возраста живо);
#   7) само tmp/ цело.
#
# СТАБ-ПРИВЯЗКИ (Н-39: каждый обманный стаб — к входу, где его дефект НАБЛЮДАМ):
#   S-done-vsyo    — «done ⇒ реап всегда» (сам свидетель 7e11c9e): умирает на
#                    ассерте 2 — свежая снесена;
#   S-bez-svjazki  — «выживание молча, без stderr-строки»: умирает на ассерте 3;
#   S-gracia-vsem  — «грация на ВСЕ done-записи, не только свежие»: умирает на
#                    ассерте 4 (broshennyj жив);
#   S-ignor-zakryt — «done без сверки с датой закрытия»: умирает на ассерте 5
#                    (остаток до закрытия жив);
#   S-bez-vozrasta — «анонимы не сносятся»: умирает на ассерте 6.
# На до-фикс свидетеле (7e11c9e): apply rc 0, все четыре записи снесены молча →
# краснеет ассертом 2 именованным отказом.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

R="$WORK/repo-reap-done-grace"
zhnec_igrushka "$R"

# Close-out ПОЗАДИ: committer-date −5ч наследуется ЛЁГКИМ тегом как creatordate
# (taggerdate у лёгкого тега пуст — замер 5294dd5).
GIT_COMMITTER_DATE="@$(( $(date +%s) - 5 * 3600 ))" \
  zgi "$R" commit -q --allow-empty -m 'close-out 026 (committer-date позади)'
zgi "$R" tag done/contracts/026/1

# Записи-кандидаты: свежая не трогается (mtime = сейчас), возрастные — touch по эпохе.
mkdir -p "$R/tmp/done026rework" "$R/tmp/done026broshennyj" "$R/tmp/done026ostatok" "$R/tmp/anon8d"
printf 'свежий rework после close-out\n' > "$R/tmp/done026rework/f"
printf 'брошенный rework, старше грации\n' > "$R/tmp/done026broshennyj/f"
printf 'остаток до закрытия\n' > "$R/tmp/done026ostatok/f"
printf 'анонимный стейл\n' > "$R/tmp/anon8d/f"
vozrast_chasov "$R/tmp/done026broshennyj" 4
vozrast_chasov "$R/tmp/done026ostatok" 6
vozrast_dnej "$R/tmp/anon8d" 8

# 1) apply: rc 0. stdout и stderr — РАЗНЫЕ файлы (канал связки живёт в stderr).
out="$(mktemp "$WORK/gc-out.XXXXXX")"; err="$(mktemp "$WORK/gc-err.XXXXXX")"; rc=0
"$BARRIER" --root "$R" --tmp-reap-apply --wip-grace-hours 3 >"$out" 2>"$err" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: apply вернул rc %s, ожидался 0:\n%s\n%s\n' "$rc" "$(cat "$out")" "$(cat "$err")" >&2; exit 1; }

# 2) СВЕЖИЙ rework ВЫЖИВАЕТ (грация Н-107). Свидетель 7e11c9e сносит его молча.
[ -d "$R/tmp/done026rework" ] || { printf 'ОТКАЗ: свежая done-запись tmp/done026rework снесена --tmp-reap-apply — гонка Н-107: жнец не различает свежий rework после close-out\n%s\n%s\n' "$(cat "$out")" "$(cat "$err")" >&2; exit 1; }

# 3) stderr объясняет выживание строкой-связкой (канал + фраза грации пиннаты).
grep -F -- 'tmp/done026rework' "$err" | grep -Fq 'свежий rework — ВЫЖИВАЕТ (грация Н-107)' \
  || { printf 'ОТКАЗ: stderr не объясняет выживание tmp/done026rework — нет строки-связки «свежий rework — ВЫЖИВАЕТ (грация Н-107)»\nstderr:\n%s\n' "$(cat "$err")" >&2; exit 1; }

# 4) Грация НЕ тормозит уборку: брошенный (после закрытия, старше 3ч) снесен.
[ ! -e "$R/tmp/done026broshennyj" ] || { printf 'ОТКАЗ: tmp/done026broshennyj (−4ч > грации 3ч, после закрытия) пережила apply — грация расползлась на ВСЕ done-записи\n%s\n%s\n' "$(cat "$out")" "$(cat "$err")" >&2; exit 1; }

# 5) Остаток ДО закрытия (−6ч ≤ creatordate −5ч) снесен немедленно — hygiene 026 жива.
[ ! -e "$R/tmp/done026ostatok" ] || { printf 'ОТКАЗ: tmp/done026ostatok (запись ДО закрытия) пережила apply — done-правило не сверяется с датой закрытия\n%s\n%s\n' "$(cat "$out")" "$(cat "$err")" >&2; exit 1; }

# 6) Аноним −8д снесен — правило возраста живо.
[ ! -e "$R/tmp/anon8d" ] || { printf 'ОТКАЗ: анонимная tmp/anon8d (−8 дней) пережила apply — правило возраста умерло\n%s\n%s\n' "$(cat "$out")" "$(cat "$err")" >&2; exit 1; }

# 7) Само tmp/ цело.
[ -d "$R/tmp" ] || { printf 'ОТКАЗ: само tmp/ удалено — запрещено\n%s\n%s\n' "$(cat "$out")" "$(cat "$err")" >&2; exit 1; }

exit 0
