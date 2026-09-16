# Красное предъявление 1/4 контракта 026 (правка-2: Б1+Б3 вердикта критика v1).
#
# ВХОД: игрушка — живой контракт 026 (файл есть, done/contracts/026/* НЕТ), тег
# done/contracts/021/1, tmp/ в .gitignore; записи:
#   tmp/anon10d/     — аноним (имя без распознанного NNN), mtime −10 дней;
#   tmp/critic021v3/ — done-именованная (тег 021), mtime −1 час.
#
# ПОВЕДЕНИЕ ПОСЛЕ ПРЕДМЕТА (порядок ассертов = порядок инвариантов):
#   1) dry-run (без флага) → rc 0, TMP-РЕАП список называет ОБЕ записи (инв. 4);
#   2) dry-run СОХРАНЯЕТ: записи существуют, sha256 байтов равны снятым ДО вызова
#      (Б3, часть 1: удаление — ТОЛЬКО явным флагом);
#   3) apply (--tmp-reap-apply) на ТОМ ЖЕ входе → rc 0 (инв. 6);
#   4) apply УДАЛЯЕТ: обе записи отсутствуют, само tmp/ цело (инв. 1, 3).
#
# СТАБ-ПРИВЯЗКИ (Н-39: привязка живёт в коде пробы, не в прозе контракта):
#   S-exclude — источник с --exclude-standard слеп к tmp/ под .gitignore игрушки:
#               реапа нет → краснеет ассертом 4 (записи на месте);
#   S-ageonly — возраст без done-правила: свежая (−1ч) done-именованная выживает
#               → краснеет ассертом 4 (critic021v3 на месте).
# На текущем HEAD (gc флага не знает): dry-run даёт rc 0 БЕЗ TMP-РЕАП списка →
# краснеет ассертом 1 именованным отказом; apply дал бы «неизвестный аргумент» rc 1.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

R="$WORK/repo-reap-stale"
zhnec_igrushka "$R"
mkdir -p "$R/tmp/anon10d" "$R/tmp/critic021v3"
printf 'стейл по возрасту\n' > "$R/tmp/anon10d/f"
printf 'стейл по done-тегу\n' > "$R/tmp/critic021v3/f"
vozrast_dnej "$R/tmp/anon10d" 10
vozrast_chasov "$R/tmp/critic021v3" 1
sha_anon="$(sha256sum "$R/tmp/anon10d/f" | cut -d' ' -f1)"
sha_done="$(sha256sum "$R/tmp/critic021v3/f" | cut -d' ' -f1)"

# 1) dry-run: rc 0, список называет обе записи.
rc=0; out="$("$BARRIER" --root "$R" 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: dry-run вернул rc %s, ожидался 0:\n%s\n' "$rc" "$out" >&2; exit 1; }
for k in tmp/anon10d tmp/critic021v3; do
  printf '%s\n' "$out" | grep -Fq -- "$k" || {
    printf 'ОТКАЗ: TMP-РЕАП список не называет кандидата %s — реап не реализован (инвариант 4). Вывод gc:\n%s\n' "$k" "$out" >&2
    exit 1; }
done

# 2) Б3, часть 1: dry-run сохраняет записи и их байты.
for p in anon10d/f critic021v3/f; do
  [ -f "$R/tmp/$p" ] || { printf 'ОТКАЗ: dry-run удалил tmp/%s — удаление обязано быть ТОЛЬКО явным флагом --tmp-reap-apply (Б3)\n' "$p" >&2; exit 1; }
done
[ "$(sha256sum "$R/tmp/anon10d/f" | cut -d' ' -f1)" = "$sha_anon" ] \
  || { printf 'ОТКАЗ: dry-run изменил байты tmp/anon10d/f (Б3)\n' >&2; exit 1; }
[ "$(sha256sum "$R/tmp/critic021v3/f" | cut -d' ' -f1)" = "$sha_done" ] \
  || { printf 'ОТКАЗ: dry-run изменил байты tmp/critic021v3/f (Б3)\n' >&2; exit 1; }

# 3) apply: rc 0.
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: --tmp-reap-apply вернул rc %s, ожидался 0 (на HEAD без предмета — «неизвестный аргумент»):\n%s\n' "$rc" "$out" >&2; exit 1; }

# 4) Б3, часть 2: apply удаляет обе записи; само tmp/ цело.
for d in anon10d critic021v3; do
  [ ! -e "$R/tmp/$d" ] || { printf 'ОТКАЗ: стейл tmp/%s пережил --tmp-reap-apply (инвариант 3)\n' "$d" >&2; exit 1; }
done
[ -d "$R/tmp" ] || { printf 'ОТКАЗ: само tmp/ удалено — запрещено (инвариант 1)\n' >&2; exit 1; }
