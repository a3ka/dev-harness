# Контракт 165 — материализация уже состоявшегося суда critic

КЛАСС ЗАДАЧИ: кодовый. КЛАСС РИСКА: рисковый — подмена результата судьи позволяет юридически значимое действие от имени владельца (основание: юридически значимые действия/безопасность). ТРЕК: полный; adversary и reviewer после accept.
КОНТЕКСТ: владелец утвердил пакет 1 («утверждаю пакет 1») и дал дословное разрешение «сделай это с моей подписью, если там есть полноценные законченные вердикты судей». Это УСЛОВИЕ, не разрешение сочинять новый суд и не санкция коммитить `user.name=owner`.

## Существующее

- `roles/critic.md:28` называет кандидатом суда зафиксированный SHA/OBJECT («Кандидат суда — зафиксированный SHA/OBJECT»), `:40-43` — суд только по закоммиченному («Судишь файл на HEAD… Не закоммичено — предмета нет»), `:45-55` — неполный набор; `history://Crit163b` демонстрирует существующий yield с полным verdict и заданием `OBJECT=...`; JSONL сессии содержит событие вызова `yield` и `details.data.verdict`, а файл вердикта может лежать только в scratch судьи. Н-источник — уже состоявшаяся сессия, а не новый спавн.
- `scripts/check_sud_model.sh --verdict` и `scripts/judge_gate.sh --verdict-row --sud` судят обычного судью по модели, трассе и объекту перед строкой журнала; материализатор НЕ судья и не может создавать строку accept этой дорогой ногой без судьи. Эти механизмы остаются для обычных судов и их вызовов; обходной вызов с подложным `--sud` недопустим.
- `.omp/extensions/spawn-guard.ts` берёт алфавит ролей из установочного `config/agent_models.json`; `scripts/gen-harness.ts` выводит `.omp/agents/*.md` из `roles/*.md` и модели конфига; `scripts/zamok_predmeta.sh` перечисляет WORKERS/JUDGES и пропускает другие зарегистрированные роли без занятия предмета. `scripts/make_task.sh` сегодня закрывает собственный алфавит ролью без materializer: для штатного запуска нужен адресный допуск контекста, не добавление в замок. `scripts/check_zones.sh` читает зоны из замороженного контракта.
- Контракты 104 (сверка модели/привязки судьи перед строкой журнала `registry/candidates.tsv`) и 173 (нормализация имён моделей при сравнении) не материализуют ФАЙЛ вердикта и не создают роль: 165 добавляет запись байтов уже состоявшегося accept в `verdicts/critic/` с owner-цитатой и ролью вне WORKERS/JUDGES — не дубль. `models_actual.sh --tsv --bind` при session-id вне `[A-Za-z0-9._-]` (измерено: `Arbiter079Б1`) возвращает rc 2 `NOT_IMPLEMENTED` — дефект производителя трассы, зафиксированный контрактом 173 §Существующее; материализация вердикта судьи с таким session-id через маршрут 104 остаётся заблокированной, 165 её не обходит.

## Предмет

Один результат: штатная роль `verdict-materializer` принимает ТОЛЬКО уже завершённое решение `history://Critic*` роли `critic` на ТОЧНЫЙ OBJECT и записывает его байты в `verdicts/critic/` лишь после проверки буквальной цитаты владельца «сделай это с моей подписью, если там есть полноценные законченные вердикты судей». Никакого нового суда, пересказа вердикта, замены `FAIL`/`ESCALATE` на `accept`, подстановки иной сессии или файлового текста как источника решения. Материализатор не входит ни в WORKERS, ни в JUDGES; `check_sud_model` к нему не применяется, к исходному судье применяется прежний маршрут 104, если требует действующая судейская процедура. Коммит — собственной ролью, без присвоения git identity `owner` или `critic`; owner-цитата — авторизация операции, не техническая подмена автора.

Норма роли (при реализации переносится в roles/verdict-materializer.md — ЗОНА implementer): при получении задания с буквальной owner-цитатой и OBJECT материализатор читает `history://Critic*` и исходный `task`-спавн родителя, подтверждает `agent:critic`, завершённый `yield` и привязку OBJECT в задании и в самом результате, сверяет в первой строке вердикта ровно `accept`, копирует неизменённые байты, прекращает работу на первом отказе; в задачах без этих условий останавливается без записи. Источник `history://` читается заново ДО записи, ожидания остаются в памяти проверяющего; данные файла назначения или scratch проверяемого не служат оракулом. `check_sud_model` по имени `verdict-materializer` не вызывается: существующая функция принимает замкнутый список только судейских ролей.

Исполняемый seam — `python3 scripts/materialize_verdict_165.py --repo-root <корень репозитория> --history <экспорт history> --history-uri history://Critic<ID> --owner-text <сообщение владельца> --object <40 hex> --output <голое имя файла>`; дверь пишет только в `<repo-root>/verdicts/critic/<имя>` — без корня репозитория зона выхода непроверяема, поэтому корень — обязательный вход двери. Передача экспорта осуществляется доверенным адаптером чтения `history://` и подтверждённым parent task-call с `agent:critic`, не от имени файла, URI-строки или поля JSON внутри экспорта. API экспорта: `{source,agent,task,result:{tool,complete,verdict}}`; `source` и `agent` — результаты СВЕРКИ адаптера с самим history/parent spawn, а НЕ поля, которым можно доверять из произвольного файла. Если доверенный адаптер отсутствует или связь parent task-call ↔ session не доказана, rc 1 `ISTOCHNIK_NE_CRITIC_HISTORY`, запись не производится. Доверенность источника нельзя доказывать простым `--history-uri` рядом с произвольным JSON: файл без подлинного `history://` является контрпримером и обязан краснеть на живой ноге. Источник цитаты — буквальное сообщение владельца в контексте вызывающей сессии, не самодельная строка материализатора. Скрипт поля сверяет в каждом отказе до записи, не выпускает новый verdict.

Входы: `history://Critic<ID>` (латинские буквы, цифры, `._-`, непустой ID); uri вне алфавита → rc 1 `URI_NEVALIDEN`. `OBJECT=[0-9a-f]{40}` самостоятельной строкой задания и второй строкой вердикта; негекс → rc 1 `OBJECT_NEVALIDEN`. Единственная строка `СУД:` результата (ровно одна на весь текст вердикта, третья строка) содержит `роль=critic;` и `сессия=<ID>;` отдельными полями; вторая или смещённая `СУД:`-строка → rc 1 `SUD_NE_EDINSTVENNA`; не-critic в полях → rc 1 `VERDICT_AVTOR_NE_CRITIC`. Первая строка вердикта — `accept` целиком. Точное текстовое сравнение, никакого regex, собранного из недоверенного значения. Структурные поля JSON разных уровней не смешиваются, не используются подстроки из произвольного текста вместо полей. Выход — только голое имя файла в существующей зоне `verdicts/critic/` выбранного репозитория: имя с каталогом, `..` или абсолютное → rc 1 `OUT_ZONE`, в корне не появляется ни одного нового или изменённого файла. Существующий вердикт нельзя перезаписывать несовпадающими байтами → rc 1 `PEREZAPIS_NE_SOVPAL`; идентичные байты — идемпотентный успех rc 0. При отказе код 1 и именованная причина, destination отсутствует либо не меняется. Недоступен доверенный источник или в корне нет существующей зоны `verdicts/critic/` — rc 2 `NOT_IMPLEMENTED`, не ложная зелень.

## Приёмочный критерий

`W=python3 fixtures/workshop_project/verdict_materializer_165/probe.py`. Конформные входы — завершённое событие yield реального critic, его parent task-call с `agent:critic` и точным OBJECT, дословная цитата в owner-сообщении; поля API и путь результата по объявленной грамматике. Контрпример валиден лишь при расхождении на конформном входе, инвариантном к именам Critic-ID, OBJECT и тексту вердикта вне заголовка; неподписанный JSON, притворяющийся `history://`, НЕ является конфорным источником. Слой `W` изолирует проверку полей после доверенного адаптера; живой сценарий ниже отдельно судит реальный источник. Каждый стаб предъявлен в коде `fixtures/workshop_project/verdict_materializer_165/stabs.py` ровно на различающем его входе `probe.py`, не обещанием в прозе.

1. Дано: этот черновик до реализации. Когда `W --repo .`. Тогда rc 1 `SUBJECT_ABSENT` (живой кандидат ещё не создан); `W --model` rc 0, `W --stabs` rc 0 с четырнадцатью независимыми отказами честного контроля и четырнадцатью принятыми плохими входами у адресных мутантов (полный перечень клеток — код `cases()` в `probe.py`, не проза).
2. Дано: завершённый critic с owner-цитатой и точным OBJECT. Когда `W --repo .` после реализации. Тогда rc 0; на выходе побайтово тот же verdict. Дано: чужой source, чужая роль, нет цитаты, иное OBJECT задания, незаконченный yield, `FAIL` вместо `accept`, иное OBJECT вердикта, не-critic в строке СУД, отсутствие verdict, uri вне алфавита `history://Critic<ID>`, негекс-OBJECT, вторая строка `СУД:` в теле, имя выхода с каталогом (`../`), существующий вердикт с несовпадающими байтами. Когда та же команда. Тогда каждый отдельный вход rc 1 со своей именованной причиной из раздела «Входы», в корне репозитория не появляется ни одного нового или изменённого файла (оракул — снимок всех файлов до/после в `probe.py`, не вывод кандидата). Дано: роль без цитаты / результат reviewer / подложный текст с `verdict=accept` без yield. Когда запускается дверь. Тогда rc 1, новый суд не запускается.
3. Дано: существующий результат `history://Critic<ID>` и исходный parent `task`-call, взятый живым `read`, owner-сообщение с точной цитатой; когда materializer запускает дверь на живом источнике, тогда запись дословного вердикта и собственный commit; на изменённом exported JSON при неизменённой живой сессии — rc 1 `ISTOCHNIK_NE_CRITIC_HISTORY` без записи. Источник извлекается перед запуском кандидата и удерживается в памяти проверяющего; диск кандидата не перечитывается как истина. Если нет доверенного read/parent-свидетельства, эта нога остаётся красной, freeze запрещён.
4. Дано: штатная регистрация роли. Когда `node scripts/gen-harness.ts --check`, `bash scripts/check_sud_model.sh --spawn verdict-materializer ignored`, `W --repo .` и scoped spawn-gate toy-проба. Тогда генератор rc 0, `check_sud_model` по имени новой роли rc 2 «роль вне алфавита судей», валидный materializer проходит алфавит spawn-guard и НЕ создаёт запись WORKERS/JUDGES в замке, `W` rc 0. Обычный critic сохраняет действующий `check_sud_model` и прежние батареи 104/140; правки implementer в `scripts/make_task.sh` (соседи 095/168/184/187) и блоках `.omp/config.yml` (соседи 002/005/010/012/025) не ухудшают соседей: `bash scripts/gen_ci_steps.sh --check` rc 0 на дереве после правок и полный CI-прогон workflow зелён.
5. Дано: черновик. Когда `bash scripts/pre_critic.sh contracts/165-materializator-verdicta-critic.md`, `bash scripts/check_spec_ready.sh . contracts/165-materializator-verdicta-critic.md`, `bash scripts/check_threat_model.sh . contracts/165-materializator-verdicta-critic.md` и `bash fixtures/workshop_project/verdict_materializer_165/zones_union_165.sh . contracts/165-materializator-verdicta-critic.md`. Тогда каждый rc 0; zones_union сверяет заявленные ПЕРЕСЕЧЕНИЕ с живыми frozen-тегами (чужой автор точной зоны — всегда, свой — пока контракт не закрыт done; каталожные зоны верхнего уровня и verdicts/ не суть пересечение). До подключения CI-строки батареи 165 `bash scripts/check_provodka.sh . contracts/165-materializator-verdicta-critic.md` вправе отказать (rc 1 «guard не подключён»); после подключения CI-строки — rc 0, и source-gate проекта (если профиль требует) rc 0.

ПРЕДПОСЫЛКИ:
- setting Существующий GitHub Actions workflow харнесса `.github/workflows/ci.yml` выполняет добавляемый scoped шаг батареи 165 в стандартной среде Python 3 без новых secrets, variables или environments.
- setting Чтение `history://` разрешено роли станции в живой сессии; личная owner-цитата приходит от владельца, не из настроек GitHub.

## Модель угроз

ЗАЩИЩАЕТ:
- Разделяет уже существующий `yield` critic, исходный OBJECT и owner-санкцию: ни один из них по отдельности не разрешает запись.
- Отличает чистую роль материализации от судьи: другой агент не получает судейскую запись одним названием файла, а новая роль не претендует на судейскую модель.
НЕ ЗАЩИЩАЕТ:
- Модель с экспортом JSON сама по себе не аутентифицирует `history://`. Без живого read и parent task-call это демонстрация схемы полей, НЕ доказательство происхождения. Независимый ловец — живой сценарий 3 и adversary; недоступность источника — блокирующий отказ.
- Настоящий владелец сообщения подтверждается контекстом сессии, не текстом файла owner.txt, доступного кандидату. Подмена доверенного контекста — отдельное нарушение границы установки.
- Дефект производителя трассы (см. «Существующее»): session-id судьи с символами вне `[A-Za-z0-9._-]` ломает `models_actual.sh --tsv --bind` rc 2 до материализации; 165 не чинит производителя и не подменяет трассу — такой вердикт не материализуется (красная нога 3), ложной зелени нет.
- Коммиты роли `verdict-materializer` в `verdicts/critic/` до заморозки 165 не судятся `check_zones` (необъявленных авторов он не проверяет); граница записи обеспечена самой дверью (клетки `OUT_ZONE`/`PEREZAPIS_NE_SOVPAL`), ловец остального — заморозка 165 с ЗОНА-строками и полный проход reviewer/adversary.
- Модель-факт материализуемого вердикта дверью не сверяется: свидетель — трасса исходного суда (roles/critic.md §Счёт: модель-факт дописывается в строку `СУД:` из трейсы, без дописки вердикт не материализуется); требует ли повторной сверки — решает действующая норма судьи, не материализатор; ловец — reviewer.
- Симлинк-редирект записи — висячий симлинк на месте имени выхода, симлинк-каталог зоны или TOCTOU-окно между проверкой байтов и записью: путь записи остаётся в зоне, физический редирект дверью не различается; атакующий с записью в зону может положить файл напрямую, границу не расширяет; ловец — implementer (O_NOFOLLOW/lstat/атомарная замена в scripts/materialize_verdict_165.py) и adversary.
- Ложная зелень проводки от совпадения базового имени: guard_is_wired барьера 038 матчит базовое имя guard (`probe.py`) — чужая ci-строка, зовущая любой `probe.py` дерева, засчитается как подключение; свойство замороженного барьера 038/083, предмет не правит; ловец — orchestrator/reviewer на CI-ноге.

## Зоны и проводка

ЗОНА architect: contracts/165-materializator-verdicta-critic.md
ЗОНА architect: fixtures/workshop_project/verdict_materializer_165/
ЗОНА implementer: scripts/materialize_verdict_165.py
ЗОНА implementer: roles/verdict-materializer.md
ЗОНА implementer: config/agent_models.json
ЗОНА implementer: scripts/make_task.sh
ЗОНА implementer: .omp/agents/verdict-materializer.md
ЗОНА implementer: .omp/config.yml
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 002 только блоки modelRoles/fallbackChains, результат генератора
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 005 только блоки modelRoles/fallbackChains, результат генератора
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 010 только блоки modelRoles/fallbackChains, результат генератора
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 012 только блоки modelRoles/fallbackChains, результат генератора
ПЕРЕСЕЧЕНИЕ implementer: .omp/config.yml — 025 только блоки modelRoles/fallbackChains, результат генератора
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 095 только адресный допуск materializer; трасса и запреты семейств не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 168 только адресный допуск materializer; трасса и запреты семейств не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 184 только адресный допуск materializer; трасса и запреты семейств не меняются
ПЕРЕСЕЧЕНИЕ implementer: scripts/make_task.sh — 187 только адресный допуск materializer; трасса и запреты семейств не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 141 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 147 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 148 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 149 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 157 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 158 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 163 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 168 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 184 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 187 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 188 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 189 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 190 только шаг 165; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 141 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 147 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 148 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 149 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 157 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 158 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 163 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 168 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 184 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 187 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 188 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 189 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 190 только строка 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 165; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 141 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 147 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 148 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 149 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 157 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 158 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 163 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 168 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 184 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 187 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 188 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 189 только замер 165; чужие замеры не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 190 только замер 165; чужие замеры не меняются
Пояснение перечня: строки «— 195» не заявлены — живой замороженной зоны 195 в дереве суда нет (живых заморозок 171 по `git tag -l 'frozen/contracts/*/*'`, пропуски: 009, 075–077, 089, 096, 101–102, 126, 134, 137, 144, 150, 152, 154–156, 160, 164–165, 171, 176–181, 183; черновик 195 ЗОНА-строк не несёт, локальный тег станции зон не публикует). Появление живой зоны 195 на этих путях обязан поймать zones_union отказом `NEOBYAVLENO — 195`; строки добавляет следующая редакция контракта, не молчаливое ожидание тега в конкретном клоне.
ПРОВОДКА:
- guard=fixtures/workshop_project/verdict_materializer_165/probe.py
ПРОВОДКА-ЭНФОРСМЕНТ: чистый энфорсмент полей — скрипт-дверь (guard-канал, прецедент 158); поведенческая норма новой роли задаёт этот контракт (раздел «Предмет») и при реализации переносится в roles/verdict-materializer.md (ЗОНА implementer) — role-канал не заявлен, пока файла роли нет в живом дереве: барьер 038 судит норму-строку по существующему roles-файлу, ссылка на несуществующий файл делала бы заявленное зелёное состояние проводки недостижимым; CI-проводка оркестратора после landing, не обход других судейских батарей.

## Незаполненные требования:
- Живой provenance-сценарий до freeze является обязательной приёмкой, пока доказательства нет — красный, а не предполагаемый зелёный.
