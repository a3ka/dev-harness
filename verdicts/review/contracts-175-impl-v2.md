FAIL
OBJECT=3707adc4da81a7f5bfc58c69917388e89933c570
СУД: repo=dev-harness; предмет=175; фаза=реализация (контракт frozen/contracts/175/2); роль=reviewer; вызов=1 (полный); модель-план=config/agent_models.json (reviewer → @opus = anthropic/claude-opus-5-5); модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev175` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev175	3707adc4da81a7f5bfc58c69917388e89933c570`); сессия=Rev175; SHA=3707adc4da81a7f5bfc58c69917388e89933c570 (tip `origin/wip/175/implementer`, один коммит author=committer=implementer поверх main 90c4aa63c3); СУД-запись оркестратора — HANDOFF state-ветки :4; предыдущий=нет (контракт v2: Crit175V3 accept, арбитраж Arb175V1); класс риска обычный, адверсарий не назначен

# Вердикт ревьюера — 175 v2, реализация (вызов 1)

- Судимые блобы: `ops/server/user/orch-tablo` ca17f45b1eb332e976cf50ccd41bd935c94f835a, `ops/server/README.md` c6801b3e863a8d164772c1842675b9a07c9154ea (`git hash-object` в собранном дереве == `git rev-parse OBJECT:<путь>`; `git diff --cached OBJECT --stat` пуст).
- Находки: `.review/2026-11-18-105.md`. **Блоков 1** (Б-1, implementer). Советов 3 (С-1 и С-2 — architect, С-3 — architect/orchestrator). Наблюдений 2.
- Клон: `/tmp/dev-harness-verify/Rev175/repo` (ssh-origin `ssh://git@github.com/a3ka/dev-harness.git`, свой `.git`). Второй клон для живого прогона: `/tmp/dev-harness-verify/Rev175/live` (HEAD = OBJECT). Worktree не создавались, push не делался.

## Б-1 — блок: в окружении потребителя ведущий потока mob не виден

`ops/server/user/orch-tablo:97-99` ищет журналы через `os.path.expanduser('~/.local/state/dev-harness-projects/complior-mob/…')`. Табло запускает оркестратор из своей omp-сессии (ПРОВОДКА: `roles/orchestrator.md`; на origin/main `grep -c` дословной строки = 1). Его же зовёт wait-guard 128: `execFile('python3', [TABLO], {timeout, maxBuffer})` без `env` (`.omp/extensions/wait-guard.ts:75`). Под omp `HOME` перенаправлен в каталог зоны (`scripts/orch_restart.sh:82-84`, контракт 088 И-1). Замер в этой сессии (зона оркестратора `c907157c`):

```
$ echo "HOME=$HOME"
HOME=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev
$ python3 home_probe.py                  # строки 97–107 OBJECT дословно, окно 360
HOME=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev mob_ses=0 journals=0 mob_vedet=False
$ HOME=/home/harness python3 home_probe.py
HOME=/home/harness mob_ses=1 journals=94 mob_vedet=True age_min=9
```

Вся программа OBJECT на живой станции. Единственная инструментовка — `active.pop('mob', None)` перед `print('ПОТОКИ:')`: она даёт предусловие контракта :47 «у станции нет своих предметов mob» (`live_nomob.py`, 2026-11-18T00:18:53Z):

```
== HOME=/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev (сессия, как у оркестратора)
ПОТОКИ:
  бэкенд: ведёт сессия проекта Complior-back — станция его предметы НЕ исполняет
  СТОИТ ПОТОК харнесс: ни один предмет не в работе — 61 мин; возьми следующую задачу потока
  СТОИТ ПОТОК mob: ни один предмет не в работе — 0 мин; возьми следующую задачу потока
итог: стоит без хода — 11  → сделай следующий шаг по каждой строке СТОИТ до wait
rc=0
== HOME=/home/harness (passwd)
ПОТОКИ:
  бэкенд: ведёт сессия проекта Complior-back — станция его предметы НЕ исполняет
  СТОИТ ПОТОК харнесс: ни один предмет не в работе — 61 мин; возьми следующую задачу потока
  mob: ведёт сессия проекта Complior-mob (журнал 15 мин назад) — станция поток не требует
итог: стоит без хода — 10  → сделай следующий шаг по каждой строке СТОИТ до wait
rc=0
самый свежий журнал моба: mtime 2026-11-18T00:02:58Z  2026-11-17T23-42-06-758Z_01a1ebe3-a3a6-7021-85b4-fd6cec5e6878.jsonl (828729 байт)
```

- Обязательства: инв. 4 («ведущий есть — печатается ровно строка-факт… без СТОИТ»); «После реализации» :47 («дано живое дерево и свежий в окне журнал сессии моба; когда `python3 ops/server/user/orch-tablo 360`; тогда … строки `СТОИТ ПОТОК mob` нет»); КОНТЕКСТ :5 («шов — тот же запуск»). В окружении настоящего запуска остаётся именно то ложное требование, которое v2 убирает («Красное сейчас» :34).
- Состояние достижимо: любое пробуждение оркестратора, когда у станции нет своего предмета mob в работе. Сейчас 201 держит `mob: в работе предметов — 1` и маскирует дефект (прогон без инструментовки ниже).
- Батарея этого не ловит: мир привязан к `$HOME` прогона (`probe.py:58-59`), см. С-1.
- Сдача автора не названа ложной, но неполна. Живой прогон автора шёл под подменённым `HOME=/home/harness`. Что `HOME` сессии — зона, он заметил (`history://Impl175` :155), но следствие для потребителя в сдаче не указал.
- Исправление в ЗОНЕ implementer существует и проходит те же строки приёмки: корень дома = объединение `os.path.expanduser('~')` и `pwd.getpwuid(os.getuid()).pw_dir` (дом из passwd, прецедент 088 И-1). Батарея `alt_home.py` в обоих окружениях: `ALT home_or_passwd ok=26/26`. Форма «только passwd» в сессии с `HOME` зоны — `ok=21/26`: это ограничение батареи, С-1.

## 1. Область правки, атомарность, история проверок

```
$ git show --stat --format='%H%nA:%an <%ae>%nC:%cn <%ce>%nP:%P' 3707adc4da
3707adc4da81a7f5bfc58c69917388e89933c570
A:implementer <implementer@dev-harness.local>
C:implementer <implementer@dev-harness.local>
P:90c4aa63c34247878d02fdd6827b5ee11a7eb9b3
 ops/server/README.md       |  2 ++
 ops/server/user/orch-tablo | 25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+)
$ git log --oneline origin/main..origin/wip/175/implementer
3707adc4 175 v2: реализация — табло не требует поток mob при живой сессии проекта Complior-mob
```

- ЗОНА живьём, `git show frozen/contracts/175/2^{commit}:contracts/175-tablo-bez-demo.md` :68: `ЗОНА implementer: ops/server/user/orch-tablo ops/server/README.md`. Оба файла коммита совпадают с ней точно, автор `implementer` — объявленное имя. Вне зоны 0 файлов.
- `scripts/check_zones.sh` (без аргументов, по всей истории) в `/tmp/dev-harness-verify/Rev175/live`, HEAD = OBJECT 3707adc4da, теги `frozen/contracts/175/1`, `/2` на месте, без ambient `GIT_*`: `замороженных контрактов: 180 · объявленных авторов: 5 · коммитов в диапазонах: 64353 · проверено по зонам: 20527`, rc_zones=0, 924 с. Первый прогон в `repo` был убит по таймауту 600 с.
- ПЕРЕСЕЧЕНИЯ README: `git diff -U0 origin/main OBJECT -- ops/server/README.md` → один ханк `@@ -649,0 +650,2 @@`, только вставка. Он внутри раздела 175 `## Табло потоков ведущей сессии (orch-tablo)` (:644, следующий раздел :652). Разделы 074 (инвентарь/установка), 081 (`## Обслуживание .git/config` :596), 085 (цикл), 093 (граница исполнения), 997 (scope/receipt) не тронуты: удалённых строк 0. Текст ПЕРЕСЕЧЕНИЯ («только предложение о демонстрационных PR») для v2 не обновлён — С-3.
- Атомарность: один предмет — один коммит, в заголовке ссылка «175 v2». Проверки не переписаны под реализацию: `git log origin/main..OBJECT -- fixtures/ contracts/` пуст, батарея и контракт на OBJECT == main == тег.
- Норма не тронута: в диффе нет `roles/`, `contracts/`, `AGENTS.md`.

## 2. Красное предъявлено (чистый origin/main 90c4aa63c3, `--repo .`)

```
175 mob_session_zel_pr KRASNO pr=1/1 mob_facts=0 potok_mob=1 err='' rc=0
175 mob_session_krasny_pr KRASNO pr=1/1 mob_facts=0 potok_mob=1 err='' rc=0
175 mob_tolko_prjamoj_zhurnal KRASNO pr=1/1 mob_facts=0 potok_mob=1 err='' rc=0
175 mob_tolko_vlozhennyj_zhurnal KRASNO pr=1/1 mob_facts=0 potok_mob=1 err='' rc=0
175 mob_granica_okna KRASNO pr=1/1 mob_facts=0 potok_mob=1 err='' rc=0
(остальные 21 — ok, в том числе 15 клеток v1)
rc=1
```

Красны ровно 5 клеток, названных контрактом :36.

## 3. Прогоны на судимом дереве (origin/main + два файла OBJECT; блобы сверены)

| Команда | Результат |
|---|---|
| `bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .` | 26 строк `ok rc=0`, rc 0 |
| `… red_tablo_demo_175.sh` (голый) | 26/26 ok, rc 0 |
| `… --model` | `CONTROL ctl-glob/ctl-fullpath/ctl-find/ctl-walk 26/26 ok`, rc 0 |
| `… --stabs` | 4 контроля по 26/26, 26 строк `STAB … caught`, 0 `ZHIV`, rc 0 |
| `python3 -c "py_compile.compile('ops/server/user/orch-tablo', cfile=…, doraise=True)"` | rc 0 (`cfile` вне дерева, без `__pycache__`); `ast.parse` ok; файл — python3 (shebang), `bash -n` неприменим |
| `bash scripts/gen_ci_steps.sh --check` | rc 0 |
| `bash scripts/check_charter.sh` | rc 0 (`уставных документов: 180 · изменений в них: 525 · с разрешения: 525`) |
| `bash scripts/pre_critic.sh --repo . contracts/175-tablo-bez-demo.md` | rc 0 (`КРИТИК: дверь зелёная`) |
| `bash scripts/check_provodka.sh . contracts/175-tablo-bez-demo.md` | rc 0 |
| `grep -cF "ведёт сессия проекта Complior-mob" ops/server/README.md` | 1, rc 0 (на origin/main: 0, rc 1) |
| `ls fixtures/workshop_project/tablo_demo_175/* \| wc -l` | 3 (census контракта :43) |

Все гейты шли без ambient `GIT_AUTHOR_*/GIT_COMMITTER_*` (`env -u …`).

Счёт своей мерой, другой командой, чем у автора: `python3 -c "import probe,model; …"` → `worlds 26 v1 15 v2 11`, `v2stabs 13` (13 v1 из списка `mutants` + 13 v2 = 26). `--stabs | grep -c ' caught @ '` → 26, `grep -c ' ZHIV @ '` → 0. `--repo . | grep -c ' ok rc=0$'` → 26. Числа автора (26/26, 4×26/26, 26 caught, до правки 21 ok + 5 красных) совпали.

Живой запуск без инструментовки, HOME сессии, клон `repo`, 2026-11-18T00:11:29Z: `python3 ops/server/user/orch-tablo 360` → rc 0. Вывод не падает; ПОТОКИ: `бэкенд …`, `СТОИТ ПОТОК харнесс … 53 мин`, `  mob: в работе предметов — 1` (Arch201Fix3-2 РАБОТАЕТ по 201), `итог: стоит без хода — 10`. 5 PR-строк Complior-mob показаны как обычно. Время строки mob сверено с журналом только в прогоне Б-1: под `HOME=/home/harness` «15 мин назад» против mtime 00:02:58Z при запуске 00:18:53Z (15 мин 55 с, целая часть 15) — верно. Под `HOME` сессии ведущий не найден — Б-1.

## 4. Обязательства v2 — по чтению кода и мутациям субъекта

- Источник — дом 055 И-2, обе формы: `glob(b + '/*.jsonl') + glob(b + '/*/*.jsonl')` (:102). Корень дома — Б-1.
- Граница включительная: `max(mob_last) >= NOW.timestamp() - WINDOW * 60` (:107). Возраст ровно N мин — ведущий есть, N мин + 1 с — нет; клетки `mob_granica_okna`/`mob_za_granicej_okna` зелёные.
- Состояние проекта и чужая сессия ведущими не считаются: путь литерально `…/complior-mob/…/--home-harness-projects-Complior-mob--`, glob по `complior-mob*` и `*/home` отсутствует. Клетки `otlozhennaja_sessija`/`chuzhaja_sessija` ok.
- Read-only: новые вызовы — только `glob.glob` и `os.path.getmtime`, записей нет. Прежний `git fetch --tags` (:72) не новый.
- Счёт: ветка `elif s == 'mob' and mob_vedet` (:232) `stoit` не трогает. Итог на 1 меньше (живой прогон: 11 → 10).
- Порядок разделов прежний: ПОТОКИ → бэкенд → харнесс → mob → итог. Предшествование `active.get(s)` раньше `mob_vedet` (:230).
- v1 не сломан: 15 клеток v1 ok, `--stabs` 13 v1-стабов пойманы. Фильтр :119–126 не тронут.

Мутации субъекта (мои, в памяти, против миров батареи; `mut_subject.py`):

```
MUT strict_border caught red=1 mob_granica_okna
MUT only_direct caught red=1 mob_tolko_vlozhennyj_zhurnal
MUT only_nested caught red=1 mob_tolko_prjamoj_zhurnal
MUT recursive_any_depth caught red=8 …
MUT forever_alive caught red=2 mob_stary_zhurnal,mob_za_granicej_okna
MUT dir_alive caught red=3 mob_pustoj_zhurnal,mob_stary_zhurnal,mob_za_granicej_okna
MUT wider_window caught red=1 mob_za_granicej_okna
MUT narrower_window caught red=1 mob_granica_okna
MUT age_ceil ZHIV red=0
MUT age_oldest ZHIV red=0
MUT counts_stoit caught red=5 …
MUT fact_overrides_active ZHIV red=0
MUT any_project caught red=1 chuzhaja_sessija
MUT back_home caught red=6 …
subject_unmutated green
```

`age_ceil`/`age_oldest` — С-2 (субъект верен по чтению). `fact_overrides_active` — остаток К-2 контракта, ниже.

## 5. Неподгонка

Ветвления по имени мира, синтетическим именам (`synthetic-*`), `FROZEN_NOW`, `WINDOW_ARG=20` или пути приманки в субъекте нет. Путь дома строится через `expanduser`, `/home/harness` не захардкожен. Именно это и даёт Б-1: `~` ≠ дом станции у потребителя. Субъект ≠ `model.honest_v2()` (`subject==honest_v2 False`), у них совпадают только строки `MOB_VEDET_LINE` и `MOB_MINS_EXPR` (по 1 вхождению). Блок `MOB_BLOCK` модели и цикл `LOOP_NEW` в субъекте не встречаются.

## 6. Остатки (НЕ ЗАЩИЩАЕТ контракта :57–60)

- ОСТАТОК: К-1 (правдивость журнала) — не укусил. Дифф правдивость не утверждает; ловец — оркестратор.
- ОСТАТОК: К-2 (одновременная работа станции и внешней сессии) — не укусил. Живой прогон без инструментовки: при `РАБОТАЕТ 201` печатается `mob: в работе предметов — 1`, предшествование по :230. Батарея этого не различает (`fact_overrides_active` ZHIV) — согласно декларации.
- ОСТАТОК: К-3 (намеренное демо без признаков и GitHub API) — не укусил. Фильтр v1 не тронут, PR Complior-mob на живом табло показаны.

## 7. Wait-guard 128 против README

README: «строка без «СТОИТ» хода не требует (wait-guard контракта 128 …)». Guard судит только `^ *СТОИТ ([0-9]+) мин ` (`wait-guard.ts:35`) и итог `^итог: стоит без хода — [0-9]+` (:38). Строка-факт `  mob: ведёт …` не начинается с СТОИТ, итог печатается тем же print. Расхождения нет. «СТОИТ ПОТОК» guard не судит вовсе (:33–34), поэтому сама строка-факт на wait не влияет. Влияние v2 — только счёт в итоге и норма роли («закрой каждую строку СТОИТ»).

## 8. ПРОВОДКА, сложность, сверки

- ПРОВОДКА: канал `role=roles/orchestrator.md` существует (дословная строка на origin/main, `grep -c` = 1; производная `.omp/agents/orchestrator.md:341`). Потребитель тот же, что у v1. Действующего канала диффом не прибавлено и не убавлено. Но в окружении этого канала признак v2 не работает — Б-1.
- Паразитная сложность (050). Артефакт — блок `mob_ses/mob_last/mob_vedet` (:90–107), ветвь `elif` (:232–237) и абзац README (:650).
  1. Свойство: инв. 3–4 v2.
  2. Состояние: нет, только чтение mtime; результат виден в выводе строкой-фактом.
  3. При следующей правке свойства меняются вместе `orch-tablo` + README, как и в v1; число не выросло.
  4. Интерфейс не вырос: новых аргументов, флагов, env и rc нет.
  5. Потребитель — клетки v2 батареи и CI-шаг `check:tablo-demo-175-family-selftest`. Грамматику не повторяет: мера свежести — тот же glob+mtime, что у журналов станции (:44–47), но корень другой (:39 — `/home/harness`, литерал) — Б-1.

  Вывод: ESSENTIAL.
- СВЕРКА-СТАНДАРТОВ: `AGENTS.md` харнесса документ архитектуры и стандарт кода не объявляет (`grep -n 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` — пусто). `docs/owner/ARCHITECTURE.md` и `docs/owner/CODING-STANDARDS.md` — документы продукта («AI Act Compliance Platform», Onion/DDD/TypeScript). Python-скрипт станции `ops/server/user/` ни одним их разделом не покрыт — неприменимо.
- СВЕРКА-АРХИТЕКТУРЫ:
  - размещение — существующий станционный скрипт `ops/server/user/orch-tablo`, рядом с журналами станции, ок;
  - зависимости — только stdlib `glob`/`os`, новых нет;
  - писатели — нет (read-only);
  - операции — чтение mtime;
  - `bindings.json` — в харнессе нет (`pre_critic`: `ARCH_187A_SKIP: проект не в режиме 187а`);
  - нерасширение долга — НЕ соблюдено: второй способ определять дом. Журналы станции берутся по литеральному `/home/harness` (:39), а 088 И-1 требует дом из passwd; новая ветвь вводит `$HOME` сессии — Б-1;
  - уровень diff модели — модели архитектуры у харнесса нет. Расхождение «буква контракта `~`/батарея на `$HOME`» против «живого потребителя под зоной» записано как С-1. Инструмент `node tooling/checks/cli.js finding new` в дереве отсутствует (`MODULE_NOT_FOUND`), находка — в `.review/`. L2/L3 не принимаю.

## 9. Не проверено / развилки

- `scripts/check_zones.sh` на OBJECT: rc 0 за 924 с (раздел 1). Зона сверена и построчно: 2 файла коммита == ЗОНА implementer :68, автор implementer.
- Скриншотов нет (не мобильный экран). sourceCanon не объявлен.
- Развилка: задание называет файл `verdicts/review/contracts-175-impl-v1.md`, но на origin/main он уже занят accept-вердиктом реализации v1 (OBJECT 8533d157a4). Перезапись стёрла бы действующую запись суда v1. Поэтому взял `contracts-175-impl-v2.md` — по образцу `contracts-NNN-impl-v2.md` (40 таких файлов в `verdicts/review/`).
- Развилка: Б-1 можно счесть дефектом модели (буква `~` и батарея на `$HOME`), а не реализации. Блоком реализации считаю его потому, что нарушен сценарий приёмки на живом шве и у implementer есть исправление в своей зоне, проходящее ту же батарею (26/26 в обоих окружениях). Решение об ужесточении модели (С-1) — за architect/оркестратором.
