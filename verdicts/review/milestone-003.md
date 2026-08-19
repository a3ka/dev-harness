FAIL

# Ревью пачки майлстоуна 003

Предмет: исполнение `frozen/contracts/003/5`, диапазон `028c06f..e70cade`
(включая accept-вердикт адверсария `e70cade`; его файл —
`verdicts/adversary/milestone-003-zakrytie-4.md`). Проверка проведена на HEAD
`e70cade31e64a58bf8a81f46a2f30313ce8d718f`.

## Находка

- **[ЗАЯВЛЕННОЕ ≠ СДЕЛАННОМУ · БЛОКИРУЮЩАЯ]** В замороженном контракте v5,
  критерий 2, для `roles/architect.md` и `roles/implementer.md` требуются ровно
  шесть поимённых строк: путь `skills/<имя>/SKILL.md` и ведущее английское слово
  на одной строке для четырёх пар архитектора и двух пар исполнителя. Независимая
  проверка по исходникам ролей не нашла ни одного вхождения `skills/` и ни одного
  имени из множества `grilling`, `writing-for-agents`, `tdd`,
  `diagnosing-bugs`. Фактическое число обязательных указателей — **0**, а не 6.
  Это именно назначенный контрактом `cognitive-only` ловец ревьюера; барьер
  `check_skills.sh` его не заменяет. Контракт на HEAD идентичен замороженному
  блобу, поэтому это не расхождение рабочей копии.

  Сырой вывод независимой текстовой меры:

  ```text
  $ grep /skills/ в roles/architect.md и roles/implementer.md
  No matches found

  $ grep /grilling|writing-for-agents|diagnosing-bugs|tdd/ в тех же файлах
  No matches found
  ```

  Эта находка сама достаточна для отказа. Чужой код не правился.

## Семь вопросов ревьюера

### 1. Область правки — пройдена

Проверен именованный диапазон. В нём 50 путей: предметные `skills/` и
`.agents/skills/`, проводка (`package.json`, `scripts/overlay.sh`, `config/`),
архитекторские барьеры и фикстуры, а также контрактные итерации и судейские
вердикты. Каждый путь относится к предмету или к его формальному кругу; выход за
объявленную область не найден. Суд зон также прошёл (его собственный счёт дан
ниже). Вердикт этого ревью добавлен отдельно и не меняет предмет.

```text
$ git diff --name-status 028c06f..HEAD
A .agents/skills/... (11 файлов зеркала)
M HANDOFF.md
M NABLIUDENIA.md
M config/ci_parity_exceptions.txt
M contracts/003-skills-metta-adaptacija.md
M fixtures/check_skills/... (12 файлов)
M/A fixtures/check_zones/... (4 файла)
M package.json
M scripts/check_skills.sh
M scripts/check_zones.sh
M scripts/overlay.sh
A verdicts/adversary/... (3 файла)
A verdicts/arbitration/... (2 файла)
A verdicts/critic/... (9 файлов)
rc=0
```

### 2. Сырой вывод вместо пересказа — пройдена с указанной диагностикой

Все шесть запрошенных приёмочных команд исполнены ниже с их кодами возврата.
`check:antiplacebo` вернул 0, но его сырой stderr содержит две одинаковые строки
`find: ... Permission denied` из старой временной пробы
`tmp/adversary-003-round4/probe-mirror-permissions/`; они не были скрыты и не
изменили код этой команды. Это не основание подменять её зелёный результат
пересказом.

```text
$ bash scripts/check_skills.sh
барьер зелёный: 8 ветвей пройдены
rc=0

$ bash scripts/check_skills.sh --live
барьер зелёный: 8 ветвей пройдены
rc=0

$ npm run check:antiplacebo
find: ‘./tmp/adversary-003-round4/probe-mirror-permissions/.agents/skills/tdd’: Permission denied
find: ‘./tmp/adversary-003-round4/probe-mirror-permissions/.agents/skills/tdd’: Permission denied
барьеров: 19 · фикстур: 130 · предъявлено красным повторным прогоном: 130
rc=0

$ npm run check:ci-parity
workflow-команд: 15 · скриптов в приёмке: 23 · объявленных исключений: 8 · расхождений: 0
rc=0

$ npm run check:zones
замороженных контрактов: 3 · объявленных авторов: 2 · коммитов в диапазонах: 92 · проверено по зонам: 59
rc=0

$ npm run check:contract-frozen
планов и контрактов на HEAD: 7 · черновиков: 3 · заморожено: 4 · реестр: full
rc=0

$ npm run check:gen
харнес соответствует roles/ (7 ролей)
rc=0
```

### 3. Проверка не переписана автором реализации — пройдена

История `fixtures/check_skills/` содержит только автора `architect`; первый
коммит фикстур — `f46e61b5` архитектора — предшествует первому предметному
коммиту `054088a9` implementer. История `fixtures/check_zones/` также содержит
только архитектора. Implementer в этом круге изменял только зеркало и проводку
(`bc58a03`, `8d4b351`), а не фикстуры.

```text
$ git log --format='%H\t%an\t%s' -- fixtures/check_skills/
f46e61b... architect 003 Q8-C: красные фикстуры восьми ветвей (а)-(з) — ДО раздачи
04e68e7... architect 003: скилы + барьер check_skills.sh — от исполнителя ...
bec61d6... architect 003: барьер check_skills, четыре скила, восемь фикстур ...
028c06f... architect 003: три пробоя закрытия ...
e646540... architect 003 (реестровая v4): check_skills ...
b5e7f55... architect 003: два обхода круга 4 закрыты ...

$ git log --format='%H\t%an\t%s' -- fixtures/check_zones/
1ee74c0... architect Шаг 8: барьер зон + пять фикстур ...
...
42bb7ba... architect СПАСЕНО в check_zones: поимённые коммиты вне суда зон ...
rc=0
```

### 4. Красное предъявлено — пройдена

Помимо полного повторного прогона 130 фикстур из вопроса 2, красное новых
барьеров предъявлено отдельными, не изменяющими основной репозиторий пробами в
`tmp/`.

```text
$ bash scripts/check_skills.sh --live tmp/reviewer-003-red-skills
  ok   ветвь (в): hash контракта начинается с 9c9f36c
ОТКАЗ: предмет исчез: skills/ отсутствует, а история коммитов по skills/ есть — это порченный чекаут предмета, не изолированный контракт
rc=1

$ bash scripts/check_skills.sh tmp/reviewer-003-red-hidden
...
ОТКАЗ: каталог вне объявленного множества: найдено «diagnosing-bugs grilling .reviewer-hidden tdd writing-for-agents», ожидается «diagnosing-bugs grilling tdd writing-for-agents»; лишний: .reviewer-hidden
rc=1

$ WORK="$PWD/tmp/reviewer-003-red-zones" BARRIER="$PWD/scripts/check_zones.sh" bash fixtures/check_zones/case_spaseno_ne_nazvannyj_hash.sh
  ok   contracts/001-x.md — зона: agent-x → scripts/  001
  ok   контракт 001: коммит 8437741a (agent-x) — СПАСЕНО, из суда зон выведен
...
  FAIL коммит вне зоны: agent-x 0565b4bf plans/vtoroe.md — зона контракта 001: scripts/
...
rc=1
```

### 5. Атомарность — пройдена

Ключевые изменения разделены предметно: `bc58a03` — только зеркало, `8d4b351`
— только проводка, `42bb7ba` — грамматика СПАСЕНО с её фикстурами, `b5e7f55` —
два варианта одного класса обхода (исчезновение/скрытый состав) с барьером и
тремя соответствующими фикстурами. Контрактные итерации, критические и
адверсарские вердикты лежат отдельными коммитами с предметными сообщениями.

```text
$ git show --stat --oneline 42bb7ba bc58a03 8d4b351 b5e7f55
42bb7ba ... 5 files changed, 165 insertions(+), 2 deletions(-)
bc58a03 ... 11 files changed, 462 insertions(+)
8d4b351 ... 3 files changed, 3 insertions(+), 23 deletions(-)
b5e7f55 ... 4 files changed, 89 insertions(+), 14 deletions(-)
rc=0
```

### 6. Норма не тронута молча — пройдена

Контракт менялся только в зарегистрированных итерациях v3–v5 с отдельными
вердиктами критика; текущий текст побайтно совпадает с замороженным v5.
`09b2e6af` явно назван в строке СПАСЕНО, Н-33 описывает гонку индекса; Н-35
отдельно зафиксирован в `NABLIUDENIA.md` как кандидат следующей пачки, а тег v5
аннотирован и содержит причину и accept критика. Н-31/Н-34 и остаточный риск
совместной подмены бинаря и пина также прямо записаны в контракте и
`NABLIUDENIA.md`; они не скрыты.

```text
$ git diff --name-only frozen/contracts/003/5 HEAD -- contracts/003-skills-metta-adaptacija.md

$ git cat-file -t frozen/contracts/003/5
tag
$ git for-each-ref --format='%(refname:short)\t%(objecttype)\t%(subject)' refs/tags/frozen/contracts/003/5
frozen/contracts/003/5  tag  реестровая v5: СПАСЕНО дополнен хешом гонки индекса 09b2e6af (Н-33, делегирование владельца 2026-08-19); accept критика 56e1f66
rc=0
```

### 7. Заявленное равно сделанному — не пройдена

Независимая мера состава подтверждает четыре канонических каталога и полное
совпадение зеркала, но та же независимая вычитка ролей выявила блокирующее
расхождение, указанное в начале вердикта.

```text
$ find skills -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
diagnosing-bugs
grilling
tdd
writing-for-agents

$ find .agents/skills -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
diagnosing-bugs
grilling
tdd
writing-for-agents

$ diff -r --brief skills .agents/skills

$ поиск skills/ в roles/architect.md и roles/implementer.md
No matches found
```

Итог: все механические приёмочные команды зелёные и новые красные пробы честно
красные, но обязательная часть замороженного контракта о шести указателях ролей
вообще не исполнена. Принять пачку нельзя.
