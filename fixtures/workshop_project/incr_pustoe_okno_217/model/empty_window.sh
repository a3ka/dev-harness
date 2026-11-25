# 217: inserted after successful incr_parse and ustav/1 check, before discovery.
# shellcheck shell=bash
if [ "${INCR_MODE:-full}" = "incr" ] && [ "$INCR_BASE" = "$INCR_HEAD" ]; then
  incr_finish 0
  exit 0
fi
