FAIL

# Ревьюер — контракт 012, полный финальный гейт, HEAD `e9ed95b3555cae21372a9d443dc58dac170988b0`

## Блокирующая находка 1 — предмет не реализован

**Класс: заявленное не равно сделанному / ложное разделение проверки барьера и приёмки предмета.**

Контракт требует, чтобы на дереве *после предмета* стали зелёными шесть ветвей
`lockdef techka pidrec izolcfg klon izolnorm`. На HEAD все шесть исполняемых
приёмок предмета красные. Это не дефект фикстур: `verify_antiplacebo` проверяет
40 фикстур `check_runner_hygiene` на эталонном `_ref_runner.sh` и обманках, а
не живой `scripts/verify_antiplacebo.sh`. Поэтому его 40/40 не доказывает
реализацию райдеров и норм в текущем дереве.

Сырой вывод исполнения живого предмета:

```text
$ bash scripts/check_runner_hygiene.sh . lockdef
ОТКАЗ ветвь (lockdef): второй default-прогон при живом владельце вышел кодом 0, а не 3 — default-скратч обязан быть ОБЩИМ для прогонов одного дерева: уникальный mktemp делает lock мёртвым по построению (райдер (i) контракта 012, замер шага 1: два параллельных прогона — оба RC=1 «дерево изменилось»). Хвост второго: ный прогон красный кодом 1 — «нет mark (check_a)»  барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
COMMAND_EXIT_RC=1

$ bash scripts/check_runner_hygiene.sh . techka
ОТКАЗ ветвь (techka): после завершившегося прогона под $TMPDIR остался новый путь (./verify_antiplacebo.mfP2zV ) — прогон, создавший default-скратч, обязан убирать его за собой на выходе (райдер (ii) контракта 012, замер владельца: 47→49 каталогов за два прогона). Хвост: ный прогон красный кодом 1 — «нет mark (check_a)»  барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1
COMMAND_EXIT_RC=1

$ bash scripts/check_runner_hygiene.sh . pidrec
ОТКАЗ ветвь (pidrec): lock живого-по-pid, но ЧУЖОГО-по-pgid владельца заблокировал прогон (rc=3) — pid перерождён, владелец мёртв: kill -0 без сверки pgid принимает посторонний процесс за владельца (райдер (iii) контракта 012). Хвост: �дёт над этим деревом (pid 1248424, корень /home/aka/Documents/dev-harness/tmp/check_runner_hygiene.EeGdIG/toy-pidrec) — второй прогон не запускается
COMMAND_EXIT_RC=1

$ bash scripts/check_runner_hygiene.sh . izolcfg
ОТКАЗ ветвь (izolcfg): .omp/config.yml не несёт вложенный ключ task.isolation.mode: btrfs — нет изоляции спавна: параллельные пачки контендятся за живое дерево (решение владельца 2026-08-26, шаг А; замер шага 1: два параллельных verify — оба RC=1, 279с/29с, воспроизведено дважды)
COMMAND_EXIT_RC=1

$ bash scripts/check_runner_hygiene.sh . klon
ОТКАЗ ветвь (klon): roles/architect.md не несёт пути ${TMPDIR}/dev-harness-<роль>/repo — клон роли обязан жить вне стерегомого дерева: ./tmp/<имя>/repo внутри дерева сам является мутацией стерегомого (решение владельца 2026-08-26, шаг А)
COMMAND_EXIT_RC=1

$ bash scripts/check_runner_hygiene.sh . izolnorm
ОТКАЗ ветвь (izolnorm): roles/orchestrator.md не несёт правила «isolated: true» на спавн параллельных пачек architect/implementer — без него пачки работают над живым деревом и контендятся (решение владельца 2026-08-26, шаг А)
COMMAND_EXIT_RC=1
```

Причина подтверждена независимым чтением живого раннера: его строки 252–256
по-прежнему создают пустой default через
`mktemp -d "${TMPDIR:-/tmp}/verify_antiplacebo.XXXXXX"`; строки 350–353
судят владельца только по pid; строки 371–373 не удаляют созданный default-
каталог. Исторический журнал `20fd5ad..HEAD` содержит **ноль** коммитов
implementer по `scripts/verify_antiplacebo.sh`, `.omp/config.yml`,
`roles/orchestrator.md` или предметной части `roles/architect.md`.

## Блокирующая находка 2 — область правки

**Класс: превышение объявленной ЗОНЫ / посторонние коммиты в предметном диапазоне.**

Проверен весь диапазон `frozen/contracts/012/1..HEAD`, а не только логика
`check_zones.sh`. Зоны 012 объявляют author identities architect, implementer,
critic, adversary и reviewer; зоны для `orchestrator` нет. Тем не менее в
диапазоне лежат три коммита `%an=orchestrator`, затрагивающие не объявленные
для 012 пути: `10cc9b0` (`NABLIUDENIA.md`), `e62bc2f`
(`.omp/agents/architect.md`, `NABLIUDENIA.md`, `roles/architect.md`) и `e9ed95b`
(`NABLIUDENIA.md`). В особенности `e62bc2f` меняет глобальную роль architect
по инциденту Н-59, а не А/В/райдеры контракта 012. Это самостоятельная работа,
которую текущий контракт не раздавал и которую нельзя молча положить в его
ревьюируемый диапазон. `check_zones.sh` этого не опровергает: его шапка прямо
исключает необъявленных авторов из суда.

Сырой исторический вывод:

```text
$ git log --format='%H\t%an\t%ae\t%s' --name-status frozen/contracts/012/1..HEAD
 e9ed95b3555cae21372a9d443dc58dac170988b0	orchestrator	orchestrator@dev-harness.local	NABLIUDENIA: Н-57 третий рецидив на frozen/contracts/012/2 - обход словом исчерпан, приоритет починки первым

M	NABLIUDENIA.md
a588a8e52567c13e3347bd15c3263e04b3751418	critic	critic@dev-harness.local	critic: восстановить contracts-012-v1.md (accept круга 2, уничтожен ошибочной перезаписью) + создать v2.md (узкий accept под верным именем) - исправление ошибки оркестратора в номере версии

M	verdicts/critic/contracts-012-v1.md
A	verdicts/critic/contracts-012-v2.md
f3c933f0e4aa7c792e474a97fc4f85ce7be229d5	critic	critic@dev-harness.local	critic: accept zone amendment for contract 012

M	verdicts/critic/contracts-012-v1.md
e62bc2fe4dbe0a425f4dbdfadccf44c793f259eb	orchestrator	orchestrator@dev-harness.local	NABLIUDENIA: Н-58/Н-59 - check_charter грамматика + architect самовольная строка; roles/architect.md усилена

M	.omp/agents/architect.md
M	NABLIUDENIA.md
M	roles/architect.md
913b6b4f820cebf402692c91c352b4091cdccb6b	architect	architect@dev-harness.local	012 v+1: ЗОНА architect += NABLIUDENIA_ARCHITECT.md; декларация четырёх дозаморозочных коммитов наблюдений (ревью-FAIL 1); §История правок

M	contracts/012-izoljacija-progonov.md
7fc8d1dfd15b4d8fcfe36ad6eb902656a2ba9e03	reviewer	reviewer@dev-harness.local	review: FAIL contract 012 final gate

A	verdicts/review/contracts-012.md
10cc9b0daf7985395c3fac16a2602ec0a3b988e4	orchestrator	orchestrator@dev-harness.local	NABLIUDENIA: Н-57 - рецидив на контракте 012, ложный кап кругов (circles считает переименования)

M	NABLIUDENIA.md
HISTORICAL_LOG_EXIT_RC=0
```

Исторический журнал до первой заморозки (`20fd5ad..frozen/contracts/012/1`)
также проверен. Четыре architect-коммита в `NABLIUDENIA_ARCHITECT.md`, бывшие
причиной предыдущего FAIL (`7e8852b`, `f685378`, `998459c`, `8119cac`), теперь
принадлежат явно расширенной ЗОНЕ architect замороженной v2. Это закрывает
именно прежнюю находку о них; новой причиной этого FAIL они не являются.

## Сырой вывод обязательных механических гейтов

```text
$ bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 40 · предъявлено красным повторным прогоном: 40
COMMAND_EXIT_RC=0

$ bash scripts/check_zones.sh
замороженных контрактов: 11 · объявленных авторов: 5 · коммитов в диапазонах: 245 · проверено по зонам: 165
COMMAND_EXIT_RC=0

$ bash scripts/check_contract_frozen.sh
  ok   contracts/012-izoljacija-progonov.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
планов и контрактов на HEAD: 15 · черновиков: 3 · заморожено: 12 · реестр: full
COMMAND_EXIT_RC=0

$ npm run check:charter
  ok   уставной документ изменён с разрешения владельца: contracts/012-izoljacija-progonov.md в 913b6b4f
  ok   contracts/012-izoljacija-progonov.md — уставной с frozen/contracts/012/1, коммитов в диапазоне 7, изменений без разрешения нет
уставных документов: 14 · изменений в них: 38 · с разрешения: 38
COMMAND_EXIT_RC=0

$ npm run check:ceilings
  ok   персоны: 8 файл(ов), потолок 51200 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 11 черновик(ов) судится, замороженные — по тегам
потолки в порядке
COMMAND_EXIT_RC=0

$ npm run check:ci-parity
workflow-команд: 22 · скриптов в приёмке: 34 · объявленных исключений: 12 · расхождений: 0
COMMAND_EXIT_RC=0

$ bash scripts/check_scoped_run.sh
  ok   (л) фильтр: прогнан ровно выбранный b, RC=0
  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed
  ok   (изол) HOME изолирован per-fixture: leak-игрушка отвергнута («красное не предъявлено»)
  ok   (ц) нерезолвимый base → полный прогон, RC=0
  ok   (ч) doc-only → RC=0, 0 барьеров
  ok   (ц2) пустой base → полный прогон, RC=0
  ok   (ц3) нерезолвимый ненулевой SHA → полный прогон, RC=0
  ok   (ч2) не-README нулевая выборка → RC=0, 0 барьеров
  ok   (ci) ci.yml: ИСПОЛНЯЕМАЯ run-строка гонит анти-плацебо scoped (--changed github.event.before)
check_scoped_run: ветви «all» зелены
COMMAND_EXIT_RC=0
```

## Итог

**FAIL.** Два независимых блокирующих класса: предмет А+В+трёх райдеров не
реализован на HEAD (все шесть его живых приёмок красные), а в диапазон 012
попали три незонных orchestrator-коммита. Механические гейты из задания зелёные,
но не отменяют ни отсутствия реализации, ни превышения области.
