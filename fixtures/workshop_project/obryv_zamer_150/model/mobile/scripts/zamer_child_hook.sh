#!/usr/bin/env bash
# 150 (prichinnyy-zamer-obryva): ДОЧЕРНИЙ ХУК матричного экрана (child).
# Вызывается раннером mobile/scripts/run-ci-screen.cjs в трёх канонических
# точках (каноничные строки вызова — model/kanon/child-hook-vyzovy.txt
# батареи 150; отклонение от них — именованный отказ батареи):
#   start   — до экранного исполнения child: сэмплер до boot/maestro
#             (данные ДО остановки/повтора по построению);
#   maestro — обёртка КАЖДОЙ попытки Maestro: stdout/stderr передаются в
#             диагностический ns текущей попытки (<ns>/maestro.log, append)
#             И в журнал job (tee); при отказе с канонической сигнатурой
#             обрыва 141 сбор исполняется НЕМЕДЛЕННО — до повтора/finally
#             раннера (состояние первой неудачи не теряется);
#   sbor    — в finally раннера ДО остановки эмулятора: стоп сэмплера,
#             гейт по ТЕКУЩЕЙ попытке ns, сбор артефакта.
# Итог child не меняется: rc хука = rc обёрнутой команды (И-1); собственные
# отказы — именованные маркеры в stderr, не rc.
set -uo pipefail

ZAMER='mobile/scripts/zamer_obryva.sh'
SIGNATURY_RE='device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException'

EKRAN="${EKRAN:-}" NS="${NS:-}" SERIAL="${SERIAL:-}" SPOOL="${SPOOL:-}" OUT="${OUT:-}"
KMD=''
ZAPRED=''
while [ $# -gt 0 ]; do
  case "$1" in
    start|maestro|sbor) KMD="$1"; shift; continue ;;
    --ekran) EKRAN="$2"; shift 2 ;;
    --ns) NS="$2"; shift 2 ;;
    --serial) SERIAL="$2"; shift 2 ;;
    --spool) SPOOL="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    --) shift; ZAPRED="$*"; break ;;
    *) printf 'ZAMER_HOOK_ARG_NEIZVESTEN: %s\n' "$1" >&2; exit 1 ;;
  esac
done

case "$KMD" in
  start)
    exec bash "$ZAMER" start \
      --ekran "$EKRAN" --ns "$NS" --serial "$SERIAL" --spool "$SPOOL"
    ;;
  sbor)
    exec bash "$ZAMER" sbor \
      --ekran "$EKRAN" --ns "$NS" --serial "$SERIAL" \
      --spool "$SPOOL" --out "$OUT"
    ;;
  maestro)
    [ -n "$ZAPRED" ] || { printf 'ZAMER_HOOK_MASTRO_PUSTO\n' >&2; exit 1; }
    [ -n "$NS" ] || { printf 'ZAMER_HOOK_BEZ_NS\n' >&2; exit 1; }
    mkdir -p "$NS" 2>/dev/null || true
    # stdout/stderr попытки Maestro — в диагностический ns ТЕКУЩЕЙ попытки
    # (append: каждая попытка дописывается) и в журнал job (tee)
    $ZAPRED 2>&1 | tee -a "$NS/maestro.log"
    rc="${PIPESTATUS[0]}"
    if [ "$rc" -ne 0 ] && grep -qE "$SIGNATURY_RE" "$NS/maestro.log" 2>/dev/null; then
      # сбор ДО повтора/finally раннера (S2 §1.3: снимок/сбор — до его
      # finally/повтора); rc сбора не влияет на итог child (И-1)
      bash "$ZAMER" sbor \
        --ekran "$EKRAN" --ns "$NS" --serial "$SERIAL" \
        --spool "$SPOOL" --out "$OUT" \
        || printf 'ZAMER_HOOK_SBOR_OTKAZ (itog child ne menjaetsja)\n' >&2
    fi
    exit "$rc"
    ;;
  *)
    printf 'ZAMER_HOOK_KMD_NEIZVESTEN: %s\n' "${KMD:-pusto}" >&2
    exit 1
    ;;
esac
