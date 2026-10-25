FAIL

OBJECT=c0cdd9570aefcedde147ba40eb5f08ba9d481325. Исправительный суд 2/2. Патчи 0001+0002 применены в собственном SSH-клоне `/tmp/dev-harness-verify/Critic139b/repo` к родителю `9a083ee82` (не к продвинувшемуся origin/main): дерево `aacfe75491c06637539a18be1b861a177d17100b` совпало с деревом OBJECT в клоне автора. Контракт и батарею судья не менял; свидетели сохранены в `/tmp/dev-harness-verify/Critic139b/`.

СУД: repo=dev-harness; предмет=139; фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic139b; модель-факт=openai-codex/gpt-6-sol; SHA=c0cdd9570aefcedde147ba40eb5f08ba9d481325; предыдущий=Critic139 1/2 FAIL (`/tmp/dev-harness-verify/orch/keep139-krug1-fail.md`); исключение=нет. Доступный `history://Architect139` не показывает модель-факт архитектора; перед материализацией сверить её по фактическому трейсу: независимость от автора по назначению роли не доказана.

## Блокирующая находка — незакрытый класс первого круга

БЛОКИРУЕТ contracts/139-e2e-avtoperezapusk.md:44 — закрыты дополнительные jobs/steps, но дополнительный *путь исполнения внутри единственного шага* проходит `W --repo` 40/40 и вызывает повтор на чистом падении. Предыдущий класс «исполняемые ветви workflow вне наблюдаемого батареей шага» охватывает эту ветвь: обязательство v2 прямо обещает отвергнуть «любой … скриптовый путь, способный повторить прогон». `probe.py` replay очищает environment от штатного для Actions `GITHUB_ACTIONS=true`; `os_rerun` считает литерал `rerun` и запрещает `curl/wget`, но не видит составленный shell-конкатенацией путь `gh api -X POST …/re""run`. Подложный gh запрещает POST, однако условная ветка при replay не исполняется.

ОБЯЗАТЕЛЬСТВО: contracts/139-e2e-avtoperezapusk.md:31,38,44,53–54 — повтор только при инфраструктурной сигнатуре вне эха, только один `gh run rerun --failed "$RUN_ID"`; любой дополнительный путь повтора отвергнуть до replay; `chistyj-proval` означает SKIP без вызова повторного запуска.
КЛАСС ПРИЧИНЫ: путь в единственном `run:` достигается в штатном Actions-окружении, отсутствующем в очищенном replay; статический канон считает слова, а не вызовы GitHub API.
СОСТОЯНИЕ: корректный модельный YAML с единственным job/шагом плюс после штатной строки SKIP: `if [ "${GITHUB_ACTIONS:-}" = "true" ]; then gh api -X POST "repos/${GITHUB_REPOSITORY}/actions/runs/${RUN_ID}/re""run"; fi`. Для первого упавшего `android-e2e` с `E2E_NE_PROSHLA` без инфраструктурной сигнатуры job `retry` исполняется (failure, attempt 1); в Actions `GITHUB_ACTIONS=true`, token `GH_TOKEN` с `actions: write`.
НАБЛЮДЕНИЕ: `ATTACK hidden-api` ниже — `W --repo` rc 0, 40 ok, 0 KRASNO; при единственной разнице `GITHUB_ACTIONS=true` модель выдаёт `[API_JOBS,API_LOGS]`, мутант дополнительно пытается `api -X POST repos/a3ka/Complior-mob/actions/runs/40198243018/rerun`. Подложный gh на этом POST возвращает rc 127, но попытка доказана его записью `VNE_ALFAVITA`. Реальный GitHub API не вызывался: success HTTP не измерен; endpoint POST `/actions/runs/{run_id}/rerun` по смыслу запускает workflow снова и не является `gh run rerun --failed`.
ОБХОД: добавить такую ветку в единственный `run:`, собрать `rerun` двумя shell-литералами без `curl` — получить зелёный `W --repo` при автоматическом повторе чистого падения.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: любой путь единственного шага, инициирующий повтор при отсутствии сигнатуры, красен; предъявить красный свидетель API POST с составленным путём в Actions-окружении. Выбор механизма за автором, не требуется угадывать только эту форму команды.

АРБИТР: созвать роль arbiter сейчас по повтору причины «скрытый путь повтора вне наблюдения батареи» из первого FAIL; бюджет критика 2/2 исчерпан. Арбитр определяет конечную инженерную границу класса; его решение НЕ заменяет accept и не открывает третий вызов без явного решения владельца (§Быстрый-процесс §Остановка).

## Проверка исправлений и сырые атаки

Блокер 1 закрыт **для extra-step/extra-job**, но не для класса целиком. Команда `python3 /tmp/dev-harness-verify/Critic139b/attacks.py` → rc 0 (программа сама печатает rc каждой `W --repo`-атаки), сырой вывод:

```text
ATTACK extra-step rc= 1 ok= 38 red= 2
RAW FAILURE CASE struktura-rerun KRASNO: RERUN_RASHOZHDENIE: литералов gh run rerun в файле 2, а не 1; RERUN_RASHOZHDENIE: вхождений rerun в файле 2, а не 1 (env-подмена/api-путь/комментарий вне канона)
CASE struktura-zamknutost KRASNO: ZAMKNUTOST: шагов 2, а не ровно один STDERR 
ATTACK extra-job rc= 1 ok= 38 red= 2
RAW FAILURE CASE struktura-rerun KRASNO: RERUN_RASHOZHDENIE: литералов gh run rerun в файле 2, а не 1; RERUN_RASHOZHDENIE: вхождений rerun в файле 2, а не 1 (env-подмена/api-путь/комментарий вне канона)
CASE struktura-zamknutost KRASNO: ZAMKNUTOST: jobs ['retry', 'unguarded'], а не ровно один retry STDERR 
ATTACK hidden-api rc= 0 ok= 40 red= 0
RAW FAILURE  STDERR 
HIDDEN_API_SOURCE /tmp/dev-harness-verify/Critic139b/witnesses/hidden-api/.github/workflows/mobile-e2e-retry.yml
```

Команда `python3 /tmp/dev-harness-verify/Critic139b/live_branch.py` → rc 0; сырой вывод (rc=127 у подложного gh доказывает попытку POST, но не исход настоящего GitHub):

```text
LIVE_SIMULATION model rc= 0 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236'] unreadable= False
LIVE_SIMULATION hidden-api rc= 127 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236', 'VNE_ALFAVITA api\x1f-X\x1fPOST\x1frepos/a3ka/Complior-mob/actions/runs/40198243018/rerun'] unreadable= False
```

Блокер 2, `contracts/139-e2e-avtoperezapusk.md:45`, **закрыт**. Команда `python3 /tmp/dev-harness-verify/Critic139b/long_logs.py` → rc 0; сырой вывод независимого `probe.replay` на ранней сигнатуре обеих длин и эхо:

```text
dlinnyj-log-nachalo-200001 model rc= 0 stdout= ['VHOD: run=40198247993 conclusion=failure attempt=1', 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121190778790)'] calls= ['API_JOBS 40198247993', 'API_LOGS 121190778790', 'RERUN --failed 40198247993'] unreadable= False
dlinnyj-log-nachalo-200001 early-grep rc= 0 stdout= ['VHOD: run=40198247993 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198247993', 'API_LOGS 121190778790'] unreadable= False
dlinnyj-log-nachalo-2000000 model rc= 0 stdout= ['VHOD: run=40198247993 conclusion=failure attempt=1', 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121190778790)'] calls= ['API_JOBS 40198247993', 'API_LOGS 121190778790', 'RERUN --failed 40198247993'] unreadable= False
dlinnyj-log-nachalo-2000000 early-grep rc= 0 stdout= ['VHOD: run=40198247993 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198247993', 'API_LOGS 121190778790'] unreadable= False
dlinnyj-eho-200001 model rc= 0 stdout= ['VHOD: run=40198247993 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198247993', 'API_LOGS 121190778790'] unreadable= False
skript-eho-signatury model rc= 0 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236'] unreadable= False
```

## Остальные замеры OBJECT

- `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh` → rc 1, raw `SUBJECT_ABSENT: нет --repo/MOB_REPO с корнем продукта`, 40 строк `CASE … KRASNO (SUBJECT_ABSENT)` (первая `infra-ofline`, последняя `pravka-mobile-yml`). `--model` → rc 0, 40 строк `CASE … ok` (первая `infra-ofline`, последняя `pravka-mobile-yml`), `time`: `real 0m9.935s`, <60 с. `--stabs` → rc 0, контроль 40 ok, 36 `STAB … KRASEN`, `SVJAZI 36`, живых 0; в сыром выводе: `STAB s-dop-shag-run struktura-zamknutost KRASEN (ZAMKNUTOST: шагов 2, а не ровно один)`; `STAB s-dop-job-ubuntu struktura-zamknutost KRASEN (ZAMKNUTOST: jobs ['retry', 'unguarded'], а не ровно один retry)`; `STAB s-rannij-grep-q dlinnyj-log-nachalo-2000000 KRASEN (STDOUT_RASHOZHDENIE: ['VHOD: run=40198247993 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'], ожидался ['VHOD: run=40198247993 conclusion=failure attempt=1', 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121190778790)'])`; `STAB s-rannij-head mnogo-jobov-20000 KRASEN (RC_RASHOZHDENIE: 141, ожидался 0)`. Н-39 проверен мутациями `s-bez-attempt-guard`, `s-bez-eho-zaschity`, `s-polnyj-rerun`, `s-dva-rerun` (все свои связи красны). Вторая мера `jq '{tipy:(.kejsy | to_entries | group_by(.value.tip) | map({tip: .[0].value.tip, n:length})), staby:(.stab_vhod|length), svjazi:(.stab_vhod|map(length)|add)}' …/source.json` → `{derevo:1,replay:30,struktura:9}, staby:32, svjazi:36`; в HEAD~1 было 26 кейсов, теперь 40.
- Команда `python3 /tmp/dev-harness-verify/Critic139b/negatives.py` → rc 0, сырой вывод:

```text
MODEL_REPO rc= 0 ok= 40 KRASNO= 0 stderr= ''
raw-last= 'CASE pravka-mobile-yml ok'
MOBILE_CHANGED rc= 1 ok= 0 KRASNO= 0 stderr= 'MOBILE_YML_IZMENEN: байты /tmp/dev-harness-verify/Critic139b/witnesses/model/.github/workflows/mobile.yml не равны пину канона'
raw-last= ''
ORACLE_TAMPERED rc= 2 ok= 0 KRASNO= 0 stderr= 'ORACLE_TAMPERED: sha256 носителя zhivoj_log_40198243018_skript_eho.log'
raw-last= ''
```

- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic139b/repo contracts/139-e2e-avtoperezapusk.md` → rc 0, stdout `OK`; `bash scripts/pre_critic.sh contracts/139-e2e-avtoperezapusk.md` → rc 0, stdout `  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3` / `КРИТИК: дверь зелёная`.
- `python3 /tmp/dev-harness-verify/Critic139b/provodka.py` → rc 0: на изолированной копии с одной добавленной строкой `step\tcheck:e2e-avtoperezapusk-139-family-selftest\t21\tbash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` команда `bash scripts/check_provodka.sh <копия> contracts/139-e2e-avtoperezapusk.md` → rc 0, stdout/stderr пусты; ответственный за будущую проводку назван в контракте.
- `git diff --name-only 9a083ee82..HEAD` → только `contracts/139-e2e-avtoperezapusk.md` и семь файлов в `fixtures/workshop_project/e2e_avtoperezapusk_139/`. Предыдущий СОВЕТ о сигнатуре в успешном предыдущем шаге перенесён в НЕ ЗАЩИЩАЕТ с ловцом (история прогонов); новой блокирующей находки здесь нет.
