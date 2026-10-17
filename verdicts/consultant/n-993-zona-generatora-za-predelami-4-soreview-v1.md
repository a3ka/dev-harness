ПРЕДМЕТ: n-993-zona-generatora-za-predelami-4
МОДЕЛЬ: openai-codex/gpt-6-astra
ВОПРОС: действительно ли полная поставка 5.8.3 требует расширения §4 сверх семи путей
РЕКОМЕНДАЦИЯ: Предлагаю вариант (а): точечное расширение §4 на девять файлов ниже для согласованной поставки 5.8.3, с новым accepted alignment в уже разрешённом contracts/ и сохранением исторических источников; альтернатива (б) — отдельный подготовительный результат без выпуска 5.8.3, re-freeze и заявления полного PASS_STATIC, только по явному изменению владельцем объёма 993. Одних пяти дополнительных путей из форка недостаточно.

## Статус и граница

Это предложения ДО критика и подписи владельца, не разрешение реализации и не вердикт критика. Контракт в worktree архитектора прочитан живьём: он объявлен черновиком, открытые зависимости блокируют заморозку. Файлов критика, арбитража и прежнего СОревью по 993 при поиске в основном дереве, клоне консультанта и verdicts worktree архитектора не обнаружено. Совмещения с арбитражной подписью не найдено.

Прочитаны весь живой форк, DECISIONS-121.md, owner §3–4, контракт 993 и исполняемые зависимости поставки. Исследован Complior-back на `842f4e99d6024ab62336a6a0be787ae667fb555b`; исходный клон архитектора не изменялся. Исполнение — в отдельном `/tmp/dev-harness-verify/consultant993-cback-smoke`. Файлы продукта, owner-документ и контракт не исправлялись.

Важная поправка происхождения: в момент проверки форк присутствовал в рабочем дереве `/home/harness/dev-harness`, но `git status --porcelain forks/n-993-zona-generatora-za-predelami-4.md` дал `A  forks/n-993-zona-generatora-za-predelami-4.md`: он staged, не входит в HEAD `77b4fc15e0235e7029cec274167d2368df4dd1d3`. Поэтому анализ относится к прочитанному живому форку; чужой staged файл консультант не коммитит. Owner-документ есть в указанном HEAD.

## Что установлено, а что в форке преувеличено

1. `tools/generate_derived.py:14,73,114` действительно открывает на запись `data/client-field-decisions-v3_10.json`, `tests/acceptance-ux1175.json`, `server/mock-5_8.json`. Но запись не равна изменению байтов и не равна отказу по зоне: проверки owner §4 внутри генератора нет. В собственном прогоне неизменённого генератора на исходной базе rc=0, все три файла записаны, SHA каждого остался прежним. Из tracked-файлов изменился только `FILES.sha256`. Поэтому утверждение «уже сейчас генератор обязательно отказывает без допуска этих путей» неверно. Разрешение на регенерацию этих трёх путей разумно для полной поставки; обязательность diff у data/acceptance не доказана, пустой diff создавать не надо.
2. `VERSION_MANIFEST.json` не безусловный output генератора. `:137–139` пишет его только при `--freeze-vs01` И отсутствии `vs01_spec_freeze`. При существующем freeze обычный запуск только сверяет digest; флаг не переутверждает freeze. В прогоне manifest не открывался на запись и не изменился. Но для согласованного нового `openapi`, `vs01_spec_freeze.api`, hash и provenance его правка необходима: listPostItems входит в freeze, а `:117–135` хеширует полные operation objects и ref closure, включая example. Удаление freeze для обхода проверки не предлагается.
3. Alignment действительно закрепляет 5.8.2: `tools/validate_alignment_11782_31422.py:37`; `:48–54` требует равенства текущего YAML/index с историческим `sources/frontend-ux1_17_8_2/Complior_OpenAPI_5_8_2_Operation_Waves.json`, а `:89` — active backend 5.8.2 в историческом Mobile Design Data. Замена одной строки версии недостаточна. Нужен новый принятый слой alignment/provenance, не переписывание старого source snapshot и не удаление hash-проверок.
4. **В форке пропущен ещё один обязательный executable pin:** `tools/validate_invitation_target_31421.py:19` требует `manifest.openapi == '5.8.2'`. Он прямо включён в приёмку 993 и штатную поставку README. При честном manifest 5.8.3 он отвергает пакет, даже если alignment уже исправлен. Семантика invitation target и NOT_RUN должны сохраниться; принятие нового invitation wire этим не разрешается.
5. **В форке пропущена пара mock/consumer:** `server/src/mock-5_8.ts:12` всегда отвечает `X-BrokerOS-Contract: 5.8.2`, не читая версию из fixture; `server/test/mock-5_8.test.ts:12` закрепляет тот же ответ. Генератор тем временем берёт `server/mock-5_8.json.contract` из OpenAPI. [INFERENCE] Одна регенерация JSON на 5.8.3 оставит ложный 5.8.2 response header, а прежний тест способен оставаться зелёным именно на этой несогласованности. Нужна синхронная миграция emitter и проверки фактического заголовка против принятой версии API, не ослабление consumer-теста. Разрешённый диапазон запросов `5.8.x` сохраняется; исторический runtime `server/src/app.ts` с 5.7.0 сюда не относится.
6. В `Complior_Backend_Architecture_v3_14_RU.md:300` текущий нормативный §18 обещает ответ 5.8.2 и универсальные X-Scope-Id/strong If-Match. DECISIONS §6.1 требует его уточнения. Для выбранного варианта полноценной поставки предлагаю разрешить именно этот файл и именно согласование §18 с принятыми профилями, а не широкую правку документации, PDF или runtime.

## Точный предлагаемый добавочный список для §4

Все пути относительно корня **Complior-back**, не dev-harness. Исходные семь сохраняются.

| Добавить | Узкое основание и предел |
|---|---|
| `VERSION_MANIFEST.json` | Версия пакета API и контролируемый re-freeze с old/new hash, source и owner-основанием; не автоматическое принятие любого drift. |
| `tools/validate_alignment_11782_31422.py` | Принятая 5.8.3 и проверка нового alignment/source hash при отдельной проверке неизменности исторического UX snapshot. |
| `tools/validate_invitation_target_31421.py` | Согласование current API pin с 5.8.3 без изменения invitation target, transport или runtime-допуска. |
| `data/client-field-decisions-v3_10.json` | Только output существующего генератора; не менять field ownership/release gates ради версии; при прежних bytes не включать в diff. |
| `tests/acceptance-ux1175.json` | Только согласованный generated acceptance; NOT_RUN и release gates сохраняются; при прежних bytes не включать в diff. |
| `server/mock-5_8.json` | Регенерированный fixture с текущей версией/схемами, без новых handlers и claims о runtime. |
| `server/src/mock-5_8.ts` | Только согласование объявляемой версии fixture-mock с поставкой; 5.8.x input compatibility и FIXTURE_ONLY остаются. |
| `server/test/mock-5_8.test.ts` | Проверка фактической response version для нового пакета с сохранением несовместимых-version и остальных отрицательных случаев. |
| `Complior_Backend_Architecture_v3_14_RU.md` | Только §18: текущая версия ответа и уже разрешённые §3 профили scope/CAS/CSRF; никакой новой wire-семантики. |

Это девять точечных разрешений, не утверждение, что все девять обязательно имеют diff. Первые пять путей, названные форком, недостаточны для сохранения всей существующей цепочки поставки.

### Как не раздувать зону sources/ и evidence/

Предлагаю новый accepted артефакт `contracts/backend-5_8_3-alignment.json` **в уже разрешённом contracts/**. Это предлагаемое имя, сейчас такого файла не заявляю существующим. Содержание: источник/хэш исторического UX1.17.8.2, исходный 5.8.2 OpenAPI hash, новый 5.8.3 OpenAPI hash и version, operation-wave/deprecated parity, явная принятая backend-reference delta с owner-основанием. Alignment проверяет исходные исторические bytes отдельно и текущий index/API против принятой дельты, а не считает старый Mobile Design Data будто всегда содержавшим 5.8.3. Это продолжает существующий принцип original source bytes + explicit accepted overrides; canonical consumer registry остаётся единственным `frontend-consumer-bindings.json`.

Новые verification outputs штатных команд возникают также в `evidence/ux175/`, `evidence/mock/`, `evidence/runs/`, `evidence/ddl/`, `evidence/ddl013/`, `evidence/policy/` — это видно в проверенных writer callsites, но общий suite здесь не запускался. Чтобы не просить ещё шесть зон, выбранный вариант предполагает интеграционный прогон в disposable checkout и сохранение его новых сырых outputs/manifest/stdout/rc в уже разрешённом `evidence/contracts/993/` с исходными относительными путями и provenance. Только созданные этим прогоном временные дубликаты убираются из собираемого checkout до финального generate_derived/verify_handoff; существующее evidence не удаляется. Иначе финальный FILES.sha256 может сослаться на непоставленные файлы. Если интегратор предпочитает коммитить новые outputs на штатных местах, это уже другая, явно расширенная заявка на эти шесть append-only зон, не молчаливое право из настоящего списка.

Существующие PDF, старый handoff и source snapshots не переписываются как текущая 5.8.3: README_RU/manifest должны явно отделить историческую документацию 3.14.2.2 от нового erratum и действующего §18. Новое зеркало Complior-mob остаётся отдельным PR.

## Альтернатива без расширения

Вариант (б) возможен как отдельная подготовительная пачка: исправить в пределах прежних семи путей обход bodyless, проверку consumer graph и независимые профили; оставить API 5.8.2, missing PostPage example и прежний freeze; честно выдавать оставшиеся FAIL_STATIC. Не запускать преобразование версии и не утверждать «993 / поставка 5.8.3 завершена». [INFERENCE] Это сохраняет запрет выхода за §4, но **не выполняет нынешний предмет и приёмку 993**. Нужен явный выбор владельца о разделении результата и переносе erratum/re-freeze в следующий контракт; консультант сам этого не делает. Исключить missing example из проверки или благословить старый manifest при новых bytes — не альтернатива.

Даже вариант (а) снимает только path-blocker. Реальные non-mobile source_ref и семантические CAS dispositions остаются обязанностью реализации/судов; разрешённая зона не доказывает, что все 36 команд могут быть exempt без изменения wire.

## Собственный smoke и маршрутизация

В disposable клоне запущен настоящий неизменённый generate_derived через runpy с audit-hook только для наблюдения открытий файлов; before/after SHA всех tracked-файлов считались независимо. Вывод:

```text
GENERATOR_RC 0
Derived consumers, wire and 10-route mock rebuilt
Handoff hashes rebuilt: 271 files
CHANGED_TRACKED ["FILES.sha256"]
WRITE_VS_CHANGE VERSION_MANIFEST.json written=False changed=False
WRITE_VS_CHANGE data/client-field-decisions-v3_10.json written=True changed=False
WRITE_VS_CHANGE tests/acceptance-ux1175.json written=True changed=False
WRITE_VS_CHANGE server/mock-5_8.json written=True changed=False
```

Затем в том же disposable checkout временно изменены только info.version на 5.8.3 и для второй проверки manifest.openapi на 5.8.3; исходные bytes обоих файлов восстановлены в finally. Настоящие CLI дали:

```text
VERSION_ONLY_ALIGNMENT_RC 1
AssertionError: OpenAPI version
VERSION_ONLY_INVITATION_RC 1
PASS no runtime/wire claim
AssertionError: current package and API version
```

Это отрицательный smoke зависимости версии, не реализация согласованного 5.8.3. Mock HTTP, общий npm test, валидатор 187 отказов и проектный CI не запускались; их зелёный статус не утверждается.

Запрошенная команда `bash scripts/check_fork_route.sh --root /home/harness/dev-harness` выполнена: rc=1, дословно `класс не подтверждён — свидетельство без «ПОДТВЕРЖДЕНО: воля-владельца»: n093-cikl085-oracle-stale-pgrep-filter`. Чужая запись не исправлялась. Этот ранний отказ не является проверкой нашего СОревью и не означает красноту предмета 993.

## Готовый батч владельцу

**Вопрос:** разрешаете ли для полной поставки 993 / OpenAPI 5.8.3 расширить §4 на девять точечных файлов, перечисленных ниже, сохранив исторические source bytes и прежние ограничения wire/runtime? **Рекомендация:** да, вариант (а); пять путей исходного форка не закрывают invitation-validator и version-header mock. Вариант (б) — только отдельно разрешённая подготовительная поставка с сохраняющимся FAIL_STATIC, не закрытие 993.

**Готовый дословный текст строки ответа для добавления в §4 (это проект ответа, НЕ уже полученное разрешение):**

> Да. Для контракта 993 дополнительно разрешаю в Complior-back пути `VERSION_MANIFEST.json`, `tools/validate_alignment_11782_31422.py`, `tools/validate_invitation_target_31421.py`, `data/client-field-decisions-v3_10.json`, `tests/acceptance-ux1175.json`, `server/mock-5_8.json`, `server/src/mock-5_8.ts`, `server/test/mock-5_8.test.ts`, `Complior_Backend_Architecture_v3_14_RU.md` — только для согласованной поставки additive erratum 5.8.3 по §3: контролируемый re-freeze VS01 с old/new hash и provenance, проверяемый accepted alignment в `contracts/backend-5_8_3-alignment.json`, регенерация производных, согласование version checks/fixture-mock и §18 архитектуры. Исторические UX snapshots, PDF и прежнее evidence не переписывать; новый verification evidence собрать из disposable прогона в уже разрешённом `evidence/contracts/993/`, финальный FILES.sha256 должен ссылаться только на поставленные файлы. Запросы 5.8.x остаются совместимыми, wire/handlers/новые invitation flows и `backend/` не меняются; runtime readiness не заявляется; Complior-mob/api — отдельный PR; Merge PR 993 остаётся за владельцем.

ОСНОВАНИЕ-ДЕРЕВО:
КОМАНДА: git show 77b4fc15e0235e7029cec274167d2368df4dd1d3:docs/owner/2026-10-17-resheniya-back-992-993.md
RC: 0
ВЫВОД-SHA256: e9d5cf84b214f54da0550173374a901cf295a2ade055fd05b8efdb2543a163c1
КОМАНДА: git show 842f4e99d6024ab62336a6a0be787ae667fb555b:tools/generate_derived.py
RC: 0
ВЫВОД-SHA256: 1e3abe370a285d65fe080e16fccd10404ff6e7b875c329c6bcd96bf0ba475a05
КОМАНДА: git show 842f4e99d6024ab62336a6a0be787ae667fb555b:VERSION_MANIFEST.json
RC: 0
ВЫВОД-SHA256: bad9d2128d076d7b728b81507a662805c12f7fe76f53c93e6db567ff7bf658de
КОМАНДА: git show 842f4e99d6024ab62336a6a0be787ae667fb555b:tools/validate_alignment_11782_31422.py
RC: 0
ВЫВОД-SHA256: 984d0aff596eddb9dc69c2c985ad32a34b94e66a2b5d971792eb5eee858a711a
КОМАНДА: git show 842f4e99d6024ab62336a6a0be787ae667fb555b:tools/validate_invitation_target_31421.py
RC: 0
ВЫВОД-SHA256: b26ea32215c0337cbfbe09b21b768a216ce90338d0623340bb0130135a18c14a
КОМАНДА: git show 842f4e99d6024ab62336a6a0be787ae667fb555b:server/src/mock-5_8.ts
RC: 0
ВЫВОД-SHA256: bb30b2c23767cec38d254711f2da5ead8ea146b49e7514e55028b610c13e5218
КОМАНДА: git show 842f4e99d6024ab62336a6a0be787ae667fb555b:server/test/mock-5_8.test.ts
RC: 0
ВЫВОД-SHA256: cd479318a10f4ced7e735f688049dd6f53ff5a2f8b1fbaa7e005f7b9b6195f37
КОМАНДА: git show 842f4e99d6024ab62336a6a0be787ae667fb555b:Complior_Backend_Architecture_v3_14_RU.md
RC: 0
ВЫВОД-SHA256: 70a9c3cec0ba017833991640a2e560264bf1b843bda8dda4b5295a000893bbd0
