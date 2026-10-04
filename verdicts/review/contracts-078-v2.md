accept

# Reviewer 078, круг 2: повторный суд после FAIL `contracts-078-v1.md` (`c654672`)

Предмет: `frozen/contracts/078/1` (tag-object `68e0f6a9a807` → `e66f75b`) и текст v+1 на
`origin/wip/078/architect` (раздел Зон, критиком принят: `verdicts/critic/contracts-078-vplus1-v1.md`).
Судимый объект — ОБЪЕДИНЕНИЕ двух ветвей (прецедент 019/018):

- `origin/wip/078/implementer` HEAD `9fb8eae`, ветвление от main `a108e89`, 21 коммит;
- `origin/wip/078/architect` HEAD `1b6c55b`, ветвление от main `3e9b75a`, 2 коммита (`1ebfccf`, `1b6c55b`);
- merge в клоне суда: `git merge origin/wip/078/architect` поверх `origin/wip/078/implementer` →
  `ea588ad` (ort, без конфликтов). Merge-коммит — только артефакт суда, в origin не пушится.

Клон суда: `/tmp/dev-harness-verify/review078круг2/clone` (SSH-клон origin). Прогоны батареи, мутанты и
пробы — в одноразовых копиях `c-*` этого клона; предмет, батарея и скрипты в ветках не правились.

| артефакт | блоб frozen/078/1 | блоб merged `ea588ad` |
|---|---|---|
| `contracts/078-limit-aktivnyh-kontraktov.md` | `ae54ba4d0a4c` | `f997faba5080` (v+1) |
| `fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh` | `f9418b47e1e4` | `da58973fbb80` |
| `fixtures/limit_aktivnyh/mini_core_078.sh` | `f3195a8ff1de` | `f3195a8ff1de` |
| `fixtures/_krasnye_078.sh` | `7286e21ab430` | `7286e21ab430` |
| `fixtures/freeze_contract/_repo.sh` | `70d310773f38` | `70d310773f38` |
| `scripts/lib_active_contracts.sh` | нет | `cea88ac82c8a` |
| `scripts/next_id.sh` | `789d0dfd7690` | `cd4aec3bed66` |
| `scripts/mint_line.sh` | `fb85fd0b35be` | `c960fe337cc8` |
| `scripts/freeze_contract.sh` | `15b8b1032bb7` | `5dfb83df6991` |
| `.github/workflows/ci.yml` | `f02c99a5a427` | `07501d0be971` |
| `package.json` | `904c5862ec99` | `0a26cdccda7c` |
| `fixtures/freeze_contract/case_kap_smena_pervoj_stroki.sh` | `b9d4a97e7b3f` | `b5158bad35a5` |
| `fixtures/drill_contract_change/case_procedura_ne_prinjata.sh` | `2478b902e275` | `07e534d56b83` |
| `fixtures/check_check_contract_ready/_doc027.py` | `6efd5e0e5737` | `321baa0cd249` |
| `fixtures/check_precision_gate/red_14_freeze_refuses_red_precision.sh` | `f210e2421727` | `defbdbf4b5e4` |
| `fixtures/workshop_project/red_samodostatochnost_repo_060.sh` | `692bbe09f037` | `a37184158f69` |

Вердикт привязан к этим блобам. Новая редакция любого из них (в том числе иной блоб контракта при
заморозке v2) это решение не наследует.

## Итог

Все пять блокеров круга 1 закрыты, каждый проверен своей мерой (ниже). Батарея 078 на объединении —
89/89, rc 0 в четырёх прогонах, включая два с ПРИНУДИТЕЛЬНЫМИ крайними пулами SEED. Два мутанта
краснеют. ПРОВОДКА, precision-гейт, check_zones и соседи (068, drill_next_id_race, 060, клетки
freeze_contract) — rc 0. Блокирующих находок нет. Шесть неблокирующих — в «Находках»; одна из них (Н-6)
— условие посадки, а не дефект 078: CI по HEAD `9fb8eae` красен по чужой (074/HANDOFF) причине, и шаг 078
в этом прогоне пропущен.

---

## Статус блокеров круга 1

| | закрытие | своя мера | итог |
|---|---|---|---|
| Б-1 | v+1 `1ebfccf`: 7 ПЕРЕСЕЧЕНИЕ-строк + carve-out case_kap + пути в ЗОНА своих авторов | `zonecov.py` (ниже, (1)) | закрыт |
| Б-2 | revert `9a28f7d` коммита `dd54c8f` | `git diff --stat a108e89 origin/wip/078/implementer -- ops/` пуст | закрыт (Н-5) |
| Б-3 | откат `9fb8eae` | `git diff ad814c6 9fb8eae -- scripts/mint_line.sh` пуст | закрыт |
| Б-4 | `2ed0ac7`: `-ge 2` → `-eq 2` в обеих ветвях `--backfill` | toy-проба rc 1 / мутант rc 0 | закрыт в коде (Н-1: клетки нет) |
| Б-5 | `3bdc3ac`: `range(985, 999)` | 4 прогона, из них 2 принудительных крайних пула | закрыт |

## (1) Область правки — PASS

**Механический гейт.** `bash scripts/check_zones.sh` в merged-клоне:

```
  FAIL строка ЗОНА вне объявленной грамматики в contracts/055-izoljacija-sostojanija-po-projectid.md: … (диагностика чужого 055, rc не красит; была и в круге 1)
  ok   contracts/078-limit-aktivnyh-kontraktov.md — работа не раздаётся: … fixtures/freeze_contract/case_*.sh (замороженные клетки: правка только каркаса _repo.sh) …
замороженных контрактов: 75 · объявленных авторов: 2 · коммитов в диапазонах: 4106 · проверено по зонам: 1798
check_zones rc=0
```

Предел этого свидетельства, назван прямо (по п. (а) задания): check_zones читает зоны из БЛОБА ВЫСШЕЙ
ЗАМОРОЗКИ (`scripts/check_zones.sh`, шапка «ЗОНЫ ЧИТАЮТСЯ ИЗ БЛОБА ВЫСШЕЙ ЗАМОРОЗКИ»). Высшая заморозка
078 — `/1`; строка `РАБОТА НЕ РАЗДАЁТСЯ` в выводе — СТАРАЯ, без carve-out. Значит, v+1 гейт пока не
читает. Пять путей он «не красит» и не красил в круге 1 тоже (rc 0 по union-семантике 033). Отсутствие
красного в check_zones само по себе НЕ доказывает покрытие строками v+1.

**Проба v+1 через тот же гейт.** Копия `c-z`, локальный тег `frozen/contracts/078/2` на `ea588ad`
(не пушится, копия удалена):

```
  ok   contracts/078-limit-aktivnyh-kontraktov.md — работа не раздаётся: … fixtures/freeze_contract/case_*.sh, КРОМЕ case_kap_smena_pervoj_stroki.sh (замороженные клетки: правка только каркаса _repo.sh; case_kap_smena_pervoj_stroki.sh — см. ПЕРЕСЕЧЕНИЕ выше) …
замороженных контрактов: 75 · объявленных авторов: 2 · коммитов в диапазонах: 4106 · проверено по зонам: 1798
rc=0
```

Грамматика v+1 гейтом читается, отказов по новым строкам нет.

**Своя мера покрытия, без union.** `zonecov.py` (одноразовый, вне репо): для каждого коммита обеих
ветвей и каждого его пути — покрыт ли путь ЗОНА-строкой v+1 ДЛЯ ИМЕНИ АВТОРА коммита; плюс число
ПЕРЕСЕЧЕНИЕ-строк на путь:

```
ok  9fb8eae implementer  scripts/mint_line.sh  ПЕРЕСЕЧЕНИЕ-строк=1
ok  3bdc3ac architect    fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh  ПЕРЕСЕЧЕНИЕ-строк=0
ok  2ed0ac7 implementer  scripts/next_id.sh  ПЕРЕСЕЧЕНИЕ-строк=1
OUT 9a28f7d implementer  ops/server/README.md  ПЕРЕСЕЧЕНИЕ-строк=0
ok  c19ad80 architect    fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh  ПЕРЕСЕЧЕНИЕ-строк=0
ok  40e785d architect    fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh  ПЕРЕСЕЧЕНИЕ-строк=0
ok  4dc7c6f implementer  scripts/lib_active_contracts.sh  ПЕРЕСЕЧЕНИЕ-строк=0
ok  4dc7c6f implementer  scripts/mint_line.sh  ПЕРЕСЕЧЕНИЕ-строк=1
ok  2ced157 architect    fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh  ПЕРЕСЕЧЕНИЕ-строк=0
OUT dd54c8f implementer  ops/server/README.md  ПЕРЕСЕЧЕНИЕ-строк=0
ok  bd03fc9 architect    fixtures/workshop_project/red_samodostatochnost_repo_060.sh  ПЕРЕСЕЧЕНИЕ-строк=1
ok  131bb1b implementer  fixtures/check_precision_gate/red_14_freeze_refuses_red_precision.sh  ПЕРЕСЕЧЕНИЕ-строк=1
ok  db9b426 architect    fixtures/check_check_contract_ready/_doc027.py  ПЕРЕСЕЧЕНИЕ-строк=2
ok  937fd58 implementer  fixtures/drill_contract_change/case_procedura_ne_prinjata.sh  ПЕРЕСЕЧЕНИЕ-строк=1
ok  d24d0f5 architect    fixtures/freeze_contract/case_kap_smena_pervoj_stroki.sh  ПЕРЕСЕЧЕНИЕ-строк=2
ok  7ac1365 implementer  .github/workflows/ci.yml  ПЕРЕСЕЧЕНИЕ-строк=2
ok  7ac1365 implementer  package.json  ПЕРЕСЕЧЕНИЕ-строк=2
ok  a3887a3 implementer  scripts/freeze_contract.sh  ПЕРЕСЕЧЕНИЕ-строк=2
ok  ad814c6 implementer  scripts/mint_line.sh  ПЕРЕСЕЧЕНИЕ-строк=1
ok  84f8d2a implementer  scripts/next_id.sh  ПЕРЕСЕЧЕНИЕ-строк=1
ok  103bcee implementer  scripts/lib_active_contracts.sh  ПЕРЕСЕЧЕНИЕ-строк=0
OUT 1b6c55b critic       verdicts/critic/contracts-078-vplus1-v1.md  ПЕРЕСЕЧЕНИЕ-строк=0
ok  1ebfccf architect    contracts/078-limit-aktivnyh-kontraktov.md  ПЕРЕСЕЧЕНИЕ-строк=0
ПЕРЕСЕЧЕНИЕ всего: 17
carve-out case_kap в РАБОТА НЕ РАЗДАЁТСЯ: True
вне зоны своего автора: 3
```

Разбор трёх `OUT`:
- `dd54c8f` + `9a28f7d` — коммит 074 и его revert. Чистая дельта нулевая: `git diff --stat a108e89
  origin/wip/078/implementer -- ops/` пуст. Пара остаётся в истории — Н-5.
- `1b6c55b` — вердикт критика, судейский канал (`verdicts/critic/`), не исполнительская зона.

Все пять коллатеральных путей Б-1 покрыты ЗОНА-строкой своего автора и 1–2 ПЕРЕСЕЧЕНИЕ-строками; 10
прежних ПЕРЕСЕЧЕНИЕ + 7 новых = 17. Carve-out `case_kap` точечный. Содержание пяти патчей не менялось
после круга 1 (в списке выше нет коммитов по этим путям после исходных sha). Их зелень/суждение
подтверждены прогонами ниже (соседи) и CI `37161247813` на `3bdc3ac` (6/6 jobs success), где эти пять
блобов равны merged.

Чистая дельта к main (`git diff --stat origin/main HEAD`) содержит 4 удаления `forks/080-b4…`,
`forks/081-krug5…`, `verdicts/consultant/…080-v1.md`, `…081-v1.md`. Это коммиты main `014ac44`/`3f66ec3`
ПОЗЖЕ базы architect-ветви `3e9b75a`, а не правка 078; при посадке через merge с main они не теряются.

## (2) Сырой вывод — своя мера

`bash fixtures/_krasnye_078.sh` в шести копиях merged-клона, параллельно (16 CPU, load до старта 0.43).
Счёт по логам, `grep -cE '^КРАСНОЕ 078: [^:]+: '`, зелёные — `…: ЗЕЛЁНАЯ`, красные — `…: КРАСНАЯ`,
дубли имён клеток — `uniq -d`:

```
run1     cells=89 green=89 red=0 dup=0   rc=0  красных 0, зелёных 89, не исполнено 0
run2     cells=89 green=89 red=0 dup=0   rc=0  красных 0, зелёных 89, не исполнено 0
seeddesc cells=89 green=89 red=0 dup=0   rc=0  красных 0, зелёных 89, не исполнено 0
seedasc  cells=89 green=89 red=0 dup=0   rc=0  красных 0, зелёных 89, не исполнено 0
mut      rc=1  красных 2, зелёных 87, не исполнено 0
mut2     rc=1  красных 9, зелёных 80, не исполнено 0
```

Хвост run1:

```
ИТОГ 078 (лимит активных): честных ветвей 44 (л0–л26, включая л2б, л2в, л3б, л5б, л5в, л7б, л8б, л8в, л9б, л10б, л11б, л11в, л12б, л14б, л14в, л16, л17, л18, л19, л20, л21, л22, л23, л24, л25, л26, лР, + ядро0), стабов 13 (стА–стЖ, Фм, Фф, П, Т, 124м, 124ф), применений 13, диффпроб 15, нарушений 17; красных 0, зелёных 89, не исполнено 0
rc=0
```

Гейты в merged-клоне, последовательно (параллельный запуск делит scratch `lib_zones` — урок критика):

```
$ bash scripts/check_precision_gate.sh . contracts/078-limit-aktivnyh-kontraktov.md
OK
precision rc=0
$ bash scripts/check_provodka.sh . contracts/078-limit-aktivnyh-kontraktov.md
provodka rc=0
```

Соседи (строка приёмки «Соседи не сломаны»):

```
$ bash fixtures/mint_line/red_mint_line_068.sh        → КРАСНОЕ 068b: м0…м4: ЗЕЛЁНАЯ …   068 rc=0
$ bash scripts/drill_next_id_race.sh                  →   ok   атомарность выдачи: 001 и 002 — max+1 и max+2 от пустого репозитория, оба с тегами   race rc=0
$ bash fixtures/_krasnye_060.sh                       → итог 060: rc=0
$ BARRIER=… WORK=… REPO=$PWD bash fixtures/freeze_contract/case_verdikt_fail.sh
  ok   заморожено: contracts/001-x.md → frozen/contracts/001/1 («accept прочитан») …
  ОТКАЗ: критик заморозку не разрешил: FAIL в verdicts/critic/contracts-001-v2.md. …     rc=1 (красная ПО ПРЕДМЕТУ)
$ BARRIER=… WORK=… REPO=$PWD bash fixtures/freeze_contract/case_kap_smena_pervoj_stroki.sh
  ok   заморожено: contracts/001-x.md → frozen/contracts/001/2 («шум — не круг: смена первой строки одна») …
  ОТКАЗ: кап кругов: критик прошёл уже 4 кругов по contracts/001, а вердикта арбитра по этому предмету нет …   rc=1 (красная ПО ПРЕДМЕТУ, не «лимит активных»)
```

## (3) Проверка не переписана под реализацию — PASS

- С круга 1 батарею трогал только architect (`3bdc3ac`); implementer — только `scripts/next_id.sh`,
  `scripts/mint_line.sh`, `ops/server/README.md` (revert).
- `_krasnye_078.sh`, `mini_core_078.sh`, `_repo.sh` побайтово равны frozen.
- `git diff frozen/contracts/078/1 HEAD -- fixtures/limit_aktivnyh/…` → +435/−5. Пять удалённых строк:
  комментарий диапазона 985–999, `pool = …range(985, 1000)`, комментарий «15 хватает», старый список
  `norun` и старая строка ИТОГ. Каждая заменена расширенной версией. Новый `norun` содержит л1…л26,
  то есть все честные клетки до л0. Ослабления нет: из множества значений ушло только 999. 999 —
  край «1000 > 999» механизма 060, а не предмет 078.
- Пять коллатеральных фикстур чужих семей теперь — объявленная v+1 работа (ПЕРЕСЕЧЕНИЕ), а не
  самовольная правка проверки; см. (1).

## (4) Красное предъявлено — своя мера, другим мутантом, чем в круге 1

**Мутант A (новый, И-1/И-6).** `c-mut`: в `lib_active_contracts.sh` удалена строка
`for (k in d) delete act[k]` — done-тег больше не вычитает. Прогон батареи копии:

```
КРАСНОЕ 078: л4: КРАСНАЯ — rc=1 out= err=ОТКАЗ: лимит активных контрактов: активных 2 ≥ 2: 991,995
КРАСНОЕ 078: лР: КРАСНАЯ — rc=1 out= тегов id=1 err=ОТКАЗ: лимит активных контрактов: активных 6 ≥ 2: 986,987,988,989,990,998 — решётка классов не пиннует И-1: множество обязано быть {989,987,990}
… красных 2, зелёных 87, не исполнено 0   rc=1
```

**Мутант B (составной timeout fail-open круга 1).** Повторён на НОВОМ дереве. Это важно: откат Б-3
поменял `mint_line.sh`, и барьер л24 мог отвалиться. `c-mut2`: `return 1` → `return "$ls_rc"` в
библиотеке плюс `if [ "$active_rc" -eq 124 ]; then active_rc=0; fi` в `mint_line.sh` и
`freeze_contract.sh`:

```
КРАСНОЕ 078: л24: КРАСНАЯ — rc=0 out=MINTED nnn=997 … строк=1 err=ОТКАЗ: лимит активных контрактов: авторитет недоступен (ls-remote origin rc=124), данн…
КРАСНОЕ 078: л26: КРАСНАЯ — rc=0 out=v1 err=ОТКАЗ: … (ls-remote origin rc=124) … — ответ позже SLA 15s не переведён в именованный fail-closed rc=124 …
КРАСНОЕ 078: нарушПн / нарушПм / нарушПф / нарушТм / нарушТф / наруш124м / наруш124ф: КРАСНАЯ
… красных 9, зелёных 80, не исполнено 0   rc=1
```

Клетка «таймаут → отказ, не пропуск» из слова владельца (timeout 15s в библиотеке остаётся в 078)
живая: л24/л26 ловят fail-open исполнением.

**Б-4, toy-проба** (`git init` toy, `next_id.sh <toy> --backfill PLAN --reason x`):

```
== clone (merged)
ОТКАЗ: для --backfill после <КОРЕНЬ> требуется один аргумент — класс; получено: 4
rc=1
  ok   backfill PLAN: создано 0, уже было 0
rc(plain)=0
== c-mut3 (-eq 2 → -ge 2 в обеих ветвях --backfill)
  ok   backfill PLAN: создано 0, уже было 0
rc=0
```

Текст отказа и rc совпадают с `a108e89` из пробы круга 1. Простой `--backfill PLAN` не задет.
Регресс, однако, никакой клеткой не пиннуется — см. Н-1 и прогон батареи на `c-mut3` ниже.

Батарея 078 на `c-mut3` (мутант Б-4):

```
ИТОГ 078 (лимит активных): честных ветвей 44 (…); … красных 0, зелёных 89, не исполнено 0
rc=0
```

Мутант И-7 проходит батарею зелёным: барьера на Б-4 нет (Н-1).

**ПРОВОДКА (038).** `check_provodka` rc 0 на merged. Шаг CI `run: bash fixtures/_krasnye_078.sh`
(`ci.yml:655`) и ключ `"check:limit-active-family-selftest": "bash fixtures/_krasnye_078.sh"`
(`package.json:79`) на месте. Канал — раннер ИМЕННО этого предмета. `ПРОВОДКА-ЭНФОРСМЕНТ` обоснован
механическим пределом; красное до подключения показано в круге 1 (rc 1 на `a108e89`).

## (5) Атомарность — PASS

Новые коммиты с круга 1 — каждый один файл и ссылка на предмет/находку:

| коммит | автор | файл |
|---|---|---|
| `9a28f7d` | implementer | `ops/server/README.md` (revert `dd54c8f`) |
| `2ed0ac7` | implementer | `scripts/next_id.sh` (Б-4) |
| `3bdc3ac` | architect | `fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh` (Б-5) |
| `9fb8eae` | implementer | `scripts/mint_line.sh` (Б-3) |
| `1ebfccf` | architect | `contracts/078-limit-aktivnyh-kontraktov.md` (Б-1, v+1) |
| `1b6c55b` | critic | `verdicts/critic/contracts-078-vplus1-v1.md` |

Пустые `990c739`/`864b451` («ci: retrigger») остаются шумом истории. Это Н-1 круга 1, повторно не
заводится.

## (6) Норма не тронута вне разрешённого v+1 — PASS

- `git diff --stat a108e89..origin/wip/078/implementer` — нет `roles/`, `AGENTS.md`, `contracts/`.
- `git diff --stat 3e9b75a..origin/wip/078/architect` — только `contracts/078-…md` (+10/−3, раздел Зон)
  и вердикт критика.
- `git diff frozen/contracts/078/1 HEAD -- contracts/078-…md` — изменены ТОЛЬКО две ЗОНА-строки,
  семь новых ПЕРЕСЕЧЕНИЕ и строка РАБОТА НЕ РАЗДАЁТСЯ. Инварианты, приёмка и ПРОВОДКА побайтово прежние.
- Дельты `AGENTS.md`, `roles/architect.md`, `roles/orchestrator.md`, `contracts/071`, `contracts/080` в
  `frozen/078/1..merged` пришли из main через базу `3e9b75a`, а не из коммитов 078.
- Разрешение владельца — `forks/078-vplus1-kollateralnye-fiksy.md`, «ОТВЕЧЕНО: да — РЕШЕНИЕ владельца
  2026-10-04». timeout в `mint_line.sh` из 078 исключён, и это сделано: см. Б-3.

## (7) Заявленное = сделанное — своя мера

- **89 зелёных.** Пересчитано не ИТОГ-строкой, а классификацией имён клеток run1:
  `честных 44 стаб/применений 13 диффпроб 15 нарушений 17 всего 89`. Отдельно счёт строк — 89 клеток,
  89 `ЗЕЛЁНАЯ`, 0 дублей; в четырёх честных прогонах одинаково.
- **SEED-flaky (Б-5).** Класс «следующий номер 1000 превышает 999» требует локального тега 999, а
  теперь максимум пула — 998. Проверены оба края пула принудительно, предмет не тронут, правится одна
  строка генератора в копии:
  - `seeddesc`: `pool = [998] + sorted(range(985, 998), reverse=True)[:11]` — SEED=998 (выдача 999),
    все соседи у верхнего края;
  - `seedasc`: `pool = list(range(985, 997))` — SEED=985, нижний край.

  Оба 89/89, rc 0. Плюс два естественных случайных прогона — 89/89. Из 13 клеток, красных при
  SEED=999 в круге 1, ни одна не покраснела.
- **«Б-3 откат вернул файл к предфиксовому состоянию».** Верно в точном смысле:
  `git diff ad814c6 9fb8eae -- scripts/mint_line.sh` пуст, то есть файл равен состоянию после
  реализации и до `4dc7c6f`. Формулировка задания «diff от merge-base ДОЛЖЕН быть пуст» НЕ верна и
  НЕ выполняется: `git diff a108e89 HEAD -- scripts/mint_line.sh` даёт +31/−2 законной реализации 078
  (`--reason`, И-5; ветвь лимита 3-bis, И-3). Строка dual-control `ls_out="$(git -C "$ROOT" ls-remote
  "origin" "refs/tags/id/CONTRACT/$NNN" …)"` в этом diff отсутствует, то есть она байт-в-байт как на
  `a108e89`. ПЕРЕСЕЧЕНИЕ 068 соблюдено.
- **CI.** См. Н-6: по HEAD `9fb8eae` run `37188026886` — failure; шаг 078 пропущен.

## Паразитная сложность (контракт 050)

Дельта круга 2 новых артефактов не вводит, она только сужает. Строки по всем артефактам итогового
диффа (суть круга 1 сохранена, изменённое отмечено):

- `scripts/lib_active_contracts.sh` — (1) И-1, единый счёт; (2) без состояния, rc/stderr явные; (3) 1
  файл на правку определения; (4) глубокий: 1 аргумент, работа — 3 паттерна + разбор; (5) три входа,
  л1–л26. **ESSENTIAL.** Ложный комментарий о герметичности остался — Н-3.
- `timeout 15s` в библиотеке — (1) И-2, плюс слово владельца 2026-10-04 «остаётся в 078»; (2) нет; (3) 1;
  (4) интерфейс не растёт; (5) л21–л26, мутант B. **ESSENTIAL.**
- `timeout` dual-control в `mint_line.sh` — **УДАЛЁН** (`9fb8eae`); ACCIDENTAL круга 1 закрыт.
- `--reason` у `next_id.sh` — (1) И-5; (2) явный аргумент; (3) 1; (4) после `2ed0ac7` ширина ровно по
  грамматике И-5, `--backfill` снова `-eq 2`; (5) л2б/л2в/л3/л3б. **ESSENTIAL.**
- `--reason` у `mint_line.sh` — (1) И-5; (2) явный; (3) 1; (4) одна ветвь while; (5) л8б/л8в/л9/л9б.
  **ESSENTIAL.**
- Ветвь лимита в `freeze_contract.sh` — (1) И-4; (2) нет; (3) 1; (4) не растёт; (5) л10–л14в, л25/л26.
  **ESSENTIAL.**
- CI-шаг и npm-ключ — (1) ПРОВОДКА; (2) —; (3) 2 по правилу 6 паритета; (4) —; (5) check_provodka.
  **ESSENTIAL.**
- Семья пяти коллатеральных фикстур (bare-origin / копия библиотеки) — (1) зелень соседей при
  fail-closed И-2, теперь объявлена ПЕРЕСЕЧЕНИЕм v+1; (2) окружение toy; (3) при следующей правке
  того же свойства догоняют 6 файлов (было 1) — класс Н-142; (4) —; (5) CI-шаги соседей. **ESSENTIAL**
  по свойству. Совет круга 1 (общий хелпер toy-origin) в силе, мерилом не является.
- Сужение пула SEED (`3bdc3ac`) — (1) А2 rc 0 детерминированно; (2) нет; (3) 1; (4) —; (5) раннер в CI.
  **ESSENTIAL**, проще некуда.

## Находки

Блокирующих нет.

- [x] **Б-1** закрыт v+1 `1ebfccf` + critic `1b6c55b`; своя мера — (1).
- [x] **Б-2** закрыт revert `9a28f7d`; чистая дельта `ops/` пуста.
- [x] **Б-3** закрыт `9fb8eae`; `mint_line.sh` = `ad814c6`.
- [x] **Б-4** закрыт `2ed0ac7`; toy-проба rc 1.
- [x] **Б-5** закрыт `3bdc3ac`; оба края пула зелёные.
- [ ] **Н-1 (не блокирует, барьер).** У И-7 «`--backfill` байт-в-байт как до 078» нет клетки. Мутант
  `c-mut3` (`-eq 2` → `-ge 2`, ровно дефект круга 1) возвращает приём `--reason` после `--backfill`
  (rc 0), а батарея 078 его не видит (прогон выше). `git grep backfill -- fixtures` пуст: ни одна
  фикстура дерева грамматику `--backfill` не пиннует. Закрытие из Б-4 круга 1 («красную клетку добавляет
  architect») не исполнено. Не блокирует: строки приёмки 078 эту клетку не называют, а код верен по
  своей пробе. Класс: ДОЛГ БАРЬЕРА / И-7. Адресат — architect.
- [ ] **Н-2 (не блокирует, перенос из круга 1).** Комментарий шага `ci.yml:641-642` («33 честных клеток…
  (7+7+7+33)») по-прежнему врёт: честных 44, всего 89. Адресат — implementer.
- [ ] **Н-3 (не блокирует, перенос из круга 1).** `lib_active_contracts.sh:32`: комментарий «Герметичность
  нужна и библиотеке…» обещает санацию, которой в функции нет. Адресат — implementer.
- [ ] **Н-4 (не блокирует, текст).** Строка А2 («честные ветви 33/33… зелёных 54») не описывает
  батарею 89; v+1 приёмку не трогал по своему мандату. Долг следующей редакции.
- [ ] **Н-5 (не блокирует, история).** Б-2 закрыт revert-парой `dd54c8f`+`9a28f7d`, а не удалением
  коммита. Чистая дельта нулевая; переписывать опубликованную ветку ради истории — деструктивная
  операция, revert — законная форма. При посадке пара видна в `git log` main. Маршрут 074 для самого
  текста README — вне 078.
- [ ] **Н-6 (не блокирует вердикт, условие посадки).** CI по HEAD:
  `gh run list --branch wip/078/implementer` → run `37188026886` (pull_request, headSha `9fb8eae`) —
  **failure**. Упал шаг 25 «Сам-тесты серверной обвязки станции (контракт 074)»: `k7: в первой секции
  ГДЕ МЫ нет строки-указателя`, `КРАСНО: cell_k7`. Шаги 26–53, включая шаг 50 «…лимит активных
  контрактов (контракт 078)», — **skipped**; ap4 — cancelled. Причина вне 078. Моя мера:
  `bash fixtures/_krasnye_074.sh` на чистом worktree `origin/main` (`3f66ec3`) даёт тот же `КРАСНО:
  cell_k7` (плюс станционный k5b, в CI пропускаемый), rc 1. `HANDOFF.md` ни одна из веток 078 не
  трогает (`git diff --stat a108e89..origin/wip/078/implementer -- HANDOFF.md` пуст). Значит, CI по
  HEAD 078 НЕ ПОДТВЕРЖДЁН. Последний зелёный CI 078 — `37161247813` на `3bdc3ac` (6/6 success, шаг 50
  success); от HEAD он отличается только откатом `mint_line.sh`, который я прогнал локально (батарея,
  068). Объединение с architect-веткой CI не гонял никогда: PR #10 закрыт. Условие посадки — зелёный CI
  по итоговому merge-коммиту после починки k7 на main.
- [ ] **Н-7 (не блокирует, процедура).** v+1 не заморожен: тега `frozen/contracts/078/2` нет ни
  локально, ни на origin (`git ls-remote origin 'refs/tags/*078*'`). Поэтому check_zones судит по `/1`.
  Механическую силу новые декларации получат только с заморозкой `/2`, и это ОБЯЗАН быть блоб
  `f997faba5080`: иной блоб не наследует этого вердикта.

## Что не проверял

- `case_procedura_ne_prinjata.sh` по протоколу анти-плацебо раннера — как и в круге 1. Покрыт только CI
  `37161247813` (блоб равен merged).
- Полный антиплацебо-прогон шардов на merged-коммите — его не было ни в CI (см. Н-6), ни у меня (вне
  бюджета и задания).
- Живой origin dev-harness под лимитом — батарея на toy-мирах по замыслу контракта.
