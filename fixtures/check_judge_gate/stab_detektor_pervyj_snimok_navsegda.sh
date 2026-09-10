#!/usr/bin/env bash
# НЕ БАРЬЕР: слабая форма детектора контракта 024 — «первый-снимок-навсегда».
# --snapshot пишет снимок ТОЛЬКО если файла ещё нет: повторный вызов молча
# ничего не обновляет, база навсегда первая. На живой церемонии (снимок на
# каждую пачку) такой детектор ложится красным на любую легитимную смену
# состояния между пачками — вечный ложный красный, который учат обходить
# (худший исход: нормализация обхода). Дефект наблюдаем на воротах 6
# red_detektor_utechek.sh — «повторный снимок обновляет базу»: мусор,
# добавленный между двумя снимками, не входит в базу, сверка краснеет
# вместо rc 0. Привязка — кодом этой шапки и кодом пробы (Н-39).
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
SNAP_DIR="${TMPDIR:-/tmp}/dev-harness-leak/$(printf '%s' "$CANON" | sha256sum | cut -c1-8)"
SNAP="$SNAP_DIR/porcelain"

do_snapshot() {
  # ДЕФЕКТ: пишем только при отсутствии — первый снимок заморожен навсегда.
  if [ -f "$SNAP" ]; then
    return 0
  fi
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
