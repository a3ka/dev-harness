#!/usr/bin/env bash
# Клетка И-9 «стартовый и задачный контекст укладываются в принятые бюджеты
# без потери обязательных норм» (контракт 095, Выход п.7). (а) гигантская
# вклейка (>40000 байт, потолок §13.6-1 владельца) — именованный отказ
# «режь задачу», без пака; (б) обычный пак укладывается в бюджет, строка
# BUDGET несёт фактический размер вклейки, пересчитанный проверяющим
# (вклейка = байты до секции MANIFEST — манифест есть ссылки, не вклейка).
# Обман (s9: бюджет не считается) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: bjudzhet-vklejki: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i9)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

# (а) гигантская КОНТЕКСТ-вклейка — режь задачу
python3 - "$R/contracts/777-toy.md" <<'PY'
import sys
p = sys.argv[1]
line = 'КОНТЕКСТ: ' + 'x' * 41000 + '\n'
s = open(p).read().replace('КОНТЕКСТ: модуль toy, сосед один\n', line)
open(p, 'w').write(s)
PY
out="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: режь задачу:'; then
  printf 'КРАСНО: i9: сверхбюджетная вклейка не отказана «режь задачу» (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq '=== make_task'; then
  printf 'КРАСНО: i9: сверхбюджетный отказ выдал пак\n' >&2; exit 1
fi

# (б) обычный мир — бюджет заявлен и совпадает с пересчётом проверяющего
python3 - "$R/contracts/777-toy.md" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
import re
s = re.sub(r'^КОНТЕКСТ: x+$', 'КОНТЕКСТ: модуль toy, сосед один', s, flags=re.M)
open(p, 'w').write(s)
PY
out2="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
if [ "$rc2" -ne 0 ]; then
  printf 'КРАСНО: i9: обычный пак не строится (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi
vk="$(printf '%s\n' "$out2" | sed -n 's/^BUDGET: vklejka=\([0-9]*\)\/40000$/\1/p')"
[ -n "$vk" ] || { printf 'КРАСНО: i9: строки BUDGET нет\n' >&2; exit 1; }
[ "$vk" -le 40000 ] || { printf 'КРАСНО: i9: заявленный бюджет сверх потолка: %s\n' "$vk" >&2; exit 1; }
fact="$(printf '%s\n' "$out2" | awk '/^=== MANIFEST ===$/{exit} {print}' | wc -c | tr -d ' ')"
[ "$vk" = "$fact" ] || { printf 'КРАСНО: i9: заявленная вклейка %s != фактическая %s\n' "$vk" "$fact" >&2; exit 1; }
exit 0
