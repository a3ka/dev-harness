#!/usr/bin/env bash
# Фактическая модель сессии и её делегирование — ПО ТРЕЙСУ, а не по конфигу.
#
# Заведено по измеренному расхождению: конфиг объявлял одну модель, а интерактивная сессия
# поднялась на другой — TUI восстановил ранее выбранную поверх конфига, и `modelRoleStorage`
# у omp `global`, то есть выбор живёт в доме, а не в проекте. Непрогонные запуски конфигу при
# этом подчинялись, поэтому расхождение было НЕВИДИМЫМ.
#
# Второе, что печатается здесь, — ДЕЛЕГИРОВАНИЕ. Сессия ведётся ролью `architect` на дорогой
# модели, и экономия держится ровно на том, отдаёт ли она пункты исполнителю или делает сама.
# «Отдаёт» — счётное утверждение, значит его надо считать, а не чувствовать. Субагентские
# сессии лежат в подкаталоге по имени родителя, поэтому счёт возможен.
#
#   bash scripts/models_actual.sh            последняя сессия
#   bash scripts/models_actual.sh --all      все сессии зоны, от новых к старым
#
# Коды возврата: 0 — модель совпала с заявленной, 1 — разошлась, 2 — нечем проверить.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZONE="$HERE/.zones/dev"

ALL=0
[ "${1:-}" = "--all" ] && ALL=1

# Заявлено — модель РОЛИ СЕССИИ, а не `default`: сессию ведёт роль, и сверять надо с её моделью.
SESSION_ROLE="architect"
mr="$(grep -oE '^model: \["@[a-z]+"\]' "$HERE/.omp/agents/$SESSION_ROLE.md" 2>/dev/null | sed 's/.*@//;s/"\]//' || true)"
[ -n "$mr" ] || { printf 'NOT_IMPLEMENTED: у роли %s не объявлена роль модели\n' "$SESSION_ROLE" >&2; exit 2; }
declared="$(grep -oE "^\s+${mr}:\s*\"[^\"]+\"" "$HERE/.omp/config.yml" | sed 's/.*"\(.*\)"/\1/')"
[ -n "$declared" ] || { printf 'NOT_IMPLEMENTED: роль модели @%s не объявлена в .omp/config.yml\n' "$mr" >&2; exit 2; }

mapfile -t traces < <(find "$ZONE" -name '*.jsonl' -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2)
[ "${#traces[@]}" -gt 0 ] || { printf 'NOT_IMPLEMENTED: трейсов в зоне нет — сессий ещё не было\n' >&2; exit 2; }

printf 'роль сессии %s, заявлена модель %s\n\n' "$SESSION_ROLE" "$declared"

bad=0; shown=0
for f in "${traces[@]}"; do
  # Полная форма `провайдер/модель`: короткая встречается в теле ответов и свидетельством о
  # том, чем работала сессия, не является.
  actual="$(grep -ohE '"model":"[a-z-]+/[^"]+"' "$f" 2>/dev/null | sed 's/.*:"\(.*\)"/\1/' | sort -u | tr '\n' ' ' | sed 's/ $//')"
  when="$(date -r "$f" '+%d.%m %H:%M' 2>/dev/null || echo '?')"

  kids_dir="${f%.jsonl}"
  kids=0; roles=''
  if [ -d "$kids_dir" ]; then
    kids="$(find "$kids_dir" -name '*.jsonl' 2>/dev/null | wc -l)"
    roles="$(grep -rhoE '"agent"[[:space:]]*:[[:space:]]*"[a-z-]+"' "$kids_dir" 2>/dev/null \
             | sed 's/.*"\([a-z-]*\)"$/\1/' | sort -u | tr '\n' ',' | sed 's/,$//')"
  fi
  deleg="делегировано $kids"
  [ -n "$roles" ] && deleg="$deleg ($roles)"

  # ГЕЙТ — только ПОСЛЕДНЯЯ сессия. Прошлые могли идти на другой модели законно: роль сессии
  # или её модель менялись, и это записано в git. История — контекст, а не нарушение; гейт,
  # краснеющий на прошлом, которое уже нельзя исправить, отучает себе верить.
  mark='  '
  if [ -z "$actual" ]; then mark='? '
  elif [ "$actual" = "$declared" ]; then mark='ok'
  else
    mark='!!'
    [ "$shown" -eq 0 ] && bad=$((bad + 1))
  fi
  printf '  %s  %s  %-30s %s\n' "$when" "$mark" "${actual:-модель не названа}" "$deleg"
  shown=$((shown + 1))
  [ "$ALL" -eq 1 ] || break
done

printf '\nсессий показано: %d · гейт по ПОСЛЕДНЕЙ: %s\n' "$shown" "$([ "$bad" -eq 0 ] && echo 'совпала с заявленной' || echo 'РАСХОЖДЕНИЕ')"
[ "$ALL" -eq 1 ] && printf 'знаки: ok совпало · !! разошлось (для прошлых сессий это норма, если модель меняли) · ? не названа\n'
[ "$bad" -eq 0 ] || exit 1
