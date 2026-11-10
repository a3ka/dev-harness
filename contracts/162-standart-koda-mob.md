# Контракт 162 — стандарт кода мобильного клиента Complior-mob

КЛАСС ЗАДАЧИ: ДОКУМЕНТНЫЙ (профиль architecture, механизм 027). КЛАСС РИСКА: обычный — документирование и трассировка соглашений кода, без изменения прав БД, авторизации, безопасности, денег, ПД/health и юридически значимых операций. ТРЕК: лёгкий. Основание: слово владельца 2026-11-04 ~19:40 UTC; продуктовый кандидат PR Complior-mob #158, ветка `wip/136/standard`, HEAD `1e9b07ce594d7b3a65e92ceb2dcadd27bff0d6bf` (снимок, не обещание текущего HEAD). Владелец поручил договориться о стандарте до следующего среза; этот контракт не меняет экран и не принимает продуктовый PR заочно.

КОНТЕКСТ: Complior-mob PR #158: `docs/CODING-STANDARDS.md` §§1–16, `STRUCTURE.md` §§3–5, `AGENTS.md` §Источники; `docs/context/CONTEXT-POLICY.md` §Контракт; исходники из product worktree `wip/136/standard`. Источники ниже проверяются из корня продукта (не из корня харнесса):

ИСТОЧНИК: docs/CODING-STANDARDS.md@b32fb106a50d7803521a9e8811d17a3f6034ed31ede09622c5f1976e5464a436 §1 строки=5-15
ИСТОЧНИК: docs/CODING-STANDARDS.md@b32fb106a50d7803521a9e8811d17a3f6034ed31ede09622c5f1976e5464a436 §13 строки=118-133
ИСТОЧНИК: STRUCTURE.md@b91af22dfd3ebbd231c962028cc26bc0c2a39a6dd10f9fcbfec153e7c1b71e11 §5 строки=167-179
ИСТОЧНИК: AGENTS.md@e76d217b361b0f3e1c50a56c8699f34d242a9abcd7673871a0fdd1c3bda99f9a §Источники строки=6-14
ИСТОЧНИК: docs/context/CONTEXT-POLICY.md@ac1e9dbe13f904384825e77754b3e397704c5145c200874fe91485251b433e4c §Контракт строки=33-39

## Существующее

- Кандидат PR #158: `docs/CODING-STANDARDS.md` (16 разделов; правило precedence §1), `STRUCTURE.md:68,166` исправляет ложное обещание генерации API-типов: типы сейчас выписаны вручную, генерация — цель. Корневой `AGENTS.md:24–28` уже связывает структуру, lint и экранные e2e; `mobile/AGENTS.md` содержит Expo-ограничения. Не переписывать их вторым каноном и не объявлять цель миграции исполненной.
- В том же product worktree существуют **неотслеживаемые** `tmp/claims.tsv` и `tmp/verify-standard.sh`, вывод `tmp/verify-standard.out`: живой повтор `bash tmp/verify-standard.sh` показал 123/123, rc 0; типы claims: exists 18, grep 89, grep-none 6, json 4, goal 6. Это проверка соответствия паттернов существующему дереву, а не семантическое доказательство каждого правила или артефакт PR. Если tmp очищен, запуск без claims должен отказывать, а не выдавать успех. Формат текущей строки TSV: `id TAB раздел TAB утверждение TAB тип TAB путь-или-глоб TAB шаблон`; типы/семантика — комментарий `tmp/verify-standard.sh:10–18`. Проверка по grep-паттерну не устанавливает полноту doc↔code сама по себе.
- `mobile/scripts/check-context-sources.py` уже проверяет точные строки `ИСТОЧНИК:`: локальные файлы, SHA256, §, диапазон и опциональную цитату; он не проверяет полноту правил стандарта. `mobile/structure-policy.json`, `mobile/eslint.config.js`, `mobile/scripts/check-structure.cjs` + `npm --prefix mobile run lint` — существующий энфорсмент мест и импортов, не новая реализация 162.
- `mobile/scripts/check-structure.cjs:20` разрешает в `mobile/scripts/` только исполняемые расширения; таблица `.tsv` из ЗОНЫ implementer без записи в `mobile/structure-policy.json` → `mobileFiles` даёт `outside allowed location/type`. В раскладке обязательного CI job `quality` существующие временные каталоги вынесены до lint, поэтому этот отказ единственный новый (Rev162: база rc 0, кандидат 932ee4a rc 1); нужна одна разрешающая строка, а не перенос таблицы из `mobile/scripts/`.
- Харнесс: 027 `scripts/doc_contract.ts`, `scripts/check_document.sh` — профиль architecture и evidence; 095 — contextPack; 123 (`scripts/sverka_maketa.py`) судит PNG, 132 (`scripts/ekran_shablon.py`) судит форму экрана, 146 — движение. `registry/plan.tsv` содержит запись 162 (complior, до V-2), но батарея стандарта 162 в существующих экранных `fixtures/workshop_project/` отсутствует; `fixtures/workshop_project/standarty_115/` относится к другому продукту. `contracts/158-ekrannyj-nabor.md` уже есть в этом checkout, его wip фиксирует HANDOFF: это экранный набор, не стандарт кода; 123/132/146 и 158 не переписывать. Прецедент Complior-back 115 даёт стандарт + ESLint, но мобильный клиент имеет собственную структуру и конфигурацию; не портировать правила Node/PG.
- В продуктовой ветке лежит неотслеживаемый `.harness/contracts/151-standart-koda.md` — черновик моб-сессии с тем же предметом, а не замороженный источник и не часть PR #158; трассировка 162 должна жить в опубликованном контракте харнесса и продуктовой команде, а не зависеть от этого scratch-файла.

## Frontier: способ устранить измеренную боль

- Оставить `tmp/verify-standard.sh` как свидетельство и принять PR без checker: отвергнуто — `tmp/` не отслеживается, честный 123/123 пропадает при чистом checkout, а воспроизводимый rc не появляется.
- Перенести проверку утверждений в `mobile/scripts/` с таблицей там же (выбрано): существующий 123/123 используется как контроль поведения, обратную связь правила и носителя добавляет та же проверка; цена — узкая продуктовая поставка после freeze, до reviewer.
- Ввести новый общий guard в CI харнесса: отвергнуто — CI харнесса не имеет product checkout, стандарт и код живут в продукте; возникла бы зависимость от чужого репозитория без изменения наблюдаемой приёмки.
- Перенести таблицу в другой путь: отвергнуто после пробы CI Rev162 — потребитель и таблица уже поставлены и воспроизводят 123/123; узкое разрешение `"scripts/coding-standards-claims.tsv"` в существующем `mobileFiles` сохраняет их интерфейс и даёт `structure: OK` без нового типа файлов.

## Предмет

Один результат: принять текст стандарта и две правки `STRUCTURE.md` из PR #158 **после** независимой сверки каждой заявленной проверки с живым файлом кода/конфига; обеспечить воспроизводимую команду сверки из дерева продукта вместо текущих `tmp/`-свидетельств. Стандарт описывает текущие нормы и явные долги «ЦЕЛЬ (код не соответствует: …)»; долги не чинятся под этим номером. Таблица `mobile/scripts/coding-standards-claims.tsv` допускается одной точной строкой в `mobile/structure-policy.json` → `mobileFiles` для прохождения обязательного CI `quality`. Это не новая lint-политика, не миграция существующего кода и не экранный предмет.

## Инварианты

1. Единственный текст стандарта — `docs/CODING-STANDARDS.md`; структура/границы — `STRUCTURE.md` + `mobile/structure-policy.json`. Допустимый носитель правила — существующий файл кода, теста, конфигурации или сценария в product tree, а не цитата в самом стандарте, произвольный текст в выводе скрипта либо неотслеживаемая копия. В каждом утверждении проверяющей таблицы явно указаны идентификатор правила, номер раздела стандарта, точная формулировка проверяемого утверждения, вид проверки и путь носителя; строки разделены TAB, один id = одно проверяемое утверждение. Пустой носитель, пустой glob, неверный путь и невозможная проверка — именованный отказ, не зелень.
2. Заявленное правило с проверяемым носителем имеет свидетельство на том носителе; заявленный носитель имеет явную обратную ссылку на правило стандарта в таблице проверки. Таблица обязана проверять существование и ссылку на конкретную непустую строку **в своей секции** стандарта, а не только находить регулярное выражение где угодно в дереве. Двусторонность относится к **объявленному множеству утверждений/носителей**, не ко всем файлам и всем семантическим фразам; полноту отражения всех смысловых норм проверяет независимый ревьюер по §§1–16. Новое правило без проверяемого носителя либо явной пометки «ЦЕЛЬ (код не соответствует: перечень файлов)» не проходит. ЦЕЛЬ: каждый названный файл реально несёт заявленное нарушение, но это не доказательство текущего соответствия правилу.
3. База утверждений — проверенный снимок PR, 123/123; разбиение по типам и поля — §Существующее. `tmp/claims.tsv` и `tmp/verify-standard.sh` допустимы как факт исходного замера, но при поставке воспроизводимые checker + таблица должны быть отслеживаемыми файлами `mobile/scripts/` продукта; checker не полагается на scratch, не выдаёт rc 0 на нулевом количестве утверждений и называет id неудачного утверждения. Новые версии требований не требуют фиксировать число 123 навечно; для кандидата #158 это мера согласованности двух независимых перечней (таблица ↔ стандарт) до мержа.
4. `mobile/scripts/check-context-sources.py` судит пины этого контракта против конкретного product worktree после помещения **побайтовой копии** контракта в относительный путь `.harness/contracts/162-standart-koda-mob.md` внутри disposable worktree продукта; абсолютный путь контракта вне продукта его CLI отвергает по конструкции. Сначала снять ожидаемые значения в память проверяющего; изменение стандартного текста после съёма не становится новым оракулом. Продуктовый `contextPack` добавляет одну mandatory строку `kind=rules`, `path=docs/CODING-STANDARDS.md`, `roles=architect,implementer,reviewer,adversary` после reviewer и merge #158; остальные строки не теряются.

## Док-приёмка

Профиль architecture 027: документ фиксирует правила уже предложенного PR, evidence — проверяемую трассировку к коду/конфигу. Док-гейт проверяет форму и source pins, а не смысл правила. Продуктовые `docs/CODING-STANDARDS.md` и `STRUCTURE.md` меняются в PR #158; `docs/CODING-STANDARDS.evidence.json` создаётся при поставке с компонентами/связями/решениями/отказами согласно профилю architecture. До реализации preflight черновика в харнессе проверяет форму; `--check` загрузчика 027 принимает лишь `contracts/(0+\d+)-…` с frozen-тегом в **том же** репозитории и потому не может проверять контракт `162` в `.harness/contracts/` продукта. Проверка evidence для 162 ниже использует экспортированные валидаторы 027 напрямую, без подмены номера контракта; семантика текста остаётся cognitive-only (ловец — независимый reviewer).

```json
{
  "type": "documentation",
  "version": 1,
  "profile": "architecture",
  "outputs": {"markdown": "docs/CODING-STANDARDS.md", "evidence": "docs/CODING-STANDARDS.evidence.json"},
  "required": {
    "components": ["Стандарт", "Структура", "Код", "Конфиг", "Сверка"],
    "links": ["Стандарт-к-носителю", "Носитель-к-правилу", "Скрипт-к-таблице"],
    "decisions": ["Приоритет", "Цель-не-реализация", "Трекаемая-сверка"],
    "failures": ["Правило-без-носителя", "Носитель-без-правила", "Пустая-выборка"]
  },
  "assertions": [],
  "sources": [{"id":"PR158", "kind":"external", "address":"https://github.com/a3ka/Complior-mob/pull/158", "freshness":"historical", "verification":"cognitive-only"}],
  "questions": []
}
```

## Приёмочный критерий

- Дано: черновик харнесса; когда: `bash scripts/check_document.sh --root . --contract contracts/162-standart-koda-mob.md --preflight`; тогда: rc 0, форма doc-профиля; негативная пара: удалить `## Док-приёмка` → rc 1 «нет раздела».
- Дано: worktree PR #158 с отслеживаемыми checker и таблицей, стандарт и STRUCTURE из указанного SHA, честные носители; когда: `bash mobile/scripts/verify-coding-standards.sh` из корня продукта; тогда: rc 0, каждое утверждение адресовано id и своим носителем, количество зелёных = количеству объявленных ненулевых утверждений. Пары на disposable копии продукта: удалить файл носителя одного id → rc 1 с этим id; добавить в объявленный перечень носитель без соответствующей строки правила → rc 1 «носитель без правила» с путём; добавить правило без проверяемого носителя и без объявленной ЦЕЛИ → rc 1 «правило без носителя» с id. Пары исполняются отдельно, честная исходная копия зелена после каждой отмены мутации. Дано: отдельная disposable копия того же commit в раскладке `quality` после выноса временных каталогов и пачек действующим workflow продукта; когда: `node mobile/scripts/check-structure.cjs` из корня продукта; тогда: rc 0 `structure: OK` при ровно одной новой строке `"scripts/coding-standards-claims.tsv"` в `mobile/structure-policy.json` → `mobileFiles`. Пара: убрать эту строку на отдельной копии → rc 1 `mobile/scripts/coding-standards-claims.tsv: file outside allowed location/type`, вернуть → rc 0.
- Дано: product commit `54fd5c83c7b4e9e5ad5fc6dd1e162c9766bbfea4`, единственная 162-правка после `932ee4a54352a8731fbb6570da30faae7406c10a`, и слитый кандидат PR #158 `a1b3d41a8d6fa6f79779eef6732c191d874529ba` поверх 143 `50699aeea16675980cb92175248c03ac1fbc62ab`; когда: `python3 fixtures/workshop_project/standart_koda_162/check_policy_delta.py --repo <P> --base 932ee4a54352a8731fbb6570da30faae7406c10a --feature 54fd5c83c7b4e9e5ad5fc6dd1e162c9766bbfea4 --main 50699aeea16675980cb92175248c03ac1fbc62ab --head a1b3d41a8d6fa6f79779eef6732c191d874529ba` из корня харнесса (`<P>` — абсолютный путь одноразового клона продукта с этими коммитами); тогда: rc 0, только `mobile/structure-policy.json` изменён в диапазоне 932ee4a..54fd5c83, его `git diff --numstat` — `1<TAB>1<TAB>mobile/structure-policy.json` (однострочный JSON-массив заменён при добавлении элемента; TAB — байт 0x09), на обоих диапазонах 932ee4a..54fd5c83 и 50699aeea..a1b3d41a8 JSON-политика отличается **ровно** добавлением `"scripts/coding-standards-claims.tsv"` последним элементом `mobileFiles`, остальные ключи и прежние элементы без изменений. Диапазон 932ee4a..HEAD нельзя судить как 162-дельту: HEAD включает 143. Негативные пары: второе изменение в изолированном 162-diff → rc 1 «diff содержит второй файл или не содержит политику»; добавление другого элемента, удаление прежнего элемента либо изменение другого ключа политики → rc 1 «policy не одна разрешающая строка». Когда: `bash fixtures/workshop_project/standart_koda_162/red_policy_delta.sh` из корня харнесса; тогда: rc 0, честная пара зелена, каждый из трёх обманных JSON-входов красен своей проверкой.
- Дано: тот же disposable worktree с `.harness/contracts/162-standart-koda-mob.md` (копия frozen-текста из харнесса); когда: `python3 mobile/scripts/check-context-sources.py --root . --contract .harness/contracts/162-standart-koda-mob.md`; тогда: rc 0 `CITATIONS OK count=5`. Пара: изменить один байт стандарта → rc 1 `CITATIONS FAIL: SHA256: docs/CODING-STANDARDS.md`. Исходный живой контроль перед заморозкой при отсутствии продуктового checker: `bash tmp/verify-standard.sh` → rc 0, 123/123; `python3 mobile/scripts/check-context-sources.py --root . --contract .harness/contracts/151-standart-koda.md` → rc 0, если сохранён неотслеживаемый черновик 151 — только диагностика, не приёмка 162.
- Дано: опубликованный документ и evidence в disposable product checkout с побайтовой копией контракта 162 в `.harness/contracts/162-standart-koda-mob.md`; когда: из корня харнесса `cmp -s <(git show frozen/contracts/162/3:contracts/162-standart-koda-mob.md) "<P>/.harness/contracts/162-standart-koda-mob.md"` (bash, `<P>` — абсолютный путь product checkout), затем следующая команда с тем же `<P>`; тогда: оба rc 0, соответствие evidence архитектурному профилю 027 по валидаторам того же `scripts/doc_contract.ts`:

  ```sh
  node --input-type=module -e '
  import {readFileSync} from "node:fs";
  import {join} from "node:path";
  import {parseSpecFromMarkdown,validateSpecSchema,validatePackageAgainstSpec,checkIdSets,checkEvidenceOwnership,checkSectionMarkers} from "./scripts/doc_contract.ts";
  const root=process.argv[1], spec=parseSpecFromMarkdown(readFileSync(join(root,".harness/contracts/162-standart-koda-mob.md"),"utf8"));
  const errors=[validateSpecSchema(spec)];
  if (!errors[0]) {
    const pkg=JSON.parse(readFileSync(join(root,spec.outputs.evidence),"utf8"));
    errors.push(validatePackageAgainstSpec(spec,pkg),checkIdSets(spec,pkg),checkEvidenceOwnership(spec,pkg),
      checkSectionMarkers(readFileSync(join(root,spec.outputs.markdown),"utf8"),spec.required.sections ?? []));
  }
  const problem=errors.find(Boolean); if (problem) {console.error("ОТКАЗ DOC: "+problem); process.exitCode=1;}
  ' <P>
  ```

  Пары на отдельных disposable копиях: убрать `Пустая-выборка` из `failures` evidence → rc 1 «package.failures не покрывает required: Пустая-выборка»; убрать `Скрипт-к-таблице` из `links` → rc 1 «package.links не покрывает required: Скрипт-к-таблице»; вернуть поля → rc 0. Отсутствие документа/evidence не считается зеленью; проверка не утверждает полноту или истинность каждой семантической нормы стандарта — это cognitive-only, ловец reviewer. `scripts/check_document.sh --check` на пути 162 даёт rc 2 `NOT_IMPLEMENTED` из-за ограничения загрузчика 027 и **не** является этой приёмочной командой.
- Дано: ветка продукта после reviewer и merge #158, отслеживаемый `mobile/scripts/check-coding-standards-context.sh`, mandatory строка стандарта для четырёх ролей, **замороженный проектный** контракт `<контракт-проекта>` с тегом `frozen/contracts/<контракт-проекта>/<версия>` в git продукта и `.harness/registry/trace.tsv` (готовит оркестратор); когда: `bash mobile/scripts/check-coding-standards-context.sh --repo . --contract <контракт-проекта> --make-task <корень-харнесса>/scripts/make_task.sh` из корня продукта; тогда: rc 0 только если checker для **каждой** роли architect, implementer, reviewer, adversary запускает указанный `make_task --repo . --role <роль> --contract <контракт-проекта>` (для reviewer добавляет `--task-file <временный-служебный-файл>`), проверяет в `harness.project.json` применимую к этой роли строку `kind=rules, path=docs/CODING-STANDARDS.md, mandatory=true` и сверяет **самостоятельные точные строки внутри секции RULES** её пакета: `RULES: docs/CODING-STANDARDS.md` и все прочие применимые к роли правила из профиля (без потери существующих). Пара на disposable копии после merge: удалить роль из mandatory-строки профиля (или удалить строку целиком) → та же команда rc 1 с именем роли и отсутствующего правила; изменение остальных профильных правил не считается успешной парой. До merge #158 этот пункт NOT_RUN.

## Модель угроз

ЗАЩИЩАЕТ:
- Объявленный носитель не исчезает бесследно, пустая выборка становится отказом с именем идентификатора, а несоответствие пина документа продукту выявляется до принятия.
- Конформны утверждения разрешённых типов с явной строкой внутри существующего раздела стандарта и носителем в дереве продукта; валидный контрпример сохраняет результат при замене значений внутри этой грамматики и расходится на конформном входе.
НЕ ЗАЩИЩАЕТ:
- Семантика произвольного правила не выводится из одного совпадения паттерна в комментарии, а незаявленные носители вне перечисленной области требуют отдельного содержательного суда ревьюера.
- Будущий дрейф после снимка и действительность обещаний бэкенда остаются вне проверки; scratch-цель g05 устанавливает наличие `tapOn`, но не отсутствие `assertVisible` непосредственно перед ним — смысл цели судит независимый reviewer, а дрейф — предметная приёмка срезов.

## Порядок и граница поставки

Контракт v+1 → critic по действующему лёгкому треку (оркестратор) → freeze → reviewer повторяет CI-раскладку `check-structure` на слитом SHA и сверяет изолированную 162-дельту к 932ee4a (ровно одна добавленная запись политики) и актуальный пин STRUCTURE.md → merge #158 по действующему маршруту после зелёного обязательного CI → оркестратор обеспечивает замороженный контракт проекта + `.harness/registry/trace.tsv` и ставит mandatory contextPack-строку для четырёх ролей → критерий контекста на живом продукте. Checker/table/evidence уже поставлены implementer в 932ee4a, разрешение `mobileFiles` — в 54fd5c83; существующий doc-пакет проверяется валидаторами 027 без изменения загрузчика 027. Советы Rev162 С-1 (пустой id), С-2 (c102/c16/c17) и С-3 (перепин SHA стандарта на финальной версии PR) остаются за пределами этой механической правки.

ЗОНА architect: contracts/162-standart-koda-mob.md fixtures/workshop_project/standart_koda_162/check_policy_delta.py fixtures/workshop_project/standart_koda_162/red_policy_delta.sh
ЗОНА implementer: docs/CODING-STANDARDS.md docs/CODING-STANDARDS.evidence.json STRUCTURE.md mobile/scripts/verify-coding-standards.sh mobile/scripts/coding-standards-claims.tsv mobile/scripts/check-coding-standards-context.sh harness.project.json mobile/structure-policy.json
ПЕРЕСЕЧЕНИЕ implementer: mobile/structure-policy.json — 143 владеет структурной политикой и CI-выносом экранных пачек; 162 добавляет только `"scripts/coding-standards-claims.tsv"` в `mobileFiles`, не меняя остальные элементы политики и механизм 143
ЗОНА critic: verdicts/critic/
ЗОНА reviewer: verdicts/review/

ПРЕДПОСЫЛКИ: продуктовый checkout с PR #158, Python 3 и Bash, GNU grep -P и jq (текущий scratch использует их); возможность поместить frozen-контракт в disposable product worktree для цитатной проверки. CI проекта, secrets, variables и environments эта пачка не меняет. Проверка контекста требует идентичных байтов файлов product PR.

ПРОВОДКА:
- guard=scripts/check_document.sh

ПРОВОДКА-ЭНФОРСМЕНТ: существующий документный guard `scripts/check_document.sh` подключён к CI харнесса и вызывается в preflight и продуктовой приёмке 162; новый продуктовый checker+таблица отслеживаемы и исполняются как точечная приёмка в Complior-mob, но не являются guard-файлом харнесса и не заявляются как CI-гейт. Роль/charter харнесса не меняются, CI dev-harness не получает зависимости от чужого product checkout; source-check уже существует в продукте.

## Незаполненные требования:
нет
