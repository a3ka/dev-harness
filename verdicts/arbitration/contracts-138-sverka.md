accept
OBJECT=ef9c646df52baea37ee788014fe506ee3f7e6092

# Сверка исполнения РЕШЕНИЯ 138-2 (контракт 138) start-ekran — закрытый перечень пп.1–6: исполнено; блокеров нет; четыре совета вне перечня

Дата: 2026-10-25. Роль: arbiter (Arbiter138c), модель anthropic/claude-fable-5-1 (НЕ модель автора — architect GLM); свежий контекст, переписка сторон не наследована. Это сверка исполнения собственного решения `contracts-138-arbitraz-2.md` (п.3 порядка), не круг критика: первая строка вердикта критика не меняется, счётчик кругов `freeze_contract.sh:404-417` не трогается.

Клон арбитра: `/tmp/dev-harness-verify/Arbiter138c/repo` (SSH `ssh://git@github.com/a3ka/dev-harness.git`, ветка `wip/138/arbiter-c` = `e56edc322` + `git am` патчей `Architect138/patches4/0001..0004`, hooks отключены `core.hooksPath=…/nohooks`); `HEAD^{tree}` = `61b63254fb78a29b8d9b4a1addb29da3038b7962` = `ef9c646d^{tree}` в клоне автора — предмет тот же побайтово. Все 24 файла дельты `7c22be4d..HEAD` — внутри зоны architect (`contracts/138-start-ekran.md`, `fixtures/workshop_project/start_ekran_138/**`); семьи 135/118/132 не тронуты (`git diff --exit-code` rc 0 ×3). Инструменты арбитра — `Arbiter138c/scratch/arb138c.py` (свидетели, таблица форм на лексере OBJECT, 14 мутантов × 57 входов через штатные `probe.run_subject`/`judge` — независимое воспроизведение, не инструмент автора), `sweep138c.py` (замер E: лексер OBJECT против лексера 7c22be4d на продукте), `tsx138c.cjs` (Babel), `dts138c.cjs` (семантика `.d.tsx`), `kontrakt138c.py` (текст контракта ↔ решения), адаптации свидетелей критика `audit138r3c.py`/`closure138r3c.py` (переписаны только пути). За пределы `Arbiter138c/**` ничего не записано.

## Замеры (сырые)

### п.5 Регрессы — батарея (клон арбитра, `fixtures/workshop_project/start_ekran_138`)

```text
python3 probe.py --model                 rc 0   68 × CASE … ok                                     3.7 с
python3 probe.py --stabs                 rc 0   контроль 68/68 ok, 51 × STAB … KRASEN, SVJAZI 51, живых 0   10.6 с
bash red_start_ekran_138.sh (безфлаговый) rc 1   11 ok + 57 KRASNO (происхождение судит второй субъект)      50.9 с
копия без субъекта (closure138r3c)        rc 1   SHABLON_ABSENT + 68 × KRASNO (SHABLON_ABSENT)
bash scripts/pre_critic.sh contracts/138-start-ekran.md           rc 0  «КРИТИК: дверь зелёная»
bash scripts/check_precision_gate.sh . contracts/138-start-ekran.md rc 0  OK
135 red_first_run_ekran_135.sh --stabs    rc 0   SVJAZI 13   18.6 с
118 red_erstinformation_118.sh --stabs    rc 0   SVJAZI 37   58.3 с
132 red_ekran_shablon_132.sh --stabs      rc 0   SVJAZI 38   84.3 с (передний план, < 880 с)
```

Числа source.json (замер, не проза): kejsy 68 (11 зелёных / 57 красных), stab_vhod 30 стабов, связей 51 (27 прежних s01–s47 + 24 новых s51–s64), proverka-входов 57, носителей 16, кадров 8. Контракт пачки `kontrakt_tekst`: 60 строк / 108 символов / 3998 байт (≤ 60/120/4000; синхронен с `teksty/kontrakt_tekst.md`). Ожидания прежних 62 клеток относительно 7c22be4d изменены только у `kontrakt-slishkom-dlinnyj`/`kontrakt-shirokij` (байт 5283→5298, 16884→16899 — следствие +15 байт текста пачки, числа из `--snapshot`); остальные 60 — побайтово те же; формы `-stroka-dvojnaja-ekranirovannaja`, `-mesto-tests`, `-mesto-snapshots` заменены по таблице решения при тех же ожиданиях. Стабы s01–s47 без изменений; s49/s50 удалены; ЗОНА/ПЕРЕСЕЧЕНИЕ не изменены; ПРОВОДКА (`guard=`) не изменена, ПРОВОДКА-ЭНФОРСМЕНТ — только числа 54→57 входов, 48→51 связей, 18→30 стабов (осмысленно).

`bash scripts/check_provodka.sh . contracts/138-start-ekran.md` → rc 1 «guard не подключён: …red_start_ekran_138.sh не вызывается в .githooks/ или .github/workflows/». Тот же rc 1 на 7c22be4d (worktree `Arbiter138c/wt7c`) — состояние не изменено кругом 4 и не входит в A–H; подключение guard — строка `registry/ci-steps.tsv` вне зоны architect, интеграционный коммит оркестратора (образец 135: `ci-steps.tsv:183,188`), что и записано в ПРОВОДКА-ЭНФОРСМЕНТ контракта. ОБХОД проверен: worktree HEAD + строка `step	check:start-ekran-138-family-selftest	22	bash fixtures/workshop_project/start_ekran_138/red_start_ekran_138.sh --stabs` в `registry/ci-steps.tsv` → `check_provodka.sh` rc 0. Не блокер исполнения решения; к ленду — строка оркестратора.

### п.1 Таблица форма → клетка → защита → стаб (проверено по коду и прогоном)

Привязки — `source.json.stab_vhod` (по коду, Н-39; `pre_critic` рука (в) rc 0; собственный скан контракта на «стаб+глагол» — 0 связок). Каждый стаб s51–s64 импортирует честный `teksty/proverka_text.py` через `importlib`, подменяет РОВНО одну защиту (`kod_maska` копией без одной ветви/правила — s51–s57; `NE_EKRAN_KATALOGI`/`NE_EKRAN_IMENA`/`ekran_kod` — s58–s64) и зовёт честный `main()`; копий 384 строк нет. Колонка «мутант» — `arb138c.py` §3: мутация `proverka_tekst` «минус одна защита» × все 57 входов `subekt=proverka`; `red` — клетки, которые краснеют (= клетки, которые этот стаб и только он делает зелёными в `--stabs`).

| ось | форма входа (клетка) | защита | стаб | stab_vhod | MUTANT «минус защита» |
|---|---|---|---|---|---|
| H1 | `-kommentarij-hvost`, `-kommentarij-stroka`, `-selektor-nositel-v-kommentarii` | ветвь `//` | s51_bez_kommentarija_stroka | 3 | KILLED red те же 3 |
| H1 | `-kommentarij-blok`, `-blok-mnogostrochnyj`, `-jsdoc`, `-jsx`, `-jsx-mnogostrochnyj` | ветвь `/* */` | s52_bez_kommentarija_blok | 5 | KILLED red те же 5 |
| H2 | `-stroka-odinarnaja`, `-selektor-nositel-v-stroke` | ветвь кавычек | s53_bez_stroki | 2 | KILLED red 4 (+ `-dvojnaja-ekranirovannaja`, `-prodolzhenie`: ветвь целиком — надмножество, допустимо) |
| H2 | `-stroka-dvojnaja-ekranirovannaja` = `"say \" testID='…' x"` (форма заменена) | `\`-экранирование в кавычках | s54_bez_ekrana_v_stroke | 1 | KILLED red [`-dvojnaja-ekranirovannaja`, `-prodolzhenie`] |
| H2 | `-stroka-prodolzhenie` = `'prefix \`⏎`<View…/> suffix'` (новая) | `\`+`\n` — продолжение | s55_bez_prodolzhenija_stroki | 1 | KILLED red [`-prodolzhenie`] — ровно одна |
| H2 | `-stroka-shablon` (многострочный бэктик) | ветвь бэктика | s56_bez_shablona | 1 | KILLED red 3 (+ две ekran-клетки: ветвь целиком) |
| H2 | `-stroka-shablon-ekran-backtick` = `` `prefix \` <View…/> suffix` `` (свидетель критика B1), `-stroka-shablon-ekran-bekslesh` = `` `a\\\` <View…/> ` `` (новые) | `\`-экранирование в шаблоне | s57_bez_ekrana_v_shablone | 2 | KILLED red те же 2 |
| H3 | `-mesto-tests` = `__tests__/helper.tsx` (форма заменена; имя без меток) | `__tests__` | s58_bez_kataloga_tests | 1 | KILLED red [`-mesto-tests`] — блокер B2 закрыт |
| H3 | `-mesto-mocks` = `__mocks__/f.tsx` | `__mocks__` | s59_bez_kataloga_mocks | 1 | KILLED red [`-mesto-mocks`] |
| H3 | `-mesto-snapshots` = `__snapshots__/f.tsx` (форма заменена; было `.snap` — три причины) | `__snapshots__` | s60_bez_kataloga_snapshots | 1 | KILLED red [`-mesto-snapshots`] |
| H3 | `-mesto-test-fajl` / `-mesto-spec-fajl` / `-mesto-stories` | `.test.` / `.spec.` / `.stories.` | s61 / s62 / s63 | 1/1/1 | KILLED ×3, каждый — ровно своя клетка |
| H3 | `-mesto-d-ts` (`f.d.ts`), `-mesto-snap` (`f.snap`), `-mesto-ne-kod` (`f.md`) | белый список `RASSHIRENIJA_KODA` (`.d.ts`/`.snap` из `NE_EKRAN_IMENA` удалены) | s64_bez_rasshirenij | 3 | KILLED red те же 3 |
| C | `-chestnyj-shablon-bekslesh` (`` `a\\`; ``), `-chestnyj-stroka-bekslesh` (`"a\\";`), `-chestnyj-shablon-podstanovka` (`` `n=${1}`; ``) — новые, rc 0 | ложный красный недопустим | — | — | `--model` ok ×3 |
| C | `-chestnyj-ternar`, `-jsx-kommentarij-rjadom`, `-apostrof-drugaja-stroka`, `-fajl-rjadom-s-testom`, `-probely`, `-v-oboih`, `chistyj` | как есть | — | — | `--model` ok ×7 |

```text
PROVERKA_CASES 57 of 68
MUTANT H1-minus-//            KILLED   MUTANT H2-minus-ekran-v-shablone KILLED   MUTANT H3-minus-.test.      KILLED
MUTANT H1-minus-/*            KILLED   MUTANT H3-minus-__tests__        KILLED   MUTANT H3-minus-.spec.      KILLED
MUTANT H2-minus-kavychki      KILLED   MUTANT H3-minus-__mocks__        KILLED   MUTANT H3-minus-.stories.   KILLED
MUTANT H2-minus-ekran-v-stroke KILLED  MUTANT H3-minus-__snapshots__    KILLED   MUTANT H3-minus-rasshirenija KILLED
MUTANT H2-minus-prodolzhenie  KILLED   MUTANT H2-minus-backtick         KILLED
MUTANTS 14 ALIVE 0
```

Пять живых мутантов решения 138-2 (`__tests__`, `__snapshots__`, `.d.ts`, `.snap`, `\` в кавычках) — закрыты: три клеткой с одной причиной, два удалением мёртвой защиты. Каждая форма H2/H3 таблицы решения имеет клетку; каждая из 14 защит — свой стаб с ≥1 связью и мутант, убиваемый ровно своими клетками (для ветвей кавычек/бэктика — надмножеством клеток той же ветви, что и требовалось: ветвь целиком включает свои правила).

### п.2 Свидетели критика кр.3 и арбитра на принятом дереве (`arb138c.py` §1, `audit138r3c.py`, `closure138r3c.py`; V — эталон 132, Pr — `teksty/proverka_text.py` OBJECT)

```text
WITNESS H2-escaped-backtick   Pr rc 1 ['PRICHINA\tSELEKTOR_BEZ_EKRANA\tstart_sostojanie_composer']   (кр.3: было rc 0 — закрыт)
WITNESS H2-bekslesh-backtick  Pr rc 1 SELEKTOR_BEZ_EKRANA
WITNESS H2-line-continuation  Pr rc 1 SELEKTOR_BEZ_EKRANA
WITNESS H2-dvoj-ekran-kavychka Pr rc 1 SELEKTOR_BEZ_EKRANA
WITNESS H3-tests-helper       Pr rc 1 SELEKTOR_BEZ_EKRANA;  Pr-M4 (минус __tests__) rc 0 → мутант различим входом
WITNESS H3-snapshots-tsx      Pr rc 1 SELEKTOR_BEZ_EKRANA
critic audit138r3 (пути → клон арбитра): WITNESS escaped-backtick Pr rc 1; line-continuation Pr rc 1; r2-tests Pr rc 1; r2-comment rc 1; r1-foreign rc 1; r1-conditional rc 1 FLOW_USLOVNYJ_SHAG…; control V rc 0 / Pr rc 0
critic LEX: все H1/H2/H3-ожидания критика совпали, кроме трёх названных остатков/отступлений: H2-template-nested-residual (остаток `${…}`), C-apostrophe-same-line-residual (остаток решения 138), H3-fake.d.tsx (п.4 ниже)
critic MUTATION M1 (/* */) rejected 5 / M2 (owner alias) 2 / M3 (все каталоги) 3 — ALIVE False ×3
critic closure M4 (минус __tests__): M4_MODEL 67/68 — красна ТОЛЬКО proiskhozdenie-nositel-mesto-tests; M4_STABS_KILLED 51/51 (тривиально, как и записано в решении); M4_WITNESS Pr-OBJECT rc 1 / Pr-mutant rc 0
```

### п.3 Требования A–H

- **A** (лексер, `proverka_text.py:266-317`): ветвь кавычек — `\` экранирует следующий символ, в т.ч. `\n` (`i += 2`), обрыв на парной кавычке либо неэкранированном `\n`; ветвь бэктика — `\` экранирует следующий, закрытие только на неэкранированном бэктике, многострочно; `${` не разбирается (нет ветви). `NE_EKRAN_IMENA = ('.test.', '.spec.', '.stories.')`, `NE_EKRAN_KATALOGI` = три каталога, `RASSHIRENIJA_KODA = ('.tsx', '.jsx', '.js')`. Шапка п.5 (`:27-40`) — текст решения A по смыслу дословно (строка обрывается на неэкранированном \n; `\`+перевод — продолжение; апостроф JSX-текста — обход носитель своей строкой; `\` экранирует следующий символ в строках и шаблонах; ${…} не разбирается — носитель внутри ложный красный, вложенный бэктик — остаток). Таблица форм на лексере OBJECT (`arb138c.py` §2): 14 форм с ожиданием — `LEX_MISMATCH 0` (7 красных форм H2 → носитель не виден; 5 честных C → виден; `{false && …}` и `if (false)` → виден: **H** — лексер не вычисляет `&&`/`?:`/`if`/константы/достижимость, в коде нет ни одной такой ветви).
- **B**: четыре новые красные клетки H2 + две заменённые формы H3 + три зелёных контроля C — присутствуют (`probe.py:745-786, 858-884`), все в `MUTACII`; правило конструкции записано комментарием над блоком H (`probe.py:650-653`): «каждая красная клетка H краснеет по ОДНОЙ защите; форма с двумя причинами — не клетка». Зелёные контроли C — прежние четыре и три новых — `--model` ok, свидетели C-* `arb138c.py` §1b rc 0 ×5.
- **C**: 14 стабов по образцу (импорт честного файла, подмена ровно одной защиты, честный `main()`); `SVJAZI 51` = 27 + 24 из прогона.
- **D**: 14 KILLED — выше, независимым инструментом.
- **E** (`sweep138c.py`, продукт `/tmp/dev-harness-verify/Impl118g/mob`, лексер OBJECT против лексера 7c22be4d): `SWEEP scanned 22 unique 80 occurrences 82 files 10 diffs 0 mask_diffs 0 line_continuations 0 backticks 124 escaped_backticks 0`; `EKRAN_KOD_DIFFS 0` — удаление `.d.ts`/`.snap` из `NE_EKRAN_IMENA` на продукте нейтрально (два `.d.ts` файла продукта отсекаются расширением `.ts`). Критик-метод (`audit138r3c`): `PRODUCT 82 LITERALS 10 FILES DIFFS 0 LINE_MISMATCHES 0`, `VLADELTCY 14/14 FOUND 8`.
- **F** (`tsx138c.cjs`, Babel `typescript,jsx` из node_modules продукта): `TSX_STANDIN` ×4 OK; `TSX_FORM` ×8 OK (3 новые красные H2 + заменённая `dvojnaja-ekranirovannaja` + `__tests__/helper.tsx` + 3 контроля C). Стенд-ины обёрнуты `<>…</>` (diff `+<>`/`+</>` в трёх файлах).
- **G** (`kontrakt138c.py`): строка лексера §НЕ ЗАЩИЩАЕТ — `D2_LITERAL … EXACT True` (дословно строка решения 138-2); строка H4/H5 — `D1_LITERAL '- исполнимость носителя…' EXACT True FINAL '.' '.'` (дословно решению 138-1, финальная точка). Критерий 3 — «14 стабов-на-защиту … выключаются СВОИМ стабом и краснят свою клетку — по одной защите на клетку; s49/s50 удалены (поглощены 14)»; критерий 2 — новые клетки/контроли перечислены (`:53`); критерий 4 — ожидания новых клеток (`:55`); §ЗАЩИЩАЕТ «от селектора чужого экрана» дополнен «…клетки на все формы таблицы оси H, по одной защите на клетку: стаб-на-защиту» (`:98`); меры входов `kontrakt-slishkom-dlinnyj`/`-shirokij` пересчитаны (100/5298; 61+6900/16899) и совпадают со snapshot.
- **H**: `.TSX`, `tests/`, `e2e/`, `fixtures/` в алфавит не добавлены (критик-LEX: `PATH-outside-alphabet-*` found True — сканируются как код, по решению).

### п.4 Отступление автора (1): `fake.d.tsx` → найден как носитель (critic LEX expected False found True)

Замер: `NE_EKRAN_IMENA` на 7c22be4d содержала `'.d.ts'`, и `'.d.ts' in 'fake.d.tsx'` — истина ПОДСТРОКОЙ: файл исключался побочно, не замыслом (замысел метки по докстрингу OBJECT: «описания типов — не экранной код (.ts вообще не JSX)»). TypeScript 6.0.3 продукта: `ts.isDeclarationFileName('a.d.tsx') → false` (`a.d.ts`, `a.d.mts`, `a.d.css.ts` → true); Babel разбирает `fake.d.tsx` с JSX как обычный модуль (`BABEL fake.d.tsx OK`); metro резолвит `.tsx` по расширению. То есть `fake.d.tsx` — ОБЫЧНЫЙ модуль кода экрана с любым именем: если он смонтирован, его `testID` — честный носитель, и красный на нём был бы ложным; если не смонтирован — это класс H4/H5 (недостижимый узел в файле кода, что `fake.tsx`, что `fake.d.tsx`), остаток §НЕ ЗАЩИЩАЕТ с ловцом Maestro `assertVisible` → `FLOW_BEZ_DOSTIZHENIJA`/`E2E_NE_PROSHLA` + ревью, принятый владельцем 2026-10-25 ~15:45.

Решение сверки: **не дефект исполнения**. Алфавит места решения 138-2 замкнут (`.test.`/`.spec.`/`.stories.` + три каталога + белый список расширений), автор исполнил A дословно и правильно НЕ расширил алфавит; «`.d.`» как метка имени для `.tsx` не имеет семантики ни в TS, ни в metro — добавлять её было бы новым классом по прозе, а не по инструменту. Отступление (1) принимается как исполнение решения; остаток — тот же H4/H5, новым не является. Совет — ниже.

### п.6 Остаток как заявлено

§НЕ ЗАЩИЩАЕТ `:101` (H4/H5, дословно решению 138-1: ловец — Maestro `assertVisible` → `FLOW_BEZ_DOSTIZHENIJA`, неотрисованный узел → `E2E_NE_PROSHLA`, второй ловец — ревью) и `:102` (лексер/`${…}`, дословно решению 138-2). `probe.py:653` — «достижимость H4/H5 — остаток §НЕ ЗАЩИЩАЕТ, ловец — живой Maestro». Критик-LEX `H2-template-nested-residual` found True — названный остаток «вложенный бэктик в `${…}` сдвигает пары», на продукте 0 экранированных бэктиков и 0 продолжений строки (замер E).

## Блокеры по закрытому перечню пп.1–5

Нет.

## Советы (вне перечня; исполнения решения не касаются, FAIL не образуют)

1. `contracts/138-start-ekran.md:3`: `` `id/ConTRACT/138` `` — опечатка круга 4 (на 7c22be4d было `id/CONTRACT/138`). Ни один механизм прозу не читает (`check_precision_gate.sh:311`, `check_zones.sh:1099+` берут тег из git; pre_critic/precision rc 0), но имя тега в шапке контракта обязано совпадать с тегом. Исправить в ближайшем коммите автора (одна строка, зона architect).
2. `check_provodka.sh` rc 1 до ленда — состояние с v1, не круга 4; закрывается строкой оркестратора в `registry/ci-steps.tsv` (команда и rc 0 замерены выше). К моменту freeze — проверить rc 0 на дереве с подключением.
3. `.d.tsx` (п.4): по желанию автора — одна фраза в докстринге `ekran_kod` или в §НЕ ЗАЩИЩАЕТ: «метка `.d.` в имени `.tsx`/`.jsx`/`.js` — обычный модуль (TS: не declaration file), судится как код; недостижимость — H4/H5». Алфавит НЕ расширять.
4. Строка лексера §НЕ ЗАЩИЩАЕТ (моего решения, воспроизведена дословно) обобщает «всё это — ложный `SELEKTOR_BEZ_EKRANA`»; для случая «вложенный бэктик в `${…}` сдвигает пары» исход может быть и ложным ЗЕЛЁНЫМ (носитель внутри вложенного шаблона виден как код — критик-LEX `H2-template-nested-residual`); ловец тот же — Maestro `assertVisible` строкой `:101`. Уточнение формулировки — в v+1 текста, не сейчас: это неточность решения, не исполнения.

## Порядок дальше

Сверка арбитра — `accept` по закрытому перечню; она НЕ заменяет вердикт критика: механизм заморозки (`freeze_contract.sh` §6) требует `verdicts/critic/contracts-138-v1.md` первой строкой `accept`. Узкий accept-вызов критика по закрытому перечню этого вердикта — четвёртое событие критика по предмету — **только словом владельца** (правило 12; вопрос 1 решения 138-2, рекомендация — вариант Б). Без слова владельца путь к freeze 138 закрыт; автору до того — совет 1 (опечатка) одной строкой, оркестратору — проводка (совет 2) интеграционным коммитом.

## Счёт по сторонам (сигнал, не доказательство)

Спорных пунктов между сторонами в сверке нет: единственное разногласие — ожидание критика `fake.d.tsx → False` против исполнения автора — решено замером семантики (`ts.isDeclarationFileName`) в пользу автора; это замер, не доверие. Советы 1 и 4 — против автора и против собственного решения соответственно.
