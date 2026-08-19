#!/usr/bin/env bash
# scripts/check_skills.sh — барьер на подлинность и комплектность скилов по контракту 003.
#
# Восемь ветвей:
#   (а) скил не обнаружен omp — ЖИВАЯ проба, только с --live: omp читает skill://<имя>
#       инструментом read и цитирует дословно строку шапки «# Адаптация: …», которой в
#       запросе нет; бинарь обязан совпадать с пином config/harness_pin.json (sha256).
#       Базовый прогон ветвь (а) НЕ заявляет — зелёного пропуска без omp нет.
#   (б) имя каталога ≠ имени фронтматтера
#   (в) hash шапки-адаптации ≠ значению из блоба высшей заморозки контракта (не зашит в барьер)
#   (г) каталог в skills/ вне объявленного множества четырёх
#   (д) зеркало .agents/skills ≠ skills/ — ПОЛНОЕ дерево корней целиком, включая скрытые
#       имена корня; omp 17.2.10 читает ПРОЕКТНОЕ .agents/skills (Н-34)
#   (е) тело после шапки-адаптации не совпадает со снимком upstream
#   (ж) псевдоним grill-me не документирован в шапке grilling
#   (з) полнота красных фикстур: 8 на родителе первого коммита; ВСЕ коммиты по ним — architect
#
#   bash scripts/check_skills.sh [--live] [корень]   — live добавляет живую пробу (а)
#
# Коды возврата: 0 — зелёный, 1 — расхождение, 2 — нечем проверить (сеть, отсутствие omp в live).
set -uo pipefail

LIVE=0
REPO=""
for arg in "$@"; do
  case "$arg" in
    --live) LIVE=1 ;;
    *)      REPO="$arg" ;;
  esac
done
REPO="${REPO:-$(pwd)}"
REPO_ABS="$(cd "$REPO" 2>/dev/null && pwd)" || { printf 'ОТКАЗ: корень %s недоступен\n' "$REPO" >&2; exit 1; }
SKILLS_DIR="$REPO/skills"
EXPECTED="grilling writing-for-agents tdd diagnosing-bugs"
EMPTY_TREE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
EXPECTED_PREFIX="9c9f36c"

die()  { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
ok()   { printf '  ok   %s\n' "$*" >&2; }

# ── (в) hash контракта: чтение снимка и сверка префикса ───────────────────────
# Барьер НЕ зашивает hash: значение берётся из блоба высшей заморозки контракта 003, который
# хранится в git-теге frozen/contracts/003/<v>. Файл ищется среди contracts/003*.md; первый
# матч — это и есть предмет сверки. Префикс 9c9f36c — единственное, что барьер знает об
# источнике: всё, что идёт после, живёт в контракте.
contract_file=""
for path in "$REPO/contracts/003"*.md; do
  [ -f "$path" ] && contract_file="$path" && break
done

contract_hash=""
if [ -n "$contract_file" ]; then
  if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
    frozen_blob="$(git -C "$REPO" show "frozen/contracts/003/1:$contract_file" 2>/dev/null || true)"
    if [ -n "$frozen_blob" ]; then
      contract_hash=$(printf '%s\n' "$frozen_blob" | grep -oE '9c9f36c[a-f0-9]*' | head -1)
    fi
  fi
  if [ -z "$contract_hash" ]; then
    contract_hash=$(grep -oE '9c9f36c[a-f0-9]*' "$contract_file" 2>/dev/null | head -1)
  fi
fi

if [ -z "$contract_hash" ]; then
  ok "ветвь (в): контракт 003 не найден — сверка hash пропущена"
elif [[ "$contract_hash" != "$EXPECTED_PREFIX"* ]]; then
  die "hash шапки не совпадает: контракт «$contract_file» начинается с «${contract_hash:0:12}», ожидается начало с $EXPECTED_PREFIX"
else
  ok "ветвь (в): hash контракта начинается с $EXPECTED_PREFIX"
fi

# ── (а) и (б) по каждому скилу в EXPECTED ────────────────────────────────────
# Скилы есть? Отсутствие skills/ законно ТОЛЬКО в изолированном контрактном каталоге
# (там проверяется одна ветвь (в)). Если история коммитов по skills/ есть — это
# порченный чекаут ПРЕДМЕТА, и исчезновение предмета не может быть зелёным
# (адверсарий, круг 4, находка 1).
if [ ! -d "$SKILLS_DIR" ]; then
  if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 \
     && [ -n "$(git -C "$REPO" log --reverse --format=%H -- skills/ scripts/check_skills.sh 2>/dev/null | head -1)" ]; then
    die "предмет исчез: skills/ отсутствует, а история коммитов по skills/ есть — это порченный чекаут предмета, не изолированный контракт"
  fi
  ok "skills/ отсутствует — ветви (а)-(г), (е), (ж) пропущены"
else
  # Поиск omp — один раз на прогон, не по разу на скил.
  omp_bin="$(command -v omp 2>/dev/null || true)"

  # ── (а) ЖИВАЯ ПРОБА: ворота — только --live, пин обязателен ──────────────────
  # Базовый прогон ветвь (а) не заявляет вовсе: без omp зелёного пропуска нет (контракт
  # 003 v3, закрытие обхода «CI без omp молчит зелёным»). В live: omp обязан быть, и его
  # бинарь обязан совпадать с пином репозитория — ответу подменного бинаря верить нельзя;
  # совместная подмена бинаря и пина в клоне — объявленный остаточный риск (cognitive-only),
  # ловцы: анти-плацебо читает объявленное окружение фикстур, подлинность в честном
  # прогоне держит check:overlay.
  live_ok=0
  if [ "$LIVE" -eq 1 ]; then
    [ -n "$omp_bin" ] || skip "нет omp в PATH — живую пробу нечем провести (в CI — объявленное исключение паритета)"
    pin="$REPO/config/harness_pin.json"
    [ -f "$pin" ] || skip "нет пина $pin — sha бинаря не с чем сверить"
    want_sha="$(grep -oP '(?<="sha256": ")[0-9a-f]{64}' "$pin" | head -1)"
    [ -n "$want_sha" ] || die "пин $pin не назвал sha256 — живой пробе нечего сверять"
    got_sha="$(sha256sum "$(readlink -f "$omp_bin")" | cut -d' ' -f1)"
    [ "$got_sha" = "$want_sha" ] \
      || die "omp не совпадает с пином: $got_sha против $want_sha — ответу живой пробы нельзя верить (подлинность бинаря держит check:overlay)"
    live_ok=1
  else
    ok "ветвь (а): живая проба не заявлена базовым прогоном — она в check:skills-live"
  fi
  for skill in $EXPECTED; do
    dir="$SKILLS_DIR/$skill"
    f="$dir/SKILL.md"

    if [ ! -d "$dir" ]; then
      rogue_dir=""
      for d in "$SKILLS_DIR"/*; do
        [ -d "$d" ] || continue
        [ -f "$d/SKILL.md" ] || continue
        fm="$(awk '/^name:/ { sub(/^name:[[:space:]]*/, ""); print; exit }' "$d/SKILL.md")"
        [ "$fm" = "$skill" ] && rogue_dir="$(basename "$d")" && break
      done
      if [ -n "$rogue_dir" ]; then
        die "имя каталога ≠ имени фронтматтера: каталог «$rogue_dir» объявлен скилом «$skill», но называется иначе"
      fi
      die "скил «$skill» не обнаружен omp: каталог $dir отсутствует"
    fi

    if [ ! -f "$f" ]; then
      die "скил «$skill» не обнаружен omp: файл $f отсутствует"
    fi

    fm_name=$(awk '/^name:/ { sub(/^name:[[:space:]]*/, ""); print; exit }' "$f")

    # (а) скил не обнаружен omp: имя во фронтматтере должно входить в EXPECTED, иначе
    # omp не нашёл бы его — фильтр по объявленному множеству ломается.
    if ! printf '%s\n' $EXPECTED | grep -qxF "$fm_name"; then
      die "скил «$skill» не обнаружен omp: во фронтматтере «$fm_name», а объявленное множество $EXPECTED"
    fi
    ok "скил «$skill» обнаружен omp (структурно)"

    # (а) ЖИВАЯ ПРОБА (только --live), контракт 003 реестровая v4 итерация 2: доказательство —
    # КОРРЕЛИРОВАННАЯ пара событий в json-потоке по одному toolCallId (арбитраж
    # orakul-korreljacija): у tool_execution_start args.path РАВЕН skill://<имя>; в
    # tool_execution_end того же вызова — дословная строка шапки (уникальна, на русском, в
    # запросе отсутствует) и resolvedPath после нормализации — проектный
    # .agents/skills/<имя>/SKILL.md. Отсутствие любого поля — отказ: у запиненного бинаря
    # resolvedPath при skill://-резолве есть всегда. Эхо argv, константы, чтение обычного
    # файла и одноимённый HOME-скил не проходят по построению. Пин проверен выше, один раз.
    if [ "$live_ok" -eq 1 ]; then
      want_line="$(grep -m1 '^# Адаптация: ' "$f")"
      [ -n "$want_line" ] || die "скил «$skill» не обнаружен omp: в шапке нет строки «# Адаптация:» для живой пробы"
      want_path="$REPO_ABS/.agents/skills/$skill/SKILL.md"
      prompt="Use the read tool on the URI skill://$skill, find the line that starts with '# Адаптация:' and output that line verbatim, character for character. Nothing else."
      stream=$(timeout 180 "$omp_bin" --no-session --mode json -p "$prompt" 2>&1)
      rc=$?
      if [ "$rc" -ne 0 ]; then
        die "скил «$skill» не обнаружен omp: вызов завершился кодом $rc, поток «$(printf '%s' "$stream" | tail -c 300)»"
      fi
      # Старт события с точным равенством args.path (границы — кавычки JSON).
      call_id="$(printf '%s\n' "$stream" | grep '"type":"tool_execution_start"' \
                 | grep '"toolName":"read"' | grep -F "\"path\":\"skill://$skill\"" \
                 | sed -n 's/.*"toolCallId":"\([^"]*\)".*/\1/p' | head -1)"
      if [ -z "$call_id" ]; then
        die "скил «$skill» не обнаружен omp: в потоке нет вызова read с args.path = skill://$skill — резолв не предъявлен"
      fi
      end_line="$(printf '%s\n' "$stream" | grep '"type":"tool_execution_end"' | grep -F "\"toolCallId\":\"$call_id\"" | head -1)"
      if [ -z "$end_line" ]; then
        die "скил «$skill» не обнаружен omp: нет tool_execution_end вызова $call_id — пара не коррелирована"
      fi
      if ! printf '%s' "$end_line" | grep -qF -- "$want_line"; then
        die "скил «$skill» не обнаружен omp: результат вызова не содержит дословно строку шапки «$want_line»"
      fi
      got_path="$(printf '%s' "$end_line" | sed -n 's/.*"resolvedPath":"\([^"]*\)".*/\1/p' | head -1)"
      if [ -z "$got_path" ]; then
        die "скил «$skill» не обнаружен omp: у результата нет resolvedPath — у запиненного бинаря поле есть всегда; смена схемы событий — правка контракта через upgrade_policy пина"
      fi
      if [ "$(readlink -f "$got_path")" != "$want_path" ]; then
        die "скил «$skill» не обнаружен omp: resolvedPath «$got_path» — не проектный $want_path (одноимённый скил из HOME или чтение обычного файла)"
      fi
      ok "скил «$skill» — коррелированная пара событий: skill://$skill резолвится в проектное зеркало"
    fi

    # (б) имя каталога ≠ имени фронтматтера
    if [ "$fm_name" != "$skill" ]; then
      die "имя каталога «$skill» ≠ имени фронтматтера «$fm_name»"
    fi
    ok "имя каталога «$skill» = имя фронтматтера"

    # (в) hash шапки-адаптации (если шапка есть)
    if [ -n "$contract_hash" ]; then
      adaptation_hash=$(grep -m1 '^# Источник: ' "$f" | sed 's/^# Источник: //')
      if [ -n "$adaptation_hash" ]; then
        case "$adaptation_hash" in
          "$contract_hash"*) ok "hash шапки $skill совпадает с контрактом" ;;
          *) die "hash шапки не совпадает: $skill «$adaptation_hash» не начинается с «$contract_hash»" ;;
        esac
      else
        ok "ветвь (в): $skill без шапки-адаптации — сверка пропущена"
      fi
    fi
  done
  # ── (г) состав skills/ ────────────────────────────────────────────────────────
  # ls -A: скрытые имена — часть состава (адверсарий, круг 4, находка 2: пятый
  # каталог с точкой в имени проходил мимо ls).
  found=$(ls -A "$SKILLS_DIR" 2>/dev/null | sort | tr '\n' ' ' | sed 's/ *$//')
  expected=$(printf '%s\n' $EXPECTED | sort | tr '\n' ' ' | sed 's/ *$//')
  if [ "$found" != "$expected" ]; then
    rogue=$(comm -23 <(printf '%s\n' $found | tr ' ' '\n' | sort -u) \
                   <(printf '%s\n' $EXPECTED | sort -u))
    die "каталог вне объявленного множества: найдено «$found», ожидается «$expected»; лишний: $rogue"
  fi
  ok "состав skills/ точно совпадает с объявленным множеством (включая скрытые имена)"

  # ── (ж) псевдоним grill-me в шапке grilling ───────────────────────────────────
  grill_file="$SKILLS_DIR/grilling/SKILL.md"
  if [ ! -f "$grill_file" ] || ! grep -qF 'grill-me' "$grill_file"; then
    die "псевдоним grill-me не документирован в шапке grilling"
  fi
  ok "псевдоним grill-me документирован в шапке grilling"

  # ── (е) тело после шапки-адаптации vs upstream ────────────────────────────────
  cmp_body() {
    local f1="$1" f2="$2"
    local n1 n2
    n1=$(grep -n '^---$' "$f1" 2>/dev/null | head -1 | cut -d: -f1)
    n2=$(grep -n '^---$' "$f2" 2>/dev/null | head -1 | cut -d: -f1)
    [ -n "$n1" ] && [ -n "$n2" ] || return 1
    cmp -s <(tail -n +"$n1" "$f1") <(tail -n +"$n2" "$f2")
  }

  for skill in $EXPECTED; do
    case "$skill" in
      grilling|writing-for-agents) category="productivity" ;;
      tdd|diagnosing-bugs)         category="engineering"  ;;
    esac

    f="$SKILLS_DIR/$skill/SKILL.md"
    snapshot=""
    for path in "$REPO/tmp/snapshot/skills/$skill/SKILL.md" \
                "$REPO/tmp/snapshot/skills/$category/$skill/SKILL.md"; do
      if [ -f "$path" ]; then snapshot="$path"; break; fi
    done

    if [ -n "$snapshot" ]; then
      cmp_body "$f" "$snapshot" || die "тело не совпадает со снимком $snapshot"
      ok "тело $skill совпадает со снимком"
    elif [ -n "$contract_hash" ]; then
      url="https://raw.githubusercontent.com/mattpocock/skills/$contract_hash/skills/$category/$skill/SKILL.md"
      tmp=$(mktemp)
      if ! curl -sSf --max-time 10 "$url" -o "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        skip "сеть недоступна для сверки с upstream: $url"
      fi
      if ! cmp_body "$f" "$tmp"; then
        rm -f "$tmp"
        die "тело не совпадает со снимком upstream по $url"
      fi
      rm -f "$tmp"
      ok "тело $skill совпадает со снимком upstream"
    else
      ok "ветвь (е): для $skill нет ни снимка, ни контракта — сверка пропущена"
    fi
  done
  # ── (д) зеркало разложения: .agents/skills == skills/, ПОЛНОЕ дерево ─────────
  # Контракт 003 реестровая v4: канонические корни omp — ~/.agents/skills и ПРОЕКТНЫЙ
  # .agents/skills (изолированные замеры 2026-08-19, Н-34); .omp/skills и
  # $HOME/.omp/agent/skills корнями не являются. Зеркало коммитится рядом с skills/
  # по прецеденту .omp/agents из roles/: чистый чекаут получает скилы без прогонов —
  # и omp обнаруживает их прямо из проекта; дрейф ловит эта ветвь.
  MIRROR="$REPO/.agents/skills"
  if [ ! -d "$MIRROR" ]; then
    die "разложение отсутствует: нет $MIRROR — omp читает проектный корень .agents/skills, зеркало не разложено"
  fi
  mirror_found="$(ls -A "$MIRROR" 2>/dev/null | sort | tr '\n' ' ' | sed 's/ *$//')"
  if [ "$mirror_found" != "$expected" ]; then
    die "состав зеркала .agents/skills неточен: найдено «$mirror_found», ожидается «$expected»"
  fi
  # ПОЛНОЕ дерево ЦЕЛИКОМ, а не по четырём ожидаемым подкаталогам: корневые
  # скрытые файлы и любой неоговоренный элемент ловятся одним сравнением корней
  # (адверсарий, круг 4, находка 2).
  if ! diff_out=$(diff -r --brief "$SKILLS_DIR" "$MIRROR" 2>&1); then
    die "зеркало не совпадает: полное дерево .agents/skills отличается от skills/:
$diff_out"
  fi
  ok "зеркало .agents/skills совпадает с skills/ (полное дерево, включая корень)"
fi

# ── (з) полнота красных фикстур ───────────────────────────────────────────────
if git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  first_commit=$(git -C "$REPO" log --reverse --format=%H -- skills/ scripts/check_skills.sh 2>/dev/null | head -1)
  if [ -n "$first_commit" ]; then
    parent=$(git -C "$REPO" rev-parse "$first_commit^" 2>/dev/null || echo "$EMPTY_TREE")
    fixtures_at_parent=$(git -C "$REPO" ls-tree --name-only "$parent" -- fixtures/check_skills/ 2>/dev/null || true)

    missing=0
    for f in case_a_ne_obnaruzhen.sh case_b_imja_kataloga.sh case_v_hash_ne_sovpadaet.sh \
             case_g_katalog_vne_mnozhestva.sh case_d_profil_iz_pustogo.sh case_e_telo_ne_sovpadaet.sh \
             case_z_polnota_fikstur.sh case_zh_psevdonim_grill_me.sh; do
      if ! printf '%s\n' "$fixtures_at_parent" | grep -q "$f"; then
        missing=$((missing + 1))
      fi
    done

    if [ "$missing" -gt 0 ]; then
      die "полнота фикстур: на родителе первого коммита по skills/ отсутствует $missing из 8 фикстур"
    fi
    # Находка адверсария (§3 вердикта о закрытии, второй подход): «первый автор —
    # architect» не закрывает пробу — implementer коммитил фикстуры ПОЗЖЕ первого
    # коммита. Судятся ВСЕ коммиты, когда-либо затрагивавшие fixtures/check_skills/:
    # каждый обязан быть от architect.
    bad_authors=$(git -C "$REPO" log --format='%an' -- fixtures/check_skills/ 2>/dev/null \
                  | LC_ALL=C sort -u | grep -vxF 'architect' || true)
    if [ -n "$bad_authors" ]; then
      named="$(printf '%s' "$bad_authors" | tr '\n' ' ')"
      die "полнота фикстур: коммиты по fixtures/check_skills/ есть от «$named»— а не от architect (Q8-C)"
    fi
    ok "фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect"
  else
    ok "ветвь (з): нет коммитов по skills/ — проверка полноты фикстур неприменима"
  fi
else
  ok "ветвь (з): не репозиторий git — проверка полноты фикстур неприменима"
fi

printf 'барьер зелёный: 8 ветвей пройдены\n' >&2
