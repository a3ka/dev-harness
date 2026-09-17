# ПРИЧИНА: запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run-script check:antiplacebo -- --changed ${{ github.event.before }}
#
# Контракт 020 инвариант 4 через ПСЕВДОНИМ npm: чистый cutover требует, чтобы ни одна
# форма запуска анти-плацебо не оставалась вне matrix-джобы — и `npm run`, и его
# официальный alias `npm run-script` (признанный тем же барьером в правиле 6).
# Прежняя редакция ANTI_TSV искала ЛИТЕРАЛ `npm run check:antiplacebo`, и alias-форма
# проходила зелёной: «сохранённый прежний --changed-шаг через `npm run-script`»
# невидим сборщику. Находка адверсария 020 к1, исправление в ANTI_TSV (нормализация
# `run-script` → `run` на границе слова) делает обе формы взаимно исключительными:
# одна и та же ветвь ловит и канонический, и alias-шаг. Эта проба — регрессионная
# защита на alias-форму: та же матрица, та же полнота, тот же stub — только через
# `npm run-script`. Зелёный контроль в начале предъявляет полную корректную форму;
# повторный прогон после stub'а должен быть красным. Та же ветвь несёт красное
# `case_shard_legacy_shag` (канонический `npm run`): одна ветвь, два перехода.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
. "$(dirname "$0")/_shard_tree.sh"
shard_tree "$WORK"
"$BARRIER" "$WORK"
# Стаб: прежний --changed-шаг через ПСЕВДОНИМ `npm run-script` оставлен в главной джобе
# поверх полной matrix. До фикса инварианта 4 под alias-форму — зелёное; после — красное.
sed -i 's|^  antiplacebo:|      - name: Анти-плацебо прежний (alias)\n        run: npm run-script check:antiplacebo -- --changed ${{ github.event.before }}\n  antiplacebo:|' \
  "$WORK/.github/workflows/ci.yml"
"$BARRIER" "$WORK"
