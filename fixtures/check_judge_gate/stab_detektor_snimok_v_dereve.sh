#!/usr/bin/env bash
# НЕ БАРЬЕР: слабая форма детектора контракта 024 — «снимок-в-дереве». Пишет
# снимок ВНУТРИ стерегомого чекаута ($CANON/.leak-snimok) вместо ВНЕ. Сам
# снимок становится записью porcelain стерегомого — детектор загрязняет то,
# что стережёт (класс Н-48(2): барьер ловит сам себя). Дефект наблюдаем на
# воротах 8 red_detektor_utechek.sh — «снятие/сверка не загрязняют»: байтовое
# сравнение porcelain до/после ломается появившимся .leak-snimok. На прочих
# воротах форма честна (база включает собственный файл снимка, дельта
# считается корректно). Привязка — кодом этой шапки и кодом пробы (Н-39).
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
# ДЕФЕКТ: снимок ВНУТРИ стерегомого дерева.
SNAP="$CANON/.leak-snimok"

do_snapshot() {
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
