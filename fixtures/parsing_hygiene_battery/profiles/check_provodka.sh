# Профиль батареи для scripts/check_provodka.sh (038) — РЕГРЕССИОННОЕ
# предъявление: батарея прогнана на УЖЕ ДОЧИНЕННОМ (после круга 15) барьере
# БЕЗ единой правки его кода — контракт 041 038 НЕ трогает ретроактивно.
# Зелёный итог здесь доказывает, что круги 11-15 038 действительно закрыли
# соответствующие классы, и что батарея не орфанна (различает честный вход от
# форжа — см. регрессию battery_regex_injection).
PROVODKA_REPO="$(cd "$HERE/../.." && pwd -P)"
PROVODKA_SUBJ="$PROVODKA_REPO/scripts/check_provodka.sh"

_provodka_toy() {  # <каталог> — честная минимальная основа
  local r="$1"
  mkdir -p "$r/scripts" "$r/.githooks" "$r/roles" "$r/contracts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/check_ok.sh"
  printf 'bash scripts/check_ok.sh\n' > "$r/.githooks/pre-commit"
  printf '# role fixture\n\nNorma stroki roli battery R.\n' > "$r/roles/fixer.md"
}

battery_delimiter_collision() {
  # (а) Норма-строка легально содержит байт `|` — исторический внутренний
  # разделитель ДО круга 12 (channel-pipe-truncation). Пост-round-12
  # реализация несёт поля МАССИВАМИ — байт `|` в данных не участвует ни в
  # каком join. Ожидание: норма-строка НЕ усечена, найдена через grep -Fxq.
  local w r norm out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_dc.XXXXXX")"; r="$w/toy"; _provodka_toy "$r"
  norm='Norma so znakom | vnutri teksta ostajotsja celoj.'
  printf '# role fixture\n\n%s\n' "$norm" > "$r/roles/fixer.md"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- role=roles/fixer.md «%s»\n' "$norm" > "$r/contracts/001-x.md"
  out="$(bash "$PROVODKA_SUBJ" "$r" "contracts/001-x.md" 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 0 ]; then
    return 1
  fi

  # (б, генерализация verdicts/adversary/contracts-041-parsing-hygiene-v2.md
  # — АДВЕРСАРИЙ КРУГ 2, f89c5e2). Прежняя версия этого случая закрывала
  # РОВНО N=2 role-канала; обманная реализация круга 2 честно проверяет
  # первые ДВА канала (не join+split — честные параллельные массивы НА
  # ПЕРВЫХ ДВУХ индексах), но ИГНОРИРУЕТ канал №3 и далее (хардкод длины
  # цикла, не длины поля) — на N=2 неотличима от честной (то, сколько
  # канала прежний тест и строил); форж-канал №3 честный гард ловит
  # (rc 1, именует roles/fixerN.md), обманный — не доходит до него
  # (rc 0 ошибочно). Просто поднять N с 2 до другого хардкода (заранее
  # известного адверсарию из файла) — НЕ структурный фикс, тот же класс,
  # отложенный на следующий круг (см. отчёт architect круга 3).
  # СТРУКТУРНЫЙ фикс: ЦИКЛ строит n3=4 role-канала (число, НЕ
  # встречавшееся в прежних вердиктах — 1,2,3 уже «засвечены» как
  # кандидаты хардкода читающим файл стабом), forge применяется к
  # ПОСЛЕДНЕМУ каналу, чьё ИМЯ ВЫЧИСЛЕНО из ТОЙ ЖЕ переменной $n3
  # (`roles/fixer${n3}.md`), а не вписано руками как "fixer2" — код,
  # проверяющий только первые K<n3 каналов (K=2 круга 2 или ЛЮБОЙ K<4),
  # никогда не доходит до forged N-го канала → rc 0 ошибочно, тогда как
  # честный гард обязан упасть ИМЕННО на нём. Позитив: все n3 канала
  # честны → rc 0 (доказывает, что легитимный вход той же формы и длины
  # не ломается). Как и в check_threat_model, это не доказывает защиту
  # от адверсария, заранее подбирающего cap=4, зная этот файл —
  # фундаментальный предел example-based теста; закрывает конкретно
  # продемонстрированный класс «cap ниже длины поля», не абсолютно любое
  # N (см. отчёт architect).
  local w3 g3 n3 i chnorm body3 out3g rc3g out3b rc3b lastfile
  n3=4
  body3=""
  w3="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_dc3.XXXXXX")"; g3="$w3/toy"; _provodka_toy "$g3"
  for ((i = 1; i <= n3; i++)); do
    chnorm="Norma kanala nomer ${i} so znakom | vnutri teksta kanala ${i}."
    printf '# role fixture %d\n\n%s\n' "$i" "$chnorm" > "$g3/roles/fixer${i}.md"
    body3+="- role=roles/fixer${i}.md «${chnorm}»"$'\n'
  done
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n%s' "$body3" > "$g3/contracts/001-x.md"
  out3g="$(bash "$PROVODKA_SUBJ" "$g3" "contracts/001-x.md" 2>&1)"; rc3g=$?

  lastfile="$g3/roles/fixer${n3}.md"
  printf '# role fixture forged\n\nSovsem drugoj tekst bez sviazi s normoj poslednego kanala.\n' > "$lastfile"
  out3b="$(bash "$PROVODKA_SUBJ" "$g3" "contracts/001-x.md" 2>&1)"; rc3b=$?
  rm -rf "$w3"

  [ "$rc3g" -eq 0 ] \
    && [ "$rc3b" -eq 1 ] \
    && printf '%s' "$out3b" | grep -Fq "$(printf 'проводка: норма-строка не найдена в role-файле: roles/fixer%d.md' "$n3")"
}

battery_regex_injection() {
  # Basename гарда с ERE-метасимволом (`.` в `a.b.sh`) — круг 14 закрыл
  # интерполяцию regex. Позитив: литеральный basename в hook → rc 0.
  # Форж: суррогат `axb.sh` без `a.b.sh` → rc 1 (НЕ должен матчиться regex'ом).
  local w g b out_g rc_g out_b rc_b
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_ri.XXXXXX")"; g="$w/green"; b="$w/bad"
  mkdir -p "$g/scripts" "$g/.githooks" "$g/roles" "$g/contracts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$g/scripts/a.b.sh"
  printf 'bash scripts/a.b.sh\n' > "$g/.githooks/pre-commit"
  printf '# role fixture\n\nNorma stroki roli battery R.\n' > "$g/roles/fixer.md"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- guard=scripts/a.b.sh\n- role=roles/fixer.md «Norma stroki roli battery R.»\n' > "$g/contracts/001-x.md"
  out_g="$(bash "$PROVODKA_SUBJ" "$g" "contracts/001-x.md" 2>&1)"; rc_g=$?

  mkdir -p "$b/scripts" "$b/.githooks" "$b/roles" "$b/contracts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$b/scripts/a.b.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$b/scripts/axb.sh"
  printf 'bash scripts/axb.sh\n' > "$b/.githooks/pre-commit"
  printf '# role fixture\n\nNorma stroki roli battery R.\n' > "$b/roles/fixer.md"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- guard=scripts/a.b.sh\n- role=roles/fixer.md «Norma stroki roli battery R.»\n' > "$b/contracts/001-x.md"
  out_b="$(bash "$PROVODKA_SUBJ" "$b" "contracts/001-x.md" 2>&1)"; rc_b=$?
  rm -rf "$w"
  [ "$rc_g" -eq 0 ] && [ "$rc_b" -eq 1 ]
}

battery_silent_drop() {
  # Голая строка канала без `- `-префикса рядом с честной (round 11,
  # bare-channel-line) — ожидание: ИМЕНОВАННЫЙ отказ САМОЙ строкой.
  local w r out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_sd.XXXXXX")"; r="$w/toy"; _provodka_toy "$r"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- role=roles/fixer.md «Norma stroki roli battery R.»\nrole=roles/missing.md «Missing.»\n' > "$r/contracts/001-x.md"
  out="$(bash "$PROVODKA_SUBJ" "$r" "contracts/001-x.md" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq 'проводка: строка вне грамматики: role=roles/missing.md «Missing.»'
}

battery_self_application_green() {
  # (а) Само-применение: check_provodka.sh на СОБСТВЕННОМ буквальном
  # тексте контракта 038 (носителя поля ПРОВОДКА) — GREEN, без правки
  # его кода.
  local out rc
  out="$(cd "$PROVODKA_REPO" && bash "$PROVODKA_SUBJ" "$PROVODKA_REPO" "contracts/038-provodka-done-gejt.md" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || return 1

  # (б, ДОДЕЛ АРБИТРАЖА 041 п.2 — verdicts/arbitration/
  # contracts-041-battery-example-based-predel.md, «Решение по существу»
  # п.2 + Замер З3.) Круг 3 адверсария
  # (verdicts/adversary/contracts-041-parsing-hygiene-v3.md) предъявил
  # хардкод-стаб, различающий ИМЕННО строку пути
  # `contracts/038-provodka-done-gejt.md` (условие `[ "$CONTRACT_PATH" =
  # "contracts/038-provodka-done-gejt.md" ]`, минуя фактическое чтение
  # содержимого) — прежняя версия негативного контроля проверяла ТОЛЬКО
  # этот один путь, и стаб проходил её тривиально, отвечая честно ровно
  # на единственном проверяемом пути. Точечная константа (А-225) закрывает
  # C (эту конкретную строку), а не класс «хардкод ЛЮБОГО известного
  # пути» — арбитраж разделил находку РОВНО так: адверсарий прав в том,
  # что дыра закрываема одним ходом (Замер З3), автор прав в том, что
  # предел РЕАЛЬНЕЕ (класс без единой константы, Замер З2 — вне области
  # этого додела, именованный остаток). Додел (пункт 2 решения): множество
  # путей негативного контроля — НЕ ручная константа, а ЖИВОЙ glob
  # `contracts/*.md` ТЕКУЩЕГО репозитория (single source — та же
  # дисциплина, что уже несёт n/m/n3 выше и соседний профиль); путь
  # forge-файла и путь, передаваемый гарду, — ОДНА переменная цикла
  # ($relpath), не два места, которые могут разойтись.
  #
  # Для КАЖДОГО пути из живого glob строится СВЕЖИЙ forged toy-корень
  # (mktemp, НЕ реальный репозиторий) под ЭТИМ ЖЕ относительным именем —
  # та же forge-дисциплина, что и раньше: role-канал, чья норма-строка НЕ
  # совпадает с фактическим текстом role-файла. Честный гард резолвит
  # root+path в конкретный файл и парсит его СОДЕРЖИМОЕ — ему всё равно,
  # что путь ТЕКСТУАЛЬНО совпадает с любой строкой любого настоящего
  # контракта; ожидание — rc 1 с именованной причиной НА КАЖДОМ пути без
  # исключения. Хардкод-по-одной-строке (круг 3) теперь ложно проходит
  # РОВНО на своей строке и ловится на любой другой из множества — Замер
  # З3 живого прогона одноразового клона арбитра: 40 путей, 1 пробитие на
  # стабе круга 3, 0 пробитий на честном гарде (обе цифры воспроизведены
  # живьём этим кругом — см. отчёт architect).
  local relpath w4 out4 rc4 tested=0 bad=0
  while IFS= read -r relpath; do
    [ -n "$relpath" ] || continue
    tested=$((tested + 1))
    w4="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_selfhard.XXXXXX")"
    _provodka_toy "$w4"
    mkdir -p "$w4/${relpath%/*}"
    printf '# kontrakt forged self-application-path probe\n\n## Predmet\np\n\nПРОВОДКА:\n- role=roles/fixer.md «Sovershenno drugaja norma nikak ne sovpadajet s faktom v fajle.»\n' \
      > "$w4/$relpath"
    out4="$(bash "$PROVODKA_SUBJ" "$w4" "$relpath" 2>&1)"; rc4=$?
    rm -rf "$w4"
    if [ "$rc4" -ne 1 ] || ! printf '%s' "$out4" | grep -Fq 'проводка: норма-строка не найдена в role-файле: roles/fixer.md'; then
      bad=$((bad + 1))
      printf 'БАТАРЕЯ %s: self-application-негатив пробит на пути %s (rc=%s)\n' \
        "${PROFILE_NAME:-check_provodka}" "$relpath" "$rc4" >&2
    fi
  done < <(cd "$PROVODKA_REPO" && printf '%s\n' contracts/*.md | LC_ALL=C sort)
  [ "$tested" -gt 0 ] || return 1
  [ "$bad" -eq 0 ]
}
