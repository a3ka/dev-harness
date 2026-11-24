# СДАЧА 210 — Architect210g: легально пустой git log

Основание: регресс CI на 009ceeeba1fa1932292da0dcbc22eac69adb54c5:
история только с A законно даёт пустой log --diff-filter=MD.
База production: 1cc8ed23edf275d2fca02e40e35fa74310bf4f1c.
Правится только fixtures/workshop_project/charter_tekst_do_tega_210/.
Прежние 314 клеток и 46 привязок сохранены; добавлены 11 клеток и 4 привязки.
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
- К-05 · чисто · вход: исторический клон 009ceeeba красен только пятью новыми клетками; исправленная production-база и модель зелёные; машинные двери имеют устойчивый rc · - · -
- К-06 · чисто · вход: отсутствующий субъект, timeout, непредписанный subject-rc, пустой набор, неуникальный якорь и синтаксическая поломка дают rc 2 NOT_IMPLEMENTED; только no-ustav требует заранее названный subject-rc 2 с точными потоками · - · -
- К-07 · чисто · вход: полные rc/stdout/stderr и байты кеша; root/additions — rc 0 во всех режимах; отсутствие ustav — именно rc 2 с отдельной причиной; прежние ошибки/оборванный поток сохранены · - · -
- К-08 · чисто · вход: stabs.tsv/MUTATIONS адресуют старую проверку пустоты и запись кеша по коду check_charter; каждый якорь однократен, честный контроль и точное контрфактическое ожидание предшествуют поимке · - · -
- К-09 · чисто · вход: прежняя матрица не урезана; новые реальные миры — один root без родителя, три A-коммита, те же три без ustav, сосед с настоящей M; fast/oracle/incr и сеяние кеша · - · -
- К-10 · чисто · вход: NUL до последнего потребителя; NFC/NFD, кавычки, буквальные slash-t/slash-n, пробелы, TAB/LF и SOH с SHA-текстом не нормализуются; число документов и точный путь судятся даже при rc 0 · - · -
- К-11 · чисто · вход: события и ожидаемые байты задаёт конструктор до субъекта; parse_artifact_basename обёрнут прозрачной записью входного аргумента для свидетельства зависимости, не заменён двойником · - · -
- К-12 · чисто · вход: Git mktree -z, diff-tree -z, ls-tree -z и log -z — настоящие инструменты; выделенные production-циклы извлекаются побайтово без переписывания их тела; bash -n и Python compile — штатные валидаторы · - · -
- К-13 · н/п · секретов нет, данные и origin синтетические локальные · - · -
- К-14 · чисто · вход: каждой запрещающей ветви соответствуют честные clean/land/sync, ASCII и положительные 167/owner контроли; обычные commit принимают кавычку/backslash, отвергают control-имена · - · -
- К-15 · чисто · вход: KLETKI=325 ZELENYE=325 KRASNYE=0; MUTACII=41 SVJAZI=50 POIMANY=50 ZHIVYH=0; независимый подсчёт cells/MUTATIONS/TSV — 325/41/50; прежние 314/39/46 сохранены · - · -
- К-16 · чисто · вход: реальное отсутствие ustav не получает выдуманного допуска; недостижимый на предъявленных здоровых историях разрыв native-потоков не подменяется новым двойником git, граница и ловцы названы ниже · - · -
- К-17 · н/п · продуктового tooling/checks/cli.js здесь нет; меняется исполняемая модель Git-стража, не продуктовая архитектура 188 · - · -

## Дельта

- К-03 · канон/инструмент · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --stabs · 0 · 0
- К-09 · канон/инструмент · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0
- К-10 · канон/инструмент · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --syntax · 0 · 0
- К-16 · граница · bash fixtures/workshop_project/charter_tekst_do_tega_210/red_charter_tekst_do_tega_210.sh --model · 0 · 0

Дельта Architect210g (по коду production-базы, не по прозе контракта):

| Место | Клетка | Мутация | Честный сосед |
|---|---|---|---|
| check_charter:1142–1150, пустота/независимый log -1 | empty-root-fast, empty-additions-fast, empty-root-incr | EMPTY-OLD-REJECTION: весь блок заменён прежним `[ -z "$__ch_c" ] || [ -n "$__ch_line" ]` без пробы | empty-root-oracle, empty-additions-oracle |
| check_charter:1183–1185, успешный incr_finish | empty-root-incr-seed | EMPTY-ROOT-CACHE: incr_finish 0 → incr_finish 1 при exit 0 | empty-root-incr, empty-additions-incr |

EmptyWorld использует прежние tree()/commit()/annotate() с настоящими Git
plumbing-командами. Начальные файлы и два аннотированных тега повторяют форму
fixtures/check_charter/_repo.sh make_repo. Никакой предварительной M нет.
До субъекта независимо проверяются число коммитов, отсутствие родителя root,
пустота native NUL-log и log -1; у M-соседа оба потока непусты. Ожидание CLI
строится до субъекта; сохраняются полные потоки, HEAD/index/файлы и байты кеша.
Root-incr имеет base=HEAD; отдельный root-incr-seed начинает без кеша и требует
его появления с HEAD. Последний различает no-op записи, невидимый при base=HEAD.

Измеренное поведение no-ustav во всех режимах — rc 2, stdout пуст:
`NOT_IMPLEMENTED: устав не введён — создайте тег ustav/1 последним коммитом документных правок`.
Incr дополнительно печатает штатный маркер, кеш остаётся base. Только этот
именованный вход допускает subject-rc 2; остальные средовые двойки не поимки.
M-сосед требует rc 1 именно за AGENTS.md без разрешения, не за пустой протокол.

Новые предикаты валидности миров имеют честные противоположные контроли:
root ↔ три коммита и пустые потоки ↔ настоящая M. Сравнение кеша имеет адресную
мутацию и честные seeded/HEAD контроли. Снятие/граница вместо регресс-клеток
не закрыли бы наблюдавшийся ложный отказ; канон Git уже используется, но сам
по себе не доказывает решение CLI, поэтому здесь необходимы клетки.


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
W --repo <одноразовый клон 009ceeeba> → rc 1,
KLETKI=325 ZELENYE=320 KRASNYE=5, 48.23 с. Красны ТОЛЬКО
empty-root-fast, empty-root-incr, empty-additions-fast, empty-additions-incr,
empty-root-incr-seed; причина — «пустой или оборванный протокол git log:
проверить невозможно». Прежние 314 зелёные. Oracle и no-ustav не краснятся.
Клон имеет собственную .git и не правит исходный чекаут; новый probe исполняется
из этой семьи с --repo на историческое дерево, без подстановки production.

W --repo . на 1cc8ed23 → rc 0,
KLETKI=325 ZELENYE=325 KRASNYE=0, 47.16 с.
W --model → rc 0, KLETKI=325 ZELENYE=325 KRASNYE=0, 49.67 с.
W --stabs → rc 0, MUTACII=41 SVJAZI=50 POIMANY=50 ZHIVYH=0, 22.42 с.
Независимый Python-подсчёт cells()/MUTATIONS/непустых некомментарных строк TSV:
CELLS 325 EMPTY 11 MUTATIONS 41 BINDINGS 50.
pre_critic → rc 0, «КРИТИК: дверь зелёная», 342.38 с.
Его строки «модель угроз красна», «потолки красны», «проводка красна»,
«сдаточный лист красен» сохранены в сыром выводе; общий rc не выдаётся
за независимый зелёный результат каждой вложенной проверки.
check_sdacha "$PWD" contracts/210-charter-tekst-do-tega.md --run → rc 0,
«СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=6)», 350.23 с.
verify_antiplacebo --scope check_charter в одноразовом клоне той же
production-базы → rc 0, «барьеров: 1 · фикстур: 13 · предъявлено красным
повторным прогоном: 13», 15.14 с. VERIFY_ANTIPLACEBO_SCRATCH — сосед клона
в собственной разрешённой копии, не внутри проверяемого корня.
Первый запуск в основном корне дал rc 1 при 13 успешных предъявлениях:
snapshot заметил удаление пяти старых lib_zones.*.active под TMPDIR после
дверей формы. Это средовая мутация скратча, не ложный отказ check_charter.
У verify default scratch намеренно вне проверяемого корня (014); клон
позволил соблюсти одновременно это условие и запрет новых записей вне
собственной копии. Production/фикстуры для зелёного не изменялись.

Изоляция: TMPDIR=tmp/scratch-arch210g внутри собственной копии: старший запрет
записи вне копии сильнее внешнего TMPDIR из задания. Каждый Git-мир имеет
собственную .git; TemporaryDirectory удаляет мир сразу. Временный клон и scratch
удаляются до сдачи. Shellcheck закреплён через VALIDATE_STD_SHELLCHECK.

Сохранённые границы прежней пачки: next_id и check_zones предъявляются на
адресном seam; полный live check_zones не заявлен (re-exec стирает TMPDIR).
Ловцы — Main в разрешённой среде и reviewer интеграционного v+1-регресса.
Check_charter, check_contract_frozen и pre-push предъявляются целиком.
Frozen-числа 36/18/20 исторические; reviewer сверяет текущие 325/41/50 с
движком/TSV, а не меняет замороженное обязательство.

НЕ ЗАЩИЩАЕТ: батарея не устанавливает новое требование для мира без ustav/1;
она фиксирует существующий именованный rc 2, не объявляя такой мир проверенным.
Ловцы изменения этой политики — отдельный контракт и reviewer.

НЕ ЗАЩИЩАЕТ: на предъявленных неизменных здоровых Git-мирах не найден вход,
где MD-коммит есть, native NUL-log пуст, а native log -1 непуст.
[INFERENCE] При одинаковых HEAD/фильтре Git печатает заголовок %x00%H для
каждого выбранного коммита независимо от байтов имени. NUL в имени Git
непредставим; TAB/LF/SOH в данных не стирают заголовок (прежняя матрица
сохранена). Поэтому реальная парная клетка «незаконно пусто», а также адресные
мутации «пустота всегда оправдана» и «проба повторяет NUL-поток» не заявлены
пойманными новыми реальными мирами. Ловцы — adversary/reviewer: воспроизводимый
контрпример на настоящем Git; при его нахождении нужна адресная клетка.
Прежние wire-errors-empty/truncated остаются контролируемой инъекцией потери
потока, а НЕ доказательством достижимости такого входа без двойника Git.
Существующий fail-closed код не ослаблялся; новая M-клетка не выдаётся за
доказательство ветви незаконной пустоты.

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

Измерение Architect210g: все прежние положительные миры имели предварительную
M при создании frozen-текста; матрица значений/имён не различала ноль выбранных
MD-коммитов. Ловец следующей пачки — сохранённые root/additions-клетки и
историческое красное предъявление. Первая локальная проба новых клеток нашла
ошибку ожидания «2 коммитов» вместо «2 коммита»; исправлен оракул, не продукт.
Общий журнал А-NNN в main вне зоны не менялся; это процессное наблюдение
передаётся Main этим листом.

Процессный остаток среды: verify отклоняет in-tree TMPDIR, а старший маршрут
субагента запрещает свои записи снаружи копии. Для следующей пачки —
одноразовый дочерний клон и явный scratch-сосед внутри разрешённой копии;
не ослабление snapshot и не повтор до случайного зелёного. Первый failed-run
оставлен самим verify по /tmp/verify_antiplacebo-056dcf3b/run-1691639:
путь вне разрешённой копии, удаление передано Main, здесь не исполнялось.
