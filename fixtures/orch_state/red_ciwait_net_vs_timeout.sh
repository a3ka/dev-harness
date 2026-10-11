#!/usr/bin/env bash
# Клетка 14 — red_ciwait_net_vs_timeout.sh (И-5; контракт 092 §(2).14). ДВА входа,
# каждый — своё предъявление; клетка красна, если хотя бы один вход прошёл
# неправильно: два РАЗНЫХ терминальных исхода ci_wait — два РАЗНЫХ rc.
# Вход-а: шов эндпоинта GitHub → 127.0.0.1:9 (connection refused), валидный
# 40-hex, щедрые --attempts/--timeout. Тогда: rc 2 «нечем проверить» (транспорт),
# НЕ rc 3. Вход-б: toy-API отвечает in_progress на КАЖДЫЙ запрос; --attempts 2.
# Тогда: rc 3 «таймаут» при ≥2 полученных валидных in_progress-ответах — НЕ rc 2.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need ciwait
K=red_ciwait_net_vs_timeout

kletka() {
  # Вход-а — транспорт недоступен: терминальный исход «нечем проверить» = rc 2
  # (НЕ таймаут rc 3: попытки/таймаут щедрые, отказа по исчерпанию быть не может).
  o92_world
  o92_toy nvt_a
  O92_API='http://127.0.0.1:9'
  o92_rnd_hex40
  o92_probe ciwait --sha "$O92_HEX" --interval 0.3 --attempts 5 --timeout 10
  o92_assert_rc "$K[а]" 2 || return
  # Вход-б — валидные in_progress-ответы исчерпали попытки: исход «таймаут» = rc 3
  # (НЕ «нечем проверить» rc 2: ≥2 ответа получены, счёт — из лога toy-API).
  o92_world
  o92_toy nvt_b
  o92_api_responses "$O92_RESP_INPROG"
  o92_rnd_hex40
  o92_probe ciwait --sha "$O92_HEX" --interval 0.3 --attempts 2 --timeout 10
  o92_assert_rc "$K[б]" 3 || { o92_api_stop; return; }
  local n; n="$(o92_api_count)"
  [ "$n" -ge 2 ] || { o92_red "$K[б]" "валидных in_progress-ответов $n < 2 — таймаут не доказан (счёт из лога toy-API)"; o92_api_stop; return; }
  o92_api_stop
  o92_ok "$K"
}
kletka
exit "$O92_RED"
