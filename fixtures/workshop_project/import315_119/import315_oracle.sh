#!/usr/bin/env bash
# Контракт 119 — ОРАКУЛ импорта 3.15 (круг 2, усилен по Б1–Б5 вердикта критика
# круга 1): судит репозиторий Complior-back (или мини-мир той же раскладки) по
# инвариантам аддитивного слияния. Единый источник грамматики — дерево
# проверяемого + его git-история (база = родитель коммита, впервые добавившего
# docs/sources/backend-3.15/core.openapi.yaml) и ПИН состава pin_315.json рядом
# с оракулом (зона architect, implementer изменить не может).
# Поведенческие пробы (Б2): генератор/валидатор проверяются НА РАЗЛИЧАЮЩИХ
# входах в одноразовых локальных клонах (запись только в TMPDIR-клонах).
# Оракул ТОЛЬКО ЧИТАЕТ проверяемый репозиторий (кроме вызова продуктового
# генератора --check, который по норме сух); все сверки — в mktemp TMPDIR.
# Выход: 0 — IMPORT315_OK; 1 — ОТКАЗ: import315: <причина>; 2 — неправильный
# вызов либо NEEDS_ENV (среда не позволяет судить: пакет npm, нужный
# gen-contracts.js судимого дерева, не разрешается, или нет PyYAML — Rev119v2
# Б-1; это не причина продукта). Алфавит причин замкнут (34; v2 расширила
# 26 → 32 ветвями spec-3.14 смешанных профилей и производных app/schemas;
# круг 2 v2 — 33-я, schemas-proekcija; круг 4 — 34-я, dokument-ne-sliyanie:
# структурное равенство published слиянию по арбитражу
# 119-impl-struktura-dokumenta, заменило причину маршрута вердикта Adv119v2):
#   import-otsutstvuet raskladka-vtoroj-koren raskladka-istochniki
#   struktura-policy core-zamenen additivnost-cas additivnost-operacija
#   additivnost-reasoncode poterya-consumer sql-izmenen vs01-otkatan
#   status-nechestnyj rashodenie-operacij owners-rashozhdenie
#   manifest-rashozhdenie files-sha256-rashozhdenie generator-bez-check
#   vosproizvodimost validator-kreven known-issues-nepolnyj istorika-podmenena
#   sostav-rashozhdenie generator-noop validator-noop generator-ne-pishet
#   known-failures-nepust spec314-kreven spec314-noop schemas-rashozhdenie
#   gencontracts-rashozhdenie gencontracts-noop gencontracts-ne-pishet
#   schemas-proekcija dokument-ne-sliyanie
REPO="${1:-}"
[ -n "$REPO" ] || { echo "использование: import315_oracle.sh <корень репозитория>" >&2; exit 2; }
[ -d "$REPO/.git" ] || [ -f "$REPO/.git" ] || { echo "ОТКАЗ: import315: ne-git-repo" >&2; exit 2; }
cd "$REPO" || exit 2
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PIN="$HERE/pin_315.json"
fail() { echo "ОТКАЗ: import315: $1" >&2; exit 1; }
# Б-1 (Rev119v2): вывод node → имя НЕРАЗРЕШЁННОГО пакета npm (голый
# спецификатор: CJS «Cannot find module 'x'», ESM «Cannot find package 'x'»);
# относительный/абсолютный путь — дефект продукта, а не среды
npm_miss() {
  printf '%s\n' "$1" | sed -n \
    -e "s/^Error: Cannot find module '\([^./'][^']*\)'.*/\1/p" \
    -e "s/^Error \[ERR_MODULE_NOT_FOUND\]: Cannot find package '\([^']*\)' imported from .*/\1/p" \
    | sed -n 1p
}
# gen-contracts.js в каталоге $1 (далее — его аргументы); неразрешённый пакет
# npm = суд невозможен в этой среде → rc 2 NEEDS_ENV, не gencontracts-* (Б-1)
gc() {
  local dir="$1" out rc miss; shift
  out="$(cd "$dir" && node tests/tools/gen-contracts.js "$@" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ]; then
    miss="$(npm_miss "$out")"
    [ -z "$miss" ] || { echo "NEEDS_ENV: import315: npm-paket-nedostupen $miss (npm-дерево судимого дерева: npm ci либо NODE_PATH)" >&2; exit 2; }
  fi
  return "$rc"
}
PUB=docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml
BIND=docs/contracts/frontend-consumer-bindings.json
SRC315=docs/sources/backend-3.15
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/import315-oracle-XXXXXX")"

[ -f "$SRC315/core.openapi.yaml" ] && [ -f "$SRC315/platform-extension.yaml" ] \
  || fail import-otsutstvuet
[ ! -e Complior_Backend_v3_15 ] || fail raskladka-vtoroj-koren
for f in "$SRC315/baseline-lock.json" "$SRC315/new-consumers.json" \
         "$SRC315/declared-counts.json" "$SRC315/provenance/nasha_5_8_4.sha256" \
         "$SRC315/provenance/KNOWN-ISSUES-DECLARED.json" \
         docs/plans/delivery-plan-3.15.json docs/data/physical-model.json; do
  [ -f "$f" ] || fail raskladka-istochniki
done
grep -q 'tests/spec-3.15/' structure-policy.json || fail struktura-policy

# ── ПИН состава (Б1): ожидание НЕЗАВИСИМО от проверяемого дерева ────────────
# запись пина выбирается по sha256 базового published из git-истории;
# неизвестная оракулу база или расхождение состава = sostav-rashozhdenie.
[ -f "$PIN" ] || { echo "ОТКАЗ: import315: pin-otsutstvuet (батарея повреждена)" >&2; exit 2; }
ADDCORE="$(git log --format=%H --diff-filter=A -1 -- "$SRC315/core.openapi.yaml")"
[ -n "$ADDCORE" ] || fail core-zamenen
BASE="${ADDCORE}^"
git show "$BASE:$PUB" > "$SCRATCH/base_published.yaml" 2>/dev/null || fail core-zamenen
BASE_SHA="$(sha256sum "$SCRATCH/base_published.yaml" | cut -d' ' -f1)"
pin() { jq -r --arg s "$BASE_SHA" --arg k "$1" \
  '.entries[] | select(.base_published_sha256==$s) | getpath($k|split(".")) | if .==null then "" else tostring end' "$PIN"; }
PIN_SCOPE="$(pin scope)"
[ -n "$PIN_SCOPE" ] || fail sostav-rashozhdenie
PIN_COMMIT="$(pin base_git_commit)"
if [ -n "$PIN_COMMIT" ]; then
  [ "$(git rev-parse "$BASE")" = "$PIN_COMMIT" ] || fail sostav-rashozhdenie
fi
PIN_NEW_OPS="$(pin new_ops)"; PIN_NEW_SCH="$(pin new_schemas)"
PIN_NEW_CON="$(pin new_consumers)"; PIN_TABLES="$(pin physical_tables)"
PIN_EXT_SHA="$(pin extension_sha256)"; PIN_PLATFORM="$(pin platform_component)"
PIN_RUNTIME="$(pin runtime_status_new)"

# канонические записи потребителей (инфраструктура сверки, вне сентинелов:
# контрмодель без блока аддитивности продолжает считать состав по пину)
git show "$BASE:$BIND" | jq -Sc '.workflow_consumers[]' | LC_ALL=C sort > "$SCRATCH/base_recs"
jq -Sc '.workflow_consumers[]' "$BIND" | LC_ALL=C sort > "$SCRATCH/cur_recs"
LC_ALL=C comm -13 "$SCRATCH/base_recs" "$SCRATCH/cur_recs" > "$SCRATCH/new_recs"
 # ── ADDITIV-315-BEG: аддитивность против git-базы ───────────────────────────
[ "$(sha256sum "$SRC315/core.openapi.yaml" | cut -d' ' -f1)" = "$BASE_SHA" ] \
  || fail core-zamenen
for op in $(grep -o 'operationId: [A-Za-z0-9_]*' "$SCRATCH/base_published.yaml" | awk '{print $2}'); do
  awk -v o="$op" '$0 ~ "operationId: "o"$" {f=1; next} /operationId: /{f=0} /^components:/{f=0} /^  \//{f=0} f' "$SCRATCH/base_published.yaml" > "$SCRATCH/op_base.txt"
  awk -v o="$op" '$0 ~ "operationId: "o"$" {f=1; next} /operationId: /{f=0} /^components:/{f=0} /^  \//{f=0} f' "$PUB" > "$SCRATCH/op_cur.txt"
  cmp -s "$SCRATCH/op_base.txt" "$SCRATCH/op_cur.txt" && continue
  if grep -q 'If-Match' "$SCRATCH/op_base.txt"; then fail additivnost-cas; fi
  fail additivnost-operacija
done
awk '/^    ReasonCode:/{f=1;next} /^    [A-Za-z]/{f=0} f' "$SCRATCH/base_published.yaml" | sed '/^$/d' > "$SCRATCH/rc_base.txt"
awk '/^    ReasonCode:/{f=1;next} /^    [A-Za-z]/{f=0} f' "$PUB" | sed '/^$/d' > "$SCRATCH/rc_cur.txt"
cmp -s "$SCRATCH/rc_base.txt" "$SCRATCH/rc_cur.txt" || fail additivnost-reasoncode
# идентичность потребителей (Б3): каноническая запись целиком (значимые поля
# operation_id/adoption_status/... — id у 50 из 53 реальных записей нет),
# мультимножества id недостаточно; базовые projections index сохраняются.
LC_ALL=C comm -23 "$SCRATCH/base_recs" "$SCRATCH/cur_recs" | grep -q . && fail poterya-consumer
while IFS= read -r rec; do
  [ -n "$rec" ] || continue
  ok="$(echo "$rec" | jq -r --arg rt "$PIN_RUNTIME" '
    ((.action_id==null) and
     (.binding_status=="AWAITING_FRONTEND_ACTION_ID" or .binding_status=="INTERNAL_SERVICE") and
     (.runtime_status==$rt) and
     ((.adoption_status // "")!="confirmed_5_8_4"))')"
  [ "$ok" = true ] || fail status-nechestnyj
done < "$SCRATCH/new_recs"
if git cat-file -e "$BASE:docs/contracts/operation-index.json" 2>/dev/null; then
  [ -f docs/contracts/operation-index.json ] || fail poterya-consumer
  git show "$BASE:docs/contracts/operation-index.json" \
    | jq -Sc '.operations[] | {operation_id, consumers}' | LC_ALL=C sort > "$SCRATCH/base_proj"
  jq -Sc '.operations[] | {operation_id, consumers}' docs/contracts/operation-index.json \
    | LC_ALL=C sort > "$SCRATCH/cur_proj"
  LC_ALL=C comm -23 "$SCRATCH/base_proj" "$SCRATCH/cur_proj" | grep -q . && fail poterya-consumer
fi
[ -z "$(git diff --name-only --diff-filter=MD "$BASE" -- migrations/)" ] || fail sql-izmenen
CUR_VS01="$(jq -r '.vs01_spec_freeze.sha256 // empty' docs/VERSION_MANIFEST.json)"
BASE_VS01="$(git show "$BASE:docs/VERSION_MANIFEST.json" | jq -r '.vs01_spec_freeze.sha256 // empty')"
[ "$CUR_VS01" = "$BASE_VS01" ] || fail vs01-otkatan
# ── ADDITIV-315-END ─────────────────────────────────────────────────────────

# ── состав против ПИНА (Б1): числа/хэши не читаются из проверяемого дерева ──
BASE_OPS="$(grep -c 'operationId:' "$SCRATCH/base_published.yaml")"
CUR_OPS="$(grep -c 'operationId:' "$PUB")"
[ "$CUR_OPS" -eq $((BASE_OPS + PIN_NEW_OPS)) ] || fail rashodenie-operacij
BASE_SCH="$(awk '/^  schemas:/{f=1;next} /^  [A-Za-z]/{f=0} f && /^    [A-Za-z0-9_]+:/{n++} END{print n+0}' "$SCRATCH/base_published.yaml")"
CUR_SCH="$(awk '/^  schemas:/{f=1;next} /^  [A-Za-z]/{f=0} f && /^    [A-Za-z0-9_]+:/{n++} END{print n+0}' "$PUB")"
[ "$CUR_SCH" -eq $((BASE_SCH + PIN_NEW_SCH)) ] || fail sostav-rashozhdenie
NEW_CON_N="$(grep -c . "$SCRATCH/new_recs")"
[ "$NEW_CON_N" -eq "$PIN_NEW_CON" ] || fail sostav-rashozhdenie
[ "$(sha256sum "$SRC315/platform-extension.yaml" | cut -d' ' -f1)" = "$PIN_EXT_SHA" ] \
  || fail sostav-rashozhdenie
grep -Eq "^    ${PIN_PLATFORM}:" "$SRC315/platform-extension.yaml" || fail sostav-rashozhdenie
dc_new_ops="$(jq -r '.new_ops // ""' "$SRC315/declared-counts.json")"
dc_new_con="$(jq -r '.new_consumers // ""' "$SRC315/declared-counts.json")"
dc_owners="$(jq -r '.owners // ""' "$SRC315/declared-counts.json")"
{ [ "$dc_new_ops" = "$PIN_NEW_OPS" ] && [ "$dc_new_con" = "$PIN_NEW_CON" ] \
  && [ "$dc_owners" = "$PIN_TABLES" ]; } || fail sostav-rashozhdenie
CUR_HIST="$(jq -Sc '[.workflow_consumers[] | select(.binding_status!=null)] | group_by(.binding_status) | map({(.[0].binding_status):length}) | add' "$BIND")"
PIN_HIST="$(jq -Sc --arg s "$BASE_SHA" '.entries[] | select(.base_published_sha256==$s) | .binding_status_new' "$PIN")"
[ "$CUR_HIST" = "$PIN_HIST" ] || fail sostav-rashozhdenie
CUR_TABLES="$(jq '.tables | length' docs/data/physical-model.json)"
[ "$CUR_TABLES" = "$PIN_TABLES" ] || fail owners-rashozhdenie
[ "$(jq -r '.compatibility_baseline // ""' "$SRC315/baseline-lock.json")" = "5.8.4" ] \
  || fail sostav-rashozhdenie
# ── STRUKTURA-315-BEG: published = merge(ядро, extension) структурно ───────
# Арбитраж 119-impl-struktura-dokumenta, Решение 1 (закрытый перечень П-1…П-7):
# ОДНА сверка всего документа после yaml.safe_load, независимая от писателя и
# валидатора продукта. Ядро — базовый published git-базы (то же основание,
# что у поблочной сверки аддитивности), extension — источник (sha по пину —
# выше). П-1 корень (все ключи, кроме paths/components) = корню ядра; П-2
# множество path items = ядро ∪ extension, пересечение пусто; П-6 у каждой
# операции есть operationId, повторов нет; П-3 path item ядра = ядру целиком;
# П-4 path item extension = источнику целиком после снятия ЕДИНСТВЕННОЙ
# денормализации — маркера x-supported-contract-versions == [info.version
# extension], обязательного у каждой операции extension; П-5 components:
# секции и элементы — только из ядра либо extension, равны своему источнику.
# Равенство строгое: тип узла, ключи, длина и порядок последовательностей,
# значения. П-7: первое расхождение — строкой «адрес: <путь в документе>» в
# stderr, причина одна. python3+PyYAML — уже зависимость батареи; без него
# rc 2 NEEDS_ENV (Б-1). Интерпретатор стартует в scratch оракула (sys.path[0]
# = каталог запуска): модуль судимого дерева (yaml.py в корне) не подменяет
# парсер сверки.
( cd "$SCRATCH" && python3 - base_published.yaml "$OLDPWD/$SRC315/platform-extension.yaml" "$OLDPWD/$PUB" <<'PY'
import sys
try:
    import yaml
except ImportError:
    print('NEEDS_ENV: import315: python3-yaml-nedostupen (PyYAML)', file=sys.stderr)
    sys.exit(2)
METHODS = ('get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace')
MARK = 'x-supported-contract-versions'


def stop(at, why):
    addr = ''
    for part in at:
        addr += part if part.startswith('[') else ('.' if addr else '') + part
    print('адрес: %s' % (addr or '<документ>'), file=sys.stderr)
    print('dokument-ne-sliyanie: %s' % why, file=sys.stderr)
    sys.exit(1)


def diff(act, exp, at):
    # первый узел act, отличный от exp: в порядке published, затем недостающие
    if type(act) is not type(exp):
        return at
    if isinstance(act, dict):
        ek = {(type(k), k): k for k in exp}
        ak = {(type(k), k): k for k in act}
        for t, k in ak.items():
            if t not in ek:
                return at + [str(k)]
            d = diff(act[k], exp[ek[t]], at + [str(k)])
            if d is not None:
                return d
        for t, k in ek.items():
            if t not in ak:
                return at + [str(k)]
        return None
    if isinstance(act, list):
        for i, (a, e) in enumerate(zip(act, exp)):
            d = diff(a, e, at + ['[%d]' % i])
            if d is not None:
                return d
        return None if len(act) == len(exp) else at + ['[%d]' % min(len(act), len(exp))]
    return None if act == exp or (act != act and exp != exp) else at


def load(path):
    with open(path, encoding='utf-8') as f:
        return yaml.safe_load(f)


core, ext = load(sys.argv[1]), load(sys.argv[2])
try:
    pub = load(sys.argv[3])
except yaml.YAMLError as e:
    stop([], 'published не разбирается как YAML (%s)' % str(e).split('\n')[0])
if not isinstance(pub, dict):
    stop([], 'published — не отображение')
# П-1 корень документа
NODE = ('paths', 'components')
d = diff({k: v for k, v in pub.items() if k not in NODE},
         {k: v for k, v in core.items() if k not in NODE}, [])
if d is not None:
    stop(d, 'П-1 корень документа ≠ корню ядра')
# П-2 множество path items
cp, ep, pp = core.get('paths') or {}, ext.get('paths') or {}, pub.get('paths')
if not isinstance(pp, dict):
    stop(['paths'], 'П-2 paths — не отображение')
for p in cp:
    if p in ep:
        stop(['paths', str(p)], 'П-2 path и в ядре, и в extension (коллизия)')
for p in pp:
    if p not in cp and p not in ep:
        stop(['paths', str(p)], 'П-2 path не из ядра и не из extension')
for p in list(cp) + list(ep):
    if p not in pp:
        stop(['paths', str(p)], 'П-2 path источника потерян')
# П-6 операция без operationId; кратность operationId
seen = {}
for p, item in pp.items():
    if not isinstance(item, dict):
        continue  # узел целиком сравнивают П-3/П-4
    for m in METHODS:
        if m not in item:
            continue
        op = item[m]
        if not isinstance(op, dict) or 'operationId' not in op:
            stop(['paths', str(p), m, 'operationId'], 'П-6 операция без operationId')
        key = (type(op['operationId']), repr(op['operationId']))
        if key in seen:
            stop(['paths', str(p), m, 'operationId'],
                 'П-6 operationId повторён (первый: %s %s)' % seen[key])
        seen[key] = (p, m)
# П-3/П-4 path item целиком — в порядке published
want = [(ext.get('info') or {}).get('version')]
for p, item in pp.items():
    if p in cp:
        d = diff(item, cp[p], ['paths', str(p)])
        if d is not None:
            stop(d, 'П-3 path item ядра ≠ ядру')
        continue
    if isinstance(item, dict):
        item = dict(item)
        for m in METHODS:
            if m not in item:
                continue
            op = item[m]
            if not isinstance(op, dict) or MARK not in op:
                stop(['paths', str(p), m, MARK], 'П-4 нет маркера профиля extension')
            d = diff(op[MARK], want, ['paths', str(p), m, MARK])
            if d is not None:
                stop(d, 'П-4 маркер профиля ≠ %r' % (want,))
            item[m] = {k: v for k, v in op.items() if k != MARK}
    d = diff(item, ep[p], ['paths', str(p)])
    if d is not None:
        stop(d, 'П-4 path item extension ≠ источнику (маркер снят)')
# П-5 components
cc, ec, pc = core.get('components') or {}, ext.get('components') or {}, pub.get('components')
if pc is None and not cc and not ec:
    pc = {}
if not isinstance(pc, dict):
    stop(['components'], 'П-5 components — не отображение')
for s, sec in pc.items():
    if s not in cc and s not in ec:
        stop(['components', str(s)], 'П-5 секция не из ядра и не из extension')
    if not isinstance(sec, dict):
        stop(['components', str(s)], 'П-5 секция — не отображение')
    srcs = [x for x in (cc.get(s), ec.get(s)) if x is not None]
    for k, v in sec.items():
        own = [x for x in srcs if k in x]
        if not own:
            stop(['components', str(s), str(k)], 'П-5 элемент не из ядра и не из extension')
        for x in own:
            d = diff(v, x[k], ['components', str(s), str(k)])
            if d is not None:
                stop(d, 'П-5 элемент ≠ своему источнику')
    for x in srcs:
        for k in x:
            if k not in sec:
                stop(['components', str(s), str(k)], 'П-5 элемент источника потерян')
for s in list(cc) + list(ec):
    if s not in pc:
        stop(['components', str(s)], 'П-5 секция источника потеряна')
PY
)
case $? in 0) ;; 2) exit 2 ;; *) fail dokument-ne-sliyanie ;; esac
# ── STRUKTURA-315-END ───────────────────────────────────────────────────────

MAN_OPS="$(jq -r '.operations' docs/VERSION_MANIFEST.json)"
MAN_SCH="$(jq -r '.schemas' docs/VERSION_MANIFEST.json)"
MAN_CON="$(jq -r '.consumers' docs/VERSION_MANIFEST.json)"
CUR_CON="$(jq '.workflow_consumers | length' "$BIND")"
{ [ "$MAN_OPS" = "$CUR_OPS" ] && [ "$MAN_SCH" = "$CUR_SCH" ] && [ "$MAN_CON" = "$CUR_CON" ]; } \
  || fail manifest-rashozhdenie
while IFS= read -r rf; do [ -e "$rf" ] || fail manifest-rashozhdenie; done < <(jq -r '.required_files[]' docs/VERSION_MANIFEST.json)

git ls-files --cached --others --exclude-standard | grep -v '^FILES.sha256$' \
  | while IFS= read -r p; do [ -f "$p" ] && printf '%s\n' "$p"; done | LC_ALL=C sort > "$SCRATCH/live_paths"
sed 's/^[0-9a-f]\{64\}  //' FILES.sha256 | LC_ALL=C sort > "$SCRATCH/manifest_paths"
diff -q "$SCRATCH/live_paths" "$SCRATCH/manifest_paths" >/dev/null || fail files-sha256-rashozhdenie
while read -r sha path; do
  [ "$(sha256sum "$path" 2>/dev/null | cut -d' ' -f1)" = "$sha" ] || fail files-sha256-rashozhdenie
done < FILES.sha256

tree_hash() { find . -path ./.git -prune -o -type f -print | LC_ALL=C sort | xargs sha256sum 2>/dev/null | sha256sum | cut -d' ' -f1; }
TH_BEFORE="$(tree_hash)"
GEN_OUT="$(python3 tests/tools/generate_derived.py --check 2>&1)"; GEN_RC=$?
TH_AFTER="$(tree_hash)"
[ "$TH_BEFORE" = "$TH_AFTER" ] || fail vosproizvodimost
if [ "$GEN_RC" -ne 0 ]; then
  if echo "$GEN_OUT" | grep -q -- '--check не поддерживается'; then fail generator-bez-check; fi
  if echo "$GEN_OUT" | grep -q 'Frozen VS01'; then fail vosproizvodimost; fi
  [ "$GEN_RC" -eq 1 ] || fail generator-bez-check
  fail vosproizvodimost
fi

# ── поведенческие пробы генератора (Б2): различающие входы в одноразовых ────
# локальных клонах; noop (sys.exit(0)) на них зелёным быть не может.
# П1/W1 + П2/W2 (арбитраж 119): писатель без аргументов обязан ВОССТАНАВЛИВАТЬ
# устаревший производный до байтов судимого дерева и вносить новое имя операции
# на ином входе — иначе generator-ne-pishet (писатель-пустышка при исправном
# --check, включая «восстанови выходы из git», зелёной быть не может).
make_probe() {  # $1 = имя клона; клон HEAD + оверлей рабочего дерева
  local d="$SCRATCH/$1"
  git clone -q --local . "$d" 2>/dev/null || return 1
  git diff HEAD --binary 2>/dev/null | git -C "$d" apply --whitespace=nowarn 2>/dev/null
  # оверлей неотслеживаемых (Rev119v2 Б-1 в): регулярный файл — cp, симлинк —
  # cp -P (как есть, без разыменования), прочее (каталог через симлинк,
  # вложенный репозиторий) не копируется; npm-дерево — отдельно ниже
  git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do
    [ "$f" = node_modules ] && continue
    if [ -L "$f" ]; then mkdir -p "$d/$(dirname "$f")" && cp -P "$f" "$d/$f" || exit 1
    elif [ -f "$f" ]; then mkdir -p "$d/$(dirname "$f")" && cp "$f" "$d/$f" || exit 1
    fi
  done || return 1
  # npm-дерево судимого дерева (каталог в .gitignore либо симлинк) достижимо
  # в клоне: пробы node судят продукт, а не отсутствие зависимостей (Б-1 б/в)
  if [ -e node_modules ] && [ ! -e "$d/node_modules" ] && [ ! -L "$d/node_modules" ]; then
    ln -s "$PWD/node_modules" "$d/node_modules" || return 1
  fi
}
# проба 1: --check на УСТАРЕВШЕМ производном обязан краснеть
make_probe probe-stale || fail vosproizvodimost
printf '\n# oracle-stale-marker\n' >> "$SCRATCH/probe-stale/$PUB"
if (cd "$SCRATCH/probe-stale" && python3 tests/tools/generate_derived.py --check >/dev/null 2>&1); then
  fail generator-noop
fi
# проба 1а (П1/W1): писатель без аргументов восстанавливает устаревший
# производный до БАЙТОВ судимого дерева — другая мера (cmp), не повторный --check
if ! (cd "$SCRATCH/probe-stale" && python3 tests/tools/generate_derived.py >/dev/null 2>&1); then
  fail generator-ne-pishet
fi
for f in "$PUB" docs/contracts/frontend-consumer-bindings.json \
         docs/contracts/operation-index.json docs/VERSION_MANIFEST.json FILES.sha256; do
  cmp -s "$SCRATCH/probe-stale/$f" "$f" || fail generator-ne-pishet
done
# проба 2: генерация на ЗАВЕДОМО ИНОМ входе обязана расходиться с диском
make_probe probe-discrim || fail vosproizvodimost
sed -i '0,/^\( *operationId: \)[A-Za-z0-9_]*$/s//\1oracleProbeOp/' \
  "$SCRATCH/probe-discrim/$SRC315/platform-extension.yaml"
if (cd "$SCRATCH/probe-discrim" && python3 tests/tools/generate_derived.py --check >/dev/null 2>&1); then
  fail generator-noop
fi
# проба 2а (П2/W2): писатель на ином входе обязан внести новое имя операции
# в published, и после него --check сходится
if ! (cd "$SCRATCH/probe-discrim" && python3 tests/tools/generate_derived.py >/dev/null 2>&1); then
  fail generator-ne-pishet
fi
grep -q 'operationId: oracleProbeOp' "$SCRATCH/probe-discrim/$PUB" || fail generator-ne-pishet
(cd "$SCRATCH/probe-discrim" && python3 tests/tools/generate_derived.py --check >/dev/null 2>&1) \
  || fail generator-ne-pishet

VAL_OUT="$(python3 tests/spec-3.15/validate_import_315.py 2>&1)"; VAL_RC=$?
{ [ "$VAL_RC" -eq 0 ] && echo "$VAL_OUT" | grep -q 'failures=\[\]'; } || fail validator-kreven

# known-failures=0 — инвариант ФАЙЛА (П3, арбитраж 119), независимо от вывода
# валидатора: реестр читает lane продукта как допуск (run_backend_ci.py:27),
# поэтому пустота проверяется оракулом по самому файлу (нет файла/не-JSON — то же)
jq -e '(.failure_ids|length)==0 and (.fingerprints|length)==0' \
  tests/tools/contract-validator-known-failures.json >/dev/null 2>&1 \
  || fail known-failures-nepust

# ── поведенческая проба валидатора (Б2): подсунутый дефект обязан краснеть ──
make_probe probe-val || fail vosproizvodimost
jq 'del(.workflow_consumers[0])' "$SCRATCH/probe-val/$BIND" > "$SCRATCH/probe-val/bind.tmp" \
  && mv "$SCRATCH/probe-val/bind.tmp" "$SCRATCH/probe-val/$BIND"
if (cd "$SCRATCH/probe-val" && python3 tests/spec-3.15/validate_import_315.py >/dev/null 2>&1); then
  fail validator-noop
fi
git -C "$SCRATCH/probe-val" checkout -q -- "$BIND"
jq '.compatibility_baseline="5.8.2"' "$SCRATCH/probe-val/$SRC315/baseline-lock.json" \
  > "$SCRATCH/probe-val/bl.tmp" && mv "$SCRATCH/probe-val/bl.tmp" "$SCRATCH/probe-val/$SRC315/baseline-lock.json"
if (cd "$SCRATCH/probe-val" && python3 tests/spec-3.15/validate_import_315.py >/dev/null 2>&1); then
  fail validator-noop
fi

# ── spec-3.14 смешанные профили (v2, R-1): lane-паритет без known-failures ───
# Б-2 (Rev119v2): evidence валидатора — в scratch оракула (--out), не в
# судимое дерево: иначе evidence/ попадает в инвентарь FILES повторного прогона
S314_OUT="$(python3 tests/spec-3.14/validate_contract_v3_9.py --out "$SCRATCH/s314" 2>&1)"; S314_RC=$?
{ [ "$S314_RC" -eq 0 ] && echo "$S314_OUT" | grep -Eq 'failures=\[\]|"failures": *\[\]'; } || fail spec314-kreven
# поведенческие пробы: подсунутый профильный дефект обязан краснеть —
# обманки «зелёный через пропуск extension-операций», «ослабление профиля
# core» и «неопределённые профили» (открытый алфавит маркеров) зеленеют на
# конформном дереве и различаются ТОЛЬКО здесь
make_probe probe-spec314 || fail vosproizvodimost
sed -i "0,/x-supported-contract-versions: \['5\.9\.0'\]/s//x-supported-contract-versions: ['5.8.x']/" \
  "$SCRATCH/probe-spec314/$PUB"
if (cd "$SCRATCH/probe-spec314" && python3 tests/spec-3.14/validate_contract_v3_9.py >/dev/null 2>&1); then
  fail spec314-noop
fi
git -C "$SCRATCH/probe-spec314" checkout -q -- "$PUB"
python3 - "$SCRATCH/probe-spec314/$PUB" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
needle = '      operationId: acknowledgeDisclosure'
i = s.index(needle)
open(p, 'w').write(s[:i + len(needle)] + "\n      x-supported-contract-versions: ['5.9.0']" + s[i + len(needle):])
PY
if (cd "$SCRATCH/probe-spec314" && python3 tests/spec-3.14/validate_contract_v3_9.py >/dev/null 2>&1); then
  fail spec314-noop
fi
git -C "$SCRATCH/probe-spec314" checkout -q -- "$PUB"
sed -i "0,/x-supported-contract-versions: \['5\.9\.0'\]/s//x-supported-contract-versions: ['9.9.9']/" \
  "$SCRATCH/probe-spec314/$PUB"
if (cd "$SCRATCH/probe-spec314" && python3 tests/spec-3.14/validate_contract_v3_9.py >/dev/null 2>&1); then
  fail spec314-noop
fi
git -C "$SCRATCH/probe-spec314" checkout -q -- "$PUB"

# ── app/schemas (v2, R-2): производные published, пересобранные генератором ──
SCHEMAS_SRC=app/schemas/source.json
[ -f app/schemas/openapi.json ] && [ -f "$SCHEMAS_SRC" ] || fail schemas-rashozhdenie
[ "$(jq -r '.source // ""' "$SCHEMAS_SRC")" = "$PUB" ] || fail schemas-rashozhdenie
[ "$(jq -r '.source_sha256 // ""' "$SCHEMAS_SRC")" = "$(sha256sum "$PUB" | cut -d' ' -f1)" ] \
  || fail schemas-rashozhdenie
[ "$(jq -r '.api_version // ""' "$SCHEMAS_SRC")" = "$(grep -m1 '^  version: ' "$PUB" | sed 's/^  version: //')" ] \
  || fail schemas-rashozhdenie
gc . --check || fail gencontracts-rashozhdenie
# ── полная независимая сборка published → openapi.json (арбитраж 119 v2, П1:
# полный документ, НЕ состав) ────────────────────────────────────────────────
# оракул САМ строит ожидаемый производный из САМОГО published (yaml→JSON,
# python3+PyYAML — уже зависимость батареи) и сравнивает канонические формы
# обеих сторон (jq -S -c, cmp): любое расхождение содержимого — связь
# operationId↔путь×метод, параметры, ответы, $ref, тела схем — красно.
# Сверка независима от писателя и его --check: согласованные на любом
# документе ≠ published writer/checker (обе lane зелёные, metadata честна)
# красны здесь; три частичные сверки множеств удалены как подмножество полной
jq -e . app/schemas/openapi.json >/dev/null 2>&1 || fail schemas-proekcija
python3 -c 'import sys, json, yaml; print(json.dumps(yaml.safe_load(open(sys.argv[1])), ensure_ascii=False, separators=(",", ":")))' "$PUB" \
  > "$SCRATCH/proj_expected.json" 2>/dev/null || fail schemas-proekcija
jq -S -c . "$SCRATCH/proj_expected.json" > "$SCRATCH/proj_expected.canon" 2>/dev/null || fail schemas-proekcija
jq -S -c . app/schemas/openapi.json > "$SCRATCH/proj_actual.canon" 2>/dev/null || fail schemas-proekcija
cmp -s "$SCRATCH/proj_expected.canon" "$SCRATCH/proj_actual.canon" || fail schemas-proekcija
# поведенческие пробы (W1/W2-зеркало для gen-contracts): --check обязан
# краснеть на устаревшем производном; писатель без аргументов обязан
# восстановить его до байтов судимого дерева — обманки «--check обойдён» и
# «пересборка не детерминирована» различаются только здесь
make_probe probe-schemas || fail vosproizvodimost
printf '\n/* oracle-stale */\n' >> "$SCRATCH/probe-schemas/app/schemas/openapi.json"
if gc "$SCRATCH/probe-schemas" --check; then
  fail gencontracts-noop
fi
if ! gc "$SCRATCH/probe-schemas"; then
  fail gencontracts-ne-pishet
fi
cmp -s "$SCRATCH/probe-schemas/app/schemas/openapi.json" app/schemas/openapi.json \
  || fail gencontracts-ne-pishet
cmp -s "$SCRATCH/probe-schemas/app/schemas/source.json" app/schemas/source.json \
  || fail gencontracts-ne-pishet
gc "$SCRATCH/probe-schemas" --check || fail gencontracts-ne-pishet

# ── known-issues (Б5): минимальный состав из ПИНА, не из проверяемого дерева ─
jq -r --arg s "$BASE_SHA" '.entries[] | select(.base_published_sha256==$s) | .known_issues_min[]' "$PIN" \
  | LC_ALL=C sort > "$SCRATCH/pin_iss"
jq -r '.ids[]' tests/spec-3.15/known-issues-315.json | LC_ALL=C sort > "$SCRATCH/reg_iss"
LC_ALL=C comm -23 "$SCRATCH/pin_iss" "$SCRATCH/reg_iss" | grep -q . && fail known-issues-nepolnyj
jq -r '.ids[]' "$SRC315/provenance/KNOWN-ISSUES-DECLARED.json" | LC_ALL=C sort > "$SCRATCH/declared_iss"
LC_ALL=C comm -23 "$SCRATCH/declared_iss" "$SCRATCH/reg_iss" | grep -q . && fail known-issues-nepolnyj

# ── история (Б4): сверка с git-базой, не с файлом проверяемого дерева ───────
cmp -s docs/history/3_14/BrokerOS_Unified_OpenAPI_v3.yaml "$SCRATCH/base_published.yaml" \
  || fail istorika-podmenena
git show "$BASE:docs/VERSION_MANIFEST.json" > "$SCRATCH/base_manifest.json" 2>/dev/null \
  || fail istorika-podmenena
cmp -s docs/history/3_14/VERSION_MANIFEST.json "$SCRATCH/base_manifest.json" \
  || fail istorika-podmenena
[ "$(cut -d' ' -f1 "$SRC315/provenance/nasha_5_8_4.sha256" 2>/dev/null)" = "$BASE_SHA" ] \
  || fail istorika-podmenena

CONFIRMED_N="$(LC_ALL=C comm -12 "$SCRATCH/base_recs" "$SCRATCH/cur_recs" | wc -l | tr -d ' ')"
ISSUES_N="$(wc -l < "$SCRATCH/reg_iss" | tr -d ' ')"
rm -rf "$SCRATCH"
echo "IMPORT315_OK operations=$CUR_OPS schemas=$CUR_SCH consumers_confirmed=$CONFIRMED_N consumers_total=$CUR_CON new_consumers=$NEW_CON_N tables=$CUR_TABLES known_issues=$ISSUES_N pin=$PIN_SCOPE"
