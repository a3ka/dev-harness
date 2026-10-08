#!/usr/bin/env bash
# Батарея 091 «ротация HANDOFF» (контракт 091 §Приёмка): клетки к0–к6, о1–о10.
#
# Оракул — модель W_* в памяти (_toy.sh, правило 8): toy пишется из модели, ожидания
# (байты архива, байты итогового HANDOFF) считаются из ТОЙ ЖЕ модели до вызова субъекта.
# Субъект — env H91_SUBJECT (умолчание $ROOT/scripts/handoff_rotate.sh); отсутствует →
# «красная: предмет отсутствует» rc 1, клетки не исполняются.
#
# Использование: bash red_rotate_091.sh <корень> [клетка…]
#   без списка — все клетки по порядку; rc 0 ⟺ все зелёные; каждая красная печатает
#   «КРАСНО: <код> — <причина>»; rc 2 — нечем проверить.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
H91_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
# shellcheck disable=SC1091
. "$HERE/_toy.sh"

SUBJ="${H91_SUBJECT:-$H91_ROOT/scripts/handoff_rotate.sh}"
if [ ! -f "$SUBJ" ]; then
  printf 'красная: предмет отсутствует\n'
  printf 'КРАСНОЕ 091: нет %s (корень %s)\n' "$SUBJ" "$H91_ROOT" >&2
  exit 1
fi

RED=0
ok_kletka() { printf 'ок %s\n' "$1"; }
red_kletka() { printf 'КРАСНО: %s — %s\n' "$1" "$2" >&2; RED=1; }

# Успех (И-1, И-3, И-4): rc 0; stdout — ровно строка «архив: <путь>»; архив байт-в-байт
# == перенесённой секции; итоговый HANDOFF == префикс+маркеры+хвост (маркеры не тронуты,
# не продублированы, не потеряны — побайтово). Чужой файл архива (W_ARCH_FOREIGN) не тронут.
assert_uspeh() {  # <код> <toy>
  local kod="$1" toy="$2"
  local archoj="$toy/$H91_ARCHDIR/$H91_DATE.md"
  [ "$H91_RC" -eq 0 ] || { red_kletka "$kod" "rc=$H91_RC, ожидался 0"; return; }
  grep -Fxq -- "${H91_OK_PRE}$H91_ARCHDIR/$H91_DATE.md" "$SCR/out" \
    || { red_kletka "$kod" "stdout без строки «архив: …»"; return; }
  h91_expected_archive > "$SCR/exp_arch"
  cmp -s "$archoj" "$SCR/exp_arch" || { red_kletka "$kod" "архив не байт-в-байт секция"; return; }
  h91_expected_result > "$SCR/exp_res"
  cmp -s "$toy/HANDOFF.md" "$SCR/exp_res" || { red_kletka "$kod" "итоговый HANDOFF не префикс+маркеры+хвост"; return; }
  if [ -n "${W_ARCH_FOREIGN:-}" ]; then
    printf '%s' "$W_ARCH_FOREIGN" > "$SCR/exp_fr"
    cmp -s "$toy/$H91_ARCHDIR/2029-12-31.md" "$SCR/exp_fr" \
      || { red_kletka "$kod" "чужой файл архива тронут"; return; }
  fi
  ok_kletka "$kod"
}

# Отказ (И-2, И-6): rc 1; stderr несёт именованную строку; НИ ОДИН байт toy не меняется.
assert_otkaz() {  # <код> <toy> <строка>
  local kod="$1" toy="$2" lit="$3"
  [ "$H91_RC" -eq 1 ] || { red_kletka "$kod" "rc=$H91_RC, ожидался 1"; return; }
  h91_err_has "$lit" || { red_kletka "$kod" "stderr без именованной строки: $lit"; return; }
  cmp -s "$toy/HANDOFF.md" "$SCR/atom_hand" || { red_kletka "$kod" "HANDOFF.md изменён при отказе"; return; }
  if [ "${W_ARCH_EXIST:-}" = 'да' ]; then
    printf '%s' "${W_ARCH_BYTES:-}" > "$SCR/exp_arch_pre"
    cmp -s "$toy/$H91_ARCHDIR/$H91_DATE.md" "$SCR/exp_arch_pre" \
      || { red_kletka "$kod" "существующий архив изменён при отказе"; return; }
  else
    [ ! -e "$toy/$H91_ARCHDIR/$H91_DATE.md" ] \
      || { red_kletka "$kod" "архив создан при отказе"; return; }
  fi
  ok_kletka "$kod"
}

atom_snimok() {  # <toy> — снимок до прогона
  cp "$1/HANDOFF.md" "$SCR/atom_hand"
}

# h91_markers_size <N> — W_MARKERS ровно N байт (паддинг-строка внутри блока).
h91_markers_size() {
  local block
  block="$(python3 - "$1" "$H91_BEGIN" "$H91_END" <<'PY'
import sys
n = int(sys.argv[1]); begin = sys.argv[2]; end = sys.argv[3]
head = (begin + "\n## Следующая сессия (генерируется: bash scripts/gen_plan.sh --write)\n\n"
        + "- 082 · пара 1 · заморожен · трек CI\n").encode()
tail = (end + "\n").encode()
m = n - len(head) - len(tail) - 2
if m < 0:
    sys.exit(1)
sys.stdout.write((head + b"-" + b"x" * m + b"\n" + tail).decode())
PY
)" || { printf 'NOT_IMPLEMENTED: паддинг маркерного блока\n' >&2; exit 2; }
  W_MARKERS="$block
"
}

# ── клетки ──────────────────────────────────────────────────────────────────────────────
k0() {  # базовый перенос: секция первая, маркеры в конце, архивного каталога нет
  h91_set_konform
  h91_write_toy "$SCR/k0"
  h91_probe_run "$SCR/k0" --date "$H91_DATE"
  assert_uspeh k0 "$SCR/k0"
}

k1() {  # непустые префикс и хвост вокруг маркеров — остаются байт-в-байт
  h91_set_konform
  W_PREFIX="# Журнал сессий харнеса

"
  h91_rnd_line; W_TAIL="$H91_LINE
"
  h91_write_toy "$SCR/k1"
  h91_probe_run "$SCR/k1" --date "$H91_DATE"
  assert_uspeh k1 "$SCR/k1"
}

k2() {  # маркеров нет, секция до конца файла — итоговый == префикс
  h91_set_konform
  W_MARKERS=''; W_TAIL=''
  W_PREFIX="# Журнал сессий харнеса

"
  h91_write_toy "$SCR/k2"
  h91_probe_run "$SCR/k2" --date "$H91_DATE"
  assert_uspeh k2 "$SCR/k2"
}

k3() {  # после секции другой раздел ^## — граница переноса на нём
  h91_set_konform
  local other
  h91_rnd_line; other="## Прочее

$H91_LINE
"
  W_MARKERS=''; W_TAIL="$other"
  h91_write_toy "$SCR/k3"
  h91_probe_run "$SCR/k3" --date "$H91_DATE"
  assert_uspeh k3 "$SCR/k3"
}

k4() {  # маркеры ПОСЛЕ другого раздела: граница — более ранний ^##, маркеры в хвосте
  h91_set_konform
  local other mk
  mk="$W_MARKERS"; W_MARKERS=''
  h91_rnd_line; other="## Прочее

$H91_LINE
"
  W_TAIL="$other$mk"
  h91_write_toy "$SCR/k4"
  h91_probe_run "$SCR/k4" --date "$H91_DATE"
  assert_uspeh k4 "$SCR/k4"
}

k5() {  # архивный каталог существует с чужим файлом — не тронут, архив рядом
  h91_set_konform
  h91_rnd_line
  W_ARCH_FOREIGN="## ГДЕ МЫ (2029-12-31, старьё)
$H91_LINE
"
  h91_write_toy "$SCR/k5"
  h91_probe_run "$SCR/k5" --date "$H91_DATE"
  assert_uspeh k5 "$SCR/k5"
}

k6() {  # секция без завершающего LF (конец файла) — архив байт-в-байт, без дописывания
  h91_set_konform
  W_MARKERS=''; W_TAIL=''
  W_PREFIX="# Журнал сессий харнеса

"
  while :; do
    case "$W_SECTION" in
      *$'\n') W_SECTION="${W_SECTION%$'\n'}" ;;
      *) break ;;
    esac
  done
  h91_write_toy "$SCR/k6"
  h91_probe_run "$SCR/k6" --date "$H91_DATE"
  assert_uspeh k6 "$SCR/k6"
}

o1() {  # секции нет — именованный отказ, атомарно
  h91_set_konform
  W_SECTION=''
  h91_write_toy "$SCR/o1"
  atom_snimok "$SCR/o1"
  h91_probe_run "$SCR/o1" --date "$H91_DATE"
  assert_otkaz o1 "$SCR/o1" "$H91_OTKAZ_NOL"
}

o2() {  # две секции одновременно — именованный отказ (Н-209-гейт объёма)
  h91_set_konform
  h91_rnd_line
  W_SECTION="$W_SECTION## ГДЕ МЫ (дубль — вторая секция)
$H91_LINE
"
  h91_write_toy "$SCR/o2"
  atom_snimok "$SCR/o2"
  h91_probe_run "$SCR/o2" --date "$H91_DATE"
  assert_otkaz o2 "$SCR/o2" "$H91_OTKAZ_MANY"
}

o3() {  # итоговый HANDOFF 30721 байт — отказ «больше 30 КБ», атомарно
  h91_set_konform
  h91_markers_size $((H91_LIMIT + 1))
  h91_write_toy "$SCR/o3"
  atom_snimok "$SCR/o3"
  h91_probe_run "$SCR/o3" --date "$H91_DATE"
  assert_otkaz o3 "$SCR/o3" "$H91_OTKAZ_BIG"
}

o4() {  # итоговый ровно 30720 байт — успех (порог «больше», не «не меньше»)
  h91_set_konform
  h91_markers_size "$H91_LIMIT"
  h91_write_toy "$SCR/o4"
  h91_probe_run "$SCR/o4" --date "$H91_DATE"
  assert_uspeh o4 "$SCR/o4"
}

o5() {  # архив этого числа существует — отказ, существующее не тронуто
  h91_set_konform
  h91_rnd_line
  W_ARCH_EXIST='да'; W_ARCH_BYTES="старое содержимое архива: $H91_LINE
"
  h91_write_toy "$SCR/o5"
  atom_snimok "$SCR/o5"
  local archoj="$SCR/o5/$H91_ARCHDIR/$H91_DATE.md"
  local sha1; sha1="$(h91_sha "$archoj")"
  h91_probe_run "$SCR/o5" --date "$H91_DATE"
  assert_otkaz o5 "$SCR/o5" "${H91_OTKAZ_EXIST_PRE}$H91_ARCHDIR/$H91_DATE.md"
  [ "$(h91_sha "$archoj")" = "$sha1" ] || red_kletka o5 "существующий архив перезаписан"
}

o6() {  # --date вне грамматики — отказ
  h91_set_konform
  h91_write_toy "$SCR/o6"
  atom_snimok "$SCR/o6"
  h91_probe_run "$SCR/o6" --date 2030-1-1
  assert_otkaz o6 "$SCR/o6" "$H91_OTKAZ_DATE"
}

o7() {  # порядок проверок: нет секции + архив существует → «нет раздела» (3 < 4)
  h91_set_konform
  W_SECTION=''
  W_ARCH_EXIST='да'; W_ARCH_BYTES='старое содержимое архива
'
  h91_write_toy "$SCR/o7"
  atom_snimok "$SCR/o7"
  h91_probe_run "$SCR/o7" --date "$H91_DATE"
  assert_otkaz o7 "$SCR/o7" "$H91_OTKAZ_NOL"
}


sborka_dve_sekcii() {
  h91_set_konform
  h91_rnd_line
  W_SECTION="$W_SECTION## ГДЕ МЫ (дубль — вторая секция)
$H91_LINE
"
}

o8() {
  sborka_dve_sekcii
  h91_write_toy "$SCR/o8"
  atom_snimok "$SCR/o8"
  h91_probe_run "$SCR/o8" --date 2030-1-1
  assert_otkaz o8 "$SCR/o8" "$H91_OTKAZ_DATE"
}

o9() {  # HANDOFF.md нет — отказ, в toy ничего не создано
  rm -rf "$SCR/o9"; mkdir -p "$SCR/o9"
  h91_probe_run "$SCR/o9" --date "$H91_DATE"
  [ "$H91_RC" -eq 1 ] || { red_kletka o9 "rc=$H91_RC, ожидался 1"; return; }
  h91_err_has "$H91_OTKAZ_NET" || { red_kletka o9 "stderr без именованной строки"; return; }
  [ ! -e "$SCR/o9/$H91_ARCHDIR" ] || { red_kletka o9 "в пустом toy что-то создано"; return; }
  ok_kletka o9
}

o10() {  # порядок: архив существует + итог >30 КБ → «архив уже существует» (4 < 5)
  h91_set_konform
  h91_markers_size $((H91_LIMIT + 1))
  W_ARCH_EXIST='да'; W_ARCH_BYTES='старое содержимое архива
'
  h91_write_toy "$SCR/o10"
  atom_snimok "$SCR/o10"
  h91_probe_run "$SCR/o10" --date "$H91_DATE"
  assert_otkaz o10 "$SCR/o10" "${H91_OTKAZ_EXIST_PRE}$H91_ARCHDIR/$H91_DATE.md"
}

# ── запуск ─────────────────────────────────────────────────────────────────────────────
VSE=(k0 k1 k2 k3 k4 k5 k6 o1 o2 o3 o4 o5 o6 o7 o8 o9 o10)
if [ "$#" -gt 0 ]; then
  for c in "$@"; do
    case " ${VSE[*]} " in
      *" $c "*) "$c" ;;
      *) printf 'NOT_IMPLEMENTED: нет клетки %s\n' "$c" >&2; exit 2 ;;
    esac
  done
else
  for c in "${VSE[@]}"; do "$c"; done
fi
exit "$RED"
