#!/usr/bin/env bash
# Клетка И-10 «ADR и уроки по области» (контракт 095, состав п.6, круг 2).
# ADR: decisions_for по владельцу §10.6 — метки ОБЛАСТЬ (path-glob | роль:*)
# матчатся к путям ЗОНА-строк и роли пака; «заменено»/«предложено» не
# выдаются; потолок 8 → «зона слишком широкая, режь задание». Уроки: реестр
# registry/lessons-harness.tsv, матч ОБЛАСТЬ-глоба к путям зоны, кап 5.
# (а) implementer: 5 первых уроков области, чужой области (А-5, docs/*) нет;
# (б) ADR: путь-метка (001) выдан, заменённый (003) и предложенный (004) нет,
# роль-метка (002, роль:architect) implementer'у НЕ выдана;
# (в) architect: роль-метка 002 выдана (красный тест §10.6 владельца);
# (г) 10 действующих ADR области → отказ «зона слишком широкая».
# Обманы (s10: фильтр области уроков снят; s16: статус-фильтр ADR снят) → красна.
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
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

out="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i10: пак не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# (а) уроки: кап 5, только своя область
n="$(printf '%s\n' "$out" | grep -c '^LESSON: ')"
[ "$n" -eq 5 ] || { printf 'КРАСНО: i10: уроков области %s, ожидался кап 5\n' "$n" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq 'LESSON: Н-71 :: зоны не по памяти' || { printf 'КРАСНО: i10: урок своей области не выдан\n' >&2; exit 1; }
if printf '%s\n' "$out" | grep -Fq 'Н-88'; then
  printf 'КРАСНО: i10: урок сверх капа 5 прошёл в пак (Н-88)\n' >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'А-5'; then
  printf 'КРАСНО: i10: урок ЧУЖОЙ области (docs/*) попал в пак зоны scripts/*\n' >&2; exit 1
fi
# (б) ADR: путь-метка да, статус-фильтр и роль-метка — по владельцу
printf '%s\n' "$out" | grep -Fxq 'ADR: 001 :: единый toy-модуль' || { printf 'КРАСНО: i10: ADR своей области (путь-метка) не выдан\n' >&2; exit 1; }
if printf '%s\n' "$out" | grep -Fq 'заменённый не выдаётся'; then
  printf 'КРАСНО: i10: ЗАМЕНЁННЫЙ ADR (003) выдан\n' >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'предложенный не выдаётся'; then
  printf 'КРАСНО: i10: ПРЕДЛОЖЕННЫЙ ADR (004) выдан\n' >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'архитектору — grilling и ADR'; then
  printf 'КРАСНО: i10: роль-метка (роль:architect) выдана implementer\n' >&2; exit 1
fi

# (в) architect получает роль-метку (красный тест §10.6: роль:architect → да)
outa="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rca=$?
if [ "$rca" -ne 0 ] || ! printf '%s\n' "$outa" | grep -Fq 'ADR: 002 :: архитектору — grilling и ADR'; then
  printf 'КРАСНО: i10: архитектору не выдана роль-метка ADR-002 (rc=%s, вывод: %s)\n' "$rca" "$outa" >&2; exit 1
fi

# (г) потолок 8: 10 действующих ADR области → «зона слишком широкая»
i=5
while [ "$i" -le 13 ]; do
  _t95_adr "$R" "$(printf '%03d' "$i")" "toy-kap" '' 'scripts/*' "kap-ADR $i"
  i=$((i+1))
done
outc="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcc=$?
if [ "$rcc" -ne 1 ] || ! printf '%s\n' "$outc" | grep -Fq 'ОТКАЗ: зона слишком широкая, режь задание'; then
  printf 'КРАСНО: i10: превышение потолка 8 ADR не отказано (rc=%s, вывод: %s)\n' "$rcc" "$outc" >&2; exit 1
fi
if printf '%s\n' "$outc" | grep -Fq '=== make_task'; then
  printf 'КРАСНО: i10: отказ потолка выдал частичный пак\n' >&2; exit 1
fi
exit 0
