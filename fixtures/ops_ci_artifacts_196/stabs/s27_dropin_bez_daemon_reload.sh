#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s27 (Н-39: вход install-runner-dropin).
# Дефект: daemon-reload идёт ДО установки drop-in — reload перечитывает
# юниты по-старому (без ReadWritePaths на корень моба); строки журнала
# все на месте, установка «зелёная». Маркер шима: dropin=no.
# Тело — модель model/install-artifacts.sh (швы и коды те же).
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
DROPIN_SRC="$SRC_ROOT/root/gh-runner-complior-ci-artifacts.conf"
CLEAN_DST="$SBIN_DST/ci-artifacts-clean"
SVC_DST="$ETC_DST/ci-artifacts-clean.service"
TMR_DST="$ETC_DST/ci-artifacts-clean.timer"
RUNNER_UNITS="gh-runner-complior gh-runner-complior-2"

usage() {
  printf 'NOT_IMPLEMENTED: использование: install-artifacts.sh artifacts|verify-artifacts\n' >&2
  exit 2
}
die_write() {
  printf 'ОТКАЗ: запись %s\n' "$1" >&2
  exit 1
}
check_one() { # <адресат> <источник>
  [ -f "$1" ] || { printf 'ОТКАЗ: расхождение %s (нет файла)\n' "$1" >&2; return 1; }
  a="$(sha256sum <"$1" | cut -d' ' -f1)"
  b="$(sha256sum <"$2" | cut -d' ' -f1)"
  [ "$a" = "$b" ] || { printf 'ОТКАЗ: расхождение %s\n' "$1" >&2; return 1; }
}
existing_matches() { # <каталог> <режим> <владелец:группа>
  [ "$(stat -c %a -- "$1")" = "$2" ] || return 1
  [ "$(stat -c %U:%G -- "$1")" = "$3" ] || return 1
  return 0
}
refuse_existing() { # <путь>
  printf 'ОТКАЗ: существующий корень расходится: %s\n' "$1" >&2
  exit 1
}
provision_base() { # <каталог>
  if [ -L "$1" ]; then
    printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2
    exit 1
  fi
  if [ -e "$1" ]; then
    [ -d "$1" ] || { printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2; exit 1; }
    existing_matches "$1" 755 root:root || refuse_existing "$1"
  else
    mkdir -p -- "$1" || die_write "$1"
    chown root:root -- "$1" || die_write "chown $1"
    chmod 755 -- "$1" || die_write "chmod $1"
  fi
}
provision_root() { # <каталог> <владелец>
  if [ -L "$1" ]; then
    printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2
    exit 1
  fi
  if [ -e "$1" ]; then
    [ -d "$1" ] || { printf 'ОТКАЗ: репо — символьная ссылка: %s\n' "$1" >&2; exit 1; }
    existing_matches "$1" 2750 "$2:$CIART_GROUP" || refuse_existing "$1"
  else
    mkdir -p -- "$1" || die_write "$1"
    chown "$2:$CIART_GROUP" -- "$1" || die_write "chown $1"
    chmod 2750 -- "$1" || die_write "chmod $1"
  fi
}

check_root() { # <корень репо> <владелец>
  if [ ! -d "$1" ] || [ "$(stat -c %a -- "$1")" != "2750" ]; then
    printf 'ОТКАЗ: расхождение ci-artifacts: %s\n' "$1" >&2
    return 1
  fi
  if [ "$(stat -c %U:%G -- "$1")" != "$2:$CIART_GROUP" ]; then
    printf 'ОТКАЗ: расхождение ci-artifacts: %s\n' "$1" >&2
    return 1
  fi
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
    [ -f "$DROPIN_SRC" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$DROPIN_SRC" >&2; exit 1; }
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
    provision_base "$CIART_ROOT"
    provision_root "$CIART_ROOT/Complior-mob" "$MOB_OWNER"
    provision_root "$CIART_ROOT/Complior-back" "$BACK_OWNER"
    # ДЕФЕКТ (стаб s27): reload ДО drop-in — юнит перечитан без него
    command -v "$SYSTEMCTL" >/dev/null 2>&1 \
      || { printf 'NOT_IMPLEMENTED: нет %s\n' "$SYSTEMCTL" >&2; exit 2; }
    "$SYSTEMCTL" daemon-reload >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: systemctl daemon-reload\n' >&2; exit 1; }
    for unit in $RUNNER_UNITS; do
      if [ -f "$ETC_DST/$unit.service" ]; then
        dropin_dir="$ETC_DST/$unit.service.d"
        dropin_dst="$dropin_dir/ci-artifacts.conf"
        mkdir -p -- "$dropin_dir" || die_write "$dropin_dir"
        cp -- "$DROPIN_SRC" "$dropin_dst" || die_write "$dropin_dst"
        chmod 644 -- "$dropin_dst" || die_write "$dropin_dst"
        chown root:root -- "$dropin_dst" || die_write "$dropin_dst"
        check_one "$dropin_dst" "$DROPIN_SRC" || exit 1
      fi
    done
    "$SYSTEMCTL" enable --now ci-artifacts-clean.timer >/dev/null 2>&1 \
      || { printf 'ОТКАЗ: ci-artifacts-clean.timer не включён\n' >&2; exit 1; }
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
    if [ "$rc" -ne 0 ]; then
      exit 1
    fi
    check_root "$CIART_ROOT/Complior-mob" "$MOB_OWNER" || exit 1
    check_root "$CIART_ROOT/Complior-back" "$BACK_OWNER" || exit 1
    for unit in $RUNNER_UNITS; do
      if [ -f "$ETC_DST/$unit.service" ]; then
        check_one "$ETC_DST/$unit.service.d/ci-artifacts.conf" "$DROPIN_SRC" || exit 1
      fi
    done
    printf 'ci-artifacts: сверка 3/3\n'
    exit 0
    ;;
  *) usage ;;
esac
