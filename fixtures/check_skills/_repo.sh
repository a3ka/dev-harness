# Каркас подставного дерева для фикстур check_skills.
# Фикстуры case_v не вызывает make_tree (она строит свой минимальный контракт напрямую), но
# обращается к $R/contracts/: если каталог не создан, printf на стр. 11 падает с «No such file».
# Каркас страхует эту дыру — создаёт каталог при импорте, а не навязывает make_tree.
[ -n "${WORK:-}" ] && mkdir -p "$WORK/repo/contracts"

#
# Имя НЕ case_*.sh: сам он фикстурой не считается и в прогон не попадает.
#
# stub_omp <каталог> — подставной omp для ЗЕЛЁНОЙ основы поведенческой ветви (а).
# Отвечает на промпт словом из «…» ЗАГЛАВНЫМИ: рабочий omp с загруженным скилом
# возвращает слово из тела скила, и барьер требует именно его. Фикстура обязана
# объявить его в PATH строкой «# ОКРУЖЕНИЕ: PATH=<каталог>:$PATH».
stub_omp() {
  mkdir -p "$1"
  cat > "$1/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
for a in "$@"; do
  case "$a" in
    *«*»*) a="${a#*«}"; printf '%s\n' "${a%%»*}" | tr '[:lower:]' '[:upper:]'; exit 0 ;;
  esac
done
printf 'stub omp: в промпте нет слова\n' >&2
exit 1
OMP
  chmod +x "$1/omp"
}

# make_tree <каталог> — подставное дерево с ЧЕТЫРЬМЯ скилами и подставным omp.
# Зелёная основа обязательна для положительного контроля каждой фикстуры.
make_tree() {
  local r="$1" s
  mkdir -p "$r/skills/grilling" "$r/skills/writing-for-agents" "$r/skills/tdd" \
           "$r/skills/diagnosing-bugs" "$r/scripts" "$r/contracts" "$r/verdicts/critic" \
           "$r/fixtures/check_skills" "$r/tmp"
  for s in grilling writing-for-agents tdd diagnosing-bugs; do
    {
      printf '# Источник: 9c9f36ccd3995266cd675468af71639c8dde1ec5\n'
      [ "$s" = grilling ] && printf '# Псевдоним: grill-me\n'
      printf -- '---\nname: %s\ndescription: test\n---\ntest body sentinel for %s\n' "$s" "$s"
    } > "$r/skills/$s/SKILL.md"
    # Лишние файлы деревьев — предмет ветви (д): профиль обязан совпадать ПОЛНЫМ
    # деревом, а не одним SKILL.md. Состав зеркалит настоящий skills/.
    mkdir -p "$r/skills/$s/agents"
    printf 'agents-profile: stub for %s\n' "$s" > "$r/skills/$s/agents/openai.yaml"
  done
  printf 'mocking stub\n'      > "$r/skills/tdd/mocking.md"
  printf 'tests stub\n'        > "$r/skills/tdd/tests.md"
  printf 'mechanics stub\n'    > "$r/skills/writing-for-agents/SKILL-MECHANICS.md"
  stub_omp "$r/bin"
}
