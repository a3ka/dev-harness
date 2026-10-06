# Профиль батареи гигиены парсинга для scripts/check_plan.sh (контракт 084, норма 041 —
# новый гард чужого ввода registry/plan.tsv, блоков ROADMAP.md/HANDOFF.md, реестров и
# заголовков docs/owner/*.md). Живое предъявление — ж2 контракта 084:
#   bash fixtures/parsing_hygiene_battery/run_battery.sh check_plan   → rc 0
# (после реализации и переноса И-12; ДО реализации — 4 класса пробиты: субъекта нет).
#
# Реюз, не переизобретение: toy-миры, грамматика и оракул блоков — каркас семьи
# fixtures/plan_084/_toy.sh (модель p84_world_main, p84_build, o_roadmap_block,
# o_handoff_block, p84_py). Блоки toy пишутся ОРАКУЛОМ, не gen_plan.sh: предмет профиля —
# только разбор check_plan, генератор судит батарея семьи (б1/с1).
PLAN_REPO="$(cd "$HERE/../.." && pwd -P)"
PLAN_SUBJ="$PLAN_REPO/scripts/check_plan.sh"
# shellcheck disable=SC1091
. "$PLAN_REPO/fixtures/plan_084/_toy.sh"

_plan_world() {  # <каталог> — конформный мир к0 с блоками ROADMAP/HANDOFF по оракулу
  local w="$1"
  p84_world_main
  p84_build "$w" >/dev/null 2>&1 || return 1
  o_roadmap_block > "$w.rm" && o_handoff_block > "$w.ho" || return 1
  p84_py fill "$w/ROADMAP.md" "$P84_RM_BEGIN" "$P84_RM_END" "$w.rm" || return 1
  p84_py fill "$w/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$w.ho" || return 1
}
_plan_run() {  # <корень> → PL_OUT, PL_RC (субъект из «/», корень — явно)
  PL_OUT="$(cd / && bash "$PLAN_SUBJ" --root "$1" 2>&1 </dev/null)"; PL_RC=$?
}
_plan_named() {  # <фраза> — rc 1 и строка вывода, ОКАНЧИВАЮЩАЯСЯ фразой (литерально, норма 037)
  local l
  [ "$PL_RC" -eq 1 ] || return 1
  while IFS= read -r l; do [[ "$l" == *"$1" ]] && return 0; done <<< "$PL_OUT"
  return 1
}
_plan_last_dep_row() {  # → P84_I — последняя строка модели с непустым «зависит»
  local i
  P84_I=''
  for i in "${!W_ID[@]}"; do [ "${W_DEPS[$i]}" = - ] || P84_I="$i"; done
  [ -n "$P84_I" ]
}

battery_delimiter_collision() {
  # Байты-разделители соседних слоёв ВНУТРИ значений: символьные id несут «.» и «-»
  # («V-2.xx», «CI-xxБ», «пункт-xxx»), «зависит» — списки через «,», разделы источников —
  # «a.b» с заголовками всех трёх терминаторов («a.b Текст», «a.b. Текст», «a.b»), H1
  # контрактов — «:», «—», «#», реестр — « → ». (а) Конформный мир ОБЯЗАН быть зелёным:
  # разбор, делящий id по «.»/«-» или источник по «.», ложно отвергает его. (б) Фрагмент
  # существующего id до разделителя «.» («V-2» при «V-2.xx») как зависимость — ОБЯЗАН быть
  # именованным отказом: токенизация id по «.» ложно находит фрагмент существующим.
  # (в) «|» — разделитель столбцов СЛЕДУЮЩЕГО слоя (таблица блока ROADMAP) — внутри трека той
  # же строки: ОБЯЗАН быть именованным отказом разбора «строка <N>: трек», а не столбцом таблицы.
  local w dep tr
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_plan_dc.XXXXXX")"
  if ! _plan_world "$w/a"; then rm -rf "$w"; printf 'delimiter-collision: мир не построен\n' >&2; return 1; fi
  _plan_run "$w/a"
  if [ "$PL_RC" -ne 0 ]; then
    printf 'delimiter-collision: конформный мир отвергнут, rc %s: %s\n' "$PL_RC" "$PL_OUT" >&2
    rm -rf "$w"; return 1
  fi
  _plan_last_dep_row || { rm -rf "$w"; return 1; }
  dep="${W_SYMS[3]%%.*}"
  cp -a "$w/a" "$w/b"
  p84_emit_plan set "$P84_I" 3 "${W_DEPS[$P84_I]},$dep" > "$w/b/registry/plan.tsv"
  _plan_run "$w/b"
  if ! _plan_named "зависимость на несуществующий id: ${W_ID[$P84_I]} → $dep"; then
    printf 'delimiter-collision: фрагмент «%s» id «%s» принят зависимостью, rc %s: %s\n' "$dep" "${W_SYMS[3]}" "$PL_RC" "$PL_OUT" >&2
    rm -rf "$w"; return 1
  fi
  tr="${W_TRACK[$P84_I]}"
  cp -a "$w/a" "$w/c"
  p84_emit_plan set "$P84_I" 5 "${tr:0:2}|${tr:2}" > "$w/c/registry/plan.tsv"
  _plan_run "$w/c"
  rm -rf "$w"
  if ! _plan_named "план не разбирается: строка $((P84_I + 2)): трек"; then
    printf 'delimiter-collision: «|» в треке «%s» не отвергнут разбором, rc %s: %s\n' "${tr:0:2}|${tr:2}" "$PL_RC" "$PL_OUT" >&2
    return 1
  fi
  return 0
}

battery_regex_injection() {
  # «.» в значении — литерал, не «любой символ». (а) Зависимость «<X>.<Y>» при
  # существующем «<X>z<Y>» — именованный отказ (regex-членство находит «XzY»).
  # (б) Раздел источника «a.b», когда в документе есть лишь «### axb …» (и прочие
  # околозаголовки «a.b7», «##a.b», «Раздел a.b», проза с «a.b») — «источник не
  # резолвится» (regex/префикс/поиск-по-тексту находят ловушку). Позитив — тот же мир без
  # порчи (id «V-2.xx» в списках зависимостей резолвятся ЛИТЕРАЛЬНО) — rc 0.
  local w dep src
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_plan_ri.XXXXXX")"
  if ! _plan_world "$w/a"; then rm -rf "$w"; printf 'regex-injection: мир не построен\n' >&2; return 1; fi
  _plan_run "$w/a"
  if [ "$PL_RC" -ne 0 ]; then
    printf 'regex-injection: конформный мир отвергнут, rc %s: %s\n' "$PL_RC" "$PL_OUT" >&2
    rm -rf "$w"; return 1
  fi
  _plan_last_dep_row || { rm -rf "$w"; return 1; }
  dep="$W_ZX.$W_ZY"
  cp -a "$w/a" "$w/b"
  p84_emit_plan set "$P84_I" 3 "${W_DEPS[$P84_I]},$dep" > "$w/b/registry/plan.tsv"
  _plan_run "$w/b"
  if ! _plan_named "зависимость на несуществующий id: ${W_ID[$P84_I]} → $dep"; then
    printf 'regex-injection: «%s» принят при существующем «%sz%s», rc %s: %s\n' "$dep" "$W_ZX" "$W_ZY" "$PL_RC" "$PL_OUT" >&2
    rm -rf "$w"; return 1
  fi
  src="$W_DOC1#$W_MISS_SEC"
  cp -a "$w/a" "$w/c"
  p84_emit_plan set 0 4 "$src" > "$w/c/registry/plan.tsv"
  _plan_run "$w/c"
  rm -rf "$w"
  if ! _plan_named "источник не резолвится: ${W_ID[0]}: $src"; then
    printf 'regex-injection: раздел «%s» найден по околозаголовку, rc %s: %s\n' "$W_MISS_SEC" "$PL_RC" "$PL_OUT" >&2
    return 1
  fi
  return 0
}

battery_silent_drop() {
  # (а) Блок HANDOFF из ДВУХ строк, закрытый (done) — ПОСЛЕДНИЙ: проверка, судящая только
  # первую строку блока, молча теряет его — ожидание «done-пункт стоит следующим: <id>».
  # (б) Висячая зависимость — в ПОСЛЕДНЕЙ строке плана, последним элементом списка;
  # (б2) то же без завершающего LF у последней строки — цикл `while read` без
  # `|| [ -n "$line" ]` теряет строку молча. Ожидание (б2) — именованный отказ (висячая
  # зависимость ЛИБО «план не разбирается: строка <N>:» этой строки), не rc 0.
  local w num last n dep v si
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_plan_sd.XXXXXX")"
  if ! _plan_world "$w/a"; then rm -rf "$w"; printf 'silent-drop: мир не построен\n' >&2; return 1; fi
  p84_idx_of "${W_SYMS[0]}"; si="$P84_I"
  num="${W_NUMS[0]}"; p84_idx_of "$num"
  {
    printf '%s\n\n' "$P84_HO_TITLE"
    printf -- '- %s · пара %s · не начат · трек %s\n' "${W_SYMS[0]}" "${W_PAIR[$si]}" "${W_TRACK[$si]}"
    printf -- '- %s · пара %s · номер выдан · трек %s\n' "$num" "${W_PAIR[$P84_I]}" "${W_TRACK[$P84_I]}"
  } > "$w/ho2"
  cp -a "$w/a" "$w/b"
  p84_py fill "$w/b/HANDOFF.md" "$P84_HO_BEGIN" "$P84_HO_END" "$w/ho2"
  p84_tag "$w/b" "done/contracts/$num/1" >/dev/null 2>&1
  _plan_run "$w/b"
  if ! _plan_named "done-пункт стоит следующим: $num"; then
    printf 'silent-drop: закрытый %s второй строкой блока HANDOFF потерян, rc %s: %s\n' "$num" "$PL_RC" "$PL_OUT" >&2
    rm -rf "$w"; return 1
  fi
  last=$(( ${#W_ID[@]} - 1 )); n=$(( ${#W_ID[@]} + 1 )); p84_sfx 4; dep="нет-$P84_S"
  cp -a "$w/a" "$w/c"
  if [ "${W_DEPS[$last]}" = - ]; then v="$dep"; else v="${W_DEPS[$last]},$dep"; fi
  p84_emit_plan set "$last" 3 "$v" > "$w/c/registry/plan.tsv"
  _plan_run "$w/c"
  if ! _plan_named "зависимость на несуществующий id: ${W_ID[$last]} → $dep"; then
    printf 'silent-drop: висячая зависимость последней строки потеряна, rc %s: %s\n' "$PL_RC" "$PL_OUT" >&2
    rm -rf "$w"; return 1
  fi
  printf '%s' "$(cat "$w/c/registry/plan.tsv")" > "$w/c/registry/plan.tsv.nolf"
  mv "$w/c/registry/plan.tsv.nolf" "$w/c/registry/plan.tsv"
  _plan_run "$w/c"
  rm -rf "$w"
  if [ "$PL_RC" -ne 1 ] || { ! _plan_named "зависимость на несуществующий id: ${W_ID[$last]} → $dep" \
       && [[ "$PL_OUT" != *"план не разбирается: строка $n:"* ]]; }; then
    printf 'silent-drop: последняя строка без LF потеряна молча, rc %s: %s\n' "$PL_RC" "$PL_OUT" >&2
    return 1
  fi
  return 0
}

battery_self_application_green() {
  # (а) Само-применение (ж1 контракта 084): check_plan.sh на ЖИВОМ дереве — rc 0.
  # (б, ДОДЕЛ АРБИТРАЖА 041 п.2 — verdicts/arbitration/contracts-041-battery-example-based-
  # predel.md, «Решение по существу» п.2): один позитив не отличает честный гард от стаба,
  # принимающего «похожее на dev-harness» дерево. Негатив — одноразовый клон ЖИВОЙ истории
  # (объекты и теги — настоящие), поверх которого лежат ТЕ ЖЕ входы, что судит (а): рабочие
  # копии registry/plan.tsv, registry/contracts.tsv, registry/closed-without-done.tsv,
  # ROADMAP.md, HANDOFF.md и docs/owner/ (перечень — «Разбираемый чужой ввод» §Модель угроз
  # 084; без наложения клон судил бы HEAD, а (а) — рабочее дерево). Множество порч ВЫВОДИТСЯ
  # из живого registry/plan.tsv (single source — КАЖДАЯ строка плана, не ручная константа): у
  # строки k пустеет поле трека → ожидание rc 1 «нет трека: <id строки k>» (id — из той же
  # строки, той же переменной цикла). Стаб с ответом по байтам/пути дерева проходит (а) и
  # ловится на (б); класс «различить харнесс» (арбитраж З2) — именованный остаток.
  local out rc w k id f tested=0 bad=0
  out="$(cd / && bash "$PLAN_SUBJ" --root "$PLAN_REPO" 2>&1 </dev/null)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    printf 'БАТАРЕЯ %s: self-application (а) — живое дерево красно, rc %s: %s\n' "${PROFILE_NAME:-check_plan}" "$rc" "$out" >&2
    return 1
  fi
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_plan_self.XXXXXX")"
  if ! git clone -q --shared "$PLAN_REPO" "$w/clone" 2>/dev/null; then
    printf 'БАТАРЕЯ %s: self-application (б) — клон живой истории не создан\n' "${PROFILE_NAME:-check_plan}" >&2
    rm -rf "$w"; return 1
  fi
  for f in registry/plan.tsv registry/contracts.tsv registry/closed-without-done.tsv ROADMAP.md HANDOFF.md; do
    rm -f "$w/clone/$f"
    if [ -f "$PLAN_REPO/$f" ]; then mkdir -p "$(dirname "$w/clone/$f")"; cp "$PLAN_REPO/$f" "$w/clone/$f"; fi
  done
  rm -rf "$w/clone/docs/owner"
  if [ -d "$PLAN_REPO/docs/owner" ]; then mkdir -p "$w/clone/docs"; cp -a "$PLAN_REPO/docs/owner" "$w/clone/docs/owner"; fi
  if [ ! -f "$w/clone/registry/plan.tsv" ]; then
    printf 'БАТАРЕЯ %s: self-application (б) — живого registry/plan.tsv нет\n' "${PROFILE_NAME:-check_plan}" >&2
    rm -rf "$w"; return 1
  fi
  cp "$w/clone/registry/plan.tsv" "$w/plan.orig"
  k=1
  while IFS= read -r id; do
    k=$((k + 1))
    [ -n "$id" ] || continue
    tested=$((tested + 1))
    awk -F'\t' -v OFS='\t' -v k="$k" 'NR == k { $6 = "" } { print }' "$w/plan.orig" > "$w/clone/registry/plan.tsv"
    _plan_run "$w/clone"
    if ! _plan_named "нет трека: $id"; then
      bad=$((bad + 1))
      printf 'БАТАРЕЯ %s: self-application-негатив пробит на строке %d (%s), rc %s: %s\n' \
        "${PROFILE_NAME:-check_plan}" "$k" "$id" "$PL_RC" "$(printf '%s' "$PL_OUT" | sed -n 1p)" >&2
    fi
  done < <(awk -F'\t' 'NR > 1 { print $1 }' "$w/plan.orig")
  rm -rf "$w"
  [ "$tested" -gt 0 ] || { printf 'БАТАРЕЯ %s: self-application (б) — пустая выборка\n' "${PROFILE_NAME:-check_plan}" >&2; return 1; }
  [ "$bad" -eq 0 ]
}
