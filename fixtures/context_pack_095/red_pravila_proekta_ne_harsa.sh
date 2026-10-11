#!/usr/bin/env bash
# Клетка И-1 «реальный запуск в репозитории проекта получает его правила, а не
# контекст харнеса» (контракт 095, Выход п.1, круг 2). Мир несёт карту ТОЛЬКО в
# настоящем профиле (contextPack репо-слоя) — toy-TSV harness/context-map в
# мире НЕТ: субъект, читающий его вместо профиля, красен уже на зелёной стороне.
# (а) RULES-секция несёт ТОЛЬКО правила проекта (DEVELOPMENT.md); харнесовские
# документы (AGENTS.md, CODING-STANDARDS.md) в паке отсутствуют дословно.
# (б) contextPack отсутствует в обоих слоях — именованный отказ «нет карты
# контекста: contextPack», не пустой пак. Обман (s1: харнесовские правила
# вклеиваются всегда) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: pravila-proekta-ne-harsa: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i1)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

out="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i1: честный пак не строится — карта потреблена не из профиля? (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -Fxq 'RULES: DEVELOPMENT.md' || { printf 'КРАСНО: i1: правила проекта не в паке\n' >&2; exit 1; }
printf '%s\n' "$out" | grep -Fxq 'MAP: PROJECT.md :: карта проекта' || { printf 'КРАСНО: i1: карта проекта не из профиля\n' >&2; exit 1; }
if printf '%s\n' "$out" | grep -Fq 'AGENTS.md'; then
  printf 'КРАСНО: i1: в пак проекта попал харнесовский AGENTS.md\n' >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq 'CODING-STANDARDS.md'; then
  printf 'КРАСНО: i1: в пак проекта попал харнесовский CODING-STANDARDS.md\n' >&2; exit 1
fi

# (б) contextPack отсутствует в обоих слоях — точная причина, не пустая выдача
jq 'del(.contextPack)' "$R/harness.project.json" >"$W/rj.json" && mv "$W/rj.json" "$R/harness.project.json"
jq 'del(.defaults.contextPack)' "$R/registry/harness-project.json" >"$W/pj.json" && mv "$W/pj.json" "$R/registry/harness-project.json"
out2="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
if [ "$rc2" -ne 1 ] || ! printf '%s\n' "$out2" | grep -Fq 'ОТКАЗ: нет карты контекста: contextPack'; then
  printf 'КРАСНО: i1: потеря карты профиля не названа именем (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi
[ -z "$(printf '%s\n' "$out2" | grep -v 'ОТКАЗ:')" ] || { printf 'КРАСНО: i1: отказ выдал частичный пак\n' >&2; exit 1; }
exit 0
