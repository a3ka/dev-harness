#!/usr/bin/env bash
# Красное предъявление 036, ветвь В3 «перенос зоны» (боль 75f5ffe/v4-класс:
# v2-перенос ЗОНА-путей 031 молча выкинул v1-покрытие трёх коммитов → СПАСЕНО-v4
# стоил форк owner-канала, консультанта, подпись и scoped-круг).
#
# Каталог ОТКРЫТ для architect (живая матрица круга 1, Б2); файл ложится ТЕМ ЖЕ
# коммитом, что и контракт. Прямой запуск — red_* вне case_*-глоба раннера (А-82).
#
# Б1 круга 1: грамматика СПАСЕНО — НАСТОЯЩАЯ 003-v3 (живой потребитель
# scripts/check_zones.sh:188–235): «СПАСЕНО <автор>: <полные 40-hex через
# пробел> — <непустая причина>». Псевдо-грамматика v1 «СПАСЕНО: <путь> — …»
# не спасает историю — доказано критиком на toy; здесь это воспроизведено
# ФИКСТУРОЙ как постоянная часть приёмки.
#
# ВОРОТА (оракул — в памяти предъявления, правило 8):
#   г4  боль v4: v2 выкидывает scripts/foo.sh из ЗОНА implementer → rc 1
#        «перенос зоны: scripts/foo.sh (implementer): коммит <sha> не покрыт
#        СПАСЕНО (замороженный frozen/contracts/001/1)»;
#   г4б настоящая грамматика: `СПАСЕНО implementer: <полный 40-hex> — перенос
#        в семейство Y` → гейт rc 0; И живой потребитель: toy с ЗАМОРОЖЕННОЙ v2
#        (тег) → настоящий check_zones rc 0 «СПАСЕНО, из суда зон выведен»;
#   г4б-боль живьём: та же toy, v2 без СПАСЕНО → check_zones rc 1 «коммит вне
#        зоны» (пример критика);
#   г4в валидная строка, хеши не связаны с выпавшим путём → «не привязан к
#        выпавшему пути»;
#   г4д псевдо-грамматика v1 → «не по грамматике»;
#   г4е без предыдущих версий (тега нет) → rc 0 (vacuous);
#   стабы Н-39 (в коде, не в прозе): с3 «зоны-только-синтаксис» — вход г4;
#   с4 «СПАСЕНО-пропускник» (любая строка со словом СПАСЕНО освобождает) —
#   вход г4д. Каждый расходится с честным предметом ровно на своём входе.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_spec_ready.sh"
CZ="$REPO/scripts/check_zones.sh"
[ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 036 НЕ РЕАЛИЗОВАН: В3 перенос зоны — %s отсутствует на дереве\n' "$SUBJ" >&2; exit 1; }
[ -f "$CZ" ] || { printf 'NOT_IMPLEMENTED: живой потребитель %s не найден\n' "$CZ" >&2; exit 2; }

. "$HERE/_repo.sh"   # g, commit_as, make_repo, freeze_ver — общие помощники семьи

WORK="$(mktemp -d "${TMPDIR:-/tmp}/v3_036.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

LAST_OUT=''; LAST_RC=0
run_gate() {  # <субъект> <каталог>
  local subj="$1" r="$2"
  LAST_OUT="$(cd "$r" && bash "$subj" "$r" contracts/001-x.md 2>&1)"; LAST_RC=$?
}
want() {  # <имя> <субъект> <каталог> <want_rc> <фраза|->
  local name="$1" subj="$2" r="$3" wrc="$4" phrase="$5"
  run_gate "$subj" "$r"
  [ "$LAST_RC" -eq "$wrc" ] || { printf 'ОТКАЗ: ворота %s: rc %s, ожидался %s\nвывод:\n%s\n' "$name" "$LAST_RC" "$wrc" "$LAST_OUT" >&2; exit 1; }
  if [ "$wrc" -eq 0 ]; then
    [ "$(printf '%s\n' "$LAST_OUT" | tail -n 1)" = "OK" ] || { printf 'ОТКАЗ: ворота %s: rc 0 без «OK» последней строкой:\n%s\n' "$name" "$LAST_OUT" >&2; exit 1; }
  else
    printf '%s\n' "$LAST_OUT" | grep -Fq -- "$phrase" || { printf 'ОТКАЗ: ворота %s: вывод не несёт «%s»:\n%s\n' "$name" "$phrase" "$LAST_OUT" >&2; exit 1; }
  fi
  printf 'ворота %s: rc %s — как заявлено\n' "$name" "$LAST_RC" >&2
}
stab_mismatch() {  # <имя> <субъект> <каталог> <честный rc>
  local name="$1" subj="$2" r="$3" honest="$4"
  run_gate "$subj" "$r"
  [ "$LAST_RC" -ne "$honest" ] || { printf 'ОТКАЗ: стаб %s не расходится с честным предметом (rc %s) — заглушка устарела, предъявление не различает\n' "$name" "$LAST_RC" >&2; exit 1; }
  printf 'стаб-ворота %s: расходится с честным (rc %s ≠ %s) — предъявление различает\n' "$name" "$LAST_RC" "$honest" >&2
}
run_cz() {  # <каталог>: живой запуск настоящего потребителя зон
  LAST_OUT="$(cd "$1" && bash "$CZ" . 2>&1)"; LAST_RC=$?
}

# ── с3 «зоны-только-синтаксис»: ЗОНА-строки parses, union не сравнивает ───────
cat > "$WORK/s3.sh" <<'STAB'
#!/usr/bin/env bash
set -uo pipefail
root="$1"; c="$2"
grep -E '^ЗОНА [^:]+: ' "$root/$c" >/dev/null || { printf 'спек-гейт 036: зон нет\n' >&2; exit 1; }
echo OK
STAB

# ── с4 «СПАСЕНО-пропускник»: любое слово СПАСЕНО освобождает перенос ──────────
cat > "$WORK/s4.sh" <<'STAB'
#!/usr/bin/env bash
set -uo pipefail
root="$1"; c="$2"
grep -E '^ЗОНА [^:]+: ' "$root/$c" >/dev/null || { printf 'спек-гейт 036: зон нет\n' >&2; exit 1; }
grep -q 'СПАСЕНО' "$root/$c" && { echo OK; exit 0; }
printf 'спек-гейт 036: перенос зоны без СПАСЕНО\n' >&2; exit 1
STAB

# toy-основание: v1 заморожен с зоной implementer на foo+bar; исторический
# коммит implementer по foo — его полный SHA и есть оракул г4б.
mk_base() {  # <каталог> → FOO_SHA в глобале
  local r="$1"
  make_repo "$r" 'ЗОНА implementer: scripts/foo.sh scripts/bar.sh'
  printf 'foo\n' > "$r/scripts/foo.sh"
  commit_as "$r" implementer 'исторический коммит по foo'
  FOO_SHA="$(g "$r" rev-parse HEAD)"
}
draft_v2() {  # <каталог> <декларация ЗОНА> [строки поверх…]
  local r="$1" decl="$2"; shift 2
  { printf '# контракт 001 v2\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n%s\n' "$decl"
    for l in "$@"; do printf '%s\n' "$l"; done ; } > "$r/contracts/001-x.md"
}

# ── входы г4/г4б/г4д (спек-гейт судит ЧЕРНОВИК до заморозки) ─────────────────
T4="$WORK/g4";   mk_base "$T4";   draft_v2 "$T4" 'ЗОНА implementer: scripts/bar.sh'
T4B="$WORK/g4b"; mk_base "$T4B";  draft_v2 "$T4B" 'ЗОНА implementer: scripts/bar.sh' "СПАСЕНО implementer: $FOO_SHA — перенос в семейство Y"
T4D="$WORK/g4d"; mk_base "$T4D";  draft_v2 "$T4D" 'ЗОНА implementer: scripts/bar.sh' 'СПАСЕНО: scripts/foo.sh — перенос в семейство Y'

# ── вход г4в: ничего не выпало, а СПАСЕНО называет бар-коммит ────────────────
T4V="$WORK/g4v"; mk_base "$T4V"
printf 'bar\n' > "$T4V/scripts/bar.sh"
commit_as "$T4V" implementer 'исторический коммит по bar'
BAR_SHA="$(g "$T4V" rev-parse HEAD)"
draft_v2 "$T4V" 'ЗОНА implementer: scripts/foo.sh scripts/bar.sh' "СПАСЕНО implementer: $BAR_SHA — перенос в семейство Y"

# ── вход г4е: предыдущих версий нет (тега frozen нет) → vacuous ──────────────
T4E="$WORK/g4e"
mkdir -p "$T4E/contracts"
printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Исполнители и зоны\nЗОНА implementer: scripts/bar.sh\n' > "$T4E/contracts/001-x.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$T4E"
g "$T4E" add -A && g "$T4E" commit -q -m основание

# ── г4б живьём (Б1): тот же toy, но v2 ЗАМОРОЖЕН — судит НАСТОЯЩИЙ check_zones ─
TL_NEG="$WORK/live_neg"; mk_base "$TL_NEG"
freeze_ver "$TL_NEG" 2 'ЗОНА implementer: scripts/bar.sh'
TL_POS="$WORK/live_pos"; mk_base "$TL_POS"
freeze_ver "$TL_POS" 2 "ЗОНА implementer: scripts/bar.sh
СПАСЕНО implementer: $FOO_SHA — перенос в семейство Y"

# ── предъявление ──────────────────────────────────────────────────────────────
want г4  "$SUBJ" "$T4"  1 'спек-гейт 036: перенос зоны: scripts/foo.sh (implementer)'
want г4б "$SUBJ" "$T4B" 0 -
want г4в "$SUBJ" "$T4V" 1 'спек-гейт 036: СПАСЕНО не привязан к выпавшему пути'
want г4д "$SUBJ" "$T4D" 1 'спек-гейт 036: СПАСЕНО не по грамматике'
want г4е "$SUBJ" "$T4E" 0 -

run_cz "$TL_NEG"
[ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: живой контроль боли: check_zones на переносе без СПАСЕНО дал rc %s, ожидался 1 (пример критика):\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf 'ворота г4б-боль: живой check_zones красен без СПАСЕНО (rc 1) — как в вердикте круга 1\n' >&2

run_cz "$TL_POS"
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: ворота г4б-жив: настоящий check_zones не принял СПАСЕНО-грамматику 003-v3 (rc %s) — Б1 не закрыт:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf '%s\n' "$LAST_OUT" | grep -Fq 'СПАСЕНО, из суда зон выведен' || { printf 'ОТКАЗ: ворота г4б-жив: check_zones не назвал спасение:\n%s\n' "$LAST_OUT" >&2; exit 1; }
printf 'ворота г4б-жив: настоящий check_zones вывел коммит из суда (rc 0) — грамматика совместима (Б1)\n' >&2

stab_mismatch с3-зоны-только-синтаксис "$WORK/s3.sh" "$T4" 1
stab_mismatch с4-СПАСЕНО-пропускник   "$WORK/s4.sh" "$T4D" 1
exit 0
