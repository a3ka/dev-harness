#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s29 (Н-39: вход verify-runner-dropin).
# Дефект: сверка не смотрит drop-in моб-раннера — юнит стоит, drop-in
# дрейфнут или отсутствует, verify всё равно печатает «сверка 3/3».
# Стиль s11: установка не реализована, обманке отдан только этап сверки.
set -u

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${OPS_SERVER_SRC:-$SELF_DIR}"
SBIN_DST="${OPS_SERVER_SBIN_DST-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST-/etc/systemd/system}"
CIART_ROOT="${OPS_SERVER_CI_ARTIFACTS-/var/lib/ci-artifacts}"
MOB_OWNER="${OPS_SERVER_CI_ARTIFACTS_MOB_OWNER-harness}"
BACK_OWNER="${OPS_SERVER_CI_ARTIFACTS_BACK_OWNER-ci-back}"
CIART_GROUP="${OPS_SERVER_CI_ARTIFACTS_GROUP-harness}"

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
    printf 'ОТКАЗ: стаб s29 не реализует установку\n' >&2
    exit 1
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
    # ДЕФЕКТ (стаб s29): drop-in'ы моб-раннера не сверяются никак
    printf 'ci-artifacts: сверка 3/3\n'
    exit 0
    ;;
  *) usage ;;
esac
