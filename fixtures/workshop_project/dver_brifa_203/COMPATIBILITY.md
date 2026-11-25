# 203 rev2 — доказательство для консультанта, не сдача отказа как результата

Решение: ветвь 2 задания `/tmp/dev-harness-verify/task-203-architect-rev2.md`.
Контракт 203 и исполняемая батарея оставлены без изменений. Цель успешной
доставки api.transport НЕ выполнена и отказ ARCH_BRIEF_BUDGET не объявляется
итогом 203. Требуется адресное решение о frozen 170, а не повышение капа.

## Существующее: точные опубликованные обязательства

Проверка `git ls-remote --tags ssh://git@github.com/a3ka/dev-harness.git
'refs/tags/frozen/contracts/170/*'` показала только 170/1. Для соседей последние
опубликованные версии — 140/5, 187/3, 188/2, 189/1. Их peeled commits:

```
170/1 272e756d84ed6fe71b44d6f62682c2de5d4ea761
187/3 ac91200c8cbb46dcd4a5c5737a39857940bb348b
188/2 857d7b11dd443303441cf06fd6f773b9594372a1
189/1 b8d02f4997956bd75ecf70c9f5af1dc4fabfc278
140/5 a59decb01866627d31fe196ac0ab3be9c41ca11d
```

Команда получения первичного текста (остальные — тем же `git show`):

```
git show frozen/contracts/170/1^{commit}:contracts/170-arch-component-brief-vhod-zadanija.md
```

170/1, строка 17, дословно:

> Вывод каждого запуска попадает в contextPack именно для своего ID и роли, а не в ссылку на файл generated/briefs; его порядок соответствует порядку входных ID.

В той же строке:

> Бюджет 095 включает новый текст, а не обходится отдельным лимитом.

170/1, строка 29, самостоятельный приёмочный сценарий:

> Дано: проектный brief размером за пределами потолка contextPack 095; когда: `bash fixtures/workshop_project/arch_component_170/red_arch_component_170.sh --model`; тогда: rc 0, отдельная клетка `brief_over_budget ok` удостоверяет rc 1 субъекта, пустой stdout и именованный отказ `ОТКАЗ: режь задачу: … > 40000`; бриф учитывается в `pack_body`.

Это не только запрет каталога с буквальным именем generated/briefs: положительное
обязательство той же строки — **вывод каждого запуска в contextPack**, с прежним
общим бюджетом. Переименование внешнего файла не исполняет его. Строка 29
отдельно требует отказ на превышающем лимит брифе, а не успешный пак ссылок.

187/3 (`contracts/187-arhitektura-v-processe.md`), строка 33:
`make_task --arch-component` доставляет brief `--compact` из точного SHA lock,
с `--with-rules` для architect/critic/arbiter, без него для остальных трёх
ролей; две версии модели не смешиваются. Строка 51 требует сохранить прочие
обязанности 170 при смене источника. Поэтому pin-cutover не является санкцией
на другой формат доставки. Строка 9 также прямо оставляет зелёной батарею 170.

188/2 (`contracts/188-roli-po-arhitekture.md`), ПРОВОДКА:
architect выводит клетки из схем операций, semanticInvariant, writers,
isolationKeys брифа с правилами; critic сверяет операции, схемы, клетки,
consumes/writers и check --base. Следовательно, заменить большой компонент
произвольной краткой аннотацией недостаточно для обоих потребителей.

189/1 **станции** (`contracts/189-standartnye-validatory-i-kanon.md`) вводит
валидаторы и канон, а не исключение из доставки brief. 140/5 меняет замок,
OBJECT и runtime-checkout суда, не формат contextPack; его implementer-зона
не содержит make_task/check_architecture_contract. Их зоны сверены живыми
`git show`, новых станционных путей эта доказательная пачка не требует.

## Потребитель: 189 бэкенда — другой контракт

Прочитан именно тег **Complior-back**, не одноимённый 189 станции:

```
git -c credential.helper='!gh auth git-credential' fetch https://github.com/a3ka/Complior-back.git refs/tags/frozen/contracts/189/1
git show 7065462fc33f577f041c4102dd205f80a98dc04d:.harness/contracts/189-bdebt-imports-exact-exports.md
```

Коммит тега: `7065462fc33f577f041c4102dd205f80a98dc04d`.
Строки 12–13:

```
АРХИТЕКТУРА: L1 api.auth,api.transport,api.loader
ОПЕРАЦИЯ: contract.api.transport/command; вход schema.api_transport_command_Input; выход schema.api_transport_command_Output
```

Раздел «Существующее» называет pin snapshot 6
`6de3ff1211c9b0a67b00b46766f2f9d889cf1719` и подтверждение DECLARED операции
через `brief --component <id> --compact`; consumers — HTTP/command-transport
в api.transport, main/lib/errors/app/schemas в api.loader. Убрать api.transport
из флага ради бюджета значит потерять названный компонент предмета.
Наблюдение владельца из задания: brief api.transport **без rules** уже 91 445
байт. Повторно этот замер не запускался; ещё больший role-rules вариант не
нужен для доказательства нижней границы.

Первый SSH fetch backend дал `ERROR: Repository not found.`; HTTPS с
документированным credential helper успешно прочитал тег. Это исправленный
способ чтения, не недоступный источник и не причина остановки исследования.

## Как собирает существующий код

Код сверялся на базе сдачи `02e9fffae18522711586daae38e8e5249f9709f8`.
`scripts/check_architecture_contract.sh:490–504`, arch187_brief:
внутри выгруженного exact pin вызывает Node CLI `brief --compact`, добавляет
`--with-rules` по флагу роли, получает stdout в out и печатает его целиком.
Сейчас stderr направлен в /dev/null — самостоятельный дефект 203, который
доказательство упаковки не отменяет.

`scripts/make_task.sh:1055–1091` последовательно обходит входные ID,
выбирает role-rules и добавляет `COMPONENT: <id>` плюс весь `_arch_text`
в ARCH_SEC. `pack_body:1104–1125` печатает эту секцию вместе с MAP/RULES и
остальными обязательными секциями. Строки 1155–1156 считают **байты того же
сериализатора** и отказывают выше 40000. Строки 1171–1198 записывают manifest
и печатают пак только после этой проверки. Отдельного канала, автоматического
разбиения или обязательного разыменования/sha-проверки brief у потребителя нет.
`spawn_agent.sh:326–355` проверяет существование manifest, не собирает brief
из файлов или секций. Ролевые потребители 188 работают с доставленным брифом.

## Почему предлагаемые способы требуют изменения обещания

| Способ | Нарушаемое обязательство |
| --- | --- |
| Полный inline в одном прежнем паке | 91 445 > 40 000 ещё до MAP/RULES и остальных компонентов. |
| Внешний файл со ссылкой и sha256 | 170:17: в contextPack находится ссылка, не вывод каждого запуска; 170:29 вместо обязательного rc 1 получается rc 0. Проверка sha обеспечивает целостность, но не отменяет это обязательство. |
| Пронумерованные секционные паки | 170:17 и :29: один публичный вызов и его contextPack больше не содержат stdout каждого запуска; общий текст выносится в несколько самостоятельных лимитов. Порядок/sha не восстанавливают обещание одного прежнего пака. |
| Сжатый/base64 inline с последующей распаковкой | В паке другое представление, не stdout brief, а существующие роли/сборщик не имеют обязательного декодирующего шва; сценарий 170:29 также меняется. Сжимаемость произвольного конформного stdout в любом случае не гарантирована. |
| Срез или фильтрация операций/правил | 170:17: вывод заменён подмножеством; 188: схемы и инварианты потребителя могут исчезнуть. |
| Другой ID или несколько более узких ID | Не доставляет требуемый backend 189:12 api.transport; CLI данного компонента остаётся целым stdout. |
| Кап поднят, brief исключён из подсчёта или вынесен в иной лимит | Прямое нарушение общего бюджета 170:17 и условия задания. |

Доказательство несовместимости не зависит от перечисления всех упаковщиков:
при сохранении 170:17 прежний единый contextPack содержит весь вывод B,
следовательно его размер не меньше |B|. Для названного B |B| = 91445 > 40000.
Любая успешная альтернатива меняет либо включение B в этот пак, либо предел;
первое требует изменения frozen 170, второе прямо запрещено владельцем.
Нормализация завершающих LF command substitution эту нижнюю границу не снимает.

## Предложение для адресного решения владельца

Рекомендую разрешить v+1 170 **только для pinned overflow**: малый brief
остаётся прежним inline; большой целиком сохраняется вне checkout и .git в
каноническом project state, а пак ≤40000 содержит обязательное указание
прочитать файл до работы, component, exact pin, длину и sha256. Дверь
проверяет доступность/длину/sha до успешной выдачи, а потребляющий агент
обязан прочитать и проверить тот же файл до предметной работы. Срок жизни
артефакта покрывает сдачу потребителя; удаление tmp-выгрузки его не удаляет.
Это предложение, НЕ действующий инвариант 203 и НЕ записанное разрешение.

Выбор файла вместо секций: одно полное каноническое представление, не нужен
парсер заголовков модели и протокол продолжений/порядка; sha связывает
метаданные с содержимым. Цена — явная совместимая редакция 170:17/:29 и
обязательный потребитель ссылки; без них обещание недоказуемо. При санкции
красные клетки должны отдельно различать exact 91445-байтный brief,
усечение, подмену файла, отсутствие/перестановку частей (если выбраны части)
и повышение капа. Новая батарея до решения не подменяет прежнюю приёмку.
Зависимости exact-pin lock и видимый первый stderr остаются предметом 203.

## Процессное наблюдение

Статус старого SDACHA.md относится к исходной сдаче до решения 20:02 и не
свидетельствует о достижении новой цели успешной доставки. Эта пачка
показывает конфликт первичными frozen-строками, а не переписывает обязательство
или выдаёт формально зелёные ворота формы за решение владельческой боли.
Журнал NABLIUDENIA_ARCHITECT.md вне выданной зоны и не main; А-номер здесь не
резервируется. Наблюдение для оркестратора: проверка совместимости нового
формата должна читать также отрицательный frozen-сценарий over-budget,
не только положительную норму о полноте.

## Прогоны неизменённой батареи и ворот формы

Все команды запускались в собственной копии с
`TMPDIR=/tmp/dev-harness-verify`; subject `--repo .` — база выданной ветки,
не вновь полученный main. Production-файлы не менялись.
`--model` → rc 0, `--stabs` → rc 0, `--repo .` → rc 1.
Сырой итог и адресные предъявления (выдержки stdout):

```
CELLS=21 FAILURES=0 STABS=0 ZHIVYH=0
STAB unchecked-lock @ lock-different: CAUGHT rc=0 stderr=''
STAB lock-name-only @ lock-same-size: CAUGHT rc=0 stderr=''
STAB missing-donor-accepted @ donor-lock-missing: CAUGHT rc=0 stderr=''
STAB lockless-dependencies @ pin-lock-missing: CAUGHT rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (rc=1): node:internal/modules/cjs/loader:1573'
STAB raised-cap @ budget-large: CAUGHT rc=0 stderr=''
STAB silent-truncate @ budget-large: CAUGHT rc=0 stderr=''
STAB stderr-lost @ stderr-first: CAUGHT rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (rc=17): '
STAB stderr-last @ stderr-first: CAUGHT rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity (rc=17): SECOND_CAUSE_203: never select this'
STAB pin-from-head @ dependencies: CAUGHT rc=0 stderr=''
STAB rules-removed @ rules-architect: CAUGHT rc=0 stderr=''
STAB second-diagnostic-lost @ stderr-second: CAUGHT rc=1 stderr='ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events'
STAB budget-generic @ budget-large: CAUGHT rc=1 stderr='ОТКАЗ: режь задачу: api.identity 93024 > 40000; сузьте --arch-component или разделите задание'
CELLS=21 FAILURES=0 STABS=12 ZHIVYH=0
RED budget-large: rc=1 stderr='ОТКАЗ: режь задачу: 93024 > 40000'; named refusal missing, first cause/recommendation missing, budget/component missing
RED budget-utf8: rc=1 stderr='ОТКАЗ: режь задачу: 45569 > 40000'; named refusal missing, first cause/recommendation missing, budget/component missing
CELLS=21 FAILURES=12 STABS=0 ZHIVYH=0
```

Имена остальных красных `--repo .`: dependencies, lock-different,
lock-same-size, donor-lock-missing, pin-lock-missing, modules-missing,
stderr-first, stderr-second, stderr-empty, stderr-unicode.
Прочие клетки зелёные. Старый budget-large добавляет 91445 символов к
заголовкам и rules, а не создаёт exact 91445-байтный api.transport: это
проверка старого отказа, не предъявление новой успешной упаковки.
Такой клетки и новой реализации в ветви 2 задания намеренно нет.

`check_provodka.sh . contracts/203-dver-brifa-arhitektury.md` → rc 0
(пустой вывод); `check_sdacha.sh . contracts/203-dver-brifa-arhitektury.md --run`
→ rc 0; `pre_critic.sh --repo . contracts/203-dver-brifa-arhitektury.md` → rc 0.
Сырой вывод двух последних дверей:

```
СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=0)
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```

Это rc существующей формы, не свидетельство исполнения новой цели 20:02.
