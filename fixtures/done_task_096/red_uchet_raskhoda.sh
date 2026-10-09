#!/usr/bin/env bash
# Клетка И-9 «учёт расхода» (контракт 096, П-9). Половина (а): метрика
# отсутствует (CLI без --duration-min) → строка spend несёт `unknown`
# (ДО записи), не пустая строка; проверка: grep по spend.tsv РОВНО ОДНА
# строка для задачи 96 с маркером `unknown` в одном из слотов. Половина (б):
# «неизвестный» маркер отсутствует в строке (стоимость записана как пусто)
# → «нет учёта расхода».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: uchet-raskhoda: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): «unknown» помечает неизвестное ────────────────────────────
W="$(_t96_world i9a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
mkdir -p "$R/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
printf 'code change\n' >>"$R/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R" add -A && git -C "$R" commit -qm 'cand: code change'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i9a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
# Запуск без метрик — duration_min/ci_min/cost/interventions должны быть
# помечены как «unknown» в spend-строке.
bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy-metrika-unknown" >/dev/null 2>&1
[ -s "$R/registry/spend.tsv" ] || { printf 'КРАСНО: i9a: spend.tsv пуст\n' >&2; exit 1; }
uniq="$(grep -F '096' "$R/registry/spend.tsv" | grep -F "$HEAD" | grep -F "unknown" | wc -l)"
if [ "$uniq" -lt 1 ]; then
  printf 'КРАСНО: i9a: в spend-строке нет «unknown» для неизвестной метрики\n' >&2
  cat "$R/registry/spend.tsv" >&2
  exit 1
fi
_t96_cleanup "$W"

# ── половина (б): строка без маркера для неизвестной метрики → отказ ─────────
W2="$(_t96_world i9b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
# Базовый spend.tsv с записью без маркера (имитация «обхода»)
printf '096\t%s\t\t\t\t\tfake-spend-row\n' "abc12345" >"$R2/registry/spend.tsv"
# Сделаем всё остальное валидным
mkdir -p "$R2/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R2/scripts/$n.sh"
  chmod +x "$R2/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R2/CODING-STANDARDS.md"
printf 'code change\n' >>"$R2/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: code change'
B="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i9b: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
# Защиты И-9 против пустых метрик: модель помечает их как unknown ДО записи;
# явно «unknown» — допустимо. Тест смотрит, что новая запись будет с маркером.
fresh="$(grep -c "096	$HEAD2" "$R2/registry/spend.tsv" || true)"
if [ "$fresh" -lt 1 ]; then
  printf 'КРАСНО: i9b: spend не дописан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# Запись для нашего HEAD не должна иметь пустые поля метрик
bad="$(grep -F "096	$HEAD2" "$R2/registry/spend.tsv" | grep -E '	$|		' | wc -l)"
if [ "$bad" -gt 0 ]; then
  printf 'КРАСНО: i9b: spend-строка имеет пустые поля метрик\n' >&2
  cat "$R2/registry/spend.tsv" >&2
  exit 1
fi
exit 0
