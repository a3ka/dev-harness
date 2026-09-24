accept

# Контракт 043 — шестой круг критика

Предмет `contracts/043-precizionnyj-prefriz-gejt.md` прочитан целиком на HEAD
`b7a16880683295b4bb4704cddf33ea31f631b436`. Целиком прочитаны diff
`2fca0deae0665a6bf666e2b096011b4b566107d8` и арбитраж
`verdicts/arbitration/043-bs7-cmdline-pozicii-env-s.md`.

Собственный клон получен ТОЛЬКО через
`ssh://git@github.com/a3ka/dev-harness.git` в уникальный каталог
`/tmp/dev-harness-verify/critic-043-v6-CautiousMagpie-20260924`.
Н-143 прочитан до клонирования. Локальный путь оркестратора не клонировался;
общий `/tmp/dev-harness-verify` не удалялся и не использовался как каталог клона.

## Граница и полнота

Б4, исходный Б5, Б6 и Б7 как спор о фиксированных позициях окончательно закрыты
арбитром и здесь НЕ переоткрываются. Предмет круга — исполнение решения Б7 и
действительно новые дефекты именно этого изменения, не повторный аудит всей
истории 043.

Набор полный: предмет :10–53, модель угроз :57–69, именованные исполнители
architect/implementer и ЗОНА-границы :275–287, команды готовности :312–347.
Контракт закоммичен. Критик не правил контракт, реализацию или постоянные
фикстуры. Единственный постоянный артефакт этого круга — настоящий вердикт.

## Решение арбитра исполнено

1. `scripts/check_precision_gate.sh:507–520`: чтение NUL-полей идёт до EOF,
   прежнего ограничения тремя полями нет. Цикл сравнения начинается с индекса
   1 и идёт до длины массива; каждое поле сравнивается с `"$barrier"` через
   литеральный `[ = ]`. Regex/glob-интерпретации содержимого поля нет.
2. Комментарий :424–505 переписан: названы ядерный и userspace-уровни,
   позиционное допущение «ВСЕГДА на 1 или 2» явно снято, а не заменено другим
   фиксированным индексом.
3. Добавлена ровно ОДНА постоянная green-фикстура —
   `green_20_honest_live_barrier_env_s_multi_flag.sh`, с требуемым shebang
   `#!/usr/bin/env -S bash -e -u`. Дифференциал ниже доказывает её полезность.
4. `contracts/043-precizionnyj-prefriz-gejt.md:68`: остаток обобщён на любое
   поле argv. Расширение уже принятого риска «путь как данные» не объявляется
   новым блокером.
5. `git diff --exit-code 2fca0de^ HEAD --` для green_17/18/19 дал rc0 без
   вывода: их текст не менялся. Полный список изменённых путей в scripts/,
   fixtures/, contracts/ между этими точками содержит только сам гейт,
   green_20 и контракт. Остальные барьеры этим фиксом не изменены.

## Живой дифференциал green_20: 1 → 0

Создан отдельный detached worktree на проверяемом HEAD:

```bash
git worktree add --detach /tmp/dev-harness-verify/critic-043-v6-CautiousMagpie-20260924-diff HEAD
# Дальнейшие команды — только внутри этого worktree:
git restore --source=2fca0de^ -- scripts/check_precision_gate.sh
bash fixtures/check_precision_gate/green_20_honest_live_barrier_env_s_multi_flag.sh
git restore --source=HEAD -- scripts/check_precision_gate.sh
bash fixtures/check_precision_gate/green_20_honest_live_barrier_env_s_multi_flag.sh
```

Менялся ТОЛЬКО гейт; green_20 и все остальные файлы оставались одинаковыми.
До фикса команда вернула **rc1**, после восстановления — **rc0**.

До фикса, существенные строки сырого вывода:

```text
ACTUAL_BARRIER_EXEC pid=2120348 argc=0
ACTUAL_BARRIER_EXEC pid=2120359 argc=0
precision-гейт 043: fixtures/check_dummy/green_live_env_s_multi_flag.sh: барьер dummy не вызван живьём (/proc-наблюдение не нашло exec)
```

В этом отрицательном прогоне также была строка `No such file or directory`
при чтении уже исчезнувшего `/proc/2120360/cmdline`; бесшумного stderr не
заявляю. Фикстура отказала именно по отсутствию подтверждённой живости, а
реальное исполнение dummy видно в обоих запусках. После восстановления фикса
вывод green_20 завершился `: rc 0`.

## Нерегрессия всех 16 прежних файлов

`bash fixtures/_krasnye_043.sh` на проверяемом HEAD → **rc0**:

```text
check_precision_gate/red_02_zona_collision_undeclared.sh rc=0
check_precision_gate/red_04_peresechenie_grammar.sh rc=0
check_precision_gate/red_05_peresechenie_unbound.sh rc=0
check_precision_gate/red_06_case_polarity_undeclared.sh rc=0
check_precision_gate/red_07_case_no_live_call.sh rc=0
check_precision_gate/red_08_case_self_check_fails.sh rc=0
check_precision_gate/red_13_multi_collision_same_path.sh rc=0
check_precision_gate/red_14_freeze_refuses_red_precision.sh rc=0
check_precision_gate/red_15_forged_trace_via_xtracefd.sh rc=0
check_precision_gate/red_16_xtrace_only_pass.sh rc=0
check_precision_gate/green_01_honest_no_collision.sh rc=0
check_precision_gate/green_03_zona_collision_declared.sh rc=0
check_precision_gate/green_09_self_application_043.sh rc=0
check_precision_gate/green_17_honest_live_barrier.sh rc=0
check_precision_gate/green_18_honest_live_barrier_with_arg.sh rc=0
check_precision_gate/green_19_honest_live_barrier_shebang_option.sh rc=0
check_precision_gate/green_20_honest_live_barrier_env_s_multi_flag.sh rc=0
итог: 17 файлов, провалов 0
```

Здесь rc0 у red-файла — успех его самопроверки отказа, а не принятие обманного
входа. В частности, green_17/18/19 зелены без переписывания их ожиданий.

Дополнительная scoped-приёмка:

- `bash fixtures/parsing_hygiene_battery/run_battery.sh check_precision_gate`
  → **rc0**, четыре класса закрыты: delimiter-collision, regex-injection,
  silent-drop, self-application-green. В stderr есть прежняя строка
  `fatal: tag 'frozen/contracts/991/1' already exists`; чистого stderr не заявляю.
- Обязательная живая команда роли:
  `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/critic-043-v6-CautiousMagpie-20260924 contracts/043-precizionnyj-prefriz-gejt.md`
  → **rc0**, последняя строка `OK`; stderr именует пропуск собственной семьи
  по исключению «барьер правится этим же черновиком».
- Попытка `bash scripts/verify_antiplacebo.sh --scope check_precision_gate`
  → **rc1**, `scope_select отказал (код 1)`. Прямой вызов scope_select
  уточняет: `неизвестный ключ check_precision_gate`. Это не успешный прогон
  антиплацебо. Причина явно записана в НЕ БАРЬЕР-шапке гейта :49–58:
  эта red_/green_-семья проверяется прямым Р10/Р11, а не case_*-шардом.
  Данное устройство не введено фиксом 2fca0de и не переоткрывается как Б4.

Полный CI, полный verify_antiplacebo, линтеры и форматтеры не запускались.

## Независимый поиск нового края

Проверены не следующие индексы той же матрицы арбитра, а сохранение байтов
поля и отсутствие ложного совпадения в расширенной области сканирования.
Одноразовая проба `bash tmp/critic043-edge.sh` использовала штатный `_toy.sh`,
настоящий гейт и настоящий toy git-репозиторий с mint-тегом. Гейт не подменялся.

- Положительный контроль: корень toy содержит литеральные `[x]` и обратную
  косую (`literal.[x]\\name`); dummy имеет shebang `env -S bash -e -u`, печатает
  число аргументов, спит секунду. Case прямо исполняет абсолютный путь dummy
  с тремя аргументами: пустым, содержащим обратную косую, многострочным.
  **Гейт rc0**, два `REAL_EXEC argc=3`, затем `OK`.
- Отрицательный контроль: в том же toy case больше НЕ исполняет dummy.
  Вместо него живёт `python3 -c 'import time; time.sleep(1)'`, у которого
  после пустого argv-поля стоят `"$barrier.suffix"` и `"prefix$barrier"`.
  Это проверяет именно поздние поля и точность полного литерального
  совпадения, не принятый остаток с ТОЧНЫМ путём как данными.
  **Гейт rc1**, `барьер dummy не вызван живьём`.

Вся проба → **rc0**, поскольку оба ожидаемых результата получены. Новый
блокер не воспроизведён. Это конечные положительный/отрицательный контроли,
а не заявление об исчерпывающем доказательстве всех возможных cmdline.
Короткоживущий барьер и точный путь в чужом argv не выдаются за новые находки:
оба остатка уже названы арбитражем и не возникли в этом изменении.

## Оценка пяти вопросов в границе круга

Критерий отличает фикс от отсутствия фикса живым green_20-дифференциалом;
заявленная готовность предъявлена командами с rc, не существованием файла.
Выбор алгоритма после арбитража исполнителю не оставлен: literal-скан всех
полей с индекса 1 задан и выполнен. Все три изменённых пути имеют исполнителя
и объявленные ЗОНА-границы. Нового противоречия AGENTS.md в изменении не
обнаружено. Действительных блокирующих находок нет; заморозка разрешена.

СОВЕТ contracts/043-precizionnyj-prefriz-gejt.md:68 — сопроводительный комментарий
нового механизма (`scripts/check_precision_gate.sh:429–449`, также комментарии
green_20) неточно рисует промежуточный argv ядра. Ядро передаёт один аргумент
`"-S bash -e -u"` целиком, а не отдельный `"-S"` и отдельный `"bash -e -u"`;
форма до userspace-разрезания — `[env, "-S bash -e -u", barrier]`.
Два уровня и отсутствие позиционного лимита описаны, алгоритм не опирается
на эту неточность и живой дифференциал зелён. Это только совет к пояснению,
не блокер и не возобновление решённого Б7.

Перед коммитом выполнены `git fetch origin` и `git merge --ff-only origin/main`:
`Already up to date`. Вердикт коммитится с явной identity critic и отправляется
на настоящий SSH-origin; рабочее дерево оркестратора критик не мутирует.
