FAIL

Блокируют слияние три находки. Полный список с чекбоксами — `.review/2026-10-13-02.md`.

1. **Р2-1 [architect], новая.** `check:nabludenia` красный от адреса А-411 (коммит 010b644a). Класс тот же,
   что у Р1-4 круга 1. Ключ стоит в CI (lane l6) и, кроме того, валит само-проверку `_krasnye_071.sh`.
2. **Р2-2 [architect v+1 + implementer], новая.** Решение 1г2 не выполнено: `registry/ci-steps.tsv` лежит
   вне проверочного замыкания M^1. Материализованный lane-раннер исполняет команду из реестра кандидата.
   Предъявлено живьём: «CANDIDATE-BYTES-EXECUTED», lane_rc=0. Клетка л на этом зелёная.
3. **Р1-7 [владелец], перенос.** `config/ci_parity_exceptions.txt` вне ЗОНЫ implementer. Ждёт подписи по
   `forks/099-ci-parity-exceptions-zone.md`. Новых находок по этому пути нет.

Р1-1…Р1-6 и Р1-8 круга 1 закрыты: проверено своей мерой и красными прогонами V1–V5.
A099-M2 закрыт: вход н-1 красен против pr_dopusk до фикса (V5).

# Reviewer 099, круг 2 (гейт перед слиянием)

- **Модель трассы (Н-270).** Тир роли reviewer — `audit` (`config/agent_models.json:57-58,85`, `"model": "@opus"`).
  Модель этой сессии — `anthropic/claude-opus-5-5` (workstation). Совпадает. Авторы предмета на других
  семействах (architect/implementer), самокритики нет.
- **Предмет.** `frozen/contracts/099/1` → `430522ce`. Блоб контракта `aff103f7` одинаков на теге и на слиянии.
- **Судимые tip.**
  - architect: `010b644a`.
  - implementer: `4952f3ff`. Это потомок architect tip (`merge-base --is-ancestor` rc 0), база 601b4534.
  - Адверсарий: круг 3 `e6eac1dd` (BLOCKS A099-M2) → круг 4 `23cc2258` (ACCEPT).
- **Клон.** Одноразовый SSH-клон `/tmp/dev-harness-verify/rev099-c2-n7f3q`
  (`git clone ssh://git@github.com/a3ka/dev-harness.git`, rc 0).
  - Слияние: `checkout origin/main 23cc2258` + `merge --no-ff origin/wip/099/implementer` → `8f84e8fe`,
    конфликтов нет.
  - Worktree: main `23cc2258`, `010b644a`, `4952f3ff`, `34ce4e29`, `8bd94a43`.
  - Пробы: `rev099-c2-reg` (Р2-2, V1–V5), `rev099-c2-071-*`.
  - После коммита вердикта всё удалено.

| артефакт на слиянии 8f84e8fe | блоб |
|---|---|
| scripts/pr_dopusk.sh | 19cbe8a6 |
| .github/workflows/ci.yml | 15fe7a26 |
| config/transition_producers_099.tsv | 7964759c |
| config/ci_parity_exceptions.txt | 77a4a058 |
| roles/orchestrator.md | 9c28af2b |
| .omp/agents/orchestrator.md | 3e3db447 |
| fixtures/zashchita_main_099/red_perehodnyj_gheit_perechen.sh | 899cdffc |
| fixtures/zashchita_main_099/_mir.sh | af8d656a |
| fixtures/zashchita_main_099/.probe-only | 431d0ee1 |
| NABLIUDENIA_ARCHITECT.md | 1bba65f7 |

Новая редакция любого из этих блобов принятие этого вердикта не наследует.

## Сырой вывод (своя мера, слияние 8f84e8fe, если не сказано иное)

```
$ bash fixtures/_krasnye_099.sh
стаб-пак: 12/12 поймано
случаев 18, провалено 0
ЗЕЛЕНО: red_huk_task_spavna … ЗЕЛЕНО: red_sud_model_materializatsija      (grep -c '^ЗЕЛЕНО' = 10)
ИТОГ 099: rc=0                                                              RC_099=0
$ ls fixtures/zashchita_main_099/red_*.sh | wc -l                → 10
$ grep 'пойман' вывод | grep -vc 'стаб-пак:'                     → 12
# входы perechen своей мерой: toy-вызовы zpg а б в г д ж н-1 н-2 е з и к м-1 м-2 + живые л, м
#   → 13 буквенных входов (а…н) — сходится с «Тринадцать входов» (:5) и А-411 «12→13»

$ reslop t -- npm run -s check:ceilings        → потолки в порядке, exit 0  (orchestrator.md 50691 байт)
$ reslop t -- npm run -s check:gen             → exit 0 («харнес соответствует roles/ (9 ролей)»)
$ reslop t -- npm run -s check:ci-parity       → workflow-команд: 17 · … · расхождений: 0, exit 0
$ reslop t -- bash scripts/gen_ci_steps.sh --check → exit 0
$ npm run -s check:zones                       → RC_ZONES=0
  # 099 в registry/contracts.tsv слияния нет (grep -P '^099\t' пуст) — зоны 099 барьер НЕ судит; мера — таблица ниже
$ reslop t -- npm run -s check:nabludenia      → FAIL А-411: адрес не называет цель (…), exit 1     (Р2-1)
  main 23cc2258 rc=0 · 34ce4e29 rc=0 · architect 010b644a rc=1 · implementer 4952f3ff rc=1 · слияние rc=1

$ bash scripts/verify_antiplacebo.sh --scope land_agent      (чистое дерево)
  FAIL fixtures/dokazatelstva_098: фикстура без барьера — она ничего не держит
барьеров: 1 · фикстур: 9 · предъявлено красным повторным прогоном: 9
расхождений: 1                                                  RC_AP=1   (= main, круг 1: main 1)
# первый прогон дал 2: второе — «дерево изменилось вне $WORK … ./tmp/zones.*» — артефакт моего
# параллельного check:zones в том же дереве; перепрогон на чистом дереве — 1

$ bash fixtures/_krasnye_098.sh                 main RC_098=1 · слияние RC_098=1
  diff stdout: единственная строка — путь корня (/tmp/…/rev099-c2-wt-23cc2258 vs …/rev099-c2-n7f3q)

# Р2-2, проба /tmp/dev-harness-verify/probe_reg.sh (кандидат поверх слияния 8f84e8fe)
== дифф кандидата
 registry/ci-steps.tsv  |  2 +-
 scripts/run_ci_lane.sh | 67 +-------------------------------------------------
== материализация дословно (ci.yml, шаг 1г2)
== остаток кандидата после материализации
 registry/ci-steps.tsv | 2 +-
== контроль: lane-раннер восстановлен из M^1?
run_ci_lane.sh = M^1
== Lane-шаг: bash scripts/run_ci_lane.sh check:ids
+ echo CANDIDATE-BYTES-EXECUTED; exit 0
CANDIDATE-BYTES-EXECUTED
lane_rc=0
== команда ключа в M^1:
step	check:ids	20	bash scripts/check_ids.sh --incr tmp/ci-incr/ids.sha
$ npm run -s check:ci-parity   (на кандидатском реестре)  → расхождений: 0, parity_rc=0
# клетка perechen на слиянии ЗЕЛЕНА (V0) — вход л реестр не видит

# Красное предъявление, /tmp/dev-harness-verify/probe_mut.sh (клетка perechen, слияние 8f84e8fe)
== V0 честное слияние                                   ЗЕЛЕНО                                  cell_rc=0
== V1 ci.yml круга 1 (8bd94a43)                         КРАСНО … вход л: живой workflow не материализует замыкание M^1 до запуска проверок …   cell_rc=1
== V2 живая таблица производителей пуста                КРАСНО … вход м: таблица производителей пуста (0 строк) …   cell_rc=1
== V3 живая таблица без строки ap5                      КРАСНО … вход м: производитель не объявлен для обязательных имён: ap5 … строк 12, обязательный набор — 13   cell_rc=1
== V4 pr_dopusk: отказ на пустую таблицу снят           КРАСНО … вход м-1 … вход м-2 … ожидался отказ «таблица производителей пуста или отсутствует»; факт rc=1 (другая фраза)   cell_rc=1
== V5 pr_dopusk до фикса A099-M2 (54b5a816)            КРАСНО … вход н-1: ожидался отказ rc 1 «составляющая неоднозначна: l1»; факт rc=0   cell_rc=1
```

### 071

```
$ bash fixtures/_krasnye_071.sh
main 23cc2258:                       28 строк ok, затем ОТКАЗ: п3а: rc=0 (ожидался 1) …            RC_071=1
implementer 8bd94a43 (фикс Р1-8):    28 строк ok, затем ОТКАЗ: п3а: rc=0 (ожидался 1) …            RC_071=1
  diff ok/ОТКАЗ-строк 8bd94a43 ↔ main (tmp-пути и хеши нормализованы) → IDENTICAL_MODULO_TMP
слияние 8f84e8fe:                    ОТКАЗ: само-проверка: toy-мир не зелёный на check:nabludenia rc=1:
                                     FAIL А-411: адрес не называет цель …                        RC_071=1  (Р2-1)
слияние + маска А-411 (проба):       28 строк ok, затем ОТКАЗ: п3а: rc=0 (ожидался 1) …            RC_071=1  (= main)
# Р1-8 закрыт: заявление 8bd94a43 («rc 1 на п3а, предсуществующее») воспроизводится; семантика 071 дельтой
# --object не ослаблена. На слиянии до п3а прогон не доходит из-за Р2-1.
```

## Семь вопросов гейта

1. **Область.** Таблица зон круга 2 — коммиты после круга 1, своя мера `git diff --stat <c>^1 <c>`:

   | коммит | автор | файлы | зона |
   |---|---|---|---|
   | 4c670475 | architect | `.probe-only`, `_mir.sh`, perechen, NABLIUDENIA_ARCHITECT.md | ✓ ЗОНА architect + процессный |
   | 77f3cffd | architect | NABLIUDENIA_ARCHITECT.md | ✓ процессный |
   | 34ce4e29 | architect | perechen | ✓ |
   | 010b644a | architect | NABLIUDENIA_ARCHITECT.md | ✓ процессный (Р2-1 — содержание) |
   | 8bd94a43 | implementer | roles/orchestrator.md, pr_dopusk.sh, **.omp/agents/orchestrator.md** | ✓ + генерат вне зоны (Н2-1) |
   | 518d9312 | implementer | merge architect 77f3cffd | ✓ чисто: `git diff 77f3cffd 518d9312 -- fixtures NABLIUDENIA_ARCHITECT.md contracts .omp/extensions` пуст |
   | 96278cb2 | implementer | ci.yml, transition_producers_099.tsv, pr_dopusk.sh | ✓ |
   | 54b5a816 | implementer | merge architect 010b644a | ✓ чисто: тот же diff против 010b644a пуст |
   | 4952f3ff | implementer | pr_dopusk.sh | ✓ |
   | (39bf3efa, перенос) | implementer | config/ci_parity_exceptions.txt | ✗ Р1-7, форк у владельца |

   Identity: `git log --format='%an|%cn' origin/main..4952f3ff` → architect 9, architect099 4, implementer 7,
   orchestrator 1. Чужих имён нет.
2. **Сырой вывод.** Каждое «закрыто» из сообщений коммитов я перепрогнал сам (выше).
   - Р1-1: «50691 < 51200» совпадает.
   - Р1-2: «осталось 1 расхождение dokazatelstva_098» совпадает.
   - 99-батарея «10/10, 12/12» совпадает.
   - Живые пробы приёмки 4 по-прежнему не исполнены — НЕ ПРОВЕРЕНО (Н2-5).
3. **Проверки не переписаны под код.** Собственные коммиты implementer не трогают `fixtures/` и контракт. Два
   merge-коммита несут только содержимое architect, без злых правок (таблица выше). Клетку perechen после
   заморозки правил architect по находкам Р1-5/Р1-6/A099-M2. Вход л переписан на свойство «ни один шаг
   проверяемой джобы не исполняет байты кандидата до материализации». Старый контрпример он по-прежнему ловит
   (V1).
4. **Красное предъявлено.** Вход л — V1, вход м — V2/V3/V4, вход н — V5, все мои. Барьера на реестр lane-команд
   нет совсем (Р2-2).
5. **Атомарность.** 8bd94a43 закрывает три находки (Р1-1/Р1-2/Р1-8), 96278cb2 — две (Р1-5/Р1-6). Это пачки
   починки одного предмета по норме 050 со ссылками на находки: не связка разных задач, отказа нет. 4952f3ff —
   одна находка (A099-M2).
6. **Норма.** `roles/orchestrator.md` лежит в ЗОНЕ implementer, ПЕРЕСЕЧЕНИЯ — «точечные нормы Решений 6/7,
   прочая семантика не меняется». Сокращение примерно 660 байт вне секции 099 вынуждено потолком (запас базы
   46 байт). По моему чтению это дубли и история, норма не ослаблена. Одна снятая строка в сообщении не названа
   — Н2-2, вопрос владельцу. Других нормативных документов дифф не трогает.
7. **Заявленное = сделанное.**
   - «10 клеток» — 10 по `ls` и 10 строк ЗЕЛЕНО.
   - «12/12» — 12 строк «пойман».
   - «13 входов» — 13 букв по вызовам.
   - «13 строк таблицы» — `wc` 13, имена совпадают с реестром перехода.
   - «check:gen rc 0» — 0.
   - «0 расхождений parity» — 0.
   - Отчёт о 071 — см. раздел 071.
   - Адверсарий круга 4 «M2 закрыт» — подтверждаю (V5).

## ПРОВОДКА (038)

- guard=`fixtures/_krasnye_099.sh` существует. Он подключён прямым шагом в новой джобе `selftest` и судит именно
  этот предмет. Джоба не входит в обязательный набор допуска (Н2-4). Это согласуется со строкой
  ПРОВОДКА-ЭНФОРСМЕНТ, но противоречие «подключён до landing» (Н-4 круга 1) остаётся.
- role=`roles/orchestrator.md`, «## Нормы 099 (Н-270)». После сжатия несёт все пять норм:
  - явный agent и модель тира;
  - PR-работа в отдельном дереве;
  - служебные записи пакетными PR;
  - owner-PR без переавторства;
  - слияние — доверенный компонент.
- Поведенческая норма идёт role-каналом, хук З-7 — guard-каналом. Обоснование честное.

## Паразитная сложность (050): артефакты круга 2

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель/дубль | класс |
|---|---|---|---|---|---|---|
| pr_dopusk.sh нога производителя (переписана, без выключателя) | Решение 2 «каждое имя покрыто» | читает tsv по M^1, явное | 3: tsv, pr_dopusk, клетка — не выросло | интерфейс не вырос (флагов и env нет) | вход м | ESSENTIAL |
| pr_dopusk.sh счёт дублей check-run (+9) | Решение 1г, A099-M2 | нет | 1 | новых флагов нет | вход н | ESSENTIAL |
| pr_dopusk.sh шапка «Коды возврата:» | 016/022: классификация анти-плацебо | нет | 1 | — | verify_antiplacebo | ESSENTIAL |
| config/transition_producers_099.tsv (13 строк) | Решение 2 «команда дословно» | данные | дублирует команды ci.yml дословно — этого требует сам контракт | — | pr_dopusk, вход м | ESSENTIAL |
| ci.yml: джоба `selftest` + материализация в `antiplacebo` | 1г2 (Р1-5) | нет | ci.yml + exceptions (2) | — | вход л; parity | ESSENTIAL (дыра — Р2-2) |
| `_mir.sh` Z99_BASE_PRODUCERS (env фикстуры) | toy-входы м-1/м-2 | env только внутри семьи | 1 | 1 env | м-1, м-2 | ESSENTIAL |
| perechen, входы л/м/н (семья — один артефакт) | приёмка 1-3, Р1-5/Р1-6/M2 | живой ci.yml читается awk | — | — | раннер 099 | ESSENTIAL. Совет: awk-разбор ci.yml во входе л — вторая грамматика рядом с `verify_ci_parity.sh`, не блокирует |
| `.probe-only` | 034, инв. 1 | нет | 1 | — | verify_antiplacebo | ESSENTIAL |
| roles/orchestrator.md (сжатие) | Р7 + потолок Н-77 | нет | 2 (+генерат) | — | ПРОВОДКА role, check:gen | ESSENTIAL |

Находок класса ACCIDENTAL нет.

## Итог

FAIL. Починка по норме 050 (раздаёт оркестратор):

- architect — Р2-1 (адрес А-411 по грамматике);
- architect — Р2-2: контракт v+1, замыкание или байт-минимум включает `registry/ci-steps.tsv`, плюс красный
  вход;
- implementer — Р2-2: ci.yml или pr_dopusk по v+1;
- владелец — Р1-7 (подпись форка), вопрос Н2-2.

Р1-7 (форк, `ОТВЕЧЕНО: нет`) и Р2-2 оба требуют v+1 `contracts/099-*.md`. Одна редакция v+1 может нести
и ПЕРЕСЕЧЕНИЕ на `config/ci_parity_exceptions.txt`, и расширенный хвост замыкания. Это наблюдение о порядке
работ, решение — за оркестратором и владельцем.

Неблокирующие Н2-1…Н2-6 — в `.review/2026-10-13-02.md`.
