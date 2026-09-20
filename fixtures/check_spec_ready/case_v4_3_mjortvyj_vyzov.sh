#!/usr/bin/env bash
# ПРИЧИНА: спек-гейт 036: зелёный контроль семьи не предъявлен
# В4-3, обход из вердикта критика fe5e4f73: зелёный контроль семьи кредитуется
# ЛИТЕРАЛОМ в тексте пробы (grep файла пробы), а не состоявшимся вызовом —
# проба «exit 0» с недостижимой строкой «bash scripts/check_judge_gate.sh . --retake»
# проходит и В1 (rc 0 — пропуск), и В4-2-кредит: вызов барьера ни разу не
# исполнен, а гейт зелёнеет. Различающий критерий — трасса исполнения вызова.
# Конформность по 019: черновик законен (честная красная проба с фразой по В1,
# семья настоящая — каталог fixtures/check_judge_gate/ и барьер в дереве есть),
# расхождение — «контроль предъявлен» без исполнения вызова.
# Дифференциал (Н-39, три входа одного семейства, у каждого своё предъявление):
#   S-zhivyj-vyzov (G): живая проба канона case_v4_3_net_zelenogo_kontrolja —
#     exec-вызов барьера ветвью «зелёный» на честном предмете; rc 0 ДО и ПОСЛЕ
#     фикса — зелёный контроль фикстуры, живой вызов обязан оставаться зелёным;
#   S-mjortvyj-vyzov (M): exit 0 + недостижимый вызов; субъект ДО фикса —
#     git show fe5e4f73:scripts/check_spec_ready.sh, исторический свидетель —
#     даёт rc 0 «OK» (свидетельство дыры); честный субъект обязан отказать
#     rc 1 именованным «зелёный контроль семьи не предъявлен»;
#   S-bez-vyzova-voobshhe (O): проба без литерала барьера вовсе — старый класс,
#     ДО фикса уже красный rc 1 теми же словами: стаб не слеп, его зелёность на M
#     специфична мёртвому вызову, а не «пропускает всё».
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

# Стаб: субъект ДО фикса (В4-3 по литералу текста) из объекта истории дерева.
STAB="$WORK/stab_do_fiksa_fe5e4f73.sh"
if ! git -C "$REPO" show 'fe5e4f73:scripts/check_spec_ready.sh' > "$STAB" 2> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб fe5e4f73:scripts/check_spec_ready.sh не извлекается из %s — история не несёт ДО-фикса субъекта\n' "$REPO" >&2
  exit 1
fi
# Библиотека субъекта — тем же объектом истории, рядом со стабом (SELF_DIR-резолв):
# субъект доизвлекает lib_registry.sh из собственного каталога; стаб без неё
# неисполним («реестр заморозок не читается»).
if ! git -C "$REPO" show 'fe5e4f73:scripts/lib_registry.sh' > "$WORK/lib_registry.sh" 2>> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб fe5e4f73:scripts/lib_registry.sh не извлекается — субъект ДО фикса неисполним\n' >&2
  exit 1
fi

# ── S-zhivyj-vyzov (G): живой вызов — зелёный контроль фикстуры ───────────────
G="$WORK/s_zhivogo_vyzova"; make_toy "$G"; sbor_semi "$G"
printf 'printf "ФРАЗА ЖИВОГО ВЫЗОВА\\n" >&2\nexit 1\n' > "$G/p_ok.sh"
cat > "$G/contracts/997-n113-zhivoj-vyzov.md" <<'MD'
# 997 — Н-113: семья с живым вызовом барьера

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА ЖИВОГО ВЫЗОВА
- `bash fixtures/check_judge_gate/case_zhivoj_kontrol.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_zhivoj_kontrol.sh
MD
commit_all "$G" 'семья с живой пробой'
"$BARRIER" "$G" contracts/997-n113-zhivoj-vyzov.md

# ── S-mjortvyj-vyzov (M): exit 0 + недостижимый вызов барьера ─────────────────
M="$WORK/s_mjortvogo_vyzova"; make_toy "$M"
cp "$REPO/scripts/check_judge_gate.sh" "$M/scripts/check_judge_gate.sh"
printf 'printf "ФРАЗА МЁРТВОГО ВЫЗОВА\\n" >&2\nexit 1\n' > "$M/p_ok.sh"
cat > "$M/fixtures/check_judge_gate/case_mjortvyj_vyzov.sh" <<'PROBE'
#!/usr/bin/env bash
# «зелёный контроль» семьи judge_gate: литерал вызова есть, вызова нет
exit 0
bash scripts/check_judge_gate.sh . --retake
PROBE
cat > "$M/contracts/998-n113-mjortvyj-vyzov.md" <<'MD'
# 998 — Н-113: мёртвый вызов барьера семьи

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА МЁРТВОГО ВЫЗОВА
- `bash fixtures/check_judge_gate/case_mjortvyj_vyzov.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_mjortvyj_vyzov.sh
MD
commit_all "$M" 'мёртвый вызов: литерал без исполнения'

# Свидетельство дыры: субъект ДО фикса кредитует литерал — гейт зелёный на
# обмане (rc 0, последняя строка OK), вызов барьера не исполнялся ни разу.
run_gate "$STAB" "$M" contracts/998-n113-mjortvyj-vyzov.md
if [ "$GATE_RC" -ne 0 ]; then
  printf 'ОТКАЗ: стаб fe5e4f73 (В4-3 по литералу) не воспроизвёл пропуск мёртвого вызова — rc %s, свидетельство требует rc 0:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
[ "$(printf '%s\n' "$GATE_OUT" | tail -n 1)" = 'OK' ] || {
  printf 'ОТКАЗ: стаб fe5e4f73 дал rc 0, но без канонической последней строки OK:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'свидетельство: ДО фикса мёртвый вызов проходит — rc 0, «OK»\n' >&2

# Красное предъявление: честный субъект обязан отказать именованным «зелёный
# контроль семьи не предъявлен» — доказательство вызова несёт трасса исполнения,
# не литерал в тексте пробы (различающий критерий живого вызова, fe5e4f73).
run_gate "$BARRIER" "$M" contracts/998-n113-mjortvyj-vyzov.md
if [ "$GATE_RC" -ne 1 ]; then
  printf 'ОТКАЗ: мёртвый вызов (exit 0 + недостижимый bash scripts/check_judge_gate.sh . --retake) засчитан живым контролем — rc %s, гейт зелёный на обмане:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
printf '%s\n' "$GATE_OUT" | grep -Fq 'зелёный контроль семьи не предъявлен' || {
  printf 'ОТКАЗ: мёртвый вызов отказан rc 1, но без именованной причины «зелёный контроль семьи не предъявлен»:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'красное предъявление: мёртвый вызов отказан именованным\n' >&2

# ── S-bez-vyzova-voobshhe (O): литерала нет вовсе — старый класс ──────────────
O="$WORK/s_bez_vyzova_voobshhe"; make_toy "$O"
cp "$REPO/scripts/check_judge_gate.sh" "$O/scripts/check_judge_gate.sh"
printf 'printf "ФРАЗА БЕЗ ВЫЗОВА\\n" >&2\nexit 1\n' > "$O/p_ok.sh"
cat > "$O/fixtures/check_judge_gate/case_bez_vyzova_voobshhe.sh" <<'PROBE'
#!/usr/bin/env bash
# «зелёный контроль» без вызова барьера и без его литерала в тексте
exit 0
PROBE
cat > "$O/contracts/999-n113-bez-vyzova.md" <<'MD'
# 999 — Н-113: контроль без вызова барьера вовсе

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА БЕЗ ВЫЗОВА
- `bash fixtures/check_judge_gate/case_bez_vyzova_voobshhe.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_bez_vyzova_voobshhe.sh
MD
commit_all "$O" 'контроль без вызова и без литерала'

# Калибровка стаба: старый класс ДО фикса уже красен — зелёность стаба на M
# специфична мёртвому вызову (литерал есть, исполнения нет), а не слепоте.
run_gate "$STAB" "$O" contracts/999-n113-bez-vyzova.md
if [ "$GATE_RC" -ne 1 ]; then
  printf 'ОТКАЗ: стаб fe5e4f73 на пробе без литерала дал rc %s, ожидание 1 (старый класс был закрыт В4-3 и до фикса):\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
printf '%s\n' "$GATE_OUT" | grep -Fq 'зелёный контроль семьи не предъявлен' || {
  printf 'ОТКАЗ: стаб отказал старому классу rc 1, но без именованной причины:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'калибровка: старый класс красен и ДО фикса — стаб различает три входа\n' >&2

# Красное предъявление старого класса: честный субъект отказывает и ему.
run_gate "$BARRIER" "$O" contracts/999-n113-bez-vyzova.md
if [ "$GATE_RC" -ne 1 ]; then
  printf 'ОТКАЗ: старый класс (без литерала) на честном субъекте дал rc %s, ожидание 1:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
printf '%s\n' "$GATE_OUT" | grep -Fq 'зелёный контроль семьи не предъявлен' || {
  printf 'ОТКАЗ: старый класс отказан rc 1, но без именованной причины:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'красное предъявление: старый класс отказан именованным\n' >&2
