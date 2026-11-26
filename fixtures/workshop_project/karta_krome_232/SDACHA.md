# СДАЧА 232 — историческое исключение данными и материализация критика

Обещание: исходный 178 принимается только по точному Git blob в установочном реестре; новая нештатная карта не материализуется. Наблюдение: настоящий Git, реальные check_verdict_karta/pre_judge, API библиотеки и полная раскрытая карта. Production в этой пачке не меняется.

## Конструкция и переход

До: 69 клеток / 10 стабов / 33 связи (source.json базового 8fe4e79ca). После: 55 клеток / 24 стаба / 38 связей (build.py, catalog, source.json/stabs.tsv). Привязки — build.py; каждая связь исполняется отдельно после полного честного контроля. Ошибка среды/синтаксиса не считается поимкой. Ожидаемые rc/карта — литералы памяти до субъекта, не reference и не диск проверяемого. Хеши носителей/оракула сверяются до запуска. JSON-эквивалент и тот же blob под другим путём зелены; другой blob и новая нормализованная карта допускаются только добавлением конфигурации без правок кода. live-installed-default отдельно судит настоящую поставленную запись, без инъекции тестовой политики.

Снято по m2564: предмет переработан в (б). Удалены прежние клетки number-* и previous-* на новое допущение хвостов `, кроме` / `;`, их произвольные/пустые/регистр/пробел/перенос/терминатор-соседи, новые большие/нулевые номера с этими хвостами, direct-*, missing-* и scoped --reachable; старые стабы st01-any-tail…st10-whitespace-text больше не про предмет. Старый обязательный live178-as-is заменён положительным live-registered и отрицательными live-empty/live-absent; исходные байты live178.md сохранены. Не является ослаблением 193: новая грамматика снята, unregistered-comma/semicolon/clean-qualifier теперь обязаны отказать. Прежние клетки 193 и 224 не правились.

Идентификатор из задания 0a7d5c84 — SHA-256 файла, НЕ Git blob; полный digest `0a7d5c84b0cbebc8e9e61bfd58db185f6d4f38c0ae711842a7b72c820aacae66`. Живые `git hash-object` и `git -C a178 rev-parse 5cf13779:<путь>` независимо дали `0c079b17b3d1a3fee5cf58c5daf19ea9c156d713`. Реестр использует этот 40-hex. Исходный СУД нечисловой: call 6 задаётся адресными данными, а не общим расширением грамматики. Именно index-call6 и last-fail6 проверяют, что принят не только предъявленный текст, но и исторический вызов.

Черновик v+1 193 — отдельный коммит, только новая норма; полномочную строку добавляет оркестратор при приёме по R-0168. Остальной frozen-текст и батареи не меняются. Пересечения pre_judge: 140/172/185/206; lib: 193/204; check_verdict: 193 — сняты живым context.py по высшим frozen, а не взяты из памяти.

## Двери

- Model · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --catalog · 0 · 0
- Repo-before · bash fixtures/workshop_project/karta_krome_232/red_karta_krome_232.sh --repo . · 1 · 1
- Precision · bash scripts/check_precision_gate.sh . contracts/232-gramm-karta-krome.md · 0 · 0
- Pre-critic · bash scripts/pre_critic.sh contracts/232-gramm-karta-krome.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: исполняемые двери выше; сырые результаты прогона сохраняет verify.py, неподтверждённые rc не объявляются наблюдёнными · - · -
- К-02 · чисто · вход: R-0168 включает исторический реестр и pre_judge verdict; расширение нового языка снято; полный неизменённый живой образец сохранён · - · -
- К-03 · чисто · вход: узкий v+1 193 разрешён R-0168; поправлена единица хеша, не образец; остальные обязательства 193/204/224 сохранены · - · -
- К-04 · чисто · вход: только контракт/своя семья и отдельный черновик 193; production не правится; context.py печатает живые frozen-зоны · - · -
- К-05 · чисто · вход: каждый инвариант имеет публичное наблюдение через CLI/API/materialization; полный результат — карта, а не только маркер успеха · - · -
- К-06 · чисто · вход: отсутствие инструментов, таймаут, неожиданный код и ошибки подготовки мира не засчитываются поимкой; штатный usage rc 2 проверяется отдельно · - · -
- К-07 · чисто · вход: полный --model, без reachable-исключений; конфиг-only последовательности проверяют обе стороны и неизменность кода · - · -
- К-08 · чисто · вход: --stabs исполняет каждую связь отдельно; честный контроль обязателен перед мутантами · - · -
- К-09 · чисто · вход: live/current/index/last-FAIL, отсутствующий/пустой/битый реестр, ключи, перекраска, целевой номер, материализация FAIL/accept/вызов 2 и запрет обхода · - · -
- К-10 · чисто · вход: CLI обе трубы/rc, API карта целиком, PJ stdout и именованная первая строка; HEAD и исходный blob после субъекта неизменны · - · -
- К-11 · чисто · вход: ожидаемые 17 статусов — литералы памяти, normalized178.json независим от normalizer; digest до запуска, не диск проверяемого как истина · - · -
- К-12 · чисто · вход: JSON Schema + validate_std, штатная карта 193, bash -n/shellcheck; новый парсер формата карты не пишется · - · -
- К-13 · н/п · новых секретных входов и сетевого протокола предмет не вводит · - · -
- К-14 · чисто · вход: каждый отказ имеет честный сосед; эквивалентный JSON, полный sha, правильные карты и тот же blob под другим путём не запрещены · - · -
- К-15 · чисто · вход: build/catalog и независимые suite/stabs сверяют фактические числа; 72 декларации context.py сняты живым Git · - · -
- К-16 · чисто · вход: риск допуска указан; содержание суждения, доверенная установка и истинность исторического call отделены, ловец reviewer · - · -
- К-17 · н/п · продуктовая модель 188, writers/isolationKeys и операции продукта предметом не затронуты · - · -

## Доказательства

Проверено последовательно в SSH-origin-клоне tmp/verify232-origin на базе 8fe4e79ca8c5165bcd1e7dfb75768c5bd329d3cb, без наложения production/старых батарей. Сырые stdout/stderr/rc/секунды каждого запуска (включая ранние красные и финальные исправленные) — tmp/verify232-results.json.

```text
--model: rc 0, KLETKI 55 KRASNYH 0 (51.56 с)
--stabs: rc 0, STABY 24 SVJAZI 38 ZHIVYH 0 (86.63 с)
--sintaksis: rc 0, SINTAKSIS 13 SHELLCHECK 3 JSON_SCHEMA 1
--catalog: rc 0, KLETKI 55 STABY 24 SVJAZI 38
--repo .: rc 1, KLETKI 55 KRASNYH 35 (красное до реализации)
context.py: rc 0, ДЕКЛАРАЦИИ 72
pre_critic: rc 0, КРИТИК: дверь зелёная (320.12 с)
check_sdacha --run: rc 0, двери=7 карта=17/17 дельта=0 (381.46 с)
check_precision_gate: rc 0, OK (38.16 с)
193 --repo .: rc 0, KLETKI=152 ZELENYE=152 KRASNYE=0
224 --repo .: rc 0, KLETKI 100 KRASNYH 0
check_provodka (done, не --grammar): rc 1, guard не подключён
```

Последняя строка — ожидаемый долг подключения CI оркестратором после freeze/implementer, вне зоны этой пачки; зелёный done не заявляется. Формальная ошибка раннего pre_critic (абзац «Порядок» без заголовка попадал внутрь ПРОВОДКА) исправлена заголовком, затем обе двери дали rc 0. Ранние ошибки подготовки мира/диагностики и inherited unused ts в модельном pre_judge исправлены без изменения production.

Точный список 35 красных до реализации: live-registered, live-installed-default, identical-other-path, index-call6, last-fail6, config-add-only, config-remove-only, config-new-blob-only, config-new-map-only, config-equivalent, subject-empty-bait, invalid-json, unreadable-registry, schema-missing, schema-invalid, wrong-version, duplicate-sha, duplicate-json-key, prefix-sha, uppercase-sha, mask-sha, repaint-block, repaint-reference, change-reference-target, change-tail, bad-normalized-grammar, missing-normalized-class, change-call, pj-invalid-accept, pj-invalid-fail, pj-invalid-call2, pj-live-unregistered, pj-local-fake, pj-timeout-not-bypass, pj-role-bypass.

## Наблюдение процесса

Кандидат в main-журнал, без самовольного А-номера: перед контрактом нужно различать digest файла и Git object id и проверять метаданные живого образца, а не только секцию карты. В задании SHA-256-префикс был назван 40-hex blob, а поле вызова в реальном СУД нечисловое. Буквальная реализация только замены карты пропустила бы этот blob в индексе и не доказала обещанный вызов 6. Цена: отдельная диагностика идентичности, скрытая неполнота прежнего предмета. Источник: hash-object, sha256sum, git rev-parse исторического файла, live178.md:4. Класс: конструкция задания/проверки. Закрыто в этой пачке явной поправкой единицы и клетками index-call6/last-fail6; истинность legacy call остаётся reviewer. Журнал NABLIUDENIA_ARCHITECT.md в wip не меняется; запись в main делает оркестратор.
