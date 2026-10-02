#!/usr/bin/env bash
# 072-БАТАРЕЯ (вторая дверь оркестратора) — «дверь перед критиком»:
# scripts/pre_critic.sh <contract> — ЕДИНСТВЕННЫЙ вход к спавну критика
# (слово владельца 2026-10-01 вечер, дословно в contracts/072-* §Предмет):
# (а) npm run check:precision-gate -- . <contract> → красное = отказ;
# (б) npm run check:spec-ready -- . <contract> → красное = отказ;
# (в) эвристика Н-39 по тексту контракта: строка, где стаб (s<N>|стаб|
# обманка) связан глаголом привязки (умирает|ловится|краснеет|падает) с
# клеткой/входом/кейсом → именованный отказ «Н-39: привязка стаба в прозе,
# строка N»; порог отсекает отметку от предложения (правило 8: цитата в
# кавычках «…» „…" "…" `…` — отметка, не предложение); ложное срабатывание
# — правка формулировки, не обход. Отказ = назад архитектору, критик не
# зовётся. Строка роли: «критик спавнится только после rc 0
# scripts/pre_critic.sh».
#
# Дом семьи — fixtures/dver_pered_kritikom/ (probe-only, 034: носитель
# red_* вне case_*-глоба раннера; каталог НЕ назван по барьерному ключу —
# не попадает в чужие glob'ы, урок А-314), раннер — fixtures/_krasnye_072.sh
# (агрегатор обеих дверей 072). До-заморозочный носитель закоммичен
# АРХИТЕКТОРОМ (красные предъявления ДО круга критика; прецеденты 058/070).
#
# Структура:
#   1. СТАБ-ПАК (6 обманных стабов двери, ручки STUB_*) — зелёный ДО и
#      ПОСЛЕ реализации: каждый стаб умирает на СВОЕЙ клетке; диффпроба —
#      те же стабы БЕЗ ручек проходят те же клетки.
#   2. г0 «предмет отсутствует» — fail-fast по НОСИТЕЛЮ: в дереве нет
#      scripts/pre_critic.sh → клетки не исполняются, rc 1 (ДО-мера пачки:
#      grep -rc pre_critic scripts/ roles/ = 0).
#   3. ЧЕСТНАЯ ЧАСТЬ (клетки ч1..ч6) — зелёная ПОСЛЕ реализации; четыре
#      владелицы ветви — дословно из слова владельца: (i) контракт с
#      Б2-формой ПЕРЕСЕЧЕНИЕ → rc 1; (ii) строка «s1 умирает на клетке X»
#      → rc 1 «Н-39: привязка стаба в прозе»; (iii) честный → rc 0; плюс
#      (iv) контракт красный для spec-ready → rc 1 (нога (б) слова
#      владельца); плюс усиление по вердикту адверсария 072-r1: ч5 — та
#      же связка, РАЗНЕСЁННАЯ переводом строки («s2 ловится»/«на входе
#      X») → rc 1 с номером ПЕРВОЙ строки связки (Б1); ч6 — отличимый
#      красный вход с токеном s2 (не s1) → ловит мутант, сузивший словарь
#      `s[0-9]+|стаб|обманка` до константы `s1` (Б3).
#
# Привязки обманных стабов к входам (Н-39 — живут ЗДЕСЬ, в коде батареи,
# не в прозе контракта; каждый стаб красен на входе, где его дефект
# НАБЛЮДАЕМ, и честен без ручки на том же входе):
#   s1 STUB_SKIP_PRECISION «не зовёт precision-гейт» — красен на входе (i)
#        (Б2-форма ПЕРЕСЕЧЕНИЕ): красный черновик пропущен, rc 0.
#   s2 STUB_SKIP_SPECREADY «не зовёт spec-ready» — красен на входе (iv)
#        (проба красна без заявленной причины): rc 0.
#   s3 STUB_SKIP_N39 «не сканирует прозу» — красен на входе (ii)
#        (привязка стаба в прозе): rc 0, Н-39 обойдён.
#   s4 STUB_FLAG_QUOTED «порог не отсекает цитату» — красен на входе (iii)
#        (честный контракт с ЦИТИРОВАННОЙ отметкой): ложный отказ на
#        честном черновике — дверь делает контракты ненаписуемыми.
#   s5 STUB_SILENT «отказывает без пиннутого маркера» — красен на входе
#        (ii): rc 1, НО нет дословного «Н-39: привязка стаба в прозе,
#        строка N» — отказ безымянный, назад архитектору без причины.
#   s6 STUB_WRONG_TARGET «судит умолчательный контракт» — красен на входе
#        (i): зовёт ключ с ЗАПЕЧЁННЫМИ аргументами (реальная форма
#        package.json: check:precision-gate несёт contracts/043), проброс
#        «npm run … -- . <contract>» судит 043, а не переданный черновик —
#        нога (а) пуста, красный черновик проходит rc 0.
#
# Демаркация контрпримеров (уроки 019): КОНФОРМНЫЕ входы по грамматике
# предмета — настоящий git-репозиторий (main, один коммит) с копиями
# РЕАЛЬНЫХ scripts/check_precision_gate.sh и check_spec_ready.sh и их
# библиотеками, toy package.json с БЕЗАРГУМЕНТНЫМИ npm-ключами (форма,
# которую реализация обязана дать настоящему package.json — иначе проброс
# судит 043, дефект s6) и минимальным ci.yml (паритет); вход-контракт —
# файл в contracts/ с корректной шапкой. Валидный контрпример =
# инвариантность к путям/именам (toy-пути случайны, mktemp) ∧ расхождение
# честного и стаба на КОНФОРМНОМ входе.
#
# ГИГИЕНА: батарея ничего не пишет в живое дерево — все миры в mktemp;
# спавн критика не исполняется (предмет — rc двери, спавн живёт у роли).
#
# Прогон: bash red_dver_pred_kritikom_072.sh [корень worktree]
#   rc 0 — стаб-пак пойман (6/6) И диффпроба (6/6) И честная часть (6/6).
#   rc 1 — расхождение / предмет отсутствует (г0, ДО реализации двери).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
die_pack() { printf '072-дверь-перед-критиком ОТКАЗ: %s\n' "$*" >&2; exit 1; }
command -v git  >/dev/null 2>&1 || die_pack "нет git"
command -v npm  >/dev/null 2>&1 || die_pack "нет npm (нога (а)/(б) слова владельца — npm run)"

for f in scripts/check_precision_gate.sh scripts/check_spec_ready.sh \
         scripts/verify_ci_parity.sh scripts/lib_registry.sh scripts/lib_zones.sh scripts/lib_roles.sh; do
  [ -f "$ROOT/$f" ] || die_pack "в дереве нет $f — батарея строит toy-мир на нём"
done

# ── строитель toy-мира ───────────────────────────────────────────────────────
# toy_make <dir>: настоящий git-репозиторий (main, один коммит) + копии
# РЕАЛЬНЫХ гейтов и их библиотек + toy package.json с безаргументными
# npm-ключами (грамматика слова владельца «npm run … -- . <contract>»
# осмысленна только на безаргументном ключе — иначе проброс судит
# запечённый contracts/043, дефект стаба s6) + минимальный ci.yml (паритет).
toy_make() { # $1=toy-root
  local t="$1"
  mkdir -p "$t/scripts" "$t/contracts" "$t/.github/workflows" "$t/config"
  cp "$ROOT/scripts/check_precision_gate.sh" "$ROOT/scripts/check_spec_ready.sh" "$ROOT/scripts/verify_ci_parity.sh" "$t/scripts/"
  cp "$ROOT"/scripts/lib_*.sh "$t/scripts/"
  cat > "$t/package.json" <<'JSON'
{
  "name": "toy",
  "version": "1.0.0",
  "scripts": {
    "check:precision-gate": "bash scripts/check_precision_gate.sh",
    "check:precision-gate-baked": "bash scripts/check_precision_gate.sh . contracts/043-foreign.md",
    "check:spec-ready": "bash scripts/check_spec_ready.sh"
  }
}
JSON
  cat > "$t/.github/workflows/ci.yml" <<'YML'
name: toy-ci
on: [push]
jobs:
  toy:
    runs-on: ubuntu-latest
    steps:
      - run: npm run check:precision-gate -- . contracts/043-foreign.md
      - run: npm run check:spec-ready -- . contracts/043-foreign.md
YML
  : > "$t/config/ci_parity_exceptions.txt"
printf 'check:precision-gate-baked = toy-ручка стаба s6 батарей 072 (ключ с запечёнными аргументами — модель угрозы проброса)\n' >> "$t/config/ci_parity_exceptions.txt"
  git -C "$t" init -q -b main
  git -C "$t" config user.name orchestrator
  git -C "$t" config user.email orchestrator@dev-harness.local
  git -C "$t" add -A
  git -C "$t" commit -qm 'toy: init'
}

# Зелёный контрольный контракт baked-ключа (s6): 043-foreign — здоровый
# черновик без ЗОНА/ПЕРЕСЕЧЕНИЕ/case-семей; гейт на нём ЗЕЛЁН.
put_foreign() { # $1=toy-root
  cat > "$1/contracts/043-foreign.md" <<'MD'
# Контракт 043 — чужой (toy, зелёный контроль baked-ключа)

## Предмет
p

## Незаполненные требования:
нет
MD
  git -C "$1" add -A && git -C "$1" commit -qm 'toy: foreign'
}

# ВХОД (i): контракт с Б2-формой ПЕРЕСЕЧЕНИЕ (несколько NNN в одной строке
# — форма, отвергнутая критиком к1/071-Б2 и к1/072-Б1; грамматика 043
# требует ОДИН NNN на строку) → precision-гейт красен ДО реализации двери.
put_in_B2() { # $1=toy-root
  cat > "$1/contracts/999-toy-draft.md" <<'MD'
# Контракт 999 — toy-черновик с Б2-формой ПЕРЕСЕЧЕНИЕ

## Предмет
p

## Зоны

ЗОНА architect: contracts/999-toy-draft.md toy/a.txt

ПЕРЕСЕЧЕНИЕ implementer: toy/a.txt — 016/026/030 implementer-зоны (landed): дельта — только ветвь двери

## Незаполненные требования:
нет
MD
  git -C "$1" add -A && git -C "$1" commit -qm 'toy: Б2-форма'
}

# ВХОД (ii): здоровый контракт с ГОЛОЙ строкой привязки стаба в прозе
# (Н-39: пара «стаб ↔ клетка» — запрет AGENTS.md, обходившийся только
# кругом критика — к1/072-Б4). Номер строки — оракул батареи (grep -n).
put_in_N39() { # $1=toy-root
  cat > "$1/contracts/998-toy-draft.md" <<'MD'
# Контракт 998 — toy-черновик с привязкой стаба в прозе

## Предмет
p

## Красные предъявления

s1 умирает на клетке X

## Незаполненные требования:
нет
MD
  git -C "$1" add -A && git -C "$1" commit -qm 'toy: Н-39 проза'
}

# ВХОД (iii): ЧЕСТНЫЙ контракт — цитированная отметка входа (ii) в кавычках:
# порог обязан отсечь отметку от предложения (правило 8) → rc 0.
put_in_HONEST() { # $1=toy-root
  cat > "$1/contracts/997-toy-draft.md" <<'MD'
# Контракт 997 — честный toy-черновик

## Предмет
p

## Красные предъявления

Красная клетка батареи кладёт в toy-контракт строку «s1 умирает на клетке X» и требует отказа — цитата, не утверждение.

## Незаполненные требования:
нет
MD
  git -C "$1" add -A && git -C "$1" commit -qm 'toy: честный'
}

# ВХОД (iv): контракт красный для spec-ready — проба rc 1 БЕЗ суффикса
# «→ красная: <фраза>» (грамматика 036 §В1; прецедент case_prichina_predmeta).
put_in_SPEC() { # $1=toy-root
  printf '# Контракт 996 — toy-черновик с красной пробой\n\n## Предмет\np\n\n## Приёмка\n\n- `bash weak.sh`\n\n## Незаполненные требования:\nнет\n' > "$1/contracts/996-toy-draft.md"
  printf 'exit 1\n' > "$1/weak.sh"
  chmod +x "$1/weak.sh"
  git -C "$1" add -A && git -C "$1" commit -qm 'toy: spec-ready красен'
}

# ВХОД (v) — Б1 (адверсарий 072-r1): здоровый контракт со связкой стаба в
# прозе, РАЗНЕСЁННОЙ переводом строки на соседнюю строку («s2 ловится» /
# «на входе X») — перенос строки не меняет утверждения; нога (в) обязана
# ловить её, номер отказа — ПЕРВАЯ строка связки (оракул — n39_line_multi).
put_in_N39_MULTI() { # $1=toy-root
  cat > "$1/contracts/994-toy-draft.md" <<'MD'
# Контракт 994 — toy-черновик с многострочной привязкой стаба в прозе

## Предмет
p

## Красные предъявления

s2 ловится
на входе X

## Незаполненные требования:
нет
MD
  git -C "$1" add -A && git -C "$1" commit -qm 'toy: Н-39 многострочная проза'
}

# ВХОД (vi) — Б3 (адверсарий 072-r1): отличимый красный вход с токеном s2
# (НЕ s1, не дубль входа (ii)/(iii)) — ловит мутант, сузивший словарь
# `s[0-9]+|стаб|обманка` до константы `s1`.
put_in_N39_S2() { # $1=toy-root
  cat > "$1/contracts/995-toy-draft.md" <<'MD'
# Контракт 995 — toy-черновик с s2-привязкой стаба в прозе

## Предмет
p

## Красные предъявления

s2 ловится на входе X

## Незаполненные требования:
нет
MD
  git -C "$1" add -A && git -C "$1" commit -qm 'toy: Н-39 s2-привязка'
}

# СТАБ-ДВЕРЬ: полная обманная реализация предмета; ручки STUB_* выкрашивают
# ровно одну ветвь. Без ручек — честное поведение всех ветвей (диффпроба).
# Ноги (а)/(б) зовут гейты дословным расширением безаргументных npm-ключей
# («bash scripts/check_…sh» — то, во что npm разворачивает
# «npm run check:… -- . <contract>»); ручка STUB_WRONG_TARGET зовёт ключ с
# ЗАПЕЧЁННЫМИ аргументами — реальная угроза проброса (s6).
write_stub() { # $1=toy-root
  cat > "$1/scripts/pre_critic.sh" <<'STUB'
#!/usr/bin/env bash
# СТАБ-ДВЕРЬ-ПЕРЕД-КРИТИКОМ (обманный предмет 072; ручки STUB_*)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
CONTRACT="${1:?использование: pre_critic.sh <отн-путь-контракта>}"
[ -f "$ROOT/$CONTRACT" ] || { printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$CONTRACT" >&2; exit 2; }
refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }
cd "$ROOT" || { printf 'NOT_IMPLEMENTED: нет корня\n' >&2; exit 2; }

# нога (а): precision-гейт на ПЕРЕДАННОМ контракте
if [ "${STUB_SKIP_PRECISION:-}" != 1 ]; then
  if [ "${STUB_WRONG_TARGET:-}" = 1 ]; then
    # ОБМАН (s6): ключ с запечёнными аргументами судит умолчальный
    # contracts/043-foreign.md, а не переданный черновик
    npm run check:precision-gate-baked -- . "$CONTRACT" >/dev/null 2>&1
  else
    bash scripts/check_precision_gate.sh . "$CONTRACT" >/dev/null 2>&1
  fi
  rc=$?
  [ "$rc" -eq 0 ] || refuse "precision-gate красен (rc $rc): $CONTRACT"
fi

# нога (б): spec-preflight на ПЕРЕДАННОМ контракте
if [ "${STUB_SKIP_SPECREADY:-}" != 1 ]; then
  bash scripts/check_spec_ready.sh . "$CONTRACT" >/dev/null 2>&1
  rc=$?
  [ "$rc" -eq 0 ] || refuse "spec-ready красен (rc $rc): $CONTRACT"
fi

# нога (в): Н-39 — привязка стаба в прозе; порог (правило 8): цитата в
# кавычках — отметка, не предложение; вырезаем кавычные спаны до поиска.
if [ "${STUB_SKIP_N39:-}" != 1 ]; then
  n=0
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n+1))
    if [ "${STUB_FLAG_QUOTED:-}" = 1 ]; then
      scan="$line"   # ОБМАН (s4): порог не отсекает цитату — ложный отказ
    else
      scan="$(printf '%s\n' "$line" | sed -e 's/«[^»]*»//g' -e 's/„[^“]*“//g' -e 's/"[^"]*"//g' -e 's/`[^`]*`//g')"
    fi
    if printf '%s\n' "$scan" | grep -Eq 's[0-9]+|стаб|обманка' \
       && printf '%s\n' "$scan" | grep -Eq 'умирает|ловится|краснеет|падает' \
       && printf '%s\n' "$scan" | grep -Eq 'клетк|вход|кейс'; then
      if [ "${STUB_SILENT:-}" = 1 ]; then
        refuse 'черновик красен'   # ОБМАН (s5): отказ без пиннутого маркера
      else
        refuse "Н-39: привязка стаба в прозе, строка $n"
      fi
    fi
  done < "$CONTRACT"
fi
printf 'КРИТИК: дверь зелёная\n'
exit 0
STUB
}

# run_door <toy> <рел-путь> [VAR=1 …]: прогон субъекта клетки.
run_door() {
  local t="$1" c="$2"; shift 2
  rm -f "$t/door.out" "$t/door.err"
  ( cd / && env "$@" bash "$t/scripts/pre_critic.sh" "$c" ) \
    > "$t/door.out" 2> "$t/door.err"
  S_RC=$?
}

# ── предикаты клеток ─────────────────────────────────────────────────────────
# Позиции: $1=имя $2=rc $3=stderr-файл.
fail_cell() { printf 'клетка %s: %s\n' "$1" "$2" >&2; CELL_FAIL=1; }
p_refuse() { # $4=подстрока причины; rc 1, stderr несёт причину
  local sub="$4"
  [ "$2" -eq 1 ] || { fail_cell "$1" "ожидался отказ rc 1, получен rc $2: $(cat "$3")"; return 1; }
  grep -Fq "$sub" "$3" || { fail_cell "$1" "нет причины «$sub» в stderr: $(cat "$3")"; return 1; }
  return 0
}
p_i()  { p_refuse "$1" "$2" "$3" 'precision-gate'; }                # вход (i)
p_iv() { p_refuse "$1" "$2" "$3" 'spec-ready'; }                    # вход (iv)
p_ii() { # вход (ii): маркер Н-39 дословно + ПРАВИЛЬНЫЙ номер строки
  p_refuse "$1" "$2" "$3" "Н-39: привязка стаба в прозе, строка $EXPECT_LINE" || return 1
  return 0
}
p_iii() { # вход (iii): rc 0, отказа нет (честный черновик проходит)
  [ "$2" -eq 0 ] || { fail_cell "$1" "ожидался rc 0, получен $2: $(cat "$3")"; return 1; }
  grep -Fq 'ОТКАЗ' "$3" && { fail_cell "$1" "ложный отказ на честном черновике: $(cat "$3")"; return 1; }
  return 0
}

# n39_line <toy> <рел-путь> [grep-шаблон]: номер строки голой привязки —
# оракул батареи; шаблон по умолчанию — однострочная форма входа (ii).
n39_line() { grep -n "${3:-^s1 умирает на клетке X$}" "$1/$2" | head -1 | cut -d: -f1; }

# build_world <toy> <вход>: toy-мир + стаб-дверь + вход-контракт.
build_world() {
  local t="$1" input="$2"
  rm -rf "$t"; toy_make "$t"; put_foreign "$t"; write_stub "$t"
  "$input" "$t"
}

# ── СТАБ-ПАК: 6 стабов × (ручка=дефект ловится, ручки нет — диффпроба) ──────
stab_caught=0; diff_green=0
run_pair() { # $1=метка $2=строитель-входа $3=рел-путь $4=предикат $5=ручка
  local tag="$1" input="$2" rel="$3" pred="$4" knob="$5"
  local T="$WORK/t-$tag"
  build_world "$T" "$input"
  EXPECT_LINE="$(n39_line "$T" "$rel")"
  run_door "$T" "$rel" "STUB_$knob=1"
  CELL_FAIL=0
  "$pred" "$tag(ручка)" "$S_RC" "$T/door.err"
  if [ "$CELL_FAIL" -ne 0 ]; then stab_caught=$((stab_caught+1)); else
    printf 'стаб-пак ОТКАЗ: стаб %s с ручкой ПРОШЁЛ клетку (%s)\n' "$knob" "$tag" >&2
    exit 1
  fi
  build_world "$T" "$input"
  EXPECT_LINE="$(n39_line "$T" "$rel")"
  run_door "$T" "$rel"
  CELL_FAIL=0
  "$pred" "$tag(дифф)" "$S_RC" "$T/door.err"
  if [ "$CELL_FAIL" -eq 0 ]; then diff_green=$((diff_green+1)); else
    printf 'стаб-пак ОТКАЗ: диффпроба %s упала без ручки\n' "$tag" >&2
    exit 1
  fi
}

run_pair s1 put_in_B2     'contracts/999-toy-draft.md' p_i   SKIP_PRECISION
run_pair s6 put_in_B2     'contracts/999-toy-draft.md' p_i   WRONG_TARGET
run_pair s2 put_in_SPEC   'contracts/996-toy-draft.md' p_iv  SKIP_SPECREADY
run_pair s3 put_in_N39    'contracts/998-toy-draft.md' p_ii  SKIP_N39
run_pair s5 put_in_N39    'contracts/998-toy-draft.md' p_ii  SILENT
run_pair s4 put_in_HONEST 'contracts/997-toy-draft.md' p_iii FLAG_QUOTED
printf 'дверь-перед-критиком: стаб-пак %d/6 поймано, диффпроба %d/6\n' "$stab_caught" "$diff_green"
[ "$stab_caught" -eq 6 ] && [ "$diff_green" -eq 6 ] \
  || die_pack "счёт стаб-пака не сошёлся (поймано $stab_caught, дифф $diff_green)"

# г0: носитель предмета (двери)
if [ ! -f "$ROOT/scripts/pre_critic.sh" ]; then
  printf 'ОТКАЗ: предмет отсутствует — в дереве нет scripts/pre_critic.sh\n' >&2
  exit 1
fi

# ── ЧЕСТНАЯ ЧАСТЬ: ч1..ч6 против реального scripts/pre_critic.sh ────────────
# ч5 (Б1) и ч6 (Б3) — усиление по вердикту адверсария 072-r1: ч5 проверяет
# ногу (в) на связке, разнесённой переводом строки (номер — первая строка
# связки); ч6 — отличимость от мутанта, сузившего словарь s[0-9]+ до s1.
honest_green=0; honest_total=0
run_honest() { # $1=метка $2=строитель-входа $3=рел-путь $4=предикат [$5=grep-шаблон оракула]
  local tag="$1" input="$2" rel="$3" pred="$4" linepat="${5:-}"
  honest_total=$((honest_total+1))
  local T="$WORK/h-$tag"
  build_world "$T" "$input"
  cp "$ROOT/scripts/pre_critic.sh" "$T/scripts/pre_critic.sh"
  EXPECT_LINE="$(n39_line "$T" "$rel" "$linepat")"
  run_door "$T" "$rel"
  CELL_FAIL=0
  "$pred" "$tag" "$S_RC" "$T/door.err"
  if [ "$CELL_FAIL" -eq 0 ]; then honest_green=$((honest_green+1)); fi
}
run_honest ч1 put_in_B2        'contracts/999-toy-draft.md' p_i
run_honest ч2 put_in_SPEC      'contracts/996-toy-draft.md' p_iv
run_honest ч3 put_in_N39       'contracts/998-toy-draft.md' p_ii
run_honest ч4 put_in_HONEST    'contracts/997-toy-draft.md' p_iii
run_honest ч5 put_in_N39_MULTI 'contracts/994-toy-draft.md' p_ii '^s2 ловится$'
run_honest ч6 put_in_N39_S2    'contracts/995-toy-draft.md' p_ii '^s2 ловится на входе X$'
printf 'дверь-перед-критиком: честная часть %d/%d зелёная\n' "$honest_green" "$honest_total"
[ "$honest_green" -eq "$honest_total" ] \
  || die_pack "честная часть красна ($honest_green/$honest_total)"
printf 'итог 072-двери-перед-критиком: предъявлений стабы 6/6 + дифф 6/6 + честные 6/6\n'
exit 0
