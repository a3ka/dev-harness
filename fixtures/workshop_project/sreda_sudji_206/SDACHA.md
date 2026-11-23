# СДАЧА 206 — среда изолированного судьи

Исполнительный круг по арбитражу
`predmet-206-granica-ohrannyh-predikatov` (OBJECT e7749ca8231b7d8f76c1d285e905bd6365317f06):
класс слепоты батареи к переносам охранной операции на соседние оси закрывается
ОДНИМ механизмом — параметрической матрицей входов с конечными структурными
осями (matrix.py + пакетный драйвер guard_driver.mjs) и производным реестром
адресных мутаций по позициям реального кода. Вердикты adversary в дереве OBJECT
не закоммичены, строка предыдущего вердикта листом не заявляется. Production,
frozen-контракт, роли и CI этой пачкой не меняются: правки — только семья
fixtures/workshop_project/sreda_sudji_206. Эталон production остаётся дельтой
над immutable BASE db56f44d1012854b6098a7076fccdae0855badeb, существующие 86
клеток, 36 стабов, контроли ролей/наблюдателя и frozen-регресс сохранены и не
ослаблены; генератор включён в настоящие --repo, --model, --stabs.

## Двери

- repo · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo . · 0 · 0
- модель · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- каталог-канон · fixtures/workshop_project/sreda_sudji_206/catalog.py --check · 0 · 0
- наблюдатель-контроли · fixtures/workshop_project/sreda_sudji_206/live_control.py · 0 · 0
- precision · bash scripts/check_precision_gate.sh . contracts/206-sreda-sudji.md · 0 · 0
- spec-ready · bash scripts/check_spec_ready.sh . contracts/206-sreda-sudji.md · 0 · 0
- ids · bash scripts/check_ids.sh . · 0 · 0
- потолки · bash scripts/check_ceilings.sh . · 0 · 0
- проводка-грамматика · bash scripts/check_provodka.sh --grammar . contracts/206-sreda-sudji.md · 0 · 0
- модель-угроз · bash scripts/check_threat_model.sh . contracts/206-sreda-sudji.md · 0 · 0
- предпосылки · bash scripts/check_predposylki.sh . contracts/206-sreda-sudji.md · 0 · 0
- pre-critic · bash scripts/pre_critic.sh contracts/206-sreda-sudji.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: машинные двери листа и раздел Дельта, pre_critic обязателен до сдачи критику · - · -
- К-02 · чисто · вход: task-arch206c исполняет таблицу осей арбитража буквально — генератор входов matrix.py, производный реестр стабов, три предъявленных мутанта дословно, production и frozen-текст не меняются · - · -
- К-03 · чисто · вход: права М1 037, scratch 025 и явно назначенный пин положительны в матрице, режимы 172 и детектор 185 не тронуты · - · -
- К-04 · чисто · вход: меняется только семья fixtures/workshop_project/sreda_sudji_206, git diff --stat OBJECT..HEAD содержит только её · - · -
- К-05 · чисто · вход: приёмка — rc-команды листа, live принимает назначенный --object, каждая строка матрицы несёт полный ожидаемый результат · - · -
- К-06 · чисто · вход: observer-null/number/string/array/broken-json/bom ожидают полный rc2/stderr, empty/count-1/count-2 ожидают предметный rc1/stdout · - · -
- К-07 · чисто · вход: канон входов — конечные оси matrix.py с ожиданием по назначению мира ДО вызова субъекта, пакетный драйвер судит публичный judge реального файла, rc процесса и пустой stderr проверяются отдельно · - · -
- К-08 · чисто · вход: вердиктная матрица abs/rel × четыре лексические формы × прямой путь/ссылка-каталог/ссылка-файл × внутри/снаружу, относительная форма считается от --repo, а не от cwd вызывающего · - · -
- К-09 · чисто · вход: основной продукт 1280 строк (cp с двумя источниками и mkdir с выделенной целью на позициях 0/1/2) плюс 48 symlink-представителей, ссылка-файл cp внутрь/наружу, контроль symlink+.. и относительная цель cp без cwd · - · -
- К-10 · чисто · вход: observer-honest/different-objects/unassigned-object/missing-object, мутации сравниваются по полному rc/stdout/stderr, не подстроке · - · -
- К-11 · чисто · вход: ожидания вычислены до запуска субъекта и не зовут pathAllowed/judge, селектор каждого стаба требует красноту neg-строк и зелёность честного ctl-контроля того же представления на том же мутанте · - · -
- К-12 · чисто · вход: GNU realpath для нормализации, штатная токенизация guard, единый словарь LEX_SEPS matrix.py для команд и вердикт-строк, побайтовая сверка stabs.tsv каталогом · - · -
- К-13 · н/п · секреты в предмет не входят · - · -
- К-14 · чисто · вход: положительные контроли матрицы — своя М1-копия, scratch-allowlist и явно назначенный пин зелёные на production и на модели при всех лексических формах · - · -
- К-15 · чисто · вход: счётчики раннеров KLETKI/OBMANOK/SELEKTOR из прогона, побайтовая сверка stabs.tsv с MUTATIONS из 41 записи · - · -
- К-16 · чисто · вход: риск безопасности путей, грамматика cp/mkdir не расширена, обязательная живая тройка после рестарта не подменена статикой · - · -
- К-17 · н/п · harness не имеет pinned проектного архитектурного брифа 187а/188 для этого предмета · - · -

## Дельта

- К-07 · канон/инструмент · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo . · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0

## Исполнение решения арбитра

Оси матрицы (таблица арбитража, исполнена буквально): операция × basename/`/bin`
(cp, /bin/cp, mkdir, /bin/mkdir) — 4; основание цели abs/rel от абсолютного cwd
своей копии плюс именованный отрицательный контроль rel без cwd — 2+1; хвост
без `/` и с `/` — 2; лексические представления plain, `//`, `./`,
`existing/../` сырым операндом — 4; размещения своя М1-копия, scratch-allowlist
025, live-state, чужое неназначенное дерево, явно назначенный пин — 5 (первые
два и пин положительны, state и чужое дерево отрицательны); `--` и без него —
2; позиции: cp — последняя цель при двух источниках, mkdir — выделенная цель на
первой/средней/последней позиции среди разрешённых; отдельный symlink-продукт —
три назначения ссылки (внутрь копии/state/чужое дерево); для cp дополнительно
ссылка-файл внутрь/наружу без искусственного хвостового `/`; контроль
symlink+`..` различает действительное назначение после обхода ссылки.
Вердиктная матрица — abs/rel × четыре формы × прямой путь/ссылка-каталог/
ссылка-файл × внутри/снаружи. Именованные граничные клетки прежних 86 клеток
(кавычки, пробел, LF, односимвольный путь, NUL, ведущий дефис после `--`,
отсутствие cwd, пустая команда) сохранены без умножения на весь продукт.

Объём матрицы: основной продукт 1280 (cp 320 + mkdir 960), symlink-продукт 48,
ссылка-файл cp 4, symlink+`..` 4, rel-без-cwd 1 — guard 1337 строк; вердиктная
матрица 48 строк; итого матрица 1385 строк, батарея 86+1385=1471 клеток.
Ожидания назначаются миром до вызова субъекта (matrix.py), ответ проверяемого
pathAllowed/judge ожиданием не вычисляется, честная модель и production — два
проверяемых субъекта.

Реестр стабов: 41 запись (36 прежних сохранены дословно, 5 новых по позициям
реального кода): mkdir-absolute-slash-ignored (предъявленная замена Adv206b
дословно), write-command-basename-ignored (потеря basename в детекте формы
записи), mkdir-last-operand-only (потеря итерации каждой цели mkdir),
target-not-passed-to-judge (извлечённая цель не передаётся общему суду),
verdict-relative-base-ignored (потеря базирования относительного --file на
--repo). Шестнадцать записей (11 guard + 5 verdict) несут матричные селекторы
neg/ctl поверх прежней привязки к клетке; схлопывание замен не снимает ни одну
обязательную ось. stabs.tsv остаётся побайтовой производной MUTATIONS
(catalog.py --check). Неуникальный или пропавший якорь, авария Node/git —
NOT_IMPLEMENTED rc 2, не поимка.

Три предъявленных мутанта воспроизведены на копиях РЕАЛЬНЫХ файлов production
(якорь кратности 1, миры внутри scratch, системные cp/mkdir не исполнялись):

| Мутант на реальных файлах | rc батареи --repo | Итог |
|---|---|---|
| `cp-trailing-slash-ignored` | 1 | KLETKI=1471 ZELENYE=1398 KRASNYE=73 — 72 матричных ряда cp/slash/state+foreign плюс прежняя клетка guard-cp-trailing-slash-live-state |
| `mkdir-absolute-slash-ignored` (Adv206b дословно) | 1 | KLETKI=1471 ZELENYE=1371 KRASNYE=100 — ровно 100 матричных ряда abs∧slash у state/foreign и symlink-назначений |
| `absolute-symlink-ignored` | 1 | KLETKI=1471 ZELENYE=1462 KRASNYE=9 — 8 матричных вердикт-клеток abs/ссылка/снаружи плюс прежняя клетка verdict-absolute-file-symlink-outside |

Числа совпадают с ориентиром арбитра (72, 100, 8); дополнительные красные —
прежние именованные клетки того же дефекта, не новые обязательства. На
честных production и модели те же ряды зелёные: разрешённые контроли
матрицы (своя копия, scratch, назначенный пин, ссылки внутрь) KRASNYE=0.

НЕ ЗАЩИЩАЕТ (остаток по арбитражу, ловцы названы): конечная структурная
матрица и адресные удаления/замены не доказывают полноту по произвольным
комбинациям, длинам списков, повторениям сегментов и специально распознающим
значения программам — ловцы adversary в санкционированном объёме и reviewer по
достижимому дефекту или изменению охранной операции, CI по закреплённой
матрице и регрессу. Формы shell вне объявленной грамматики cp/mkdir, в том
числе `cp -t`, `--target-directory=`, обёртки `env`/`command`/`sudo`/`busybox`
и произвольная shell-программа, специально распознающая один путь — ловцы
adversary/reviewer по действующему остатку контракта, грамматика предмета этой
пачкой не расширялась. Компрометация интерпретатора/бинарника, гонка общего
uid, изменение symlink между судом и записью и алиас inode через hardlink не
доказаны этой матрицей путей — ловцы reviewer и живая станционная проба в
пределах существующей модели угроз. Статические роли и локальный эксперимент
не доказывают прохождение живой тройки после рестарта (LIVE_JUDGES_NOT_RUN) —
ловец обязательная живая приёмка и orchestrator по первому реальному диагнозу,
красная тройка запрещает done. Принятие границы риска — К ВЛАДЕЛЬЦУ, эта
пачка его не решает.

## Фактический замер пачки

| Команда | Сырой rc | Полный итог счётчика / наблюдение |
|---|---|---|
| `red_sreda_sudji_206.sh --repo .` | 0 | KLETKI=1471 ZELENYE=1471 KRASNYE=0, время 10.1 с |
| `red_sreda_sudji_206.sh --model` | 0 | KLETKI=1471 ZELENYE=1471 KRASNYE=0, время 10.0 с |
| `red_sreda_sudji_206.sh --stabs` | 0 | OBMANOK=41 POIMANY=41 ZHIVYH=0, все 16 селекторов POIMAN, время 64.4 с |
| `catalog.py --check` | 0 | STABS=41 NORM_CONSUMERS=3, wc -l stabs.tsv = 42 с заголовком |
| `live_control.py` | 0 | OBSERVER_CONTROLS=21 KRASNYE=0, LIVE_JUDGES_NOT_RUN |
| `check_precision_gate.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_spec_ready.sh . contracts/206-sreda-sudji.md` | 0 | OK |
| `check_ids.sh .` | 0 | номера уникальны и согласованы с регистром выдачи |
| `check_ceilings.sh .` | 0 | потолки в порядке |
| `check_provodka.sh --grammar . contracts/206-sreda-sudji.md` | 0 | без вывода |
| `check_threat_model.sh . contracts/206-sreda-sudji.md` | 0 | ЗАЩИЩАЕТ 4, НЕ ЗАЩИЩАЕТ 5 |
| `check_predposylki.sh . contracts/206-sreda-sudji.md` | 0 | PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2 |
| `node scripts/gen-harness.ts --check` | 0 | харнес соответствует roles/ (13 ролей) |
| `validate_std.sh bash red_sreda_sudji_206.sh` | 0 | bash -n и shellcheck 0.11.0, обёртка батареи не менялась |
| `red_own_copy_paket_b.sh .` | 0 | ветвей 13, красных 0, зелёных 13 |
| `red_extract_pin_actual_066.sh .` | 0 | ветвей 15, красных 0, зелёных 15 |
| `red_predverie_172.py --repo` | 0 | 16 ok, prepare/sync-main/archive и коды сохранены |
| `pre_critic.sh contracts/206-sreda-sudji.md` | 0 | гейты предпосылок/трека/модели угроз/потолков/проводки зелёные |
| воспроизведение трёх мутантов арбитра на реальных файлах | 0 | rc батареи 1/1/1, KRASNYE 73/100/9, время 33.1 с |

Время --repo/--model/--stabs замерено `time` на станции (оркестратор
перемеряет вес CI-шага 15 с: матрица тяжелее, пакетный драйвер держит весь
guard-продукт одним Node-процессом, вердиктные строки — настоящие вызовы
pre_judge). Валидатор исполнен полной командой `env
VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck
bash scripts/validate_std.sh bash
fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh`. Дверей,
клеток и обязательств сверх решения арбитра не введено: production, контракт,
роли и CI не тронуты, git diff --stat e7749ca823..HEAD содержит только семью
fixtures/workshop_project/sreda_sudji_206.
