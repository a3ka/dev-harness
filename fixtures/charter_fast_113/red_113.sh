#!/usr/bin/env bash
# red_113.sh — батарея контракта 113 «быстрый check_charter при коммите устав-пути».
#
# ПРЕДМЕТ БАРЬЕРА (инвариант владельца): быстрый режим даёт ТОТ ЖЕ вердикт, что полный
# обход (ни одного пропущенного нарушения устава), а коммит устав-пути в СВЕЖЕМ worktree
# идёт секунды. Оракул — ПРЕСЛОВУТЫЙ ПОЛНЫЙ ОБХОД, сохранённый в барьере режимом --oracle;
# быстрая сторона — режим по умолчанию (его и ждёт хук check_staged и CI).
#
# СТРУКТУРА (сверка СТРУКТУРНА: сортированные множества целых строк-вердиктов, компаратор
# 083 — единый источник грамматики сравнения; пустая выборка — именованный отказ, не зелёное):
#   Д-клетки — дифференциал «оракул == быстрый» на корпусе подставных деревьев korpus_113.sh:
#     строгая сверка (ok+FAIL+rc) для полных режимов, только-красная (FAIL+rc) для --incr-окон,
#     где счётчики диапазонов легитимно сужаются (прецедент нормализации — ревью 083 С-5);
#     Д-клетка гонки — «записанная в кеш отметка ≤ проверенный объём» (инвариант
#     «Запись кеша», арбитраж круга 3): обёртка гонки в PATH (gonka-bin/git — файл
#     батареи) даёт конкурентный коммит ПОСЛЕ снимка истории; «гонка не
#     состоялась» — КРАСНАЯ; обёртка общая для клетки и поимки s10;
#     Д/d10 — свежее уставное имя из nonce РАННЕРА (литерала нет ни в одной
#     клетке; закрывает класс «зашитая константа» — вердикт адверсария круга 1,
#     обманка s11);
#     Д/d11 — проб режима: --oracle обязан первым чтением истории идти полным
#     обходом, не быстрым проходом (нейтрализация ORACLE=0 — вердикт адверсария
#     круга 1; маркер — обёртка oracle-probe-bin/git, обманка s12);
#     Д/d12 — семья sha256-репозиториев (находка Б-3 ревьюера круг 1: фильтр
#     «жёсткие 40 hex» быстрого пути отбрасывал в --object-format=sha256 все
#     совпадения → тихий rc 0 при живом нарушении); критерий — АБСОЛЮТНЫЙ
#     вердикт обеих сторон (нарушение: rc 1 и то же множество FAIL; законная
#     правка: rc 0 у обеих): сверка режимов слепа к двухсторонней слепоте;
#     git станции без sha256 — именованный пропуск NEEDS_ENV (обманка s13);
#   В-клетка — бюджет 60 с и немолчаливое зелёное на ХОЛОДНОМ локальном клоне живого
#     дерева (свой git-каталог: кеша нет ни в worktree, ни в git-common-dir — обход
#     круга 2 критика: прогретый общий кеш переживает свежий worktree); прогретый
#     повторный прогон — отдельная справочная метка, не критерий;
#   В2-клетка — дифференциал на ВСЕЙ живой истории (только RED_113_FULL=1 — приёмка);
#   С-клетки — обманные стабы stuby/: каждый обязан быть ПОЙМАН на своей ветви лжи
#     (привязка стаб↔корпус — ЗДЕСЬ, по коду, Н-39) и быть честным на корпусе вне своей лжи.
#
# ДО реализации (база) батарея КРАСНАЯ по умыслу: --oracle отсутствует → именованный отказ
# компаратора; В-клетка пробивает бюджет полным обходом (Н-380). Стаб-пак ловится и на базе —
# доказательная сила батареи видна до реализации.
#
# Коды возврата: 0 — все клетки зелёные; 1 — есть красное (именованные клетки); 2 — отказ
# инструмента (нет батареи/компаратора/скратча).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CHARTER="$REPO/scripts/check_charter.sh"
DIFF083="$REPO/fixtures/ci_gen_083/diff_verdicts_083.sh"
KORPUS="$HERE/korpus_113.sh"
STUBY="$HERE/stuby"
# Разрешить переопределение снаружи (приёмка на честной модели/чужом дереве — иначе
# стабы честной модели уйдут в рекурсию через её же обёртку).
export RED113_REAL_CHARTER="${RED113_REAL_CHARTER:-$CHARTER}"

[ -f "$CHARTER" ] || { printf 'ОТКАЗ: нет барьера %s\n' "$CHARTER" >&2; exit 2; }
[ -f "$DIFF083" ] || { printf 'ОТКАЗ: нет компаратора %s\n' "$DIFF083" >&2; exit 2; }
[ -f "$KORPUS" ]  || { printf 'ОТКАЗ: нет построителя корпусов %s\n' "$KORPUS" >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/charter113.XXXXXX")" || exit 2
clean() { rm -rf "$WORK"; }
trap clean EXIT

fails=0; kletki=0
krasnym() { fails=$((fails + 1)); printf 'FAIL_КЛЕТКА: %s\n' "$*" >&2; }
zeleno()  { printf 'ok_КЛЕТКА: %s\n' "$*" >&2; }

snap() {  # <файл-снимок> <cwd> <барьер> [арг…]: полный вывод + строка rc=N.
  # cwd = КОРЕНЬ судимого дерева: так вызывает барьер CI и хук (для --incr грамматика
  # lib_incr читает HEAD ДО разбора позиционного корня), и оракул живёт в памяти
  # проверяющего — снимок пишется ДО любого повторного чтения.
  local out="$1" cwd="$2"; shift 2
  local rc=0
  ( cd "$cwd" && bash "$@" > "$out" 2>&1 ) || rc=$?
  printf 'rc=%s\n' "$rc" >> "$out"
}

sravni_krasnye() {  # <A> <B> → 0: rc и сортированное множество «  FAIL » совпали
  local a b ra rb
  a="$(grep '^  FAIL ' "$1" | sort)"; b="$(grep '^  FAIL ' "$2" | sort)"
  ra="$(sed -n 's/^rc=//p' "$1" | tail -n1)"; rb="$(sed -n 's/^rc=//p' "$2" | tail -n1)"
  if [ -z "$ra" ] || [ -z "$rb" ]; then
    printf 'сравнение: нет строки rc= (A=%s B=%s)\n' "${ra:-нет}" "${rb:-нет}" >&2; return 2
  fi
  if [ "$ra" = "$rb" ] && [ "$a" = "$b" ]; then
    printf 'красные совпали: rc=%s\n' "$ra" >&2; return 0
  fi
  printf 'rc: A=%s B=%s\nтолько-A:\n%s\nтолько-B:\n%s\n' "$ra" "$rb" "$a" "$b" >&2
  return 1
}

postroit() {  # <имя> <метка-клетки> → K_ROOT, K_CACHE (у каждой клетки СВОЙ каталог корпуса)
  local imja="$1" metka="$2"
  local out rc=0
  out="$(bash "$KORPUS" "$WORK/$metka" "$imja" 2>&1)" || rc=$?
  if [ "$rc" -ne 0 ]; then krasnym "корпус $imja не строится (rc=$rc): $out"; return 1; fi
  K_ROOT="$(printf '%s\n' "$out" | sed -n 's/^ROOT=//p')"
  K_CACHE="$(printf '%s\n' "$out" | sed -n 's/^CACHE=//p')"
  [ -n "$K_ROOT" ] || { krasnym "корпус $imja не назвал ROOT"; return 1; }
  return 0
}

# ── Д-клетки: дифференциал «оракул == быстрый» ────────────────────────────────
dif_kletka() {  # <имя> <режим: polnyj|incr> <сверка: strogoe|krasnye>
  local imja="$1" rezhim="$2" srav="$3"
  kletki=$((kletki + 1))
  postroit "$imja" "dif-$imja" || return
  local A="$WORK/$imja.A" B="$WORK/$imja.B" crc=0
  snap "$A" "$K_ROOT" "$CHARTER" --oracle "$K_ROOT"
  if [ "$rezhim" = "incr" ]; then
    [ -n "$K_CACHE" ] || { krasnym "Д/$imja: incr-клетка без кеша у корпуса"; return; }
    snap "$B" "$K_ROOT" "$CHARTER" --incr "$K_CACHE" "$K_ROOT"
  else
    snap "$B" "$K_ROOT" "$CHARTER" "$K_ROOT"
  fi
  if [ "$srav" = "krasnye" ]; then
    sravni_krasnye "$A" "$B" >&2 || crc=$?
  else
    bash "$DIFF083" "$A" "$B" >&2 || crc=$?
  fi
  [ "$crc" -eq 0 ] && zeleno "Д/$imja: быстрый ($rezhim) неотличим от оракула ($srav)" \
                    || krasnym "Д/$imja: быстрый режим ($rezhim) РАЗОШЁЛСЯ с оракулом (сверка $srav, код $crc)"
}
# ── Д-клетка гонки: отметка кеша ≤ проверенный объём (инвариант «Запись кеша») ──
# Прецедент формы — И15 батареи 083 (late-коммит между parse и finish).
# Ветви записи кеша: (б) кеш отсутствует — сеяние, (а) проверенный кеш, посеянный
# самим барьером (как d9 в korpus_113.sh). Ветвь (в′) lib_incr идёт тем же путём
# записи, что (б), — точка записи одна (incr_finish), отдельная ветвь клетки не
# требуется (арбитраж круга 3; зафиксировано здесь по коду).
gonka_snap() {  # <out> <cwd> <кеш> <маркер>: прогон субъекта ПОД расписанием гонки
  local out="$1" cwd="$2" kesh="$3" marker="$4" rc=0
  ( cd "$cwd" && PATH="$HERE/gonka-bin:$PATH" GONKA_MARKER="$marker" GONKA_ROOT="$cwd" \
      bash "$CHARTER" --incr "$kesh" "$cwd" > "$out" 2>&1 ) || rc=$?
  printf 'rc=%s\n' "$rc" >> "$out"
}
gonka_kletka() {
  kletki=$((kletki + 1))
  local vetka bad_=0 seedrc h0 h1 kv
  for vetka in b a; do
    postroit d0_chistoe "gonka-$vetka" || return
    local R="$K_ROOT" KESH="$WORK/gonka-$vetka.sha" MK="$WORK/gonka-$vetka.marker"
    rm -f "$KESH" "$MK"
    if [ "$vetka" = "a" ]; then
      # (а) проверенный кеш: сеет сам барьер на чистом корпусе (как d9)
      snap "$WORK/gonka-$vetka.seed" "$R" "$CHARTER" --incr "$KESH" "$R"
      seedrc="$(sed -n 's/^rc=//p' "$WORK/gonka-$vetka.seed" | tail -n1)"
      [ "$seedrc" = "0" ] || { krasnym "Д/gonka_kesha(а): сеяный прогон барьера не зелёный (rc=$seedrc)"; bad_=1; continue; }
    fi
    h0="$(git -C "$R" rev-parse HEAD)"
    gonka_snap "$WORK/gonka-$vetka.race" "$R" "$KESH" "$MK"
    h1="$(git -C "$R" rev-parse HEAD)"
    kv=""
    [ -f "$KESH" ] && kv="$(head -c 40 "$KESH")"
    # страховка от молчаливой зелени: расписание обязано сработать (прецедент И15 :1850)
    if [ ! -f "$MK" ] || [ "$h0" = "$h1" ] \
       || ! git -C "$R" merge-base --is-ancestor "$h0" "$h1" 2>/dev/null; then
      krasnym "Д/gonka_kesha($vetka): гонка НЕ СОСТОЯЛАСЬ (маркер обёртки отсутствует / HEAD конца не дочерний к HEAD начала) — клетка недействительна"
      bad_=1; continue
    fi
    # (i) кеш ∈ {отсутствует, HEAD начала}, НИКОГДА HEAD конца
    if [ -n "$kv" ] && [ "$kv" != "$h0" ]; then
      krasnym "Д/gonka_kesha($vetka): кеш обогнал проверенный объём — записан не HEAD начала ${h0:0:8}, а ${kv:0:8} (HEAD конца ${h1:0:8})"
      bad_=1; continue
    fi
    # (ii) второй --incr-прогон на чистом git == --oracle на итоговом дереве
    snap "$WORK/gonka-$vetka.vtoroj" "$R" "$CHARTER" --incr "$KESH" "$R"
    snap "$WORK/gonka-$vetka.ora" "$R" "$CHARTER" --oracle "$R"
    if sravni_krasnye "$WORK/gonka-$vetka.ora" "$WORK/gonka-$vetka.vtoroj" >&2; then
      zeleno "Д/gonka_kesha($vetka): кеш ≤ проверенного объёма (${kv:+${kv:0:8}}); второй --incr == --oracle"
    else
      krasnym "Д/gonka_kesha($vetka): второй --incr-прогон на чистом git РАЗОШЁЛСЯ с --oracle на итоговом дереве (rc и множество FAIL — сверка выше)"
      bad_=1
    fi
  done
  [ "$bad_" -eq 0 ] && zeleno "Д/gonka_kesha: отметка кеша ≤ проверенный объём на ветвях (б) сеяние и (а) валидный кеш"
  return 0
}

# ── Д-клетка d11: --oracle обязан исполнять НЕ быстрый путь ───────────────────
# Вердикт адверсария круг 1: мутация `--oracle) ORACLE=0` (флаг разбирается, но
# не действует) проходила батарею 22/0. Наблюдаемое отличие режимов определено
# контрактом (§Батарея, обёртка гонки): первое чтение истории умолчания —
# `log --name-only`, полного обхода — `rev-list <since>..HEAD` без --count.
# Проб-обёртка oracle-probe-bin/git пишет маркер ДО делегирования настоящему git
# (без подделок вывода и расписания); «не наблюдала чтения» — недействительная
# клетка, не зелёное.
d11_kletka() {
  kletki=$((kletki + 1))
  postroit d0_chistoe d11-oracle-probe || return
  local MK="$WORK/d11.marker" rc=0
  rm -f "$MK"
  ( cd "$K_ROOT" && PATH="$HERE/oracle-probe-bin:$PATH" ORACLE_PROBE="$MK" \
      bash "$CHARTER" --oracle "$K_ROOT" > "$WORK/d11.out" 2>&1 ) || rc=$?
  printf 'rc=%s\n' "$rc" >> "$WORK/d11.out"
  if [ ! -f "$MK" ]; then
    krasnym 'Д/d11_oracle_rezhim: проб-обёртка НЕ НАБЛЮДАЛА чтения истории — клетка недействительна (маркер отсутствует)'
    return
  fi
  if [ "$(cat "$MK")" = 'full-traversal' ]; then
    zeleno 'Д/d11_oracle_rezhim: --oracle исполняет полный обход (первое чтение истории — rev-list <since>..HEAD)'
  else
    krasnym 'Д/d11_oracle_rezhim: --oracle исполняет БЫСТРЫЙ путь (первое чтение истории — log --name-only) — флаг нейтрализован (вердикт адверсария круг 1: ORACLE=0)'
  fi
}
# ── Д-клетка d12: sha256-репозиторий (находка Б-3 ревьюера круг 1) ─────────────
# В --object-format=sha256 длина SHA 64: фильтр «жёсткие 40 hex» отбрасывает ВСЕ
# совпадения быстрого пути → тихий rc 0 при живом нарушении (обход инварианта 1
# «на любом дереве»). Критерий — АБСОЛЮТНЫЙ вердикт ОБЕИХ сторон, не только
# сверка режимов: двухсторонняя слепота к sha256 дала бы согласие rc 0/rc 0.
# git станции без --object-format=sha256 — именованный пропуск NEEDS_ENV
# (клетка не зелёная и не красная; счёт клеток сохраняется).
d12_kletka() {
  kletki=$((kletki + 1))
  local probe; probe="$(mktemp -d "$WORK/d12probe.XXXXXX")"
  if ! GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
       git init -q --object-format=sha256 "$probe/r" >"$WORK/d12probe.out" 2>&1; then
    printf 'ПРОПУСК_КЛЕТКА: Д/d12_sha256: NEEDS_ENV — git станции (%s) не умеет --object-format=sha256: %s\n' \
      "$(git --version)" "$(head -n1 "$WORK/d12probe.out")" >&2
    return
  fi
  # фаза 1: живое нарушение — обе стороны обязаны дать rc 1 и то же множество FAIL
  postroit d12_sha256_narushenie dif-d12_sha256_narushenie || return
  local A="$WORK/d12sha256.A" B="$WORK/d12sha256.B" ra rb crc=0
  snap "$A" "$K_ROOT" "$CHARTER" --oracle "$K_ROOT"
  snap "$B" "$K_ROOT" "$CHARTER" "$K_ROOT"
  ra="$(sed -n 's/^rc=//p' "$A" | tail -n1)"; rb="$(sed -n 's/^rc=//p' "$B" | tail -n1)"
  if [ "$ra" != 1 ] || [ "$rb" != 1 ] || ! grep -q '^  FAIL ' "$A"; then
    krasnym "Д/d12_sha256[нарушение]: не признано обеими сторонами (оракул rc=${ra:-нет}, быстрый rc=${rb:-нет}) — тихий зелёный на живом нарушении = обход инварианта 1 (Б-3 ревьюера круг 1)"
    return
  fi
  sravni_krasnye "$A" "$B" >&2 || crc=$?
  [ "$crc" -eq 0 ] && zeleno 'Д/d12_sha256[нарушение]: оракул и быстрый дают rc 1 и одно множество FAIL' \
                    || krasnym "Д/d12_sha256[нарушение]: быстрый РАЗОШЁЛСЯ с оракулом на sha256-дереве (сверка krasnye, код $crc)"
  # фаза 2: законная правка СО строкой — обе стороны обязаны дать rc 0
  postroit d12_sha256_zakonno dif-d12_sha256_zakonno || return
  A="$WORK/d12sha256.ZA"; B="$WORK/d12sha256.ZB"
  snap "$A" "$K_ROOT" "$CHARTER" --oracle "$K_ROOT"
  snap "$B" "$K_ROOT" "$CHARTER" "$K_ROOT"
  ra="$(sed -n 's/^rc=//p' "$A" | tail -n1)"; rb="$(sed -n 's/^rc=//p' "$B" | tail -n1)"
  if [ "$ra" = 0 ] && [ "$rb" = 0 ]; then
    zeleno 'Д/d12_sha256[законно]: оракул и быстрый оба зелёные на законной правке'
  else
    krasnym "Д/d12_sha256[законно]: законная правка не признана (оракул rc=${ra:-нет}, быстрый rc=${rb:-нет})"
  fi
}


# ── В-клетка: бюджет ХОЛОДНОГО старта ─────────────────────────────────────────
# Обход круга 2 критика: worktree делит git-common-dir с хозяином — прогретый
# хозяином кеш маскирует холодную меру (кандидат «быстр только при живом кеше»
# проходил В за 17 с). Холодная мера — ЛОКАЛЬНЫЙ КЛОН: свой git-каталог целиком,
# кеша нет ни в worktree, ни в common-dir ПО ПОСТРОЕНИЮ (клон не наследует
# файлы .git). Холод — обязательный критерий; прогретый повтор — метка.
v_kletka() {
  kletki=$((kletki + 1))
  local COLD="$WORK/cold-clone" rc=0 wall
  if ! git clone -q "$REPO" "$COLD" >/dev/null 2>&1; then
    krasnym 'В: холодный локальный клон живого дерева не создаётся'; return
  fi
  SECONDS=0
  timeout 60 bash "$COLD/scripts/check_charter.sh" "$COLD" > "$WORK/v.out" 2>&1 || rc=$?
  wall=$SECONDS
  if [ "$rc" -eq 124 ]; then krasnym "В: ХОЛОДНЫЙ старт (локальный клон: кеша нет ни в worktree, ни в common-dir) пробил 60 с (Н-380: предмет отсутствует/медленный)"; return; fi
  if [ "$rc" -ne 0 ]; then krasnym "В: холодный клон: rc=$rc (ожидался 0 — HEAD зелёный по CI), вывод: $WORK/v.out"; return; fi
  if [ "$wall" -gt 60 ]; then krasnym "В: бюджет 60 с пробит на холодной мере: стена ${wall} с"; return; fi
  grep -q '^  ok ' "$WORK/v.out" || { krasnym 'В: молчаливое зелёное — ни одной ok-строки с числом просмотренного'; return; }
  local rc2=0 wall2
  SECONDS=0
  timeout 60 bash "$COLD/scripts/check_charter.sh" "$COLD" > "$WORK/v-warm.out" 2>&1 || rc2=$?
  wall2=$SECONDS
  printf 'В: метка прогретого повтора (справочно, не критерий): rc=%s, стена %s с\n' "$rc2" "$wall2" >&2
  zeleno "В: ХОЛОДНЫЙ клон зелёный за ${wall} с (бюджет 60 с); прогретый повтор ${wall2} с — метка"
}

# ── В2-клетка: дифференциал на ВСЕЙ живой истории (приёмка) ───────────────────
v2_kletka() {
  kletki=$((kletki + 1))
  if [ "${RED_113_FULL:-}" != "1" ]; then
    printf 'В2: ПРОПУСК (именованный): вся история судится только при RED_113_FULL=1 (приёмка, timeout >= 3600)\n' >&2
    return
  fi
  local rc=0 fwall owall
  SECONDS=0
  timeout 60 bash "$CHARTER" "$REPO" > "$WORK/v2fast" 2>&1 || rc=$?
  printf 'rc=%s\n' "$rc" >> "$WORK/v2fast"
  fwall=$SECONDS
  [ "$rc" -eq 124 ] && { krasnym 'В2: быстрая сторона пробила 60 с на живой истории — предмет отсутствует'; return; }
  SECONDS=0
  rc=0
  timeout 3600 bash "$CHARTER" --oracle "$REPO" > "$WORK/v2oracle" 2>&1 || rc=$?
  printf 'rc=%s\n' "$rc" >> "$WORK/v2oracle"
  owall=$SECONDS
  printf 'В2: стена быстрая=%s с, оракул=%s с\n' "$fwall" "$owall" >&2
  local crc=0
  bash "$DIFF083" "$WORK/v2oracle" "$WORK/v2fast" >&2 || crc=$?
  [ "$crc" -eq 0 ] && zeleno "В2: ВСЯ история — быстрый неотличим от оракула (оракул ${owall} с, быстрый ${fwall} с)" \
                    || krasnym "В2: на всей истории вердикты разошлись (код $crc)"
}

# ── С-клетки: обманные стабы (привязка лжи к корпусу — ПО КОДУ, ниже) ─────────
# формат строки: <стаб>|<корпус поимки>|<режим поимки: polnyj|incr>|<корпус честности|->
stub_kletka() {  # <строка карты>
  local IFS='|'
  # shellcheck disable=SC2206
  local ch=($1)
  local stab="${ch[0]}" ulov="${ch[1]}" rezhim="${ch[2]}" chestno="${ch[3]}"
  kletki=$((kletki + 1))
  local f="$STUBY/$stab.sh"
  [ -f "$f" ] || { krasnym "С/$stab: файла нет: $f"; return; }

  # 1. поимка: стаб обязан РАЗОЙТИСЬ с собственным --oracle (= честный барьер) на своей ветви лжи
  # поимка на гонке (s10): ложь «finish пишет HEAD конца» наблюдаема ТОЛЬКО под
  # расписанием обёртки (гонка-коммит после снимка); вне гонки HEAD конца ==
  # HEAD начала и стаб ведёт себя честно (контроль честности ниже, как у всех).
  # Критерий поимки: сеяный прогон rc 0 И кеш == HEAD конца И второй --incr на
  # чистом git нарушения не видит, а полный обход (--oracle) видит.
  if [ "$ulov" = "gonka" ]; then
    postroit d0_chistoe "$stab-gonka" || return
    local gR="$K_ROOT" gKESH="$WORK/$stab-gonka.sha" gMK="$WORK/$stab-gonka.marker"
    rm -f "$gKESH" "$gMK"
    local grc=0 gh0 gh1 gkv="" gvt gseed
    gh0="$(git -C "$gR" rev-parse HEAD)"
    ( cd "$gR" && PATH="$HERE/gonka-bin:$PATH" GONKA_MARKER="$gMK" GONKA_ROOT="$gR" \
        bash "$f" --incr "$gKESH" "$gR" > "$WORK/$stab.race" 2>&1 ) || grc=$?
    printf 'rc=%s\n' "$grc" >> "$WORK/$stab.race"
    gh1="$(git -C "$gR" rev-parse HEAD)"
    [ -f "$gKESH" ] && gkv="$(head -c 40 "$gKESH")"
    if [ ! -f "$gMK" ] || [ "$gh0" = "$gh1" ] \
       || ! git -C "$gR" merge-base --is-ancestor "$gh0" "$gh1" 2>/dev/null; then
      krasnym "С/$stab: гонка НЕ СОСТОЯЛАСЬ — поимка недействительна (маркер обёртки / HEAD конца не дочерний к HEAD начала)"
    else
      snap "$WORK/$stab.vtoroj" "$gR" "$f" --incr "$gKESH" "$gR"
      gvt="$(sed -n 's/^rc=//p' "$WORK/$stab.vtoroj" | tail -n1)"
      snap "$WORK/$stab.ora" "$gR" "$f" --oracle "$gR"
      gseed="$(sed -n 's/^rc=//p' "$WORK/$stab.ora" | tail -n1)"
      if [ "$grc" -eq 0 ] && [ "$gkv" = "$gh1" ] && [ "$gvt" = "0" ] \
         && [ "$gseed" = "1" ] && grep -q '^  FAIL ' "$WORK/$stab.ora"; then
        zeleno "С/$stab: ПОЙМАН на клетке гонки (кеш == HEAD конца при rc 0; второй --incr нарушение не видит, --oracle видит)"
      else
        krasnym "С/$stab: НЕ ПОЙМАН на клетке гонки (сеяный rc=$grc, кеш=${gkv:0:8}, HEAD конца=${gh1:0:8}, второй rc=$gvt, оракул rc=$gseed)"
      fi
    fi
  else
  postroit "$ulov" "$stab-ulov" || return
  if [ "$rezhim" = "probe" ]; then
    # поимка проб-обёрткой режима: стаб получает --oracle, но первое чтение истории
    # обязано быть полным обходом (rev-list <since>..HEAD без --count); log --name-only
    # = быстрый путь = нейтрализованный флаг (класс s12, вердикт адверсария круг 1)
    local MK="$WORK/$stab.probe.marker" prc=0
    rm -f "$MK"
    ( cd "$K_ROOT" && PATH="$HERE/oracle-probe-bin:$PATH" ORACLE_PROBE="$MK" \
        bash "$f" --oracle "$K_ROOT" > "$WORK/$stab.probe.out" 2>&1 ) || prc=$?
    printf 'rc=%s\n' "$prc" >> "$WORK/$stab.probe.out"
    if [ ! -f "$MK" ]; then
      krasnym "С/$stab: проб-обёртка не наблюдала чтения истории — поимка недействительна (маркер отсутствует)"
    elif [ "$(cat "$MK")" = 'full-traversal' ]; then
      krasnym "С/$stab: НЕ ПОЙМАН — --oracle исполняет полный обход (маркер full-traversal)"
    else
      zeleno "С/$stab: ПОЙМАН — --oracle исполняет быстрый путь (первое чтение истории log --name-only)"
    fi
  else
  local A="$WORK/$stab.A" B="$WORK/$stab.B" crc=0
  snap "$A" "$K_ROOT" "$f" --oracle "$K_ROOT"
  if [ "$rezhim" = "incr" ]; then
    snap "$B" "$K_ROOT" "$f" --incr "$K_CACHE" "$K_ROOT"
  else
    snap "$B" "$K_ROOT" "$f" "$K_ROOT"
  fi
  if [ "$stab" = "s7_kesh_linii" ]; then
    sravni_krasnye "$A" "$B" >/dev/null 2>&1 && crc=0 || crc=1
  else
    bash "$DIFF083" "$A" "$B" >/dev/null 2>&1 && crc=0 || crc=1
  fi
  if [ "$crc" -eq 0 ]; then
    krasnym "С/$stab: НЕ ПОЙМАН на $ulov — батарея не различает этот класс лжи"
  else
    zeleno "С/$stab: ПОЙМАН на $ulov (класс лжи наблюдаем)"
  fi
  fi
  fi

  # 2. честность вне своей лжи: на другом корпусе стаб ведёт себя как барьер (только-красная
  #    сверка: предмет инварианта — ВЕРДИКТ, косметика ok-строк не предмет)
  [ "$chestno" = "-" ] && return
  postroit "$chestno" "$stab-chestno" || return
  local H1="$WORK/$stab.H1" H2="$WORK/$stab.H2"
  snap "$H1" "$K_ROOT" "$f" --oracle "$K_ROOT"
  if [ -n "${K_CACHE:-}" ]; then
    snap "$H2" "$K_ROOT" "$f" --incr "$K_CACHE" "$K_ROOT"
  else
    snap "$H2" "$K_ROOT" "$f" "$K_ROOT"
  fi
  local hrc=0
  sravni_krasnye "$H1" "$H2" >/dev/null 2>&1 || hrc=$?
  [ "$hrc" -eq 0 ] || krasnym "С/$stab: нечестен уже на $chestno (стаб лжёт шире своей ветви — карта лжи неверна)"
}

# ── карта привязок (Н-39: код, не проза контракта) ────────────────────────────
KARTA=(
  's1_okno|d1_staroe|polnyj|d0_chistoe'
  's2_bez_merge|d2_merge|polnyj|d0_chistoe'
  's3_sostojanie|d3_otkat|polnyj|d0_chistoe'
  's4_bez_udalenija|d4_udalenie|polnyj|d0_chistoe'
  's5_renames|d5_pereim|polnyj|d0_chistoe'
  's6_bez_since|d0_chistoe|polnyj|-'   # честность не наблюдаема: ложь «судит всё» красит любой корпус с вне-окна матчами (Н-39: ветвь без входа не заводится)
  's7_kesh_linii|d7_kesh_linii|incr|d8_kesh_valid'
  's8_molchalivyj|d0_chistoe|polnyj|-'
  's9_okno_globalnoe|d9_bokovaja_zamorozka|incr|d8_kesh_valid'
  's10_finish_konca|gonka|incr|d8_kesh_valid'  # поимка — ТОЛЬКО клетка гонки (обёртка расписания): вне гонки HEAD конца == HEAD начала, ложь ненаблюдаема; честен на d8_kesh_valid (Н-39)
  's11_konstanta_oblasti|d10_novoe_imja|polnyj|d8_kesh_valid'  # свежее имя вне зашитого перечня: быстрый путь стаба документ не судит, оракул судит; честность — d8_kesh_valid (как s7/s9/s10): его документы в перечне, а единственная правка БЕЗ строки — контроль слеп к потере тел в sourced-razreshil (чужой дефект честной модели, не ложь стаба; d2_merge с законной правкой непригоден)
  's12_ignoriruet_oracle|d0_chistoe|probe|d0_chistoe'     # поимка — ТОЛЬКО проб-обёрткой режима: дифференциал слеп (быстрый путь каркаса честен), различима форма первого чтения истории
  's13_zhestkie_40|d12_sha256_narushenie|polnyj|d0_chistoe'  # ложь наблюдаема ТОЛЬКО в sha256-корпусе (64-hex совпадения отброшены → rc 0 при живом нарушении); в sha1-корпусе фильтр прозрачен, честность — d0_chistoe (Н-39)
)

printf 'батарея 113: дерево %s, барьер %s\n' "$REPO" "$CHARTER" >&2

# Д-клетки: полные режимы — строгая сверка; incr-окна — только-красная
dif_kletka d0_chistoe    polnyj strogoe
dif_kletka d1_staroe     polnyj strogoe
dif_kletka d2_merge      polnyj strogoe
dif_kletka d3_otkat      polnyj strogoe
dif_kletka d4_udalenie   polnyj strogoe
dif_kletka d5_pereim     polnyj strogoe
dif_kletka d7_kesh_linii incr   krasnye
dif_kletka d8_kesh_valid incr   krasnye
dif_kletka d9_bokovaja_zamorozka incr krasnye

# Д/d10 — свежее уставное имя из nonce (класс «зашитая константа», вердикт
# адверсария круг 1): имя генерируется ЗДЕСЬ, в раннере, литерала нет ни в
# одной клетке; воспроизводимость — логом (повтор: D10_NONCE=<nonce>).
D10_NONCE="${D10_NONCE:-$$-$(date +%s%N)}"
export KORPUS113_NONCE="$D10_NONCE"
printf 'Д/d10_novoe_imja: nonce=%s имя=%s (повтор: D10_NONCE=%s)\n' \
  "$D10_NONCE" "$(bash "$KORPUS" --imja "$D10_NONCE")" "$D10_NONCE" >&2
dif_kletka d10_novoe_imja polnyj strogoe
gonka_kletka
d11_kletka
d12_kletka

v_kletka
v2_kletka

for stroka in "${KARTA[@]}"; do stub_kletka "$stroka"; done

printf '\nклеток: %d · красных: %d\n' "$kletki" "$fails" >&2
[ "$fails" -eq 0 ] || exit 1
exit 0
