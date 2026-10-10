#!/usr/bin/env bash
# Клетка И-11 «чистая среда выполняет реальные команды профиля, включая
# установку окружения» (контракт 096, В-1). Половина (а): мир без HOME
# сбрасывается на /tmp, команды запускаются с env -i; rc=0 на команде,
# которая проверяет работу чистой среды (нулевая PATH — угадай что).
# Половина (б): команды профиля РЕАЛЬНО выполняются — зелёная.
#
# Конвенция мира: cell переключает себя на cand branch, делает модификации,
# строит merge-объект M, пишет published-строку в candidates.tsv (В CAND-
# рабочем дереве до возврата на main), после чего запускает модель без
# переключения обратно (запускающий процесс из CAND-рабочего дерева).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: chistaja-sreda-realnye-komandy: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): мир без HOME ────────────────────────────────────────────────
W="$(_t96_world i11a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
mkdir -p "$R/scripts"
cat >"$R/scripts/lint.sh" <<'LINT'
#!/usr/bin/env bash
# Чистая среда детерминирована двумя независимыми следствиями env -i:
# наследованный маркер НЕ доходит до команды, HOME сброшен на /tmp.
[ "${T96_SENTINEL:-clean}" = "clean" ] && [ "$HOME" = "/tmp" ] && exit 0 || exit 1
LINT
cat >"$R/scripts/build.sh" <<'BUILD'
#!/usr/bin/env bash
exit 0
BUILD
cat >"$R/scripts/secrets.sh" <<'SECRETS'
#!/usr/bin/env bash
exit 0
SECRETS
chmod +x "$R/scripts/lint.sh" "$R/scripts/build.sh" "$R/scripts/secrets.sh"
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
git -C "$R" add -A && git -C "$R" commit -qm 'cand: clean env'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i11a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
# Контрактный тег (как 038 бы поставил): ставим на любую ревизию
git -C "$R" tag -f done/contracts/096/1 "$HEAD^{}"
# НЕ переключаемся обратно на main — оставляем рабочее дерево на CAND,
# чтобы file-команды профиля имели реальные файлы на диске.
# Маркер наследованной среды: честная модель с env -i его НЕ пропускает;
# стаб без чистой среды (m11) пропускает — и lint падает.
export T96_SENTINEL=dirty
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id $OID --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i11a: чистая среда не работает (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): smoke — все ступени запускаются ────────────────────────────
W2="$(_t96_world i11b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
mkdir -p "$R2/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R2/scripts/$n.sh"
  chmod +x "$R2/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R2/CODING-STANDARDS.md"
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: simple change'
B="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i11b: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
git -C "$R2" tag -f done/contracts/096/1 "$HEAD2^{}"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id $OID --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i11b: запуск не зелёный (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
