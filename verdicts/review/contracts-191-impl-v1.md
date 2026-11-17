accept
OBJECT=bcaef502be178d2805df679cacfc96767fa72bc3
КЛАСС=кодовый; КЛАСС РИСКА=обычный — подтверждаю: это инструмент формы до платного критика; права и роли, авторизация, деньги и ПД не затронуты; адверсарий по заданию не вызывался
СУД: repo=a3ka/dev-harness; предмет=191; фаза=реализация; роль=reviewer; вызов=1/1; модель-план=reviewer→audit (config/agent_models.json); сессия=Rev191Impl; модель-факт=anthropic/claude-opus-5-5; SHA=bcaef502be178d2805df679cacfc96767fa72bc3; контракт=frozen/contracts/191/1 (c3f1335a7ea99872b43705a778e67d5a6b736b6e); предыдущий=нет; исключение=нет

# Вердикт reviewer — 191 «Л1: форма до критика», реализация, вызов 1/1

**accept.** Блоков нет.

Советы и наблюдения лежат в `.review/2026-11-17-91.md` (`status: ready`); этот файл входит в тот же коммит.

| Находка | Класс | Адресат | Суть |
|---|---|---|---|
| С-1 | совет | architect / владелец | Буква И-2 «первая строка stderr» в живом дереве недостижима: (д2)/(д3) раньше печатают `ok`-строки, а трогать их запрещает И-5. Рабочее прочтение — форма строки отказа. |
| С-2 | совет | implementer / architect | На зелёной двери строки успеха несут маркер отказа: `ok   модель угроз красна` и т.д. Форма унаследована из честной модели. |
| С-3 | совет | architect | Отказ (з) цитирует первую строку check_ceilings, а это `ok`-строка. Причину (какой черновик) не видно. Реализация следует букве И-2. |
| С-4 | совет | architect | `--grammar` пропускает `- charter=AGENTS.md § «…»` с пустым заголовком (rc 0). Честная модель делает так же, done-гейт ловит. |
| Н-1 | наблюдение | orchestrator | В задании «+56/−2», по numstat +54/−2; всего +93/−2, а не +95. |
| Н-2 | наблюдение | — | Ветвь «--repo-дерево с гейтами формы» (вне батареи) проверена своим зондом, поведение верное. |
| Н-3 | наблюдение | — | NBSP в guard-цели проходит --grammar, done ловит. |
| Н-4 | наблюдение | — | (з) судит все черновики BASE (А-963). Старый check_provodka в --repo даёт rc 2 → отказ (И-3). |

**Клон.** `ssh://git@github.com/a3ka/dev-harness.git` склонирован в `/tmp/dev-harness-verify/Rev191Impl/repo`, у клона свой `.git`, frozen-теги подтянуты. Рядом локальные клоны `base` (detached на `e16a4c3ea4`) и `mut` (detached на OBJECT; мутации шли только в его рабочем дереве и откатаны, `git status --short` пуст), плюс `nogit-base` (`git archive e16a4c3ea4`). Основной чекаут станции не трогал. Вердикт закоммичен на ветке `wip/191/reviewer-impl1` от `origin/main` 87e2521a76.

## 1. Область правки

```
$ git log --format='%H %an <%ae> %s' -3 bcaef502be
bcaef502be178d2805df679cacfc96767fa72bc3 implementer <implementer@dev-harness.local> 191-Л1: ноги формы (ж/з/и) в двери и режим --grammar гейта проводки
e16a4c3ea40613d59c9882de34cb6ff8764cd270 orchestrator freeze: registry 191 → d95b7b351f6b7ba0fbe2450edee02300064fc9f6
c3f1335a7ea99872b43705a778e67d5a6b736b6e orchestrator land: wip/int-1913/architect
$ git diff --numstat e16a4c3ea4 bcaef502be
54	2	scripts/check_provodka.sh
39	0	scripts/pre_critic.sh
$ git diff --stat 'frozen/contracts/191/1^{commit}' bcaef502be -- fixtures/workshop_project/forma_do_kritika_191 contracts/191-forma-do-kritika.md   → пусто, rc 0
$ git diff --stat e16a4c3ea4 origin/main -- scripts/pre_critic.sh scripts/check_provodka.sh fixtures/workshop_project/forma_do_kritika_191 contracts/191-forma-do-kritika.md   → пусто
$ git merge-tree --write-tree origin/main bcaef502be   → 827f02a9f0…, rc 0
```

Изменены ровно два файла из `ЗОНА implementer: scripts/pre_critic.sh scripts/check_provodka.sh`. Коммит один, автор `implementer`, в сообщении есть ссылка на предмет («191-Л1»).

В pre_critic.sh только добавления: 13 строк в шапке и блок (ж)/(з)/(и) перед `printf 'КРИТИК: дверь зелёная'`. Ноги (а)–(е), разбор CLI `--repo` и строка зелёной двери не тронуты.

В check_provodka.sh две удалённые строки — это `ROOT=`/`CONTRACT_PATH=` с usage. В ветви `else` они вернулись дословно, так что usage обычного режима байт-в-байт прежний. Новые ветви `GRAMMAR` стоят после всех проверок формы и до первого обращения к ФС: guard на :611, role на :655 после role_component_ok, charter на :744 после pinning `AGENTS.md`.

Проверки 3 и 6 чисты: файлы батареи, фикстур, контракта и норм коммит не трогает. Последняя правка семьи — `73166b66` от architect, она до заморозки.

## 2. Сырой вывод, своя мера

Батарея 191 на OBJECT:

```
$ reslop t -- bash fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh   → exit: 0
  (raw) 191 g01-dver-zelena ok rc=0 · t01 ok rc=0 · r01 ok rc=0 · p04 ok rc=1 ['проводка: guard-файл не существует: scripts/novyj_gard_191.sh']
        191 m02-ugrozy-metki-v-bullete ok rc=1 ['ОТКАЗ: модель угроз красна (rc=1): модель угроз: список ЗАЩИЩАЕТ: отсутствует']
        191 m03/m04/p01/p02/p05/p06/p07 ok rc=1 · p03-grammar-bez-fajlov ok rc=0 []
        191 f01-rc2-ne-zeleno ok rc=1 ['ОТКАЗ: модель угроз красна (rc=2): NOT_IMPLEMENTED: тело контракта пусто: …']
        ИТОГ 191: rc=0 KLETKI=14 ZELENYE=14 KRASNYE=0
$ … --model   → ИТОГ 191: rc=0 KLETKI=14 ZELENYE=14 KRASNYE=0        RC_MODEL=0
$ … --stabs   → ИТОГ 191: rc=0 OBMANOK=13 POIMANY=13 ZHIVYH=0        RC_STABS=0
```

Свой счёт сделан другой командой, не выводом раннера. `grep -c "Kletka(" probe.py` = 14 (14 строк `K.append(Kletka(…))`, probe.py:156–191). `ls stabs | wc -l` = 13. Строк данных в stabs.tsv (`grep -vc '^#'`) — 13. Миров (`grep -cE "^    '[a-z_]+': \(" probe.py`) — 12. `mir/*.md` — 8, `model/scripts/*.sh` — 2. С приёмкой и census-строками контракта всё совпадает.

Приёмка 7 на OBJECT:

```
$ bash scripts/pre_critic.sh contracts/191-forma-do-kritika.md        → stdout «КРИТИК: дверь зелёная»; stderr «ok модель угроз красна / ok потолки красны / ok проводка красна»; rc=0
$ bash scripts/check_threat_model.sh . contracts/191-forma-do-kritika.md → «модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 10 буллет(ов))» rc=0
$ bash scripts/check_ceilings.sh .                                      → «потолки в порядке» rc=0
$ bash scripts/check_precision_gate.sh . contracts/191-forma-do-kritika.md → OK rc=0
$ bash scripts/check_provodka.sh --grammar . contracts/191-forma-do-kritika.md → rc=0
$ bash scripts/check_provodka.sh . contracts/191-forma-do-kritika.md   → «проводка: guard не подключён: fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh не вызывается в .githooks/ или .github/workflows/» rc=1  (ожидаемо до CI-строки оркестратора)
```

Приёмка 8 (копия `mut` без guard-файла):

```
$ bash scripts/check_provodka.sh . contracts/191-forma-do-kritika.md         → «проводка: guard-файл не существует: fixtures/…/red_forma_do_kritika_191.sh» rc8=1
$ bash scripts/check_provodka.sh --grammar . contracts/191-forma-do-kritika.md → rc8g=0
```

Соседи на OBJECT (`/tmp/dev-harness-verify/Rev191Impl/sosedi.sh`):

```
=== krasnye_103                 ИТОГ 103: rc=0                                                     --- rc=0
=== krasnye_072                 итог 072: rc-перезапуск=0 rc-дверь-перед-критиком=0                  --- rc=0
=== red_dver_072                итог 072-двери-перед-критиком: стабы 6/6 + дифф 6/6 + честные 6/6    --- rc=0
=== red_pre_critic_cwd_103      i2/i2г/i2д/i2в — вердикт один                                      --- rc=0
=== antiplacebo_pre_critic      барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2   --- rc=0
=== antiplacebo_check_provodka  барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28 --- rc=0
=== krasnye_038 (EXPECT_RC=0)   итог: 37 файлов, расхождений 0 (режим ожидания rc=0)                --- rc=0
```

В выводе red_dver_072 есть строка «клетка s4(ручка): ожидался rc 0, получен 1». На базе `e16a4c3ea4` она такая же, это поимка стаба, rc 0.

996 `--matrix`, ДО и ПОСЛЕ:

```
base e16a4c3ea4: mutation broken-profile-fallback: freeze-broken-profile: rc=0  · 996: examined=111 mutants=76 mismatches=1  RC996_BASE=1
OBJECT bcaef502: mutation broken-profile-fallback: freeze-broken-profile: rc=0  · 996: examined=111 mutants=76 mismatches=1  RC996_OBJ=1
```

Расхождение побайтово одно и то же (мутант freeze-пути, к двери и гейту проводки не относится) — оно не новое.

## 3. Проверка не подогнана, красное предъявлено

Семью писал architect: коммиты `24b2e96f`, `fd90a443`, `31f25ed5`, `73166b66`, все с автором `architect`, все до заморозки. Между тегом и OBJECT diff пуст. Голая батарея на базе без реализации:

```
$ (base e16a4c3ea4) bash fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh
191 m02 … f01 KRASNO (10 клеток; p03 rc=2 'NOT_IMPLEMENTED: корня нет:')
ИТОГ 191: rc=1 KLETKI=14 ZELENYE=4 KRASNYE=10        RC_BASE_BARE=1
```

Это совпадает с приёмкой 1: зелёные контроли g01/t01/r01/p04, красных 10. Стабы — 13 из 13 пойманы, живых 0.

## 4. Инварианты контракта в коде — своими входами

Свой зонд — `/tmp/dev-harness-verify/Rev191Impl/rev_probe.py` и `rev_probe2.py`, вне дерева. Миры строит `probe.postroit_mir` батареи, субъект — scripts OBJECT.

```
R1 --repo вооруж. + красн. угрозы  rc=1 stderr1=['ОТКАЗ: модель угроз красна (rc=1): модель угроз: список ЗАЩИЩАЕТ: отсутствует']
R2 --repo вооруж. + честный        rc=0 stdout='КРИТИК: дверь зелёная'
O1 красен по ж,з,и                 rc=1 stderr1=['ОТКАЗ: модель угроз красна (rc=1): …']                 ← порядок: ж раньше з/и
O2 красен по з,и                   rc=1 stderr: ['  ok   модель угроз красна', 'ОТКАЗ: потолки красны (rc=1):   ok   roles/ пуст …']   ← з раньше и
S1 угрозы без +x (пропуск)         rc=0 stderr: ['  ok   потолки красны', '  ok   проводка красна']   ← нет исполняемого → молчаливый пропуск
F rc2 гейта (ж)                    rc=1 ['ОТКАЗ: модель угроз красна (rc=2): NOT_IMPLEMENTED: zond']
F rc2 гейта (з) / (и), rc7 (з)     rc=1 (отказ; первая строка — ok-строка (ж), см. С-1)
G12 несущ. цели (приёмка 6)        grammar rc=0 '' | normal rc=1 'проводка: guard-файл не существует: scripts/net.sh'
G06/G07/G09 role без нормы/вложенные/пустая      grammar rc=1 = normal rc=1, фраза «строка вне грамматики» та же
G08 role traversal                 grammar rc=1 = normal rc=1 «role-канал обязан ссылаться строго на roles/<роль>.md»
G10/G11 charter не AGENTS / без пробела перед «   grammar rc=1 = normal rc=1 «строка вне грамматики»
G13/G14 неизвестный канал / голая строка        grammar rc=1 = normal rc=1 «строка вне грамматики»
H01–H05 guard: таб / пробел / хвостовой пробел / пустой / «» вплотную   grammar rc=1 «строка вне грамматики: …» | normal rc=1 «guard-файл не существует»
H08 guard-токен + роль             grammar rc=0 | normal rc=1 «guard-файл не существует»
G01 charter с пустым §             grammar rc=0 | normal rc=1 «секция устава не найдена: §»   → С-4
```

Неизменность обычного режима (И-5) я мерил на всём корпусе. Прежний гейт (база) и новый прогнаны в обычном режиме на каждом `contracts/*.md` дерева OBJECT, сравнивались rc и весь stderr:

```
$ bash /tmp/dev-harness-verify/Rev191Impl/corpus_038.sh
CORPUS n=177 same=177 diff=0 rc0=120 rc1=57 rc2=0        rc=0
```

По инвариантам:
- И-1 выполнен: порядок ж→з→и (pre_critic.sh:330/332/334) идёт после (е); проверка `-x` и вызов гейта — оба от `$BASE` (:320–322); (а)/(б) на --repo не тронуты.
- И-2 выполнен по форме строки отказа: `ОТКАЗ: <маркер> (rc=N): <первая строка вывода>` (:324). Буквальное «первая строка stderr» в живом дереве недостижимо, подробности в С-1.
- И-3 выполнен: rc 1, 2 и 7 гейта дают отказ.
- И-4 выполнен: S1, t01, r01, а также 103 и 072 зелёные.
- И-5 выполнен: корпус 177/177; 038 37/0; antiplacebo check_provodka 28/28.
- И-6 выполнен: G/H выше, с одной оговоркой С-4.
- И-7 выполнен: g01 и сам 191 дают rc 0.
- И-8 выполнен: привязки стабов лежат в stabs.tsv.

## 5. Безопасность и надёжность

- **Подмена гейта кандидатом.** Без --repo `BASE=ROOT`, гейты — это `scripts/*.sh` судимого дерева. Кандидат — только файл контракта, путь до скрипта ноги он не задаёт: имена гейтов зашиты в pre_critic.sh:330–334. С --repo гейты берутся из R, как и требует И-1. Дерево, которое несёт свои ослабленные гейты, само себя и судит — это плата, названная в «НЕ ЗАЩИЩАЕТ». Обхода нет.
- **Инъекция аргументов через имя контракта.** Позиционных флагов у гейтов нет: check_threat_model.sh и check_ceilings.sh берут `$1/$2` без разбора опций. check_provodka.sh распознаёт `--grammar` только в `$1`, а там всегда стоит литерал или абсолютный `$BASE`. Значит, контракт с именем `--grammar`/`-x` попадает в CONTRACT_PATH, а флагом не становится. Всё процитировано в кавычках.
- **BASE без git.** Замер на `git archive` базы и OBJECT: дверь отказывает уже на ноге (а) («precision-gate красен»; гейт: «не репозиторий git»), одинаково ДО и ПОСЛЕ. Новые ноги туда не доходят. Отсутствие git в PATH нога ловит раньше, `NOT_IMPLEMENTED: нет git` (не изменено).

## 6. Паразитная сложность (050)

- **`noga_formy()` + 3 вызова (pre_critic.sh:318–334).**
  - (1) Свойство: И-1–И-4 (вооружение от BASE, именованный отказ с rc, fail-closed, пропуск).
  - (2) Состояние: только локальные `rc`/`out`, всё явно в аргументах и выводе.
  - (3) Число файлов, меняющихся вместе: 1, не выросло.
  - (4) Интерфейс: маркер + скрипт + argv, возврат 0 или exit 1. За ним скрыты exec, rc, первая строка и пропуск — модуль глубокий. Функция заменяет три копии inline-блока (д2)/(д3).
  - (5) Потребители: клетки m02–f01 батареи 191 и стабы.
  - Итог: ESSENTIAL.
- **Флаг `--grammar` + `GRAMMAR` + ветвь usage (check_provodka.sh:165–173).**
  - (1) Свойство: И-6.
  - (2) Состояние: `GRAMMAR` задаётся явно через argv.
  - (3) 1 файл.
  - (4) +1 флаг, коды rc те же; новой грамматики нет, переиспользован существующий разбор г0/г0-доп/Л/extract_quoted/pinning.
  - (5) Потребители: нога (и) и клетки p01–p07/p03.
  - Сдвоенная ветвь usage нужна, чтобы по И-5 сохранить usage обычного режима дословно. Единая строка `[--grammar]`, как в модели, его бы изменила.
  - Итог: ESSENTIAL.
- **Три `if GRAMMAR … continue` в цикле каналов (:611, :655, :744).**
  - (1) Свойство: И-6 «существование не судится».
  - (2) Нового состояния нет.
  - (3) 1 файл.
  - (4) Интерфейса нет.
  - (5) Потребитель: p03.
  - Guard-ветвь добавляет одно правило формы «один токен», его требует И-6.
  - Итог: ESSENTIAL.
- **Шапки-комментарии (+13 и +14 строк).** Документация режима и ног, повторяет И-1–И-6. Состояния не вводят. ESSENTIAL как описание API.

ACCIDENTAL-находок нет. С-2 — это вопрос именования, не сложности.

## 7. Нормы проводки, режима проекта, макета

- ПРОВОДКА контракта: `- guard=fixtures/workshop_project/forma_do_kritika_191/red_forma_do_kritika_191.sh` и строка ПРОВОДКА-ЭНФОРСМЕНТ. Guard — это раннер семьи этого предмета, не «любой скрипт дерева». Обоснование чистого энфорсмента честное: поведенческих норм ролей предмет не вводит, механизм — дверь и гейт. Подключение в CI — шаг оркестратора между freeze и done. Сейчас обычный режим даёт rc 1 «guard не подключён»; на done нужен rc 0 после CI-строки и замера.
- Режим проекта (996): дерево — сам харнесс, sourceCanon не объявлен, так что не применимо.
- Мобильный экран: не применимо.

СВЕРКА-СТАНДАРТОВ: не применимо. AGENTS.md дерева не объявляет документа архитектуры и стандарта кода: `grep 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` пуст. Файлы `docs/owner/ARCHITECTURE.md` и `docs/owner/CODING-STANDARDS.md` в дереве — документы чужого проекта (AI Act Compliance Platform, TypeScript и backend), к bash-скриптам харнесса они не относятся. Сверял по кодовому канону самих файлов: доверенный PATH и env-гард check_provodka не тронуты; новые ветви встали после проверок формы и до ФС; фраз причин не прибавилось — в --grammar используются только существующие «строка вне грамматики» и «role-канал обязан…».

СВЕРКА-АРХИТЕКТУРЫ: не применимо. У dev-harness нет закреплённой модели архитектуры: в `git ls-tree origin/main` нет `tooling/checks/cli.js`, а единственный `bindings.json` — фикстура `import315_119`. Значит, не по чему судить размещение, зависимости и писателей, операций и `bindings.json` тоже нет. Дифф модели — нулевой, уровень L0. Долг не расширен: правка не выходит за два файла зоны. Находок 188 не заводил, расхождения модели и работы нет.

## Итог

Работе можно верить. Дифф ровно в зоне. Батарея написана до реализации и красна на базе 10 из 14, на OBJECT зелёна 14 из 14, стабы 13 из 13 пойманы. Обычный режим проводки побайтово неизменен на 177 контрактах. Соседи зелёные. Расхождение 996 одно и то же ДО и ПОСЛЕ. Четыре совета адресованы в основном формулировкам контракта 191 (С-1, С-3, С-4) и форме строки успеха (С-2). Ни один не опровергает замороженного обязательства так, чтобы блокировать.

После accept оркестратору остаётся: строка step батареи 191 в `registry/ci-steps.tsv` и её замер, затем `bash scripts/check_provodka.sh . contracts/191-forma-do-kritika.md` → rc 0 на HEAD с CI-строкой.
