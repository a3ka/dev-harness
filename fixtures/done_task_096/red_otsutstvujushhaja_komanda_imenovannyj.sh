#!/usr/bin/env bash
# Клетка И-12 «отсутствующая обязательная команда даёт именованный отказ»
# (контракт 096, В-2). Половина (а): команда профиля указывает на файл,
# отсутствующий в репо → отказ «обязательная команда профиля отсутствует»
# ДО запуска. Половина (б): команда существует, но падает с rc≠0 → отказ
# уже по И-11 (другая формулировка «не выполнена обязательная команда
# класса»), это РАЗНЫЕ отказы (содержательное различие).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: otsutstvujushhaja-komanda-imenovannyj: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): профиль указывает на несуществующий файл ──────────────────
W="$(_t96_world i12a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
# Перепишем профиль так, чтобы lint указывал на НЕсуществующий файл
{
  printf 'repoId=%s\n' "toy-096"
  printf 'projectId=%s\n' "toy"
  printf 'issueField=closed\n'
  printf 'tagFormat=done/project/%s/<v>\n' "toy"
  printf 'contracts\t%s\t%s\n' "096" "code"
  printf 'command\tcode\tlint\tbash ./scripts/lint.sh\n'
  printf 'command\tcode\tbuild\tbash ./scripts/build-missing.sh\n'  # отсутствует
  printf 'command\tcode\tsecrets\tbash ./scripts/secrets.sh\n'
  printf 'doc\tcode\tCODING-STANDARDS.md\n'
  printf 'issuePolicy\tcode\tclose\n'
} >"$R/harness/done-profile.tsv"
mkdir -p "$R/scripts"
for n in lint secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
printf 'change\n' >>"$R/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R" add -A && git -C "$R" commit -qm 'cand: missing build'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i12a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'обязательная команда профиля отсутствует'; then
  printf 'КРАСНО: i12a: отсутствующая команда не отказана именованно (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0

# ── половина (б): содержимое подтверждает, что И-11 — другое сообщение
# (команда есть, упала с rc≠0) — здесь уже было доказано в i4a; данная
# клетка покрывает РОВНО отсутствие файла.
