#!/usr/bin/env bash
# Клетка Б-4 «отключение любого писателя красит сквозную пробу» (контракт 098,
# §Инварианты Б-4, гашение Р4-3: писатели реальны, не декорация): сквозная проба
# Б-1 (полный журнал штатными вызовами + publish) с ОТКЛЮЧЁННЫМ ровно одним
# писателем красна ИМЕНОВАННЫМ отказом двери — verdict-off: «нет применимого
# accept для задачи», check-off: «нет обязательной проверки: ci-b», policy-off:
# «неавторизованный переход политики»; target неизменен. Положительный
# контроль: все писатели на месте — публикация зелёная. Обманные стабы
# s1/s2/s3 (писатель ничего не пишет) ловятся этой же пробой через клетку Б-1.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: otkljuchenie-pisatelja: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

# proba <писатель-off> <фраза отказа> — свежий мир, полный журнал БЕЗ одного
# писателя, publish обязан отказать именованной фразей, main не тронут
proba() {  # использует глобальные W/pc/B/C/M/OID — trap EXIT видит актуальный мир
  local except="$1" fraza="$2" out rc
  W="$(_d98_world "otkl-$except")" || return 2
  trap '_d98_cleanup "${W:-}"' EXIT
  pc="$(_d98_podgotovka "$W" T-1)" || return 2
  read -r B C M OID <<<"$pc"
  _d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" "$except" || return 2
  out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
    --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
    --candidate-ref kandidat --journal "$W/prinyato/registry/candidates.tsv" 2>&1)"; rc=$?
  if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "$fraza"; then
    printf 'КРАСНО: otkljuchenie-pisatelja: %s-off не красит сквозную пробу (rc=%s, вывод: %s)\n' "$except" "$rc" "$out" >&2
    return 1
  fi
  if [ "$(git -C "$W/repo" rev-parse main)" != "$B" ]; then
    printf 'КРАСНО: otkljuchenie-pisatelja: %s-off — отказ сдвинул main\n' "$except" >&2
    return 1
  fi
  _d98_cleanup "$W"; trap - EXIT
  return 0
}

proba verdict 'нет применимого accept для задачи: T-1' || exit 1
proba check   'нет обязательной проверки: ci-a'       || exit 1
proba policy  'неавторизованный переход политики:'    || exit 1

# положительный контроль: все писатели — публикация зелёная
W="$(_d98_world otkl-vse)" || exit 2
trap '_d98_cleanup "${W:-}"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: otkljuchenie-pisatelja: полный набор писателей отказал\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$W/prinyato/registry/candidates.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: otkljuchenie-pisatelja: полный набор не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
