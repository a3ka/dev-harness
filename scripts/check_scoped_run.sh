#!/usr/bin/env bash
# Барьер приёмки ИНТЕГРАЦИИ scoped-режима в раннер (контракт 006, тир 2). Гоняет
# `<корень>/scripts/verify_antiplacebo.sh` на ПОРОЖДЁННЫХ игрушечных деревьях и УТВЕРЖДАЕТ:
#   (л) ФИЛЬТР: при правке одного барьера прогнан ТОЛЬКО он («барьеров: 1», RC==0) — ловит
#       фильтр, который выронил бы выбранный барьер либо не сузил выборку, ИЛИ вернул бы не-ноль;
#   (м1) СОХРАНЕНИЕ ОТКАЗА (класс «красное не предъявлено»): сломанная фикстура b — scoped_rc
#       равен full_rc И scoped-вывод содержит ту же подстроку диагноза;
#   (м2) СОХРАНЕНИЕ ОТКАЗА (класс «код 2»): барьер b выходит кодом 2 (нечем проверить) — scoped
#       даёт ТОТ ЖЕ код и диагноз, НЕ зелёный и НЕ needs-full;
#   (м3) СОХРАНЕНИЕ ОТКАЗА (класс «необъявленный код», напр. 7) — та же сверка;
#   (н) СОХРАНЕНИЕ ОТКАЗА (запись вне $WORK): фикстура пишет в $REPO — scoped даёт ТОТ ЖЕ
#       отказ «дерево изменилось вне $WORK» с тем же диагнозом;
#   (case) CASE-ФИЛЬТР: `--scope <ключ>/<case>` прогоняет РОВНО этот case — ни больше, ни меньше.
#
# Образец — check_metering/check_scope_select: предмет (`verify_antiplacebo.sh`) пишет
# ИСПОЛНИТЕЛЬ; этот барьер и fixtures/check_scoped_run/ — АРХИТЕКТОРА; фикстуры предъявляют ЕГО
# красным, подавая обманный verify_antiplacebo в подставной корень. ВЕТВЬ м1 ВКЛЮЧАЕТ В СЕБЯ м
# (бывшая проверка «оба ненулевые» — частный случай равенства, оба не-ноль по построению).
#
#   bash scripts/check_scoped_run.sh [<корень>] [<ветвь>]
#     <корень> — где лежит scripts/verify_antiplacebo.sh (умолчание — корень репозитория);
#     <ветвь>  — одна из л м м1 м2 м3 н case (умолчание — все). «м» — алиас м1 для обратной
#                совместимости со старыми фикстурами.
#
# Коды возврата: 0 — запрошенные ветви зелены, 1 — ветвь провалена, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null LC_ALL="${LC_ALL:-C.UTF-8}"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$SELF_DIR/.." && pwd)}"
WANT="${2:-all}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd || echo "$ROOT")"
VA="$ROOT/scripts/verify_antiplacebo.sh"

die()  { printf 'ОТКАЗ ветвь (%s): %s\n' "$1" "$2" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

command -v git >/dev/null 2>&1 || skip "нет git — игрушку не построить"
[ -f "$VA" ] || skip "нет $VA — предмет проверки отсутствует"

TMP_ROOT="$SELF_DIR/../tmp"; mkdir -p "$TMP_ROOT" 2>/dev/null || skip "tmp не создать"
WORK="$(mktemp -d "$TMP_ROOT/check_scoped_run.XXXXXX")" || skip "mktemp не смог"
WORK="$(cd "$WORK" && pwd -P)"; export GIT_CEILING_DIRECTORIES="$WORK"
trap 'rm -rf "$WORK"' EXIT

gg() { git -C "$1" -c user.name=T -c user.email=t@l -c commit.gpgsign=false \
       -c core.hooksPath=/dev/null -c init.defaultBranch=main "${@:2}"; }

# Пишет inline scope_select в <каталог>/scripts/scope_select.sh — НЕ БАРЬЕР.
# Использует heredoc с ОДИНАРНЫМИ кавычками-ограничителями, чтобы \$ остался литералом.
write_inline_scope_select() {  # <каталог>
  local r="$1"
  cat > "$r/scripts/scope_select.sh" <<'EOF'
#!/usr/bin/env bash
# НЕ БАРЬЕР: игрушечный селектор (контракт 006)
set -uo pipefail
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
root="${1:?корень}"; shift
flag="${1:-}"; [ "$#" -gt 0 ] && shift || true
emit() { printf 'SCOPED: %s\n' "$*" >&2; }
case "$flag" in
  --scope)
    [ "$#" -gt 0 ] || { echo "пустой --scope — ключи не заданы" >&2; exit 1; }
    for k in "$@"; do
      case "$k" in
        */*) bar="${k%%/*}"; cas="${k#*/}"
             [ -f "$root/scripts/$bar.sh" ] || { echo "неизвестный ключ $bar" >&2; exit 1; }
             [ -f "$root/fixtures/$bar/$cas.sh" ] || { echo "неизвестный case $k" >&2; exit 1; } ;;
        *)   [ -f "$root/scripts/$k.sh" ] || { echo "неизвестный ключ $k" >&2; exit 1; } ;;
      esac
    done
    emit "не для приёмки"
    printf 'MODE: scoped\n'; for k in "$@"; do printf 'KEY: %s\n' "$k"; done
    exit 0 ;;
  --changed)
    base="${1:-}"
    if ! command -v git >/dev/null 2>&1; then
      emit "нет git — fail-closed"; printf 'MODE: needs-full\n'; exit 2
    fi
    if ! git -C "$root" rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1; then
      emit "база не резолвится: $base"; printf 'MODE: needs-full\n'; exit 2
    fi
    names="$(git -C "$root" diff --name-status "$base" HEAD)"
    full=0; keys=""
    while IFS=$'\t' read -r st p _; do
      [ -n "$st" ] || continue
      case "$st" in A|D|R*|C*) full=1 ;; esac
      case "$p" in
        scripts/*.sh) f="${p#scripts/}"; f="${f%.sh}"
                      if head -5 "$root/scripts/$f.sh" 2>/dev/null | grep -q 'Коды возврата'; then keys="$keys $f"; else full=1; fi ;;
        fixtures/*/*) k="${p#fixtures/}"; k="${k%%/*}"; keys="$keys $k" ;;
      esac
    done <<< "$names"
    if [ "$full" = 1 ]; then emit "не для приёмки"; printf 'MODE: full\n'; exit 0; fi
    keys="$(printf '%s\n' $keys | sort -u | grep -v '^$' || true)"
    [ -n "$keys" ] || { emit "0 задетых — scoped ничего не доказал, полный гейт в CI"; printf 'MODE: needs-full\n'; exit 2; }
    emit "не для приёмки"
    printf 'MODE: scoped\n'; for k in $keys; do printf 'KEY: %s\n' "$k"; done
    exit 0 ;;
  *) echo "неизвестный режим: $flag" >&2; exit 1 ;;
esac
EOF
  chmod +x "$r/scripts/scope_select.sh"
}

# Стандартный toy с a,b — оба барьера используют `$0`-относительный маркер, оба с честной
# фикстурой (green → remove mark → red).
build_toy() {  # <каталог>
  local r="$1" x
  mkdir -p "$r/scripts" "$r/fixtures/a" "$r/fixtures/b"
  for x in a b; do
    cat > "$r/scripts/$x.sh" <<EOF
#!/usr/bin/env bash
# Коды возврата: 0 — маркер есть, 1 — нет
d="\$(cd "\$(dirname "\$0")/.." && pwd)"
[ -f "\$d/mark" ] || { echo "нет mark ($x)" >&2; exit 1; }
EOF
    chmod +x "$r/scripts/$x.sh"
    cat > "$r/fixtures/$x/case_$x.sh" <<EOF
# ПРИЧИНА: нет mark ($x)
set -euo pipefail
mkdir -p "\$WORK/w"; touch "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
rm -f "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
EOF
  done
  write_inline_scope_select "$r"
  printf 'документация\n' > "$r/README.md"   # не-барьерный док: для ветви (ч) doc-only
  printf 'заметки\n' > "$r/notes.txt"        # ещё не-барьерный путь (не README): для ветви (ч2)
  gg "$r" init -q -b main .
  gg "$r" add -A; gg "$r" commit -q -m base
  BASE="$(gg "$r" rev-parse HEAD)"
}

# (м1): стандартный toy, но фикстура b НЕ снимает маркер → красное не предъявлено.
build_toy_broken() {  # <каталог>
  local r="$1"; build_toy "$r"
  cat > "$r/fixtures/b/case_b.sh" <<'EOF'
# ПРИЧИНА: нет mark (b)
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
}

# (м2): b выходит кодом 2 (нечем проверить), если маркер не выставлен.
build_toy_code2() {  # <каталог>
  local r="$1"
  mkdir -p "$r/scripts" "$r/fixtures/a" "$r/fixtures/b"
  cat > "$r/scripts/a.sh" <<'EOF'
#!/usr/bin/env bash
# Коды возврата: 0 — ok, 1 — fail
exit 0
EOF
  chmod +x "$r/scripts/a.sh"
  cat > "$r/scripts/b.sh" <<'EOF'
#!/usr/bin/env bash
# Коды возврата: 0 — маркер, 2 — нечем проверить
d="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$d/mark" ] && exit 0
echo "нечем проверить (b)" >&2; exit 2
EOF
  chmod +x "$r/scripts/b.sh"
  cat > "$r/fixtures/a/case_a.sh" <<'EOF'
# ПРИЧИНА: нет mark (a)
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
  cat > "$r/fixtures/b/case_b.sh" <<'EOF'
# ПРИЧИНА: барьер ответил «нечем проверить» (код 2)
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
  write_inline_scope_select "$r"
  gg "$r" init -q -b main .
  gg "$r" add -A; gg "$r" commit -q -m base
  BASE="$(gg "$r" rev-parse HEAD)"
}

# (м3): b выходит необъявленным кодом 7.
build_toy_code7() {  # <каталог>
  local r="$1"
  mkdir -p "$r/scripts" "$r/fixtures/a" "$r/fixtures/b"
  cat > "$r/scripts/a.sh" <<'EOF'
#!/usr/bin/env bash
# Коды возврата: 0 — ok, 1 — fail
exit 0
EOF
  chmod +x "$r/scripts/a.sh"
  cat > "$r/scripts/b.sh" <<'EOF'
#!/usr/bin/env bash
# Коды возврата: 0 — ok, 1 — fail
d="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$d/mark" ] && exit 0
echo "чужой код (b)" >&2; exit 7
EOF
  chmod +x "$r/scripts/b.sh"
  cat > "$r/fixtures/a/case_a.sh" <<'EOF'
# ПРИЧИНА: нет mark (a)
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
  cat > "$r/fixtures/b/case_b.sh" <<'EOF'
# ПРИЧИНА: барьер вышел кодом 7, которого не объявлял
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
  write_inline_scope_select "$r"
  gg "$r" init -q -b main .
  gg "$r" add -A; gg "$r" commit -q -m base
  BASE="$(gg "$r" rev-parse HEAD)"
}

# (н): стандартный toy, но фикстура b ПИШЕТ в $REPO (вне $WORK) → слепок дерева расходится.
build_toy_writeout() {  # <каталог>
  local r="$1"; build_toy "$r"
  cat > "$r/fixtures/b/case_b.sh" <<'EOF'
# ПРИЧИНА: дерево изменилось
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
mkdir -p "$REPO/tmp"; touch "$REPO/tmp/006-writeout-$$"
EOF
}

# (case): стандартный toy, но b имеет ДВА case — case_b_1 и case_b_2.
build_toy_twocase() {  # <каталог>
  local r="$1" x
  mkdir -p "$r/scripts" "$r/fixtures/a" "$r/fixtures/b"
  for x in a b; do
    cat > "$r/scripts/$x.sh" <<EOF
#!/usr/bin/env bash
# Коды возврата: 0 — маркер есть, 1 — нет
d="\$(cd "\$(dirname "\$0")/.." && pwd)"
[ -f "\$d/mark" ] || { echo "нет mark ($x)" >&2; exit 1; }
EOF
    chmod +x "$r/scripts/$x.sh"
  done
  cat > "$r/fixtures/a/case_a.sh" <<'EOF'
# ПРИЧИНА: нет mark (a)
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
  cat > "$r/fixtures/b/case_b_1.sh" <<'EOF'
# ПРИЧИНА: нет mark (b)
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
  cat > "$r/fixtures/b/case_b_2.sh" <<'EOF'
# ПРИЧИНА: нет mark (b)
set -euo pipefail
mkdir -p "$WORK/w"; touch "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
rm -f "$WORK/w/mark"
BARRIER_ROOT="$WORK/w" "$BARRIER"
EOF
  write_inline_scope_select "$r"
  gg "$r" init -q -b main .
  gg "$r" add -A; gg "$r" commit -q -m base
  BASE="$(gg "$r" rev-parse HEAD)"
}

# (изол): a оставляет HOME-маркер на зелёном прогоне; b краснеет ТОЛЬКО если маркер протёк из
# HOME фикстуры a. При корректной per-fixture изоляции HOME (§4) b НЕ видит маркер и не краснеет
# → «красное не предъявлено» → раннер обязан отвергнуть игрушку. Общий HOME (обманка) → b краснеет.
build_toy_homeleak() {  # <каталог>
  local r="$1" x
  mkdir -p "$r/scripts" "$r/fixtures/a" "$r/fixtures/b"
  cat > "$r/scripts/a.sh" <<'EOF'
#!/usr/bin/env bash
# Коды возврата: 0 — маркер есть, 1 — нет
d="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$d/mark" ]; then touch "$HOME/seed-from-a"; exit 0; fi
echo "нет mark (a)" >&2; exit 1
EOF
  cat > "$r/scripts/b.sh" <<'EOF'
#!/usr/bin/env bash
# Коды возврата: 0 — ок, 1 — HOME протёк
d="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$d/mark" ] && exit 0
[ -f "$HOME/seed-from-a" ] && { echo "home протёк между фикстурами" >&2; exit 1; }
exit 0
EOF
  chmod +x "$r/scripts/a.sh" "$r/scripts/b.sh"
  for x in a b; do
    cat > "$r/fixtures/$x/case_$x.sh" <<EOF
# ПРИЧИНА: нет mark ($x)
set -euo pipefail
mkdir -p "\$WORK/w"; touch "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
rm -f "\$WORK/w/mark"
BARRIER_ROOT="\$WORK/w" "\$BARRIER"
EOF
  done
  write_inline_scope_select "$r"
  gg "$r" init -q -b main .
  gg "$r" add -A; gg "$r" commit -q -m base
  BASE="$(gg "$r" rev-parse HEAD)"
}

run_va() { OUT="$( "$VA" "$@" 2>&1 )"; RC=$?; }
want() { [ "$WANT" = all ] || [ "$WANT" = "$1" ]; }
has() { case "$2" in *"$1"*) return 0 ;; *) return 1 ;; esac; }

# Диспетчер ветвей fail-closed: неизвестное имя → не-ноль с названным WANT.
KNOWN_BRANCHES="л м м1 м2 м3 н case изол ц ц2 ц3 ч ч2 ci"
if [ "$WANT" != all ]; then
  found=0
  for k in $KNOWN_BRANCHES; do [ "$WANT" = "$k" ] && found=1; done
  [ "$found" -eq 1 ] || { printf 'ОТКАЗ диспетчер: неизвестная ветвь «%s» (допустимы: %s)\n' \
                                  "$WANT" "$KNOWN_BRANCHES" >&2; exit 1; }
fi

# ── (л) ФИЛЬТР: правка одного барьера b → прогнан ТОЛЬКО он, RC==0 ─────────────
if want л; then
  T="$WORK/л"; build_toy "$T"
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  run_va "$T" --changed "$BASE"
  rc_l="$RC"
  [ "$RC" = 0 ] || die л "прогон вернул RC=$RC (не 0) — фильтр сузил, но раннер отказал не по предмету. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '%s\n' "$OUT" | grep -q 'барьеров: 1' \
    || die л "правка одного барьера дала не «барьеров: 1» — фильтр не сузил выборку. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 200)"
  printf '%s\n' "$OUT" | grep -q 'b/case_b.sh' \
    || die л "выбранный барьер b не прогнан — фильтр выронил задетое"
  printf '%s\n' "$OUT" | grep -q 'a/case_a.sh' \
    && die л "барьер a прогнан, хотя не задет — выборка не сужена"
  printf '  ok   (л) фильтр: прогнан ровно выбранный b, RC=0\n' >&2
fi

# Общая проверка равенства (full vs scoped) для (м1)/(м2)/(м3)/(н). Использует глобальные $T и
# $BASE, установленные построителем игрушки.
assert_eq_full_scoped() {  # <ветвь> <ожидаемая подстрока>
  local br="$1" reason="$2"
  run_va "$T";       full_rc="$RC"; full_out="$OUT"
  run_va "$T" --changed "$BASE"; scoped_rc="$RC"; scoped_out="$OUT"
  [ "$full_rc" != 0 ]    || die "$br" "полный прогон дал 0 — тест не про предмет (ожидался не-ноль на $reason)"
  has "$reason" "$full_out" \
    || die "$br" "полный прогон не назвал «$reason» — тест не про предмет (посторонний отказ, а не заявленный класс). Вывод: $(printf '%s' "$full_out" | tr '\n' ' ' | tail -c 240)"
  [ "$scoped_rc" = "$full_rc" ] \
    || die "$br" "scoped_rc ($scoped_rc) != full_rc ($full_rc) — отказ НЕ сохранён в scoped. Вывод: $(printf '%s' "$scoped_out" | tr '\n' ' ' | tail -c 240)"
  has "$reason" "$scoped_out" \
    || die "$br" "scoped-вывод не содержит «$reason» — класс отказа изменён/проглочен в scoped (full назвал его, scoped — нет). Вывод: $(printf '%s' "$scoped_out" | tr '\n' ' ' | tail -c 240)"
}

# (м1) — и алиас (м): сломанная фикстура b.
if want м1 || want м; then
  T="$WORK/м1"; build_toy_broken "$T"
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  assert_eq_full_scoped м1 "красное не предъявлено"
  [ "$full_rc" = 1 ] || die м1 "ожидался код 1, получен $full_rc"
  printf '  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=%s)\n' "$full_rc" >&2
fi

if want м2; then
  T="$WORK/м2"; build_toy_code2 "$T"
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  assert_eq_full_scoped м2 "нечем проверить"
  [ "$full_rc" = 1 ] || die м2 "ожидался код 1, получен $full_rc"
  printf '  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=%s)\n' "$full_rc" >&2
fi

if want м3; then
  T="$WORK/м3"; build_toy_code7 "$T"
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  assert_eq_full_scoped м3 "которого не объявлял"
  [ "$full_rc" = 1 ] || die м3 "ожидался код 1, получен $full_rc"
  printf '  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=%s)\n' "$full_rc" >&2
fi

if want н; then
  T="$WORK/н"; build_toy_writeout "$T"
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  assert_eq_full_scoped н "дерево изменилось"
  [ "$full_rc" = 1 ] || die н "ожидался код 1, получен $full_rc"
  printf '  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=%s)\n' "$full_rc" >&2
fi

if want case; then
  T="$WORK/case"; build_toy_twocase "$T"
  printf '# правка\n' >> "$T/scripts/b.sh"; gg "$T" commit -q -am 'правка b'
  run_va "$T" --scope b/case_b_1; rc_case="$RC"; out_case="$OUT"
  [ "$rc_case" = 0 ] \
    || die case "--scope b/case_b_1 вернул RC=$rc_case — ожидался 0 (1 case). Вывод: $(printf '%s' "$out_case" | tr '\n' ' ' | tail -c 240)"
  has 'фикстур: 1' "$out_case" \
    || die case "--scope b/case_b_1 прогнал НЕ ровно 1 case — фильтр case-уровня не сузил. Вывод: $(printf '%s' "$out_case" | tr '\n' ' ' | tail -c 240)"
  has 'b/case_b_2.sh' "$out_case" \
    && die case "--scope b/case_b_1 прогнал case_b_2 — фильтр не работает. Вывод: $(printf '%s' "$out_case" | tr '\n' ' ' | tail -c 240)"
  # Несуществующий case — fail-closed (verify_antiplacebo или scope_select обязаны отказать).
  run_va "$T" --scope b/case_unknown; rc_unk="$RC"
  [ "$rc_unk" != 0 ] \
    || die case "--scope b/case_unknown вернул RC=0 — несуществующий case не отвергнут, фильтр молча даёт 0 фикстур. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  printf '  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed\n' >&2
fi

if want изол; then
  T="$WORK/изол"; build_toy_homeleak "$T"
  run_va "$T"
  [ "$RC" != 0 ] || die изол "раннер объявил home-leak-игрушку зелёной (RC=0) — HOME течёт между фикстурами; при per-fixture изоляции (§4) b не краснеет → «красное не предъявлено»"
  has "красное не предъявлено" "$OUT" || die изол "раннер не назвал «красное не предъявлено» на b — per-fixture изоляция HOME не доказана. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  printf '  ok   (изол) HOME изолирован per-fixture: leak-игрушка отвергнута («красное не предъявлено»)\n' >&2
fi

# ── (ц) FAIL-SAFE: нерезолвимый base → ПОЛНЫЙ прогон, RC==0 (не exit 2) ────────
if want ц; then
  T="$WORK/ц"; build_toy "$T"
  run_va "$T" --changed 0000000000000000000000000000000000000000
  [ "$RC" = 0 ] || die ц "нерезолвимый base дал RC=$RC — fail-safe обязан ПОЛНЫЙ прогон зелёным, не отказ. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'a/case_a.sh' "$OUT" || die ц "нерезолвимый base не валидировал a — не полный набор (fail-safe должен гонять всё). Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'b/case_b.sh' "$OUT" || die ц "нерезолвимый base не валидировал b — не полный набор"
  has 'MODE: full' "$OUT" || die ц "MODE: full не напечатан — потребитель verify_antiplacebo не различает fail-safe от needs-full (пин протокола)"
  printf '  ok   (ц) нерезолвимый base → полный прогон, RC=0\n' >&2
fi

# ── (ч) DOC-ONLY: резолвимый base, дифф только по докам → RC==0, 0 барьеров ────
if want ч; then
  T="$WORK/ч"; build_toy "$T"
  printf 'ещё документация\n' >> "$T/README.md"; gg "$T" commit -q -am 'правка доки'
  run_va "$T" --changed "$BASE"
  [ "$RC" = 0 ] || die ч "doc-only дифф дал RC=$RC — doc-коммит обязан зелёный, не краснить CI. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'case_' "$OUT" && die ч "doc-only прогнал барьеры — 0 задетых обязано быть 0 прогонов. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'MODE: none' "$OUT" || die ч "MODE: none не напечатан — потребитель не различает нулевую выборку от needs-full (пин протокола)"
  printf '  ok   (ч) doc-only → RC=0, 0 барьеров\n' >&2
fi

# ── (ц2) FAIL-SAFE: ПУСТОЙ base → ПОЛНЫЙ прогон, RC==0 (обобщение ц, не спецкейс нулей) ─
if want ц2; then
  T="$WORK/ц2"; build_toy "$T"
  run_va "$T" --changed ""
  [ "$RC" = 0 ] || die ц2 "пустой base дал RC=$RC — fail-safe обязан ПОЛНЫЙ прогон зелёным. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'a/case_a.sh' "$OUT" || die ц2 "пустой base не валидировал a — не полный набор"
  has 'b/case_b.sh' "$OUT" || die ц2 "пустой base не валидировал b — не полный набор"
  has 'MODE: full' "$OUT" || die ц2 "MODE: full не напечатан — пин протокола (fail-safe ≠ needs-full)"
  printf '  ok   (ц2) пустой base → полный прогон, RC=0\n' >&2
fi

# ── (ц3) FAIL-SAFE: нерезолвимый НЕНУЛЕВОЙ SHA → ПОЛНЫЙ прогон (закрывает обход «спецкейс нулей») ─
if want ц3; then
  T="$WORK/ц3"; build_toy "$T"
  run_va "$T" --changed 1111111111111111111111111111111111111111
  [ "$RC" = 0 ] || die ц3 "нерезолвимый ненулевой SHA дал RC=$RC — fail-safe обязан ПОЛНЫЙ прогон зелёным, не только на сорока нулях. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'a/case_a.sh' "$OUT" || die ц3 "нерезолвимый ненулевой SHA не валидировал a — не полный набор"
  has 'b/case_b.sh' "$OUT" || die ц3 "нерезолвимый ненулевой SHA не валидировал b — не полный набор"
  has 'MODE: full' "$OUT" || die ц3 "MODE: full не напечатан — пин протокола (fail-safe ≠ needs-full)"
  printf '  ok   (ц3) нерезолвимый ненулевой SHA → полный прогон, RC=0\n' >&2
fi

# ── (ч2) DOC-ONLY по НЕ-README пути → RC==0, 0 барьеров (закрывает обход «спецкейс README») ─
if want ч2; then
  T="$WORK/ч2"; build_toy "$T"
  printf 'ещё заметки\n' >> "$T/notes.txt"; gg "$T" commit -q -am 'правка заметок'
  run_va "$T" --changed "$BASE"
  [ "$RC" = 0 ] || die ч2 "резолвимый base, нулевая выборка по не-README пути (notes.txt) дал RC=$RC — 0 задетых обязано exit 0, не спецкейс README. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'case_' "$OUT" && die ч2 "нулевая выборка прогнала барьеры — 0 задетых обязано быть 0 прогонов. Вывод: $(printf '%s' "$OUT" | tr '\n' ' ' | tail -c 240)"
  has 'MODE: none' "$OUT" || die ч2 "MODE: none не напечатан — пин протокола (нулевая выборка ≠ needs-full)"
  printf '  ok   (ч2) не-README нулевая выборка → RC=0, 0 барьеров\n' >&2
fi

# ── (ci) ПРОВОДКА: ci.yml гонит анти-плацебо scoped через --changed github.event.before ──
# Читает РЕАЛЬНЫЙ ci.yml (предмет implementer), проверка — architect. Засчитывается ТОЛЬКО
# ИСПОЛНЯЕМАЯ часть run:-строки — YAML- И shell-комментарий (всё от первого '#') отсечены
# (арбитраж krasnye-proby-granica-primera п.1). github.event.before у check:no-rewrite не подходит.
if want ci; then
  CI="$ROOT/.github/workflows/ci.yml"
  [ -f "$CI" ] || die ci "нет $CI — проводку scoped CI негде проверить"
  # Строка run: с анти-плацебо ДО shell-комментария ([^#]* останавливается на '#'); режем комментарий.
  ci_line="$(grep -E '^[[:space:]]*run:[^#]*antiplacebo' "$CI" | head -1)"
  ci_exec="${ci_line%%#*}"
  case "$ci_exec" in
    *antiplacebo*--changed*github.event.before*)
      printf '  ok   (ci) ci.yml: ИСПОЛНЯЕМАЯ run-строка гонит анти-плацебо scoped (--changed github.event.before)\n' >&2 ;;
    *)
      die ci "ci.yml: --changed \${{ github.event.before }} НЕ в ИСПОЛНЯЕМОЙ части run:-строки анти-плацебо (после '#' = shell-комментарий, не считается)." ;;
  esac
fi

printf 'check_scoped_run: ветви «%s» зелены\n' "$WANT" >&2
exit 0
