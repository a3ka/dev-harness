# Профиль батареи для scripts/check_zones.sh (контракт 040, v9 — структурный фикс
# круга 8, verdicts/adversary/contracts-040-v8-circle.md). ДОГФУД: контракт 041
# первым потребителем этой батареи назначает ИМЕННО check_zones.sh — владелец явно
# сравнил порядок (041 первым, потому что дал бы эту батарею ДО того, как круг 7/8
# нашли свой класс putanicы заново вручную). Домен ЭТОГО барьера — не разбор ОДНОГО
# текстового файла (как у check_provodka/check_threat_model), а разбор NUL-потока
# `git diff-tree --raw --always -z --stdin`: классификация SHA-заголовок/путь,
# которую v7→v8→v9 чинили сначала regex-по-форме, потом позиционно-с-редундантным-
# fallback, теперь структурно (`:`-префикс формата git, конечный автомат из двух
# состояний, см. scripts/check_zones.sh — комментарий у `--raw`).
#
# Реюз, не переизобретение: toy-репозитории строит ШТАТНЫЙ
# fixtures/check_zones/_repo.sh (make_repo/commit_as/freeze_v2/add_contract) — тот
# же каркас, что несут все 28+ existing case_*.sh этого барьера.
ZONES_REPO="$(cd "$HERE/../.." && pwd -P)"
ZONES_SUBJ="$ZONES_REPO/scripts/check_zones.sh"
# shellcheck disable=SC1091
. "$HERE/../check_zones/_repo.sh"

battery_delimiter_collision() {
  # (а, круг 7 находка 2 — verdicts/adversary/contracts-040-v7-circle.md) Путь ==
  # 40-hex, НЕ совпадающий ни с одним заголовком потока этого окна (старая
  # regex-по-форме `/^[0-9a-f]{40}$/` путала его с SHA-заголовком ПО ФОРМЕ).
  # Ожидание: легальный top-level путь внутри объявленной зоны принят (rc 0),
  # НЕСВЯЗАННЫЙ файл вне зоны — красный, назван байт-в-байт.
  local w r P out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_zn_dc_a.XXXXXX")"; r="$w/toy"
  P=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  make_repo "$r" "ЗОНА agent-x: $P"
  out="$(bash "$ZONES_SUBJ" "$r" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then rm -rf "$w"; return 1; fi
  printf 'honest\n' > "$r/$P"
  commit_as "$r" agent-x 'легальное имя файла — ровно 40 hex-символов, top-level, внутри зоны'
  out="$(bash "$ZONES_SUBJ" "$r" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] || printf '%s' "$out" | grep -q 'ОТКАЗ'; then rm -rf "$w"; return 1; fi
  mkdir -p "$r/plans"
  printf 'forbidden\n' > "$r/plans/outside-a.md"
  commit_as "$r" agent-x 'коммит вне зоны — несвязанный путь'
  out="$(bash "$ZONES_SUBJ" "$r" 2>&1)"; rc=$?
  rm -rf "$w"
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'plans/outside-a.md'; then return 1; fi

  # (б, круг 8 — verdicts/adversary/contracts-040-v8-circle.md) Путь == sha
  # РАНЕЕ уже поглощённого коммита C ЭТОГО ЖЕ окна (позиционно-с-редундантным-
  # membership-fallback v8 путал его со ВТОРЫМ заголовком C). Заморозка v2
  # добавляет к зоне ТОЧНЫЙ путь = sha C, диапазон суда остаётся от v1 (C уже
  # в нём). Ожидание: топ-level файл с именем ровно C принят (rc 0, НЕ
  # «ОТКАЗ: искажённый поток»), НЕСВЯЗАННЫЙ файл вне зоны — красный.
  local w2 r2 out2 rc2 CSHA
  w2="$(mktemp -d "${TMPDIR:-/tmp}/battery_zn_dc_b.XXXXXX")"; r2="$w2/toy"
  make_repo "$r2" "ЗОНА agent-x: scripts/"
  mkdir -p "$r2/scripts"
  printf 'honest\n' > "$r2/scripts/inside.sh"
  commit_as "$r2" agent-x 'C: честный коммит внутри зоны scripts/'
  CSHA="$(GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$r2" rev-parse HEAD)"
  freeze_v2 "$r2" "ЗОНА agent-x: scripts/ $CSHA"
  printf 'named after prior commit sha\n' > "$r2/$CSHA"
  commit_as "$r2" agent-x 'D: top-level файл, имя — ровно sha РАНЕЕ поглощённого коммита C'
  out2="$(bash "$ZONES_SUBJ" "$r2" 2>&1)"; rc2=$?
  if [ "$rc2" -ne 0 ] || printf '%s' "$out2" | grep -q 'ОТКАЗ'; then rm -rf "$w2"; return 1; fi
  mkdir -p "$r2/plans"
  printf 'forbidden\n' > "$r2/plans/outside-b.md"
  commit_as "$r2" agent-x 'коммит вне зоны — несвязанный путь'
  out2="$(bash "$ZONES_SUBJ" "$r2" 2>&1)"; rc2=$?
  rm -rf "$w2"
  [ "$rc2" -eq 1 ] && printf '%s' "$out2" | grep -Fq 'plans/outside-b.md'
}

battery_regex_injection() {
  # Путь дельты несёт ЛИТЕРАЛЬНЫЕ ERE/glob-метасимволы (`.` `*` `+` `?` `[`
  # `]` `(` `)` `^` `$` `|`). Классификатор НЕ использует regex ни на одном
  # шаге (только substr($0,1,1)==":" — байтовое сравнение — и `==`); сверка
  # зоны — bash `case` с КВОТИРОВАННЫМ префиксом (`"$p"*` — quoting гасит
  # спецсимволы $p В ПОЗИЦИИ ПАТТЕРНА). Ожидание: честный файл с ЭТИМИ
  # БАЙТАМИ внутри зоны — rc 0; ТОТ ЖЕ файл вне зоны — rc 1, назван
  # байт-в-байт: метасимволы не интерпретированы ни как regex, ни как glob,
  # ни в ту, ни в другую сторону (не ложный accept, не ложный вечный reject).
  local w r NAME out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_zn_ri.XXXXXX")"; r="$w/toy"
  NAME='a.b+c(d)[e]^f$g|h.sh'
  make_repo "$r" "ЗОНА agent-x: scripts/"
  mkdir -p "$r/scripts"
  printf 'honest\n' > "$r/scripts/$NAME"
  commit_as "$r" agent-x 'честный файл с regex/glob-метасимволами в имени, внутри зоны'
  out="$(bash "$ZONES_SUBJ" "$r" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then rm -rf "$w"; return 1; fi

  mkdir -p "$r/plans"
  printf 'forbidden\n' > "$r/plans/$NAME"
  commit_as "$r" agent-x 'тот же файл (те же метасимволы) — вне зоны'
  out="$(bash "$ZONES_SUBJ" "$r" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "plans/$NAME"
}

battery_silent_drop() {
  # Многофайловый коммит (2 пути: один В зоне, один — нарушение), СРАЗУ
  # следом — честный ПУСТОЙ (`--allow-empty`, 0 файлов) коммит ТОГО ЖЕ
  # автора. Это ИМЕННО граница, которую защищает структурный разбор: конец
  # файлового списка коммита N переходит в заголовок коммита N+1 БЕЗ единой
  # `:`-метазаписи между двумя заголовками подряд (N+1 отдаёт 0 путей). Если
  # бы разбор терял синхронизацию на этой границе, нарушение из МНОГОфайлового
  # коммита N могло бы молча потеряться либо ложно приписаться N+1. Ожидание:
  # нарушение НЕ теряется, названо байт-в-байт.
  local w r out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_zn_sd.XXXXXX")"; r="$w/toy"
  make_repo "$r" "ЗОНА agent-x: scripts/"
  mkdir -p "$r/scripts" "$r/plans"
  printf 'ok\n' > "$r/scripts/ok.sh"
  printf 'forbidden\n' > "$r/plans/silent-drop-target.md"
  commit_as "$r" agent-x 'многофайловый коммит: один путь в зоне, один — нарушение'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c user.name=agent-x -c user.email=agent-x@local \
        -c commit.gpgsign=false -c core.hooksPath=/dev/null \
        commit -q --allow-empty -m 'сразу следом: честный ПУСТОЙ коммит того же автора (0 путей)'
  out="$(bash "$ZONES_SUBJ" "$r" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq 'plans/silent-drop-target.md'
}

battery_self_application_green() {
  # DOGFOOD: живое требование контракта 040 «check_zones.sh . rc=0» (§Условие
  # done) — здесь ПОСТОЯННЫМ, CI-гоняемым регрессом, не разовым наблюдением.
  # ОДИН клон РЕАЛЬНОЙ истории dev-harness несёт ОБА плеча:
  #   (а) БАЗА — клон на момент вызова = ПОЛНАЯ реальная история (тысячи
  #       коммитов, десятки живых заморозок) → ожидание rc 0. Это НЕ toy.
  #   (б, ДОДЕЛ по доктрине арбитража 041 п.2 — verdicts/arbitration/
  #       contracts-041-battery-example-based-predel.md — тот же класс, что
  #       додел соседних профилей check_provodka/check_threat_model круга 3):
  #       один позитив (а) НЕ различает честный гард от стаба, хардкодящего
  #       accept ДЛЯ ЭТОГО КОНКРЕТНОГО байтового содержимого дерева. Негатив
  #       НЕ toy (28 существующих fixtures/check_zones/case_*.sh это уже
  #       покрывают) — ТА ЖЕ клонированная РЕАЛЬНАЯ история плюс СВЕЖИЙ,
  #       никогда не существовавший номер контракта (max существующих + 1,
  #       вычислен ДИНАМИЧЕСКИ — не хардкод, коллизия с реальным номером
  #       структурно исключена) с зоной для НОВОГО, никогда не встречавшегося
  #       имени автора, и РОВНО одним нарушающим коммитом поверх. Хардкод
  #       «байты похожи на dev-harness → accept» ложно проходит (б) так же,
  #       как и (а) — байты ДО добавления идентичны; честный гард обязан
  #       различить их, потому что судит коммит, добавленный ПОСЛЕ.
  # Клон — ОДНОРАЗОВЫЙ ($w/clone); $ZONES_REPO (рабочее дерево architect) не
  # трогается ни чтением-для-мутации, ни записью.
  local w nxt out rc out2 rc2
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_zn_self.XXXXXX")"
  git clone -q --no-hardlinks "$ZONES_REPO" "$w/clone" 2>/dev/null || { rm -rf "$w"; return 1; }

  out="$(bash "$ZONES_SUBJ" "$w/clone" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    printf 'БАТАРЕЯ %s: self-application базовое плечо (а) пробито на клоне реальной истории (rc=%s)\n' \
      "${PROFILE_NAME:-check_zones}" "$rc" >&2
    rm -rf "$w"; return 1
  fi

  nxt=$(( $(cd "$ZONES_REPO" && printf '%s\n' contracts/*.md 2>/dev/null \
              | sed -n 's#^contracts/\([0-9][0-9][0-9]\)-.*#\1#p' \
              | LC_ALL=C sort -n | tail -n1) + 1 ))
  add_contract "$w/clone" "$nxt" "ЗОНА battery-self-neg-author: scripts/allowed/"
  mkdir -p "$w/clone/plans"
  printf 'forbidden\n' > "$w/clone/plans/self-application-negative.md"
  commit_as "$w/clone" battery-self-neg-author \
    'нарушение НА РЕАЛЬНОЙ истории dev-harness — вне свежеобъявленной зоны'
  out2="$(bash "$ZONES_SUBJ" "$w/clone" 2>&1)"; rc2=$?
  rm -rf "$w"
  if [ "$rc2" -ne 1 ] || ! printf '%s' "$out2" | grep -Fq 'plans/self-application-negative.md'; then
    printf 'БАТАРЕЯ %s: self-application-негатив (б) пробит на клоне реальной истории (rc=%s)\n' \
      "${PROFILE_NAME:-check_zones}" "$rc2" >&2
    return 1
  fi
  return 0
}
