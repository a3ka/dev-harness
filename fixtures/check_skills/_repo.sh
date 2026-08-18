# Каркас подставного дерева для фикстур check_skills.
#
# Имя НЕ case_*.sh: сам он фикстурой не считается и в прогон не попадает.
#
# make_tree <каталог> — подставное дерево с ЧЕТЫРЬМЯ скилами и подставным omp.
# Зелёная основа обязательна для положительного контроля каждой фикстуры.
g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$1" -c user.name=Фикстура -c user.email=fixture@local "$@"
}
commit_all() { g "$1" add -A; g "$1" commit -q -m "$2"; }

make_tree() {
  local r="$1"
  mkdir -p "$r/skills/grilling" "$r/skills/writing-for-agents" "$r/skills/tdd" \
           "$r/skills/diagnosing-bugs" "$r/scripts" "$r/fixtures/check_skills" "$r/tmp"
  for s in grilling writing-for-agents tdd diagnosing-bugs; do
    printf -- '---\nname: %s\ndescription: test\n---\ntest body for %s\n' "$s" "$s" > "$r/skills/$s/SKILL.md"
  done
  # Подставной omp: --version для пина, skill-вызов отвечает словом из тела
  mkdir -p "$r/bin"
  cat > "$r/bin/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
printf 'probe-answer\n'
OMP
  chmod +x "$r/bin/omp"
}
