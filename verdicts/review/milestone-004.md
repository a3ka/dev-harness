FAIL

# Ревью пачки майлстоуна 004

Проверено на `82860c545bb9c618c12a5a640757b754019d78a5`. Предмет —
исполнение `frozen/contracts/004/1` после финального accept адверсария
`82860c5`; граница собственно исполнения — от заморозки `30f0a5e` до
`850b29d`. Вердикт **FAIL**: барьер молча исключает битый файл-правило из
области и возвращает успех, хотя контракт требует отказа для нечитаемого
размера.

## Находки

1. **[Класс: красное не предъявлено / покрытие требования] Битый
   файл-правило не вызывает отказ.** В `scripts/check_ceilings.sh` правила
   собираются через `[ -f "$f" ]`; битая символическая ссылка этому предикату
   не удовлетворяет и исчезает до `wc -c`. Фикстура
   `case_razmer_nechitaem.sh` добавляет одновременно битую персону и битое
   правило, поэтому её «красное» получается от персоны и не доказывает вторую
   ветвь, хотя комментарий фикстуры заявляет «Обе ветви». Независимая проба
   ниже содержит только обычную персону и битое правило: барьер сообщил
   «файлы-правила отсутствуют» и завершился `0`. Та же поломка воспроизводится
   для битого `AGENTS.md`. Это противоречит предмету контракта: нечитаемый
   размер файла-правила обязан быть отказом, а не неприменимой областью.

2. **[Класс: проверка не независима от реализации] История не даёт
   хронологического разделения барьера и его фикстур.** `517ec13` одним
   коммитом автора `architect` добавил `scripts/check_ceilings.sh` и все семь
   исходных `case_*.sh`; тот же автор одновременно менял барьер и шесть
   фикстур в `a9d6816`, а в `d74e802` добавил восьмую фикстуру. Сам по себе
   общий автор не был бы достаточным доказательством подгонки, но находка 1
   показывает её наблюдаемый результат: объединённая фикстура отчитывается
   красным за одну ветвь, оставляя другую зелёной. Независимого доработчика
   проверки до реализации в истории нет.

Блокирующие находки: 2. Других классов находок не обнаружено.

## Сырой вывод приёмки

Все строки в блоках — буквальный вывод прогонов; `…` в длинном
`check:antiplacebo` означает опущенные однотипные успешные строки, а не
подмену его итоговой строки и кода.

```text
$ bash scripts/check_ceilings.sh
  ok   персоны: 7 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 4 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[exit=0]

$ npm run check:ceilings
npm notice run dev-harness@0.0.0 check:ceilings
npm notice run bash scripts/check_ceilings.sh
  ok   персоны: 7 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 4 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[exit=0]

$ npm run check:antiplacebo
npm notice run dev-harness@0.0.0 check:antiplacebo
npm notice run bash scripts/verify_antiplacebo.sh
  ok   check_ceilings/case_dvoinik_zamorozhennosti.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «(132 байт)»
  ok   check_ceilings/case_kirillica_schetchik.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «52000 байт»
  ok   check_ceilings/case_persona_granica.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «51201 байт»
  ok   check_ceilings/case_pravilo_agents_granica.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «30721 байт»
  ok   check_ceilings/case_pravilo_omp_rules_granica.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «30721 байт»
  ok   check_ceilings/case_razdel_grammatika.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «(120 байт): нет раздела»
  ok   check_ceilings/case_razmer_nechitaem.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «размер нечитаем»
…
барьеров: 20 · фикстур: 138 · предъявлено красным повторным прогоном: 138
[exit=0]

$ npm run check:ci-parity
npm notice run dev-harness@0.0.0 check:ci-parity
npm notice run bash scripts/verify_ci_parity.sh
workflow-команд: 16 · скриптов в приёмке: 24 · объявленных исключений: 8 · расхождений: 0
[exit=0]

$ npm run check:zones
npm notice run dev-harness@0.0.0 check:zones
npm notice run bash scripts/check_zones.sh
  ok   contracts/004-potolki-dokumentov.md — зона: architect → .agents/skills/writing-for-agents/  004
  ok   contracts/004-potolki-dokumentov.md — зона: architect → contracts/004-potolki-dokumentov.md  004
  ok   contracts/004-potolki-dokumentov.md — зона: architect → fixtures/check_ceilings/  004
  ok   contracts/004-potolki-dokumentov.md — зона: architect → HANDOFF.md  004
  ok   contracts/004-potolki-dokumentov.md — зона: architect → NABLIUDENIA.md  004
  ok   contracts/004-potolki-dokumentov.md — зона: architect → scripts/check_ceilings.sh  004
  ok   contracts/004-potolki-dokumentov.md — зона: architect → skills/writing-for-agents/  004
  ok   contracts/004-potolki-dokumentov.md — зона: implementer → .github/workflows/ci.yml  004
  ok   contracts/004-potolki-dokumentov.md — зона: implementer → package.json  004

замороженных контрактов: 4 · объявленных авторов: 2 · коммитов в диапазонах: 111 · проверено по зонам: 69
[exit=0]

$ npm run check:contract-frozen
npm notice run dev-harness@0.0.0 check:contract-frozen
npm notice run bash scripts/check_contract_frozen.sh
  ok   contracts/004-potolki-dokumentov.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают

планов и контрактов на HEAD: 8 · черновиков: 3 · заморожено: 5 · реестр: full
[exit=0]

$ npm run check:gen
npm notice run dev-harness@0.0.0 check:gen
npm notice run node scripts/gen-harness.ts --check
харнес соответствует roles/ (7 ролей)
[exit=0]

$ npm run check:skills
npm notice run dev-harness@0.0.0 check:skills
npm notice run bash scripts/check_skills.sh
  ok   ветвь (в): hash контракта начинается с 9c9f36c
  ok   зеркало .agents/skills совпадает с skills/ (полное дерево, включая корень)
  ok   фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect
барьер зелёный: 8 ветвей пройдены
[exit=0]

$ bash scripts/check_skills.sh --live
  ok   скил «writing-for-agents» — коррелированная пара событий: skill://writing-for-agents резолвится в проектное зеркало
  ok   зеркало .agents/skills совпадает с skills/ (полное дерево, включая корень)
  ok   фикстуры полны: 8 на родителе, все авторы коммитов по fixtures/ — architect
барьер зелёный: 8 ветвей пройдены
[exit=0]

$ npm run check:charter
npm notice run dev-harness@0.0.0 check:charter
npm notice run bash scripts/check_charter.sh
  ok   contracts/004-potolki-dokumentov.md — уставной с frozen/contracts/004/1, коммитов в диапазоне 8, изменений без разрешения нет

уставных документов: 7 · изменений в них: 23 · с разрешения: 23
[exit=0]

$ npm run check:decisions
npm notice run dev-harness@0.0.0 check:decisions
npm notice run bash scripts/check_decisions.sh

записей: 7 · нарушений: 0
  ok   реестр решений полон, поля в грамматике, основания разрешимы
[exit=0]

$ npm run check:approval
npm notice run dev-harness@0.0.0 check:approval
npm notice run bash scripts/check_approval.sh

политика: always-ask · нарушений: 0
  ok   always-ask объявлен в конфиге, запуск его наследует, флаги отмены политики отвергнуты
[exit=0]
```

Зелёные штатные прогоны не отменяют находку: они не содержат битого
файла-правила. Ниже — самостоятельная красная проба ровно пропущенной ветви.

```text
$ bash scripts/check_ceilings.sh tmp/reviewer-004-broken-rule
  ok   персоны: 1 файл(ов), потолок 51200 байт
  ok   файлы-правила отсутствуют — потолок правил неприменим
  ok   contracts/*.md отсутствуют — раздел требований неприменим
потолки в порядке
[exit=0]

$ bash scripts/check_ceilings.sh tmp/reviewer-004-broken-agents
  ok   персоны: 1 файл(ов), потолок 51200 байт
  ok   файлы-правила отсутствуют — потолок правил неприменим
  ok   contracts/*.md отсутствуют — раздел требований неприменим
потолки в порядке
[exit=0]
```

## Семь вопросов ревьюера

1. **Область правки — пройдена.** `frozen/contracts/004/1^{}` разрешается в
   `30f0a5e`; первый коммит после него — `517ec13`. Собственный
   `git log --name-status 517ec13^..850b29d` назвал только барьер,
   `fixtures/check_ceilings/`, обе копии скила, проводку `package.json` и CI,
   HANDOFF и судейские вердикты. Исполнитель `architect` менял только свою
   зону, `implementer` — только свою. `check:zones` выше также завершился
   `0`. Предыдущий диапазон `0f49a3b..30f0a5e` — разработка и суд контракта
   до его заморозки, не исполнение предмета.

2. **Сырой вывод — пройден формально, но не достаточен по существу.** Выше
   сохранены буквальные выводы и коды всех 11 запрошенных приёмочных команд.
   Они зелёные. Отдельная проба с кодом `0` там, где по контракту требуется
   `1`, опровергает доверие к зелёному пересказу барьера.

3. **Проверка не переписана под реализацию — не пройдена.** История предметных
   путей дословно: `517ec13 architect`, `a9d6816 architect`,
   `d74e802 architect`; она не содержит автора фикстур, отделённого от автора
   барьера. Совместная фикстура скрыла отказ одной из обеих заявленных ветвей;
   обстоятельства и воспроизведение перечислены в находках.

4. **Красное предъявлено — не пройдено полностью.** `check:antiplacebo`
   действительно предъявил красный `1` для именованной фикстуры нечитаемого
   размера, но не для каждой ветви, которую она заявляет. Моя проба с одним
   битым правилом и проба с одним битым `AGENTS.md` получили `0`; тем самым
   новый барьер не предъявлен красным против этой сломанной реализации.

5. **Атомарность — пройдена.** `517ec13` — единая поставка барьера, его
   фикстур и обязательного зеркала; `524f855` — только проводка; `a9d6816` —
   один ответ на четыре находки адверсария; `d74e802` — один заявленный
   недостающий красный случай; `850b29d` — только HANDOFF. Связанных задач,
   смешанных в одном коммите исполнения, не найдено.

6. **Норма не тронута молча — пройдена.** Собственный
   `git diff --name-status frozen/contracts/004/1^{}..850b29d -- AGENTS.md ROADMAP.md contracts`
   не напечатал путей и завершился `0`; `check:contract-frozen` подтвердил
   побайтное совпадение v1. Нормативный контракт после заморозки не менялся.

7. **Заявленное равно сделанному — не пройдено.** Независимая мера дала 8
   файлов `fixtures/check_ceilings/*.sh` (7 `case_*.sh` и `_gen.sh`), 7 ролей,
   4 `skills/*/SKILL.md`, 6 строк `skills/` в ролях и размеры ролей ниже; эти
   числа согласуются с заявленным составом. Но счёт не заменяет проверку
   поведения: самостоятельная мера незаявленного пути дала успех вместо
   требуемого отказа.

```text
$ git ls-files 'fixtures/check_ceilings/*.sh' | wc -l
8
[exit=0]

$ git ls-files 'fixtures/check_ceilings/case_*.sh' | wc -l
7
[exit=0]

$ git ls-files 'roles/*.md' | wc -l && git ls-files 'skills/*/SKILL.md' | wc -l
7
4
[exit=0]

$ git grep -n 'skills/' roles/
roles/architect.md:45:**Проектируешь решение владельца — сначала погриль его сам:** навык skills/grilling/SKILL.md — дерево решений, rounds по frontier, вопрос с рекомендованным ответом.
roles/architect.md:47:**Пишешь документ для агента — по грамматике указателей:** навык skills/writing-for-agents/SKILL.md — context pointer несёт одну нагрузку; две нагрузки — два указателя.
roles/architect.md:49:**Красная фикстура умирает от предмета, а не от себя:** навык skills/tdd/SKILL.md — tautological тест на барьер проверяет проверку, а не предмет.
roles/architect.md:51:**Диагноз затягивается контуром, а не вдумчивостью:** навык skills/diagnosing-bugs/SKILL.md — tight loop гипотеза → прогон; недетерминизм лечится частотой.
roles/implementer.md:69:**Вертикальные срезы, а не горизонтальные слои:** навык skills/tdd/SKILL.md — каждый срез ведёт red → green через один шов.
roles/implementer.md:71:**Трудный баг затягивается контуром, а не вдумчивостью:** навык skills/diagnosing-bugs/SKILL.md — tight loop красного контура, пока причина не названа прогоном.
[exit=0]

$ wc -c roles/*.md
 4970 roles/adversary.md
 6367 roles/arbiter.md
13168 roles/architect.md
16919 roles/critic.md
 6182 roles/implementer.md
 4820 roles/reviewer.md
 4998 roles/steward.md
57424 total
[exit=0]
```

## Итог

Пачка не принимается, пока барьер не будет судить битые файлы-правила
(`AGENTS.md` и `.omp/rules/*.md`) как нечитаемые и пока красное этой ветви не
будет предъявлено отдельной пробой, не маскируемой битой персоной. Теги не
создавались; чужой код и документы не правились.
