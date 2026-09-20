#!/usr/bin/env bash
# ПРИЧИНА: спек-гейт 036: семья без барьера: scripts/check_netu.sh не существует
# В4-1 (Н-113, вторая половина класса 031-v3: «check_no_leak — НЕ БАРЬЕР,
# scope_select неизвестный ключ»). ЗОНА черновика объявляет семью
# fixtures/check_netu/… с будущим case, а барьера scripts/check_netu.sh
# в дереве нет; приёмка честна по В1 (красная проба с совпавшей фразой).
# Конформность по 019: вход не ломает грамматику гейта (пробы и замеры
# законны), расхождение — на входе семьи: каталог объявлен, барьер отсутствует.
# Дифференциал: СТАБ = check_spec_ready.sh ДО В4 из git-объекта ef5ff3a
# (предок HEAD; 24057a1 меняет в scripts/ только этот файл), прямой запуск —
# исторический субъект-свидетель, не барьер прогона. До В4 такой черновик
# проходит rc 0 «OK»; В4-1 обязан отказать именованным «семья без барьера»
# ДО заморозки, а не молчанием на суде.
set -euo pipefail

make_toy() {  # <каталог> — герметичный git-каркас (Н-12: локальная identity файлом)
  mkdir -p "$1/contracts"
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
# 998 — зелёный контроль В4-1

## Приёмочный критерий
- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА ЗЕЛЁНОГО

## Исполнители и зоны
ЗОНА architect: contracts/998-n113-zelenyj.md
MD
commit_all "$G" 'зелёный черновик'
"$BARRIER" "$G" contracts/998-n113-zelenyj.md

# ── Семья без барьера: ЗОНА объявляет fixtures/check_netu/, барьера нет ───────
H="$WORK/semlja_netu"; make_toy "$H"
mkdir -p "$H/fixtures/check_netu"
printf 'printf "ПРЕДМЕТНАЯ ФРАЗА НЕТУ\\n" >&2\nexit 1\n' > "$H/p_ok.sh"
cat > "$H/fixtures/check_netu/case_x.sh" <<'PROBE'
#!/usr/bin/env bash
# будущая проба семьи netu (класс 031-v3: каталог заявлен, барьера в дереве нет)
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SELF_DIR/../.." && pwd)"
bash "$REPO/scripts/check_netu.sh" "$REPO"
PROBE
cat > "$H/contracts/998-n113-netu.md" <<'MD'
# 998 — Н-113: ЗОНА объявляет семью check_netu, барьер не существует

## Приёмочный критерий
- `bash p_ok.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА НЕТУ

## Исполнители и зоны
ЗОНА architect: fixtures/check_netu/case_x.sh
MD
commit_all "$H" 'семья без барьера'

# Свидетельство дыры: субъект ДО В4 пропускает черновик (rc 0, последняя строка OK).
run_gate "$STAB" "$H" contracts/998-n113-netu.md
if [ "$GATE_RC" -ne 0 ]; then
  printf 'ОТКАЗ: стаб ef5ff3a (до В4) не воспроизвёл пропуск семьи без барьера — rc %s, свидетельство требует rc 0:\n%s\n' "$GATE_RC" "$GATE_OUT" >&2
  exit 1
fi
[ "$(printf '%s\n' "$GATE_OUT" | tail -n 1)" = 'OK' ] || {
  printf 'ОТКАЗ: стаб ef5ff3a дал rc 0, но без канонической последней строки OK:\n%s\n' "$GATE_OUT" >&2
  exit 1
}
printf 'свидетельство: ДО В4 семья без барьера проходит — rc 0, «OK»\n' >&2

# Красное предъявление: честный субъект (В4-1) отказывает именованным
# «семья без барьера» ещё на драфте, до заморозки.
"$BARRIER" "$H" contracts/998-n113-netu.md
