FAIL
OBJECT=05807e003e7a350a4de0cc8403c189681a944ffa
СУД: repo=dev-harness; предмет=190; фаза=реализация; роль=reviewer; вызов=3/2; модель-план=anthropic/claude-opus-5-5; сессия=Rev190Scoped3M; SHA=05807e003e7a350a4de0cc8403c189681a944ffa; контракт=frozen/contracts/190/1; предыдущий=verdicts/review/contracts-190-impl-v2.md; исключение=одноразовое слово владельца 2026-11-15 ~00:00 UTC через консультанта (исполнение на сведённом M по решению консультанта ~00:55 UTC, форк forks/190-object-pred-sudom.md)
КЛАСС=обычный

# Вердикт reviewer — 190, реализация, вызов 3 (scoped, по слову владельца)

**FAIL.** Один блок, Б-1. CI-шаг 190 на M достаёт учётный `docs/190-zamer-svyazki.md` из объектов git (`git archive HEAD … docs/190-zamer-svyazki.md`) — в обход `ci_klass strip`. Замороженный 087 (`frozen/contracts/087/1`, §НЕ ЗАЩИЩАЕТ) прямо называет этот случай и назначает его ловцом ревьюера. Остальное в дельте чисто: три фикстурных коммита, синхронизация с main, неизменность frozen 190. Сбой job `obshchij` в попытке 1 — нестабильность батареи 083, а не дефект M. Accept v2 на этот OBJECT не переносится.

## Кандидат и область

```
$ git log --format='%H %P %an' -1 05807e00…   → 05807e00 f846b540… 438c3a9b… orchestrator (merge)
$ git merge-base --is-ancestor 8255f4cf 05807e00 → rc 1 (8255f4cf перебазирован в main как 51bdb222; land e8d8c3a65)
$ git diff --stat 8255f4cf 51bdb222 -- scripts/zamer_svyazki.* docs/190-zamer-svyazki.md fixtures/…/zamer_svyazki_190 → пусто
$ git diff --stat 8255f4cf 447559102 -- scripts/zamer_svyazki.sh scripts/zamer_svyazki.py docs/190-zamer-svyazki.md → пусто (реализация с v2 не менялась)
$ git diff --stat 5d5e3a4d 0ff35daf -- fixtures/…/zamer_svyazki_190 contracts/190-… → пусто (семья v2 = перебазированный 0ff35daf)
$ git diff --stat 447559102 05807e00   (447559102 = merge-base с origin/main)
 .github/workflows/ci.yml | 12 · _zamorozka/190-zamer-svyazki.md | 92 · probe.py | 261 · source.json | 5 · registry/ci-steps.tsv | 4 · registry/ci-zamery.tsv | 4
$ git diff --stat 438c3a9b 05807e00 → HANDOFF.md, _zamorozka, probe.py, source.json (дерево M не подменено)
$ git diff --stat frozen/contracts/190/1 05807e00 -- contracts/190-zamer-svyazki.md → пусто, rc 0
```

PR #907: `headRefName=wip/190/orchestrator`, `headRefOid=05807e00…`, `MERGEABLE`, `OPEN`. Ветка `wip/190/architect` тоже указывает на M.

## (1) CI-проводка 190 — Б-1

Шаг на M, `registry/ci-steps.tsv:309`:

```
step check:zamer-svyazki-190-family-selftest 4 bash …/red_zamer_svyazki_190.sh --stabs && bash -n scripts/zamer_svyazki.sh && T=$(mktemp -d) && trap 'rm -rf "$T"' EXIT && git archive HEAD fixtures/workshop_project/zamer_svyazki_190 scripts/zamer_svyazki.sh scripts/zamer_svyazki.py docs/190-zamer-svyazki.md | tar -x -C "$T" && bash "$T"/fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
```

Что здесь в порядке:
- Суд без флага идёт по настоящей реализации: в `probe.py:769-802` для режима без флага `doc_root = TOOLS`, а `TOOLS = HERE.parents[2]` (`:53`), то есть `$T`. Субъект — `$T/scripts/zamer_svyazki.sh`.
- Субъект и документ совпадают с проверяемым HEAD: checkout `ref: 05807e003e…` (лог job), strip сверяет рабочее дерево с HEAD.
- `--stabs` и `bash -n` сохранены.
- frozen 190 не ослаблен.

Норма, против которой шаг идёт:
- frozen 087 §ЗАЩИЩАЕТ: «тяжёлый вердикт, зависящий от учётных путей: тяжёлые шаги исполняются на дереве без учётных путей».
- frozen 087 §НЕ ЗАЩИЩАЕТ: «чтение учётного содержимого тяжёлым шагом через объекты git (`git show HEAD:<учётный путь>`) в обход strip — ловец ревьюер».
- `registry/ci-steps.tsv:33` — `uchet docs/`.
- `registry/ci-steps.tsv:46-48`: учёт-независимость обеспечивают `_zamorozka/`.

Сырой CI, job l3 (132645724892):

```
Run bash scripts/ci_klass.sh strip d5fb06ab…
strip: удалено учётных путей 2272, кодовое дерево H=d5fb06aba64654a12e0a03f6c4ca7503b54a3b2b579534fed3d4054730aac18b
+ bash …--stabs && … git archive HEAD … docs/190-zamer-svyazki.md | tar -x -C "$T" && bash "$T"/…
ИТОГ 190: клеток 34, зелёных 34, красных 0; СВЯЗИ 19, поймано 19, жив 0
ИТОГ 190: клеток 34, зелёных 34, красных 0; СВЯЗИ 0, поймано 0, жив 0
```

Удалённый strip-ом документ возвращается из объекта git, и тяжёлый суд читает его байты.

**Достижимость — своя мера.** Одноразовый SSH-клон `/tmp/dev-harness-verify/Rev190Scoped3M/repo` со своим `.git`. Зонд `/tmp/dev-harness-verify/Rev190Scoped3M/probe_uchet.sh` строит M' = M плюс одна правка строки канона в `docs/190` и делает это через plumbing-коммит: без checkout, без push, под identity reviewer.

```
Mprime=1db065fdb375ce6744805533c9f87f423a601d49
 docs/190-zamer-svyazki.md | 2 +-
hash M : d5fb06aba64654a12e0a03f6c4ca7503b54a3b2b579534fed3d4054730aac18b
hash M': d5fb06aba64654a12e0a03f6c4ca7503b54a3b2b579534fed3d4054730aac18b
klass M M': uchet
git archive M  docs/190 canon line sha256: b5f70dbf6d926d7e99e5a56edf4c8d1efe05b74b7c6b35dbba351e7badc1cfad
git archive M' docs/190 canon line sha256: 4ed63a2c7c1c8e1b92d40c1f7dc3849b85a0913ae81d1b5cc8d4b7a90706973a
_zamorozka canon line sha256 (M'):        b5f70dbf6d926d7e99e5a56edf4c8d1efe05b74b7c6b35dbba351e7badc1cfad
rc=0
```

У M и M' один кодовый хеш H, класс правки — `uchet`, а шаг 190 читает для них разные байты канона. По коду (`probe.py:445-452`, `:611-640`) M' даёт RED `dokument-kanon` и RED `kanon-drift-kopii` [INFERENCE: батарею по заданию не запускал]. Тяжёлые прогоны на M прошли (`tyazhelyj-itog` success), то есть артефакт `tyazhelyj-<H>` есть. Отсюда два последствия.
- Правка только `docs/190` (зона implementer) получает `tyazh=reuse`: правку канона тяжёлый суд не видит.
- Следующий кодовый PR с новым H краснеет на 190 по чужой причине. Это ровно тот контрпример, по которому architect в `f1dbea4081` отверг чтение git HEAD: «два HEAD с одним H и разными документами давали разные исходы тяжёлой проверки, reuse артефакта не доказывал результат».

**Как дошло до этого.** Красный `--repo .` в job 132034648114 был на `head_sha=6d1f5f9a`. В этом коммите ещё не было фолбэка architect: `b5f0bece`…`f846b540` легли позже, 13.11 19:06–19:55, на другую ветку. Обход `438c3a9b` (14.11 20:01) лечил дерево без фолбэка. На M есть оба механизма, и обход избыточен.

Более простая форма, которая проходит те же строки приёмки:

```
bash …/red_zamer_svyazki_190.sh --stabs && bash -n scripts/zamer_svyazki.sh && bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh
```

Это суд без флага в strip-дереве. Strip удаляет все файлы `docs/` и подрезает пустые каталоги (`ci_klass.sh` c_strip). `kanon_istochnik` (`probe.py:406-442`) видит пустой `docs/` и читает `_zamorozka`, а её блоб равен документу (ниже). Ожидаемый исход — 34/34 [INFERENCE по коду; ведущему проверить, см. конец]. Такое лечение 087 и предписывает: «правка фикстуры, не расширение U».

Прочее по (1):
- ПЕРЕСЕЧЕНИЕ. Дельта M против main меняет и чужие строки: 157 (`:287`, 30→90, `+ probe.py --stabs`) и новый шаг 189 (`:308`), всё в коммите `93629cb651` «шаги 157, 189, 190». Это санкционировано словом владельца: HANDOFF.md:155 и :190, «Патч station-ci-wiring.patch своим коммитом → PR → CI → done 157, 189, 190». Не блок. Строки 157 и 189 судят предметы 157 и 189, не этот вердикт.
- Перестановка lane в ci.yml — вывод `gen_ci_steps` (LPT). В CI на M: 083 Г1 `gen_ci_steps.sh --check rc 0` ok, Г3 ok.

## (2) Три фикстурных коммита architect — чисто

- Авторство и зона. `b5f0bece8f`, `f1dbea4081`, `f846b540ee` — author и committer `architect`. Пути — только `fixtures/workshop_project/zamer_svyazki_190/` (`probe.py`, `source.json`, `_zamorozka/190-zamer-svyazki.md`). `dannye/`, `model/`, `stabs/` и привязки `stab_vhod` не тронуты.
- Клетки не ослаблены. Нетто-удаление в `probe.py` — только прежняя встроенная проверка: 4 строки `if not doc.is_file(): … header not in doc…`. Её заменил `sud_kanon` с той же побайтовой проверкой.
- Добавлено 6 клеток-контролей: `kanon-podmena`, `kanon-otsutstvuet`, `kanon-strip`, `kanon-strip-podmena`, `kanon-strip-lozhnyj`, `kanon-drift-kopii`. 28 + 6 = 34, и CI показывает 34/34.
- Подгонки под код нет: реализация с 8255f4cf не менялась (diff пуст), правка касается только источника канона.
- Strip отличим от обычного отсутствия. Признак структурный: под `docs/` нет ни одного файла (`_fajly_pod_docs`, `:392-404`). Если остался хоть один чужой файл — это «отсутствует», RED (`:427-435`). Клетка `kanon-strip-lozhnyj` строит ровно такой мир: копия и git HEAD несут правильный канон, а отказ обязан называть «отсутствует». В живом дереве под `docs/` сотни файлов, так что обычное удаление `docs/190` краснеет.
- Копия — копия документа:

```
$ git rev-parse M:docs/190-zamer-svyazki.md M:fixtures/…/_zamorozka/190-zamer-svyazki.md
413dfc67e4db5d0911bb76747b18907dc78ba453
413dfc67e4db5d0911bb76747b18907dc78ba453
$ git show M:…/_zamorozka/190-zamer-svyazki.md | sha256sum → 1b9abae7…f465 = пин source.json:14
```

- Строка канона копии = `b5f70dbf…cfad`. Тот же хеш у контракта, документа и инструмента в v2.

## (3) Синхронизация с main — чисто

- `0ff35daf` (перебазированный `5d5e3a4d`, дерево семьи равно) — предок `f846b540`, ff=0. Ветка автора продвинулась без переписи: `0ff35daf` → (main `447559102`) → `b5f0bece` → `f1dbea40` → `f846b540`.
- `447559102` лежит в origin/main. Это merge-base M и origin/main `35eefa87`.
- В `447559102..origin/main` ни один путь 190/ci-steps/ci-zamery/ci.yml/ci_klass не тронут.

## Raw CI PR #907, run 43659587468

```
run_attempt=2 head_sha=05807e003e… conclusion=success pull_requests=[907]
попытка 1: obshchij failure (132645724760); klass/legkij/ci l1-l7/antiplacebo ap1-ap5 success; tyazhelyj-itog skipped
попытка 2: obshchij success (132654435823), tyazhelyj-itog success (132655511948)
```

Попытка 1, obshchij:

```
red_ci_a_083.sh: line 1522: printf: write error: Broken pipe
FAIL И0б/check_charter: … ждали rc 0 + маркер '(7 коммит' + кеш=HEAD; rc=0: incr: check_charter судит f846b540..05807e00 (7 коммитов)
ok И0б/check_zones · ok И0б/check_ids · ok И0б/check_protected
083-батарея: ok=119 FAIL=1
```

Попытка 2, тот же SHA: `ok И0б/check_charter: непустое окно: маркер с истинным N=7, кеш перезаписан HEAD`, `083-батарея: ok=120 FAIL=0`.

Оценка — **нестабильность, не дефект M.** В `fixtures/ci_gen_083/red_ci_a_083.sh:1522` стоит `printf '%s' "$out" | grep -q …` под `set -uo pipefail` (`:165`). `grep -q` выходит на первом совпадении, printf получает EPIPE, pipefail гасит условие. В той же строке FAIL видны и `rc=0`, и маркер `(7 коммитов)`. На том же SHA исход разный — это гонка. Совет — за 083 (Н-9). На этот вердикт сбой не влияет.

## ПРОВОДКА (038)

- `guard=scripts/zamer_svyazki.sh` существует.
- В шаге стоит `bash -n scripts/zamer_svyazki.sh`, сам guard исполняется батареей как субъект — из `$T`, побайтовой копии HEAD.
- ПРОВОДКА-ЭНФОРСМЕНТ честен: батарея идёт bash-обёрткой.
- Канал подключён. Дефект канала — источник байтов документа (Б-1).

## Паразитная сложность (050)

- **Ветвь `T=… git archive HEAD … | tar …` в шаге `ci-steps.tsv:309`.**
  1. Свойство «безфлаговый суд» (frozen 190 §Зоны) выполняется и без неё.
  2. Вводит скрытое состояние: байты учётного пути из объекта git, в H не видны.
  3. Число файлов, меняющихся вместе: 1 + ci.yml — не выросло.
  4. Интерфейса нет.
  5. Повторяет то, что уже делает фолбэк `_zamorozka`.

  **ACCIDENTAL, блокирует.** Три части названы: фрагмент — `:309`; нарушенное свойство — учёт-независимость тяжёлого шага (087); более простая форма — суд без флага в strip-дереве, выше.
- **`kanon_istochnik`/`_fajly_pod_docs`/`_zamorozka` + пин.**
  1. frozen 190 «отсутствие — красная» при 087.
  2. Состояние явное: путь фиксирован и пинован.
  3. Вместе меняются 3 файла: документ, копия, пин.
  4. Интерфейс не менялся.
  5. Потребитель — шаг CI в простой форме.

  **ESSENTIAL**, если принять исправление Б-1. Сейчас фолбэк в CI мёртв: `$T` несёт `docs/190`.
- **Клетки `kanon-*` (одна семья).** Держат функцию суда канона против самоэха, безусловного фолбэка и чтения HEAD. ESSENTIAL.

## СВЕРКА-СТАНДАРТОВ

Неприменимо:
- `git show M:AGENTS.md | grep -E 'ARCHITECTURE|CODING-STANDARDS|sourceCanon'` → пусто, rc 1;
- `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` в дереве M нет.

Мобильного экрана нет.

## Находки (reslop, status: ready)

- [ ] **Б-1 (блок; orchestrator; дефект проводки по frozen 087 §НЕ ЗАЩИЩАЕТ п.3 / §ЗАЩИЩАЕТ п.4).**
  - Где: `registry/ci-steps.tsv:309` (и генерат в ci.yml не меняется — ключ тот же).
  - Что: `git archive HEAD … docs/190-zamer-svyazki.md` возвращает учётный документ после strip. Исход тяжёлого шага зависит от байтов вне H: M/M' с H=d5fb06ab… дают разные байты канона, `klass=uchet`.
  - Лечение: убрать ветку `T=…git archive…tar` и судить без флага в strip-дереве (фолбэк `_zamorozka` уже на M). Затем `gen_ci_steps.sh --write`/`--check`, `check_provodka`.
- [ ] **Н-8 (наблюдение, 157/189).** PR #907 несёт проводку 157 (`:287`) и 189 (`:308`) по слову владельца (HANDOFF:155, :190). Судятся в своих предметах.
- [ ] **Н-9 (совет, 083).** Гонка SIGPIPE в `fixtures/ci_gen_083/red_ci_a_083.sh:1522` (и симметричная `:1505`): `printf | grep -q` под pipefail. Форма без гонки — `grep -q … <<<"$out"`.
- [ ] **Н-10 (наблюдение).** Дерево `--repo R` без единого файла под `docs/` суд принимает за strip и читает копию. В дереве станции недостижимо, вне Б-1.
- Советы v2 (С-6…С-8, Н-4…Н-7) дельтой не затронуты. Н-6/Н-7 сняты: семья слита, ячеек 34.

Которые счётные утверждения задания проверены своей мерой:
- 34/34 и 19/19 — по сырому логу CI, не по пересказу;
- frozen 190 — пустой diff;
- копия = документ — по блобу;
- H — `ci_klass.sh hash` в клоне.

Заявление ведущего «28/28, 19/19 на 438c3a9b» относится к другому SHA, без фикстур architect, и сюда не засчитывается.

## Закрытие

FAIL применим к OBJECT `05807e003e7a350a4de0cc8403c189681a944ffa`. По заданию вызов единственный, новых кругов нет.

Узкая проверка ведущему — в одноразовом клоне на M, после `bash scripts/ci_klass.sh strip $(bash scripts/ci_klass.sh hash HEAD)`:
- (а) `bash fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh` → ожидается 34/34 rc 0 (простая форма);
- (б) текущая форма шага на M' (коммит `1db065fd` в моём клоне `/tmp/dev-harness-verify/Rev190Scoped3M/repo`, не запушен) → ожидаются RED `dokument-kanon` и `kanon-drift-kopii`.

Клон и зонд `probe_uchet.sh` одноразовые: push не делался, общий checkout не тронут, сборку и тесты я не запускал.
