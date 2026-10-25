FAIL
OBJECT=7c22be4d0d6fd9fe3d39e9f02f583cc271296a8d

# Круг 3 (последний): контракт 138 start-ekran

Судится закоммиченный контракт и доказательная сила его батареи, НЕ реализация Android. Граница — РЕШЕНИЕ арбитра `contracts-138-arbitraz.md`, вопрос 4: оси G/H, H1–H3, зелёные контроли C, замер продукта E, сохранность прежних клеток. H4/H5 не использованы как основание FAIL.

**Итог: два блокера — H2 (экранированный бэктик внутри шаблонного литерала) и H3 (живая мутация удаления защиты каталога `__tests__`, скрытая соседней проверкой имени `.test.`).** Точные прежние обходы закрыты. Следующий шаг — возврат к арбитру по его решению, НЕ круг 4.

## Объект и полнота набора

Клон создан только SSH-командой:

```text
git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic138r3/repo
rc 0
```

`origin/main` уже продвинулся относительно указанной в задании базы. Поэтому окончательное дерево построено новой локальной веткой от `e56edc322`, затем применены три заданных патча `git -c core.hooksPath=/tmp/dev-harness-verify/nohooks am` с committer architect. OBJECT не доступен как git-объект в SSH-клоне (`git diff 7c22be4d HEAD` первоначально дал `fatal: bad object`, rc 128); вместо притворного пустого diff предъявляю тождество полных деревьев:

```text
# клон автора, только чтение
 git rev-parse 7c22be4d^{tree}
0e9cda672aa27309c0a29eb2b024798374592754
# клон критика после восстановления точной базы
 git rev-parse HEAD HEAD^{tree}
af0705fdb3eff860697be0cd3a11de4e4c07f61e
0e9cda672aa27309c0a29eb2b024798374592754
```

Предмет, критерий с командами, исполнители, ЗОНА/ПЕРЕСЕЧЕНИЕ, класс риска и модель угроз присутствуют. Набор полный. Обычный класс риска соответствует объявленной границе: новые решения auth/gate не раздаются 138. Правки контракта, батареи и продукта критиком не делались. Мутации и свидетели — только в одноразовой области `/tmp/dev-harness-verify/Critic138r3/`. По специальному заданию вердикт передаётся оркестратору для коммита; critic commit/push не делает.

## Замеры перед выводом

Команды из корня клона, если не указан абсолютный путь:

| команда | rc | наблюдение |
|---|---:|---|
| `python3 fixtures/workshop_project/start_ekran_138/probe.py --model` | 0 | 62/62 `CASE … ok`, все четыре контроля C зелёные |
| `python3 fixtures/workshop_project/start_ekran_138/probe.py --stabs` | 0 | контроль 62/62, 48 `STAB … KRASEN`, `SVJAZI 48`, живых 0 |
| `env TMPDIR=/tmp/dev-harness-verify/Critic138r3/scratch bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh` | 1 | 11 `ok`, 51 `KRASNO`; это ожидаемая граница безфлагового режима с субъектом 132 |
| `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic138r3/repo contracts/138-start-ekran.md` | 0 | `OK` |
| `bash scripts/pre_critic.sh contracts/138-start-ekran.md` | 0 | `ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3`, `КРИТИК: дверь зелёная` |
| `python3 /tmp/dev-harness-verify/Critic138r3/audit138r3.py` | 0 | независимые меры, таблица лексики/места, три мутации кода, полные свидетели V→Pr |
| `python3 /tmp/dev-harness-verify/Critic138r3/closure138r3.py` | 0 | замер продукта методом арбитра, frozen-зоны, отсутствие субъекта, четвёртая мутация |
| `node /tmp/dev-harness-verify/Critic138r3/syntax138r3.cjs` | 0 | синтаксический разбор свидетелей и стенд-инов; результаты каждого файла ниже |

Вторая мера — данные source.json и байты текста, а не счёт повторного вывода модели:

```text
COUNTS 62 8 18 48 16 8
PACK_MEASURES 60 108 3983
OLD_EXPECTATIONS 39 CHANGED ['kontrakt-slishkom-dlinnyj', 'kontrakt-shirokij']
SYNC proverka_tekst True
SYNC flow True
SYNC kontrakt_tekst True
ARBITER_MEASURE unique_literals 80 occurrences 82 files 10 diffs 0
VLADELTCY 14 / 14 FOUND 8
```

Расшифровка COUNTS: 62 входа, 8 зелёных/54 красных, 18 файлов стабов, 48 связей, 16 PNG-носителей, 8 кадров. Пачка **60 строк / максимум 108 символов / 3983 байта**, все три предела выдержаны. Из 39 прежних ожиданий 37 тождественны; два размера изменились ровно на пять байт вслед за текстом пачки: `100/5278 → 100/5283`, `61/6900/16879 → 61/6900/16884`; оба остаются красными `NE_ODNA_STRANICA`.

Продукт `/tmp/dev-harness-verify/Impl118g/mob` прочитан без изменений. Важно для воспроизводимости числа 80: скрипт арбитра `Arbiter138/scratch/arb_lexer_sweep.py` считает **уникальные литеральные значения**; в файлах 82 вхождения этих 80 значений, 10 файлов. По той же мере 80/80 совпадают с функцией круга 2, расхождений 0; дополнительно проверены все 82 позиции, рассинхрона переводов строк 0. По VLADELTCY совпадают все 14 ответов, положительных 8: шесть ещё не реализованных/отсутствующих носителей не превращены в фиктивно найденные.

```text
OWNER start_sostojanie_idle False False
OWNER start_sostojanie_composer False False
OWNER start_sostojanie_decision False False
OWNER start_sostojanie_resume False False
OWNER start_next_variant False False
OWNER first-run-continue False False
OWNER erstinfo_gate_current True True
OWNER erstinfo_continue_start True True
OWNER auth-demo-entry True True
OWNER start_tabs True True
OWNER start_tab_start True True
OWNER start_tab_vorgaenge True True
OWNER start_tab_schutz True True
OWNER start_tab_post True True
```

В реальной отдельной копии без `scripts/ekran_shablon.py`, не через подмену SUBJECT:

```text
bash /tmp/dev-harness-verify/Critic138r3/scratch/nosubject/fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh
rc 1
SHABLON_ABSENT
CASE chestnyj-ekran KRASNO (SHABLON_ABSENT)
```

Далее по каждому из 62 входов та же строка отказа; независимый счёт `ABSENT_CASES 62`.

## Таблица H и привязки по коду

На OBJECT стандартные клетки H1 (7) красные: хвостовой `//`, отдельный `//`, inline `/* */`, многострочный `/* */`, JSDoc, однострочный/многострочный JSX-комментарий. H2: одинарная строка не вплотную, двойная строка с экранированием, многострочный шаблон и прежняя строка вплотную красные. H3 (9) красные: `__tests__`, `__mocks__`, `__snapshots__`, `.test.`, `.spec.`, `.stories.`, `.d.ts`, `.snap`, не-код `.md`. Имя клетки само по себе не доказывает независимость адресных причин — см. блокер B2.

Из кода s49/s50 проверено: s49 убирает применение `kod_maska`, сохраняя фильтр места; s50 убирает `ekran_kod`, сохраняя лексер. Живой `--stabs` действительно краснит s49 на 12 связях (7 комментариев + 3 новые строки + прежние v-stroke/v-kommentarii), s50 на 9 местах. s46 красен на девяти формах G, s47 — на двух чужих деревьях. Это не приписано по одному лишь названию стабов.

Независимый расширенный прогон места на OBJECT:

```text
LEX H3-__tests__/fake.test.tsx expected False found False
LEX H3-deep/__tests__/fake.tsx expected False found False
LEX H3-__mocks__/fake.tsx expected False found False
LEX H3-__snapshots__/fake.tsx expected False found False
LEX H3-fake.test.tsx expected False found False
LEX H3-fake.spec.tsx expected False found False
LEX H3-fake.stories.tsx expected False found False
LEX H3-fake.d.ts expected False found False
LEX H3-fake.snap expected False found False
LEX H3-fake.md expected False found False
LEX H3-fake.TSX expected False found False
LEX H3-fake.test.TSX expected False found False
LEX H3-fake.test.tsx.jsx expected False found False
LEX H3-fake.tsx.md expected False found False
LEX H3-fake.d.tsx expected False found False
LEX PATH-outside-alphabet-tests/fake.tsx expected True found True
LEX PATH-outside-alphabet-e2e/fake.tsx expected True found True
LEX PATH-outside-alphabet-fixtures/fake.tsx expected True found True
LEX PATH-outside-alphabet-fake.tsx.jsx expected True found True
```

`tests/`, `e2e/`, `fixtures/` не входят в закрытый алфавит арбитра; зелень здесь не объявлена новым блокером. Верхний регистр и двойные расширения запрещённые случаи не спасают.

Зелёные контроли из форм продукта остаются зелёными; дополнительно проверены `http://` и `/* */` внутри настоящих строк, экранированная кавычка, апостроф/regex/JSX `//` строкой выше носителя:

```text
LEX C-http-string expected True found True
LEX C-block-in-string expected True found True
LEX C-escaped-quote expected True found True
LEX C-runtime-ternary expected True found True
LEX C-jsx-comment-neighbor expected True found True
LEX C-apostrophe-other-line expected True found True
LEX C-jsx-slashes-next-line expected True found True
LEX C-regex-next-line expected True found True
LEX C-apostrophe-same-line-residual expected True found False
```

Последняя строка — явно разрешённый арбитром остаток, не блокер.

## Прежние обходы закрыты

Команда `python3 /tmp/dev-harness-verify/Critic138r3/audit138r3.py`, rc 0. Каждый свидетель строит собственную пачку; сначала запускается настоящий валидатор V, создающий свежие кадры, затем файл проверки Pr. V в каждом случае rc 0 с восемью `KADR … 1.000 0.600 G OK` и `SHABLON start-ekran OK`.

```text
WITNESS control Pr rc 0 stdout '' stderr ''
WITNESS r1-conditional Pr rc 1 stdout '' stderr 'PRICHINA\tFLOW_BEZ_DOPUSKA\tstart-ekran-f04-01\nPRICHINA\tFLOW_USLOVNYJ_SHAG\trunFlow:11\nPRICHINA\tFLOW_USLOVNYJ_SHAG\twhen:12\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:15\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:16\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:17\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:18\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:19\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:20\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:21\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:22\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:23\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:24\nPRICHINA\tFLOW_USLOVNYJ_SHAG\tvlozhennyj_shag:25\n'
WITNESS r1-foreign Pr rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
WITNESS r2-comment Pr rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
WITNESS r2-tests Pr rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
```

## Собственные мутации проверяющего (четыре)

M1–M3 запускаются `python3 /tmp/dev-harness-verify/Critic138r3/audit138r3.py` (rc 0 скрипта исследования), каждый мутант — отдельный файл, все 51 вход происхождения судятся настоящим `probe.judge`:

- M1: выключена ветвь блок-комментария, не весь лексер.
- M2: корень владельца подменён общим `mobile/src`, то есть обход через смежное дерево.
- M3: удалён фильтр каталогов, сохранён фильтр расширений/имён.

Сырой вывод всех несовпадений:

```text
MUTATION_REJECT M1-block-comments-visible proiskhozdenie-nositel-kommentarij-blok rc 0 stdout '' stderr ''
MUTATION_REJECT M1-block-comments-visible proiskhozdenie-nositel-kommentarij-blok-mnogostrochnyj rc 0 stdout '' stderr ''
MUTATION_REJECT M1-block-comments-visible proiskhozdenie-nositel-kommentarij-jsdoc rc 0 stdout '' stderr ''
MUTATION_REJECT M1-block-comments-visible proiskhozdenie-nositel-kommentarij-jsx rc 0 stdout '' stderr ''
MUTATION_REJECT M1-block-comments-visible proiskhozdenie-nositel-kommentarij-jsx-mnogostrochnyj rc 0 stdout '' stderr ''
MUTATION_SUMMARY M1-block-comments-visible tested 51 rejected 5 ALIVE False
MUTATION_REJECT M2-owner-alias proiskhozdenie-selektor-chuzhoj-drevo rc 0 stdout '' stderr ''
MUTATION_REJECT M2-owner-alias proiskhozdenie-dopusk-selektor-chuzhoj-drevo rc 0 stdout '' stderr ''
MUTATION_SUMMARY M2-owner-alias tested 51 rejected 2 ALIVE False
MUTATION_REJECT M3-place-directory-filter-removed proiskhozdenie-nositel-mesto-mocks rc 0 stdout '' stderr ''
MUTATION_SUMMARY M3-place-directory-filter-removed tested 51 rejected 1 ALIVE False
```

M4 запускается `python3 /tmp/dev-harness-verify/Critic138r3/closure138r3.py`, rc 0. Удалён ТОЛЬКО `__tests__` из `NE_EKRAN_KATALOGI`, остальное побайтово исходное. Изменённый текст подан через отдельную in-memory копию source в штатные `run_subject`/`judge`, контрактовые файлы не переписаны. Прогнаны ВСЕ 62 входа и ВСЕ 48 связей, не узкая выборка:

```text
M4_MODEL 62 / 62
M4_STABS_KILLED 48 / 48
M4_WITNESS Pr-mutant rc 0 stdout '' stderr ''
M4_WITNESS Pr-OBJECT rc 1 stdout '' stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
```

Это **живая собственная мутация**, в отличие от трёх убитых выше.

## Блокирующие находки

### B1 — H2, экранирование разделителя шаблонной строки

БЛОКИРУЕТ contracts/138-start-ekran.md:47 — инвариант «ВНЕ строкового литерала» и критерий H2 (`:55`) удовлетворяются при ложном носителе внутри обычного шаблонного литерала с экранированным бэктиком. `teksty/proverka_text.py:296-301` завершает шаблон на первом найденном бэктике, даже `\``; это не парный разделитель. После него текст шаблона считается кодом. Клетка `probe.py:735-740` проверяет только шаблон без экранирования. Это лексика H2, НЕ вложенный `${…}`, НЕ вычисление достижимости H4/H5 и НЕ новый класс вне решения.

ОБХОД: в дереве входа удалить единственный `<View testID="start_sostojanie_composer" />` из `mobile/src/features/start/testids.stand-in.tsx`, добавить только `mobile/src/features/start/fake.tsx` следующего содержания; flow, appId, кадры и проверку не менять:

```tsx
const x = `prefix \` <View testID="start_sostojanie_composer" /> suffix`;
```

Это валидный TSX/JavaScript, содержащий только строку, а не JSX-носитель. Команда построения и прогона — `python3 /tmp/dev-harness-verify/Critic138r3/audit138r3.py`, rc 0; сохранённое дерево — `/tmp/dev-harness-verify/Critic138r3/scratch/witness-escaped-backtick/`. Команды, реально запущенные последовательно:

```text
/usr/bin/python3 /tmp/dev-harness-verify/Critic138r3/repo/fixtures/workshop_project/ekran_shablon_132/model/ekran_shablon.py --pack /tmp/dev-harness-verify/Critic138r3/scratch/witness-escaped-backtick/pack --repo /tmp/dev-harness-verify/Critic138r3/scratch/witness-escaped-backtick/repo --harness /tmp/dev-harness-verify/Critic138r3/repo
rc 0
KADR	F04.01 dark	1.000	0.600	G	OK
KADR	F04.01 light	1.000	0.600	G	OK
KADR	F04.07 dark	1.000	0.600	G	OK
KADR	F04.07 light	1.000	0.600	G	OK
KADR	F04.08 dark	1.000	0.600	G	OK
KADR	F04.08 light	1.000	0.600	G	OK
KADR	F04.13 dark	1.000	0.600	G	OK
KADR	F04.13 light	1.000	0.600	G	OK
SHABLON	start-ekran	OK
stderr ''
/usr/bin/python3 /tmp/dev-harness-verify/Critic138r3/scratch/witness-escaped-backtick/pack/batareja/proverka_proiskhozdenija.py --pack /tmp/dev-harness-verify/Critic138r3/scratch/witness-escaped-backtick/pack --repo /tmp/dev-harness-verify/Critic138r3/scratch/witness-escaped-backtick/repo --harness /tmp/dev-harness-verify/Critic138r3/repo
rc 0
stdout ''
stderr ''
NODE_SYNTAX H2-escaped-backtick rc 0 stderr ''
TSX_SYNTAX scratch/witness-escaped-backtick/repo/mobile/src/features/start/fake.tsx OK
```

Последние два результата получены соответственно `node --check --input-type=module` с текстом на stdin и Babel parser с plugins `typescript,jsx` через `syntax138r3.cjs`. Ожидание отдельного статического барьера: rc 1 `SELEKTOR_BEZ_EKRANA start_sostojanie_composer`; фактически V=0 и Pr=0. Это не утверждение о зелёном настоящем Maestro: Android в этом круге не запускался. Блокирует обещание независимого лексического барьера ДО кода. Закрытие — красный вход H2 с экранированным разделителем до заморозки, не ослабление инварианта под лексер.

### B2 — H3, каталог замаскирован проверкой имени

БЛОКИРУЕТ contracts/138-start-ekran.md:54 — критерий 62/62 + 48/48 не отличает действующую защиту `__tests__` от её полного отсутствия. Клетка H3 `probe.py:743-746` кладёт носитель одновременно в запрещённый каталог И файл `.test.tsx`; фильтр имени сам краснит её, даже если каталог вообще не проверяется. Зелёный соседний контроль C этого не исправляет, потому что в нём честный носитель сохранён. Это класс H3 «каталог на любой глубине», не новая норма о достижимости.

ОБХОД: заменить в проверяющем `frozenset(('__tests__', '__mocks__', '__snapshots__'))` на `frozenset(('__mocks__', '__snapshots__'))`. Команда `python3 /tmp/dev-harness-verify/Critic138r3/closure138r3.py` → rc 0, **M4_MODEL 62/62 и M4_STABS_KILLED 48/48**, то есть объявленный красный критерий не отличает дефектную реализацию. При удалённом собственном composer и единственном носителе `export const f = () => <View testID="start_sostojanie_composer" />;` в `mobile/src/features/start/__tests__/helper.tsx` мутант даёт V=0, Pr=0; исходный OBJECT на том же дереве Pr=1. Штатная проверка на OBJECT сейчас каталог отсекает, но контрактная батарея не гарантирует сохранение этого свойства.

Точная живая команда свидетеля:

```text
/usr/bin/python3 /tmp/dev-harness-verify/Critic138r3/scratch/M4-test-directory-filter-removed.py --pack /tmp/dev-harness-verify/Critic138r3/scratch/witness-M4-tests-bare/pack --repo /tmp/dev-harness-verify/Critic138r3/scratch/witness-M4-tests-bare/repo --harness /tmp/dev-harness-verify/Critic138r3/repo
rc 0
stdout ''
stderr ''
/usr/bin/python3 /tmp/dev-harness-verify/Critic138r3/repo/fixtures/workshop_project/start_ekran_138/teksty/proverka_text.py --pack /tmp/dev-harness-verify/Critic138r3/scratch/witness-M4-tests-bare/pack --repo /tmp/dev-harness-verify/Critic138r3/scratch/witness-M4-tests-bare/repo --harness /tmp/dev-harness-verify/Critic138r3/repo
rc 1
stdout ''
stderr 'PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer\n'
```

Закрытие — независимый красный вход каталога с допустимым именем/расширением, например `__tests__/helper.tsx`, и соответствующая мутация до заморозки. Аналогичное совмещение причин у `__snapshots__/f.snap` видно в `probe.py:754-756`, но отдельную живую мутацию этого каталога я не выдаю за исполненную.

АРБИТР: роль `arbiter`; по РЕШЕНИЮ вопрос 4 пункт 3 возвращаю последний круг с конкретными строками таблицы **H2 «шаблонный литерал»** и **H3 «каталог __tests__»**. Предмет: неполнота закрытия лексического класса и выжившая мутация адресного класса при зелёном приёмочном критерии. Четвёртый круг критика не запрашивается. H4/H5 не пересуждаются.

## Советы и объявленные остатки (не основания FAIL)

СОВЕТ contracts/138-start-ekran.md:101 — строка H4/H5 не дословно равна строке арбитра: финальная точка заменена точкой с запятой. Весь остальной текст совпадает; строка лексического остатка `:102` совпадает полностью. Это не смысловой обход и не самостоятельный блокер.

```text
ARBITER_LITERAL - исполнимость носителя: статическа False FINAL_CHARS '.' ';'
ARBITER_LITERAL - лексер носителя — минимальный (ко True FINAL_CHARS '.' '.'
```

СОВЕТ contracts/138-start-ekran.md:102 — предписанный арбитром сброс одинарной/двойной строки на `\n` имеет не только названный ложный красный, но и зелёное следствие на валидном JavaScript line continuation. Свидетель `const x = 'prefix \\\n<View testID="start_sostojanie_composer" /> suffix';` проходит Node/Babel и V=0/Pr=0. Не превращаю это в новый запрет вопреки явному решению «строка обрывается на \n»; передаю арбитру как уточнение честно объявленного остатка. Вложенный бэктик `${…}` также остался зелёным, но прямо назван остатком в заголовке проверки и не используется для B1.

```text
LEX H2-string-continuation expected False found True
NODE_SYNTAX H2-string-continuation rc 0 stderr ''
WITNESS line-continuation Pr rc 0 stdout '' stderr ''
LEX H2-template-nested-residual expected False found True
NODE_SYNTAX H2-template-nested-residual rc 0 stderr ''
```

СОВЕТ contracts/138-start-ekran.md:53 — утверждение «стенд-ины — честный TSX» всё ещё слишком сильное: `#`/случайный `/**` устранены, но три файла содержат смежные JSX-элементы без общего контейнера, Babel TSX их отвергает. Лексический контроль этим не обойдён, поэтому отдельный FAIL на синтаксисе стенд-инов не ставлю.

```text
node /tmp/dev-harness-verify/Critic138r3/syntax138r3.cjs
rc 0
TSX_SYNTAX repo/fixtures/workshop_project/start_ekran_138/teksty/testids.stand-in.tsx ERROR Adjacent JSX elements must be wrapped in an enclosing tag. Did you want a JSX fragment <>...</>? (7:0)
TSX_SYNTAX repo/fixtures/workshop_project/start_ekran_138/teksty/testids_onboarding.stand-in.tsx ERROR Adjacent JSX elements must be wrapped in an enclosing tag. Did you want a JSX fragment <>...</>? (4:0)
TSX_SYNTAX repo/fixtures/workshop_project/start_ekran_138/teksty/testids_auth.stand-in.tsx OK
TSX_SYNTAX repo/fixtures/workshop_project/start_ekran_138/teksty/app_start.stand-in.tsx ERROR Adjacent JSX elements must be wrapped in an enclosing tag. Did you want a JSX fragment <>...</>? (5:0)
```

## Границы и нормы: итог обязательных пяти вопросов

1. **Критерий слабее предмета:** да, B1 — исходная модель пропускает H2; B2 — дефектная проверка H3 удовлетворяет всей батарее.
2. **Недоказуемое командой:** команды действительно запускаются и возвращают коды; зелень не подменяет доказательство полноты классов. Живой Maestro/визуальная приёмка нового экрана сейчас не заявлены как исполненные.
3. **Решение оставлено исполнителю:** достижимость не оставлена молча — H4/H5 явно отнесены к Maestro/ревью по решению арбитра. Найденные B1/B2 относятся к уже обещанным лексике/адресу, не к новому выбору реализации.
4. **Границы исполнения:** ЗОНА implementer ограничена `mobile/src/features/start/`, `mobile/.maestro/`, `mobile/e2e-start/`, `.github/workflows/mobile.yml`; механизм — зоны и объявленные пересечения. Live-чтение frozen-блобов 108/1, 995/1, 117/3, 118/1, 135/1 подтверждает прежних владельцев; `git diff --exit-code <frozen> HEAD -- contracts/<файл>` для каждого rc 0. Auth/app/mocks/api-client/tab-shell в зону 138 не добавлены. Деревья батарей 135/118/132 относительно базы трёх патчей не изменились (`UNCHANGED_FAMILY … rc 0 stdout ''`); соседние большие батареи заново не запускались, им не приписываю новый прогон.
5. **Норма AGENTS.md:** предметный блокер — именно живой обход, не вкус; риск и threat-model объявлены; счёт проверен второй мерой; precision/pre_critic зелёные. Правило 7 не использовано для требования частичного TSX-парсера: B1 требует только корректного экранирования разделителя, B2 — независимости адресной клетки. Новых блокирующих требований вне осей G/H и решения арбитра нет.
