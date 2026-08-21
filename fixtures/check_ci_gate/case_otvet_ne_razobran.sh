# ПРИЧИНА: ответ CI не разобран
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# curl ответил телом без total_count (HTML-страница, прокси-заглушка) — это
# НЕ успех: отказ называет разбор, пустая выборка не зелёная. Зелёный
# контроль: настоящий JSON → 0. Красное: HTML → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

printf '<html>502 Bad Gateway</html>\n' > "$WORK/curl.json"
"$BARRIER" "$R"
