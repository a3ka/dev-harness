# ПРИЧИНА: запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): npm run "$ANTI_SCRIPT" -- --changed ${{ github.event.before }}
#
# Находка адверсария 020 к2 (вердикт 448f4b4), форма «переменное имя скрипта»:
# `npm run "$ANTI_SCRIPT"` с литеральным `env: {ANTI_SCRIPT: check:antiplacebo}` на
# том же шаге. Прежняя редакция ANTI_TSV искала ТОЛЬКО литерал `npm run
# check:antiplacebo` — переменная в командной позиции проходила мимо совпадения по
# подстроке, и `config/ci_parity_exceptions.txt` с записью `команда:` для внешней
# формы (здесь её нет намеренно — сама проба не объявляет исключение, вопрос не в
# нём) легализовал бы правило 6, но не инвариант 4. Барьер обязан САМ статически
# разрешить `$ANTI_SCRIPT` через литеральный `env:` шага (`_resolve_npm_indirection`)
# и увидеть фактический запуск check:antiplacebo вне matrix. Исполненный контрпример
# был предъявлен зелёным (`attack_variable_name.sh`, rc=0) ДО фикса — проба
# регрессионно защищает именно этот обход. Та же ветвь несёт красное
# `case_shard_legacy_shag.sh` (буквальное имя): ветвь одна, переходы разные.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
. "$(dirname "$0")/_shard_tree.sh"
shard_tree "$WORK"
"$BARRIER" "$WORK"
# Стаб: прежний --changed-шаг через ПЕРЕМЕННОЕ ИМЯ скрипта ($ANTI_SCRIPT), значение
# объявлено литерально в env: этого же шага — статически разрешимо, поэтому
# барьер обязан увидеть подставленный запуск и дать красное так же, как на
# буквальном тексте.
sed -i 's|^  antiplacebo:|      - name: Анти-плацебо прежний (переменное имя)\n        env:\n          ANTI_SCRIPT: check:antiplacebo\n        run: npm run "$ANTI_SCRIPT" -- --changed ${{ github.event.before }}\n  antiplacebo:|' \
  "$WORK/.github/workflows/ci.yml"
"$BARRIER" "$WORK"
