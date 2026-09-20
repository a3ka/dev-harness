#!/usr/bin/env bash
# ПРИЧИНА: спек-гейт 036: зелёный контроль семьи не предъявлен
# В4-3 (Н-113, главная цена 031-v3: «case будет создан исполнителем ПОСЛЕ
# заморозки», блоб e34a6059). ЗОНА объявляет case-путь семьи check_judge_gate
# (в т.ч. БУДУЩИЙ файл), а приёмка не несёт НИ ОДНОЙ живой пробы вызова
# барьера этой семьи: argv будущего case живёт в прозе и до заморозки не
# сталкивался с грамматикой барьера. Конформность по 019: черновик законен
# по В1 (честная красная проба с фразой), семья настоящая (каталог и барьер
# в дереве есть), расхождение — отсутствие живого зелёного контроля семьи.
# Дифференциал: СТАБ = check_spec_ready.sh ДО В4 из git-объекта ef5ff3a
# (предок HEAD; 24057a1 меняет в scripts/ только этот файл), прямой запуск —
# исторический субъект-свидетель, не барьер прогона. До В4 — rc 0 «OK»;
# с В4 — rc 1 именованным «зелёный контроль семьи не предъявлен».
# Пара «с пробой → rc 0» — зелёный контроль этой же фикстуры: приёмка с
# живой грамматически совместимой пробой `check_judge_gate <корень> зелёный`
# (настоящий rc 0 реального барьера на честном предмете) не красится В4.
set -euo pipefail

make_toy() {  # <каталог> — герметичный git-каркас (Н-12: локальная identity файлом)
  mkdir -p "$1/contracts" "$1/fixtures/check_judge_gate" "$1/scripts"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$1"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$1" config user.name Фикстура
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$1" config user.email fixture@local
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$1" config commit.gpgsign false
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$1" config core.hooksPath /dev/null
}
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c user.name=Фикстура -c user.email=fixture@local "$@"
}
commit_all() { g "$1" add -A && g "$1" commit -q -m "$2"; }
run_gate() {  # <скрипт-субъект> <корень> <контракт> → GATE_RC/GATE_OUT (память проверяющего)
  GATE_RC=0; GATE_OUT="$(bash "$1" "$2" "$3" 2>&1)" || GATE_RC=$?
}
sbor_semi() {  # <каталог> — честная семья: барьер-копия + предмет + живая проба
  cp "$REPO/scripts/check_judge_gate.sh" "$1/scripts/check_judge_gate.sh"
  cat > "$1/scripts/judge_gate.sh" <<'SUBJ'
#!/usr/bin/env bash
# честный предмет: зовёт check_ci_gate со своим $1, пропускает rc, печатает OK
d="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$("$d/check_ci_gate.sh" "$1" 2>&1)"; rc=$?
printf '%s\n' "$out"
if [ "$rc" -eq 0 ]; then printf 'OK\n'; fi
exit "$rc"
SUBJ
  cat > "$1/fixtures/check_judge_gate/case_zhivoj_kontrol.sh" <<'PROBE'
#!/usr/bin/env bash
# живой зелёный контроль семьи: вызов scripts/check_judge_gate.sh совместимой
# грамматикой (известная ветвь «зелёный») на настоящем предмете judge_gate.sh
set -uo pipefail
exec bash scripts/check_judge_gate.sh . зелёный
PROBE
}

# Стаб: субъект ДО В4 из неизменяемого объекта истории дерева.
STAB="$WORK/stab_do_v4_ef5ff3a.sh"
if ! git -C "$REPO" show 'ef5ff3a:scripts/check_spec_ready.sh' > "$STAB" 2> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб ef5ff3a:scripts/check_spec_ready.sh не извлекается из %s — история не несёт ДО-В4 субъекта\n' "$REPO" >&2
  exit 1
fi
# Библиотека субъекта — тем же объектом истории, рядом со стабом (SELF_DIR-резолв):
# субъект с первого своего коммита доизвлекает lib_registry.sh из собственного
# каталога; стаб без неё неисполним («реестр заморозок не читается»).
if ! git -C "$REPO" show 'ef5ff3a:scripts/lib_registry.sh' > "$WORK/lib_registry.sh" 2>> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб ef5ff3a:scripts/lib_registry.sh не извлекается из %s — субъект ДО В4 неисполним\n' "$REPO" >&2
  exit 1
fi

# ── Зелёный контроль («с пробой — rc 0»): живой зелёный контроль семьи ───────
G="$WORK/s_probej"; make_toy "$G"; sbor_semi "$G"
printf 'printf "ПРЕДМЕТНАЯ ФРАЗА С ПРОБОЙ\\n" >&2\nexit 1\n' > "$G/p_ok.sh"
cat > "$G/contracts/998-n113-kontrol.md" <<'MD'
# 998 — Н-113: семья с живым зелёным контролем

## Приёмочный критерий
- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА С ПРОБОЙ
- `bash fixtures/check_judge_gate/case_zhivoj_kontrol.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_budet.sh fixtures/check_judge_gate/case_zhivoj_kontrol.sh
MD
commit_all "$G" 'семья с живой пробой'
"$BARRIER" "$G" contracts/998-n113-kontrol.md

# ── Без пробы: случай заявлен (в т.ч. будущий), живого контроля нет ───────────
H="$WORK/bez_proby"; make_toy "$H"
cp "$REPO/scripts/check_judge_gate.sh" "$H/scripts/check_judge_gate.sh"
printf 'printf "ПРЕДМЕТНАЯ ФРАЗА БЕЗ ПРОБЫ\\n" >&2\nexit 1\n' > "$H/p_ok.sh"
cat > "$H/contracts/998-n113-budet.md" <<'MD'
# 998 — Н-113 контрпример B: case будет создан исполнителем ПОСЛЕ заморозки

## Приёмочный критерий
- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА БЕЗ ПРОБЫ

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_budet.sh
MD
commit_all "$H" 'будущий case без живой пробы'

# Свидетельство дыры: субъект ДО В4 пропускает черновик (rc 0, последняя строка OK).
run_gate "$STAB" "$H" contracts/998-n113-budet.md
if [ "$GATE_RC" -ne 0 ]; then
  printf 'ОТКАЗ: стаб ef5ff3a (до В4) не воспроизвёл пропуск будущего case — rc %s, свидетельство требует rc 0:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
[ "$(printf '%s\n' "$GATE_OUT" | tail -n 1)" = 'OK' ] || {
  printf 'ОТКАЗ: стаб ef5ff3a дал rc 0, но без канонической последней строки OK:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'свидетельство: ДО В4 будущий case без пробы проходит — rc 0, «OK»\n' >&2

# Красное предъявление: честный субъект (В4-3) отказывает именованным
# «зелёный контроль семьи не предъявлен» — argv будущего case обязан быть
# показан живой пробой ДО заморозки.
"$BARRIER" "$H" contracts/998-n113-budet.md
