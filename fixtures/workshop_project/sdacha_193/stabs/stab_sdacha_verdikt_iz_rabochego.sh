#!/usr/bin/env bash
# обманка «предыдущий вердикт из рабочего дерева»: покрытие дельты читает
# РАБОЧИЙ файл вердикта, а не HEAD-блоб (AGENTS п.8/9; батарея 193, И5;
# блок критика Crit193V1 К-08). Различающий вход — мир, где рабочий файл
# вердикта скрывает закоммиченные блоки.
set -uo pipefail
ROOT="$1"; CONTRACT="$2"
otkaz() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
LISTOK="$(sed -n 's/^СДАЧА: //p' "$ROOT/$CONTRACT" | head -n 1)"
[ -n "$LISTOK" ] || otkaz 'строка СДАЧА: обязательна'
PRED="$(sed -n 's/^ПРЕДЫДУЩИЙ ВЕРДИКТ: //p' "$ROOT/$LISTOK" | head -n 1)"
[ -n "$PRED" ] || { printf 'СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)\n'; exit 0; }
# ДЕФЕКТ: cat по рабочему дереву вместо закоммиченного HEAD-блоба
telo="$(cat "$ROOT/$PRED" 2>/dev/null)" || otkaz "предыдущий вердикт не закоммичен (AGENTS п.9): $PRED"
delta="$(awk '/^## Дельта/{f=1;next} /^## /{f=0} f && /^- /' "$ROOT/$LISTOK")"
v_sekcii=0
while IFS= read -r stroka; do
    [ "$stroka" = '## Карта классов' ] && { v_sekcii=1; continue; }
    if [ "$v_sekcii" -eq 1 ]; then
        case "$stroka" in
            '## '*) break ;;
            'К-'*': блок — '*)
                klass="${stroka%%:*}"
                printf '%s\n' "$delta" | grep -q "^- $klass · " \
                    || otkaz "блок $klass предыдущего вердикта не закрыт в «## Дельта»" ;;
        esac
    fi
done <<< "$telo"
printf 'СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=%d)\n' \
    "$(printf '%s\n' "$delta" | grep -c -- '^- ' || true)"
exit 0
