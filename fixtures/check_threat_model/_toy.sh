# Каркас семьи check_threat_model (контракт 041). В отличие от check_provodka
# (038), этот барьер НЕ трогает git — только текстовый файл контракта; каркас
# не нуждается в git init/commit, только во временном файле.
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_threat_model.sh"

LAST_OUT=''; LAST_RC=0
run_barrier() {  # <корень> <отн-путь>
  LAST_OUT="$(bash "$SUBJ" "$1" "$2" 2>&1)"; LAST_RC=$?
}

put_contract() {  # <файл> <тело>
  printf '%s\n' "$2" > "$1"
}

refuse() {  # <имя-входа> <фраза>
  local gate="$1" phrase="$2"
  [ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 1)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq "$phrase" || { printf 'ОТКАЗ: %s: причина не названа дословно «%s»:\n%s\n' "$gate" "$phrase" "$LAST_OUT" >&2; exit 1; }
  printf '%s: отказ rc 1, причина названа дословно\n' "$gate" >&2
}

accept() {  # <имя-входа>
  local gate="$1"
  [ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 0)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s: rc 0\n' "$gate" >&2
}
