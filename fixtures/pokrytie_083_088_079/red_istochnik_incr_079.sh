#!/usr/bin/env bash
# Семья 079, часть Р3: единый источник грамматики --incr (083, инв. И-6:
# «грамматика живёт в scripts/lib_incr.sh, чеки несут её побайтово через вызов
# библиотеки; переизобретение в каждом чеке — провал»). Дыра покрытия (аудит
# 079): И-клетки судят ПОВЕДЕНИЕ чеков на тою-копиях (переизобретатель,
# скопировавший грамматику на момент реализации, байт-в-байт проходит всё);
# И15 судит библиотеку НАПРЯМУЮ (драйвер source'ит lib_incr.sh, минуя чеки).
# Связка «чек → библиотека» не судима ни одной существующей клеткой.
#
# Использование: bash red_istochnik_incr_079.sh <корень> [Р3-источник …]
#   Р3-источник без аргументов клеток судит ВСЕ четыре чека.
# Коды: 0 — все судимые клетки зелёные; 1 — есть красная; 2 — нечем проверить.
#
# Метод (различимость по следованию, не по поведению; арбитраж 079): копия
# scripts/lib_incr.sh в тою-мире чека несёт РОДОВОЙ носитель (iii) — след
# входа в КАЖДУЮ функцию библиотеки — плюс ДВЕ побайтовых сверки формы
# независимыми прогонами (ровно одно вхождение носителя — проверяется
# кодом; прецедент подмены внутренних элементов библиотеки — стаб И15
# батареи ci_gen_083):
#   (iii) РОДОВОЙ след (арбитраж 079, замер: 16/16 мутантов): множество
#       функций читается из копии по якорю «^<имя>() {» ДО прогонов (ноль
#       найденных — rc 2, NOT_IMPLEMENTED-класс); в каждую функцию вшита
#       трассировка входа «printf FUNCNAME в файл-следа», путь — ЛИТЕРАЛОМ
#       в теле функции (check_zones/check_protected re-exec через env -i:
#       путь через переменную окружения не доживает). Два входа на чек:
#       кеш=HEAD (путь incr_parse → _incr_plural → … → incr_finish 0) и
#       кеш=invalid (путь incr_parse → incr_fail → exit 1). Зелёное ⇔
#       объединённый след содержит ВСЕ имена множества; отсутствующее имя —
#       именованный отказ «функция <имя> не вызвана честным путём» (на
#       честном прогоне без --check-sub — rc 2: функция недостижима
#       входами, дрейф библиотеки; тихого зелёного нет).
#   (i) маркер окна в incr_parse: «incr: %s судит» → «zond079: %s судит» —
#       честный чек (source библиотеки) печатает мутировавший маркер
#       самостоятельной строкой, исходной формы «incr: <имя> судит» в stderr НЕТ;
#   (ii) кеш-запись в incr_finish: «HEAD\n» → «HEAD\nzond079-finish\n» —
#       честный чек после rc 0 оставляет в кеш-файле вторую строку
#       «zond079-finish» (grep -Fxq, структурная сверка).
# Переизобретатель — частная копия грамматики ЛЮБОЙ функции библиотеки
# (перенаправленный source ИЛИ побайтовая копия функции ПОВЕРХ source) —
# не оставляет следа подменённой функции: красное поимённо по ней.
#
# PAK (стаб → клетка; дефект):
#   д6 → Р3-источник/<каждый чек> чек с ЧАСТНОЙ копией грамматики: source-строка
#     перенаправлена на lib_incr_private.sh (немутированную копию; sed по двум
#     живым формам: «$SELF_DIR/lib_incr.sh» у charter/zones,
#     «$(dirname "${BASH_SOURCE[0]}")/lib_incr.sh» у ids/protected; ноль замен —
#     rc 2 стаб-пака, не тихо). Наблюдаем на мутированном мире (i): маркер
#     «incr:» (частная грамматика) — пойман. Диффпроба: на немутированном мире
#     д6 ведёт себя как честный (rc 0, маркер «incr:»).
#   д6ф → Р3-источник/<каждый чек>/<функция>: чек source'ит живую библиотеку
#     (маркер следует мутации (i) — контроль встроен), НО несёт ЧАСТНУЮ
#     побайтовую копию ЛЮБОЙ функции lib_incr.sh (множество — по якорю
#     «^<имя>() {» из живой библиотеки), внедрённую сразу после
#     source-строки. Наблюдаем на носителе (iii): подменённая функция не
#     оставляет следа — красное поимённо ровно по ней. Диффпроба встроена:
#     прогон клетки начинается с немутированного входа (rc 0 + маркер), на
#     немутированной библиотеке побайтовая копия ведёт себя как честная;
#     стаб, ломающий честное поведение, даёт «вход недействителен», а не
#     поимённое красное.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$HERE/../..}" 2>/dev/null && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
shift || true
CHKSUB=""
kletki=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --check-sub) CHKSUB="$2"; shift 2 ;;   # стаб-пак: подменить чек тою-мира
    *) kletki+=("$1"); shift ;;
  esac
done

zavisimosti() { # <чек> → список зависимостей (формы живого дерева, grep-проверены)
  case "$1" in
    check_charter)   printf '%s\n' check_charter.sh next_id.sh lib_registry.sh lib_roles.sh ;;
    check_zones)     printf '%s\n' check_zones.sh next_id.sh lib_roles.sh lib_zones.sh lib_registry.sh ;;
    check_ids)       printf '%s\n' check_ids.sh next_id.sh lib_roles.sh lib_registry.sh ;;
    check_protected) printf '%s\n' check_protected.sh next_id.sh lib_roles.sh lib_registry.sh ;;
  esac
}

KRASNYH=0; ZELENYH=0
zeleno() { printf 'ЗЕЛЕНО: %s\n' "$1"; ZELENYH=$((ZELENYH+1)); }
krasno() { printf 'КРАСНО: %s\n' "$1"; KRASNYH=$((KRASNYH+1)); }
nado() { [ "${#kletki[@]}" -eq 0 ] || case " ${kletki[*]} " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
SCR="$(mktemp -d "${TMPDIR:-/tmp}/pokrytie079-incr.XXXXXX")" || exit 2
trap 'rm -rf -- "$SCR"' EXIT

mutiruj_lib() { # <lib-копия> — маркер окна «incr: %s судит» → «zond079: %s судит»
  python3 - "$1" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = "incr: %s судит %s..%s (%s)\\n"
assert s.count(old) == 1, f"строка-носитель маркера встречается {s.count(old)} раз(а), ждали 1"
open(p, 'w', encoding='utf-8').write(s.replace(old, "zond079: %s судит %s..%s (%s)\\n"))
PY
}

mutiruj_finish() { # <lib-копия> — кеш-запись incr_finish: «HEAD\n» → «HEAD\nzond079-finish\n»
  python3 - "$1" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = "if printf '%s\\n' \"$head\" > \"$tmp\" 2>/dev/null; then"
assert s.count(old) == 1, f"носитель кеш-записи incr_finish: {s.count(old)} вхождений, ждали 1"
new = "if printf '%s\\nzond079-finish\\n' \"$head\" > \"$tmp\" 2>/dev/null; then"
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY
}

mutiruj_sled() { # <lib-копия> <файл-следа> — родовой носитель (iii): в КАЖДУЮ функцию
  # копии вшить трассировку входа; строка-вставка собирается в bash и
  # передаётся python.argv — путь следа оказывается ЛИТЕРАЛОМ в теле
  # функции (check_zones/check_protected re-exec через env -i: путь через
  # переменную окружения не доживает; замер арбитража 079). Печатает
  # найденные имена (по одному в строке), оракул-множество — ДО прогонов;
  # ноль функций — ненулевой rc.
  local G2 vstavka
  G2='>'
  G2=$G2'>'
  vstavka="  printf '%s\n' \"\${FUNCNAME[0]}\" $G2 '$2'"
  python3 - "$1" "$vstavka" <<'PY'
import re, sys
lib_path, vstavka = sys.argv[1], sys.argv[2]
s = open(lib_path, encoding='utf-8').read()
pat = re.compile(r'^([a-zA-Z_][a-zA-Z0-9_]*)\(\) \{$')
names, out = [], []
for line in s.split('\n'):
    m = pat.match(line)
    if m:
        names.append(m.group(1))
        out.append(line)
        out.append(vstavka)
    else:
        out.append(line)
if not names:
    sys.exit('функции по якорю ^<имя>() { не найдены в %s' % lib_path)
open(lib_path, 'w', encoding='utf-8').write('\n'.join(out))
print('\n'.join(names))
PY
}

kletka_istochnik() { # <чек>
  local chk="$1" d dep
  d="$SCR/t-$chk"
  mkdir -p "$d/scripts"
  git -C "$d" init -q -b main || return 2
  printf 'toy\n' > "$d/README.md"
  git -C "$d" -c user.name=t -c user.email=t@t add -A
  git -C "$d" -c user.name=t -c user.email=t@t commit -qm c1
  printf 'toy2\n' >> "$d/README.md"
  git -C "$d" -c user.name=t -c user.email=t@t commit -qam c2
  while IFS= read -r dep; do
    [ -f "$ROOT/scripts/$dep" ] || { printf 'NOT_IMPLEMENTED: нет зависимости %s\n' "$dep" >&2; return 2; }
    cp -- "$ROOT/scripts/$dep" "$d/scripts/$dep"
  done < <(zavisimosti "$chk")
  [ -f "$ROOT/scripts/lib_incr.sh" ] || { printf 'NOT_IMPLEMENTED: нет lib_incr.sh\n' >&2; return 2; }
  cp -- "$ROOT/scripts/lib_incr.sh" "$d/scripts/lib_incr.sh"
  if [ "$chk" = check_charter ]; then
    cp -- "$ROOT/AGENTS.md" "$d/AGENTS.md" && cp -- "$ROOT/ROADMAP.md" "$d/ROADMAP.md" || return 2
    git -C "$d" -c user.name=t -c user.email=t@t add -A
    git -C "$d" -c user.name=t -c user.email=t@t commit -qm import
    git -C "$d" tag ustav/1 HEAD
    printf 'x\n' >> "$d/README.md"
    git -C "$d" -c user.name=t -c user.email=t@t commit -qam c3
  fi
  if [ "$chk" = check_zones ]; then
    # носитель (ii) наблюдаем только на ОСНОВНОМ пути чека: без замороженных
    # контрактов check_zones выходит ранним exit 0 БЕЗ вызова incr_finish
    # (честно — судить нечего). Замораживаем тою-контракт (прецедент
    # build_zones_toy viol=0, батарея 083): основной путь доходит до
    # incr_finish 0; правка после тега — внутри зоны, коммитивы — toy
    mkdir -p "$d/contracts"
    printf '# toy contract\n\nЗОНА toy: contracts/090-demo.md\n' > "$d/contracts/090-demo.md"
    git -C "$d" -c user.name=toy -c user.email=toy@t add -A
    git -C "$d" -c user.name=toy -c user.email=toy@t commit -qm zones-import
    git -C "$d" tag frozen/contracts/090/1
    printf ' v2\n' >> "$d/contracts/090-demo.md"
    git -C "$d" -c user.name=toy -c user.email=toy@t commit -qam zones-c2
  fi
  if [ -n "$CHKSUB" ]; then
    if [ -d "$CHKSUB" ]; then cp -- "$CHKSUB"/* "$d/scripts/" || return 2
    else cp -- "$CHKSUB" "$d/scripts/$chk.sh"; fi
  fi
  # кеш = HEAD тою, запуск ИЗ КОРНЯ тою (норма самих чеков: INCR_GIT_ROOT от cwd)
  local h err rc
  h="$(git -C "$d" rev-parse HEAD)"
  printf '%s\n' "$h" > "$SCR/$chk.cache"
  err="$(cd "$d" && bash "scripts/$chk.sh" --incr "$SCR/$chk.cache" . 2>&1 >/dev/null)"; rc=$?
  if [ "$rc" -ne 0 ] || ! grep -Fq "incr: $chk судит" <<<"$err"; then
    krasno "Р3-источник/$chk: вход недействителен (без мутации ждали rc 0 + маркер «incr: $chk судит»): rc=$rc: $err"
    return 0
  fi
  # мутация библиотеки — честный чек обязан СЛЕДОВАТЬ
  mutiruj_lib "$d/scripts/lib_incr.sh" || { printf 'NOT_IMPLEMENTED: носитель маркера не найден в lib_incr.sh\n' >&2; return 2; }
  printf '%s\n' "$h" > "$SCR/$chk.cache2"
  err="$(cd "$d" && bash "scripts/$chk.sh" --incr "$SCR/$chk.cache2" . 2>&1 >/dev/null)"; rc=$?
  if grep -Fq "zond079: $chk судит" <<<"$err" && ! grep -Fq "incr: $chk судит" <<<"$err"; then
    zeleno "Р3-источник/$chk: маркер СЛЕДУЕТ мутации lib_incr.sh (грамматика — из библиотеки, не частная)"
  else
    krasno "Р3-источник/$chk: маркер НЕ следовал мутации lib_incr.sh — переизобретение грамматики (rc=$rc): $err"
  fi
  # вторая независимая мутация — кеш-запись финализатора (носитель (ii)):
  # библиотека восстанавливается из корня, мутируется ТОЛЬКО incr_finish;
  # честный чек после rc 0 обязан оставить в кеш-файле вторую строку
  # «zond079-finish» (частная копия финализатора пишет исходную форму)
  cp -- "$ROOT/scripts/lib_incr.sh" "$d/scripts/lib_incr.sh"
  mutiruj_finish "$d/scripts/lib_incr.sh" || { printf 'NOT_IMPLEMENTED: носитель кеш-записи не найден в lib_incr.sh\n' >&2; return 2; }
  printf '%s\n' "$h" > "$SCR/$chk.cache3"
  (cd "$d" && bash "scripts/$chk.sh" --incr "$SCR/$chk.cache3" . >/dev/null 2>&1); rc=$?
  if [ "$rc" -eq 0 ] && grep -Fxq 'zond079-finish' "$SCR/$chk.cache3"; then
    zeleno "Р3-источник/$chk/финиш: кеш-запись СЛЕДУЕТ мутации incr_finish (финализатор — из библиотеки, не частная копия)"
  else
    krasno "Р3-источник/$chk/финиш: кеш-запись НЕ следовала мутации incr_finish — частная копия финализатора (rc=$rc, кеш: $(tr '\n' '|' < "$SCR/$chk.cache3"))"
  fi
  # третья мутация — РОДОВОЙ носитель (iii, арбитраж 079): след входа в
  # КАЖДУЮ функцию библиотеки. Множество имён снимается из копии ДО
  # прогонов (оракул — в памяти клетки), ноль функций — rc 2. Два входа:
  # кеш=HEAD (rc 0 — путь до incr_finish 0) и кеш=invalid (rc 1 — путь до
  # incr_fail). Зелёное ⇔ объединённый след содержит ВСЕ имена; на честном
  # прогоне (без --check-sub) отсутствующее имя — rc 2 (недостижимость =
  # дрейф библиотеки), подставному чеку — именованное красное поимённо.
  cp -- "$ROOT/scripts/lib_incr.sh" "$d/scripts/lib_incr.sh"
  local sled fns fn propali
  sled="$SCR/$chk.trace"
  rm -f -- "$sled"
  fns="$(mutiruj_sled "$d/scripts/lib_incr.sh" "$sled")" || { printf 'NOT_IMPLEMENTED: функции по якорю ^<имя>() { не найдены в lib_incr.sh\n' >&2; return 2; }
  printf '%s\n' "$h" >"$SCR/$chk.cache4"
  (cd "$d" && bash "scripts/$chk.sh" --incr "$SCR/$chk.cache4" . >/dev/null 2>&1); rc=$?
  [ "$rc" -eq 0 ] || { printf 'NOT_IMPLEMENTED: Р3-источник/%s/след: честный чек (кеш=HEAD) дал rc=%d, ждали 0 — мир сломан\n' "$chk" "$rc" >&2; return 2; }
  printf 'ne-sha-079\n' >"$SCR/$chk.cache5"
  (cd "$d" && bash "scripts/$chk.sh" --incr "$SCR/$chk.cache5" . >/dev/null 2>&1); rc=$?
  [ "$rc" -eq 1 ] || { printf 'NOT_IMPLEMENTED: Р3-источник/%s/след: честный чек (кеш=invalid) дал rc=%d, ждали 1 — мир сломан\n' "$chk" "$rc" >&2; return 2; }
  propali=""
  while IFS= read -r fn; do
    grep -Fxq -- "$fn" "$sled" || propali="${propali:+$propali }$fn"
  done <<<"$fns"
  if [ -z "$propali" ]; then
    zeleno "Р3-источник/$chk/след: объединённый след (кеш=HEAD ∪ кеш=invalid) содержит все $(printf '%s\n' "$fns" | grep -c .) функций lib_incr.sh"
  elif [ -z "$CHKSUB" ]; then
    printf 'NOT_IMPLEMENTED: Р3-источник/%s/след: функция %s не вызвана честным путём на честном прогоне — недостижима входами (дрейф lib_incr.sh)\n' "$chk" "$propali" >&2
    return 2
  else
    for fn in $propali; do
      krasno "Р3-источник/$chk/след: функция $fn не вызвана честным путём — грамматика из частной копии, не из lib_incr.sh (след: $(tr '\n' ' ' <"$sled" 2>/dev/null))"
    done
  fi
}

declined=0
for chk in check_charter check_zones check_ids check_protected; do
  if nado "Р3-источник/$chk"; then
    kletka_istochnik "$chk"; rc_k="$?"
    [ "$rc_k" -eq 2 ] && declined=1
  fi
done

printf 'red_istochnik_incr_079.sh: зелёных %d, красных %d\n' "$ZELENYH" "$KRASNYH"
[ "$KRASNYH" -eq 0 ] || exit 1
[ "$declined" -eq 0 ] || exit 2
[ "$ZELENYH" -gt 0 ] || exit 2
exit 0
