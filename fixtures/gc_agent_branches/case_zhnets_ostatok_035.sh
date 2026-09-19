# ПРИЧИНА: не удалось удалить
#
# Постоянная фикстура-страж закрытия Н-97ост (контракт 035, вариант В1): живой
# остаток ./tmp основного чекаута (census 2026-09-20 00:40) воспроизведён игрушкой
# дословно — имена, возраст в днях, пустота каталогов, done-ландшафт (020 done,
# 032 активен, 026 жив — даёт каркас).
#
# ЗЕЛЁНЫЙ контроль: dry-run назначает кандидатов РОВНО две done-записи
# (draft020 ×2, done 020) и НЕ назначает возрастных (critic −3д, charter −6д)
# и ложный актив (ci_job_*.log −8д: «032» из имени CI-джоба при живом контракте
# 032); записи и байты целы; apply сносит ровно done-записи, выжившие и ПУСТЫЕ
# каталоги (scratch −43д, barrier005 −21д) целы — слепота источника к
# git-невидимым пустым каталогам зафиксирована ПРОГОНОМ (замер-аргумент В1:
# остаток вне досягаемости механизма стоит 0 байт).
# КРАСНОЕ: apply при tmp, закрытом на запись (chmod 555), → rc 1
# «не удалось удалить», кандидаты целы (fail-closed); состояние персистентно —
# повторный прогон проверяющего на том же входе даёт тот же отказ.
#
# СТАБ-ПРЕДЪЯВЛЕНИЕ (Н-39, привязка КОДОМ ниже: стаб-блоб 358b12a~1 — эпоха 016,
# строк TMP-РЕАП в нём ноль): пред-026 стаб на ТОЙ ЖЕ живой-реплике обязан
# ОСТАВИТЬ done-записи — слеп по построению. Стаб, сносящий их, красит фикстуру:
# проверка перестала различать предмет (026-механизм) и пустой прогон. Дефект
# стаба наблюдаем именно на done-записях: на возрастных входах слепота стаба
# неразличима с «запись не квалифицирована» — привязка к входу, где дефект НАБЛЮДАЕМ.
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

# Живая реплика остатка (census 2026-09-20 00:40): имена/возраст дословно из
# основного чекаута; каркас даёт живой контракт 026 и тег done/contracts/021/1.
ostatok_igrushka() {  # <корень>
  local r="$1"
  zhnec_igrushka "$r"
  printf '# live: 020 done\n' > "$r/contracts/020-cls.md"
  printf '# live: 032 активен\n' > "$r/contracts/032-cls.md"
  zgi "$r" add -- contracts/020-cls.md contracts/032-cls.md
  zgi "$r" commit -qm 'live: 020 done, 032 активен'
  zgi "$r" tag done/contracts/020/1
  mkdir -p "$r/tmp/critic" "$r/tmp/charter.RERj63" "$r/tmp/scratch" "$r/tmp/barrier005"
  printf 'масса критика\n' > "$r/tmp/critic/f"
  printf 'чартер\n' > "$r/tmp/charter.RERj63/f"
  printf 'лог ci\n' > "$r/tmp/ci_job_103282533944.log"
  printf 'таск\n' > "$r/tmp/draft020-task.md"
  printf 'таск-5\n' > "$r/tmp/fix5-draft020-task.md"
  vozrast_dnej "$r/tmp/critic" 3
  vozrast_dnej "$r/tmp/charter.RERj63" 6
  vozrast_dnej "$r/tmp/ci_job_103282533944.log" 8
  vozrast_dnej "$r/tmp/draft020-task.md" 16
  vozrast_dnej "$r/tmp/fix5-draft020-task.md" 16
  vozrast_dnej "$r/tmp/scratch" 43
  vozrast_dnej "$r/tmp/barrier005" 21
}

R="$WORK/repo-case-ostatok-035"
rm -rf "$R"
ostatok_igrushka "$R"

# ── ЗЕЛЁНЫЙ контроль: dry-run квалифицирует остаток ровно ─────────────────────
rc=0; out="$("$BARRIER" --root "$R" 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: dry-run rc %s, ожидался 0:\n%s\n' "$rc" "$out" >&2; exit 1; }
for k in tmp/draft020-task.md tmp/fix5-draft020-task.md; do
  printf '%s\n' "$out" | grep -Fq -- "$k" \
    || { printf 'ОТКАЗ: список не называет done-кандидата %s:\n%s\n' "$k" "$out" >&2; exit 1; }
done
printf '%s\n' "$out" | grep -Fq 'TMP-РЕАП кандидатов 2' \
  || { printf 'ОТКАЗ: сводка не «TMP-РЕАП кандидатов 2»:\n%s\n' "$out" >&2; exit 1; }
for k in tmp/critic tmp/charter.RERj63 tmp/ci_job_103282533944.log tmp/scratch tmp/barrier005; do
  if printf '%s\n' "$out" | grep -Fq -- "$k"; then
    printf 'ОТКАЗ: список назначает НЕ-кандидата %s:\n%s\n' "$k" "$out" >&2; exit 1
  fi
done
for f in critic/f charter.RERj63/f ci_job_103282533944.log draft020-task.md fix5-draft020-task.md; do
  [ -f "$R/tmp/$f" ] || { printf 'ОТКАЗ: dry-run удалил %s (Б3)\n' "$f" >&2; exit 1; }
done

# ── ЗЕЛЁНЫЙ контроль: apply сносит ровно done-записи ──────────────────────────
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: apply rc %s, ожидался 0:\n%s\n' "$rc" "$out" >&2; exit 1; }
for f in draft020-task.md fix5-draft020-task.md; do
  [ ! -e "$R/tmp/$f" ] || { printf 'ОТКАЗ: apply оставил done-запись %s\n' "$f" >&2; exit 1; }
done
for f in critic/f charter.RERj63/f ci_job_103282533944.log; do
  [ -f "$R/tmp/$f" ] || { printf 'ОТКАЗ: apply снёс выживающего по правилам %s\n' "$f" >&2; exit 1; }
done
for d in scratch barrier005; do
  [ -d "$R/tmp/$d" ] \
    || { printf 'ОТКАЗ: apply снёс пустой каталог %s — слепота источника нарушена\n' "$d" >&2; exit 1; }
done

# ── СТАБ-предъявление (Н-39): пред-026 блоб слеп на живой-реплике ─────────────
STAB="$WORK/stab-pre026-035.sh"
sha="$(git -C "$REPO" rev-parse --verify '358b12a~1:scripts/gc_agent_branches.sh' 2>/dev/null)" \
  || { printf 'ОТКАЗ: стаб-блоб 358b12a~1 недоступен в %s — пустая выборка красна\n' "$REPO" >&2; exit 1; }
git -C "$REPO" cat-file blob "$sha" > "$STAB"
chmod +x "$STAB"
if grep -q 'TMP-РЕАП' "$STAB"; then
  printf 'ОТКАЗ: стаб-блоб уже несёт TMP-РЕАП — церемония 024 указывает не на пред-026\n' >&2
  exit 1
fi
R3="$WORK/repo-case-ostatok-035-stab"
rm -rf "$R3"
ostatok_igrushka "$R3"
rc=0; "$STAB" --root "$R3" --tmp-reap-apply >/dev/null 2>&1 || rc=$?
for f in draft020-task.md fix5-draft020-task.md; do
  [ -e "$R3/tmp/$f" ] \
    || { printf 'ОТКАЗ: стаб СНЁС done-запись %s (rc %s) — проверка не различает предмет и пустой прогон\n' "$f" "$rc" >&2; exit 1; }
done

# ── КРАСНОЕ: apply при закрытом на запись tmp — именованный отказ, всё цело ───
# Персистентно до конца прогона: повтор проверяющего обязан увидеть тот же отказ.
R2="$WORK/repo-case-ostatok-035-blok"
rm -rf "$R2"
ostatok_igrushka "$R2"
chmod 555 "$R2/tmp"
rc=0; out="$("$BARRIER" --root "$R2" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 1 ] || { printf 'ОТКАЗ: закрытый apply дал rc %s, ожидался 1:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq 'не удалось удалить' \
  || { printf 'ОТКАЗ: отказ не назван «не удалось удалить» (инвариант 6 026):\n%s\n' "$out" >&2; exit 1; }
for f in draft020-task.md fix5-draft020-task.md; do
  [ -f "$R2/tmp/$f" ] \
    || { printf 'ОТКАЗ: закрытый apply снёс %s вопреки отказу — fail-closed нарушен\n' "$f" >&2; exit 1; }
done
