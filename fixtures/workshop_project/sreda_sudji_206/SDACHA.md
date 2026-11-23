# СДАЧА 206 — среда изолированного судьи

Исправительный круг по вызову 3 adversary (archive/206/adversary-v3-fail-72238dc2e7,
OBJECT 1731f9316861fc351ca05ab492794f42d93cbbaf): закрыты БЛОК 1 (сочетания
«квалифицированное имя × несколько операндов × позиция цели-ссылки наружу» в
symlink-продукте — оси bin/position/lex/--), БЛОК 2 (отрицательный корневой
контроль `--file R == корень repo` + адресный стаб), реальность
относительного `existing/../` (промежуточный каталог существует в обеих
формах, клетка-проверка мира) и систематический обход мутаций охранных
предикатов (sweep.py: 112 однострочных мутантов path-guard.ts/pre_judge.sh,
выжившие объяснены по коду). Production, frozen-контракт, роли и
CI-реестры этой пачкой не меняются: правки — только семья
fixtures/workshop_project/sreda_sudji_206. Прежние 86 клеток, 41 стаб,
контроли ролей/наблюдателя и frozen-регресс сохранены и не ослаблены;
генераторы включены в настоящие ноги раннера.

## Двери

- repo · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --repo . · 0 · 0
- модель · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --model · 0 · 0
- адресные-мутации · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- каталог-канон · fixtures/workshop_project/sreda_sudji_206/catalog.py --check · 0 · 0
- наблюдатель-контроли · fixtures/workshop_project/sreda_sudji_206/live_control.py · 0 · 0
- систематический-обход · fixtures/workshop_project/sreda_sudji_206/sweep.py --check · 0 · 0
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
- К-02 · чисто · вход: task-arch206d закрывает два блока Adv206c, реальность existing и системный обход; production и frozen-текст не меняются · - · -
- К-03 · чисто · вход: права М1 037, scratch 025 и явно назначенный пин положительны в матрице, режимы 172 и детектор 185 не тронуты · - · -
- К-04 · чисто · вход: меняется только семья fixtures/workshop_project/sreda_sudji_206, git diff --stat 1731f931..HEAD содержит только её · - · -
- К-05 · чисто · вход: приёмка — rc-команды листа, каждая строка матрицы несёт полный ожидаемый результат (rc/stdout/stderr либо решение целиком) · - · -
- К-06 · чисто · вход: observer-null/number/string/array/broken-json/bom ожидают полный rc2/stderr, empty/count-1/count-2 ожидают предметный rc1/stdout · - · -
- К-07 · чисто · вход: sweep.py порождает однострочные мутанты объявленных охранных предикатов и гоняет батарею пакетными драйверами одной сессией; выживший либо эквивалент (EQUIVALENTS с обоснованием по коду), либо дыра; --check rc 0 только при пустом списке необъяснённых · - · -
- К-08 · чисто · вход: корневой контроль verdict-root-file (честный --repo R --file R rc 1, пустой stdout, ОТКАЗ: VERDIKT_VNE_REPO) плюс verdict-no-file; адресный стаб удаляет `&& [ "$vcanon" != "$R" ]` · - · -
- К-09 · чисто · вход: symlink-продукт несёт оси bin/position/lex/-- (cp/mkdir × basename//bin × abs/rel × хвост × 4 лексики × 3 назначения × -- × позиции mkdir среди разрешённых), реальность existing/../ в абсолютной и относительной форме держится клетками мира · - · -
- К-10 · чисто · вход: observer-honest/different-objects/unassigned-object/missing-object, мутации сравниваются по полному rc/stdout/stderr, не подстроке · - · -
- К-11 · чисто · вход: ожидания вычислены до запуска субъекта и не зовут pathAllowed/judge; селектор нового стаба требует красноту neg-строк (48) и зелёность честного ctl-контроля (24) того же представления · - · -
- К-12 · чисто · вход: GNU realpath для нормализации, штатная токенизация guard, единый словарь LEX_SEPS matrix.py, побайтовая сверка stabs.tsv каталогом · - · -
- К-13 · н/п · секреты в предмет не входят · - · -
- К-14 · чисто · вход: положительные контроли матрицы — своя М1-копия, scratch-allowlist, назначенный пин и m206lnk-own зелёные на production и модели · - · -
- К-15 · чисто · вход: счётчики раннеров KLETKI/OBMANOK/SELEKTOR/MUTANTOV из прогона, побайтовая сверка stabs.tsv с MUTATIONS из 43 записей · - · -
- К-16 · чисто · вход: риск безопасности путей, грамматика cp/mkdir не расширена, обязательная живая тройка после рестарта не подменена статикой · - · -
- К-17 · н/п · harness не имеет pinned проектного архитектурного брифа 187а/188 для этого предмета · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh --stabs · 0 · 0
- К-07 · канон/инструмент · fixtures/workshop_project/sreda_sudji_206/sweep.py --check · 0 · 0

## Исполнение решения арбитра и блоков вызова 3

Симлинк-продукт (арбитраж: «те же применимые формы и позиции») расширен с 48
до 768 строк: операция × basename/`/bin` × abs/rel × хвост × четыре
лексические формы × три назначения ссылки × `--` × позиции (cp — последняя
цель при двух источниках; mkdir — выделенная цель-ссылка на
первой/средней/последней позиции среди разрешённых). Мутант Adv206c дословно
(БЛОК 1) ловится 48 матричными рядами mkdir/bin=abs/lex=plain/dest∈{state,foreign}
(оба хвоста, оба основания, все позиции, оба `--`) плюс статической клеткой
guard-mkdir-dirlink-bin-outside; честный контроль того же представления
(dest=own, 24 ряда и guard-mkdir-dirlink-bin-inside) остаётся зелёным на
мутанте. По коду: lstatSync(dirname(path)).isSymbolicLink() истинен только
для plain-формы (у `//`, `/./`, `existing/../` lstat идёт сквозь ссылку в
каталог-цель), поэтому селектор ограничен lex=plain.

БЛОК 2: клетка verdict-root-file — честный `verdict --repo R --file R`
rc 1, пустой stdout, полный VERDIKT_VNE_REPO с формой; адресный стаб
удаляет неравенство корню. Дополнительно verdict-no-file закрывает вход без
--file (NE_POLNYJ_VHOD). Реальность existing/../: относительный
target_text теперь опускается в root/lex (промежуточный каталог существует
в относительной и абсолютной формах), prepare создаёт existing и в трёх
назначениях dirlink-ссылок, 13 клеток world-existing-* фиксируют
существование assert'ами.

Систематический обход (sweep.py): 89 предикатов path-guard.ts и 23
pre_judge.sh (полные строки-якоря, кратность 1; дрейф файла — NOT_IMPLEMENTED
rc 2). Операторы: удаление/инверсия условия if, &&↔||, удаление ветви
continue/return/exit/refuse/skip/case-альтернативы, замена сравнения.
Guard-мутанты судятся всеми guard-зависимыми клетками (статические + фабрика
+ полная матрица) пакетным драйвером; pre_judge-мутанты — всеми
вердикт-зависимыми клетками на одном мире со сменой веток; семейства,
независимые от мутанта по построению, не прогоняются (эквивалентность
документирована в докстринге). Итог прогона: 112 мутантов, 80 пойманы,
28 выживших — все 28 объяснены в EQUIVALENTS по коду (17 URI-ветвей вне
канона входов 206 — ловцы батареи 025/030; 2 actual-ветви М1 037; пустая
команда/пустые операнды/slash<=0/относительный write-путь/равенство
path_inside — структурные эквивалентности с названными ловцами), 4 аварии
рантайма (null-разыменования) — не поимка по норме арбитража. Прежние 41
стаб не ослаблены; реестр 43 записи остаётся побайтовой производной
MUTATIONS (catalog.py --check).

Объём батареи: основной продукт 1280, symlink-продукт 768, ссылка-файл cp 4,
symlink+`..` 4, rel-без-cwd 1 — guard 2057 строк; вердиктная матрица 48;
статические клетки 103 (guard 42 + фабрика 1 + роли 9 + вердикты 15 +
реальность мира 13 + unchanged 2 + observer 21). Итого 2208 клеток.

## Фактический замер пачки

| Команда | Сырой rc | Полный итог счётчика / наблюдение |
|---|---|---|
| `red_sreda_sudji_206.sh --repo .` | 0 | KLETKI=2208 ZELENYE=2208 KRASNYE=0, время 19.4 с |
| `red_sreda_sudji_206.sh --model` | 0 | KLETKI=2208 ZELENYE=2208 KRASNYE=0, время 16.2 с |
| `red_sreda_sudji_206.sh --stabs` | 0 | OBMANOK=43 POIMANY=43 ZHIVYH=0, все 17 селекторов POIMAN, время 97.7 с |
| `catalog.py --check` | 0 | STABS=43 NORM_CONSUMERS=3, wc -l stabs.tsv = 44 с заголовком |
| `sweep.py --check` | 0 | MUTANTOV=112 POIMANY=80 ZHIVYH=28 EKVIVALENTOV=28 AVARII=4 SEKUND=218.5, список необъяснённых пуст |
| `live_control.py` | 0 | OBSERVER_CONTROLS=21 KRASNYE=0, LIVE_JUDGES_NOT_RUN |
| мутант БЛОК 1 (Adv206c дословно) на реальных файлах | 1 | KLETKI=2208 KRASNYE=49: 48 dirlink-рядов + guard-mkdir-dirlink-bin-outside |
| мутант БЛОК 2 (удаление `&& [ "$vcanon" != "$R" ]`) | 1 | KLETKI=2208 KRASNYE=1: verdict-root-file |
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
| `check_sdacha.sh . contracts/206-sreda-sudji.md --run` | 0 | двери=14, карта=17/17, дельта=3 |
| `gen_ci_steps.sh --check` | 0 | реестр и workflow согласованы |

Время ног замерено `time` на станции: --repo 19.4 с + --model 16.2 с +
--stabs 97.7 с = 133.3 с; отдельная нога --sweep (раннер) 218.5 с — вес
CI-шага правит оркестратор. Валидатор исполнен полной командой `env
VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck
bash scripts/validate_std.sh bash
fixtures/workshop_project/sreda_sudji_206/red_sreda_sudji_206.sh`. Дверей,
клеток и обязательств сверх блоков вызова 3 не введено: production,
контракт, роли и CI не тронуты, git diff --stat 1731f931..HEAD содержит
только семью fixtures/workshop_project/sreda_sudji_206.
