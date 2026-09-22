# Профиль батареи для scripts/check_provodka.sh (038) — РЕГРЕССИОННОЕ
# предъявление: батарея прогнана на УЖЕ ДОЧИНЕННОМ (после круга 15) барьере
# БЕЗ единой правки его кода — контракт 041 038 НЕ трогает ретроактивно.
# Зелёный итог здесь доказывает, что круги 11-15 038 действительно закрыли
# соответствующие классы, и что батарея не орфанна (различает честный вход от
# форжа — см. регрессию battery_regex_injection).
PROVODKA_REPO="$(cd "$HERE/../.." && pwd -P)"
PROVODKA_SUBJ="$PROVODKA_REPO/scripts/check_provodka.sh"

_provodka_toy() {  # <каталог> — честная минимальная основа
  local r="$1"
  mkdir -p "$r/scripts" "$r/.githooks" "$r/roles" "$r/contracts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$r/scripts/check_ok.sh"
  printf 'bash scripts/check_ok.sh\n' > "$r/.githooks/pre-commit"
  printf '# role fixture\n\nNorma stroki roli battery R.\n' > "$r/roles/fixer.md"
}

battery_delimiter_collision() {
  # Норма-строка легально содержит байт `|` — исторический внутренний
  # разделитель ДО круга 12 (channel-pipe-truncation). Пост-round-12
  # реализация несёт поля МАССИВАМИ — байт `|` в данных не участвует ни в
  # каком join. Ожидание: норма-строка НЕ усечена, найдена через grep -Fxq.
  local w r norm out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_dc.XXXXXX")"; r="$w/toy"; _provodka_toy "$r"
  norm='Norma so znakom | vnutri teksta ostajotsja celoj.'
  printf '# role fixture\n\n%s\n' "$norm" > "$r/roles/fixer.md"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- role=roles/fixer.md «%s»\n' "$norm" > "$r/contracts/001-x.md"
  out="$(bash "$PROVODKA_SUBJ" "$r" "contracts/001-x.md" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 0 ]
}

battery_regex_injection() {
  # Basename гарда с ERE-метасимволом (`.` в `a.b.sh`) — круг 14 закрыл
  # интерполяцию regex. Позитив: литеральный basename в hook → rc 0.
  # Форж: суррогат `axb.sh` без `a.b.sh` → rc 1 (НЕ должен матчиться regex'ом).
  local w g b out_g rc_g out_b rc_b
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_ri.XXXXXX")"; g="$w/green"; b="$w/bad"
  mkdir -p "$g/scripts" "$g/.githooks" "$g/roles" "$g/contracts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$g/scripts/a.b.sh"
  printf 'bash scripts/a.b.sh\n' > "$g/.githooks/pre-commit"
  printf '# role fixture\n\nNorma stroki roli battery R.\n' > "$g/roles/fixer.md"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- guard=scripts/a.b.sh\n- role=roles/fixer.md «Norma stroki roli battery R.»\n' > "$g/contracts/001-x.md"
  out_g="$(bash "$PROVODKA_SUBJ" "$g" "contracts/001-x.md" 2>&1)"; rc_g=$?

  mkdir -p "$b/scripts" "$b/.githooks" "$b/roles" "$b/contracts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$b/scripts/a.b.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$b/scripts/axb.sh"
  printf 'bash scripts/axb.sh\n' > "$b/.githooks/pre-commit"
  printf '# role fixture\n\nNorma stroki roli battery R.\n' > "$b/roles/fixer.md"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- guard=scripts/a.b.sh\n- role=roles/fixer.md «Norma stroki roli battery R.»\n' > "$b/contracts/001-x.md"
  out_b="$(bash "$PROVODKA_SUBJ" "$b" "contracts/001-x.md" 2>&1)"; rc_b=$?
  rm -rf "$w"
  [ "$rc_g" -eq 0 ] && [ "$rc_b" -eq 1 ]
}

battery_silent_drop() {
  # Голая строка канала без `- `-префикса рядом с честной (round 11,
  # bare-channel-line) — ожидание: ИМЕНОВАННЫЙ отказ САМОЙ строкой.
  local w r out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_pk_sd.XXXXXX")"; r="$w/toy"; _provodka_toy "$r"
  printf '# kontrakt\n\n## Predmet\np\n\nПРОВОДКА:\n- role=roles/fixer.md «Norma stroki roli battery R.»\nrole=roles/missing.md «Missing.»\n' > "$r/contracts/001-x.md"
  out="$(bash "$PROVODKA_SUBJ" "$r" "contracts/001-x.md" 2>&1)"; rc=$?
  rm -rf "$w"
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq 'проводка: строка вне грамматики: role=roles/missing.md «Missing.»'
}

battery_self_application_green() {
  # Само-применение: check_provodka.sh на СОБСТВЕННОМ буквальном тексте
  # контракта 038 (носителя поля ПРОВОДКА) — GREEN, без правки его кода.
  local out rc
  out="$(cd "$PROVODKA_REPO" && bash "$PROVODKA_SUBJ" "$PROVODKA_REPO" "contracts/038-provodka-done-gejt.md" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ]
}
