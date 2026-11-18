accept
OBJECT=c283cf3f8576e66b22e467dd04bc3cc640f496dc
СУД: repo=dev-harness; предмет=175; фаза=реализация (контракт frozen/contracts/175/2); роль=reviewer; вызов=2 (СКОУПНЫЙ повтор после FAIL Rev175, регламент «один полный + не более одного scoped»; исключения нет); модель-план=config/agent_models.json (reviewer → @opus = anthropic/claude-opus-5-5); модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev175b` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev175b	c283cf3f8576e66b22e467dd04bc3cc640f496dc`, rc 0); сессия=Rev175b; SHA=c283cf3f8576e66b22e467dd04bc3cc640f496dc (tip `origin/wip/175/implementer`: `3707adc4da` + fix1 `c283cf3f85`, оба коммита author=committer=implementer, merge-base с main — 90c4aa63c3); СУД-запись оркестратора — HANDOFF state-ветки `wip-011-orchestrator/HANDOFF.md`:4 (`предмет=175`, вызов=2, OBJECT совпадает); предыдущий=Rev175 FAIL (`wip/175/reviewer-impl1` c078773520, `verdicts/review/contracts-175-impl-v2.md`, `.review/2026-11-18-105.md`, один блок Б-1).

# Вердикт ревьюера — 175 v2, реализация (вызов 2, скоупный)

- Судимое дерево: origin/main `0ddebafb57` плюс два файла OBJECT. Блобы: `ops/server/user/orch-tablo` 9eb3e79e0c88048294d38fbf7978d0d410430845 и `ops/server/README.md` 5e73e8ce3e4aab1b32cc4ca45fdefc838fd76037; `git hash-object` == `git rev-parse c283cf3f85:<путь>`. `git diff --cached c283cf3f85 --stat -- ops/ fixtures/workshop_project/tablo_demo_175/` пуст. Между merge-base 90c4aa63c3 и origin/main эти файлы и батарея не менялись (`git diff --stat 90c4aa63 origin/main -- …` пуст).
- Клон: `/tmp/dev-harness-verify/Rev175b/repo` (ssh-origin `ssh://git@github.com/a3ka/dev-harness.git`, свой `.git`). Worktree не создавал, push не делал. Все гейты шли через `env -u GIT_AUTHOR_* -u GIT_COMMITTER_* -u GIT_DIR -u GIT_WORK_TREE`.
- Повестка задания, пункты (1)–(4), закрыта. **Блоков 0.** Советов 1 (С-4, implementer), наблюдений 1 (Н-3, оркестратор): `.review/2026-11-18-107.md`. Советы С-1…С-3 из `.review/2026-11-18-105.md` остаются в силе, но не блоки (задание, триаж).
- **Б-1 Rev175 — ЗАКРЫТ.**

## 1. Б-1: дом сессии mob = объединение `$HOME` и дома из passwd

Код OBJECT, `orch-tablo:101-104`:

```
mob_ses = sorted({p for h in (os.path.expanduser('~'), pwd.getpwuid(os.getuid()).pw_dir)
                  for p in glob.glob(h + '/.local/state/dev-harness-projects/complior-mob'
                                     '/home/.omp/profiles/dev/agent/sessions'
                                     '/--home-harness-projects-Complior-mob--')})
```

Корней два, совпавшие пути схлопываются множеством. Ведущий определяется по `max(mob_last)` над журналами всех корней (:106-112), то есть журнал в окне в любом корне делает ведущего.

### 1а. Живой шов — реальный `python3 ops/server/user/orch-tablo 360` (read-only)

HOME этой сессии — каталог зоны omp `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev`, то есть ровно окружение потребителя из Б-1. Дом из passwd: `/home/harness`. Пустой HOME: `/tmp/dev-harness-verify/Rev175b/emptyhome` (`ls -A | wc -l` = 0 до и после прогонов).

Драйвер `drv_live.py` — свой. Он исполняет исходник табло целиком и делает ровно одну вставку: `active.pop('mob', None)` перед `print('ПОТОКИ:')`. Это предусловие «нет своих mob-предметов в работе». После табло драйвер печатает диагностику корней из того же процесса. Запуск 2026-11-18T00:53:31Z:

```
== HOME=/home/harness nomob=1
ПОТОКИ:
  бэкенд: ведёт сессия проекта Complior-back — станция его предметы НЕ исполняет
  харнесс: в работе предметов — 1
  mob: ведёт сессия проекта Complior-mob (журнал 12 мин назад) — станция поток не требует
итог: стоит без хода — 7  → сделай следующий шаг по каждой строке СТОИТ до wait
DIAG HOME=/home/harness roots=('/home/harness', '/home/harness') real=['/home/harness', '/home/harness']
DIAG mob_ses=['/home/harness/.local/state/dev-harness-projects/complior-mob/home/.omp/profiles/dev/agent/sessions/--home-harness-projects-Complior-mob--'] n_journals=94 mob_vedet=True active_mob=None
DIAG newest_mtime=2026-11-18T00:40:49Z NOW=2026-11-18T00:53:31Z age_s=762
rc=0
== HOME=/tmp/dev-harness-verify/Rev175b/emptyhome nomob=1
ПОТОКИ:
  бэкенд: ведёт сессия проекта Complior-back — станция его предметы НЕ исполняет
  харнесс: в работе предметов — 1
  mob: ведёт сессия проекта Complior-mob (журнал 12 мин назад) — станция поток не требует
итог: стоит без хода — 7  → сделай следующий шаг по каждой строке СТОИТ до wait
DIAG HOME=/tmp/dev-harness-verify/Rev175b/emptyhome roots=('/tmp/dev-harness-verify/Rev175b/emptyhome', '/home/harness') real=[…emptyhome, '/home/harness']
DIAG mob_ses=['/home/harness/…/--home-harness-projects-Complior-mob--'] n_journals=94 mob_vedet=True active_mob=None
DIAG newest_mtime=2026-11-18T00:40:49Z NOW=2026-11-18T00:53:35Z age_s=766
rc=0
== HOME=<зона omp c907157c> nomob=1
  mob: ведёт сессия проекта Complior-mob (журнал 12 мин назад) — станция поток не требует
итог: стоит без хода — 7  → …
DIAG roots=('/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev', '/home/harness') … n_journals=94 mob_vedet=True
rc=0
```

Тот же запуск без инструментовки, сам файл: `HOME=… python3 -B ops/server/user/orch-tablo 360`. Сейчас у станции своего mob-предмета в работе нет, и вывод совпадает с инструментованным. Для `HOME=/home/harness` и для `HOME=emptyhome` раздел ПОТОКИ один и тот же: строка-факт `mob: ведёт … (журнал 12 мин назад)`, `итог: стоит без хода — 7`, rc 0. Полный вывод для `HOME=emptyhome` (00:55): 5 строк `СТОИТ … PR Complior-mob#…`, `РАБОТАЕТ 193`, `СТОИТ … 095`, `СТОИТ … 201`, ПОТОКИ в порядке бэкенд → харнесс → mob, итог 7. Строки `СТОИТ ПОТОК mob` нет.

Возраст N сверен с самим журналом: при age_s=762 табло печатает «12 мин», при age_s=857 — «14 мин» (целая часть от деления на 60).

**Красное против прежней реализации, на том же шве.** Тот же драйвер с исходником `git show 3707adc4da:ops/server/user/orch-tablo` (только `$HOME`), 00:55:01Z:

```
== RED-контроль: 3707adc4da HOME=emptyhome nomob=1
  СТОИТ ПОТОК mob: ни один предмет не в работе — 0 мин; возьми следующую задачу потока
итог: стоит без хода — 8  → сделай следующий шаг по каждой строке СТОИТ до wait
DIAG mob_ses=[] n_journals=0 mob_vedet=False active_mob=None
rc=0
== RED-контроль: 3707adc4da HOME=/home/harness nomob=1
  mob: ведёт сессия проекта Complior-mob (журнал 14 мин назад) — станция поток не требует
итог: стоит без хода — 7
```

С 3707adc4da дефект Б-1 воспроизводится: в чужом HOME печатается СТОИТ, итог 8. С OBJECT дефекта нет: строка-факт, итог 7. Разница ровно в одну строку СТОИТ, как и требует сценарий :47 («итог меньше на 1»).

### 1б. Батарея в мире фикстуры и проверка «именно объединение»

`red_tablo_demo_175.sh --repo .` с тремя значениями HOME: `/home/harness`, `emptyhome` (мир) и HOME зоны. Во всех трёх `grep -c ' ok rc=0$'` = 26, rc 0.

Свой драйвер `drv_battery.py` гоняет варианты субъекта через `probe.run_case` по 26 мирам:

```
VAR OBJ            HOME=/home/harness ok=26/26 red=-
VAR home_only_3707 HOME=/home/harness ok=26/26 red=-
VAR passwd_only    HOME=/home/harness ok=26/26 red=-
VAR union_realpath HOME=/home/harness ok=26/26 red=-
VAR OBJ            HOME=…/emptyhome ok=26/26 red=-
VAR home_only_3707 HOME=…/emptyhome ok=26/26 red=-
VAR passwd_only    HOME=…/emptyhome ok=21/26 red=mob_session_zel_pr,mob_session_krasny_pr,mob_tolko_prjamoj_zhurnal,mob_tolko_vlozhennyj_zhurnal,mob_granica_okna
VAR union_realpath HOME=…/emptyhome ok=26/26 red=-
VAR OBJ            HOME=<зона> ok=26/26 red=-
VAR passwd_only    HOME=<зона> ok=21/26 red=(те же 5)
```

Реализация — именно объединение корней, а не чистый passwd. Чистый passwd даёт 21/26 (это и есть отвергнутая форма), объединение — 26/26 во всех средах. Прежняя форма «только `$HOME`» в батарее зелёная, но на живом шве красная (1а). Поэтому только объединение проходит обе меры. Мутант `drop_home_root` (корни без `$HOME`) в мире emptyhome пойман на тех же 5 клетках (раздел 2).

### 1в. Дубликаты

`drv_dedup.py` исполняет блок `mob_ses … mob_vedet` из OBJECT, вырезанный по якорям:

```
HOME=/home/harness  mob_ses=1 real_distinct=1 journals=94  mob_vedet=True age_min=13
HOME=/home/harness/ mob_ses=1 real_distinct=1 journals=94  mob_vedet=True age_min=13
HOME=…/homelink(→/home/harness) mob_ses=2 real_distinct=1 journals=188 mob_vedet=True age_min=13
HOME=…/emptyhome    mob_ses=1 real_distinct=1 journals=94  mob_vedet=True age_min=13
```

Совпадающие корни, включая хвостовой `/`, каталог дважды не дают. Если HOME — симлинк на дом, журналы попадают в список дважды. Но ведущий и возраст считаются через `max`, поэтому вывод не меняется. Обязательства на счёт журналов у контракта нет. Комментарий `:100` шире кода — это совет С-4, не блок.

## 2. Остальное поведение v2 не изменилось

Дифф fix1 против 3707adc4da (`git diff -U0`) — два ханка: `@@ -12 +12 @@` (импорт `pwd`) и `@@ -97,3 +97,8 @@` (комментарий и `mob_ses`). Строки `mob_last`/glob обеих форм (:106-111), `mob_vedet` с `>=` (:112), предшествование `active.get(s)` (:235), ветвь `elif s == 'mob' and mob_vedet` без `stoit += 1` (:237-242), порядок ПОТОКИ, PR-цикл и фильтр v1 не тронуты.

Мои мутации субъекта (`drv_mut.py`, HOME=emptyhome, исходник = OBJECT):

```
MUT strict_border caught red=1 mob_granica_okna
MUT only_direct caught red=1 mob_tolko_vlozhennyj_zhurnal
MUT only_nested caught red=1 mob_tolko_prjamoj_zhurnal
MUT forever_alive caught red=2 mob_stary_zhurnal,mob_za_granicej_okna
MUT dir_alive caught red=3 mob_pustoj_zhurnal,mob_stary_zhurnal,mob_za_granicej_okna
MUT wider_window caught red=1 mob_za_granicej_okna
MUT narrower_window caught red=1 mob_granica_okna
MUT counts_stoit caught red=5 mob_session_zel_pr,mob_session_krasny_pr,mob_tolko_prjamoj_zhurnal,mob_tolko_vlozhennyj_zhurnal,mob_granica_okna
MUT any_project caught red=1 chuzhaja_sessija
MUT back_home caught red=6 …,chuzhaja_sessija
MUT state_dir caught red=5 …
MUT drop_home_root caught red=5 …
subject_unmutated green HOME=/tmp/dev-harness-verify/Rev175b/emptyhome
rc=0
```

- Обе формы журналов на месте (`only_direct`/`only_nested` пойманы).
- Граница окна включительная (`strict_border`/`narrower_window` пойманы).
- Состояние проекта и чужая сессия ведущими не считаются (`state_dir`, `any_project`, `back_home` пойманы).
- Счёт «стоит без хода» на месте (`counts_stoit` пойман).
- Read-only: новые вызовы — только `pwd.getpwuid` и `glob.glob`. Запись не появилась. После всех живых прогонов `git status --short` показывает только мои временные `M` двух судимых файлов, emptyhome пуст.
- Порядок разделов и итоговая грамматика — по живому выводу (1а).

## 3. README

`git diff -U0 3707adc4da c283cf3f85 -- ops/server/README.md` — один ханк `@@ -651,0 +652,2 @@`, только вставка, удалённых строк 0. Он внутри раздела `## Табло потоков ведущей сессии (orch-tablo)` (:644; следующий раздел `## Механизмы консультанта вне репо` — :654). Разделы ПЕРЕСЕЧЕНИЙ 074 (инвентарь и установка), 081 (`## Обслуживание .git/config` :596), 085 (цикл), 093 (граница исполнения), 997 (scope/receipt) не тронуты. `grep -cF "ведёт сессия проекта Complior-mob" ops/server/README.md` → 1, rc 0.

## 4. Регресс на судимом дереве

| Команда | Результат |
|---|---|
| `bash fixtures/workshop_project/tablo_demo_175/red_tablo_demo_175.sh --repo .` | 26 строк `ok rc=0`, rc 0 (отдельный вызов) |
| `… --model` | `CONTROL ctl-glob/ctl-fullpath/ctl-find/ctl-walk 26/26 ok`, rc 0 (отдельный вызов) |
| `… --stabs` | 4 контроля по 26/26; 26 строк `STAB … caught` (13 v1 + 13 v2), 0 `ZHIV`, rc 0 (отдельный вызов) |
| `python3 -c "import py_compile; py_compile.compile('ops/server/user/orch-tablo', cfile='/tmp/dev-harness-verify/Rev175b/orch-tablo.pyc', doraise=True)"` | rc 0 (cfile вне дерева; `find . -name __pycache__` вне `.git` → 0) |
| `bash scripts/gen_ci_steps.sh --check` | rc 0 |
| `bash scripts/check_charter.sh` | rc 0 (`уставных документов: 181 · изменений в них: 525 · с разрешения: 525`) |

Зона проверена построчно, вживую. `git show frozen/contracts/175/2^{commit}:contracts/175-tablo-bez-demo.md` :68: `ЗОНА implementer: ops/server/user/orch-tablo ops/server/README.md`. `git show --name-only c283cf3f85` → ровно эти два файла, `A:implementer <implementer@dev-harness.local> C:implementer <implementer@dev-harness.local>`, родитель 3707adc4da. Коммитов `origin/main..c283cf3f85` два, оба от implementer. `git log origin/main..c283cf3f85 -- fixtures/ contracts/ roles/ AGENTS.md` пуст, значит проверки и норма не тронуты. `scripts/check_zones.sh` в этом вызове не запускал (раздел «Не проверено»).

Атомарность: fix1 — один коммит, в заголовке ссылка «175 fix1 … (Б-1 Rev175)».

## 5. Остатки (НЕ ЗАЩИЩАЕТ контракта)

- ОСТАТОК: К-1 (правдивость журнала) — не укусил. fix1 добавляет корень поиска, но не меру доверия. Журнал по-прежнему признак, а не доказательство (`orch-tablo:101-112`).
- ОСТАТОК: К-2 (одновременная работа станции и внешней сессии) — не укусил. Предшествование `if active.get(s)` (:235) диффом не тронуто: ханки только :12 и :97-104.
- ОСТАТОК: К-3 (намеренное демо, достоверность GitHub API) — не укусил. Фильтр v1 не тронут, на живом выводе 5 PR Complior-mob показаны.

## 6. ПРОВОДКА, сложность, сверки

- ПРОВОДКА: канал `role=roles/orchestrator.md` прежний. fix1 делает признак v2 рабочим именно в окружении этого канала (HOME зоны, 1а). Wait-guard 128 судит только `^ *СТОИТ ([0-9]+) мин ` и итог, строка-факт не изменилась.
- Паразитная сложность (050). Новый артефакт — объединение корней (:12 импорт, :97-104) и абзац README :652.
  1. Свойство: инв. 3–4 и сценарий :47 на живом шве под HOME зоны.
  2. Состояние: нет, только чтение passwd и mtime. Результат виден строкой-фактом.
  3. При следующей правке свойства меняются вместе те же 2 файла, число не выросло.
  4. Интерфейс: новых аргументов, флагов, env и rc нет. Неявный вход `pw_dir` назван в README.
  5. Потребитель — живой шов (ПРОВОДКА) и клетки v2 батареи. Более простые формы не проходят те же строки: «только `$HOME`» красна на живом шве (1а), «только passwd» — 21/26 в батарее (1б).

  Вывод: ESSENTIAL.
- СВЕРКА-СТАНДАРТОВ: `AGENTS.md` харнесса не объявляет документ архитектуры и стандарт кода (`grep -n 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` пуст, как у Rev175). `docs/owner/ARCHITECTURE.md` и `CODING-STANDARDS.md` относятся к продукту и python-скрипт станции `ops/server/user/` не покрывают — неприменимо.
- СВЕРКА-АРХИТЕКТУРЫ:
  - размещение прежнее — `ops/server/user/orch-tablo`;
  - зависимости — stdlib `pwd`, новых внешних нет;
  - писателей нет;
  - операции — чтение passwd и mtime;
  - `bindings.json` у харнесса нет;
  - нерасширение долга — соблюдено: дом из passwd совпадает с прецедентом 088 И-1. Литерал `/home/harness` в журналах станции (:39) — прежний, диффом не расширен;
  - уровень diff модели — модели архитектуры у харнесса нет. Расхождение «батарея на `$HOME`» против «живого потребителя» — С-1 (105), L2/L3 не заявлены. Инструмент `node tooling/checks/cli.js finding new` в дереве отсутствует (как у Rev175), находки — в `.review/`.

## 7. Не проверено / развилки

- `scripts/check_zones.sh` в этом вызове не запускался (до ~1000 с). Задание разрешает построчную проверку, и я её сделал: раздел 4. На 3707adc4da гейт прогнал Rev175: rc 0, 924 с.
- Счёт своей мерой, против задания: правка `orch-tablo` в fix1 — +9/−4 (`--numstat`), а не «+13/−4»: 13 — это изменённые строки. Наблюдение Н-3. Автор в коммите чисел не заявляет.
- Живые прогоны зависят от текущего состояния станции (журнал моба 00:40:49Z, 193 в работе). Через ~6 ч без записей в журнал моба строка-факт законно сменится на СТОИТ.
- Скриншотов нет (не мобильный экран). sourceCanon не объявлен.
- Развилка: имя вердикта `-impl-v3.md` задано заданием, потому что `-impl-v1.md` (accept v1) уже на main, а `-impl-v2.md` (FAIL Rev175) — в ветке `wip/175/reviewer-impl1`, на origin её нет. На main `-impl-v2.md` нет, поэтому номер v3 оставляет пропуск до ленда ветки Rev175.
