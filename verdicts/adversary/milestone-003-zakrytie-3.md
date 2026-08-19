FAIL

# Круг 4: исполнение реестровой v4

Замер выполнен на `8d4b35136d68e2e6675ffca475ada48b41c8da34` против
`frozen/contracts/003/4:contracts/003-skills-metta-adaptacija.md`. Все порчи были
построены в изолированных клонах `tmp/adversary-003-round4/`; основной предмет,
барьер и фикстуры не менялись. `check:zones` намеренно не запускался: известный
красный Н-33 вне предмета этого круга.

## Положительные контроли

```text
$ bash scripts/check_skills.sh
rc=0
…
  ok   зеркало .agents/skills совпадает с skills/ (полное дерево каждого скила)
  ok   фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect
барьер зелёный: 8 ветвей пройдены

$ sha256sum "$(readlink -f "$(command -v omp)")"
rc=0
4fe564b23482cd627671a2417842498c97b2f72b5f8a3a4efb8094e623df7a33  /home/aka/.local/bin/omp

$ bash scripts/check_skills.sh --live
rc=0
…
  ok   скил «grilling» — коррелированная пара событий: skill://grilling резолвится в проектное зеркало
  ok   скил «writing-for-agents» — коррелированная пара событий: skill://writing-for-agents резолвится в проектное зеркало
  ok   скил «tdd» — коррелированная пара событий: skill://tdd резолвится в проектное зеркало
  ok   скил «diagnosing-bugs» — коррелированная пара событий: skill://diagnosing-bugs резолвится в проектное зеркало
  ok   зеркало .agents/skills совпадает с skills/ (полное дерево каждого скила)
барьер зелёный: 8 ветвей пройдены

$ diff -r skills .agents/skills
rc=0
<пустой вывод>
```

Следовательно, честная реализация и настоящая запиненная живая проба работоспособны;
отказы ниже не являются вечно-красным барьером.

## Два проходящих обмана

### 1. Пустое дерево выключает шесть ветвей, включая live

В клоне `probe-empty-tree` удалены **только** `skills/` и `.agents/skills/`.
Это не изолированный контрактный каталог, а порченный чекаут предмета: история,
контракт, барьер и фикстуры остались на месте.

```text
$ bash scripts/check_skills.sh
rc=0
  ok   ветвь (в): hash контракта начинается с 9c9f36c
  ok   skills/ отсутствует — ветви (а)-(г), (е), (ж) пропущены
  ok   фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect
барьер зелёный: 8 ветвей пройдены

$ bash scripts/check_skills.sh --live
rc=0
  ok   ветвь (в): hash контракта начинается с 9c9f36c
  ok   skills/ отсутствует — ветви (а)-(г), (е), (ж) пропущены
  ok   фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect
барьер зелёный: 8 ветвей пройдены
```

Это нарушает критерий 1 замороженного контракта: `skills/` обязан содержать ровно
четыре каталога, а зеркало должно существовать и быть полным. Условие
`[ ! -d "$SKILLS_DIR" ]` в `scripts/check_skills.sh` объявляет исчезновение всего
предмета неприменимостью и обходом выключает также заявленную `--live` ветвь. В
контрактном чекауте это должен быть код 1; отдельный режим проверки одного
изолированного контракта не может молча принимать порченный чекаут предмета.

### 2. Скрытый корневой дрейф не входит ни в состав, ни в полный diff

В клоне `probe-hidden-drift` создан только один пустой каталог
`skills/.not-mirrored`; в `.agents/skills/` его нет. Следовательно, полные деревья
источника и зеркала различны, а `skills/` содержит пятый каталог.

```text
$ bash scripts/check_skills.sh
rc=0
…
  ok   состав skills/ точно совпадает с объявленным множеством
…
  ok   зеркало .agents/skills совпадает с skills/ (полное дерево каждого скила)
  ok   фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect
барьер зелёный: 8 ветвей пройдены
```

Дополнительный контроль `probe-hidden-rogue` создал одинаковый пустой
`/.rogue` в `skills/` и `.agents/skills/`; даже живой барьер его принял:

```text
$ bash scripts/check_skills.sh --live
rc=0
…
  ok   скил «diagnosing-bugs» — коррелированная пара событий: skill://diagnosing-bugs резолвится в проектное зеркало
  ok   состав skills/ точно совпадает с объявленным множеством
  ok   зеркало .agents/skills совпадает с skills/ (полное дерево каждого скила)
  ok   фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect
барьер зелёный: 8 ветвей пройдены
```

Причина: оба состава строятся `ls`, который не перечисляет имена, начинающиеся с
точки, а `diff -r` запускается лишь для четырёх ожидаемых подкаталогов. Поэтому
скрытые корневые файлы и каталоги не проверяются вообще; во втором варианте даже
разное полное дерево проходит. Это прямо пробивает требования «РОВНО каталоги» и
«полное дерево» ветви (д).

## Закрытые прежние пробы и дополнительные отрицательные контроли

Все следующие заглушки созданы в отдельных клонах. Там, где нужно проверить
пост-исполнение оракула, пин клона был перепривязан ровно на sha256 заглушки;
это не изменяло основной пин.

```text
# 127-omp: заглушка печатает «подставной omp недоступен» и выходит 127
$ PATH="$PWD/bin:$PATH" bash scripts/check_skills.sh --live
rc=1
ОТКАЗ: скил «grilling» не обнаружен omp: вызов завершился кодом 127, поток «подставной omp недоступен»

# Инструмент отсутствует из PATH
$ PATH=/usr/bin:/bin bash scripts/check_skills.sh --live
rc=2
NOT_IMPLEMENTED: нет omp в PATH — живую пробу нечем провести (в CI — объявленное исключение паритета)

# Чужой omp при исходном пине
$ PATH="$PWD/bin:$PATH" bash scripts/check_skills.sh --live
rc=1
ОТКАЗ: omp не совпадает с пином: fb99eae951f1adc14d1a4a9a186c21930db2786b3208c94c7d9af382bd1048e5 против 4fe564b23482cd627671a2417842498c97b2f72b5f8a3a4efb8094e623df7a33 — ответу живой пробы нельзя верить (подлинность бинаря держит check:overlay)

# Эхо всех argv, rc 0, перепривязанный пин
$ PATH="$PWD/bin:$PATH" bash scripts/check_skills.sh --live
rc=1
ОТКАЗ: скил «grilling» не обнаружен omp: в потоке нет вызова read с args.path = skill://grilling — резолв не предъявлен

# «Чтение» обычного .agents/skills/grilling/SKILL.md, с правильной строкой в end
$ PATH="$PWD/bin:$PATH" bash scripts/check_skills.sh --live
rc=1
ОТКАЗ: скил «grilling» не обнаружен omp: в потоке нет вызова read с args.path = skill://grilling — резолв не предъявлен

# Константная шапка grilling, но формально коррелированные start/end для каждого имени
$ PATH="$PWD/bin:$PATH" bash scripts/check_skills.sh --live
rc=1
ОТКАЗ: скил «writing-for-agents» не обнаружен omp: результат вызова не содержит дословно строку шапки «# Адаптация: грамматика документов для агентов.»

# Удалён проектный grilling, HOME содержит одноимённый настоящий файл
$ HOME=/home/aka/Documents/dev-harness/tmp/adversary-003-round4/home bash scripts/check_skills.sh --live
rc=1
ОТКАЗ: скил «grilling» не обнаружен omp: resolvedPath «/home/aka/Documents/dev-harness/tmp/adversary-003-round4/home/.agents/skills/grilling/SKILL.md» — не проектный /home/aka/Documents/dev-harness/tmp/adversary-003-round4/probe-home/.agents/skills/grilling/SKILL.md (одноимённый скил из HOME или чтение обычного файла)

# SKILL.md зеркала — символическая ссылка на skills/grilling/SKILL.md
$ bash scripts/check_skills.sh --live
rc=1
ОТКАЗ: скил «grilling» не обнаружен omp: resolvedPath «…/probe-symlink/.agents/skills/grilling/SKILL.md» — не проектный …/probe-symlink/.agents/skills/grilling/SKILL.md (одноимённый скил из HOME или чтение обычного файла)

# Удалён вложенный .agents/skills/tdd/tests.md
$ bash scripts/check_skills.sh
rc=1
ОТКАЗ: зеркало не совпадает: дерево tdd в .agents/skills отличается от skills/:
Only in …/skills/tdd: tests.md

# В .agents/skills/tdd/tests.md добавлено «искажение»
$ bash scripts/check_skills.sh
rc=1
ОТКАЗ: зеркало не совпадает: дерево tdd в .agents/skills отличается от skills/:
Files …/skills/tdd/tests.md and …/.agents/skills/tdd/tests.md differ

# chmod 000 .agents/skills/tdd
$ bash scripts/check_skills.sh
rc=1
ОТКАЗ: зеркало не совпадает: дерево tdd в .agents/skills отличается от skills/:
diff: …/.agents/skills/tdd: Permission denied

# Поздний комментарий к fixture и commit --author implementer
$ bash scripts/check_skills.sh
rc=1
ОТКАЗ: полнота фикстур: коммиты по fixtures/check_skills/ есть от «implementer»— а не от architect (Q8-C)
```

Отдельно проверен объявленный `cognitive-only` остаток: заглушка **не читает
никаких** скилов, а только по argv подставляет жёстко записанные четыре строки
шапки, четыре `skill://` и проектные `resolvedPath`; пин её изолированного клона
переписан на sha256 заглушки. Она ожидаемо проходит:

```text
$ PATH="$PWD/bin:$PATH" bash scripts/check_skills.sh --live
rc=0
  ok   скил «grilling» — коррелированная пара событий: skill://grilling резолвится в проектное зеркало
  ok   скил «writing-for-agents» — коррелированная пара событий: skill://writing-for-agents резолвится в проектное зеркало
  ok   скил «tdd» — коррелированная пара событий: skill://tdd резолвится в проектное зеркало
  ok   скил «diagnosing-bugs» — коррелированная пара событий: skill://diagnosing-bugs резолвится в проектное зеркало
барьер зелёный: 8 ветвей пройдены
```

Это не отдельная находка: именно совместная подмена бинаря и пина объявлена
контрактом cognitive-only остатком с названными ловцами. В отличие от неё, два
проходящих обмана выше не подменяют ни бинарь, ни пин и не входят в объявленное
исключение.

## Решение

Не принимать. Положительные контроли и все перечисленные закрытия прежних
проб зелёные/красные ровно по назначению, но барьер принимает (1) полное
исчезновение предмета и (2) скрытый корневой пятый каталог, в том числе
несинхронизированный с зеркалом. Исправление предмета и повторный круг — за
автором.
