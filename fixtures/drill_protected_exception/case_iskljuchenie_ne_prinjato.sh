# ПРИЧИНА: исключение не принято
#
# Дрилл существует ради зелёной ветви, которую анти-плацебо доказать не умеет. Значит красным
# его предъявляет подставной барьер: `check_protected.sh`, который разрешений не признаёт и
# краснеет всегда.
#
# Зелёный контроль здесь — НАСТОЯЩИЙ `check_protected.sh` рядом с дриллом: на нём дрилл обязан
# вернуть ноль. Так фикстура разводит два случая: «дрилл работает» и «дрилл красен всегда».
set -euo pipefail
mkdir -p "$WORK/scripts"
cp "$REPO/scripts/check_protected.sh" "$WORK/scripts/"
BARRIER_ROOT="$WORK" "$BARRIER"

{
  printf '#!/usr/bin/env bash\n'
  printf '# Подставной барьер: разрешений не признаёт.\n'
  printf '# Коды возврата: 0 — никогда, 1 — всегда.\n'
  printf 'printf "  FAIL защищённый артефакт существовал и на HEAD его нет: что-нибудь\\n" >&2\n'
  printf 'exit 1\n'
} > "$WORK/scripts/check_protected.sh"
chmod +x "$WORK/scripts/check_protected.sh"
BARRIER_ROOT="$WORK" "$BARRIER"
