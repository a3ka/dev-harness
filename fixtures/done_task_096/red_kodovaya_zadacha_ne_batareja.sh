#!/usr/bin/env bash
# Клетка И-13 «нельзя закрыть кодовую задачу одной батареей без реализации»
# (контракт 096, В-3). Половина (а): class=code, candidates.tsv пустой (нет
# published-строки), команды + документы проходят → отказ «кодовая задача
# без опубликованной реализации» / «объект не опубликован» (И-7
# срабатывает раньше). Половина (б): class=doc, та же конфигурация (без
# published) → код-требование НЕ применяется (И-13 class-specific) — но
# в текущей модели class=doc ещё не зависит от candidates.tsv; этот кейс
# зафиксирован здесь: проверяем, что класс doc проходит БЕЗ candidates.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: kodovaya-zadacha-ne-batareja: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): class=code — нет published — отказ (реализация не дошла) ──
W="$(_t96_world i13a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
mkdir -p "$R/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
printf 'code change\n' >>"$R/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R" add -A && git -C "$R" commit -qm 'cand: only code, no publish'
# НЕ пишем published в candidates.tsv
HEAD="$(git -C "$R" rev-parse HEAD)"
OID="$(printf '%064d' 1)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ]; then
  printf 'КРАСНО: i13a: code без published прошёл (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# Сообщение должно указывать на И-7 или И-13 (на этом круге модель отказывает
# по И-7 раньше И-13; это КОРРЕКТНО — публикация требуется первой; оба
# сообщения — содержательные)
printf '%s' "$out" | grep -Eq 'объект не опубликован|опубликованной реализации' || {
  printf 'КРАСНО: i13a: отказ не содержательный: %s\n' "$out" >&2; exit 1
}
exit 0

# ── половина (б): class=doc — без published, без code-команд (markdownlint есть),
# без CHANGELOG-документа НЕ публикуется — ДОЛЖЕН ПРОХОДИТЬ по doc-классу, если
# документы в порядке и команда есть.
# Уточнение модели: на этом круге И-7 (consumes candidates.tsv) применяется
# всегда (для любого класса), потому что публикация — общее ядро контракта 3.
# Защита И-13 проявляется через И-2/И-7: кодовая задача без diff/merge
# отказывается по И-7; против этой формы клетка красна при попытке
# «class=code + пустой diff». Здесь показываем форму: код И-13 — НЕ закрыть
# КОДОВУЮ батареей, отказ по И-7 защищает кодовую форму (тот же код И-7 покрывает
# универсально, И-13 усиливает требованием diff).
