#!/usr/bin/env bash
# ПРИЧИНА: спек-гейт 036: зелёный контроль семьи не предъявлен
# В4-3, подмена «литерал в СОБСТВЕННОМ stderr пробы» (арбитраж 036d1f1
# замер 1, вход probe.py own_stderr; красный вход 8e6ec26 «литерал-в-stderr»;
# класс 030 «forged-record» — обход к4 контракта 030 был ровно таким):
# второй прогон пишется «2>файл-трассы» в ОБЩИЙ stderr прогона — проба,
# лишь ПЕЧАТАЮЩАЯ путь барьера в свой stderr («echo … >&2; exit 0»),
# кредитуется гейтом: потоки пробы — канал, которым проба владеет целиком.
# Различающий критерий (036d1f1): трасса В4-прога пишется в гейт-приватный
# fd (BASH_XTRACEFD), stdout/stderr пробы в неё НЕ попадают вовсе — печать
# литерала в собственный поток зачёта не даёт.
# Конформность по 019: черновик законен (честная красная проба с фразой по В1,
# семья настоящая — каталог fixtures/check_judge_gate/ и барьер в дереве есть),
# расхождение — «контроль предъявлен» без вызова.
# Дифференциал (Н-39, три входа одного семейства, у каждого своё предъявление):
#   S-zhivyj-s-shumom (G): живой вызов + ШУМ с литералом в stderr — канал
#     разделён, шум в трассу не попадает, вызов кредитуется; rc 0 ДО и ПОСЛЕ
#     фикса (замер 2 вердикта: «честный вызов + шум в stderr с упоминанием
#     пути — ЖИВОЙ, шум в трассу НЕ попал»);
#   S-stderr-kanal (M): только печать литерала в stderr + exit 0; субъект
#     ДО фикса — git show 8e6ec26:scripts/check_spec_ready.sh (трасса в общем
#     stderr), исторический свидетель — даёт rc 0 «OK» (свидетельство дыры);
#     честный субъект обязан отказать rc 1 именованным «зелёный контроль
#     семьи не предъявлен»;
#   S-bez-vyzova-voobshhe (O): проба без литерала барьера вовсе — старый класс,
#     ДО фикса уже красный rc 1 теми же словами: стаб не слеп, его зелёность
#     на M специфична подделке канала, а не «пропускает всё».
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
sbor_semi() {  # <каталог> — честная семья: барьер-копия + предмет + живой контроль
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

# Стаб: субъект ДО фикса (трасса В4-прога в общем stderr) из объекта истории
# дерева. 8e6ec26 — арбитражный вердикт на main: гейт в нём ещё кредитует
# печать литерала в stderr (замер 1 вердикта 036d1f1, own_stderr → rc 0 OK).
STAB="$WORK/stab_do_fiksa_8e6ec26.sh"
if ! git -C "$REPO" show '8e6ec26:scripts/check_spec_ready.sh' > "$STAB" 2> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб 8e6ec26:scripts/check_spec_ready.sh не извлекается из %s — история не несёт ДО-фикса субъекта\n' "$REPO" >&2
  exit 1
fi
if ! git -C "$REPO" show '8e6ec26:scripts/lib_registry.sh' > "$WORK/lib_registry.sh" 2>> "$WORK/stab-err.txt"; then
  printf 'ОТКАЗ: стаб 8e6ec26:scripts/lib_registry.sh не извлекается — субъект ДО фикса неисполним\n' >&2
  exit 1
fi

# ── S-zhivyj-s-shumom (G): живой вызов + шум в stderr — зелёный ──────────────
G="$WORK/s_zhivogo_s_shumom"; make_toy "$G"; sbor_semi "$G"
printf 'printf "ФРАЗА ЖИВОГО С ШУМОМ\\n" >&2\nexit 1\n' > "$G/p_ok.sh"
cat > "$G/fixtures/check_judge_gate/case_zhivoj_kontrol.sh" <<'PROBE'
#!/usr/bin/env bash
# живой зелёный контроль семьи + ДОПУСТИМЫЙ шум: проба вправе печатать в
# собственный stderr что угодно (030) — каналом трассы её потоки не являются
set -uo pipefail
echo "scripts/check_judge_gate.sh шум допустим" >&2
bash scripts/check_judge_gate.sh . зелёный
PROBE
cat > "$G/contracts/997-v43-stderr-kanal-zhivoj.md" <<'MD'
# 997 — В4-3: семья с живым вызовом и шумом в stderr

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА ЖИВОГО С ШУМОМ
- `bash fixtures/check_judge_gate/case_zhivoj_kontrol.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_zhivoj_kontrol.sh
MD
commit_all "$G" 'живой вызов с шумом в stderr'
"$BARRIER" "$G" contracts/997-v43-stderr-kanal-zhivoj.md

# ── S-stderr-kanal (M): только печать литерала в stderr, вызова нет ─────────
M="$WORK/s_stderr_kanala"; make_toy "$M"
cp "$REPO/scripts/check_judge_gate.sh" "$M/scripts/check_judge_gate.sh"
printf 'printf "ФРАЗА STDERR-КАНАЛА\\n" >&2\nexit 1\n' > "$M/p_ok.sh"
cat > "$M/fixtures/check_judge_gate/case_stderr_kanal.sh" <<'PROBE'
#!/usr/bin/env bash
# «зелёный контроль» семьи judge_gate: литерал лишь НАПЕЧАТАН в собственный
# stderr пробы, вызова нет (вход probe.py own_stderr арбитража 036d1f1)
echo scripts/check_judge_gate.sh >&2
exit 0
PROBE
cat > "$M/contracts/998-v43-stderr-kanal.md" <<'MD'
# 998 — В4-3: печать литерала барьера в stderr вместо вызова

## Приёмочный критерий
- `bash p_ok.sh` → красная: ФРАЗА STDERR-КАНАЛА
- `bash fixtures/check_judge_gate/case_stderr_kanal.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_stderr_kanal.sh
MD
commit_all "$M" 'печать литерала в stderr без вызова'

# Свидетельство дыры: субъект ДО фикса кредитует печать в stderr — гейт зелёный
# на обмане (rc 0, последняя строка OK), вызов барьера не исполнялся ни разу.
run_gate "$STAB" "$M" contracts/998-v43-stderr-kanal.md
if [ "$GATE_RC" -ne 0 ]; then
  printf 'ОТКАЗ: стаб 8e6ec26 (трасса в общем stderr) не воспроизвёл пропуск печати в stderr — rc %s, свидетельство требует rc 0:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
[ "$(printf '%s\n' "$GATE_OUT" | tail -n 1)" = 'OK' ] || {
  printf 'ОТКАЗ: стаб 8e6ec26 дал rc 0, но без канонической последней строки OK:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'свидетельство: ДО фикса печать литерала в stderr проходит — rc 0, «OK»\n' >&2

# Красное предъявление: честный субъект обязан отказать именованным «зелёный
# контроль семьи не предъявлен» — зачёт несёт трасса в гейт-приватном fd,
# потоками пробы гейт не владеет и не судит (036d1f1, класс 030).
run_gate "$BARRIER" "$M" contracts/998-v43-stderr-kanal.md
if [ "$GATE_RC" -ne 1 ]; then
  printf 'ОТКАЗ: печать литерала в stderr (echo … >&2; exit 0) засчитана живым контролем — rc %s, гейт зелёный на обмане:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
printf '%s\n' "$GATE_OUT" | grep -Fq 'зелёный контроль семьи не предъявлен' || {
  printf 'ОТКАЗ: печать в stderr отказана rc 1, но без именованной причины «зелёный контроль семьи не предъявлен»:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'красное предъявление: подделка stderr-канала отказана именованным\n' >&2

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
# специфична подделке канала (литерал в stderr есть, вызова нет), а не слепоте.
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
