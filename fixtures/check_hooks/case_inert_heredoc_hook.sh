# ПРИЧИНА: поведенческая проба связи — pre-commit вернул rc=0
#
# Q6 контракта 016, закрытие находки 2 раунда 2 адверсария (`inert-heredoc-hook`,
# verdicts/adversary/contracts-016.md): awk-проверка «не-комментарная строка со
# ссылкой» пропускала pre-commit, где `scripts/check_staged.sh` упомянут ТОЛЬКО в
# теле heredoc — литерал не-комментарен, но не исполняем. Текст-зависимая форма не
# доказывает связь. Закрыто поведенческой пробой в самом check_hooks.sh: на своём
# скратче с подставным staged-нарушением запускается УСТАНОВЛЕННЫЙ pre-commit и
# требуется rc≠0 с именованной причиной судьи.
#
# Различимость входа (Н-39): heredoc-хук ПРОХОДИТ текстовую ветвь (awk видит
# литерал на не-комментарной строке тела heredoc) и ПРОВАЛИВАЕТ поведенческую —
# выходит rc=0, не вызывая судью. Существующая case_huk_kommentarij_vmesto_zapuska.sh
# ловит комментарий (там красит ещё awk); здесь красит именно поведенческая проба.
# Судья в проверяемом корне одновременно подменён на `exit 97`: даже реальный вызов
# такого судьи не дал бы именованной причины — двойная пустышка обязана краснеть.
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

# ── Зелёный контроль: полный честный механизм → rc 0 ───────────────────────────
out_green="$("$BARRIER" "$R" 2>&1)"
if [ "$?" -ne 0 ]; then
  printf 'ОТКАЗ: зелёный контроль не зелёный: %s\n' "$out_green" >&2
  exit 1
fi

# ── Порча: pre-commit — heredoc-литерал без исполняемой связи; судья — exit 97 ──
cat > "$R/.githooks/pre-commit" <<'HOOK'
#!/usr/bin/env bash
: <<'JUDGE_TEXT'
scripts/check_staged.sh
JUDGE_TEXT
exit 0
HOOK
chmod +x "$R/.githooks/pre-commit"
printf '#!/usr/bin/env bash\nexit 97\n' > "$R/scripts/check_staged.sh"
chmod +x "$R/scripts/check_staged.sh"

out_red="$("$BARRIER" "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_red" | grep -q 'поведенческая проба связи'; then
  printf 'ОТКАЗ: фикстура inert-heredoc-hook не назвала причину «поведенческая проба связи»: %s\n' "$out_red" >&2
  exit 1
fi
