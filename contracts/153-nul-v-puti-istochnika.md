# Контракт 153 — ложный отказ NUL в пути источника sourceCanon

КЛАСС ЗАДАЧИ: КОДОВЫЙ — контракт, красная батарея и ремонт существующего шлюза.
КЛАСС РИСКА: обычный — меняется диагностика/приём допустимого пути источника; права, авторизация, безопасность доступа, деньги, ПД/health и юридически значимые действия не меняются. Ограждения источников сохраняются.
КОНТЕКСТ: слово владельца 2026-11-01 ~11:20 «эту ошибку в механизме харнеса надо взять в починку прямо сейчас»; репро бэкенда Complior-back: sourceCanon.path `migrations/001_core.sql` ложно даёт `SOURCE_CANON_INVALID: NUL в пути` при pre_critic/done по 142/143/144. Это блокирует штатный done; ручные done-теги не доказывают починку шлюза.

## Существующее

Существующий публичный CLI `scripts/check_project_sources.sh --repo R --contract P --stage pre_critic|done` получает effective sourceCanon от `scripts/profile_resolver.sh`, после проверки источника вызывает объявленный gate. В проверке пути `case "$p" in *\0*)` bash читает `\0` как литерал цифры 0: путь `migrations/001_core.sql` отказывает как NUL. Переменная bash не может хранить байт NUL.

`scripts/profile_resolver.sh:scan_canon` уже проверяет JSON-строки path и gate на `contains("\u0000")` ДО извлечения путей через `jq -r`/`mapfile`; источник грамматики сохраняется единым. Его существующие отказы `SOURCE_CANON_INVALID` наблюдаемы отдельным входом с JSON `"source\u0000.md"`. Повторный NUL-предикат над переменной bash не чинить другим строковым шаблоном.

`scripts/pre_critic.sh` и `scripts/done_contract.sh` вызывают этот CLI; менять их не нужно. `fixtures/workshop_project/rezhim_996/probe.py` + `probe.sh` судят режим проекта и sourceCanon, но не предъявляют путь с цифрой 0; это замороженная батарея, остаётся зелёной. `contracts/996-rezhim-proekta-polnyj-cikl.md` §Lifecycle и `contracts/112-podklyuchenie-proekta.md` описывают существующий шлюз и миграции бэкенда; текст замороженного 996 не правится. `registry/plan.tsv` — отдельная раздача консультанта, не зона этой пачки.

## Frontier и граница

Выбор: убрать неисполнимый NUL-case из `check_project_sources.sh` и оставить существующую проверку исходного JSON в `profile_resolver.sh`. Вариант «искать NUL в bash-переменной» отвергнут: байт теряется при командной подстановке; вариант «дублировать jq-парсер в consumer» отвергнут: две грамматики расходятся. Измеренная боль — ложный отказ пути с 0, не перепроектирование путей источников.

Соседний `*..*` отвергает также `a..b.md`; резолвер 996 запрещает подстроку `..` в исходном JSON (`contains("..")`). Изменение его замороженной грамматики — новый класс отказа и отдельный контракт; 153 сохраняет её без ослабления. Конформные пути этой пачки не содержат `..` даже как подстроку; отрицательный вход с компонентом `..` остаётся красным.

## Предмет и инварианты

Один результат: объявленный в sourceCanon относительный regular file с цифрой 0 проходит тот же публичный шлюз и запускает gate, а настоящий JSON NUL отказывает ДО преобразования пути в bash; остальные проверки остаются действующими.

- И-1. Существующие относительные regular files `migrations/001_core.sql`, `10.sql`, `a0b/0.md` дают rc 0 при gate rc 0: отсутствие stderr/stdout и фактический запуск gate; цифра 0 сама по себе не основание `SOURCE_CANON_INVALID`.
- И-2. JSON path с `\u0000` в `harness.project.json` даёт rc 1 `SOURCE_CANON_INVALID` и причину `path NUL` до извлечения путей и до исполнения gate. Сравнение исходного JSON выполняет действующий resolver, не дублирующий парсер в consumer.
- И-3. Абсолютный path и path с компонентом `..` дают rc 1 `SOURCE_CANON_INVALID`; симлинк на существующий файл вне R даёт rc 1 `SOURCE_CANON_INVALID: источник вне репозитория`; каталог и FIFO вместо regular file дают rc 1 `SOURCE_CANON_INVALID: источник не regular file`. Отказы 996 о симлинках и каталогах не ослабляются.
- И-4. Шов `pre_critic|done`, режим отсутствующего канона, argv/cwd/HEAD и коды существующего gate не меняются. Аддитивная батарея 153 дополняет, но не правит frozen 996; его батарея остаётся зелёной на реализации.

## Приёмка

Команда `W` = `bash fixtures/workshop_project/nul_istochnika_153/probe.sh` из корня харнесса; все миры — независимые временные git-репозитории. Конформный положительный вход: JSON sourceCanon с существующим относительным regular file внутри R, приоритетом 0 и исполняемым argv gate; отрицательные входы нарушают ровно названное свойство (JSON NUL, абсолютный/`..`, каноническое положение вне R, не-regular файл). Контрпример стаба валиден, если его результат расходится с честным на указанном конформном входе, независимо от значения временного корня; JSON NUL — отрицательный грамматический вход с требуемым отказом, не файл с NUL на диске.

1. Дано дерево до реализации; когда `W`; тогда rc 1, `CELLS=9 GREEN=6`: только пути с цифрой 0 красны, каждый по собственному отказу `SOURCE_CANON_INVALID: NUL в пути`.
2. Дано модель честного ремонта (одна отмена ложного NUL-case, действующий resolver сохранён); когда `W --model` и `W --model --seed 7`; тогда оба rc 0, `CELLS=9 GREEN=9`. Парный негатив: когда `W` до ремонта, тогда rc 1 с вышеуказанными тремя ложными отказами.
3. Дано модель и обманные копии реальных скриптов; когда `W --stabs`; тогда rc 0, `SVJAZI=8 CAUGHT=8 LIVE=0`, каждый стаб пойман собственным входом по реальному исполнению CLI: ложный 0 — backend; безусловное принятие и пропуск JSON NUL — path NUL; пропуск абсолютного — absolute; пропуск компонента `..` — dotdot; отключение канонизации — outside; замена regular file на существование — directory и fifo. Негатив: выживший стаб → rc 1 `STAB_SURVIVED`.
4. Дано реализация в scripts/check_project_sources.sh; когда `W` и `W --repo`; тогда оба rc 0, `CELLS=9 GREEN=9`. Парный негатив — отдельные клетки JSON NUL, absolute, dotdot, outside, directory, fifo по И-2/И-3: каждая rc 1 по именованной причине.
5. Правило совместимости: `bash fixtures/workshop_project/rezhim_996/probe.sh` на реализации → rc 0; отрицательные клетки источника 996 остаются красными внутри своей батареи (её общий итог rc 0).
6. Правило ворот: `bash scripts/pre_critic.sh contracts/153-nul-v-puti-istochnika.md` и `bash scripts/check_ceilings.sh` → rc 0; `bash scripts/check_zones.sh` на ветке → rc 0. Сухие done-ворота `bash scripts/check_provodka.sh . contracts/153-nul-v-puti-istochnika.md` → rc 0.

## Зоны и порядок

ЗОНА architect: contracts/153-nul-v-puti-istochnika.md fixtures/workshop_project/nul_istochnika_153/
ЗОНА implementer: scripts/check_project_sources.sh
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_project_sources.sh — 996 удалить лишь ложный NUL-case; проверка JSON NUL в существующем resolver остаётся источником грамматики, проверки -f/readlink, CLI и gate не меняются; frozen-текст 996 неизменен.
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 добавить только строку self-test 153 после реализации; `gen_ci_steps.sh --write`, `--check` rc 0, чужие шаги не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка CI 153; чужие шаги не трогаются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только новая строка CI 153; чужие шаги не трогаются.
Порядок: architect предъявляет `W --model` зелёным и `W` красным → implementer меняет скрипт и предъявляет `W` зелёным плюс совместимость 996 → orchestrator подключает строку CI и проводит суд. Батарея — действующий потребитель исправленной ветки.

ПРЕДПОСЫЛКИ:
- setting CI-харнесса: git, jq, bash, python3 в PATH; секретов, variables, environments и внешней сборки не требуется.

ПРОВОДКА:
- guard=fixtures/workshop_project/nul_istochnika_153/probe.sh
ПРОВОДКА-ЭНФОРСМЕНТ: только существующее требование sourceCanon (996) проверяется исполнением CLI на путях с цифрой 0 и отрицательных входах; новой поведенческой нормы роли нет. CI-шаг после реализации судит безфлаговый `W`.

## Модель угроз

ЗАЩИЩАЕТ:
- ложный отказ на конформном пути с цифрой 0 и ложное принятие настоящего JSON NUL;
- ослабление прежних отказов по абсолютному/`..`/симлинку наружу/каталогу/FIFO;
- статический плацебо-тест: батарея исполняет шлюз в отдельных git-мирах, сравнивает код и структурную причину в stderr, oracle задан в памяти проверяющего до запуска.

НЕ ЗАЩИЩАЕТ:
- имена файлов с подстрокой `..` без компонента: существующая замороженная грамматика 996 запрещает их, соседний дефект — отдельный предмет;
- непредусмотренные нестандартные файловые системы, изменяемый между readlink и gate файл (TOCTOU): отдельный класс отказа, не измерен этим предметом;
- поведение самого пользовательского sourceCanon.gate: 153 судит запуск и отказ уровня шлюза, не корректность содержимого проверки проекта.

## Незаполненные требования:
нет
