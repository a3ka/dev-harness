# Контракт 165 — материализация уже состоявшегося суда critic

КЛАСС ЗАДАЧИ: кодовый. КЛАСС РИСКА: рисковый — подмена результата судьи позволяет юридически значимое действие от имени владельца (основание: юридически значимые действия/безопасность). ТРЕК: полный; adversary и reviewer после accept.
КОНТЕКСТ: владелец утвердил пакет 1 («утверждаю пакет 1») и дал дословное разрешение «сделай это с моей подписью, если там есть полноценные законченные вердикты судей». Это УСЛОВИЕ, не разрешение сочинять новый суд и не санкция коммитить `user.name=owner`.

## Существующее

- `roles/critic.md:40-55` требует завершённый суд по закоммиченному OBJECT; `history://Crit163b` демонстрирует существующий yield с полным verdict и заданием `OBJECT=...`; JSONL сессии содержит событие вызова `yield` и `details.data.verdict`, а файл вердикта может лежать только в scratch судьи. Н-источник — уже состоявшаяся сессия, а не новый спавн.
- `scripts/check_sud_model.sh --verdict` и `scripts/judge_gate.sh --verdict-row --sud` судят обычного судью по модели, трассе и объекту перед строкой журнала; материализатор НЕ судья и не может создавать строку accept этой дорогой ногой без судьи. Эти механизмы остаются для обычных судов и их вызовов; обходной вызов с подложным `--sud` недопустим.
- `.omp/extensions/spawn-guard.ts` берёт алфавит ролей из установочного `config/agent_models.json`; `scripts/gen-harness.ts` выводит `.omp/agents/*.md` из `roles/*.md` и модели конфига; `scripts/zamok_predmeta.sh` перечисляет WORKERS/JUDGES и пропускает другие зарегистрированные роли без занятия предмета. `scripts/make_task.sh` сегодня закрывает собственный алфавит ролью без materializer: для штатного запуска нужен адресный допуск контекста, не добавление в замок. `scripts/check_zones.sh` читает зоны из замороженного контракта.

## Предмет

Один результат: штатная роль `verdict-materializer` принимает ТОЛЬКО уже завершённое решение `history://Critic*` роли `critic` на ТОЧНЫЙ OBJECT и записывает его байты в `verdicts/critic/` лишь после проверки буквальной цитаты владельца «сделай это с моей подписью, если там есть полноценные законченные вердикты судей». Никакого нового суда, пересказа вердикта, замены `FAIL`/`ESCALATE` на `accept`, подстановки иной сессии или файлового текста как источника решения. Материализатор не входит ни в WORKERS, ни в JUDGES; `check_sud_model` к нему не применяется, к исходному судье применяется прежний маршрут 104, если требует действующая судейская процедура. Коммит — собственной ролью, без присвоения git identity `owner` или `critic`; owner-цитата — авторизация операции, не техническая подмена автора.

Норма роли (role-канал): при получении задания с буквальной owner-цитатой и OBJECT материализатор читает `history://Critic*` и исходный `task`-спавн родителя, подтверждает `agent:critic`, завершённый `yield` и привязку OBJECT в задании и в самом результате, сверяет в первой строке вердикта ровно `accept`, копирует неизменённые байты, прекращает работу на первом отказе; в задачах без этих условий останавливается без записи. Источник `history://` читается заново ДО записи, ожидания остаются в памяти проверяющего; данные файла назначения или scratch проверяемого не служат оракулом. `check_sud_model` по имени `verdict-materializer` не вызывается: существующая функция принимает замкнутый список только судейских ролей.

Исполняемый seam — `python3 scripts/materialize_verdict_165.py --history <экспорт history> --history-uri history://Critic<ID> --owner-text <сообщение владельца> --object <40 hex> --output <файл>`; передача экспорта осуществляется доверенным адаптером чтения `history://` и подтверждённым parent task-call с `agent:critic`, не от имени файла, URI-строки или поля JSON внутри экспорта. API экспорта: `{source,agent,task,result:{tool,complete,verdict}}`; `source` и `agent` — результаты СВЕРКИ адаптера с самим history/parent spawn, а НЕ поля, которым можно доверять из произвольного файла. Если доверенный адаптер отсутствует или связь parent task-call ↔ session не доказана, rc 1 `ISTOCHNIK_NE_CRITIC_HISTORY`, запись не производится. Доверенность источника нельзя доказывать простым `--history-uri` рядом с произвольным JSON: файл без подлинного `history://` является контрпримером и обязан краснеть на живой ноге. Источник цитаты — буквальное сообщение владельца в контексте вызывающей сессии, не самодельная строка материализатора. Скрипт поля сверяет в каждом отказе до записи, не выпускает новый verdict.

Входы: `history://Critic<ID>` (латинские буквы, цифры, `._-`, непустой ID), `OBJECT=[0-9a-f]{40}` самостоятельной строкой задания и второй строкой вердикта; единственная строка `СУД:` результата содержит `роль=critic;` и `сессия=<ID>;` отдельными полями; первая строка вердикта — `accept` целиком. Точное текстовое сравнение, никакого regex, собранного из недоверенного значения. Структурные поля JSON разных уровней не смешиваются, не используются подстроки из произвольного текста вместо полей. Выход только в существующую зону `verdicts/critic/` выбранного репозитория; существующий вердикт нельзя перезаписывать несовпадающими байтами. При отказе код 1 и именованная причина, destination отсутствует либо не меняется. Недоступен доверенный источник — rc 2 `NOT_IMPLEMENTED`, не ложная зелень.

## Приёмочный критерий

`W=python3 fixtures/workshop_project/verdict_materializer_165/probe.py`. Конформные входы — завершённое событие yield реального critic, его parent task-call с `agent:critic` и точным OBJECT, дословная цитата в owner-сообщении; поля API и путь результата по объявленной грамматике. Контрпример валиден лишь при расхождении на конформном входе, инвариантном к именам Critic-ID, OBJECT и тексту вердикта вне заголовка; неподписанный JSON, притворяющийся `history://`, НЕ является конфорным источником. Слой `W` изолирует проверку полей после доверенного адаптера; живой сценарий ниже отдельно судит реальный источник. Каждый стаб предъявлен в коде `fixtures/workshop_project/verdict_materializer_165/stabs.py` ровно на различающем его входе `probe.py`, не обещанием в прозе.

1. Дано: этот черновик до реализации. Когда `W --repo .`. Тогда rc 1 `SUBJECT_ABSENT` (живой кандидат ещё не создан); `W --model` rc 0, `W --stabs` rc 0 с девятью независимыми отказами честного контроля и девятью принятыми плохими входами у адресных мутантов.
2. Дано: завершённый critic с owner-цитатой и точным OBJECT. Когда `W --repo .` после реализации. Тогда rc 0; на выходе побайтово тот же verdict. Дано: чужой source, чужая роль, нет цитаты, иное OBJECT задания, незаконченный yield, `FAIL` вместо `accept`, иное OBJECT вердикта, не-critic в строке СУД, отсутствие verdict. Когда та же команда. Тогда каждый отдельный вход rc 1 со своей именованной причиной, файл назначения не создан. Дано: роль без цитаты / результат reviewer / подложный текст с `verdict=accept` без yield. Когда запускается дверь. Тогда rc 1, новый суд не запускается.
3. Дано: существующий результат `history://Critic<ID>` и исходный parent `task`-call, взятый живым `read`, owner-сообщение с точной цитатой; когда materializer запускает дверь на живом источнике, тогда запись дословного вердикта и собственный commit; на изменённом exported JSON при неизменённой живой сессии — rc 1 `ISTOCHNIK_NE_CRITIC_HISTORY` без записи. Источник извлекается перед запуском кандидата и удерживается в памяти проверяющего; диск кандидата не перечитывается как истина. Если нет доверенного read/parent-свидетельства, эта нога остаётся красной, freeze запрещён.
4. Дано: штатная регистрация роли. Когда `node scripts/gen-harness.ts --check`, `bash scripts/check_sud_model.sh --spawn verdict-materializer ignored`, `W --repo .` и scoped spawn-gate toy-проба. Тогда генератор rc 0, `check_sud_model` по имени новой роли rc 2 «роль вне алфавита судей», валидный materializer проходит алфавит spawn-guard и НЕ создаёт запись WORKERS/JUDGES в замке, `W` rc 0. Обычный critic сохраняет действующий `check_sud_model` и прежние батареи 104/140.
5. Дано: черновик. Когда `bash scripts/pre_critic.sh contracts/165-materializator-verdicta-critic.md`, `bash scripts/check_spec_ready.sh . contracts/165-materializator-verdicta-critic.md` и `bash scripts/check_threat_model.sh . contracts/165-materializator-verdicta-critic.md`. Тогда каждый rc 0. До done `check_provodka` вправе отказать, когда CI-строка ещё не подключена; до done `bash scripts/check_provodka.sh . contracts/165-materializator-verdicta-critic.md` и source-gate проекта (если профиль требует) rc 0.

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
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер 165; чужие строки не меняются
ПРОВОДКА:
- guard=fixtures/workshop_project/verdict_materializer_165/probe.py
- role=roles/verdict-materializer.md
ПРОВОДКА-ЭНФОРСМЕНТ: чистый энфорсмент полей — скрипт-дверь; новая поведенческая норма роли — role-канал; CI-проводка оркестратора после landing, не обход других судейских батарей.

## Незаполненные требования:
- Живой provenance-сценарий до freeze является обязательной приёмкой, пока доказательства нет — красный, а не предполагаемый зелёный.
