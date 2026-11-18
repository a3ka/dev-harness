accept
OBJECT=92fb47e12bd2ccf008b0ed675bde834987a12e08
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; адверсарий не вызывался — frozen 182/2)
СУД: repo=dev-harness; предмет=182; фаза=реализация v2 (контракт ЗАМОРОЖЕН `frozen/contracts/182/2` → d7b18b463e; `git diff frozen/contracts/182/2 origin/main -- contracts/182-plan-posle-perezapuska.md` пуст); роль=reviewer; вызов=2 (СКОУПНЫЙ повтор после FAIL; исключения нет); последний судья; сессия=Rev182b; модель-план=config/agent_models.json reviewer → audit → @opus → anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev182b` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev182b	92fb47e12bd2ccf008b0ed675bde834987a12e08`, RC=0); автор=implementer (Impl182Fix1); предыдущие=Rev182 FAIL (`verdicts/review/contracts-182-v2-impl-v1.md`, ветка wip/182/reviewer-impl1 4d06e00702, три блока Рв182-1/2/3); СУД-запись оркестратора — HANDOFF state-ветки, строка 4 (`предмет=182 … вызов=2 … OBJECT=92fb47e1…`); находки=`.review/2026-11-18-106.md` (только советы)

# Вердикт reviewer — 182 v2, реализация, вызов 2 (скоупный)

## Итог

**accept.** Все три блока Rev182 закрыты; регресс на судимом дереве зелёный. Блоков нет, есть два совета (С-4, С-5).

- **Рв182-1 (038 ПРОВОДКА) — закрыт.** Норма-строка `role=` стоит в роли дословно, одной физической строкой. Оговорка v2 идёт следующей строкой того же абзаца. `check_provodka` RC=0, `gen-harness --check` RC=0.
- **Рв182-2 (И-7) — закрыт.** В проектном режиме отказы `ls-remote` и `rev-list` несут полный префикс И-7 и названный выход; rc 1, stdout пуст. Станционный режим побайтно равен v1, в том числе при недоступном origin и нечитаемой истории.
- **Рв182-3 (И-6/И-7) — закрыт.** Профиль `registry` с хвостовыми `/` и внутренними `//` (и `state` с ними же) даёт точный оракульный срез. Пути отказа нормализованы. Путь без `/` не меняется.

## Объект и судимое дерево

```
клон: /tmp/dev-harness-verify/Rev182b/repo (git clone ssh://git@github.com/a3ka/dev-harness.git; свой .git)
git fetch origin main wip/182/implementer (+ теги frozen/contracts/182/*)
origin/main                 = 0ddebafb577fdbaacbfe92ab89da669799f5522e
origin/wip/182/implementer  = 92fb47e12bd2ccf008b0ed675bde834987a12e08 (== OBJECT)
92fb47e1^                   = 5aa24116427089282883f0b68cb2a509fd29a3cd (прежний OBJECT Rev182)
merge-base(origin/main, OBJECT) = 90c4aa63c3; git diff --stat 90c4aa63 origin/main -- <три файла> → пусто
author | committer 92fb47e1 = implementer <implementer@dev-harness.local> | implementer <implementer@dev-harness.local>
git diff --stat 5aa24116 92fb47e1:
 .omp/agents/orchestrator.md |  3 ++-
 roles/orchestrator.md       |  3 ++-
 scripts/orch_plan_slice.sh  | 37 ++++++++++++++++++++++++++++++++-----
 3 files changed, 36 insertions(+), 7 deletions(-)
судимое дерево: git checkout -b rev182b-judge origin/main && git checkout 92fb47e1 -- <три файла>
git hash-object (рабочее) == git rev-parse 92fb47e1:<f>:
 scripts/orch_plan_slice.sh  d862fd576ced22df0c07c8c51a21bd8422eb7e49
 roles/orchestrator.md       d5e67a20eafe5bdf2ad33b461757c6e851933be7
 .omp/agents/orchestrator.md 8540f329ad5a398c0d08c58b3a3c20650c8e998b
```

Заявление «один коммит, 3 файла, +37/−7 и +3/−3» совпадает с моей мерой (`--stat`): +36/−7 всего, из них 1 строка заменена на 2 в каждом из двух md-файлов.

## Повестка (1) — Рв182-1, ПРОВОДКА 038

```
env -u GIT_AUTHOR_* -u GIT_COMMITTER_* bash scripts/check_provodka.sh "$PWD" contracts/182-plan-posle-perezapuska.md → PROVODKA RC=0
node scripts/gen-harness.ts --check → «харнес соответствует roles/ (13 ролей)» GEN RC=0
grep -cFx '<норма-строка role= из ПРОВОДКИ контракта>' roles/orchestrator.md .omp/agents/orchestrator.md → 1 / 1
grep -n -A1 -B1 'После успешного штатного brief' roles/orchestrator.md:
 22-(пусто)
 23:После успешного штатного brief … строки ЖДЁТ из HANDOFF без живого подтверждения не сообщай как актуальные.
 24-В проектном режиме <root> — корень проекта; отказ проектного среза правдив и станционным реестром не подменяется; статус проекта при отказе сообщается как неизвестный, не выдумывается из HANDOFF.
git diff --word-diff=porcelain origin/main -- roles/orchestrator.md → одна вставка: строка 24 (`+В проектном режиме …`); прочие строки роли без изменений
```

- **Абзац сохранён.** Строки 23 и 24 идут без пустой строки между ними — это один абзац (мягкий перенос markdown).
- **Оговорка дословная.** Строка 24 равна тексту ЗОНЫ implementer v2 («В проектном режиме <root> … не выдумывается из HANDOFF»), к которому добавлена точка.
- **Смысл инварианта цел.** Оговорка удерживает «проектный режим»: отказ правдив, станционным реестром не подменяется, статус при отказе — неизвестный.
- **Чужие нормы не тронуты.** Нормы ПЕРЕСЕЧЕНИЙ 095/010/…/100 не изменены: дифф роли относительно main — ровно +1 строка.
- **Производная синхронна.** `.omp/agents/orchestrator.md` даёт тот же +1, `gen --check` зелёный.

## Повестка (2) и (3) — свой мир

Мир — `/tmp/dev-harness-verify/Rev182b/myworld.py`, throwaway вне репо. Устройство:

- номера 711–714;
- этапы «волна-Север» и «волна-Юг»;
- пауза «пока не ответит аудитор»;
- профиль `doc/c|v|f`, `projectLayer` — `doc/layer.json`;
- bare-origin, опубликованные теги `done/711/1` и `frozen/712/3`, локальный неопубликованный `done/714/7`.

Оракул собирается в памяти ДО запуска субъекта, сравнение — точное по stdout. Окружение берётся без `GIT_AUTHOR_*`, `GIT_COMMITTER_*` и `HARNESS_*`. Способы поломки:

- для `ls-remote` URL origin после fetch перенаправлен в несуществующий каталог;
- для `rev-list` удалён loose-объект коммита-родителя снятого SHA.

v1 — это `git show origin/main:scripts/orch_plan_slice.sh`.

### Прогон против судимого дерева

`python3 myworld.py <клон>`:

```
PASS N0-plain registry='ops/ledger2' state='meta': rc=0 … stderr=''
PASS N1-trail1 registry='ops/ledger2/' state='meta': rc=0
PASS N2-trail3 registry='ops/ledger2///' state='meta': rc=0
PASS N3-inner registry='ops//ledger9' state='meta': rc=0
PASS N4-inner-trail registry='ops//ledger9//' state='meta': rc=0
PASS N5-deep registry='a//b///c/' state='meta': rc=0
PASS N6-state-trail registry='ops/ledger2' state='meta//': rc=0
PASS N7-state-inner registry='ops/ledger2/' state='st//x/': rc=0
PASS N8-dot-state registry='ops//ledger2/' state='.': rc=0
PASS N9-noplan-normalized-path: rc=1 stdout='' stderr='PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=8fd424ab…): нет ops/ledger9/plan.tsv на origin/main=8fd424ab…; станционный корневой реестр не подменяет; выход: план проекта заводит владелец коммитом в ops/ledger9/plan.tsv (996)'
PASS N10-nopauzy-trail: rc=0 (713 = черновик)
PASS P1-ls-remote: rc=1 stdout='' stderr='PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=baf22823…): не читаются опубликованные теги origin в …/P1-ls-remote/R; выход: восстановить доступ к origin (fetch)'
PASS P2-rev-list: rc=1 stdout='' stderr='PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=bf8d8d3a…): не читается история origin/main=bf8d8d3a…; выход: восстановить доступ к origin (fetch)'
PASS S1-healthy   v1: rc=0 stderr='' == v2, stdout == оракул
PASS S2-ls-remote v1: rc=1 'PLAN_SOURCE_UNAVAILABLE: не читаются опубликованные теги origin в …/S2-ls-remote/S' == v2
PASS S3-rev-list  v1: rc=1 'PLAN_SOURCE_UNAVAILABLE: не читается история origin/main=dec6341e…' == v2
PASS S4-no-plan   v1: rc=1 'PLAN_SOURCE_UNAVAILABLE: нет registry/plan.tsv на origin/main=…' == v2
PASS S5-no-pauzy  v1: rc=1 'PLAN_SOURCE_UNAVAILABLE: нет registry/pauzy.tsv на origin/main=…' == v2
PASS S6-mismatch  v1: rc=1 'PLAN_ROADMAP_RASHOZHDENIE: plan.tsv расходится с generated-блоком ROADMAP: 713' == v2
MYWORLD=19 PASS=19 → RC=0
```

Что требовали клетки:

- **N\*:** rc 0, stdout равен оракулу, stderr пуст, в stdout нет `//`.
- **P\*:** rc 1, stdout пуст, stderr начинается ровно с `PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=<sha>):`, несёт причину и `; выход: ` и состоит из одной строки.
- **S\*:** тройка (rc, stdout, stderr) у v1 и v2 побайтно равна.

### Красное предъявлено

Тот же мир против прежнего OBJECT. Блоб `5aa24116:scripts/orch_plan_slice.sh` = `a1610b1c…` положен рядом с `scripts/` из origin/main.

Результат: `MYWORLD=19 PASS=7`, RED-RUN RC=1.

FAIL (12 из 19):

- **N1–N10:** например, N1 — `нет ops/ledger2//plan.tsv`, N6 — `нет meta//ROADMAP.md`;
- **P1** — `PLAN_SOURCE_UNAVAILABLE: не читаются опубликованные теги origin в …` без префикса и выхода;
- **P2** — `PLAN_SOURCE_UNAVAILABLE: не читается история origin/main=…` без префикса и выхода.

PASS (7 из 19): N0 и S1–S6. Новые клетки различают сломанную и исправленную реализацию, а станционные равны v1 в обеих.

### Живой срез

Только чтение.

- **Харнесс как проект.** Клон, `state: "."`. v1 и OBJECT, оба `--repo <клон>`:
  - `sha256` stdout у обоих `fcb4f7a95a40aee21a8ed6e6f0168b6cae9310b3385754234ab1f8a15f589f5e`, RC=0;
  - 124 строки, `PLAN_SNAPSHOT: origin/main=0ddebafb577fdbaacbfe92ab89da669799f5522e`;
  - `PLAN: 182 | ROADMAP=3/до V-2 | STATUS=done | NEXT=закрыто` — это тег `done/contracts/182/1`, инвариант 2.
- **Complior-mob.** `git status --porcelain` до и после — 0 и 0 строк. rc=1, stdout пуст:
  - `PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=4182557eb9d4e1651f8d14233b5a224af50fab36): нет .harness/registry/plan.tsv на origin/main=4182557e…; станционный корневой реестр не подменяет; выход: план проекта заводит владелец коммитом в .harness/registry/plan.tsv (996)`.
- **Complior-back.** Porcelain 0 и 0. rc=1, сообщение того же вида, origin/main=12ce21658c9db2168758cf4031553f64dcc867c4.

## Повестка (4) — регресс на судимом дереве

Гейты запускались через `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL`, каждый режим батареи — отдельным вызовом.

```
W --repo .  (прогон 1) → 34 GREEN, «RED proj-no-decoy: rc=0» (вторая клетка — мир без пауз), CELLS=35 GREEN=34, RC=1  ← ложная RED батареи, см. С-4
W --repo .  (повтор 1) → CELLS=35 GREEN=35, RC=0
W --repo .  (повтор 2) → CELLS=35 GREEN=35, RC=0
W --model              → CELLS=35 GREEN=35, RC=0
W --stabs              → 35 GREEN; STAB handoff/stale/local/no-roadmap/head/no-project-mode/root-decoy/local-profile-plan/pauzy-required/silent-empty/station-fallback/project-no-crosscheck/resolver-fallback/legacy-fallback/registry-hardcode/vague-refusal/no-exit caught; STABS=17 CAUGHT=17, RC=0
bash -n scripts/orch_plan_slice.sh                 → RC=0
bash scripts/gen_ci_steps.sh --check               → RC=0
bash scripts/check_charter.sh  «уставных документов: 181 · изменений в них: 525 · с разрешения: 525» → RC=0
bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh → RC=0
bash fixtures/workshop_project/rezhim_996/probe.sh «996: examined=111 mutants=0 mismatches=0» → RC=0
bash fixtures/workshop_project/sessii_125/red_sessii_125.sh «s125 red: зелёных 70, красных 0» → RC=0
bash scripts/check_zones.sh — второй чистый ssh-клон /tmp/dev-harness-verify/Rev182b/zones, detached HEAD=92fb47e12bd2ccf008b0ed675bde834987a12e08 (HEAD не переключался):
     «замороженных контрактов: 181 · объявленных авторов: 5 · коммитов в диапазонах: 64383 · проверено по зонам: 20556» real 14m9.9s → ZONES RC=0
```

**Почему первая RED — артефакт батареи, а не дефект OBJECT.** В том же прогоне `GREEN proj-no-pauzy-structural`, то есть stdout равен оракулу `project_expected(pauzy=False)`. Неизменяемые строки оракула (301–304, `7/до W-1`) не содержат `147`, `148` или `V-2`. Значит, подстроку дал случайный SHA в строке `PLAN_SNAPSHOT`, который проверка `probe.py:298-299` тоже просматривает.

**Зоны своей мерой.** `git show --name-only 92fb47e1` даёт `scripts/orch_plan_slice.sh`, `roles/orchestrator.md` и `.omp/agents/orchestrator.md`. Это подмножество двух зон:

- ЗОНА implementer 182 — `scripts/orch_plan_slice.sh roles/orchestrator.md`, строка ЗОНЫ v1 и дельта v2;
- `.omp/agents/` — ЗОНА implementer `contracts/002-approval-mode-steward.md:67` и `contracts/003-skills-metta-adaptacija.md:102` (последние теги 002/7 и 003/6).

Автор коммита — implementer.

`ci_preflight` не запускал: задание фиксирует, что он одинаково красный на main и OBJECT (это подтверждено Rev182), и он вне повестки скоупного вызова.

## Проверки роли (в объёме повестки)

1. **Область правки.** Три файла входят в зоны (см. выше); правка роли — +1 строка. Соответствует.
2. **Сырой вывод.** Всё выше получено своими прогонами. Соответствует.
3. **Проверки не подогнаны.** `git diff --stat 5aa24116 92fb47e1` даёт только три файла, `fixtures/` и `contracts/` не тронуты. Мир свой: номера, пути и тексты отличаются от батареи и от `edge.py`/`edge2.py`. Соответствует.
4. **Красное предъявлено.** На прежнем OBJECT — 7/19, на OBJECT — 19/19 (см. выше). Соответствует.
5. **Атомарность.** Один коммит со ссылкой на предмет: «182 v2 fix1: три блока Rev182 …». Соответствует.
6. **Норма не тронута молча.** Правка роли — ровно санкционированная оговорка ЗОНЫ v2. Норма-строка ПРОВОДКИ цела. Соответствует.
7. **Заявленное = сделанное.** Счёт файлов и строк сверен по `--stat` (выше). Счёт клеток своей мерой: CELLS=35, STABS=17 по выводу раннера и по 35 строкам GREEN. Уникальных имён клеток 34 — это С-2 Rev182, батарея architect.

## Паразитная сложность (050) — новые артефакты диффа

- **`norm_rel()` (`scripts/orch_plan_slice.sh:157-167`) — ESSENTIAL.**
  1. Свойство: И-6/И-7 (путь резолвера в относительной форме, правдивый отказ).
  2. Состояние: локальная `p`; результат виден в путях сообщений.
  3. Совместно меняется 1 файл.
  4. Интерфейс не вырос.
  5. Потребитель — повестка (3); в батарее клетки нет (риск остаётся, см. «Что не проверено»).

  Простая форма Rev182 (`${reg_rel%/}`) не покрывает `///` и `//` из повестки — нынешняя форма ей адекватна.
- **Проектная ветка ls-remote/rev-list (`:258-272`) — ESSENTIAL по свойству (И-7 в проектном режиме, побайтность v1 в станционном).** Ни состояния, ни интерфейса не добавляет. Дублирование вызовов git в двух ветках — ACCIDENTAL-мелочь. Простая форма есть (один вызов, выбор сообщения в `||`), но обязательной её не делает ни одна строка приёмки. Это совет С-5, не блок.

## ПРОВОДКА (038)

- **guard.** `scripts/orch_plan_slice.sh` — барьер этого предмета; шаг CI `registry/ci-steps.tsv:303` не менялся.
- **role.** Канал восстановлен: `check_provodka` RC=0, норма-строка `grep -Fx` = 1.

## СВЕРКА-СТАНДАРТОВ:

Неприменимо: `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (`grep -c` → 0).

## СВЕРКА-АРХИТЕКТУРЫ:

- **Размещение:** `scripts/`, как в v1.
- **Зависимости:** новых нет — `next_id.sh` (`project_paths_resolve`) уже был в 5aa24116, второй резолвер не введён.
- **Писатели:** нет, срез только читает.
- **Операции:** git show / cat-file / ls-remote / rev-list — только чтение.
- **`bindings.json` и модель 188:** в харнессе отсутствуют (`tooling/checks/cli.js` нет; `git ls-files | grep bindings.json$` → 1, это фикстура 119). Уровень diff модели неприменим, долг не расширен.

## Режим проекта (996)

sourceCanon не объявлен: в `harness.project.json` на origin/main нет `sourceCanon`, grep rc 1.

## ОСТАТОК (192)

В контракте 182 строк К-NN нет (`grep -c 'К-[0-9]'` → 0). По «НЕ ЗАЩИЩАЕТ» v2:

- **Отсутствие плана — не укусило.** Complior-mob и Complior-back дают правдивый отказ с выходом.
- **Задержка fetch — не укусило.** P1 и P2 называют выход «восстановить доступ к origin (fetch)».

## Мобильный экран

Неприменимо.

## Советы и наблюдения

Подробно — в `.review/2026-11-18-106.md`.

- **С-4 (architect 182 — батарея).** `probe.py:276-277,298-299` проверяет no-decoy по подстрокам `147`/`148` с учётом строки SHA. Около 5 % ложной RED на прогон; наблюдено один раз из трёх `--repo .`. Простая форма — `lines[1:]` или поиск по полю id.
- **С-5 (implementer 182 — 050).** Дублирование вызовов `ls-remote`/`rev-list` по веткам режима.
- **С-1…С-3 Rev182.** Не повторно судятся и остаются советами.

## Развилки

- **Ложная RED батареи (С-4) при «35/35 rc 0» в повестке (4).**
  - Прочтение: повестка требует зелёного прогона на судимом дереве, а первая RED — артефакт фикстуры (зона architect), не судимой реализации.
  - Решение: принял по двум повторам 35/35 rc 0 и по доказательству, что RED дал SHA, а не stdout субъекта.
  - Консервативная часть: находка заведена советом architect, а не замолчана.
  - Если оркестратор считает нестабильность шага CI блоком предмета — это вопрос к architect 182, не к OBJECT.
- **Имя ветки вердикта.** Взял `wip/182/reviewer-impl2`, как в задании. Вердикт `contracts-182-v2-impl-v2.md` новый, чужой файл не перезаписан.

## Что не проверено

- Полный проход Р1–Р… не повторял: вызов скоупный.
- `ci_preflight` не запускал (см. выше).
- Полный CI-workflow не гонял.
- В батарее 182 нет клетки на нормализацию `//` и на префикс ls-remote/rev-list. Регресс этих свойств держат только мои миры вне репо, CI их не ловит. Это вопрос к будущей v+1 батареи, не к OBJECT.

## Применимость

Вердикт привязан к OBJECT `92fb47e12bd2ccf008b0ed675bde834987a12e08` и к судимому дереву «origin/main `0ddebafb57` + блобы»:

- `scripts/orch_plan_slice.sh` = `d862fd57`;
- `roles/orchestrator.md` = `d5e67a20`;
- `.omp/agents/orchestrator.md` = `8540f329`.

Изменение любого из них снимает accept.
