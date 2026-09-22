# Разделяемый драйвер реиспользуемой батареи гигиены парсинга (контракт 041,
# Направление 3). Профиль — fixtures/parsing_hygiene_battery/profiles/<имя>.sh,
# объявляющий 4 функции: battery_delimiter_collision, battery_regex_injection,
# battery_silent_drop, battery_self_application_green. Каждая печатает свою
# диагностику САМА и возвращает 0 (класс закрыт честно) либо 1 (класс пробит).
# lib.sh НЕ содержит знания ни об одном конкретном гарде — параметризация
# ИМЕНЕМ ПРОФИЛЯ (аргумент run_battery.sh), не хардкодом под check_provodka.sh.
BATTERY_TOTAL=0
BATTERY_BAD=0

battery_case() {  # <имя-класса> <имя-функции>
  local name="$1" fn="$2"
  BATTERY_TOTAL=$((BATTERY_TOTAL + 1))
  if "$fn"; then
    printf 'БАТАРЕЯ %s: класс %-24s — закрыт (rc 0)\n' "$PROFILE_NAME" "$name"
  else
    BATTERY_BAD=$((BATTERY_BAD + 1))
    printf 'БАТАРЕЯ %s: класс %-24s — ПРОБИТ (rc 1)\n' "$PROFILE_NAME" "$name"
  fi
}

battery_summary() {
  printf 'БАТАРЕЯ %s: итог %d/%d классов закрыто\n' "$PROFILE_NAME" \
    "$((BATTERY_TOTAL - BATTERY_BAD))" "$BATTERY_TOTAL"
  if [ "$BATTERY_TOTAL" -eq 0 ]; then
    printf 'БАТАРЕЯ %s: пустая выборка — не проверено ничего\n' "$PROFILE_NAME" >&2
    return 1
  fi
  [ "$BATTERY_BAD" -eq 0 ]
}
