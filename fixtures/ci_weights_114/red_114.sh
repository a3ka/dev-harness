#!/usr/bin/env bash
# red_114.sh — батарея контракта 114 «веса lane CI по замерам».
#
# ПРЕДМЕТ БАРЬЕРА: веса step/legkij реестра registry/ci-steps.tsv обязаны быть
# ИЗ ЗАМЕРОВ CI (грамматика «замер: <ключ> <сек>» — 087 И-9, единый источник
# run_ci_lane/ci_vesa), воспроизводимо: мера (median ceil последних ≥N
# наблюдений зелёных прогонов) пишет TSV замеров; гвард сверяет реестр с TSV
# (покрытие / двустороннее расхождение > 3× / свежесть ≤ 30 дней).
#
# СТРУКТУРА (40 клеток — круг 3: +т22/т23/т24, +s12/s13):
#   Д1/Д2 — предмет существует: $RED114_GUARD/$RED114_MEASURE (по умолчанию
#     scripts/check_ci_weights.sh, scripts/measure_ci_weights.sh). До
#     реализации красны ПО УМЫСЛУ («предмет отсутствует»).
#   т1–т18 — инварианты на toy-мирах через ТЕ ЖЕ точки входа:
#     т1 конформный мир зелёный НЕМОЛЧАЛИВО (ok-строка с числом ключей);
#     т2 завышение ×4 красное именованным ключом; т3 занижение ×4 красное
#     (двусторонность); т4 ключ без строки замеров красный; т5a TSV старше
#     30 дней красный; т5b TSV не закоммичен красный; т6 медиана устойчива к
#     выбросу ([10,10,10,200,200] → 10, не max); т7 округление ВВЕРХ
#     (медиана 10.5 → 11); т8 мало данных rc 2 и TSV НЕ написан (атомарно);
#     т9 пустая выборка rc 2; т10 ровно 3× — зелёное (граница включительна,
#     красит «более чем»); т11 приманки середины/хвоста строки замером НЕ
#     являются; т12 TSV вне грамматики — именованный отказ;
#     т13 (круг 2, Б2) миграция --migrate: веса == TSV ТОЧНО — зелёное
#     немолчаливо «веса по замеру (миграция): N ключей»;
#     т14 (Б2) миграция: 2×TSV — красное именованно «вес не по замеру
#     (миграция)» (постоянный допуск 3× миграцию не закрывает);
#     т15 (Б2) миграция: ±1 к медиане — красное именованно;
#     т16 (Б3) миграция --base: реестр с lanes 2→1 против неизменной базы —
#     красное «состав реестра изменился: lanes» (граница «только веса»);
#     т17 (Б1) сетевой режим: источник-двойник gh в PATH — TSV побайтово
#     равен ожиданию, выведенному из данных двойника ВРУЧНУЮ, И след вызова
#     gh непуст (фабрикация TSV из реестра без источника красна);
#     т18 (Б3) мера пишет только TSV: деревья миров модель/кандидат после
#     прогона с default --out тождественны (побочная запись красна).
#     т19 (арбитраж 114, П1) побочные записи меры: СЕТЬ + default --out —
#     близнецы-миры против gh-двойника, вызов БЕЗ --logs и БЕЗ --out;
#     красное именованное «побочная запись меры (сеть, default --out)»;
#     т20 (П2а) СЕТЬ + явный --out ВНЕ root: снимок --root до/после вызова
#     кандидата — неравенство красное «побочная запись меры (сеть, явный
#     --out)»;
#     т21 (П2б) КОРПУС + явный --out ВНЕ root (мир/корпус т18): снимок
#     --root до/после — неравенство красное «побочная запись меры (корпус,
#     явный --out)». Матрица {корпус, сеть}×{default, явный --out} закрыта
#     всеми четырьмя ячейками (т18 — корпус/default).
#     т22 (круг 3, Rev114 Б1/Б2) сетевой ПОРЯДОК: двойник22 — 3 прогона
#       разных времён на ключ, СВЕЖИЕ ПЕРВЫМИ (как реальный API),
#       нетривиальная разница старое/новое, --min-obs 2 < 3 наблюдений:
#       TSV == ручному ожиданию ceil(медиана ВСЕХ наблюдений окна)
#       (frozen :45/:99/:178; min-obs — порог, не размер выборки);
#       обман «медиана хвоста/старейших/первых N» красен;
#     т23 (круг 3, Adv114 №2) сеть БЕЗ gh в PATH (bash+python3+dirname —
#       минимум обёрток меры, gh исключён) —
#       именованный rc 2 «gh api отказ…», не rc 1/traceback; TSV не
#       написан (атомарно);
#     т24 (круг 3, Adv114 №1) корпус 8 (step) / 20 (legkij) наблюдений
#       при min-obs 5: TSV хранит n == числу наблюдений окна, не 5
#       (frozen :348 «n≥8 у step-ключей, n≥20 у legkij»).
#   С1–С13 — обманные стабы stuby/ на каркасе _karkas_staba.py. KARTA
#     (Н-39: привязка по коду, не по прозе контракта):
#       s1 «всегда-зелёный»    — вход лжи: мир т2;  честность: т1;
#       s2 «односторонний»     — вход лжи: мир т3;  честность: т1;
#       s3 «само-оракул»       — вход лжи: мир т2;  честность: т1;
#       s4 «без свежести»      — вход лжи: мир т5a; честность: т1;
#       s5 «максимум»          — вход лжи: корпус т6;  честность: константный;
#       s6 «floor»             — вход лжи: корпус т7;  честность: константный;
#       s7 «мало-данных-зелё»  — вход лжи: корпус т8;  честность: константный;
#       s8 «подстрочник»       — вход лжи: корпус т11; честность: константный;
#       s9 «сеть-без-источника» — вход лжи: мир т17 (след gh пуст, TSV из
#                                реестра); честность: конформный корпус;
#       s10 «писатель»          — вход лжи: мир т18 (деревья миров
#                                различаются); честность: TSV конформного
#                                корпуса (побочная запись есть на каждом
#                                входе — честность вне лжи наблюдаема только
#                                по байтам TSV, класс как у s5/s6).
#       s11 «писатель-по-режиму» — вход лжи: сеть/default-out близнецы (т19);
#                                красны ровно клетки-носители т19/т20/т21,
#                                т18 зелёная; честность: TSV конформного
#                                корпуса (арбитраж 114, П3).
#       s12 «хвост-вместо-медианы» — вход лжи: сеть т22 (двойник22: 3
#                                наблюдения, свежие первыми, min-obs 2 <
#                                наблюдений); честность: конформный корпус;
#       s13 «gh-отсутствует-traceback» — вход лжи: сеть без gh в PATH
#                                (т23, traceback rc 1); честность:
#                                конформный корпус.
#     ПОЙМАН = на входе лжи стаб расходится с честной моделью, на конформном
#     входе совпадает. s5/s6 взаимно грязны на чужих корпусах (max≠медиана и
#     floor≠ceil на любом разбросанном корпусе) — честность вне лжи для них
#     наблюдаема ТОЛЬКО на константном корпусе, оговорка здесь, по классу
#     (прецедент 113: s6/s8).
#
# Модель — model/vesa_lib.py (честная реализация предмета; эталон клеток).
# До реализации Д1/Д2 и т1–т24 красны именованно «нет инструмента» — батарея
# красна на базе ПО УМЫСЛУ; стаб-пак ловится и на базе.
#
# Коды возврата: 0 — все клетки зелёные; 1 — есть красное; 2 — отказ
# инструмента (нет модели/каркаса/скратча).
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
GUARD="${RED114_GUARD:-$REPO/scripts/check_ci_weights.sh}"
MEASURE="${RED114_MEASURE:-$REPO/scripts/measure_ci_weights.sh}"
MODEL_GUARD="$HERE/model/guard_model.sh"
MODEL_MEASURE="$HERE/model/measure_model.sh"

[ -f "$MODEL_GUARD" ]   || { printf 'ОТКАЗ: нет модели гварда\n' >&2; exit 2; }
[ -f "$MODEL_MEASURE" ] || { printf 'ОТКАЗ: нет модели меры\n' >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/vesa114.XXXXXX")" || exit 2
trap 'rm -rf "$WORK"' EXIT

GREEN=0; REDO=0; TOTAL=0
ok()   { TOTAL=$((TOTAL+1)); GREEN=$((GREEN+1)); printf 'ok: %s\n' "$1"; }
kraz() { TOTAL=$((TOTAL+1)); REDO=$((REDO+1)); printf 'КРАСНО: %s\n' "$1" >&2; }

# ── миры ─────────────────────────────────────────────────────────────────────
# конформный: zamery gen 10 / alpha 100 / beta 7; веса равны замерам.
build_world() { # $1 dir $2 w_gen $3 w_alpha $4 w_beta
  rm -rf "$1"; mkdir -p "$1/registry"
  printf 'lanes\t2\nstep\tcheck:gen\t%s\tnpm run check:gen\nstep\tcheck:alpha\t%s\tnpm run check:alpha\nlegkij\tcheck:beta\t%s\tnpm run check:beta\n' \
    "$2" "$3" "$4" > "$1/registry/ci-steps.tsv"
  printf '# toy замеры 114\ncheck:gen\t10\t5\t42\ncheck:alpha\t100\t5\t42\ncheck:beta\t7\t5\t42\n' \
    > "$1/registry/ci-zamery.tsv"
}
mk_git() { # $1 dir $2 возраст_дней
  git -C "$1" init -q
  git -C "$1" add -A
  local d; d="$(date -u -d "$2 days ago" '+%Y-%m-%dT%H:%M:%SZ')" || return 1
  GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" \
    git -C "$1" -c user.name=toy -c user.email=toy@114 -c commit.gpgsign=false \
    -c core.hooksPath=/dev/null commit -qm 'toy: zamery 114'
}
build_logs() { # $1 dir ; файлы пишет вызывающий
  rm -rf "$1"; mkdir -p "$1"
}
wr_line() { # $1 файл $2 строка
  printf '%s\n' "$2" >> "$1"
}

# ── Д-клетки: предмет существует ─────────────────────────────────────────────
if [ -f "$GUARD" ] && bash -n "$GUARD" 2>/dev/null; then
  ok "Д1 гвард существует и синтаксически валиден: $GUARD"
else
  kraz "Д1 гвард отсутствует/вне синтаксиса: $GUARD (предмет отсутствует — красная по умыслу до реализации)"
fi
if [ -f "$MEASURE" ] && bash -n "$MEASURE" 2>/dev/null; then
  ok "Д2 мера существует и синтаксически валидна: $MEASURE"
else
  kraz "Д2 мера отсутствует/вне синтаксиса: $MEASURE (предмет отсутствует — красная по умыслу до реализации)"
fi

# ── т-клетки: инварианты через точки входа $GUARD/$MEASURE ───────────────────
G_OUT="$WORK/g.out"; G_ERR="$WORK/g.err"
run_guard() { # $1 инструмент $2 мир
  "$1" --root "$2" >"$G_OUT" 2>"$G_ERR"; RC=$?
}
guard_absent() { # $1 клетка $2 инструмент
  [ -f "$2" ] || { kraz "$1 нет инструмента: $2 (предмет отсутствует — красная по умыслу)"; return 0; }
  return 1
}

# т1 конформный: rc 0 + ok-строка с числом ключей (немое зелёное — плацебо)
W1="$WORK/w1"; build_world "$W1" 10 100 7; mk_git "$W1" 0
if guard_absent т1 "$GUARD"; then :; else
  run_guard "$GUARD" "$W1"
  if [ "$RC" -eq 0 ] && grep -q 'веса по замеру: 3 ключей' "$G_OUT"; then
    ok "т1 конформный мир: зелёный НЕМОЛЧАЛИВО (rc 0, ok-строка с числом)"
  else
    kraz "т1 конформный мир: rc=$RC, вывод вне грамматики (ожидался rc 0 и ok-строка)"
  fi
fi

# т2 завышение ×4
W2="$WORK/w2"; build_world "$W2" 40 100 7; mk_git "$W2" 0
if guard_absent т2 "$GUARD"; then :; else
  run_guard "$GUARD" "$W2"
  if [ "$RC" -eq 1 ] && grep -q 'check:gen' "$G_ERR"; then
    ok "т2 завышение ×4: красное именованным ключом check:gen"
  else
    kraz "т2 завышение ×4: rc=$RC (ожидался 1 с именем check:gen)"
  fi
fi

# т3 занижение ×4 (двусторонность)
W3="$WORK/w3"; build_world "$W3" 10 25 7; mk_git "$W3" 0
if guard_absent т3 "$GUARD"; then :; else
  run_guard "$GUARD" "$W3"
  if [ "$RC" -eq 1 ] && grep -q 'check:alpha' "$G_ERR"; then
    ok "т3 занижение ×4: красное именованным ключом check:alpha"
  else
    kraz "т3 занижение ×4: rc=$RC (ожидался 1 с именем check:alpha)"
  fi
fi

# т4 ключ без строки замеров
W4="$WORK/w4"; build_world "$W4" 10 100 7; mk_git "$W4" 0
printf '# toy замеры 114\ncheck:gen\t10\t5\t42\ncheck:alpha\t100\t5\t42\n' > "$W4/registry/ci-zamery.tsv"
if guard_absent т4 "$GUARD"; then :; else
  run_guard "$GUARD" "$W4"
  if [ "$RC" -eq 1 ] && grep -q 'нет замера: check:beta' "$G_ERR"; then
    ok "т4 ключ без замера: красное «нет замера: check:beta»"
  else
    kraz "т4 ключ без замера: rc=$RC (ожидался 1 «нет замера: check:beta»)"
  fi
fi

# т5a устаревший TSV (40 дней)
W5A="$WORK/w5a"; build_world "$W5A" 10 100 7; mk_git "$W5A" 40
if guard_absent т5a "$GUARD"; then :; else
  run_guard "$GUARD" "$W5A"
  if [ "$RC" -eq 1 ] && grep -q 'устарел' "$G_ERR"; then
    ok "т5a TSV старше 30 дней: красное «устарел»"
  else
    kraz "т5a TSV старше 30 дней: rc=$RC (ожидался 1 «устарел»)"
  fi
fi

# т5b TSV не закоммичен (мир без git-истории пути)
W5B="$WORK/w5b"; build_world "$W5B" 10 100 7
if guard_absent т5b "$GUARD"; then :; else
  run_guard "$GUARD" "$W5B"
  if [ "$RC" -eq 1 ] && grep -q 'не закоммичен' "$G_ERR"; then
    ok "т5b TSV не закоммичен: красное «не закоммичен»"
  else
    kraz "т5b TSV не закоммичен: rc=$RC (ожидался 1 «не закоммичен»)"
  fi
fi

# т10 ровно 3× — зелёное (красит «более чем»)
W10="$WORK/w10"; build_world "$W10" 30 100 7; mk_git "$W10" 0
if guard_absent т10 "$GUARD"; then :; else
  run_guard "$GUARD" "$W10"
  if [ "$RC" -eq 0 ]; then ok "т10 ровно 3×: зелёное (граница включительна)"
  else kraz "т10 ровно 3×: rc=$RC (ожидался 0)"; fi
fi

# т12 TSV вне грамматики
W12="$WORK/w12"; build_world "$W12" 10 100 7; mk_git "$W12" 0
printf '# toy\nмусор без табов\n' > "$W12/registry/ci-zamery.tsv"
if guard_absent т12 "$GUARD"; then :; else
  run_guard "$GUARD" "$W12"
  if [ "$RC" -eq 1 ] && grep -q 'вне грамматики' "$G_ERR"; then
    ok "т12 TSV вне грамматики: именованный отказ"
  else
    kraz "т12 TSV вне грамматики: rc=$RC (ожидался 1 «вне грамматики»)"
  fi
fi

# ── т-клетки миграции (круг 2: Б2/Б3) ────────────────────────────────────────
run_migrate() { # $1 инструмент $2 мир $3 база (пусто = без --base)
  if [ -n "$3" ]; then
    "$1" --root "$2" --migrate --base "$3" >"$G_OUT" 2>"$G_ERR"; RC=$?
  else
    "$1" --root "$2" --migrate >"$G_OUT" 2>"$G_ERR"; RC=$?
  fi
}

# т13 миграция: точное равенство весов столбцу TSV — зелёное немолчаливо
W13="$WORK/w13"; build_world "$W13" 10 100 7; mk_git "$W13" 0
if guard_absent т13 "$GUARD"; then :; else
  run_migrate "$GUARD" "$W13" ""
  if [ "$RC" -eq 0 ] && grep -q 'веса по замеру (миграция): 3 ключей' "$G_OUT"; then
    ok "т13 миграция: веса == TSV точно — зелёное немолчаливо"
  else
    kraz "т13 миграция: rc=$RC (ожидался 0 и ok-строка миграции)"
  fi
fi

# т14 миграция: 2×TSV — красное (Б2: 2× проходило постоянный допуск 3×)
W14="$WORK/w14"; build_world "$W14" 20 100 7; mk_git "$W14" 0
if guard_absent т14 "$GUARD"; then :; else
  run_migrate "$GUARD" "$W14" ""
  if [ "$RC" -eq 1 ] && grep -Fq 'вес не по замеру (миграция): check:gen (реестр 20, замер 10)' "$G_ERR"; then
    ok "т14 миграция 2×TSV: красное именованно с обоими числами"
  else
    kraz "т14 миграция 2×TSV: rc=$RC (ожидался 1 «вес не по замеру (миграция): check:gen (реестр 20, замер 10)»)"
  fi
fi

# т15 миграция: ±1 к медиане — красное (Б2: дрейф-допуск миграцию не закрывает)
W15="$WORK/w15"; build_world "$W15" 11 100 7; mk_git "$W15" 0
if guard_absent т15 "$GUARD"; then :; else
  run_migrate "$GUARD" "$W15" ""
  if [ "$RC" -eq 1 ] && grep -Fq 'check:gen (реестр 11, замер 10)' "$G_ERR"; then
    ok "т15 миграция ±1: красное именованно"
  else
    kraz "т15 миграция ±1: rc=$RC (ожидался 1 с «check:gen (реестр 11, замер 10)»)"
  fi
fi

# т16 миграция: границы дельты — lanes 2→1 против неизменной базы (Б3)
W16="$WORK/w16"; build_world "$W16" 10 100 7; mk_git "$W16" 0
cp "$W16/registry/ci-steps.tsv" "$WORK/base16.tsv"
sed -i '1s/^lanes\t2$/lanes\t1/' "$W16/registry/ci-steps.tsv"
if guard_absent т16 "$GUARD"; then :; else
  run_migrate "$GUARD" "$W16" "$WORK/base16.tsv"
  if [ "$RC" -eq 1 ] && grep -Fq 'состав реестра изменился: lanes' "$G_ERR"; then
    ok "т16 границы миграции: lanes 2→1 — красное «состав реестра изменился: lanes»"
  else
    kraz "т16 границы миграции: rc=$RC (ожидался 1 «состав реестра изменился: lanes»)"
  fi
fi

# ── т-клетки меры ────────────────────────────────────────────────────────────
M_OUT="$WORK/tsv"; M_ERR="$WORK/m.err"
run_measure() { # $1 инструмент $2 мир $3 логи $4 min-obs → RC; TSV в $M_OUT
  rm -f "$M_OUT"
  "$1" --root "$2" --logs "$3" --out "$M_OUT" --min-obs "$4" --okno 42 >"$WORK/m.stdout" 2>"$M_ERR"
  RC=$?
}
tsv_has() { # $1 ключ $2 вес $3 n → строка ровно такая
  printf '%s\t%s\t%s\t42\n' "$1" "$2" "$3" > "$WORK/row"
  grep -Fxq -f "$WORK/row" "$M_OUT"
}

# т6 медиана устойчива к выбросу
W6="$WORK/w6"; build_world "$W6" 10 100 7
L6="$WORK/l6"; build_logs "$L6"
i=1; for v in 10 10 10 200 200; do
  printf 'замер: check:gen %s\nзамер: check:alpha 7\nзамер: check:beta 3\n' "$v" >> "$L6/0$i.log"; i=$((i+1))
done
if guard_absent т6 "$MEASURE"; then :; else
  run_measure "$MEASURE" "$W6" "$L6" 5
  if [ "$RC" -eq 0 ] && tsv_has check:gen 10 5; then ok "т6 медиана [10,10,10,200,200] → 10 (не max)"
  else kraz "т6 медиана: rc=$RC, TSV=$(cat "$M_OUT" 2>/dev/null | tr '\n' '|') (ожидался вес gen 10)"; fi
fi

# т7 округление вверх
W7="$WORK/w7"; build_world "$W7" 10 100 7
L7="$WORK/l7"; build_logs "$L7"
i=1; for v in 10 11 10 12; do
  printf 'замер: check:gen %s\nзамер: check:alpha 4\nзамер: check:beta 2\n' "$v" >> "$L7/0$i.log"; i=$((i+1))
done
if guard_absent т7 "$MEASURE"; then :; else
  run_measure "$MEASURE" "$W7" "$L7" 4
  if [ "$RC" -eq 0 ] && tsv_has check:gen 11 4; then ok "т7 медиана 10.5 → ceil 11"
  else kraz "т7 ceil: rc=$RC, TSV=$(cat "$M_OUT" 2>/dev/null | tr '\n' '|') (ожидался вес gen 11)"; fi
fi

# т8 мало данных: rc 2, TSV не написан
W8="$WORK/w8"; build_world "$W8" 10 100 7
L8="$WORK/l8"; build_logs "$L8"
i=1; while [ "$i" -le 5 ]; do
  { printf 'замер: check:gen 6\nзамер: check:beta 5\n'; [ "$i" -le 4 ] && printf 'замер: check:alpha 8\n'; } >> "$L8/0$i.log"; i=$((i+1))
done
if guard_absent т8 "$MEASURE"; then :; else
  run_measure "$MEASURE" "$W8" "$L8" 5
  if [ "$RC" -eq 2 ] && grep -q 'мало данных' "$M_ERR" && [ ! -f "$M_OUT" ]; then
    ok "т8 мало данных (alpha 4<5): rc 2, TSV НЕ написан (атомарный отказ)"
  else
    kraz "т8 мало данных: rc=$RC, TSV есть=$([ -f "$M_OUT" ] && echo да || echo нет) (ожидался rc 2 и нет TSV)"
  fi
fi

# т9 пустая выборка
W9="$WORK/w9"; build_world "$W9" 10 100 7
L9="$WORK/l9"; build_logs "$L9"
printf 'какой-то шаг прошёл\nи ещё вывод\n' >> "$L9/01.log"; printf 'без замеров\n' >> "$L9/02.log"
if guard_absent т9 "$MEASURE"; then :; else
  run_measure "$MEASURE" "$W9" "$L9" 5
  if [ "$RC" -eq 2 ] && grep -q 'пустая выборка' "$M_ERR"; then
    ok "т9 пустая выборка: rc 2 «пустая выборка»"
  else
    kraz "т9 пустая выборка: rc=$RC (ожидался rc 2)"
  fi
fi

# т11 приманки не являются замерами
W11="$WORK/w11"; build_world "$W11" 10 100 7
L11="$WORK/l11"; build_logs "$L11"
i=1; while [ "$i" -le 10 ]; do
  { printf 'замер: check:alpha 9\nзамер: check:beta 1\n'
    if [ "$i" -le 5 ]; then printf 'замер: check:gen 5\n'
    else printf 'info позже замер: check:gen 999\n'; fi
    [ "$i" -eq 10 ] && printf 'замер: check:gen 999 хвост\n'
  } >> "$L11/0$i.log"; i=$((i+1))
done
if guard_absent т11 "$MEASURE"; then :; else
  run_measure "$MEASURE" "$W11" "$L11" 5
  if [ "$RC" -eq 0 ] && tsv_has check:gen 5 5; then
    ok "т11 приманки середины/хвоста строки замером НЕ являются (gen 5, не 999)"
  else
    kraz "т11 приманки: rc=$RC, TSV=$(cat "$M_OUT" 2>/dev/null | tr '\n' '|') (ожидался вес gen 5)"
  fi
fi

# т17 (круг 2, Б1) сетевой режим: gh-двойник в PATH — TSV из его данных +
# след вызова; TSV из реестра без источника и пустой след красны
W17="$WORK/w17"; build_world "$W17" 40 100 8
GHDBL="$HERE/gh_dvoynik"; GHTRACE="$WORK/gh.trace"
if guard_absent т17 "$MEASURE"; then :; elif [ ! -x "$GHDBL/gh" ]; then
  kraz "т17 нет gh-двойника: $GHDBL/gh (инструмент батареи отсутствует)"
else
  rm -f "$GHTRACE" "$M_OUT"
  RED114_GH_TRACE="$GHTRACE" PATH="$GHDBL:$PATH" \
    "$MEASURE" --root "$W17" --out "$M_OUT" --min-obs 2 --repo toy/ci \
    >"$WORK/n17.out" 2>"$M_ERR"; RC17=$?
  # ожидание выведено ВРУЧНУЮ из данных двойника (не моделью):
  # прогоны 402/401, ген [20,10]→15, альфа [30,30]→30, бета [7,7]→7, окно 401
  printf 'check:gen\t15\t2\t401\ncheck:alpha\t30\t2\t401\ncheck:beta\t7\t2\t401\n' > "$WORK/want17"
  if [ "$RC17" -ne 0 ]; then
    kraz "т17 сетевой режим: rc=$RC17 (ожидался 0 против двойника)"
  elif ! [ -s "$GHTRACE" ]; then
    kraz "т17 сетевой режим: источник не вызван — след gh пуст (TSV из ниоткуда)"
  elif ! diff -q <(grep -vE '^#|^$' "$M_OUT" | LC_ALL=C sort) <(LC_ALL=C sort "$WORK/want17") >/dev/null; then
    kraz "т17 сетевой режим: TSV ≠ ожиданию из данных двойника"
  else
    ok "т17 сетевой режим: TSV из источника-двойника, gh вызван (след непуст)"
  fi
fi

# т18 (круг 2, Б3) мера пишет только TSV: деревья миров модель/кандидат
# после прогона с default --out (registry/ci-zamery.tsv) тождественны
W18M="$WORK/w18m"; W18C="$WORK/w18c"
build_world "$W18M" 10 100 7; build_world "$W18C" 10 100 7
L18="$WORK/l18"; build_logs "$L18"
i=1; while [ "$i" -le 5 ]; do
  printf 'замер: check:gen 10\nзамер: check:alpha 7\nзамер: check:beta 3\n' >> "$L18/0$i.log"; i=$((i+1))
done
tree_snap() { (cd "$1" && find . -type f -print | LC_ALL=C sort | xargs sha256sum); }
if guard_absent т18 "$MEASURE"; then :; else
  "$MODEL_MEASURE" --root "$W18M" --logs "$L18" --min-obs 5 --okno 42 >/dev/null 2>&1; M18=$?
  "$MEASURE" --root "$W18C" --logs "$L18" --min-obs 5 --okno 42 >/dev/null 2>&1; C18=$?
  if [ "$M18" -eq 0 ] && [ "$C18" -eq 0 ] && [ "$(tree_snap "$W18M")" = "$(tree_snap "$W18C")" ]; then
    ok "т18 мера пишет только TSV: деревья миров тождественны"
  else
    kraz "т18 побочная запись меры: rc модель/кандидат $M18/$C18, деревья миров различаются"
  fi
fi

# т19 (арбитраж 114, П1) побочные записи меры: СЕТЬ + default --out —
# близнецы-миры, gh-двойник первым в PATH, вызов БЕЗ --logs и БЕЗ --out
W19M="$WORK/w19m"; W19C="$WORK/w19c"
build_world "$W19M" 40 100 8; build_world "$W19C" 40 100 8
if guard_absent т19 "$MEASURE"; then :; elif [ ! -x "$GHDBL/gh" ]; then
  kraz "т19 нет gh-двойника: $GHDBL/gh (инструмент батареи отсутствует)"
else
  rm -f "$WORK/gh19m.trace" "$WORK/gh19c.trace"
  RED114_GH_TRACE="$WORK/gh19m.trace" PATH="$GHDBL:$PATH" \
    "$MODEL_MEASURE" --root "$W19M" --min-obs 2 --repo toy/ci >/dev/null 2>&1; M19=$?
  RED114_GH_TRACE="$WORK/gh19c.trace" PATH="$GHDBL:$PATH" \
    "$MEASURE" --root "$W19C" --min-obs 2 --repo toy/ci >/dev/null 2>&1; C19=$?
  if [ "$M19" -eq 0 ] && [ "$C19" -eq 0 ] && [ "$(tree_snap "$W19M")" = "$(tree_snap "$W19C")" ]; then
    ok "т19 побочные записи (сеть, default --out): деревья миров тождественны"
  else
    if [ "$(tree_snap "$W19M")" = "$(tree_snap "$W19C")" ]; then same19=тождественны; else same19=различаются; fi
    kraz "т19 побочная запись меры (сеть, default --out): rc модель/кандидат $M19/$C19, деревья миров $same19"
  fi
fi

# т20 (арбитраж 114, П2а) побочные записи меры: СЕТЬ + ЯВНЫЙ --out вне root —
# снимок --root кандидата до/после вызова (out вне root — равенство ПОЛНОЕ)
W20="$WORK/w20"; build_world "$W20" 40 100 8
if guard_absent т20 "$MEASURE"; then :; elif [ ! -x "$GHDBL/gh" ]; then
  kraz "т20 нет gh-двойника: $GHDBL/gh (инструмент батареи отсутствует)"
else
  snap20_do="$(tree_snap "$W20")"
  rm -f "$WORK/gh20.trace" "$WORK/tsv20"
  RED114_GH_TRACE="$WORK/gh20.trace" PATH="$GHDBL:$PATH" \
    "$MEASURE" --root "$W20" --out "$WORK/tsv20" --min-obs 2 --repo toy/ci >/dev/null 2>&1; C20=$?
  if [ "$C20" -eq 0 ] && [ "$snap20_do" = "$(tree_snap "$W20")" ]; then
    ok "т20 побочные записи (сеть, явный --out вне root): снимок --root неизменен"
  else
    if [ "$snap20_do" = "$(tree_snap "$W20")" ]; then izm20=не_изменилось; else izm20=изменилось; fi
    kraz "т20 побочная запись меры (сеть, явный --out): rc=$C20, дерево --root $izm20"
  fi
fi

# т21 (арбитраж 114, П2б) побочные записи меры: КОРПУС + ЯВНЫЙ --out вне root —
# тот же мир/корпус, что т18, но --out задан явно; снимок до/после (ПОЛНОЕ равенство)
W21="$WORK/w21"; build_world "$W21" 10 100 7
if guard_absent т21 "$MEASURE"; then :; else
  snap21_do="$(tree_snap "$W21")"
  "$MEASURE" --root "$W21" --logs "$L18" --out "$WORK/tsv21" --min-obs 5 --okno 42 >/dev/null 2>&1; C21=$?
  if [ "$C21" -eq 0 ] && [ "$snap21_do" = "$(tree_snap "$W21")" ]; then
    ok "т21 побочные записи (корпус, явный --out вне root): снимок --root неизменен"
  else
    if [ "$snap21_do" = "$(tree_snap "$W21")" ]; then izm21=не_изменилось; else izm21=изменилось; fi
    kraz "т21 побочная запись меры (корпус, явный --out): rc=$C21, дерево --root $izm21"
  fi
fi

# т22 (круг 3, Rev114 Б1/Б2) сетевой ПОРЯДОК: gh-двойник22 — 3 прогона
# разных времён на ключ, СВЕЖИЕ ПЕРВЫМИ, нетривиальная разница старое/новое,
# --min-obs 2 < 3 наблюдений: TSV == ручному ожиданию ceil(медиана ВСЕХ
# наблюдений окна) (frozen :45/:99/:178; Rev114 В1: min-obs — порог «мало
# данных», не размер выборки). Обман «медиана хвоста/старейших/первых N»
# обязан разойтись с ожиданием — красен.
W22="$WORK/w22"; build_world "$W22" 40 100 8
GHDBL22="$HERE/gh_dvoynik22"; GHTRACE22="$WORK/gh22.trace"
# ожидание выведено ВРУЧНУЮ из данных двойника22 (не моделью): прогоны
# 503/502/501 (свежие первыми); gen [30,20,10]→20, alpha [60,50,40]→50,
# beta [12,9,6]→9 — медиана ВСЕХ трёх, n=3, окно = min(run-id) = 501.
# Ложь хвоста o[-2:]=[20,10]→15, «первых N» o[:2]=[30,20]→25 — обе красны.
printf 'check:gen\t20\t3\t501\ncheck:alpha\t50\t3\t501\ncheck:beta\t9\t3\t501\n' > "$WORK/want22"
if guard_absent т22 "$MEASURE"; then :; elif [ ! -x "$GHDBL22/gh" ]; then
  kraz "т22 нет gh-двойника22: $GHDBL22/gh (инструмент батареи отсутствует)"
else
  rm -f "$GHTRACE22" "$M_OUT"
  RED114_GH_TRACE="$GHTRACE22" PATH="$GHDBL22:$PATH" \
    "$MEASURE" --root "$W22" --out "$M_OUT" --min-obs 2 --repo toy/ci \
    >"$WORK/n22.out" 2>"$M_ERR"; RC22=$?
  if [ "$RC22" -ne 0 ]; then
    kraz "т22 сетевой порядок: rc=$RC22 (ожидался 0 против двойника22)"
  elif ! [ -s "$GHTRACE22" ]; then
    kraz "т22 сетевой порядок: источник не вызван — след gh пуст"
  elif ! diff -q <(grep -vE '^#|^$' "$M_OUT" | LC_ALL=C sort) <(LC_ALL=C sort "$WORK/want22") >/dev/null; then
    kraz "т22 сетевой порядок: TSV ≠ ceil(медиана ВСЕХ наблюдений окна) — обман хвоста/старейших/первых N"
  else
    ok "т22 сетевой порядок: TSV = ceil(медиана ВСЕХ 3 наблюдений) при min-obs 2"
  fi
fi

# т23 (круг 3, Adv114 №2) сетевой режим БЕЗ gh в PATH (bash+python3+dirname):
# именованный rc 2 «gh api отказ…» (отказ транспорта), не rc 1/traceback;
# TSV не написан (атомарно).
W23="$WORK/w23"; build_world "$W23" 40 100 8
NOGH="$WORK/nogh23"; rm -rf "$NOGH"; mkdir -p "$NOGH"
ln -s "$(command -v bash)" "$NOGH/bash"
ln -s "$(command -v python3)" "$NOGH/python3"
ln -s "$(command -v dirname)" "$NOGH/dirname"
if guard_absent т23 "$MEASURE"; then :; else
  rm -f "$M_OUT"
  PATH="$NOGH" "$MEASURE" --root "$W23" --out "$M_OUT" --min-obs 2 --repo toy/ci \
    >"$WORK/n23.out" 2>"$M_ERR"; RC23=$?
  if [ "$RC23" -eq 2 ] && grep -q 'gh api отказ' "$M_ERR" && [ ! -f "$M_OUT" ]; then
    ok "т23 нет gh в PATH: именованный rc 2 «gh api отказ», TSV не написан"
  else
    kraz "т23 нет gh в PATH: rc=$RC23, Traceback-строк=$(grep -c Traceback "$M_ERR") (ожидался rc 2 «gh api отказ» и нет TSV)"
  fi
fi

# т24 (круг 3, Adv114 №1) живой-контракт n: корпус 8 наблюдений у step /
# 20 у legkij при min-obs 5 — TSV хранит n == числу наблюдений окна
# (frozen :348 «n≥8 у step-ключей, n≥20 у legkij»); n=5 у всех ключей —
# стёртая выборка, красна.
W24="$WORK/w24"; build_world "$W24" 10 100 7
L24="$WORK/l24"; build_logs "$L24"
i=1; while [ "$i" -le 20 ]; do
  { [ "$i" -le 8 ] && printf 'замер: check:gen 10\nзамер: check:alpha 7\n'
    printf 'замер: check:beta 3\n'; } >> "$L24/0$i.log"; i=$((i+1))
done
if guard_absent т24 "$MEASURE"; then :; else
  run_measure "$MEASURE" "$W24" "$L24" 5
  if [ "$RC" -eq 0 ] && tsv_has check:gen 10 8 && tsv_has check:alpha 7 8 && tsv_has check:beta 3 20; then
    ok "т24 n = числу наблюдений окна: gen/alpha 8, beta 20 (не min-obs 5)"
  else
    kraz "т24 n окна: rc=$RC, TSV=$(cat "$M_OUT" 2>/dev/null | tr '\n' '|') (ожидались n 8/8/20)"
  fi
fi

# ── С-клетки: KARTA стабов (привязка по коду, Н-39) ──────────────────────────
# конформный корпус меры (константный): все стабы обязаны совпасть с моделью
WC="$WORK/wc"; build_world "$WC" 10 100 7
LC="$WORK/lc"; build_logs "$LC"
i=1; while [ "$i" -le 5 ]; do
  printf 'замер: check:gen 10\nзамер: check:alpha 7\nзамер: check:beta 3\n' >> "$LC/0$i.log"; i=$((i+1))
done
stab_guard() { # $1 имя $2 стаб $3 мир лжи $4 клетка-ожидание
  local src srcrc mdl mdlrc conf
  "$2" --root "$3" >/dev/null 2>&1; src=$?
  "$MODEL_GUARD" --root "$3" >/dev/null 2>&1; mdl=$?
  "$2" --root "$W1" >/dev/null 2>&1; conf=$?
  if [ "$mdl" -ne 0 ] && [ "$src" -eq 0 ] && [ "$conf" -eq 0 ]; then
    ok "С:$1 ПОЙМАН на $4 (стаб rc 0 против модели rc $mdl), честен на т1"
  else
    kraz "С:$1 ускользнул: вход лжи стаб rc=$src (модель rc=$mdl), конформ rc=$conf"
  fi
}
stab_measure() { # $1 имя $2 стаб $3 логи лжи $4 min-obs $5 ключ $6 ожидаемая строка-различие: 0=rc/наличие, 1=значение $7 вес модели
  local srcrc mdlrc stub_tsv model_tsv conf_ok
  rm -f "$WORK/s.tsv" "$WORK/m2.tsv"
  "$2" --root "$WC" --logs "$LC" --out "$WORK/s.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1; srcrc=$?
  "$MODEL_MEASURE" --root "$WC" --logs "$LC" --out "$WORK/m2.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  if cmp -s "$WORK/s.tsv" "$WORK/m2.tsv"; then conf_ok=1; else conf_ok=0; fi
  rm -f "$WORK/s.tsv" "$WORK/m2.tsv"
  "$2" --root "$WC" --logs "$3" --out "$WORK/s.tsv" --min-obs "$4" --okno 42 >/dev/null 2>&1; srcrc=$?
  "$MODEL_MEASURE" --root "$WC" --logs "$3" --out "$WORK/m2.tsv" --min-obs "$4" --okno 42 >/dev/null 2>&1; mdlrc=$?
  local caught=0
  if [ "$6" = 0 ]; then
    # различие по rc/наличию TSV (мало данных)
    if { [ "$mdlrc" -eq 2 ] && [ ! -f "$WORK/m2.tsv" ]; } && { [ "$srcrc" -eq 0 ] && [ -f "$WORK/s.tsv" ]; }; then caught=1; fi
  else
    # различие по значению веса: СТРУКТУРНАЯ сверка (правило 8): ожидаемая
    # строка целиком `<ключ>\t<вес>\t<min-obs>\t42` — grep -Fxq по файлу
    # паттерна; стаб пойман, если модель строку имеет, а стаб — нет
    # (подстрочный матч любой строки ключа ловил бы пустоту).
    printf '%s\t%s\t%s\t42\n' "$5" "$7" "$4" > "$WORK/want_row"
    if grep -Fxq -f "$WORK/want_row" "$WORK/m2.tsv"; then
      if ! grep -Fxq -f "$WORK/want_row" "$WORK/s.tsv" 2>/dev/null; then caught=1; fi
    else
      caught=2
    fi
  fi
  if [ "$caught" -eq 1 ] && [ "$conf_ok" -eq 1 ]; then
    ok "С:$1 ПОЙМАН (значение/rc на входе лжи), совпал с моделью на конформном"
  elif [ "$caught" -eq 2 ]; then
    kraz "С:$1 КАРКАС КЛЕТКИ ВЕРЕН? модель дала не ожидаемое значение на входе лжи"
  else
    kraz "С:$1 ускользнул: caught=$caught conf_ok=$conf_ok"
  fi
}

stab_guard s1 "$HERE/stuby/s1_vsegda_zelenyj.sh"     "$W2"  'т2 (завышение)'
stab_guard s2 "$HERE/stuby/s2_odnostoronnij.sh"      "$W3"  'т3 (занижение)'
stab_guard s3 "$HERE/stuby/s3_samo_orakul.sh"        "$W2"  'т2 (источник замера)'
stab_guard s4 "$HERE/stuby/s4_bez_svezhosti.sh"      "$W5A" 'т5a (свежесть)'
stab_measure s5 "$HERE/stuby/s5_max_vmesto_mediany.sh"   "$L6"  5 check:gen 1 10
stab_measure s6 "$HERE/stuby/s6_floor_vmesto_ceil.sh"    "$L7"  4 check:gen 1 11
stab_measure s7 "$HERE/stuby/s7_zelenyj_na_malo_dannyh.sh" "$L8" 5 check:alpha 0 ''
stab_measure s8 "$HERE/stuby/s8_podstrochnik.sh"     "$L11" 5 check:gen 1 5

stab_net() { # $1 имя $2 стаб — сеть-без-источника (Б1): вход лжи мир т17,
  #            честность — конформный корпус (совпадение TSV с моделью)
  local conf_ok=0 caught=0 T
  rm -f "$WORK/sn.tsv" "$WORK/mn.tsv"
  "$2" --root "$WC" --logs "$LC" --out "$WORK/sn.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  "$MODEL_MEASURE" --root "$WC" --logs "$LC" --out "$WORK/mn.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  cmp -s "$WORK/sn.tsv" "$WORK/mn.tsv" && conf_ok=1
  T="$WORK/sn.trace"; rm -f "$T" "$WORK/snet.tsv"
  RED114_GH_TRACE="$T" PATH="$HERE/gh_dvoynik:$PATH" \
    "$2" --root "$W17" --out "$WORK/snet.tsv" --min-obs 2 --repo toy/ci >/dev/null 2>&1
  if [ ! -s "$T" ]; then caught=1; fi
  if diff -q <(grep -vE '^#|^$' "$WORK/snet.tsv" 2>/dev/null | LC_ALL=C sort) <(LC_ALL=C sort "$WORK/want17") >/dev/null 2>&1; then :; else caught=1; fi
  if [ "$caught" -eq 1 ] && [ "$conf_ok" -eq 1 ]; then
    ok "С:$1 ПОЙМАН (сеть: источник не вызван/TSV из реестра), честен на конформном корпусе"
  else
    kraz "С:$1 ускользнул: caught=$caught conf_ok=$conf_ok"
  fi
}

stab_tree() { # $1 имя $2 стаб — мера-писатель (Б3): вход лжи мир т18 на
  #            копиях (деревья различаются), честность — TSV конформного корпуса
  local conf_ok=0 caught=0 A B
  rm -f "$WORK/st.tsv" "$WORK/mt.tsv"
  "$2" --root "$WC" --logs "$LC" --out "$WORK/st.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  "$MODEL_MEASURE" --root "$WC" --logs "$LC" --out "$WORK/mt.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  cmp -s "$WORK/st.tsv" "$WORK/mt.tsv" && conf_ok=1
  A="$WORK/sta"; B="$WORK/stb"; build_world "$A" 10 100 7; build_world "$B" 10 100 7
  "$MODEL_MEASURE" --root "$A" --logs "$L18" --min-obs 5 --okno 42 >/dev/null 2>&1
  "$2" --root "$B" --logs "$L18" --min-obs 5 --okno 42 >/dev/null 2>&1
  if [ "$(tree_snap "$A")" = "$(tree_snap "$B")" ]; then :; else caught=1; fi
  if [ "$caught" -eq 1 ] && [ "$conf_ok" -eq 1 ]; then
    ok "С:$1 ПОЙМАН (побочная запись реестра мира), TSV честен на конформном корпусе"
  else
    kraz "С:$1 ускользнул: caught=$caught conf_ok=$conf_ok"
  fi
}

stab_net  s9  "$HERE/stuby/s9_set_bez_istochnika.sh"
stab_tree s10 "$HERE/stuby/s10_mera_pisatel.sh"

stab_modewriter() { # $1 имя $2 стаб — писатель-по-режиму (арбитраж 114, П3):
  # вход лжи — близнецы-мир сети/default-out (клетка т19): побочный файл в
  # мире стаба; честность — TSV конформного корпуса (побайтово равен модели)
  local conf_ok=0 caught=0 A B
  rm -f "$WORK/sw.tsv" "$WORK/wm.tsv"
  "$2" --root "$WC" --logs "$LC" --out "$WORK/sw.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  "$MODEL_MEASURE" --root "$WC" --logs "$LC" --out "$WORK/wm.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  cmp -s "$WORK/sw.tsv" "$WORK/wm.tsv" && conf_ok=1
  A="$WORK/sw19a"; B="$WORK/sw19b"; build_world "$A" 40 100 8; build_world "$B" 40 100 8
  rm -f "$WORK/sw19m.trace" "$WORK/sw19s.trace"
  RED114_GH_TRACE="$WORK/sw19m.trace" PATH="$HERE/gh_dvoynik:$PATH" \
    "$MODEL_MEASURE" --root "$A" --min-obs 2 --repo toy/ci >/dev/null 2>&1
  RED114_GH_TRACE="$WORK/sw19s.trace" PATH="$HERE/gh_dvoynik:$PATH" \
    "$2" --root "$B" --min-obs 2 --repo toy/ci >/dev/null 2>&1
  [ "$(tree_snap "$A")" = "$(tree_snap "$B")" ] || caught=1
  if [ "$caught" -eq 1 ] && [ "$conf_ok" -eq 1 ]; then
    ok "С:$1 ПОЙМАН (сеть/default-out: побочный файл в мире стаба), TSV честен на конформном корпусе"
  else
    kraz "С:$1 ускользнул: caught=$caught conf_ok=$conf_ok"
  fi
}

stab_modewriter s11 "$HERE/stuby/s11_pisatel_po_rezhimu.sh"

stab_net_order() { # $1 имя $2 стаб — хвост-вместо-медианы (круг 3, Rev114 Б1):
  # вход лжи — сеть против двойника22 (3 наблюдения, свежие первыми,
  # min-obs 2): TSV стаба ≠ ручному ожиданию want22; честность — TSV
  # конформного корпуса побайтово равен модели
  local conf_ok=0 caught=0 T
  rm -f "$WORK/so.tsv" "$WORK/mo.tsv"
  "$2" --root "$WC" --logs "$LC" --out "$WORK/so.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  "$MODEL_MEASURE" --root "$WC" --logs "$LC" --out "$WORK/mo.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  cmp -s "$WORK/so.tsv" "$WORK/mo.tsv" && conf_ok=1
  T="$WORK/so.trace"; rm -f "$T" "$WORK/sneto.tsv"
  RED114_GH_TRACE="$T" PATH="$HERE/gh_dvoynik22:$PATH" \
    "$2" --root "$W22" --out "$WORK/sneto.tsv" --min-obs 2 --repo toy/ci >/dev/null 2>&1
  if diff -q <(grep -vE '^#|^$' "$WORK/sneto.tsv" 2>/dev/null | LC_ALL=C sort) <(LC_ALL=C sort "$WORK/want22") >/dev/null 2>&1; then :; else caught=1; fi
  if [ "$caught" -eq 1 ] && [ "$conf_ok" -eq 1 ]; then
    ok "С:$1 ПОЙМАН (сеть: медиана хвоста вместо ВСЕХ наблюдений окна), честен на конформном корпусе"
  else
    kraz "С:$1 ускользнул: caught=$caught conf_ok=$conf_ok"
  fi
}

stab_nogh() { # $1 имя $2 стаб — gh-отсутствует-traceback (круг 3, Adv114 №2):
  # вход лжи — сеть без gh в PATH (клетка т23): стаб умирает traceback rc≠2
  # против именованного rc 2 модели; честность — TSV конформного корпуса
  local conf_ok=0 caught=0 srcrc mdlrc
  rm -f "$WORK/sg.tsv" "$WORK/mg.tsv"
  "$2" --root "$WC" --logs "$LC" --out "$WORK/sg.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  "$MODEL_MEASURE" --root "$WC" --logs "$LC" --out "$WORK/mg.tsv" --min-obs 5 --okno 42 >/dev/null 2>&1
  cmp -s "$WORK/sg.tsv" "$WORK/mg.tsv" && conf_ok=1
  rm -f "$WORK/s23g.tsv" "$WORK/m23g.tsv"
  PATH="$NOGH" "$2" --root "$W23" --out "$WORK/s23g.tsv" --min-obs 2 --repo toy/ci >/dev/null 2>&1; srcrc=$?
  PATH="$NOGH" "$MODEL_MEASURE" --root "$W23" --out "$WORK/m23g.tsv" --min-obs 2 --repo toy/ci >/dev/null 2>&1; mdlrc=$?
  if [ "$mdlrc" -eq 2 ] && [ "$srcrc" -ne 2 ]; then caught=1; fi
  if [ "$caught" -eq 1 ] && [ "$conf_ok" -eq 1 ]; then
    ok "С:$1 ПОЙМАН (нет gh: rc $srcrc вместо именованного rc 2 модели), честен на конформном корпусе"
  else
    kraz "С:$1 ускользнул: caught=$caught conf_ok=$conf_ok (стаб rc=$srcrc, модель rc=$mdlrc)"
  fi
}

stab_net_order s12 "$HERE/stuby/s12_hvost_vmesto_mediany.sh"
stab_nogh     s13 "$HERE/stuby/s13_gh_otsutstvuet_traceback.sh"

printf 'батарея 114: клеток %d, зелёных %d, красных %d\n' "$TOTAL" "$GREEN" "$REDO"
[ "$REDO" -eq 0 ]
