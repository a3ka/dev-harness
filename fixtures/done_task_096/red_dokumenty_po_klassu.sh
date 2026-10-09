#!/usr/bin/env bash
# Клетка И-5 «необходимые документы по классу» (контракт 096, П-5). Половина
# (а): class=code — CODING-STANDARDS.md отсутствует → «нет обязательного
# документа класса code: CODING-STANDARDS.md». Половина (б): class=research —
# decisions/<NNN>-research.md со статусом «предложено» (НЕ «принято») →
# отказ.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: dokumenty-po-klassu: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): class=code — CODING-STANDARDS.md отсутствует ───────────────
W="$(_t96_world i5a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
# На кандидатной ветке добавляем lint/build/secrets в зоне implementer и путь
# в зоне architect (НЕ добавляем CODING-STANDARDS.md — это требуемый документ)
git -C "$R" checkout -q cand
mkdir -p "$R/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
git -C "$R" add -A && git -C "$R" commit -qm 'cand: code w/o standards'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i5a: merge-tree не строится\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательного документа класса code'; then
  printf 'КРАСНО: i5a: class=code без CODING-STANDARDS.md не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): class=research, ADR со статусом ≠ «принято» ───────────────
W2="$(_t96_world i5b research toy 096)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
mkdir -p "$R2/scripts"
cat >"$R2/scripts/adr-new.sh" <<'ADRNEW'
#!/usr/bin/env bash
exit 0
ADRNEW
chmod +x "$R2/scripts/adr-new.sh"
# ADR со статусом «предложено» (для research — формат записи, чтоб
# match был лексический)
cat >"$R2/decisions/096-research.md" <<'ADR'
# ADR 096 (research)
status: предложено
ADR
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: ADR предложено'
B="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i5b: merge-tree не строится\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
ISS2="https://example.com/issue/96"
printf '%s\t%s\tresearchStatus\t%s\n' "$ISS2" "closed:complete" "in-progress" >>"$R2/harness/issue-state.tsv"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class research --project-id toy \
  --issue "$ISS2" --object-id "$OID" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ]; then
  printf 'КРАСНО: i5b: ADR «предложено» не отказано (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# Сообщение должно быть содержательным
printf '%s' "$out" | grep -Eq 'нет обязательного документа класса research|статус' || {
  printf 'КРАСНО: i5b: сообщение не содержательное: %s\n' "$out" >&2; exit 1
}
exit 0
