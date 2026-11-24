# 217: inserted after successful incr_parse, before charter discovery.
# shellcheck shell=bash
if [ "${INCR_MODE:-full}" = "incr" ] && [ "$INCR_BASE" = "$INCR_HEAD" ]; then
  incr_finish 0
  exit 0
fi
