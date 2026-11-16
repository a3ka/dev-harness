#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s11 (Н-39: вход verify-drift).
# Дефект: сверка установленного слепа — при любых установленных файлах
# печатает успех, не сравнивая байты. Дрейф не ловится.
set -u

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="${OPS_SERVER_SRC:-$SELF_DIR}"
SBIN_DST="${OPS_SERVER_SBIN_DST-/usr/local/sbin}"
ETC_DST="${OPS_SERVER_ETC_DST-/etc/systemd/system}"

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

[ "$#" -eq 1 ] || usage
MODE="$1"

case "$MODE" in
  artifacts)
    printf 'ОТКАЗ: стаб s11 не реализует установку\n' >&2
    exit 1
    ;;
  verify-artifacts)
    if [ ! -e "$CLEAN_DST" ] && [ ! -e "$SVC_DST" ] && [ ! -e "$TMR_DST" ]; then
      printf 'ci-artifacts: не установлены (sudo bash ops/server/install.sh artifacts)\n'
      exit 0
    fi
    # ДЕФЕКТ: байты не сверяются
    printf 'ci-artifacts: сверка 3/3\n'
    exit 0
    ;;
  *) usage ;;
esac
