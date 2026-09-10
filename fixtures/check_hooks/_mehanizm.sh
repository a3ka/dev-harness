# Каркас полного механизма установки хуков для фикстур `check_hooks`
# (Q6 контракта 016 — pre-commit; контракт 022 — pre-push, фазы 6–8 check_hooks).
#
# Имя НЕ `case_*.sh`: сам он фикстурой не считается и в прогон не попадает.
#
# Механизм установки = ПЯТЬ коммиченных частей:
#   1) .githooks/pre-commit — исполняемый, ведёт к судье scripts/check_staged.sh;
#   2) scripts/check_staged.sh — сам судья (здесь значима лишь НАЛИЧНОСТЬ:
#      поведение судьи — предмет каталога fixtures/check_staged, не этого);
#   3) package.json — установщик: npm-скрипт, выставляющий core.hooksPath на .githooks;
#   4) .githooks/pre-push — исполняемый, не-комментарной строкой импортирует кольцо
#      scripts/check_charter.sh (контракт 022, И-4: текст-фаза 7);
#   5) сам pre-push — ЖИВАЯ копия хука предмета: двухфазная push-проба (фаза 8)
#      гоняет хук ИЗ ПРОВЕРЯЕМОГО КОРНЯ против живого кольца из SELF_DIR барьера,
#      поэтому зелёный контроль обязан быть честным механизмом, не заглушкой
#      (А-101: зелёный контроль старого мира краснеет против выросшего барьера).
#
# check:hooks проверяет МЕХАНИЗМ, не рантайм-наличие: свежий клон без установки
# хука — статус-кво (остаток назван в контракте), но сломанный/неполный механизм
# в дереве — именованный отказ.
mehanizm() {  # <корень>
  local r="$1"
  local repo="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  mkdir -p "$r/.githooks" "$r/scripts"
  printf '#!/usr/bin/env bash\nexec bash "$(dirname "$0")/../scripts/check_staged.sh" "$(git rev-parse --show-toplevel)"\n' \
    > "$r/.githooks/pre-commit"
  chmod +x "$r/.githooks/pre-commit"
  printf '# судья среза 1; поведение — предмет check_staged, здесь значимо наличие\n' \
    > "$r/scripts/check_staged.sh"
  printf '{\n  "scripts": {\n    "hooks:install": "git config core.hooksPath .githooks"\n  }\n}\n' \
    > "$r/package.json"
  cp "$repo/.githooks/pre-push" "$r/.githooks/pre-push"
  chmod +x "$r/.githooks/pre-push"
}
