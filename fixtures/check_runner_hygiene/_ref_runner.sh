#!/usr/bin/env bash
# НЕ БАРЬЕР: эталон ГИГИЕНЫ раннера (контракт 011, тест-актив для check_runner_hygiene).
#
# Реализует ПИННОВАННЫЙ контрактом 011 API гигиены `scripts/verify_antiplacebo.sh` вокруг
# тривиальной «работы» (sleep). Настоящий предмет исполняет ту же дисциплину вокруг полной
# пачки фикстур; здесь дисциплина выделена в чистом виде, чтобы ЗЕЛЁНЫЙ контроль барьера
# не зависел от предмета (прецедент — `fixtures/check_scoped_run/_ref_va.sh`). Кнопка
# REF_HOLD (сек) держит «работу» на месте, где у настоящего раннера гоняются фикстуры:
# барьеру нужно окно, в котором lock жив.
#
# API дословно из контракта 011 §Предмет:
#   VERIFY_ANTIPLACEBO_SCRATCH — корень scratch; умолчание — mktemp под ${TMPDIR:-/tmp}
#         (carve-out правила 16, РАЗРЕШИЛ-ВЛАДЕЛЕЦ 2026-08-24);
#   lock — $SCRATCH/verify_antiplacebo-<hash8>.lock, где hash8 — первые 8 hex sha256
#         КАНОНИЧЕСКОГО пути корня проверяемого дерева (разные деревья не блокируют друг
#         друга: взаимная порча снапшотов измерена только для одного дерева, Н-48-3);
#   содержимое lock — «<pid> <pgid> <epoch>»; захват атомарен (noclobber);
#   живой владелец → rc 3 и stderr «занят: …»; существующий прогон НЕ трогается;
#   стартовая чистка — lock-файлы и run-<pid> каталоги МЁРТВЫХ владельцев плюс файлы,
#         не являющиеся ни lock, ни run-каталогом живого pid (base64-обрывки путей);
#         чужой live lock другого дерева неприкосновенен;
#   раннер не убивает НИЧЕГО, кроме собственных потомков по pgid; pkill -f по имени
#         запрещён (Н-48-4: pkill убивал чужие прогоны).
set -uo pipefail

ROOT_ARG="${1:-}"
[ -n "$ROOT_ARG" ] || { echo 'ОТКАЗ: нужен аргумент — корень проверяемого дерева' >&2; exit 1; }
ROOT="$(cd "$ROOT_ARG" 2>/dev/null && pwd)" || { echo "ОТКАЗ: корня нет: $ROOT_ARG" >&2; exit 1; }

SCRATCH="${VERIFY_ANTIPLACEBO_SCRATCH:-}"
if [ -z "$SCRATCH" ]; then
  SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX")" || {
    echo 'ОТКАЗ: scratch не создать' >&2; exit 2; }
fi
mkdir -p "$SCRATCH" 2>/dev/null || { echo "ОТКАЗ: scratch не создать: $SCRATCH" >&2; exit 2; }

hash8="$(printf '%s' "$ROOT" | sha256sum | cut -c1-8)"
LOCK="$SCRATCH/verify_antiplacebo-$hash8.lock"

# ── стартовая чистка: только артефакты МЁРТВЫХ владельцев ──────────────────────
for l in "$SCRATCH"/verify_antiplacebo-*.lock; do
  [ -f "$l" ] || continue
  read -r pid _ < "$l" || true
  if [ -n "${pid:-}" ] && ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$l"
    rm -rf "$SCRATCH/run-$pid" 2>/dev/null || true
  fi
done
for f in "$SCRATCH"/*; do
  [ -e "$f" ] || continue
  b="${f##*/}"
  case "$b" in
    verify_antiplacebo-*.lock) ;;          # lock (в т.ч. чужой live) — не трогаем
    run-*) pid="${b#run-}"
           kill -0 "$pid" 2>/dev/null || rm -rf "$f" ;;
    *) rm -rf "$f" ;;                       # base64-обрывки и прочий мусор убитых прогонов
  esac
done

# ── захват lock: живой владелец → именованный отказ, существующий не трогаем ────
if [ -f "$LOCK" ]; then
  read -r pid _ < "$LOCK" || true
  if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
    printf 'занят: verify_antiplacebo уже идёт над этим деревом (pid %s, корень %s) — второй прогон не запускается\n' \
      "$pid" "$ROOT" >&2
    exit 3
  fi
  rm -f "$LOCK"    # владелец мёртв — чистка выше не знала формата, добираем здесь
fi
if ( set -C; : > "$LOCK" ) 2>/dev/null; then
  printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$LOCK"
else
  printf 'занят: lock %s не захвачен атомарно — параллельный прогон\n' "$LOCK" >&2
  exit 3
fi

RUN="$SCRATCH/run-$$"
mkdir -p "$RUN"
release() { rm -rf "$RUN"; rm -f "$LOCK"; }
trap release EXIT
printf 'run %s: работа раннера\n' "$RUN" > "$RUN/log"

sleep "${REF_HOLD:-2}"
exit 0
