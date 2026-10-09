#!/usr/bin/env bash
# Клетка И-4 «класс задачи управляет обязательными командами» (контракт 096,
# П-4). Половина (а): класс code — обязательные команды lint/build/secrets из
# profile; одна из команд возвращает rc≠0 → «не выполнена обязательная
# команда класса code: <name>». Половина (б): класс doc — НЕ требует
# lint/build (это не code), срабатывают только markdownlint; защита от
# слов-владельца о «не применять требование «есть реализационный код» к
# документальной».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: klass-komandy: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): class=code, lint возвращает rc≠0 ──────────────────────────
W="$(_t96_world i4a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
# Создаём триггерные скрипты
mkdir -p "$R/scripts"
cat >"$R/scripts/lint.sh" <<'LINT'
#!/usr/bin/env bash
exit 1
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
# Создаём merge с реальными изменениями в зоне
printf 'lint bug\n' >>"$R/scripts/done_project.sh" 2>/dev/null || true
printf 'lint bug\n' >>"$R/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R" add -A && git -C "$R" commit -qm 'cand: lint fail'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i4a: merge-tree не строится\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'не выполнена обязательная команда класса code'; then
  printf 'КРАСНО: i4a: lint-отказ не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): class=doc НЕ требует lint/build ────────────────────────────
W2="$(_t96_world i4b doc toy 096)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
mkdir -p "$R2/scripts"
cat >"$R2/scripts/markdownlint.sh" <<'MDL'
#!/usr/bin/env bash
exit 0
MDL
chmod +x "$R2/scripts/markdownlint.sh"
cat >"$R2/CHANGELOG.md" <<'CHANGELOG'
# CHANGELOG (toy)
CHANGELOG
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: changelog updated'
B="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i4b: merge-tree не строится\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class doc --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i4b: class=doc сломался по чужой команде (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
