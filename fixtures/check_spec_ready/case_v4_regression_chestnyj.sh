#!/usr/bin/env bash
# ПРИЧИНА: спек-гейт 036: проба красна без заявленной причины
# Регресс В4 (Н-113, ревьюер 036 З-1): В4 не куплена ложными отказами. Честный
# контракт 036-формы — красная проба с совпавшей фразой + семья с барьером +
# живой зелёный контроль — обязан проходить rc 0 «OK» и на дереве С В4, и на
# дереве ДО В4: В4 расширяет охват, но не меняет вердикт честному черновику.
# СТАБ = check_spec_ready.sh ДО В4 из git-объекта ef5ff3a (предок HEAD;
# 24057a1 меняет в scripts/ только этот файл), прямой запуск — исторический
# субъект-свидетель, не барьер прогона. Красная половина — регресс В1:
# проба rc≠0 без суффикса «→ красная:» обязана отказывать именованным
# «проба красна без заявленной причины» на ОБОИХ деревьях (лексика В1
# не изменилась — замер grep по обеим версиям субъекта).
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

# ── Честный контракт 036-формы: rc 0 на обоих деревьях ───────────────────────
G="$WORK/chestnyj"; make_toy "$G"
cp "$REPO/scripts/check_judge_gate.sh" "$G/scripts/check_judge_gate.sh"
cat > "$G/scripts/judge_gate.sh" <<'SUBJ'
#!/usr/bin/env bash
# честный предмет: зовёт check_ci_gate со своим $1, пропускает rc, печатает OK
d="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$("$d/check_ci_gate.sh" "$1" 2>&1)"; rc=$?
printf '%s\n' "$out"
if [ "$rc" -eq 0 ]; then printf 'OK\n'; fi
exit "$rc"
SUBJ
cat > "$G/fixtures/check_judge_gate/case_zhivoj_kontrol.sh" <<'PROBE'
#!/usr/bin/env bash
# живой зелёный контроль семьи: вызов scripts/check_judge_gate.sh совместимой
# грамматикой (известная ветвь «зелёный») на настоящем предмете judge_gate.sh
set -uo pipefail
exec bash scripts/check_judge_gate.sh . зелёный
PROBE
printf 'printf "ПРЕДМЕТНАЯ ФРАЗА ЧЕСТНОГО\\n" >&2\nexit 1\n' > "$G/p_ok.sh"
cat > "$G/contracts/998-n113-chestnyj.md" <<'MD'
# 998 — честный контракт 036-формы (регресс В4)

## Приёмочный критерий
- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА ЧЕСТНОГО
- `bash fixtures/check_judge_gate/case_zhivoj_kontrol.sh`

## Исполнители и зоны
ЗОНА architect: fixtures/check_judge_gate/case_zhivoj_kontrol.sh
MD
commit_all "$G" 'честный черновик'

# Зелёный контроль на честном субъекте (с В4): rc 0.
"$BARRIER" "$G" contracts/998-n113-chestnyj.md

# Не куплено ложными отказами: ДО В4 тот же честный черновик тоже rc 0 «OK».
run_gate "$STAB" "$G" contracts/998-n113-chestnyj.md
if [ "$GATE_RC" -ne 0 ]; then
  printf 'ОТКАЗ: стаб ef5ff3a (до В4) покраснел на честном черновике — rc %s, регресс-свидетельство требует rc 0:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
[ "$(printf '%s\n' "$GATE_OUT" | tail -n 1)" = 'OK' ] || {
  printf 'ОТКАЗ: стаб ef5ff3a дал rc 0, но без канонической последней строки OK:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'свидетельство: честный черновик зелёен на ДОМЕ и на ПОСЛЕ-В4 дереве\n' >&2

# ── Регресс В1: проба красна без заявленной причины — отказ на обоих деревьях ─
R="$WORK/regress_v1"; make_toy "$R"
printf 'exit 1\n' > "$R/p_bad.sh"
cat > "$R/contracts/998-n113-regress.md" <<'MD'
# 998 — регресс В1: красная проба без суффикса

## Приёмочный критерий
- `bash p_bad.sh`

## Исполнители и зоны
ЗОНА architect: contracts/998-n113-regress.md
MD
commit_all "$R" 'проба без причины'
run_gate "$STAB" "$R" contracts/998-n113-regress.md
if [ "$GATE_RC" -ne 1 ] || ! printf '%s\n' "$GATE_OUT" | grep -Fq 'проба красна без заявленной причины'; then
  printf 'ОТКАЗ: стаб ef5ff3a не воспроизвёл отказ В1 (ожидался rc 1 с прежней лексикой), получено rc %s:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi

# Красное предъявление: честный субъект отказывает той же именованной причиной.
"$BARRIER" "$R" contracts/998-n113-regress.md
