accept
OBJECT=a65a3d4caf136d6d2ee5205093bc2ec22760ecff
СУД: репо=dev-harness; предмет=207; роль=reviewer; вызов=2 (scoped); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev207b | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущий=archive/207/reviewer-v1-fail-e84ee63108; класс риска=обычный
КЛАСС=КОДОВЫЙ. Вызов 2 — исправительный scoped: судятся только закрытие Б-1 вызова 1 и зависимый регресс. Норма «полный + один scoped» этим вызовом исчерпана.
Контракт: contracts/207-check-zones-incr-odin-sud-okna.md, frozen/contracts/207/1. `git diff --stat frozen/contracts/207/1 HEAD -- contracts/207-check-zones-incr-odin-sud-okna.md` → пусто, rc 0.
Находки: блоков 0. Советов 4 (С-1b, С-2, С-3, С-4) — `.review/2026-11-23-152.md`.

# Вердикт reviewer — 207, реализация, вызов 2 (scoped)

## Итог

**accept.** Б-1 закрыт. Replay стартует с номера своего контракта: `own_nnn="$nnn"` на `scripts/check_zones.sh:1186` стоит до цикла сбора, `zones_replay "$own_nnn"` — на `:1790`.

Мои миры wA и wB и новый мир wD дают OBJECT == база (`0eb88386a`) по rc, stdout, stderr и кешу, в полном и в incr режиме; incr == полный. Прежний OBJECT `b73141d01a` воспроизводит дефект — это контроль. Регресс зелёный.

Остаются советы:
- **С-1b:** мутант «replay не восстанавливает eff_nnn из .clob» в батарее всё ещё живой, а мой мир wD его ловит.
- **С-3:** счётные литералы приёмки контракта отстали от аддитивной дельты батареи.

## 1. Область правки

```
git diff --stat b73141d01a681243f649e1958ea8b383894580c4 a65a3d4caf136d6d2ee5205093bc2ec22760ecff
 .../check_zones_incr_207/SDACHA.md                 |  204 ++-
 .../check_zones_incr_207/base/check_zones.sh       | 1636 ++++++++++++++++++++
 .../workshop_project/check_zones_incr_207/probe.py |  203 ++-
 .../red_check_zones_incr_207.sh                    |    4 +-
 .../check_zones_incr_207/stabs.tsv                 |    6 +
 scripts/check_zones.sh                             |    5 +-
git diff --stat b73141d01a.. a65a3d4ca -- contracts registry .github → пусто, rc 0
git log b73141d01a..a65a3d4ca:
  d6ae38ef8 architect <architect@dev-harness.local> | architect   — только fixtures/workshop_project/check_zones_incr_207/**
  a65a3d4ca implementer <implementer@dev-harness.local> | implementer — только scripts/check_zones.sh (+3/−2)
git show 0eb88386a:scripts/check_zones.sh | cmp - fixtures/.../base/check_zones.sh → BASE-EQ
git grep -c 'zones_replay "$own_nnn"' HEAD -- scripts/ → scripts/check_zones.sh:1
```

- Дифф implementer — ровно три правки: `:704` `u_since` → `_` (закрыт SC2034 из С-2), `:1186` `own_nnn="$nnn"`, `:1790` `zones_replay "$own_nnn"`.
- Вызов на `:809` не тронут, и это правильно. В incr контракты 2..K уходят в `zones_exclude_incr` + `zones_replay "$nnn"` + `continue` (`:806-810`) до цикла сбора. `nnn` у них свежий из `read` (`:775`), ADD-переприсваивания (`:1442`) в этой итерации нет.
- Иных использований `$nnn` после цикла сбора, кроме replay, нет: `grep '\$\{?nnn'` по `:1180-1792` даёт только `:1185-1186` и тело ADD-ветви `:1442-1458`.
- Атомарность: два коммита, у каждого своя зона и свой автор, тема со ссылкой на 207.
- Неподгонка: implementer батарею не трогал; architect батарею дополнил. Дельта аддитивна, своя мера:
  - множество имён клеток b73141 ⊂ OBJECT (+e16, +e17);
  - `stabs.tsv` `+6/−0`;
  - в диффе probe.py нет ни одной удалённой строки ожиданий миров (`info.update|rc=|fails=|commits=|checked=`, grep rc 1).

## 2. Закрытие Б-1 — воспроизведено своей мерой

Скрипт `rw.py` написан заново, `probe.py` не переиспользует. Устройство:
- субъекты — `scripts/` OBJECT, в котором `check_zones.sh` заменён на `git show <rev>:scripts/check_zones.sh` (база `0eb88386a`, прежний OBJECT `b73141d01a`, OBJECT); остальные файлы `scripts/` в `0eb88386a..HEAD` не менялись — LIBS-SAME;
- даты коммитов строго возрастают, по +60 с;
- полный прогон и `--incr` с кешем = база окна;
- байтовое сравнение rc, stdout, stderr и кеша;
- миры строятся по одному и удаляются сразу.

**wA** (номера 101/102):
- 101 = `ЗОНА alice: a/` + `ЗОНА orchestrator: registry/`; 102 = `ЗОНА alice: a/`.
- Окно: c (alice, `plans/x.md`) → 102 v2 `СПАСЕНО alice: <c>` → минт ADD 102 (orchestrator).

```
wA base full rc=1 / incr rc=1 (FAIL c у 101; ok контракт 102 СПАСЕНО; проверено 2)
wA prev full rc=0 / incr rc=0 (ok контракт 102 ×2; проверено 1)        ← дефект воспроизводится
wA obj  full rc=1 / incr rc=1 (== base)
== wA full: base==prev rc=False out=True err=False cache=True
== wA incr: base==prev rc=False out=True err=False cache=False
== wA full: base==obj rc=True out=True err=True cache=True
== wA incr: base==obj rc=True out=True err=True cache=True
== wA obj: full==incr rc=True out=True err(sans marker)=True
```

**wB** (номера 101/102/103):
- 101 = `ЗОНА alice: a/` + v2 `СПАСЕНО alice: <c>`; 102 = `ЗОНА orchestrator: registry/`.
- В окне минт ADD 103.

```
wB base full rc=0 / incr rc=0 (ok контракт 101 СПАСЕНО; кеш=HEAD)
wB prev full rc=0 / incr rc=1 (FAIL c; кеш не записан)                  ← дефект воспроизводится
wB obj  full rc=0 / incr rc=0 (== base; кеш=HEAD)
== wB incr: base==prev rc=False out=True err=False cache=False
== wB prev: full==incr rc=False out=True err(sans marker)=False
== wB full: base==obj rc=True out=True err=True cache=True
== wB incr: base==obj rc=True out=True err=True cache=True
== wB obj: full==incr rc=True out=True err(sans marker)=True
```

**wD** — новый мир, номера 214/229/236/295 и минты 288/290/301:
- 214 = `ЗОНА alice: a/` + `ЗОНА orchestrator: registry/`; 229 = `ЗОНА alice: a/`; 236 = `ЗОНА bob: b/` + `ЗОНА orchestrator: registry/`; 295 = `ЗОНА alice: a/`.
- Окно по порядку:
  1. c0 (alice, нарушитель);
  2. ok-a;
  3. минт ADD 288;
  4. минт ADD `290`+`295` — второй подряд, две строки;
  5. c1 (alice, нарушитель);
  6. ветка feat: c3 (alice, нарушитель), минт ADD 301, b-out (bob, нарушитель);
  7. c4 (alice, нарушитель);
  8. merge `land: wip/229/feat` (свой у 229, чужой у 214/236/295);
  9. 295 v2 `СПАСЕНО alice: <c1>`;
  10. 229 v2 `СПАСЕНО alice: <c4>`;
  11. b-in;
  12. минт ADD 229;
  13. c5 (alice, нарушитель);
  14. 214 v2 `СПАСЕНО alice: <c5>`.

Минты стоят ДО СПАСЕНО-коммитов в окне, поэтому у 214 ключ СПАСЕНО c1 уходит на 295.

```
wD base full rc=1 / incr rc=1 (… ok контракт 229 c4 ×2, ok контракт 295 c1, проверено 20)
wD prev full rc=1 / incr rc=1 (== base: класс «минт до СПАСЕНО» дефект Б-1 не задевает)
wD obj  full rc=1 / incr rc=1
== wD full: base==obj rc=True out=True err=True cache=True
== wD incr: base==obj rc=True out=True err=True cache=True
== wD obj: full==incr rc=True out=True err(sans marker)=True
```

**Мутанты производственной двери на моих мирах.** Каждый — одна строка, `subj.py` проверяет, что якорь встречается ровно 1 раз:

| Мутант | wA | wB | wD |
|---|---|---|---|
| mskip `zones_replay "$own_nnn"` → `"$nnn"` (= PROIZV-CLOB-SKIP) | full/incr ≠ base | incr ≠ base, full≠incr | == base |
| mread `:769` восстановление eff_nnn из .clob → `:` | == base | == base | full/incr err ≠ base, full≠incr |
| msort `:771` `done < <(sort "$TMP/commits")` | == base | == base | full/incr err ≠ base |
| mkesh `:1798` `incr_finish 0` → `1` | == base | incr cache ≠ base | == base (мир красный) |

## 3. Батарея и регресс — сырые rc (по одному; TMPDIR — скратч копии)

```
W --repo .                 → KLETKI=50 ZELENYE=50 KRASNYE=0                   rc=0 t=76s
W --model                  → KLETKI=50 ZELENYE=50 KRASNYE=0                   rc=0 t=88s
W --stabs                  → MUTACII=33 SVJAZI=33 POIMANY=33 ZHIVYH=0         rc=0 t=66s
                             (pojman PATERN:PROIZV-CLOB-SKIP: e16 красна rc=0≠1, СПАСЕНО-строка 041 задвоена)
W --catalog                → EQ=18 C=6 H=21 N=4 K0=1 KLETKI=50 STABS=33 PATERNS=30 PROIZV=1 ANCHORS=1  rc=0
W --base                   → KLETKI=18 ZELENYE=18 KRASNYE=0                   rc=0 t=12s
W --repo <прежний OBJECT b73141d01a> → KLETKI=50 ZELENYE=48 KRASNYE=2 (e16, e17)   rc=1 t=75s   ← контроль
W --repo <mskip>           → KLETKI=50 ZELENYE=48 KRASNYE=2 (e16 rc=0≠1; e17 rc=1≠0)  rc=1 t=76s
W --repo <msort>           → KLETKI=50 ZELENYE=49 KRASNYE=1 (e14-porjadok-replay)     rc=1 t=78s
W --repo <mkesh>           → KLETKI=50 ZELENYE=40 KRASNYE=10 (e1 e4 e7 e9 e17 c1 c3 c4 c5 c6: кеш)  rc=1 t=77s
W --repo <mread>           → KLETKI=50 ZELENYE=50 KRASNYE=0                    rc=0 t=77s   ← ЖИВОЙ (С-1b)
npm run check:antiplacebo -- --scope check_zones → «барьеров: 1 · фикстур: 42 · предъявлено красным повторным прогоном: 42»  rc=0 t=65s
bash fixtures/_krasnye_083.sh (OBJECT) → «083-батарея: ok=120 FAIL=0»          rc=0 t=59s
bash fixtures/_krasnye_083.sh (база 0eb88386a) → ok=119 FAIL=1, единственная «FAIL И0б/check_zones … rc=1: incr: check_zones судит 23a707f3..0eb88386 (1 коммит)»  rc=1 t=68s
bash -n scripts/check_zones.sh → rc 0
shellcheck 0.11.0 -S warning -f gcc: OBJECT rc 1, база rc 1 — по 9 находок (8×SC2034 :253/:268/:273/:285×3/:298/:302 + 1×SC2046 :1388 ≡ база :1233, та же строка mint_diff); множества равны; прежний OBJECT — 10 (лишняя SC2034 u_since)
bash scripts/gen_ci_steps.sh --check → rc 0
bash scripts/pre_critic.sh contracts/207-check-zones-incr-odin-sud-okna.md → «КРИТИК: дверь зелёная» rc 0
bash scripts/check_sdacha.sh "$PWD" contracts/207-check-zones-incr-odin-sud-okna.md --run → «СДАЧА: лист зелёный (двери=7 карта=17/17 дельта=2)» rc 0 t=220s
```

Замечания к прогонам:
- **Счёт shellcheck.** В задании — «11 строк: 8×SC2034 + 1×SC2046». Моя мера даёт 9 находок, по 8+1. Формат tty в обоих деревьях — 40 строк. Равенство с базой подтверждено; литерал «11» моей мерой не подтверждается.
- **Красная 083 на базе — среда, не регресс.** В моей копии `frozen/contracts/207/1` лёгкий (`git cat-file -t` → commit; в основном репозитории → tag). Окно И0б HEAD~1..HEAD на базе = REPLACE-коммит 207 → «не аннотированный». На OBJECT окно = коммит implementer без минта → зелено.
- **Конкуренция моих прогонов — честно.** Первый прогон `W --repo <mread>` дал rc 2 за 9 с: параллельно шёл мой же `pre_critic`. Повтор в одиночку дал rc 0, 50/50/0 — это и записано выше. Первый antiplacebo дал rc 1 «расхождений: 1 … прогон недостоверен»: во время прогона я сам записал файл `.review`. Повтор без записей дал rc 0 — записан выше.

## 4. «НЕ ЗАЩИЩАЕТ» — остаток

- ОСТАТОК: К-01 (полный режим; ловец — reviewer регресса) — **не укусил**. Укус вызова 1 (Б-1) снят. Полный режим OBJECT == база побайтно на wA/wB/wD и на e16/e17 (полный канон = зафиксированная база). Регресс семьи (antiplacebo) — rc 0, 083 на OBJECT — rc 0.
- ОСТАТОК: К-02 (ПРЕДСТОЯЩЕЕ v+1, REPLACE, гварды) — **не укусил**. Дифф вызова 2 этих ветвей не касается: REPLACE использует `add_nnn`/`rem_nnn`, правка — только `:704`/`:1186`/`:1790`.
- ОСТАТОК: К-04 (повтор вычисления вне Git-dispatch) — **не укусил**. Правка не добавляет ни одного вызова. Счётчики c1–c6 под strace — 1/1/1/1 (c2 1/1/0/0, c3 1/1/1/0, k0 0/0/0/0) в `W --repo .`.
- ОСТАТОК: К-05 (распознавание фикстуры) — **не укусил**. `grep 'probe207|check_zones_incr_207|zones/w[0-9]|PROBE|Фикстура|scratch|alice|041|077' scripts/check_zones.sh` → совпадений нет.
- ОСТАТОК: К-06 (секундный бюджет) — **не укусил**. И0б 083 на OBJECT зелёная при неизменном timeout 300; c4 (A2, 605 путей / 22 коммита) — 11,8 с. Правка вызова 2 стоимости не добавляет: одно присваивание.
- К-03 (тексты ОТКАЗ git-окружения; ловец — регресс семьи 040, не reviewer): дифф тексты не меняет.

## Паразитная сложность (050) — артефакты диффа вызова 2

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые файлы | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `own_nnn` (`:1186`/`:1790`) | И2/И3: ключ СПАСЕНО replay = свой контракт | явное, одна переменная итерации | 1 (было 1) | — | e16/e17, PROIZV-CLOB-SKIP | ESSENTIAL |
| `u_since` → `_` | — (уборка С-2) | убирает переменную | 1 | — | shellcheck | уменьшение |
| клетки e16/e17 + миры wA/wB | И2/И3 на «СПАСЕНО раньше ADD-минта» | одноразовые миры в TMPDIR | probe.py | — | `W --repo .` (CI) | ESSENTIAL |
| `PATERN:PROIZV-CLOB-SKIP` | связь Н-39 мутанта Б-1 с e16 | якорная замена | stabs.tsv + probe.py | — | `W --stabs`, лист | ESSENTIAL |
| `base/check_zones.sh` + `--base` | канон Б-1-клеток, стабильный до и после правки implementer (урок 208 Б-2; прецедент `normy_roley_svyazki_192/base/`) | статичный файл, `cmp` == `0eb88386a` | 1 | — | дверь листа «красное-до-на-зафиксированной-базе», e16/e17 | ESSENTIAL. Форма `git show 0eb88386a:…` проще по байтам, но привязывает канон к истории клона; в CI `fetch-depth: 0`. Совет не заводится. |
| `--delta model/proizv` | адресные дельты листа | флаг argparse | probe.py, SDACHA.md | — | `check_sdacha --run` (дельта=2) | ESSENTIAL |

## Сверки

- СВЕРКА-СТАНДАРТОВ: `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (`grep -c -i 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` → 0; файлов нет). Сверять не с чем — не применимо.
- СВЕРКА-АРХИТЕКТУРЫ: модели архитектуры и `bindings.json` нет, `tooling/checks/cli.js` отсутствует.
  - Размещение — правка внутри существующей двери.
  - Новых зависимостей, писателей и операций нет.
  - Долг не расширен: SC2034 уменьшен на 1.
  - diff модели — модели нет, L0. Находку 188 заводить некуда.
- Режим проекта (996): sourceCanon не объявлен — не применимо. Мобильного экрана нет.
- ПРОВОДКА (038): guard `red_check_zones_incr_207.sh` подключён строкой `check:zones-incr-207-family-selftest` (`--repo .`), строка не изменена. Новые e16/e17 входят в CI-прогон без правки реестров.

## Миры и скратч

Миры wA/wB/wD и мутанты строились в `$PWD/.scratch-rev207b` по одному и удалялись. Скратч удалён перед коммитом вердикта.
