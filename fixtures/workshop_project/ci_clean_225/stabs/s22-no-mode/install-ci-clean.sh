#!/usr/bin/env bash
# Исполнительная модель новой ветви install.sh; прежние ветви судит 196.
set -u
SRC_ROOT="${OPS_SERVER_SRC:?}"
SBIN_DST="${OPS_SERVER_SBIN_DST:?}"
ETC_DST="${OPS_SERVER_ETC_DST:?}"
CTL="${OPS_SERVER_SYSTEMCTL-systemctl}"
FILES='root/ci-artifacts-clean root/ci-runner-tmp-clean root/ci-clean.py ci-clean.json ci-clean.schema.json root/systemd/ci-runner-tmp-clean.service root/systemd/ci-runner-tmp-clean.timer'
COMMON='root/ci-clean.py ci-clean.json ci-clean.schema.json'
TMP_FILES='root/ci-runner-tmp-clean root/systemd/ci-runner-tmp-clean.service root/systemd/ci-runner-tmp-clean.timer'
if [ "${1-}" = artifacts ]; then FILES="root/ci-artifacts-clean $COMMON"; fi

# Один инвентарь, check_one — тот же sha256-механизм, что у 074.
destination() {
  case "$1" in
    root/systemd/*) printf '%s/%s\n' "$ETC_DST" "${1##*/}" ;;
    *) printf '%s/%s\n' "$SBIN_DST" "${1##*/}" ;;
  esac
}
check_one() {
  [ -f "$1" ] && [ "$(sha256sum "$1" | cut -d' ' -f1)" = "$(sha256sum "$2" | cut -d' ' -f1)" ] \
    || { printf 'ОТКАЗ: расхождение %s\n' "$1" >&2; return 1; }
}
validate_config() {
  CI_CLEAN_CONFIG="$SRC_ROOT/ci-clean.json" CI_CLEAN_SCHEMA="$SRC_ROOT/ci-clean.schema.json" \
    python3 "$SRC_ROOT/root/ci-clean.py" check
}
case "${1-}" in
  ci-clean|artifacts)
    [ "$(id -u)" -eq 0 ] || { printf 'ОТКАЗ: ci-clean требует euid 0\n' >&2; exit 1; }
    for rel in $FILES; do
      [ -f "$SRC_ROOT/$rel" ] || { printf 'ОТКАЗ: нет источника: %s\n' "$SRC_ROOT/$rel" >&2; exit 1; }
    done
    command -v "$CTL" >/dev/null || { printf 'NOT_IMPLEMENTED: нет systemctl\n' >&2; exit 2; }
    validate_config || exit $?
    mkdir -p -- "$SBIN_DST" "$ETC_DST" || exit 1
    for rel in $FILES; do
      dst="$(destination "$rel")"
      mode=644
      case "$rel" in root/ci-artifacts-clean|root/ci-runner-tmp-clean) mode=755 ;; esac
      if ! { cp -- "$SRC_ROOT/$rel" "$dst" && chown root:root -- "$dst"; }; then
        printf 'ОТКАЗ: запись %s\n' "$dst" >&2; exit 1
      fi
      check_one "$dst" "$SRC_ROOT/$rel" || exit 1
    done
    if [ "$1" = ci-clean ]; then
      "$CTL" daemon-reload || { printf 'ОТКАЗ: systemctl daemon-reload\n' >&2; exit 1; }
      "$CTL" enable --now ci-runner-tmp-clean.timer || { printf 'ОТКАЗ: systemctl enable\n' >&2; exit 1; }
    fi
    printf 'установлено: ci-clean\n'
    ;;
  verify)
    present=0
    for rel in $TMP_FILES; do
      [ -e "$(destination "$rel")" ] && present=$((present + 1))
    done
    if [ "$present" -eq 0 ]; then
      printf 'ci-clean: не установлены\n'
      FILES="$COMMON"
      for rel in $COMMON; do
        [ -e "$(destination "$rel")" ] && present=$((present + 1))
      done
      [ "$present" -gt 0 ] || exit 0
    fi
    rc=0
    for rel in $FILES; do
      dst="$(destination "$rel")"
      check_one "$dst" "$SRC_ROOT/$rel" || rc=1
    done
    [ "$rc" -eq 0 ] && printf 'ci-clean: сверка\n'
    exit "$rc"
    ;;
  *) printf 'ОТКАЗ: USAGE\n' >&2; exit 1 ;;
esac
