# Профиль батареи для scripts/accept_task_commit.sh (контракт 037, §Инварианты
# М2). Профиль ЗНАЕТ свою грамматику (^[A-Za-z0-9_-]+$ для --author,
# ^wip/[0-9]+/[A-Za-z0-9_-]+$ для --branch, ^[0-9a-f]{40}$ для sha) и строит
# синтетические деревья ЗНАНИЕМ этой грамматики (не общий шаблон для всех
# гардов — параметризация по имени профиля).
ACC_REPO="$(cd "$HERE/../.." && pwd -P)"
ACC_SUBJ="$ACC_REPO/scripts/accept_task_commit.sh"

_acc_toy_init() {  # <MAIN> — инициализировать main-репо (root)
  local r="$1"
  mkdir -p "$r"
  git -C "$r" init -q -b main
  printf 'seed\n' > "$r/seed.txt"
  git -C "$r" add seed.txt
  git -C "$r" -c user.name=seed -c user.email=seed@dev-harness.local -c commit.gpgsign=false commit -qm init
}

_acc_src_make() {  # <SRC_DIR> <author-name> <email> <commit-msg>  — src с одним коммитом
  local s="$1" an="$2" ae="$3" msg="$4"
  git clone -q "$MAIN" "$s" 2>/dev/null
  git -C "$s" checkout -q -b work
  printf 'work-by-%s\n' "$an" > "$s/work.txt"
  git -C "$s" add work.txt
  git -C "$s" -c user.name="$an" -c user.email="$ae" -c commit.gpgsign=false commit -qm "$msg"
}

battery_delimiter_collision() {
  # Контракт 037 §М2 п.4 (точечный якорь терминатора): «wip/201/implementer»
  # не должен матчить частично «wip/201/implementer-old» при любой форме
  # сравнения. Байт `-` легален ВНУТРИ `--branch` (алфавит `[A-Za-z0-9_-]+`),
  # и `wip/201/architect-decoy` — супер-строка `wip/201/architect`. Если бы
  # гард использовал префикс-матч (`wip/201/architect` как `case` glob или
  # подстрочный grep), приёмка на `wip/201/architect` случайно задела бы
  # decoy-ветку.
  #
  # Тест: создаём обе ветки с architect и architect-decoy; единственный src
  # несёт коммит author=architect (валидный); запускаем accept на
  # wip/201/architect; проверяем:
  #   (a) rc 0, wip/201/architect tip СДВИНУЛСЯ на коммит architect;
  #   (б) wip/201/architect-decoy tip НЕ СДВИНУЛСЯ (точечный якорь ≠
  #       префиксный матч).
  local w MAIN SRC a_tip_before d_tip_before a_tip_after d_tip_after out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_acc_dc.XXXXXX")"
  MAIN="$w/main"; SRC="$w/src"
  _acc_toy_init "$MAIN"
  git -C "$MAIN" branch wip/201/architect
  git -C "$MAIN" branch wip/201/architect-decoy
  # tip обеих веток сейчас == tip main (init). Запоминаем ОБА — для
  # доказательства, что decoy не двинулся.
  a_tip_before="$(git -C "$MAIN" rev-parse wip/201/architect)"
  d_tip_before="$(git -C "$MAIN" rev-parse wip/201/architect-decoy)"
  [ "$a_tip_before" = "$d_tip_before" ] || { rm -rf "$w"; return 1; }
  _acc_src_make "$SRC" "architect" "architect@dev-harness.local" "by architect"
  out="$(bash "$ACC_SUBJ" --root "$MAIN" --source "$SRC" --branch wip/201/architect --author architect 2>&1)"; rc=$?
  a_tip_after="$(git -C "$MAIN" rev-parse wip/201/architect)"
  d_tip_after="$(git -C "$MAIN" rev-parse wip/201/architect-decoy)"
  rm -rf "$w"
  # rc 0 (architect валиден), wip/201/architect СДВИНУЛСЯ, wip/201/architect-decoy НЕ двинулся.
  [ "$rc" -eq 0 ] \
    && [ "$a_tip_after" != "$a_tip_before" ] \
    && [ "$d_tip_after" = "$d_tip_before" ] \
    && printf '%s' "$out" | grep -Fq "ACCEPTED branch=wip/201/architect tip="
}

battery_regex_injection() {
  # Контракт 037 §М2 п.3 (литеральное untrusted-untrusted сравнение): коммитный
  # %an/%ae НЕ интерпретируется как regex-паттерн при сравнении с --author.
  # Git ничем не ограничивает содержимое имени автора — ERE-метасимволы (.,
  # *, +, ?, [... и т.д.) легальны в %an буквально. Если бы гард интерполировал
  # чужой %an в `grep -E` против ожидаемого автора, обманная реализация
  # приняла бы коммит с %an='.*' как «соответствующий ЛЮБОМУ --author» —
  # `grep -E '.*' <<<'implementer'` ошибочно матчит. Литеральное `[ = ]` —
  # НЕ матчит: `.*` ≠ `implementer` байт-в-байт.
  #
  # ТРИ пары в одном тесте:
  #   (a) --author 'a.*b' (метасимвол В argv, вне алфавита [A-Za-z0-9_-]+)
  #       → именованный отказ ГРАММАТИКИ (rc 1), ДО какого-либо сравнения
  #       identity. Стаб «расширяет алфавит ради инъекции» умирает здесь.
  #   (б) --author implementer против коммита с %an='.*' (ERE-метасимвол в
  #       фактическом имени, git-легальный) → rc 1 (именованный отказ
  #       identity, литеральное сравнение). Стаб «интерполирует чужой %an
  #       в grep -E» умирает здесь.
  #   (в) --author implementer против честного коммита с %an='implementer'
  #       (без метасимволов) → rc 0 (различающая зелёная пара — литеральное
  #       сравнение корректно).
  local w MAIN SRC_REJECT SRC_REGEX SRC_OK out_r out_x out_a rc_r rc_x rc_a
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_acc_ri.XXXXXX")"
  MAIN="$w/main"
  _acc_toy_init "$MAIN"
  git -C "$MAIN" branch wip/201/implementer

  # (a) --author 'a.*b' — argv вне алфавита. Источник не нужен — отказ
  # ГРАММАТИКИ срабатывает ДО любого сравнения identity. Достаточно
  # любого валидного --source (создадим один).
  SRC_REJECT="$w/src-reject"
  _acc_src_make "$SRC_REJECT" "implementer" "implementer@dev-harness.local" "valid author"
  out_r="$(bash "$ACC_SUBJ" --root "$MAIN" --source "$SRC_REJECT" --branch wip/201/implementer --author 'a.*b' 2>&1)"; rc_r=$?

  # (б) %an='.*' (ERE-мета в фактическом имени, легально для git).
  # git не отвергает '.*' как author name — он передаётся буквально в
  # commit object; rev-list/log %an возвращает '.*' как строку.
  SRC_REGEX="$w/src-regex"
  _acc_src_make "$SRC_REGEX" ".*" ".*@dev-harness.local" "metachar author"
  out_x="$(bash "$ACC_SUBJ" --root "$MAIN" --source "$SRC_REGEX" --branch wip/201/implementer --author implementer 2>&1)"; rc_x=$?

  # (в) Честный %an='implementer' → rc 0.
  SRC_OK="$w/src-ok"
  _acc_src_make "$SRC_OK" "implementer" "implementer@dev-harness.local" "valid author 2"
  out_a="$(bash "$ACC_SUBJ" --root "$MAIN" --source "$SRC_OK" --branch wip/201/implementer --author implementer 2>&1)"; rc_a=$?

  rm -rf "$w"

  # (a) Грамматический отказ: rc 1, именованный (--author не соответствует).
  [ "$rc_r" -eq 1 ] && printf '%s' "$out_r" | grep -Fq -- '--author не соответствует грамматике' || return 1
  # (б) Identity расхождение литеральное: rc 1, именует actual_an='.*'.
  [ "$rc_x" -eq 1 ] && printf '%s' "$out_x" | grep -Fq 'actual_an=.*' || return 1
  # (в) Честный вход: rc 0, stdout ACCEPTED.
  [ "$rc_a" -eq 0 ] && printf '%s' "$out_a" | grep -Fq 'ACCEPTED branch=wip/201/implementer tip='
}

battery_silent_drop() {
  # Контракт 037 §М2 п.1 (точечный якорь терминатора) + п.4 («wip/201/main»
  # как `main` без `wip/N/автор`-формы вне грамматики): если бы гард НЕ
  # валидировал --branch и принимал произвольную форму, тестовая ветка
  # «main» (которая существует в каждом репо как refs/heads/main по
  # умолчанию) была бы молчаливо использована целью. Это противоречит
  # §М2 п.4 — заякоренность ОБЕИХ границ.
  #
  # Тест: --branch='main' (без wip/NNN/автор-формы) → rc 1, именованный
  # отказ ГРАММАТИКИ, НЕ молчаливое использование main как цели.
  local w MAIN SRC out rc
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_acc_sd.XXXXXX")"
  MAIN="$w/main"; SRC="$w/src"
  _acc_toy_init "$MAIN"
  _acc_src_make "$SRC" "implementer" "implementer@dev-harness.local" "valid"
  out="$(bash "$ACC_SUBJ" --root "$MAIN" --source "$SRC" --branch main --author implementer 2>&1)"; rc=$?
  rm -rf "$w"
  # rc 1, именованный отказ грамматики --branch.
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq -- '--branch не соответствует грамматике wip/NNN/автор'
}

battery_self_application_green() {
  # Контракт 037 §Инварианты М2 п.5 (battery_self_application_green):
  # грамматика author/branch применена к БУКВАЛЬНЫМ подстрокам
  # `<автор>`/`wip/<NNN>/<автор>` ИЗ ТЕКСТА КОНТРАКТА 037 секции М2
  # → ОБЕ отвергнуты (rc≠0 гарда на этом вводе), доказывая, что
  # плейсхолдер-проза контракта не принимается за валидный ввод.
  #
  # Угловые скобки `<`/`>` вне замкнутого алфавита `[A-Za-z0-9_-]+` — даже
  # без отдельной проверки «содержимое контракта» видно: если бы гард
  # НЕ валидировал author, он бы попытался скормить argv '<автор>' в
  # git-fetch/wip-ветку, что очевидно сломало бы любую операцию. Здесь
  # тест пинует ОТКАЗ ГРАММАТИКИ ДО какой-либо операции.
  local w MAIN SRC out_a out_b rc_a rc_b
  w="$(mktemp -d "${TMPDIR:-/tmp}/battery_acc_sag.XXXXXX")"
  MAIN="$w/main"; SRC="$w/src"
  _acc_toy_init "$MAIN"
  _acc_src_make "$SRC" "implementer" "implementer@dev-harness.local" "valid"
  # Подстрока из §Инварианты М2: `<автор>` (буквально, с угловыми скобками).
  out_a="$(bash "$ACC_SUBJ" --root "$MAIN" --source "$SRC" --branch wip/201/implementer --author '<автор>' 2>&1)"; rc_a=$?
  # Подстрока из §Инварианты М2: `wip/<NNN>/<автор>` (буквально, с угловыми).
  out_b="$(bash "$ACC_SUBJ" --root "$MAIN" --source "$SRC" --branch 'wip/<NNN>/<автор>' --author implementer 2>&1)"; rc_b=$?
  rm -rf "$w"
  # ОБА отвергнуты rc 1 с именованным отказом грамматики.
  [ "$rc_a" -eq 1 ] \
    && printf '%s' "$out_a" | grep -Fq -- '--author не соответствует грамматике' \
    && [ "$rc_b" -eq 1 ] \
    && printf '%s' "$out_b" | grep -Fq -- '--branch не соответствует грамматике'
}
