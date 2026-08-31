#!/usr/bin/env bash
# НЕ ФИКСТУРА (нет case_-префикса, раннером не гоняется): проба-СТРАЖ И-4
# контракта 017 — «ветви не замедлены» как rc-мера.
#
# Блокер 3 вердикта v1: обещание «регресс времени > 2× — красное» не выражалось
# названной командой `bash scripts/check_metering.sh` — она не меряет время и
# возвращает 0 при любом sleep в ветвях. Здесь порог — ОТ СОБСТВЕННОЙ БАЗЫ ТОГО
# ЖЕ ПРОГОНА, без замороженного wall-числа (урок 015/016 о счётчиках):
#   база   — медиана трёх поднятий прокси тем же пламбингом, что у ветвей
#            (gen_config → proxy_up → proxy_down);
#   порог  = ФАКТОР × N × база, где N — счёт ветвей из финальной строки полного
#            барьера (число из вывода, не из этого файла), ФАКТОР=4 — запас на
#            контеншен: обе меры сняты подряд в одном прогоне и масштабируются
#            вместе. Спящая ветвь (обход вердикта v1: sleep 20 в ветви при базе
#            ~5.4 с, порог ~21 с) рвёт порог кратно.
# Зелёная на честном дереве СЕЙЧАС; красная при послезаморозочном замедлении
# предмета. Гонять на спокойном дереве (не под taskset): предмет — деградация
# предмета, не флейк-окно среды (дым-окно — Q2).
#
#   bash fixtures/verify_antiplacebo/probe_vetvi_ne_zamedleny.sh
#       приёмка И-4: rc=0 — замедления нет, rc=1 — порог рвануло/мера не снялась.
#   bash fixtures/verify_antiplacebo/probe_vetvi_ne_zamedleny.sh --selftest
#       демонстрация красноты ловца (тауто-принцип: проверка проверки): та же
#       мера против обёртки со sleep ровно в порог — обязана уйти в красное.
#       НЕ приёмка: один прогон, доказывает ловец, не предмет.
#
# Коды возврата: 0 — замедления нет (в selftest: ловец красит), 1 — порог
# рвануло или мера не снялась, 2 — нечем проверить.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
BARRIER="$REPO/scripts/check_metering.sh"

# Флаг --selftest снимаем ДО источника: check_metering.sh парсит ${1:-} и
# откажет на неизвестном режиме.
SELFTEST=0
[ "${1:-}" = "--selftest" ] && SELFTEST=1
[ "$#" -gt 0 ] && shift

export PROBE017_LIB=1
# shellcheck disable=SC1091
. "$BARRIER"
unset PROBE017_LIB

fails=0
ok()  { printf '  ok   %s\n' "$*" >&2; }
bad() { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

FAKTOR=4
W="$(mktemp -d "$TMP_ROOT/probe017time.XXXXXX")"
trap 'rm -rf "$W"' EXIT
export HOME="$W"

now_us() {  # микросекунды эпохи; обе меры — одной шкалы
  if [ -n "${EPOCHREALTIME:-}" ]; then
    printf '%s' "${EPOCHREALTIME/./}"
  else
    echo $(( $(date +%s%N) / 1000 ))
  fi
}

# ── база: медиана трёх поднятий прокси тем же пламбингом, что у ветвей ────────
raise_one() {  # <имя> — полный цикл: конфиг → прокси → гашение
  local c d p
  c="$(gen_config "$W/$1")" || return 1
  d="$(jq -r '.data_dir' "$c")"
  p="$(proxy_up "$c" "$d/proxy.pid" 2>"$W/$1.err")" || return 1
  proxy_down "$p"
}
for r in 1 2 3; do
  t0="$(now_us)"
  raise_one "base$r" || die "не снять базу: поднятие $r не удалось — лог: $W/base$r.err"
  eval "b$r=$(( ($(now_us) - t0) / 1000 ))"
done
b_ms="$(printf '%s\n%s\n%s\n' "$b1" "$b2" "$b3" | sort -n | sed -n 2p)"

# ── полный барьер: время, rc, счёт ветвей из финальной строки ─────────────────
run_full() {  # <cmd...> — заполняет full_rc / full_ms / full_N; лог в $W/full.log
  local t0 n
  t0="$(now_us)"
  "$@" > "$W/full.log" 2>&1
  full_rc=$?
  full_ms=$(( ($(now_us) - t0) / 1000 ))
  n="$(grep 'ветвей пройдены' "$W/full.log" | tail -1 | grep -oE '[0-9]+' | head -1)"
  full_N="$n"
}

if [ -z "$b_ms" ]; then
  bad "медиана базы пуста (b1=$b1 b2=$b2 b3=$b3) — мера не снялась"
elif [ "$SELFTEST" = 1 ]; then
  # ── демонстрация ловца: честная мера, затем обёртка со sleep ровно в порог ──
  run_full bash "$BARRIER"
  if [ "$full_rc" != 0 ]; then
    bad "selftest: полный барьер не зелёный (rc=$full_rc) — демонстрация ловца невозможна: $(tail -c 160 "$W/full.log" | tr '\n' ' ')"
  elif [ -z "$full_N" ]; then
    bad "selftest: счёт ветвей не прочитан из финальной строки — мера не снялась"
  else
    porog=$(( FAKTOR * full_N * b_ms ))
    printf 'фактор %d · ветвей %d (из вывода) · база мс %d (медиана %d/%d/%d) · полный мс %d · порог мс %d\n' \
      "$FAKTOR" "$full_N" "$b_ms" "$b1" "$b2" "$b3" "$full_ms" "$porog" >&2
    if [ "$full_ms" -gt "$porog" ]; then
      bad "selftest: честное дерево уже за порогом (${full_ms} > ${porog} мс) — фактор/база неверны, ловец не доказуем"
    else
      ok "честная мера внутри порога (${full_ms} ≤ ${porog} мс) — подкладываю sleep ровно в порог"
      printf '#!/usr/bin/env bash\nsleep %d\nexec bash "%s" "$@"\n' \
        "$(( porog / 1000 + 1 ))" "$BARRIER" > "$W/wrapper.sh"
      chmod +x "$W/wrapper.sh"
      run_full bash "$W/wrapper.sh"
      if [ "$full_rc" != 0 ]; then
        bad "selftest: обёртка сломала сам барьер (rc=$full_rc) — демонстрация нечиста: $(tail -c 160 "$W/full.log" | tr '\n' ' ')"
      elif [ "$full_ms" -gt "$porog" ]; then
        ok "selftest: обёртка (sleep $(( porog / 1000 + 1 )) с = порог) замерена ${full_ms} мс > порога ${porog} мс — ЛОВЕЦ КРАСИТ замедление"
      else
        bad "selftest: обёртка со sleep в порог замерена ${full_ms} мс ≤ порога ${porog} мс — ЛОВЕЦ СЛЕП к обходу вердикта v1"
      fi
    fi
  fi
else
  # ── приёмка И-4 ─────────────────────────────────────────────────────────────
  run_full bash "$BARRIER"
  if [ "$full_rc" != 0 ]; then
    bad "полный барьер не зелёный (rc=$full_rc) — замер бессмыслен, чинить предмет: $(tail -c 160 "$W/full.log" | tr '\n' ' ')"
  elif [ -z "$full_N" ]; then
    bad "счёт ветвей не прочитан из финальной строки барьера — мера не снялась"
  else
    porog=$(( FAKTOR * full_N * b_ms ))
    printf 'фактор %d · ветвей %d (из вывода) · база мс %d (медиана %d/%d/%d) · полный мс %d · порог мс %d\n' \
      "$FAKTOR" "$full_N" "$b_ms" "$b1" "$b2" "$b3" "$full_ms" "$porog" >&2
    if [ "$full_ms" -gt "$porog" ]; then
      bad "полный барьер ${full_ms} мс > порога ${porog} мс (фактор ${FAKTOR} × ${full_N} ветвей × база ${b_ms} мс) — ветви замедлены кратно своей же базе, И-4 нарушен"
    else
      ok "полный барьер ${full_ms} мс внутри порога ${porog} мс (фактор ${FAKTOR} × ${full_N} ветвей × база ${b_ms} мс) — замедления нет"
    fi
  fi
fi

[ "$fails" -eq 0 ] || exit 1
exit 0
