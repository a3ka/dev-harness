accept — PR#82 @ 6bc7166f5 можно сливать штатно. Диф: 3 файла (+68/−5). Каждый путь в зоне implementer живого блоба 093/4. Новый файл попадает под trailing-slash грант `ops/server/root/systemd/`. Дверь отказывает вне `GITHUB_ACTIONS=true` (rc=1, побочных эффектов нет). Новый sudoers не добавляется, `ci093-agent` sudo и группы runner не получает, scratch-копия удаляется trap'ом с сохранением rc guard'а. Живые RC своей мерой: `check_staged` 0, `check_zones` (полный) 0, `gen_ci_steps --check` 0, `check_provodka 093` 0 (на main 1), `verify_ci_parity` 0. PR-CI 12/12 pass на head 6bc7166f5, в l4 шаг 093 реально исполнен: `ЗЕЛЁНО(093-8): … euid=999 ≠ владельца=1001`, `ИТОГ 093: rc=0`. Блокирующих находок нет. Неблокирующие Рв82-1…5 — в `.review/2026-10-14-04.md`.

# Review PR#82 `wip/093/implementer` — CI-дверь второго uid для семьи 093

МОДЕЛЬ: `anthropic/claude-opus-5-5` (reviewer). Автор коммита 6bc7166f5 — identity implementer. По `scripts/models_actual.sh --tsv` это `zai/glm-5.3`, другое семейство.

**Субъект.** PR https://github.com/a3ka/dev-harness/pull/82, head `6bc7166f5f2d1eca0a955b99f0ed50c69f5e83d9`. Сверено через `gh pr view 82`: headRefOid, state OPEN, MERGEABLE, base main. В PR единственный коммит: `git log main..wip/093/implementer` → 6bc7166f5. Merge-base = main HEAD `47919a9ce`, так что ленд — чистый `--no-ff` поверх текущего main.

**Сборка.** Одноразовые клоны `/tmp/dev-harness-verify/review82-19817720` (PR-голова) и `…-st` (staged-проба на 47919a9ce, симуляция ленда, мутация). В основной репозиторий ничего не писалось, кроме этого вердикта. Ничего не пушилось в origin.

## 1. Область правки — PASS

```
$ git show --stat 6bc7166f5
 .github/workflows/ci.yml                 | 10 +++---
 ops/server/root/systemd/run-ops093-ci.sh | 62 ++++++++++++++++++++++++++++++++
 registry/ci-steps.tsv                    |  1 +
 3 files changed, 68 insertions(+), 5 deletions(-)
$ gh pr view 82 --json files → те же 3 пути (5/5, 62/0, 1/0)
```
Своя мера для ci.yml — множество ключей JOBS до и после (`comm -3`): разница ровно один ключ `check:granica-ispolneniya-093-family-selftest`. Ключей 101 → 102, дублей нет. Остальные 5 строк diff'а — перестановка lane LPT-генератором, а не правка руками (§4 `gen --check`). Строка TSV содержит 4 поля через `^I`: `step^Icheck:granica-ispolneniya-093-family-selftest^I120^Ibash ops/server/root/systemd/run-ops093-ci.sh fixtures/_krasnye_093.sh`.

## 2. Зона — PASS

```
$ git show refs/tags/frozen/contracts/093/4:contracts/093-granica-ispolneniya-i-postavka-ops.md | grep '^ЗОНА'
ЗОНА architect: contracts/093-granica-ispolneniya-i-postavka-ops.md fixtures/ops_granica/ fixtures/_krasnye_093.sh NABLIUDENIA_ARCHITECT.md
ЗОНА implementer: ops/server/install.sh ops/server/root/orch-peak ops/server/user/orch-loop ops/server/README.md ops/server/root/systemd/ registry/ci-steps.tsv .github/workflows/ci.yml
```
Автор и коммиттер 6bc7166f5: `implementer <implementer@dev-harness.local>`. `.github/workflows/ci.yml` и `registry/ci-steps.tsv` — точные файлы гранта. `ops/server/root/systemd/run-ops093-ci.sh` начинается с префикса-каталога `ops/server/root/systemd/`, то есть входит в trailing-slash грант. Текст контракта на main совпадает с тегом: `git diff --stat refs/tags/frozen/contracts/093/4 47919a9ce -- contracts/093-…` пуст.

Staged-проба (клон `-st` на 47919a9ce, `git checkout 6bc7166f5 -- <3 пути>`, env `GIT_AUTHOR_NAME=implementer`):
```
judged: .github/workflows/ci.yml
judged: ops/server/root/systemd/run-ops093-ci.sh
judged: registry/ci-steps.tsv
ok: staged в зоне автора implementer (3 путь/путей)
check_staged(positive) rc=0
```
Красное к ней: к тем же трём добавлен staged `scripts/run_ops093_ci.sh` (путь консультанта):
```
ОТКАЗ: вне зоны: scripts/run_ops093_ci.sh
check_staged(negative scripts/) rc=1
```

## 3. Безопасность двери — PASS

Тело (`git show 6bc7166f5:ops/server/root/systemd/run-ops093-ci.sh`, 62 строки, mode 100755) построчно:
- **CI-only:** строка 39 `[ "${GITHUB_ACTIONS:-}" = true ] || { printf 'CI-only door\n' >&2; exit 1; }` — первая исполняемая после `set -euo pipefail`, до любого побочного эффекта. Живьём на станции:
  ```
  env -u GITHUB_ACTIONS bash …/run-ops093-ci.sh fixtures/_krasnye_093.sh → CI-only door, rc=1
  GITHUB_ACTIONS=false …                                               → CI-only door, rc=1
  GITHUB_ACTIONS=TRUE  …                                               → CI-only door, rc=1
  env -u GITHUB_ACTIONS bash scripts/run_ci_lane.sh check:granica-ispolneniya-093-family-selftest
    + bash ops/server/root/systemd/run-ops093-ci.sh fixtures/_krasnye_093.sh
    CI-only door
    lane: отказ ключа check:granica-ispolneniya-093-family-selftest (rc=1)   → rc=1
  id ci093-agent → no such user; /var/lib/ci093-agent — нет
  ```
  CI-ветку на станции я не запускал намеренно: она делает `chmod go-rwx "$HOME"` и `install -d`. По коду первый привилегированный шаг — `sudo -n useradd` (строка 45). Он стоит ДО `chmod "$HOME"` (строка 47), а `set -e` прерывает скрипт на его отказе. Без passwordless sudo дверь выходит раньше любой правки HOME. Отказ implementer «sudo: a password is required» — с его слов, я его не перемерял.
- **Новый sudoers не добавляется:** в исполняемых (не-комментарных) строках нет ни `sudoers`, ни `visudo`, ни `/etc/` (своя мера: `grep -v "^#" | grep -cE "sudoers|visudo|/etc/"` → 0; `grep -c "sudo -n"` → 4). Все 4 вызова `sudo -n` (useradd, install ×2, `-H -u ci093-agent`) идут через существующую политику runner-пользователя.
- **ci093-agent без sudo и группы runner:** `useradd --system --user-group --create-home --home-dir /var/lib/ci093-agent --shell /usr/sbin/nologin` — без `-G`/`-aG`, своя группа. Агент стартует в `env -i` с `PATH=/usr/bin:/bin HOME=/var/lib/ci093-agent LC_ALL=C.UTF-8`. Креденшлы чекаута до него не доходят: копия собрана `git archive HEAD` (без `.git`), HOME раннера закрыт `go-rwx`. На CI клетка 8 меряет euid=999 ≠ владельца 1001. То, что на hosted-образе нет общего правила sudoers для всех, — [INFERENCE], на VM я это не мерял.
- **Изоляция и снятие scratch:** `mktemp -d /tmp/dev-harness-verify/ci093-XXXXXX` от uid раннера, без sudo и chown. `chmod 755` корня и `chmod -R a+rX,go-w` копии: агент читает, но писать не может. `trap 'rm -rf "$scratch"' EXIT`. Последняя команда — `sudo … /bin/bash "$guard"`, rc guard'а уходит наверх. Своя проба того, что EXIT-trap не съедает rc и снимает каталог:
  ```
  bash -c 'set -euo pipefail; s=…/trapprobe; mkdir -p $s; trap "rm -rf $s" EXIT; /bin/bash -c "exit 3"' → rc=3; ls trapprobe → No such file (rc=2)
  ```
- Сверка с телом-кандидатом консультанта (`diff` с нормализацией переносов): отличия — только usage-гард `[ $# -eq 1 ]` и идемпотентный `id -u ci093-agent || sudo -n useradd …`. Остальная последовательность совпадает.

## 4. Живые RC своей мерой — PASS

Клон `review82-19817720` на 6bc7166f5, через `reslop t --`:
```
bash scripts/gen_ci_steps.sh --check                                                   exit: 0
bash scripts/check_provodka.sh . contracts/093-granica-ispolneniya-i-postavka-ops.md   exit: 0   (stdout/stderr пусто)
bash scripts/verify_ci_parity.sh   … workflow-команд: 12 · скриптов в приёмке: 71 · объявленных исключений: 24 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0   exit: 0
bash scripts/check_zones.sh (полный, без --incr):
  FAIL строка ЗОНА вне объявленной грамматики в contracts/055-… (известная, на rc не влияет, дифф не трогает)
  замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 11146 · проверено по зонам: 2635
  AFTER check_zones rc=0
```
Красное к каждому барьеру:
```
# provodka на main 47919a9ce (до PR):
проводка: guard не подключён: fixtures/_krasnye_093.sh не вызывается в .githooks/ или .github/workflows/
provodka@main rc=1
# gen --check с ci.yml от main при реестре PR:
gen_ci_steps: дрейф блока JOBS — побайтовое расхождение с генерацией из реестра
gen_check(stale ci.yml) rc=1   → после возврата ci.yml PR: rc=0
# клетка 8 под uid владельца (клон, uid 1004 = stat-uid корня 1004):
раннер запущен под uid владельца станции: граница не установлена снаружи (И-8б, арбитраж 093)
cell8 owner-uid rc=1
```
Симуляция ленда (`-st`: 47919a9ce + `merge --no-ff -m 'land: wip/093/implementer' 6bc7166f5` = d9d2e6135):
```
замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 11133 · проверено по зонам: 2623
LAND check_zones rc=0
```
Мутация ленда: голова PR + коммит implementer с `scripts/run_ops093_ci.sh`, ленд тем же merge (251aca283):
```
  FAIL коммит вне зоны: implementer ab51cf32 scripts/run_ops093_ci.sh — зона автора (объединение всех замороженных): …
… проверено по зонам: 2624
LAND+MUT check_zones rc=1
```
После ленда суд зон видит коммиты ветки wip/093: 2623 → 2624, и мутация краснеет. Значит, зелёное на ленде — это суд, а не выпадение из окна.

## 5. PR-CI — PASS

```
$ gh pr checks 82   (rc=0)
antiplacebo ap1..ap5   pass (5)
ci l1..l7              pass (7)   — l4: ci (l4, check:granica-ispolneniya-093-family-selftest check:fix-090-…) pass 7m17s
$ gh api …/actions/runs/38599989026 → head_sha 6bc7166f5f2d…, event pull_request, conclusion success, run_attempt 2
```
Шаг 093 не отфильтрован и реально исполнен. Лог job l4 (`gh api …/jobs/115983279521/logs`):
```
16:41:17.6081640Z + bash ops/server/root/systemd/run-ops093-ci.sh fixtures/_krasnye_093.sh
16:44:26.7656544Z ЗЕЛЁНО(093-bat): 10/10 обманных стабов пойманы
ЗЕЛЁНО(093-1) … ЗЕЛЁНО(093-2) … ЗЕЛЁНО(093-9) … ЗЕЛЁНО(093-3) … ЗЕЛЁНО(093-4) … ЗЕЛЁНО(093-5) … ЗЕЛЁНО(093-6) … ЗЕЛЁНО(093-7) …
16:44:43.9288050Z ЗЕЛЁНО(093-8): граница унаследована (euid=999 ≠ владельца=1001), чтение и запись перечня станции отказаны ОС (И-8а+б)
16:44:43.9289209Z ИТОГ 093: rc=0
16:44:44.1185600Z + bash fixtures/_krasnye_090.sh   … ИТОГ 090: rc=0
```
Своя мера счёта: 9 клеточных строк ЗЕЛЁНО(093-1…9) плюс батарея 10/10 — это ровно заявленное в шапке двери «10/10, все клетки rc 0, ИТОГ 093: rc=0». Клетка 8б зеленеет через чужой euid, полученный снаружи, а не через подмену: fixtures в диффе нет. Позитив измерен один раз (Рв82-5): попытка 1 упала только на ap5 (`profile_resolver/case_defaults_vne_alfavita.sh`, вне диффа), job l4 попытки 1 (115976457045) зелёный с теми же штампами.

## 6. Норма не тронута молча — PASS

В диффе ровно 3 пути (§1). Не тронуты `contracts/`, `roles/`, `AGENTS.md`, `fixtures/` (в том числе `fixtures/_krasnye_093.sh` и `fixtures/ops_granica/`), `scripts/`, `config/ci_parity_exceptions.txt`. Текст 093 на main совпадает с тегом 093/4 (§2). Файлы проверок автор реализации не менял, guard исполняется неизменённым из `git archive HEAD`.

## ПРОВОДКА (контракт 038)

Канал: `ПРОВОДКА: guard=fixtures/_krasnye_093.sh`. Цепочка: `registry/ci-steps.tsv:79` → JOBS l4 в ci.yml → `run_ci_lane.sh` → дверь → `/bin/bash "$guard"`. Канал существует и подключён: `check_provodka` 1 → 0, лог l4 показывает исполнение. Guard — раннер семьи этого предмета, а не посторонний скрипт дерева. Цель поля ПРОВОДКА-ЭНФОРСМЕНТ 093/4 — «CI-шаг обязан создать [второй uid] и запустить раннер от его имени (`sudo useradd` + `sudo -u <uid агента> bash fixtures/_krasnye_093.sh`)… самопереключение uid раннером не строится». Она выполнена: uid переключает внешняя дверь, семья не тронута. Guard-only при строке ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: это станционная граница исполнения, предметного role-канала нет, норма не 029-класса.

## Атомарность и маршрут — PASS

Одна задача — один коммит со ссылкой на предмет (fork `093-provodka-ci-uid-door-ne-postroen` и вердикт консультанта). Маршрут: ветка → PR → CI → reviewer. В main 6bc7166f5 нет.

## Паразитная сложность (контракт 050)

**А. `ops/server/root/systemd/run-ops093-ci.sh` (новый скрипт).** (1) Свойство: ПРОВОДКА-ЭНФОРСМЕНТ 093/4 — CI-шаг создаёт второй uid и запускает guard от его имени. Простые формы не проходят. Реестр отвергает ведущий `sudo` («команда вне грамматики») и `bash -c` («bash-путь -c не найден») — замер консультанта. Setup в `run:` workflow потребовал бы новых строк `config/ci_parity_exceptions.txt`. Итог: ESSENTIAL. (2) Состояние: на VM создаются пользователь, `go-rwx $HOME`, `/tmp/dev-harness-verify`, `/var/lib/orch-peak` и scratch. Scratch снимается trap'ом, остальное живёт до конца lane и в выводе не видно — Рв82-3, совет. (3) Совместные правки: смена guard'а — 1 строка реестра (guard передаётся аргументом). Смена ключа — реестр плюс регенерация ci.yml, как у любого step. Число не выросло. (4) Глубина: 1 позиционный аргумент, 1 читаемая env (`GITHUB_ACTIONS`), rc = rc guard'а либо 1 при отказе. За этим скрыты провижининг uid, изоляция копии и переключение uid. Модуль глубокий. (5) Потребитель: ключ `check:granica-ispolneniya-093-family-selftest` в lane l4 и `check_provodka`. Логику дерева не повторяет: `install.sh` провизионит станционного `orchagent`, шимы клеток 3/4/7 — субъект теста, а не внешний uid. Размещение в каталоге юнитов — Рв82-1, совет: более простая форма `scripts/` вне зоны.

**Б. Строка `registry/ci-steps.tsv`.** (1) Свойство: «Подключение в CI — implementer строкой в `registry/ci-steps.tsv` + `gen_ci_steps.sh --write`» (093/4). (2) Нового состояния не вводит. (3) 2 файла, генератор, как у каждого step. (4) Интерфейс не растёт. (5) Потребитель — генератор JOBS и `verify_ci_parity`. ESSENTIAL. Вес 120 против измеренных ≈206.5 с — Рв82-2, совет.

**В. Регенерация `.github/workflows/ci.yml`.** Порождённый артефакт, `gen --check` rc=0. ESSENTIAL.

## Находки

Блокирующих находок нет. Неблокирующие, подробно — в `.review/2026-10-14-04.md`:
- Рв82-1 [→ orchestrator/architect], класс «паразитная сложность 050 / размещение», совет: исполняемая CI-дверь лежит в каталоге systemd-юнитов. Место вынуждено зоной; при будущем глоб-потребителе каталога её подберут.
- Рв82-2 [→ implementer], класс «заявленное ≠ сделанное (вес LPT)», совет: вес 120 — объявленная оценка, замер CI ≈206.5 с теперь есть.
- Рв82-3 [→ orchestrator], класс «состояние побочным эффектом (050, вопрос 2)», наблюдение: эффекты двери на VM, кроме scratch, переживают шаг и действуют на следующие ключи lane.
- Рв82-4 [→ orchestrator], класс «заявленное ≠ сделанное (пересказ адаптации)», неточность: в теле коммита не названы смена пути и смена ключа относительно кандидата консультанта.
- Рв82-5 [→ orchestrator], класс «наблюдение вне диффа»: позитив второго uid — n=1 (re-run перезапустил только ap5); флак ap5 `profile_resolver/case_defaults_vne_alfavita.sh`.

Вердикт: **accept**.
