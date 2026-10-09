#!/usr/bin/env bash
# Клетка И-10 «ADR и уроки по области» (контракт 095, состав п.6). Уроки
# выдаются ПО ОБЛАСТИ (glob по путям зоны), кап 5 (§13.6-4 владельца):
# (а) шесть уроков области scripts/* — в паке ровно ПЕРВЫЕ ПЯТЬ;
# (б) урок чужой области (А-5, docs/*) в пак НЕ попадает.
# Обман (s10: фильтр области снят — все уроки подряд) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: uroki-po-oblasti: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i10)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed

out="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i10: пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
n="$(printf '%s\n' "$out" | grep -c '^LESSON: ')"
[ "$n" -eq 5 ] || { printf 'КРАСНО: i10: уроков области %s, ожидался кап 5\n' "$n" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq 'LESSON: Н-71 :: зоны не по памяти' || { printf 'КРАСНО: i10: урок своей области не выдан\n' >&2; exit 1; }
if printf '%s\n' "$out" | grep -Fq 'Н-88'; then
  printf 'КРАСНО: i10: урок сверх капа 5 прошёл в пак (Н-88)\n' >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'А-5'; then
  printf 'КРАСНО: i10: урок ЧУЖОЙ области (docs/*) попал в пак зоны scripts/*\n' >&2; exit 1
fi
exit 0
