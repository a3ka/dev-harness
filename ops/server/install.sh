#!/usr/bin/env bash
# ops/server/install.sh — установщик серверной обвязки из репо (контракт 074).
#
# Единый источник — ops/server/ в этом дереве; установленное == репо (sha256
# по каждому из 9 файлов). Подкоманды (ровно одна):
#   user  — копирует ops/server/user/orch-loop в $HOME/.local/bin/orch-loop,
#           режим 755, перечитывает sha256 адресата против источника (rc 0 /
#           rc 1 с именем файла);
#   root  — копирует ops/server/root/orch-peak в /usr/local/sbin/orch-peak
#           (755, root:root) и 7 systemd-юнитов в /etc/systemd/system/
#           (644, root:root), перечитывает sha256 каждого; euid-гард под
#           harness отказывает rc 1 с фразой «root-часть требует euid 0»
#           ДО любых записей;
#   verify — только читает: побайтно сверяет все 9 адресатов с источниками;
#             все равны — rc 0 и «сверка: 9/9»; любое расхождение — rc 1
#             с stderr «ОТКАЗ: расхождение <путь>».
#
# Швы (инвариант 6): OPS_SERVER_SRC (умолчание — каталог скрипта), адресаты
# OPS_SERVER_BIN_DST / OPS_SERVER_SBIN_DST / OPS_SERVER_ETC_DST. При шве
# скрипт не читает и не пишет умолчательный путь того же шва.
#
# Коды возврата:
#   0 — успех (или сверка чиста);
#   1 — именованный отказ (запись/расхождение/euid), в stderr имя файла или
#       путь;
#   2 — нечем проверить (NOT_IMPLEMENTED: …; нет sha256sum / нет источника).

set -u

# ── корни и швы ──────────────────────────────────────────────────────────────
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${OPS_SERVER_SRC:-$SELF_DIR}"
# Швы-адресаты (инвариант 6): ${VAR-…} — пустая строка = значение (намеренный пустой OPS_SERVER_BIN_DST/ETC_DST/SBIN_DST = путь по умолчанию); источник SRC остаётся с :-(отсутствие SRC = дефолт).
BIN_DST="${OPS_SERVER_BIN_DST-$HOME/.local/bin}"
SBIN_DST="${OPS_SERVER_SBIN_DST-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST-/etc/systemd/system}"
UNITS='orch-peak@.service orch-peak-warn.timer orch-peak-stop.timer orch-peak-start.timer orch-peak-reenable.timer orch-peak-reenable.service orch-ctx.timer'

# ── зависимости и источник (fail-closed rc 2) ────────────────────────────────
command -v sha256sum >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }
[ -f "$SRC_ROOT/user/orch-loop" ] && [ -f "$SRC_ROOT/root/orch-peak" ] \
  || { printf 'NOT_IMPLEMENTED: нет источника ops/server (user/orch-loop, root/orch-peak)\n' >&2; exit 2; }

# ── помощники ────────────────────────────────────────────────────────────────
usage() {
  printf 'NOT_IMPLEMENTED: использование: ops/server/install.sh user|root|verify\n' >&2
  exit 2
}
die_write() {
  printf 'ОТКАЗ: запись %s\n' "$1" >&2
  exit 1
}
check_one() { # <адресат> <источник> — sha256 адресата vs источник
  [ -f "$1" ] || { printf 'ОТКАЗ: расхождение %s (нет файла)\n' "$1" >&2; return 1; }
  a="$(sha256sum <"$1" | cut -d' ' -f1)"
  b="$(sha256sum <"$2" | cut -d' ' -f1)"
  [ "$a" = "$b" ] || { printf 'ОТКАЗ: расхождение %s\n' "$1" >&2; return 1; }
}

# ── разбор подкоманды ────────────────────────────────────────────────────────
[ $# -eq 1 ] || usage
case "$1" in
  user)
    # user-часть: orch-loop → ~/.local/bin, режим 755, sha256 против источника.
    mkdir -p "$BIN_DST" || die_write "$BIN_DST"
    cp -- "$SRC_ROOT/user/orch-loop" "$BIN_DST/orch-loop" \
      || die_write "$BIN_DST/orch-loop"
    chmod 755 "$BIN_DST/orch-loop" || die_write "$BIN_DST/orch-loop"
    check_one "$BIN_DST/orch-loop" "$SRC_ROOT/user/orch-loop" || exit 1
    printf 'установлено: %s/orch-loop\n' "$BIN_DST"
    ;;
  root)
    # euid-гард: под harness отказываем rc 1 ДО mkdir/cp по швовым путям.
    if [ "$(id -u)" -ne 0 ]; then
      printf 'ОТКАЗ: root-часть требует euid 0\n' >&2
      exit 1
    fi
    mkdir -p "$SBIN_DST" "$ETC_DST" || die_write "$SBIN_DST $ETC_DST"
    cp -- "$SRC_ROOT/root/orch-peak" "$SBIN_DST/orch-peak" \
      || die_write "$SBIN_DST/orch-peak"
    chmod 755 "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    chown root:root "$SBIN_DST/orch-peak" || die_write "$SBIN_DST/orch-peak"
    rc=0
    check_one "$SBIN_DST/orch-peak" "$SRC_ROOT/root/orch-peak" || rc=1
    for u in $UNITS; do
      cp -- "$SRC_ROOT/root/systemd/$u" "$ETC_DST/$u" \
        || die_write "$ETC_DST/$u"
      chmod 644 "$ETC_DST/$u" || die_write "$ETC_DST/$u"
      chown root:root "$ETC_DST/$u" || die_write "$ETC_DST/$u"
      check_one "$ETC_DST/$u" "$SRC_ROOT/root/systemd/$u" || rc=1
    done
    [ "$rc" -eq 0 ] && printf 'установлено: root-часть (orch-peak + 7 юнитов)\n'
    exit "$rc"
    ;;
  verify)
    rc=0
    check_one "$BIN_DST/orch-loop" "$SRC_ROOT/user/orch-loop" || rc=1
    check_one "$SBIN_DST/orch-peak" "$SRC_ROOT/root/orch-peak" || rc=1
    for u in $UNITS; do
      check_one "$ETC_DST/$u" "$SRC_ROOT/root/systemd/$u" || rc=1
    done
    [ "$rc" -eq 0 ] && printf 'сверка: 9/9\n'
    exit "$rc"
    ;;
  *) usage ;;
esac
