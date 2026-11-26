# СДАЧА 228 — owner-overrides

Лист architect до реализации. Два rc в машинных рядах — согласованные заявления, которые check_sdacha перепроверяет исполнением. Production-двери и реестр не изменены. SHA базы и census — source.json; адресная привязка — stabs/mutations.json, не проза контракта.

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

- К-01 · чисто · вход: все двери формы перечислены выше; лист запускается настоящим check_sdacha --run, рекурсия штатно разрывается SDACHA_OKRUG · - · -
- К-02 · чисто · вход: R-0114/R-0102, FABLE-RECOMMENDATIONS-1121 §в/Ш-3/Б-6, PLAN-V9 §1/4 и ADR 21.11 сопоставлены с предметом; неверные имена предполагаемых четырёх дверей заменены фактическим census 237 · - · -
- К-03 · чисто · вход: context.py читает высшие реальные frozen и canonical zones_load; 065/083/200/207/210/217/218/992/071 названы; регресс-команды сохранены без изменения их клеток; 218 интегрируется прежде реализации 228 · - · -
- К-04 · чисто · вход: отдельные зоны architect/implementer/orchestrator; canonical precision-гейт проверяет все 97 пересечений; production и CI здесь не пишутся · - · -
- К-05 · чисто · вход: каждый пункт приёмки несёт команду и rc, включая до/после production, миграцию, регрессы и CI; sourceCanon/модель продукта не объявлены · - · -
- К-06 · чисто · вход: PATH=/nonexistent /bin/bash fixtures/workshop_project/owner_overrides_228/red_owner_overrides_228.sh --model дал rc 2 и NOT_IMPLEMENTED: python3 unavailable; subprocess timeout/tool failure/crash и неверный mutation-anchor также не являются поимкой · - · -
- К-07 · чисто · вход: модель вызывает настоящие Bash-функции, Git CLI и четыре реальные двери; parsing использует существующий runner 041; library import не читает ROOT, каждая реальная CLI получает ROOT мира · - · -
- К-08 · чисто · вход: прежние 35 мутаций/43 предъявления stabs/mutations.json сохранены; отдельные адресные стабы исторической политики привязаны кодом historical_checks.py, честный контроль перед каждой группой; синтаксический сбой не поимка · - · -
- К-09 · чисто · вход: literal baseline всех 148 строк, 586 старых предикатных ответов, два конечных skip-version; перечислены положительные и отрицательные SHA/scope/actor/expiry/file/authority сценарии и malformed-хвост · - · -
- К-10 · чисто · вход: API по rc/обеим трубам; historical.py повторяет сохранённый baseline дважды и проверяет полный паритет только воспроизводимых SHA; unreproducible содержит оба наблюдения, рост бюджета красен; матрица и живые allow/deny миры ловят область исключения · - · -
- К-11 · чисто · вход: baseline.json/исторический оракул загружаются в память до субъекта; ожидаемый реестр не перечитывается из мира после вызова; уставная правка самого carrier не может разрешить себя · - · -
- К-12 · чисто · вход: Bash — bash -n и pinned shellcheck через validate_std; Python — ast; tagged blobs — Git plumbing; поля TSV имеют один reference-parser, буквальная миграция — исполнение старых case, не второй интерпретатор его смысла · - · -
- К-13 · н/п · секреты в выводе не предмет; новые secrets/variables/environments не требуются · - · -
- К-14 · чисто · вход: listed/not-listed, exact/prefix/sibling, canonical/malformed, allowed/denied authority и per-door allow/deny — парные миры; каждый mutant проходит честный контроль своих связанных клеток · - · -
- К-15 · чисто · вход: --catalog сверяет вычисленный census с source.json; context.py независимо считает 237 SHA-вхождений и frozen-пересечения; matrix хранит буквальные ответы pinned-базы · - · -
- К-16 · чисто · вход: рисковый класс авторизации; модель угроз различает область исключения, порчу источника и самоамнистию от подделки owner-текста при общем uid; ловцы остатка названы · - · -
- К-17 · н/п · станционный предмет, продуктовой модели 188 нет; shared reader и TSV вместо новых ветвей в каждой двери · - · -

## Наблюдённые предъявления

До реализации W --repo . вернул rc 1: KLETKI=52 ZELENYE=6 KRASNYE=46. Причины включают OWNER_INTERFACE_ABSENT, исполняемые SHA-литералы, отсутствие защиты authority-carrier, статический skip-version и отсутствие fail-closed для битого TSV. Зелёные старые deny/санкционированные authority-контроли не объявлены дефектами.

Последний лист подтвердил rc 0 для W --model, W --stabs, W --sintaksis, W --catalog и настоящего parsing 041 на полном census 52 клеток / 35 мутаций / 43 предъявлений. Отдельная TDD-проба bad-path-trailing сначала вернула rc 1 на прежнем reference; исправлено удаление ровно литерального suffix '/*', без нормализации пустых компонентов. Честный prefix-scope сохранён зелёным, оба пустых терминатора адресно привязаны к тому же дефектному scope-предикату.

Сквозной последовательный прогон на сдаваемом коде: bash scripts/pre_critic.sh contracts/228-sh3-owner-overrides.md → rc 0; затем bash scripts/check_sdacha.sh . contracts/228-sh3-owner-overrides.md --run → rc 0, «двери=12 карта=17/17 дельта=0». В нём заново исполнены все двенадцать команд листа, включая честную модель, адресные стабы и parsing.

W --catalog: CELLS=52 STABS=35 BINDINGS=43 ROWS=148 MATRIX=586. Independent extraction даёт 133 уникальных исторических SHA. Это 237 вхождений исходного кода, не 237 разрешений.

Исходный исторический съём неизменён: 133 SHA × четыре CLI = 532 ответа, пять check_zones rc 141. Решение оркестратора task-architect228b.md — граница воспроизводимых SHA, не ремонт SIGPIPE и не пересъём до случайного зелёного. historical.py повторяет каждый сохранённый ответ дважды на pinned-baseline; нестабильный SHA явно учитывается в reproducibility.json и исключается целиком, рост числа исключённых SHA сверх бюджета даёт HISTORICAL_ORACLE_TOOL_FAILURE rc 2. Полный паритет воспроизводимых SHA не ослаблен; остаток cognitive-only с ловцами reviewer, literal-матрицей и живыми мирами назван в НЕ ЗАЩИЩАЕТ контракта.

## Рефлексия процесса

Историческая проба выявила дефект собственного стенда: lib_incr выбирает HEAD из cwd до установки ROOT. Вызов с внешним cwd соединял cache исторического мира с HEAD ведущей копии и приводил к 60-секундному таймауту check_zones. Исправлен cwd настоящей CLI, а не порог/продукт; timeout остаётся 60 секунд, частичный checkpoint не принимается за полный оракул. Дополнительно env -i дверей сбрасывает TMPDIR: временные копии зависимостей получают внутренний scratch, выбранные четыре --repo-двери не патчатся. Это наблюдения конструкции стенда; запись А-NN может быть внесена только оркестратором в main, не в данной wip-ветке.

Общий 3600-секундный предел внешнего запуска остановил съём после 461 из 532 решений; это не зелёный результат. Неполный historical.json предъявлен --model: rc 2, NOT_IMPLEMENTED: HISTORICAL_ORACLE_INCOMPLETE. --capture-resume допускает только точный префикс неизменённой базы и сначала проверяет sha256 всех четырёх исходных production-дверей; продолжение не подменяет и не переснимает готовые ответы. Приёмочный предел каждой CLI остаётся 60 секунд.

Исправительный круг 228b: W --model → rc 0, прежние 52 клетки зелены; W --stabs → rc 0, прежние 35 мутаций/43 предъявления и отдельные исторические стабы пойманы, ZHIVYH=0; --sintaksis и --catalog → rc 0; --repo . → rc 1, KRASNYE=46. pre_critic → rc 0; SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 check_sdacha --run → rc 0 («двери=12 карта=17/17 дельта=0»); check_precision_gate → rc 0.

Полный historical --model --record-reproducibility НЕ зелёный: rc 2, timeout неизменённого baseline/check_zones после 60 секунд; весь прогон 6421.70 с. Завершён префикс 82 из 133 SHA: 78 воспроизводимых с полным паритетом четырёх CLI, четыре исключённых; следующий SHA 8f2dc6c24f5b54425eb3e3a0106984f5edffc44c. reproducibility.json несёт complete=false, четыре измеренных исключения с сохранёнными и двумя повторными rc/хешами труб, исходный бюджет declared_unreproducible_shas не расширен. Среди измеренных — новый 1fb51dc3378087bcfc9143d9e2a6aad103a00485/check_zones (сохранён rc 0; обе перепроверки rc 141, с различными stderr). Полная классификация оставшихся SHA и допуск к freeze заблокированы, не объявлены выполненными; Main получил точный отказ. Timeout/production не изменены, повторов до случайного зелёного нет.

Конструктивное наблюдение: первая версия границы ошибочно отвергала новый адрес уже внутри численного бюджета. Исправлено на число уникальных SHA; честный контроль роста допускает другой адрес и два CLI одного SHA. При первом долгом отказе сохранился только stdout, поэтому runner теперь сохраняет проверенные baseline-наблюдения при каждом исключении, с complete=false до завершения. Журнал А-NN остаётся только для main, не для wip.

## Проводка исполнения

CI в зоне orchestrator; до его подключения предъявляется только грамматика ПРОВОДКА, не done. Батарея исторических CLI исполняется отдельно от ограниченного по времени листа формы. Реализация и регрессы после cutover остаются следующему исполнителю согласно контракту, это не выполненная production-работа architect.
