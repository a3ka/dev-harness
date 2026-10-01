FAIL

# Reviewer 067: круг 1 — isolation.backend: auto

Предмет: `frozen/contracts/067/1` (tag-object `cd41703` → коммит `29aa3ec`), `contracts/067-isolyacija-backend-auto.md`.
Судимый HEAD: `fd66ed4` (land `wip/067/implementer`, = origin/main клона). Реализация — `245f90e` (implementer,
родитель `244a68a`). В задании она названа `942b604`. Это тот же коммит до перекоммита: тот же родитель `244a68a`,
то же дерево `d3bf235`, та же авторская дата 11:45:09, отличается только дата коммитера. `942b604` не достижим ни
из одной ссылки клона. Клон суда: `/tmp/dev-harness-verify/rev067`. Его я не правил, кроме этого файла.
Своя мера лежит отдельно: ДО-клон `rev067-before` (на `244a68a`), мутант-клон `rev067-mut` (патчи через
`git apply`, после прогона откачен) и пробы `rev067-probe/p1…p8` (конфиги написаны инструментом записи).

| артефакт | блоб HEAD |
|---|---|
| `scripts/check_runner_hygiene.sh` | `e752627` |
| `.omp/config.yml` | `b1f8d3d` |
| `fixtures/check_runner_hygiene/_lib.sh` | `ca8e5f6` |
| `roles/architect.md` / `.omp/agents/architect.md` | `3d873a5` / `697b88a` |
| `roles/orchestrator.md` / `.omp/agents/orchestrator.md` | `1857e50` / `fda1755` |
| `fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh` (заморожен) | `1701ee3` |
| `contracts/067-isolyacija-backend-auto.md` (заморожен) | `269706b` |

Вердикт связан с этими блобами. Новая редакция любого из них принятия не наследует.

## Стенограммы спавна и моя сверка

- Детектор: rc 0 (HEAD `fd66ed4` = origin, 0/0). Это слово оркестратора, я его не перепрогонял. В клоне
  `git rev-parse HEAD origin/main` дал `fd66ed4` дважды, `git status --short` пуст.
- CI: оркестратор пишет «зелёный abe86c2, поле 067 после». Сверил `gh run list`: `244a68a` (freeze) — success
  (id 36855953287). Прогон ленда `fd66ed4` (id 36857427873) **отменён** («higher priority waiting request»):
  `ci` и ap1 помечены X по отмене, ap2–ap5 success. Новее завершённых прогонов, покрывающих `fd66ed4`, на момент
  суда нет: `976ce10` (adversary) был in_progress. **CI для реализации 067 НЕ ПРОВЕРЕН.**
- Приёмка scoped (Н-48): батарея 067, ветви izolcfg/klon/izolnorm и полный барьер на живом дереве, gen,
  provodka, precision, zones. Полный verify_antiplacebo я не гонял.

## Сырой вывод (живые прогоны, клон суда на `fd66ed4`)

```text
$ bash fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh .
ВЕТВЬ к1-norma-avto … к8-vykljucheno-s-backend — все 8 зелёные
ИТОГ 067: ветвей 8, красных 0, зелёных 8                                   rc=0
$ bash scripts/check_runner_hygiene.sh . izolcfg
  ok   (izolcfg) .omp/config.yml: task.isolation.enabled: true + верхнеуровневая isolation.backend: auto   rc=0
$ bash scripts/check_runner_hygiene.sh . klon                              rc=0
$ bash scripts/check_runner_hygiene.sh . izolnorm                          rc=0
$ bash scripts/check_runner_hygiene.sh .          (все 19 ветвей)          «ветви all зелены»  rc=0
$ omp config get isolation.backend --json        → "value": "auto"         rc=0
$ omp config get task.isolation.enabled --json   → "value": true           rc=0
$ git diff --exit-code frozen/contracts/067/1 fd66ed4 -- contracts/067-… fixtures/…/red_izolcfg_backend_avto_067.sh
(пусто)                                                                    rc=0
$ reslop t -- npm run -s check:gen                                         exit: 0
$ bash scripts/check_provodka.sh . contracts/067-isolyacija-backend-auto.md          rc=0
$ bash scripts/check_precision_gate.sh . contracts/067-isolyacija-backend-auto.md    OK  rc=0
$ bash scripts/check_zones.sh
замороженных контрактов: 68 · … · проверено по зонам: 1531                  rc=0
$ case_izolcfg_bez_kljucha.sh (WORK/BARRIER вручную): зелёный корень ok; обманка — ОТКАЗ NO_KEYS   rc=1 (ожидаемо)
```

Первый параллельный прогон `check_zones` вместе с `check_precision_gate` упал с rc 1 на
`cp: cannot stat '/tmp/lib_zones.823e6809.*/zones_scoped'`. Две копии `lib_zones` делят один временный префикс.
Последовательный повтор дал rc 0. Это не 067 (см. С-4).

**Красное ДО** (своя мера, клон `rev067-before` на `244a68a`, до ленда реализации):

```text
$ bash fixtures/check_runner_hygiene/red_izolcfg_backend_avto_067.sh .
ВЕТВЬ к1-norma-avto красная (v1: rc=1 «не несёт … mode: btrfs»)
ВЕТВЬ к2-stab-legasi-pin красная (v1: rc=0 «ok (izolcfg) … mode: btrfs»)
ВЕТВЬ к8-vykljucheno-s-backend красная (rc=1 без «enabled: false»)
ИТОГ 067: ветвей 8, красных 3, зелёных 5                                   rc=1
$ omp config get isolation.backend --json → "btrfs";  task.isolation.enabled → true
```

3 красных (к1, к2, к8) подтверждены. Заявление контракта 8/3/5 → 8/0/8 сходится с моим замером. Число 8 проверено
другой командой: `grep -cE '^run_cell '` даёт 8, элементов `к[0-9]` в `ORDER=(…)` тоже 8.

**Свой мутант** (обход «v2 судит backend, игнорирует enabled»: удалены обе enabled-проверки END-блока,
`mut-ignore-enabled.patch`):

```text
ВЕТВЬ к8-vykljucheno-s-backend красная: … получено rc=0: ok (izolcfg) …
ИТОГ 067: ветвей 8, красных 1, зелёных 7                                   rc=1
```

Мутант пойман. Клетка Б2 (к8) работает как различитель.

## СТРОГОСТЬ: реализация после заморозки

**Соблюдена.** Тег `frozen/contracts/067/1`: tagger orchestrator, 2026-10-01 11:31:22 UTC, на `29aa3ec`. Freeze-коммит
реестра `244a68a` — 11:31:22. Реализация `245f90e`: автор и коммитер implementer, авторская дата 11:45:09,
единственный родитель `244a68a`. Коммиты architect по 067 до заморозки (`cce5bc8`, `2a9f878`, `5957e12`) трогают
только `contracts/067-…` и `red_izolcfg_backend_avto_067.sh`. Это видно по
`git log --name-only c3fdd74..244a68a` по путям реализации. Ни один путь реализации architect'ом не тронут.
Frozen-diff пуст.

## Добросовестность критика

Круг 1 `4305580` — FAIL (Б1 Н-39, Б2 «критерий не доказывает включение изоляции»). Круг 2 `de501ae` — FAIL.
Арбитр `9548be3` — 067-Б1. МИНИ `29aa3ec` — accept. Б2 дал клетку к8, и мой мутант подтверждает, что она живая.
Упрёк, не блокер: инв. 4 («грамматика структурна», «значение с хвостом не совпадают») ни одной клеткой не
исполняется. Структурную границу секций в батарее не стережёт ни одна клетка (к7 проверяет только backend под
task.isolation), поэтому Р-1 и Р-2 ниже прошли батарею 8/8.

## Находки (reslop)

status: ready

- [ ] **Р-1 (блокирует; инв. 1 и 4, Модель угроз «ЗАЩИЩАЕТ … перепутанный путь ключа»).** Ветвь izolcfg v2 не
  держит границу секций и даёт `ok` на конфиге, где omp фактически **выключает** изоляцию.
  Фрагмент `scripts/check_runner_hygiene.sh:839-843`: `in_task` сбрасывается только из `in_task_isol` или на
  `isolation:`, а `in_task_isol` не закрывается на соседнем ключе `task:`. v1 (`244a68a`) выходил на любой новой
  верхнеуровневой строке (`t && /^[^#[:space:]][^:]*:/ { exit }`), так что это регрессия диффом. Своя мера:
  - p4 `task:`/`  maxConcurrency: 4` + `retry:`/`  isolation:`/`    enabled: true` + верхний `isolation:`/`  backend: auto`
    → барьер **rc=0 ok**, `omp config get task.isolation.enabled` → **false**. Контроль v1 на том же классе
    (p7, `retry.isolation.mode: btrfs`) → rc=1.
  - p8 `task:`/`  isolation:`/`    enabled: false`/`  other:`/`    enabled: true` + верхний `backend: auto` → барьер
    **rc=0 ok**, omp → **false**. Это дефект клетки к8 (enabled: false при правильном backend), обойдённый соседней
    подсекцией.

  Простая форма проверена в мутант-клоне (`fix-structure.patch`): две строки после правила
  `/^isolation:/` — `/^[^[:space:]#]/ { in_task = 0; in_task_isol = 0; in_top_isol = 0; next }` и
  `in_task_isol && /^  [^[:space:]#]/ { in_task_isol = 0; next }`. Результат: батарея 8/0/8 rc 0, живое дерево ok,
  p4 → rc=1 HALF, p8 → rc=1 «ENABLED: false», p5/p6 по-прежнему отказ. Adversary (`976ce10`) независимо нашёл тот же
  класс (sibling/deep).
- [ ] **Р-2 (блокирует; инв. 4 дословно: «сравнения литеральны (`backend:[[:space:]]*auto`) — … значение с хвостом не
  совпадают»).** Фрагмент `:853-854`: `backend = $2` берёт первое слово значения. p1 `backend: auto btrfs` →
  **rc=0 ok**. В рантайме omp откатывается к дефолту `auto` (`omp config get` → `auto`), так что вред в рантайме
  нулевой, но замороженное обязательство нарушено. Форма лечения: литеральный якорь
  `backend:[[:space:]]*auto[[:space:]]*(#.*)?$` вместо `$2`. Для enabled это уже так: `enabled: true x` не совпадает.
- [ ] **Р-3 (050 ACCIDENTAL, блокирует по правилу трёх частей).** Фрагмент `:869-872`
  `if (have_enabled && enabled != "true") { print "ENABLED_INVALID…" }` — недостижим. `have_enabled = 1` ставится
  только правилом с якорем `(true|false)[[:space:]]*$`, поэтому `enabled ∈ {true,false}`, а false отсечён строкой выше.
  Свойства за ним нет. Простая форма — удалить блок. Проверено `drop-enabled-invalid.patch`: батарея 8/0/8 rc 0.
- [ ] **С-1 (совет).** `2>/dev/null` на awk (`:891`) глушит синтаксические ошибки awk. Отказ при этом остаётся
  закрытым, но причина пуста: `reason` = "" при пустом файле, и запасной текст «причина не записана» срабатывает только
  при сбое `cat`. 3-аргументный `match()` — gawk-only, но прецедент в дереве есть (`check_approval.sh:68`), CI на
  ubuntu-latest его уже исполняет.
- [ ] **С-2 (совет).** p3 `isolation:`/`  extra:`/`    backend: auto` → ok (`^[[:space:]]+backend:` любой глубины).
  Вреда в рантайме нет (дефолт omp — auto). При лечении Р-1 можно тем же якорем `^  backend:` закрыть и это.
- [ ] **С-3 (совет).** Охраны `!in_top_isol` и `!in_task_isol` в правилах регистрации (`:846-853`) избыточны: флаги
  взаимоисключающие по построению, каждое правило входа обнуляет другой флаг. Комментарий `:844-845` обещает
  разбор «пересечения», которого не бывает.
- [ ] **С-4 (совет, не 067).** `lib_zones.sh` делит префикс `/tmp/lib_zones.<hash>.*` между параллельными вызовами
  (`check_zones` ‖ `check_precision_gate`), и один прогон стирает временные файлы другого. Отсюда rc 1 при
  параллельном запуске.
- [ ] **С-5 (совет, батарея).** Лечение Р-1/Р-2 стоит закрепить клетками sibling/чужой-родитель/хвост с ожиданием
  reject (red-батарея 067 или новая red-* в той же семье, зона implementer `fixtures/check_runner_hygiene/`).
  Замороженные Р1–Р8 таких клеток не требуют, поэтому это совет, а не условие.

## Паразитная сложность (050)

- **awk-программа ветви izolcfg v2 (`:828-894`, +98/−~10)** — (1) инв. 1–4 (пара, легаси-пин, половина нормы,
  литеральная структурная грамматика); (2) состояние — временный `$WORK/izolcfg.reason` в собственном скратче барьера
  (cleanup `:166`); причина видна в выводе `die`, это явно; (3) при следующей правке нормы изоляции вместе
  меняются конфиг, toy `_lib.sh`, барьер и две роли с генератами, как и до диффа (инв. 5), число не выросло;
  (4) интерфейс прежний (ключ ветви `izolcfg`, rc 0/1), работа выросла — модуль углубился; (5) потребители —
  CI `ci.yml:393` (`check:runner-hygiene`, живое дерево), шард ap1 (`case_izolcfg_bez_kljucha`), батарея 067.
  ESSENTIAL, кроме Р-3 (мёртвая ветвь) и С-3 (избыточные охраны).
- **Восемь именованных причин (LEGACY_MODE … NO_KEYS)** — (1) «отклонения с именованной причиной» (инв. 3,
  Незаполненные (б)); (5) потребитель — grep -F `enabled: false` клетки к8. ESSENTIAL, кроме ENABLED_INVALID (Р-3).
- **Пара ключей в `.omp/config.yml` и toy `mk_norm_isol`** — (1) инв. 1, 5, 7; (2)–(4) без нового состояния;
  (5) omp-проба → auto/true, зелёный корень семьи. ESSENTIAL.
- **Строки ролей и генераты** — (1) Незаполненные (г); (3) роль и генерат меняются парой (gen rc 0). ESSENTIAL.

## Проверки роли по пунктам

1. Область: 7 путей. `scripts/check_runner_hygiene.sh` и `fixtures/check_runner_hygiene/` — ЗОНА implementer 067;
   `.omp/config.yml` — implementer 002/012/025; `roles/architect.md` и `roles/orchestrator.md` — implementer 012;
   `.omp/agents/` — implementer 002/003. Своя мера — `grep '^ЗОНА implementer:'` по контрактам, плюс `check_zones` rc 0. ✓
2. Сырой вывод — выше. ✓ CI для `fd66ed4` НЕ ПРОВЕРЕН (отменён).
3. Проверки не подогнаны: батарея и контракт после заморозки не тронуты (frozen-diff пуст, `git log 244a68a..fd66ed4`
   по ним пуст). `_lib.sh` переведён по инв. 5 и на оракулы клеток не влияет: клетки сами пишут конфиг. ✓
4. Красное: ДО 8/3/5 rc 1 (своя мера на `244a68a`), свой мутант 8/1/7 rc 1. ✓ Но для свойства инв. 4 красного нет,
   поэтому Р-1/Р-2 прошли.
5. Атомарность: один implementer-коммит `245f90e` со ссылкой на 067 (инв. 5 — одним коммитом). ✓
6. Норма не тронута: роли изменены только в ссылках на ключи (Незаполненные (г)); норма-строк ПРОВОДКА не касались. ✓
7. Заявленное = сделанному: 8/0/8 и 8/3/5 своей мерой, другой командой (подсчёт `run_cell` и `ORDER`). omp-проба
   auto/true; ДО — btrfs/true. ✓ Заявление «барьер судит пару + legacy + enabled» верно на 8 клетках и ложно на
   структурных входах p4/p8 (Р-1).

ПРОВОДКА: `guard=scripts/check_runner_hygiene.sh` существует. Ветвь izolcfg — барьер именно этого предмета, в CI
подключена `ci.yml:393` (живое дерево) и шардом ap1. ПРОВОДКА-ЭНФОРСМЕНТ честна: норма — состояние конфига, роли
лишь синхронизируют ссылку. ✓

## Вердикт

**FAIL.** СТРОГОСТЬ соблюдена: реализация — отдельный implementer-коммит после заморозки. Батарея 8/0/8, ДО 8/3/5,
omp auto/true, frozen-diff пуст, gen/provodka/precision/zones rc 0. Слияние блокируют:
- Р-1 — структурная дыра: барьер даёт ok на конфигах, где omp выключает изоляцию. Это регрессия против v1.
- Р-2 — хвост значения backend, прямое нарушение инв. 4.
- Р-3 — мёртвая ветвь ENABLED_INVALID.

Лечение Р-1 проверено: две строки, батарея 8/0/8. С-1…С-5 — советы.
