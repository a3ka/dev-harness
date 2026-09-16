# Красное предъявление 3/4 контракта 026: tracked не трогается НИКОГДА (инвариант 2),
# две ветви — каждая СВОИМ предъявлением (правка-2 критика v1).
#
# ВХОД: две игрушки; в обеих живой контракт 026, тег done/contracts/021/1, tmp/ в
# .gitignore.
#   (а) tmp/old021/x — TRACKED (в индексе через add -f), done-имя, mtime −40 дней,
#       плюс положительный контроль tmp/anon10d-b/ (untracked, −10 дней);
#   (б) tmp/mix/ — СМЕШАННАЯ квалифицированная запись: tracked y + untracked z,
#       mtime −40 дней (квалифицируется ВОЗРАСТОМ — контроль смешанности судит
#       кандидата перед удалением, неквалифицированная запись не трогается).
#
# ПОВЕДЕНИЕ ПОСЛЕ ПРЕДМЕТА:
#   (а) apply → rc 0; tracked old021/x ЦЕЛ с теми же байтами, контроль ОТСУТСТВУЕТ;
#   (б) apply → rc 1; отказ называет «смешанный вход» и запись tmp/mix; y и z ЦЕЛЫ.
#
# СТАБ-ПРИВЯЗКИ (Н-39: по коду, не по прозе контракта):
#   S-find — find-подметание по mtime мимо git-источника: сносит tracked old021/x
#            (−40д) — краснеет веткой (а) целостностью;
#   слепой-untracked-реап (сносит untracked части смешанной записи) и «молчаливая»
#            смешанность (rc 0 без имени) — краснеют веткой (б) отказом и целостностью;
#   no-op  — краснеет веткой (а) положительным контролем.
# На текущем HEAD: ветка (а) apply → «неизвестный аргумент» rc 1 — именованный отказ.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

# ── Ветка (а): tracked не кандидат даже с done-именем и −40д ───────────────────
R1="$WORK/repo-tracked"
zhnec_igrushka "$R1"
mkdir -p "$R1/tmp/old021" "$R1/tmp/anon10d-b"
printf 'tracked под tmp\n' > "$R1/tmp/old021/x"
zgi "$R1" add -f -- tmp/old021/x
zgi "$R1" commit -q -m 'tracked-запись под tmp'
printf 'положительный контроль\n' > "$R1/tmp/anon10d-b/f"
vozrast_dnej "$R1/tmp/old021" 40
vozrast_dnej "$R1/tmp/anon10d-b" 10
sha_tr="$(sha256sum "$R1/tmp/old021/x" | cut -d' ' -f1)"

rc=0; out="$("$BARRIER" --root "$R1" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: ветка (а) apply rc %s, ожидался 0 (на HEAD — «неизвестный аргумент»):\n%s\n' "$rc" "$out" >&2; exit 1; }
[ -f "$R1/tmp/old021/x" ] && [ "$(sha256sum "$R1/tmp/old021/x" | cut -d' ' -f1)" = "$sha_tr" ] \
  || { printf 'ОТКАЗ: tracked tmp/old021/x удалён — tracked не трогается НИКОГДА (инвариант 2)\n' >&2; exit 1; }
[ ! -e "$R1/tmp/anon10d-b" ] \
  || { printf 'ОТКАЗ: положительный контроль tmp/anon10d-b/ пережил apply — реап не исполнен\n' >&2; exit 1; }

# ── Ветка (б): смешанный вход — именованный отказ, оба файла целы ──────────────
R2="$WORK/repo-mixed"
zhnec_igrushka "$R2"
mkdir -p "$R2/tmp/mix"
printf 'tracked-половина\n' > "$R2/tmp/mix/y"
zgi "$R2" add -f -- tmp/mix/y
zgi "$R2" commit -q -m 'смешанная запись: tracked y'
printf 'untracked-половина\n' > "$R2/tmp/mix/z"
vozrast_dnej "$R2/tmp/mix" 40

rc=0; out="$("$BARRIER" --root "$R2" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 1 ] || { printf 'ОТКАЗ: смешанный вход дал rc %s, ожидался 1 (на HEAD — rc 1 «неизвестный аргумент» БЕЗ имени отказа):\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'смешанный вход' \
  || { printf 'ОТКАЗ: отказ не назван «смешанный вход» (инвариант 2). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'tmp/mix' \
  || { printf 'ОТКАЗ: отказ не называет запись tmp/mix (правило 7). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
[ -f "$R2/tmp/mix/y" ] && [ -f "$R2/tmp/mix/z" ] \
  || { printf 'ОТКАЗ: смешанная запись повреждена — fail-closed нарушен: y и z обязаны быть целы\n' >&2; exit 1; }
