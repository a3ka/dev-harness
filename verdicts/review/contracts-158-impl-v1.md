FAIL

OBJECT=a77f3d11c10fe1f521635714225fd6a2eee6decf
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; ТРЕК набора: ПОЛНЫЙ)
СУД: repo=dev-harness (контракт frozen/contracts/158/1 → 9c6ebde7); предмет=158; фаза=реализация; роль=reviewer; сессия=Reviewer158Opus3; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5; вызов=3 (прежние Reviewer158Scoped @3a1cea50 и Reviewer158Fresh @04ab0217 в main не материализованы)
НЕЗАВИСИМОСТЬ: автор — implementer (MiniMax по слову владельца 2026-11-03 ~18:40); адверсарий r2 — openai-codex/gpt-5.6-terra (accept, verdicts/adversary/contracts-158-impl-r2.md @619e7d8f); судья — Anthropic.
НАХОДКИ: .review/2026-11-07-81.md — блоки implementer Б-1…Б-4, условия У-1, У-2 (не implementer), советы С-1…С-6.

## Вердикт

FAIL. Блокирующих находок четыре, все у implementer:

- **Б-1** (И-6(в), И-9, SPEC §6A «Раннер --ekran»). Раннер сверяет трассу слоя ПОЛНЫЙ с зашитой
  таблицей toy-номеров `sloi_paketa` (`probe.py:464-468`, используется на `:655-658` и
  `:908-911`). Своей мерой: конформный экран 501 с полностью исполненным зелёным слоем → rc 1
  `TREK_SLOJ_NE_ISPOLNEN`. ПОЛНЫЙ трек неисполним для любого настоящего экрана без правки кода.
- **Б-2** (приёмка п.4, SPEC §6A «подпроцессом»). Клетки a01/a06/a10–a13 и f03–f08 зовут
  внутренние функции, а не дверь `W`. Диспетчер `main()` (`probe.py:2742-2768`) не судится.
  Мутант двери с toy-ветвью без зонда R даёт rc 0, а клетка f03 на нём ok. Честная дверь на
  входе f03 даёт rc 2, хотя клетка f03 зелёна.
- **Б-3** (норма роли, п.5 «Атомарность»). Коммит `8b83d383` — связка из пяти задач.
- **Б-4** (контракт 050, ACCIDENTAL). Код без потребителя: `firstrun`/`NABOR_158_FIRSTRUN`
  (`probe.py:727,758-759`), `NABOR_158_KOREN` (`:51`), отбрасываемый прогон зонда (`:912-914`).
  Более простая форма проходит f03–f05 (показано).

Отдельно, не implementer: **У-1** — гейт и батарея 159 не в дереве. Строки приёмки п.2
(`W --repo` rc 0), п.6 и п.7 (безфлаговый `W` rc 0) на этом HEAD недостижимы, а батарея честно
fail-closed. Без ленда 159 нужно слово владельца о порядке. **У-2** (architect) — п.7 контракта
(«`W` без флага после полной реализации → rc 0; живые семьи — только в --repo») расходится с
SPEC §1/§10 п.2 (живые семьи строятся в безфлаговом режиме именованной краснотой). Implementer
идёт по SPEC, поэтому безфлаговый `W` красен по построению: 33 живые клетки даже после 159.

Что сделано верно и принято без замечаний: область правки; неизменность замороженных соседей;
нога (д3) только добавлена после (д2); гейт трека и нога в одном коммите; эталон — единственный
источник грамматики (скрипт делегирует ему через `exec`); `--model` и `--stabs` зелёны своей
мерой; счёты сходятся двумя мерами; Б-1 прошлого круга адверсария (компактная риск-шапка) закрыт.

## Сырые прогоны (клон /tmp/dev-harness-verify/Rev158r3/repo @ OBJECT, detached)

```text
$ git fetch origin wip/158/implementer-r2 && git rev-parse FETCH_HEAD
a77f3d11c10fe1f521635714225fd6a2eee6decf
$ git rev-parse origin/main; git merge-base HEAD origin/main
38ab6c336127ded12171b35566bad35a9bb04e8a
13484e53ed1baceaab4acb9fb0128d3abc541acf
$ git log --format='%h %an <%ae> | %cn | %s' 13484e53ed..HEAD
a77f3d11 implementer <implementer@dev-harness.local> | implementer | 158: гейт трека читает класс риска и в компактной шапке (Б-1)
04ab0217 implementer … | 158: generiruy отдаёт ЕДИНЫЙ контракт возврата …
9d45984e implementer … | 158: батарея ekrannyj_nabor_158 — клетки f06–f08 отдают именованный отказ …
7134f2f2 implementer … | 158: клетка f01 — имя причины LIVE_PREDPOSYLKA наружу дословно …
8b83d383 implementer … | 158: батарея ekrannyj_nabor_158 — четыре блока ревью 158 (Б-1…Б-4) + гейт трека и нога (д3)
120a0eb5 implementer … | 158: батарея набора ekrannyj_nabor_158 — probe.py (73 клетки), …, 13 стабов
$ git diff --name-status 13484e53ed HEAD | cut -f1 | sort | uniq -c
     63 A
      1 M            # M = scripts/pre_critic.sh, +24/−0, удалённых строк 0
$ git diff --name-only 13484e53ed HEAD | grep -vE '^(fixtures/workshop_project/ekrannyj_nabor_158/|scripts/check_trek_ekrana\.sh$|scripts/pre_critic\.sh$)'
(пусто, rc=1)
$ git diff --quiet frozen/contracts/158/1 HEAD -- contracts/158-ekrannyj-nabor.md fixtures/workshop_project/ekrannyj_nabor_158/SPEC.md fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh; echo rc=$?
rc=0
$ git diff --quiet 13484e53ed HEAD -- fixtures/workshop_project/{gespraech_vhod_147,vkladki_tabov_148,gespraech_tekst_149,mob_ci_143} scripts/sverka_maketa.py scripts/ekran_shablon.py contracts; echo rc=$?
rc=0
```

Каталога `frozen/` в дереве нет, поэтому `git diff -- frozen` (так проверял адверсарий r2) пуст
по построению. Неизменность замороженных барьеров здесь проверена по их настоящим путям.

```text
$ bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --model
CASE a01-trek-po-umolchaniju ok
… (a02–a13, b01–b07, c01–c04, d01–d03, e01–e02 — все ok)
CASE g01-147-model ok
CASE g02-147-stabs ok
CASE g03-148-model ok
CASE g04-148-stabs ok
CASE g05-149-model ok
CASE g06-149-stabs ok
CASE g07-143-stabs ok
клеток 36, зелёных 36, красных 0
rc=0          (387 с)
```

```text
$ bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh --stabs
CASE a01…g07 ok (те же 36, что в --model)
клеток 36, зелёных 36, красных 0
STAB st01-trek-bez-riska.py a02-risk-bez-stroki KRASEN
STAB st01-trek-bez-riska.py a03-risk-legkij KRASEN
STAB st02-trek-udaljaet-sloj.py a06-pereklyuchenie KRASEN
STAB st03-avd-393-bez-podtverzhdenija.py b02-zalipshij-390 KRASEN
STAB st03-avd-393-bez-podtverzhdenija.py b07-mutant-393-pri-390 PROSHYOL
STAB st04-lint-po-chislu.py c01-literal-nav-height KRASEN
STAB st04-lint-po-chislu.py c04-ravnoe-chislo-bez-svjazi KRASEN
STAB st05-zond-bez-predkov.py f15-tsel-opacity0 KRASEN
STAB st05-zond-bez-predkov.py f16-tsel-predok-opacity0 KRASEN
STAB st05-zond-bez-predkov.py f25-nadpis-vlozhennyj-prozrachnyj KRASEN
STAB st06-oracle-s-diska.py d02-oracle-tamper KRASEN
STAB st06-oracle-s-diska.py e01-soglasovano PROSHYOL
STAB st07-polnyj-bez-ispolnenija.py a10-sloj-ispolnen-v-polnom KRASEN
STAB st07-polnyj-bez-ispolnenija.py a06-pereklyuchenie KRASEN
STAB st07-polnyj-bez-ispolnenija.py a11-sloj-krasen KRASEN
STAB st08-marker-gde-ugodno.py a12-marker-vne-priemki KRASEN
STAB st09-sovmestnyj-v-toy.py f03/f04/f05 KRASEN (3 строки)
STAB st10-sovmestnyj-otvergaet.py f03/f04/f05 KRASEN (3 строки)
STAB st11-sovmestnyj-karta-ref-clean.py f06-sovmestnyj-karta-iz-fajla KRASEN
STAB st12-sovmestnyj-tablica-nomerov.py f06 KRASEN, f07 KRASEN
STAB st13-sovmestnyj-karta-po-nomeru.py f06-sovmestnyj-karta-iz-fajla KRASEN
(итоговые строки «STAB stNN… KRASEN» — все 13)
SVJAZI 26
rc=0          (486 с)
```

Своя мера: привязок KRASEN 24, PROSHYOL 2 (st03→b07, st06→e01), сумма 26 = SVJAZI. Каждый
стаб пойман хотя бы на одном входе (SPEC §7). Две непойманные привязки — не дефект: SPEC требует
«хотя бы на одном». Но st09/st10 пойманы на шве функции, а не двери (Б-2).

```text
$ bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh
CASE a01…a13 ok (13), z01-gate-v-dereve ok, z02-noga-pre-critic ok, b01…b07 ok, c01…c04 ok
CASE c05-slezhenie KRASNO: ожидался rc=0, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: референс не задан (живой суд — только с референсом)); нет причины TOKEN_SLEDUET (…)
CASE d01…d03 ok, e01 ok, e02 ok
CASE f00-chestnyj-kontrol KRASNO: ожидался rc=0, факт rc=2 (причины факта: LIVE_PREDPOSYLKA: референс не задан (нужен --repo))
CASE f01-predposylka ok
CASE f02-sposoby-zony KRASNO: ожидался rc=0, факт rc=2 (… LIVE_PREDPOSYLKA …)
CASE f03…f08, f10…f33 KRASNO: … факт rc=2 (причины факта: LIVE_PREDPOSYLKA: референс не задан (живой суд — только с референсом)) …   (30 клеток, каждая этой причиной)
CASE g01…g07 ok
CASE g08-159 KRASNO: ожидался rc=0, факт rc=2 (причины факта: NOT_IMPLEMENTED: батарея 159 не заведена (порядок контракта: 159 раньше 158))
клеток 73, зелёных 39, красных 34
rc=1          (422 с)
```

Красных 34 = живые 33 (c05, f00, f02, f03–f08, f10–f33) + g08. Своя мера: 1+1+1+6+24+1 = 34.

```text
$ bash scripts/check_trek_ekrana.sh . contracts/158-ekrannyj-nabor.md; echo rc=$?
ТРЕК ЛЁГКИЙ (по умолчанию)
rc=0
$ bash scripts/check_trek_ekrana.sh .; echo rc=$?
ТРЕК ЛЁГКИЙ (по умолчанию)
ТРЕК ЛЁГКИЙ (по умолчанию)
ТРЕК ЛЁГКИЙ (по умолчанию)
ТРЕК ЛЁГКИЙ (по умолчанию)
rc=0
$ bash scripts/pre_critic.sh contracts/158-ekrannyj-nabor.md; echo rc=$?
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
  ok   гейт трека: ТРЕК ЛЁГКИЙ (по умолчанию)
КРИТИК: дверь зелёная
rc=0
$ bash scripts/verify_antiplacebo.sh --scope pre_critic; echo rc=$?
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   pre_critic/case_01_honest_green.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «Н-39: привязка стаба в прозе»
  ok   pre_critic/case_02_n39_s2_binding.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «Н-39: привязка стаба в прозе»
барьеров: 1 · фикстур: 2 · предъявлено красным повторным прогоном: 2
rc=0
```

Первый прогон antiplacebo дал rc=1 «дерево изменилось вне $WORK — ./tmp/zones.*». Причина —
мой собственный параллельный `check_zones.sh`, который пишет в `./tmp` клона. Повтор после его
окончания — выше, rc=0.

```text
$ bash scripts/check_zones.sh .; echo rc=$?
  ok   contracts/158-ekrannyj-nabor.md — работа не раздаётся: правка SPEC.md исполнителем; …
…
замороженных контрактов: 152 · объявленных авторов: 5 · коммитов в диапазонах: 47304 · проверено по зонам: 11607
rc=0          (467 с)
$ bash scripts/check_provodka.sh . contracts/158-ekrannyj-nabor.md; echo rc=$?
проводка: guard не подключён: fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh не вызывается в .githooks/ или .github/workflows/
rc=1          (ожидаемо: подключение — оркестратор в окне freeze..done, SPEC §10 п.5)
$ python3 fixtures/workshop_project/ekrannyj_nabor_158/samoopisanie/samoopisanie.py
{"kletok": 73, "nositelej": 40, "piny": 7, "roditel": "d965c688…71cd", "stabov": 13, "svjazej": 26}
```

### Своя мера счётов (другая команда, не повтор)

Python-разбор `KLETKI` в probe.py, `kejsy` и `stab_vhod` в source.json, таблиц §6 SPEC.md:
KLETKI 73 = kejsy 73 = клеток SPEC 73. Разности множеств пусты; f14 с заглавной S в `hitSlop`
сверена вручную. Файлов-стабов `st01…st13` — 13 (st03 и st05 имеют по два носителя, всего 15
файлов). Привязок `stab_vhod` — 26, равно `SVJAZI 26`. В режиме `--model` строится 39 клеток
(не f* и не c05) минус 3 субъект-клетки дерева (z01, z02, g08) — 36, равно выводу. Заявление
коммита 120a0eb5 «73 клетки, 13 стабов» сходится.

### Репро Б-1 (`repro-sloj.sh`: toy-корень, контракт 501 ТРЕК: ПОЛНЫЙ, `NABOR_158_TOY_ROOT`, дверь `W --ekran`)

```text
=== A: свой слой (negativnyj-obrazec, зелёный)
ЭКРАН 501 ТРЕК ПОЛНЫЙ
ЯДРО: ok
SLED negativnyj-obrazec rc=0
ПРИЧИНА TREK_SLOJ_NE_ISPOLNEN
rc=1
sled: negativnyj-obrazec rc=0
=== B: та же пачка, команда переименована в shag-1 (имя toy-таблицы)
ЭКРАН 501 ТРЕК ПОЛНЫЙ
ЯДРО: ok
SLED shag-1 rc=0
rc=0
=== C: номер 196 (из таблицы), слой: одна зелёная shag-1
ЭКРАН 196 ТРЕК ПОЛНЫЙ
ЯДРО: ok
SLED shag-1 rc=0
ПРИЧИНА TREK_SLOJ_NE_ISPOLNEN
rc=1
```

### Репро Б-2 (`repro-dver.sh`: toy-мир `postroit_toy`, R = /tmp/dev-harness-verify/Arch147t/ref-clean)

```text
=== 1. честная дверь: W --repo ref-clean --ekran 195 (вход f03)
rc=2
ZOND-строк: 26
NOT_IMPLEMENTED: гейт 159 (scripts/check_pustoj_produkt.sh) в дереве отсутствует
NOT_IMPLEMENTED: гейт 159 отсутствует в дереве — совместный режим не зелёный (И-8)
=== 2. мутант двери (диспетчер main: совместная ветвь отключена → toy-ветвь --ekran)
rc=0
ZOND-строк: 0
ЭКРАН 195 ТРЕК ЛЁГКИЙ
ЯДРО: proverka-osnovaniya: основание экрана на месте
=== 3. клетка f03 мутантного probe (как её зовёт батарея — в процессе)
f03 akt rc=0 pri=[]
f03 sudit: ok
rc=0
```

### Репро Б-4(в) (`repro-prostaja.sh`: копия батареи без `zond_na_repo(repo, karta=None)` в `sovmestnyj_rezhim`)

```text
f03-sovmestnyj-chestnyj rc=0 pri=[] sudit=ok (6s)
f04-sovmestnyj-vykljuchennaja-tsel rc=1 pri=['TSEL_VYKLYUCHENA'] sudit=ok (6s)
f05-sovmestnyj-polnyj-sloj rc=1 pri=['POLNYJ_TREK_KRASNO'] sudit=ok (5s)
rc=0
```

Одноразовые копии и toy-корни репро удалены в самих скриптах.

## 1–7 по норме роли

1. **Область.** 64 пути, все в ЗОНЕ implementer frozen 158/1: `fixtures/workshop_project/ekrannyj_nabor_158/`,
   `scripts/check_trek_ekrana.sh`, `scripts/pre_critic.sh`. ПЕРЕСЕЧЕНИЕ по pre_critic соблюдено:
   только новая нога (д3) после (д2), удалённых строк 0. `check_zones` rc=0.
2. **Сырой вывод.** Здесь — мои прогоны. Тела коммитов несут замеры автора, их я не засчитывал.
3. **Подгонка проверок.** SPEC, дверь и контракт равны frozen/contracts/158/1. Оракул source.json
   написан тем же автором, что раннер. Это заложено в раздаче; пин эталона в a77f3d11 обновлён
   вместе с эталоном (ожидаемо). Подгонку видно в другом месте: проверяющий a10 берёт ожидание
   sled из той же таблицы `sloi_paketa`, что и субъект (Б-1). Проверка и субъект делят одну
   константу, поэтому дефект Б-1 зелен.
4. **Красное.** Для Б-1 прошлого круга адверсарий показал красное на старом эталоне, и моя мера
   на это не нужна. Красное для Б-1/Б-2 этого вердикта показал я: мутанты/входы выше.
5. **Атомарность.** Пять коммитов из шести — одна задача каждый, со ссылкой «158:». Связка —
   `8b83d383` (Б-3).
6. **Норма.** Нормативных документов (roles/, AGENTS.md, contracts/) в диффе нет.
7. **Заявленное = сделанное.** Счёты сходятся (см. «Своя мера»). Заявление тела 8b83d383
   «Клетки z01/z02 зелёные …» верно. А вот «гейт по всему contracts/ → rc 0 (147/148/149/158 без
   изменений)» из a77f3d11 скрывает, что 158 с объявленным ПОЛНЫЙ читается как ЛЁГКИЙ (С-1).

## Достаточность предмета (сверка с §Предмет контракта)

| часть предмета | реализация | суд |
|---|---|---|
| единые хелперы И-1 (хозяин/зона/видимость/надпись/действие/состояния) | zond/helpery.ts + nabor-zond-158.test.tsx | есть; судятся f00–f33 на живом R (в `--repo`). Полный `--repo` в этом круге не гонял: f03–f05 своей мерой зелёны (репро Б-4) |
| e2e-канон AVD двойником | teksty/e2e-porjadok.sh + fake-adb, b01–b07 | зелёно в `--model` |
| линт литералов | lint_tokena + nositeli/lint-obrazcy, c01–c05 | c01–c04 зелёно; c05 — живая |
| самоописание | samoopisanie.py, e01/e02 | зелёно, счёты сходятся |
| переключатель трека, ЛЁГКИЙ/ПОЛНЫЙ точечно и обратимо | эталон + гейт + раннер `--ekran` | гейт и грамматика — да; **исполнение ПОЛНЫЙ для настоящего экрана — нет (Б-1)** |
| механическая сверка в двери критика | нога (д3) | есть, z02 живой прогон |
| совместный `--repo R --ekran NNN` по карте пачки | `sovmestnyj_rezhim` + `main()` | функция по карте файла пачки — да (f06–f08); **дверь не судится (Б-2)** |

## ПРОВОДКА (контракт 038)

`guard=fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`. Канал существует,
дверь исполняет `probe.py`. Guard — барьер именно этого предмета. Подключения в CI нет:
`check_provodka` rc=1 «guard не подключён», это ожидаемо, зона orchestrator. ПРОВОДКА-ЭНФОРСМЕНТ
обоснован честно: поведенческой нормы вне механизма приёмки нет, role-канал не требуется.

## СВЕРКА-СТАНДАРТОВ

СВЕРКА-СТАНДАРТОВ: неприменимо. AGENTS.md харнесса не объявляет ни документа архитектуры, ни
стандарта кода (`grep -nE 'ARCHITECTURE|CODING-STANDARDS|стандарт кода' AGENTS.md` пуст;
`docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` в дереве нет).

## Паразитная сложность (контракт 050) — по каждому новому артефакту

Пять вопросов: (1) свойство контракта; (2) состояние и его явность; (3) сколько файлов меняется
при следующей правке того же свойства; (4) глубина модуля; (5) потребитель / повтор логики.

- `probe.py` (раннер+клетки+стабы-вход). (1) весь SPEC §1/§6/§7. (2) env `NABOR_158_TOY_ROOT` —
  объявлен SPEC; `NABOR_158_KOREN`, `NABOR_158_FIRSTRUN` — скрытые/мёртвые (Б-4). (3) таблица
  `sloi_paketa` заставит менять probe.py с каждым экраном ПОЛНЫЙ — рост связности (Б-1). (4) CLI в
  пять флагов = SPEC; глубокий. (5) дверь W, CI-шаг будущий. **ESSENTIAL, кроме Б-1/Б-4 — ACCIDENTAL.**
- `source.json` + `osi.md`. (1) SPEC §8, правило 8. (2) явное, пины. (3) 1–2 файла. (4) данные.
  (5) probe, samoopisanie. ESSENTIAL.
- `model/check_trek_ekrana_158.py`. (1) И-6(а)/(г)/(д), единый источник грамматики. (2) нет.
  (3) 1 файл + пин source.json. (4) CLI `<корень> [<контракт>]`, rc 0/1/2; глубокий. (5) гейт,
  батарея, нога. ESSENTIAL.
- `scripts/check_trek_ekrana.sh`. (1) И-6(д). (2) нет. (3) 0: делегирует эталону через `exec`,
  второго источника нет. (4) тонкая обёртка, интерфейс = эталону. (5) нога (д3), z01. ESSENTIAL.
- нога (д3) `pre_critic.sh`. (1) И-6(д). (2) нет. (3) 1. (4) судьба по rc. (5) дверь критика.
  ESSENTIAL.
- `model/karta-*.json`. (1) SPEC §4, d01. (2) данные. (3) 1. (5) зонд, d01, f03–f05. ESSENTIAL.
- семья `model/mutanty/*.py` + `_mutator.py`. (1) SPEC §6F «ровно одна замена, якорь count==1».
  (2) нет. (3) 1 на образец. (4) общий `_mutator.py` — без повтора. (5) f04, f10–f33. ESSENTIAL.
- `zond/` (3 файла). (1) И-1, f02. (2) маркер `.firstrun` — скрытый переключатель (С-3).
  (3) 1–2. (5) все живые клетки. ESSENTIAL, С-3 — совет.
- `teksty/` (двойник, fake-adb, мутант). (1) И-4, b01–b07. (2) файловое состояние песочницы,
  явное через `FAKE_ADB_STATE`. ESSENTIAL.
- `nositeli/` (пины e2e.sh, tokens-выписка, lint-obrazcy). (1) b06, И-3. ESSENTIAL.
- семья `stubs/` (13 стабов, 15 файлов). (1) SPEC §7. (2) нет. (3) 1 на стаб. (5) `--stabs`.
  ESSENTIAL. st09/st10 вшиты в шов функции, а не двери — следствие Б-2.
- `samoopisanie/samoopisanie.py`. (1) И-5. (2) нет. (5) e01. ESSENTIAL.

## Модель-факт

anthropic/claude-opus-5-5 — равна плану реестра. Вызов 3-й по предмету.
