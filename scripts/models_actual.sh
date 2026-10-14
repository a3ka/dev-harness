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
#   bash scripts/models_actual.sh --tsv      TSV-адаптер трассы: `роль TAB модель
#                                            TAB allowed|denied` из того же
#                                            трейс-источника (JSONL сессий).
#                                            Человекочитаемый вывод без флага
#                                            идентичен прежнему (Решение 9
#                                            контракта 095, 028-дельта).
#   bash scripts/models_actual.sh --tsv --bind
#                                            проекция-надмножество (контракт
#                                            104, Решение 2): к каждой строке
#                                            --tsv байт-в-байт добавлены
#                                            `TAB <session-id> TAB <object-sha|->`;
#                                            session-id — basename JSONL без
#                                            .jsonl; object-sha — первая строка
#                                            `^OBJECT=[0-9a-f]{40}$` текста
#                                            задания сессии, иначе `-`.
#                                            Потребитель — оркестратор
#                                            (трасса --sud для judge_gate) и
#                                            check_sud_model --verdict; трасса
#                                            095 НЕ расширяется на месте
#                                            (make_task читает ровно 3 поля).
#
# Коды возврата: 0 — модель совпала с заявленной, 1 — разошлась, 2 — нечем проверить.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Потребитель следует разрешённому корню (контракт 028, инвариант 7):
# HARNESS_SESSION_HOME (унаследован от сессии) — первый приоритет; иначе —
# побайтовая формула с тем же `hash8-канон-корня` (внешняя оболочка, та же
# грамматика, что в workshop: единая формула, единая ручка).
if [ -n "${HARNESS_SESSION_HOME:-}" ]; then
  ZONE="$HARNESS_SESSION_HOME"
else
  _028_ROOT_TAIL=""
  _028_ROOT="$HERE"
  while [ ! -d "$_028_ROOT" ] && [ "$_028_ROOT" != "/" ]; do
    _028_ROOT_TAIL="/${_028_ROOT##*/}$_028_ROOT_TAIL"
    _028_ROOT="${_028_ROOT%/*}"
  done
  if [ -d "$_028_ROOT" ]; then
    _028_CANON="$(cd "$_028_ROOT" && pwd -P)$_028_ROOT_TAIL"
  else
    _028_CANON="$(cd "$HERE" && pwd -P)"
  fi
  _028_HASH8="$(printf '%s' "$_028_CANON" | sha256sum | cut -c1-8)"
  ZONE="${HARNESS_SCRATCH:-${XDG_STATE_HOME:-$HOME/.local/state}/dev-harness-sessions/$_028_HASH8}/zones/dev"
fi

ALL=0
TSV=0
BIND=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --all)  ALL=1 ;;
    --tsv)  TSV=1 ;;
    --bind) TSV=1; BIND=1 ;;
    "")     ;;
    *)      printf 'NOT_IMPLEMENTED: неизвестный флаг: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

# `--tsv` — адаптер трассы для make_task.sh: печатает строки
# `роль TAB модель TAB allowed|denied` из ТОГО ЖЕ источника (JSONL сессий
# в ZONE), что и человекочитаемый режим. Семантика 028 не меняется:
# `resolvedModelIsFallback=false` → заявленная модель РАЗРЕШЕНА (allowed),
# `true` → ЗАЯВЛЕННАЯ отвергнута и взята запасная (denied). Выход — на
# stdout; rc 0 если есть хоть одна строка, иначе 2. Не требует
# SESSION_ROLE/declared сверки (другая роль — другая задача).
if [ "$TSV" = "1" ]; then
  TAB="$(printf '\t')"
  mapfile -t _tsv_traces < <(find "$ZONE" -name '*.jsonl' -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2)
  [ "${#_tsv_traces[@]}" -gt 0 ] || { printf 'NOT_IMPLEMENTED: трейсов в зоне нет\n' >&2; exit 2; }
  if [ "$BIND" = "1" ]; then
    command -v jq >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq — текст задания сессии нечем разобрать\n' >&2; exit 2; }
  fi
  _tsv_found=0
  for f in "${_tsv_traces[@]}"; do
    # Роль — наиболее частое значение `"agent":"..."` в файле (агент,
    # ведший сессию). Пустая роль — пустое поле в TSV (cons make_task
    # тогда отказывает «нет свидетельства модели» — это не наш отказ).
    _role="$(grep -ohE '"agent"[[:space:]]*:[[:space:]]*"[a-z][a-z0-9-]*"' "$f" 2>/dev/null \
             | sed 's/.*"\([a-z][a-z0-9-]*\)"$/\1/' | LC_ALL=C sort | LC_ALL=C uniq -c \
             | LC_ALL=C sort -rn | head -1 | awk '{print $2}' || true)"
    # Каждое событие `model_change` — отдельная строка TSV. Регекс
    # однострочный: эти события короткие и не содержат переводов строк.
    _events="$(grep -ohE '"type":"model_change"[^{]*"model":"[^"]+"[^{]*"resolvedModelIsFallback":[a-z]+' "$f" 2>/dev/null || true)"
    # `--bind` (контракт 104, Решение 2): привязка сессии и объекта суда.
    # session-id — basename JSONL без .jsonl (тот же примитив, что норма 037);
    # алфавит [A-Za-z0-9._-] — TAB в значении невозможен по построению, вне
    # алфавита строка отбрасывается с rc 2 (fail-closed). object-sha — первая
    # строка `^OBJECT=[0-9a-f]{40}$` текста ЗАДАНИЯ сессии (сообщения роли
    # user; jq -r разворачивает \n — якоря ^…$ работают построчно), иначе `-`.
    if [ "$BIND" = "1" ]; then
      _session="$(basename "$f" .jsonl)"
      case "$_session" in ''|*[!A-Za-z0-9._-]*)
        printf 'NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: %s\n' "$_session" >&2; exit 2 ;;
      esac
      _object="$(jq -r 'select(.type == "message" and .message.role == "user") | .message.content[]?.text' "$f" 2>/dev/null \
                 | grep -m1 -E '^OBJECT=[0-9a-f]{40}$' | sed 's/^OBJECT=//' || true)"
      _object="${_object:--}"
      _tsv_tail="$TAB$_session$TAB$_object"
    else
      _tsv_tail=""
    fi
    if [ -z "$_events" ]; then continue; fi
    while IFS= read -r ev; do
      [ -z "$ev" ] && continue
      _m="$(printf '%s' "$ev" | sed -n 's/.*"model":"\([^"]*\)".*/\1/p')"
      _fb="$(printf '%s' "$ev" | sed -n 's/.*"resolvedModelIsFallback":\([a-z][a-z]*\).*/\1/p')"
      case "$_fb" in
        false) _perm="allowed" ;;
        true)  _perm="denied"  ;;
        *)     _perm="$_fb"    ;;
      esac
      printf '%s%s%s%s%s%s\n' "${_role:-}" "$TAB" "$_m" "$TAB" "$_perm" "$_tsv_tail"
      _tsv_found=$((_tsv_found + 1))
    done <<<"$_events"
  done
  [ "$_tsv_found" -gt 0 ] || { printf 'NOT_IMPLEMENTED: model_change событий в зоне нет\n' >&2; exit 2; }
  exit 0
fi

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
