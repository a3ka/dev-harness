#!/usr/bin/env bash
# ПРИЧИНА: спек-гейт 036: зелёный контроль семьи не предъявлен
# В4-3, подмена «исполненное ПРИСВОЕНИЕ» (арбитраж 036d1f1 замер 1, вход
# probe.py assign_dead; красный вход 8e6ec26 «исполненное присвоение»):
# зелёный контроль семьи кредитуется ЛИТЕРАЛОМ в трассе (grep -F по xtrace),
# а не КОМАНДНОЙ ПОЗИЦИЕЙ — проба «B=scripts/check_judge_gate.sh; exit 0» с
# недостижимым вызовом проходит: xtrace честно печатает исполненное
# присвоение «+ B=scripts/check_judge_gate.sh», вызова нет, гейт зелёнеет.
# Различающий критерий (036d1f1): командная позиция литерала в ИЗОЛИРОВАННОЙ
# трассе (BASH_XTRACEFD, поток пробы в трассу не пишется) — литерал после
# «=» командной позиции не занимает.
# Конформность по 019: черновик законен (честная красная проба с фразой по В1,
# семья настоящая — каталог fixtures/check_judge_gate/ и барьер в дереве есть),
# расхождение — «контроль предъявлен» без вызова.
# Дифференциал (Н-39, три входа одного семейства, у каждого своё предъявление):
#   S-zhivyj-cherez-peremennuju (G): присвоение + ЖИВОЙ вызов «bash "$B" …» —
#     каноническая форма В4-2 «$BARRIER»: xtrace печатает слова ПОСЛЕ раскрытия,
#     командная позиция занята — rc 0 ДО и ПОСЛЕ фикса, живой вызов обязан
#     оставаться зелёным;
#   S-prisvoenie-bez-vyzova (M): то же присвоение + exit 0 + недостижимый
#     вызов; субъект ДО фикса — git show 8e6ec26:scripts/check_spec_ready.sh
#     (grep литерала по трассе), исторический свидетель — даёт rc 0 «OK»
#     (свидетельство дыры); честный субъект обязан отказать rc 1 именованным
#     «зелёный контроль семьи не предъявлен»;
#   S-bez-vyzova-voobshhe (O): проба без литерала барьера вовсе — старый класс,
#     ДО фикса уже красный rc 1 теми же словами: стаб не слеп, его зелёность
#     на M специфична присвоению-без-вызова, а не «пропускает всё».
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
sbor_semi() {  # <каталог> — честная семья: барьер-копия + предмет + литеральный живой контроль
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
}

# Стаб: субъект ДО фикса (В4-3 по grep литерала в трассе) из объекта истории
# дерева. 8e6ec26 — арбитражный вердикт на main: гейт в нём ещё кредитует
# присвоение (замер 1 вердикта 036d1f1, строка assign_dead → rc 0 OK).
STAB="$WORK/stab_do_fiksa_8e6ec26.sh"
if ! git -C "$REPO" show '8e6ec26:scripts/check_spec_ready.sh' > "$STAB" 2> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб 8e6ec26:scripts/check_spec_ready.sh не извлекается из %s — история не несёт ДО-фикса субъекта\n' "$REPO" >&2
  exit 1
fi
# Библиотека субъекта — тем же объектом истории, рядом со стабом (SELF_DIR-резолв).
if ! git -C "$REPO" show '8e6ec26:scripts/lib_registry.sh' > "$WORK/lib_registry.sh" 2>> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб 8e6ec26:scripts/lib_registry.sh не извлекается — субъект ДО фикса неисполним\n' >&2
  exit 1
fi

# ── S-zhivyj-cherez-peremennuju (G): присвоение + живой вызов $B — зелёный ────
G="$WORK/s_zhivogo_cherez_peremennuju"; make_toy "$G"; sbor_semi "$G"
printf 'printf "ФРАЗА ЖИВОГО ВЫЗОВА\\n" >&2\nexit 1\n' > "$G/p_ok.sh"
cat > "$G/fixtures/check_judge_gate/case_zhivoj_kontrol.sh" <<'PROBE'
#!/usr/bin/env bash
# живой зелёный контроль семьи, каноническая форма В4-2 «$BARRIER»:
# присвоение + ЖИВОЙ вызов — xtrace печатает слова ПОСЛЕ раскрытия переменной
set -uo pipefail
B=scripts/check_judge_gate.sh
bash "$B" . зелёный
PROBE
cat > "$G/contracts/997-v43-prisvoenie-zhivoj.md" <<'MD'
# 997 — В4-3: семья с живым вызовом барьера через переменную

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА ЖИВОГО ВЫЗОВА
- `bash fixtures/check_judge_gate/case_zhivoj_kontrol.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_zhivoj_kontrol.sh
MD
commit_all "$G" 'живой вызов через переменную'
"$BARRIER" "$G" contracts/997-v43-prisvoenie-zhivoj.md

# ── S-prisvoenie-bez-vyzova (M): присвоение + exit 0 + мёртвый вызов ─────────
M="$WORK/s_prisvoenija_bez_vyzova"; make_toy "$M"
cp "$REPO/scripts/check_judge_gate.sh" "$M/scripts/check_judge_gate.sh"
printf 'printf "ФРАЗА ПРИСВОЕНИЯ\\n" >&2\nexit 1\n' > "$M/p_ok.sh"
cat > "$M/fixtures/check_judge_gate/case_prisvoenie_bez_vyzova.sh" <<'PROBE'
#!/usr/bin/env bash
# «зелёный контроль» семьи judge_gate: присвоение исполнено, вызова нет
# (вход probe.py assign_dead арбитража 036d1f1 — дословно)
B=scripts/check_judge_gate.sh
exit 0
bash "$B" . зелёный
PROBE
cat > "$M/contracts/998-v43-prisvoenie.md" <<'MD'
# 998 — В4-3: исполненное присвоение вместо вызова барьера семьи

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА ПРИСВОЕНИЯ
- `bash fixtures/check_judge_gate/case_prisvoenie_bez_vyzova.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_prisvoenie_bez_vyzova.sh
MD
commit_all "$M" 'присвоение без вызова: литерал после «=»'

# Свидетельство дыры: субъект ДО фикса кредитует присвоение — гейт зелёный
# на обмане (rc 0, последняя строка OK), вызов барьера не исполнялся ни разу.
run_gate "$STAB" "$M" contracts/998-v43-prisvoenie.md
if [ "$GATE_RC" -ne 0 ]; then
  printf 'ОТКАЗ: стаб 8e6ec26 (grep литерала по трассе) не воспроизвёл пропуск присвоения — rc %s, свидетельство требует rc 0:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
[ "$(printf '%s\n' "$GATE_OUT" | tail -n 1)" = 'OK' ] || {
  printf 'ОТКАЗ: стаб 8e6ec26 дал rc 0, но без канонической последней строки OK:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'свидетельство: ДО фикса присвоение без вызова проходит — rc 0, «OK»\n' >&2

# Красное предъявление: честный субъект обязан отказать именованным «зелёный
# контроль семьи не предъявлен» — зачёт несёт КОМАНДНАЯ ПОЗИЦИЯ литерала в
# изолированной трассе, не литерал после «=» (036d1f1).
run_gate "$BARRIER" "$M" contracts/998-v43-prisvoenie.md
if [ "$GATE_RC" -ne 1 ]; then
  printf 'ОТКАЗ: присвоение без вызова (B=…; exit 0; мёртвый bash "$B") засчитано живым контролем — rc %s, гейт зелёный на обмане:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
printf '%s\n' "$GATE_OUT" | grep -Fq 'зелёный контроль семьи не предъявлен' || {
  printf 'ОТКАЗ: присвоение без вызова отказано rc 1, но без именованной причины «зелёный контроль семьи не предъявлен»:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'красное предъявление: присвоение без вызова отказано именованным\n' >&2

# ── S-bez-vyzova-voobshhe (O): литерала нет вовсе — старый класс ──────────────
O="$WORK/s_bez_vyzova_voobshhe"; make_toy "$O"
cp "$REPO/scripts/check_judge_gate.sh" "$O/scripts/check_judge_gate.sh"
printf 'printf "ФРАЗА БЕЗ ВЫЗОВА\\n" >&2\nexit 1\n' > "$O/p_ok.sh"
cat > "$O/fixtures/check_judge_gate/case_bez_vyzova_voobshhe.sh" <<'PROBE'
#!/usr/bin/env bash
# «зелёный контроль» без вызова барьера и без его литерала в тексте
exit 0
PROBE
cat > "$O/contracts/999-v43-bez-vyzova.md" <<'MD'
# 999 — В4-3: контроль без вызова барьера вовсе

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА БЕЗ ВЫЗОВА
- `bash fixtures/check_judge_gate/case_bez_vyzova_voobshhe.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_bez_vyzova_voobshhe.sh
MD
commit_all "$O" 'контроль без вызова и без литерала'

# Калибровка стаба: старый класс ДО фикса уже красен — зелёность стаба на M
# специфична присвоению-без-вызова (литерал в трассе есть, командной позиции
# нет), а не слепоте.
run_gate "$STAB" "$O" contracts/999-v43-bez-vyzova.md
if [ "$GATE_RC" -ne 1 ]; then
  printf 'ОТКАЗ: стаб 8e6ec26 на пробе без литерала дал rc %s, ожидание 1 (старый класс был закрыт В4-3 и до фикса):\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
printf '%s\n' "$GATE_OUT" | grep -Fq 'зелёный контроль семьи не предъявлен' || {
  printf 'ОТКАЗ: стаб отказал старому классу rc 1, но без именованной причины:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'калибровка: старый класс красен и ДО фикса — стаб различает три входа\n' >&2

# Красное предъявление старого класса: честный субъект отказывает и ему.
run_gate "$BARRIER" "$O" contracts/999-v43-bez-vyzova.md
if [ "$GATE_RC" -ne 1 ]; then
  printf 'ОТКАЗ: старый класс (без литерала) на честном субъекте дал rc %s, ожидание 1:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
printf '%s\n' "$GATE_OUT" | grep -Fq 'зелёный контроль семьи не предъявлен' || {
  printf 'ОТКАЗ: старый класс отказан rc 1, но без именованной причины:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'красное предъявление: старый класс отказан именованным\n' >&2
