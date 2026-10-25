accept

OBJECT=72e27313d9a1f4b41f16c39ae9912b4a6d27eb8a (Complior-mob, ветка `cmp-mob-139/e2e-avtoperezapusk`, PR a3ka/Complior-mob#126; `gh pr view 126` → `headRefOid=72e27313d9a1f4b41f16c39ae9912b4a6d27eb8a`, `isCrossRepository=false`). Контракт `frozen/contracts/139/1` (`contracts/139-e2e-avtoperezapusk.md`), харнесс origin/main `b9b4c66f3d84dc8aa7eb7c8e83b466e807817416`.

СУД: repo=dev-harness; предмет=139; фаза=реализация; роль=reviewer; вызов=1/2 (полный); сессия=Rev139; модель-факт=anthropic/claude-opus-5-5; SHA=72e27313d9a1f4b41f16c39ae9912b4a6d27eb8a; автор Impl139 — `minimax` (трасса `models_actual`, со слов задания; трассу сам не открывал), семейства разные; адверсарий не вызывался (риск «обычный»).

**БЛОКИРУЕТ: нет.** **СОВЕТ: 6** (С1–С6 ниже).

перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код

## Клоны (Н-143)

Одноразовые SSH-клоны со своим `.git`: `git clone -q ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev139/harness` и `git clone -q ssh://git@github.com/a3ka/Complior-mob.git /tmp/dev-harness-verify/Rev139/mob` → rc 0. `git fetch origin cmp-mob-139/e2e-avtoperezapusk` в клоне продукта — дважды rc 128 `ERROR: Repository not found.` (сразу после успешного clone по тому же адресу; сбой транспорта, разбирать не стал). Clone уже содержал `origin/cmp-mob-139/e2e-avtoperezapusk`: `git checkout -q origin/cmp-mob-139/e2e-avtoperezapusk && git rev-parse HEAD origin/main` → `72e27313d9a1f4b41f16c39ae9912b4a6d27eb8a` / `8f338d885333f78c79070e663713288280ca500c`; HEAD совпадает с `headRefOid` PR. Клон `Impl139/mob` источником не служил.

## 1. Область правки

```
$ git log --format='%H %an <%ae> %s' origin/main..HEAD
72e27313d9a1f4b41f16c39ae9912b4a6d27eb8a implementer <implementer@dev-harness.local> ci: mobile-e2e-retry — один автоповтор android-e2e по инфра-сигнатурам (контракт 139)
$ git diff origin/main..HEAD --stat
 .github/workflows/mobile-e2e-retry.yml | 70 ++++++++++++++++++++++++++++++++++
 1 file changed, 70 insertions(+)
$ git diff origin/main..HEAD --name-status
A	.github/workflows/mobile-e2e-retry.yml
$ git diff origin/main HEAD -- .github/workflows/mobile.yml | wc -c
0
```

Ровно один новый файл в ЗОНЕ implementer; `mobile.yml` и шаги 995/108/111/117/123/135 не тронуты. Коммит один, ссылается на контракт 139 (атомарность). Нормативных документов дифф не касается.

## 2. Соответствие контракту и модели

```
$ sha256sum .github/workflows/mobile-e2e-retry.yml (продукт @OBJECT) и model/mobile-e2e-retry.yml (харнесс @b9b4c66f)
53beb5949243a8cfef2ec4cd780395bb042f144f06f3c26a342fbea1370ab779  .github/workflows/mobile-e2e-retry.yml
53beb5949243a8cfef2ec4cd780395bb042f144f06f3c26a342fbea1370ab779  fixtures/workshop_project/e2e_avtoperezapusk_139/model/mobile-e2e-retry.yml
$ cmp <модель> <субъект>; echo cmp_rc=$?
cmp_rc=0
```

Мой статический замер, отдельный от батареи: `python3 /tmp/dev-harness-verify/Rev139/static139.py` и `static139b.py` (pyyaml, разбор по тексту файла) → rc 0:

```
top keys: ['True', 'jobs', 'name', 'permissions']            # True = ключ `on` в YAML 1.1
on: {'workflow_run': {'workflows': ['mobile'], 'types': ['completed']}}
permissions: {'actions': 'write', 'contents': 'read'}
jobs: ['retry']
job keys: ['if', 'runs-on', 'steps', 'timeout-minutes'] runs-on: ['self-hosted', 'linux', 'x64', 'complior'] timeout: 5
if: github.event.workflow_run.name == 'mobile' && github.event.workflow_run.conclusion == 'failure' && github.event.workflow_run.run_attempt == 1
steps: 1 step keys: ['env', 'name', 'run']
expressions: ['github.event.workflow_run.conclusion', 'github.event.workflow_run.id', 'github.event.workflow_run.run_attempt', 'github.token']
count 'gh run rerun' file/run: 1 1 word rerun: 1
secrets: False uses: False checkout: False
signatury verbatim in run: True gradle/lock in run: False
echo-cut present: True
grep -q on file (not pipe end): True head: False
code lines: 26
HIT: for | if grep -qE '…|Timeout waiting for emulator' "$LOG_F"   # единственное «for» — слово внутри сигнатуры, циклов нет
```

`sed q` в первом прогоне дал ложное срабатывание: буква `q` из комментария `# sed -n '1p' … (без 'q')`. По 26 строкам кода без комментариев (`static139b.py`) `sed … q` нет. Замер «26 строк кода» совпадает с батареей (`в каноне 26`).

Страж скрипта: `CONCLUSION != failure` → SKIP; `ATTEMPT != 1` → SKIP; JID — `sed -n '1p'`; эхо вырезается `sed -e '/##\[group\]Run /,/##\[endgroup\]/d'` в файл; `grep -qE '<канон 7 альтернатив>' "$LOG_F"`; ровно один `gh run rerun --failed "$RUN_ID"`. `workflows: [mobile]` и фильтр `android-e2e` совпадают с живыми именами: `mobile.yml:1 name: mobile`, а jobs API run 40220769334 → `121252247319 android-e2e failure`.

**Инъекции через `${{ github.event.workflow_run.* }}`:** выражения стоят только в `env:` и `if:`, в теле `run:` их нет. Значения: `id` и `run_attempt` — числа, `conclusion` — перечисление, `github.token`. Поля, которыми управляет атакующий (`head_branch`, `display_title`, `head_commit.message`, `head_repository.*`), не используются, алфавит выражений закрыт (`struktura-vyrazhenija`). Текст лога идёт только в `printf '%s\n' "$LOG"` (builtin, ARG_MAX нет) → `sed` → файл → `grep -q`, не исполняется. Путь инъекции не нашёл.

## 3. Приёмка батареи, сырой вывод из моего клона

Рабочий каталог — `/tmp/dev-harness-verify/Rev139/harness` @ `b9b4c66f3`; `W` = `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh`.

- `W` (без субъекта) → **rc 1**, `SUBJECT_ABSENT: нет --repo/MOB_REPO с корнем продукта` + 42 `CASE … KRASNO (SUBJECT_ABSENT)` (первая `infra-ofline`, последняя `struktura-skript-pereformat`).
- `W --model` → **rc 0**, 42 строки `CASE … ok`, 14.45 с (≤ 60).
- `W --stabs` → **rc 0**, 42 `CASE … ok`, 60 строк `STAB … KRASEN (…)`, финал `SVJAZI 60`, строки `PROSHYOL`/`STAB_ZHIV` отсутствуют, 27.68 с. Примеры строк: `STAB s-skrytaja-vetv-github-actions chistyj-proval KRASEN (@ACTIONS RC_RASHOZHDENIE: 127, ожидался 0)`; `STAB s-rannij-grep-q dlinnyj-log-nachalo-2000000 KRASEN (@CHISTYJ STDOUT_RASHOZHDENIE: […'SKIP: …'], ожидался […'POVTOR: …'])`; `STAB s-dop-job-ubuntu struktura-zamknutost KRASEN (ZAMKNUTOST: jobs ['retry', 'unguarded'], а не ровно один retry)`.
- **Вторая мера, другой командой** (`python3 /tmp/dev-harness-verify/Rev139/count139.py --stabs`: заново запускает W, разбирает stdout построчно и отдельно читает source.json) → `kejsy dict 42`, `stab_vhod dict 41`, `nositeli dict 3`; `mode ['--stabs'] rc 0`, `CASE total 42 ok 42`, `STAB lines 60 KRASEN 60 distinct stabs 41`, `tail: ['SVJAZI 60']`, stderr пуст. Мой первый счётчик (`grep -cE '^STAB .* KRASEN$'`) дал 0: строка не кончается на `KRASEN`, за ним идёт `(…)`. Это ошибка моего regex, исправлена во второй мере.
- `W --repo /tmp/dev-harness-verify/Rev139/mob` (безфлаговая, реальный main продукта + PR) → **rc 1**, stderr `MOBILE_YML_IZMENEN: байты /tmp/dev-harness-verify/Rev139/mob/.github/workflows/mobile.yml не равны пину канона`. Известный факт подтверждён. Причина измерена: `git show 1e9bcc59a2:.github/workflows/mobile.yml | sha256sum` → `31c400e7…c32ae` (= пин), main `8f338d885` → `282288de…08421`. `git diff 1e9bcc59a2 origin/main -- .github/workflows/mobile.yml` — одна строка job `quality`: `-    runs-on: ubuntu-24.04` / `+    runs-on: [self-hosted, linux, x64, complior]` (PR #125, не автор 139).
- **Копия батареи с перепином, собранная мной** (`python3 /tmp/dev-harness-verify/Rev139/repin139.py` → `repin 31c400e7… -> 282288de…`; копия лежит вне репо в `/tmp/dev-harness-verify/Rev139/battery_repin/`). `diff -r` против оригинала показывает ровно две правки: `nositeli/mobile.yml` (та же строка `runs-on`) и `source.json:40` (пин). Затем `bash …/battery_repin/…/red_e2e_avtoperezapusk_139.sh --repo /tmp/dev-harness-verify/Rev139/mob` → **rc 0, 42/42 `CASE … ok`**.

**Красное против сломанной реализации** (`python3 red139.py && bash runred139.sh`). Деревья — реальный `mobile.yml` main и субъект PR с одной мутацией; суд — перепиненной копией:

| дерево | rc | ok/42 | первые клетки KRASNO |
|---|---|---|---|
| bez-failed (`gh run rerun "$RUN_ID"`) | 1 | 20 | 19× replay `RC_RASHOZHDENIE: 127` + `VNE_ALFAVITA run␟rerun␟…`; `struktura-rerun RERUN_RASHOZHDENIE`; `struktura-skript … строка 23` |
| gradle-v-signaturah (`\|Timeout waiting to lock`) | 1 | 39 | `gradle-lock … 'POVTOR: …'`; `struktura-skript … строка 21` |
| bez-attempt (`if false; then`) | 1 | 39 | `attempt-2-ofline … 'POVTOR: …'`; `struktura-skript … строка 7` |
| bez-eho (`sed -e ''`) | 1 | 38 | `skript-eho-signatury`, `dlinnyj-eho-200001` → POVTOR; `struktura-skript … строка 20` |
| kontrol-kommentarij (только комментарий/пустая строка) | **0** | **42** | — (свобода формата подтверждена) |

Перепин не ослабляет приёмку: мутации реализации краснеют на той же копии, а правка только формата остаётся зелёной. `W --svideteli /tmp/dev-harness-verify/Rev139/svideteli` → rc 0, 6 деревьев. `W --repo` на каждом → **6/6 rc 1** `CASE struktura-skript KRASNO: SKRIPT_RASHOZHDENIE: строка 27: …` (env-ci, env-f-post, kritik-hidden-api, run-id-vne-batarei, sandbox-tell-gh-bin, sandbox-tell-scenarij).

**Replay на живых данных** (сверх батареи; `python3 /tmp/dev-harness-verify/Rev139/live139.py 40220769334 failure 1`). Тело `run:` субъекта исполнялось против РЕАЛЬНОГО API: GET jobs/logs шел через настоящий `gh`, `run rerun` перехватывал шим. Результат: `rc 0`; `VHOD: run=40220769334 conclusion=failure attempt=1` / `SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки`; вызовы: `SHIM_API …/runs/40220769334/jobs`, `SHIM_API …/jobs/121252247319/logs`, rerun не вызывался. Сверка — `logscan139.py 121252247319` → `lines 2187 sig_in_eho 2 sig_vne_eho 0`, `PRICHINA	E2E_NE_PROSHLA	rc=1` (стр. 2032). Решение совпадает с контрактом: сигнатуры только в эхе → SKIP.

## 4. Не переписаны ли проверки под код

`git diff frozen/contracts/139/1 origin/main --stat -- fixtures/workshop_project/e2e_avtoperezapusk_139/ contracts/139-e2e-avtoperezapusk.md` → пусто, rc 0. `git log --all --format='%h %an %s' -- fixtures/workshop_project/e2e_avtoperezapusk_139/` → только `da7029ea`/`ca7f3de8`/`839b28b4` от `architect`. `git log --all --author=implementer --since=2026-10-25` в харнессе → пусто; `git branch -r --list '*139*'` → пусто. Пин `nositeli.mobile.yml` в source.json — по-прежнему `31c400e7…`; пин модели — `53beb594…`. Перепиненная копия implementer (`/tmp/dev-harness-verify/Impl139/battery_repin`) лежит вне репозитория, в PR — один файл workflow. Следов в репо нет.

## 5. ПРОВОДКА (038) и паразитная сложность (050)

ПРОВОДКА: `guard=fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh` существует, это барьер именно предмета 139. Он судит файл субъекта 42 клетками, на сломанных деревьях выше становится красным. ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно: механический CI-гейт на норму о поведении CI, role-канал не нужен. Подключение self-test в CI ещё не сделано (С4).

Паразитная сложность, артефакт `.github/workflows/mobile-e2e-retry.yml` (единственный в диффе):
(1) требуют инварианты 1–10 и «Предмет» контракта 139;
(2) нового состояния не вводит. Есть только временный `LOG_F` из `mktemp` (`trap rm` на EXIT); входы явны через `env:` (RUN_ID/CONCLUSION/ATTEMPT/GH_TOKEN), выход явный — строка `VHOD:` и `POVTOR:`/`SKIP:` + один вызов `gh`;
(3) при следующей правке того же свойства вместе меняются файл и `model/…` (канон построчно) с пином sha256 в source.json, всего 3. Дифф это число не увеличил: связь задал frozen-контракт;
(4) глубина: интерфейс — 4 env и событие, работа — фильтр jobs, вырезка эха, сигнатурный grep, однократный повтор; модуль не мелкий;
(5) потребитель — строки приёмки 2/5 и вход `W --repo`; дублирования грамматики нет, сигнатуры — канон шагов 116/117 + поправка владельца.
Итог: **ESSENTIAL**.

Неприменимо: мобильный экран (экрана нет), sourceCanon (не объявлен).

## БЛОКИРУЕТ

нет. Состояния, на котором реализация нарушала бы названное обязательство контракта, не нашёл: файл побайтово равен замороженной модели, все клетки зелёные на реальных байтах main, мутации красные.

## СОВЕТ

**С1 (дизайн контракта; самое весомое; владельцу и оркестратору). Механизм по замеру не сработал бы ни на одном историческом падении, включая эталонный флейк Н-407 из раздела «Существующее».** `python3 /tmp/dev-harness-verify/Rev139/attempts139.py 40198247993 40198243018 40220769334` (живой API, решение канона 139 по каждой attempt) → rc 0:
```
run 40198247993 attempt 1 android-e2e failure -> SKIP; PRICHINA=[]; sig_vne_eho=0 []
run 40198247993 attempt 2 android-e2e failure -> SKIP; PRICHINA=[]; sig_vne_eho=0 []
run 40198247993 attempt 3 android-e2e failure -> SKIP; PRICHINA=['PRICHINA\tE2E_NE_PROSHLA\trc=1']; sig_vne_eho=0 []
run 40198247993 attempt 4 android-e2e success
run 40198243018 attempt 1 android-e2e failure -> SKIP; PRICHINA=['PRICHINA\tE2E_NE_PROSHLA\trc=1']; sig_vne_eho=0 []
run 40220769334 attempt 1 android-e2e failure -> SKIP; PRICHINA=['PRICHINA\tE2E_NE_PROSHLA\trc=1']; sig_vne_eho=0 []
```
Итог: **0 из 5 упавших attempt-ов → POVTOR**. Причины по `errctx139.py 40198247993 1 2 3`: att.1 — `BUILD FAILED` gradle (вне сигнатур по нарезке В, Н-409); att.2 — `995 native rc=1 testcases=7 failed=6`; att.3 — шаг 135 `PRICHINA E2E_NE_PROSHLA`, между `Picked up JAVA_TOOL_OPTIONS` и PRICHINA вывода нет. Шаг 135 гасит adb в `>/dev/null 2>&1`, вывод Maestro уходит в каталог артефакта. [INFERENCE] При frozen-тексте шага 135 обрыв adb в Maestro до лога job-а почти не доходит, и до нового слова владельца первый «реальный инфра-флейк» (критерий 5) может не наступить. Это не дефект реализации: «только по сигнатурам» — слово владельца, шаг 135 трогать запрещено. Ловец — решение владельца: (а) выводить диагностику adb/Maestro вне эха (очередь Н-407, отдельный контракт по шагу 135) или (б) расширить признак повтора. Оркестратору — записать замер в NABLIUDENIA/HANDOFF, чтобы долгое отсутствие `POVTOR:` не прочитали как «флейков нет».

**С2 (дизайн frozen-инварианта 6, ответ на п.3(а)/(б) задания).** (а) Приёмку не ослабляет: перепин ставит пин ровно на байты main (`282288de…`, проверено sha256 и `diff -r`). Реализация судится теми же 42 клетками, мутанты красные, переформат зелёный (таблица выше). (б) Пин байтов целого `mobile.yml` ломается любой законной правкой — уже сломан однострочной правкой `quality` из PR #125. Реализацию это не затрагивает: в диффе нет состояния, где она нарушает обязательство. Ловец: перепин данными (зона architect: `nositeli/mobile.yml` + `source.json:nositeli.mobile.yml`) при каждом законном изменении `mobile.yml`. Его нужно сделать ДО подключения пост-лендового безфлагового `W --repo` в CI, иначе шаг будет красным с первого прогона.

**С3 (merge-гейт PR #126).** `gh pr view 126` → `mergeStateStatus=BLOCKED`, checks `quality SUCCESS`, `android-e2e FAILURE` (run 40220769334, шаг 135 `E2E_NE_PROSHLA`, сигнатур вне эха 0). К диффу отношения нет: новый файл не входит в workflow `mobile` и в PR не исполняется (`workflow_run` идёт только из default branch). Для merge нужен зелёный android-e2e — ручной повтор оркестратора; сам 139 этот случай не повторил бы даже после merge (SKIP, см. С1).

**С4 (ПРОВОДКА).** На origin/main `b9b4c66f3` в `registry/` и `.github/` нет упоминания `e2e_avtoperezapusk` (grep пуст). Строку `check:e2e-avtoperezapusk-139-family-selftest … --stabs` кладёт оркестратор интеграционным коммитом по контракту; до `done_contract 139` она обязана появиться.

**С5 (платформа, fork-PR).** `workflow_run` срабатывает и на прогоны `mobile` из fork-PR и исполняется в контексте базового репо с `actions: write`. Скрипт fork-кода не исполняет и не делает checkout, читает только лог. Автор форка, печатающий сигнатуру вне эха, получит не больше одного `rerun --failed`: гейт attempt ограничивает. Обычный путь fork-PR (`PILOT_DEMO_CODE_ABSENT`) → SKIP (вход `fork-pr-bez-sekreta`). Формулировки §НЕ ЗАЩИЩАЕТ и ПРЕДПОСЫЛОК (default branch, `gh` на раннере, политика прав) этого достаточны. Добавить к ним стоит только замер С1.

**С6 (процесс).** `git fetch origin cmp-mob-139/e2e-avtoperezapusk` по SSH дважды вернул rc 128 `Repository not found` сразу после успешного `git clone` по тому же адресу. Ref взят из clone и сверен с `headRefOid` PR. Если повторится у других ролей, это транспорт или ключ станции.

## Числа замеров (сводка)

`W` rc 1 / 42 KRASNO; `W --model` rc 0 / 42 ok / 14.45 с; `W --stabs` rc 0 / 42 ok / 60 STAB KRASEN / 41 стаб / SVJAZI 60 / живых 0 (две меры: stdout W и count139.py); `W --repo` реальный main rc 1 `MOBILE_YML_IZMENEN`; перепиненная копия: rc 0 42/42, мутанты 4/4 rc 1, контроль формата rc 0 42/42; свидетели 6/6 rc 1 `строка 27`; живой replay run 40220769334 → SKIP без rerun; история: 0/5 упавших attempt-ов → POVTOR.
