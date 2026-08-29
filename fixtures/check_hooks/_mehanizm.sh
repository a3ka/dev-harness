# Каркас полного механизма установки хука (Q6 контракта 016) для фикстур `check_hooks`.
#
# Имя НЕ `case_*.sh`: сам он фикстурой не считается и в прогон не попадает.
#
# Механизм установки = ТРИ коммиченных части:
#   1) .githooks/pre-commit — исполняемый, ведёт к судье scripts/check_staged.sh;
#   2) scripts/check_staged.sh — сам судья (здесь важна лишь его НАЛИЧИСТЬ:
#      поведение судьи — предмет каталога fixtures/check_staged, не этого);
#   3) package.json — установщик: npm-скрипт, выставляющий core.hooksPath на .githooks.
#
# check:hooks проверяет МЕХАНИЗМ, не рантайм-наличие: свежий клон без установки
# хука — статус-кво (остаток назван в контракте), но сломанный/неполный механизм
# в дереве — именованный отказ.
mehanizm() {  # <корень>
  local r="$1"
  mkdir -p "$r/.githooks" "$r/scripts"
  printf '#!/usr/bin/env bash\nexec bash "$(dirname "$0")/../scripts/check_staged.sh" "$(git rev-parse --show-toplevel)"\n' \
    > "$r/.githooks/pre-commit"
  chmod +x "$r/.githooks/pre-commit"
  printf '# судья среза 1; поведение — предмет check_staged, здесь значимо наличие\n' \
    > "$r/scripts/check_staged.sh"
  printf '{\n  "scripts": {\n    "hooks:install": "git config core.hooksPath .githooks"\n  }\n}\n' \
    > "$r/package.json"
}
