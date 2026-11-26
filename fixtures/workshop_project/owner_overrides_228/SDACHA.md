# СДАЧА 228 — owner-overrides

Лист architect до реализации. Машинные ряды задают ожидаемые rc, check_sdacha перепроверяет их исполнением. Production, CI и реестры не изменены. SHA базы и исходный census — source.json; прежняя адресная привязка — stabs/mutations.json; историческая — код historical_checks.py/historical_snapshot_checks.py.

## Двери

- честная-модель · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --model · 0 · 0
- адресные-стабы · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --stabs · 0 · 0
- синтаксис · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --sintaksis · 0 · 0
- census · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --catalog · 0 · 0
- гигиена-парсинга · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --parsing · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/228-sh3-owner-overrides.md · 0 · 0
- спецификация · bash scripts/check_spec_ready.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- пересечения · bash scripts/check_precision_gate.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/228-sh3-owner-overrides.md · 0 · 0
- грамматика-проводки · bash scripts/check_provodka.sh --grammar . contracts/228-sh3-owner-overrides.md · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0

## Карта классов

- К-01 · чисто · вход: все двери формы перечислены выше; check_sdacha --run исполняет лист, SDACHA_OKRUG разрывает рекурсию · - · -
- К-02 · чисто · вход: R-0114/R-0102, FABLE-RECOMMENDATIONS-1121 §в/Ш-3/Б-6, PLAN-V9 §1/4 и ADR 21.11; фактические четыре двери установлены по census 237 · - · -
- К-03 · чисто · вход: context.py читает высшие frozen и canonical zones_load; регрессы 065/083/200/207/210/217/218/992/071 сохранены; 218 интегрируется прежде cutover · - · -
- К-04 · чисто · вход: зоны architect/implementer/orchestrator раздельны; precision-гейт проверяет пересечения; production/CI здесь не пишутся · - · -
- К-05 · чисто · вход: приёмка задаёт команды и rc; исторический живой пересъём явно ручной, не обязательная дверь · - · -
- К-06 · чисто · вход: historical-missing-tools запускает настоящий historical.py с PATH=/nonexistent и требует rc 2; timeout/SIGPIPE ручного check_zones явно записываются, не объявляются полным доказательством · - · -
- К-07 · чисто · вход: настоящие Bash API, Git и четыре CLI; parsing — runner 041; baseline-identity сравнивает материализованные двери с pinned git show, не двойник инструмента · - · -
- К-08 · чисто · вход: прежние клетки и стабы сохранены; actor-name проверяет близкие неравные имена на настоящих CLI process exact/prefix и mint; каждый мир сначала отказывает без grant, затем проверяет буквальный actor; пять адресных мутаций сравнения — stabs/mutations.json; ошибки чтения 228d неизменны · - · -
- К-09 · чисто · вход: все 148 строк/586 старых предикатных ответов и живые allow/deny миры сохранены; snapshot требует все 312 пар четырёх CLI на 78 SHA · - · -
- К-10 · чисто · вход: snapshot сверяет rc и хеши обеих труб, покрытие, закрытый перечень четырёх исключений и complete=false; реальный live replay вынесен в ручной --historical · - · -
- К-11 · чисто · вход: все oracle-байты снимаются до субъекта; equality-log и хеши закоммичены; реконструкция reference из измеренного равенства указана явно, не выдана за отдельно сохранённые actual-трубы · - · -
- К-12 · чисто · вход: Bash — bash -n и pinned shellcheck через validate_std; Python — ast; snapshot — JSON Schema Draft 2020-12 через jsonschema; git-факты — plumbing · - · -
- К-13 · н/п · секреты в выводе не предмет; новых secrets/variables/environments нет · - · -
- К-14 · чисто · вход: actor-name содержит равенство/'*' и честные имена с точкой/дефисом/подчёркиванием/цифрой/разным регистром; каждый положительный вход имеет отрицательный no-grant контроль того же CLI/автора/пути; новые стабы привязаны только к различимым неравным именам · - · -
- К-15 · чисто · вход: --catalog сверяет прежние числа с source.json; schema задаёт 78/4/312, snapshot независимо сверяет лог, исходные 532 ответа и точное декартово покрытие · - · -
- К-16 · чисто · вход: рисковая авторизация; граница исторического доказательства — cognitive-only с reviewer, literal-матрицей, живыми мирами и ручным replay перед ленд-ревью · - · -
- К-17 · н/п · станционный предмет, продуктовой модели 188 нет; общий reader и TSV вместо ветвей в дверях · - · -

## Дельта

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-228-v1.md

- К-08 · клетка · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --stabs · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --model · 0 · 0

## Соответствие блоков

| Блок Crit228/1 | Клетки | Стаб (код-якорь в mutations.json) | Ловит --repo |
| --- | --- | --- | --- |
| И3: потеря автора CLI | actor:process:match/other/wildcard, actor:prefix:match/other/wildcard, actor:mint:match/other/wildcard | critic-literal-author; соседний prefix-ignores-actor; существующий ignore-actor дополнительно привязан к process:other/mint:other | Да: эти же живые CLI-миры исполняются без патча production |
| И1: ошибка чтения стала допуском | unreadable:api:eacces/directory/eloop, unreadable:cli:eacces/directory/eloop | critic-oserror-allow; соседний oserror-empty-registry | Да: те же API и check_charter с читаемым контролем |

Способ «клетка»: снять обещание/сузить границу нельзя без изменения И1/И3; канон формата не доказывает передачу автора и fail-closed реальной ошибки чтения. Используются настоящие Git/Bash и системные OSError, а не двойник инструмента. При EACCES проверяется реальное открытие: root, способный читать chmod 000, получает именованный rc 2 батареи, не фиктивный зелёный; EISDIR/ELOOP наблюдаемы и для root.

Новые предикаты: actor match/other/wildcard и ожидаемый rc (мутанты literal-author/ignore-actor, честные равный/'*'); errno подтверждает именно созданную ошибку (реальные chmod 000, каталог и self-symlink, читаемый файл — контроль); rc API/CLI и самостоятельная диагностика (OSError→allow/empty, читаемый grandfather — контроль). Неизменность HEAD проверяется прежним Git-оракулом. Новых дверей/обязательств сверх двух блоков нет; историческая граница не менялась.

## Дельта 228e — Crit228/2 К-08 (тот же класс К-14)

Способ — клетка: обязательство И3/И4 не сужается; канон формата не доказывает буквальность сравнения. Новый самописный разбор не вводится: настоящая check_zones получает реальные Git-автора/SHA/путь и TSV. Процессные exact/prefix и mint — все существующие CLI-вызовы, передающие actor-контекст; mint сохраняет прежнее ограничение автора orchestrator, а process проверяет остальные допустимые авторские имена.

| Блок/мутация | Клетки actor-name (каждая отдельно) | Стаб в stabs/mutations.json | Ловит --repo |
| --- | --- | --- | --- |
| К-08/К-14: author.startswith(actor) | process/prefix/mint: prefix | critic-actor-prefix | Да, те же настоящие CLI без reference-патчей |
| К-08/К-14: lower(actor)==lower(author) | process/prefix/mint: title-case, upper-case; process/prefix: case-reversed | critic-actor-casefold | Да |
| К-08/К-14: actor in author | process/prefix/mint: prefix, infix, suffix | critic-actor-substring | Да |
| К-08/К-14: игнорирование разделителей | process/prefix/mint: trailing-dash, trailing-dot, separator-swap, separator-insert | actor-ignore-separators | Да |
| К-08/К-14: срез до первой точки/дефиса | process/prefix/mint: trailing-dash, trailing-dot; process/prefix: dot-components, dash-components | actor-first-component | Да |

Предикаты новых клеток: no-grant требует rc 1 и сообщение о точных авторе/SHA/пути, чтобы неизвестный автор не прошёл клетку молчаливым skip; grant требует rc 0 для равенства/'*' либо rc 1 с тем же сообщением и без OWNER_OVERRIDES_INVALID для близкого неравного имени. Мутации выше красят каждый свой адресный вход; честные эквиваленты — equal/wildcard для всех трёх видов, equal-dot/equal-dash/equal-underscore/equal-digit/equal-title-case/equal-upper-case для process exact/prefix. Новые авторы объявлены в настоящей frozen-зоне allowed.txt до проверяемого коммита; их outside-путь сначала реально красен без grant. SHA и автор проверены Git plumbing; HEAD сравнивается с памятью до вызова. Новый предмет, двери или обязательства сверх буквального сравнения не добавлены.



## Исторический снимок: происхождение и граница

Решение оркестратора task-architect228c.md: обязательная приёмка включает литеральную матрицу 148/586, живые API/CLI миры и закоммиченный снимок паритета. Живой пересъём 133 SHA × четыре CLI в обязательную приёмку и CI НЕ входит.

Исходный historical.json — 532 ранее снятых ответа неизменённого baseline. Предыдущий прогон 228b длился 6421.70 с и завершился rc 2: timeout baseline/check_zones 60 с. Завершены 82 SHA: 78 с точным паритетом всех четырёх CLI и четыре исключённых из-за SIGPIPE. Полные actual-трубы reference не сохранялись. reproducibility.json поэтому явно имеет provenance.kind=reconstructed-from-equality-log: значения reference восстановлены из historical.json только для строк сохранённого stdout HISTORICAL_SHA <sha> doors=4, которые runner печатал после полного сравнения; это НЕ новый измеренный вывод и НЕ отдельный снимок сырых труб. Источник — прогон версии 247e39679b059dfb8d823e77bfbc95c25152004c, stdout сохранён побайтово в historical-parity.log, его hash включён в манифест/lock. Исключения сохраняют реально снятые saved/rechecked и причину BASELINE_SIGPIPE. complete=false сохраняется; оставшиеся SHA не объявлены доказанными.

Снимок проходит JSON Schema и проверки хешей, точного покрытия, обоих ответов каждой пары, списка исключений и равенства состава с equality-log. Подмена, усечение, скрытый complete=true и рост unreproducible — красные входы. Новые адресные мутанты: игнорирование паритета снимка, тихий рост исключений, игнорирование хеша, замена неизменённого baseline reference и включение live replay в --model. Прежние клетки/мутации не ослаблены; изменения probe.py — только добавления.

## НЕ ЗАЩИЩАЕТ

Живой пересъём исторического CLI-паритета по всем 133 SHA не входит в обязательную приёмку: baseline check_zones нестабилен (наследуемый SIGPIPE/timeout 60 с под нагрузкой); паритет на невоспроизведённых SHA не доказывается. Остаточный риск cognitive-only (AGENTS правило 1). Ловцы — reviewer (полный diff production), литеральная матрица 148/586, живые API/CLI миры, ручной --historical перед ленд-ревью. Пересмотр границы — консультант/владелец, не автор батареи.

Ручная команда: bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --historical. Для production: python3 fixtures/workshop_project/owner_overrides_228/historical.py --historical --repo .; ограничение --seconds 1..2400 (по умолчанию 2400). Она НЕ строка раздела «Двери» и НЕ CI. rc 0 означает только отсутствие расхождений на воспроизведённых; rc 1 — расхождение, rc 2 — недоступный инструмент. complete=false допустим при time budget/timeout/SIGPIPE check_zones, причины/расхождения печатаются и записываются в tmp/scratch-arch228/historical-manual.json; закоммиченные ожидания не перезаписываются.

## Рефлексия процесса

Измеренный дефект 228b — checkpoint сохранял baseline-наблюдения лишь при исключении и вообще не сохранял actual reference. Число 78 в манифесте само по себе не является снимком ответов: для переноса потребовался подлинный equality-log с явной provenance реконструкции. Новый ручной runner сохраняет отдельный scratch-отчёт, а неполный результат не маскируется complete=true. Это наблюдение конструкции стенда; А-NN может быть внесена только оркестратором в main, не в этой wip-ветке.

Первый собственный --stabs выявил двух живых hash-мутантов: вспомогательный rejected ошибочно считал успешный tuple загрузчика ненулевым rc. Исправлен тип наблюдаемого результата (только rc 1 либо именованное исключение), добавлен честный положительный контроль самого загрузчика. Это дефект проверки, не production и не основание ослабить hash-обязательство.

## Проводка исполнения

CI подключает orchestrator; до этого предъявляется только --grammar ПРОВОДКА, не done. Реализация production и регрессы после cutover остаются implementer согласно контракту. Исходный до-реализационный контроль 228b: --repo . rc 1, KLETKI=52 ZELENYE=6 KRASNYE=46; это не результат нового прогона 228c.

## Замер 228c

Последовательный прогон в собственном чистом SSH-origin-клоне с дельтой кандидата: --model rc 0 за 17.67 с; --stabs rc 0 за 35.33 с; --sintaksis rc 0; --catalog rc 0; --repo . rc 1, KLETKI=52 ZELENYE=6 KRASNYE=46. Старые стабы: 35/43, историческая политика: 4/4, снимок: 6/6; во всех группах ZHIVYH=0. Census клеток по группам: 52, 5, 9. Снимок: REPRODUCIBLE_SHAS=78 EXCLUDED_SHAS=4 DECISIONS=312, complete=false.

pre_critic rc 0 (136.36 с); SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 check_sdacha --run rc 0 (167.72 с, двери=12 карта=17/17 дельта=0); check_precision_gate rc 0 (21.78 с). Настоящий parsing 041 исполнен в листе, не подменён проверкой профиля.

Ровно одна фоновая ручная проба W --historical --seconds 120: rc 2 за 0.68 с, именованный GIT/tool failure при восстановлении refs.json — в чистом origin-клоне нет объекта ca425084bad2090fbb38535a33d9a5a0ae6445e1 (refs/tags/archive/wip-140-impl-v2-ca425084b). Проба не объявлена зелёной, исключения/ожидания ради неё не изменены; это недоступная предпосылка полного исторического мира, не обязательная дверь. Для живого replay перед ленд-ревью нужна полная объектная база сохранённых тегов.

## Рефлексия 228d

Первая адресная проба нового unreadable:cli:directory нашла дефект самой клетки: честный check_charter пишет штатные ok-строки в stderr. Положительный CLI-контроль теперь требует rc 0 и пустой stdout, не запрещает штатную диагностику; API-контроль остаётся без вывода. Отказ на OSError по-прежнему требует самостоятельную строку OWNER_OVERRIDES_INVALID. Журнал А-NN в wip не пишется; запись при необходимости делает orchestrator в main.

## Замер 228d

Чистый SSH-origin-клон внутри собственной копии, база 1af3cd3c9dbd4e99b1fbc89efc49f10a04c20f10; команды исполнены последовательно. И1/И3 и историческое доказательство не менялись. Все прежние строки probe.py сохранены; новые клетки добавлены. Числа ниже — stdout собственных прогонов, не обещание количества в инвариантах.

```text
--model: RAW_RC=0 SECONDS=32.23
KLETKI=67 ZELENYE=67 KRASNYE=0
--stabs: RAW_RC=0 SECONDS=61.52
STABS=39 BINDINGS=62 ZHIVYH=0
HISTORICAL_STABS=4 BINDINGS=4 ZHIVYH=0
SNAPSHOT_CELLS=9 SNAPSHOT_STABS=6 ZHIVYH=0
--sintaksis: RAW_RC=0 SECONDS=0.32
--catalog: RAW_RC=0 SECONDS=0.08
CELLS=67 STABS=39 BINDINGS=62 ROWS=148 MATRIX=586
--repo .: RAW_RC=1 SECONDS=9.66
KLETKI=67 ZELENYE=9 KRASNYE=58
pre_critic: RAW_RC=0 SECONDS=263.12
check_sdacha --run: RAW_RC=0 SECONDS=304.46
СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2)
check_precision_gate: RAW_RC=0 SECONDS=23.89
```

Оба мутанта критика проверены полным --model до/после добавления клеток, не только адресным --stabs. Для --repo материализована та же честная/мутантная реализация: байты четырёх дверей и библиотеки копируются обычным --repo, без reference-патчей на этом пути.

| Блок | Способ | Команда/вход | До: rc, секунды | После: rc, секунды, красных |
| --- | --- | --- | --- | --- |
| И3, К-08/К-14 | клетка | --model; build.py process/mint: "$an" → orchestrator | 0, 30.10; 52/52 зелёных | 1, 27.47; 4 |
| И3, К-08/К-14 | клетка | --repo; честный контроль / тот же мутант | н/п | 0, 23.68; 0 / 1, 31.39; 4 |
| И1, К-08/К-14 | клетка | --model; except OSError: sys.exit(0) | 0, 19.96; 52/52 зелёных | 1, 31.52; 6 |
| И1, К-08/К-14 | клетка | --repo; честный контроль / тот же мутант | н/п | 0, 32.51; 0 / 1, 31.15; 6 |

Адресный --stabs отдельно поймал prefix-ignores-actor на actor:prefix:other и oserror-empty-registry на каждой из шести API/CLI ошибок; ignore-actor дополнительно пойман на actor:process:other и actor:mint:other. Все 62 привязки красны своим предъявлением после честного контроля. Сырой полный stdout/stderr прогона хранится в tmp/evidence-228d/ собственной копии. Печать KRASNO snapshot в --model/--stabs — существующий намеренный отрицательный контроль снимка, не новый провал: итог MISMATCHES=0, ZHIVYH=0, rc 0.

## Рефлексия 228e

Предыдущая пара «fixture/orchestrator» различала потерю автора, но не более слабый предикат равенства. Нужны близкие неравные значения и положительные допустимые написания; одной пробы на regex-грамматику недостаточно. No-grant контроль в каждом новом мире дополнительно исключает пустую зелень от необъявленного автора. Журнал А-NN в wip не меняется.

## Замер 228e

Чистый SSH-origin-клон внутри собственной копии, исходный HEAD f60f16ef54496924aaca30070be3dba73970ed6f; наложены только файлы зоны кандидата. Прогоны последовательны. Историческая граница, И1…И3, существующие клетки и стабы не менялись; И4 только уточняет буквальность actor. В probe.py только добавления. Независимый счёт литеральных таблиц через AST: NEW_ACTOR_CASES=57; новых связей в JSON — 42, новых стабов — 5. --catalog независимо получил следующие итоговые числа.

```text
--model: RAW_RC=0 SECONDS=47.27
KLETKI=124 ZELENYE=124 KRASNYE=0
--stabs: RAW_RC=0 SECONDS=72.22
STABS=44 BINDINGS=104 ZHIVYH=0
SNAPSHOT_CELLS=9 SNAPSHOT_STABS=6 ZHIVYH=0
HISTORICAL_STABS=4 BINDINGS=4 ZHIVYH=0
--sintaksis: RAW_RC=0 SECONDS=0.21
--catalog: RAW_RC=0 SECONDS=0.06
CELLS=124 STABS=44 BINDINGS=104 ROWS=148 MATRIX=586
--repo .: RAW_RC=1 SECONDS=23.47
KLETKI=124 ZELENYE=48 KRASNYE=76
pre_critic: RAW_RC=0 SECONDS=331.62
check_sdacha --run: RAW_RC=0 SECONDS=369.67
СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=2)
check_precision_gate: RAW_RC=0 SECONDS=22.08
check_verdict_karta: RAW_RC=0 SECONDS=19.25
КАРТА: 17/17 зелёный
```

SDACHA_TIMEOUT_SEK=1200, SDACHA_BUDZHET_SEK=2400. --repo . намеренно красен: production ещё не реализован; отрицательные клетки, которые baseline уже отвергает, не считаются свидетельством нового reader. Честный материализованный reference предъявлен отдельно через --repo: RAW_RC=0 SECONDS=44.96, KLETKI=124 ZELENYE=124 KRASNYE=0.

Операция actor != author в model/lib_owner.sh заменялась буквально и отдельно; после каждого полного --model модель восстановлена. «До» — самостоятельно исполненный --model на базе f60f16ef5 без новых клеток, не пересказ вердикта. --repo — отдельная материализованная реализация с тем же единственным мутантным сравнением, без патча четырёх CLI на пути --repo.

| Блок | Способ | Операция/стаб | --model ДО: rc / зелёных / с | --model ПОСЛЕ: rc / красных / с | --repo: rc / красных / с |
| --- | --- | --- | --- | --- | --- |
| К-08/К-14 | клетка | critic-actor-prefix | 0 / 67 / 25.24 | 1 / 3 / 48.29 | 1 / 3 / 44.73 |
| К-08/К-14 | клетка | critic-actor-casefold | 0 / 67 / 26.27 | 1 / 8 / 43.87 | 1 / 8 / 43.34 |
| К-08/К-14 | клетка | critic-actor-substring | 0 / 67 / 23.29 | 1 / 9 / 43.35 | 1 / 9 / 44.85 |
| К-08/К-14 | клетка | actor-ignore-separators | н/п | 1 / 12 / 47.04 | 1 / 12 / 47.42 |
| К-08/К-14 | клетка | actor-first-component | н/п | 1 / 10 / 44.52 | 1 / 10 / 44.49 |

Все красные после мутаций — адресные actor-name, равные/'*' и честные имена остались зелёными. --stabs поймал каждую из 42 новых связей отдельно после честного контроля; прежние 62 связи сохранены. Полные сырые stdout/stderr, argv, cwd, rc и секунды — tmp/evidence-228e/ собственной копии. Существующая строка KRASNO snapshot — отрицательный контроль самого снимка с итогом MISMATCHES=0, не провал команды. Ручной --historical не запускался заново: историческое доказательство вне дельты задания 228e.
