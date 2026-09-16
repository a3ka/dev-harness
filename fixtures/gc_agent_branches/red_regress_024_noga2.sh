# Красное предъявление 4/4 контракта 026: REGRESS-024 — реап НЕ ослепляет ногу-2
# детектора (инвариант 7, критическая приёмка владельца).
#
# ВХОД: две игрушки; оракул — живой scripts/check_no_leak.sh (НЕ БАРЬЕР, контракт 024,
# правка заморожена). В каждой tmp/ в .gitignore (зеркало живого дерева) и стейл
# tmp/anon10d-*/ (−10 дней, кандидат реапа).
#   (а) снимок → СВЕЖАЯ утечка tmp/leak-026.txt + apply-реап стейла → --check:
#       rc 1, утечка ПОИМЁННО (нога-2 видит свежие утечки МИМО реапа);
#   (б) снимок → apply-реап стейла, утечки НЕТ → --check: rc 0 (исчезновение ≠ утечка).
#
# СТАБ-ПРИВЯЗКИ (Н-39: по коду, не по прозе контракта):
#   S-overreach — реап хватает и свежие: утечка удалена до сверки — красна И файловой
#                 проверкой (leak отсутствует сразу после apply), и отказом сверки
#                 (check дал бы rc 0) в ветке (а).
# На текущем HEAD: apply-вызов gc — «неизвестный аргумент» rc 1 — именованный отказ.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

ORAKUL="$REPO/scripts/check_no_leak.sh"

# ── Ветка (а): утечка при реапе остаётся ловимой ───────────────────────────────
R1="$WORK/repo-noga2-a"
zhnec_igrushka "$R1"
mkdir -p "$R1/tmp/anon10d-r"
printf 'стейл ветки а\n' > "$R1/tmp/anon10d-r/f"
vozrast_dnej "$R1/tmp/anon10d-r" 10
"$ORAKUL" --snapshot "$R1" || { printf 'ОТКАЗ: оракул 024 не снял снимок (ветка а)\n' >&2; exit 1; }
printf 'УТЕЧКА-026 нога-2 обязана это видеть\n' > "$R1/tmp/leak-026.txt"

rc=0; out="$("$BARRIER" --root "$R1" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: apply вернул rc %s, ожидался 0 (на HEAD — «неизвестный аргумент»):\n%s\n' "$rc" "$out" >&2; exit 1; }
[ ! -e "$R1/tmp/anon10d-r" ] || { printf 'ОТКАЗ: стейл не реапнут в ветке (а)\n' >&2; exit 1; }
[ -f "$R1/tmp/leak-026.txt" ] || { printf 'ОТКАЗ: реап удалил СВЕЖУЮ утечку — S-overreach (инвариант 7)\n' >&2; exit 1; }

rc=0; out="$("$ORAKUL" --check "$R1" 2>&1)" || rc=$?
[ "$rc" -eq 1 ] || { printf 'ОТКАЗ: сверка после утечки дала rc %s, ожидался 1:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'tmp/leak-026.txt' \
  || { printf 'ОТКАЗ: утечка не названа поимённо. Вывод оракула:\n%s\n' "$out" >&2; exit 1; }

# ── Ветка (б): чистый реап между снимком и сверкой — rc 0 ──────────────────────
R2="$WORK/repo-noga2-b"
zhnec_igrushka "$R2"
mkdir -p "$R2/tmp/anon10d-r2"
printf 'стейл ветки б\n' > "$R2/tmp/anon10d-r2/f"
vozrast_dnej "$R2/tmp/anon10d-r2" 10
"$ORAKUL" --snapshot "$R2" || { printf 'ОТКАЗ: оракул 024 не снял снимок (ветка б)\n' >&2; exit 1; }

rc=0; out="$("$BARRIER" --root "$R2" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: apply вернул rc %s, ожидался 0 (ветка б):\n%s\n' "$rc" "$out" >&2; exit 1; }
[ ! -e "$R2/tmp/anon10d-r2" ] || { printf 'ОТКАЗ: стейл не реапнут в ветке (б)\n' >&2; exit 1; }

rc=0; out="$("$ORAKUL" --check "$R2" 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: исчезновение строк посчитано утечкой (rc %s, ожидался 0):\n%s\n' "$rc" "$out" >&2; exit 1; }
