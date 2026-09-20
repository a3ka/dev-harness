#!/usr/bin/env bash
# ПРИЧИНА: спек-гейт 036: проба несовместима с грамматикой барьера семьи judge_gate
# В4-2 (Н-113, ревьюер 036 З-1: фикс 24057a1 не был закреплён фикстурой). Дыра A2
# из блоба 6096e3d6: мёртвая проба семьи check_judge_gate зовёт замороженный
# барьер чужой грамматикой (--retake — грамматика check_no_leak 031), а диспетчер-
# отказ скопирован автором в причину «→ красная: неизвестная ветвь».
# Конформность по 019: вызов `check_judge_gate --retake <корень>` соответствует
# документированной грамматике вызываемого инструмента (диспетчер отвечает
# именованным отказом «ОТКАЗ диспетчер»), расхождение — на входе семьи.
# Дифференциал: СТАБ = check_spec_ready.sh ДО В4, извлечён из git-объекта
# ef5ff3a (предок HEAD; 24057a1 меняет в scripts/ только этот файл) и запущен
# напрямую — это исторический субъект-свидетель, а не барьер прогона; канал
# $BARRIER судит только честный субъект. На дыре стаб даёт rc 0 «OK» (замер
# ArchN113, прогон A2), честный субъект обязан дать rc 1 именованным отказом
# argv-совместимости НЕЗАВИСИМО от заявленной автором фразы.
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

# ── Зелёный контроль: честный черновик без семьи → субъект зелёный ────────────
G="$WORK/zelenyj"; make_toy "$G"
printf 'printf "ПРЕДМЕТНАЯ ФРАЗА ЗЕЛЁНОГО\\n" >&2\nexit 1\n' > "$G/p_ok.sh"
cat > "$G/contracts/998-n113-zelenyj.md" <<'MD'
# 998 — зелёный контроль В4-2

## Приёмочный критерий
- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА ЗЕЛЁНОГО

## Исполнители и зоны
ЗОНА architect: contracts/998-n113-zelenyj.md
MD
commit_all "$G" 'зелёный черновик'
"$BARRIER" "$G" contracts/998-n113-zelenyj.md

# ── Дыра A2 (блоб 6096e3d6): мёртвая проба с диспетчер-фразой ────────────────
H="$WORK/dyra_a2"; make_toy "$H"
cp "$REPO/scripts/check_judge_gate.sh" "$H/scripts/check_judge_gate.sh"
cat > "$H/fixtures/check_judge_gate/case_peresnjatie_n113.sh" <<'PROBE'
#!/usr/bin/env bash
# Н-113 контрпример: дословная реконструкция класса 031-v3.
# Case протеста ДВЕРИ ПЕРЕСНЯТИЯ (--retake — грамматика scripts/check_no_leak.sh,
# механизм-2 контракта 031), но лежит в семье check_judge_gate и зовёт её канал
# $BARRIER: scripts/check_judge_gate.sh. Зелёный контроль: вердиктная дельта →
# --retake rc 0 + стенограмма. Замороженный 008 барьер отвечает диспетчер-отказом.
set -uo pipefail
out="$(bash scripts/check_judge_gate.sh --retake . 2>&1)"; rc=$?
printf '%s\n' "$out"
if [ "$rc" -ne 0 ]; then
  printf 'case: дверь --retake отказала (rc=%s)\n' "$rc" >&2
  exit 1
fi
PROBE
cat > "$H/contracts/998-n113-a2.md" <<'MD'
# 998 — Н-113 контрпример A2: мёртвая проба с заявленной диспетчер-фразой

## Приёмочный критерий
- `bash fixtures/check_judge_gate/case_peresnjatie_n113.sh` → красная: неизвестная ветвь

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_peresnjatie_n113.sh
MD
commit_all "$H" 'дыра A2: мёртвая проба с фразой'

# Свидетельство дыры: субъект ДО В4 пропускает черновик (rc 0, последняя строка OK).
run_gate "$STAB" "$H" contracts/998-n113-a2.md
if [ "$GATE_RC" -ne 0 ]; then
  printf 'ОТКАЗ: стаб ef5ff3a (до В4) не воспроизвёл дыру A2 — rc %s, свидетельство требует rc 0:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
[ "$(printf '%s\n' "$GATE_OUT" | tail -n 1)" = 'OK' ] || {
  printf 'ОТКАЗ: стаб ef5ff3a дал rc 0, но без канонической последней строки OK:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'свидетельство: ДО В4 дыра A2 жива — rc 0, «OK»\n' >&2

# Красное предъявление: честный субъект (В4-2) отказывает именованным отказом
# argv-совместимости независимо от заявленной автором причины.
"$BARRIER" "$H" contracts/998-n113-a2.md
