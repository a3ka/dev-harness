#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s09 (Н-39: вход install-artifacts).
# Дефект: таймер не включается — ни daemon-reload, ни enable --now. Установка
# «зелёная», но очистка никогда не запустится. Честная модель включает.
set -u

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${OPS_SERVER_SRC:-$SELF_DIR}"
SBIN_DST="${OPS_SERVER_SBIN_DST-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST-/etc/systemd/system}"
CIART_ROOT="${OPS_SERVER_CI_ARTIFACTS-/var/lib/ci-artifacts}"
MOB_OWNER="${OPS_SERVER_CI_ARTIFACTS_MOB_OWNER-harness}"
BACK_OWNER="${OPS_SERVER_CI_ARTIFACTS_BACK_OWNER-ci-back}"
CIART_GROUP="${OPS_SERVER_CI_ARTIFACTS_GROUP-harness}"
SYSTEMCTL="${OPS_SERVER_SYSTEMCTL-systemctl}"

CLEAN_SRC="$SRC_ROOT/root/ci-artifacts-clean"
SVC_SRC="$SRC_ROOT/root/systemd/ci-artifacts-clean.service"
TMR_SRC="$SRC_ROOT/root/systemd/ci-artifacts-clean.timer"
CLEAN_DST="$SBIN_DST/ci-artifacts-clean"
SVC_DST="$ETC_DST/ci-artifacts-clean.service"
TMR_DST="$ETC_DST/ci-artifacts-clean.timer"

usage() {
  printf 'NOT_IMPLEMENTED: использование: install-artifacts.sh artifacts|verify-artifacts\n' >&2
  exit 2
}
die_write() {
  printf 'ОТКАЗ: запись %s\n' "$1" >&2
  exit 1
}
check_one() {
  [ -f "$1" ] || { printf 'ОТКАЗ: расхождение %s (нет файла)\n' "$1" >&2; return 1; }
  a="$(sha256sum <"$1" | cut -d' ' -f1)"
  b="$(sha256sum <"$2" | cut -d' ' -f1)"
  [ "$a" = "$b" ] || { printf 'ОТКАЗ: расхождение %s\n' "$1" >&2; return 1; }
}
provision_root() {
  if [ -e "$1" ] || [ -L "$1" ]; then
    if [ -L "$1" ] || [ ! -d "$1" ]; then
      printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2
      exit 1
    fi
  else
    mkdir -p -- "$1" || die_write "$1"
  fi
  chown "$2:$CIART_GROUP" -- "$1" || die_write "chown $1"
  chmod 2775 -- "$1" || die_write "chmod $1"
}

command -v sha256sum >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

[ "$#" -eq 1 ] || usage
MODE="$1"

case "$MODE" in
  artifacts)
    if [ "$(id -u)" -ne 0 ]; then
      printf 'ОТКАЗ: artifacts-часть требует euid 0\n' >&2
      exit 1
    fi
    [ -f "$CLEAN_SRC" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$CLEAN_SRC" >&2; exit 1; }
    [ -f "$SVC_SRC" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$SVC_SRC" >&2; exit 1; }
    [ -f "$TMR_SRC" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$TMR_SRC" >&2; exit 1; }
    getent passwd "$MOB_OWNER" >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: нет пользователя: %s\n' "$MOB_OWNER" >&2; exit 1; }
    getent passwd "$BACK_OWNER" >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: нет пользователя: %s\n' "$BACK_OWNER" >&2; exit 1; }
    getent group "$CIART_GROUP" >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: нет группы: %s\n' "$CIART_GROUP" >&2; exit 1; }
    mkdir -p -- "$SBIN_DST" "$ETC_DST" || die_write "$SBIN_DST $ETC_DST"
    cp -- "$CLEAN_SRC" "$CLEAN_DST" || die_write "$CLEAN_DST"
    chmod 755 -- "$CLEAN_DST" || die_write "$CLEAN_DST"
    chown root:root -- "$CLEAN_DST" || die_write "$CLEAN_DST"
    check_one "$CLEAN_DST" "$CLEAN_SRC" || exit 1
    cp -- "$SVC_SRC" "$SVC_DST" || die_write "$SVC_DST"
    chmod 644 -- "$SVC_DST" || die_write "$SVC_DST"
    chown root:root -- "$SVC_DST" || die_write "$SVC_DST"
    cp -- "$TMR_SRC" "$TMR_DST" || die_write "$TMR_DST"
    chmod 644 -- "$TMR_DST" || die_write "$TMR_DST"
    chown root:root -- "$TMR_DST" || die_write "$TMR_DST"
    check_one "$SVC_DST" "$SVC_SRC" || exit 1
    check_one "$TMR_DST" "$TMR_SRC" || exit 1
    mkdir -p -- "$CIART_ROOT" || die_write "$CIART_ROOT"
    chown root:root -- "$CIART_ROOT" || die_write "chown $CIART_ROOT"
    chmod 755 -- "$CIART_ROOT" || die_write "chmod $CIART_ROOT"
    provision_root "$CIART_ROOT/Complior-mob" "$MOB_OWNER"
    provision_root "$CIART_ROOT/Complior-back" "$BACK_OWNER"
    # ДЕФЕКТ: включение таймера снято
    printf 'установлено: ci-artifacts (скрипт + 2 юнита + корни %s)\n' "$CIART_ROOT"
    exit 0
    ;;
  verify-artifacts)
    if [ ! -e "$CLEAN_DST" ] && [ ! -e "$SVC_DST" ] && [ ! -e "$TMR_DST" ]; then
      printf 'ci-artifacts: не установлены (sudo bash ops/server/install.sh artifacts)\n'
      exit 0
    fi
    rc=0
    check_one "$CLEAN_DST" "$CLEAN_SRC" || rc=1
    check_one "$SVC_DST" "$SVC_SRC" || rc=1
    check_one "$TMR_DST" "$TMR_SRC" || rc=1
    [ "$rc" -eq 0 ] && printf 'ci-artifacts: сверка 3/3\n'
    exit "$rc"
    ;;
  *) usage ;;
esac
