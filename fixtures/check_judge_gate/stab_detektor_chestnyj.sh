#!/usr/bin/env bash
# НЕ БАРЬЕР: ЧЕСТНАЯ ФОРМА предмета контракта 024 — детектора утечек
# scripts/check_no_leak.sh (эталон договора для фазы 1 пробы
# probe_slabyh_detektora.sh; прецедент stab_mera_chestnyj.sh контракта 021).
# Договор — Демаркация контракта 024; фразы несёт побайтово:
#   «основной чекаут загрязнён: <имена>» rc 1 — новые записи porcelain;
#   «снимок отсутствует» rc 1 — fail-closed, НЕ пропуск;
#   «основной чекаут чист» rc 0 — дельта пуста.
# Снимок — ВНЕ стерегомого дерева, путь производен от канонического корня
# (hash8-паттерн spawn_agent.sh:250), перезапись (последний выигрывает), TMPDIR
# уважается. Слабые формы живут в stab_detektor_*.sh — каждая умирает на СВОЁМ
# входе red_detektor_utechek.sh (Н-39: привязка кодом шапок).
set -uo pipefail
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'
P_NET_SNIMKA='снимок отсутствует'

usage() { printf 'ОТКАЗ диспетчер: использование: check_no_leak.sh --snapshot|--check <абс-корень>\n' >&2; exit 1; }
[ "$#" -eq 2 ] || usage
MODE="$1"; ROOT_ARG="$2"
case "$MODE" in --snapshot|--check) ;; *) usage ;; esac

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
CANON="$(cd "$ROOT_ARG" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: %s не каталог\n' "$ROOT_ARG" >&2; exit 2; }
git -C "$CANON" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$CANON" >&2; exit 2; }

# Снимок ВНЕ стерегомого дерева (И-1/И-8), путь — от канонического корня:
# два вызова с разными cwd сходятся в один файл (И-7).
SNAP_DIR="${TMPDIR:-/tmp}/dev-harness-leak/$(printf '%s' "$CANON" | sha256sum | cut -c1-8)"
SNAP="$SNAP_DIR/porcelain"

do_snapshot() {
  mkdir -p "$SNAP_DIR" || { printf 'NOT_IMPLEMENTED: %s не создать\n' "$SNAP_DIR" >&2; exit 2; }
  git -C "$CANON" status --porcelain > "$SNAP" \
    || { printf 'ОТКАЗ: status отказал в %s\n' "$CANON" >&2; exit 1; }
}

do_check() {
  if [ ! -f "$SNAP" ]; then
    printf 'ОТКАЗ: %s (%s) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)\n' "$P_NET_SNIMKA" "$SNAP" >&2
    exit 1
  fi
  cur="$(git -C "$CANON" status --porcelain)" \
    || { printf 'ОТКАЗ: status отказал в %s\n' "$CANON" >&2; exit 1; }
  base="$(cat "$SNAP")"
  delta="$(printf '%s\n' "$cur" | sort | comm -23 - <(printf '%s\n' "$base" | sort))"
  if [ -n "$delta" ]; then
    names=""
    while IFS= read -r l; do
      [ -n "$l" ] || continue
      p="${l:3}"
      if [ -z "$names" ]; then names="$p"; else names="$names, $p"; fi
    done <<< "$delta"
    printf 'ОТКАЗ: %s: %s\n' "$P_ZAGR" "$names" >&2
    exit 1
  fi
  printf '%s\n' "$P_CHISTO"
}

case "$MODE" in
  --snapshot) do_snapshot ;;
  --check)    do_check ;;
esac
exit 0
