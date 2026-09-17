#!/usr/bin/env bash
# Красное предъявление 6/6 контракта 028 (блокер 3 вердикта критика v1):
# миграция mv СОХРАНЯЕТ прежнее состояние — успех НОВОЙ сессии не доказывает
# сохранности прежних трейсов/agent.db и непрерывности --resume.
#
# ПРИВЯЗКА К ВЕТВЯМ КОДА (Н-39): ветка — блок разрешения ZONE (дефолт-формула
# с hash8-пинтом инварианта 1) + церемония миграции инварианта 5. Игрушка:
# одноразовый клон со СТАРОЙ раскладкой <клон>/.zones/dev/.omp/… (agent.db,
# трейс сессии с известным id, composer status.json) → ДО-манифест sha256 →
# церемония (mkdir -p РОДИТЕЛЯ назначения; стоп при существующем назначении;
# mv) → первый запуск workshop (PATH-подставной omp, объявлен здесь,
# прецедент А-156; живая сессия НЕ спавнится) → контроли.
#
# Честная реализация: ПОСЛЕ-mv-манифест байт-точно накрывает ДО (comm пуст);
# первый запуск пишет в мигрировавший корень: HOME подставного omp = корень
# байт-точно, корень ЕДИНСТВЕННЕН (грамматика hash8 лаунчера и церемонии едина
# — второй dev-дом не заводится); манифест путей ВСЕГО дерева клона не растёт;
# каждый путь ДО жив после первого запуска; ./workshop -r <id> доходит до exec
# с --resume <id> и внешним HOME — прежняя сессия продолжаема.
#
# СТАБ, который предъявление ловит: «mv + новый дом, старую историю потерять» —
# первый запуск пересоздаёт историю заново, прежние пути ДО исчезают/заменяются.
# Дефект наблюдаем РОВНО здесь: на входах 1–3 миграция не участвует вовсе.
# На игрушке shim-omp ничего не мутирует, потому байт-точность держится и
# ПОСЛЕ первого запуска — строже живого дерева (живой omp дописывает agent.db).
#
# Ожидание сегодня (ручки нет, дефолт уходит в дерево клона): rc 1 именованный.
# После предмета: rc 0. Коды: 0 — сохранность и непрерывность доказаны;
# 1 — именованный отказ пробы.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
[ -f "$REPO/workshop" ] || {
  printf 'ОТКАЗ: лаунчер отсутствует — workshop (клон неполон?)\n' >&2
  exit 1
}

WORK="$(mktemp -d /tmp/red028-migr.XXXXXX)"   # А-78: свежий WORK вне дерева
trap 'rm -rf "$WORK"' EXIT
fail() { printf 'ОТКАЗ %s: %s\n' "$1" "$2" >&2; exit 1; }

# ── игрушка: одноразовый клон со старой раскладкой сессии ────────────────────
KLON="$WORK/klon"
git clone -q "$REPO" "$KLON"
OLD_ID='02802808'
SESS="$KLON/.zones/dev/.omp/profiles/dev/agent/sessions/probe-slug"
mkdir -p "$SESS" "$KLON/.zones/dev/.omp/profiles/dev/agent" \
         "$KLON/.zones/dev/.omp/profiles/dev/cache/composer/abc123"
printf 'agentdb-probe-028\n'        > "$KLON/.zones/dev/.omp/profiles/dev/agent/agent.db"
printf '{"composer":"probe-028"}\n' > "$KLON/.zones/dev/.omp/profiles/dev/cache/composer/abc123/status.json"
printf '{"model":"probe/staraia-sessija"}\n' \
  > "$SESS/2026-01-01T00-00-00Z_${OLD_ID}0000-0000-0000-000000000000.jsonl"

# ДО-манифест (инвариант 5а): rc-проверяемо и НЕ пуст — пустой при непустой
# игрушке = красное (пустая выборка не зелёная).
( cd "$KLON/.zones/dev" && find . -type f -exec sha256sum {} + | LC_ALL=C sort ) > "$WORK/migr.do"
[ -s "$WORK/migr.do" ] || fail 'do-manifest-pust' 'манифест ДО пуст при непустой игрушке — съёмка сломана'

# ── церемония (инвариант 5б: mkdir -p РОДИТЕЛЯ назначения — совет 1 v1;
#    существующее назначение — стоп, слияние запрещено) ───────────────────────
CANON_KLON="$(cd "$KLON" && pwd -P)"
HASH8="$(printf '%s' "$CANON_KLON" | sha256sum | cut -c1-8)"
HOME0="$WORK/home"                        # внешний дом дефолт-формулы первого запуска
DST_PARENT="$HOME0/.local/state/dev-harness-sessions/$HASH8/zones"
mkdir -p "$DST_PARENT"
[ ! -e "$DST_PARENT/dev" ] \
  || fail 'naznachenie-suschestvuet' "$DST_PARENT/dev уже есть — церемония обязана остановиться (молчаливое слияние/перезапись запрещены)"
mv "$KLON/.zones/dev" "$DST_PARENT/dev"   # только mv, ничего не удаляется

# ПОСЛЕ-mv-ДО-первого-запуска (инвариант 5в): байт-точно накрывает ДО.
# Сортировка — ПОЛНАЯ строка (LC_ALL=C), как сравнивает comm: sort -k2 и comm
# расходятся на общих префиксах путей (совет к2 вердикта critic-028-v1).
( cd "$DST_PARENT/dev" && find . -type f -exec sha256sum {} + | LC_ALL=C sort ) > "$WORK/migr.p1"
POTERI="$(comm -23 "$WORK/migr.do" "$WORK/migr.p1" 2>"$WORK/comm-p1.err")"
COMM1_RC=$?
[ "$COMM1_RC" -eq 0 ] || fail 'comm-otkaz-p1' "comm -23 отказал rc=$COMM1_RC: $(cat "$WORK/comm-p1.err")"
[ ! -s "$WORK/comm-p1.err" ] || fail 'comm-nie-otsortirovan-p1' "вход comm не отсортирован его мерой: $(cat "$WORK/comm-p1.err") — сортировка манифеста обязана совпадать с полной строкой (совет к2)"
[ -z "$POTERI" ] || fail 'mv-poterjal-izmenil' "mv потерял/изменил файлы ДО:
$POTERI"

# ── первый запуск: дефолт-формула обязана вести в мигрировавший корень ──────
mkdir -p "$WORK/bin"
cat > "$WORK/bin/omp" <<'EOS'
#!/usr/bin/env bash
printf 'OMP_SHIM_RAN HOME=%s PWD=%s ARGS=%s\n' "$HOME" "$PWD" "$*" >> "${OMP_SHIM_LOG:?}"
exit 0
EOS
chmod +x "$WORK/bin/omp"

# Герметичность require_metering (workshop:115-133): непустых значений достаточно.
export ZAI_API_KEY=dummy-probe
export METERING_PROXY_URL=http://127.0.0.1:1
export METERING_PROXY_TOKEN=dummy-probe
export MINIMAX_API_KEY=dummy-probe
export OMP_SHIM_LOG="$WORK/omp-shim.log"

find "$KLON" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.do"
OUT="$WORK/out.log"
env -u HARNESS_SCRATCH -u XDG_STATE_HOME PATH="$WORK/bin:$PATH" HOME="$HOME0" \
  bash "$KLON/workshop" >"$OUT" 2>&1
RC=$?

WANT_HOME="$DST_PARENT/dev"

# 0. workshop дошёл до exec (вакуумная зелёность запрещена).
[ -f "$WORK/omp-shim.log" ] \
  || fail 'sessija-ne-doshla' "подставной omp не запущен (workshop rc=$RC) — предъявление вакуумно. Вывод: $(head -c 500 "$OUT")"

# 1. HOME подставного omp — мигрировавший корень, байт-точно.
SHIM_HOME="$(sed 's/^OMP_SHIM_RAN HOME=//' "$WORK/omp-shim.log" | head -1 | cut -d' ' -f1)"
[ "$SHIM_HOME" = "$WANT_HOME" ] \
  || fail 'home-ne-v-novom-korne' "omp увидел HOME=$SHIM_HOME, ожидан $WANT_HOME — дефолт-формула не ведёт в мигрировавший корень (расхождение грамматики hash8 лаунчера и церемонии)"

# 2. Манифест путей всего дерева клона не вырос.
find "$KLON" -printf '%y %p\n' | LC_ALL=C sort > "$WORK/tree.posle"
NOVY="$(comm -13 "$WORK/tree.do" "$WORK/tree.posle")"
[ -z "$NOVY" ] \
  || fail 'novye-puti-v-dereve' "дерево клона выросло после первого запуска: $NOVY — рантайм вернулся в судимое дерево"

# 3. Корень ЕДИНСТВЕННЕН: второй dev-дом не заводится (maxdepth 3 — сам корень
#    .../<hash8>/zones/dev; вложенные .omp/profiles/dev из старой раскладки
#    корнями не считаются).
KORNIA="$(find "$HOME0/.local/state/dev-harness-sessions" -maxdepth 3 -name dev -type d)"
[ "$KORNIA" = "$WANT_HOME" ] \
  || fail 'koren-ne-edinstven' "обнаружены корни: $KORNIA — ожидался ровно $WANT_HOME (грамматика hash8 разошлась между лаунчером и церемонией)"

# 4. Каждый путь ДО жив после первого запуска (инвариант 5г; shim не мутирует —
#    байт-точно, строже живого дерева).
( cd "$WANT_HOME" && find . -type f -exec sha256sum {} + | LC_ALL=C sort ) > "$WORK/migr.p2"
POTERI="$(comm -23 "$WORK/migr.do" "$WORK/migr.p2" 2>"$WORK/comm-p2.err")"
COMM2_RC=$?
[ "$COMM2_RC" -eq 0 ] || fail 'comm-otkaz-p2' "comm -23 отказал rc=$COMM2_RC: $(cat "$WORK/comm-p2.err")"
[ ! -s "$WORK/comm-p2.err" ] || fail 'comm-nie-otsortirovan-p2' "вход comm не отсортирован его мерой: $(cat "$WORK/comm-p2.err") — сортировка манифеста обязана совпадать с полной строкой (совет к2)"
[ -z "$POTERI" ] || fail 'pervyj-zapisk-stjor-izmenil' "после первого запуска утрачены/изменены файлы ДО (стаб «mv + новый дом, историю потерять»): $POTERI"

# 5. Непрерывность (инвариант 5д): прежняя сессия продолжаема — -r доходит до
#    exec, --resume <id> передан, HOME внешен, прежний трейс на месте.
rm -f "$WORK/omp-shim.log"
env -u HARNESS_SCRATCH -u XDG_STATE_HOME PATH="$WORK/bin:$PATH" HOME="$HOME0" \
  bash "$KLON/workshop" -r "$OLD_ID" >"$WORK/out-resume.log" 2>&1
RC2=$?
[ -f "$WORK/omp-shim.log" ] \
  || fail 'resume-ne-doshel' "продолжение не дошло до exec (rc=$RC2). Вывод: $(head -c 500 "$WORK/out-resume.log")"
RESUME_LINE="$(head -1 "$WORK/omp-shim.log")"
SHIM_HOME2="$(printf '%s\n' "$RESUME_LINE" | sed 's/^OMP_SHIM_RAN HOME=//' | cut -d' ' -f1)"
case " $RESUME_LINE " in
  *" --resume "$OLD_ID" "*) ;;
  *) fail 'resume-ne-peredan' "omp не получил --resume $OLD_ID: $RESUME_LINE" ;;
esac
[ "$SHIM_HOME2" = "$WANT_HOME" ] \
  || fail 'resume-home-ne-vneshnij' "продолжение видит HOME=$SHIM_HOME2 ≠ $WANT_HOME — стенограмма прежней сессии недостижима"
STARYJ_TREJS="$WANT_HOME/.omp/profiles/dev/agent/sessions/probe-slug/2026-01-01T00-00-00Z_${OLD_ID}0000-0000-0000-000000000000.jsonl"
[ -f "$STARYJ_TREJS" ] \
  || fail 'staryj-trejs-ischez' "трейс прежней сессии не найден в новом корне ($STARYJ_TREJS) — продолжение невозможно"

printf 'red_migratsija_sohrannost: mv байт-точно (%s файлов ДО), первый запуск в мигрировавший корень, дерево клона чисто, --resume %s передан с внешним HOME, прежний трейс жив\n' \
  "$(wc -l < "$WORK/migr.do" | tr -d ' ')" "$OLD_ID" >&2
exit 0
