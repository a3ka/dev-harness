#!/usr/bin/env bash
# Клетка И-0/И-4 «вакуумный перечень обязательных проверок» (контракт 094,
# требование adversary круга 1): доверенная политика с mandatory= (пустой CSV)
# НЕКОНФОРМНА — каждый глагол (prepare, object, publish) обязан дать именованный
# отказ «политика: грамматика» ДО движения refs и без строки published; публикация
# по вакуумному перечню невозможна ни при каком журнале. Вход publish: accept без
# единой строки check. Обман (s17: пустой список допущен, порчи t94-m17a+m17b)
# пускает конвейер (prepare rc 0) и публикует без проверок → клетка красна на
# первом же ушедшем глаголе.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: pustoj-mandatory: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i0pust main '')" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"

out="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0: prepare принял вакуумный mandatory= (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# merge строим git-рецептом модели (prepare честно отказал; для object/publish
# аргумент --merge всё равно нужен — вход КРОМЕ политики полностью валиден)
tree="$(git -C "$R" merge-tree --write-tree --no-messages "$BASE" "$CAND" 2>/dev/null)" || exit 2
MERGE="$(GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local \
  GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local \
  git -C "$R" commit-tree "$tree" -p "$BASE" -p "$CAND" -m 'land: T-1')" || exit 2

out="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0: object принял вакуумный mandatory= (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# журнал: accept без единой строки check (честная дверь отказывает ГРАММАТИКОЙ
# политики раньше чтения журнала — живой замер на субъекте e9ae7ab7)
_t94_verdict "$J" 1 T-1 "$(_t94_anysha i0pust-toy)" accept

out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0: publish по вакуумному mandatory= не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse refs/heads/main)" = "$BASE" ] || { printf 'КРАСНО: i0: отказ сдвинул main\n' >&2; exit 1; }
n="$(grep -c '^published	' "$J")"
[ "$n" -eq 0 ] || { printf 'КРАСНО: i0: строк published %s, ожидалось 0\n' "$n" >&2; exit 1; }
exit 0
