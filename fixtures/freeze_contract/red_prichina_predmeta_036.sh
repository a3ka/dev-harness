#!/usr/bin/env bash
# Красное предъявление 036, ветвь В1 «причина-предмета» (боль Н-113/v3-класс:
# case_peresnjatie_* краснели «ОТКАЗ диспетчер: неизвестная ветвь» — argv чужой
# семьи; сегодня ЛЮБАЯ краснота проходит предполёт).
#
# Каталог ОТКРЫТ для architect (живая матрица круга 1, Б2): файл ложится ТЕМ ЖЕ
# коммитом, что и контракт (AGENTS 127–133 red-first). Прямой запуск — red_*
# вне case_*-глоба раннера (А-82).
#
# ВОРОТА (оракул — в памяти предъявления, правило 8: toy строится здесь,
# ожидания снимаются ДО вызова субъекта; диск проверяемого как истина не
# перечитывается):
#   г1  зелёный контроль: проба rc 0 → гейт rc 0 «OK» последней строкой (008);
#        проба rc 1 с совпавшей заявленной фразой → rc 0 (ре-фриз реализованного
#        предмета видит зелёное/честное красное — асимметрия названа в контракте);
#   г2  боль Н-113: проба выходит 2 с ПОСТОРОННИМ выводом при заявленной
#        предметной фразе → rc 1 «проба красна не по предмету: вывод не несёт
#        заявленной причины»;
#   г2б проба rc 1 без суффикса → rc 1 «проба красна без заявленной причины»;
#   г2в файла пробы нет → rc 1 «проба не исполняема»;
#   стаб-ворота Н-39 (заглушки ЗДЕСЬ, в коде, не в прозе контракта):
#   с1  «любая-красная-годится» — принимает любую красноту без сверки фразы;
#        дефект наблюдаем ровно на входе г2 (там rc 0 вместо 1);
#   с6  «перестарался-зелёную-валит» — краснит зелёную пробу; дефект наблюдаем
#        ровно на входе г1 (там rc 1 вместо 0).
# Заглушка, НЕ разошедшаяся с честным предметом на своём входе, краснит
# предъявление именем стаба (устаревшая заглушка = предъявление не различает).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_spec_ready.sh"
[ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 036 НЕ РЕАЛИЗОВАН: В1 причина-предмета — %s отсутствует на дереве\n' "$SUBJ" >&2; exit 1; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/v1_036.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# герметичный git (прецедент _repo.sh: глобальная gpgsign/hooksPath валят
# построение истории кодом 128/1 — тогда toy краснел бы от окружения, не от предмета)
G() { local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

mk_toy() {  # <каталог> <тело «## Приёмка»>
  local r="$1" priemka="$2"
  mkdir -p "$r/contracts"
  { printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\n'
    printf '%s\n' "$priemka" ; } > "$r/contracts/001-x.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  G "$r" add -A && G "$r" commit -q -m основание
}

LAST_OUT=''; LAST_RC=0
run_gate() {  # <субъект> <каталог>
  local subj="$1" r="$2"
  LAST_OUT="$(cd "$r" && bash "$subj" "$r" contracts/001-x.md 2>&1)"; LAST_RC=$?
}

want() {  # <имя-ворот> <субъект> <каталог> <want_rc> <фраза|-> ; want_rc 0 ⇒ последняя строка «OK»
  local name="$1" subj="$2" r="$3" wrc="$4" phrase="$5"
  run_gate "$subj" "$r"
  [ "$LAST_RC" -eq "$wrc" ] || { printf 'ОТКАЗ: ворота %s: rc %s, ожидался %s\nвывод:\n%s\n' "$name" "$LAST_RC" "$wrc" "$LAST_OUT" >&2; exit 1; }
  if [ "$wrc" -eq 0 ]; then
    [ "$(printf '%s\n' "$LAST_OUT" | tail -n 1)" = "OK" ] || { printf 'ОТКАЗ: ворота %s: rc 0 без «OK» последней строкой (канон 008):\n%s\n' "$name" "$LAST_OUT" >&2; exit 1; }
  else
    printf '%s\n' "$LAST_OUT" | grep -Fq -- "$phrase" || { printf 'ОТКАЗ: ворота %s: вывод не несёт «%s»:\n%s\n' "$name" "$phrase" "$LAST_OUT" >&2; exit 1; }
  fi
  printf 'ворота %s: rc %s — как заявлено\n' "$name" "$LAST_RC" >&2
}

stab_mismatch() {  # <имя-стаба> <субъект> <каталог> <честный rc>: стаб обязан разойтись
  local name="$1" subj="$2" r="$3" honest="$4"
  run_gate "$subj" "$r"
  [ "$LAST_RC" -ne "$honest" ] || { printf 'ОТКАЗ: стаб %s не расходится с честным предметом (rc %s) — заглушка устарела, предъявление не различает\n' "$name" "$LAST_RC" >&2; exit 1; }
  printf 'стаб-ворота %s: расходится с честным (rc %s ≠ %s) — предъявление различает\n' "$name" "$LAST_RC" "$honest" >&2
}

# ── с1 «любая-красная-годится»: существование проб сверяет, фразу — нет ────────
cat > "$WORK/s1.sh" <<'STAB'
#!/usr/bin/env bash
set -uo pipefail
root="$1"; c="$2"
while IFS= read -r cmd; do
  [ -n "$cmd" ] || continue
  path="$root/${cmd#* }"
  [ -f "$path" ] || { printf 'спек-гейт 036: проба не исполняема: %s не существует\n' "$path" >&2; exit 1; }
  (cd "$root" && timeout 60 bash "$path") >/dev/null 2>&1   # rc любой принимается
done < <(grep '^- `' "$root/$c" | sed -e 's/^- `//' -e 's/`.*//')
echo OK
STAB

# ── с6 «перестарался-зелёную-валит»: зелёная проба для него — дефект ──────────
cat > "$WORK/s6.sh" <<'STAB'
#!/usr/bin/env bash
set -uo pipefail
root="$1"; c="$2"
fails=0
while IFS= read -r cmd; do
  [ -n "$cmd" ] || continue
  (cd "$root" && timeout 60 $cmd) >/dev/null 2>&1
  [ $? -eq 0 ] && { printf 'спек-гейт 036: проба зелёна на черновике\n' >&2; fails=1; }
done < <(grep '^- `' "$root/$c" | sed -e 's/^- `//' -e 's/`.*//')
[ "$fails" -eq 0 ] && echo OK
exit "$fails"
STAB

# ── вход г1: зелёная + честная предметная красная с фразой ────────────────────
T1="$WORK/g1"
mk_toy "$T1" '- `bash p_green.sh`
- `bash p_red.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА В1'
printf 'echo ok\n' > "$T1/p_green.sh"
printf 'echo ПРЕДМЕТНАЯ ФРАЗА В1 >&2; exit 1\n' > "$T1/p_red.sh"
G "$T1" add -A && G "$T1" commit -q -m 'пробы г1'

# ── вход г2: env-красная (выход 2, посторонний вывод) при заявленной фразе ────
T2="$WORK/g2"
mk_toy "$T2" '- `bash p_env.sh` → красная: ПРЕДМЕТНАЯ ФРАЗА В1'
printf 'echo чужое окружение >&2; exit 2\n' > "$T2/p_env.sh"
G "$T2" add -A && G "$T2" commit -q -m 'проба г2'

# ── вход г2б: красная без заявленного суффикса ────────────────────────────────
T2B="$WORK/g2b"
mk_toy "$T2B" '- `bash p_x.sh`'
printf 'exit 1\n' > "$T2B/p_x.sh"
G "$T2B" add -A && G "$T2B" commit -q -m 'проба г2б'

# ── вход г2в: файла пробы нет ─────────────────────────────────────────────────
T2V="$WORK/g2v"
mk_toy "$T2V" '- `bash netu.sh`'

# ── предъявление ──────────────────────────────────────────────────────────────
want г1  "$SUBJ" "$T1"  0 -
want г2  "$SUBJ" "$T2"  1 'спек-гейт 036: проба красна не по предмету'
want г2б "$SUBJ" "$T2B" 1 'спек-гейт 036: проба красна без заявленной причины'
want г2в "$SUBJ" "$T2V" 1 'спек-гейт 036: проба не исполняема'
stab_mismatch с1-любая-красная-годится "$WORK/s1.sh" "$T2"  1
stab_mismatch с6-зелёную-валит         "$WORK/s6.sh" "$T1"  0
exit 0
