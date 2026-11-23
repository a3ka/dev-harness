# СДАЧА 210 — Arb210: сквозной NUL-транспорт имён

Основание: verdicts/arbitration/predmet-210-granica-imen-putej.md в wip/210/arbiter-v1,
23bec24cc3102b8aa388de53a546661b9812b867. База production —
8b84c0da1e0c784f0b89a84a2838d06490525685 (OBJECT).
Правится только fixtures/workshop_project/charter_tekst_do_tega_210/.
Frozen-контракт, production, CI и разрешительная грамматика не меняются.

## Двери

- честная-модель · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --stabs · 0 · 0
- пре-критик · bash scripts/pre_critic.sh contracts/210-charter-tekst-do-tega.md · 0 · 0
- готовность-спеки · bash scripts/check_spec_ready.sh . contracts/210-charter-tekst-do-tega.md · 0 · 0
- идентификаторы · bash scripts/check_ids.sh . · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/210-charter-tekst-do-tega.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/210-charter-tekst-do-tega.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/210-charter-tekst-do-tega.md · 0 · 0
- грамматика-проводки · bash scripts/check_provodka.sh --grammar . contracts/210-charter-tekst-do-tega.md · 0 · 0
- генератор-CI · bash scripts/gen_ci_steps.sh --check · 0 · 0
- синтаксис · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --syntax · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы выше; check_sdacha исполняет команды, SDACHA_OKRUG штатно разрывает рекурсию pre_critic; вне машинных секций нет строк списков · - · -
- К-02 · чисто · вход: обещание — сохранение реальных байтов пути до суда, а не запрет штатных кавычек/backslash; решение Arb210 исполняется без нового освобождения · - · -
- К-03 · чисто · вход: первичная публикация, Б-1, grandfather 70/71 и 72–74, plans, per-document окна и owner-канал сохранены; реальные next_id/mint_line/pre-commit проверены отдельно · - · -
- К-04 · чисто · вход: изменена только семья; модель соседних читателей не изменяет production; кольцо использует общий charter_frozen_publication · - · -
- К-05 · чисто · вход: красное-до — историческое предъявление OBJECT; после миграции --repo должна дать rc 0, а не вечный rc 1; машинные двери листа имеют устойчивый rc · - · -
- К-06 · чисто · вход: отсутствующий субъект, timeout, средовой rc вне 0/1, пустой набор, неуникальный якорь и синтаксическая поломка дают rc 2 NOT_IMPLEMENTED; ошибочный Git не засчитывается произвольным отрицательным rc · - · -
- К-07 · чисто · вход: уставные CLI сравниваются полной тройкой rc/stdout/stderr; читатели проверяются раздельно, а не одним отказом до нужного места; ошибка и пустой/оборванный log имеют самостоятельные клетки · - · -
- К-08 · чисто · вход: stabs.tsv и MUTATIONS связывают каждый адресный возврат строкового транспорта со своей различающей клеткой; кратность каждого якоря ровно 1; все стабы Б-1 сохранены · - · -
- К-09 · чисто · вход: draft, чистая история, land, sync, M, oracle, непустой incr и hook на штатных формах; отдельные HEAD/history/backfill, owner, четыре diff исключения 167 и оба внешних потребителя · - · -
- К-10 · чисто · вход: NUL до последнего потребителя; NFC/NFD, кавычки, буквальные slash-t/slash-n, пробелы, TAB/LF и SOH с SHA-текстом не нормализуются; число документов и точный путь судятся даже при rc 0 · - · -
- К-11 · чисто · вход: события и ожидаемые байты задаёт конструктор до субъекта; parse_artifact_basename обёрнут прозрачной записью входного аргумента для свидетельства зависимости, не заменён двойником · - · -
- К-12 · чисто · вход: Git mktree -z, diff-tree -z, ls-tree -z и log -z — настоящие инструменты; выделенные production-циклы извлекаются побайтово без переписывания их тела; bash -n и Python compile — штатные валидаторы · - · -
- К-13 · н/п · секретов нет, данные и origin синтетические локальные · - · -
- К-14 · чисто · вход: каждой запрещающей ветви соответствуют честные clean/land/sync, ASCII и положительные 167/owner контроли; обычные commit принимают кавычку/backslash, отвергают control-имена · - · -
- К-15 · чисто · вход: движок измерил KLETKI=258 ZELENYE=258 KRASNYE=0; MUTACII=36 SVJAZI=43 POIMANY=43 ZHIVYH=0; исходные 42 клетки и 25 привязок сохранены · - · -
- К-16 · чисто · вход: TAB/LF-пути создаются plumbing, не выдаются за разрешённый staged-ввод; NUL не является байтом имени; остатки Arb210 и ограничения внешнего live-замера названы ниже · - · -
- К-17 · н/п · продуктового tooling/checks/cli.js здесь нет; меняется исполняемая модель Git-стража, не продуктовая архитектура 188 · - · -

## Дельта

- К-03 · канон/инструмент · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --stabs · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-10 · канон/инструмент · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --syntax · 0 · 0
- К-16 · граница · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0

Соответствие ПО КОДУ, не по прозе frozen-контракта. Номера строк — OBJECT из арбитража.

| Место миграции | Различающая клетка | Адресный стаб | Честный сосед |
|---|---|---|---|
| check_charter:412–418, charter_diff_paths | wire-diff-quote | NUL-DIFF | wire-diff-ascii, wire-diff-slash |
| check_charter:840–871, ls-tree/sort/docs | nul-quote-edit-fast | CYRILLIC-VNE-OBLASTI | nul-quote-history-fast, nul-slash-land-fast |
| check_charter:840–871, pairs | nul-tab-edit-fast | NUL-PAIRS | nul-quote-land-fast |
| check_charter:884/920–925, oracle membership | nul-lf-edit-oracle | NUL-ORACLE | nul-quote-edit-oracle, b3-oracle |
| check_charter:971–1112, fast/--incr | nul-lf-edit-fast, nul-lf-edit-incr | NUL-FAST | nul-quote-sync-incr, nul-header-edit-fast |
| pre-push:215, base→p1 | wire-167-d1-deny | NUL-167-D1 | wire-167-d1-allow |
| pre-push:216, base→p2 | wire-167-d2-deny | NUL-167-D2 | wire-167-d2-allow |
| pre-push:271, p1→c | wire-167-cm-allow | NUL-167-CM | wire-167-cm-deny |
| pre-push:272, p2→c | wire-167-cm2-allow | NUL-167-CM2 | wire-167-cm2-deny |
| pre-push:357–364, owner producer | wire-owner-quote | NUL-OWNER | wire-owner-clean, wire-owner-slash |
| pre-push:438–443, owner consumer | wire-ownerread-quote | NUL-OWNER-READ | wire-ownerread-clean |
| pre-push:410–434, charter ring | nul-quote-edit-push | NUL-RING | nul-quote-sync-push |
| next_id:274–282, HEAD | wire-head-quote | NUL-HEAD | wire-head-ascii, wire-head-slash |
| next_id:287–305, reachable history | wire-history-quote | NUL-HISTORY | wire-history-ascii, wire-history-slash |
| next_id:624–636, find/backfill | wire-backfill-lf | NUL-BACKFILL | wire-backfill-ascii, wire-backfill-tab |
| check_contract_frozen:224–232, v+1 companion | wire-frozen-quote | NUL-FROZEN | wire-frozen-clean, wire-frozen-slash |
| check_zones:482–489, v+1 authorization | wire-zones-quote | NUL-ZONES | wire-zones-clean, wire-zones-slash |

Снятие обещания и граница «цитируемые имена запрещены» отвергнуты арбитражем.
Канон/инструмент: NUL-протокол самого Git. Клетки необходимы, потому что статическая
проверка наличия -z не доказывает сохранение записи потребителем. Производители
пишут поток в файл с проверкой rc; read -r -d '', sort -z и NUL-пары сохраняют поля.
Fast читает один native log: пустая запись объявляет SHA, один служебный LF снимается
только с первого пути коммита. SOH и SHA в данных не объявляют метаданные.

Матрица форм задаётся единожды в cells(): ASCII, кириллица, NFC, NFD, кавычка,
backslash, внутренний/ведущий/конечный пробел slug, ведущие дефис/точка slug,
буквальные escape-последовательности. Для каждой — draft/history/land/sync,
обычная M (fast/oracle/incr/push), успешный incr и sync-push. Отдельные TAB/LF/SOH,
LF+SOH+SHA и SHA-подобные имена — только mktree -z. Смешанные миры различают
освобождённый путь и независимый обычный документ той же дельты. Plans сохраняют
строгий суд, а не получают освобождение публикации.

На отказе incr кеш остаётся base, на успехе равен проверенному HEAD; окна непустые,
base расположен до /1. Четыре merge-167 клетки исполняют настоящую функцию хука,
включая merge-tree и union реестра. Неуспех любого производителя не заменяется
пустым массивом. HEAD/history испытываются отдельно: другой источник не маскирует
потерю номера; history удаляет файл с HEAD и оставляет его в достижимой истории.
Аудит аргументов настоящего parse_artifact_basename различает искажённое имя даже
при случайно сохранённом числовом максимуме (измеренный случай HEAD арбитра).

wire-route-* исполняют настоящий next_id → публикация локального одноразового
origin → mint_line с настоящим pre-commit → commit architect. Кавычка/backslash
зелёные; TAB/LF/CR/SOH/DEL дают rc 1 и причину «имя с control-символом», HEAD не
меняется. Owner-identity, --no-verify и замена хуков двойником не используются.

## Измерения и границы

W = bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh.
Финальный прогон W --model → KLETKI=258 ZELENYE=258 KRASNYE=0;
W --stabs → MUTACII=36 SVJAZI=43 POIMANY=43 ZHIVYH=0;
W --syntax → bash=4 python=2. Последовательная цепочка заняла 118.27 с.
W --repo . на OBJECT → rc 1, KLETKI=258 ZELENYE=171 KRASNYE=87, real 44.34 с;
все исходные 42 зелёные. pre_critic → «КРИТИК: дверь зелёная», real 352.98 с.

Красное-до — историческая мера на OBJECT, не строка машинной двери:
W --repo . должна обнаруживать потерю имён; после production-ремонта та же команда
обязана стать rc 0, KRASNYE=0. Прежние 42 клетки зелёные на OBJECT. Честные новые
контроли намеренно зелёные и на старом production: требовать красноты draft или
корректного ASCII-контроля означало бы испортить оракул. Счётчики итогового
красного-до и сырые rc машинных дверей передаются докладом по исполненным командам.

Изоляция: TMPDIR расположен в tmp/ собственной изолированной копии, а не во внешнем
/tmp/dev-harness-verify/scratch-arch210e: старший запрет записи вне копии сильнее
адреса из задания. TemporaryDirectory удаляет каждый мир и общий scratch. Бинарь
shellcheck закреплён внешним VALIDATE_STD_SHELLCHECK; --syntax не выдаёт bash -n
за чистый shellcheck существующих больших моделей.

Внешние next_id/check_contract_frozen/check_zones читатели предъявлены на адресном
seam: production-цикл извлечён без изменения тела, модель реализует тот же читатель
в model/path_readers.sh. Это не объявляется полным живым запуском check_zones:
его re-exec стирает TMPDIR и запрещён в этой копии. Main восполняет live check_zones
в разрешённой среде и полный интеграционный v+1-регресс на production-кандидате.
Уставный check_charter и pre-push предъявляются также целиком через настоящие CLI.

Остаточный риск: числа 36/18/20 frozen-приёмки устарели; frozen-текст не правился.
Ловец reviewer сверяет реальные 258/36/43 с движком и TSV, не меняет обязательство.

НЕ ЗАЩИЩАЕТ: сквозной транспорт имён сам по себе не удостоверяет человеческую волю и подлинность администрирования настроенного origin; ловцы — adversary/reviewer и действующие owner/публикационные двери. Прежний остаток 210, не новая амнистия.

НЕ ЗАЩИЩАЕТ: конечная батарея не доказывает отсутствие всех будущих дефектов реализации; ловцы — независимый узкий adversary по изменённому классу, reviewer полноты миграции и CI с сохранёнными регрессами. Известный ложный rc 0 этой оговоркой не принимается.

НЕ ЗАЩИЩАЕТ: транспортное исправление не вводит разрешение создавать control-имена штатным commit и не делает непредставимый NUL допустимым байтом имени; ловцы — существующий check_staged и его CI-регресс, Git для структуры дерева. Git-plumbing-вход с представимыми управляющими не должен молча исчезать из читаемой дельты.

НЕ ЗАЩИЩАЕТ: эта пачка не является общерепозиторной сертификацией всех читателей путей, не меняет грамматику razreshil, не расширяет освобождение на plans/AGENTS/ROADMAP, /2+ или третий родитель и не устраняет прежнюю HEAD-only полноту поиска удалённых уставных документов; ловцы — reviewer и существующие профильные CI-гарды. Два непосредственных потребителя изменённого charter_diff_paths исключением НЕ являются: они мигрируют обязательно.

## Наблюдение процесса

Измерено: mapfile -t над NUL-потоком может сохранить первый элемент и не различить
строковый откат на одноэлементном diff. Это не контрпример продукту: первоначально
четыре 167-стаба были живыми (39/43), после возврата полной старой пары producer +
consumer адресные стабы пойманы (43/43). Н-39 требует проверять наблюдаемость всей
пары транспорта, а не наличия одного флага. Общий журнал А-NNN по старшему запрету
на main и вне зоны этой ветки не изменяется; наблюдение передано этим листом.
