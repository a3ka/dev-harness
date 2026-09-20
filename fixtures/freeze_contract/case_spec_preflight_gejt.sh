# ПРИЧИНА: spec-preflight 036
# Интеграционный вход freeze_contract: красный черновик (env-красная проба с посторонним
# выводом при заявленной фразе) ⇒ freeze отказывает именем spec-preflight ДО записи тега
# frozen/contracts/001/1 и реестра registry/contracts.tsv. Зелёный контроль — честный
# черновик (rc=1 с совпавшей фразой) ⇒ freeze проходит. Тестовая пара сшита с г5/г5б
# red_spec_preflight_036.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"

write_contract_() {
  local r="$1" priemka="$2"
  { printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\n'
    printf '%s\n' "$priemka" ; } > "$r/contracts/001-x.md"
  g "$r" add -A && g "$r" commit -q -m 'черновик'
}

# Зелёный контроль: честная проба rc=1 с заявленной причиной в выводе.
G="$WORK/green"; make_repo "$G"
write_contract_ "$G" '- `bash ok.sh` → красная: ПРИЧИНА_Г5Б'
printf 'echo ПРИЧИНА_Г5Б >&2\nexit 1\n' > "$G/ok.sh"
g "$G" add -A && g "$G" commit -q -m 'проба'
"$BARRIER" contracts/001-x.md "заморозка честного черновика" "$G"

# Красное: env-красная проба при заявленной фразе (выход 2, посторонний вывод).
R="$WORK/red_draft"; make_repo "$R"
write_contract_ "$R" '- `bash env.sh` → красная: ФРАЗА_Г5'
printf 'echo чужое окружение >&2\nexit 2\n' > "$R/env.sh"
g "$R" add -A && g "$R" commit -q -m 'проба'
"$BARRIER" contracts/001-x.md "заморозка красного черновика" "$R"