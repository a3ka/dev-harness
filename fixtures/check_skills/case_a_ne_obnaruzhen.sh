# ПРИЧИНА: не обнаружен omp
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH HOME=$WORK/fakehome
#
# Ветвь (а), реестровая v4: живая проба --live с коррелированной парой событий
# (арбитраж orakul-korreljacija). Зелёная основа: stub-omp печатает пару
# tool_execution_start/end по одному toolCallId, args.path = skill://<имя>,
# дословная строка шапки в result, resolvedPath — проектное зеркало; пин под ставку.
# Три красных: omp падает кодом 127; omp отвечает БЕЗ skill://-вызова (чтение
# обычного файла — обход из вердикта draft-r4); resolvedPath указывает в HOME.
# После каждой порчи пин перегенерируется: порча меняет sha бинаря-ставки.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" --live "$R" || true

# Порча 1: omp «вызвал» скил и упал кодом 127 — статус вызова обязан стать отказом
cat > "$R/bin/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
printf 'skill invocation intentionally unavailable\n'
exit 127
OMP
chmod +x "$R/bin/omp"
stub_pin "$R"
"$BARRIER" --live "$R" || true

# Порча 2: omp завершается 0, но read идёт ОБЫЧНЫМ путём файла — skill:// не предъявлен
cat > "$R/bin/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
root="$(cd "$(dirname "$0")/.." && pwd)"
name=""
for a in "$@"; do
  case "$a" in
    *skill://*) name="${a##*skill://}"; name="${name%%[!a-z-]*}"; break ;;
  esac
done
skill_file="$root/.agents/skills/$name/SKILL.md"
line="$(grep -m1 '^# Адаптация: ' "$skill_file")"
printf '{"type":"tool_execution_start","toolCallId":"c-file","toolName":"read","args":{"path":"%s"}}\n' "$skill_file"
printf '{"type":"tool_execution_end","toolCallId":"c-file","toolName":"read","result":{"content":[{"type":"text","text":"%s"}],"details":{"resolvedPath":"%s"}}}\n' "$line" "$skill_file"
OMP
chmod +x "$R/bin/omp"
stub_pin "$R"
"$BARRIER" --live "$R" || true

# Порча 3: пара коррелирована, но resolvedPath — ЧУЖОЙ корень (сеяный HOME), не проектный
cat > "$R/bin/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
name=""
for a in "$@"; do
  case "$a" in
    *skill://*) name="${a##*skill://}"; name="${name%%[!a-z-]*}"; break ;;
  esac
done
home_skill="$HOME/.agents/skills/$name/SKILL.md"
line="$(grep -m1 '^# Адаптация: ' "$home_skill")"
printf '{"type":"tool_execution_start","toolCallId":"c-home","toolName":"read","args":{"path":"skill://%s"}}\n' "$name"
printf '{"type":"tool_execution_end","toolCallId":"c-home","toolName":"read","result":{"content":[{"type":"text","text":"%s"}],"details":{"resolvedPath":"%s"}}}\n' "$line" "$home_skill"
OMP
chmod +x "$R/bin/omp"
stub_pin "$R"
mkdir -p "$WORK/fakehome/.agents/skills"
cp -r "$R/skills/." "$WORK/fakehome/.agents/skills/"
"$BARRIER" --live "$R" || true
