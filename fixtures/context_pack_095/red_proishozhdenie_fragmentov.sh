#!/usr/bin/env bash
# Клетка И-11 «манифест и происхождение фрагментов» (контракт 095, состав п.3).
# КАЖДЫЙ фрагмент манифеста несёт происхождение из замкнутого алфавита
# {profile,frozen,draft,taskfile,trace}, и оно ПРАВДИВО: (а) на незамороженном
# контракте architect-фрагменты — origin=draft; (б) на замороженном — origin=frozen.
# Обман (s11: происхождение всегда frozen) → клетка красна.
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
TAB="$(printf '\t')"

# (а) до заморозки — черновик, происхождение draft
out="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || { printf 'КРАСНО: i11: architect-пак до заморозки не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq "zones${TAB}contracts/777-toy.md${TAB}mandatory${TAB}draft" || { printf 'КРАСНО: i11: зоны незамороженного контракта не помечены origin=draft\n' >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq "context${TAB}contracts/777-toy.md${TAB}mandatory${TAB}draft" || { printf 'КРАСНО: i11: контекст незамороженного контракта не помечен origin=draft\n' >&2; exit 1; }

# (б) после заморозки — frozen
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
out2="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
[ "$rc2" -eq 0 ] || { printf 'КРАСНО: i11: implementer-пак после заморозки не строится (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1; }
printf '%s\n' "$out2" | grep -Fxq "zones${TAB}contracts/777-toy.md${TAB}mandatory${TAB}frozen" || { printf 'КРАСНО: i11: зоны замороженного контракта не помечены origin=frozen\n' >&2; exit 1; }

# алфавит происхождений замкнут
man="$(printf '%s\n' "$out2" | sed -n '/^=== MANIFEST ===$/,/^=== BUDGET ===$/p' | sed '1d;$d')"
bad="$(printf '%s\n' "$man" | awk -F '\t' '$4 != "profile" && $4 != "frozen" && $4 != "draft" && $4 != "taskfile" && $4 != "trace" {print}')"
[ -z "$bad" ] || { printf 'КРАСНО: i11: происхождение вне алфавита: %s\n' "$bad" >&2; exit 1; }
exit 0
