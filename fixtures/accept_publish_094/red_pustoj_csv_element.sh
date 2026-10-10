#!/usr/bin/env bash
# Клетка И-0 «пустой CSV-компонент перечня политики» (контракт 094, требование
# adversary круга 2, verdicts/adversary/contracts-094-v2.md): каждый компонент
# CSV в mandatory/targetBranches — непустое слово своего алфавита, запятая —
# только разделитель. Ведущая/хвостая/двойная запятая НЕКОНФОРМНА: bash
# `read -ra` молча роняет пустые компоненты, `mandatory=ci-a,` без структурной
# проверки превращается в перечень из ОДНОЙ ci-a — вторая обязательная проверка
# исчезает БЕЗ именованного отказа (живой обход на субъекте e9ae7ab7: PUBLISHED;
# то же для targetBranches=main,). Обе формы обязаны получить rc 1
# «политика: грамматика» на КАЖДОМ глаголе (prepare/object/publish) ДО
# движения refs, без строки published; ref и журнал байт-в-байт прежние.
# Обман (s18: проверка пустых CSV-компонентов снята, порчи t94-m18a+m18b)
# пускает конвейер → клетка красна на первом ушедшем глаголе (форма а:
# prepare rc 0) либо на publish мимо грамматического отказа (форма б).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: pustoj-csv-element: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# ── форма (а): mandatory=ci-a, — хвостая запятая, check-строка только ci-a ────
W1="$(_t94_world i0csv-a main 'ci-a,')" || exit 2
trap '_t94_cleanup "$W1"' EXIT
R1="$W1/repo"; J1="$W1/journal.tsv"
B1="$(git -C "$R1" rev-parse main)"
C1="$(git -C "$R1" rev-parse cand)"

out="$(bash "$SUBJ" prepare --repo "$R1" --task T-1 --base "$B1" --candidate "$C1" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0-csv(a): prepare принял mandatory=ci-a, (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# merge строим git-рецептом модели (prepare честно отказал; вход КРОМЕ политики
# полностью валиден — для object/publish аргумент --merge всё равно нужен)
tree="$(git -C "$R1" merge-tree --write-tree --no-messages "$B1" "$C1" 2>/dev/null)" || exit 2
M1="$(GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local \
  GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local \
  git -C "$R1" commit-tree "$tree" -p "$B1" -p "$C1" -m 'land: T-1')" || exit 2

out="$(bash "$SUBJ" object --repo "$R1" --task T-1 --target main --base "$B1" --candidate "$C1" --merge "$M1" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0-csv(a): object принял mandatory=ci-a, (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# журнал как в живой пробе вердикта: accept + зелёная ci-a, БЕЗ ci-b
_t94_verdict "$J1" 1 T-1 "$(_t94_anysha i0csv-a-toy)" accept
_t94_check "$J1" "$(_t94_anysha i0csv-a-toy)" ci-a ok 1 "$(_t94_wfsha "$R1" "$B1" ci-a)" "$(_t94_tree "$R1" "$M1")"

sha1="$(sha256sum "$J1" | cut -d' ' -f1)"
out="$(bash "$SUBJ" publish --repo "$R1" --task T-1 --target main --base "$B1" --candidate "$C1" --merge "$M1" --candidate-ref cand --journal "$J1" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0-csv(a): publish по mandatory=ci-a, не отказан грамматикой (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R1" rev-parse refs/heads/main)" = "$B1" ] || { printf 'КРАСНО: i0-csv(a): отказ сдвинул main\n' >&2; exit 1; }
[ "$(sha256sum "$J1" | cut -d' ' -f1)" = "$sha1" ] || { printf 'КРАСНО: i0-csv(a): отказ изменил журнал\n' >&2; exit 1; }
n="$(grep -c '^published	' "$J1")"
[ "$n" -eq 0 ] || { printf 'КРАСНО: i0-csv(a): строк published %s, ожидалось 0\n' "$n" >&2; exit 1; }
_t94_cleanup "$W1"

# ── форма (б): targetBranches=main, — полный валидный журнал обеих проверок ───
W2="$(_t94_world i0csv-b 'main,')" || exit 2
trap '_t94_cleanup "$W2"' EXIT
R2="$W2/repo"; J2="$W2/journal.tsv"
B2="$(git -C "$R2" rev-parse main)"
C2="$(git -C "$R2" rev-parse cand)"

out="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$B2" --candidate "$C2" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0-csv(б): prepare принял targetBranches=main, (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

tree="$(git -C "$R2" merge-tree --write-tree --no-messages "$B2" "$C2" 2>/dev/null)" || exit 2
M2="$(GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local \
  GIT_COMMITTER_NAME=orchestrator GIT_COMMITTER_EMAIL=orchestrator@dev-harness.local \
  git -C "$R2" commit-tree "$tree" -p "$B2" -p "$C2" -m 'land: T-1')" || exit 2

out="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$B2" --candidate "$C2" --merge "$M2" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0-csv(б): object принял targetBranches=main, (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# журнал как во второй живой пробе вердикта: accept + ОБЕ зелёные проверки
_t94_verdict "$J2" 1 T-1 "$(_t94_anysha i0csv-b-toy)" accept
_t94_green "$R2" "$B2" "$J2" "$(_t94_anysha i0csv-b-toy)" "$M2"

sha2="$(sha256sum "$J2" | cut -d' ' -f1)"
out="$(bash "$SUBJ" publish --repo "$R2" --task T-1 --target main --base "$B2" --candidate "$C2" --merge "$M2" --candidate-ref cand --journal "$J2" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'политика: грамматика'; then
  printf 'КРАСНО: i0-csv(б): publish по targetBranches=main, не отказан грамматикой (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R2" rev-parse refs/heads/main)" = "$B2" ] || { printf 'КРАСНО: i0-csv(б): отказ сдвинул main\n' >&2; exit 1; }
[ "$(sha256sum "$J2" | cut -d' ' -f1)" = "$sha2" ] || { printf 'КРАСНО: i0-csv(б): отказ изменил журнал\n' >&2; exit 1; }
n="$(grep -c '^published	' "$J2")"
[ "$n" -eq 0 ] || { printf 'КРАСНО: i0-csv(б): строк published %s, ожидалось 0\n' "$n" >&2; exit 1; }
exit 0
