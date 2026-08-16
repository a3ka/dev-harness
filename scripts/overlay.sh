#!/usr/bin/env bash
# Наложение НАШЕГО слоя поверх omp — одной командой.
#
# Заведено потому, что «помнить три команды после обновления» механизмом не является.
# Порядок был: распаковать харнес, перегенерировать роли, вернуть назначения моделей — и
# любой пропущенный шаг оставлял назначение до следующего обновления, после чего оно молча
# исчезало.
#
# Обновление харнеса — смена ОСНОВАНИЯ контура. Оно требует записанной причины, иначе
# основание меняется без следа. Поэтому расхождение с пином по умолчанию ОТКАЗ, а согласие
# выражается флагом с причиной, а не молчанием.
#
#   bash scripts/overlay.sh                        наложить слой, сверив пин
#   bash scripts/overlay.sh --check                только сверить, ничего не менять
#   bash scripts/overlay.sh --accept-new "причина"  принять новую версию и переписать пин
#
# Коды возврата: 0 — слой наложен и сверен, 1 — расхождение, 2 — нечем проверить.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIN="$HERE/config/harness_pin.json"

die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
ok()   { printf '  ok   %s\n' "$*" >&2; }

CHECK=0; ACCEPT=""; ACCEPT_SEEN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --check)      CHECK=1 ;;
    # Значение берётся ЯВНОЙ проверкой, а не `shift` вслепую: `shift` при пустом списке
    # возвращает не ноль и под `set -e` убивал скрипт молча — отказ без названной причины
    # это тот же тихий провал, против которого написано правило про код возврата.
    --accept-new) ACCEPT_SEEN=1; ACCEPT="${2:-}"; [ $# -ge 2 ] && shift ;;
    *)            die "неизвестный аргумент: $1" ;;
  esac
  shift
done
[ "$ACCEPT_SEEN" -eq 0 ] || [ -n "$ACCEPT" ] \
  || die "--accept-new требует причину: обновление контура без записанной причины — смена основания без следа"

command -v omp >/dev/null 2>&1 || skip "omp не установлен — накладывать не на что"
command -v jq  >/dev/null 2>&1 || skip "нет jq — пин не прочитать"
[ -f "$PIN" ] || skip "нет пина $PIN"

BIN="$(readlink -f "$(command -v omp)")"
got_ver="$(omp --version 2>/dev/null | sed 's|^omp/||')"
got_sha="$(sha256sum "$BIN" | cut -d' ' -f1)"
want_ver="$(jq -r '.version' "$PIN")"
want_sha="$(jq -r '.sha256' "$PIN")"

[ -n "$want_sha" ] && [ "$want_sha" != "null" ] \
  || die "в пине пуста контрольная сумма — пин без неё пином не является"

# ── сверка пина ──────────────────────────────────────────────────────────────
if [ "$got_ver" = "$want_ver" ] && [ "$got_sha" = "$want_sha" ]; then
  ok "пин совпал: omp/$got_ver"
elif [ -n "$ACCEPT" ]; then
  # Принятие новой версии — запись, а не правка одного числа: причина уходит в пин, чтобы
  # через месяц было видно, ЧТО именно приняли и зачем.
  [ "$CHECK" -eq 0 ] || die "--check и --accept-new вместе бессмысленны: первый ничего не меняет"
  tmp="$(mktemp)"
  jq --arg v "$got_ver" --arg s "$got_sha" --arg b "$(stat -c%s "$BIN")" \
     --arg why "$ACCEPT" --arg when "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '.version=$v | .sha256=$s | .bytes=($b|tonumber)
      | ._accepted = ((._accepted // []) + [{when:$when, version:$v, why:$why}])' \
     "$PIN" > "$tmp" && mv "$tmp" "$PIN"
  ok "принята новая версия omp/$got_ver, причина записана в пин"
else
  printf 'ОТКАЗ: харнес разошёлся с пином.\n' >&2
  printf '  версия:  установлена %s, пин %s\n' "$got_ver" "$want_ver" >&2
  printf '  sha256:  установлена %s\n           пин        %s\n' "$got_sha" "$want_sha" >&2
  printf '\nСовпадение версий при разной сумме означает переопубликованный тег: содержимое\n' >&2
  printf 'изменилось, номер нет. Принять осознанно:\n' >&2
  printf '  bash scripts/overlay.sh --accept-new "<почему обновляемся>"\n' >&2
  exit 1
fi

# ── наш слой ─────────────────────────────────────────────────────────────────
# Слой невелик намеренно: роли моделей в `.omp/config.yml` и агенты, порождённые из
# `roles/`. Всё, что можно породить, порождается, а не хранится дважды.
if [ "$CHECK" -eq 1 ]; then
  node "$HERE/scripts/gen-harness.ts" --check >/dev/null || die "агенты разошлись с roles/ — наложите слой"
  ok "агенты соответствуют roles/"
else
  node "$HERE/scripts/gen-harness.ts" >/dev/null || die "не удалось породить агентов из roles/"
  node "$HERE/scripts/gen-harness.ts" --check >/dev/null \
    || die "агенты разошлись с roles/ СРАЗУ после порождения — дефект генератора, не слоя"
  ok "агенты порождены из roles/ и сверены"
fi

[ -f "$HERE/.omp/config.yml" ] || die "нет .omp/config.yml — роли моделей не объявлены"
missing=0
for role in slow advisor plan; do
  grep -qE "^\s+${role}:" "$HERE/.omp/config.yml" || { printf '  FAIL роль модели не объявлена: %s\n' "$role" >&2; missing=1; }
done
[ "$missing" -eq 0 ] || die "слой неполон: роль без модели означает работу на умолчании харнеса"
ok "роли моделей объявлены: slow, advisor, plan"

printf '\nслой наложен поверх omp/%s\n' "$got_ver" >&2
