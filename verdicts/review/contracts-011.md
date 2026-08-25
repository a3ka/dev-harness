FAIL

# Ревьюер — контракт 011, финальный гейт, HEAD `6a34bd1`

## Единственная блокирующая находка — область правки / идентичность исполнителя

**FAIL: незаявленный исполнитель внёс предметные правки в зону architect.** В §Зоны
`contracts/011-prijomka-sudi-i-gigiiena-rannera.md` объявлены только `architect`,
`implementer`, `critic`, `adversary` и `reviewer`; строки `ЗОНА orchestrator:` нет. Это
не относится к четырём уже оформленным исключениям `СПАСЕНО architect`: в строке
СПАСЕНО названы только `4a73d71d`, `a2aaf5ee`, `320d67f5`, `a534e4b6`.

Независимая историческая мера (`git log`, а не `check_zones`) дала следующий сырой
результат для файлов предмета:

```text
COMMIT 7b98b07f741e8ec7d2c59af8fb3afd2e9b1c88bf
AUTHOR orchestrator
SUBJECT 011: семантическое усиление sostav + ветвь tocou (находки 1-2 адверсария, круг 2)

COMMIT 8e4b5d1aacc8950e2edc2461be4adacdbac70648
AUTHOR orchestrator
SUBJECT 011: причина ветви sostav — континуальная подстрока (вызов не наблюдался)
IMPLEMENTATION_OWNER_AUDIT_EXIT_RC=0
```

Сырой `git show --name-status` для этих коммитов подтверждает предметные пути:

```text
7b98b07:
M fixtures/check_runner_hygiene/_ref_runner.sh
A fixtures/check_runner_hygiene/case_sostav_gigiena_bez_raboty.sh
A fixtures/check_runner_hygiene/case_sostav_kardinalnost_obmanka.sh
A fixtures/check_runner_hygiene/case_tocou_symlink_podmena.sh
M scripts/check_runner_hygiene.sh

8e4b5d1:
M scripts/check_runner_hygiene.sh
```

Следовательно, фактическое `user.name=orchestrator` не соответствует заявленной
зоне автора этих правок. Это ровно тот случай, для которого идентичность автора
нормативна; успешный `check_zones` не закрывает находку, поскольку его цикл берёт
в суд только коммиты, чей `%an` уже присутствует среди объявленных авторов, и
пропускает не объявленный `orchestrator`. Его зелёный вывод поэтому не является
доказательством зоны для двух коммитов выше. Отдельный связанный процессный коммит
`092314c7` также имеет `AUTHOR orchestrator` и меняет
`NABLIUDENIA_ARCHITECT.md` — путь зоны architect; он подтверждает, что это не
опечатка отображения одного коммита.

Четыре санкционированных СПАСЕНО проверены отдельно: строка контракта содержит
все четыре полных хеша, а независимая команда дала:

```text
FIXTURE_COUNT=33
RESCUE_COMMIT=4a73d71d2657cc9be1ef14d79635fccf1d930e49 PRESENT
RESCUE_COMMIT=a2aaf5ee2963a5c434bb4894449bbbac6e4ee37d PRESENT
RESCUE_COMMIT=320d67f52a4a12add583f6fb76d02267d494ae70 PRESENT
RESCUE_COMMIT=a534e4b6bd45fed582ca042de091d20c09ae1481 PRESENT
MEASUREMENT_EXIT_RC=0
```

Они не санкционируют `7b98b07`, `8e4b5d1` или `092314c7`.

## Самостоятельно воспроизведённые зелёные результаты

Все предписанные конечные пробы выполнены на HEAD самим ревьюером. Они не
снимают блокер области, но исключают пересказ чужих логов:

```text
$ bash scripts/check_runner_hygiene.sh
  ok   (lock) трёхпольный lock владельца, отказ код 3 «занят», чужой lock байт-в-байт цел, первый прогон цел (rc=0)
  ok   (race) два одновременных старта: ровно один rc=3 «занят», lock никогда не пуст
  ok   (scratch) дерево нетронуто ни во время прогона, ни после (рекурсивный зонд: состав+тип+размер и байты)
  ok   (scratchdef) пустая переменная → скратч с lock под ${TMPDIR:-/tmp}; дерево чисто и во время, и после (рекурсивный зонд)
  ok   (scratchexpl) явная переменная с in-tree путём не оставила следов: отказ до создания — эталон, вынос наружу — равным образом честен
  ok   (tocou) symlink-подмена scratch-пути не оставляет артефактов в дереве (создание от канонического предка)
  ok   (sostav) непредсказуемый состав ×2 кардинальности: lock и run-каталог в скратче, ФАКТИЧЕСКИЙ зелёный и повторный красный вызов каждого барьера/фикстуры (внешние журналы свидетельств), дерево нетронуто
  ok   (chistka) мусор мёртвых владельцев убран, неприкосновенное цело
  ok   (pgid) name-decoy пережил прогон и второй запуск — убийство только по pgid своих
  ok   (norma) полный текст в разделе «Воркфлоу майлстоуна»; маркеры единственны во всём файле
  ok   (carveout) правило 16 сохраняет исключение для scratch раннера
  ok   (a010) у п.8 контракта 010 стоит пометка v+1 (грилинг 2026-08-24)
  ok   (porjadok) аннотация 010 и вердикт 010-v2 — разные коммиты в верном порядке; состав пачки A полон, маркер в A:AGENTS.md есть; вердикт accept
check_runner_hygiene: ветви «all» зелены
CHECK_RUNNER_HYGIENE_EXIT_RC=0
```

```text
$ bash scripts/verify_antiplacebo.sh --scope check_runner_hygiene
SCOPED: барьеров 1 из выборки — не для приёмки
... 33 строки `ok`, каждая: зелёный контроль есть, повторный прогон красный кодом 1 ...
барьеров: 1 · фикстур: 33 · предъявлено красным повторным прогоном: 33
VERIFY_HYGIENE_EXIT_RC=0

$ bash scripts/verify_antiplacebo.sh --scope check_zones
SCOPED: барьеров 1 из выборки — не для приёмки
... 12 строк `ok`, каждая: зелёный контроль есть, повторный прогон красный кодом 1 ...
барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
VERIFY_ZONES_EXIT_RC=0
```

```text
$ bash scripts/check_zones.sh
... контракт 011: коммит a534e4b6 (architect) — СПАСЕНО, из суда зон выведен
... контракт 011: коммит 320d67f5 (architect) — СПАСЕНО, из суда зон выведен
... контракт 011: коммит a2aaf5ee (architect) — СПАСЕНО, из суда зон выведен
... контракт 011: коммит 4a73d71d (architect) — СПАСЕНО, из суда зон выведен
замороженных контрактов: 10 · объявленных авторов: 5 · коммитов в диапазонах: 224 · проверено по зонам: 145
CHECK_ZONES_EXIT_RC=0

$ bash scripts/check_contract_frozen.sh
  ok   contracts/010-topologija-orkestrator-arhitektor.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
  ok   contracts/011-prijomka-sudi-i-gigiiena-rannera.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
планов и контрактов на HEAD: 14 · черновиков: 3 · заморожено: 11 · реестр: full
CHECK_CONTRACT_FROZEN_EXIT_RC=0
```

```text
$ npm run check:charter
... уставных документов: 13 · изменений в них: 35 · с разрешения: 35
CHECK_CHARTER_EXIT_RC=0

$ npm run check:ci-parity
workflow-команд: 22 · скриптов в приёмке: 34 · объявленных исключений: 12 · расхождений: 0
CHECK_CI_PARITY_EXIT_RC=0

$ bash scripts/check_scoped_run.sh
  ok   (л) фильтр: прогнан ровно выбранный b, RC=0
  ok   (м1) отказ «красное не предъявлено» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м2) отказ «код 2 (нечем проверить)» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (м3) отказ «необъявленный код 7» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (н) отказ «дерево изменилось вне $WORK» сохранён в scoped (full_rc=scoped_rc=1)
  ok   (case) --scope key/case прогоняет ровно 1 case, несуществующий case → fail-closed
  ok   (изол) HOME изолирован per-fixture: leak-игрушка отвергнута («красное не предъявлено»)
  ok   (ц) нерезолвимый base → полный прогон, RC=0
  ok   (ч) doc-only → RC=0, 0 барьеров
  ok   (ц2) пустой base → полный прогон, RC=0
  ok   (ц3) нерезолвимый ненулевой SHA → полный прогон, RC=0
  ok   (ч2) не-README нулевая выборка → RC=0, 0 барьеров
  ok   (ci) ci.yml: ИСПОЛНЯЕМАЯ run-строка гонит анти-плацебо scoped (--changed github.event.before)
check_scoped_run: ветви «all» зелены
CHECK_SCOPED_RUN_EXIT_RC=0
```

## Независимые проверки прочих пунктов

**Красные барьеры не переписаны implementer под реализацию.** `git diff-tree` показал,
что `d0471c6` меняет только `scripts/verify_antiplacebo.sh` (+18), а `a3858f8` —
только тот же файл (+35); ни один не меняет барьер или fixture. Исторические
усиления соответствуют §История правок и фактическим диффам: `fe6dbdf` добавил
формат/атомарность lock, противоположную norma и scratchdef; `81291c5` добавил
real race, placement/unique norma, во-время default scratch и porjadok; `6d9f7ca`
добавил fence, вложенное дерево и пачку A. В каждом случае добавлены именованные
negative fixture, а собственный scoped прогон выше показал все 33 повторных
красных после зелёного контроля. Последующие adversary-фикстуры проверены
исполнением: `case_scratchexpl_javnyj_v_dereve`,
`case_tocou_symlink_podmena`, `case_sostav_gigiena_bez_raboty` и
`case_sostav_kardinalnost_obmanka` дают красное с соответствующими причинами.

**Счётчик.** Текст замороженного §Приёмочный критерий всё ещё говорит
`счёт: 28 фикстур`, а независимый `find ... -name 'case_*.sh' | wc -l` дал 33;
реальный scoped прогон подтвердил 33/33. Это объявленная устаревшая
нормативная сводка, но не уменьшение фактической защиты и не скрытый дефект
приёмки: пять дополнительных фикстур предъявлены красными. Сам по себе счётчик
не был бы основанием блокировать done; его следует исправить только процедурой
v+1 до следующего цикла, а не молча менять замороженный контракт.

**Следы грайнда.** Поиск `TODO|FIXME|XXX|not implemented|недодел|заглуш` в
`scripts/verify_antiplacebo.sh`, `scripts/check_runner_hygiene.sh` и
`fixtures/check_runner_hygiene/` не нашёл TODO/FIXME/недописанных веток; найденные
`NOT_IMPLEMENTED` — объявленный код 2 и обработка отсутствующих prerequisites,
а «заглушка» — предмет red fixtures. Воспроизведённые 13 зелёных ветвей и
33/33 красных не дают признака недоделанной реализации. Процессный тайм-бокс
не превращён в отдельную находку предмета.

## Рекомендация

Не ставить `done/contracts/011/1`, пока блокер области не закрыт в истории по
регламенту. После закрытия нужен новый финальный гейт; текущий FAIL не является
оценкой уже решённой конструкции контракта.
