# Контракт 210 — публикация frozen-текста не становится правкой устава задним числом

КЛАСС ЗАДАЧИ: кодовый.
КЛАСС РИСКА: рисковый — меняется допуск стража устава (безопасность и права на изменение утверждённых документов); после реализации adversary → reviewer.
КОНТЕКСТ: новый предмет по слову владельца 2026-11-22 «не судить коммит, внёсший текст контракта до публикации frozen-тега»; номер id/CONTRACT/210, строка registry/contracts.tsv выданы механизмом. Owner-затравка заменяется этой спекой; это не разрешение изменять frozen-текст без owner-канала.
СДАЧА: fixtures/workshop_project/charter_tekst_do_tega_210/SDACHA.md

## Боль и обещание

Порядок 130 «текст → тег после влива» не делает GitHub-merge предком коммита тега: merge 409836ed5d918d4ecb16f132b8f6e26d287b32cc имеет второй родитель fd294feda1b08c36d08f90dd3b2d50e3f083d445, на котором стоит frozen/contracts/204/1. Merge входит в диапазон тег..HEAD и меняет путь относительно первого родителя. Поэтому после публикации тега полный check_charter судил его как M без разрешения. Sync-merge 66a37efff06a1da72febe8e36b9bb37f8ff6d3eb имеет второй родитель 409836ed5d и повторяет отказ в ветке 205. Это измеренная боль #1240/#1241 и двери Д3, снятая разово owner-парами 70/71 (#1244).

Один результат: внесение того же frozen-блоба через связанную с заморозкой историю не требует повторной строки разрешения в merge; иная уставная дельта продолжает судиться. Наблюдение — rc, полный stdout и полный stderr настоящих CLI на независимых одноразовых Git-репозиториях. Происхождение содержания устанавливается равенством Git-блобов и опубликованного объекта тега, а не словами «frozen» в сообщении.

Совместимость: сохраняются merge-суд по первому родителю 019, единственное кольцо 022, грамматика razreshil и grandfather-список 046/065, per-document окно и кеш 083, оба обхода 113, порядок публикации 130 и ограничения merge main→wip 167. Меняется только основание освобождения пары (коммит, путь), не разрешительная грамматика.

## Существующее

Срез — owner-база b4a39c229f9e31b827e7348bece1f3bf8d4ef7a7; факты топологии 204 сняты Git plumbing. Зоны сверены с union высших живых frozen-блобов через zones_load; историческое упоминание файла не подменяет его нынешнюю зону.

- scripts/check_charter.sh уже строит область из AGENTS.md/ROADMAP.md при ustav/1 и plans/contracts при первой заморозке /1. До /1 контракт — черновик. Есть медленный --oracle и быстрый/default/--incr, общие is_charter_path, charter_diff_paths, razreshil и grandfather_pair. Новая разрешительная грамматика не нужна.
- Предки коммита /1 уже исключены диапазоном /1..HEAD. Новый дефект — не они, а land/sync-merge вне этой предковой области. Дополнительный тест предковости самого C в новом предикате был бы мёртвым: штатный pre-push также исключает историю опубликованных origin-ref-ов.
- .githooks/pre-push импортирует тот же check_charter через CHARTER_LIB=1 и судит M/D по каждому пути. Его место вызова обязано использовать то же освобождение; иначе CLI починен, а передача той же истории остаётся запрещённой. Снимок живого main и исключение 167 не меняются.
- scripts/check_contract_frozen.sh импортирует razreshil/grandfather_pair из того же файла; проверяет неизменность HEAD-блоба и аннотированность frozen-тегов (Н-35). Его окно (б), будущие v+1, список и реализация в этой пачке не меняются. Страж staged продолжает делегировать основному check_charter, а не получает второй предикат.
- scripts/lib_registry.sh сравнивает имена и допускает unknown-remote читателю. Это не свидетельство, что конкретный локальный тег опубликован с тем же объектом: новый допуск требует отдельной точной сверки объекта с живым origin. Прежняя offline-семантика путей, которым это освобождение не нужно, сохраняется.
- На origin frozen/contracts/204/1 — аннотированный объект 58117ad6fccac6d34950dcb558641656a2a128fd → fd294feda1b08c36d08f90dd3b2d50e3f083d445; оба merge несут contracts/204 с блобом 9288a6cd6979733546fade0d02efbc64445ac0b9. В изолированной копии локальная ссылка peeled (тип commit), не tag: её не исправляют и не объявляют подлинной. Миры батареи создают настоящие аннотированные теги и отдельный доступный origin.
- Пары 70/71 остаются буквально в grandfather_pair. Их допуск и точечность проверяются через существующий библиотечный интерфейс на настоящих SHA; новые именные пары не добавляются. Синтетические истории воспроизводят оба класса без этих SHA.
- fixtures/check_charter/ и fixtures/charter_fast_113/ уже защищают разрешения, merge-дельту, per-document окна, SHA-256 и дифференциал режимов. Устройство новой семьи берётся из fixtures/workshop_project/karta_vyzova_204/: реальные CLI, модель, данные привязок, SDACHA. Исторические уроки Н-427/Н-445/Н-448/Н-449 и А-965 запрещают новый ручной grandfather как системный ремонт.

## Frontier

1. Продолжать добавлять именные grandfather-пары. Отвергнуто: измерены уже два последовательных случая 204; тот же порядок повторяется на каждом новом контракте, список не реализует свойство.
2. Освобождать любой merge или любой равный HEAD блоб. Отвергнуто: первое прячет evil merge, второе не удостоверяет frozen-источник и допускает боковое пере-внесение/возврат после тега.
3. Выбрана конъюнкция точного блоба, связанной истории и подлинного опубликованного /1. Для land второй родитель — предок коммита тега; для sync наоборот, коммит тега — предок второго родителя, который сам несёт тот же блоб. Вторая форма необходима именно для измеренного 66a37eff; назвать её первой означало бы снова не закрыть боль.

## Решение и инварианты

Обозначения: P — прямой путь contracts/NNN-<slug>.md в существующей грамматике next_id; T — коммит аннотированного refs/tags/frozen/contracts/NNN/1; B(X,P) — имя Git-блоба по пути в коммите X. Предок включает равенство. Git сам выдаёт идентификаторы SHA-1/SHA-256; входного поля с произвольной строкой SHA не вводится.

- И1 — область прежняя. История самого T и его предков не судится /1..HEAD; до первой заморозки файл остаётся черновиком. Другой номер, /01, /v1, произвольная метка и последующая /2 не заменяют /1. Plans, AGENTS.md и ROADMAP.md новым освобождением не охватываются.
- И2 — освобождение только при B(C,P) = B(T,P). Это побайтовое равенство именами блобов: пустота, NUL, CRLF, объём и кодировка не нормализуются. Другой блоб, включая LF вместо CRLF, остаётся под прежним судом.
- И3 — для судимого merge C его второй родитель Q должен сам нести B(Q,P) = B(T,P) и быть сравнимым с T: Q предок T (land) либо T предок Q (sync). Связь с другим родителем, общая когда-то база или боковая ветка сами по себе не основание. Суд по первому родителю 019 не изменяется.
- И4 — обычная правка после /1, боковое пере-внесение и возврат к frozen-байтам после иной правки не получают освобождения. Новая /2 не амнистирует изменение после /1: остаётся действующий owner/v+1-маршрут. Разрешённые ранее изменения по razreshil и grandfather проверяются первыми и не меняют своего сообщения.
- И5 — основание опубликовано: локальный ref /1 должен иметь тип tag, разыменовываться в коммит с P и буквально совпадать объектом с одноимённым ref живого настроенного origin. Не сравниваются только peeled-коммиты, число/имена тегов или annotation-текст. Лёгкий тег основания не даёт; поддельный локальный объект не даёт допуска даже при том же peeled-коммите.
- И6 — неизвестность не чисто. Нет origin/связи/опубликованного одноимённого объекта либо нельзя прочитать нужный тег/блоб/предковость — для нуждающегося в новом освобождении кандидата rc 1 с самостоятельной причиной «не могу проверить публикацию заморозки» и выходом проверить origin, тег и объекты. Отсутствие /1 у черновика — не этот случай; прежняя область не расширяется ради проверки отсутствующего основания.
- И7 — допуск исключительно по паре (C,P). Он не оправдывает другую уставную дельту того же коммита. Смешанный merge остаётся красным по другому пути, без ложного отказа по опубликованному P.
- И8 — grandfather-список не правится: 70/71 остаются точечными прежними разрешениями, не универсальной амнистией. Правило поглощает их класс функционально на новых историях; удаление записей и добавление новых — вне предмета без отдельного слова владельца.
- И9 — один библиотечный предикат нового допуска используется обеими ветвями основного check_charter и устав-дельта циклом pre-push. Default, --oracle и --incr на одной истории дают одинаковые предметные решения; прежние различия порядка строк, счётчиков и incr-маркера сохраняются. На зелёном incr кеш равен проверенному HEAD.
- И10 — проверка не меняет HEAD, staged-содержимое и файлы судимого мира. Модель — предъявляемый кандидат механизма, не новый production-страж. Производственную реализацию и CI подключают после заморозки; ред-батарея не достраивает выбранное --repo дерево.

## Модель угроз

ЗАЩИЩАЕТ:
- от повторного суда за публикацию frozen-байтов через land/sync-merge: проверяются настоящий эффект CLI и полные потоки вывода, включая отрицательные решения по соседним путям;
- от подмены «замороженного» содержания, локального/лёгкого/переаннотированного тега и несвязанной истории: проверяются блоб, объект origin и предковость, а не свободная метка;
- от амнистии новой правки или всего смешанного коммита и от молчаливого допуска при недоступном авторитете: в модели это именованные отрицательные результаты.

НЕ ЗАЩИЩАЕТ:
- подлинность человеческой воли, администрирование/переписывание самого origin и подмену настроенного origin вне штатного процесса: cognitive-only, ловцы adversary/reviewer и действующие owner/публикационные двери; криптографическую подпись тегов предмет не вводит;
- новые освобождения для plans, ROADMAP.md/AGENTS.md, последующих версий /2+, draft-блобов вне истории /1 или octopus-переноса только через третий родитель: прежний строгий суд сохраняется, отдельный предмет по измеренной боли, ловец reviewer;
- будущие v+1-окна check_contract_frozen/check_zones: новый non-grandfather merge в них по-прежнему судится через razreshil; полнота прежнего HEAD-only поиска удалённых контрактов также не меняется. Ловцы существующие гарды и reviewer, отдельный предмет по повторной боли;
- сговор автора батареи с субъектом или универсальность конечного списка мутаций: ловец независимый adversary перед reviewer, не разрешение нарушать инварианты.

Конформный контрпример: поддерживаемое имя P, настоящее Git-дерево с первой заморозкой/явно заданной её подделкой или недоступностью, обычная либо двухродительская история. Блоб — любые байты; замена значений NNN, содержимого и канонического object-format не меняет критерий. Контрпример валиден при расхождении на таком входе, а не при поломке инструмента/оракула. Разрешённые структуры создаёт git plumbing; Git-протокол не заменяется двойником. Ожидания и числа снимаются в память до запуска субъекта. Привязки мутаций находятся исключительно в probe.py и stabs.tsv (Н-39). Отсутствие программы/субъекта, таймаут, пустая выборка, неприменимый якорь и синтаксически сломанная мутация — rc 2 NOT_IMPLEMENTED, не поимка. Потоки субъекта сравниваются байтами без decode/strip/слияния stderr в stdout.

## Приёмка

W — bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh. --repo ROOT выбирает реальные check_charter и pre-push этого дерева; --model/--stabs заменяют только их предъявленными моделями, остальные библиотеки настоящие. Миры создаются последовательно под TMPDIR и удаляются сразу; основной чекаут, доставка и чужой origin не записываются.

1. Дано: production до реализации; когда: `bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --repo .`; тогда: rc 1, красные именованы. Это историческое красное-до, не rc-нестабильный ряд листа. После реализации та же команда обязана дать rc 0, KRASNYE=0: отрицательные subject-rc 1 также считаются зелёными клетками при полном совпадении ожидаемого отказа.
2. Дано: честная исполняемая модель; когда: `bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model`; тогда: rc 0, KLETKI=33 ZELENYE=33 KRASNYE=0 (прогон пачки). Набор включает обе merge-формы, предковую историю, все режимы, hook, боковое пере-внесение, пост-тег правку/возврат, разные пути одного коммита, тип/публикацию/подмену/грамматику тега, исчезнувший путь тега, отсутствие origin/связи, пусто/NUL/CRLF/длинный блоб, иной номер и настоящий SHA-256.
3. Дано: адресные изменения модели с однократными якорями; когда: `bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --stabs`; тогда: rc 0, MUTACII=15 SVJAZI=16 POIMANY=16 ZHIVYH=0 (прогон пачки). Перед каждым предъявлением честный контроль зелёный, результат изменённого субъекта сверяется с полным отдельным ожиданием, не с произвольным ненулевым rc.
4. Правило формы: `bash scripts/check_spec_ready.sh . contracts/210-charter-tekst-do-tega.md`, `bash scripts/check_ids.sh .`, `bash scripts/check_ceilings.sh .`, `bash scripts/check_precision_gate.sh . contracts/210-charter-tekst-do-tega.md`, `bash scripts/check_threat_model.sh . contracts/210-charter-tekst-do-tega.md`, `bash scripts/check_predposylki.sh . contracts/210-charter-tekst-do-tega.md`, `bash scripts/check_provodka.sh --grammar . contracts/210-charter-tekst-do-tega.md` → каждый rc 0.
5. Правило сдачи: `bash scripts/check_sdacha.sh . contracts/210-charter-tekst-do-tega.md --run` → rc 0 при бюджете листа 900 с; `bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md` → rc 0 «КРИТИК: дверь зелёная». Предыдущего вердикта нового предмета нет; ожидаемое имя первого — verdicts/critic/contracts-210-v1.md.
6. Правило инструментов: `bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --syntax` → rc 0: настоящий bash -n на модели check_charter, модели pre-push и обёртке; compile без записи pyc на probe.py. Закреплённый shellcheck вызывается через `bash scripts/validate_std.sh bash <файл Bash>`; отсутствие бинаря — rc 2 среды, не объявляется пройденной проверкой.
7. Правило подключения: `bash scripts/gen_ci_steps.sh --check` → rc 0 на сдаче architect. Orchestrator добавляет только self-test 210 (W --repo ., W --model, W --stabs) и его замер, материализует workflow через gen_ci_steps.sh --write и повторяет --check → rc 0. Полный `bash scripts/check_provodka.sh . contracts/210-charter-tekst-do-tega.md` до CI-строки → rc 1 «guard не подключён», после подключения → rc 0.

## Незаполненные требования:
нет

## Зоны и проводка

ЗОНА architect: contracts/210-charter-tekst-do-tega.md fixtures/workshop_project/charter_tekst_do_tega_210/
ЗОНА implementer: scripts/check_charter.sh .githooks/pre-push
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml

ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 019 только общий предикат публикации и его два места вызова; is_charter_path и diff к первому родителю сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 022 только общий предикат для кольца и библиотечный экспорт; разрешительная грамматика не меняется
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 046 только отдельное основание публикации рядом с razreshil; grandfather-список и окружение не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 065 только новый предикат и места вызова; именные пары и грамматика разрешения остаются буквально прежними
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 083 только одинаковый допуск в обоих режимах; lib_incr, per-document окно и атомарная запись кеша не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 084 только новый предикат публикации; правила ROADMAP не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 086 только новое основание допуска; прежние отказы/грамматика разрешения сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 113 только общий предикат и два места вызова; одиночный быстрый обход, oracle и отсутствие персистентного состояния сохраняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/check_charter.sh — 992 только новый предикат с fail-closed возвратом; отказы чтения области/истории/дельты сохраняются
ПЕРЕСЕЧЕНИЕ implementer: .githooks/pre-push — 016 только вызов общего допуска внутри принадлежащего 016 каталога .githooks/; изоляция, остальные хуки и их проверки не меняются
ПЕРЕСЕЧЕНИЕ implementer: .githooks/pre-push — 022 только вызов общего допуска в устав-дельта M/D цикле; диапазон и грамматика кольца прежние
ПЕРЕСЕЧЕНИЕ implementer: .githooks/pre-push — 167 только вызов допуска устава; запрет merge main→wip, живой main и условия исключения 167 не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только новая строка self-test 210; чужие строки сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер self-test 210; чужие замеры сохраняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только производная материализация gen_ci_steps.sh строки self-test 210 из registry/ci-steps.tsv; чужая проводка сохраняется

ПРЕДПОСЫЛКИ:
- setting CI харнесса уже предоставляет bash, Python 3, git с SHA-256, awk, sed, grep и timeout; новых secrets, variables, environments и настроек репозитория нет. Для нового освобождения доступен настроенный origin и полный объект первой заморозки. Самотест использует отдельные одноразовые локальные origin-репозитории под TMPDIR без внешней сети. Закреплённый shellcheck берётся из ops/server/validators.tsv; его отсутствие не считается зелёной проверкой.

Порядок: architect (контракт, батарея, модели и мутации одной пачкой) → двери формы → critic → freeze → implementer (только объявленные production-файлы) → orchestrator (self-test, замер, gen_ci_steps --check) → adversary → reviewer → done. Список grandfather не расширяется; если при реализации требуется менять файл, который сам распознаётся is_charter_path (в частности frozen-текст этого контракта), это отдельное разрешение владельца в том же коммите по owner-каналу, не обход проверяемого стража. scripts/check_charter.sh сам уставным путём is_charter_path не является, что не отменяет риск его изменения.

ПРОВОДКА:
- guard=fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh

ПРОВОДКА-ЭНФОРСМЕНТ: ремонтируется чистый энфорсмент существующего порядка публикации 130 и суда 019/022; новой поведенческой нормы роли нет. Канал — guard семьи. CI-строку, её замер и производный workflow коммитит orchestrator; до этого полный check_provodka красен по отсутствию подключения, grammar и pre_critic обязаны быть зелёными.
