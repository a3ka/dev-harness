# СДАЧА 232 — исторический реестр и содержимое до коммита

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-232-v1.md

Обещание: исходный 178 принимается только по точному Git blob установочного реестра; pre_judge судит рабочий --file до коммита, а не прежний HEAD. Production в этой пачке не меняется. Исторический HEAD-only режим остаётся отдельным неизменным швом.

Исправление по Crit232b, вызов 2: `archive/232/critic-v2-fail-ffdcbf05f:verdicts/critic/contracts-232-v1.md`, OBJECT 0d19e859623913d9670a92c73e2dae7ed759cd60; арбитраж `verdicts/arbitration/contracts-232-b1.md`, база 0901d79cf18d64073c9ad25f13065cbf7ad7b603. Предыдущий К-08 закрывается способом **канон/инструмент**: Git `hash-object --no-filters` сравнивает индекс именно с сырыми рабочими байтами, без clean/text/eol-преобразований. Возврат фильтрующей операции — адресная мутация в build.py. И8 не сужен до нормализованного равенства; production, грамматика, исторические байты и карта реестра не меняются.

Различение: LF-карта и CRLF вне карты, `verdicts/critic/*.md text`, первый unstaged-вызов → rc 0; обычный git add; финальный вызов до коммита → rc 1, пустой stdout, первая строка stderr `ОТКАЗ: KARTA_NE_SHTATNA`, причина `индекс отличается от --file`. Каждый вызов сохраняет HEAD/индекс/рабочий файл; снимки и ожидаемое содержимое живут в памяти проверяющего. Честные соседи — полностью LF при том же text-пути и CRLF вне карты без преобразования Git: оба вызова rc 0, после add выполняется финальная дверь, затем проверяющий коммитит и сверяет HEAD/content.

`python3 -B fixtures/workshop_project/karta_krome_232/index_filter.py --before` воспроизведён на прежней модели: staged `be050a1b0a0be911950356926920c3d927559d0a`, raw `b73f98cb5211388f1a4599047b5b511e15cc151d`, staged pre_judge rc 0 `VERDICT_BRANCH=wip/178/critic` — нарушение И8; раннер rc 0 означает подтверждённое воспроизведение, не годность модели. Оба честных соседа rc 0. До/после и прежние reproduce.py включены в verify.py, который сохраняет source_head и обе трубы каждой команды. Полные свежие результаты ниже добавляются только по выполненным прогонам; исторические результаты предыдущего круга сохранены.

## Конструкция и переход

База исправления — bbda9d3f9ebcb035e95b4671db8064a46dbe7a23. Прежние клетки сохранены; pj-миры исправлены под настоящую операцию: целевой файл не коммитится до вызова. Старые HEAD-only клетки по-прежнему коммитят целевой файл. Новые клетки предъявляют новый файл, нештатную замену корректного HEAD, различие индекс/рабочий файл, отсутствие файла, чужой каталог и несудейскую ветку, неизменность adversary/reviewer/arbiter, зарегистрированный 178 вне HEAD и изменённый байт. После честного допуска проверяющий сам коммитит именно проверенные байты и сравнивает rc/stdout/stderr двух режимов. Сам субъект не вправе менять HEAD, индекс или рабочий файл. Ожидания и снимки сохранены в памяти до запуска.

Привязки стабов к ветвям — build.py и генерируемый stabs.tsv, не проза контракта. Добавлены адресные мутации старого HEAD вместо файла, другого файла, проверки только новых файлов, проверки после собственного коммита и пропуска расхождения с индексом. Ошибка среды/синтаксиса/таймаут не засчитывается поимкой.

Способ закрытия блока — клетка: обещание допуска реальной операции нельзя снять или вынести за границу R-0168; формат карты уже судится канонической библиотекой 193, но канон сам не различает неверный источник байтов. Поэтому добавлены только поведенческие клетки на названный отказ, без собственного парсера карты. Конкурентная замена байтов ПОСЛЕ завершения pre_judge не обещана; ловец — повтор двери судьёй и HEAD-only freeze.

Снято по m2564: предмет переработан в (б). Ранее удалённые number-*/previous-*, direct-*/missing-* и scoped --reachable относились к расширению грамматики, которое больше не является предметом. Это не ослабление 193: unregistered-comma/semicolon/clean-qualifier обязаны отказать. Старые файлы батарей 193/224 не правятся.

Живой образец сохранён побайтно: SHA-256 файла 0a7d5c84b0cbebc8e9e61bfd58db185f6d4f38c0ae711842a7b72c820aacae66, Git blob 0c079b17b3d1a3fee5cf58c5daf19ea9c156d713. Это разные единицы идентичности. В новом режиме ключ вычисляется hash-object из прочитанных байтов, Git-объект целевого файла не обязан существовать. Независимый normalized178.json — оракул полной карты; исходный СУД нечисловой, call 6 — адресные данные, не расширение грамматики новых вердиктов. config-only и index-call6/last-fail6 сохранены.

Черновик v+1 193 — отдельный текстовый коммит без строки владельца: режим по содержимому для материализации, прежний HEAD-only неизменен. Полномочное оформление и freeze — оркестратор по R-0168. Зоны production не расширены: check_verdict_karta уже в зоне implementer. context.py снимает высшие frozen-зоны живым Git.

## Двери

- Model · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --catalog · 0 · 0
- Repo-before · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --repo . · 1 · 1
- Precision · bash scripts/check_precision_gate.sh . contracts/232-gramm-karta-krome.md · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh contracts/232-gramm-karta-krome.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери выше; сырые stdout/stderr/rc сохраняются verify.py, неподтверждённая зелень не объявляется наблюдённой · - · -
- К-02 · чисто · вход: R-0168 включает реестр и materialization, Crit232 единственный блок — источник байтов до коммита · - · -
- К-03 · чисто · вход: режим по содержимому добавлен, прежние HEAD-only И5/И7 и регрессии 193/224 сохранены · - · -
- К-04 · чисто · вход: своя семья и контракт 232, отдельный черновик 193; context.py по живым frozen, production неизменен · - · -
- К-05 · чисто · вход: И7/И8 контракта задают команду, источник, порядок, rc и причины для реальной операции · - · -
- К-06 · чисто · вход: ошибки подготовки, неожиданный rc, timeout и синтаксис не считаются поимкой; usage rc 2 отдельно · - · -
- К-07 · чисто · вход: новый честный файл, нештатная замена, содержимое живого 178 вне HEAD и после коммита · - · -
- К-08 · чисто · вход: raw-byte Git-канон, различающая text/CRLF последовательность и честные LF/text и CRLF/raw соседи; полный контроль перед стабами · - · -
- К-09 · чисто · вход: реестр/current/index/last-FAIL, config-only, новые/заменённые/отсутствующие файлы и остальные роли · - · -
- К-10 · чисто · вход: rc/обе трубы, полный API-результат; снимки HEAD/индекса/файла до субъекта, одинаковые байты после коммита · - · -
- К-11 · чисто · вход: полная литеральная карта normalized178.json и статусы в памяти до вызова; digest носителей до запуска · - · -
- К-12 · чисто · вход: штатная грамматика 193, JSON Schema/validate_std, bash -n/shellcheck; своего парсера формата нет · - · -
- К-13 · н/п · секреты и новый сетевой протокол не вводятся · - · -
- К-14 · чисто · вход: новый честный/плохой файл, честная/плохая замена, совпадающий/отличающийся индекс, точный/изменённый blob · - · -
- К-15 · чисто · вход: catalog/source.json/stabs.tsv и фактический проход каждой связи независимо проверяют счёт · - · -
- К-16 · чисто · вход: до коммита проверяется --file, не HEAD; конкурентная последующая подмена отделена и имеет ловца · - · -
- К-17 · н/п · продуктовая модель 188 не объявлена, предмет — станционные двери · - · -

## Дельта

- К-03 · клетка · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --model · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --model · 0 · 0
- К-08 · канон/инструмент · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --stabs · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --model · 0 · 0
- К-16 · клетка · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --stabs · 0 · 0

## Класс шире примера

Мутация критика: прежний HEAD вместо --file. Соседи: новый честный файл, плохая замена старого честного файла, честная staged-замена; подмена другим честным файлом и несовпадающий индекс. Новый предикат выбора режима красится st25/st26/st27, честный новый/заменённый файл зелён; порядок красится st28, честный субъект не коммитит; предикат индексной идентичности красится st29, совпадающий staged-файл зелён. Ключ реестра от рабочих байтов проверяют content-live-uncommitted/content-changed-byte; посткоммитная эквивалентность — commit_equivalence. Воспроизведение до/после — reproduce.py, запускается verify.py.

## Наблюдение процесса

Кандидат в main-журнал (А-номер не присваивается в wip): мир батареи коммитил целевой вердикт ДО pre_judge, хотя реальная операция 206 вызывает дверь до коммита. HEAD-only оракул оказался неверным для предкоммитного шва: честный новый файл красен, плохая замена зелена. Цена — один полный круг Crit232. Источник — verdicts/critic/contracts-232-v1.md и reproduce.py --before. Класс — конструкция проверки. Закрыто разделением исторического HEAD-only и явного content-режима, незакоммиченными входами и независимой проверкой идентичности после коммита. Журнал в main дополняет оркестратор.

## Измеренные результаты предыдущего круга Architect232c

Чистый SSH-origin-клон tmp/verify232-origin, HEAD bbda9d3f9ebcb035e95b4671db8064a46dbe7a23; наложены только контракт/своя семья, production и старые батареи не подменялись. Полные stdout/stderr/rc/секунды, включая ранние ошибки и исправленные прогоны, сохраняются в tmp/verify232-results.json. Счёт: 55/24/38 → 70/29/44 (клетки/стабы/связи, catalog + реальное исполнение всех связей).

```text
--model: rc 0, KLETKI 70 KRASNYH 0
--stabs: rc 0, STABY 29 SVJAZI 44 ZHIVYH 0
--sintaksis: rc 0, SINTAKSIS 19 SHELLCHECK 4 JSON_SCHEMA 1
--catalog: rc 0, KLETKI 70 STABY 29 SVJAZI 44
--repo .: rc 1, KLETKI 70 KRASNYH 47
context.py: rc 0, ДЕКЛАРАЦИИ 72
193 --repo .: rc 0, KLETKI=152 ZELENYE=152 KRASNYE=0
224 --repo .: rc 0, KLETKI 100 KRASNYH 0
reproduce.py --before: rc 0, новый файл rc 1, плохая замена rc 0
reproduce.py: rc 0, новый файл rc 0, плохая замена rc 1 KARTA_NE_SHTATNA
```

Оба воспроизведения дополнительно коммитили плохую замену проверяющим: историческая HEAD-дверь давала rc 1. Это демонстрирует дефект старой reference до/после, не утверждает зелень production.

Красные до реализации (ровно 47): live-registered, live-installed-default, identical-other-path, index-call6, last-fail6, config-add-only, config-remove-only, config-new-blob-only, config-new-map-only, config-equivalent, subject-empty-bait, invalid-json, unreadable-registry, schema-missing, schema-invalid, wrong-version, duplicate-sha, duplicate-json-key, prefix-sha, uppercase-sha, mask-sha, repaint-block, repaint-reference, change-reference-target, change-tail, bad-normalized-grammar, missing-normalized-class, change-call, pj-invalid-accept, pj-invalid-fail, pj-invalid-call2, pj-live-unregistered, pj-local-fake, pj-timeout-not-bypass, pj-role-bypass, pj-new-honest, pj-new-invalid, pj-replace-invalid, pj-replace-honest, pj-index-different, pj-file-missing, pj-outside-critic, content-new-honest, content-new-invalid, content-live-uncommitted, content-changed-byte, content-replacement-invalid. Причины — отсутствие production-реестра, content-режима, предкоммитной ноги и сверки индекса; прежняя карта/HEAD-only регресс зелён.

Ранние два живых предъявления st25/st27 выявили, что несовпадение индекса маскировало источник старого HEAD: контрпример замены теперь честно staged ДО двери, как реальная операция. st28 получил явную fixture identity, чтобы краснеть реальным ранним коммитом, не ошибкой окружения; у model-двери NEXT_ID_LIB экспортирован вместо неиспользуемого локального присваивания для штатного shellcheck. После этих ремонтов полный честный контроль и все связи зелены/красны соответственно; смысл 193 и предмет 232 не менялись.

Финальные двери в том же чистом origin-клоне (SDACHA_TIMEOUT_SEK=1200, SDACHA_BUDZHET_SEK=2400):

```text
pre_critic: rc 0, КРИТИК: дверь зелёная (807.59 с)
check_sdacha --run: rc 0, двери=7 карта=17/17 дельта=5 (700.21 с)
check_precision_gate: rc 0, OK (27.60 с)
```

Сухой done-гейт check_provodka: rc 1, `guard не подключён` (живой прогон в origin-клоне). Это прежнее объявленное состояние черновика: CI подключает orchestrator после freeze/implementer; чужие .github/workflows и registry этой пачкой не меняются, зелёный done не заявляется.


## Наблюдение исправительного круга

Кандидат в main-журнал без А-номера: файловый `git hash-object -- <путь>` применяет атрибуты и не доказывает raw-byte идентичность. Цена — узкий Crit232b и арбитраж. Источник — Crit232b К-08 и contracts-232-b1.md. Класс — конструкция проверки/выбор инструмента. Закрыто штатным --no-filters, отрицательной последовательностью и честными соседями; один только успех до add не свидетельствует об индексных байтах, поэтому финальная дверь после add обязательна. Запись общего журнала — только в main оркестратором; в wip журнал не правится.
