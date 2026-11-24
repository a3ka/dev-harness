# СДАЧА 210 — Arch210f: оставшиеся строковые чтения путей

Основание: verdicts/arbitration/predmet-210-granica-imen-putej.md в wip/210/arbiter-v1,
23bec24cc3102b8aa388de53a546661b9812b867; FAIL Adv210c —
archive/210/adversary-v3-fail-2cc1783466:verdicts/adversary/contracts-210-v3.md.
База production: f974b9c487f7ff2c15d6c6d655b0e9780cdefc92 (OBJECT).
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
- К-09 · чисто · вход: сохранена прежняя матрица; добавлены полный CLI check_contract_frozen (область, draft/history/land/edit) и независимые HEAD/frozen-tag чтения check_zones с настоящим zones_declare_rows, валидными/невалидными ЗОНА и различными телами HEAD/тега · - · -
- К-10 · чисто · вход: NUL до последнего потребителя; NFC/NFD, кавычки, буквальные slash-t/slash-n, пробелы, TAB/LF и SOH с SHA-текстом не нормализуются; число документов и точный путь судятся даже при rc 0 · - · -
- К-11 · чисто · вход: события и ожидаемые байты задаёт конструктор до субъекта; parse_artifact_basename обёрнут прозрачной записью входного аргумента для свидетельства зависимости, не заменён двойником · - · -
- К-12 · чисто · вход: Git mktree -z, diff-tree -z, ls-tree -z и log -z — настоящие инструменты; выделенные production-циклы извлекаются побайтово без переписывания их тела; bash -n и Python compile — штатные валидаторы · - · -
- К-13 · н/п · секретов нет, данные и origin синтетические локальные · - · -
- К-14 · чисто · вход: каждой запрещающей ветви соответствуют честные clean/land/sync, ASCII и положительные 167/owner контроли; обычные commit принимают кавычку/backslash, отвергают control-имена · - · -
- К-15 · чисто · вход: движок измерил KLETKI=314 ZELENYE=314 KRASNYE=0; MUTACII=39 SVJAZI=46 POIMANY=46 ZHIVYH=0; прежние 258 клеток, 36 мутаций и 43 привязки сохранены · - · -
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
| check_contract_frozen:86–87, область до v+1 | wire-frozenscope-quote-edit | NUL-FROZEN-SCOPE | wire-frozenscope-quote-draft/history/land, wire-frozenscope-ascii-edit |
| check_zones:498–501, контракт HEAD | wire-zoneshead-quote-invalid | NUL-ZONES-HEAD-TREE | wire-zoneshead-quote-valid, wire-zoneshead-ascii-invalid |
| check_zones:557–560, контракт frozen-тега | wire-zonestag-quote-invalid | NUL-ZONES-FROZEN-TREE | wire-zonestag-quote-valid, wire-zonestag-ascii-invalid |

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

Дельта Adv210c: новые wire-frozenscope-* предъявляют полный внешний CLI, а не
прежний ASCII-seam v+1. Сравниваются все rc/stdout/stderr, имя документа, счётчики
draft/frozen и отказ по несовпадению блобов. Модель подставляет только NUL-область
из path_readers.sh и соответствующий delimiter основного цикла; остальное тело
check_contract_frozen неизменно. Адресный стаб возвращает прежние ls-tree/awk/sort
и строковый delimiter именно здесь. Штатный --repo никогда не переписывается.

wire-zoneshead-* и wire-zonestag-* извлекают настоящие блоки выбора пути и чтения
блоба без правки тела, затем вызывают настоящий zones_declare_rows. Правильный
путь/тело/структурированные строки зон либо bad_author сверяются побайтово.
HEAD и frozen намеренно несут разные зоны: чтение неправильного ref красно.
Для каждой новой оси: ASCII, кавычка, backslash, кириллица, NFC, NFD, пробел.
Область имеет draft/history/land/edit; оба зонных места — valid/invalid.
Стабы адресованы отдельно трём местам; ошибка инструмента не считается поимкой.

Полнота этой дельты: поиск ls-tree/name-only/name-status/ls-files/diff-tree/raw
по пяти заданным production-файлам нашёл три оставшихся строковых чтения —
check_contract_frozen:86, check_zones:498 и :557. Остальные пути уже NUL;
check_charter:753 возвращает только objectname и не читает имя пути.

## Измерения и границы

W = bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh.
W --repo . на OBJECT → rc 1, KLETKI=314 ZELENYE=274 KRASNYE=40, real 81.55 с.
Прежние 258 зелёные; новые ASCII/space-контроли зелёные, цитируемые пять форм
красные на каждом независимом чтении (полные тройки и счётчики в сыром выводе).
W --model → rc 0, KLETKI=314 ZELENYE=314 KRASNYE=0, real 98.44 с.
W --stabs → rc 0, MUTACII=39 SVJAZI=46 POIMANY=46 ZHIVYH=0, real 40.92 с.
W --syntax → rc 0, bash=4 python=2, real 0.07 с.
pre_critic → rc 0, «КРИТИК: дверь зелёная», real 352.16 с.
check_sdacha "$PWD" contracts/210-charter-tekst-do-tega.md --run → rc 0,
«двери=12 карта=17/17 дельта=6», real 322.37 с (меньше 900 с).
gen_ci_steps --check → rc 0, real 0.46 с.
Независимый подсчёт cells()/MUTATIONS/строк TSV: 314/39/46;
новые оси frozenscope=28, zoneshead=14, zonestag=14.
Предыдущий незавершённый --stabs дал rc 2 ANCHOR_NOT_UNIQUE: NUL-HEAD:
новые ls-tree-команды совпали с его старым подстрочным якорем. Эквивалентный
порядок опций -z -r у новых моделей восстановил однократность прежнего якоря;
итоговый полный --stabs выше проверил все старые и новые привязки.

Красное-до — историческая мера на OBJECT, не строка машинной двери:
после production-ремонта W --repo . должна стать rc 0, KRASNYE=0.
Пространство имён не сужается ради зелёного rc, контроли draft/land не
выдаются за отрицательные subject-rc. Отсутствие документа различается
даже при rc 0 именованной строкой и числом прочитанных документов.

Изоляция: TMPDIR — tmp/scratch-arch210f внутри собственной копии, а не
внешний /tmp/dev-harness-verify/scratch-arch210f: старший запрет записи вне
копии сильнее адреса из задания. Каждый Git-мир имеет собственную .git;
TemporaryDirectory удаляет мир и общий scratch. Shellcheck закреплён через
VALIDATE_STD_SHELLCHECK; --syntax не выдаёт bash -n за shellcheck больших моделей.

Полный check_contract_frozen теперь предъявлен живым CLI. Внешние next_id и
check_zones предъявлены на адресном seam: production-блок извлечён без
изменения тела, модель читает NUL в model/path_readers.sh. Полный live
check_zones здесь не заявлен: его re-exec стирает TMPDIR, записывая вне
разрешённой копии. Ловцы — Main с живым check_zones в разрешённой среде
и reviewer интеграционного v+1-регресса на production-кандидате.
Check_charter и pre-push по-прежнему предъявляются целиком.

Остаточный риск: числа 36/18/20 frozen-приёмки устарели; frozen-текст не правился.
Ловец reviewer сверяет реальные 314/39/46 с движком и TSV, не меняет обязательство.

НЕ ЗАЩИЩАЕТ: сквозной транспорт имён сам по себе не удостоверяет человеческую волю и подлинность администрирования настроенного origin; ловцы — adversary/reviewer и действующие owner/публикационные двери. Прежний остаток 210, не новая амнистия.

НЕ ЗАЩИЩАЕТ: конечная батарея не доказывает отсутствие всех будущих дефектов реализации; ловцы — независимый узкий adversary по изменённому классу, reviewer полноты миграции и CI с сохранёнными регрессами. Известный ложный rc 0 этой оговоркой не принимается.

НЕ ЗАЩИЩАЕТ: транспортное исправление не вводит разрешение создавать control-имена штатным commit и не делает непредставимый NUL допустимым байтом имени; ловцы — существующий check_staged и его CI-регресс, Git для структуры дерева. Git-plumbing-вход с представимыми управляющими не должен молча исчезать из читаемой дельты.

НЕ ЗАЩИЩАЕТ: эта пачка не является общерепозиторной сертификацией всех читателей путей, не меняет грамматику razreshil, не расширяет освобождение на plans/AGENTS/ROADMAP, /2+ или третий родитель и не устраняет прежнюю HEAD-only полноту поиска удалённых уставных документов; ловцы — reviewer и существующие профильные CI-гарды. Два непосредственных потребителя изменённого charter_diff_paths исключением НЕ являются: они мигрируют обязательно.

НЕ ЗАЩИЩАЕТ: арбитраж пропустил место check_contract_frozen.sh:86 — ловец: adversary вызова 4/reviewer. Это ограничение полноты прежнего перечня, не принятие известного ложного rc 0; место теперь закрыто полным CLI и адресным стабом.

## Наблюдение процесса

Измерено: mapfile -t над NUL-потоком может сохранить первый элемент и не различить
строковый откат на одноэлементном diff. Это не контрпример продукту: первоначально
четыре 167-стаба были живыми (39/43), после возврата полной старой пары producer +
consumer адресные стабы пойманы (43/43). Н-39 требует проверять наблюдаемость всей
пары транспорта, а не наличия одного флага. Общий журнал А-NNN по старшему запрету
на main и вне зоны этой ветки не изменяется; наблюдение передано этим листом.

Adv210c измерил дефект перечня: seam v+1 с искусственно ASCII-именем не
доказывал обнаружение самого документа полным внешним CLI. Полный CLI с
именованным счётчиком теперь предъявлен для frozen; два зонных обнаружения
проверяются независимо, с разными телами HEAD/тега. Старый якорь NUL-HEAD
совпал с новыми командами — остановка rc 2 сработала до ложной поимки.
Общий журнал А-NNN на main не трогается из этой изолированной зоны;
процессное наблюдение передаётся Main этим листом.
