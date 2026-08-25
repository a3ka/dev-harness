# ПРИЧИНА: пачка доехала после вердикта
# Ветвь (porjadok): барьер ловит обход «пачка доехала после вердикта» (обход круга 3
# критика, замер арбитра 6; РЕШЕНИЕ арбитра по контракту 011, вопрос 3):
# implementer первым коммитом вносит ТОЛЬКО аннотацию 010, critic вторым судит и
# пишет accept, а раннер и норма AGENTS.md доезжают ТРЕТЬИМ коммитом — уже ПОСЛЕ
# вердикта. Порядок «аннотация раньше вердикта» при этом честен — различает именно
# СОСТАВ коммита A: критик судил блоб, в котором половины предмета не было.
# Зелёный контроль — акт (i) ОДНОЙ пачкой (раннер + AGENTS.md + аннотация), акт
# (ii) critic отдельным коммитом.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_porjadok_green "$G"
"$BARRIER" "$G" porjadok

# Красное: (1) ТОЛЬКО аннотация 010 → (2) accept-вердикт critic → (3) раннер +
# норма AGENTS.md ПОСЛЕ вердикта. A = коммит (1): в его составе нет AGENTS.md и
# раннера (замер арбитра 6 — история /tmp/arb011-porjadok).
R="$WORK/red"; mkdir -p "$R/contracts" "$R/scripts" "$R/verdicts/critic"
cat > "$R/contracts/010-topologija-orkestrator-arhitektor.md" <<'EOF'
# Контракт 010 (игрушечный): аннотация внесена — но пачкой из одного файла

## §Приёмка

8. Регресс: `npm run check:ci-parity` → 0; `bash scripts/verify_antiplacebo.sh` → 0
   (отменено грилингом 2026-08-24, см. contracts/011: судье — scoped-регресс затронутых
   барьеров, полный прогон — CI, Н-48).
EOF
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
pgit_commit_as "$R" implementer 'аннотация 010 (акт i) — БЕЗ раннера и устава'
printf 'accept\nкруг критика по блобу, в котором половины предмета не было (обход круга 3)\n' \
  > "$R/verdicts/critic/contracts-010-v2.md"
pgit_commit_as "$R" critic 'вердикт 010-v2: accept (акт ii)'
cp "$HYG/_ref_runner.sh" "$R/scripts/verify_antiplacebo.sh"
chmod +x "$R/scripts/verify_antiplacebo.sh"
mk_norm_agents "$R"
pgit_commit_as "$R" implementer 'раннер + норма AGENTS.md — ПОСЛЕ вердикта (пачка доехала)'
"$BARRIER" "$R" porjadok
