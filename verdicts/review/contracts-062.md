FAIL

# Reviewer 062 — круг 2, после Р-1/Р-2 (атрибуция окна потребителей 116)

Предмет: `frozen/contracts/062/1` (tag-object `daca6ec492c293d3264888228187547bde36232b`; строка реестра
`062 → daca6ec…` совпадает), `contracts/062-atribucija-okna-potrebitelej.md`.
Реализация `bb42a41` (ленд `80c5697`) + `82b40d8` Р-1/Р-2 (ленд `6a22e66`). Вердикты: adversary v1 `d3bac14`
(accept), reviewer v1 `f228af7` (FAIL Р-1/Р-2), adversary v2 `d109e4c` (accept).

Судимый HEAD `5f49310` (локальный main). Клон суда `/tmp/dev-harness-verify/rev062c2`. Поле 062 с `6a22e66`
не менялось: `git diff --stat 6a22e66 HEAD -- scripts/check_consumers.sh package.json .github/workflows/ci.yml
fixtures/check_consumers fixtures/_krasnye_038.sh contracts/062-…` пуст, rc 0. Блоб `scripts/check_consumers.sh`
на HEAD = `9b2468d6c7435bccc10d522202f18e4932bb5499`. Свою меру держал вне клона суда: одноразовые клоны
`rev062k2-mut-{fl,rev,m2,ci,key,simple}`, `rev062k2-pre` (`59d8c4d`, main до ленда Р-1/Р-2), патчи в
`rev062k2-patches/`, проба v1 `rev062c-probe/difftree_failopen.sh`. В клоне суда правился только этот файл.

## Стенограммы спавна

Из контракта спавна: детектор rc 0 (локально, HEAD 5f49310); CI-гейт 6/6 success по 799f697.

Мой повтор:

```text
$ bash scripts/check_no_leak.sh --check /home/harness/dev-harness     (основной HEAD 5f49310)
основной чекаут чист                                                         LEAK_RC=0
$ bash scripts/check_ci_gate.sh /home/harness/dev-harness 799f697
  ok   CI зелёный: проверок 6, все success, по 799f697d77fd (a3ka/dev-harness)   CIGATE_799_RC=0
$ bash scripts/check_ci_gate.sh /home/harness/dev-harness
ОТКАЗ: коммит 5f493100244e не на origin/main — CI по нему не запускался; запушь и дождись прогона   CIGATE_HEAD_RC=1
```

HEAD-отказ ожидаем: батч-дисциплина, пуша нет (Н-5 из v1 остаётся наблюдением).

## Итог

- **Р-1 закрыт.** Проводка живая: npm-ключ гонит батарею 062, ci-шаг стоит сразу после
  `check:provodka-family-selftest`, `check_provodka` rc 0, `verify_ci_parity` показывает 0 расхождений.
  Обе формы фантом-проводки красны.
- **Р-2 закрыт по своей букве.** Отказ diff-tree теперь даёт именованный rc 1: на той же пробе до
  фикса было rc 0, после стало rc 1.
- **Р-3 — новый блокирующий отказ, его внёс сам фикс Р-2.** `2>&1` сливает stderr diff-tree в канал
  данных «тронут». Любой вывод git в stderr при успешном diff-tree делает писателя тронутым. Под
  `GIT_TRACE=1` живой потребитель 056 даёт rc 1 и называет `scripts/lib_registry.sh` «изменён».
  До фикса и на более простой форме тот же вход даёт rc 0.
- Н-3 остаётся неблокирующим, M2 перемерян.
- Adversary v2 добросовестен: все его утверждения воспроизводятся. Р-3 он не увидел — это пропуск
  охвата.

## Прогоны — сырой вывод и rc

### (а) Р-1: проводка живая

```text
$ npm run check:consumers-window-family-selftest
> bash fixtures/check_consumers/krasnye_062.sh
  ok   к1 … к8 (8 строк ok), s1..s6 пойманы, s1..s6-диффпробы ok
062: честных клеток 8, зелёных 8, красных: нет
062: стабов 6, поймано 6, ускользнуло: нет
062: диффпроб стабов без ручки 6, зелёных 6, провал: нет
итог 062: rc=0                                                               NPM_RC=0
$ bash scripts/check_provodka.sh . contracts/062-atribucija-okna-potrebitelej.md    PROVODKA_RC=0
$ bash scripts/verify_ci_parity.sh .
workflow-команд: 51 · скриптов в приёмке: 63 · объявленных исключений: 23 · matrix-ключей: 46 · анти-плацебо-запусков: 2 · расхождений: 0
PARITY_RC=0
$ grep -n 'krasnye_062\|provodka-family-selftest' .github/workflows/ci.yml
173:        run: npm run check:provodka-family-selftest
192:        run: bash fixtures/check_consumers/krasnye_062.sh
```

Положение шага совпадает с буквой ПРОВОДКИ («после шага `check:provodka-family-selftest`»). Ключ
`check:consumers-window-family-selftest` в package.json равен значению шага.

Счёт своей мерой, по коду батареи, а не по её выводу: определений `k[0-9]()` — 8, строк `hcell` — 8,
`s[0-9]()` — 6, `scell` — 6, `dcell` — 6. Ключей в блоке `scripts` package.json — 63, это совпадает со
«скриптов в приёмке: 63» у паритета.

### (б) Р-2: diff-tree fail-closed (проба v1)

```text
HEAD 5f49310:
ДО удаления: rc=1 вывод=[потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы]
rev-list окна rc=0
diff-tree коммита писателя rc=128
ПОСЛЕ удаления дерева: rc=1 вывод=[потребители 116: список судимых коммитов окна недоступен: fatal: unable to read tree 79c51f64f25170f6ed2bf309dfae49ba400ffc05]
59d8c4d (до ленда Р-1/Р-2):  ПОСЛЕ удаления дерева: rc=0 вывод=[]          ← красное предъявлено
мутант rev (фикс Р-2 откатан к форме `2>/dev/null | grep -q .`): ПОСЛЕ удаления дерева: rc=0 вывод=[]
```

Сама обёртка пробы возвращает rc 0: последняя её команда — `echo`. Судимый rc — `rc=` в печати.

### (в) Р-3: stderr git в предикате тронутости

```text
HEAD 5f49310:
$ bash scripts/check_consumers.sh . contracts/056-dver-retake-ahead.md                         PLAIN_056_RC=0
$ GIT_TRACE=1 bash scripts/check_consumers.sh . contracts/056-dver-retake-ahead.md
потребители 116: писатель scripts/lib_registry.sh изменён, потребитель scripts/check_spec_ready.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы
TRACE_056_RC=1
59d8c4d (до фикса), тот же вход:  GIT_TRACE=1 … 056                                              PRE_TRACE_056_RC=0
rev062k2-mut-simple (строка 221 без `2>&1` и без `: $out`):
  GIT_TRACE=1 … 056                                                                            SIMPLE_TRACE_056_RC=0
  batterie 062: 8/8, 6/6, 6/6, итог 062: rc=0                                                  SIMPLE_K062_RC=0
  проба v1: ПОСЛЕ удаления дерева: rc=1 (fatal git в stderr, фраза И-4 в отказе)
  живые 056/058/059                                                                            RC=0 RC=0 RC=0
```

### (г) Мутанты adversary: прежний и новые

```text
fl  «чужой ленд включён» (ветвь исключения → `;;`), git apply:
  FAIL к1: чужой ленд (land: wip/090/…) вне окна — гейт не судит: rc 1, ожидался 0
  062: честных клеток 8, зелёных 7, красных: к1-чужой-ленд-не-судится   итог 062: rc=1    K062_fl_RC=1
ci  фантом-шаг (строка 192 `run:` закомментирована):
  FAIL скрипт «check:consumers-window-family-selftest» есть в приёмке, но отсутствует в CI и не объявлен исключением
  workflow-команд: 50 · … · расхождений: 1                                                 PARITY_ci_RC=1
  проводка: guard не подключён: fixtures/check_consumers/krasnye_062.sh не вызывается …    PROVODKA_ci_RC=1
key фантом-ключ (значение → `bash fixtures/_krasnye_060.sh`):
  > bash fixtures/_krasnye_060.sh … итог 060: rc=0                                         NPM_key_RC=0
  FAIL …ci.yml:192: команда «bash fixtures/check_consumers/krasnye_062.sh» есть в CI, но нет пункта в приёмке …
  FAIL скрипт «check:samodostatochnost-family-selftest» есть в приёмке, но отсутствует в CI …
  … расхождений: 2                                                                          PARITY_key_RC=1
                                                                                            PROVODKA_key_RC=0
```

Цифры и имена сходятся с таблицами `d109e4c` дословно. Одно уточнение своей меры: подмену ключа ловит
только паритет, `check_provodka` её пропускает (rc 0). Хватает одного барьера, потому что оба стоят в CI.

### (д) Н-3 перемерян (M2 «исключается только tip чужой ветки»)

```text
rev062k2-mut-m2: 062: честных клеток 8, зелёных 8 … итог 062: rc=0                         K062_m2_RC=0
живые 056/058/059 под M2                                                                   RC=0 RC=0 RC=0
```

### (е) Зоны, frozen-diff, scoped, живые, 038, gen

```text
$ git show --stat 82b40d8     (author implementer)
 .github/workflows/ci.yml   | 19 +++  package.json | 3 ++-  scripts/check_consumers.sh | 14 +++---
$ git diff --stat 82b40d8 6a22e66 -- scripts/check_consumers.sh fixtures/check_consumers      (пусто) rc 0
ЗОНА implementer (контракт :184): scripts/check_consumers.sh fixtures/check_consumers/ .github/workflows/ci.yml package.json
$ git diff --exit-code frozen/contracts/062/1 HEAD -- contracts/062-… fixtures/check_consumers fixtures/_krasnye_038.sh
(пусто)                                                                                    FROZEN_DIFF_RC=0
$ bash scripts/check_contract_frozen.sh . contracts/062-…
  ok   contracts/062-atribucija-okna-potrebitelej.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают   CF_RC=0
$ bash scripts/check_zones.sh .
замороженных контрактов: 64 · объявленных авторов: 1 · коммитов в диапазонах: 2969 · проверено по зонам: 1513   ZONES_RC=0
$ bash scripts/verify_antiplacebo.sh . --scope check_consumers
  ok   check_consumers/case_proba_krasna.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «ПОТРЕБИТЕЛЬ-проба красна»
барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1                      AP_RC=0
$ bash scripts/check_consumers.sh . contracts/056-dver-retake-ahead.md                    RC=0
$ bash scripts/check_consumers.sh . contracts/058-sharing-agentdb-dev-zona.md             RC=0
$ bash scripts/check_consumers.sh . contracts/059-sverka-objavlennyh-putej-profylja-s-derevom.md   RC=0
$ EXPECT_RC=0 bash fixtures/_krasnye_038.sh
check_consumers/red_atribucija_okna_062.sh rc=skip (чужой NNN 062: …)
итог: 37 файлов, расхождений 0 (режим ожидания rc=0)                                     K038_RC=0
$ node scripts/gen-harness.ts --check
харнес соответствует roles/ (9 ролей)                                                    GEN_RC=0
```

Первый прогон scoped antiplacebo дал AP_RC=1: «дерево изменилось вне $WORK — ./tmp/frozen.ZSo7cF/…».
Причина — мой собственный параллельный запуск `check_contract_frozen` в том же клоне, он пишет
`./tmp/frozen.*`. Одиночный повтор выше — rc 0. Дефектом предмета это не является.

Проверка не подогнана: файлы батареи, раннера и `_krasnye_038.sh` после заморозки не правились (frozen-diff
пуст). `82b40d8` не трогает `roles/`, `contracts/`, `verdicts/`, то есть норму молча не меняет. Коммит
один на закрытие одного вердикта `f228af7` с двумя пунктами одной задачи, ссылка «062» есть; атомарность
принимаю.

## Находки (формат reslop)

---
status: ready
---

- [x] **Р-1 (из v1) — guard-канал 062 не подключён.** ЗАКРЫТ `82b40d8`: см. (а) и фантомы ci/key в (г).
- [x] **Р-2 (из v1) — отказ diff-tree маскировался под пустое множество (И-4).** ЗАКРЫТ `82b40d8`:
  до фикса проба давала rc 0, после — rc 1 с фразой И-4 (б).
- [ ] **Р-3 — stderr git сливается с каналом «тронут» (И-2, И-3).** Класс: БЛОКИРУЕТ. Это семантический
  FAIL и одновременно блокирующий ACCIDENTAL по 050: все три части названы.
  - Фрагмент, `scripts/check_consumers.sh:221-223`:
    `out="$( { git -C "$ROOT" diff-tree … "$c" -- "$w"; } 2>&1 )" || die "…недоступен: $out"`, затем
    `[ -n "$out" ] && { hit=1; break; }`.
  - Источник, И-2: «Зарегистрированный писатель считается тронутым ⟺ хотя бы один коммит судимого
    множества менял блоб его пути (diff-tree по коммиту)». И-3: «vacuous-ветви (… нет тронутых
    писателей) — rc 0 как сегодня».
  - Наблюдение (в): при `GIT_TRACE=1` diff-tree завершается успешно, но пишет в stderr. `out`
    становится непустым, и каждый писатель окна объявляется тронутым. Живой 056 даёт rc 1 с фразой
    «писатель scripts/lib_registry.sh изменён». Без переменной и до фикса (`59d8c4d`) на том же входе
    rc 0. Регрессию внёс фикс Р-2.
  - Исход — ложный отказ, не ложный зелёный. Но предикат, определённый контрактом через блоб пути,
    теперь зависит от диагностики git. Отказ называет неизменённый писатель изменённым.
  - [INFERENCE] Другие источники stderr при успешном diff-tree (`GIT_TRACE2`, hint'ы устаревших
    механизмов вроде grafts) дают тот же исход. Сам я мерял только `GIT_TRACE=1`.
  - Отсутствующее свойство: тронутость определяется только stdout diff-tree.
  - Более простая форма, проходящая все строки приёмки (измерено в `rev062k2-mut-simple`):
    `out="$(git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" -- "$w")" || die "потребители 116:
    список судимых коммитов окна недоступен"`. stderr git остаётся на терминале. Результат: батарея
    8/8·6/6·6/6, rc 0; проба v1 rc 1 с фразой И-4; живые 056/058/059 rc 0; `GIT_TRACE=1` 056 rc 0.
  - Закрывает implementer, в своей зоне, одной строкой.
- [ ] **Н-3 (из v1) — батарея не отличает «чужой ленд исключён целиком» от «исключён только tip».**
  Класс: пробел батареи (architect-зона); НЕ блокирует, подтверждаю оценку v1.
  - Перемер (д): M2 зелёный, 8/8, 6/6, 6/6; живые rc 0 ×3.
  - Ошибка M2 направлена в строгость: недоисключённый чужой коммит даёт ложный отказ, а не ложный
    зелёный.
  - Честный код исполняет И-1 буквально (`${mc}^1..${mc}`, строка 198).
  - Более простая форма — к1 с чужой веткой из двух коммитов — остаётся рекомендацией architect.
- [ ] **Н-4 (из v1) — rev-list/log цикла исключения (строки 193-198) глушат отказ.** Класс: наблюдение;
  НЕ блокирует. Не закрыт `82b40d8`. Исход по-прежнему только ложный отказ (исключение теряется), а
  не vacuous rc 0.
- [ ] **Н-6 — Р-2 и Р-3 не стерегутся постоянной клеткой.** Класс: пробел батареи (architect-зона,
  Н-39); НЕ блокирует.
  - Мутант rev (откат фикса Р-2) проходит батарею зелёным (8/8, rc 0). Ловит его только одноразовая
    проба ревьюера (б).
  - Р-3 батарея тоже не видит.
  - Рекомендация architect: клетка «удалён tree-объект коммита окна → rc 1 фразой И-4» и клетка
    «stderr git при успехе (GIT_TRACE=1) → vacuous rc 0».
- [ ] **Н-7 — комментарий п2 (строки 179-183) по-прежнему сужает И-4 до «rev-list диапазона
  отказал».** Класс: наблюдение; НЕ блокирует. Новый комментарий строк 213-220 называет
  rev-list/log/diff-tree, а шапка п2 ему противоречит.
- [ ] **Н-5 (из v1) — CI-гейт на HEAD суда rc 1.** Класс: наблюдение процесса; НЕ блокирует.

## Добросовестность adversary v2 (`d109e4c`)

- **Воспроизведено дословно:**
  - позитивный контроль 8/6/6;
  - прежний мутант «чужой land включён» (к1);
  - обе формы фантом-проводки, включая имена расхождений паритета и счёт 1/2;
  - проба Р-2;
  - scoped, живые, frozen-diff, `check_contract_frozen`, зоны.
- **Честность изложения.** Adversary честно оговорил, что обёртка пробы возвращает rc 0 из-за
  последнего `echo`. Счёт зон у него 2951 при HEAD `8e52c20`, у меня 2969 при `5f49310` — HEAD разные,
  расхождения нет.
- **Пропуск охвата, не сокрытие.**
  - Новую поверхность фикса Р-2 (захват `2>&1` в канал данных) он не пробовал — это Р-3.
  - Откат Р-2 против батареи не ставил, поэтому не увидел, что постоянной клетки у Р-2 нет (Н-6).
  - Всё, что вердикт утверждает, верно.

## Паразитная сложность (контракт 050) — пять вопросов по артефактам `82b40d8`

| артефакт | (1) свойство | (2) состояние, явность | (3) файлов на правку | (4) глубина | (5) потребитель / дубль | класс |
|---|---|---|---|---|---|---|
| ci-шаг `bash fixtures/check_consumers/krasnye_062.sh` (ci.yml:175-192) | ПРОВОДКА 062: guard подключён, прямой шаг после provodka-family | нет | 2 (ci.yml + package.json — правило 6 паритета); +1 к числу CI-шагов, так велит контракт | интерфейс 0, работа — вся батарея | check_provodka г2, verify_ci_parity; форма прецедента 058/059/060/063 | ESSENTIAL (17 строк комментария многословны, это совет) |
| ключ `check:consumers-window-family-selftest` | ПРОВОДКА: «ключ … равен значению шага» | нет | те же 2 | — | verify_ci_parity правило 6 | ESSENTIAL |
| `out=… \|\| die` (строки 221-223) | И-4: отказ diff-tree именован | локальная `out`; явная | 1 | интерфейс гейта не менялся | к8-класс, проба (б) | ESSENTIAL |
| `2>&1` + хвост `: $out` в die (строка 221-222) | ни одно: фраза И-4 проходит и без них, stderr git виден на терминале сам | stderr смешан с данными — неявно, только побочным эффектом | 1 | — | потребителя нет | ACCIDENTAL, блокирует — Р-3 (фрагмент, свойство, простая форма названы и измерены) |

## Вердикт

**FAIL** на HEAD `5f49310`, круг 2, после Р-1/Р-2.
- Р-1 и Р-2 закрыты добротно, на живых прогонах.
- Блокирует **Р-3**: регрессия, которую внёс фикс Р-2. Правка — одна строка в зоне implementer
  (`scripts/check_consumers.sh:221-222`); простая форма измерена и проходит все строки приёмки.
- Н-3, Н-4, Н-5, Н-6, Н-7 не блокируют. Н-3 и Н-6 — рекомендации architect-зоне.
- Путь закрытия: коммит implementer по Р-3, затем круг adversary и ревьюера по новому блобу
  `scripts/check_consumers.sh`.
