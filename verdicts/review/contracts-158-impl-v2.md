FAIL

OBJECT=f8134ed4dadb5168232f131140ecd0fab5a73c83
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; ТРЕК набора: ПОЛНЫЙ)
СУД: repo=dev-harness (контракт frozen/contracts/158/2 → 60ed70d4); предмет=158; фаза=реализация (scoped-исправительный); роль=reviewer; сессия=Rev158r5; модель-план=@opus (config/agent_models.json roles.reviewer → tiers.audit) = anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; вызов=4 (прежние: Reviewer158Scoped, Reviewer158Fresh, Reviewer158Opus3 FAIL @a77f3d11)
НЕЗАВИСИМОСТЬ: автор — implementer (identity implementer, все 10 коммитов кандидата); адверсарий r2 accept @a77f3d11, повторно не звался (бюджет 2/2, класс обычный); судья — reviewer, правок кода не вносил.
НАХОДКИ: .review/2026-11-09-91.md — блоки implementer Б-5, Б-6; условие У-3 (оркестратор); советы С-7…С-11, С-1 (повтор). Статус прошлого круга: Б-1, Б-2, Б-4 закрыты; Б-3 не закрыт (продолжение — Б-5).

## Вердикт

FAIL. Блокирующих находок две, обе у implementer:

- **Б-5** (норма роли, п.5 «Атомарность»; незакрытый Б-3 круга 3). Связка-коммит `2ea0e47d`
  («четыре блока ревью 158 (Б-1…Б-4) + гейт трека и нога (д3)», 7 файлов, +292/−66) — тот же
  патч, что `8b83d383`: `git patch-id --stable` у `8b83d383`, `7946021f` (r4) и `2ea0e47d` (r5)
  один, `a8566d300bc32166`. Перенос cherry-pick'ом сохранил связку дословно. Заявление «девять
  коммитов закрывают Б-1…Б-4» для Б-3 неверно.
- **Б-6** (контракт 158/2 п.2; SPEC §1, §10 п.2). `W --repo /tmp/dev-harness-verify/Arch148t/mob-ref`
  → rc 1, клеток 74, красных 27 (своя мера ниже). Строка приёмки требует rc 0 на ОБОИХ
  референсах. **Ответ на вопрос задания о находке 2 отчёта implementer:** да, frozen 158/2 п.2
  и SPEC §10 п.2 требуют `W --repo <R>` rc 0 на ref-clean и на mob-ref. Это дефект РЕАЛИЗАЦИИ
  (адресат — implementer), а не текста SPEC или контракта. SPEC §6F сам задаёт входы красных
  клеток: f03–f05 — «одноразовые reflink-копии ref-clean» с картой «ПОБАЙТОВО
  model/karta-ref-clean.json», f06–f08 — «одна копия живого ref-clean R». Путь ref-clean —
  §4 `istochnik` и `REFERENSI[0]` батареи. Образцы f10–f33 и c05 — «reflink-копия референса»
  без привязки к R; якоря мутаторов — изделие implementer. Реализация копирует ПЕРЕДАННЫЙ R
  (`k_f03/k_f04/k_f05`, `k_negativnyj`, `k_c05` → `zhivaya_kopiya(repo)`) и сверяет копию с
  ожиданиями ref-clean. При R ≠ ref-clean краснота получается по построению. Форма, которая
  проходит те же строки и не требует v+1, существует: ref-clean-входы берутся с ref-clean
  станции, как уже делает `--stabs` (`probe.py:3003-3005`), либо мутаторы ставятся на каждую
  карту. Противоречия SPEC/контракта нет. Уточнение SPEC — совет С-8, не блок.

Принято без замечаний: область правки; десятый коммит (в зоне и нужен); закрытие Б-1, Б-2, Б-4
с красным, показанным моими мутантами; неизменность соседей 147/148/149/151/143/159; `--model`,
`--stabs`, безфлаговый `W` и `W --repo ref-clean` зелёные своей мерой; счёты сходятся двумя
мерами; CI PR #619 на head = OBJECT зелёный (16 SUCCESS, 1 SKIPPED).

Референсы (происхождение, вопрос задания): оба собраны implementer'ом, это не git-клоны.
ref-clean = продукт Impl147h/mob `cc38881` + носитель раскладки замороженной батареи 147 без
правок. Это та же A-раскладка, на которой судили критики 147, и способ восстановления
2026-11-06 (HANDOFF:348). Допустимо. mob-ref = Impl148h/mob `6b5ef76` + носитель 148 + ПРАВКА
автора субъекта (`style={styles.profileZone}` на `shell-profile-entry`). Обоснование («в
продукте 148 зона 44») я проверил, оно верно (Impl148h tab-shell.tsx:312-318), но вход,
подогнанный автором проверяемого кода, не независим. Это условие У-3 для оркестратора, а не блок
сверх Б-6.

## Сырые прогоны

Клон `/tmp/dev-harness-verify/Rev158r5/1794192305-1354241/repo` (SSH-клон
ssh://git@github.com/a3ka/dev-harness.git, detached на OBJECT). Тяжёлые режимы шли параллельно
в отдельных локальных клонах того же OBJECT `c-<режим>`, у каждого свой `.git`. Одновременно
жило не больше трёх копий референсов.

```text
$ git log --oneline -12   # в клоне на OBJECT
f8134ed4 158: перенос r4 на базу с лендом 159 — две правки пробы (гейт 159, живые клетки вне --repo)
cf909592 158: удалён код без потребителя (Б-4 ревью 3, ACCIDENTAL): …
99009248 158: клетки семьи A (экранный режим) и f03–f08 судят дверь W подпроцессом; … (Б-2 ревью 3)
3714d534 158: раннер ждёт трассу слоя по командам polnyj_trek/*.sh, … (Б-1 ревью 3)
1de109d1 158: гейт трека читает класс риска и в компактной шапке (Б-1)
5e5565bf 158: generiruy отдаёт ЕДИНЫЙ контракт возврата …
c301d9da 158: батарея ekrannyj_nabor_158 — клетки f06–f08 отдают именованный отказ …
24d5e1a3 158: клетка f01 — имя причины LIVE_PREDPOSYLKA наружу дословно …
2ea0e47d 158: батарея ekrannyj_nabor_158 — четыре блока ревью 158 (Б-1…Б-4) + гейт трека и нога (д3)
49d3be64 158: батарея набора ekrannyj_nabor_158 — probe.py (73 клетки), …, 13 стабов
77d71d1d Merge commit '5757f0ab83d765f00218c2b2fa28d416d9b2c4ea'
$ git merge-base origin/main f8134ed4
77d71d1dcd29fbab760227aac4b43c49fb343f29
$ git merge-base --is-ancestor done/contracts/159/1 f8134ed4; echo anc=$?
anc=0
$ for c in 8b83d383 7946021f 2ea0e47d 120a0eb5 615478b1 49d3be64; do git show $c | git patch-id --stable | cut -c1-16; done
8b83d383 a8566d300bc32166
7946021f a8566d300bc32166
2ea0e47d a8566d300bc32166
120a0eb5 c1d8979f0d1d5060
615478b1 c1d8979f0d1d5060
49d3be64 c1d8979f0d1d5060
$ git show --stat 2ea0e47d
 osi.md 6 +-, probe.py 259 ++-, st03 10 ++-, st05 5 +-, st09 4 +-, scripts/check_trek_ekrana.sh 50 +, scripts/pre_critic.sh 24 +
 7 files changed, 292 insertions(+), 66 deletions(-)
```

Область и неизменность:

```text
$ git diff --name-only 77d71d1d f8134ed4 | grep -vE '^(fixtures/workshop_project/ekrannyj_nabor_158/|scripts/check_trek_ekrana\.sh$|scripts/pre_critic\.sh$)'; echo out_of_zone_rc=$?
out_of_zone_rc=1
$ git diff --name-status 77d71d1d f8134ed4 | cut -f1 | sort | uniq -c
     63 A
      1 M
$ git diff --numstat 77d71d1d f8134ed4 -- scripts/pre_critic.sh
24	0	scripts/pre_critic.sh
$ git diff --quiet frozen/contracts/158/2 f8134ed4 -- contracts/158-ekrannyj-nabor.md fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh; echo rc=$?
rc=0
$ git diff --quiet 77d71d1d f8134ed4 -- fixtures/workshop_project/{gespraech_vhod_147,vkladki_tabov_148,gespraech_tekst_149,mob_ci_143,pustoj_produkt_159} scripts/check_pustoj_produkt.sh scripts/sverka_maketa.py scripts/ekran_shablon.py contracts roles AGENTS.md; echo neighbours_unchanged_rc=$?
neighbours_unchanged_rc=0
$ git diff --quiet 77d71d1d f8134ed4 -- fixtures/workshop_project/gespraech_otdacha_151; echo n151_rc=$?
n151_rc=0
$ bash scripts/check_zones.sh .        # клон repo
  ok   contracts/158-ekrannyj-nabor.md — работа не раздаётся: правка SPEC.md исполнителем; …
…
замороженных контрактов: 156 · объявленных авторов: 5 · коммитов в диапазонах: 49353 · проверено по зонам: 12364
RC=0 (545 s)
$ gh pr view 619 --json headRefOid,state,statusCheckRollup
f8134ed4dadb5168232f131140ecd0fab5a73c83  OPEN  {"SKIPPED":1,"SUCCESS":16}
```

Режимы двери (`W` = `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`):

```text
$ (c-bare) W
CASE a01…a14 ok, z01-gate-v-dereve ok, z02-noga-pre-critic ok, b01…b07 ok, c01…c04 ok,
     d01-karty-polny ok, d02-oracle-tamper ok, d03-pustoj-produkt ok, e01 ok, e02 ok, g01…g07 ok, g08-159 ok
клеток 40, зелёных 40, красных 0
RC=0 (456 s)

$ (c-model) W --model
CASE a01…a14 ok, b01…b07 ok, c01…c04 ok, d01…d03 ok, e01 ok, e02 ok, g01-147-model … g07-143-stabs ok
клеток 37, зелёных 37, красных 0
RC=0 (441 s)

$ (c-stabs) W --stabs
клеток 37, зелёных 37, красных 0
STAB st01-trek-bez-riska.py a02-risk-bez-stroki KRASEN / a03-risk-legkij KRASEN / st01 KRASEN
STAB st02-trek-udaljaet-sloj.py a06-pereklyuchenie KRASEN / st02 KRASEN
STAB st03-avd-393-bez-podtverzhdenija.py b02-zalipshij-390 KRASEN / b07-mutant-393-pri-390 PROSHYOL / st03 KRASEN
STAB st04-lint-po-chislu.py c01-literal-nav-height KRASEN / c04-ravnoe-chislo-bez-svjazi KRASEN / st04 KRASEN
STAB st05-zond-bez-predkov.py f15-tsel-opacity0 KRASEN / f16-tsel-predok-opacity0 KRASEN / f25-nadpis-vlozhennyj-prozrachnyj KRASEN / st05 KRASEN
STAB st06-oracle-s-diska.py d02-oracle-tamper KRASEN / e01-soglasovano PROSHYOL / st06 KRASEN
STAB st07-polnyj-bez-ispolnenija.py a10 KRASEN / a06 KRASEN / a11 KRASEN / st07 KRASEN
STAB st08-marker-gde-ugodno.py a12-marker-vne-priemki KRASEN / st08 KRASEN
STAB st09-sovmestnyj-v-toy.py f03 KRASEN / f04 KRASEN / f05 KRASEN / st09 KRASEN
STAB st10-sovmestnyj-otvergaet.py f03 KRASEN / f04 KRASEN / f05 KRASEN / st10 KRASEN
STAB st11-sovmestnyj-karta-ref-clean.py f06-sovmestnyj-karta-iz-fajla KRASEN / st11 KRASEN
STAB st12-sovmestnyj-tablica-nomerov.py f06 KRASEN / f07-sovmestnyj-nezavisimost-nomera KRASEN / st12 KRASEN
STAB st13-sovmestnyj-karta-po-nomeru.py f06-sovmestnyj-karta-iz-fajla KRASEN / st13 KRASEN
SVJAZI 26
RC=0 (495 s)

$ (c-repoRef) W --repo /tmp/dev-harness-verify/Arch147t/ref-clean
CASE a01…a14, z01, z02, b01…b07, c01…c05 (c05-slezhenie ok), d01…d03, e01, e02,
     f00…f08 ok (f03-sovmestnyj-chestnyj ok … f08-sovmestnyj-dobavlenie-dannyh ok), f10…f33 ok, g01…g08 ok
клеток 74, зелёных 74, красных 0
RC=0 (641 s)

$ (c-repoMob) W --repo /tmp/dev-harness-verify/Arch148t/mob-ref
CASE a01…a14, z01, z02, b01…b07, c01…c04, d01…d03, e01, e02 ok
CASE c05-slezhenie KRASNO: ожидался rc=0, факт rc=1 (причины факта: ЗОНД НЕ ИЗМЕРИЛ ЦЕЛЬ gespraech-mitte); нет причины TOKEN_SLEDUET
CASE f00-chestnyj-kontrol ok
CASE f01-predposylka ok
CASE f02-sposoby-zony ok
CASE f03-sovmestnyj-chestnyj KRASNO: ожидался rc=0, факт rc=1 (причины факта: SOSTOJANIE_NEDOSTIZHIMO, TSEL_OTSVTSTVUET)
CASE f04-sovmestnyj-vykljuchennaja-tsel KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор не применён: MUTATOR_YAKOR: mobile/src/bootstrap/tab-shell.tsx: якорь найден 0 раз (нужно 1)); …
CASE f05-sovmestnyj-polnyj-sloj ok
CASE f06 ok, f07 ok, f08 ok
CASE f10-zona-20 KRASNO: ожидался rc=1, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: мутатор model/mutanty/zona-20.py не применён: MUTATOR_YAKOR: … якорь найден 0 раз (нужно 1)); нет причины ZONA_MENSHE_NORMY
… f11…f15, f17…f33 — та же форма (rc=2 MUTATOR_YAKOR, якорь найден 0 раз), каждая без своей причины
CASE f16-tsel-predok-opacity0 KRASNO: ожидался rc=1, факт rc=0 (причины факта: —); нет причины TSEL_NEVIDIMA
CASE g01…g08 ok
клеток 74, зелёных 47, красных 27
RC=1 (540 s)
```

f16 на mob-ref: якорь `<View style={styles.section} testID={`section-${section}`}>` есть в обоих
референсах (ref-clean:287, mob-ref:299). В mob-ref этот контейнер целей карты не держит:
таб-бар — отдельный оверлей. Поэтому opacity 0 на нём ничего обязательного не скрывает, и rc 0
здесь честный, это не дефект хелпера. Это ещё одно наблюдение, что образцы привязаны к ref-clean.

Гейты контракта (клон c-mut, чистый OBJECT):

```text
$ bash scripts/pre_critic.sh contracts/158-ekrannyj-nabor.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
  ok   гейт трека: ТРЕК ЛЁГКИЙ (по умолчанию)
КРИТИК: дверь зелёная
RC=0
$ bash scripts/check_trek_ekrana.sh . contracts/158-ekrannyj-nabor.md
ТРЕК ЛЁГКИЙ (по умолчанию)
RC=0
$ bash scripts/check_trek_ekrana.sh .
ТРЕК ЛЁГКИЙ (по умолчанию)   ×4
RC=0
$ python3 fixtures/workshop_project/ekrannyj_nabor_158/samoopisanie/samoopisanie.py
{"kletok": 74, "nositelej": 40, "piny": 7, "roditel": "83955a665f576e77be452851e3afd5aec0783b05d6953a1837952b365a1f0afb", "stabov": 13, "svjazej": 26}
RC=0
$ bash scripts/check_provodka.sh . contracts/158-ekrannyj-nabor.md
проводка: guard не подключён: fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh не вызывается в .githooks/ или .github/workflows/
RC=1          (ожидаемо: подключение — оркестратор в окне freeze..done, SPEC §10 п.5)
```

### Красное моими мутантами (одноразовый `kletka.py`: клетка в процессе проверяющего, субъект — дверь probe.py мутированного клона подпроцессом; клон возвращён `git checkout -- .`)

```text
=== честно: a14-sloj-vne-tablicy
KLETKA a14-sloj-vne-tablicy akt rc=0 pri=[]   SLED negativnyj-obrazec rc=0   SUDIT ok   rc=0
=== M1 (Б-1 назад): sud_ekran сверяет sled с sloi_paketa(nomer)
KLETKA a14-sloj-vne-tablicy akt rc=1 pri=['TREK_SLOJ_NE_ISPOLNEN']
SUDIT KRASNO: ожидался rc=0, факт rc=1 (причины факта: TREK_SLOJ_NE_ISPOLNEN)   rc=1
KLETKA a10-sloj-ispolnen-v-polnom … SUDIT ok   (toy-таблица совпадает — ожидаемо)
KLETKA a11-sloj-krasen … SUDIT ok
=== M2 (Б-2): совместная ветвь двери не печатает строки ZOND; R = ref-clean
KLETKA f03-sovmestnyj-chestnyj akt rc=1 pri=['ZOND_NA_R_NE_ZAPUSHCHEN']
SUDIT KRASNO: ожидался rc=0, факт rc=1 (причины факта: ZOND_NA_R_NE_ZAPUSHCHEN); нет маркера ZOND shell-tab-start 390 ok   rc=1
=== M3 (Б-2): совместная ветвь двери не запускает зонд R, rc 0 + одна фальшивая строка ZOND
KLETKA f04-sovmestnyj-vykljuchennaja-tsel akt rc=1 pri=['ZOND_NA_R_NE_ZAPUSHCHEN']
  mark: ZOND gespraech-sprechen 390 ok / ЭКРАН 195: СОВМЕСТНЫЙ РЕЖИМ ЗЕЛЁНЫЙ
SUDIT KRASNO: нет причины TSEL_VYKLYUCHENA (факт: ZOND_NA_R_NE_ZAPUSHCHEN); нет маркера ZOND shell-tab-start 390 ok   rc=1
```

### Своя мера счётов (другая команда, не повтор)

- Клетки: импорт probe.py в c-mut → `KLETKI 74 unique 74`; `stroit_cell` по режимам:
  bare 40, model 37, stabs 37, repo 74, f* 33. Сходится с итогами прогонов 40/37/37/74/74.
  `source.json.kejsy` против таблиц §6 SPEC.md регэкспом: kejsy 74, клеток SPEC 73, лишняя
  `a14-sloj-vne-tablicy`, недостающих нет (совет С-7).
- Стабы: строк `STAB <файл> <клетка> …` в логе `--stabs` — KRASEN 24, PROSHYOL 2, сумма 26 =
  `SVJAZI 26` = `sum(len(stab_vhod))` 26; стабов 13 (ключи stab_vhod; файлов в stubs/ 15 — у st03 и st05 по два носителя), каждый в итоговой строке KRASEN.
- mob-ref: строк `^CASE` 74, из них KRASNO 27 (c05, f03, f04, f10–f33). `grep 'ok$'` даёт 48,
  потому что красная строка f04 кончается маркером «… 390 ok», значит зелёных 47 = вывод.
  Отчёт implementer (27 красных, 47/74) моей мерой подтверждён.
- ref-clean: строк `^CASE … ok$` 74, KRASNO 0.

## 1–7 по норме роли

1. **Область.** 64 пути (63 A, 1 M), все в ЗОНЕ implementer frozen 158/2. В `pre_critic.sh`
   +24/−0, только нога (д3) после (д2). `check_zones` rc 0. Десятый коммит меняет только
   probe.py (зона) и нужен. (1) `geyt_159` отдавал тройку `zapusk_komandy` при живом гейте, а
   вызовы разбирали пару: на базе с 159 d03 и ветвь `--repo` падали ValueError. (2)
   `stroit_cell` строил живые клетки в безфлаговом режиме, а SPEC §1 v+1 и п.7 158/2 велят
   строить их только при `--repo`. Две причины в одном коммите — совет С-10.
2. **Сырой вывод.** Здесь — мои прогоны. Отчёт implementer как доказательство не засчитан,
   сверен моей мерой.
3. **Подгонка проверок.** SPEC, дверь и контракт равны тегу 158/2. Изменения `source.json`
   с прошлого круга (a77f3d11): +`a14` и условие f03 при отсутствии гейта 159
   (rc 2 NOT_IMPLEMENTED); ожидания не ослаблены. Подгонка — во входе mob-ref (У-3).
4. **Красное.** Новый барьер a14 красен на M1. Б-2: f03/f04 красны на M2/M3 (не стабы), st09/st10
   KRASEN на f03–f05 в `--stabs`.
5. **Атомарность.** Связка `2ea0e47d` в истории — **Б-5**. Остальные коммиты — по одной задаче
   со ссылкой «158:».
6. **Норма.** Нормативных документов (roles/, AGENTS.md, contracts/) в диффе нет.
7. **Заявленное = сделанное.** Счёты отчёта implementer (40/37/26/74/27) моей мерой сходятся.
   Неверно заявление «девять коммитов закрывают Б-1…Б-4»: Б-3 не закрыт (Б-5).

## ПРОВОДКА (контракт 038)

`guard=fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`. Дверь существует и
исполняет probe.py; это барьер именно этого предмета. Клетки зовут probe.py напрямую
(`PUT_DVERI`), а обёртка — `exec python3 probe.py "$@"` плюс отказ при отсутствии probe.py,
так что поведение то же. Подключения в CI нет: `check_provodka` rc 1, ожидаемо (зона
orchestrator). ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно.

## СВЕРКА-СТАНДАРТОВ

СВЕРКА-СТАНДАРТОВ: неприменимо. AGENTS.md харнесса не объявляет документа архитектуры и
стандарта кода; `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` в дереве нет (как в круге 3).

## Паразитная сложность (контракт 050) — дельта с a77f3d11

- `komandy_sloya`/`ozhidanie_sleda`/`sloi_iz_fajlov` (probe.py). (1) И-6(в), SPEC §6A «Раннер».
  (2) Состояния нет: ожидание снимается с файлов слоя до запуска. (3) Новый экран ПОЛНЫЙ больше
  не требует правки probe.py, связность упала. (4) Внутренние функции. (5) `sud_ekran`,
  `sovmestnyj_rezhim`, клетки a10/a14. ESSENTIAL.
- `dver`/`ekran_dver`/`sovmestnaya_dver`/`dver_s_zamenoy` + `PUT_DVERI`. (1) SPEC §6A
  «подпроцессом», п.4 контракта. (2) `PUT_DVERI` — модульная точка подмены, явная, стабы её
  ставят и удаляют копию в finally. (3) 1 файл. (4) Тонкие обёртки над `zapusk_komandy`.
  (5) Клетки A и f03–f08, стабы st07/st09–st13. ESSENTIAL.
- Клетка `a14-sloj-vne-tablicy`. (1) Закрывающее свойство Б-1 (И-9). (2) Нет. (3) 2 файла
  (probe, source.json); в SPEC отсутствует (С-7). (5) `W`, `--model`. ESSENTIAL.
- `stroit_cell` (десятый коммит). (1) п.7 158/2. (2) Нет. ESSENTIAL.
- Параметр `helper` у `zond_na_repo` и `imya_kletki` у `sudi_repo` — без потребителя
  (ACCIDENTAL). Без строки приёмки, которую бы ломали, поэтому совет С-9.

## Модель-факт

anthropic/claude-opus-5-5 — равна плану реестра (`roles.reviewer` → `@opus`). Вызов 4-й по
предмету.
