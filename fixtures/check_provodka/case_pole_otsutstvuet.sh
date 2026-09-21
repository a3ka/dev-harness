#!/usr/bin/env bash
# ПРИЧИНА: поле ПРОВОДКА отсутствует
# Барьер check_provodka.sh судит наличие поля ПРОВОДКА: в контракте (г0).
# Стаб-привязка (Н-39): стаб «любой файл проходит» пропускает вход — отказ
# обязан называть именем г0.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts" "$G/.githooks" "$G/contracts" "$G/roles"
printf '#!/usr/bin/env bash\nexit 0\n' > "$G/scripts/check_ok.sh"
printf 'bash scripts/check_ok.sh\n' > "$G/.githooks/pre-commit"
printf '# role fixture\n\nNorma stroki roli v igrushke R.\n' > "$G/roles/fixer.md"
printf '# kontrakt\n\nПРОВОДКА:\n- guard=scripts/check_ok.sh\n- role=roles/fixer.md «Norma stroki roli v igrushke R.»\n' > "$G/contracts/001-x.md"
"$BARRIER" "$G" "$G/contracts/001-x.md"

R="$WORK/red"; mkdir -p "$R/contracts" "$R/scripts"
cp "$REPO/scripts/check_provodka.sh" "$R/scripts/check_provodka.sh"
cat > "$R/scripts/check_provodka.sh" <<'STUB'
#!/usr/bin/env bash
# НЕ БАРЬЕР
# Стаб: всегда OK — пропускает вход без проверки.
exit 0
STUB
chmod +x "$R/scripts/check_provodka.sh"
printf '# kontrakt bez polya\n' > "$R/contracts/001-x.md"
"$BARRIER" "$R" "$R/contracts/001-x.md"
