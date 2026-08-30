# ПРИЧИНА: заявленная зависшая ветка не наблюдается
#
# Срез 4 контракта 016, И-6: GC сносит СЛИТЫЕ wip/*, а зависшие СОХРАНЯЕТ наблюдаемо.
# «Наблюдаемо» здесь — не самосверка скрипта, а ЗАЯВЛЕННОЕ НАЛИЧИЕ: владелец объявляет
# зависшую входом `--expect-kept <ref>[=<oid>]`, и после прогона ref обязан быть в
# `for-each-ref`. Пустая выборка на заявленное наличие — красное, не зелёное.
#
# ПОЧЕМУ ВХОД ОБЪЯВЛЕННЫЙ, А НЕ ВНУТРЕННИЙ. Прежняя редакция барьера красила только
# расхождение ДВУХ СОБСТВЕННЫХ снимков refs/heads/wip/, снятых одним процессом; между
# ними мутирует лишь сам GC и лишь удалением слитых, а удалённые во второй снимок не
# попадают — счётчик отказов был нулём ПО ПОСТРОЕНИЮ, и предъявить барьер красным не мог
# никто (проверено: update-ref 0…0 и на несуществующий OID, dangling symref, git replace,
# symref-алиас — ни один не доживает до второго снимка). Такая самосверка — плацебо,
# ровно тот класс, который ловит verify_antiplacebo; вход объявлен, чтобы судимое
# отношение приезжало ИЗВНЕ.
#
# Различимость входа (Н-39): заявляется ветка, ДОСТИЖИМАЯ из HEAD, — GC сносит её как
# слитую, и заявленное наличие рушится. Барьер, который «сохраняет всё подряд» либо
# «не сносит ничего», на этом входе зелен.
#
# Зелёный контроль: одна слитая wip/001/slitaja (обязана исчезнуть) и одна зависшая
# wip/010/leftover, заявленная через --expect-kept (обязана уцелеть с тем же OID) → rc 0.
# Красное: слитая wip/002/slitaja-vtoraja заявлена зависшей → rc 1 «заявленная зависшая
# ветка не наблюдается после GC». Воспроизводимо: снесённая не возвращается.
#
# Серийные вызовы — `|| true` (А-32): серединный красный не обрывает case по set -e.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"
cd "$R"

# ── Зелёный контроль: слитая снесена, заявленная зависшая сохранна ────────────
mk_merged "$R" wip/001/slitaja
mk_hung "$R" wip/010/leftover "$WORK/wt-010"
oid_before="$(git -C "$R" rev-parse refs/heads/wip/010/leftover)"
"$BARRIER" --root "$R" --expect-kept "refs/heads/wip/010/leftover=$oid_before" || true

if git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q '^refs/heads/wip/001/slitaja$'; then
  printf 'ОТКАЗ: слитая ветка wip/001/slitaja пережила GC — авто-снос не исполнен\n' >&2
  exit 1
fi
if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q '^refs/heads/wip/010/leftover$'; then
  printf 'ОТКАЗ: зависшая wip/010/leftover снесена GC — она СОХРАННА (И-6)\n' >&2
  exit 1
fi
oid_after="$(git -C "$R" rev-parse refs/heads/wip/010/leftover)"
if [ "$oid_after" != "$oid_before" ]; then
  printf 'ОТКАЗ: цель wip/010/leftover сменена (было %s, стало %s) — смена цели равносильна сносу (И-6)\n' \
    "${oid_before:0:8}" "${oid_after:0:8}" >&2
  exit 1
fi

# ── Красное: зависшей заявлена ветка, достижимая из HEAD, — GC её сносит ──────
mk_merged "$R" wip/002/slitaja-vtoraja
out_gc="$("$BARRIER" --root "$R" --expect-kept refs/heads/wip/002/slitaja-vtoraja || true)"
if ! printf '%s\n' "$out_gc" | grep -q 'заявленная зависшая ветка не наблюдается'; then
  printf 'ОТКАЗ: GC не назвал пустую выборку на заявленное наличие: %s\n' "$out_gc" >&2
  exit 1
fi
if git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q '^refs/heads/wip/002/slitaja-vtoraja$'; then
  printf 'ОТКАЗ: заявленная ветка на месте — вход «пропала после GC» не построен\n' >&2
  exit 1
fi
