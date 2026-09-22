# Профиль батареи для scripts/check_threat_model.sh (041) — DOGFOOD: НОВЫЙ
# гард, введённый ЭТИМ ЖЕ контрактом, проверен ТОЙ ЖЕ реиспользуемой батареей,
# которую его контракт вводит как норму для будущих гардов.
TM_REPO="$(cd "$HERE/../.." && pwd -P)"
TM_SUBJ="$TM_REPO/scripts/check_threat_model.sh"

_tm_write() {  # <файл> <тело-после-заголовка-или-пусто>
  local f="$1" body="$2"
  {
    printf '# toy kontrakt\n\n## Predmet\np\n\n'
    if [ -n "$body" ]; then
      printf '## Модель угроз\n\n%s\n' "$body"
    fi
  } > "$f"
}

battery_delimiter_collision() {
  # Буллет содержит байт `:` ВНУТРИ данных: короткий префикс ДО первого ':'
  # ("мало-совсем", НИЖЕ порога формы сам по себе) + длинное продолжение
  # ПОСЛЕ. Ожидание — ЦЕЛЫЙ буллет проходит порог формы (rc 0, счётчик
  # буллетов подтверждает целостность). Дискриминирует Б1 (verdicts/critic/
  # contracts-041-v1.md): усечение по первому ':' оставило бы только
  # префикс "мало-совсем" — ниже порога — и барьер отказал бы ошибочно.
  local w f out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_tm_dc.XXXXXX")"; f="$w/c.md"
  _tm_write "$f" 'ЗАЩИЩАЕТ:
- мало-совсем: достаточно длинное продолжение которое нельзя терять при разборе

НЕ ЗАЩИЩАЕТ:
- враждебное окружение вызывающего процесса за пределами базового PATH-экспорта'
  out="$(bash "$TM_SUBJ" "$w" "c.md" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq 'ЗАЩИЩАЕТ 1 буллет(ов)'
}

battery_regex_injection() {
  # Буллет содержит ERE-метасимволы буквально — сравнение меток/префикса
  # литеральное, содержимое буллета вообще не участвует в построении
  # паттерна → rc 0, метасимволы не интерпретированы.
  local w f out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_tm_ri.XXXXXX")"; f="$w/c.md"
  _tm_write "$f" 'ЗАЩИЩАЕТ:
- символы . * + ? [ ] ( ) ^ $ | остаются буквами буллета а не regex-командами

НЕ ЗАЩИЩАЕТ:
- смысловую адекватность границы которую судит критик а не механический барьер'
  out="$(bash "$TM_SUBJ" "$w" "c.md" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 0 ]
}

battery_silent_drop() {
  # Список ЗАЩИЩАЕТ: присутствует, но без единого буллета — ожидание:
  # ИМЕНОВАННЫЙ отказ, не тихий проход.
  local w f out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_tm_sd.XXXXXX")"; f="$w/c.md"
  _tm_write "$f" 'ЗАЩИЩАЕТ:

НЕ ЗАЩИЩАЕТ:
- враждебное окружение вызывающего процесса за пределами базового PATH-экспорта'
  out="$(bash "$TM_SUBJ" "$w" "c.md" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq 'модель угроз: список ЗАЩИЩАЕТ: пуст (нет буллета)'
}

battery_self_application_green() {
  # Само-применение: check_threat_model.sh на СОБСТВЕННОМ буквальном тексте
  # контракта 041 — GREEN (это её жеself-application-green экземпляр).
  local out rc contract
  contract="$(cd "$TM_REPO/contracts" && ls 041-*.md 2>/dev/null | head -n1)"
  [ -n "$contract" ] || return 1
  out="$(cd "$TM_REPO" && bash "$TM_SUBJ" "$TM_REPO" "contracts/$contract" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ]
}
