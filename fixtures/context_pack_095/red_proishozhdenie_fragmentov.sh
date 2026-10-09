#!/usr/bin/env bash
# Клетка И-11 «происхождение фрагментов» (контракт 095, состав п.3, круг 2).
# Каждая строка манифеста несёт origin ∈ {profile,frozen,draft,taskfile,trace}
# и он ПРАВДИВ: незамороженный контракт — origin=draft (architect по черновику),
# замороженный — origin=frozen (implementer по тегу). ЕДИНСТВЕННЫЙ источник
# значения — ветвление источник-пака. Обман (s11: происхождение всегда frozen)
# → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: proishozhdenie-fragmentov: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i11)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed

# до заморозки: architect собирает по черновику — origin=draft
outd="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcd=$?
if [ "$rcd" -ne 0 ]; then
  printf 'КРАСНО: i11: architect-пак по черновику не строится (rc=%s, вывод: %s)\n' "$rcd" "$outd" >&2; exit 1
fi
printf '%s\n' "$outd" | grep -Fq "$(printf 'context\tcontracts/777-toy.md\tmandatory\tdraft')" || { printf 'КРАСНО: i11: незамороженный контракт выдан не как draft\n' >&2; exit 1; }
if printf '%s\n' "$outd" | grep -Fq "$(printf 'context\tcontracts/777-toy.md\tmandatory\tfrozen')"; then
  printf 'КРАСНО: i11: черновик выдан за заморозку\n' >&2; exit 1
fi

# после заморозки: implementer собирает по тегу — origin=frozen
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
outf="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcf=$?
if [ "$rcf" -ne 0 ]; then
  printf 'КРАСНО: i11: implementer-пак по заморозке не строится (rc=%s, вывод: %s)\n' "$rcf" "$outf" >&2; exit 1
fi
printf '%s\n' "$outf" | grep -Fq "$(printf 'context\tcontracts/777-toy.md\tmandatory\tfrozen')" || { printf 'КРАСНО: i11: замороженный контракт выдан не как frozen\n' >&2; exit 1; }
if printf '%s\n' "$outf" | grep -Fq "$(printf 'context\tcontracts/777-toy.md\tmandatory\tdraft')"; then
  printf 'КРАСНО: i11: заморозка выдана за черновик\n' >&2; exit 1
fi
exit 0
