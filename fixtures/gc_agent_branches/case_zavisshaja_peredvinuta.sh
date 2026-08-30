# ПРИЧИНА: цель заявленной зависшей сменена
#
# Срез 4 контракта 016, И-6, ТОЖДЕСТВО ЦЕЛИ, а не только имя: владелец пинует OID зависшей
# ДО прогона и заявляет пару входом `--expect-kept <ref>=<oid>`. Имя может быть живо и
# честно напечатано в СПИСКЕ, но если ref смотрит на ДРУГОЙ объект — это равносильно
# сносу, и сверка тождества красная. Способы смены цели не перечисляются: судится
# результат-форма (наблюдаемый OID), а не механизм перевода.
#
# Различимость входа (Н-39): ветка ОСТАЁТСЯ зависшей (её новая цель тоже недостижима из
# HEAD), поэтому ветвь «не наблюдается» на этом входе молчит — красит ровно тождество
# цели. Барьер, проверяющий лишь присутствие имени, здесь зелен.
#
# Зелёный контроль: зависшая wip/011/leftover заявлена парой ref=oid; GC её сохраняет,
# OID совпадает → rc 0, и в СПИСКЕ владельцу она названа поимённо.
# Красное: цель wip/011/leftover переведена на другой недостижимый коммит (ветка
# wip/012/other), заявка та же, со СТАРЫМ oid → rc 1 «цель заявленной зависшей сменена».
# Воспроизводимо: переведённая цель остаётся переведённой.
#
# Серийные вызовы — `|| true` (А-32): серединный красный не обрывает case по set -e.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"
cd "$R"

# ── Зелёный контроль: заявленная пара ref=oid наблюдается после прогона ───────
mk_hung "$R" wip/011/leftover "$WORK/wt-011"
oid_before="$(git -C "$R" rev-parse refs/heads/wip/011/leftover)"
out_green="$("$BARRIER" --root "$R" --expect-kept "refs/heads/wip/011/leftover=$oid_before" || true)"
if ! printf '%s\n' "$out_green" | grep -q 'refs/heads/wip/011/leftover'; then
  printf 'ОТКАЗ: зависшая не названа поимённо в СПИСКЕ владельцу (Н-59): %s\n' "$out_green" >&2
  exit 1
fi
if [ "$(git -C "$R" rev-parse refs/heads/wip/011/leftover)" != "$oid_before" ]; then
  printf 'ОТКАЗ: GC сам сменил цель зависшей — зелёная основа не построена\n' >&2
  exit 1
fi

# ── Красное: цель переведена на другой недостижимый коммит, заявка прежняя ────
mk_hung "$R" wip/012/other "$WORK/wt-012"
oid_other="$(git -C "$R" rev-parse refs/heads/wip/012/other)"
# Ветка вычекана в своём worktree — пока он жив, цель не перевести. Снимаем worktree,
# переводим ref: имя остаётся живым, объект — другой.
g "$R" worktree remove --force "$WORK/wt-011"
g "$R" branch -f wip/011/leftover "$oid_other"
if [ "$(git -C "$R" rev-parse refs/heads/wip/011/leftover)" = "$oid_before" ]; then
  printf 'ОТКАЗ: цель не переведена — вход «OID сменился» не построен\n' >&2
  exit 1
fi
out_red="$("$BARRIER" --root "$R" --expect-kept "refs/heads/wip/011/leftover=$oid_before" || true)"
if ! printf '%s\n' "$out_red" | grep -q 'цель заявленной зависшей сменена'; then
  printf 'ОТКАЗ: GC не назвал смену цели заявленной зависшей: %s\n' "$out_red" >&2
  exit 1
fi
# Имя при этом живо и напечатано — красит именно тождество, а не присутствие.
if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q '^refs/heads/wip/011/leftover$'; then
  printf 'ОТКАЗ: ветка исчезла — вход «имя живо, цель другая» не построен\n' >&2
  exit 1
fi
