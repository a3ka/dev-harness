# ПРИЧИНА: не обнаружен omp
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Ветвь (а): скил не обнаружен omp — ПОВЕДЕНЧЕСКАЯ. Зелёная основа: подставной omp
# (объявлен в PATH) отвечает словом из тела скила ЗАГЛАВНЫМИ. Два красных — оба из
# вердикта адверсария milestone-003-zakrytie §1: omp падает кодом 127, и omp
# завершается 0, но ответ не называет слова из тела («непусто» больше не ответ).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" "$R"

# Порча 1: omp «вызвал» скил и упал кодом 127 — статус вызова обязан стать отказом
cat > "$R/bin/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
printf 'skill invocation intentionally unavailable\n'
exit 127
OMP
chmod +x "$R/bin/omp"
"$BARRIER" "$R"

# Порча 2: omp завершается 0, но ответ — общий текст без слова из тела скила
cat > "$R/bin/omp" <<'OMP'
#!/usr/bin/env bash
if [ "${1:-}" = "--version" ]; then printf 'omp/17.2.10\n'; exit 0; fi
printf 'skill invocation intentionally unavailable\n'
exit 0
OMP
chmod +x "$R/bin/omp"
"$BARRIER" "$R"
