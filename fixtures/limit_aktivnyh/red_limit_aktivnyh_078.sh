#!/usr/bin/env bash
# КРАСНОЕ 078 — «лимит активных контрактов»: отказ номера (next_id.sh CONTRACT),
# строки реестра (mint_line.sh) и заморозки (freeze_contract.sh contracts/NNN-*.md)
# при ≥2 активных на origin (слово владельца 2026-10-02, ТРЕТЬЯ РЕДАКЦИЯ).
#
# ДОГОВОР (контракт 078 §Инварианты): активный N = (frozen/contracts/N/* на origin ∨
# wip/N/* на origin) ∧ без done/contracts/N/* на origin; ≥2 активных → именованный отказ
# «лимит активных» ДО первой мутации; freeze не считает замораживаемого; исключение —
# ТОЛЬКО литеральная подстрока «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: сверх лимита» в причине; счёт — живой
# ls-remote origin, отказ сети — fail-closed «авторитет недоступен».
#
# ПРИВЯЗКА К КОДУ (Н-39; стабы — к ветвям по фактическому коду, не проза):
#   л0 fail-fast (п1-класс 037): на л1/л7/л10-входах все три субъекта МОЛЧАТ (номер
#     выдан / MINTED / заморожено v1) → rc 1 «предмет отсутствует», честные клетки
#     не исполняются; после реализации л0 зелёная, идут все;
#   л1–л6, л5б, лР, л15 — next_id (л1: 2 frozen → rc 1, тег не создан; л2: 1 → rc 0;
#     л2б/л2в: 1 + маркер/почти-маркер в --reason → rc 0, артефакт л2, stderr БЕЗ
#     «лимит активных» — ниже порога причина не читается и снятие не печатается
#     (078-к3 Р3; mut1-класс «причина до порога» печатает снятие → красная); л3:
#     строка владельца → rc 0; л3б: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → rc 1;
#     л4: done закрывает; л5: 2 wip; л5б: frozen+wip — СМЕШАННЫЕ пространства, активны
#     ОБА (объединение frozen ∪ wip): «wip только при отсутствии frozen» видит 1 и
#     пропускает; л5в: ОДИН NNN и в frozen, и в wip — ДЕДУП пересечения (И-1: активные —
#     множество, не сумма частей): double_namespace-счётчик видит 2 и отказывает;
#     дедуп-проба freeze не нужна — вычет И-4 (мини-ядро: grep -vxF по готовому
#     множеству) обнуляет вклад замораживаемого ЦЕЛИКОМ, двойной счёт самого
#     замораживаемого ненаблюдаем, чужое пересечение судится той же единой функцией И-1,
#     предъявленной л5в; лР: РЕШЁТКА классов {F,W,FW,FD,WD,FWD,D} — по ОДНОМУ NNN на
#     класс в одном мире, честное множество {LA,LB,LC}, оракул diag9 (смена оракула
#     078-к3 Р1/З4): один решётчатый мир пиннует счётчик И-1 на всей решётке разом —
#     mut2-класс «пересечение → только F» и обход к1 дают 2 {LA,LC}, double_namespace
#     и «done не вычитается» — шесть, локальные refs — пусто; л6: резерв id-тегом не
#     активен; л15: мёртвый origin → fail-closed «данные неизвестны»);
#   л7–л9 — mint_line (л7: 2 frozen → rc 1, HEAD не двинут; л7б: минтимый NNN сам
#     активен + ещё один frozen → rc 1 — ошибочный вычет --nnn из активных ловится;
#     л8: 1 → MINTED; л8б/л8в: 1 + маркер/почти-маркер в --reason → rc 0 MINTED,
#     stderr БЕЗ «лимит активных» (078-к3 Р3); л9: строка владельца → MINTED; л9б:
#     «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → rc 1);
#   л10–л14 — freeze (л10: 2 frozen ≠001 → rc 1, тега нет, реестр/HEAD/чистота до/после;
#     л10б: 2 чужих wip ТОЛЬКО в bare-origin (локально не fetched) + 1 fetched frozen →
#     rc 1 «активных 3» — считающий ЛОКАЛЬНЫЕ refs видит 1 и пропускает; л11: 1 → v1;
#     л11б/л11в: 1 + маркер/почти-маркер причиной $2 → rc 0 v1, stderr БЕЗ «лимит
#     активных» — freeze печатает свои ok-строки, сверка отрицательная (078-к3 Р3);
#     л12: строка владельца → v1; л12б: причина «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх
#     лимита» → rc 1, тега нет; л13: активен только сам 001 (wip/001 на origin) → v1;
#     л14: сам 001 + 2 frozen → rc 1 — вычтен только замораживаемый; л14б: сам 001 +
#     ОДИН frozen → v1 — пограничная различает вычет субъекта: невычитающая реализация
#     даёт rc 1; л14в: 001 сам в ОБОИХ пространствах (frozen/contracts/001/1 +
#     wip/001) + frozen <ACT1> + wip <ACT2> → rc 1 «активных 2: ACT1,ACT2» — вычет И-4
#     снимает 001 из ОБОИХ частей целиком: вычитающий одну часть до объединения видит
#     3, mut2-класс «пересечение → только F» видит 1 и пропускает (078-к3 Р2/З5);
#     тегов 001 сверх fetched v1 нет, реестр/HEAD/чистота нетронуты);
#   л16/л17 (вход №1 адверсария 078-v1, fail-closed ПОТРЕБИТЕЛЕЙ): dual-control/
#     грамматика/реестр прошли, отказал именно ЛИМИТНЫЙ ls-remote — PATH-шим ломает
#     только три паттерна active_contracts_list (dual-control id/CONTRACT у mint и
#     registry_state refs/tags/frozen/* идут к живому git) → rc 1 «авторитет
#     недоступен … данные неизвестны» БЕЗ мутации: л16 mint (строки нет, HEAD,
#     чистота), л17 freeze (тега нет, реестр байт-в-байт, HEAD, чистота); fail-open
#     стаб-Фм/Фф здесь МИНТУЕТ/ЗАМОРАЖИЕТ — вход их наблюдаемости (Н-39);
#   л18/л19/л20 (вход №2 адверсария 078-v1, ноль refs): origin жив, ls-remote rc 0,
#     ПУСТО во всех трёх пространствах → активных 0 < 2 → нормальный успех БЕЗ
#     диагностики лимита: л18 next_id (номер+тег), л19 mint (MINTED), л20 freeze
#     (v1); стаб-П «пустой ответ = недоступность» отказывает ровно здесь;
#   л21/л22 (вход №3 адверсария 078-v2 к2, граница SLA 15s И-2): делегирующий
#     PATH-шим git задерживает ТОЛЬКО лимитный ls-remote (те же три паттерна):
#     л21 — ответ 6s < 15s, здоровый, но медленный → нормальный успех (мутант
#     фактической границы 1s/5s убивает 6s-ответ и ложно отказывает — до 078-v2
#     проходил батарею целиком); л22 — ответ 17s > 15s → НОРМАТИВНЫЙ fail-closed
#     rc=124 без мутации (SLA — часть определения недоступности, И-2);
#   л23–л26 (вход адверсария 078-v2 к3: SLA-граница пинует ВСЕХ трёх потребителей,
#     т1/т2 к2 дёргали только next_id — тот же делегирующий шим на входах mint/freeze:
#     л23 mint 6s → MINTED без диагностики лимита; л24 mint 17s → именованный
#     fail-closed rc=124 ПОСЛЕ dual-control, строки в реестре нет, HEAD/чистота
#     нетронуты; л25 freeze 6s → v1 без диагностики; л26 freeze 17s → fail-closed
#     rc=124 ДО тега и реестра (тег/реестр/HEAD/чистота); обманный субъект «124→0
#     до fail-closed ветви» минтует/замораживает и краснеет на л24/л26;
#   И-9 в клетках отказа И снятия: stderr сверяется числом И точным множеством NNN
#     (diag9: «активных <N> ≥ 2: <NNN,NNN>»; снятие — л3/л9/л12, решётка лР и л14в —
#     тем же diag9), л15 — слова «данные неизвестны»; не один маркер. Ниже порога —
#     молчание: л2б/л2в/л8б/л8в/л11б/л11в сверяют ОТСУТСТВИЕ «лимит активных» в stderr.
#   стаб-пак стА–стЖ — мутантные копии мини-ядра mini_core_078.sh (одна замена одной
#     строки по маркеру «# ВЕТВЬ:…»; применение — двумя мерами: cmp ∧ grep -F):
#     стА ls-remote→локальные refs (И-2) · стБ done не вычитает (И-6) · стВ wip не
#     видит (И-6) · стГ широкий матчинг строки владельца (И-5) · стД замораживаемый
#     не вычтен (И-4) · стЕ сеть=пропуск (И-2) · стЖ double_namespace: wip в отдельном
#     ключе — пересечение frozen∩wip считается дважды (И-1). Каждый стаб: (а) диффпроба
#     на чистом мире rc 0 (не параноик), (б) НАРУШЕНИЕ — расходится с честным ядром
#     ровно на входе наблюдаемости дефекта; стаб-пак зелен ДО и ПОСЛЕ реализации
#     субъекта.
#   субъектные стабы Фм/Фф/П — мутантные копии РЕАЛЬНЫХ scripts/ (вердикт 078-v1;
#     одна замена одной строки по якорю фактического кода, применение cmp ∧ grep -F,
#     гейт л0 — якоря есть только у реализованного субъекта): Фм mint_line
#     `active_rc→exit 1`→`if false` (fail-open) · Фф freeze_contract то же ·
#     П lib_active_contracts `ls_rc -ne 0`→`… || [ -z "$refs" ]` (пустой ответ
#     ошибочно = недоступность). Диффпробы: вне дефекта стабы честны; нарушения —
#     ровно на входах л16/л17 (шим) и л18/л19/л20 (ноль refs).
#     Т lib_active_contracts `timeout 15s git`→`timeout 1s git` (фактическая граница
#     1s; 078-v2 к2): диффпробы на быстром авторитете (все три потребителя), поимка
#     на входах л21/л23/л25 (шим 6s). 124м mint_line / 124ф freeze_contract (078-v2
#     к3, обманный субъект адверсария, ДВЕ опоры: ядро всплывает таймаут дословно
#     (return "$ls_rc") + потребитель гасит (active_rc=124→0) ДО fail-closed ветви.
#     Одна потребительская строка нежизнена (замер: ядро возвращает 1 — гаситель
#     молчит, стаб честен); диффпробы на быстром авторитете, поимка на входах
#     л24/л26 (шим 17s): стабы МИНТУЮТ/ЗАМОРАЖИВАЮТ против честного rc 1.
#
# Активные создаются ПРЯМО В BARE origin (тег/ветка на уже запушенный main — порядок
# Н-160 коммиты→тег соблюдён), локальные refs клона остаются пустыми: счёт по origin
# наблюдаем в каждой клетке, отложенный fetch ничего не прячет. Значения случайны на
# прогон (985–999, внутрибатарейная уникальность; toy-миры изолированы mktemp+bare,
# пересечение с заявками соседних семей безопасно — worlds не пересекаются).
#
# Коды возврата: 0 — все ветви зелёные; 1 — есть красная (в т.ч. «предмет отсутствует»
# — предъявляемое красное ДО, прецедент п1 батареи 037); 2 — нечем проверять.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$HERE/../.." && pwd)}"
SUBJ_NEXT="$ROOT/scripts/next_id.sh"
SUBJ_MINT="$ROOT/scripts/mint_line.sh"
SUBJ_FREEZE="$ROOT/scripts/freeze_contract.sh"
CORE="$HERE/mini_core_078.sh"

command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3 (генератор стабов)\n' >&2; exit 2; }
[ -f "$CORE" ] || { printf 'NOT_IMPLEMENTED: нет мини-ядра: %s\n' "$CORE" >&2; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/red078.XXXXXX")"
[ "${KEEP078:-}" = "1" ] || trap 'rm -rf "$WORK"' EXIT # KEEP078=1 — диагностика: мир остаётся для вскрытия
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE \
      GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE

g() { # явная identity на каждом вызове (env-изоляция 068)
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
     -c user.name=Фикстура -c user.email=fixture@local "$@"
}

# Случайные значения: SEED — локальный артефакт toy (выдача = SEED+1), ACT* — активные
# соседи на origin, RES — резерв, L* — решётка классов лР (078-к3 Р1: по одному NNN на
# каждый из семи классов), R — хвосты причин (инвариантность к значениям).
mapfile -t RD < <(python3 - <<'PY'
import random
pool = random.sample(range(985, 1000), 12)
print("%03d" % pool[0]); print("%03d" % pool[1]); print("%03d" % pool[2])
print("%03d" % pool[3]); print("%03d" % pool[4]); print("%03d" % pool[5])
print("%03d" % pool[6]); print("%03d" % pool[7]); print("%03d" % pool[8])
print("%03d" % pool[9]); print("%03d" % pool[10]); print("%03d" % pool[11])
print("%d" % random.randint(10000000, 99999999)); print("%d" % random.randint(10000000, 99999999))
PY
)
SEED="${RD[0]}"; ACT1="${RD[1]}"; ACT2="${RD[2]}"; ACT3="${RD[3]}"; RES="${RD[5]}"
# лР-решётка (078-к3 Р1): пул расширен 8→12 (ещё четыре; 15 хватает) — семь NNN на
# классы {F,W,FW,FD,WD,FWD,D}; мёртвый слот RD[4] (бывший EXC) занят H-классом (D).
LA="${RD[6]}"; LB="${RD[7]}"; LC="${RD[8]}"; LD="${RD[9]}"; LE="${RD[10]}"; LG="${RD[11]}"; LH="${RD[4]}"
RH1="${RD[12]}"; RH2="${RD[13]}"
REASON_OK="РАЗРЕШИЛ-ВЛАДЕЛЕЦ: сверх лимита — слово владельца 2026-10-02/${RH1}"
REASON_NO="РАЗРЕШИЛ-ВЛАДЕЛЕЦ: иная причина ${RH2}"

RED=0; GRN=0; NORUN=0
declare -a REPS=()
fail()   { RED=$((RED+1));   REPS+=("$1: КРАСНАЯ — $2"); }
pass()   { GRN=$((GRN+1));   REPS+=("$1: ЗЕЛЁНАЯ"); }
norun()  { NORUN=$((NORUN+1)); REPS+=("$1: НЕ ИСПОЛНЯЛАСЬ (л0 красная — предмет отсутствует)"); }

# ── конструкторы миров ─────────────────────────────────────────────────────────
bare_of() { printf '%s-origin.git' "${1%/}"; }

# mk_next_toy <каталог>: рабочий клон с seed-артефактом <SEED> (локальный тег
# id/CONTRACT/<SEED>) и ПУСТЫМ bare-origin (push main; тег не пушится).
mk_next_toy() {
  local t="$1" b
  b="$(bare_of "$t")"
  mkdir -p "$t/contracts"
  printf '# seed-артефакт фикстуры\n' > "$t/contracts/${SEED}-seed.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$t"
  # Локальная identity ФАЙЛОМ конфига (Н-12): субъект next_id.sh зовёт `git tag` БЕЗ -c —
  # в герметичном окружении без user.name он падает «empty ident name», и клетка краснела
  # бы дефектом окружения, а не предметом.
  git -C "$t" config user.name Фикстура
  git -C "$t" config user.email fixture@local
  g "$t" add -A
  g "$t" commit -q -m 'основание: seed-артефакт'
  g "$t" tag -a "id/CONTRACT/$SEED" -m 'выдача механизмом (фикстура: seed)'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$b"
  git -C "$b" symbolic-ref HEAD refs/heads/main
  g "$t" remote add origin "$b"
  g "$t" push -q origin main
}

# Активные — ПРЯМО В BARE (локальные refs клона не знают их без fetch): Н-160 —
# теги/ветки вешаются на УЖЕ запушенные коммиты (коммиты → тег).
bare_frozen() { g "$(bare_of "$1")" tag -a "frozen/contracts/$2/1" -m "фикстура: активный $2" "$(git -C "$(bare_of "$1")" rev-parse refs/heads/main)"; }
bare_done()   { g "$(bare_of "$1")" tag -a "done/contracts/$2/1" -m "фикстура: закрыт $2" "$(git -C "$(bare_of "$1")" rev-parse refs/heads/main)"; }
bare_wip()    { g "$(bare_of "$1")" branch "wip/$2/fixture$RH1" refs/heads/main; }
bare_id()     { g "$(bare_of "$1")" tag -a "id/CONTRACT/$2" -m 'выдача механизмом (фикстура: резерв на origin)' "$(git -C "$(bare_of "$1")" rev-parse refs/heads/main)"; }

# sync_tags <toy>: подтянуть теги origin в локаль. Мирам ПИСАТЕЛЕЙ (mint_line — живая
# дверь 031, freeze_contract — реестр писателя) нужна полнота registry_state 'frozen/'
# (missing-remote = отказ по ЧУЖОМУ предмету); стаб-миры (мини-ядро + стаб-А «источник
# локальные refs») остаются БЕЗ fetch — локальная пустота и есть наблюдаемость дефекта.
sync_tags() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$1" fetch -q --tags origin; }


# diag9 <stderr> <ожидалось-число> <NNN>… — сверка И-9: отказ несёт ЧИСЛО активных и
# ТОЧНОЕ МНОЖЕСТВО NNN (форма И-3/И-4 «активных <N> ≥ 2: <NNN-через-запятую>»).
# Сверка множеством, не маркером: отказ без числа/списка или с чужим NNN красен.
diag9() {
  local err="$1" want_n="$2" line list got want; shift 2
  line="$(printf '%s\n' "$err" | grep -F 'лимит активных' | tail -n1)"
  [ -n "$line" ] || return 1
  printf '%s\n' "$line" | grep -qF "активных $want_n ≥" || return 1
  list="${line##*: }"; list="${list// /}"
  [ -n "$list" ] || return 1
  got="$(printf '%s\n' "$list" | tr ',' '\n' | sort -u | paste -sd, -)"
  want="$(printf '%s\n' "$@" | sort -u | paste -sd, -)"
  [ "$got" = "$want" ]
}

# reg_state <toy> — байт-в-байт состояние реестра (git-хэш файла; «нет-файла», если
# файла нет): отказ freeze обязан оставить реестр неприкосновенным (л10/л10б).
reg_state() {
  local f="$1/registry/contracts.tsv"
  if [ -f "$f" ]; then printf 'файл:%s' "$(git hash-object "$f")"; else printf 'нет-файла'; fi
}
# mk_freeze_toy <каталог>: каркас семьи freeze_contract (контракт 001 + вердикт
# accept + вакуумный CI-паритет) + bare-origin с запушенным main — заморозка 001
# проходит все гейты 036/038/043, предмет клетки — только лимит.
mk_freeze_toy() {
  local t="$1" b
  b="$(bare_of "$t")"
  mkdir -p "$t/contracts" "$t/verdicts/critic" "$t/.github/workflows" "$t/config"
  printf 'предмет, критерий готовности, РАБОТА НЕ РАЗДАЁТСЯ: кодификация\n' > "$t/contracts/001-x.md"
  printf 'accept\nтело вердикта\n' > "$t/verdicts/critic/contracts-001-v1.md"
  printf 'name: ci\non: push\njobs: {}\n' > "$t/.github/workflows/ci.yml"
  printf '{"scripts": {}}\n' > "$t/package.json"
  : > "$t/config/ci_parity_exceptions.txt"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$t"
  git -C "$t" config user.name Фикстура
  git -C "$t" config user.email fixture@local
  git -C "$t" config commit.gpgsign false
  git -C "$t" config core.hooksPath /dev/null
  g "$t" add -A
  g "$t" commit -q -m 'основание'
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$b"
  git -C "$b" symbolic-ref HEAD refs/heads/main
  g "$t" remote add origin "$b"
  g "$t" push -q origin main
}

# mk_mint_toy <каталог>: mk_toy семьи 068 дословно (зона orchestrator через HANDOFF,
# манифест, ЖИВАЯ дверь 031 через копию scripts — каталог хука ВНЕ toy).
BARRIER="$WORK/subj-scripts-mint"
cp -r "$ROOT/scripts" "$BARRIER"
mk_mint_toy() {
  local t="$1" orig hookdir
  mkdir -p "$t/contracts" "$t/registry" "$t/scripts"
  {
    printf '# контракт 001\n\n## Предмет\nподставной предмет\n\n## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n'
    printf 'ЗОНА orchestrator: HANDOFF.md\n'
  } > "$t/contracts/001-x.md"
  printf '# передача\n' > "$t/HANDOFF.md"
  printf 'seed\n' > "$t/scripts/a.sh"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$t"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$t" config commit.gpgsign false
  g "$t" add -A
  g "$t" commit -q -m 'основание: контракт и зона orchestrator'
  printf '000 → %s\n' "$(git -C "$t" rev-parse HEAD)" > "$t/registry/contracts.tsv"
  g "$t" add -A
  g "$t" commit -q -m 'основание: манифест реестра'
  g "$t" tag -a frozen/contracts/001/1 -m 'контракт утверждён'
  orig="$(bare_of "$t")"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q --bare "$orig"
  git -C "$orig" symbolic-ref HEAD refs/heads/main
  g "$t" remote add origin "$orig"
  g "$t" push -q origin main
  hookdir="$WORK/hookdir-$(basename "$t")"
  mkdir -p "$hookdir"
  printf '#!/bin/sh\nexec bash "%s/check_staged.sh" "%s"\n' "$BARRIER" "$t" > "$hookdir/pre-commit"
  chmod +x "$hookdir/pre-commit"
  git -C "$t" config core.hooksPath "$hookdir"
}
authority_tag() { # аннотированный тег + пуш на origin (строку НЕ пишет) — 068
  g "$1" tag -a "id/CONTRACT/$2" -m 'выдача механизмом (фикстура: авторитетная половина)'
  g "$1" push -q origin "refs/tags/id/CONTRACT/$2"
}

# ── л0: предмет присутствует и несёт лимит на всех трёх входах ────────────────
# Инвариант: # ИНВ: И-3, И-4 (fail-fast: молчание = предмет отсутствует)
T1="$WORK/l1-$RH1"; mk_next_toy "$T1"; bare_frozen "$T1" "$ACT1"; bare_frozen "$T1" "$ACT2"
out_ni="$("$SUBJ_NEXT" "$T1" CONTRACT 2>"$WORK/e-ni")"; rc_ni=$?; err_ni="$(cat "$WORK/e-ni")"

T7="$WORK/l7-$RH1"; mk_mint_toy "$T7"; authority_tag "$T7" "$ACT3"; bare_frozen "$T7" "$ACT1"; bare_frozen "$T7" "$ACT2"; sync_tags "$T7"
head7="$(git -C "$T7" rev-parse HEAD)"
out_ml="$("$SUBJ_MINT" --root "$T7" --nnn "$ACT3" 2>"$WORK/e-ml")"; rc_ml=$?; err_ml="$(cat "$WORK/e-ml")"

T10="$WORK/l10-$RH1"; mk_freeze_toy "$T10"; bare_frozen "$T10" "$ACT1"; bare_frozen "$T10" "$ACT2"; sync_tags "$T10"
head10="$(git -C "$T10" rev-parse HEAD)"; reg10pre="$(reg_state "$T10")" # л10: снимки ДО отказа — реестр байт-в-байт, HEAD
out_fr="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH1" "$T10" 2>"$WORK/e-fr")"; rc_fr=$?; err_fr="$(cat "$WORK/e-fr")"

LIM_NAME='лимит активных'
if [ "$rc_ni" -eq 1 ] && printf '%s' "$err_ni" | grep -qF "$LIM_NAME" \
   && [ "$rc_ml" -eq 1 ] && printf '%s' "$err_ml" | grep -qF "$LIM_NAME" \
   && [ "$rc_fr" -eq 1 ] && printf '%s' "$err_fr" | grep -qF "$LIM_NAME"; then
  pass л0
  PRESENT=1
else
  fail л0 "предмет отсутствует: next_id rc=$rc_ni err=$(printf '%s' "$err_ni" | sed -n 1p); mint rc=$rc_ml err=$(printf '%s' "$err_ml" | sed -n 1p); freeze rc=$rc_fr err=$(printf '%s' "$err_fr" | sed -n 1p) — субъекты молчат на трёх входах лимита"
  PRESENT=0
fi

# ── честные клетки next_id (л1–л6, л15) ───────────────────────────────────────
if [ "$PRESENT" -eq 1 ]; then
  # л1: 2 frozen на origin → отказ, тег не создан, stdout пуст; И-9: число+список. # ИНВ: И-3
  tags1="$(git -C "$T1" tag -l 'id/CONTRACT/*' | wc -l)"
  if [ "$rc_ni" -eq 1 ] && printf '%s' "$err_ni" | grep -qF "$LIM_NAME" && diag9 "$err_ni" 2 "$ACT1" "$ACT2" \
     && [ -z "$out_ni" ] && [ "$tags1" -eq 1 ]; then pass л1
  else fail л1 "rc=$rc_ni out=$out_ni тегов id=$tags1 (ожидалось 1 — только seed) err=$(printf '%s' "$err_ni" | sed -n 1p)"; fi

  # л2: 1 frozen → номер выдан, тег создан. # ИНВ: И-3
  T2="$WORK/l2-$RH2"; mk_next_toy "$T2"; bare_frozen "$T2" "$ACT1"
  want2="$(printf '%03d' $((10#$SEED + 1)))"
  out2="$("$SUBJ_NEXT" "$T2" CONTRACT 2>"$WORK/e2")"; rc2=$?
  tags2="$(git -C "$T2" tag -l 'id/CONTRACT/*' | wc -l)"
  if [ "$rc2" -eq 0 ] && [ "$out2" = "$want2" ] && [ "$tags2" -eq 2 ]; then pass л2
  else fail л2 "rc=$rc2 out=$out2 want=$want2 тегов id=$tags2"; fi

  # л2б (маркер ниже порога, 078-к3 Р3): свежий мир л2 (1 frozen) + REASON_OK → rc 0,
  # артефакт как в л2 (номер+тег); stderr БЕЗ «лимит активных» — ниже порога причина
  # не читается, снятие не печатается (mut1-класс «причина до порога» печатает →
  # красная здесь). # ИНВ: И-5, И-9
  T2b="$WORK/l2b-$RH1"; mk_next_toy "$T2b"; bare_frozen "$T2b" "$ACT1"
  out2b="$("$SUBJ_NEXT" "$T2b" CONTRACT --reason "$REASON_OK" 2>"$WORK/e2b")"; rc2b=$?; err2b="$(cat "$WORK/e2b")"
  if [ "$rc2b" -eq 0 ] && [ "$out2b" = "$want2" ] && [ "$(git -C "$T2b" tag -l 'id/CONTRACT/*' | wc -l)" -eq 2 ] \
     && ! printf '%s' "$err2b" | grep -qF "$LIM_NAME"; then pass л2б
  else fail л2б "rc=$rc2b out=$out2b err=$(printf '%s' "$err2b" | sed -n 1p) — маркер ниже порога меняет вывод (И-5 нарушен)"; fi

  # л2в (почти-маркер ниже порога, 078-к3 Р3): свежий мир л2 + REASON_NO → rc 0, тот
  # же артефакт; stderr БЕЗ «лимит активных» — причина ниже порога не читается ВООБЩЕ.
  # ИНВ: И-5, И-9
  T2v="$WORK/l2v-$RH2"; mk_next_toy "$T2v"; bare_frozen "$T2v" "$ACT1"
  out2v="$("$SUBJ_NEXT" "$T2v" CONTRACT --reason "$REASON_NO" 2>"$WORK/e2v")"; rc2v=$?; err2v="$(cat "$WORK/e2v")"
  if [ "$rc2v" -eq 0 ] && [ "$out2v" = "$want2" ] && [ "$(git -C "$T2v" tag -l 'id/CONTRACT/*' | wc -l)" -eq 2 ] \
     && ! printf '%s' "$err2v" | grep -qF "$LIM_NAME"; then pass л2в
  else fail л2в "rc=$rc2v out=$out2v err=$(printf '%s' "$err2v" | sed -n 1p) — почти-маркер ниже порога меняет вывод (И-5 нарушен)"; fi

  # л3: 2 frozen + строка владельца → номер выдан, stderr «снято строкой владельца». # ИНВ: И-5
  T3="$WORK/l3-$RH1"; mk_next_toy "$T3"; bare_frozen "$T3" "$ACT1"; bare_frozen "$T3" "$ACT2"
  out3="$("$SUBJ_NEXT" "$T3" CONTRACT --reason "$REASON_OK" 2>"$WORK/e3")"; rc3=$?; err3="$(cat "$WORK/e3")"
  if [ "$rc3" -eq 0 ] && [ "$out3" = "$want2" ] && printf '%s' "$err3" | grep -qF 'снято строкой владельца' \
     && diag9 "$err3" 2 "$ACT1" "$ACT2"; then pass л3
  else fail л3 "rc=$rc3 out=$out3 err=$(printf '%s' "$err3" | sed -n 1p)"; fi

  # л3б (негативная пара л3): «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → отказ остаётся. # ИНВ: И-5
  out3b="$("$SUBJ_NEXT" "$T3" CONTRACT --reason "$REASON_NO" 2>"$WORK/e3b")"; rc3b=$?; err3b="$(cat "$WORK/e3b")"
  if [ "$rc3b" -eq 1 ] && printf '%s' "$err3b" | grep -qF "$LIM_NAME" && diag9 "$err3b" 2 "$ACT1" "$ACT2" && [ -z "$out3b" ]; then pass л3б
  else fail л3б "rc=$rc3b out=$out3b err=$(printf '%s' "$err3b" | sed -n 1p)"; fi

  # л4: 2 frozen, у одного done → активен 1 → выдача. # ИНВ: И-6
  T4="$WORK/l4-$RH2"; mk_next_toy "$T4"; bare_frozen "$T4" "$ACT1"; bare_frozen "$T4" "$ACT2"; bare_done "$T4" "$ACT2"
  out4="$("$SUBJ_NEXT" "$T4" CONTRACT 2>"$WORK/e4")"; rc4=$?
  if [ "$rc4" -eq 0 ] && [ "$out4" = "$want2" ]; then pass л4
  else fail л4 "rc=$rc4 out=$out4 err=$(sed -n 1p "$WORK/e4")"; fi

  # л5: 2 wip-ветки на origin, frozen нет → отказ. # ИНВ: И-6
  T5="$WORK/l5-$RH1"; mk_next_toy "$T5"; bare_wip "$T5" "$ACT1"; bare_wip "$T5" "$ACT2"
  out5="$("$SUBJ_NEXT" "$T5" CONTRACT 2>"$WORK/e5")"; rc5=$?; err5="$(cat "$WORK/e5")"
  if [ "$rc5" -eq 1 ] && printf '%s' "$err5" | grep -qF "$LIM_NAME" && diag9 "$err5" 2 "$ACT1" "$ACT2" && [ -z "$out5" ]; then pass л5
  else fail л5 "rc=$rc5 out=$out5 err=$(printf '%s' "$err5" | sed -n 1p)"; fi

  # л5б (смешанные пространства): frozen <ACT1> + wip <ACT2> на origin — активны ОБА
  # (И-1: объединение frozen ∪ wip); реализация «wip только при отсутствии frozen»
  # видит 1 и выдаёт номер → красная здесь. # ИНВ: И-1, И-6, И-9
  T5b="$WORK/l5b-$RH2"; mk_next_toy "$T5b"; bare_frozen "$T5b" "$ACT1"; bare_wip "$T5b" "$ACT2"
  out5b="$("$SUBJ_NEXT" "$T5b" CONTRACT 2>"$WORK/e5b")"; rc5b=$?; err5b="$(cat "$WORK/e5b")"
  if [ "$rc5b" -eq 1 ] && printf '%s' "$err5b" | grep -qF "$LIM_NAME" && diag9 "$err5b" 2 "$ACT1" "$ACT2" \
     && [ -z "$out5b" ] && [ "$(git -C "$T5b" tag -l 'id/CONTRACT/*' | wc -l)" -eq 1 ]; then pass л5б
  else fail л5б "rc=$rc5b out=$out5b err=$(printf '%s' "$err5b" | sed -n 1p) — объединение пространств не доказано: «wip только при отсутствии frozen» видит 1 и пропускает"; fi

  # л5в (дедупликация пересечения, обход double_namespace критика 078 к2): ОДИН NNN
  # <ACT1> и в frozen, и в wip на origin, done нет → активен ОДИН (И-1: множество, не
  # сумма частей) → честная реализация ниже порога: rc 0, номер выдан, тег создан;
  # double_namespace-счётчик (уникальные внутри частей, сумма без дедупа) видит 2 →
  # rc 1 → клетка красная. Дедуп-проба freeze не нужна: вычет И-4 (мини-ядро:62,
  # grep -vxF по ГОТОВОМУ множеству) обнуляет вклад замораживаемого целиком — двойной
  # счёт самого замораживаемого ненаблюдаем; чужое пересечение судится той же единой
  # функцией И-1 на все три входа. # ИНВ: И-1, И-3
  T5v="$WORK/l5v-$RH1"; mk_next_toy "$T5v"; bare_frozen "$T5v" "$ACT1"; bare_wip "$T5v" "$ACT1"
  out5v="$("$SUBJ_NEXT" "$T5v" CONTRACT 2>"$WORK/e5v")"; rc5v=$?
  if [ "$rc5v" -eq 0 ] && [ "$out5v" = "$want2" ] && [ "$(git -C "$T5v" tag -l 'id/CONTRACT/*' | wc -l)" -eq 2 ]; then pass л5в
  else fail л5в "rc=$rc5v out=$out5v err=$(sed -n 1p "$WORK/e5v") — дедупликация пересечения не доказана: double_namespace-счётчик видит 2 (NNN $ACT1 в обоих пространствах) и отказывает"; fi

  # лР (решётка классов — смена оракула 078-к3 Р1/З4): по ОДНОМУ NNN на каждый из
  # семи классов {F,W,FW,FD,WD,FWD,D} (frozen/wip/done-принадлежность одного NNN);
  # честное множество И-1 — {LA,LB,LC}: FW-класс активен ОДИН раз, FD/WD/FWD/D
  # закрыты done. Один мир с оракулом точного множества (diag9) пиннует счётчик на
  # всей решётке разом: mut2-класс «пересечение → только F» (wip-only роняются при
  # непустом пересечении) даёт {LA,LC}, обход к1 — {LA,LC}, double_namespace и
  # «done не вычитается» — шесть, локальные refs — пусто. # ИНВ: И-1, И-6, И-9
  TR="$WORK/lR-$RH2"; mk_next_toy "$TR"
  bare_frozen "$TR" "$LA"                                               # F
  bare_wip "$TR" "$LB"                                                  # W
  bare_frozen "$TR" "$LC"; bare_wip "$TR" "$LC"                         # FW — пересечение
  bare_frozen "$TR" "$LD"; bare_done "$TR" "$LD"                        # FD — done закрывает
  bare_wip "$TR" "$LE"; bare_done "$TR" "$LE"                           # WD — done закрывает
  bare_frozen "$TR" "$LG"; bare_wip "$TR" "$LG"; bare_done "$TR" "$LG"  # FWD — done закрывает
  bare_done "$TR" "$LH"                                                 # D
  outR="$("$SUBJ_NEXT" "$TR" CONTRACT 2>"$WORK/eR")"; rcR=$?; errR="$(cat "$WORK/eR")"
  if [ "$rcR" -eq 1 ] && printf '%s' "$errR" | grep -qF "$LIM_NAME" && diag9 "$errR" 3 "$LA" "$LB" "$LC" \
     && [ -z "$outR" ] && [ "$(git -C "$TR" tag -l 'id/CONTRACT/*' | wc -l)" -eq 1 ]; then pass лР
  else fail лР "rc=$rcR out=$outR тегов id=$(git -C "$TR" tag -l 'id/CONTRACT/*' | wc -l) err=$(printf '%s' "$errR" | sed -n 1p) — решётка классов не пиннует И-1: множество обязано быть {$LA,$LB,$LC}"; fi

  # л6: резерв id/CONTRACT/<RES> на origin не активен; 1 frozen → выдача. # ИНВ: И-6
  T6="$WORK/l6-$RH2"; mk_next_toy "$T6"; bare_id "$T6" "$RES"; bare_frozen "$T6" "$ACT1"
  out6="$("$SUBJ_NEXT" "$T6" CONTRACT 2>"$WORK/e6")"; rc6=$?
  if [ "$rc6" -eq 0 ] && [ "$out6" = "$want2" ]; then pass л6
  else fail л6 "rc=$rc6 out=$out6 err=$(sed -n 1p "$WORK/e6")"; fi

  # л15: origin на мёртвом пути → fail-closed «авторитет недоступен», тег не создан. # ИНВ: И-2
  T15="$WORK/l15-$RH1"; mk_next_toy "$T15"
  g "$T15" remote set-url origin "$WORK/mrt-$RH2/repo.git"
  out15="$("$SUBJ_NEXT" "$T15" CONTRACT 2>"$WORK/e15")"; rc15=$?; err15="$(cat "$WORK/e15")"
  tags15="$(git -C "$T15" tag -l 'id/CONTRACT/*' | wc -l)"
  if [ "$rc15" -eq 1 ] && printf '%s' "$err15" | grep -qF "$LIM_NAME" \
     && printf '%s' "$err15" | grep -qF 'авторитет недоступен' && printf '%s' "$err15" | grep -qF 'данные неизвестны' \
     && [ "$tags15" -eq 1 ] && [ -z "$out15" ]; then pass л15
  else fail л15 "rc=$rc15 out=$out15 тегов id=$tags15 err=$(printf '%s' "$err15" | sed -n 1p)"; fi

  # ── честные клетки mint_line (л7–л9) ────────────────────────────────────────
  # л7: 2 frozen → отказ, HEAD не двинут, дерево чисто, строки нет. # ИНВ: И-3
  lines7="$(git -C "$T7" cat-file -p HEAD:registry/contracts.tsv | grep -cF "$ACT3 → " || true)"
  dirty7="$(git -C "$T7" status --porcelain)"
  head7b="$(git -C "$T7" rev-parse HEAD)"
  if [ "$rc_ml" -eq 1 ] && printf '%s' "$err_ml" | grep -qF "$LIM_NAME" && diag9 "$err_ml" 2 "$ACT1" "$ACT2" \
     && [ "$lines7" -eq 0 ] && [ "$head7b" = "$head7" ] && [ -z "$dirty7" ]; then pass л7
  else fail л7 "rc=$rc_ml строк=$lines7 head_двинулся=$([ "$head7b" = "$head7" ] && echo нет || echo да) dirty=${dirty7:-чисто}"; fi

  # л7б: минтимый NNN сам активен (frozen) + ещё один frozen → отказ: вычитать --nnn
  # из активных нельзя (исключение И-4 — только freeze); вычитающая реализация
  # пропустит (1 активный) и станет красной здесь. # ИНВ: И-3
  T7b="$WORK/l7b-$RH2"; mk_mint_toy "$T7b"; authority_tag "$T7b" "$ACT3"; bare_frozen "$T7b" "$ACT3"; bare_frozen "$T7b" "$ACT1"; sync_tags "$T7b"
  h7b="$(git -C "$T7b" rev-parse HEAD)"
  out7b="$("$SUBJ_MINT" --root "$T7b" --nnn "$ACT3" 2>"$WORK/e7b")"; rc7b=$?; err7b="$(cat "$WORK/e7b")"
  lines7b="$(git -C "$T7b" cat-file -p HEAD:registry/contracts.tsv | grep -cF "$ACT3 → " || true)"
  dirty7b="$(git -C "$T7b" status --porcelain)"
  if [ "$rc7b" -eq 1 ] && printf '%s' "$err7b" | grep -qF "$LIM_NAME" && diag9 "$err7b" 2 "$ACT3" "$ACT1" && [ -z "$out7b" ] \
     && [ "$lines7b" -eq 0 ] && [ "$(git -C "$T7b" rev-parse HEAD)" = "$h7b" ] && [ -z "$dirty7b" ]; then pass л7б
  else fail л7б "rc=$rc7b out=$out7b err=$(printf '%s' "$err7b" | sed -n 1p)"; fi

  # л8: 1 frozen → MINTED. # ИНВ: И-3
  T8="$WORK/l8-$RH2"; mk_mint_toy "$T8"; authority_tag "$T8" "$ACT3"; bare_frozen "$T8" "$ACT1"; sync_tags "$T8"
  out8="$("$SUBJ_MINT" --root "$T8" --nnn "$ACT3" 2>"$WORK/e8")"; rc8=$?
  if [ "$rc8" -eq 0 ] && printf '%s' "$out8" | grep -qF "MINTED nnn=$ACT3"; then pass л8
  else fail л8 "rc=$rc8 out=$out8 err=$(sed -n 1p "$WORK/e8")"; fi

  # л8б (маркер ниже порога — mint, 078-к3 Р3): сетап л8 (1 frozen) + REASON_OK →
  # rc 0 MINTED, stderr БЕЗ «лимит активных». # ИНВ: И-5, И-9
  T8b="$WORK/l8b-$RH1"; mk_mint_toy "$T8b"; authority_tag "$T8b" "$ACT3"; bare_frozen "$T8b" "$ACT1"; sync_tags "$T8b"
  out8b="$("$SUBJ_MINT" --root "$T8b" --nnn "$ACT3" --reason "$REASON_OK" 2>"$WORK/e8b")"; rc8b=$?; err8b="$(cat "$WORK/e8b")"
  if [ "$rc8b" -eq 0 ] && printf '%s' "$out8b" | grep -qF "MINTED nnn=$ACT3" \
     && ! printf '%s' "$err8b" | grep -qF "$LIM_NAME"; then pass л8б
  else fail л8б "rc=$rc8b out=$out8b err=$(printf '%s' "$err8b" | sed -n 1p) — маркер ниже порога меняет вывод (И-5 нарушен)"; fi

  # л8в (почти-маркер ниже порога — mint, 078-к3 Р3): сетап л8 + REASON_NO → rc 0
  # MINTED, stderr БЕЗ «лимит активных». # ИНВ: И-5, И-9
  T8v="$WORK/l8v-$RH2"; mk_mint_toy "$T8v"; authority_tag "$T8v" "$ACT3"; bare_frozen "$T8v" "$ACT1"; sync_tags "$T8v"
  out8v="$("$SUBJ_MINT" --root "$T8v" --nnn "$ACT3" --reason "$REASON_NO" 2>"$WORK/e8v")"; rc8v=$?; err8v="$(cat "$WORK/e8v")"
  if [ "$rc8v" -eq 0 ] && printf '%s' "$out8v" | grep -qF "MINTED nnn=$ACT3" \
     && ! printf '%s' "$err8v" | grep -qF "$LIM_NAME"; then pass л8в
  else fail л8в "rc=$rc8v out=$out8v err=$(printf '%s' "$err8v" | sed -n 1p) — почти-маркер ниже порога меняет вывод (И-5 нарушен)"; fi

  # л9: 2 frozen + строка владельца → MINTED. # ИНВ: И-5
  T9="$WORK/l9-$RH1"; mk_mint_toy "$T9"; authority_tag "$T9" "$ACT3"; bare_frozen "$T9" "$ACT1"; bare_frozen "$T9" "$ACT2"; sync_tags "$T9"
  out9="$("$SUBJ_MINT" --root "$T9" --nnn "$ACT3" --reason "$REASON_OK" 2>"$WORK/e9")"; rc9=$?; err9="$(cat "$WORK/e9")"
  if [ "$rc9" -eq 0 ] && printf '%s' "$out9" | grep -qF "MINTED nnn=$ACT3" && printf '%s' "$err9" | grep -qF 'снято строкой владельца' \
     && diag9 "$err9" 2 "$ACT1" "$ACT2"; then pass л9
  else fail л9 "rc=$rc9 out=$out9 err=$(printf '%s' "$err9" | sed -n 1p)"; fi

  # л9б (негативная пара л9, свой чистый мир — л9 уже записала строку): строка
  # владельца без « сверх лимита» → отказ остаётся, stdout пуст. # ИНВ: И-5
  T9b="$WORK/l9b-$RH2"; mk_mint_toy "$T9b"; authority_tag "$T9b" "$ACT3"; bare_frozen "$T9b" "$ACT1"; bare_frozen "$T9b" "$ACT2"; sync_tags "$T9b"
  out9b="$("$SUBJ_MINT" --root "$T9b" --nnn "$ACT3" --reason "$REASON_NO" 2>"$WORK/e9b")"; rc9b=$?; err9b="$(cat "$WORK/e9b")"
  if [ "$rc9b" -eq 1 ] && printf '%s' "$err9b" | grep -qF "$LIM_NAME" && diag9 "$err9b" 2 "$ACT1" "$ACT2" && [ -z "$out9b" ]; then pass л9б
  else fail л9б "rc=$rc9b out=$out9b err=$(printf '%s' "$err9b" | sed -n 1p)"; fi

  # ── честные клетки freeze (л10–л14) ─────────────────────────────────────────
  # л10: 2 frozen ≠001 → отказ, тега нет; реестр байт-в-байт, HEAD, чистота — снимки
  # head10/reg10pre взяты ДО вызова в блоке л0. # ИНВ: И-4, И-9
  tags10="$(git -C "$T10" tag -l 'frozen/contracts/001/*' | wc -l)"
  if [ "$rc_fr" -eq 1 ] && printf '%s' "$err_fr" | grep -qF "$LIM_NAME" && diag9 "$err_fr" 2 "$ACT1" "$ACT2" \
     && [ "$tags10" -eq 0 ] && [ "$(git -C "$T10" rev-parse HEAD)" = "$head10" ] \
     && [ "$(reg_state "$T10")" = "$reg10pre" ] && [ -z "$(git -C "$T10" status --porcelain)" ]; then pass л10
  else fail л10 "rc=$rc_fr тегов 001=$tags10 err=$(printf '%s' "$err_fr" | sed -n 1p) — нетронутость реестра/HEAD/дерева не доказана"; fi

  # л10б (источник freeze — origin): два чужих wip ТОЛЬКО в bare-origin (локально НЕ
  # fetched — теги-only fetch не создаёт refs/remotes/origin/wip) + один fetched frozen
  # → честный счёт по origin видит 3 → отказ «активных 3»; считающий ЛОКАЛЬНЫЕ refs
  # видит 1 (только fetched frozen) и пропускает заморозку → красная здесь. # ИНВ: И-2, И-4, И-9
  T10b="$WORK/l10b-$RH2"; mk_freeze_toy "$T10b"; bare_wip "$T10b" "$ACT1"; bare_wip "$T10b" "$ACT2"; bare_frozen "$T10b" "$ACT3"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$T10b" fetch -q origin '+refs/tags/*:refs/tags/*' # только теги: wip остаются невидимыми локально
  head10b="$(git -C "$T10b" rev-parse HEAD)"; reg10bpre="$(reg_state "$T10b")"
  out10b="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T10b" 2>"$WORK/e10b")"; rc10b=$?; err10b="$(cat "$WORK/e10b")"
  if [ "$rc10b" -eq 1 ] && printf '%s' "$err10b" | grep -qF "$LIM_NAME" && diag9 "$err10b" 3 "$ACT1" "$ACT2" "$ACT3" \
     && [ -z "$out10b" ] && [ "$(git -C "$T10b" tag -l 'frozen/contracts/001/*' | wc -l)" -eq 0 ] \
     && [ "$(git -C "$T10b" rev-parse HEAD)" = "$head10b" ] && [ "$(reg_state "$T10b")" = "$reg10bpre" ] \
     && [ -z "$(git -C "$T10b" status --porcelain)" ]; then pass л10б
  else fail л10б "rc=$rc10b out=$out10b err=$(printf '%s' "$err10b" | sed -n 1p) — источник origin не доказан: считающий локальные refs видит 1 и пропускает"; fi

  # л11: 1 frozen ≠001 → v1. # ИНВ: И-4
  T11="$WORK/l11-$RH2"; mk_freeze_toy "$T11"; bare_frozen "$T11" "$ACT1"; sync_tags "$T11"
  out11="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T11" 2>"$WORK/e11")"; rc11=$?
  if [ "$rc11" -eq 0 ] && [ "$out11" = 'v1' ]; then pass л11
  else fail л11 "rc=$rc11 out=$out11 err=$(sed -n 1p "$WORK/e11")"; fi

  # л11б (маркер ниже порога — freeze, 078-к3 Р3): сетап л11 (1 frozen ≠001) +
  # причиной $2 REASON_OK → rc 0 v1; stderr БЕЗ «лимит активных» (freeze печатает
  # свои ok-строки — сверка отрицательная, не «stderr пуст»). # ИНВ: И-5, И-9
  T11b="$WORK/l11b-$RH1"; mk_freeze_toy "$T11b"; bare_frozen "$T11b" "$ACT1"; sync_tags "$T11b"
  out11b="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "$REASON_OK" "$T11b" 2>"$WORK/e11b")"; rc11b=$?; err11b="$(cat "$WORK/e11b")"
  if [ "$rc11b" -eq 0 ] && [ "$out11b" = 'v1' ] && ! printf '%s' "$err11b" | grep -qF "$LIM_NAME"; then pass л11б
  else fail л11б "rc=$rc11b out=$out11b err=$(printf '%s' "$err11b" | sed -n 1p) — маркер ниже порога меняет вывод (И-5 нарушен)"; fi

  # л11в (почти-маркер ниже порога — freeze, 078-к3 Р3): сетап л11 + REASON_NO →
  # rc 0 v1, stderr БЕЗ «лимит активных». # ИНВ: И-5, И-9
  T11v="$WORK/l11v-$RH2"; mk_freeze_toy "$T11v"; bare_frozen "$T11v" "$ACT1"; sync_tags "$T11v"
  out11v="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "$REASON_NO" "$T11v" 2>"$WORK/e11v")"; rc11v=$?; err11v="$(cat "$WORK/e11v")"
  if [ "$rc11v" -eq 0 ] && [ "$out11v" = 'v1' ] && ! printf '%s' "$err11v" | grep -qF "$LIM_NAME"; then pass л11в
  else fail л11в "rc=$rc11v out=$out11v err=$(printf '%s' "$err11v" | sed -n 1p) — почти-маркер ниже порога меняет вывод (И-5 нарушен)"; fi

  # л12: 2 frozen + строка владельца в причине → v1. # ИНВ: И-5
  T12="$WORK/l12-$RH1"; mk_freeze_toy "$T12"; bare_frozen "$T12" "$ACT1"; bare_frozen "$T12" "$ACT2"; sync_tags "$T12"
  out12="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "$REASON_OK" "$T12" 2>"$WORK/e12")"; rc12=$?; err12="$(cat "$WORK/e12")"
  if [ "$rc12" -eq 0 ] && [ "$out12" = 'v1' ] && printf '%s' "$err12" | grep -qF 'снято строкой владельца' \
     && diag9 "$err12" 2 "$ACT1" "$ACT2"; then pass л12
  else fail л12 "rc=$rc12 out=$out12 err=$(printf '%s' "$err12" | sed -n 1p)"; fi

  # л12б (негативная пара л12, свой чистый мир — л12 уже заморозил 001): причина
  # «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» без « сверх лимита» → отказ остаётся, тега нет. # ИНВ: И-5
  T12b="$WORK/l12b-$RH2"; mk_freeze_toy "$T12b"; bare_frozen "$T12b" "$ACT1"; bare_frozen "$T12b" "$ACT2"; sync_tags "$T12b"
  out12b="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "$REASON_NO" "$T12b" 2>"$WORK/e12b")"; rc12b=$?; err12b="$(cat "$WORK/e12b")"
  if [ "$rc12b" -eq 1 ] && printf '%s' "$err12b" | grep -qF "$LIM_NAME" && diag9 "$err12b" 2 "$ACT1" "$ACT2" && [ -z "$out12b" ] \
     && [ "$(git -C "$T12b" tag -l 'frozen/contracts/001/*' | wc -l)" -eq 0 ]; then pass л12б
  else fail л12б "rc=$rc12b out=$out12b тегов 001=$(git -C "$T12b" tag -l 'frozen/contracts/001/*' | wc -l) err=$(printf '%s' "$err12b" | sed -n 1p)"; fi

  # л13: активен только сам 001 (wip/001 на origin) → v1. # ИНВ: И-4
  T13="$WORK/l13-$RH2"; mk_freeze_toy "$T13"; g "$(bare_of "$T13")" branch 'wip/001/fixture' refs/heads/main
  out13="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T13" 2>"$WORK/e13")"; rc13=$?
  if [ "$rc13" -eq 0 ] && [ "$out13" = 'v1' ]; then pass л13
  else fail л13 "rc=$rc13 out=$out13 err=$(sed -n 1p "$WORK/e13")"; fi

  # л14: сам 001 (wip) + 2 frozen ≠001 → rc 1 (вычтен только замораживаемый). # ИНВ: И-4
  T14="$WORK/l14-$RH1"; mk_freeze_toy "$T14"; g "$(bare_of "$T14")" branch 'wip/001/fixture' refs/heads/main; bare_frozen "$T14" "$ACT1"; bare_frozen "$T14" "$ACT2"; sync_tags "$T14"
  out14="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T14" 2>"$WORK/e14")"; rc14=$?; err14="$(cat "$WORK/e14")"
  if [ "$rc14" -eq 1 ] && printf '%s' "$err14" | grep -qF "$LIM_NAME" && diag9 "$err14" 2 "$ACT1" "$ACT2"; then pass л14
  else fail л14 "rc=$rc14 out=$out14 err=$(printf '%s' "$err14" | sed -n 1p)"; fi

  # л14б (пограничная различающая вычет субъекта): сам 001 (wip) + ОДИН frozen →
  # честный вычет сам → 1 активный → v1; невычитающая реализация видит 2 → rc 1. # ИНВ: И-4
  T14b="$WORK/l14b-$RH2"; mk_freeze_toy "$T14b"; g "$(bare_of "$T14b")" branch 'wip/001/fixture' refs/heads/main; bare_frozen "$T14b" "$ACT1"; sync_tags "$T14b"
  out14b="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T14b" 2>"$WORK/e14b")"; rc14b=$?
  if [ "$rc14b" -eq 0 ] && [ "$out14b" = 'v1' ]; then pass л14б
  else fail л14б "rc=$rc14b out=$out14b err=$(sed -n 1p "$WORK/e14b") — вычет замораживаемого не доказан: невычитающая реализация даёт здесь rc 1"; fi

  # л14в (исключение на пересечении + чужой wip, 078-к3 Р2/З5): 001 сам в ОБОИХ
  # пространствах (frozen/contracts/001/1 И wip/001/*) + frozen <ACT1> + wip <ACT2>
  # → freeze 001: rc 1 «лимит активных», diag9 2 ACT1 ACT2 — вычет И-4 снимает 001
  # из ОБОИХ частей целиком: вычитающий одну часть до объединения видит 3, mut2-класс
  # «пересечение → только F» видит 1 и пропускает, невычитающая реализация видит 3.
  # Тегов frozen/contracts/001/* сверх fetched v1 нет, реестр байт-в-байт, HEAD и
  # чистота как в л10. # ИНВ: И-1, И-4, И-9
  T14v="$WORK/l14v-$RH1"; mk_freeze_toy "$T14v"; bare_frozen "$T14v" 001; g "$(bare_of "$T14v")" branch 'wip/001/fixture' refs/heads/main; bare_frozen "$T14v" "$ACT1"; bare_wip "$T14v" "$ACT2"; sync_tags "$T14v"
  head14v="$(git -C "$T14v" rev-parse HEAD)"; reg14v="$(reg_state "$T14v")"
  out14v="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T14v" 2>"$WORK/e14v")"; rc14v=$?; err14v="$(cat "$WORK/e14v")"
  if [ "$rc14v" -eq 1 ] && printf '%s' "$err14v" | grep -qF "$LIM_NAME" && diag9 "$err14v" 2 "$ACT1" "$ACT2" \
     && [ -z "$out14v" ] && [ "$(git -C "$T14v" tag -l 'frozen/contracts/001/*' | wc -l)" -eq 1 ] \
     && [ "$(git -C "$T14v" rev-parse HEAD)" = "$head14v" ] && [ "$(reg_state "$T14v")" = "$reg14v" ] \
     && [ -z "$(git -C "$T14v" status --porcelain)" ]; then pass л14в
  else fail л14в "rc=$rc14v out=$out14v тегов 001=$(git -C "$T14v" tag -l 'frozen/contracts/001/*' | wc -l) err=$(printf '%s' "$err14v" | sed -n 1p) — вычет исключения из ОБОИХ частей не доказан: вычитающий одну часть видит 3, mut2-класс видит 1 и пропускает"; fi

  # ── честные клетки входов адверсария 078-v1: fail-closed потребителей и ноль refs ──
  # PATH-шим: rc 1 ТОЛЬКО лимитному ls-remote (три паттерна active_contracts_list);
  # прочие git-вызовы (dual-control mint — одиночный refs/tags/id/CONTRACT/<NNN>,
  # registry_state — refs/tags/frozen/*, локальные чтения) уходят к живому git.
  # Так «авторитет недоступен» наблюдается ПОСЛЕ успешной dual-control — вход №1.
  SHIM="$WORK/shim078-$RH1"; mkdir -p "$SHIM"
  REALGIT="$(command -v git)"
  printf '#!/usr/bin/env bash\nfor a in "$@"; do case "$a" in %s|%s|%s) exit 1 ;; esac; done\nexec %s "$@"\n' \
    "'refs/tags/frozen/contracts/*'" "'refs/tags/done/contracts/*'" "'refs/heads/wip/*'" "$REALGIT" > "$SHIM/git"
  chmod +x "$SHIM/git"

  # л16: mint, отказ лимитного ls-remote ПОСЛЕ dual-control → fail-closed без мутации. # ИНВ: И-2, И-9
  T16="$WORK/l16-$RH1"; mk_mint_toy "$T16"; authority_tag "$T16" "$ACT3"; bare_frozen "$T16" "$ACT1"; sync_tags "$T16"
  h16="$(git -C "$T16" rev-parse HEAD)"
  out16="$(PATH="$SHIM:$PATH" "$SUBJ_MINT" --root "$T16" --nnn "$ACT3" 2>"$WORK/e16")"; rc16=$?; err16="$(cat "$WORK/e16")"
  lines16="$(git -C "$T16" cat-file -p HEAD:registry/contracts.tsv | grep -cF "$ACT3 → " || true)"
  if [ "$rc16" -eq 1 ] && printf '%s' "$err16" | grep -qF "$LIM_NAME" \
     && printf '%s' "$err16" | grep -qF 'авторитет недоступен' && printf '%s' "$err16" | grep -qF 'данные неизвестны' \
     && [ -z "$out16" ] && [ "$lines16" -eq 0 ] && [ "$(git -C "$T16" rev-parse HEAD)" = "$h16" ] \
     && [ -z "$(git -C "$T16" status --porcelain)" ]; then pass л16
  else fail л16 "rc=$rc16 out=$out16 строк=$lines16 err=$(printf '%s' "$err16" | sed -n 1p) — отказ лимитного ls-remote после dual-control не fail-closed"; fi

  # л17: freeze, отказ лимитного ls-remote → fail-closed ДО тега и реестра. # ИНВ: И-2, И-9
  T17="$WORK/l17-$RH2"; mk_freeze_toy "$T17"; bare_frozen "$T17" "$ACT1"; sync_tags "$T17"
  h17="$(git -C "$T17" rev-parse HEAD)"; reg17="$(reg_state "$T17")"
  out17="$(cd / && PATH="$SHIM:$PATH" "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T17" 2>"$WORK/e17")"; rc17=$?; err17="$(cat "$WORK/e17")"
  if [ "$rc17" -eq 1 ] && printf '%s' "$err17" | grep -qF "$LIM_NAME" \
     && printf '%s' "$err17" | grep -qF 'авторитет недоступен' && printf '%s' "$err17" | grep -qF 'данные неизвестны' \
     && [ -z "$out17" ] && [ "$(git -C "$T17" tag -l 'frozen/contracts/001/*' | wc -l)" -eq 0 ] \
     && [ "$(git -C "$T17" rev-parse HEAD)" = "$h17" ] && [ "$(reg_state "$T17")" = "$reg17" ] \
     && [ -z "$(git -C "$T17" status --porcelain)" ]; then pass л17
  else fail л17 "rc=$rc17 out=$out17 err=$(printf '%s' "$err17" | sed -n 1p) — отказ лимитного ls-remote не fail-closed до тега/реестра"; fi

  # л18: next_id, origin жив, ПУСТО во всех трёх пространствах → успех без диагностики. # ИНВ: И-1, И-3
  T18="$WORK/l18-$RH1"; mk_next_toy "$T18"
  out18="$("$SUBJ_NEXT" "$T18" CONTRACT 2>"$WORK/e18")"; rc18=$?; err18="$(cat "$WORK/e18")"
  if [ "$rc18" -eq 0 ] && [ "$out18" = "$want2" ] && [ "$(git -C "$T18" tag -l 'id/CONTRACT/*' | wc -l)" -eq 2 ] \
     && ! printf '%s' "$err18" | grep -qF "$LIM_NAME"; then pass л18
  else fail л18 "rc=$rc18 out=$out18 err=$(printf '%s' "$err18" | sed -n 1p) — пустой авторитетный ответ ошибочно считается недоступным"; fi

  # л19: mint, на origin только id/CONTRACT/<ACT3> (не активен) → MINTED без диагностики. # ИНВ: И-1, И-3
  T19="$WORK/l19-$RH2"; mk_mint_toy "$T19"; authority_tag "$T19" "$ACT3"; sync_tags "$T19"
  out19="$("$SUBJ_MINT" --root "$T19" --nnn "$ACT3" 2>"$WORK/e19")"; rc19=$?; err19="$(cat "$WORK/e19")"
  if [ "$rc19" -eq 0 ] && printf '%s' "$out19" | grep -qF "MINTED nnn=$ACT3" \
     && ! printf '%s' "$err19" | grep -qF "$LIM_NAME"; then pass л19
  else fail л19 "rc=$rc19 out=$out19 err=$(printf '%s' "$err19" | sed -n 1p) — пустой авторитетный ответ ошибочно считается недоступным"; fi

  # л20: freeze, ни одного frozen/done/wip на origin → v1 без диагностики лимита. # ИНВ: И-1, И-3, И-4
  T20="$WORK/l20-$RH1"; mk_freeze_toy "$T20"; sync_tags "$T20"
  out20="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH1" "$T20" 2>"$WORK/e20")"; rc20=$?; err20="$(cat "$WORK/e20")"
  if [ "$rc20" -eq 0 ] && [ "$out20" = 'v1' ] && ! printf '%s' "$err20" | grep -qF "$LIM_NAME"; then pass л20
  else fail л20 "rc=$rc20 out=$out20 err=$(printf '%s' "$err20" | sed -n 1p) — пустой авторитетный ответ ошибочно считается недоступным"; fi

  # ── клетки границы SLA 15s (адверсарий 078-v2 к2): наблюдаемость timeout-обёртки ──
  # Делегирующий PATH-шим git (техника адверсария): ЛИМИТНЫЙ ls-remote (три паттерна
  # active_contracts_list) отвечает после контролируемой задержки, прочие git-вызовы
  # уходят к живому git сразу. 6s — «здоровый, но медленный» авторитет
  # (6s < 15s; ловит мутантов фактической границы 1s И 5s — оба убивают 6s-ответ);
  # 17s — исправный, но ПОЗЖЕ границы. Цена SLA-клеток (078-v2 к3): честные л21/л23/
  # л25 +6s каждая, л22/л24/л26 — обёртка режет спящий шим на 15-й секунде (TERM
  # доходит до sleep мгновенно, rc 124); нарушения Т/124 добавляют ~7s (Т убит на
  # 1s + честные 6s) и 15s+15s (честный таймаут + стаб-успех) на потребителя. Всё
  # ограничено обёрткой 15s — зависания, ради которого она введена, здесь нет.
  mk_slowshim() { # mk_slowshim <каталог> <задержка-s>
    local d="$1"
    mkdir -p "$d"
    printf '#!/usr/bin/env bash\nfor a in "$@"; do case "$a" in %s|%s|%s) sleep %s; exec %s "$@" ;; esac; done\nexec %s "$@"\n' \
      "'refs/tags/frozen/contracts/*'" "'refs/tags/done/contracts/*'" "'refs/heads/wip/*'" "$2" "$REALGIT" "$REALGIT" > "$d/git"
    chmod +x "$d/git"
  }
  SLOW6="$WORK/slow078-6s-$RH1"; mk_slowshim "$SLOW6" 6
  SLOW17="$WORK/slow078-17s-$RH2"; mk_slowshim "$SLOW17" 17

  # л21: медленный, но ЗДОРОВЫЙ авторитет (ответ 6s < SLA 15s) → нормальный успех без
  # диагностики — мутант фактической границы 1s/5s убивает 6s-ответ и ложно отказывает
  # (дыра 078-v2: батарея не наблюдала границу вовсе). # ИНВ: И-2
  T21="$WORK/l21-$RH2"; mk_next_toy "$T21"
  out21="$(PATH="$SLOW6:$PATH" "$SUBJ_NEXT" "$T21" CONTRACT 2>"$WORK/e21")"; rc21=$?; err21="$(cat "$WORK/e21")"
  if [ "$rc21" -eq 0 ] && [ "$out21" = "$want2" ] && ! printf '%s' "$err21" | grep -qF "$LIM_NAME"; then pass л21
  else fail л21 "rc=$rc21 out=$out21 err=$(printf '%s' "$err21" | sed -n 1p) — здоровый, но медленный (6s < SLA 15s) авторитет отвергнут: фактическая граница таймаута уже нормативной"; fi

  # л22: исправный авторитет ответил ПОЗЖЕ границы 15s (шим 17s) → НОРМАТИВНЫЙ
  # fail-closed (SLA И-2, 078-v2): rc 124 обёртки переводится в именованный отказ,
  # мутации нет — тег сверх seed не создан. # ИНВ: И-2, И-9
  T22="$WORK/l22-$RH1"; mk_next_toy "$T22"
  out22="$(PATH="$SLOW17:$PATH" "$SUBJ_NEXT" "$T22" CONTRACT 2>"$WORK/e22")"; rc22=$?; err22="$(cat "$WORK/e22")"
  if [ "$rc22" -eq 1 ] && printf '%s' "$err22" | grep -qF "$LIM_NAME" \
     && printf '%s' "$err22" | grep -qF 'авторитет недоступен' && printf '%s' "$err22" | grep -qF 'данные неизвестны' \
     && printf '%s' "$err22" | grep -qF 'rc=124' \
     && [ -z "$out22" ] && [ "$(git -C "$T22" tag -l 'id/CONTRACT/*' | wc -l)" -eq 1 ]; then pass л22
  else fail л22 "rc=$rc22 out=$out22 err=$(printf '%s' "$err22" | sed -n 1p) — ответ позже SLA 15s не переведён в именованный fail-closed rc=124 без мутации"; fi

  # л23 (граница SLA — mint, 078-v2 к3): здоровый, но медленный авторитет (6s <
  # SLA 15s), dual-control уже прошёл → MINTED без диагностики лимита; мутант
  # фактической границы 1s ложно отказывает после dual-control. # ИНВ: И-2
  T23="$WORK/l23-$RH1"; mk_mint_toy "$T23"; authority_tag "$T23" "$ACT3"; sync_tags "$T23"
  out23="$(PATH="$SLOW6:$PATH" "$SUBJ_MINT" --root "$T23" --nnn "$ACT3" 2>"$WORK/e23")"; rc23=$?; err23="$(cat "$WORK/e23")"
  if [ "$rc23" -eq 0 ] && printf '%s' "$out23" | grep -qF "MINTED nnn=$ACT3" \
     && ! printf '%s' "$err23" | grep -qF "$LIM_NAME"; then pass л23
  else fail л23 "rc=$rc23 out=$out23 err=$(printf '%s' "$err23" | sed -n 1p) — здоровый, но медленный (6s < SLA 15s) авторитет отвергнут на входе mint"; fi

  # л24 (граница SLA — mint, 078-v2 к3): авторитет ответил ПОЗЖЕ границы (шим 17s) →
  # НОРМАТИВНЫЙ fail-closed ПОСЛЕ dual-control: rc 1, именованный отказ несёт rc=124,
  # строки в реестре нет, HEAD/дерево нетронуты. Мутант «124→0 до fail-closed ветви»
  # (к3) превращает таймаут в пустой список и МИНТУЕТ → красная здесь. # ИНВ: И-2, И-9
  T24="$WORK/l24-$RH2"; mk_mint_toy "$T24"; authority_tag "$T24" "$ACT3"; sync_tags "$T24"
  h24="$(git -C "$T24" rev-parse HEAD)"
  out24="$(PATH="$SLOW17:$PATH" "$SUBJ_MINT" --root "$T24" --nnn "$ACT3" 2>"$WORK/e24")"; rc24=$?; err24="$(cat "$WORK/e24")"
  lines24="$(git -C "$T24" cat-file -p HEAD:registry/contracts.tsv | grep -cF "$ACT3 → " || true)"
  if [ "$rc24" -eq 1 ] && printf '%s' "$err24" | grep -qF "$LIM_NAME" \
     && printf '%s' "$err24" | grep -qF 'авторитет недоступен' && printf '%s' "$err24" | grep -qF 'данные неизвестны' \
     && printf '%s' "$err24" | grep -qF 'rc=124' \
     && [ -z "$out24" ] && [ "$lines24" -eq 0 ] && [ "$(git -C "$T24" rev-parse HEAD)" = "$h24" ] \
     && [ -z "$(git -C "$T24" status --porcelain)" ]; then pass л24
  else fail л24 "rc=$rc24 out=$out24 строк=$lines24 err=$(printf '%s' "$err24" | sed -n 1p) — ответ позже SLA 15s не переведён в именованный fail-closed rc=124 без мутации (мутант 124→0 минтует)"; fi

  # л25 (граница SLA — freeze, 078-v2 к3): здоровый медленный авторитет (6s) → v1
  # без диагностики лимита. # ИНВ: И-2
  T25="$WORK/l25-$RH1"; mk_freeze_toy "$T25"; sync_tags "$T25"
  out25="$(cd / && PATH="$SLOW6:$PATH" "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH1" "$T25" 2>"$WORK/e25")"; rc25=$?; err25="$(cat "$WORK/e25")"
  if [ "$rc25" -eq 0 ] && [ "$out25" = 'v1' ] && ! printf '%s' "$err25" | grep -qF "$LIM_NAME"; then pass л25
  else fail л25 "rc=$rc25 out=$out25 err=$(printf '%s' "$err25" | sed -n 1p) — здоровый, но медленный (6s < SLA 15s) авторитет отвергнут на входе freeze"; fi

  # л26 (граница SLA — freeze, 078-v2 к3): ответ позже границы (17s) → именованный
  # fail-closed ДО тега и реестра: rc 1, rc=124, тега 001 нет, HEAD/реестр/дерево
  # нетронуты; мутант «124→0» замораживает → красная здесь. # ИНВ: И-2, И-9
  T26="$WORK/l26-$RH2"; mk_freeze_toy "$T26"; sync_tags "$T26"
  h26="$(git -C "$T26" rev-parse HEAD)"; reg26="$(reg_state "$T26")"
  out26="$(cd / && PATH="$SLOW17:$PATH" "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$T26" 2>"$WORK/e26")"; rc26=$?; err26="$(cat "$WORK/e26")"
  if [ "$rc26" -eq 1 ] && printf '%s' "$err26" | grep -qF "$LIM_NAME" \
     && printf '%s' "$err26" | grep -qF 'авторитет недоступен' && printf '%s' "$err26" | grep -qF 'данные неизвестны' \
     && printf '%s' "$err26" | grep -qF 'rc=124' \
     && [ -z "$out26" ] && [ "$(git -C "$T26" tag -l 'frozen/contracts/001/*' | wc -l)" -eq 0 ] \
     && [ "$(git -C "$T26" rev-parse HEAD)" = "$h26" ] && [ "$(reg_state "$T26")" = "$reg26" ] \
     && [ -z "$(git -C "$T26" status --porcelain)" ]; then pass л26
  else fail л26 "rc=$rc26 out=$out26 err=$(printf '%s' "$err26" | sed -n 1p) — ответ позже SLA 15s не переведён в именованный fail-closed rc=124 до тега/реестра (мутант 124→0 замораживает)"; fi
else
  for c in л1 л2 л2б л2в л3 л3б л4 л5 л5б л5в лР л6 л7 л7б л8 л8б л8в л9 л9б л10 л10б л11 л11б л11в л12 л12б л13 л14 л14б л14в л15 л16 л17 л18 л19 л20 л21 л22 л23 л24 л25 л26; do norun "$c"; done
fi

# ── стаб-пак: мутантные копии мини-ядра (самодостаточен — не зависит от субъекта) ──
mk_stub() { # mk_stub <А|Б|В|Г|Д|Е> <путь-копии>: одна замена одной строки по маркеру
  python3 - "$1" "$CORE" "$2" <<'PY'
import sys
which, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
repl = {
 "А": ('ВЕТВЬ:LSREMOTE',
   "refs=\"$(git -C \"$root\" for-each-ref --format='%(objectname) %(refname)' "
   "'refs/tags/frozen/contracts/*' 'refs/tags/done/contracts/*' 'refs/heads/wip/*' "
   "2>/dev/null)\" || ls_rc=$? # ВЕТВЬ:LSREMOTE — СТАБ-А (источник: локальные refs)"),
 "Б": ('ВЕТВЬ:DONE', "    # ВЕТВЬ:DONE — СТАБ-Б (done не вычитается)"),
 "В": ('ВЕТВЬ:WIP',  "    # ВЕТВЬ:WIP — СТАБ-В (wip-ветки не считаются)"),
 "Г": ('ВЕТВЬ:REASON',
   "[ \"$reason\" = \"-\" ] || case \"$reason\" in *'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'*) "
   "printf '  ok   лимит активных контрактов: снято строкой владельца, активных %s ≥ 2: %s\\n' \"$n\" \"$list\" >&2; exit 0 ;; esac "
   "# ВЕТВЬ:REASON — СТАБ-Г (широкий матчинг любой строки владельца)"),
 "Д": ('ВЕТВЬ:EXCEPT', ": # ВЕТВЬ:EXCEPT — СТАБ-Д (замораживаемый не вычитается)"),
 "Е": ('ВЕТВЬ:NETFAIL', ": # ВЕТВЬ:NETFAIL — СТАБ-Е (сеть = пропуск)"),
 "Ж": ('ВЕТВЬ:WIP',
   "    for (k in w) act[\"w:\"k]=1 # ВЕТВЬ:WIP — СТАБ-Ж (double_namespace: wip в отдельном ключе, пересечение frozen∩wip считается дважды)"),
}
marker, line = repl[which]
out, hit = [], 0
for l in open(src, encoding='utf-8'):
    if marker in l and ' — СТАБ-' not in l:
        out.append(line + "\n"); hit += 1
    else:
        out.append(l)
assert hit == 1, f"маркер {marker} встречен {hit} раз (ожидался 1)"
open(dst, 'w', encoding='utf-8').write(''.join(out))
PY
}

# ЯДРО-КОНТРОЛЬ: честное мини-ядро на чистом мире — rc 0 (иначе весь стаб-пак нечестен).
TS0="$WORK/ts0-$RH1"; mk_next_toy "$TS0"
core0=0; bash "$CORE" "$TS0" - - >/dev/null 2>&1 || core0=$?
if [ "$core0" -eq 0 ]; then pass ядро0; else fail ядро0 "честное ядро отказало на чистом мире rc=$core0"; fi

# Генерация семи стабов + две меры применения (cmp ∧ grep -F).
declare -A STUB_PATH=()
for s in А Б В Г Д Е Ж; do
  p="$WORK/stub$s.sh"
  if mk_stub "$s" "$p" 2>"$WORK/e-stub$s" \
     && ! cmp -s "$CORE" "$p" \
     && grep -qF "СТАБ-$s" "$p"; then
    STUB_PATH[$s]="$p"; pass "стаб$s-применён"
  else
    fail "стаб$s-применён" "мутация не применилась/не помечена: $(sed -n 1p "$WORK/e-stub$s" 2>/dev/null)"
  fi
done

# Диффпробы: стаб на чистом мире rc 0 (параноик ловится здесь).
for s in А Б В Г Д Е Ж; do
  [ -n "${STUB_PATH[$s]:-}" ] || continue
  rc=0; bash "${STUB_PATH[$s]}" "$TS0" - - 2>"$WORK/d$s" >/dev/null || rc=$?
  if [ "$rc" -eq 0 ]; then pass "дифф$s"
  else fail "дифф$s" "стаб параноик: чистый мир rc=$rc: $(sed -n 1p "$WORK/d$s") [стаб=${STUB_PATH[$s]} мир=$TS0 remote=$(git -C "$TS0" remote get-url origin 2>&1)]"; fi
done

# Нарушения: честное ядро и стаб на входе наблюдаемости дефекта (таблица Н-39 контракта).
viol() { # viol <стаб> <мир> <except> <reason> <ядро-rc> <стаб-rc>
  local s="$1" world="$2" exc="$3" rsn="$4" wrc="$5" swant="$6" crc=0 src=0
  bash "$CORE" "$world" "$exc" "$rsn" >/dev/null 2>&1 || crc=$?
  bash "${STUB_PATH[$s]}" "$world" "$exc" "$rsn" >/dev/null 2>&1 || src=$?
  if [ "$crc" -eq "$wrc" ] && [ "$src" -eq "$swant" ]; then pass "наруш$s"
  else fail "наруш$s" "ядро rc=$crc (хотели $wrc), стаб rc=$src (хотели $swant) — стаб не обманут на своём входе"; fi
}
TA="$WORK/ta-$RH1"; mk_next_toy "$TA"; bare_frozen "$TA" "$ACT1"; bare_frozen "$TA" "$ACT2" # 2 frozen только на origin
TB="$WORK/tb-$RH2"; mk_next_toy "$TB"; bare_frozen "$TB" "$ACT1"; bare_frozen "$TB" "$ACT2"; bare_done "$TB" "$ACT2" # done закрывает одного
TV="$WORK/tv-$RH1"; mk_next_toy "$TV"; bare_wip "$TV" "$ACT1"; bare_wip "$TV" "$ACT2" # 2 wip
TE="$WORK/te-$RH2"; mk_next_toy "$TE"; g "$TE" remote set-url origin "$WORK/mrt2-$RH1/x.git" # мёртвый origin
viol А "$TA" - - 1 0
viol Б "$TB" - - 0 1
viol В "$TV" - - 1 0
viol Г "$TA" - "$REASON_NO" 1 0
viol Д "$TA" "$ACT1" - 0 1 # TA: 2 frozen (ACT1, ACT2), вычтен замораживаемый ACT1 → честно активен 1 → rc 0; стаб-Д не вычтен → видит 2 → rc 1
viol Е "$TE" - - 3 0
TNS="$WORK/tns-$RH1"; mk_next_toy "$TNS"; bare_frozen "$TNS" "$ACT1"; bare_wip "$TNS" "$ACT1" # ОДИН NNN в frozen И wip — double_namespace-вход
viol Ж "$TNS" - - 0 1 # честное ядро: активен 1 → rc 0; стаб-Ж считает пересечение дважды → 2 → rc 1

# ── субъектные стабы Фм/Фф/П (два класса вердикта 078-v1) ─────────────────────
# Обманные субъекты адверсария как стабы батареи: мутантные копии РЕАЛЬНЫХ scripts/
# (одна замена одной строки по якорю кода, применение двумя мерами cmp ∧ grep -F).
# Гейт л0: якоря существуют только у реализованного субъекта; до реализации л0 уже
# красная и субъектный стаб-пак не исполняется.
if [ "$PRESENT" -eq 1 ]; then
  declare -A SUBJ_STUB=()
  mk_subj_stub() { # mk_subj_stub <имя> <файл-в-scripts> <якорь> <замена>: копия scripts/ + одна замена
    local name="$1" fname="$2" anchor="$3" repl="$4" d
    d="$WORK/subj-$name"; rm -rf "$d"; cp -r "$ROOT/scripts" "$d"
    python3 - "$d/$fname" "$anchor" "$repl" <<'PY'
import sys
path, anchor, repl = sys.argv[1], sys.argv[2], sys.argv[3]
out, hit = [], 0
for l in open(path, encoding='utf-8'):
    if anchor in l:
        out.append(repl + "\n"); hit += 1
    else:
        out.append(l)
assert hit == 1, f"якорь встречен {hit} раз (ожидался 1): {anchor}"
open(path, 'w', encoding='utf-8').write(''.join(out))
PY
  }
  subj_ok() { # subj_ok <имя> <файл> <якорь> <замена>: генерация + две меры применения
    local name="$1" f="$2" a="$3" r="$4"
    if mk_subj_stub "$name" "$f" "$a" "$r" 2>"$WORK/e-s$name" \
       && ! cmp -s "$ROOT/scripts/$f" "$WORK/subj-$name/$f" \
       && grep -qF "СТАБ-$name" "$WORK/subj-$name/$f"; then
      SUBJ_STUB[$name]=1; pass "стаб${name}-применён"
    else
      fail "стаб${name}-применён" "мутация не применилась/не помечена: $(sed -n 1p "$WORK/e-s$name" 2>/dev/null)"
    fi
  }
  subj_ok Фм mint_line.sh 'if [ "$active_rc" -ne 0 ]; then' \
    'if false; then # СТАБ-Фм — fail-open: отказ active_contracts_list игнорируется'
  subj_ok Фф freeze_contract.sh 'if [ "$active_rc" -ne 0 ]; then' \
    '  if false; then # СТАБ-Фф — fail-open: отказ active_contracts_list игнорируется'
  subj_ok П lib_active_contracts.sh 'if [ "$ls_rc" -ne 0 ]; then' \
    '  if [ "$ls_rc" -ne 0 ] || [ -z "$refs" ]; then # СТАБ-П — пустой ls-remote ошибочно считается недоступностью'
  # СТАБ-Т (078-v2 к2): мутантная копия scripts/ с ФАКТИЧЕСКОЙ границей 1s — та же
  # техника, что Фм/Фф/П; якорь в середине строки с refspec-кавычками, потому мутация —
  # python-replace значения таймаута, маркер — хвостом той же строки.
  TSTUB="$WORK/subj-Т"; rm -rf "$TSTUB"; cp -r "$ROOT/scripts" "$TSTUB"
  python3 - "$TSTUB/lib_active_contracts.sh" <<'PYT'
import sys
path = sys.argv[1]
lines = open(path, encoding='utf-8').readlines()
out, hit = [], 0
for l in lines:
    if 'timeout 15s git' in l:
        out.append(l.replace('timeout 15s git', 'timeout 1s git').rstrip('\n')
                   + ' # СТАБ-Т — фактическая граница 1s: вялый 2s-авторитет убит как зависший (078-v2 к2)\n')
        hit += 1
    else:
        out.append(l)
assert hit == 1, 'якорь timeout 15s git встречен %d раз (ожидался 1)' % hit
open(path, 'w', encoding='utf-8').write(''.join(out))
PYT
  if ! cmp -s "$ROOT/scripts/lib_active_contracts.sh" "$TSTUB/lib_active_contracts.sh" \
     && grep -qF 'СТАБ-Т' "$TSTUB/lib_active_contracts.sh"; then
    SUBJ_STUB[Т]=1; pass "стабТ-применён"
  else
    fail "стабТ-применён" "мутация не применилась/не помечена (якоря timeout 15s git нет — дерево уже с иной границей?)"
  fi

  # СТАБ-124м/124ф (078-v2 к3): обманный субъект адверсария — «таймаут = успешный
  # пустой список». ДВЕ опоры (замер живым прогоном: потребительский гаситель
  # `-eq 124` в одиночку НЕЖИЗНЕНЕН — ядро возвращает 1, стаб ведёт себя честно):
  # ядро всплывает rc дословно (return "$ls_rc") + потребительский гаситель
  # (active_rc=124→0) ДО fail-closed ветви. Применение — двумя мерами на КАЖДЫЙ
  # файл (cmp ∧ grep -F маркера).
  for pair in '124м:mint_line.sh' '124ф:freeze_contract.sh'; do
    nm="${pair%%:*}"; cfile="${pair#*:}"
    cdir="$WORK/subj-$nm"; rm -rf "$cdir"; cp -r "$ROOT/scripts" "$cdir"
    python3 - "$cdir" "$cfile" "$nm" <<'PY124'
import sys
d, f, nm = sys.argv[1], sys.argv[2], sys.argv[3]
GUARD = {'mint_line.sh': 'if [ "$active_rc" -eq 124 ]; then active_rc=0; fi',
         'freeze_contract.sh': '  if [ "$active_rc" -eq 124 ]; then active_rc=0; fi'}[f]
lib = d + '/lib_active_contracts.sh'
out, hit = [], 0
for l in open(lib, encoding='utf-8'):
    if 'недоступен (ls-remote origin rc=%s)' in l:
        out.append(l.rstrip('\n') + '; return "$ls_rc" # СТАБ-' + nm + ' — опора 1: таймаут всплывает потребителю дословно\n')
        hit += 1
    else:
        out.append(l)
assert hit == 1, 'якорь ядра встречен %d раз (ожидался 1)' % hit
open(lib, 'w', encoding='utf-8').writelines(out)
c = d + '/' + f
out, hit = [], 0
for l in open(c, encoding='utf-8'):
    if 'if [ "$active_rc" -ne 0 ]; then' in l:
        out.append(GUARD + ' # СТАБ-' + nm + ' — опора 2: таймаут ошибочно считается успехом (078-v2 к3)\n')
        hit += 1
    out.append(l)
assert hit == 1, 'якорь потребителя встречен %d раз (ожидался 1)' % hit
open(c, 'w', encoding='utf-8').writelines(out)
PY124
    if ! cmp -s "$ROOT/scripts/lib_active_contracts.sh" "$cdir/lib_active_contracts.sh" \
       && ! cmp -s "$ROOT/scripts/$cfile" "$cdir/$cfile" \
       && grep -qF "СТАБ-$nm" "$cdir/lib_active_contracts.sh" \
       && grep -qF "СТАБ-$nm" "$cdir/$cfile"; then
      SUBJ_STUB[$nm]=1; pass "стаб${nm}-применён"
    else
      fail "стаб${nm}-применён" "мутация не применилась/не помечена (якорь ядра или потребителя не найден)"
    fi
  done

  # Диффпробы: на входе ВНЕ дефекта стабы ведут себя честно (не параноики).
  if [ -n "${SUBJ_STUB[Фм]:-}" ]; then
    DFM="$WORK/dfm-$RH1"; mk_mint_toy "$DFM"; authority_tag "$DFM" "$ACT3"; bare_frozen "$DFM" "$ACT1"; sync_tags "$DFM"
    rc=0; "$WORK/subj-Фм/mint_line.sh" --root "$DFM" --nnn "$ACT3" >/dev/null 2>"$WORK/d-Фм" || rc=$?
    if [ "$rc" -eq 0 ]; then pass диффФм; else fail диффФм "стаб параноик: чистый мир rc=$rc: $(sed -n 1p "$WORK/d-Фм")"; fi
  fi
  if [ -n "${SUBJ_STUB[Фф]:-}" ]; then
    DFF="$WORK/dff-$RH2"; mk_freeze_toy "$DFF"; bare_frozen "$DFF" "$ACT1"; sync_tags "$DFF"
    rc=0; (cd / && "$WORK/subj-Фф/freeze_contract.sh" contracts/001-x.md "причина фикстуры $RH2" "$DFF") >/dev/null 2>"$WORK/d-Фф" || rc=$?
    if [ "$rc" -eq 0 ]; then pass диффФф; else fail диффФф "стаб параноик: чистый мир rc=$rc: $(sed -n 1p "$WORK/d-Фф")"; fi
  fi
  if [ -n "${SUBJ_STUB[П]:-}" ]; then
    DPN="$WORK/dpn-$RH1"; mk_next_toy "$DPN"; bare_frozen "$DPN" "$ACT1"
    rc=0; "$WORK/subj-П/next_id.sh" "$DPN" CONTRACT >/dev/null 2>"$WORK/d-П" || rc=$?
    if [ "$rc" -eq 0 ]; then pass диффП; else fail диффП "стаб параноик: мир с одним активным rc=$rc: $(sed -n 1p "$WORK/d-П")"; fi
  fi
  if [ -n "${SUBJ_STUB[Т]:-}" ]; then
    DFT="$WORK/dft-$RH1"; mk_next_toy "$DFT"; bare_frozen "$DFT" "$ACT1"
    rc=0; "$TSTUB/next_id.sh" "$DFT" CONTRACT >/dev/null 2>"$WORK/d-Т" || rc=$?
    if [ "$rc" -eq 0 ]; then pass диффТ; else fail диффТ "стаб параноик: быстрый авторитет rc=$rc: $(sed -n 1p "$WORK/d-Т")"; fi
  fi

  if [ -n "${SUBJ_STUB[Т]:-}" ]; then
    DTM="$WORK/dtm-$RH1"; mk_mint_toy "$DTM"; authority_tag "$DTM" "$ACT3"; sync_tags "$DTM"
    rc=0; "$TSTUB/mint_line.sh" --root "$DTM" --nnn "$ACT3" >/dev/null 2>"$WORK/d-Тм" || rc=$?
    if [ "$rc" -eq 0 ]; then pass диффТм; else fail диффТм "стаб параноик: быстрый авторитет rc=$rc: $(sed -n 1p "$WORK/d-Тм")"; fi
    DTF="$WORK/dtf-$RH2"; mk_freeze_toy "$DTF"; sync_tags "$DTF"
    rc=0; (cd / && "$TSTUB/freeze_contract.sh" contracts/001-x.md "причина фикстуры $RH2" "$DTF") >/dev/null 2>"$WORK/d-Тф" || rc=$?
    if [ "$rc" -eq 0 ]; then pass диффТф; else fail диффТф "стаб параноик: быстрый авторитет rc=$rc: $(sed -n 1p "$WORK/d-Тф")"; fi
  fi
  if [ -n "${SUBJ_STUB[124м]:-}" ]; then
    DVM="$WORK/dvm-$RH1"; mk_mint_toy "$DVM"; authority_tag "$DVM" "$ACT3"; sync_tags "$DVM"
    rc=0; "$WORK/subj-124м/mint_line.sh" --root "$DVM" --nnn "$ACT3" >/dev/null 2>"$WORK/d-124м" || rc=$?
    if [ "$rc" -eq 0 ]; then pass дифф124м; else fail дифф124м "стаб параноик: быстрый авторитет rc=$rc: $(sed -n 1p "$WORK/d-124м")"; fi
  fi
  if [ -n "${SUBJ_STUB[124ф]:-}" ]; then
    DVF="$WORK/dvf-$RH2"; mk_freeze_toy "$DVF"; sync_tags "$DVF"
    rc=0; (cd / && "$WORK/subj-124ф/freeze_contract.sh" contracts/001-x.md "причина фикстуры $RH2" "$DVF") >/dev/null 2>"$WORK/d-124ф" || rc=$?
    if [ "$rc" -eq 0 ]; then pass дифф124ф; else fail дифф124ф "стаб параноик: быстрый авторитет rc=$rc: $(sed -n 1p "$WORK/d-124ф")"; fi
  fi

  # Нарушения (Н-39): расхождение с честным ровно на входе наблюдаемости дефекта.
  # Фм/Фф — вход л16/л17 (шим): честный rc 1 fail-closed БЕЗ мутации, стаб
  # игнорирует отказ счёта и МИНТУЕТ/ЗАМОРАЖИЕТ (предмет №1 вердикта 078-v1).
  if [ -n "${SUBJ_STUB[Фм]:-}" ]; then
    NFM="$WORK/nfm-$RH2"; mk_mint_toy "$NFM"; authority_tag "$NFM" "$ACT3"; bare_frozen "$NFM" "$ACT1"; sync_tags "$NFM"
    hrc=0; PATH="$SHIM:$PATH" "$SUBJ_MINT" --root "$NFM" --nnn "$ACT3" >/dev/null 2>&1 || hrc=$?
    src=0; sout="$(PATH="$SHIM:$PATH" "$WORK/subj-Фм/mint_line.sh" --root "$NFM" --nnn "$ACT3" 2>/dev/null)" || src=$?
    if [ "$hrc" -eq 1 ] && [ "$src" -eq 0 ] && printf '%s' "$sout" | grep -qF "MINTED nnn=$ACT3"; then pass нарушФм
    else fail нарушФм "честный rc=$hrc (хотели 1), стаб rc=$src (хотели 0 MINTED) — fail-open стаб не пойман на входе л16"; fi
  fi
  if [ -n "${SUBJ_STUB[Фф]:-}" ]; then
    NFF="$WORK/nff-$RH1"; mk_freeze_toy "$NFF"; bare_frozen "$NFF" "$ACT1"; sync_tags "$NFF"
    hrc=0; (cd / && PATH="$SHIM:$PATH" "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH1" "$NFF") >/dev/null 2>&1 || hrc=$?
    src=0; sout="$(cd / && PATH="$SHIM:$PATH" "$WORK/subj-Фф/freeze_contract.sh" contracts/001-x.md "причина фикстуры $RH1" "$NFF" 2>/dev/null)" || src=$?
    if [ "$hrc" -eq 1 ] && [ "$src" -eq 0 ] && [ "$sout" = 'v1' ]; then pass нарушФф
    else fail нарушФф "честный rc=$hrc (хотели 1), стаб rc=$src (хотели 0 v1) — fail-open стаб не пойман на входе л17"; fi
  fi
  # П — входы л18/л19/л20 (ноль refs): честный проходит успешно, стаб считает пустой
  # ответ недоступностью и отказывает именованно (предмет №2 вердикта 078-v1).
  # Порядок: стаб ПЕРВЫМ (отказ не оставляет следа), затем честный (успех).
  if [ -n "${SUBJ_STUB[П]:-}" ]; then
    NPN="$WORK/npn-$RH2"; mk_next_toy "$NPN"
    src=0; "$WORK/subj-П/next_id.sh" "$NPN" CONTRACT >/dev/null 2>"$WORK/e-Пн" || src=$?
    serr="$(cat "$WORK/e-Пн")"
    hrc=0; hout="$("$SUBJ_NEXT" "$NPN" CONTRACT 2>/dev/null)" || hrc=$?
    if [ "$src" -eq 1 ] && printf '%s' "$serr" | grep -qF 'авторитет недоступен' \
       && printf '%s' "$serr" | grep -qF 'данные неизвестны' \
       && [ "$hrc" -eq 0 ] && [ "$hout" = "$want2" ] \
       && [ "$(git -C "$NPN" tag -l 'id/CONTRACT/*' | wc -l)" -eq 2 ]; then pass нарушПн
    else fail нарушПн "стаб rc=$src err=$(printf '%s' "$serr" | sed -n 1p), честный rc=$hrc out=$hout — стаб пустого-ответа не пойман на входе л18"; fi

    NPM="$WORK/npm-$RH1"; mk_mint_toy "$NPM"; authority_tag "$NPM" "$ACT3"; sync_tags "$NPM"
    src=0; "$WORK/subj-П/mint_line.sh" --root "$NPM" --nnn "$ACT3" >/dev/null 2>"$WORK/e-Пм" || src=$?
    serr="$(cat "$WORK/e-Пм")"
    hrc=0; hout="$("$SUBJ_MINT" --root "$NPM" --nnn "$ACT3" 2>/dev/null)" || hrc=$?
    if [ "$src" -eq 1 ] && printf '%s' "$serr" | grep -qF 'авторитет недоступен' \
       && printf '%s' "$serr" | grep -qF 'данные неизвестны' \
       && [ "$hrc" -eq 0 ] && printf '%s' "$hout" | grep -qF "MINTED nnn=$ACT3"; then pass нарушПм
    else fail нарушПм "стаб rc=$src err=$(printf '%s' "$serr" | sed -n 1p), честный rc=$hrc — стаб пустого-ответа не пойман на входе л19"; fi

    NPF="$WORK/npf-$RH2"; mk_freeze_toy "$NPF"; sync_tags "$NPF"
    src=0; (cd / && "$WORK/subj-П/freeze_contract.sh" contracts/001-x.md "причина фикстуры $RH2" "$NPF") >/dev/null 2>"$WORK/e-Пф" || src=$?
    serr="$(cat "$WORK/e-Пф")"
    hrc=0; hout="$(cd / && "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$NPF" 2>/dev/null)" || hrc=$?
    if [ "$src" -eq 1 ] && printf '%s' "$serr" | grep -qF 'авторитет недоступен' \
       && printf '%s' "$serr" | grep -qF 'данные неизвестны' \
       && [ "$hrc" -eq 0 ] && [ "$hout" = 'v1' ]; then pass нарушПф
    else fail нарушПф "стаб rc=$src err=$(printf '%s' "$serr" | sed -n 1p), честный rc=$hrc — стаб пустого-ответа не пойман на входе л20"; fi
  fi
  # Т — вход л21 (медленный 6s авторитет, предмет 078-v2 к2): честный с границей 15s
  # ждёт и проходит, мутант с фактической границей 1s убивает ответ на первой секунде
  # и отказывает — расхождение ровно на входе наблюдаемости (Н-39). Стаб первым:
  # отказ не оставляет следа, честный затем выдаёт номер.
  if [ -n "${SUBJ_STUB[Т]:-}" ]; then
    NTT="$WORK/ntt-$RH2"; mk_next_toy "$NTT"
    src=0; PATH="$SLOW6:$PATH" "$TSTUB/next_id.sh" "$NTT" CONTRACT >/dev/null 2>"$WORK/e-Тн" || src=$?
    serr="$(cat "$WORK/e-Тн")"
    hrc=0; hout="$(PATH="$SLOW6:$PATH" "$SUBJ_NEXT" "$NTT" CONTRACT 2>/dev/null)" || hrc=$?
    if [ "$src" -eq 1 ] && printf '%s' "$serr" | grep -qF 'авторитет недоступен' \
       && printf '%s' "$serr" | grep -qF 'rc=124' \
       && [ "$hrc" -eq 0 ] && [ "$hout" = "$want2" ]; then pass нарушТ
    else fail нарушТ "стаб rc=$src err=$(printf '%s' "$serr" | sed -n 1p), честный rc=$hrc out=$hout — мутант границы 1s не пойман на входе л21"; fi
  fi

  # Т на входах mint/freeze (л23/л25, 078-v2 к3): мутант границы 1s убивает 6s-ответ
  # ПОСЛЕ dual-control mint и ДО тега freeze; честный ждёт и проходит. Стаб первым
  # (отказ не оставляет следа), затем честный.
  if [ -n "${SUBJ_STUB[Т]:-}" ]; then
    NTM="$WORK/ntm-$RH2"; mk_mint_toy "$NTM"; authority_tag "$NTM" "$ACT3"; sync_tags "$NTM"
    src=0; PATH="$SLOW6:$PATH" "$TSTUB/mint_line.sh" --root "$NTM" --nnn "$ACT3" >/dev/null 2>"$WORK/e-Тм" || src=$?
    serr="$(cat "$WORK/e-Тм")"
    hrc=0; hout="$(PATH="$SLOW6:$PATH" "$SUBJ_MINT" --root "$NTM" --nnn "$ACT3" 2>/dev/null)" || hrc=$?
    if [ "$src" -eq 1 ] && printf '%s' "$serr" | grep -qF 'авторитет недоступен' \
       && printf '%s' "$serr" | grep -qF 'rc=124' \
       && [ "$hrc" -eq 0 ] && printf '%s' "$hout" | grep -qF "MINTED nnn=$ACT3"; then pass нарушТм
    else fail нарушТм "стаб rc=$src err=$(printf '%s' "$serr" | sed -n 1p), честный rc=$hrc — мутант границы 1s не пойман на входе л23"; fi
    NTF="$WORK/ntf-$RH1"; mk_freeze_toy "$NTF"; sync_tags "$NTF"
    src=0; (cd / && PATH="$SLOW6:$PATH" "$TSTUB/freeze_contract.sh" contracts/001-x.md "причина фикстуры $RH1" "$NTF") >/dev/null 2>"$WORK/e-Тф" || src=$?
    serr="$(cat "$WORK/e-Тф")"
    hrc=0; hout="$(cd / && PATH="$SLOW6:$PATH" "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH1" "$NTF" 2>/dev/null)" || hrc=$?
    if [ "$src" -eq 1 ] && printf '%s' "$serr" | grep -qF 'авторитет недоступен' \
       && printf '%s' "$serr" | grep -qF 'rc=124' \
       && [ "$hrc" -eq 0 ] && [ "$hout" = 'v1' ]; then pass нарушТф
    else fail нарушТф "стаб rc=$src err=$(printf '%s' "$serr" | sed -n 1p), честный rc=$hrc — мутант границы 1s не пойман на входе л25"; fi
  fi
  # 124м/124ф на входах л24/л26 (шим 17s): честный — именованный fail-closed rc=124
  # без мутации; стабы-124 превращают таймаут в пустой список и МИНТУЮТ/ЗАМОРАЖИВАЮТ.
  # Честный первым (отказ не оставляет следа), затем стаб.
  if [ -n "${SUBJ_STUB[124м]:-}" ]; then
    NVM="$WORK/nvm-$RH1"; mk_mint_toy "$NVM"; authority_tag "$NVM" "$ACT3"; sync_tags "$NVM"
    hrc=0; PATH="$SLOW17:$PATH" "$SUBJ_MINT" --root "$NVM" --nnn "$ACT3" >/dev/null 2>&1 || hrc=$?
    src=0; sout="$(PATH="$SLOW17:$PATH" "$WORK/subj-124м/mint_line.sh" --root "$NVM" --nnn "$ACT3" 2>/dev/null)" || src=$?
    if [ "$hrc" -eq 1 ] && [ "$src" -eq 0 ] && printf '%s' "$sout" | grep -qF "MINTED nnn=$ACT3"; then pass наруш124м
    else fail наруш124м "честный rc=$hrc (хотели 1), стаб rc=$src (хотели 0 MINTED) — fail-open мутант 124→0 не пойман на входе л24"; fi
  fi
  if [ -n "${SUBJ_STUB[124ф]:-}" ]; then
    NVF="$WORK/nvf-$RH2"; mk_freeze_toy "$NVF"; sync_tags "$NVF"
    hrc=0; (cd / && PATH="$SLOW17:$PATH" "$SUBJ_FREEZE" contracts/001-x.md "причина фикстуры $RH2" "$NVF") >/dev/null 2>&1 || hrc=$?
    src=0; sout="$(cd / && PATH="$SLOW17:$PATH" "$WORK/subj-124ф/freeze_contract.sh" contracts/001-x.md "причина фикстуры $RH2" "$NVF" 2>/dev/null)" || src=$?
    if [ "$hrc" -eq 1 ] && [ "$src" -eq 0 ] && [ "$sout" = 'v1' ]; then pass наруш124ф
    else fail наруш124ф "честный rc=$hrc (хотели 1), стаб rc=$src (хотели 0 v1) — fail-open мутант 124→0 не пойман на входе л26"; fi
  fi
fi

for r in "${REPS[@]}"; do printf 'КРАСНОЕ 078: %s\n' "$r" >&2; done
if [ "$PRESENT" -eq 0 ]; then
  printf 'КРАСНОЕ 078: л0: предмет отсутствует — субъекты молчат на трёх входах лимита; предъявляемое красное ДО реализации\n' >&2
fi
printf 'ИТОГ 078 (лимит активных): честных ветвей 44 (л0–л26, включая л2б, л2в, л3б, л5б, л5в, л7б, л8б, л8в, л9б, л10б, л11б, л11в, л12б, л14б, л14в, л16, л17, л18, л19, л20, л21, л22, л23, л24, л25, л26, лР, + ядро0), стабов 13 (стА–стЖ, Фм, Фф, П, Т, 124м, 124ф), применений 13, диффпроб 15, нарушений 17; красных %d, зелёных %d, не исполнено %d\n' "$RED" "$GRN" "$NORUN" >&2
[ "$RED" -eq 0 ] || exit 1
exit 0
