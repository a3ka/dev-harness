# ПРИЧИНА: СОревью на рутине
#
# Зелёный контроль — дизайн-рутина, маршрут «свой», без СОревью. Красное — смена
# маршрута на «со-ревью» (over-триггер: цена — вызов сильной модели). Барьер
# обязан назвать «СОревью на рутине» и предмет.
set -euo pipefail

WORK="${WORK:-$(mktemp -d "${TMPDIR:-/tmp}/v029-case.XXXXXX")}"
ROOT="$WORK/root"
mkdir -p "$ROOT/forks" "$ROOT/verdicts/consultant"

NOW="$(date -u +%s)"
iso_nazad() { date -u -d "@$(( NOW - $1 ))" +%Y-%m-%dT%H:%M:%SZ; }

zapis() {
  local id="$1"; shift
  {
    printf 'ФОРК: %s\n' "$id"
    printf 'ВОПРОС: подставной вопрос предмета %s\n' "$id"
    for f in "$@"; do printf '%s\n' "$f"; done
  } > "$ROOT/forks/$id.md"
}

# Зелёный контроль: рутина → свой (без СОревью, без отказа).
zapis pereimenovanie-polja "КЛАСС: дизайн" "ПРИЗНАК: рутина" "МАРШРУТ: свой" \
      "ЗАВЕДЁН: $(iso_nazad 900)"

"$BARRIER" --root "$ROOT"

# Саботаж: смена маршрута на «со-ревью» — over-триггер сильной модели.
zapis pereimenovanie-polja "КЛАСС: дизайн" "ПРИЗНАК: рутина" "МАРШРУТ: со-ревью" \
      "ЗАВЕДЁН: $(iso_nazad 900)"

"$BARRIER" --root "$ROOT"