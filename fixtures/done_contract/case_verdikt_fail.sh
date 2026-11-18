#!/usr/bin/env bash
# ПРИЧИНА: вердикт ревьюера FAIL
# Барьер done_contract.sh судит первую строку вердикта ревьюера (шаг 5):
# «accept» (после trim+case-fold) проходит, всё остальное — отказ. Стаб-
# привязка (Н-39): стаб «вердикт любой формы проходит» ловится здесь.
#
# Игрушечный мир G — честный мир НОВОЙ двери (контракт 201, дверь 095), иначе
# зелёный контроль краснел не по своему предмету, а по чужой двери:
#   • заморозка frozen/contracts/001/1 — тег на базовом коммите (пункт (а)
#     двери: accept привязан к последней заморозке, без неё отказ «нет
#     заморозки frozen/contracts/001/*»);
#   • вердикт ревьюера accept со строкой OBJECT=<40 hex> — объект реализации
#     назван и связан с заморозкой (F ⊆ OBJECT);
#   • «КЛАСС РИСКА: обычный» в замороженном тексте — риск не объявлен →
#     по умолчанию рисковый → нужен accept адверсария (пункт (в));
#   • «ПРОДУКТ: станция» — место реализации объявлено явно, реестр
#     registry/mesto-legacy.tsv не нужен (пункт (б)).
# Красный мир R — по-прежнему «стаб-всегда-OK + вердикт FAIL»; дверь судит
# вердикт ревьюера ДО содержательной сверки, поэтому отказ остаётся тем же
# («done: вердикт ревьюера FAIL»), а смысл фикстуры не слабеет.
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
  printf '# kontrakt 001\n\n## Norma-provodka\nПРОВОДКА:\n- role=roles/fixer.md «Norma stroki roli v igrushke D.»\n\n## Klass riska\nКЛАСС РИСКА: обычный\n\n## Mesto realizacii\nПРОДУКТ: станция\n' > "$r/contracts/001-x.md"
}

# Вердикт ревьюера: первая строка — грамматика двери (accept|FAIL|ESCALATE),
# OBJECT=<40 hex> — объект реализации (пункт (а) двери 201).
put_verdict() {  # <корень> <первая строка> [OBJECT]
  local r="$1" first="$2" object="${3:-}"
  mkdir -p "$r/verdicts/review"
  {
    printf '%s\n' "$first"
    if [ -n "$object" ]; then printf 'OBJECT=%s\n' "$object"; fi
    printf 'telo verdikta\n'
  } > "$r/verdicts/review/contracts-001-v1.md"
}

# Заморозка версии 1 — тег frozen/contracts/001/1 на текущем коммите.
freeze_in() {  # <корень>
  git -C "$1" -c user.name=Fixture -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      tag -a frozen/contracts/001/1 -m 'zamorozka 001 v1' HEAD
}

commit_in() {
  git -C "$1" -c user.name=Fixture -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null add -A
  git -C "$1" -c user.name=Fixture -c user.email=fixture@local -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "$2"
}

G="$WORK/green"; make_drepo "$G"
git -C "$G" init -q
commit_in "$G" 'osnovanie'
# Заморозка версии 1 — на базовом коммите; вердикт ревьюера — ПОСЛЕ заморозки
# и с OBJECT=<sha заморозки>: F ⊆ OBJECT, accept свежее заморозки.
freeze_in "$G"
put_verdict "$G" 'accept' "$(git -C "$G" rev-parse HEAD)"
commit_in "$G" 'verdikt accept'
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
put_verdict "$R" 'FAIL'
commit_in "$R" 'verdikt fail'
"$BARRIER" contracts/001-x.md 'prizemlenie' "$R"
