# ПРИЧИНА: не наблюдался на непредсказуемом составе
# Ветвь (sostav): обманка РАСПОЗНАВАНИЯ КАРДИНАЛЬНОСТИ (находка 2 адверсария, круг 2,
# дословная семантика): «ровно 1 check и 1 case (check_a/case_a) ЛИБО ровно 3 check_* и
# ровно 6 case_* → exec эталона; иначе — "complete verification accepted", exit 0».
# Одноразовые суффиксы имён не защищают: обманке достаточно счёта. Усиленная ветвь
# гоняет ДВЕ кардинальности — 3×2 (форма находки) и 4×2 (не совпадает ни с 1×1, ни с
# 3×6): на второй делегировать некому, ветка «иначе» не создаёт ни lock, ни run, ни
# свидетельств работы. Зелёный контроль — эталон: ФАКТИЧЕСКИ исполняет каждый
# барьер/фикстуру на любой кардинальности (минимальный наблюдаемый контракт).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" sostav

R="$WORK/red"; mkdir -p "$R/scripts" "$R/fixtures/check_runner_hygiene"
cp "$HYG/_ref_runner.sh" "$R/fixtures/check_runner_hygiene/_ref_runner.sh"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка кардинальности (находка 2 адверсария, круг 2): известные КАРДИНАЛЬНОСТИ —
# честный эталон, любой прочий состав — «успех» без единого вызова
ck=0; for f in "$1"/scripts/check_*.sh; do [ -e "$f" ] && ck=$((ck + 1)); done
cs=0; for f in "$1"/fixtures/*/case_*.sh; do [ -e "$f" ] && cs=$((cs + 1)); done
if { [ "$ck" = 1 ] && [ "$cs" = 1 ] && [ -f "$1/scripts/check_a.sh" ]; } \
   || { [ "$ck" = 3 ] && [ "$cs" = 6 ]; }; then
  exec "$(dirname "$0")/../fixtures/check_runner_hygiene/_ref_runner.sh" "$@"
fi
printf 'complete verification accepted\n'
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" sostav
