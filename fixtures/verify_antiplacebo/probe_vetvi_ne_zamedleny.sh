#!/usr/bin/env bash
# НЕ ФИКСТУРА (нет case_-префикса, раннером не гоняется): проба-СТРАЖ И-4
# контракта 017 — «ветви не замедлены» как rc-мера.
#
# Блокер v1: обещание «регресс времени > 2× — красное» не выражалось названной
# командой `bash scripts/check_metering.sh` — она не меряет время. Блокер v2
# (арбитраж verdicts/arbitration/contracts-017-sila-povedencheskih-prob.md,
# a9e14eb): база, поднимавшая прокси судимым proxy_up, САМОСОГЛАСОВАНА с
# предметом — замедление proxy_up растит знаменатель порога в ФАКТОР×N раз
# быстрее числителя и поглощает кратное замедление ветвей. Мера времени, чей
# эталон предоставляет сам измеряемый, — не мера. База теперь НЕЗАВИСИМА:
#
#   база   — медиана трёх ПРЯМЫХ поднятий прокси; в измеряемом пути базы не
#            исполняется НИ СТРОКИ кода зоны implementer: check_metering.sh
#            не исполняется и не sourcing'уется (verify_antiplacebo.sh тоже).
#            Допустимое арбитражем и только оно: node + замороженная площадь
#            scripts/proxy/metering_proxy.ts (РАБОТА НЕ РАЗДАЁТСЯ) +
#            собственный минимальный конфиг пробы + собственное ожидание
#            события <data_dir>/.actual_port и healthz + собственное гашение.
#            Это не мок стека: реальный node, реальный прокси, реальный TCP.
#   порог  = ФАКТОР × M × база. M — НЕЗАВИСИМО ИЗМЕРЕННЫЙ пробой счёт ветвей:
#            пересчёт маркеров исполнения — строк «  ok   <имя ветви>», которые
#            обёртка ветвей барьера печатает ровно по одной на ИСПОЛНЕННУЮ ветвь
#            (внутренние сообщения несут «<метка>: …» и точного равенства не
#            дают), — собственной логикой пробы по полному выводу. Находка И-4
#            вердикта ea091d1: финальная строка заявила «100 ветвей» при
#            исполненных 15 — заявленное умножало порог и поглощало замедление;
#            формуле и сверке верно только измеренное. Заявленное N из финальной
#            строки сверяется с M: «заявленное N ≠ измеренное M» — поимённый
#            красный. ФАКТОР=6 — запас на контеншен и разброс отношения
#            полный/база (замер пачки: честное дерево 38–55 при разрешённых 90;
#            контрпример «sleep 2 в proxy_up + sleep 20 в ветви» — 172);
#            замедления ниже порога терпимы текстом контракта (арбитраж
#            §Границы 4 — цена против флейка меры). Обе меры сняты подряд в одном
#            прогоне и масштабируются вместе. Замер арбитража: независимая база
#            ~318 мс; честное дерево и контрпример расходятся по порогу кратно —
#            знаменатель больше не растёт вместе с числителем.
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
# СУБЪЕКТ замера (полный барьер — зона implementer); база его НЕ использует.
BARRIER="$REPO/scripts/check_metering.sh"
# Замороженная площадь (арбитраж 017): единственный разделяемый файл базы.
PROXY="$REPO/scripts/proxy/metering_proxy.ts"

# Флаг --selftest снимаем ДО всего: парсим только свой аргумент.
SELFTEST=0
[ "${1:-}" = "--selftest" ] && SELFTEST=1
[ "$#" -gt 0 ] && shift

command -v node >/dev/null 2>&1 || { printf 'ОТКАЗ: нет node — базу не поднять\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'ОТКАЗ: нет jq — вывод барьера не разобрать\n' >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { printf 'ОТКАЗ: нет curl — healthz не дёрнуть\n' >&2; exit 2; }
[ -f "$PROXY" ] || { printf 'ОТКАЗ: нет замороженного прокси %s\n' "$PROXY" >&2; exit 2; }

fails=0
ok()  { printf '  ok   %s\n' "$*" >&2; }
bad() { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }

FAKTOR=6
# Правило 16 нормы + А-59 (TMPDIR в субагентах пуст): временное — в ./tmp
# репозитория, без опоры на TMPDIR окружения.
TMP_ROOT="$REPO/tmp"
mkdir -p "$TMP_ROOT" 2>/dev/null || die "каталог $TMP_ROOT не создать — временному некуда лечь"
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

# ── база: медиана трёх ПРЯМЫХ поднятий, БЕЗ кода зоны implementer ─────────────
base_raise() {  # <имя> — node + замороженный прокси + свой конфиг; событие+healthz+гашение
  local d cfg p ap i
  d="$W/$1"
  mkdir -p "$d/data"
  printf 'METERING_TOKEN_probe017time=probe017time\n' > "$d/secrets.env"
  cfg="$d/config.json"
  cat > "$cfg" <<EOF
{
  "port": 0,
  "healthz_window_sec": 5,
  "secrets_env": "${d}/secrets.env",
  "data_dir": "${d}/data",
  "upstream": { "probe017time": "http://127.0.0.1:9" },
  "prices": { "probe017time": { "probe017model": { "per_m_tokens": { "in": 1, "out": 1 } } } },
  "ceilings": { "probe017time": { "usd_per_month": 1000000 } },
  "now_file": null
}
EOF
  node "$PROXY" --config "$cfg" > "$d/proxy.log" 2> "$d/proxy.err" &
  p=$!
  # Собственное ожидание: событие .actual_port от слушателя; потолок — живость.
  ap=""
  for i in $(seq 1 600); do
    [ -s "$d/data/.actual_port" ] && { ap="$(cat "$d/data/.actual_port")"; break; }
    kill -0 "$p" 2>/dev/null || break
    sleep 0.05
  done
  if [ -z "$ap" ] || [ "$ap" = 0 ]; then
    kill "$p" 2>/dev/null; wait "$p" 2>/dev/null
    die "не снять базу: поднятие $1 без события .actual_port (прокси погиб или не репортит) — лог: $d/proxy.err"
  fi
  if ! curl -fsS -o /dev/null -m 1 "http://127.0.0.1:${ap}/healthz" 2>/dev/null; then
    kill "$p" 2>/dev/null; wait "$p" 2>/dev/null
    die "не снять базу: healthz не ответил на событийном порту $ap ($1) — лог: $d/proxy.err"
  fi
  # Собственное гашение: ждать смерти, потом страховочный -9.
  kill "$p" 2>/dev/null
  for i in $(seq 1 40); do
    kill -0 "$p" 2>/dev/null || return 0
    sleep 0.05
  done
  kill -9 "$p" 2>/dev/null
}
for r in 1 2 3; do
  t0="$(now_us)"
  base_raise "base$r" || die "не снять базу: поднятие $r не удалось"
  eval "b$r=$(( ($(now_us) - t0) / 1000 ))"
done
b_ms="$(printf '%s\n%s\n%s\n' "$b1" "$b2" "$b3" | sort -n | sed -n 2p)"

# ── полный барьер (СУБЪЕКТ): время, rc, счёт ветвей из финальной строки ───────
run_full() {  # <cmd...> — заполняет full_rc / full_ms / full_N (заявлено) / full_M (измерено)
  local t0 n m
  t0="$(now_us)"
  "$@" > "$W/full.log" 2>&1
  full_rc=$?
  full_ms=$(( ($(now_us) - t0) / 1000 ))
  n="$(grep 'ветвей пройдены' "$W/full.log" | tail -1 | grep -oE '[0-9]+' | head -1)"
  full_N="$n"
  # Независимый пересчёт исполнения (И-4, ea091d1): ровно одна строка
  # «  ok   <имя ветви>» на исполненную ветвь; уникальные имена — счёт исполнения.
  m="$(grep -E '^  ok +[^: ]+$' "$W/full.log" | sort -u | wc -l | tr -d ' ')"
  full_M="$m"
}

if [ -z "$b_ms" ]; then
  bad "медиана базы пуста (b1=$b1 b2=$b2 b3=$b3) — мера не снялась"
elif [ "$SELFTEST" = 1 ]; then
  # ── демонстрация ловца: честная мера, затем обёртка со sleep ровно в порог ──
  run_full bash "$BARRIER"
  if [ "$full_rc" != 0 ]; then
    bad "selftest: полный барьер не зелёный (rc=$full_rc) — демонстрация ловца невозможна: $(tail -c 160 "$W/full.log" | tr '\n' ' ')"
  elif [ -z "$full_N" ]; then
    bad "selftest: заявленный счёт ветвей не прочитан из финальной строки — мера не снялась"
  elif [ -z "$full_M" ] || [ "$full_M" = 0 ]; then
    bad "selftest: маркеры исполнения ветвей (строки «  ok   <имя>») в выводе не найдены — независимый счёт не снялся"
  elif [ "$full_N" != "$full_M" ]; then
    bad "selftest: заявленное ветвей $full_N ≠ измеренному $full_M — на честном дереве счёты обязаны сходиться"
  else
    porog=$(( FAKTOR * full_M * b_ms ))
    printf 'фактор %d · ветвей %d (измерено = заявлено) · независимая база мс %d (медиана %d/%d/%d) · полный мс %d · порог мс %d\n' \
      "$FAKTOR" "$full_M" "$b_ms" "$b1" "$b2" "$b3" "$full_ms" "$porog" >&2
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
      elif [ "$full_N" != "$full_M" ]; then
        bad "selftest: у обёртки заявленное ветвей $full_N ≠ измеренному $full_M — вывод обёртки обязан быть выводом барьера"
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
    bad "заявленный счёт ветвей не прочитан из финальной строки барьера — мера не снялась"
  elif [ -z "$full_M" ] || [ "$full_M" = 0 ]; then
    bad "маркеры исполнения ветвей (строки «  ok   <имя>») в выводе барьера не найдены — независимый счёт не снялся"
  elif [ "$full_N" != "$full_M" ]; then
    bad "заявленное ветвей $full_N ≠ измеренному $full_M (пересчёт строк «  ok   <имя>» по полному выводу) — счёт из финальной строки не связан с исполнением (И-4, ea091d1)"
  else
    porog=$(( FAKTOR * full_M * b_ms ))
    printf 'фактор %d · ветвей %d (измерено = заявлено) · независимая база мс %d (медиана %d/%d/%d) · полный мс %d · порог мс %d\n' \
      "$FAKTOR" "$full_M" "$b_ms" "$b1" "$b2" "$b3" "$full_ms" "$porog" >&2
    if [ "$full_ms" -gt "$porog" ]; then
      bad "полный барьер ${full_ms} мс > порога ${porog} мс (фактор ${FAKTOR} × ${full_M} ветвей × независимая база ${b_ms} мс) — ветви замедлены кратно базе среды, И-4 нарушен"
    else
      ok "полный барьер ${full_ms} мс внутри порога ${porog} мс (фактор ${FAKTOR} × ${full_M} ветвей × независимая база ${b_ms} мс) — замедления нет"
    fi
  fi
fi

[ "$fails" -eq 0 ] || exit 1
exit 0
