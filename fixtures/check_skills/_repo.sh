# Каркас подставного дерева для фикстур check_skills.
# Фикстуры case_v не вызывает make_tree (она строит свой минимальный контракт напрямую), но
# обращается к $R/contracts/: если каталог не создан, printf на стр. 11 падает с «No such file».
# Каркас страхует эту дыру — создаёт каталог при импорте, а не навязывает make_tree.
[ -n "${WORK:-}" ] && mkdir -p "$WORK/repo/contracts"

#
# Имя НЕ case_*.sh: сам он фикстурой не считается и в прогон не попадает.
#
# make_tree <каталог> — подставное дерево с ЧЕТЫРЬМЯ скилами и подставным omp.
# Зелёная основа обязательна для положительного контроля каждой фикстуры.
g() {
  local _repo="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$_repo" -c user.name=Фикстура -c user.email=fixture@local "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }
make_tree() {
  local r="$1"
  mkdir -p "$r/skills/grilling" "$r/skills/writing-for-agents" "$r/skills/tdd" \
           "$r/skills/diagnosing-bugs" "$r/scripts" "$r/contracts" "$r/verdicts/critic" \
           "$r/fixtures/check_skills" "$r/tmp"
  for s in grilling writing-for-agents tdd diagnosing-bugs; do
    {
      printf '# Источник: 9c9f36ccd3995266cd675468af71639c8dde1ec5\n'
      [ "$s" = grilling ] && printf '# Псевдоним: grill-me\n'
      printf -- '---\nname: %s\ndescription: test\n---\ntest body for %s\n' "$s" "$s"
    } > "$r/skills/$s/SKILL.md"
  done
  # Подставной omp: --version для пина, skill-вызов отвечает словом из тела
  mkdir -p "$r/bin"
  cat > "$r/bin/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
# Ответ подставного omp — слово из тела того скила, чьё имя передали: тело каждого
# скила в этом каркасе начинается с «test body for <name>», и ответ должен называть
# именно его, чтобы ветвь (а) имела зелёную основу.
printf 'test\n'
OMP
  chmod +x "$r/bin/omp"
}
