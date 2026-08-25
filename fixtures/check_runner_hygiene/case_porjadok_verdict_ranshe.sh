# ПРИЧИНА: ДО аннотации
# Ветвь (porjadok): барьер ловит обход «вердикт написан заранее» — вердикт 010-v2
# (accept) закоммичен ДО того, как аннотация попала в контракт 010: критик судил
# блоб, которого ещё не было («тот же круг» из первой редакции; обход кругов 1–2
# критика). Зелёный контроль — два акта в правильном порядке: (i) implementer
# вносит аннотацию, (ii) critic ОТДЕЛЬНЫМ позже идущим коммитом — вердикт.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_porjadok_green "$G"
"$BARRIER" "$G" porjadok

# Красное: (0) база без аннотации → (1) вердикт critic ПО аннотации-которой-нет →
# (2) implementer вносит аннотацию ПОСЛЕ вердикта: A=последний коммит с 010 новее V.
R="$WORK/red"; mkdir -p "$R/scripts" "$R/contracts" "$R/verdicts/critic"
cp "$HYG/_ref_runner.sh" "$R/scripts/verify_antiplacebo.sh"
chmod +x "$R/scripts/verify_antiplacebo.sh"
mk_norm_agents "$R"
cat > "$R/contracts/010-topologija-orkestrator-arhitektor.md" <<'EOF'
# Контракт 010 (игрушечный): п.8 ещё БЕЗ аннотации — старый блоб

## §Приёмка

8. Регресс: `npm run check:ci-parity` → 0; `bash scripts/verify_antiplacebo.sh` → 0.
EOF
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
pgit_commit_as "$R" implementer 'база: раннер + устав + 010 без аннотации'
printf 'accept\nвердикт по блобу, которого ещё не было (обход кругов 1-2)\n' \
  > "$R/verdicts/critic/contracts-010-v2.md"
pgit_commit_as "$R" critic 'вердикт 010-v2: accept — раньше аннотации'
cat > "$R/contracts/010-topologija-orkestrator-arhitektor.md" <<'EOF'
# Контракт 010 (игрушечный): аннотация внесена ПОСЛЕ вердикта

## §Приёмка

8. Регресс: `npm run check:ci-parity` → 0; `bash scripts/verify_antiplacebo.sh` → 0
   (отменено грилингом 2026-08-24, см. contracts/011: судье — scoped-регресс затронутых
   барьеров, полный прогон — CI, Н-48).
EOF
pgit_commit_as "$R" implementer 'аннотация 010 после вердикта'
"$BARRIER" "$R" porjadok
