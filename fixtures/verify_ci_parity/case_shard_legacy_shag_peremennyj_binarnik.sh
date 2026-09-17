# ПРИЧИНА: запуск анти-плацебо вне шардной matrix (не несёт --scope с ключами): "$NPM_BIN" run check:antiplacebo -- --changed ${{ github.event.before }}
#
# Находка адверсария 020 к2 (вердикт 448f4b4), форма «переменный npm-бинарник»:
# `"$NPM_BIN" run check:antiplacebo` с литеральным `env: {NPM_BIN: npm}` на том же
# шаге. Скрипт здесь и так написан буквально — обходом служит переменная НА МЕСТЕ
# самого исполнителя `npm`, а не имени скрипта: прежняя редакция искала литерал
# `npm run check:antiplacebo` (с `npm` первым словом) и не видела форму, где `npm`
# скрыт за индирекцией. Барьер обязан статически разрешить `$NPM_BIN` через
# литеральный `env:` шага (`_resolve_npm_indirection`, позиция бинарника) и увидеть
# фактический запуск check:antiplacebo вне matrix. Исполненный контрпример был
# предъявлен зелёным (`attack_forms.sh`, «variable-binary rc=0») ДО фикса — проба
# регрессионно защищает именно этот обход. Та же ветвь несёт красное
# `case_shard_legacy_shag.sh` (буквальный npm): ветвь одна, переходы разные.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
. "$(dirname "$0")/_shard_tree.sh"
shard_tree "$WORK"
"$BARRIER" "$WORK"
# Стаб: прежний --changed-шаг через ПЕРЕМЕННЫЙ БИНАРНИК npm ($NPM_BIN), значение
# объявлено литерально в env: этого же шага — статически разрешимо, поэтому
# барьер обязан увидеть подставленный запуск и дать красное так же, как на
# буквальном тексте.
sed -i 's|^  antiplacebo:|      - name: Анти-плацебо прежний (переменный бинарник)\n        env:\n          NPM_BIN: npm\n        run: "$NPM_BIN" run check:antiplacebo -- --changed ${{ github.event.before }}\n  antiplacebo:|' \
  "$WORK/.github/workflows/ci.yml"
"$BARRIER" "$WORK"
