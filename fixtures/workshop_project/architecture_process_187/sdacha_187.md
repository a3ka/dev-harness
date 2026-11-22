# СДАЧА 187 — сверка Б-5 с влитым ARCH_CI (объединение семьи)

Основание: задание `/tmp/dev-harness-verify/task-b5reconcile.md`. Ветка
`wip/187/final-b5` (accept Rev187B5c на OBJECT `27983f424a`, вердикт
`1870d62500`, закрытие ревью `.review/126`) после ленда ARCH_CI в main
конфликтовала в трёх файлах семьи: `census_b5.py` (add/add), `workflow_probe.py`
и `sdacha_187.md`. Слияние `wip/187/architect-b5m`: origin/main
`e517385a5b8edc447f9eea0f6afdc82fedd065f5` + `wip/187/final-b5`
`7223880c6d98d0040875ff707ac86b58265b8232`, база
`f9f029592bbed952b4aebb94aec42fb65232b9e0`, identity architect.
Разрешение сохраняет ОБЕ стороны: клетки/стабы ARCH_CI (87/111,
ANCESTOR 20/18) и клетки/стабы Б-5 (brief_stderr 10/13, brief_signals 4/4).
Двери `scripts/*` в конфликте не состояли и взяты сторонами целиком без
правок: `scripts/done_contract.sh` — из main (rename/gitlink, Б-1 Rev187Ci),
`scripts/check_architecture_contract.sh` — из Б-5 (время жизни stderr при
сигнале группе, Б-1 Rev187B5).

## Существующее

`probe.py` создаёт независимые Git-миры; `workflow_probe.py` проводит их
через публичные двери, OBJECT/frozen, ARCH_REVIEW-warning и настоящий
done-тег. `ci_ancestor.py` строит настоящие Git-истории и SHA-адресованный
ответ внешнего curl; реализация Git и done не подменяется. Семья Б-5
использует тот же toy CLI и конфигурацию `brief-response.json` в
ЗАКРЕПЛЁННОМ дереве, а не подмену node или самой двери; `brief_stderr.py`
хранит входы, ожидаемые байты и привязки стабов, `brief_signals.py` —
сигнальные клетки и контроли; оракул снят до субъекта, после вызова
читаются только наблюдаемый TMPDIR, эффект тега и журнал запросов API.
Публичные швы: `make_task`, импортируемый `arch187_brief`, census-раннер
`census_b5.py` с побайтовым stdout/stderr и cleanup. Ожидания в памяти
до субъекта; формат JSON обслуживает стандартный json, Git-факты — plumbing.

## Двери

- census · fixtures/workshop_project/architecture_process_187/census_b5.py · 0 · 0
- battery-model · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --model · 0 · 0
- battery-stabs · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --stabs · 0 · 0
- battery-repo-before-implementation · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --repo . · 0 · 0
- regression-201 · bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo . · 0 · 0
- wiring · bash fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh --wiring . · 0 · 0
- b5-battery-model · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-model model · 0 · 0
- b5-battery-stabs · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-stabs stabs · 0 · 0
- b5-battery-repo · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-repo repo · 0 · 0
- b5-wiring · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-wiring wiring · 0 · 0
- b5-signals-base-and-control · fixtures/workshop_project/architecture_process_187/census_b5.py b5c-sheet-controls signals-base signals-control · 0 · 0

Все одиннадцать дверей прожиты на объединённом дереве с фактическим rc 0
(сырые rc — раздел «Census объединённого дерева»); строки repo обеих
сторон — `0 · 0`: правка двери Б-1 Rev187Ci (`fbc26bf57b060ee53cdeb90302d35a521fa2b011`,
только `scripts/done_contract.sh`) и ремонт сигнального cleanup Б-1 Rev187B5
(`6956c8c891b8cd44dd4882189f1b7e2b6af44828`) пришли в слияние сторонами
без правок архитектора. `census_b5.py` без аргументов печатает цензус обеих
семей; с аргументами `<stage> <режимы>` исполняет тот же bash-runner,
сохраняет сырой stdout/stderr в TMPDIR, печатает фактический rc каждого
режима и возвращает ненулевой код при любом ненулевом режиме, не маскируя
красное. Рабочий TMPDIR этой сдачи — `$PWD/.scratch-b5m`, в коммит не
включается и перед сдачей удаляется.

## Карта классов

- К-01 · чисто · вход: объединённый лист несёт одиннадцать дверей обеих сторон и полную карту К-01…К-17; решения Rev187B5c (accept 1870d62500) и Rev187Ci (Б-1, fbc26bf57b) уже в истории слияния · - · -
- К-02 · чисто · вход: два предмета — предок .harness-only (слово консультанта 23:52, harness-only) и время жизни stderr при сигнале группе (блок Б-1 Rev187B5); прежние rc и диагностики обеих сторон сохранены · - · -
- К-03 · чисто · вход: переиспользованы world, prepare, live, done_observed, ci_ancestor, library-швы brief_stderr/brief_signals и command substitution вызывающего; настоящий bash/node; дверные скрипты правились только сторонами · - · -
- К-04 · чисто · вход: слияние правит только fixtures/workshop_project/architecture_process_187/; конфликты workflow_probe.py, census_b5.py и sdacha_187.md разрешены сохранением обеих сторон; двери scripts/* пришли от сторон без правок · - · -
- К-05 · чисто · вход: живая дверь --repo на объединённом дереве rc 0, CELLS=102 FAILURES=0; исторические красные предъявления обеих сторон сохранены в разделах ниже · - · -
- К-06 · чисто · вход: модель пишет stderr и ready-маркер до сигнала; ожидание ограничено, отсутствие ready красное; SHA-адресованный curl-ответ предка снимается в память до субъекта · - · -
- К-07 · чисто · вход: ожидания NEIGHBOR и пустого scratch в памяти до субъекта; HEAD, SHA* и причины из конструкции мира; после вызова читаются только эффект тега, журнал запросов API и наблюдаемый TMPDIR · - · -
- К-08 · чисто · вход: стабы 128 из 128 caught, ZHIV=0; семьи ancestor 18 и Б-5 17 (S1/S2/S4 в brief_signals.STABS, S3 в brief_stderr.STABS); привязки только в коде, не в прозе · - · -
- К-09 · чисто · вход: реальные однородительские цепочки и merge с двумя родителями, конформные JSON check-runs; TERM/INT группе, TERM родителю, нормальные rc 0/1, чужой сосед; граница 50/51 и root · - · -
- К-10 · чисто · вход: пойманы произвольный предок, лишние каталоги, merge-обход, отсутствие лимита, тег на SHA*, prefix без слеша, утрата диагностики, скрытые rename/gitlink пути; прежнее точное равенство stderr сохранено · - · -
- К-11 · чисто · вход: ожидаемые SHA, причины и байты stderr в памяти до вызова; субъект не источник ожиданий; cleanup не требует имени и способа аллокации, сосед сравнивается с независимой константой · - · -
- К-12 · чисто · вход: SPECS и LIMIT едины для новых клеток и census; сигналы доставляет os.killpg реальной группе новой сессии; ожидания rc литеральны, без разбора bash своими предикатами · - · -
- К-13 · н/п · новых сетевых вызовов и секретов в клетках нет: автономный curl без сети, токены не выводятся · - · -
- К-14 · чисто · вход: one/three/limit/head/tag-head и честные сигнальные контроли зелены на честной модели (signals-control); docs/github/product/mixed/prefix остаются отказами · - · -
- К-15 · чисто · вход: census 87/111 workflow и 14/17 Б-5, батарея 102/128, dangling пуст; живой repo 102/0/0; regression-201 62/0/0 · - · -
- К-16 · чисто · вход: ARCH_REVIEW-warning и прежние CI-отказы сохранены; тег только на HEAD, при отказе тега нет; stderr не переживает группу, узкий сигнал родителю остаётся зелёной охраной · - · -
- К-17 · н/п · sourceCanon, модель продукта и его pin не меняются · - · -

## Дельта

Сверка слияния блоков critic не закрывает: оба предмета закрыты своими
решениями (Rev187Ci Б-1 — правкой двери `fbc26bf57b`, Rev187B5c — accept
`1870d62500`). Конфликтные файлы разрешены сохранением обеих сторон:
`workflow_probe.py` — импорты, клетки и ветвление обеих семей;
`census_b5.py` — цензус обеих семей плюс режимный раннер; `sdacha_187.md` —
машины дверей/карты объединены, исторические разделы обеих сторон сохранены.

## Census объединённого дерева

`census_b5.py` без аргументов (цензус ОБЕИХ семей, rc 0):
CELLS=87, STABS=111, ANCESTOR_CELLS=20, ANCESTOR_STABS=18,
B5_STDERR_CELLS=10, B5_STDERR_STABS=13, B5_SIGNAL_CELLS=4,
B5_SIGNAL_STABS=4, B5_CELLS=14, B5_STABS=17, OLD_CELLS=67, OLD_STABS=93,
BATTERY_CELLS=102, BATTERY_STABS=128, DANGLING=[]. Имена семей:
ANCESTOR_LABELS — 20 клеток `done-ancestor-*`; B5_LABELS — 14 клеток
`brief-stderr-*`, `brief-empty-output-*`, `brief-success-*`,
`brief-cleanup-*`, `brief-signal-*`.

Сырые замеры объединённого дерева (каждая команда прожита, rc из прогона):

• `bash …/red_architecture_process_187.sh --model` → rc 0,
CELLS=102 STABS=0 FAILURES=0, все клетки обеих семей GREEN.
• `bash …/red_architecture_process_187.sh --stabs` → rc 0,
CELLS=102 STABS=128 FAILURES=0, 128 строк STAB, живых (ZHIV) 0.
• `bash …/red_architecture_process_187.sh --repo .` (живая дверь) → rc 0,
CELLS=102 STABS=0 FAILURES=0; красных клеток Б-5 из-за дверей нет —
сигнальный ремонт и ancestor-дверь пришли сторонами.
• `bash …/red_architecture_process_187.sh --wiring .` → rc 0.
• `…/census_b5.py b5m-sheet-repo repo` → `CENSUS b5m-sheet-repo --repo rc=0`.
• `…/census_b5.py b5m-sheet-controls signals-base signals-control` →
`CENSUS … --signals-base rc=0`, `CENSUS … --signals-control rc=0`.
• `bash fixtures/workshop_project/done_dver_soderzhatelnaja_201/red_done_dver_201.sh --repo .`
→ rc 0, CELLS=62 STABS=0 FAILURES=0.

Стороны до слияния (по листам сторон): ARCH_CI — 87/111, семья 20/18,
repo 87/0 после правки двери; Б-5 — 82/110 на своей стороне (67 workflow +
14 Б-5 + selfcheck). Объединение: 102 клетки батареи = 87 workflow (в т.ч.
20 ancestor) + 14 Б-5 + 1 самоконтроль pin-границы; 128 стабов =
111 workflow (в т.ч. 18 ancestor) + 17 Б-5. Счётчик исторических листов
82/110 не пропал: его носитель — разделы «Census и клетки» и
«Исправление FAIL Rev187B5» ниже; текущий счётчик един — BATTERY_*.

## Прогон листа текущей пачки

`TMPDIR="$PWD/.scratch-b5m" bash scripts/check_sdacha.sh "$PWD"
contracts/187-arhitektura-v-processe.md --run` → rc 0:
`СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=0)`; все одиннадцать
дверей исполнены дверью листа последовательно с фактическим rc 0.
Scratch удаляется перед коммитом; push не выполняется.

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

## Census и клетки

### Исторический замер после первой реализации Б-5

На базе `8cc43759830eb16c82b729e4156dd15965673fc3` живой
`fixtures/workshop_project/architecture_process_187/census_b5.py sdacha-repo repo`
→ rc 0, `CELLS=78 STABS=0 FAILURES=0`,
`CENSUS sdacha-repo --repo rc=0`.
Сырые stdout/stderr — `$TMPDIR/sdacha-repo-repo.stdout` и `.stderr`.

Отдельный прямой `red_architecture_process_187.sh --repo .` → rc 0,
`CELLS=78 STABS=0 FAILURES=0`. Повторные режимы через
`census_b5.py post-implementation model stabs wiring`:
`CENSUS post-implementation --model rc=0`,
`CELLS=78 STABS=0 FAILURES=0`;
`CENSUS post-implementation --stabs rc=0`,
`CELLS=78 STABS=105 FAILURES=0`;
`CENSUS post-implementation --wiring rc=0`, вывод самой двери пустой.
Сырые логи — `$TMPDIR/post-implementation-{model,stabs,wiring}.{stdout,stderr}`.

Проверка обновлённого листа:
`bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0: `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=0)`.
Независимая мера `wc -l` сырых stdout: sdacha-repo-repo=80,
post-implementation-model=80, post-implementation-stabs=185.
За вычетом selfcheck и summary — 78 клеток; разность 185−80 — 105 стабов.

Рефлексия обновления: красный rc ДО нельзя оставлять текущей дверью
после совместной поставки; история отделена от действующей строки repo.
Общий журнал не менялся: эта пачка ограничена листом, журнал пишется в main.

### Исторический замер ДО реализации

Исходное задание: `/tmp/dev-harness-verify/task-b5-architect.md`;
база ДО: `94b2edff9072abaca3a5c2a848e08fa90de9869e`.
Все замеры до таблицы ниже относятся к этому красному предъявлению;
текущая строка двери repo выше требует rc 0 после ремонта.

Неизменённая семья на базе: `--repo` rc 0, CELLS=67 STABS=0 FAILURES=0;
`--model` rc 0, CELLS=67 STABS=0 FAILURES=0; `--stabs` rc 0,
CELLS=67 STABS=93 FAILURES=0; `--wiring` rc 0, вывод пуст.
Исходный `--repo` — сырой tool-вывод; прочие исходные логи — `before-*`.

После добавления клеток на ТОЙ ЖЕ двери: `--model` rc 0,
CELLS=78 STABS=0 FAILURES=0; `--stabs` rc 0,
CELLS=78 STABS=105 FAILURES=0; LIVE/ZHIV=0; `--wiring` rc 0.
Живой `--repo` до реализации: rc 1, CELLS=78 STABS=0 FAILURES=7,
красны ровно семь диагностических/static-клеток из таблицы; все прежние зелёные.
Итоговые сырые логи — `sdacha-model-model.stdout`,
`sdacha-stabs-stabs.stdout`, `sdacha-repo-repo.stdout`,
`sdacha-wiring-wiring.stdout` и одноимённые `.stderr` в TMPDIR.
`bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0: `СДАЧА: лист зелёный (двери=4 карта=17/17 дельта=0)`.
Независимая мера `wc -l` логов: before-model=69, before-stabs=162,
sdacha-model=80, sdacha-stabs=185, sdacha-repo=80.
За вычетом selfcheck и summary это 67/78 клеток;
разности stab/model дают 93 и 105 предъявлений соответственно.

| Клетка | rc субъекта ДО | До реализации | После реализации (живой замер на базе выше) |
| --- | --- | --- | --- |
| brief-stderr-plain | 1 | красная: нет ARCH_BRIEF_STDERR | зелёная, rc 1 |
| brief-stderr-rules | 1 | красная: нет ARCH_BRIEF_STDERR | зелёная, rc 1 |
| brief-stderr-empty | 1 | красная: нет пояснения пустого stderr | зелёная, rc 1 |
| brief-stderr-leading-blank | 1 | красная: нет первой непустой строки | зелёная, rc 1 |
| brief-empty-output-noisy | 1 | красная: rc модели 0, но stdout пуст | зелёная, rc 1 |
| brief-empty-output-quiet | 1 | красная: rc модели 0, оба канала пусты | зелёная, rc 1 |
| brief-success-noisy | 0 | зелёная: stdout=BODY, stderr пуст | зелёная, rc 0 |
| brief-success-quiet | 0 | зелёная: stdout=BODY, stderr пуст | зелёная, rc 0 |
| brief-cleanup-failure | 1 | зелёная: TMPDIR пуст | зелёная, rc 1 |
| brief-cleanup-success | 0 | зелёная: TMPDIR пуст | зелёная, rc 0 |
| brief-stderr-fable-static | 1 | красная: brief в /dev/null | зелёная, rc 0 |

## Развилки и заменяемые обязательства

Задание требует красноты cleanup на базе, но база вообще не создаёт
stderr-scratch: TMPDIR пуст и после отказа, и после успеха. Краснить такую
реализацию за отсутствие утечки было бы ложью. Эти клетки оставлены
зелёными регресс-стражами; S6 отдельно создаёт утечку и ловится.
Для полноты условия «rc≠0 ИЛИ пустой stdout» добавлены две адресные клетки.

Поиск `2>/dev/null|stderr` в contracts/187-arhitektura-v-processe.md
не даёт строк. Явного frozen-обещания глотать stderr в 187 нет.
В contracts/170-arch-component-brief-vhod-zadanija.md:28 объявлена первая
строка `ОТКАЗ: ARCH_BRIEF_OTKAZ: worker.events`; при переносе этой формы
на pinned-ветвь она заменяется предшествующей строкой ARCH_BRIEF_STDERR
по ADR. Локальный npm-путь 170 остаётся прежним. Строки 170:15,27
(ARCH_COMPONENT_NET/ARCHITECTURE_NET) не относятся к изменению и сохранены.

В fixtures/workshop_project/arch_component_170/probe.py:174–186 первая
строка stderr сравнивается для brief_failure, implementer_brief_failure,
adversary_brief_failure, reviewer_brief_failure; эта семья не правилась.
Её npm_stub.py:25–27 выдаёт отказ npm, не pinned node CLI.
Контракты и версию 170 эта поставка не замораживает.

## Рефлексия процесса Б-5

Новый риск конструкции: требование красноты cleanup против базы без
аллокации ведёт к ложному красному. Закрыто независимой cleanup-клеткой
и утечкой S6, а не добавлением искусственного дефекта в базу.
Общий журнал в wip не менялся: его разрешено пополнять только в main.

## Исправление FAIL Rev187B5

После ремонта Impl187B5c на `6956c8c891b8cd44dd4882189f1b7e2b6af44828`
исполнен `census_b5.py b5d model stabs repo wiring`: сырые rc режимов
соответственно 0, 0, 0, 0. Model и repo: `CELLS=82 STABS=0 FAILURES=0`;
stabs: `CELLS=82 STABS=110 FAILURES=0`, ZHIV=0.
Прямой `red_architecture_process_187.sh --repo .` также дал rc 0,
`CELLS=82 STABS=0 FAILURES=0`.
Сырые логи census: `$TMPDIR/b5d-{model,stabs,repo,wiring}.{stdout,stderr}`.

| Клетка после ремонта | rc вызывающего | Наблюдение в borrowed и managed |
| --- | --- | --- |
| brief-signal-group-term | -15 | GREEN, ready=True, leftover=[], neighbor=True |
| brief-signal-group-int | -2 | GREEN, ready=True, leftover=[], neighbor=True |
| brief-signal-parent-term | -15 | GREEN, ready=True, leftover=[], neighbor=True |
| brief-cleanup-neighbor | 0 | GREEN, ready=True, leftover=[], neighbor=True |

Независимая мера `wc -l .scratch-b5d/b5d-{model,stabs,repo}.stdout`:
84, 194, 84 строки; без selfcheck/summary — 82 клетки;
194−84 — 110 пойманных стабов, живых 0.

Рефлексия обновления: историческое красное предъявление не является текущей
дверью после ремонта; строка repo и карта теперь описывают зелёный субъект.
Общий А-журнал не менялся: разрешённая зона этой пачки — только лист,
а общий журнал пополняется только в main.

Проверка обновлённого листа после ремонта:
`TMPDIR="$PWD/.scratch-b5d" bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0, `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)`.
Исполнены все пять дверей, включая `signals-base` и `signals-control`;
текущий repo заявлен и измерен как rc 0.

### Историческое красное предъявление ДО ремонта

Б-1: «файл захвата stderr брифа остаётся, когда сигнал доходит до всей группы процессов. Место: scripts/check_architecture_contract.sh:504 (mktemp внутри функции) и :512-515 (rm только при нормальном возврате). Вызов идёт в $(...) из scripts/make_task.sh:1070, а EXIT-ловушка make_task.sh:565 этого файла не знает. Обязательство из тела PR: «удаляется ВСЕГДА»; в задании: «в т. ч. при сигнале». Проба: `GROUPKILL=1 bash .scratch-rev187b5/signal_probe.sh scripts/check_architecture_contract.sh object-timeout-group TERM` → caller_rc=124, leftover=[tmp.OHk5oKEG1g] с текстом 'slow-model-first'; файл на месте и через 22 с после конца модели. С INT то же. База a4f87d04a1 → leftover=[]. Если TERM получает только родитель, утечки нет: подоболочка доживает до конца модели и убирает файл. Закрывающее свойство: файл не переживает TERM/INT, доставленный группе, пока работает CLI модели; клетка красная на OBJECT. Более простые формы уже есть в дереве: файл выделяет вызывающий и убирает своя EXIT-ловушка, как _NPM_ERR_FILE (make_task.sh:1051, :565), либо файл лежит под ARCH187_MODEL_TMP.»

Обещание: файл захвата stderr не переживает TERM/INT группе во время CLI.
Наблюдение: после естественного выхода вызывающего TMPDIR не содержит
ничего, кроме побайтно неизменного чужого `tmp.neighbor-187`; управляемое
ARCH187_MODEL_TMP тоже убрано. Ожидание не берётся из дерева субъекта.
Borrowed-модель лежит вне TMPDIR и не принадлежит cleanup двери.
Сигнал отправляется после маркера CLI, который следует за записью stderr.
Клетка воспроизводит вложенный `$(arch187_brief ...)` публичного вызывающего.
Проверяются оба режима владения моделью; имя capture не предписывается.
Frozen-обязательства и перечень заменяемых обязательств выше не менялись.

| Клетка | OBJECT ДО: rc вызывающего / оценка | Честный исполняемый контроль: rc / оценка |
| --- | --- | --- |
| brief-signal-group-term | -15 / RED, файл остался в обоих режимах | -15 / GREEN, leftover=[] |
| brief-signal-group-int | -2 / RED, файл остался в обоих режимах | -2 / GREEN, leftover=[] |
| brief-signal-parent-term | -15 / GREEN, leftover=[] | -15 / GREEN, leftover=[] |
| brief-cleanup-neighbor | 0 / GREEN, neighbor=True | 0 / GREEN, neighbor=True |
| brief-cleanup-failure | 1 / GREEN, прежняя охрана | прежняя model-клетка: 1 / GREEN |
| brief-cleanup-success | 0 / GREEN, прежняя охрана | прежняя model-клетка: 0 / GREEN |
| brief-stderr-* | 1 / GREEN, ровно одна строка ARCH_BRIEF_STDERR | прежние model-клетки: 1 / GREEN |

Последняя колонка — исторический контроль `signals-control`/`--model`,
НЕ live-прогон после реализации. Закрывающий живой замер после ремонта
приведён в начале этого раздела; прежние красные результаты сохранены ниже.

Команда воспроизведения и дифференциального контроля:
`fixtures/workshop_project/architecture_process_187/census_b5.py b5c signals signals-base signals-control`.
Её сырой итог: `CENSUS b5c --signals rc=1`,
`CENSUS b5c --signals-base rc=0`, `CENSUS b5c --signals-control rc=0`.
`signals-base` извлекает только настоящий library-файл из `a4f87d04a1`;
остальной контур и входы идентичны. Сырые отдельные наблюдения:

```text
RED brief-signal-group-term: mode=borrowed ready=True caller_rc=-15 leftover=['tmp.wA2aKB1AwH'] neighbor=True stdout=b'' stderr=b'' | mode=managed ready=True caller_rc=-15 leftover=['tmp.pcGBhWMTyS'] neighbor=True stdout=b'' stderr=b''
RED brief-signal-group-int: mode=borrowed ready=True caller_rc=-2 leftover=['tmp.rZY6yGavsD'] neighbor=True stdout=b'' stderr=b'' | mode=managed ready=True caller_rc=-2 leftover=['tmp.HkeFknjE4L'] neighbor=True stdout=b'' stderr=b''
GREEN brief-signal-parent-term: mode=borrowed ready=True caller_rc=-15 leftover=[] neighbor=True stdout=b'' stderr=b'' | mode=managed ready=True caller_rc=-15 leftover=[] neighbor=True stdout=b'' stderr=b''
```

Историческая fixture-пачка: 78 → 82 клетки; 105 → 110 стабов. Независимая мера
`wc -l .scratch-b5c/b5c-{model,stabs,repo}.stdout` → 84, 194, 84;
за вычетом selfcheck/summary — 82 клетки, разность 194−84 — 110 стабов.
`census_b5.py b5c model stabs repo wiring` дал соответственно rc 0, 0, 1, 0.
В repo красны ТОЛЬКО group-term и group-int, `FAILURES=2`;
в stabs все предъявления caught, ZHIV=0.
Логи: `$TMPDIR/b5c-{model,stabs,repo,wiring,signals,signals-base,signals-control}.{stdout,stderr}`.

S1 исполняет normal-only cleanup отдельно на TERM и INT; S2 снимает
EXIT-cleanup при INT, оставляя честный TERM; S3 теряет прочитанную причину
и ловится прежним точным stderr-предикатом; S4 удаляет `tmp.*` и ловится
исчезновением чужого соседа. Честный контроль с точечным cleanup зелён.

Рефлексия процесса: Node наследует тип модуля родительского package.json;
первая версия toy использовала require в ESM и не достигала ready. Исправлено
на стандартный ESM import до предъявления; отсутствие ready остаётся красным.
Общий А-журнал в wip не менялся: запись разрешена только в main.

Историческая проверка листа ДО ремонта:
`TMPDIR="$PWD/.scratch-b5c" bash scripts/check_sdacha.sh "$PWD" contracts/187-arhitektura-v-processe.md --run`
→ rc 0, `СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)`.
Она повторно исполнила все пять дверей, включая оба режима контроля;
repo в том историческом листе был заявлен как красное предъявление ДО ремонта.

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

