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
#     флаг isolated:true (поле события спавна, НЕ слово в task) — в ЛЮБОЙ
#     позиции пакета: отказ NE_IZOLIROVAN на item ≥1 до START и любых
#     записей (в учёте не появляется ни одна строка пакета); START
#     записывает факт isolated; грамматика пина не ослабляется (клетки
#     d1–d10, h1–h3; d9-d10 — пакетный вход с рабочим НЕ первым
#     элементом, закрывают «гейт только item 0»);
#   * привязка сдачи (scripts/privjazka_sdachi.sh): сверка source/ветка/
#     роль/предмет/репозиторий/владелец копии с ПОСЛЕДНИМ фактом START ДО
#     accept_task_commit; ротация держателя (≥2 строк START рабочего):
#     сдача прежнего держателя отказывает KOPIJA_CHUZHAYA, корень приёма
#     выводится из последнего факта замка (клетки p1–p9; p8-p9 — ротация,
#     закрывают last→first);
#   * канонические вставки roles/orchestrator.md §«Изолированный спавн»
#     (маркеры 199-baza-*/199-nositel-*): синхробаза копии работника и
#     синхронизация носителя после приёма исполняются и судятся (w1–w2,
#     c1–c2, g1);
#   * регрессии периметра: своя копия при пине и М1-границы path-guard
#     (f1–f3 — субъект всегда живой .omp/extensions/path-guard.ts, предмет
#     199 его НЕ меняет), apply:false (g2), документы (t1–t2).
#
# РЕЖИМЫ:
#   (без флага)  — субъекты дерева; до реализации красное (rc 1);
#   --model      — субъекты model/ (эталоны целевой семантики); зелёное;
#   --stabs      — контроль над model/ + обманные стабы stabs/; зелёное
#                  означает: каждый стаб различим хотя бы одной клеткой;
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
cp "$ev" "$S199_RECORD"
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
  mkrepo "$PW_M";  printf '{"pid":1,"id":"ArchP199","startToken":"1"}' > "$d/kop/.omp-isolation-owner.json"
  mkrepo "$PW_M2"; printf '{"pid":1,"id":"Chuzhoj","startToken":"1"}'   > "$d/chp/.omp-isolation-owner.json"
  mkrepo "$PW_DRUG"; git -C "$PW_DRUG" remote add origin "$d/drugoe2.git"
  jq -nc --arg r toyrepo --arg s 199 --arg h ArchP199 --arg ro architect \
        --arg o - --arg w "$PW_CAR" --arg b wip/199/architect --argjson iso true \
    '{t:"START",repoId:$r,subjectId:$s,group:"-",holder:$h,klass:"rabochij",rol:$ro,object:$o,worktree:$w,branch:$b,at:"2026-11-16T00:00:00Z",isolated:$iso}' \
    >> "$PW_SOST/uchet.jsonl"
  PW_MAIN_ABS="$(cd "$PW_MAIN" && pwd -P)"
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
ALL_KLETKI='d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 h1 h2 h3 p1 p2 p3 p4 p5 p6 p7 p8 p9 w1 w2 c1 c2 g1 g2 f1 f2 f3 t1 t2'
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
STABI=(s01 s02 s03 s04 s05 s06 s07 s08 s09 s10 s11 s12 s13 s14)
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
  esac
}
stub_sreda() {  # <sNN> — переменная-шов субъекта
  case "$1" in
    s01|s02|s03|s13) printf 'S199_DOOR' ;;
    s04|s05)     printf 'S199_GUARD' ;;
    s06|s07|s12|s14) printf 'S199_PRIV' ;;
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
