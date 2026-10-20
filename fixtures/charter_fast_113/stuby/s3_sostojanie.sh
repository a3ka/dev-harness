#!/usr/bin/env bash
# s3_sostojanie.sh — ОБМАННЫЙ СТАБ: судит СОСТОЯНИЕ (блоб HEAD == блобу заморозки), не историю.
# Наблюдаемая ложь: d3_otkat — совершённое нарушение с откатом содержимого невидимо:
# состояние чисто, а изменение БЫЛО. Барьер судит ИЗМЕНЕНИЯ, не состояния.
st113_obhod_sostojanie() {
  local f since h8
  h8="$(git -C "$ROOT" rev-parse --short=8 HEAD)"
  while IFS=$'\t' read -r f since; do
    [ -n "$f" ] || continue
    changes=$((changes + 1))
    if git -C "$ROOT" cat-file -e "$since:$f" 2>/dev/null && \
       [ "$(git -C "$ROOT" rev-parse "HEAD:$f" 2>/dev/null)" = "$(git -C "$ROOT" rev-parse "$since:$f" 2>/dev/null)" ]; then
      excused=$((excused + 1))
    else
      bad "уставной документ изменён без разрешения владельца: $f в $h8 — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: $f <причина>» в первой колонке"
    fi
  done < "$TMP/pairs"
}
ST113_OBHOD=st113_obhod_sostojanie
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
