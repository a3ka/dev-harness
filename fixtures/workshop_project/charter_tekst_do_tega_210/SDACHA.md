# СДАЧА 210 — исправление двух блоков Adv210

Основание: Adv210 вызов 1, FAIL, OBJECT=5b37a6240ca0d35e2c00278bff949f1a8a0a85ae;
вердикт 08c94f6139d2cedb537d8d5d5b693b6b7616ea75 в archive/210/adversary-v1-fail-08c94f6139.
Правится только эта семья. Frozen-контракт, production и CI-проводка не меняются.
Архивный вердикт не входит в HEAD этой ветки; машинная ссылка на незакоммиченный
verdicts-файл не заявляется. Исторические блоки Crit210 сохраняют предъявления
на инверсию blob, возврат с T в истории и точечные grandfather-пары 72–74.

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

- К-01 · чисто · вход: двенадцать дверей формы перечислены выше; check_sdacha исполняет команды и сверяет rc, штатный SDACHA_OKRUG разрывает рекурсию с pre_critic; строки таблиц находятся только в машинных секциях · - · -
- К-02 · чисто · вход: обещание прежнее — первичная публикация frozen-блоба освобождается, возврат после разрешённой правки нет; два контрпримера Adv210 воспроизводятся на настоящих Git-мирах · - · -
- К-03 · чисто · вход: сохраняются 019, 022, 046/065, 083, 113, 130, 167 и пары 70/71, 72–74; кириллическое имя из существующей next_id-грамматики получает тот же суд, что ASCII, клетки v8/g24/g25 · - · -
- К-04 · чисто · вход: правится только fixtures/workshop_project/charter_tekst_do_tega_210; production — implementer, frozen-текст и реестры не меняются; model/pre-push сохраняет импорт единого charter_frozen_publication · - · -
- К-05 · чисто · вход: двери имеют устойчивый rc; красное-до привязано к неизменяемому OBJECT, не к состоянию текущего production, после реализации --repo обязана дать KRASNYE=0 · - · -
- К-06 · чисто · вход: отсутствующий субъект, rc вне 0/1, timeout, ошибочный Git, пустая выборка, неуникальный якорь, сломанный синтаксис и CACHE_NOT_HEAD дают rc 2 NOT_IMPLEMENTED, не поимку предметной мутации; empty/exit127 не объявляются пойманными · - · -
- К-07 · чисто · вход: g21/g22/g23 строят land(base-line,Q), branch2 от Q, T после branch2, разрешённую edit от land и возврат merge(edit,branch2); T не предок edit, но frozen уже публиковался; fast/oracle/pre-push судят один эффект · - · -
- К-08 · чисто · вход: новые T-VMESTO-PUBLIKACII и CYRILLIC-VNE-OBLASTI привязаны кодом/TSV к различающим клеткам; каждый якорь встречается один раз, честный контроль и точное отдельное ожидание мутанта обязательны; INVERSIJA-BLOBA сохранена буквально · - · -
- К-09 · чисто · вход: старые формы land/sync, режимы и hook сохранены; добавлены возврат без предковости T (fast/oracle/push), законный кириллический land и post-tag edit кириллического пути (fast/oracle) · - · -
- К-10 · чисто · вход: сравнивается полная тройка rc/stdout-bytes/stderr-bytes, без decode/нормализации; в кириллическом land различается также полный счёт области при одинаковом subject-rc 0 · - · -
- К-11 · чисто · вход: события publish/razreshil/deny заданы конструктором мира, ожидания снимаются в память до вызова; out-of-scope мутант имеет отдельное ожидание потери пути и счётчиков, диск субъекта не оракул · - · -
- К-12 · чисто · вход: факты истории даёт Git plumbing; имена Git перечисляются с core.quotePath=false, прежняя грамматика не переписывается; Bash проверяется bash -n и validate_std с закреплённым shellcheck · - · -
- К-13 · н/п · секретов нет, только синтетические публичные данные и существующие SHA · - · -
- К-14 · чисто · вход: b1/b2 остаются допустимыми эквивалентами публикации при новом запрете возврата, внутри g21/g22/g23 законный land и разрешённая edit остаются зелёными; v8 — честный кириллический land к запрещённой правке g24/g25, NUL/CRLF/пустой/большой blob и SHA-256 сохранены · - · -
- К-15 · чисто · вход: KLETKI/ZELENYE/KRASNYE вычислены из непустого списка запусков, MUTACII/SVJAZI/POIMANY/ZHIVYH — из кода и TSV; реальные итоги 42 клетки, 20 мутаций, 25 привязок, не числа устаревшего frozen-текста · - · -
- К-16 · чисто · вход: отрицательный критерий g21/g22/g23 не зависит от включения T в первую линию, g24/g25 не теряют допустимый не-ASCII путь; администрирование/подмена origin cognitive-only, ловцы adversary/reviewer · - · -
- К-17 · н/п · проектной архитектурной модели 188 нет; меняется исполняемая модель существующего Git-стража, не новый production-писатель · - · -

## Дельта

- К-01 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --stabs · 0 · 0
- К-03 · канон/инструмент · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-16 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --stabs · 0 · 0

Б-1 → клетка. Снятие обещания/сужение границы ослабило бы И3–И4, а одна проверка
merge-base не доказывает первичность: это измеренный контрпример. Поэтому после
прежнего T-предкового запрета модель перечисляет first-parent историю первого
родителя вне предков T и сравнивает блоб пути с frozen. Найденный прежний frozen-блоб
запрещает новое освобождение. Ошибка Git даёт return 2, не пустую историю.
Новый предикат равенства seen/tb красится T-VMESTO-PUBLIKACII на g21/g22/g23;
законный land и разрешённая edit в тех же мирах остаются допустимыми. Соседние
формы — oracle и hook; b1/b2 защищают первичные land/sync от ложного отказа.
Прежний BEZ-PERVICHNOJ теперь меняет отказ по T-предку на допуск и по-прежнему
различим ровно на g19/g20; проверка нового scan не превращает старый стаб в живой.
model/pre-push намеренно не получает второго предиката: использует исправленный
импорт и тот же вызов, что прежде; g23 предъявляет реальный hook.

Б-2 → канон/инструмент. Не вводится парсер Git-кавычек: core.quotePath=false
применён к ls-tree области, name-only fast log и diff-tree общей библиотечной двери
(её используют oracle и pre-push). Это сохраняет реальные UTF-8 имена.
CYRILLIC-VNE-OBLASTI возвращает прежний ls-tree и красится на g24/g25; отдельное
ожидание мутанта требует пропажи пути, его событий и счётчиков, а не любого crash.
Честная эквивалентная запись — v8: тот же кириллический путь с законной публикацией.
Новый парсер/алфавит/порог не добавлены.

## Измерения и границы

W = bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh.
Числа выдаёт движок: --model → KLETKI=42 ZELENYE=42 KRASNYE=0;
--stabs → MUTACII=20 SVJAZI=25 POIMANY=25 ZHIVYH=0. Привязки — в stabs.tsv,
не в frozen-контракте (Н-39). До каждой мутации исполнен честный контроль.

Красное-до — историческое предъявление на OBJECT, не машинная дверь листа:
W --repo . → rc 1, KLETKI=42 ZELENYE=36 KRASNYE=6; новые g21/g22/g23,
v8/g24/g25 красные, старые 36 зелёные. Subject-rc новых клеток на OBJECT равен 0;
ожидание g21/g22/g23/g24/g25 — 1, v8 — 0 с полными сообщениями и областью из
двух документов. После production-ремонта та же --repo обязана дать rc 0,
KRASNYE=0; этот исторический результат не переписывается в обещание вечного rc 1.

Исходный замер: --repo 7.41 с; --model 7.49 с; --stabs 20.50 с.
TMPDIR=/tmp/dev-harness-verify/scratch-arch210d, миры последовательны и удаляются
TemporaryDirectory. VALIDATE_STD_SHELLCHECK указывает на закреплённый 0.11.0.
Средовые отказы empty/exit127/CACHE_NOT_HEAD не выдаются за поимку мутации.

Остаточный риск: frozen-приёмка контракта всё ещё содержит 36/18/20 вместо
42/20/25. Это исторические числа замороженной пачки; текст по заданию не менялся.
Ловец — reviewer; модель и лист ссылаются на фактические счётчики движка.
Риск универсальности конечной батареи и человеческой подлинности origin прежний;
ловцы — независимые adversary/reviewer. Новых освобождений или обязательств нет.

Прямые дополнительные validate_std bash на model/check_charter.sh и model/pre-push:
оба rc 1. Закреплённый shellcheck доступен; отмечены существующие SC2034/SC2295/SC2317
в первом файле и SC2034/SC2329 во втором, не новые строки исправления. Вне двух
блоков Adv210 разрешительная грамматика и библиотечные объявления не менялись,
предупреждения не подавлялись. --syntax rc 0. pre_critic rc 0, 127.22 с,
«КРИТИК: дверь зелёная». Чистая validate_std не заявляется.
