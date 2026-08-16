#!/usr/bin/env bash
# Фактическая модель сессии — ПО ТРЕЙСУ, а не по конфигу.
#
# Заведено по измеренному расхождению: конфиг объявлял `minimax/MiniMax-M3`, а интерактивная
# сессия поднялась на `Opus 4.8` — модели, которой в наших ролях нет вовсе. TUI восстановил
# ранее выбранную модель поверх конфига, и `modelRoleStorage` у omp `global`, то есть выбор
# живёт в доме, а не в проекте. Непрогонные запуски при этом конфигу подчинялись, поэтому
# расхождение было НЕВИДИМЫМ.
#
# Конфиг говорит, что мы назначили. Трейс говорит, что произошло. Пока разницу не печатает
# команда, «сессия идёт на такой модели» — утверждение без механизма.
#
#   bash scripts/models_actual.sh            последняя сессия: заявлено против фактического
#   bash scripts/models_actual.sh --all      все сессии зоны, от новых к старым
#
# Коды возврата: 0 — совпало, 1 — разошлось, 2 — нечем проверить (трейсов нет).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZONE="$HERE/.zones/dev"

ALL=0
[ "${1:-}" = "--all" ] && ALL=1

declared="$(grep -oE '^\s+default:\s*"[^"]+"' "$HERE/.omp/config.yml" | sed 's/.*"\(.*\)"/\1/')"
[ -n "$declared" ] || { printf 'NOT_IMPLEMENTED: в .omp/config.yml не объявлена роль default\n' >&2; exit 2; }

mapfile -t traces < <(find "$ZONE" -name '*.jsonl' -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2)
[ "${#traces[@]}" -gt 0 ] || { printf 'NOT_IMPLEMENTED: трейсов в зоне нет — сессий ещё не было\n' >&2; exit 2; }

printf 'заявлено в .omp/config.yml: %s\n\n' "$declared"

bad=0; shown=0
for f in "${traces[@]}"; do
  # Полная форма `провайдер/модель`: короткая встречается в теле ответов и не является
  # свидетельством о том, чем сессия работала.
  actual="$(grep -ohE '"model":"[a-z-]+/[^"]+"' "$f" 2>/dev/null | sed 's/.*:"\(.*\)"/\1/' | sort -u | tr '\n' ' ' | sed 's/ $//')"
  when="$(date -r "$f" '+%d.%m %H:%M' 2>/dev/null || echo '?')"
  if [ -z "$actual" ]; then
    printf '  %s  %-28s модель в трейсе не названа\n' "$when" "$(basename "$f" | cut -c1-24)"
  elif [ "$actual" = "$declared" ]; then
    printf '  %s  ok         %s\n' "$when" "$actual"
  else
    printf '  %s  РАСХОЖДЕНИЕ %s (заявлено %s)\n' "$when" "$actual" "$declared"
    bad=$((bad + 1))
  fi
  shown=$((shown + 1))
  [ "$ALL" -eq 1 ] || break
done

printf '\nсессий проверено: %d, расхождений: %d\n' "$shown" "$bad"
[ "$bad" -eq 0 ] || exit 1
