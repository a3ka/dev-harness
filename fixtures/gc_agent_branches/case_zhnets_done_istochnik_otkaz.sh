# ПРИЧИНА: не удалось удалить tmp/fresh021
#
# Постоянная фикстура жнеца ./tmp (контракт 026, круг к2 адверсария): отказ
# ИСТОЧНИКА done-тегов. Вердикт к2: подставной git, возвращающий 1 только на
# `for-each-ref refs/tags/done/contracts/`, проходил ветвь
# `if g for-each-ref …; then …; fi` БЕЗ fail-closed else — отказ источника
# выглядел пустым done-набором, свежая done-запись переживала apply с rc 0
# («нечем проверить» выдано за «проверено — тегов нет»). После фикса (a2c8125)
# отказ источника обязан дать именованный rc 2 «NOT_IMPLEMENTED: git
# for-each-ref (done-теги) отказал», запись ЖИВА.
#
# ЗЕЛЁНЫЙ контроль (канал $BARRIER): apply при честном git → rc 0, свежая
# tmp/fresh021 снесена по живому тегу done/contracts/021/1 (квалификация ТОЛЬКО
# done-тегом: возраст −1ч). КРАСНОЕ (канал): та же запись воссоздана, удаление
# закрыто (chmod 555) → apply обязан отказаться rc 1 «не удалось удалить»,
# назвав запись; запись ЦЕЛА. Состояние персистентно для повторного прогона
# проверяющего.
#
# ПРЕДМЕТ к2 — прямой прогон барьера из фикстуры (scripts/gc_agent_branches.sh
# репозитория $REPO, НЕ канал: честный ответ на этот вход — rc 2, который
# мета-прогон справедливо не засчитывает фикстуре): подставной git с отказом
# только на done-for-each-ref → именованный rc 2 NOT_IMPLEMENTED с источником
# «for-each-ref» в отказе, запись tmp/fresh021 ЖИВА (fail-closed).
#
# СТАБ-ПРИВЯЗКИ (Н-39, по коду): S-noelse (for-each-ref без fail-closed else:
# отказ источника ≡ пустой done-набор) на зелёном контроле и красной ветви ЧЕСТЕН
# — живой тег реапает, закрытое удаление отказывает; его дефект наблюдаем ТОЛЬКО
# на входе с отказом источника done-тегов, к нему и привязан: прямой прогон даёт
# молчаливый rc 0 с живой записью вместо именованного rc 2 — именованное красное
# «молчаливый rc 0 и есть обход к2». Требовать красноты стаба на зелёном/красном
# входах — требовать лжи в диагнозе (Н-39).
#
# Прямой прогон (`bash fixtures/gc_agent_branches/case_zhnets_done_istochnik_otkaz.sh`):
# каркас _zhnets.sh сам назначает WORK/BARRIER; фикстура зелёна на фикс-базе
# (merge wip/026/implementer, a2c8125) и красна на пред-фикс блобе (a2c8125^)
# именованным «молчаливый rc 0».
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_zhnets.sh"

# Зелёный контроль (канал): живой done-тег 021 реапает свежую запись.
R="$WORK/repo-case-done-src"
zhnec_igrushka "$R"
mkdir -p "$R/tmp/fresh021"
printf 'свежая done-запись\n' > "$R/tmp/fresh021/f"
vozrast_chasov "$R/tmp/fresh021" 1
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: apply rc %s, ожидался 0:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'done 021' \
  || { printf 'ОТКАЗ: список не назвал причину «done 021»:\n%s\n' "$out" >&2; exit 1; }
[ ! -e "$R/tmp/fresh021" ] \
  || { printf 'ОТКАЗ: контроль реапа tmp/fresh021 не снесён — done-тег не работает\n' >&2; exit 1; }

# Красное (канал): удаление воссозданной записи невозможно — именованный отказ.
mkdir -p "$R/tmp/fresh021"
printf 'воссоздана для красной ветви\n' > "$R/tmp/fresh021/f"
vozrast_chasov "$R/tmp/fresh021" 1
chmod 555 "$R/tmp" "$R/tmp/fresh021"
rc=0; out="$("$BARRIER" --root "$R" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 1 ] || { printf 'ОТКАЗ: apply при закрытой записи дал rc %s, ожидался 1:\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'не удалось удалить' \
  || { printf 'ОТКАЗ: отказ не назван «не удалось удалить» (инвариант 6). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'tmp/fresh021' \
  || { printf 'ОТКАЗ: отказ не называет запись (правило 7). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
[ -e "$R/tmp/fresh021/f" ] \
  || { printf 'ОТКАЗ: запись повреждена вопреки отказу — fail-closed нарушен\n' >&2; exit 1; }

# Предмет к2 (прямой прогон): отказ источника done-тегов — именованный rc 2,
# запись жива. Подставной git отказывает ТОЛЬКО на refs/tags/done/contracts/*,
# остальное делегирует настоящему git.
R2="$WORK/repo-done-src-otkaz"
zhnec_igrushka "$R2"
mkdir -p "$R2/tmp/fresh021"
printf 'done-запись при отказе источника\n' > "$R2/tmp/fresh021/f"
vozrast_chasov "$R2/tmp/fresh021" 1
mkdir -p "$WORK/bin"
GITREAL="$(command -v git)"
{
  printf '#!/usr/bin/env bash\n'
  printf '# подставной git к2-атаки 2: отказ ТОЛЬКО на источнике done-тегов\n'
  printf 'for a in "$@"; do case "$a" in refs/tags/done/contracts/*) exit 1;; esac; done\n'
  printf 'exec %q "$@"\n' "$GITREAL"
} > "$WORK/bin/git"
chmod +x "$WORK/bin/git"
rc=0; out="$(PATH="$WORK/bin:$PATH" bash "$REPO/scripts/gc_agent_branches.sh" --root "$R2" --tmp-reap-apply 2>&1)" || rc=$?
[ "$rc" -eq 2 ] \
  || { printf 'ОТКАЗ: отказ источника done-тегов дал rc %s, ожидался 2 NOT_IMPLEMENTED — молчаливый rc 0 и есть обход к2 (отказ источника выдан за пустой done-набор):\n%s\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'NOT_IMPLEMENTED' \
  || { printf 'ОТКАЗ: отказ не назван NOT_IMPLEMENTED. Вывод gc:\n%s\n' "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fq -- 'for-each-ref' \
  || { printf 'ОТКАЗ: отказ не называет источник «for-each-ref» (правило 7). Вывод gc:\n%s\n' "$out" >&2; exit 1; }
[ -e "$R2/tmp/fresh021/f" ] \
  || { printf 'ОТКАЗ: запись удалена вопреки отказу источника done-тегов — fail-closed нарушен\n' >&2; exit 1; }
