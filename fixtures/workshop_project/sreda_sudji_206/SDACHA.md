# СДАЧА 206 — среда изолированного судьи

Исправительный круг по reviewer вызову 1
(archive/206/reviewer-v1-fail-696a4c00ca,
OBJECT 2d7e8b6b4ee7c34e49f1c493696bcca65f5bc2ec): закрываются Б-1
(чтение с quoted `>` и перенаправлением stderr) и Б-2 (физическое
разрешение symlink раньше `..` в границе вердикта), советы С-1…С-4.
Production, frozen-контракт, роли и CI-реестры не меняются: зона — только
fixtures/workshop_project/sreda_sudji_206. Прежние клетки и 43 стаба
сохранены; привязки различающих входов живут в MUTATIONS, stabs.tsv —
побайтовая производная. Живая тройка судов не исполнялась этой батареей.

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

- К-01 · чисто · вход: машинные двери листа и раздел Дельта; pre_critic и check_sdacha --run обязательны до сдачи · - · -
- К-02 · чисто · вход: task-arch206e закрывает Б-1/Б-2 Rev206 и С-1…С-4; production и frozen-текст не меняются · - · -
- К-03 · чисто · вход: права М1 037, scratch 025 и явно назначенный пин положительны в матрице, режимы 172 и детектор 185 не тронуты · - · -
- К-04 · чисто · вход: git diff --stat 2d7e8b6b4ee7c34e49f1c493696bcca65f5bc2ec…HEAD содержит только fixtures/workshop_project/sreda_sudji_206 · - · -
- К-05 · чисто · вход: приёмка — rc-команды листа; каждая строка матрицы несёт полный ожидаемый rc/stdout/stderr либо решение guard целиком · - · -
- К-06 · чисто · вход: observer-null/number/string/array/broken-json/bom ожидают полный rc2/stderr, empty/count-1/count-2 ожидают предметный rc1/stdout · - · -
- К-07 · чисто · вход: sweep.py --check отказывает и необъяснённому выжившему, и устаревшему EQUIVALENTS; честный неизменённый список остаётся зелёным · - · -
- К-08 · чисто · вход: verdict-root-file и verdict-no-file сохранены; полный VERDIKT_VNE_REPO с формой проверяется на всех внешних строках symlink+dotdot · - · -
- К-09 · чисто · вход: вердиктная матрица содержит dir-symlink-dotdot в abs/rel и четырёх лексиках, внешние цели отвергаются; прежний symlink-продукт guard и реальность existing/../ сохранены · - · -
- К-10 · чисто · вход: observer-honest/different-objects/unassigned-object/missing-object, мутации сравниваются по полному rc/stdout/stderr, не подстроке · - · -
- К-11 · чисто · вход: ожидания в памяти до вызова субъекта; quoted-read-stderr-is-write привязан к guard-quoted-greater-stderr-null; verdict-logical-before-physical требует красноту всех neg и зелёность всех ctl того же представления · - · -
- К-12 · чисто · вход: GNU realpath, единый LEX_SEPS matrix.py, побайтовая сверка stabs.tsv каталогом; новый разбор формата не вводится · - · -
- К-13 · н/п · секреты в предмет не входят · - · -
- К-14 · чисто · вход: quoted > с 2>/dev/null и 2>&1 проходит; внутренний symlink+dotdot проходит на production, модели и адресном мутанте Б-2 · - · -
- К-15 · чисто · вход: TS_PREDICATES/SH_PREDICATES считаются независимо от Counter(build_mutants); KLETKI/OBMANOK/SELEKTOR/MUTANTOV берутся из вывода; catalog.py --check сверяет 45 стабов · - · -
- К-16 · чисто · вход: риск безопасности путей; грамматика cp/mkdir не расширена, обязательная живая тройка после рестарта не подменена статикой · - · -
- К-17 · н/п · harness не имеет pinned проектного архитектурного брифа 187а/188 для этого предмета · - · -

## Дельта

- К-11 · клетка · fixtures/workshop_project/sreda_sudji_206/review_delta.py block1 · 0 · 0
- К-09 · клетка · fixtures/workshop_project/sreda_sudji_206/review_delta.py block2 · 0 · 0
- К-07 · канон/инструмент · fixtures/workshop_project/sreda_sudji_206/review_delta.py stale · 0 · 0

## Закрытие блоков и советов Rev206

Б-1 — клетка: добавлены guard-quoted-greater-stderr-null и
guard-quoted-greater-stderr-merge: `grep -n 'a > b' notes.md` с
`2>/dev/null` и `2>&1`, cwd своей М1-копии, pin адреса доставки → pass.
Адресный стаб quoted-read-stderr-is-write выключает ранний возврат
`if (!isWriteCommand(cmd)) return { decision: 'pass' };` и привязан
к первой клетке. Соседняя форма `2>&1` с cwd копии остаётся зелёной
и на мутанте: извлечённый `&1` разрешается внутри собственной копии;
это честный контроль, не ложное требование красноты этой ветви.
Ложный эквивалент удалён: sweep-id ca72ade2ebeb теперь POIMAN.

Б-2 — клетка: dir-symlink-dotdot добавляет 16 вердиктных строк
(abs/rel × plain/double/dot/existing × inside/outside). Внешняя
m206dlink-out/../x.md физически ведёт в sandbox вне repo: rc 1,
пустой stdout, полный VERDIKT_VNE_REPO и форма. Внутренняя
m206dlink-in/../x.md физически ведёт в copy/x.md: rc 0,
VERDICT_BRANCH=wip/206/reviewer. Мутант realpath -m → -mL
(verdict-logical-before-physical) привязан к rel/plain/outside;
селектор требует все 8 neg красными и все 8 ctl зелёными. Абсолютная
форма и соседние лексики судятся отдельно, не общей первой краснотой.

С-1 — граница: для относительного write и двух отключений continue в
пиннованной URI-ветви явно записано «ловца нет», инв. 1–6 не нарушены;
неподтверждённые названия ловцов удалены из этих записей.
С-2 — граница: slash<=0 достижим через
/nonexist206/../<своя-копия>/x.md; мутант зависает, pass не возникает;
ловца зависания в каноне нет. Эти остатки не расширяют инварианты 206.
С-3 — исправление меры: 33 предиката TS и 14 SH (полные строки-якоря,
кратность 1) порождают 89 и 23 мутанта соответственно, всего 112.
С-4 — канон/инструмент: --check возвращает rc 1 при stale EQUIVALENTS,
а не только печатает EKVIVALENT_POIMAN. Новый предикат проверяется
внесением пойманного ca72ade2ebeb обратно в EQUIVALENTS; честный
неизменённый список остаётся зелёным.

Операторы sweep: удаление/инверсия if, &&↔||, удаление ветви
continue/return/exit/refuse/skip/case-альтернативы, замена сравнения.
Guard судится статикой, фабрикой и полной матрицей; pre_judge — всеми
вердиктными клетками. Аварии не считаются поимкой.
Объём: guard-матрица 2057 строк, вердиктная матрица 64, статика 105
(guard 44 + фабрика 1 + роли 9 + вердикты 15 + мир 13 + unchanged 2 +
observer 21), всего 2226. Реестр — 45 стабов, прежние 43 не ослаблены.

## Доказательства и граница

Красное-до предъявляется адресными мутантами реальных файлов, не
состояниезависимым требованием красноты уже исправленного production:
`red_sreda_sudji_206.sh --repo <мутант-Б-1>` и `--repo <мутант-Б-2>`
обязаны дать rc 1; честный --repo . обязан дать rc 0. Мутации reviewer
стали адресными стабами с привязкой в коде. Дверей и обязательств сверх
Б-1/Б-2 и С-1…С-4 не добавлено. Вес CI-шага по замеру трёх ног меняет
оркестратор. Лист не заявляет исполнение живых судов: LIVE_JUDGES_NOT_RUN.

## Фактический замер текущей пачки

| Команда | Сырой rc | Наблюдение |
|---|---|---|
| `red_sreda_sudji_206.sh --repo .` | 0 | KLETKI=2226 ZELENYE=2226 KRASNYE=0; 24.1 с |
| `red_sreda_sudji_206.sh --model` | 0 | KLETKI=2226 ZELENYE=2226 KRASNYE=0; 18.6 с |
| `red_sreda_sudji_206.sh --stabs` | 0 | OBMANOK=45 POIMANY=45 ZHIVYH=0; 174.2 с; Б-2 SELEKTOR neg=8 ctl=8 krasnyh=8:POIMAN |
| `catalog.py --check` | 0 | STABS=45 NORM_CONSUMERS=3 |
| `sweep.py --check --verbose` | 0 | MUTANTOV=112 POIMANY=81 ZHIVYH=27 EKVIVALENTOV=27 AVARII=4 SEKUND=348.7; ca72ade2ebeb POIMAN guard-quoted-greater-stderr-null |
| `--repo <мутант-Б-1>` | 1 | KLETKI=2226 ZELENYE=2225 KRASNYE=1; guard-quoted-greater-stderr-null |
| `--repo <мутант-Б-2>` | 1 | KLETKI=2226 ZELENYE=2218 KRASNYE=8; все outside dir-symlink-dotdot, внутренние ctl зелёные |
| `red_own_copy_paket_b.sh .` | 0 | регресс |
| `red_extract_pin_actual_066.sh .` | 0 | регресс |
| `red_predverie_172.py --repo` | 0 | регресс |
| `live_control.py` | 0 | OBSERVER_CONTROLS=21 KRASNYE=0; LIVE_JUDGES_NOT_RUN |
| `node scripts/gen-harness.ts --check` | 0 | роли согласованы с производными |
| `bash scripts/gen_ci_steps.sh --check` | 0 | workflow согласован с реестром |
| `validate_std.sh bash red_sreda_sudji_206.sh` | 0 | shellcheck 0.11.0 |

Независимая мера: len(TS_PREDICATES)=33, len(SH_PREDICATES)=14;
Counter(build_mutants по пути) = path-guard.ts:89, pre_judge.sh:23.
Время CI-ног: 24.1 + 18.6 + 174.2 = 216.9 с; вес меняет оркестратор.
TMPDIR — собственная .scratch-206e; VALIDATE_STD_SHELLCHECK —
/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck.

Первый pre_critic текущей пачки: rc 1, 912.4 с — бюджет листа 900 с
исчерпан на повторном полном --stabs в Дельте (строка 52). Причина
устранена в листе, не в воротах: review_delta.py вызывает неизменённые
probe/sweep для адресной мутации каждого блока и stale-entry-контроля.
Полные --stabs и --sweep остаются в Дверях; область этих проверок,
таймауты и бюджет не ослаблены. Адаптер только выбирает субъект из
существующих MUTATIONS/build_mutants; не подменяет judge или результат.
Для stale сначала исполняется честный список на настоящем пойманном
мутанте, затем тот же мутант с внесённой устаревшей записью.
Полный отрицательный контроль stale до адаптера тоже исполнен:
rc 1, MUTANTOV=112 POIMANY=81 ZHIVYH=27 EKVIVALENTOV=27 AVARII=4
SEKUND=242.5, EKVIVALENT_POIMAN для ca72ade2ebeb.

| Заключительная команда | Сырой rc | Наблюдение |
|---|---|---|
| `review_delta.py block1` | 0 | OBMANOK=1 POIMANY=1 ZHIVYH=0; 29.2 с |
| `review_delta.py block2` | 0 | OBMANOK=1 POIMANY=1 ZHIVYH=0; SELEKTOR neg=8 ctl=8 krasnyh=8:POIMAN; 26.6 с |
| `review_delta.py stale` | 0 | DELTA_STALE honest_rc=0 stale_rc=1; оба прогона MUTANTOV=1 POIMANY=1 AVARII=0; 1.2 с |
| `bash scripts/pre_critic.sh contracts/206-sreda-sudji.md` | 0 | КРИТИК: дверь зелёная; 599.9 с |
| `bash scripts/check_sdacha.sh "$PWD" contracts/206-sreda-sudji.md --run` | 0 | СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=3); 472.5 с |

Обе тяжёлые двери исполнены последовательно, без изменения их кода,
бюджета или таймаутов. Scratch и локальные измерители удаляются до коммита;
единственный постоянный адаптер review_delta.py потребляется тремя
строками Дельты и не заменяет полные двери.
