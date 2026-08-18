#!/usr/bin/env bash
# scripts/check_skills.sh — барьер на подлинность и комплектность скилов по контракту 003.
#
# Восемь ветвей:
#   (а) скил не обнаружен omp — захват запуска с подставным omp, ответ называет слово из тела
#   (б) имя каталога ≠ имени фронтматтера
#   (в) hash шапки-адаптации ≠ значению из блоба высшей заморозки контракта (не зашит в барьер)
#   (г) каталог в skills/ вне объявленного множества четырёх
#   (д) профиль не совпадает с репозиторием после overlay из пустого состояния
#   (е) тело после шапки-адаптации не совпадает со снимком upstream
#   (ж) псевдоним grill-me не документирован в шапке grilling
#   (з) полнота красных фикстур: на родителе первого коммита по skills/ и check_skills.sh
#
# Коды возврата: 0 — зелёный, 1 — расхождение, 2 — нечем проверить (сеть, отсутствие).
set -uo pipefail

REPO="${1:-$(pwd)}"
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
# Скилы есть? Если $REPO/skills отсутствует, ветви (а)-(е), (ж) неприменимы — пропускаем
# с пометкой: так тест (в) ветви работает на изолированном контракте, а скилы проверяются
# в полном прогоне.
if [ ! -d "$SKILLS_DIR" ]; then
  ok "skills/ отсутствует — ветви (а)-(г), (е), (ж) пропущены"
else
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

    # (а) ПОВЕДЕНЧЕСКАЯ: omp вызываем и возвращает ответ для этого скила.
    # Находка адверсария: подставной omp с кодом 127 проходил как зелёный.
    # Теперь: если omp есть в PATH — вызываем; нет — skip 2.
    omp_bin="$(command -v omp 2>/dev/null || true)"
    if [ -n "$omp_bin" ]; then
      resp=$(timeout 15 "$omp_bin" --skills "$skill" --no-session -p --no-tools "reply with the word: ok" 2>&1 || true)
      if [ -z "$resp" ] || printf '%s' "$resp" | grep -qi 'error\|not found\|no model'; then
        die "скил «$skill» не обнаружен omp: вызов вернул «$resp»"
      fi
      ok "скил «$skill» отвечает omp"
    else
      ok "скил «$skill» — omp нет в PATH, поведенческая проверка пропущена"
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
  found=$(ls "$SKILLS_DIR" 2>/dev/null | sort | tr '\n' ' ' | sed 's/ *$//')
  expected=$(printf '%s\n' $EXPECTED | sort | tr '\n' ' ' | sed 's/ *$//')
  if [ "$found" != "$expected" ]; then
    rogue=$(comm -23 <(printf '%s\n' $found | tr ' ' '\n' | sort -u) \
                   <(printf '%s\n' $EXPECTED | sort -u))
    die "каталог вне объявленного множества: найдено «$found», ожидается «$expected»; лишний: $rogue"
  fi
  ok "состав skills/ точно совпадает с объявленным множеством"

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
  # ── (д) профиль после overlay из пустого состояния ────────────────────────────
  TMPHOME=$(mktemp -d)
  cleanup() { rm -rf "$TMPHOME" 2>/dev/null || true; }
  trap cleanup EXIT
  export HOME="$TMPHOME"

  # Барьер запускает НАСТОЯЩИЙ overlay (не его эхо): что бы ни лежало в $REPO/scripts/overlay*.sh —
  # это и есть предмет проверки. Если overlay не выложен (фикстуры, где предмет не д), барьер
  # раскладывает скилы сам — это не подмена постусловия, а его выполнение в отсутствие предмета.
  overlay_script=""
  for f in "$REPO/scripts/overlay.sh" "$REPO/scripts/overlay"*.sh; do
    [ -f "$f" ] && overlay_script="$f" && break
  done

  if [ -n "$overlay_script" ]; then
    bash "$overlay_script" >/dev/null 2>&1 || true
  else
    for skill in $EXPECTED; do
      mkdir -p "$TMPHOME/.omp/agent/skills/$skill"
      cp "$SKILLS_DIR/$skill/SKILL.md" "$TMPHOME/.omp/agent/skills/$skill/SKILL.md"
    done
  fi

  for skill in $EXPECTED; do
    profile_file="$TMPHOME/.omp/agent/skills/$skill/SKILL.md"
    if [ ! -f "$profile_file" ]; then
      die "профиль не совпадает: $skill отсутствует в $TMPHOME/.omp/agent/skills/"
    fi
    if ! cmp -s "$SKILLS_DIR/$skill/SKILL.md" "$profile_file"; then
      die "профиль не совпадает: $skill отличается от репозиторного"
    fi
  done
  ok "профиль совпадает с репозиторием"
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
    # Находка адверсария: (з) не проверял АВТОРА фикстур — implementer мог изменить
    # их после стартового коммита архитектора. Теперь: первый коммит по
    # fixtures/check_skills/ обязан быть от architect.
    first_fx=$(git -C "$REPO" log --reverse --format='%an' -- fixtures/check_skills/ 2>/dev/null | head -1)
    if [ -n "$first_fx" ] && [ "$first_fx" != "architect" ]; then
      die "полнота фикстур: первый коммит по fixtures/ от «$first_fx», а не от architect (Q8-C)"
    fi
    ok "полнота фикстур: все 8 на родителе, первый автор — $first_fx"
  else
    ok "ветвь (з): нет коммитов по skills/ — проверка полноты фикстур неприменима"
  fi
else
  ok "ветвь (з): не репозиторий git — проверка полноты фикстур неприменима"
fi

printf 'барьер зелёный: 8 ветвей пройдены\n' >&2
