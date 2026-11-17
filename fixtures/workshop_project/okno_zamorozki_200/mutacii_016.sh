#!/usr/bin/env bash
# Мутационное доказательство независимости эталона клетки m11 (закрытие блока
# К-08 вердикта Crit200V1b): сравнение субъекта с его собственной копией
# идемпотентно, поэтому для КАЖДОГО кейса семьи 016 здесь своя мутация
# СУЩЕСТВУЮЩЕЙ проверки двери scripts/check_contract_frozen.sh, меняющая исход
# этого кейса, — и прогон батареи 200 в режиме --repo с фильтром --cell m11 на
# одноразовой копии дерева с мутантом обязан красить m11 (субъект разошёлся с
# независимым эталоном golden_016). Якорь каждой мутации обязан встречаться в
# двери РОВНО один раз — иначе доказательство не строится (мера не врёт).
#
# Мутации — по одной строке существующей проверки, все ВНЕ целевого блока
# отбора окна (после реализации якоря остаются на месте):
#   1 imja_vne_grammatiki           отказ «объявление вне грамматики» → ok
#   2 izmenjon_bez_zamorozki        ветвление razrechen → всегда else
#   3 legkij_teg_rukoj              различение лёгкого тега → снято
#   4 predstojaschee_bez_accept     отказ «изменён без новой заморозки» → ok
#   5 predstojaschee_bez_razreshen  razreshil-отказ → всегда ok
#   6 chuzhoj_kontrakt_v_delte      чужой путь в дельте → не красит
#   7 predstojaschee_v_udercaniii   сравнение с удержанием → всегда равен
#   8 reestr_nedostupen             отказ недоступного реестра → снят
#   9 teg_rukoj_bez_verdikta        пустое тело вердикта → не отказ
#  10 verdikt_ne_accept             «первая строка != accept» → снят (мутация
#                                   критика из вердикта: минимум доказательства)
#
# Клон дерева ОДИН на весь прогон: мутации не трогают историю — перед каждой
# дверью рабочий файл двери восстанавливается из сохранённой исходной копии.
#
# Вызов: bash mutacii_016.sh [корень-дерева]   (по умолчанию — дерево батареи).
# Клон — одноразовый, вне ${TMPDIR:-/tmp}/dev-harness-verify (Н-85).
# Коды: 0 — все 10 мутаций красят m11; 1 — хоть одна прошла незамеченной либо
# якорь не уникален; 2 — нечем проверить. Скрипт не печатает PASS.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
ROOT="${1:-}"
if [ -z "$ROOT" ]; then ROOT="$(cd "$HERE/../../.." && pwd -P)"; fi
ROOT="$(cd "$ROOT" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не читается\n' >&2; exit 2; }

command -v git     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
command -v mktemp  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет mktemp\n' >&2; exit 2; }
[ -f "$ROOT/scripts/check_contract_frozen.sh" ] || { printf 'NOT_IMPLEMENTED: нет субъекта в %s\n' "$ROOT" >&2; exit 2; }

# Гигиена Н-85: унаследованные git-переменные подменяют предмет до первой команды.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

BASE="$(mktemp -d /tmp/dev-harness-m200.XXXXXX)" || exit 2
trap 'rm -rf "$BASE"' EXIT

KLON="$BASE/klon"
git clone -q --no-hardlinks "$ROOT" "$KLON" || { printf 'МУТАЦИЯ: клон не собран\n' >&2; exit 2; }
cp "$KLON/scripts/check_contract_frozen.sh" "$BASE/dver-isxodnaja.sh" \
  || { printf 'МУТАЦИЯ: исходная дверь не сохранена\n' >&2; exit 2; }

mut() {  # <кейс> <якорь> <замена> — мутирует дверь клона и гонит клетку m11; 0 = красная
  local name="$1" old="$2" new="$3" p rc
  p="$KLON/scripts/check_contract_frozen.sh"
  cp "$BASE/dver-isxodnaja.sh" "$p" || { printf 'МУТАЦИЯ %s: дверь не восстановлена\n' "$name" >&2; exit 2; }
  python3 - "$p" "$old" "$new" <<'PY' || exit 1
import sys
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding='utf-8') as f:
    text = f.read()
cnt = text.count(old)
if cnt != 1:
    sys.stderr.write('МУТАЦИЯ: якорь встречается %d раз, нужен ровно 1\n' % cnt)
    sys.exit(1)
with open(path, 'w', encoding='utf-8') as f:
    f.write(text.replace(old, new, 1))
PY
  env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_AUTHOR_DATE \
      -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL -u GIT_COMMITTER_DATE \
      bash "$HERE/red_okno_zamorozki_200.sh" --repo "$KLON" --cell m11 > "$BASE/$name.log" 2>&1
  rc=$?
  if grep -q '^FAIL m11' "$BASE/$name.log"; then
    printf 'МУТАЦИЯ 200: %s — m11 КРАСНАЯ (батарея rc %s)\n' "$name" "$rc"
    return 0
  fi
  printf 'МУТАЦИЯ 200: %s — m11 ЗЕЛЕНАЯ при rc %s: ДЕФЕКТ ОРАКУЛА (лог %s)\n' "$name" "$rc" "$BASE/$name.log"
  return 1
}

u01() { mut case_imja_vne_grammatiki \
  '    bad "объявление вне грамматики: $f — имя обязано быть NNN-<slug>.md (ровно три цифры, дефис, не-цифра)"' \
  '    ok "объявление вне грамматики: $f — имя обязано быть NNN-<slug>.md (ровно три цифры, дефис, не-цифра)"'; }
u02() { mut case_izmenjon_bez_zamorozki \
  '    if [ "$razrechen" -ne 1 ]; then' \
  '    if false; then'; }
u03() { mut case_legkij_teg_rukoj \
  '  if [ -n "$objtype" ] && [ "$objtype" != tag ]; then' \
  '  if false; then'; }
u04() { mut case_predstojaschee_bez_accept_verdikta \
  'bad "$f изменён без новой заморозки: на HEAD блоб $head_blob, в заморозке v$vmax — $tag_blob.' \
  'ok "$f изменён без новой заморозки: на HEAD блоб $head_blob, в заморозке v$vmax — $tag_blob.'; }
u05() { mut case_predstojaschee_bez_razreshenija \
  '        razreshil "$c" "$f" || { razrechen=0; break; }' \
  '        razreshil "$c" "$f" || true'; }
u06() { mut case_predstojaschee_chuzhoj_kontrakt_v_delte \
  '            contracts/*.md|plans/*.md) soglasno=0; chuzhoj="$df"; break ;;' \
  '            contracts/*.md|plans/*.md) ;;'; }
u07() { mut case_predstojaschee_v_udercaniii \
  '        if [ "$hold_blob" = "$head_blob" ]; then' \
  '        if true; then'; }
u08() { mut case_reestr_nedostupen \
  '  full|unknown-remote) ;;' \
  '  full|unknown-remote|*) ;;'; }
u09() { mut case_teg_rukoj_bez_verdikta \
  '    if [ -z "$body" ]; then' \
  '    if false; then'; }
u10() { mut case_verdikt_ne_accept \
  '      if [ "$first" != accept ]; then' \
  '      if false; then'; }

pojm=0; zivyh=0; vs=0
for u in u01 u02 u03 u04 u05 u06 u07 u08 u09 u10; do
  vs=$((vs + 1))
  if "$u"; then pojm=$((pojm + 1)); else zivyh=$((zivyh + 1)); fi
done

printf 'МУТАЦИИ 200: всего %d, красят m11 %d, зелёных %d\n' "$vs" "$pojm" "$zivyh"
[ "$vs" -eq 10 ] || { printf 'КРАСНОЕ 200-мутации: мутаций %d из 10 — таблица неполна\n' "$vs" >&2; exit 1; }
[ "$zivyh" -eq 0 ] || { printf 'КРАСНОЕ 200-мутации: незамеченных %d\n' "$zivyh" >&2; exit 1; }
exit 0
