#!/usr/bin/env bash
# Клетка identity 016 И-7/И-9 (контракт 094, architect-пачка А-393): мир СО
# реестром зон (замороженный контракт 094 несёт ЗОНА-строку orchestrator'а),
# кандидат несёт MERGE-коммит, закоммиченный лицом ВНЕ реестра (postoronnij).
# Дверь обязана отказать именованной фразой «identity: committer не в реестре
# зон: postoronnij» (дословно из субъекта :39-60 — единый источник) на prepare
# И на publish (publish — под полностью честным журналом: только identity держит
# чужака от публикации), main не двинута. Позитивный контроль (демаркация):
# тот же вход с committer ВНУТРИ реестра — merge-коммит в диапазоне кандидата
# — публикуется: отказ инвариантен к форме коммита, расходится ТОЛЬКО на
# committer вне реестра. Обман (s20: порча t94-m20 — реестровая ветвь проверки
# выключена) готовит/публикует чужака → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: identity-committer-vne-reestra: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# _ident_world <слаг> — мир с реестром: base + замороженный контракт 094
# (ЗОНА-строка orchestrator'а → реестр = {orchestrator}); печатает каталог мира.
_ident_world() {
  local W R
  W="$(_t94_world "$1")" || exit 2
  R="$W/repo"
  mkdir -p "$R/contracts"
  printf 'ЗОНА orchestrator: fixtures/accept_publish_094\n' >"$R/contracts/094-toy-identity.md"
  git -C "$R" add -A && git -C "$R" commit -qm 'toy frozen contract 094'
  git -C "$R" tag frozen/contracts/094/1
  printf '%s\n' "$W"
}
# _ident_cand <repo> <base> <committer> — кандидат с merge-коммитом: сайд-ветка
# от base, true-merge в cand коммиттером <committer> (author==committer, чтобы
# краснела РЕЕСТРОВАЯ ветвь, а не committer!=author).
_ident_cand() {
  local R="$1" BASE="$2" CMT="$3"
  git -C "$R" checkout -qb side "$BASE"
  printf 'side\n' >"$R/side.txt"
  git -C "$R" add -A && git -C "$R" commit -qm 'side work'
  git -C "$R" checkout -q cand
  git -C "$R" -c user.name="$CMT" -c user.email="$CMT@dev-harness.local" \
    merge -q --no-ff --no-edit side >/dev/null
}
PHRASE='identity: committer не в реестре зон: postoronnij'

WN="$(_ident_world ident-chuzhak)" || exit 2
WP="$(_ident_world ident-svoj)" || exit 2
trap '_t94_cleanup "$WN"; _t94_cleanup "$WP"' EXIT

# ── негатив: merge-коммит коммиттером вне реестра ─────────────────────────────
RN="$WN/repo"; JN="$WN/journal.tsv"
BASE="$(git -C "$RN" rev-parse main)"
_ident_cand "$RN" "$BASE" postoronnij
CAND="$(git -C "$RN" rev-parse cand)"
# мир не сломан: верхний коммит кандидата — merge, его committer вне реестра
[ -n "$(git -C "$RN" show -s --format='%P' "$CAND" | grep ' ')" ] \
  || { printf 'КРАСНО: identity: мир сломан — верхний коммит кандидата не merge\n' >&2; exit 1; }
[ "$(git -C "$RN" show -s --format='%cn' "$CAND")" = postoronnij ] \
  || { printf 'КРАСНО: identity: мир сломан — committer merge не postoronnij\n' >&2; exit 1; }
[ "$(git -C "$RN" show -s --format='%an' "$CAND")" = postoronnij ] \
  || { printf 'КРАСНО: identity: мир сломан — author merge не postoronnij\n' >&2; exit 1; }

# предъявление 1: prepare отказывает именованной фразой identity
out="$(bash "$SUBJ" prepare --repo "$RN" --task T-20 --base "$BASE" --candidate "$CAND" 2>&1)"; prc=$?
if [ "$prc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$PHRASE"; then
  printf 'КРАСНО: identity: prepare по committer вне реестра не отказал фразой (rc=%s, вывод: %s)\n' "$prc" "$out" >&2
  exit 1
fi
[ "$(git -C "$RN" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: identity: отказ prepare сдвинул main\n' >&2; exit 1; }

# предъявление 2: publish под полностью честным журналом — единственное, что
# держит чужака от публикации, — identity; merge строим сами (prepare отказал
# честно), строки журнала честны относительно ЭТОГО объекта.
tree="$(git -C "$RN" merge-tree --write-tree --no-messages "$BASE" "$CAND")" || exit 1
M="$(git -C "$RN" commit-tree "$tree" -p "$BASE" -p "$CAND" -m 'land: T-20')"
O="$(bash "$SUBJ" object --repo "$RN" --task T-20 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$JN" 1 T-20 "$O" accept
_t94_green "$RN" "$BASE" "$JN" "$O" "$M"
out="$(bash "$SUBJ" publish --repo "$RN" --task T-20 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$JN" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$PHRASE"; then
  printf 'КРАСНО: identity: committer вне реестра опубликован при честном журнале (rc=%s, вывод: %s)\n' "$rc" "$out" >&2
  exit 1
fi
[ "$(git -C "$RN" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: identity: publish-отказ сдвинул main\n' >&2; exit 1; }

# ── позитивный контроль: тот же вход, committer ВНУТРИ реестра ───────────────
RP="$WP/repo"; JP="$WP/journal.tsv"
BASEP="$(git -C "$RP" rev-parse main)"
_ident_cand "$RP" "$BASEP" orchestrator
CANDP="$(git -C "$RP" rev-parse cand)"
[ "$(git -C "$RP" show -s --format='%cn' "$CANDP")" = orchestrator ] \
  || { printf 'КРАСНО: identity: мир сломан — committer merge позитива не orchestrator\n' >&2; exit 1; }
M2="$(bash "$SUBJ" prepare --repo "$RP" --task T-20 --base "$BASEP" --candidate "$CANDP" 2>&1)"; prc2=$?
if [ "$prc2" -ne 0 ]; then
  printf 'КРАСНО: identity: prepare по committer В реестре отказал (rc=%s, вывод: %s)\n' "$prc2" "$M2" >&2
  exit 1
fi
O2="$(bash "$SUBJ" object --repo "$RP" --task T-20 --target main --base "$BASEP" --candidate "$CANDP" --merge "$M2")" || exit 1
_t94_verdict "$JP" 1 T-20 "$O2" accept
_t94_green "$RP" "$BASEP" "$JP" "$O2" "$M2"
out="$(bash "$SUBJ" publish --repo "$RP" --task T-20 --target main --base "$BASEP" --candidate "$CANDP" --merge "$M2" --candidate-ref cand --journal "$JP" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: identity: identity В реестре не опубликован (rc=%s, вывод: %s)\n' "$rc" "$out" >&2
  exit 1
fi
[ "$(git -C "$RP" rev-parse main)" = "$M2" ] || { printf 'КРАСНО: identity: позитивная публикация не двинула main на merge\n' >&2; exit 1; }
exit 0
