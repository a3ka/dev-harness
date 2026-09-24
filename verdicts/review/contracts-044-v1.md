FAIL

# Контракт 044 — первый круг ревьюера

Предмет: `contracts/044-bulk-peresnjatie-bazlajna.md` (заморожен
`frozen/contracts/044/1` → `f7eb7759145465ade1d5d30519c30c3050d1a53f`, коммит
`aace01dd1f1b4959bcea061fc54c3e5e485934ba`) и его реализация
`scripts/check_no_leak.sh`, семья `fixtures/check_no_leak/`.

Свежие SSH-клоны `origin`, оба на HEAD = origin/main =
`3de912d800e24280e332f4d322fee4f4f15e1fbb`: `/tmp/rev044` (замеры) и
`/tmp/dev-harness-verify/reviewer-044` (коммит вердикта).

```text
$ git remote -v
origin	ssh://git@github.com/a3ka/dev-harness.git (fetch)
origin	ssh://git@github.com/a3ka/dev-harness.git (push)
```

Прочитаны целиком: контракт; `verdicts/critic/contracts-044-v1.md` в ОБЕИХ
редакциях (`7bff616` — FAIL первого круга, `aace01d` — консолидированный accept);
`verdicts/adversary/contracts-044-v1-adversary.md` (`622d2e5`);
`verdicts/adversary/contracts-044-v1-adversary-fix.md` (`3de912d`);
`scripts/check_no_leak.sh:1397-1765`; `fixtures/check_no_leak/`
(`red_bulk_peresnjatie_bazlajna.sh` — сам текст фикстуры, не отчёты о ней,
и `.probe-only`). Чужой код ревьюер не правил; постоянная дельта ревьюера —
только этот вердикт.

## Блокирующая находка

### Р1 — закрытие блокера Б7б адверсария НЕ ПРИЖАТО ни одной клеткой фикстуры

Класс: **красное не предъявлено постоянной мерой** (обязанность 4 роли) + **заявленное
≠ сделанное** (обязанность 7).

Адверсарий (`verdicts/adversary/contracts-044-v1-adversary.md`) назвал авторскую
правку ДВУМЯ частями дословно: «сузить предикат до буквальной грамматики
`contracts/<M>-*` … **и добавить красные варианты без дефиса**». Исполнитель сделал
ТОЛЬКО первую часть: `872132b` трогает ровно один путь —

```text
$ git show --stat --format='' 872132b
 scripts/check_no_leak.sh | 119 +++++++++++++++++++++++++++++++++++++----------
 1 file changed, 94 insertions(+), 25 deletions(-)
```

Вердикт адверсария о закрытии (`3de912d`) проверил живьём только поведение кода и
факт отсутствия клеток не назвал. Семья `fixtures/check_no_leak/` после `952267f`
не менялась ни на байт; в её ВХОДАХ по-прежнему ровно б0–б10 и бб1–бб6 — клеток на
грамматику без дефиса и на пост-freeze руку А нет.

**Измерено мутантами (своя мера ревьюера, не повтор гарнизона адверсария).**
Мутант 1 — из живого `scripts/check_no_leak.sh` удалена ровно строка проверки
четвёртого байта (`[ "${base:3:1}" = "-" ] || return 1` → no-op). Мутант 2 — из того
же файла обезврежен пост-freeze `return 1` внутри общего цикла
`frozen/contracts/<M>/*`. Собственная проба ревьюера (свой toy: строгий реестр, зона
architect = ровно `contracts/001-x.md`, свой bare origin, снимок вне toy) на живом
коде и на мутантах:

```text
# ЖИВОЙ код (HEAD 3de912d) — Б7б действительно закрыт:
nodash      path=contracts/123not-a-draft.md  check_before=1 retake=1 check_after=1 snap_intact=yes
    вывод: ОТКАЗ: переснятие-bulk не доказано: путь contracts/123not-a-draft.md не покрыт ни одной зоной
underscore  path=contracts/123_not_a_draft.md check_before=1 retake=1 check_after=1 snap_intact=yes
    вывод: ОТКАЗ: переснятие-bulk не доказано: путь contracts/123_not_a_draft.md не покрыт ни одной зоной
bare        path=contracts/123                check_before=1 retake=1 check_after=1 snap_intact=yes
    вывод: ОТКАЗ: переснятие-bulk не доказано: путь contracts/123 не покрыт ни одной зоной
legit       path=contracts/123-legit.md       check_before=1 retake=0 check_after=0 snap_intact=NO
    вывод: базлайн переснят: bulk-дельта contracts/123-legit.md (автор architect, коммит 2c212fce…)|базлайн переснят: bulk-дельта — путей 1, незакоммиченного/неслитого 0
postfreeze  path=contracts/123-evil.md        check_before=1 retake=1 check_after=1 snap_intact=yes
    вывод: ОТКАЗ: переснятие-bulk не доказано: путь contracts/123-evil.md не покрыт ни одной зоной

# МУТАНТ 1 (снята проверка дефиса) — обход Б7б воспроизведён целиком:
nodash      path=contracts/123not-a-draft.md  check_before=1 retake=0 check_after=0 snap_intact=NO
    вывод: базлайн переснят: bulk-дельта contracts/123not-a-draft.md (автор architect, коммит c5606954…)
underscore  path=contracts/123_not_a_draft.md check_before=1 retake=0 check_after=0 snap_intact=NO
    вывод: базлайн переснят: bulk-дельта contracts/123_not_a_draft.md (автор architect, коммит ca047702…)
bare        path=contracts/123                check_before=1 retake=0 check_after=0 snap_intact=NO
    вывод: базлайн переснят: bulk-дельта contracts/123 (автор architect, коммит 37470b07…)

# МУТАНТ 2 (снят пост-freeze отказ) — вторая половина Б7б воспроизведена:
postfreeze  path=contracts/123-evil.md        check_before=1 retake=0 check_after=0 snap_intact=NO
    вывод: базлайн переснят: bulk-дельта contracts/123-evil.md (автор architect, коммит 7b2dfd4e…)
```

И ОБА мутанта проходят ВЕСЬ приёмочный барьер 044 зелёным:

```text
$ bash …/mutant044/fixtures/check_no_leak/red_bulk_peresnjatie_bazlajna.sh   # мутант 1
  ok   бб6 (отказ именован, снимок не тронут, дельта видна)
ok: дверь bulk-переснятия 044 — все ворота пройдены (б0..б10, бб1..бб6)
RC=0

$ bash …/mutant044/fixtures/check_no_leak/red_bulk_peresnjatie_bazlajna.sh   # мутант 2
  ok   бб6 (отказ именован, снимок не тронут, дельта видна)
ok: дверь bulk-переснятия 044 — все ворота пройдены (б0..б10, бб1..бб6)
RC=0
```

Смысл замера: реализация, в которой найденный адверсарием обход ВОССТАНОВЛЕН,
неотличима от честной для всей приёмки 044. Красное по Б7б существует только в
одноразовых гарнизонах адверсария и в этой пробе; в дереве не остаётся НИЧЕГО, что
покраснеет при рецидиве. Это ровно та конфигурация, ради запрета которой заведена
обязанность «красное предъявлено»: зелёное без красного не доказывает ничего.

Возражение «контракт заморожен, клетки потребуют нового круга» снято нормой самого
проекта: `AGENTS.md:150-152` — «ДОБАВЛЕНИЕ красных тестов по вердикту
адверсария/арбитра (пост-заморозочные шаги 5–6) законно — оно УСИЛИВАЕТ гейт, а не
ослабляет (прецедент 005: +14 фикстур после `frozen/005/2` под accept ревьюера)».
Каталог `fixtures/check_no_leak/` — ЗОНА architect по §Зоны 044; правка текста
контракта не требуется, `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` не требуется.

Требуемое закрытие: две клетки в
`fixtures/check_no_leak/red_bulk_peresnjatie_bazlajna.sh` (имена на усмотрение
автора), каждая — с той же ТРОЙКОЙ, что у б2–б9: (i) путь `contracts/<NNN>` и/или
`contracts/<NNN>X…` при ЖИВОМ `id/CONTRACT/<NNN>` на самом коммите → отказ
«путь … не покрыт ни одной зоной», снимок не тронут, `--check` красен;
(ii) `frozen/contracts/<NNN>/1` в предках + `id/CONTRACT/<NNN>`, переназначенный
на коммит незонированного `contracts/<NNN>-*.md` → тот же отказ. Предъявление —
прогон на мутанте (клетка обязана покраснеть) и на живом коде.

## Замечания (не блокируют, но наследуются)

- **З1 — бб4 в ЗАМОРОЖЕННОМ приёмочном критерии описан неверно.** Контракт
  (§Приёмочный критерий, бб4): «номера нет вовсе («назначен рукой»: **путь не матчит
  грамматику contracts/<M>-\***) → второй приём шага 7б не вступает». Живая фикстура:
  `DP4="contracts/${NNN4}-rucnoj-${RANDOM}.md"` (`red_bulk_peresnjatie_bazlajna.sh:502`)
  — путь грамматике СООТВЕТСТВУЕТ, второй приём вступает и отказывает потому, что ни
  одна рука не сработала (тега нет). Критик назвал это СОВЕТом в `aace01d`; после
  Б7б неточность стала вреднее: замороженный критерий читается как свидетельство
  покрытия грамматической ветви, которого нет (Р1). Текст заморожен — исправление
  только каналом владельца/СПАСЕНО; фиксирую как наследуемый дефект записи.
- **З2 — якорь нормы-строки в контракте не совпадает с деревом.** Контракт:
  «Норма-строка (`roles/orchestrator.md:222`…)». Фактически строка 230 — и была 230
  уже в коммите приземления:
  `git show b7477f9:roles/orchestrator.md | grep -n 'retake-bulk'` → `230:`.
  Механическая приёмка держится не на номере (`grep -cF` по тексту), поэтому это
  неточность записи, не дыра.
- **З3 — семантика нормы-строки.** Дельта к `roles/orchestrator.md:230` прочитана
  живьём целиком: она называет ОБЕ двери, требует стенограмму путей/авторов/sha
  строкой в журнал и «отказ обеих дверей переснятия = СТОП и доклад». Ослабления
  нормы (индульгенции на ручной `--snapshot`, снятия «обходы = гейминг») в дельте
  НЕТ. При этом слово «ЕДИНСТВЕННЫЙ разрешённый выход — `--retake`» из 031 осталось
  в первой половине той же строки и формально спорит со второй половиной; читается
  как два непересекающихся случая, но буквально — противоречие. Не блокер: это
  текст ЧУЖОЙ зоны (orchestrator), правка нормы внутри задачи о механизме была бы
  превышением области — называю, не правлю.

## Что проверено и сошлось

**1. Область правки.** Все коммиты 044 — в объявленных зонах, сверено по автору и
путям (`git show --name-status`), не по отчётам:

```text
60f28dd architect    NABLIUDENIA_ARCHITECT.md, contracts/044-*.md, fixtures/check_judge_gate/red_bulk_*.sh (A)
0145724 architect    contracts/044-*.md, fixtures/check_judge_gate/red_bulk_*.sh (M)
952267f architect    NABLIUDENIA_ARCHITECT.md, contracts/044-*.md, fixtures/check_no_leak/.probe-only (A),
                     R097 fixtures/check_judge_gate/red_bulk_*.sh → fixtures/check_no_leak/red_bulk_*.sh
bc4085a implementer  scripts/check_no_leak.sh
c7de0ef implementer  scripts/check_no_leak.sh
872132b implementer  scripts/check_no_leak.sh
b7477f9 orchestrator roles/orchestrator.md
cd0605a orchestrator registry/contracts.tsv
7bff616 critic       verdicts/critic/contracts-044-v1.md
9f30c50 critic       verdicts/critic/contracts-044-v2.md
aace01d critic       verdicts/critic/contracts-044-v1.md, verdicts/critic/contracts-044-v2.md (D)
622d2e5 adversary    verdicts/adversary/contracts-044-v1-adversary.md
3de912d adversary    verdicts/adversary/contracts-044-v1-adversary-fix.md
```

Ни один исполнитель не вышел за свою зону: implementer — точечно
`scripts/check_no_leak.sh`; architect — контракт и своя новая семья фикстур
(`fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh` 031 НЕ тронут, см. п.2);
норма-строка приземлена ОРКЕСТРАТОРОМ в его зоне, не автором. Атомарность
соблюдена: у каждой задачи свой коммит со ссылкой на предмет, связок из нескольких
задач в одном коммите нет. Живой суд зон:

```text
$ bash scripts/check_zones.sh .
  FAIL коммит вне зоны: implementer 80e1ea84 fixtures/parsing_hygiene_battery/profiles/check_precision_gate.sh
  FAIL коммит вне зоны: implementer 8766e769 contracts/043-precizionnyj-prefriz-gejt.md
замороженных контрактов: 43 · объявленных авторов: 2 · коммитов в диапазонах: 2001 · проверено по зонам: 1334
rc=1
```

Оба FAIL — предмет 043, НЕ 044 (`grep -c FAIL` → ровно 2); ни один коммит 044 в них
не входит. Область 044 чиста; остаток 043 — не мой предмет, называю как наблюдение.

**2. Норма не тронута молча.** `roles/orchestrator.md` правлен ОДНИМ коммитом
оркестратора `b7477f9` (`1 file changed, 1 insertion(+), 1 deletion(-)`), не автором
механизма. Замороженные тексты соседей неизменны:

```text
$ git diff --exit-code frozen/contracts/031/4 -- fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh contracts/031-strazh-semejstvo-mint-i-bazlajn.md
rc=0
$ git diff --exit-code frozen/contracts/044/1 -- contracts/044-bulk-peresnjatie-bazlajna.md fixtures/check_no_leak/
rc=0
```

**3. ПРОВОДКА (контракт 038).** Оба канала существуют и подключены живьём.
`role=roles/orchestrator.md` — строка 230 прочитана целиком ПРЯМЫМ чтением файла
(не по тексту контракта), несёт `--retake-bulk`, стенограмму путей/авторов/sha и
«отказ обеих дверей переснятия = СТОП и доклад»;
`grep -cF 'отказ обеих дверей переснятия = СТОП и доклад' roles/orchestrator.md` → `1`.
`ПРОВОДКА-ЭНФОРСМЕНТ` обоснован честно: детектор НЕ БАРЬЕР (своя шапка; норма-строка
024 зовёт его церемонией с наблюдаемым rc), guard=-канала нет по построению, а
поведенческая дельта (029-класс) пошла ИМЕННО role-каналом — это не guard-only
подмена. Машинная мера:

```text
$ bash scripts/check_provodka.sh . contracts/044-bulk-peresnjatie-bazlajna.md
rc=0
$ bash scripts/check_precision_gate.sh . contracts/044-bulk-peresnjatie-bazlajna.md
precision-гейт 043: семья no_leak — барьер правится этим же черновиком, задача (б) для неё пропущена (прецедент 036 В4-3)
OK
rc=0
$ bash scripts/check_spec_ready.sh . contracts/044-bulk-peresnjatie-bazlajna.md
спек-гейт 036: В4 — семья no_leak в правке этим же черновиком — В4 для неё судит критик
OK
rc=0
```

Граница доказательства названа прямо: задача (б) precision-гейта и В4 спек-гейта для
семьи no_leak ПРОПУЩЕНЫ, а не предъявили полярность; rc=0 этих двух гейтов не есть
свидетельство о фикстуре. Свидетельство о фикстуре — прямые прогоны п.5 и замер Р1.

**4. Проверка не подогнана под код.** История файлов проверки: фикстура создана
архитектором (`60f28dd`), дополнена им же (`0145724`), перенесена в свою семью
(`952267f`); ПОСЛЕ этого implementer правил только `scripts/check_no_leak.sh`
(`bc4085a`, `c7de0ef`, `872132b`) и фикстуру не трогал НИ РАЗУ — автор реализации
файлы проверок и фикстур не менял. Текст фикстуры прочитан самостоятельно:
toy-репозитории настоящие (`git init` + bare origin + `push`), субъект зовётся как
процесс (`bash "$SUBJ" "$mode" "$root"`, `:137`), фразы сверяются побайтово через
`grep -qF`, на каждом отказе проверяется ТРОЙКА (имя ∧ sha256 снимка до==после ∧
`--check` остался rc 1 «загрязнён»). Подгонки под реализацию не обнаружено —
обнаружен НЕДОБОР клеток (Р1).

**5. Сырой вывод.** Ключевые команды вердиктов перепроверены живьём, не приняты на
слово. Два прогона подряд:

```text
$ bash fixtures/check_no_leak/red_bulk_peresnjatie_bazlajna.sh     # прогон 1
  ok   б0 … ok   б10, ok   бб1 … ok   бб6
ok: дверь bulk-переснятия 044 — все ворота пройдены (б0..б10, бб1..бб6)
RC=0
$ bash fixtures/check_no_leak/red_bulk_peresnjatie_bazlajna.sh     # прогон 2
ok: дверь bulk-переснятия 044 — все ворота пройдены (б0..б10, бб1..бб6)
RC=0
$ bash fixtures/check_judge_gate/red_peresnjatie_bazlajna.sh
ok: дверь переснятия 031 — все ворота пройдены (р0..р10)
RC=0
$ bash scripts/verify_antiplacebo.sh . --scope check_judge_gate
барьеров: 1 · фикстур: 3 · предъявлено красным повторным прогоном: 3
RC=0
$ bash scripts/check_no_leak.sh --retake-bulk
ОТКАЗ диспетчер: использование: check_no_leak.sh --snapshot|--check|--retake|--retake-bulk <абс-корень>
rc=1
$ bash scripts/check_no_leak.sh --retake-bulk .
ОТКАЗ: корень обязан быть абсолютным: . (CLI судит абсолютный корень основного чекаута — относительный путь резолвится от случайного cwd, Н-85-класс)
rc=1
```

Счётное утверждение критика «все б0–б10 и бб1–бб6 зелёные» проверено СВОЕЙ мерой —
не повтором его команды, а пообъектным подсчётом строк `ok` в моих прогонах: 17 ворот
(б0–б10 = 11, бб1–бб6 = 6), имена сошлись.

**6. Гигиена awk (остаток адверсария).** Именованный отказ producer'а присутствует в
живом коде: `scripts/check_no_leak.sh:1637` — `NOT_IMPLEMENTED: извлечение
delta_paths упало (awk/sort rc≠0)`, плюс `:1685`, `:1701`, `:1713` на
covered_zones/owners. Ложный «путей 0 / rc 0» при отказе внешней утилиты закрыт.
Клетки фикстуры у этого класса тоже нет — тот же класс, что Р1, но он лежит внутри
явно названной TCB-демаркации 044 (подмена локального PATH) и самостоятельным
блокером не делается.

**7. Консолидация вердикта критика.** `aace01d` заменил текст
`verdicts/critic/contracts-044-v1.md` с FAIL на accept второго круга и удалил
`contracts-044-v2.md`. Прежний FAIL и все три его блокера Б1–Б3 читаются в истории
(`git show 7bff616:verdicts/critic/contracts-044-v1.md`); находки не потеряны,
подмены зелёным без следа нет. Б1 проверен мной живьём независимо (поле `ПРОВОДКА:`
в контракте И строка роли в дереве — п.3), Б2 — адресом фикстуры и прогонами, Б3 —
чтением приёмочного критерия: запрещённых пар «стаб ↔ ветвь» в нём нет, формулировки
«умирает здесь» живут только в шапке фикстуры, где они законны.

## Итог

Механизм двери `--retake-bulk` работает и проверен независимо: Б7б в живом коде
ЗАКРЫТ обеими половинами (грамматика дефиса и пост-freeze симметрия рук А/Б),
честный draft-путь остаётся зелёным, область правки чиста, норма не тронута молча,
машинные гейты зелёные.

Блокирует Р1: закрытие Б7б не оставило в дереве ни одной меры, которая покраснеет при
рецидиве — обе половины обхода восстанавливаются мутацией одной строки каждая, и вся
приёмка 044 при этом остаётся зелёной. Добавление красных клеток по вердикту
адверсария законно пост-заморозочно (`AGENTS.md:150-152`), лежит в зоне architect и
не требует правки замороженного текста.

Незакрытых находок этого круга, кроме Р1, нет. Замечания З1–З3 наследуются как
дефекты записи. Это не замена адверсария и не done-церемония.
