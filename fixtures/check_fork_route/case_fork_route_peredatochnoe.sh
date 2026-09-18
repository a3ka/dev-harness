# ПРИЧИНА: передаточное касание
#
# Зелёный контроль — журнал из конформных записей: всё адресовано консультанту, воля
# владельца засвидетельствована. Красное — добавление ОДНОЙ инженерной записи,
# адресованной владельцу (МАРШРУТ: батч без КЛАСС); барьер обязан назвать
# «передаточное касание» и предмет.
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

svidetelstvo() {
  local id="$1"
  {
    printf 'ПРЕДМЕТ: %s\n' "$id"
    printf 'МОДЕЛЬ: anthropic/claude-fable-5\n'
    printf 'ПОДТВЕРЖДЕНО: воля-владельца\n'
    printf 'РЕКОМЕНДАЦИЯ: вопрос в зоне воли.\n'
  } > "$ROOT/verdicts/consultant/$id-klass-v1.md"
}

# Зелёный контроль: всё по маршруту (а)/(б), ничего передаточного.
zapis metering-cena "КЛАСС: воля-владельца" "ПРИЗНАК: деньги" "МАРШРУТ: батч" \
      "АВТОР: anthropic/claude-opus-5" "ЗАВЕДЁН: $(iso_nazad 1200)"
svidetelstvo metering-cena
zapis ascii-konvencija "КЛАСС: инженерный" "МАРШРУТ: консультант" \
      "ЗАВЕДЁН: $(iso_nazad 600)"

"$BARRIER" --root "$ROOT"

# Саботаж: инженерная запись уведена владельцу (МАРШРУТ: батч) — нарушение инв. 1.
zapis ci-waiver-prodlenie "КЛАСС: инженерный" "МАРШРУТ: батч" \
      "ЗАВЕДЁН: $(iso_nazad 300)"

"$BARRIER" --root "$ROOT"