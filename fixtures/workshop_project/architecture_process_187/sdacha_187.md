# СДАЧА 187 — ARCH_CI: ближайший продуктовый предок

Основание: задание `/tmp/dev-harness-verify/task-archci-architect.md`,
слово консультанта 23:52; маршрут А как Б-3: один общий PR и reviewer,
без новой версии frozen-контрактов. База: `f9f029592bbed952b4aebb94aec42fb65232b9e0`;
`git ls-remote ssh://git@github.com/a3ka/dev-harness.git refs/heads/main`
вернул этот SHA, rc 0. Production и контракты этой пачкой не меняются.
Ниже предъявлено красное до реализации, не заявление о готовности done.

## Существующее

`probe.py` создаёт независимые Git-миры; `workflow_probe.py` уже проводит
их через публичные двери, OBJECT/frozen, ARCH_REVIEW-warning и настоящий
done-тег. Существующие CASES/STABS и этот раннер переиспользованы.
Новый модуль `ci_ancestor.py` строит настоящие Git-истории и SHA-адресованный
ответ внешнего curl; реализация Git и done не подменяется.
Оракул HEAD/SHA*/причины снимается в память до вызова субъекта;
после вызова читаются только эффект тега и журнал запросов API.
Формат JSON обслуживает стандартный json, Git-факты — plumbing.

## Двери

- census · fixtures/workshop_project/architecture_process_187/census_b5.py · 0 · 0
- battery-model · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- battery-stabs · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- battery-repo-before-implementation · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . · 0 · 0
- regression-201 · bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo . · 0 · 0
- wiring · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring . · 0 · 0

Замена строки repo на 0/0 выполнена: правка двери (Б-1 вердикта
Rev187Ci) реализована в `fbc26bf57b060ee53cdeb90302d35a521fa2b011`,
живой интеграционный прогон на ней дал CELLS=87 FAILURES=0 (красное
ДО правки — rc 1, ровно клетки rename/submodule — сохранено в разделе
«Исправление FAIL Rev187Ci (Б-1)»). `pre_critic` не назначается
этим маршрутом.

## Карта классов

- К-01 · чисто · вход: предметный лист, машинные двери и все К-01…К-17; один общий reviewer, без новой версии контракта · - · -
- К-02 · чисто · вход: задание 23:52 разрешает только harness-only предка; перечень заменяемых обязательств приведён ниже · - · -
- К-03 · чисто · вход: повторно использованы world, prepare, live, done_observed; продуктовые скрипты и соседняя семья 201 неизменны · - · -
- К-04 · чисто · вход: workflow_probe.py, ci_ancestor.py, census_b5.py, sdacha_187.md внутри выданной architect-зоны · - · -
- К-05 · чисто · вход: база 67/67 зелена; после новых клеток 10 RED только done-ancestor, прежние 67 GREEN · - · -
- К-06 · чисто · вход: реальные Git/Python/bash, автономный PATH-curl по SHA; новых зависимостей нет · - · -
- К-07 · чисто · вход: rc из SPECS, HEAD и SHA* из конструкции мира до субъекта; наблюдаются запрос API, stderr и настоящий тег · - · -
- К-08 · чисто · вход: stabs 87/111/0, стабов семьи 18, ZHIV=0; привязки только в ci_ancestor.STABS · - · -
- К-09 · чисто · вход: реальные однородительские цепочки и два родителя merge, конформные JSON check-runs; граница 50/51 и root · - · -
- К-10 · чисто · вход: пойманы произвольный предок, лишние каталоги, merge-обход, отсутствие лимита, тег на SHA*, prefix без слеша, утрата диагностики и скрытые rename/gitlink пути · - · -
- К-11 · чисто · вход: ожидаемые SHA/причина в памяти до вызова; субъект не становится источником ожидаемого результата · - · -
- К-12 · чисто · вход: SPECS и LIMIT едины для новых клеток и census; ожидания rc литеральны, не вычисляются селектором модели · - · -
- К-13 · н/п · новые клетки используют автономный curl без сетевого запроса; токены не выводятся · - · -
- К-14 · чисто · вход: one/three/limit/head/tag-head зелены на честной модели; docs/github/product/mixed/prefix остаются отказами · - · -
- К-15 · чисто · вход: census 87 клеток, 111 стабов, 20 клеток семьи, 18 стабов семьи; dangling пуст; repo 87/0/2 до правки двери, regression-201 62/0/0 · - · -
- К-16 · чисто · вход: ARCH_REVIEW-warning и прежние CI-отказы сохранены; тег только на HEAD, при отказе тега нет · - · -
- К-17 · н/п · sourceCanon и модель архитектуры продукта не меняются; предмет — механическая done-дверь · - · -

## Дельта

Блоков critic эта пачка не закрывает. Новый предметный отказ — неверный
ARCH_CI при служебном хвосте истории; scope не расширен за задание.
Для прежних done-миров внешний ответ дополнен успехом на scenario SHA:
их reviewer-коммит меняет только .harness, поэтому после cutover он
перестаёт быть проверяемым продуктовым SHA. Исходный успех на HEAD
сохранён; прежние отрицательные мутации применены к обоим run.

## Исправление FAIL Rev187Ci (Б-1)

Основание: FAIL вердикта `verdicts/review/contracts-187-v7.md` (Rev187Ci,
вызов 1; архив станции `archive/187/reviewer-ci-fail-3181eee080`; OBJECT
`4333f84873eea5a0d03aae3faf0337c0fd07bddc`), блок Б-1: список путей подъёма
`git diff --name-only -z` (scripts/done_contract.sh:352) неполон —
переименование продукта в `.harness/` и сдвиг gitlink при `ignore = all`
считаются `.harness`-only, живая дверь даёт rc 0. Закрывающее свойство:
список путей каждого коммита подъёма ПОЛОН и не зависит от определения
переименований и от `submodule.*.ignore`; обе стороны переименования и
каждый изменённый gitlink входят в список. Правка двери выполнена:
`fbc26bf57b060ee53cdeb90302d35a521fa2b011` (ветка `wip/187/implementer-ci2`,
только `scripts/done_contract.sh`) заменил `:352` на
`git diff --no-renames --ignore-submodules=none --name-only -z`
(мера осуществимости вердикта: 17 клеток семьи + rename + submodule →
CELLS=19 FAILURES=0). Живой замер на `fbc26bf57b`: `--repo .` rc 0,
CELLS=87 FAILURES=0. Контракты этой пачкой не правятся.

| Клетка | rc OBJECT / состояние | rc после / требование |
| --- | --- | --- |
| done-ancestor-rename | 0 / RED: засчитан продуктовый предок | 1 / GREEN, SHA*=HEAD |
| done-ancestor-submodule-ignore | 0 / RED: засчитан продуктовый предок | 1 / GREEN, SHA*=HEAD |
| done-ancestor-guard-rename | 0 / GREEN (охранная) | 0 / GREEN |

Мир rename: P создаёт `src/r.js` (байты идентичны для rename-детекта),
HEAD = `git mv src/r.js .harness/r.js`. Мир submodule-ignore: P несёт
`.gitmodules` (`submodule.sub.ignore = all`) и gitlink `src/sub`=1×40,
HEAD = `.harness/n` + сдвиг gitlink до 2×40 (`update-index --cacheinfo`).
Охранная guard-rename: HEAD = rename `.harness/a` → `.harness/b` + 30
файлов `.harness/bulk/` — принимается: дверь не запрещает переименования
как класс и не режет большие `.harness`-списки путей.

Обманные стабы (привязка по коду select, Н-39): S-ren
`ancestor-rename-detection` → клетка rename (`--name-only` БЕЗ
`--no-renames`, rename-детект закреплён в команде стаба — поведение
двери OBJECT на этом входе); S-sub `ancestor-submodule-hidden` → клетка
submodule-ignore (`--no-renames` БЕЗ `--ignore-submodules=none`);
S-both `ancestor-porcelain-paths` → клетка rename (оба флага сняты —
поведение двери OBJECT). Каждый дефект наблюдаем на входе своей клетки.

Счётчики: клетки 84 → 87 (семья done-ancestor 17 → 20: +rename,
+submodule-ignore, +guard-rename), стабы 108 → 111 (семья 15 → 18).
Замер этой пачки на OBJECT без правки двери: `--model` rc 0
CELLS=87 FAILURES=0; `--stabs` rc 0 CELLS=87 STABS=111 FAILURES=0,
все пойманы, ZHIV=0; census 87/111, семья 20/18, OLD 67/93, DANGLING=[].

Живой repo-замер этой пачки на OBJECT (правки двери нет): rc 1,
CELLS=87 STABS=0 FAILURES=2 — красные РОВНО две новые клетки, обе с
выводом живой двери «успешный check-run arch засчитан» и SHA* на
продуктовом предке вместо HEAD (миры пересоздаются, SHA — этого прогона):
rename: HEAD=a1ee994792a57478d8b65f9b2ba34b2edc2c9b69;
SHA*=b2f1d263feea36ef36b863214676493b45fdfbda;
submodule-ignore: HEAD=23631fb340e9870b38aa010a47fd5bc0f261a200;
SHA*=b341aad308f926bf802e562326d3d78ec7397ce1. Охранная
guard-rename GREEN (rc 0), остальные 84 клетки GREEN.

## ARCH_CI: предок .harness-only (слово консультанта 23:52)

Обещание: принимать ближайший продуктовый SHA за служебным хвостом,
не принимать произвольный старый success; done-тег остаётся на HEAD.
Наблюдение: rc, один SHA-адресованный запрос, оба полных SHA в одной
ARCH_CI-диагностике, причина глубины/root и настоящий ref тега.
Валидный контрпример — расхождение на истории из задания при замене
значений SHA/имён файлов, не совпадение с литералами игрушечного мира.
Это поведенческое свидетельство, не доказательство произвольной сети GitHub.

Сырой замер до изменения клеток: `--repo .` rc 0,
`CELLS=67 STABS=0 FAILURES=0`. После добавления клеток на той же
неизменённой двери: rc 1, `CELLS=84 STABS=0 FAILURES=10`.
Модель: rc 0, `CELLS=84 STABS=0 FAILURES=0`.
Стабы после ремонта merge-мира: rc 0,
`CELLS=84 STABS=108 FAILURES=0`, все 108 caught, живых 0.
Первый stab-прогон обнаружил один ZHIV у пустого diff merge:
мир исправлен на непустую .harness-дельту относительно первого родителя.
Это ремонт предъявления до сдачи, не расширение предмета.
Регресс 201: rc 0, `CELLS=62 STABS=0 FAILURES=0`.
Исходные 67 клеток остаются GREEN; все 10 RED принадлежат новой семье.

Таблица использует суффиксы `done-ancestor-`; «после» — обязательный
rc реализации и GREEN проверки, пока не наблюдавшиеся на production.
Отрицательный rc сам по себе не достаточен: диагностические клетки могут
быть RED при верном rc. Старые клетки считаются отдельно census.

| Клетка | rc базы / состояние проверки | rc после / требование |
| --- | --- | --- |
| one | 1 / RED | 0 / GREEN |
| three | 1 / RED | 0 / GREEN |
| product | 1 / GREEN | 1 / GREEN |
| docs | 1 / GREEN | 1 / GREEN |
| github | 1 / GREEN | 1 / GREEN |
| mixed | 1 / GREEN | 1 / GREEN |
| failure | 1 / RED | 1 / GREEN |
| skipped | 1 / RED | 1 / GREEN |
| depth | 1 / RED | 1 / GREEN |
| limit | 1 / RED | 0 / GREEN |
| root | 1 / RED | 1 / GREEN |
| merge | 1 / GREEN | 1 / GREEN |
| head | 0 / RED: отсутствует SHA-диагностика | 0 / GREEN |
| missing | 1 / RED | 1 / GREEN |
| tag-head | 1 / RED | 0 / GREEN, ref на HEAD |
| prefix-x | 1 / GREEN | 1 / GREEN |
| prefix-old | 1 / GREEN | 1 / GREEN |

Число клеток семьи и привязки пересчитывает
`fixtures/workshop_project/architecture_process_187/census_b5.py`:
87/111 всего, 20/18 семьи (Б-1: +rename, +submodule-ignore,
+guard-rename), 67/93 прежних; dangling=[].
Живой repo-замер до правки двери — в разделе
«Исправление FAIL Rev187Ci (Б-1)».
Сырой вывод census и прогонов сохранён в tool-трассе текущего вызова.

## Заменяемые frozen-обязательства ARCH_CI

Сверка командой `git grep -n -E 'ARCH_CI|ФИНАЛЬНОМ SHA|финальн' --
contracts/187-*.md contracts/201-*.md`:
• `contracts/187-arhitektura-v-processe.md:41,52` — run именно на финальном
SHA заменяется run на ближайшем продуктовом SHA при harness-only хвосте;
`:11` — существовавшее описание финального SHA.
• `contracts/201-done-dver-soderzhatelnaja-sverka.md:64` — `head_sha == HEAD`
становится `head_sha == SHA*`; имя/status/conclusion неизменны.
• Тот же 201 `:22,34,331` — сохранение прежнего ARCH_CI ограничивается
этой разрешённой заменой; остальные отказы НЕ СЛАБИТЬ.
Production-комментарий `scripts/done_contract.sh:313–316` про «ТОМ ЖЕ SHA,
на который встанет тег done» также заменяем; тег по-прежнему на HEAD.
Контракты и production этой architect-пачкой НЕ редактируются.

## Развилки

• Глубина выбрана 50: 50 служебных коммитов разрешены, 51 — отказ.
Это конечная граница из предложенного алгоритма, с парным контролем.
• Merge не обходится: допустима проверка самого merge, успешного run
на нём в отрицательном мире нет. Второй родитель несёт продуктовый файл,
результирующий merge его не несёт; diff первого родителя только .harness.
• Причина root/глубины судится по именованному ARCH_CI и словам
root/корневой либо depth/limit/лимит/глубина, не по новому формату текста.
Оба полных SHA должны быть на одной предметной диагностической строке.
• Текущий лист фиксирует rc 1 базы; зелёный production-замер и смена
машинной repo-строки принадлежат общей интеграционной сдаче.

## Рефлексия текущей пачки

Первый merge-стаб оказался жив из-за пустого diff подготовленного merge,
а не дефекта ловца; явная .harness-дельта сделала обход наблюдаемым.
Стоимость: один модельный stab-прогон. Закрыто исправлением мира и
повтором 108/108 caught. В общий NABLIUDENIA_ARCHITECT.md не записано:
он допускает только main-коммиты, а выданная зона — только эта семья.

## Прогон листа текущей пачки

Первая пачка: `TMPDIR="$PWD/.scratch-archci" bash scripts/check_sdacha.sh
"$PWD" contracts/187-arhitektura-v-processe.md --run` → rc 0:
`СДАЧА: лист зелёный (двери=6 карта=17/17 дельта=0)`.

Пачка Б-1 (эта): `TMPDIR="$PWD/.scratch-archci3" bash
scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md
--run` → rc 0: `СДАЧА: лист зелёный (двери=6 карта=17/17 дельта=0)`;
repo-дверь заявлена 1·1 и прожита rc 1 (красные ровно rename/submodule).
Двери исполнялись последовательно; тяжёлые батареи не перекрывались.
Scratch удаляется перед коммитом; push не выполняется.


## Исторический замер Б-3 до реализации двери

Корень прогона — собственная изолированная копия
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t291b4aff6/m`.
`TMPDIR` — `$PWD/.scratch-b3a`, сырой stdout сохранён там в
`before-repo.log`, `after-model.log`, `after-stabs.log`, `after-repo.log`.
Логи scratch не входят в поставку; полный вывод также в tool-трассе вызова.
Публичная дверь на обоих живых прогонах — неизменённая с базы.

| Режим | До замены клеток | После замены клеток, до реализации двери |
| --- | --- | --- |
| --repo . | rc 0; CELLS=61 STABS=0 FAILURES=0 | rc 1; CELLS=67 STABS=0 FAILURES=7 |
| --model | этой пачкой до замены не запускался | rc 0; CELLS=67 STABS=0 FAILURES=0 |
| --stabs | этой пачкой до замены не запускался | rc 0; CELLS=67 STABS=93 FAILURES=0 |
| --wiring . | до замены не запускался | rc 0; вывод пуст |

Красные клетки живой двери (полный перечень):
`done-review-missing-warns`, `done-review-heading-warns`,
`done-ci-missing-warns`, `done-ci-other-sha-warns`, `done-ci-red-warns`,
`done-ci-skipped-warns`, `done-ci-head-ahead-warns`.
У двух review-warns фактический rc 1 вместо 0; у пяти CI-warns rc 1,
но причина — прежний ARCH_REVIEW вместо предупреждения и ARCH_CI.
Исходные пять CI-клеток дают rc 1 / ARCH_CI; `done-valid` даёт rc 0,
тег на конечном HEAD, без предупреждения. Самоконтроль pin — 9/9.
Это ожидаемое красное предъявление предмета, не отказ среды.

`bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0: `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=0)`.
Независимый пересчёт строк логов и данных CASES/STABS → rc 0:
BEFORE_GREEN=61, AFTER_GREEN=60, AFTER_RED=7, CASES=67, STABS=93,
CAUGHT=93; красное множество в точности равно новым warns-клеткам,
все привязки STABS ссылаются на существующие CASES.

## Заменённые frozen-обязательства для описания общего PR

`contracts/187-arhitektura-v-processe.md:41,52` — ARCH_REVIEW больше
не отказ. `contracts/201-done-dver-soderzhatelnaja-sverka.md:34,331` —
неизменность ARCH_REVIEW заменена ADR. Упоминание пары свидетельств
в `contracts/201-done-dver-soderzhatelnaja-sverka.md:22` — исторический
инвентарь, не дополнительный отказ. ARCH_CI во всех этих местах сохранён.
Frozen-документы этой поставкой не редактируются.

## Рефлексия процесса

Нового дефекта процесса, мешающего следующей пачке, не обнаружено.
Журнал NABLIUDENIA_ARCHITECT.md в wip не менялся: по роли его записи
допускаются только коммитом main. Известное разделение probe.py /
workflow_probe.py учтено чтением фактического entrypoint, не номерами
строк старого задания; клетки и модель здесь живут в workflow_probe.py.

## Исторический ремонт предпосылки 154 Б-1

Предыдущая версия миров freeze подставляла собственный toy/boundary154
в приватные копии CLI и передавала пустой журнал. Это не доказательство
прохождения новых предметов через публичный счёт 154; нижеследующие
замеры относятся только к исторической конструкции.

Исходный замер автора 0f972e149b9eff8f8da63ebed340fcc20e477e4e
на BASE 154 после ремонта: `red_architecture_process_187.sh --repo .` →
rc 0, `CELLS=61 STABS=0 FAILURES=0`; `--model` → rc 0 с тем же итогом;
`--stabs` → rc 0, `CELLS=61 STABS=75 FAILURES=0`; `--wiring .` → rc 0,
вывод пустой. Это историческое свидетельство исходной сдачи, не новый
интеграционный прогон на строгой реализации 154 Б-1.

Подлинная пересдача Arch187Fixture: код workflow_probe.py побайтово
совпадает с исходной дельтой (blob e125189047681bd53033f8718b28e0a7368f4881).
На одноразовом дереве сдачи 57b9bb19f4: `--model` → rc 0,
`CELLS=61 STABS=0 FAILURES=0`; `--stabs` → rc 0,
`CELLS=61 STABS=75 FAILURES=0`; `--wiring .` → rc 0, вывод пустой.
Интеграционная предпосылка: в базе a9a602bc389edd03156cc4f937849b86562b5621
нет реализации 154 и canonical boundary SHA в обоих CLI. Живой `--repo`
на строгой реализации 154 Б-1 здесь не предъявлен; нужен её точный носитель.

## Узкая интеграционная проба с опубликованным seed 154

Это дополнительный замер Arch187Seed, не пересмотр frozen-контракта,
не свидетельство авторства 154 и не done 187.

Субъект: точный опубликованный seed реализации 154
`042c48cd2dab054654596dcf93f19f0907edcc6f`, а не последующая голова
ветки. В отдельный `.git` внутри собственной изолированной копии получен
командой `bash "$OWN/scripts/gitw" -C "$TEST" fetch --no-tags origin
042c48cd2dab054654596dcf93f19f0907edcc6f`, rc 0;
origin = `ssh://git@github.com/a3ka/dev-harness.git`.
Снимок всего seed извлечён через `git archive`; поверх положена только
семья `fixtures/workshop_project/architecture_process_187/` из принятого
локального `434ec5549a1177475c9e73153eb863282f4383a3`.
Попытка получить также этот fixture-коммит с origin дала `not our ref`;
поэтому источник fixture — предоставленный локальный объект, не
несуществующая публикация. Повторная загрузка одного seed 154 успешна.

`OWN=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t938eed683/m`;
`TEST=$OWN/.scratch-187-seed-shw9nLaC`.
Тестовый снимок записан отдельным корневым коммитом architect
`8db61ed3dd743a5892d82acc0ea4dc211beff38d` (tree
`f41f123c471ab957d5df8324db7bdd391f244a46`), без родителей:
`git rev-list --count HEAD` в TEST → `1`. Чужая история не включена в
сдаваемую ветку.

Доказательство байтов субъекта ДО единственного запуска:

• `HEAD:scripts` и `042c48cd2dab054654596dcf93f19f0907edcc6f:scripts`
  в TEST → один tree `ff08f98b97a7069fac4c7d8ac7de39c24d7d2914`;
  `git diff --exit-code 042c48cd2dab054654596dcf93f19f0907edcc6f -- scripts`
  → rc 0, вывод пустой. Совпадает вся директория scripts, не только
  два файла предполагаемого шва.
• `scripts/zamok_predmeta.sh` → blob
  `cc88f40037f3f7e907e1a28e7a289ab0014b0e48`;
  `scripts/freeze_contract.sh` → blob
  `8d79c4cbf7008178da058ec267c7c0485ee16cc3`.
• `HEAD:fixtures/workshop_project/architecture_process_187` в TEST и
  тот же путь принятого 434ec554 → tree
  `cdd855f6e9ceb0eb708025e48fc3b99bfd5b53de`;
  `workflow_probe.py` → принятый blob
  `e125189047681bd53033f8718b28e0a7368f4881`.
• Разница собранного snapshot с seed — только лист sdacha_187.md
  (17 строк diff, 13 добавленных и 4 удалённых); код дверей и батареи
  не исправлялся. Перед и после прогона
  `git diff --exit-code HEAD -- scripts fixtures/workshop_project/architecture_process_187`
  → rc 0.

Единственный живой запуск:
`TMPDIR="$TEST" bash "$TEST/fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh" --repo "$TEST"`
→ rc 0, 64.85 s, `CELLS=61 STABS=0 FAILURES=0`.
Самоконтроль диагностики отдельно: `GREEN pin-diagnostic-boundary-selfcheck 9/9`.
Ниже отдельные результаты наблюдавшихся ветвей; все перечисленные
клетки GREEN, фактический rc совпал с ожидаемым:

| Клетки | Фактический rc / причина |
|---|---|
| task-valid | 0 |
| task-line-missing, task-line-blank, brief-inline-line-missing | 1 / ARCH_LINE_MISSING |
| task-l3 | 1 / ARCH_OWNER |
| task-unmapped | 1 / PATH_WITHOUT_COMPONENT |
| task-foreign | 1 / ARCH_ZONE |
| task-locate-json-malformed, task-locate-status-missing, task-locate-status-unknown | 1 / ARCH_LOCATE_GRAMMAR |
| brief-lock, brief-no-local-copy, brief-document-no-local, brief-no-rules | 0 / PINNED_BRIEF_187 |
| brief-with-rules | 0 / RULES_FROM_PIN_187 |
| freeze-valid | 0 |
| freeze-no-line | 1 / ARCH_LINE_MISSING |
| freeze-foreign | 1 / ARCH_ZONE |
| freeze-unmapped | 1 / PATH_WITHOUT_COMPONENT |
| freeze-draft, freeze-draft-marker, freeze-draft-schema | 1 / ARCH_DRAFT |
| check-valid, check-green-latency-unresolved | 0 |
| check-failure, check-digest-mismatch, check-rc1-real-gate | 1 / ARCH_CHECK |
| check-not-evaluated | 1 / ARCH_NOT_EVALUATED |
| check-rc2-real-gate, check-rc0-gate-lie | 2 / ARCH_NOT_EVALUATED |
| done-valid | 0 |
| done-ci-missing, done-ci-other-sha, done-ci-red, done-ci-skipped, done-ci-head-ahead | 1 / ARCH_CI |
| legacy-mob, legacy-harness, wiring-valid | 0 |
| wiring-omitted, wiring-no-repo, wiring-python | 1 / CI_BATTERY_187_MISSING_OR_NOT_EXACT |
| wiring-direct-missing | 1 / CI_DIRECT_ARCH_187_MISSING |
| zone-container-file, zone-outside-runtime | 0 |
| zone-container-escape | 1 / ARCH_ZONE |
| path-unplaced-absent, zone-outside-false-refused, path-area-without-component | 1 / PATH_WITHOUT_COMPONENT |
| path-unresolved-zero-absent | 0 / вне модели: scripts/ci-helper.sh |
| path-unresolved-zero-present | 0 / вне модели: provenance.json |
| zone-outside-snapshot-failed, zone-outside-snapshot-missing | 2 / ARCH_NOT_EVALUATED |
| pin-symbolic-head, pin-symbolic-branch, pin-short-sha, pin-unresolvable-sha, pin-head-noflag | 1 / ARCH_PIN |
| applicability-lock-no-dir, applicability-dir-no-lock | 1 / ARCH_COMPONENT_NET |

Поведенческих расхождений с ожиданиями принятой батареи не обнаружено.
По отношению к историческому голому прогону выше пять прежних красных
pin/applicability-клеток зелёные на данном seed; повторного прогона старого
дерева здесь не было. `--model`, `--stabs` и отдельный `--wiring` этой
пачкой не повторялись: результаты 61/61, 75/75 и rc 0 выше принадлежат
Arch187Fixture; wiring-клетки внутри единственного `--repo` исполнены.

После прогона refs TEST: только
`refs/heads/seed-snapshot 8db61ed3dd743a5892d82acc0ea4dc211beff38d`,
тегов нет. Frozen/done-теги 187 не создавались, публикации/push не было,
доставочный WORKTREE не использовался. История seed 154 остаётся только
в экспериментальном `.git` как источник байтов, не как авторская поставка.
Санкционированный v+1 170 и законное место реализации по-прежнему
блокируют done 187; этот зелёный замер их не заменяет.

## Ремонт state нового toy-предмета 777 (Arch187ToyState)

Основание: CI #1152, job 135986462228 — честные freeze-клетки получают
SCHET_NEIZVESTEN без состояния. Исключение проектов из счёта не применяется.
Мир теперь записывает независимый `*-state154/uchet.jsonl` вне продуктового
репозитория: один START critic для subjectId=777, repoId из basename origin
без `.git` (не из профильного repoId), OBJECT существующего baseline.
START записывается до accept; author-date коммита accept равна времени START
с секундной точностью Git, поэтому это не до-журнальная история и не засев.
Публичный freeze получает этот state четвёртым аргументом. Подмена canonical
boundary, приватные копии CLI, искусственный старый тег и пустой ledger удалены.
ARCH_* ожидания, отрицательные клетки и привязки стабов не меняются.

Пачка подготовлена без прогонов по заданию; новые rc не предъявляются.
Исторический зелёный seed выше не является проверкой этой дельты.
Приёмка ведущей сессией на собранном кандидате с реализацией 154:

• `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo .`
• `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model`
• `bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs`
• `bash scripts/check_sdacha.sh . contracts/187-arhitektura-v-processe.md --run`

