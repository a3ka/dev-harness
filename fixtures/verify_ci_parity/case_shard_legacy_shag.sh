# ПРИЧИНА: запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run check:antiplacebo -- --changed ${{ github.event.before }}
#
# Чистый cutover (§Предмет п.3, обход №2 вердикта критика v1): полная корректная
# matrix + СОХРАНЁННЫЙ прежний --changed-шаг в главной джобе — слабый барьер смотрел
# только последний анти-плацебо-запуск и зеленел. Стаб вставляет прежний шаг в главную
# джобу ПЕРЕД matrix-джобой (форма исполненного обхода «legacy-step-retained»): сумма
# шардов полна, ключи живы, дублей нет — красное именно исключительности запуска.
# Та же ветвь несёт красное case_shard_scope_sloman (подстрока «не несёт --scope
# с ключами»): ветвь одна, переходы два. До предмета 020 барьер зеленеет — проба
# красна ДО реализации («красное не предъявлено»).
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
. "$(dirname "$0")/_shard_tree.sh"
shard_tree "$WORK"
"$BARRIER" "$WORK"
# Стаб: прежний --changed-шаг оставлен в главной джобе поверх полной matrix.
sed -i 's|^  antiplacebo:|      - name: Анти-плацебо прежний\n        run: npm run check:antiplacebo -- --changed ${{ github.event.before }}\n  antiplacebo:|' \
  "$WORK/.github/workflows/ci.yml"
"$BARRIER" "$WORK"
