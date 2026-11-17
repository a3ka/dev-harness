#!/usr/bin/env bash
# КРАСНОЕ 199 «Sol в изоляции» (слово владельца 2026-11-16 ~20:05 UTC через
# консультанта: «Sol в изоляции — старт»; разбор /home/harness/consultant/
# ISO-PIN-ANALYSIS-ANSWER-1115.md, вариант А — разделить адрес исполнения и
# адрес доставки).
#
# ПРЕДМЕТ БАТАРЕИ (исполнимые клетки + обманные стабы; привязка стабов к
# различающим входам — КОДОМ ниже, не прозой контракта):
#   * дверь замка предметов (scripts/zamok_predmeta.sh + нормализация
#     .omp/extensions/spawn-guard.ts): рабочий item ОБЯЗАН нести реальный
#     флаг isolated:true (поле события спавна, НЕ слово в task) — гейт
#     НЕПОЗИЦИОНЕН: отказ NE_IZOLIROVAN на плохом рабочем в ЛЮБОЙ позиции
#     пакета — ПОСЛЕДНИМ элементом (d9-d10), ПЕРВЫМ при изолированном
#     последнем (d11), СЕРЕДИНОЙ при изолированных крайних (d12) — до
#     START и любых записей (в учёте не появляется ни одна строка
#     пакета); позиционные мутации гейта («только item 0», «только
#     последний», «только крайние») различимы (стабы s13/s15); START
#     записывает факт isolated; грамматика пина не ослабляется (клетки
#     d1–d12, h1–h3; d13-d17 — пин модели-эталона на унаследованной
#     семантике двери: CLI-предусловия rc2, источники полей факта START,
#     замкнутость классов WORKERS/JUDGES, грамматика SUBJECT/OBJECT/
#     имени/пакета, судейские ворота — замыкание класса «ложная
#     достаточность» по вердикту Crit199V2);
#   * привязка сдачи (scripts/privjazka_sdachi.sh): сверка source/ветка/
#     роль/предмет/репозиторий/владелец копии с ПОСЛЕДНИМ РАБОЧИМ фактом
#     START ДО accept_task_commit; строка START судьи, лежащая в учёте
#     ПОЗЖЕ рабочей (штатный порядок: судья приходит по предмету после
#     рабочего), сверку не смещает (p11); START без поля isolated —
#     наследие сегодняшней двери — даёт NE_IZOLIROVAN (p12); корень
#     приёма выводится из последнего факта замка и НЕ выбирается
#     вызывающим даже при СОВПАДАЮЩЕМ repoId: две копии одного origin —
#     root из факта START, не из --repo (p10); ротация держателя (≥2
#     строк START рабочего): сдача прежнего держателя отказывает
#     KOPIJA_CHUZHAYA, корень — из последнего факта замка (клетки p1–
#     p13; p8-p9 — ротация, закрывают last→first; p13 — предусловия и
#     имена: rc2 до сверки, NE_REPO, KOPIJA_CHUZHAYA без owner.json,
#     NOSITEL_NEDOSTUPEN);
#   * замыкание по вердикту адверсария Adv199Impl (2026-11-17, реализация):
#     isolated двери — СТРОГО булево true: строка «true», 1, [true], {x:true},
#     null, false, отсутствие поля → NE_IZOLIROVAN до любых записей (d18 —
#     КАЖДАЯ форма независимый прогон, ошибки в одном сообщении: Adv199Impl-2;
#     стабы s19 s20 — s20 несёт РОВНО ОДИН дефект, число, строка отвергается);
#     нормализация стража === true, не truthy (h4; стаб s21);
#     флаг привязки последним аргументом без значения — rc 2 без bash-шума
#     (p14; стаб s22);
#   * канонические вставки roles/orchestrator.md §«Изолированный спавн»
#     (маркеры 199-baza-*/199-nositel-*): синхробаза копии работника и
#     синхронизация носителя после приёма исполняются и судятся (w1–w2,
#     c1–c2, g1);
#   * регрессии периметра: своя копия при пине и М1-границы path-guard
#     (f1–f3 — субъект всегда живой .omp/extensions/path-guard.ts, предмет
#     199 его НЕ меняет), apply:false (g2), документы (t1–t2).
#
#
# ── ТАБЛИЦА «операция → клетка → стаб» (замыкание класса «ложная
#    достаточность» по вердикту Crit199V2: каждая операция обеих моделей-
#    эталонов — фильтр, сравнение, источник данных, ветка отказа — имеет
#    клетку, краснеющую при её замене/удалении; «=» — замена поведенчески
#    неотличима на конформных мирах, основание указано; стаб — существующий
#    стаб, воплощающий замену именно этой операции) ──────────────────────
# ДВЕРЬ model/zamok_predmeta_199.sh:
#  --sudit обязателен (rc2)                          → d13 → —
#  --sostojanie/--zhurnaly/--repo обязательны (rc2)  → d13 → —
#  [ -d SOST ] rc2            = избыточность: append в тот же LEDGER даёт тот же rc2
#  [ -d ZHUR ] rc2            → d13 (worker-only спавн: мутант пишет START мимо предусловия) → —
#  jq/git наличны             = среда: батарея требует те же инструменты (свой rc2 раньше)
#  [ -f EVENT ] rc2           → d13 → —
#  REPO=$(cd … pwd -P)        = форма пути: git -C/basename инвариантны к форме; провал cd ≡ провалу git-проверки (тот же rc2)
#  git-проверка REPO (rc2)    → d13 → —
#  LEDGER создать             = избыточность: append START создаёт тот же файл
#  repoId: origin → strip .git → basename → fallback
#                             → d14 (repoId факта == repo_id батареи, другая мера) → —
#  ts_now/at                  = метка: ни дверь, ни привязка at не читают (порядок строк учёта позиционный)
#  список WORKERS             → d15 (негативы всех четырёх классов iso:false) → —
#  список JUDGES + PROPUST/AGENT_NET
#                             → d15 (позитивы всех четырёх судей; не-гейт агент — PROPUST; agent отсутствует — AGENT_NET) → —
#  чтения agent/name/task item → d1 d14 d15 d16 → —
#  isolated: // false и ≠true→false (fail-closed) → d2 d3 → s03
#  isolated строго по ТИПУ (=== true: "true"/1/[true]/{x:true}/null → false) → d18 → s19 s20
#  слово в task не перевешивает поле → d4 → s01
#  алфавит имени IMJA_NET     → d16 → —
#  SUBJECT ровно одна ^SUBJECT=[0-9]{3}$ → d16 → —
#  извлечение sv (c9-11)      → d14 (subjectId факта) → —
#  пара пина присутствует (PIN_NET) → d6 → s02
#  пара пина единственна (GRAMMATIKA_PINA) → d7 → s02
#  извлечение wt/br пина      → d14 (worktree/branch факта) → —
#  NNN ветки == SUBJECT (RASHOZHDENIE_PINA) → d8 → —
#  worktree пина существует и репо (rc2) → d16 → —
#  ГЕЙТ NE_IZOLIROVAN КАЖДОГО item (непозиционен) → d2 d3 d4 d9 d10 d11 d12 → s03 s13 s15
#  OBJECT ровно одна ^OBJECT=[0-9a-f]{40}$ → d16 → —
#  извлечение obj             → d5 d17 → —
#  присвоения obj/klass/rol рабочего → d14 → —
#  DUBL_V_PAKETE              → d16 → —
#  RABOCHEGO_NET              → d17 → —
#  yield-литерал журнала (stare_holder) → d5 d17 → —
#  VETKA_NEDOSTUPNA           → d17 → —
#  OBJECT_RASHODITSJA         → d17 → —
#  KLASS_RISKA_NET (класс из дерева OBJECT) → d5 d17 → —
#  ADVERSARIJ_DO_REVJUERA     → d17 → —
#  holder.json замка          → d14 → —
#  строка START (все поля + isolated факт) → d1 d14 → —
# СТРАЖ model/spawn_guard_199.ts:
#  нормализация isolated === true, НЕ truthy (строка/1/[true]/{} → false) → h4 → s21
# ПРИВЯЗКА model/privjazka_sdachi.sh:
#  обязательные аргументы (rc2) → p13 → —
#  флаг последним БЕЗ значения (rc2, без bash-диагностики) → p14 → s22
#  [ -r LEDGER ] (rc2)       → p13 → —
#  REPO cd + git-проверка (rc2) → p13 → —
#  выборка t == START        = модель-дверь пишет только START; в рассмотренной реальной грамматике RELEASE не несёт klass=rabochij и отсекается сохранённым фильтром klass; появится иной тип записи с рабочим klass — предпосылка «=» пересматривается вместе с изменением грамматики (фильтр получает клетку той же пачкой)
#  выборка subjectId == N    → p6 → —
#  выборка klass == rabochij → p11 → s17
#  выборка last              → p8 p9 → s14
#  SDACHA_NET_START          → p6 → —
#  чтения полей факта (rol/branch/isolated/worktree/holder/repoId) → p1 p2 p3 p4 p5 p7 p8 p12 → s06 s07
#  ROL_RASHODITSJA           → p3 → s06
#  VETKA_RASHODITSJA         → p2 → s06
#  SUBEKT_VETKI (грамматика ветки) = глубокая защита: на конформных мирах s_br==BR уже влечёт грамматику (дверь пишет только согласованные ветки)
#  NE_IZOLIROVAN факта START → p12 → s18
#  REPO_RASHODITSJA (repoId) → p7 → s12
#  NE_REPO (источник не репо) → p13 → —
#  owner.json существует рядом → p13 → —
#  owner.json парсится       = избыточность: битый .id → null ≠ holder → тот же KOPIJA_CHUZHAYA
#  owner.json id == holder   → p4 p8 → s06
#  TIP_RASHODITSJA           → p5 → s07
#  NOSITEL_NEDOSTUPEN (worktree факта читается) → p13 → —
#  git-common-dir носителя → корень приёма → p1 p9 p10 → s16
#  strip /.git у корня       → p1 p9 p10 → s16
#  вывод root=<корень>       → p1 p9 p10 → s16
# РЕЖИМЫ:
#   (без флага)  — субъекты дерева; до реализации красное (rc 1);
#   --model      — субъекты model/ (эталоны целевой семантики); зелёное;
#   --stabs      — контроль над model/ + обманные стабы stabs/ + stabs_adv1/;
#                  зелёное означает: каждый стаб различим хотя бы одной клеткой;
#                  census (шапка батареи, НЕ контракт): stabs/ = 18
#                  (ls fixtures/workshop_project/sol_v_izolyacii_199/stabs/*
#                  | wc -l — замер контракта 199), stabs_adv1/ = 4
#                  (ls fixtures/workshop_project/sol_v_izolyacii_199/
#                  stabs_adv1/* | wc -l); движок гоняет все 22;
#   --repo <R>   — корень дерева субъектов (CI/станция).
#
# КОДЫ: 0 — зелено; 1 — красная клетка либо живой стаб; 2 — нечем проверить.
set -u

MODE='osn'; ROOT_ARG=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --model) MODE='model' ;;
    --stabs) MODE='stabs' ;;
    --repo)  ROOT_ARG="${2:?использование: [--model|--stabs] [--repo R]}"; shift ;;
    *) printf 'использование: %s [--model|--stabs] [--repo R]\n' "$0" >&2; exit 2 ;;
  esac
  shift
done
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
if [ -n "$ROOT_ARG" ]; then
  ROOT="$(cd "$ROOT_ARG" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень --repo не читается: %s\n' "$ROOT_ARG" >&2; exit 2; }
else
  ROOT="$(cd "$HERE/../../.." && pwd -P)"
fi

command -v bash >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет bash\n' >&2; exit 2; }
command -v git  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n'  >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n'   >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v find >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет find\n' >&2; exit 2; }

# Гигиена Н-85: снять git-подсказки окружения.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# ── субъекты (env-швы стаб-паков; модели — режим --model) ────────────────────
dver()     { printf '%s' "${S199_DOOR:-$ROOT/scripts/zamok_predmeta.sh}"; }
huk()      { printf '%s' "${S199_GUARD:-$ROOT/.omp/extensions/spawn-guard.ts}"; }
priv()     { printf '%s' "${S199_PRIV:-$ROOT/scripts/privjazka_sdachi.sh}"; }
vstavka()  { printf '%s' "${S199_VSTAVKA:-$ROOT/roles/orchestrator.md}"; }
shapka()   { printf '%s' "${S199_SHAPKA:-$ROOT/scripts/spawn_agent.sh}"; }
readme()   { printf '%s' "${S199_README:-$ROOT/ops/server/README.md}"; }
PATHGUARD="$ROOT/.omp/extensions/path-guard.ts"
ACCEPT="$ROOT/scripts/accept_task_commit.sh"

if [ "$MODE" = 'model' ] || [ "$MODE" = 'stabs' ]; then
  S199_DOOR="$HERE/model/zamok_predmeta_199.sh"
  S199_GUARD="$HERE/model/spawn_guard_199.ts"
  S199_PRIV="$HERE/model/privjazka_sdachi.sh"
  S199_VSTAVKA="$HERE/model/orchestrator_vstavka_199.md"
  S199_SHAPKA="$HERE/model/dok_199.txt"
  S199_README="$HERE/model/dok_199.txt"
  export S199_DOOR S199_GUARD S199_PRIV S199_VSTAVKA S199_SHAPKA S199_README
fi
for f in "$HERE/model/zamok_predmeta_199.sh" "$HERE/model/spawn_guard_199.ts" \
         "$HERE/model/privjazka_sdachi.sh" "$HERE/model/orchestrator_vstavka_199.md" \
         "$HERE/model/dok_199.txt" "$PATHGUARD" "$ACCEPT"; do
  [ -f "$f" ] || { printf 'NOT_IMPLEMENTED: нет файла батареи/субъекта: %s\n' "$f" >&2; exit 2; }
done

# Миры СОЗНАТЕЛЬНО вне ${TMPDIR:-/tmp}/dev-harness-verify — иначе pass по
# scratch-allowlist 025 ничего не доказывает (ловушка Н-85/А-122, прецедент
# fixtures/path_guard/red_own_copy_paket_b.sh).
WB="$(mktemp -d /tmp/dev-harness-s199.XXXXXX)" || exit 2
FAKEHOME="$(mktemp -d /tmp/dev-harness-fakehome-s199.XXXXXX)" || exit 2
trap 'rm -rf "$WB" "$FAKEHOME"' EXIT
WBASE="$WB/osn"

# ── построители миров ─────────────────────────────────────────────────────────
mkrepo() {  # <путь> — минимальный репо, .git КАТАЛОГ, 1 коммит
  mkdir -p "$1"
  git -C "$1" init -q -b main
  printf 'x\n' > "$1/f.txt"
  git -C "$1" add f.txt
  git -C "$1" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -qm init
}
commit_as() {  # <репо> <роль> <msg>
  git -C "$1" add -A
  git -C "$1" -c user.name="$2" -c user.email="$2@dev-harness.local" \
    -c commit.gpgsign=false commit -qm "$3"
}
repo_id() {  # <репо> — тот же вывод, что у двери/привязки
  local url id
  url="$(git -C "$1" remote get-url origin 2>/dev/null)" || url=''
  id="${url##*/}"; id="${id%.git}"
  [ -n "$id" ] || id="$(basename "$1")"
  printf '%s' "$id"
}
izvlek() {  # <файл> <маркер-начало> <маркер-конец> <out> — блок между маркерами
  grep -Fqx "$2" "$1" || return 1
  grep -Fqx "$3" "$1" || return 1
  awk -v a="$2" -v b="$3" '$0 == a { f = 1; next } $0 == b { f = 0 } f' "$1" > "$4"
  [ -s "$4" ] || return 1
}

mk_dwer_world() {  # <dir>
  DW_MAIN="$1/main"; DW_CAR="$1/wip-199-architect"; DW_SOST="$1/sost"; DW_ZHUR="$1/zhur"
  mkdir -p "$DW_SOST" "$DW_ZHUR"
  mkrepo "$DW_MAIN"
  git -C "$DW_MAIN" worktree add -q -b wip/199/architect "$DW_CAR" >/dev/null 2>&1
}
mk_huk_world() {  # <dir> — установка с записывающей дверью-двойником
  local w="$1" inst="$1/inst"
  mkdir -p "$inst/.omp/extensions" "$inst/scripts" "$inst/config" \
           "$w/zones/z/agent/sessions" "$w/proj"
  cp "$(huk)" "$inst/.omp/extensions/spawn-guard.ts"
  cat > "$inst/scripts/zamok_predmeta.sh" <<'SEV'
#!/usr/bin/env bash
ev="${@: -1}"
cat "$ev" >> "$S199_RECORD"
exit 0
SEV
  chmod +x "$inst/scripts/zamok_predmeta.sh"
  printf '{"roles":{"architect":"slow","implementer":"task","critic":"apex","reviewer":"audit","adversary":"advisor"}}' \
    > "$inst/config/agent_models.json"
  : > "$w/zones/z/agent/sessions/S1.jsonl"
  cat > "$w/driver.mjs" <<'MJS'
import { pathToFileURL } from 'node:url';
import { readFileSync } from 'node:fs';
const [guard, casesFile, cwd, sessionFile] = process.argv.slice(2);
for (const k of Object.keys(process.env)) { if (k.startsWith('HARNESS_')) delete process.env[k]; }
process.chdir(cwd);
const mod = await import(pathToFileURL(guard).href);
const reg = typeof mod.register === 'function' ? mod.register : mod.default;
const handlers = [];
reg({ on: (_n, h) => handlers.push(h) });
const cases = JSON.parse(readFileSync(casesFile, 'utf8'));
let bad = 0;
for (const c of cases) {
  const ctx = { sessionManager: { getSessionFile: () => sessionFile } };
  const got = handlers[handlers.length - 1](c.event, ctx);
  const wantBlock = c.want !== 'pass';
  const ok = wantBlock
    ? (got !== undefined && got.block === true && typeof got.reason === 'string' && got.reason.includes(c.want))
    : got === undefined;
  if (!ok) bad++;
  console.log(`${ok ? 'ok' : 'FAIL'} ${c.name} got=${JSON.stringify(got)}`);
}
process.exit(bad > 0 ? 1 : 0);
MJS
}
mk_priv_world() {  # <dir>
  local d="$1"
  PW_MAIN="$d/pmain"; PW_CAR="$d/pcarrier"; PW_SOST="$d/psost"
  PW_M="$d/kop/pm"; PW_M2="$d/chp/pm2"; PW_DRUG="$d/drugoe"
  mkdir -p "$PW_SOST" "$d/kop" "$d/chp"
  mkrepo "$PW_MAIN"
  git -C "$PW_MAIN" remote add origin "$d/toyrepo.git"
  git -C "$PW_MAIN" worktree add -q -b wip/199/architect "$PW_CAR" >/dev/null 2>&1
  # вторая копия ТОГО ЖЕ origin: repoId совпадает, носитель START-факта — PW_MAIN (p10)
  PW_MAIN_B="$d/pmainB"; mkrepo "$PW_MAIN_B"; git -C "$PW_MAIN_B" remote add origin "$d/toyrepo.git"
  mkrepo "$PW_M";  printf '{"pid":1,"id":"ArchP199","startToken":"1"}' > "$d/kop/.omp-isolation-owner.json"
  mkrepo "$PW_M2"; printf '{"pid":1,"id":"Chuzhoj","startToken":"1"}'   > "$d/chp/.omp-isolation-owner.json"
  mkrepo "$PW_DRUG"; git -C "$PW_DRUG" remote add origin "$d/drugoe2.git"
  jq -nc --arg r toyrepo --arg s 199 --arg h ArchP199 --arg ro architect \
        --arg o - --arg w "$PW_CAR" --arg b wip/199/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-16T00:00:00Z",isolated:$iso}' \
    >> "$PW_SOST/uchet.jsonl"
  PW_MAIN_ABS="$(cd "$PW_MAIN" && pwd -P)"
  PW_MAIN_B_ABS="$(cd "$PW_MAIN_B" && pwd -P)"
  PW_TIP="$(git -C "$PW_M" rev-parse HEAD)"
}

mk_rot_world() {  # <dir> — ротация держателя: ДВЕ строки START рабочего 199
  local d="$1"
  ROT_SOST="$d/sost"; ROT_MAIN_NEW="$d/newmain"; ROT_CAR_NEW="$d/newcarrier"
  ROT_MAIN_OLD="$d/oldmain"; ROT_CAR_OLD="$d/oldcarrier"
  ROT_M_OLD="$d/kopold/m"; ROT_M_NEW="$d/kopnew/m"
  mkdir -p "$ROT_SOST" "$d/kopold" "$d/kopnew"
  mkrepo "$ROT_MAIN_NEW"; git -C "$ROT_MAIN_NEW" remote add origin "$d/toyrepo.git"
  git -C "$ROT_MAIN_NEW" worktree add -q -b wip/199/architect "$ROT_CAR_NEW" >/dev/null 2>&1
  mkrepo "$ROT_MAIN_OLD"; git -C "$ROT_MAIN_OLD" remote add origin "$d/toyrepo.git"
  git -C "$ROT_MAIN_OLD" worktree add -q -b wip/199/architect "$ROT_CAR_OLD" >/dev/null 2>&1
  mkrepo "$ROT_M_OLD"; printf '{"pid":1,"id":"ArchOld","startToken":"1"}' > "$d/kopold/.omp-isolation-owner.json"
  mkrepo "$ROT_M_NEW"; printf '{"pid":1,"id":"ArchNew","startToken":"1"}' > "$d/kopnew/.omp-isolation-owner.json"
  jq -nc --arg r toyrepo --arg s 199 --arg h ArchOld --arg ro architect --arg o - \
        --arg w "$ROT_CAR_OLD" --arg b wip/199/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-16T01:00:00Z",isolated:$iso}' \
    >> "$ROT_SOST/uchet.jsonl"
  jq -nc --arg r toyrepo --arg s 199 --arg h ArchNew --arg ro architect --arg o - \
        --arg w "$ROT_CAR_NEW" --arg b wip/199/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-16T02:00:00Z",isolated:$iso}' \
    >> "$ROT_SOST/uchet.jsonl"
  ROT_MAIN_NEW_ABS="$(cd "$ROT_MAIN_NEW" && pwd -P)"
  ROT_TIP_OLD="$(git -C "$ROT_M_OLD" rev-parse HEAD)"
  ROT_TIP_NEW="$(git -C "$ROT_M_NEW" rev-parse HEAD)"
}
zov_priv() { bash "$(priv)" "$@"; }

mk_sud_world() {  # <dir> <строка-КЛАСС РИСКА|-> <yield 1|0> [worktree] —
  # мир судейских ворот: рабочий START ArchT (iso:true, yield по флагу),
  # contracts/199-toy.md со строкой класса (или пустой), tip ветки = SW_OBJ
  local d="$1" ris="$2" yld="$3" wt="${4:-}"
  SW_MAIN="$d/main"; SW_CAR="$d/carrier"; SW_SOST="$d/sost"; SW_ZHUR="$d/zhur"
  mkdir -p "$SW_SOST" "$SW_ZHUR"
  mkrepo "$SW_MAIN"
  git -C "$SW_MAIN" remote add origin "$d/toyrepo.git"
  git -C "$SW_MAIN" worktree add -q -b wip/199/architect "$SW_CAR" >/dev/null 2>&1
  mkdir -p "$SW_CAR/contracts"
  if [ "$ris" = '-' ]; then : > "$SW_CAR/contracts/199-toy.md"; else printf '%s\n' "$ris" > "$SW_CAR/contracts/199-toy.md"; fi
  commit_as "$SW_CAR" architect 'klass'
  SW_OBJ="$(git -C "$SW_MAIN" rev-parse wip/199/architect)"
  [ -n "$wt" ] || wt="$SW_CAR"
  jq -nc --arg r toyrepo --arg s 199 --arg h ArchT --arg ro architect --arg o - \
        --arg w "$wt" --arg b wip/199/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-16T00:00:00Z",isolated:$iso}' \
    >> "$SW_SOST/uchet.jsonl"
  if [ "$yld" = '1' ]; then printf '{"toolName":"yield"}\n' > "$SW_ZHUR/ArchT.jsonl"; else : > "$SW_ZHUR/ArchT.jsonl"; fi
}
sud_event() {  # <файл> <agent> <subject> <object 40hex>
  jq -n --arg a "$2" --arg s "$3" --arg o "$4" --arg t "SUBJECT=$3
OBJECT=$4" '{tasks:[{agent:$a,name:"SudjaT",task:$t}]}' > "$1"
}

mk_wip_world() {  # <dir> <advance 1|0>
  WW_MAIN="$1/wmain"; WW_CAR="$1/wcarrier"; WW_M="$1/m"
  mkrepo "$WW_MAIN"
  git -C "$WW_MAIN" worktree add -q -b wip/199/architect "$WW_CAR" >/dev/null 2>&1
  printf 'b1\n' > "$WW_CAR/b1.txt"
  commit_as "$WW_CAR" architect 'avtor b1'
  git clone -q --no-hardlinks "$WW_MAIN" "$WW_M"
  git -C "$WW_M" branch wip/199/architect \
    "$(git -C "$WW_M" rev-parse refs/remotes/origin/wip/199/architect)" >/dev/null 2>&1
  if [ "$2" = '1' ]; then
    printf 'b2\n' > "$WW_CAR/b2.txt"
    commit_as "$WW_CAR" architect 'avtor b2'
  fi
}
mk_car_world() {  # <dir>
  CW_MAIN="$1/cmain"; CW_CAR="$1/ccarrier"; CW_M="$1/ccopy"
  mkrepo "$CW_MAIN"
  git -C "$CW_MAIN" worktree add -q -b wip/199/architect "$CW_CAR" >/dev/null 2>&1
  git clone -q --no-hardlinks "$CW_MAIN" "$CW_M"
  git -C "$CW_M" fetch -q --no-tags "$CW_CAR" refs/heads/wip/199/architect
  git -C "$CW_M" switch -q -C wip/199/architect FETCH_HEAD
  printf 'child\n' > "$CW_M/child.txt"
  commit_as "$CW_M" architect 'child'
}
FH_READY=''
mk_fajl_world() {
  [ -n "$FH_READY" ] && return 0
  FH_COPY="$FAKEHOME/profiles/dev/wt/f1/m"
  FH_COPY2="$FAKEHOME/profiles/dev/wt/f2/m"
  FH_MAINLIKE="$WBASE/f-mainlike/m"
  FH_PIN="$WBASE/f-pin"
  mkdir -p "$(dirname "$FH_COPY")" "$(dirname "$FH_COPY2")"
  mkrepo "$FH_COPY";  printf '{"pid":1,"id":"OwnerF1","startToken":"1"}' > "$(dirname "$FH_COPY")/.omp-isolation-owner.json"
  mkrepo "$FH_COPY2"; printf '{"pid":1,"id":"OwnerF2","startToken":"1"}' > "$(dirname "$FH_COPY2")/.omp-isolation-owner.json"
  mkrepo "$FH_MAINLIKE"; printf '{"pid":1,"id":"OwnerF1","startToken":"1"}' > "$(dirname "$FH_MAINLIKE")/.omp-isolation-owner.json"
  mkrepo "$FH_PIN"
  FH_READY=1
}
f_sud() {  # <json> <want pass|block>
  local out dec
  out="$(HOME="$FAKEHOME" node "$PATHGUARD" --judge "$1")" || return 1
  dec="$(printf '%s' "$out" | jq -r '.decision // "NET"')"
  [ "$dec" = "$2" ]
}

# ── клетки ───────────────────────────────────────────────────────────────────
d1() {
  local w="$WBASE/d1"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD1",task:$t,isolated:true}]}' > "$w/ev.json"
  local out rc
  out="$(bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" 2>"$w/err")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'd1: rc=%s err=%s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  grep -q 'PUSCHEM' <<<"$out" || { printf 'd1: нет PUSCHEM\n' >&2; return 1; }
  jq -e 'select(.t == "START" and .isolated == true)' "$DW_SOST/uchet.jsonl" >/dev/null 2>&1 \
    || { printf 'd1: START без isolated:true\n' >&2; return 1; }
}
d2() {
  local w="$WBASE/d2"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD2",task:$t,isolated:false}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd2: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd2: нет NE_IZOLIROVAN\n' >&2; return 1; }
  [ ! -s "$DW_SOST/uchet.jsonl" ] || { printf 'd2: START записан вопреки отказу\n' >&2; return 1; }
}
d3() {
  local w="$WBASE/d3"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD3",task:$t}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd3: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd3: нет NE_IZOLIROVAN (отсутствие поля = false)\n' >&2; return 1; }
}
d4() {
  local w="$WBASE/d4"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect
spawn isolated:true" '{tasks:[{agent:"architect",name:"ArchD4",task:$t,isolated:false}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd4: rc=%s — слово в task перевесило поле события\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd4: нет NE_IZOLIROVAN\n' >&2; return 1; }
}
d5() {
  local w="$WBASE/d5"; mkdir -p "$w"; mk_dwer_world "$w"
  mkdir -p "$DW_CAR/contracts"
  printf 'КЛАСС РИСКА: обычный\n' > "$DW_CAR/contracts/199-toy.md"
  commit_as "$DW_CAR" architect 'klass'
  local O; O="$(git -C "$DW_MAIN" rev-parse wip/199/architect)"
  jq -nc --arg r "$(repo_id "$DW_MAIN")" --arg s 199 --arg h ArchT --arg ro architect \
        --arg o - --arg w "$DW_CAR" --arg b wip/199/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-16T00:00:00Z",isolated:$iso}' \
    >> "$DW_SOST/uchet.jsonl"
  printf '{"toolName":"yield"}\n' > "$DW_ZHUR/ArchT.jsonl"
  jq -n --arg t "SUBJECT=199
OBJECT=$O" '{tasks:[{agent:"critic",name:"Crit1",task:$t,isolated:false}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'd5: судья отказан из-за isolated (требование только для рабочих): %s\n' "$(tail -1 "$w/err")" >&2; return 1; }
}
d6() {
  local w="$WBASE/d6"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199" '{tasks:[{agent:"architect",name:"ArchD6",task:$t,isolated:true}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd6: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'PIN_NET' "$w/err" || { printf 'd6: нет PIN_NET\n' >&2; return 1; }
}
d7() {
  local w="$WBASE/d7"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD7",task:$t,isolated:true}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd7: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'GRAMMATIKA_PINA' "$w/err" || { printf 'd7: нет GRAMMATIKA_PINA\n' >&2; return 1; }
}
d8() {
  local w="$WBASE/d8"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/198/architect" '{tasks:[{agent:"architect",name:"ArchD8",task:$t,isolated:true}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd8: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'RASHOZHDENIE_PINA' "$w/err" || { printf 'd8: нет RASHOZHDENIE_PINA\n' >&2; return 1; }
}

d9() {
  local w="$WBASE/d9"; mkdir -p "$w"; mk_dwer_world "$w"
  local DW_CAR2="$w/car198"
  git -C "$DW_MAIN" worktree add -q -b wip/198/architect "$DW_CAR2" >/dev/null 2>&1
  mkdir -p "$DW_CAR/contracts"
  printf 'КЛАСС РИСКА: обычный\n' > "$DW_CAR/contracts/199-toy.md"
  commit_as "$DW_CAR" architect 'klass'
  local O; O="$(git -C "$DW_MAIN" rev-parse wip/199/architect)"
  jq -nc --arg r "$(repo_id "$DW_MAIN")" --arg s 199 --arg h ArchT --arg ro architect \
        --arg o - --arg w "$DW_CAR" --arg b wip/199/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-16T00:00:00Z",isolated:$iso}' \
    >> "$DW_SOST/uchet.jsonl"
  printf '{"toolName":"yield"}\n' > "$DW_ZHUR/ArchT.jsonl"
  jq -n --arg t1 "SUBJECT=199
OBJECT=$O" --arg t2 "SUBJECT=198
WORKTREE=$DW_CAR2
BRANCH=wip/198/architect" '{tasks:[
  {agent:"critic",name:"CritD9",task:$t1},
  {agent:"architect",name:"ArchD9",task:$t2,isolated:false}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd9: rc=%s (нужен 1: рабочий item 1 пакета без isolated)\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd9: нет NE_IZOLIROVAN на item 1 пакета\n' >&2; return 1; }
  [ "$(grep -c . "$DW_SOST/uchet.jsonl")" -eq 1 ] || { printf 'd9: в учёте появились строки пакета вопреки отказу\n' >&2; return 1; }
}

d10() {
  local w="$WBASE/d10"; mkdir -p "$w"; mk_dwer_world "$w"
  local DW_CAR2="$w/car198"
  git -C "$DW_MAIN" worktree add -q -b wip/198/architect "$DW_CAR2" >/dev/null 2>&1
  jq -n --arg t1 "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" --arg t2 "SUBJECT=198
WORKTREE=$DW_CAR2
BRANCH=wip/198/architect" '{tasks:[
  {agent:"architect",name:"ArchD10a",task:$t1,isolated:true},
  {agent:"architect",name:"ArchD10b",task:$t2,isolated:false}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd10: rc=%s (нужен 1: рабочий item 1 пакета без isolated)\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd10: нет NE_IZOLIROVAN на item 1 пакета\n' >&2; return 1; }
  [ ! -s "$DW_SOST/uchet.jsonl" ] || { printf 'd10: START записан вопреки отказу (в т.ч. изолированный item 0)\n' >&2; return 1; }
}

d11() {  # блок (а) вердикта Crit199V2: плохой рабочий ПЕРВЫМ, изолированный — последним
  local w="$WBASE/d11"; mkdir -p "$w"; mk_dwer_world "$w"
  local DW_CAR2="$w/car198"
  git -C "$DW_MAIN" worktree add -q -b wip/198/architect "$DW_CAR2" >/dev/null 2>&1
  jq -n --arg t1 "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" --arg t2 "SUBJECT=198
WORKTREE=$DW_CAR2
BRANCH=wip/198/architect" '{tasks:[
  {agent:"architect",name:"ArchD11a",task:$t1,isolated:false},
  {agent:"architect",name:"ArchD11b",task:$t2,isolated:true}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd11: rc=%s (нужен 1: рабочий item 0 пакета без isolated)\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd11: нет NE_IZOLIROVAN на item 0 пакета\n' >&2; return 1; }
  [ ! -s "$DW_SOST/uchet.jsonl" ] || { printf 'd11: START записан вопреки отказу (в т.ч. изолированный последний item)\n' >&2; return 1; }
}

d12() {  # блок (а): плохой рабочий СЕРЕДИНОЙ, крайние изолированы (гейт «только крайние» мёртв)
  local w="$WBASE/d12"; mkdir -p "$w"; mk_dwer_world "$w"
  local DW_CAR2="$w/car198" DW_CAR3="$w/car197"
  git -C "$DW_MAIN" worktree add -q -b wip/198/architect "$DW_CAR2" >/dev/null 2>&1
  git -C "$DW_MAIN" worktree add -q -b wip/197/architect "$DW_CAR3" >/dev/null 2>&1
  jq -n --arg t1 "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" --arg t2 "SUBJECT=198
WORKTREE=$DW_CAR2
BRANCH=wip/198/architect" --arg t3 "SUBJECT=197
WORKTREE=$DW_CAR3
BRANCH=wip/197/architect" '{tasks:[
  {agent:"architect",name:"ArchD12a",task:$t1,isolated:true},
  {agent:"architect",name:"ArchD12b",task:$t2,isolated:false},
  {agent:"architect",name:"ArchD12c",task:$t3,isolated:true}]}' > "$w/ev.json"
  local rc; bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd12: rc=%s (нужен 1: рабочий item 1 середины пакета без isolated)\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd12: нет NE_IZOLIROVAN на item 1 пакета\n' >&2; return 1; }
  [ ! -s "$DW_SOST/uchet.jsonl" ] || { printf 'd12: START записан вопреки отказу (в т.ч. изолированные крайние items)\n' >&2; return 1; }
}

d13() {  # CLI-предусловия двери: rc2 до любых записей (мутант пропуска пишет START)
  local w="$WBASE/d13"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD13",task:$t,isolated:true}]}' > "$w/ev.json"
  mkdir -p "$w/notrepo"
  local rc
  bash "$(dver)" --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>&1; rc=$?
  [ "$rc" -eq 2 ] || { printf 'd13: без --sudit rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" "$w/ev.json" >/dev/null 2>&1; rc=$?
  [ "$rc" -eq 2 ] || { printf 'd13: без --repo rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$w/notrepo" "$w/ev.json" >/dev/null 2>&1; rc=$?
  [ "$rc" -eq 2 ] || { printf 'd13: --repo не-репозиторий rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$w/net_zhur" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>&1; rc=$?
  [ "$rc" -eq 2 ] || { printf 'd13: --zhurnaly отсутствует rc=%s (нужен 2: worker-only спавн мутантом пишется)\n' "$rc" >&2; return 1; }
  [ ! -s "$DW_SOST/uchet.jsonl" ] || { printf 'd13: START записан при нарушенном предусловии\n' >&2; return 1; }
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/netu.json" >/dev/null 2>&1; rc=$?
  [ "$rc" -eq 2 ] || { printf 'd13: файла события нет rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
}

d14() {  # факт START: источники полей (repoId/holder/subject/pin/isolated) + holder.json замка
  local w="$WBASE/d14"; mkdir -p "$w"; mk_dwer_world "$w"
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD14",task:$t,isolated:true}]}' > "$w/ev.json"
  local out rc rid
  out="$(bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" 2>"$w/err")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'd14: rc=%s %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  grep -q 'PUSCHEM' <<<"$out" || { printf 'd14: нет PUSCHEM\n' >&2; return 1; }
  rid="$(repo_id "$DW_MAIN")"
  jq -e --arg rid "$rid" --arg w "$DW_CAR" '
    .t == "START" and .repoId == $rid and .subjectId == "199" and .holder == "ArchD14"
    and .klass == "rabochij" and .rol == "architect" and .object == "-"
    and .worktree == $w and .branch == "wip/199/architect" and .isolated == true' \
    "$DW_SOST/uchet.jsonl" >/dev/null 2>&1 \
    || { printf 'd14: факт START несёт неверные поля: %s\n' "$(cat "$DW_SOST/uchet.jsonl")" >&2; return 1; }
  jq -e --arg h ArchD14 '.holder == $h' "$DW_SOST/zamki/$rid/199/zanyat/holder.json" >/dev/null 2>&1 \
    || { printf 'd14: holder.json замка не записан/чужой holder\n' >&2; return 1; }
}

d15() {  # замкнутость классов: ВСЕ WORKERS под гейтом, ВСЕ JUDIES свободны, прочие — PROPUST
  local w="$WBASE/d15"; mkdir -p "$w"; mk_dwer_world "$w"
  local r rc j out
  for r in architect implementer implementer-glm implementer-vision; do
    jq -n --arg a "$r" --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:$a,name:"W199",task:$t,isolated:false}]}' > "$w/evw.json"
    bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/evw.json" >/dev/null 2>"$w/err"; rc=$?
    [ "$rc" -eq 1 ] || { printf 'd15: %s iso:false rc=%s (нужен 1: гейт накрывает ВСЕ классы рабочих)\n' "$r" "$rc" >&2; return 1; }
    grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'd15: %s нет NE_IZOLIROVAN\n' "$r" >&2; return 1; }
    [ ! -s "$DW_SOST/uchet.jsonl" ] || { printf 'd15: %s START записан вопреки отказу\n' "$r" >&2; return 1; }
  done
  mk_sud_world "$w/sud" 'КЛАСС РИСКА: обычный' 1
  for j in critic critic-sol adversary reviewer; do
    sud_event "$w/evj.json" "$j" 199 "$SW_OBJ"
    # Слой замка 140 субъекта: предыдущий судья (тот же holder SudjaT) СДАЛ —
    # журнал holder-а с yield-литералом освобождает замок предмета до нового
    # судьи (образец — mir_zhurnal … sdal=1 в батарее 140). Модель-эталон 199
    # замок по судьям не читает — файл инертен в --model.
    printf '{"toolName":"yield"}\n' > "$SW_ZHUR/SudjaT.jsonl"
    bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/evj.json" >/dev/null 2>"$w/err"; rc=$?
    [ "$rc" -eq 0 ] || { printf 'd15: судья %s rc=%s (нужен 0: требование только для рабочих): %s\n' "$j" "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  done
  jq -e -s '([.[] | select(.klass == "sudja") | .rol] | sort) == ["adversary","critic","critic-sol","reviewer"]' \
    "$SW_SOST/uchet.jsonl" >/dev/null 2>&1 \
    || { printf 'd15: факты START судей неверны (роли/число)\n' >&2; return 1; }
  jq -n '{tasks:[{agent:"orchestrator",name:"O199",task:"SUBJECT=199",isolated:false}]}' > "$w/evo.json"
  out="$(bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/evo.json" 2>"$w/err")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'd15: не-гейт агент rc=%s (нужен 0)\n' "$rc" >&2; return 1; }
  grep -q 'PROPUST' <<<"$out" || { printf 'd15: нет PROPUST для не-гейт агента\n' >&2; return 1; }
  [ "$(grep -c . "$SW_SOST/uchet.jsonl")" -eq 5 ] || { printf 'd15: не-гейт агент что-то записал в учёт\n' >&2; return 1; }
  jq -n '{tasks:[{name:"N199",task:"SUBJECT=199"}]}' > "$w/evn.json"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/evn.json" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd15: agent отсутствует rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'AGENT_NET' "$w/err" || { printf 'd15: нет AGENT_NET\n' >&2; return 1; }
}

d16() {  # грамматика входа двери: именованные отказы/ rc2 на плохих item-входах
  local w="$WBASE/d16"; mkdir -p "$w"; mk_dwer_world "$w"
  local rc NUL; NUL=0000000000000000000000000000000000000000
  jq -n --arg t "WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"G1",task:$t,isolated:true}]}' > "$w/ev1.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev1.json" >/dev/null 2>"$w/e1"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: без SUBJECT rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'SUBJECT_NET_V_ZADANII' "$w/e1" || { printf 'd16: нет SUBJECT_NET_V_ZADANII\n' >&2; return 1; }
  jq -n --arg t "SUBJECT=199
SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"G2",task:$t,isolated:true}]}' > "$w/ev2.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev2.json" >/dev/null 2>"$w/e2"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: два SUBJECT rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'SUBEKT_DVA_V_ZADANII' "$w/e2" || { printf 'd16: нет SUBEKT_DVA_V_ZADANII\n' >&2; return 1; }
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"Плохое Имя",task:$t,isolated:true}]}' > "$w/ev3.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev3.json" >/dev/null 2>"$w/e3"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: имя вне алфавита rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'IMJA_NET' "$w/e3" || { printf 'd16: нет IMJA_NET\n' >&2; return 1; }
  printf 'not json' > "$w/ev4.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev4.json" >/dev/null 2>"$w/e4"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: битый JSON rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'BITYJ_VHOD' "$w/e4" || { printf 'd16: нет BITYJ_VHOD\n' >&2; return 1; }
  jq -n '{tasks:[]}' > "$w/ev5.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev5.json" >/dev/null 2>"$w/e5"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: пустой tasks rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'BITYJ_VHOD' "$w/e5" || { printf 'd16: нет BITYJ_VHOD (items пуст)\n' >&2; return 1; }
  jq -n --arg t1 "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" --arg t2 "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[
  {agent:"architect",name:"DUBLa",task:$t1,isolated:true},
  {agent:"architect",name:"DUBLb",task:$t2,isolated:true}]}' > "$w/ev6.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev6.json" >/dev/null 2>"$w/e6"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: дубль предмета в пакете rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'DUBL_V_PAKETE' "$w/e6" || { printf 'd16: нет DUBL_V_PAKETE\n' >&2; return 1; }
  jq -n --arg t "SUBJECT=199
WORKTREE=/netu-d16
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"G9",task:$t,isolated:true}]}' > "$w/ev7.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev7.json" >/dev/null 2>"$w/e7"; rc=$?
  [ "$rc" -eq 2 ] || { printf 'd16: пин на несуществующий worktree rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  grep -q 'NOT_IMPLEMENTED' "$w/e7" || { printf 'd16: нет NOT_IMPLEMENTED о worktree пина\n' >&2; return 1; }
  mk_sud_world "$w/sud" 'КЛАСС РИСКА: обычный' 1
  jq -n --arg t "SUBJECT=199" '{tasks:[{agent:"critic",name:"G4",task:$t}]}' > "$w/ev8.json"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/ev8.json" >/dev/null 2>"$w/e8"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: судья без OBJECT rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'OBJECT_OTSTUTSVUET' "$w/e8" || { printf 'd16: нет OBJECT_OTSTUTSVUET\n' >&2; return 1; }
  jq -n --arg t "SUBJECT=199
OBJECT=$SW_OBJ
OBJECT=$NUL" '{tasks:[{agent:"critic",name:"G5",task:$t}]}' > "$w/ev9.json"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/ev9.json" >/dev/null 2>"$w/e9"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd16: два OBJECT rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'SUBEKT_DVA_OBJECTA' "$w/e9" || { printf 'd16: нет SUBEKT_DVA_OBJECTA\n' >&2; return 1; }
}

d17() {  # судейские ворота двери: именованные отказы до START и записей
  local w="$WBASE/d17"; mkdir -p "$w"
  local rc NUL; NUL=0000000000000000000000000000000000000000
  mk_sud_world "$w/a" 'КЛАСС РИСКА: обычный' 1
  sud_event "$w/a/ev.json" critic 205 "$SW_OBJ"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/a/ev.json" >/dev/null 2>"$w/e1"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd17: судья предмета без рабочего rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'RABOCHEGO_NET' "$w/e1" || { printf 'd17: нет RABOCHEGO_NET\n' >&2; return 1; }
  mk_sud_world "$w/b" 'КЛАСС РИСКА: обычный' 0
  sud_event "$w/b/ev.json" critic 199 "$SW_OBJ"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/b/ev.json" >/dev/null 2>"$w/e2"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd17: судья при несдавшем авторе rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'AVTOR_ESHCHO_RABOTAET' "$w/e2" || { printf 'd17: нет AVTOR_ESHCHO_RABOTAET\n' >&2; return 1; }
  mk_sud_world "$w/c" 'КЛАСС РИСКА: обычный' 1 /netu-d17
  sud_event "$w/c/ev.json" critic 199 "$SW_OBJ"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/c/ev.json" >/dev/null 2>"$w/e3"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd17: носитель рабочего нечитаем rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'VETKA_NEDOSTUPNA' "$w/e3" || { printf 'd17: нет VETKA_NEDOSTUPNA\n' >&2; return 1; }
  mk_sud_world "$w/d" 'КЛАСС РИСКА: обычный' 1
  sud_event "$w/d/ev.json" critic 199 "$NUL"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/d/ev.json" >/dev/null 2>"$w/e4"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd17: OBJECT ≠ tip rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'OBJECT_RASHODITSJA' "$w/e4" || { printf 'd17: нет OBJECT_RASHODITSJA\n' >&2; return 1; }
  mk_sud_world "$w/e" '-' 1
  sud_event "$w/e/ev.json" critic 199 "$SW_OBJ"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/e/ev.json" >/dev/null 2>"$w/e5"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd17: без строки класса риска rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'KLASS_RISKA_NET' "$w/e5" || { printf 'd17: нет KLASS_RISKA_NET\n' >&2; return 1; }
  mk_sud_world "$w/f" 'КЛАСС РИСКА: рисковый' 1
  sud_event "$w/f/ev.json" reviewer 199 "$SW_OBJ"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/f/ev.json" >/dev/null 2>"$w/e7"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'd17: reviewer на рисковом rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'ADVERSARIJ_DO_REVJUERA' "$w/e7" || { printf 'd17: нет ADVERSARIJ_DO_REVJUERA\n' >&2; return 1; }
  sud_event "$w/f/ev2.json" critic 199 "$SW_OBJ"
  bash "$(dver)" --sudit --sostojanie "$SW_SOST" --zhurnaly "$SW_ZHUR" --repo "$SW_MAIN" "$w/f/ev2.json" >/dev/null 2>"$w/e6"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'd17: critic на рисковом rc=%s (нужен 0: порядок запрещает только ревьюера): %s\n' "$rc" "$(tail -1 "$w/e6")" >&2; return 1; }
}

d18() {  # [Adv199-impl-1, находка 1; Adv199-impl-2, К-08; Arb199Impl, К-10]
  # isolated двери — СТРОГО булево true: строка "true", 1, [true], {x:true},
  # null, false и отсутствие поля — НЕ изоляция: rc 1 NE_IZOLIROVAN и учёт
  # ПОБАЙТОВО неизменен — полный снимок содержимого ДО вызова сравнивается
  # cmp НЕМЕДЛЕННО после отказа (запись в учёт без перевода строки счётчику
  # строк невидима — К-10); только булево true — rc 0, START несёт
  # "isolated":true. КАЖДАЯ форма — НЕЗАВИСИМЫЙ прогон без раннего выхода
  # (Н-39/К-08: двойной дефект стаба маскировался чужой строковой формой —
  # d18 краснела на первой и до числа не доходила); все ошибочные формы
  # собираются в ОДНО сообщение с именем каждой: стаб s19 краснеет только
  # формой "true", s20 — только формой 1.
  local w="$WBASE/d18"; mkdir -p "$w"; mk_dwer_world "$w"
  local v rc pred posle oshibki=''
  for v in '"true"' '1' '[true]' '{"x":true}' 'null' 'false' 'net-polja'; do
    if [ "$v" = 'net-polja' ]; then
      jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD18",task:$t}]}' > "$w/ev.json"
    else
      jq -n --argjson iso "$v" --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD18",task:$t,isolated:$iso}]}' > "$w/ev.json"
    fi
    # оракул ДО вызова субъекта (правило 8): полный БАЙТОВЫЙ снимок учёта
    # ВНЕ файла учёта (снимок ничего не пишет в проверяемый учёт);
    # отсутствующий учёт представлен пустым содержимым (Arb199Impl, РЕШЕНИЕ 2)
    if [ -f "$DW_SOST/uchet.jsonl" ]; then cp "$DW_SOST/uchet.jsonl" "$w/uchet-do"; else : > "$w/uchet-do"; fi
    bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
    if [ "$rc" -ne 1 ]; then oshibki="${oshibki}isolated=${v}:rc=${rc};"; continue; fi
    grep -q 'NE_IZOLIROVAN' "$w/err" || oshibki="${oshibki}isolated=${v}:нет-NE_IZOLIROVAN;"
    # побайтовое сравнение СРАЗУ после отказа: cmp, НЕ счётчик строк;
    # пропавший непустой учёт снимку тоже не равен; проверка не заходит
    # за следующий вызов двери и позитивный контроль
    if [ -f "$DW_SOST/uchet.jsonl" ]; then
      cmp -s "$w/uchet-do" "$DW_SOST/uchet.jsonl" || oshibki="${oshibki}isolated=${v}:учёт-изменён-побайтово;"
    else
      [ ! -s "$w/uchet-do" ] || oshibki="${oshibki}isolated=${v}:учёт-исчез;"
    fi
  done
  if [ -f "$DW_SOST/uchet.jsonl" ]; then pred="$(wc -l < "$DW_SOST/uchet.jsonl")"; else pred=0; fi
  jq -n --arg t "SUBJECT=199
WORKTREE=$DW_CAR
BRANCH=wip/199/architect" '{tasks:[{agent:"architect",name:"ArchD18",task:$t,isolated:true}]}' > "$w/ev.json"
  bash "$(dver)" --sudit --sostojanie "$DW_SOST" --zhurnaly "$DW_ZHUR" --repo "$DW_MAIN" "$w/ev.json" >/dev/null 2>"$w/err"; rc=$?
  if [ "$rc" -eq 0 ]; then
    if [ -f "$DW_SOST/uchet.jsonl" ]; then posle="$(wc -l < "$DW_SOST/uchet.jsonl")"; else posle=0; fi
    [ "$((posle - pred))" -eq 1 ] || oshibki="${oshibki}булево-true:START-не-дописан(${pred}-${posle});"
    tail -n 1 "$DW_SOST/uchet.jsonl" | jq -e 'select(.t == "START" and .isolated == true)' >/dev/null 2>&1 \
      || oshibki="${oshibki}булево-true:START-без-isolated:true;"
  else
    oshibki="${oshibki}булево-true:rc=${rc};"
  fi
  [ -z "$oshibki" ] || { printf 'd18: формы-не-изоляции не отвергнуты (нужен rc1+NE_IZOLIROVAN и побайтово неизменный учёт): %s\n' "$oshibki" >&2; return 1; }
}


h_kletka() {  # <id> <item-json> <want-isolated>
  local w="$WBASE/$1"
  mkdir -p "$w"
  mk_huk_world "$w"
  jq -n --argjson item "$2" --arg id "$1" \
    '[{name:$id,want:"pass",event:{type:"tool_call",toolName:"task",toolCallId:$id,input:{context:"p",tasks:[$item]}}}]' \
    > "$w/cases.json"
  local rc
  S199_RECORD="$w/record.json" node "$w/driver.mjs" "$w/inst/.omp/extensions/spawn-guard.ts" \
    "$w/cases.json" "$w/proj" "$w/zones/z/agent/sessions/S1.jsonl" >"$w/out" 2>"$w/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf '%s: драйвер rc=%s %s\n' "$1" "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ -f "$w/record.json" ] || { printf '%s: событие не дошло до двери\n' "$1" >&2; return 1; }
  jq -e --argjson want "$3" '.tasks[0].isolated == $want' "$w/record.json" >/dev/null 2>&1 \
    || { printf '%s: isolated в событии ≠ %s: %s\n' "$1" "$3" "$(cat "$w/record.json")" >&2; return 1; }
}
h1() { h_kletka h1 '{"name":"H1","agent":"architect","task":"SUBJECT=199\nWORKTREE=/netu\nBRANCH=wip/199/architect","isolated":true}' true; }
h2() { h_kletka h2 '{"name":"H2","agent":"architect","task":"SUBJECT=199\nWORKTREE=/netu\nBRANCH=wip/199/architect\nisolated:true","isolated":false}' false; }
h3() { h_kletka h3 '{"name":"H3","agent":"architect","task":"SUBJECT=199\nWORKTREE=/netu\nBRANCH=wip/199/architect"}' false; }
h4() {  # [Adv199-impl-1, находка 2] нормализация стража — === true, НЕ truthy:
  # событие, дошедшее до двери, несёт isolated БУЛЕВО: строка "true", 1,
  # [true], {x:true}, null и отсутствие поля → false; только булево true →
  # true. Truthy-мутант (!!o.isolated) строку/число/массив/объект проносит
  # как true — красный здесь (дверь-двойник ДОБАВЛЯЕТ события, не перезаписывает).
  local w="$WBASE/h4"; mkdir -p "$w"; mk_huk_world "$w"
  jq -n --arg t 'SUBJECT=199
WORKTREE=/netu
BRANCH=wip/199/architect' '
  [["bool-true",true],["str-true","true"],["num-1",1],["arr",[true]],
   ["obj",{"x":true}],["null",null],["absent","ABSENT"]]
  | map(. as [$nm, $val] |
      { name: ("h4-" + $nm), want: "pass",
        event: { type: "tool_call", toolName: "task", toolCallId: ("h4-" + $nm),
                 input: { context: "p", tasks: [
                   (if $val == "ABSENT"
                    then {name:"H4", agent:"architect", task:$t}
                    else {name:"H4", agent:"architect", task:$t, isolated:$val} end)
                 ] } } })' > "$w/cases.json"
  local rc
  S199_RECORD="$w/record.json" node "$w/driver.mjs" "$w/inst/.omp/extensions/spawn-guard.ts" \
    "$w/cases.json" "$w/proj" "$w/zones/z/agent/sessions/S1.jsonl" >"$w/out" 2>"$w/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'h4: драйвер rc=%s %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ -f "$w/record.json" ] || { printf 'h4: события не дошли до двери\n' >&2; return 1; }
  jq -cse 'map(.tasks[0].isolated) == [true,false,false,false,false,false,false]' "$w/record.json" >/dev/null 2>&1 \
    || { printf 'h4: нормализация ≠ === true (порядок bool/str/1/arr/obj/null/absent): %s\n' \
         "$(jq -cs 'map(.tasks[0].isolated)' "$w/record.json" 2>/dev/null)" >&2; return 1; }
}

p1() {
  local w="$WBASE/p1"; mkdir -p "$w"; mk_priv_world "$w"
  local out rc
  out="$(zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
        --branch wip/199/architect --author architect --tip "$PW_TIP" 2>"$w/err")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'p1: rc=%s %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ "$out" = "root=$PW_MAIN_ABS" ] || { printf 'p1: вывод %s ≠ root=%s\n' "$out" "$PW_MAIN_ABS" >&2; return 1; }
}
p2() {
  local w="$WBASE/p2"; mkdir -p "$w"; mk_priv_world "$w"
  local rc; zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
    --branch wip/199/implementer --author architect --tip "$PW_TIP" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p2: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'VETKA_RASHODITSJA' "$w/err" || { printf 'p2: нет VETKA_RASHODITSJA\n' >&2; return 1; }
}
p3() {
  local w="$WBASE/p3"; mkdir -p "$w"; mk_priv_world "$w"
  local rc; zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
    --branch wip/199/architect --author implementer --tip "$PW_TIP" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p3: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'ROL_RASHODITSJA' "$w/err" || { printf 'p3: нет ROL_RASHODITSJA\n' >&2; return 1; }
}
p4() {
  local w="$WBASE/p4"; mkdir -p "$w"; mk_priv_world "$w"
  local rc t2; t2="$(git -C "$PW_M2" rev-parse HEAD)"
  zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M2" \
    --branch wip/199/architect --author architect --tip "$t2" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p4: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'KOPIJA_CHUZHAYA' "$w/err" || { printf 'p4: нет KOPIJA_CHUZHAYA\n' >&2; return 1; }
}
p5() {
  local w="$WBASE/p5"; mkdir -p "$w"; mk_priv_world "$w"
  local rc; zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
    --branch wip/199/architect --author architect --tip 0000000000000000000000000000000000000000 >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p5: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'TIP_RASHODITSJA' "$w/err" || { printf 'p5: нет TIP_RASHODITSJA\n' >&2; return 1; }
}
p6() {
  local w="$WBASE/p6"; mkdir -p "$w"; mk_priv_world "$w"
  local rc; zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 198 --source "$PW_M" \
    --branch wip/199/architect --author architect >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p6: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'SDACHA_NET_START' "$w/err" || { printf 'p6: нет SDACHA_NET_START\n' >&2; return 1; }
}
p7() {
  local w="$WBASE/p7"; mkdir -p "$w"; mk_priv_world "$w"
  local rc; zov_priv --sostojanie "$PW_SOST" --repo "$PW_DRUG" --subject 199 --source "$PW_M" \
    --branch wip/199/architect --author architect --tip "$PW_TIP" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p7: rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'REPO_RASHODITSJA' "$w/err" || { printf 'p7: нет REPO_RASHODITSJA\n' >&2; return 1; }
}

p8() {
  local w="$WBASE/p8"; mkdir -p "$w"; mk_rot_world "$w"
  local rc; zov_priv --sostojanie "$ROT_SOST" --repo "$ROT_MAIN_NEW" --subject 199 --source "$ROT_M_OLD" \
    --branch wip/199/architect --author architect --tip "$ROT_TIP_OLD" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p8: rc=%s (нужен 1: сдача прежнего держателя после ротации)\n' "$rc" >&2; return 1; }
  grep -q 'KOPIJA_CHUZHAYA' "$w/err" || { printf 'p8: нет KOPIJA_CHUZHAYA (сверка с последним START)\n' >&2; return 1; }
}

p9() {
  local w="$WBASE/p9"; mkdir -p "$w"; mk_rot_world "$w"
  local out rc
  out="$(zov_priv --sostojanie "$ROT_SOST" --repo "$ROT_MAIN_NEW" --subject 199 --source "$ROT_M_NEW" \
        --branch wip/199/architect --author architect --tip "$ROT_TIP_NEW" 2>"$w/err")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'p9: rc=%s — сдача нового держателя не принята: %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ "$out" = "root=$ROT_MAIN_NEW_ABS" ] || { printf 'p9: корень приёма %s ≠ root из последнего факта замка %s\n' "$out" "$ROT_MAIN_NEW_ABS" >&2; return 1; }
}

p10() {  # блок (б) вердикта Crit199V2: --repo = ДРУГАЯ копия того же origin (repoId равен) —
  # корень приёма обязан выводиться из ФАКТА START, а не из --repo
  local w="$WBASE/p10"; mkdir -p "$w"; mk_priv_world "$w"
  local out rc
  out="$(zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN_B" --subject 199 --source "$PW_M" \
        --branch wip/199/architect --author architect --tip "$PW_TIP" 2>"$w/err")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'p10: rc=%s %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ "$out" = "root=$PW_MAIN_ABS" ] || { printf 'p10: корень %s ≠ root из факта START %s (--repo = другая копия того же origin)\n' "$out" "root=$PW_MAIN_ABS" >&2; return 1; }
}

p11() {  # блок (в): строка START судьи НОВЕЕ рабочего — сверка идёт с последним РАБОЧИМ
  local w="$WBASE/p11"; mkdir -p "$w"; mk_priv_world "$w"
  local O out rc; O="$(git -C "$PW_MAIN" rev-parse main)"
  jq -nc --arg r toyrepo --arg s 199 --arg h CritP11 --arg ro critic --arg o "$O" \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"sudja",rol:$ro,object:$o,worktree:"-",branch:"-",at:"2026-11-16T05:00:00Z",isolated:false}' \
    >> "$PW_SOST/uchet.jsonl"
  out="$(zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
        --branch wip/199/architect --author architect --tip "$PW_TIP" 2>"$w/err")"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'p11: rc=%s — честная сдача рабочего заблокирована после визита судьи: %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ "$out" = "root=$PW_MAIN_ABS" ] || { printf 'p11: корень %s ≠ %s\n' "$out" "root=$PW_MAIN_ABS" >&2; return 1; }
}

p12() {  # блок (г): START рабочего БЕЗ поля isolated (наследие сегодняшней двери) — приём не связан
  local w="$WBASE/p12"; mkdir -p "$w"; mk_priv_world "$w"
  jq -c 'del(.isolated)' "$PW_SOST/uchet.jsonl" > "$w/u2" && mv "$w/u2" "$PW_SOST/uchet.jsonl"
  local rc; zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
    --branch wip/199/architect --author architect --tip "$PW_TIP" >/dev/null 2>"$w/err"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p12: rc=%s (нужен 1: START без isolated — приём из копии не связан)\n' "$rc" >&2; return 1; }
  grep -q 'NE_IZOLIROVAN' "$w/err" || { printf 'p12: нет NE_IZOLIROVAN\n' >&2; return 1; }
}

p13() {  # предусловия/имена привязки: rc2 до сверки; NE_REPO; KOPIJA без owner.json; NOSITEL_NEDOSTUPEN
  local w="$WBASE/p13"; mkdir -p "$w"; mk_priv_world "$w"
  mkdir -p "$w/notrepo" "$w/plain" "$w/kopbez"
  mkrepo "$w/kopbez/m"
  local rc
  zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --source "$PW_M" \
    --branch wip/199/architect --author architect >/dev/null 2>"$w/e1"; rc=$?
  [ "$rc" -eq 2 ] || { printf 'p13: без --subject rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
    --branch wip/199/architect >/dev/null 2>"$w/e2"; rc=$?
  [ "$rc" -eq 2 ] || { printf 'p13: без --author rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  zov_priv --sostojanie "$w/netsost" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
    --branch wip/199/architect --author architect >/dev/null 2>"$w/e3"; rc=$?
  [ "$rc" -eq 2 ] || { printf 'p13: состояния нет rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  zov_priv --sostojanie "$PW_SOST" --repo "$w/notrepo" --subject 199 --source "$PW_M" \
    --branch wip/199/architect --author architect >/dev/null 2>"$w/e4"; rc=$?
  [ "$rc" -eq 2 ] || { printf 'p13: --repo не-репозиторий rc=%s (нужен 2)\n' "$rc" >&2; return 1; }
  zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$w/plain" \
    --branch wip/199/architect --author architect >/dev/null 2>"$w/e5"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p13: источник не-репозиторий rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'NE_REPO' "$w/e5" || { printf 'p13: нет NE_REPO\n' >&2; return 1; }
  zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$w/kopbez/m" \
    --branch wip/199/architect --author architect >/dev/null 2>"$w/e6"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p13: копия без owner.json rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'KOPIJA_CHUZHAYA' "$w/e6" || { printf 'p13: нет KOPIJA_CHUZHAYA (нет .omp-isolation-owner.json рядом)\n' >&2; return 1; }
  jq -c '.worktree="/netu-p13"' "$PW_SOST/uchet.jsonl" > "$w/u2" && mv "$w/u2" "$PW_SOST/uchet.jsonl"
  zov_priv --sostojanie "$PW_SOST" --repo "$PW_MAIN" --subject 199 --source "$PW_M" \
    --branch wip/199/architect --author architect --tip "$PW_TIP" >/dev/null 2>"$w/e7"; rc=$?
  [ "$rc" -eq 1 ] || { printf 'p13: носитель факта недоступен rc=%s (нужен 1)\n' "$rc" >&2; return 1; }
  grep -q 'NOSITEL_NEDOSTUPEN' "$w/e7" || { printf 'p13: нет NOSITEL_NEDOSTUPEN\n' >&2; return 1; }
}

p14() {  # [Adv199-impl-1, находка 3] флаг последним аргументом БЕЗ значения —
  # rc 2 «нет обязательного аргумента» ДО любых сверок, stderr с причиной, БЕЗ
  # bash-диагностики «parameter null or not set» (rc 1) — для КАЖДОГО
  # обязательного флага и факультативного --tip (мутант rc 2 → rc 1 красен).
  local w="$WBASE/p14"; mkdir -p "$w"; mk_priv_world "$w"
  local f rc a
  for f in --sostojanie --repo --subject --source --branch --author --tip; do
    a=()
    [ "$f" != --sostojanie ] && a+=(--sostojanie "$PW_SOST")
    [ "$f" != --repo ]       && a+=(--repo "$PW_MAIN")
    [ "$f" != --subject ]    && a+=(--subject 199)
    [ "$f" != --source ]     && a+=(--source "$PW_M")
    [ "$f" != --branch ]     && a+=(--branch wip/199/architect)
    [ "$f" != --author ]     && a+=(--author architect)
    [ "$f" != --tip ]        && a+=(--tip "$PW_TIP")
    a+=("$f")
    zov_priv "${a[@]}" >/dev/null 2>"$w/err"; rc=$?
    [ "$rc" -eq 2 ] || { printf 'p14: %s без значения rc=%s (нужен 2)\n' "$f" "$rc" >&2; return 1; }
    [ -s "$w/err" ] || { printf 'p14: %s без значения — stderr пуст, причины нет\n' "$f" >&2; return 1; }
    if grep -q 'parameter null or not set' "$w/err"; then
      printf 'p14: %s без значения — bash-диагностика вместо именованного отказа\n' "$f" >&2; return 1
    fi
  done
}


w1() {
  local w="$WBASE/w1"; mkdir -p "$w"; mk_wip_world "$w" 1
  local A2 A0 rc
  A2="$(git -C "$WW_MAIN" rev-parse wip/199/architect)"
  A0="$(git -C "$WW_MAIN" rev-parse main)"
  izvlek "$(vstavka)" '# 199-baza-nachalo' '# 199-baza-konec' "$w/blk.sh" \
    || { printf 'w1: канонический блок синхробазы отсутствует в субъекте\n' >&2; return 1; }
  ( cd "$WW_M" && WORKTREE="$WW_CAR" BRANCH=wip/199/architect bash "$w/blk.sh" ) >"$w/out" 2>"$w/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'w1: блок rc=%s %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ "$(git -C "$WW_M" rev-parse HEAD)" = "$A2" ] || { printf 'w1: копия не на авторском tip\n' >&2; return 1; }
  [ "$(git -C "$WW_M" rev-parse --abbrev-ref HEAD)" = 'wip/199/architect' ] || { printf 'w1: ветка не переключена\n' >&2; return 1; }
  [ "$(git -C "$WW_MAIN" rev-parse main)" = "$A0" ] || { printf 'w1: main изменился\n' >&2; return 1; }
  [ -z "$(git -C "$WW_CAR" status --porcelain)" ] || { printf 'w1: носитель загрязнён\n' >&2; return 1; }
}
w2() {
  local w="$WBASE/w2"; mkdir -p "$w"; mk_wip_world "$w" 0
  local T0 rc
  T0="$(git -C "$WW_MAIN" rev-parse wip/199/architect)"
  izvlek "$(vstavka)" '# 199-baza-nachalo' '# 199-baza-konec' "$w/blk.sh" \
    || { printf 'w2: канонический блок синхробазы отсутствует\n' >&2; return 1; }
  ( cd "$WW_M" && WORKTREE="$WW_CAR" BRANCH=wip/199/architect bash "$w/blk.sh" ) >"$w/out" 2>"$w/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'w2: блок rc=%s\n' "$rc" >&2; return 1; }
  [ "$(git -C "$WW_M" rev-parse HEAD)" = "$T0" ] || { printf 'w2: копия не на tip ветки\n' >&2; return 1; }
  [ "$(git -C "$WW_M" rev-parse --abbrev-ref HEAD)" = 'wip/199/architect' ] || { printf 'w2: ветка не переключена\n' >&2; return 1; }
}

c1() {
  local w="$WBASE/c1"; mkdir -p "$w"; mk_car_world "$w"
  local MAIN0 rc
  MAIN0="$(git -C "$CW_MAIN" rev-parse HEAD)"
  izvlek "$(vstavka)" '# 199-nositel-nachalo' '# 199-nositel-konec' "$w/blk.sh" \
    || { printf 'c1: канонический блок приёма отсутствует в субъекте\n' >&2; return 1; }
  ( WORKTREE="$CW_CAR" SOURCE="$CW_M" BRANCH=wip/199/architect AUTHOR=architect \
    ACCEPT="$ACCEPT" ROOT="$CW_MAIN" bash "$w/blk.sh" ) >"$w/out" 2>"$w/err"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'c1: блок приёма rc=%s %s\n' "$rc" "$(tail -1 "$w/err")" >&2; return 1; }
  [ "$(git -C "$CW_MAIN" rev-parse HEAD)" = "$MAIN0" ] || { printf 'c1: HEAD основного репо изменился\n' >&2; return 1; }
  [ -z "$(git -C "$CW_MAIN" status --porcelain)" ] || { printf 'c1: основной репо загрязнён\n' >&2; return 1; }
  [ -z "$(git -C "$CW_CAR" status --porcelain)" ] || { printf 'c1: носитель не синхронизирован с принятым tip\n' >&2; return 1; }
  grep -q 'child' "$CW_CAR/child.txt" 2>/dev/null || { printf 'c1: файлы носителя не на принятом tip\n' >&2; return 1; }
  [ "$(git -C "$CW_CAR" rev-parse HEAD)" = "$(git -C "$CW_MAIN" rev-parse wip/199/architect)" ] \
    || { printf 'c1: HEAD носителя ≠ принятому tip\n' >&2; return 1; }
}
c2() {
  local w="$WBASE/c2"; mkdir -p "$w"; mk_car_world "$w"
  local rc sum0 B0
  B0="$(git -C "$CW_MAIN" rev-parse wip/199/architect)"
  printf 'dirty\n' >> "$CW_CAR/f.txt"
  sum0="$(sha256sum "$CW_CAR/f.txt" | cut -d' ' -f1)"
  izvlek "$(vstavka)" '# 199-nositel-nachalo' '# 199-nositel-konec' "$w/blk.sh" \
    || { printf 'c2: канонический блок приёма отсутствует\n' >&2; return 1; }
  ( WORKTREE="$CW_CAR" SOURCE="$CW_M" BRANCH=wip/199/architect AUTHOR=architect \
    ACCEPT="$ACCEPT" ROOT="$CW_MAIN" bash "$w/blk.sh" ) >"$w/out" 2>"$w/err"; rc=$?
  [ "$rc" -ne 0 ] || { printf 'c2: грязный носитель «вылечен» без отказа\n' >&2; return 1; }
  [ "$(sha256sum "$CW_CAR/f.txt" | cut -d' ' -f1)" = "$sum0" ] || { printf 'c2: грязные байты носителя потеряны\n' >&2; return 1; }
  [ "$(git -C "$CW_MAIN" rev-parse wip/199/architect)" = "$B0" ] || { printf 'c2: приём исполнился вопреки стопу\n' >&2; return 1; }
}

g1() {
  local w="$WBASE/g1"; mkdir -p "$w"; mk_wip_world "$w" 1
  local A2 A0 rc
  A2="$(git -C "$WW_MAIN" rev-parse wip/199/architect)"
  A0="$(git -C "$WW_MAIN" rev-parse main)"
  izvlek "$(vstavka)" '# 199-baza-nachalo' '# 199-baza-konec' "$w/blk.sh" \
    || { printf 'g1: канонический блок синхробазы отсутствует\n' >&2; return 1; }
  ( cd "$WW_M" && WORKTREE="$WW_CAR" BRANCH=wip/199/architect bash "$w/blk.sh" ) >/dev/null 2>&1; rc=$?
  [ "$rc" -eq 0 ] || { printf 'g1: блок rc=%s\n' "$rc" >&2; return 1; }
  printf 'g\n' > "$WW_M/g.txt"
  commit_as "$WW_M" architect 'g'
  [ "$(git -C "$WW_M" rev-parse HEAD)" != "$A2" ] || { printf 'g1: коммит в копии не прошёл\n' >&2; return 1; }
  [ "$(git -C "$WW_MAIN" rev-parse main)" = "$A0" ] || { printf 'g1: main изменился от git в копии\n' >&2; return 1; }
  [ -z "$(git -C "$WW_MAIN" status --porcelain)" ] || { printf 'g1: main загрязнён\n' >&2; return 1; }
  [ "$(git -C "$WW_MAIN" rev-parse wip/199/architect)" = "$A2" ] || { printf 'g1: ветка носителя изменилась\n' >&2; return 1; }
  [ -z "$(git -C "$WW_CAR" status --porcelain)" ] || { printf 'g1: носитель загрязнён\n' >&2; return 1; }
}
g2() {
  grep -Fq 'apply: false' "$ROOT/.omp/config.yml" \
    || { printf 'g2: task.isolation.apply ≠ false\n' >&2; return 1; }
}

f1() {
  mk_fajl_world
  f_sud "{\"tool\":\"write\",\"args\":{\"path\":\"$FH_COPY/f1.txt\"},\"worktree\":\"$FH_PIN\",\"skipActualCheck\":true,\"sessionName\":\"OwnerF1\",\"sessionCwd\":\"$FH_COPY\"}" pass \
    || { printf 'f1: запись в свою копию при пине не pass\n' >&2; return 1; }
}
f2() {
  mk_fajl_world
  f_sud "{\"tool\":\"write\",\"args\":{\"path\":\"$FH_MAINLIKE/f2.txt\"},\"worktree\":\"$FH_PIN\",\"skipActualCheck\":true,\"sessionName\":\"OwnerF1\",\"sessionCwd\":\"$FH_COPY\"}" block \
    || { printf 'f2: запись в основной чекаут не block\n' >&2; return 1; }
}
f3() {
  mk_fajl_world
  f_sud "{\"tool\":\"write\",\"args\":{\"path\":\"$FH_COPY2/f3.txt\"},\"worktree\":\"$FH_PIN\",\"skipActualCheck\":true,\"sessionName\":\"OwnerF1\",\"sessionCwd\":\"$FH_COPY2\"}" block \
    || { printf 'f3: чужая копия (owner.id ≠ sessionName) не block\n' >&2; return 1; }
}

t1() {
  grep -Fq 'адрес доставки' "$(shapka)" 2>/dev/null \
    && grep -Fq 'не повторное создание' "$(shapka)" 2>/dev/null \
    || { printf 't1: шапка spawn_agent.sh без якорей доставки/продолжения\n' >&2; return 1; }
}
t2() {
  grep -Fq 'Жизненный цикл изолированных копий' "$(readme)" 2>/dev/null \
    && grep -Fq 'retention' "$(readme)" 2>/dev/null \
    || { printf 't2: ops/server/README.md без раздела жизненного цикла/retention\n' >&2; return 1; }
}

# ── учёт клеток ──────────────────────────────────────────────────────────────
ALL_KLETKI='d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 h1 h2 h3 h4 p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 w1 w2 c1 c2 g1 g2 f1 f2 f3 t1 t2'
CELL_TOTAL=0; CELL_RED=0; CELL_MISS=0
kletka() {  # <id> — ОДИН прогон клетки; диагностика — в файл мира
  local id="$1" dg
  dg="$WB/${S199_TAG:-osn}.diag-$id"
  CELL_TOTAL=$((CELL_TOTAL + 1))
  WBASE="$WB/${S199_TAG:-osn}"
  mkdir -p "$WBASE"
  if "$id" >/dev/null 2>"$dg"; then
    printf 'ok   %s\n' "$id"
  else
    CELL_RED=$((CELL_RED + 1))
    printf 'FAIL %s — %s\n' "$id" "$(grep -aE '^[a-z0-9]+: ' "$dg" | sed -n '1p')"
  fi
}

run_cells() {  # <ids…>
  local id
  for id in "$@"; do
    kletka "$id"
  done
}

# ── стабы: привязка к различающим входам — КОДОМ (Н-39) ─────────────────────
# census: stabs/ = 18 (замер контракта 199), stabs_adv1/ = 4 (доп. стабы
# замыкания Adv199Impl); движок --stabs гоняет все 22 из обоих каталогов.
STABI=(s01 s02 s03 s04 s05 s06 s07 s08 s09 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22)
stab_fajl() {
  case "$1" in
    s01) printf 'stabs/s01_dver_slovo.sh' ;;
    s02) printf 'stabs/s02_dver_bez_pina.sh' ;;
    s03) printf 'stabs/s03_dver_bez_izo.sh' ;;
    s04) printf 'stabs/s04_huk_drop.ts' ;;
    s05) printf 'stabs/s05_huk_slovo.ts' ;;
    s06) printf 'stabs/s06_priv_avtor.sh' ;;
    s07) printf 'stabs/s07_priv_tip.sh' ;;
    s08) printf 'stabs/s08_vstavka_ot_main.md' ;;
    s09) printf 'stabs/s09_vstavka_staryj_snapshot.md' ;;
    s10) printf 'stabs/s10_vstavka_nositel_skip.md' ;;
    s11) printf 'stabs/s11_vstavka_nositel_force.md' ;;
    s12) printf 'stabs/s12_priv_bez_repo.sh' ;;
    s13) printf 'stabs/s13_dver_paket_nol.sh' ;;
    s14) printf 'stabs/s14_priv_pervyj.sh' ;;
    s15) printf 'stabs/s15_dver_paket_poslednij.sh' ;;
    s16) printf 'stabs/s16_priv_repo_root.sh' ;;
    s17) printf 'stabs/s17_priv_bez_klass.sh' ;;
    s18) printf 'stabs/s18_priv_bez_iso.sh' ;;
    s19) printf 'stabs_adv1/s19_dver_iso_strokoj.sh' ;;
    s20) printf 'stabs_adv1/s20_dver_iso_chislom.sh' ;;
    s21) printf 'stabs_adv1/s21_huk_truthy.ts' ;;
    s22) printf 'stabs_adv1/s22_priv_bez_znachenija.sh' ;;
  esac
}
stub_sreda() {  # <sNN> — переменная-шов субъекта
  case "$1" in
    s01|s02|s03|s13|s15|s19|s20) printf 'S199_DOOR' ;;
    s04|s05|s21)     printf 'S199_GUARD' ;;
    s06|s07|s12|s14|s16|s17|s18|s22) printf 'S199_PRIV' ;;
    s08|s09|s10|s11) printf 'S199_VSTAVKA' ;;
  esac
}
stab_kletki() {
  case "$1" in
    s01) printf 'd4' ;;
    s02) printf 'd6 d7' ;;
    s03) printf 'd2 d3' ;;
    s04) printf 'h1 h2' ;;
    s05) printf 'h2' ;;
    s06) printf 'p2 p4' ;;
    s07) printf 'p2 p4' ;;
    s08) printf 'w1' ;;
    s09) printf 'w1' ;;
    s10) printf 'c1' ;;
    s11) printf 'c2' ;;
    s12) printf 'p7' ;;
    s13) printf 'd9 d10' ;;
    s14) printf 'p8 p9' ;;
    s15) printf 'd11 d12' ;;
    s16) printf 'p10' ;;
    s17) printf 'p11' ;;
    s18) printf 'p12' ;;
    s19) printf 'd18' ;;
    s20) printf 'd18' ;;
    s21) printf 'h4' ;;
    s22) printf 'p14' ;;
  esac
}

itog() {  # <режим>
  printf 'ИТОГ 199 (%s): клеток %d, красных %d, зелёных %d\n' \
    "$1" "$CELL_TOTAL" "$CELL_RED" "$((CELL_TOTAL - CELL_RED))"
}

case "$MODE" in
  osn)
    run_cells $ALL_KLETKI
    itog 'субъекты дерева'
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'КРАСНОЕ 199: красных %d из %d (до реализации ожидаемо; после — дефект)\n' "$CELL_RED" "$CELL_TOTAL"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 199\n'
    exit 0
    ;;
  model)
    run_cells $ALL_KLETKI
    itog 'модели-эталоны'
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'КРАСНОЕ 199-model: модели не покрывают клетки: красных %d из %d\n' "$CELL_RED" "$CELL_TOTAL"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 199-model\n'
    exit 0
    ;;
  stabs)
    run_cells $ALL_KLETKI >/dev/null
    if [ "$CELL_RED" -gt 0 ]; then
      printf 'NOT_IMPLEMENTED: контроль над моделями красный (%d клеток) — оракул не зелён, стабы не судятся\n' "$CELL_RED" >&2
      exit 2
    fi
    CELL_TOTAL=0; CELL_RED=0
    POJMANO=0; ZHIVYH=0
    for s in "${STABI[@]}"; do
      sf="$HERE/$(stab_fajl "$s")"
      [ -f "$sf" ] || { printf 'NOT_IMPLEMENTED: стаб отсутствует: %s\n' "$sf" >&2; exit 2; }
      sr="$(stub_sreda "$s")"
      sk="$(stab_kletki "$s")"
      export "$sr=$sf" S199_TAG="$s"
      run_cells $sk >/dev/null
      if [ "$CELL_RED" -gt 0 ]; then
        POJMANO=$((POJMANO + 1))
        printf 'СТАБ 199: %s ПОЙМАН (клеток %d, красных %d)\n' "$s" "$CELL_TOTAL" "$CELL_RED"
      else
        ZHIVYH=$((ZHIVYH + 1))
        printf 'СТАБ 199: %s ЖИВ — все клетки зелёны (клеток %d)\n' "$s" "$CELL_TOTAL"
      fi
      unset "$sr" S199_TAG
      CELL_TOTAL=0; CELL_RED=0
    done
    printf 'СТАБЫ 199: всего %d, поймано %d, живых %d\n' "${#STABI[@]}" "$POJMANO" "$ZHIVYH"
    if [ "$ZHIVYH" -gt 0 ]; then
      printf 'КРАСНОЕ 199-stabs: живой стаб не различим клетками: %d\n' "$ZHIVYH"
      exit 1
    fi
    printf 'ЗЕЛЕНОЕ 199-stabs\n'
    exit 0
    ;;
esac
printf 'NOT_IMPLEMENTED: неизвестный режим %s\n' "$MODE" >&2
exit 2
