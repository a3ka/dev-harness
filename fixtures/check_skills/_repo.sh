# Каркас подставного дерева для фикстур check_skills.
# Контракт 003 реестровая v4: зеркало .agents/skills == skills/, живая проба (а) —
# коррелированная пара событий json-потока (арбитраж orakul-korreljacija).
[ -n "${WORK:-}" ] && mkdir -p "$WORK/repo/contracts"

#
# Имя НЕ case_*.sh: сам он фикстурой не считается и в прогон не попадает.
#
# stub_omp <каталог> — подставной omp для ЖИВОЙ пробы (а): печатает json-поток с
# КОРРЕЛИРОВАННОЙ парой событий (args.path = skill://<имя> из промпта; result с дословной
# строкой шапки и resolvedPath — проектное зеркало). Корень дерева выводит из своего пути:
# <корень>/bin/omp → <корень>. Скил читает из ЗЕРКАЛА .agents/skills — как настоящий omp.
stub_omp() {
  mkdir -p "$1"
  cat > "$1/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
root="$(cd "$(dirname "$0")/.." && pwd)"
name=""
for a in "$@"; do
  case "$a" in
    *skill://*) name="${a##*skill://}"; name="${name%%[!a-z-]*}"; break ;;
  esac
done
[ -n "$name" ] || { printf 'stub omp: в промпте нет skill://\n' >&2; exit 1; }
skill_file="$root/.agents/skills/$name/SKILL.md"
[ -f "$skill_file" ] || { printf 'stub omp: скила %s нет в зеркале\n' "$name" >&2; exit 1; }
line="$(grep -m1 '^# Адаптация: ' "$skill_file")"
[ -n "$line" ] || { printf 'stub omp: в шапке нет строки адаптации\n' >&2; exit 1; }
cid="call-stub-$name"
printf '{"type":"session","version":3}\n'
printf '{"type":"agent_start"}\n'
printf '{"type":"turn_start"}\n'
printf '{"type":"tool_execution_start","toolCallId":"%s","toolName":"read","args":{"path":"skill://%s"}}\n' "$cid" "$name"
printf '{"type":"tool_execution_end","toolCallId":"%s","toolName":"read","result":{"content":[{"type":"text","text":"%s"}],"details":{"resolvedPath":"%s"}}}\n' "$cid" "$line" "$skill_file"
printf '{"type":"turn_end"}\n'
OMP
  chmod +x "$1/omp"
}

# stub_pin <корень> — пин под СТАВКУ: sha256 того, что лежит в <корень>/bin/omp.
stub_pin() {
  mkdir -p "$1/config"
  sha="$(sha256sum "$1/bin/omp" | cut -d' ' -f1)"
  printf '{\n  "version": "17.2.10",\n  "sha256": "%s"\n}\n' "$sha" > "$1/config/harness_pin.json"
}

# make_tree <каталог> — подставное дерево: ЧЕТЫРЕ скила, ЗЕРКАЛО .agents/skills,
# подставной omp и пин к нему. Зелёная основа обязательна для положительного контроля.
make_tree() {
  local r="$1" s
  mkdir -p "$r/skills/grilling" "$r/skills/writing-for-agents" "$r/skills/tdd" \
           "$r/skills/diagnosing-bugs" "$r/scripts" "$r/contracts" "$r/verdicts/critic" \
           "$r/fixtures/check_skills" "$r/tmp" "$r/.agents/skills"
  for s in grilling writing-for-agents tdd diagnosing-bugs; do
    {
      printf '# Адаптация: тестовая шапка %s.\n' "$s"
      printf '# Источник: 9c9f36ccd3995266cd675468af71639c8dde1ec5\n'
      [ "$s" = grilling ] && printf '# Псевдоним: grill-me\n'
      printf -- '---\nname: %s\ndescription: test\n---\ntest body sentinel for %s\n' "$s" "$s"
    } > "$r/skills/$s/SKILL.md"
    mkdir -p "$r/skills/$s/agents"
    printf 'agents-profile: stub for %s\n' "$s" > "$r/skills/$s/agents/openai.yaml"
  done
  printf 'mocking stub\n'   > "$r/skills/tdd/mocking.md"
  printf 'tests stub\n'     > "$r/skills/tdd/tests.md"
  printf 'mechanics stub\n' > "$r/skills/writing-for-agents/SKILL-MECHANICS.md"
  cp -r "$r/skills/." "$r/.agents/skills/"
  stub_omp "$r/bin"
  stub_pin "$r"
}
