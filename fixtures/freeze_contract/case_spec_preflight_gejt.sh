# ПРИЧИНА: spec-preflight 036
# Интеграционный вход freeze_contract: красный черновик (env-красная проба с посторонним
# выводом при заявленной фразе) ⇒ freeze отказывает именем spec-preflight ДО записи тега
# frozen/contracts/001/1 и реестра registry/contracts.tsv. Тестовая пара сшита с г5/г5б
# red_spec_preflight_036 (там же именованная причина и негатив фикстуры о5).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"

# Красный черновик: env-красная проба при заявленной фразе (выход 2, посторонний вывод).
T="$WORK/red_draft"; make_repo "$T"
write_contract() {
  local r="$1" priemka="$2"
  { printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\n'
    printf '%s\n' "$priemka" ; } > "$r/contracts/001-x.md"
  g "$r" add -A && g "$r" commit -q -m 'черновик'
}
write_contract "$T" '- `bash env.sh` → красная: ФРАЗА_Г5'
printf 'echo чужое окружение >&2\nexit 2\n' > "$T/env.sh"
g "$T" add -A && g "$T" commit -q -m 'проба'

# freeze_contract на красном черновике ⇒ отказ именем spec-preflight.
"$BARRIER" contracts/001-x.md "заморозка красного черновика" "$T"