#!/usr/bin/env bash
# Красное предъявление 036, ветвь В2 «замер-грамматика» (боль 035: census-критерий
# судил текст, не дерево — подделка «999» проходила; обход круга 1 Б3: константа
# `printf '999\n'` при фактическом нуле).
#
# Каталог ОТКРЫТ для architect (живая матрица круга 1, Б2); файл ложится ТЕМ ЖЕ
# коммитом, что и контракт. Прямой запуск — red_* вне case_*-глоба раннера (А-82).
#
# ВОРОТА (оракул — в памяти предъявления, правило 8; сверка СТРУКТУРНАЯ):
#   г3  боль 035 с НЕЗАВИСИМЫМ пересчётом: команда согласована с заявленным N
#        (grep -l по глобу даёт 2), а census-глоб покрывает 3 файла → rc 1
#        «замер расходится: заявлено 2, дерево даёт 3» — связь census↔дерево
#        держит САМ гейт, не вера команде автора;
#   г3б обход Б3 ДОСЛОВНО (вердикт круга 1): `printf '999\n'` = 999 →
#        структурная связь ловит раньше пересчёта: «census-глоб не входит в команду»;
#   г3б′ константа С литеральной вставкой глоба (`echo 7; ls <глоб> >/dev/null`
#        = 7 при трёх файлах) → «замер расходится: заявлено 7, дерево даёт 3»;
#   г3в вывод не целое → «замер не читается: вывод не целое»;
#   г3г rc≠0 команды → «замер не исполнен: rc <K>»;
#   г3д замер без census-части → «нет census-глоба»;
#   г3е согласованный замер (команда = N = пересчёт) → rc 0 «OK»;
#   стаб с2 «замер-маркер-игнор» (грепает маркер `замер:` и только) — дефект
#        наблюдаем ровно на входе г3 (rc 0 вместо 1).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/check_spec_ready.sh"
[ -f "$SUBJ" ] || { printf 'ПРЕДМЕТ 036 НЕ РЕАЛИЗОВАН: В2 замер-грамматика — %s отсутствует на дереве\n' "$SUBJ" >&2; exit 1; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/v2_036.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

G() { local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

mk_toy() {  # <каталог> <замер-строка>
  local r="$1" zamer="$2"
  mkdir -p "$r/contracts" "$r/probes"
  { printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\nзамер: %s\n' "$zamer"; } > "$r/contracts/001-x.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  G "$r" add -A && G "$r" commit -q -m основание
}

LAST_OUT=''; LAST_RC=0
run_gate() { local subj="$1" r="$2"
  LAST_OUT="$(cd "$r" && bash "$subj" "$r" contracts/001-x.md 2>&1)"; LAST_RC=$?
}
want() {  # <имя> <субъект> <каталог> <want_rc> <фраза|->
  local name="$1" subj="$2" r="$3" wrc="$4" phrase="$5"
  run_gate "$subj" "$r"
  [ "$LAST_RC" -eq "$wrc" ] || { printf 'ОТКАЗ: ворота %s: rc %s, ожидался %s\nвывод:\n%s\n' "$name" "$LAST_RC" "$wrc" "$LAST_OUT" >&2; exit 1; }
  if [ "$wrc" -eq 0 ]; then
    [ "$(printf '%s\n' "$LAST_OUT" | tail -n 1)" = "OK" ] || { printf 'ОТКАЗ: ворота %s: rc 0 без «OK» последней строкой:\n%s\n' "$name" "$LAST_OUT" >&2; exit 1; }
  else
    printf '%s\n' "$LAST_OUT" | grep -Fq -- "$phrase" || { printf 'ОТКАЗ: ворота %s: вывод не несёт «%s»:\n%s\n' "$name" "$phrase" "$LAST_OUT" >&2; exit 1; }
  fi
  printf 'ворота %s: rc %s — как заявлено\n' "$name" "$LAST_RC" >&2
}
stab_mismatch() {  # <имя> <субъект> <каталог> <честный rc>
  local name="$1" subj="$2" r="$3" honest="$4"
  run_gate "$subj" "$r"
  [ "$LAST_RC" -ne "$honest" ] || { printf 'ОТКАЗ: стаб %s не расходится с честным предметом (rc %s) — заглушка устарела, предъявление не различает\n' "$name" "$LAST_RC" >&2; exit 1; }
  printf 'стаб-ворота %s: расходится с честным (rc %s ≠ %s) — предъявление различает\n' "$name" "$LAST_RC" "$honest" >&2
}

# ── с2 «замер-маркер-игнор»: маркер есть — гейт зелён, числа не сверяет ───────
cat > "$WORK/s2.sh" <<'STAB'
#!/usr/bin/env bash
set -uo pipefail
root="$1"; c="$2"
grep -q '^замер:' "$root/$c" || { printf 'спек-гейт 036: замеров нет\n' >&2; exit 1; }
echo OK
STAB

# toy с тремя файлами под глобом probes/g*.sh, ДВА из них несут маркер «шляпа»
mk3() {  # <каталог>
  local r="$1"
  mk_toy "$r" 'x'
  printf 'шляпа\n' > "$r/probes/g1.sh"; printf 'шляпа\n' > "$r/probes/g2.sh"; printf 'прочее\n' > "$r/probes/g3.sh"
  G "$r" add -A && G "$r" commit -q -m 'файлы замера'
}

# ── вход г3: команда (grep -l) даёт 2 = N, census-глоб покрывает 3 → «дерево даёт 3»
T3="$WORK/g3"; mk3 "$T3"
printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\nзамер: `grep -l шляпа probes/g*.sh | wc -l` = 2 census probes/g*.sh\n' > "$T3/contracts/001-x.md"
G "$T3" add -A && G "$T3" commit -q -m 'замер г3'

# ── вход г3б: обход Б3 дословно — константа при пустом глобе ─────────────────
T3B="$WORK/g3b"; mk_toy "$T3B" '`printf '"'"'999\n'"'"'` = 999 census probes/*.sh'

# ── вход г3б′: константа с литеральной вставкой глоба (7 при трёх файлах) ────
T3B2="$WORK/g3b2"; mk3 "$T3B2"
printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\nзамер: `echo 7; ls probes/g*.sh >/dev/null` = 7 census probes/g*.sh\n' > "$T3B2/contracts/001-x.md"
G "$T3B2" add -A && G "$T3B2" commit -q -m 'замер г3б2'

# ── вход г3в: вывод не целое (глоб в команде литерально) ─────────────────────
T3V="$WORK/g3v"; mk3 "$T3V"
printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\nзамер: `echo нецелое probes/g*.sh` = 3 census probes/g*.sh\n' > "$T3V/contracts/001-x.md"
G "$T3V" add -A && G "$T3V" commit -q -m 'замер г3в'

# ── вход г3г: команда падает (нет совпадений глоба нету-*) ───────────────────
T3G="$WORK/g3g"; mk_toy "$T3G" '`ls netu-x/*.sh` = 0 census netu-x/*.sh'

# ── вход г3д: замер без census-части ─────────────────────────────────────────
T3D="$WORK/g3d"; mk_toy "$T3D" '`printf '"'"'3\n'"'"'` = 3'

# ── вход г3е: согласованный замер ────────────────────────────────────────────
T3E="$WORK/g3e"; mk3 "$T3E"
printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Приёмка\nзамер: `ls probes/g*.sh | wc -l` = 3 census probes/g*.sh\n' > "$T3E/contracts/001-x.md"
G "$T3E" add -A && G "$T3E" commit -q -m 'замер г3е'

# ── предъявление ──────────────────────────────────────────────────────────────
want г3  "$SUBJ" "$T3"   1 'спек-гейт 036: замер расходится: заявлено 2, дерево даёт 3'
want г3б "$SUBJ" "$T3B"  1 'спек-гейт 036: замер не по грамматике: census-глоб не входит в команду'
want г3б2 "$SUBJ" "$T3B2" 1 'спек-гейт 036: замер расходится: заявлено 7, дерево даёт 3'
want г3в "$SUBJ" "$T3V"  1 'спек-гейт 036: замер не читается: вывод не целое'
want г3г "$SUBJ" "$T3G"  1 'спек-гейт 036: замер не исполнен: rc 2'
want г3д "$SUBJ" "$T3D"  1 'спек-гейт 036: замер не по грамматике: нет census-глоба'
want г3е "$SUBJ" "$T3E"  0 -
stab_mismatch с2-замер-маркер-игнор "$WORK/s2.sh" "$T3" 1
exit 0
