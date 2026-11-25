FAIL
OBJECT=10f6ad777c95121d344198696679597409ac8a8a
СУД: репо=dev-harness; предмет=211; фаза=реализация; роль=reviewer; вызов=3 (узкий scoped; SANKCIJA консультанта); сессия=Rev211c; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev211c | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); автор Impl211f — implementer (MiniMax), Architect211l; предыдущий=archive/211/reviewer-v2-fail-12ea23adb1 (FAIL Б-1); адверсарий — правило остановки R-0074
КЛАСС=КОДОВЫЙ. Находки: блок 1 (Б-1, зона architect), советов 0. Чекбоксы — `.review/2026-11-25-rev211c-1.md`.

# Вердикт reviewer — 211, реализация, вызов 3 (узкий, носитель r10)

**БЛОКИРУЕТ: Б-1** — строка приёмки `--stabs` → rc 0 нарушена в чистом клоне origin на OBJECT. Пины четырёх production-слоёв стабов (`probe211.py:84-87`: `8c50b4c67`, `21aafbe4e`, `1a239b49a`, `bc303e9ae`) — коммиты ветки `wip/211/orchestrator-r9`. Этой ветки нет на origin, и OBJECT её коммиты не содержит. Итог: `--stabs` даёт `ORACLE_TAMPERED … нет pinned двери 8c50b4c67…`, **rc 2**. Перепин на предков OBJECT с теми же blob проверен в том же чистом клоне: rc 0, `SVJAZI 78 ZHIVYH 0`.

Блок лежит в дельте вызова 2→3: перепин С-5 сделан в `10f6ad777`. Нарушено обязательство контракта (§Приёмка, строки 61 и 74; шаг 2 последовательности — CI до ленда несёт `--stabs`). Состояние достижимо: чистый клон origin — это то, что делает CI (`actions/checkout`, `fetch-depth: 0`), и это же клон консультанта.

**СОВЕТ: 0**

**Б-1 вызова 2 закрыт в production.** `perechen_kontrakta_raven` (`scripts/zamok_predmeta.sh:890-897`) сравнивает отсортированные `LC_ALL=C` строки «%q имя sha» из `kontrakt_perechen` (`:881-889`). Mode в ключ не входит, тип и mode проверяются с обеих сторон. Своя мера — дифференциал против живой базы `1ec472715` на 35 мирах (§3): при честном классе «обычный» reviewer получает rc 0 `PUSCHEM` при mode-only chmod у любого файла (меньшего, большего, обоих, среднего из трёх). Изменение содержимого или класса даёт отказ байтами базы. Дельта production принята; блок — только в пинах батареи (зона architect).

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

## 0. Подготовка

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t7edac9438/m
git fetch ssh://…/dev-harness.git refs/heads/wip/211/orchestrator-r10 refs/heads/main refs/heads/archive/211/reviewer-v2-fail-12ea23adb1 → rc 0
git switch --detach 10f6ad777c95…; git rev-parse HEAD → 10f6ad777c95121d344198696679597409ac8a8a
теги '+refs/tags/*:refs/tags/*' → rc 0; git remote add origin … → rc 0
git rev-parse origin/main = git merge-base origin/main HEAD = 147e2b2b7fd143f397d86756980df09ccf39c85f
TMPDIR=/tmp/dev-harness-verify/scratch-rev211c (удалён перед докладом); чистый клон /tmp/dev-harness-verify/rev211c-chist (удалён)
```

## 1. Область правки

```
git diff --name-only 147e2b2b7 HEAD | wc -l → 74; вне fixtures/…/d52_bootstrap_sudej_211/ → 1 (scripts/zamok_predmeta.sh)
по коммиту (автор, файлов, вне зоны, scripts/):
  10f6ad777 architect   62 0 0     51665ada0 implementer 1 0 1
  104368f34 architect    4 0 0     07cd89297 implementer 1 0 1
  63dd01124 architect    7 0 0     23bdfb3ba implementer 1 0 1
  413af83a5 architect    9 0 0     5df7a3f63 architect  61 0 0
  5131664ec implementer  1 0 1     dc6f7e049 architect  60 0 0
  2ed80db09 implementer  1 0 1     528f30d11 implementer 1 0 1
git diff --shortstat c973670fa 104368f34 -- scripts/zamok_predmeta.sh fixtures/…/d52_bootstrap_sudej_211/ → пусто (r10 до ремонта = r8 по зоне)
git diff --stat 147e2b2b7 HEAD -- contracts registry .github roles → пусто
```
Implementer правил только `scripts/zamok_predmeta.sh`, architect — только свою пачку. Контракт, норма, реестры и CI не тронуты. Каждый круг — отдельный коммит. Строки `--stat c973670fa HEAD` вне зоны (`.omp/config.yml`, `contracts/221…`, `222…`, `ops/server`, `registry/contracts.tsv`, `verdicts/critic/…`) — это дрейф main: c973670fa не предок OBJECT, а `147e2b2b7..HEAD` по этим путям пуст.

Дельта production к вызову 2 (`git diff c973670fa HEAD -- scripts/zamok_predmeta.sh`, +27/−32). Сверено построчно:

| место | что | объявлено |
|---|---|---|
| `:868-880` | комментарий: сверка по отсортированным строкам «%q имя sha», mode вне ключа, причина Б-1 | да |
| `:881-889` | новая `kontrakt_perechen` — та же форма, что у модели (`model:686`): обычный тип/mode или rc 1, `printf '%q %s\n'` | да (Б-1; простая форма вердикта 2 §5) |
| `:890-897` | `perechen_kontrakta_raven`: попарный обход с fd 3/4 удалён; пустой O → rc 1; сравнение `LC_ALL=C sort` обоих перечней | да |

`kontrakt_zapisi` и `klass_riska` в дельте не менялись (порядок D52 и тай-брейк базы — как в вызове 2). Необъявленной семантики нет.

## 2. Сырой вывод — регресс (по одной, rc и числа)

`B=bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh`, cwd — корень копии, TMPDIR — scratch.

```
B --repo .        → SUBJEKT 211: KLETKI 59 KRASNYH 0                                   RC=0
B --model         → MODEL 211: KLETKI 59 KRASNYH 0                                     RC_model=0
B --sintaksis     → SINTAKSIS OK                                                       RC_sint=0
B --stabs         → MODEL 211: KLETKI 59 KRASNYH 0 / STABY 211: SVJAZI 78 ZHIVYH 0      RC_stabs=0   (копия, где есть локальная ветка r9 — см. Б-1)
B --sosed-208     → SUBJEKT 208: KLETKI 35 KRASNYH 0                                   RC_sosed=0
B --negativ-208   → NEGATIV 208: KLETKI 35 KRASNYH 2 (r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod) — режим --sosed-208 различает базу без verdikt_put   RC_neg=0
red_zamok_object_predok_208.sh --repo .   → SUBJEKT 208: KLETKI 35 KRASNYH 0           RC_208=0
red_obryv_167.sh --repo .                 → … MERGE registry_drop ok / partial ok / other_ref ok   RC_167=0
red_pre_judge_leak_185.sh --repo          → clean/dirty/local_fake/missing_harness/missing_harness_local_fake ZELENO   RC_185=0
red_architecture_process_187.sh --repo .  → CELLS=111 STABS=0 FAILURES=0               RC_187=0
red_odin_agent_140.sh --model             → MODEL_KLETKI 244 KRASNYH 0                 RC_140=0
run_battery.sh zamok_predmeta             → итог 4/4 классов закрыто                    RC_hyg=0
bash -n scripts/zamok_predmeta.sh                                                      RC_bashn=0
shellcheck 0.11.0 -S warning -f gcc: OBJECT — SC1090 :560, SC2034 :1285 (psv2/prol2/pobj2); база 1ec472715 — SC1090 :534, SC2034 :1115 (те же три); r8 — :560, :1290. Мест 2 = 2 → не хуже базы
```

**Чистый клон origin** (`git clone ssh://…/dev-harness.git /tmp/dev-harness-verify/rev211c-chist`, `checkout --detach 10f6ad777…`, status пуст, alternates нет):
```
git cat-file -e <пин>^{commit}: 8c50b4c67 rc=128, 21aafbe4e rc=128, 1a239b49a rc=128, bc303e9ae rc=128; 1ec472715/5131664ec/23bdfb3ba/07cd89297/51665ada0 rc=0
git merge-base --is-ancestor <пин> 10f6ad777 (в копии) → rc 1 у всех четырёх; git branch -r --contains <пин> → пусто; git ls-remote origin 'refs/heads/wip/211/*' → orchestrator-r9 нет
B --repo .   → SUBJEKT 211: KLETKI 59 KRASNYH 0                                     RC_repo_chist=0
B --stabs    → MODEL 211: KLETKI 59 KRASNYH 0
               ORACLE_TAMPERED: st58-T-bez-hvosta-frozen: нет pinned двери 8c50b4c67058595e879a79eac08c62a431f30f80: b"fatal: path 'scripts/zamok_predmeta.sh' exists on disk, but not in '8c50b4c67058595e879a79eac08c62a431f30f80'\n"
                                                                                     RC_stabs_chist=2   ← Б-1
repin.py (4 пина → 5131664ec…/23bdfb3ba…/07cd89297…/51665ada0…, тот же blob) → B --stabs → MODEL 211: KLETKI 59 KRASNYH 0 / STABY 211: SVJAZI 78 ZHIVYH 0   RC_stabs_repin=0
```

**Ворота.** Изолированно, по одной, в чистом клоне: `bash scripts/check_spec_ready.sh . contracts/211-d52-bootstrap-sudej.md` → `спек-гейт 036: проба превысила таймаут`, RC_spec=1, real 1m0.098s. Load до прогона `19.70, 20.20, 19.93`, после — `26.53, 22.10, 20.61`. Это таймаут пробы 60 с под нагрузкой станции, а не дефект предмета (наблюдение, не блок). `pre_critic` и `check_sdacha --run` не гонял: прогон ворот в чистом клоне присылает консультант. Дверь листа «Stabs» в чистом клоне красна по Б-1, поэтому `check_sdacha --run` на этом OBJECT в чистом клоне будет красным и без таймаута [INFERENCE: вывод из rc 2 двери, сам лист не прогонялся].

**Своя мера чисел, другой командой.** `jq '{KLETKI:(.kejsy|length),MUTACII:(.stab_vhod|length),SVJAZI:([.stab_vhod[]|length]|add)}' source.json` → 59/69/78. `find stabs -mindepth 1 -maxdepth 1 -type d | wc -l` → 69. Последние ключи клеток: b57, b58, b59. Заявленное (59/69/78) совпадает с фактом.

## 3. Закрытие Б-1 вызова 2 — своя мера

**Дифференциал** — `diff3.py`, текст и устройство в §7. Двери: база `1ec472715` (живой оракул), r8 `c973670fa` (красный контроль), OBJECT, модель OBJECT, мои мутанты m1–m4. Миры строятся строителями `probe211.py` (`Mir`, `kommit_vse`, `avtor_sdal`, `stancija_teg`, `stancija_stroka`, `sudit`, `vyzov`), вызов — reviewer `Rev211` без адверсария. Оракул: для mode-only миров (содержимое F = W) — база **с** REPLACE (D42 по закреплённому тегу). Для миров с изменённым содержимым или перечнем — база **без** REPLACE (промах, инв. 2). Субъект всегда без REPLACE, то есть идёт путём D64. Сравнивается тройка (rc, stdout, stderr) байтами.

```
мир                               chmod                 база+REPLACE                    OBJECT   model   r8      m1      m2      m3      m4
odin-chmod                        211-fixture.md        rc0 PUSCHEM                     =        =       =       ≠       =       =       =
odin-bez-chmod / dva-bez-chmod    —                     rc0 PUSCHEM                     =        =       =       =       =       =       =
dva-chmod-min                     211-fixture.md (мин)  rc0 PUSCHEM                     =        =       ≠rc1    ≠       =       ≠       =
dva-chmod-max                     211-zz.md (макс)      rc0 PUSCHEM                     =        =       =       ≠       =       =       =
dva-chmod-oba                     оба                   rc0 PUSCHEM                     =        =       =       ≠       =       =       =
tri-chmod-mid / -min / -min-max   средний / мин / мин+макс rc0 PUSCHEM                  =        =       ≠rc1    ≠       =       ≠       =   (r8 ≠ на mid/min/min-max)
karet-odin-chmod                  211-a^-b.md           rc1 neodnoznachno 211-a^-b.md   =        =       =       ≠       =       =       =
karet-dva-chmod-min / -max        мин / макс            rc1 neodnoznachno               =        =       ≠/=     ≠       =       ≠/=     =
kir/kav/bs/tab/lf-dva-chmod-min/-max  кириллица, ", \, TAB, LF  rc0 PUSCHEM             =        =       ≠ на min  ≠     =       ≠ на min =
kir-dva-bez-chmod                 —                     rc0 PUSCHEM                     =        =       =       =       =       =       =
simlink-chmod / -bez-chmod        файл / —              rc1 neodnoznachno 211-link.md   ≠*       ≠*      ≠*      ≠*      ≠*      ≠*      ≠*
dva-riskovyj-v-F-chmod-min        211-fixture.md        rc1 neodnoznachno 211-zz.md     ≠**      ≠**     ≠недост ≠       ≠**     ≠       ≠**
dva-riskovyj-v-F-chmod-max        211-zz.md             rc1 neodnoznachno 211-zz.md     =        =       =       ≠       =       =       =
--- изменено содержимое/перечень после F (оракул — база без REPLACE: rc1 «закреплённый frozen недоступен» + ADVERSARIJ_DO_REVJUERA) ---
dobavlen-riskovyj (+chmod)        — / fixture           (база+REPLACE rc0 PUSCHEM)      =        =       =       =       =       =       =
dva-klass-izmenen-chmod-min       мин                                                   =        =       =       =       ≠neodn  =       ≠neodn
dva-tekst-izmenen-chmod-min       мин                                                   =        =       =       =       ≠rc0!   =       ≠rc0!
dva-udalen / dva-dobavlen-obychnyj-chmod                                                =        =       =       =       =       =       =
dva-pereimenovan                  —                                                     =        =       =       =       ≠rc0!   =       =
odin-klass-izmenen                —                                                     =        =       =       =       ≠       =       ≠
ITOG: object RAVNO 32 RAZNOE 3 | model 32/3 | r8 22/13 | m1 11/24 | m2 28/7 | m3 22/13 | m4 29/6
```
Итог по мерам:
- **OBJECT** даёт rc 0 PUSCHEM на всех mode-only мирах с честным «обычный». Это 1, 2 и 3 файла, chmod у меньшего, большего, среднего, обоих и мин+макс, плюс кириллица, `"`, `\`, TAB, LF. На мирах с изменённым содержимым, классом или перечнем, включая добавленный второй файл с `КЛАСС РИСКА: рисковый`, OBJECT выдаёт отказ байтами базы. Мир `211-a^-b.md` даёт байты базы (neodnoznachno → отказ).
- **r8** — красный контроль: он воспроизводит Б-1 вызова 2 (13 расхождений, все — chmod у файла, который не идёт последним в mode-порядке).
- **\*** Симлинк. OBJECT, модель и r8 одинаково отказывают через «закреплённый frozen недоступен»: `kontrakt_perechen` симлинк не удостоверяет (D36). База+REPLACE отказывает через neodnoznachno `211-link.md`. rc 1 у обоих, исход не зависит от chmod. Это объявленный остаток симлинка, вне дельты (r8 тот же).
- **\*\*** `dva-riskovyj-v-F-chmod-min`: в F два файла с разными классами, chmod у меньшего sha. rc и stdout равны базе, отказ сохранён. Различается только имя файла в диагностике neodnoznachno: OBJECT называет `211-fixture.md`, база+REPLACE — `211-zz.md`. По инв. 1 класс читается из ДЕРЕВА OBJECT (`klass_riska <NNN> <r_wt> <obj_fakt>`), а в дереве OBJECT exec-бит ставит `211-fixture.md` после `211-zz.md`. База D42 читает дерево заморозки. Модель-эталон даёт те же байты, что OBJECT. Это следствие определения инв. 1, а не дефект дельты; наблюдение — в Остатках.

**Свои мутанты production.** Каждый — одна замена якоря кратности 1 в тексте OBJECT (`mk.py`, `bash -n` rc 0). Ни одна замена не совпадает с якорем st69. Прогон — штатный `B --repo <корень мутанта>`.

| мутант | замена | батарея rc / красные | дифференциал RAZNOE |
|---|---|---|---|
| m1 «mode в ключе» | `printf '%q %s\n' "$imya" "$sha"` → `printf '%q %s %s\n' "$imya" "$mode" "$sha"` | 1 / b34, b59 | 24 |
| m2 «сравнение только count» | сравнение `sort` → сравнение `wc -l` | 1 / b05 | 7 (из них 2 — rc 0 PUSCHEM при изменённом тексте/имени: класс занижается) |
| m3 «без sort» | → `[ "$spO" = "$spF" ]` | 1 / b59 | 13 |
| m4 «sha вне ключа» | → `printf '%q\n' "$imya"` | 1 / b05 | 6 (rc 0 PUSCHEM при изменённом тексте) |

Каждый мутант красится и батареей, и дифференциалом.

## 4. Не подогнаны ли проверки под код

- **b01–b58 не изменены.** `git diff c973670fa HEAD -- probe211.py`: удалены только три строки пинов, их упоминания в комментариях и `zametki`, а также якоря st03, st11 и st51. Эти якоря перенесены на новый предикат модели, смысл мутаций сохранён: st03 — `→ true`, st11 — без `-n`, st51 — без равенства. Ни одной строки тела клеток или ожиданий не удалено. Тексты стабов st58–st68 побайтно прежние (`git diff --stat c973670fa HEAD -- stabs/st58…|st64…|st68…` пусто).
- **b59 судит поведение, а не текст.** Живая база `1ec472715` запускается в kontrol-мире с теми же двумя файлами и REPLACE (D42). Её тройка сверяется с литералом (`D64_MODE_BASE_DRIFT`), и только потом этой тройкой судится субъект без REPLACE (D64). Независимый `ls-tree -z` подтверждает: mode изменился ровно у одного файла, имена и blob равны.
- **st69 краснеет ТОЛЬКО b59.** `st69_vse.py` прогоняет st69 против всех 59 клеток → `st69-W-poparno-po-mode: KLETOK 59 KRASNYH 1: b59-d64-dva-fajla-mode-menshego-sha; svjaz=['b59-d64-dva-fajla-mode-menshego-sha']`, RC=0. `git diff --no-index scripts/zamok_predmeta.sh stabs/st69…/zamok_predmeta.sh` — 1 hunk (+24/−6), то есть одна замена тела. Привязка задана кодом `STAB_VHOD` (Н-39).
- **Пины стабов — НЕ предки OBJECT** → Б-1. Blob у всех четырёх совпадает с предками OBJECT: `8c3d1b966` = `5131664ec`, `d1a66c35f` = `23bdfb3ba`, `65b3a8a8e` = `07cd89297`, `8539b8d4b` = `51665ada0` = OBJECT.
- **Implementer батарею не трогал, architect не трогал production** (§1).

## 5. Б-1 (этот вызов)

Фрагмент, состояние, сырой вывод и простая форма — в §2 (чистый клон) и `.review/2026-11-25-rev211c-1.md`. Механизм такой. Architect перепинил стабы на коммиты r9 (`SDACHA.md`: «База пачки — bc303e9ae»). Оркестратор собрал r10 cherry-pick'ом на main `147e2b2b7`. У коммитов r10 новые sha: `5131664ec`, `23bdfb3ba`, `07cd89297`, `51665ada0`. Пины на r9 устарели. r9 на origin не опубликован, поэтому в клоне origin пинов нет.

## 6. Соответствие контракту — только дельта ремонта

| инв. / строка | вывод |
|---|---|
| 1 (б3) | соответствует. Mode-only chmod не снимает удостоверение ни у какого файла: 1–3 файла, ASCII, `^-`, экзотика (§3). Подмена текста, класса или перечня различима |
| 2 (промах — прежнее поведение байтами) | соответствует: изменённое содержимое и перечень дают байты базы без REPLACE (§3) |
| 3 (класс не занижается) | соответствует. m2 и m4 занижали бы, OBJECT — нет (b05 зелена, дифференциал =) |
| 4–7 | дельта не трогает: регресс зелёный (§2) |
| 8 (регресс A2/208) | соседи зелёные (§2) |
| Приёмка `--stabs` → rc 0 | **нарушена в чистом клоне origin: rc 2 → Б-1** |

## Регресс

Числа — в §2. Все соседи зелёные и совпадают с вызовом 2, кроме роста батареи 211: 58→59 клеток, 68→69 стабов, 77→78 связей. shellcheck 2 = 2, `bash -n` rc 0. `--stabs` зелёный только при локальной ветке r9: в чистом клоне origin rc 2 (Б-1). Ворота: таймаут спек-гейта при load ≈ 20–26 (наблюдение).

## Остатки

- **ОСТАТОК «батарея — конечный набор; остаток — судьи» (контракт, НЕ ЗАЩИЩАЕТ; ловец adversary → reviewer) — не укусил в production.** Дифференциал на 35 мирах с 4 своими мутантами расхождений дельты не нашёл. Б-1 — дефект инструмента батареи (`probe211.py:84-87`), а не непокрытый вход двери.
- **ОСТАТОК «D52/critic строже базы» (экзотика) — не укусил.** На пути reviewer D64 экзотические имена (кириллица, `"`, `\`, TAB, LF) дают байты базы+REPLACE. У симлинка (D36) OBJECT отказывает через «закреплённый frozen недоступен», база — через neodnoznachno. Отказ сохранён, исход не зависит от chmod. Это остаток вне дельты: r8 даёт то же. Ловец — architect/reviewer при отдельной клетке.
- **Наблюдение (не находка):** диагностика `neodnoznachno` на D64 называет файлы в mode-порядке дерева OBJECT (мир `dva-riskovyj-v-F-chmod-min`). Так следует из инв. 1, модель даёт те же байты, отказ сохранён.
- **ОСТАТОК «граница risk_repo = носитель» (принята владельцем 23.11, арбитраж 2353d9e0b8 §4) — не укусил:** дельта выбор `risk_repo` не трогает.
- **ОСТАТОК «D52 читает профиль и legacy носителя» — не укусил:** b37 зелена.
- **ОСТАТОК «живость тега на origin» (ловец — оркестратор), «побайтовая форма учёта», «проектный реестр» (ловец — батареи [registry-profile])** — дельта их не касается.
- **С-1** (модель берёт вложенный ref `frozen/contracts/211/x/2` как версию). Модель в этой части не менялась, остаток назван в `SDACHA.md`. Ловец — отдельная клетка architect/reviewer. Не блок.
- **С-2/С-5** (пины вне истории OBJECT). Не закрыты: перепин ушёл на r9 и стал Б-1 этого вызова.
- **С-3** (тяжесть `perechen_kontrakta_raven`) закрыт: −32/+27, форма модели.
- **С-4** (шага CI 211 нет: `grep d52_bootstrap registry/ci-steps.tsv .github/workflows` → нет совпадений). Ловец — оркестратор, шаг 2 последовательности, после accept. Не блок. Подключённый шаг `--stabs` в CI на этом OBJECT дал бы rc 2 — это и есть Б-1.

## СВЕРКА-СТАНДАРТОВ

н/п: `AGENTS.md` станции документа архитектуры и стандарта кода не объявляет (`grep -c -E 'ARCHITECTURE|CODING-STANDARDS' AGENTS.md` → 0).

## СВЕРКА-АРХИТЕКТУРЫ

Размещение не изменилось: дверь в `scripts/`, батарея в своей пачке. Новых зависимостей, писателей и операций нет. Новый помощник `kontrakt_perechen` — внутренняя функция двери с единственным потребителем. `bindings.json` и `tooling/checks/cli.js` в дереве отсутствуют (`test -e` → rc 1). sourceCanon не объявлен, модель архитектуры пуста, уровень L не применим, `finding new` не заводил. Расширения долга production нет. Пин-слой батареи зависит от неопубликованной ветки — это Б-1.

## Паразитная сложность (050)

Ответы на (1) свойство / (2) состояние / (3) число файлов при правке свойства / (4) глубина / (5) потребитель:

- **`kontrakt_perechen` + новое тело `perechen_kontrakta_raven`** (production). (1) инв. 1 б3: имена и sha побайтно, mode вне ключа. (2) Состояния нет, поток строк в stdout. (3) 2 файла (дверь, модель) — как прежде. (4) 3 аргумента и rc, работа — канон перечня; интерфейс не вырос, тело меньше (−32/+27). (5) `frozen_udostoveren_objectu`; форма модели повторена намеренно (эталон семантики). **ESSENTIAL.**
- **b59 (`probe211.py`, +60).** (1) инв. 1 б3 на ≥2 файлах с mode-only. (2) kontrol-мир в `m.root`, явно. (3) 1. (4) одна клетка, внутренний разбор `ls-tree -z` — независимый оракул мира. (5) `--repo`, `--stabs` (st69). **ESSENTIAL.**
- **st69 + `BAZA_PRODUCTION_211F` + `PRODUCTION_STABY_211F` + ветвь `tekst_staba`.** (1) К-08: стаб на Б-1 вызова 2. (2) Внешний git-объект-пин — неявное состояние, сейчас недостижимое из origin → Б-1. (3) 3 файла (`probe211.py`, `source.json`, `stabs/`), их связывает генератор. (4) четвёртый пин-слой. (5) `--stabs`. **ESSENTIAL**; пин — Б-1, простая форма проверена (§2).
- **`source.json` ключи `baza_production_stabov_211e/211f`.** (1) Документирование пинов. (2) Нет. (3) Генерируются. (4) —. (5) `main()` их не читает, потребитель — читатель-человек. Нейтрально, не находка.

## Что чинить

1. Architect (или оркестратор пересборкой носителя так, чтобы пины оказались предками): заменить 4 пина в `probe211.py:84-87` на `5131664ec3cad043489ec6b3923c1e8a6716c559`, `23bdfb3ba26de5d4c880c734aa5f65d7bf6254b1`, `07cd89297dbd4b8d96efc044289d7a65b3f9d2dd`, `51665ada0935c0d4bbacc46b03cc57e1fa5d295c` (blob те же). Поправить заголовок `probe211.py:15-17`, `source.json` (`--sgeneriruj-staby`) и фразы `SDACHA.md` («is-ancestor rc 0», «С-2/С-5 закрыты»). Production не трогать.
2. Проверка закрытия: `--stabs` rc 0 в чистом `git clone` origin на новом OBJECT.

## НЕ ЗАЩИЩАЕТ (этот вердикт)

- Мутационный поиск адверсария не повторялся. Мутанты m1–m4 нужны только для красного своей мерой.
- `check_zones.sh` целиком не гонялся: зона сверена по автору и путям каждого коммита.
- `pre_critic`/`check_sdacha --run` не гонялись (прогон в чистом клоне — у консультанта). `check_spec_ready` — таймаут под нагрузкой.
- Живую станцию и настоящее состояние замка не трогал: все прогоны шли в одноразовых мирах под TMPDIR и в одноразовом клоне.
- Мобильного экрана в предмете нет. Запись СУД в HANDOFF дописывает оркестратор.

## 7. Генераторы своей меры (тексты в scratch, scratch удалён)

- `mk.py <корень> <dveri>` — пишет `dveri/<имя>/scripts/zamok_predmeta.sh` для `git show <sha>:…`: база `1ec472715`, r8 `c973670fa`, OBJECT, модель OBJECT. Мутанты m1–m4 — одна замена якоря кратности 1 (`assert count == 1`) в тексте OBJECT.
- `diff3.py <корень> <dveri> base=… object=… model=… r8=… m1=… m2=… m3=… m4=…` — импортирует `probe211` и использует его строителей и `sudit`. Мир: носитель `wt211` на ветке `wip/211/impl`, файлы `contracts/<имя>` (текст `kontrakt_tekst`, симлинк — `os.symlink`), коммит F. Затем chmod 755 по порядку blob-sha в F (`min`/`max`/`mid`/`all`/имя), правки W (запись, удаление, переименование) и коммит W. Далее `avtor_sdal`, `stancija_teg(F)` и — только у оракула mode-миров — `stancija_stroka` (REPLACE). Вызов reviewer `Rev211` на W. Каждый прогон идёт в своём `Mir` под TMPDIR. 35 миров, полный вывод — в §3.
- `st69_vse.py <корень> <стаб>…` — текст стаба по `STAB_MUTACII`/`tekst_staba` и `prognot_kletku` по всем клеткам `kejsy()`.
- `repin.py <probe211.py>` — 4 замены строк-пинов (`assert count == 1`), только в одноразовом чистом клоне.
