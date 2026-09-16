# Красное предъявление 2/4 контракта 026 (правка-2: Б4 вердикта критика v1).
#
# ВХОД: игрушка — контракт 026 ЖИВ (contracts/026-*.md в дереве, done/contracts/026/*
# НЕТ), тег done/contracts/021/1 есть, tmp/ в .gitignore; записи:
#   tmp/arch026task.md   — АКТИВНЫЙ 026, файл, mtime −40 дней;
#   tmp/arch026-from021/ — РАЗЛИЧАЮЩИЙ ВХОД Б4: активный 026 И done 021 в одном
#                          имени, mtime −40 дней;
#   tmp/svezhij-anonim/  — свежий аноним, mtime −1 час;
#   tmp/critic021v3/     — положительный контроль (реап ИСПОЛНЕН): done-имя, −1 час.
#
# ПОВЕДЕНИЕ ПОСЛЕ ПРЕДМЕТА: apply → rc 0; ТРИ первых записи ЦЕЛЫ с теми же байтами
# (приоритет активного номера над done — Б4), положительный контроль ОТСУТСТВУЕТ.
#
# СТАБ-ПРИВЯЗКИ (Н-39: по коду, не по прозе контракта):
#   S-sweepall  — сносит всё tmp: краснеет целостностью выживших;
#   S-ageonly   — возраст без защиты активного: сносит arch026task.md и
#                 arch026-from021 (обе −40д);
#   S-donefirst — обход Б4 (любой done-номер бьёт раньше проверки активного):
#                 сносит arch026-from021 (021-done перевешивает живой 026);
#   no-op       — краснеет положительным контролем (critic021v3 на месте).
# На текущем HEAD: apply → «неизвестный аргумент» rc 1 — именованный отказ.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

R="$WORK/repo-aktiv"
zhnec_igrushka "$R"
mkdir -p "$R/tmp/arch026-from021" "$R/tmp/svezhij-anonim" "$R/tmp/critic021v3"
printf 'задача активного 026\n' > "$R/tmp/arch026task.md"
printf 'скратч активного 026 поверх done 021\n' > "$R/tmp/arch026-from021/f"
printf 'свежий аноним\n' > "$R/tmp/svezhij-anonim/f"
printf 'положительный контроль реапа\n' > "$R/tmp/critic021v3/f"
vozrast_dnej "$R/tmp/arch026task.md" 40
vozrast_dnej "$R/tmp/arch026-from021" 40
vozrast_chasov "$R/tmp/svezhij-anonim" 1
vozrast_chasov "$R/tmp/critic021v3" 1
sha_task="$(sha256sum "$R/tmp/arch026task.md" | cut -d' ' -f1)"
sha_from021="$(sha256sum "$R/tmp/arch026-from021/f" | cut -d' ' -f1)"
sha_svezh="$(sha256sum "$R/tmp/svezhij-anonim/f" | cut -d' ' -f1)"

rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: apply вернул rc %s, ожидался 0 (на HEAD без предмета — «неизвестный аргумент»):\n%s\n' "$rc" "$out" >&2; exit 1; }

# Выжившие: активный контекст (даже −40д), различающий вход Б4, свежий аноним.
[ -f "$R/tmp/arch026task.md" ] && [ "$(sha256sum "$R/tmp/arch026task.md" | cut -d' ' -f1)" = "$sha_task" ] \
  || { printf 'ОТКАЗ: при живом контракте 026 tmp/arch026task.md (−40д) не пережил apply — защита активного номера не работает (инвариант 3)\n' >&2; exit 1; }
[ -f "$R/tmp/arch026-from021/f" ] && [ "$(sha256sum "$R/tmp/arch026-from021/f" | cut -d' ' -f1)" = "$sha_from021" ] \
  || { printf 'ОТКАЗ: tmp/arch026-from021/ (живой 026 + done 021, −40д) удалён — приоритет активного номера над done не работает (Б4)\n' >&2; exit 1; }
[ -f "$R/tmp/svezhij-anonim/f" ] && [ "$(sha256sum "$R/tmp/svezhij-anonim/f" | cut -d' ' -f1)" = "$sha_svezh" ] \
  || { printf 'ОТКАЗ: свежий аноним tmp/svezhij-anonim/ (−1ч) не пережил apply — порог возраста не работает (инвариант 3б)\n' >&2; exit 1; }

# Положительный контроль: реап ИСПОЛНЕН (иначе no-op проходит пробу).
[ ! -e "$R/tmp/critic021v3" ] \
  || { printf 'ОТКАЗ: done-именованный положительный контроль tmp/critic021v3/ пережил apply — реап не исполнен\n' >&2; exit 1; }
