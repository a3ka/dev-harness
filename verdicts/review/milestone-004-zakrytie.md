accept

# Ревью закрытия находок майлстоуна 004

Проверено на `2b9ed294a957c07c8964fdc8eebf112db88c1111` — закрывающем
коммите после моего `f86fa0cbcfaa1dcb6127e4ca23e6129ceffa1569`. Узкий предмет:
ровно две находки `milestone-004.md`; за границы предмета не выходил.

## Закрытые находки

1. **[Класс: красное не предъявлено / покрытие требования] Битые
   файл-правило и `AGENTS.md` более не исключаются до `wc`.** В
   `scripts/check_ceilings.sh` правило собирается предикатом «обычный файл
   ИЛИ ссылка», поэтому битая ссылка доходит до замера и создаёт именованный
   отказ. Мои две самостоятельные пробы круга 1 дали `rc=1`, а не прежний
   `rc=0`.

2. **[Класс: проверка не независима от реализации] Объединённая фикстура
   больше не маскирует ветвь правил.** `case_razmer_nechitaem.sh` сначала
   даёт зелёный контроль, затем вызывает барьер с битой персоной, битым
   правилом `.omp/rules/*.md` и битым `AGENTS.md` по отдельности. Мои три
   изолированные дерева (в каждом сломана ровно одна ветвь, остальные
   применимые файлы обычные) дали самостоятельный `rc=1`. История по-прежнему
   называет автором барьера и фикстуры `architect`, но наблюдаемое основание
   прежней находки — маскировка одной ветви другой — устранено независимыми от
   фикстуры прогонами этого ревью.

Блокирующих находок: 0. Других классов находок в узком круге не обнаружено.

## Сырые самостоятельные красные пробы

Все пять деревьев созданы только в `tmp/reviewer-004-zakrytie/`; ниже
буквальный вывод вызовов и их коды.

```text
$ bash scripts/check_ceilings.sh tmp/reviewer-004-zakrytie/probe-rule
  ok   персоны: 1 файл(ов), потолок 51200 байт
scripts/check_ceilings.sh: line 58: tmp/reviewer-004-zakrytie/probe-rule/.omp/rules/broken.md: No such file or directory
  FAIL файл-правило tmp/reviewer-004-zakrytie/probe-rule/.omp/rules/broken.md: размер нечитаем — битая ссылка или права
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   contracts/*.md отсутствуют — раздел требований неприменим
превышений/нарушений: 1
[exit=1]

$ bash scripts/check_ceilings.sh tmp/reviewer-004-zakrytie/probe-agents
  ok   персоны: 1 файл(ов), потолок 51200 байт
scripts/check_ceilings.sh: line 58: tmp/reviewer-004-zakrytie/probe-agents/AGENTS.md: No such file or directory
  FAIL файл-правило tmp/reviewer-004-zakrytie/probe-agents/AGENTS.md: размер нечитаем — битая ссылка или права
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   contracts/*.md отсутствуют — раздел требований неприменим
превышений/нарушений: 1
[exit=1]

$ bash scripts/check_ceilings.sh tmp/reviewer-004-zakrytie/fixture-persona
scripts/check_ceilings.sh: line 41: tmp/reviewer-004-zakrytie/fixture-persona/roles/broken.md: No such file or directory
  FAIL персона tmp/reviewer-004-zakrytie/fixture-persona/roles/broken.md: размер нечитаем — битая ссылка или права
  ok   персоны: 1 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   contracts/*.md отсутствуют — раздел требований неприменим
превышений/нарушений: 1
[exit=1]

$ bash scripts/check_ceilings.sh tmp/reviewer-004-zakrytie/fixture-rule
  ok   персоны: 1 файл(ов), потолок 51200 байт
scripts/check_ceilings.sh: line 58: tmp/reviewer-004-zakrytie/fixture-rule/.omp/rules/broken.md: No such file or directory
  FAIL файл-правило tmp/reviewer-004-zakrytie/fixture-rule/.omp/rules/broken.md: размер нечитаем — битая ссылка или права
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   contracts/*.md отсутствуют — раздел требований неприменим
превышений/нарушений: 1
[exit=1]

$ bash scripts/check_ceilings.sh tmp/reviewer-004-zakrytie/fixture-agents
  ok   персоны: 1 файл(ов), потолок 51200 байт
scripts/check_ceilings.sh: line 58: tmp/reviewer-004-zakrytie/fixture-agents/AGENTS.md: No such file or directory
  FAIL файл-правило tmp/reviewer-004-zakrytie/fixture-agents/AGENTS.md: размер нечитаем — битая ссылка или права
  ok   правила: 2 файл(ов), потолок 30720 байт
  ok   contracts/*.md отсутствуют — раздел требований неприменим
превышений/нарушений: 1
[exit=1]
```

## Сырая приёмка и независимый счёт

```text
$ npm run check:ceilings
npm notice run dev-harness@0.0.0 check:ceilings
npm notice run bash scripts/check_ceilings.sh
  ok   персоны: 7 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 4 черновик(ов) судится, замороженные — по тегам
потолки в порядке
[exit=0]

$ npm run check:antiplacebo
  ok   check_ceilings/case_razmer_nechitaem.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «размер нечитаем»
барьеров: 20 · фикстур: 138 · предъявлено красным повторным прогоном: 138
[exit=0]

$ node tmp/reviewer-004-zakrytie/count_barriers.mjs
barriers=20
[exit=0]

$ git ls-files 'fixtures/*/case_*.sh' | wc -l
138
[exit=0]

$ npm run check:ci-parity
workflow-команд: 16 · скриптов в приёмке: 24 · объявленных исключений: 8 · расхождений: 0
[exit=0]

$ npm run check:zones
  ok   contracts/004-potolki-dokumentov.md — зона: architect → fixtures/check_ceilings/  004
  ok   contracts/004-potolki-dokumentov.md — зона: architect → scripts/check_ceilings.sh  004
замороженных контрактов: 4 · объявленных авторов: 2 · коммитов в диапазонах: 113 · проверено по зонам: 70
[exit=0]
```

Числа `20/138/138` не приняты пересказом: независимый счётчик в `tmp/`
разобрал первые непрерывные блоки комментариев всех файлов `scripts/` и нашёл
20 шапок «Коды возврата:»; отдельный `git ls-files … | wc -l` дал 138
`case_*.sh`. Третье число (`138` повторных красных) предъявлено собственным
выводом `check:antiplacebo`; его частный случай по исправленной фикстуре
показан буквально выше.

## Семь вопросов ревьюера

1. **Область правки — пройдена.** `git diff --name-status f86fa0c..2b9ed29`
   напечатал только `M fixtures/check_ceilings/case_razmer_nechitaem.sh` и
   `M scripts/check_ceilings.sh` (статистика: 2 файла, `+20/-7`). Это ровно
   барьер и фикстура закрываемых находок.
2. **Сырой вывод — пройден.** Коды всех пяти самостоятельных красных проб и
   всех четырёх предписанных приёмок приведены выше.
3. **Проверка не переписана под реализацию — пройдена.** Закрывающий коммит
   действительно меняет барьер и фикстуру одним автором (`architect`), что
   проверено историей. Поэтому вывод фикстуры не принят на слово: изолированные
   пробы ревьюера по каждой из трёх ветвей независимо подтвердили нужный
   отказ и имя сломанного входа.
4. **Красное предъявлено — пройдено.** Две прежние пропущенные ветви и все
   три ветви разделённой фикстуры дали `rc=1`; `check:antiplacebo` повторно
   предъявил красное для `case_razmer_nechitaem.sh`.
5. **Атомарность — пройдена.** `2b9ed29` — один коммит с предметной ссылкой
   на `f86fa0c`, двумя файлами закрытия и без смешанной задачи.
6. **Норма не тронута молча — пройдена.** `frozen/contracts/004/1^{}`
   разрешился в `30f0a5e`; `git diff --exit-code frozen/contracts/004/1 --
   contracts/004-potolki-dokumentov.md` завершился `0`. Также diff от
   `f86fa0c` до предмета по `AGENTS.md ROADMAP.md contracts` пуст.
7. **Заявленное равно сделанному — пройдено.** Независимые меры дали 20
   барьеров и 138 фикстур; вывод `check:antiplacebo` предъявил
   `20/138/138`, а три ручные красные ветви не зависят от его выбора
   кандидата на повторный прогон.

Теги не создавались. Чужие код и документы не правились.
