# Профиль батареи для scripts/check_precision_gate.sh (043) — DOGFOOD: НОВЫЙ
# гард, введённый ЭТИМ ЖЕ контрактом, проверен ТОЙ ЖЕ реиспользуемой батареей,
# которую контракт 041 ввёл как норму для будущих гардов.
PG_REPO="$(cd "$HERE/../.." && pwd -P)"
PG_SUBJ="$PG_REPO/scripts/check_precision_gate.sh"
# shellcheck disable=SC1091
. "$PG_REPO/fixtures/check_precision_gate/_toy.sh"

battery_delimiter_collision() {
  # Причина строки ПЕРЕСЕЧЕНИЕ несёт ВНУТРЕННИЕ байты `-` и `:` (ровно те,
  # которыми размечена сама грамматика поля) — обязана дойти до сравнения
  # целиком, не быть усечена по первому совпавшему разделителю.
  local w
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pg_dc.XXXXXX")"
  mk_toy_repo "$w"
  mk_foreign_frozen "$w" 999 otherauthor shared/thing.txt
  put_draft "$w/contracts/043-toy-draft.md" '# k

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md shared/thing.txt

ПЕРЕСЕЧЕНИЕ architect: shared/thing.txt — 999 причина-с-дефисом: и двоеточием — и ещё тире внутри текста не режет поле'
  local out rc
  out="$("$PG_SUBJ" "$w" 'contracts/043-toy-draft.md' 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 0 ]; then
    printf 'delimiter-collision: ожидался rc0 (причина с -/: внутри не режет поле), получен %s: %s\n' "$rc" "$out" >&2
    return 1
  fi
  return 0
}

battery_regex_injection() {
  # Путь foreign-контракта `a.txt`; черновик заявляет ЛИТЕРАЛЬНО ДРУГОЙ путь
  # `axtxt` (не совпадает буквально, совпал бы, будь `.` интерпретирован как
  # regex-метасимвол «любой байт»). Ожидание — NO коллизия, rc 0.
  local w
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pg_ri.XXXXXX")"
  mk_toy_repo "$w"
  mk_foreign_frozen "$w" 999 otherauthor a.txt
  put_draft "$w/contracts/043-toy-draft.md" '# k

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md axtxt'
  local out rc
  out="$("$PG_SUBJ" "$w" 'contracts/043-toy-draft.md' 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 0 ]; then
    printf 'regex-injection: "." ошибочно трактован как regex-метасимвол, rc %s: %s\n' "$rc" "$out" >&2
    return 1
  fi
  return 0
}

battery_silent_drop() {
  # ДВЕ независимые коллизии в одном черновике (разные пути, разные чужие
  # NNN) — ни одна не должна быть молча пропущена: гейт обязан красить (хотя
  # бы первую детерминированную) вместо тихого rc0.
  local w
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pg_sd.XXXXXX")"
  mk_toy_repo "$w"
  mk_foreign_frozen "$w" 991 alice one/first.txt
  mk_foreign_frozen "$w" 992 bob two/second.txt
  put_draft "$w/contracts/043-toy-draft.md" '# k

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md one/first.txt two/second.txt'
  local out rc
  out="$("$PG_SUBJ" "$w" 'contracts/043-toy-draft.md' 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -eq 0 ] || ! printf '%s' "$out" | grep -Fq 'зона-коллизия:'; then
    printf 'silent-drop: коллизия молча пропущена, rc %s: %s\n' "$rc" "$out" >&2
    return 1
  fi
  return 0
}

battery_self_application_green() {
  local out rc contract_rel
  contract_rel="$(cd "$PG_REPO" && printf '%s\n' contracts/043-*.md | head -n1)"
  [ -f "$PG_REPO/$contract_rel" ] || { printf 'self-application: contracts/043-*.md не найден\n' >&2; return 1; }
  out="$("$PG_SUBJ" "$PG_REPO" "$contract_rel" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fxq 'OK'; then
    printf 'self-application: contracts/043 на себе не зелен, rc %s: %s\n' "$rc" "$out" >&2
    return 1
  fi
  return 0
}
