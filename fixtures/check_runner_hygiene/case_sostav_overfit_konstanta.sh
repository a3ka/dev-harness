# ПРИЧИНА: не наблюдался на непредсказуемом составе
# Ветвь (sostav): барьер ловит раннер-обманку «для известной игрушки — эталон, иначе
# успех» (находка 2 адверсария, круг 1 по контракту 011): на дереве формы build_toy
# (scripts/check_a.sh + fixtures/check_a/case_a.sh) она честно исполняет эталон и
# проходит ветви lock/race/scratch/scratchdef/chistka/pgid, а на ЛЮБОМ другом составе
# печатает «complete verification accepted» и выходит 0, не создав НИЧЕГО — ни lock,
# ни run-каталога в скратче. Ветвь строит состав НЕПРЕДСКАЗУЕМО (одноразовые имена
# барьеров/фикстур), на котором гигиена обязана проявиться теми же признаками, что
# пинует scratchdef: lock <hash8> этого дерева и run-каталог. Обманка ведёт себя
# честно ровно на входах build_toy — её краснота предъявляется ЗДЕСЬ, на входе, где
# её дефект наблюдаем (Н-39). Зелёный контроль — эталон: его гигиена не зависит от
# формы дерева. Поведенческий цикл фикстур — зона check_scoped_run (заморожен 006).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" sostav

R="$WORK/red"; mkdir -p "$R/scripts" "$R/fixtures/check_runner_hygiene"
cp "$HYG/_ref_runner.sh" "$R/fixtures/check_runner_hygiene/_ref_runner.sh"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка-константа вместо вычисления (находка 2 адверсария): известная форма
# игрушки — честный эталон, любой другой вход — «успех» без единой записи
if [ -f "$1/scripts/check_a.sh" ] && [ -f "$1/fixtures/check_a/case_a.sh" ] \
   && [ -f "$(dirname "$0")/../fixtures/check_runner_hygiene/_ref_runner.sh" ]; then
  exec "$(dirname "$0")/../fixtures/check_runner_hygiene/_ref_runner.sh" "$@"
fi
printf 'complete verification accepted\n'
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" sostav
