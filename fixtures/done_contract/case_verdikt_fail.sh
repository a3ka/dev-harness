#!/usr/bin/env bash
# ПРИЧИНА: вердикт ревьюера FAIL
# Барьер done_contract.sh судит первую строку вердикта ревьюера (шаг 5):
# «accept» (после trim+case-fold) проходит, всё остальное — отказ. Стаб-
# привязка (Н-39): стаб «вердикт любой формы проходит» ловится здесь.
set -euo pipefail

make_drepo() {
  local r="$1"
  mkdir -p "$r/contracts" "$r/roles" "$r/verdicts/review" "$r/scripts/consumers.d" "$r/fixtures"
  printf 'scripts/freeze_contract.sh\tfixtures/reader.sh\n' > "$r/scripts/consumers.d/freeze_contract.sh__reader_sh.tsv"
  printf 'scripts/lib_registry.sh\tscripts/spawner.sh\n'    > "$r/scripts/consumers.d/lib_registry.sh__spawner_sh.tsv"
  printf 'scripts/done_contract.sh\tscripts/speccer.sh\n'   > "$r/scripts/consumers.d/done_contract.sh__speccer_sh.tsv"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/freeze_contract.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/lib_registry.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/done_contract.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/spawner.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/speccer.sh"
  printf '# consumer fixture\n' > "$r/fixtures/reader.sh"
  printf '# role fixture\n\nNorma stroki roli v igrushke D.\n' > "$r/roles/fixer.md"
  printf '# kontrakt 001\n\n## Norma-provodka\nПРОВОДКА:\n- role=roles/fixer.md «Norma stroki roli v igrushke D.»\n' > "$r/contracts/001-x.md"
  printf 'accept\ntelo verdikta\n' > "$r/verdicts/review/contracts-001-v1.md"
}

commit_in() {
  git -C "$1" -c user.name=Fixture -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  git -C "$1" -c user.name=Fixture -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "$2"
}

G="$WORK/green"; make_drepo "$G"
git -C "$G" init -q
commit_in "$G" 'osnovanie'
"$BARRIER" contracts/001-x.md 'prizemlenie chestnoe' "$G"

R="$WORK/red"; make_drepo "$R"
git -C "$R" init -q
commit_in "$R" 'osnovanie'
# Подменяем done_contract.sh на стаб-всегда-OK.
cat > "$R/scripts/done_contract.sh" <<'STUB'
#!/usr/bin/env bash
# НЕ БАРЬЕР
# Стаб: пропускает любое дерево, ставит done-тег всегда.
git -C "$3" tag -a done/contracts/001/1 -m "stub"
echo v1
exit 0
STUB
chmod +x "$R/scripts/done_contract.sh"
# Вердикт FAIL
printf 'FAIL\ntelo\n' > "$R/verdicts/review/contracts-001-v1.md"
commit_in "$R" 'verdikt fail'
"$BARRIER" contracts/001-x.md 'prizemlenie' "$R"
