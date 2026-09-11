#!/usr/bin/env bash
# КРАСНОЕ 025-И-3 (пачка A-2): settings deny-паттерны баш-записи — bash.patterns.
# СУБЪЕКТ: ключ настроек bash.patterns в .omp/config.yml (схемный ключ билда —
# живой «omp config get bash.patterns --json» rc 0, формат [{match, approval}];
# порядок «первое совпавшее правило побеждает», deny/prompt матчат команду
# ЦЕЛИКОМ или один сегмент составной команды; грамматика — omp://settings.md
# «Bash command approval patterns»).
# Досягаемость (прубы круга 2, §Зонд №1): ГЛАВНЫЕ сессии (проба A: именованный
# отказ) И ДОЧЕРНИЕ task-сессии (проба B3: именованный отказ у ребёнка).
# СЕГОДНЯ: правил deny нет → rc 1 именованный. ПОСЛЕ реализации: rc 0.
#
# АНТИ-ПЛАЦЕБО (вердикт 72049b0, блокер 1): фикстура читает РАСПАРСЕННОЕ
# значение рантайма (omp config get, cwd=корень субъекта), а не текст файла —
# декой-формы «три комментария # deny» и «deny-слова в прозе» не попадают в
# распарсенный массив и умирают. Каждый ночной вход — своим предъявлением
# (Н-39): каждый из трёх классов операнда обязан матчиться ОТДЕЛЬНЫМ правилом
# deny; канарейки чтения (Г1) обязаны не матчиться НИ ОДНИМ правилом deny
# (декой «deny *» умирает на канарейке). Имена файлов — $RANDOM (инвариантность).
# ДИФФЕРЕНЦИАЦИЯ A-2 (критик d141dd9, tee-блок): tee — зондовая форма стража
# (шаг 2 зонда И-6), НЕ ночная форма; зонд-канарейка ниже требует, чтобы
# `printf 'x' | tee -a <отн>` НЕ матчился ни одним deny-правилом — иначе
# политика убьёт зондовый шаг ДО стража и И-6 неизмерим при честном A-2.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"

if ! command -v omp >/dev/null 2>&1; then
  printf 'КРАСНОЕ 025-И-3: omp недоступен в PATH — живая проверка настроек невозможна (пустая мера запрещена)\n' >&2
  exit 1
fi

CFG_JSON="$(cd "$ROOT" && omp config get bash.patterns --json 2>&1)"; rc_cfg=$?
if [ "$rc_cfg" -ne 0 ]; then
  printf 'КРАСНОЕ 025-И-3: ключ bash.patterns недоступен у рантайма (rc %d: %s) — носитель баш-ветви стража не существует\n' "$rc_cfg" "$CFG_JSON" >&2
  exit 1
fi

F="z$RANDOM.txt"
VERDICT="$(ROOT="$ROOT" CFG_JSON="$CFG_JSON" F="$F" VERIFY="${TMPDIR:-/tmp}/dev-harness-verify" node --input-type=module -e '
const rules = JSON.parse(process.env.CFG_JSON).value;
if (!Array.isArray(rules)) {
  console.error("КРАСНОЕ 025-И-3: bash.patterns не массив — " + JSON.stringify(rules));
  process.exit(1);
}
const deny = rules.filter(r => r && r.approval === "deny" && typeof r.match === "string" && r.match.length > 0);
if (deny.length < 3) {
  console.error("КРАСНОЕ 025-И-3: deny-правил меньше трёх (" + deny.length + ") — ночные классы sed -i / printf >> / > не покрыты раздельными правилами; баш-канал записи не стережётся ни в одной сессии, включая дочерние");
  process.exit(1);
}
// Матчер по ДОКУМЕНТИРОВАННОЙ грамматике omp://settings.md: glob = литерал + "*";
// deny матчит команду целиком ИЛИ один сегмент (сплит на && || ; | & и переводы строк).
const globToRe = (g) => new RegExp("^" + g.replace(/[.*+?^${}()|[\]\\]/g, (c) => c === "*" ? "[\\s\\S]*" : "\\" + c) + "$");
const SPLIT = /\|\||&&|;|\||&|\n/;
const segs = (cmd) => [cmd, ...cmd.split(SPLIT).map(s => s.trim()).filter(Boolean)];
const denyMatch = (cmd) => deny.some(r => segs(cmd).some(s => globToRe(r.match).test(s)));
const F = process.env.F, VERIFY = process.env.VERIFY;
const nightly = [
  ["sed -i класс",            `sed -i s/a/b/ ${F}`],
  ["printf-перенаправление",  `printf x >> ${F}`],
  ["перенаправление записи",  `echo x > ${F}`],
];
for (const [name, cmd] of nightly) {
  if (!denyMatch(cmd)) {
    console.error(`КРАСНОЕ 025-И-3: ночная форма «${name}» (${cmd}) НЕ покрыта ни одним deny-правилом — страж баш-ветви пропускает канал Б2`);
    process.exit(1);
  }
}
const canaries = [
  ["чтение grep",  `grep -q pattern ${F}`],
  ["чтение cat",   `cat ${F}`],
  ["чтение git",   "git status"],
  ["пайп раннего выхода (Г4-легитим)", "git log --oneline | grep -q fix"],
];
for (const [name, cmd] of canaries) {
  if (denyMatch(cmd)) {
    console.error(`КРАСНОЕ 025-И-3: канарейка Г1 «${name}» (${cmd}) матчится deny-правилом — страж ложно-краснит легитимные чтения (нарушение Г1 «читать свободно»)`);
    process.exit(1);
  }
}
// ЗОНД-КАНАРЕЙКА И-6 (дифференциация A-2 — закрытие tee-блока критика d141dd9):
// форма шага 2 зонда — относительный tee без cwd — ЗОНДОВАЯ форма СТРАЖА, не
// ночная форма: политика не имеет права убить её ДО стража, иначе И-6 неизмерим
// (rc 2 вечно) при честном A-2 — противоречие обязательного паттерна и зондовой
// формы структурно, A-2 разводит их явно (А-133).
const zond = `printf 'x' | tee -a ${F}`;
if (denyMatch(zond)) {
  console.error(`КРАСНОЕ 025-И-3: зондовая форма И-6 (${zond}) матчится deny-правилом — политика убьёт зондовый шаг ДО стража (tee-противоречие d141dd9): убери tee-deny; обязательный набор — ночные формы sed -i / > / >> / printf >>`);
  process.exit(1);
}
console.log("deny-ok " + deny.length);
' 2>&1)"; rc_v=$?

if [ "$rc_v" -ne 0 ]; then
  printf '%s\n' "$VERDICT" >&2
  exit 1
fi
case "$VERDICT" in
  deny-ok\ *) exit 0 ;;
  *) printf 'КРАСНОЕ 025-И-3: неожиданный вывод проверки: %s\n' "$VERDICT" >&2; exit 1 ;;
esac
