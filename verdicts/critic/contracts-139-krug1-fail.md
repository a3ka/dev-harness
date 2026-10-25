FAIL

OBJECT=2f444f9effefb2ac7895d0167321560839e69732; суд 1/2 (полный), роль critic-sol. Отдельный SSH-клон `/tmp/dev-harness-verify/Critic139/repo`: патч архитектора применён к родителю `9a083ee821`; дерево HEAD `95fb203d35e24703542df0c8ac5f28c8bf81b6a7` = дерево OBJECT `95fb203d35e24703542df0c8ac5f28c8bf81b6a7`. Изменений контракта/реализации судьёй нет.

СУД: repo=dev-harness; предмет=139; фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-astra (дословно HANDOFF main `22243e8ab`, устарела относительно фактического вызова); сессия=Critic139; модель-факт=openai-codex/gpt-6-sol; SHA=2f444f9effefb2ac7895d0167321560839e69732; предыдущий=нет; исключение=нет. Модель-факт автора в доступном `history://Architect139` не выведена; назначение architect в `config/agent_models.json` = zai/glm-5.3 с autoFallback на Sol. Оркестратору до материализации сверить **фактический** трейс архитектора и дополнить HANDOFF; по назначению вместо трейс-подтверждения независимость не утверждаю.

## Находки (2 блокирующих класса)

БЛОКИРУЕТ contracts/139-e2e-avtoperezapusk.md:29 — батарея смотрит только первый шаг job `retry`, хотя предмет/инвариант 2 требуют ровно одного повтора на ВСЁ исполнение workflow. Класс причины: **исполняемые ветви workflow вне наблюдаемого батареей шага**; `probe.py:346-363,425-433` проверяет `jobs.retry.steps[0]`, не другие шаги/jobs. Один класс, два свидетеля: дополнительный шаг и дополнительный job. 
ОБЯЗАТЕЛЬСТВО: при чистом провале android-e2e никакого rerun; при инфраструктурном провале один `gh run rerun --failed`, только на `[self-hosted, linux, x64, complior]` (контракт:29,36,39,49).
СОСТОЯНИЕ: допустимый YAML из модели + второй шаг `retry` после основного, выполняющий `gh run rerun --failed "$RUN_ID"` с `${{ github.token }}` и `${{ github.event.workflow_run.id }}`; первая ступень на `chistyj-proval` выводит SKIP и завершает шаг rc 0, затем GitHub Actions исполнит второй шаг и повторит чистый провал. Независимый вариант — второй job `unguarded` на `ubuntu-latest`, наследующий workflow-level `actions: write`: при `run_attempt==2` он будет повторять снова, а при любом красном прогоне тратить запрещённый GitHub-hosted runner. Оба варианта — YAML, проходят всю батарею `W --repo` 26/26, rc 0.
НАБЛЮДЕНИЕ: `ATTACK extra-step` и `ATTACK extra-job` ниже: rc 0, по 26 `ok`; парсер YAML подтвердил 2 steps/2 jobs; второй шаг `gh run rerun --failed "$RUN_ID"` не был replay'нут. Это обход ложной достаточности приёмки `contracts/139-e2e-avtoperezapusk.md:50`.
ОБХОД: добавить после первого корректного шага второй автоматический rerun; зелёный `W --repo` принимает workflow, перезапускающий и чистый провал, и инфра-сбой дважды. Или добавить неограниченный второй job с `ubuntu-latest`; батарея видит только `retry`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: батарея отвергает исполнение ЛЮБОГО дополнительного job/шага/скриптового пути, способного повторить прогон, и нарушение бюджета runner; красные мутанты на дополнительный шаг И дополнительный job, а не только модель с одним шагом.

БЛОКИРУЕТ contracts/139-e2e-avtoperezapusk.md:49 — зелёная модель **не перезапускает валидный инфраструктурный сбой при длинном логе**, которого батарея из 17 replay не предъявляет. Класс причины: **pipefail и ранний `grep -q` на большом потоке**: в модели `printf '%s\n' "$LOG_OCISTENNYY" | grep -qE ...` под `set -euo pipefail`; grep завершается, когда видит раннюю сигнатуру, printf получает SIGPIPE, status pipeline становится неуспешным, условие `if` идёт в SKIP. Это дефект контрактной модели и недостаточность набора входов до раздачи реализации, не ревью конкретной реализации.
ОБЯЗАТЕЛЬСТВО: упавший android-e2e с `device offline` вне эха, attempt=1, получает один `rerun --failed` независимо от длины последующих строк лога (контракт:29,37,49–50).
СОСТОЯНИЕ: вход `infra-ofline` из source.json, но лог `maestro: device offline\n` + 200000 строк `unused log line example\n` после неё (допустимая длина лога не ограничена демаркацией: contracts/139-e2e-avtoperezapusk.md:99). Короткий контроль того же класса — 100 строк.
НАБЛЮДЕНИЕ: `large_log.py` ниже: короткий вход → `POVTOR`, `[API_JOBS,API_LOGS,RERUN --failed]`; длинный вход → rc 0, `SKIP: инфраструктурной сигнатуры ... нет`, только `[API_JOBS,API_LOGS]` при реально присутствующей сигнатуре.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: вход с ранней сигнатурой и реалистично длинным последующим логом, ожидающий `RERUN --failed`, проходит на исправленной модели с `set -o pipefail`, а намеренно ломанный ранний `grep -q` красен; исправление должно сохранить защиту от эха.

СОВЕТ contracts/139-e2e-avtoperezapusk.md:23 — принятая граница «смешанный лог с сигнатурой → повтор» разрешает случай сигнатуры в *успешном предыдущем шаге*, если последующий шаг упал только на `E2E_NE_PROSHLA`. Выбор границы следует за явной нарезкой В, поэтому не блокирую; при уточнении воли владельца различать успешный и упавший шаг пересмотреть оракул. Сырой дополнительный замер ниже.

СОВЕТ contracts/139-e2e-avtoperezapusk.md:59 — оркестратор подключает CI self-test отдельным интеграционным коммитом: `check_provodka.sh` на чистой пачке rc 1 (`guard не подключён`), хотя `pre_critic.sh` rc 0. В контракте указан ответственный; перед freeze/done фактическая проводка обязательна, не считать чистую пачку доказательством wired CI.

## Замеры и воспроизводимость

Все команды ниже выполнены из `/tmp/dev-harness-verify/Critic139/repo`. `W=fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh`.

- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic139/repo contracts/139-e2e-avtoperezapusk.md` → rc 0, stdout `OK`.
- `bash scripts/pre_critic.sh contracts/139-e2e-avtoperezapusk.md` → rc 0, stdout `  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3` / `КРИТИК: дверь зелёная`.
- `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic139/repo contracts/139-e2e-avtoperezapusk.md` → rc 1, raw `проводка: guard не подключён: fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh не вызывается в .githooks/ или .github/workflows/`.
- `bash "$W"` → rc 1: `SUBJECT_ABSENT: нет --repo/MOB_REPO с корнем продукта`; 26 строк `CASE <имя> KRASNO (SUBJECT_ABSENT)`, от `infra-ofline` до `pravka-mobile-yml`.
- `bash "$W" --model` → rc 0: 26 строк `CASE <имя> ok` (17 replay, 8 struktura, 1 derevo), от `infra-ofline` до `pravka-mobile-yml`.
- `bash "$W" --stabs` → rc 0: контроль 26 `ok`, `STAB ... KRASEN` 18 строк, `SVJAZI 18`, живых 0; пары `s-bez-attempt-guard→attempt-2-ofline`, `s-bez-eho-zaschity→skript-eho-signatury`, `s-polnyj-rerun→infra-ofline`, `s-dva-rerun→{struktura-rerun,infra-ofline}` красны. Это выборочная проверка 4 мутаций кода, не обещание о привязке из прозы.
- `python3 /tmp/dev-harness-verify/Critic139/negatives.py` → MODEL-REPO rc 0 (`26 CASE ... ok`), MOBILE-CHANGED rc 1 `MOBILE_YML_IZMENEN`, SUBJECT-MISSING rc 1 `SUBJECT_ABSENT` + 26 `KRASNO`, ORACLE-TAMPERED rc 2 `ORACLE_TAMPERED: sha256 носителя mobile.yml`.
- Frozen-зоны проверены живыми `git show frozen/contracts/{995/1,108/1,111/1,117/2,118/1,135/1,123/1,132/1}^{commit}:contracts/<имя>.md`: соответствующие 995/108/111/117/118/135/123 держат `.github/workflows/mobile.yml`; 132 — только `scripts/ekran_shablon.py`; контракт 139 даёт implementer отдельный `.github/workflows/mobile-e2e-retry.yml`, пересечения по файлу нет. Строка `КЛАСС РИСКА: обычный` для CI повтора без прав БД/авторизации/денег/ПД/health/юридических действий соответствует списку.

### Сырая атака 1: дополнительные исполняемые поверхности

Команда: `python3 /tmp/dev-harness-verify/Critic139/mutate.py` (одноразовые `--repo`-деревья из `tempfile`, носитель mobile.yml исходный). Вывод каждой из трёх YAML-мутаций дословно; `conditional-extra-step` — подтверждающий вариант класса шага:

```text
ATTACK extra-step: bash /tmp/dev-harness-verify/Critic139/repo/fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --repo /tmp/critic139-auqhvn14/extra-step; YAML jobs=['retry'] retry-steps=2; rc=0
CASE infra-ofline ok
CASE infra-adb-notfound ok
CASE infra-serial-notfound ok
CASE infra-devserverdied ok
CASE infra-install-failed ok
CASE infra-emulator-error ok
CASE infra-timeout-emulator ok
CASE chistyj-proval ok
CASE nizhe-poroga ok
CASE skript-eho-signatury ok
CASE attempt-2-ofline ok
CASE conclusion-success ok
CASE conclusion-cancelled ok
CASE upal-quality-tolko ok
CASE upali-oba ok
CASE gradle-lock ok
CASE fork-pr-bez-sekreta ok
CASE struktura-trigger ok
CASE struktura-prava ok
CASE struktura-runner ok
CASE struktura-if ok
CASE struktura-rerun ok
CASE struktura-sekrety ok
CASE struktura-vyrazhenija ok
CASE struktura-signatury ok
CASE pravka-mobile-yml ok
SECOND STEP (clean failure): gh run rerun --failed "$RUN_ID" RUN_ID=40198243018
ATTACK extra-job: bash /tmp/dev-harness-verify/Critic139/repo/fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --repo /tmp/critic139-auqhvn14/extra-job; YAML jobs=['retry', 'unguarded'] retry-steps=1; rc=0
CASE infra-ofline ok
CASE infra-adb-notfound ok
CASE infra-serial-notfound ok
CASE infra-devserverdied ok
CASE infra-install-failed ok
CASE infra-emulator-error ok
CASE infra-timeout-emulator ok
CASE chistyj-proval ok
CASE nizhe-poroga ok
CASE skript-eho-signatury ok
CASE attempt-2-ofline ok
CASE conclusion-success ok
CASE conclusion-cancelled ok
CASE upal-quality-tolko ok
CASE upali-oba ok
CASE gradle-lock ok
CASE fork-pr-bez-sekreta ok
CASE struktura-trigger ok
CASE struktura-prava ok
CASE struktura-runner ok
CASE struktura-if ok
CASE struktura-rerun ok
CASE struktura-sekrety ok
CASE struktura-vyrazhenija ok
CASE struktura-signatury ok
CASE pravka-mobile-yml ok
ATTACK conditional-extra-step: bash /tmp/dev-harness-verify/Critic139/repo/fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --repo /tmp/critic139-auqhvn14/conditional-extra-step; YAML jobs=['retry'] retry-steps=2; rc=0
CASE infra-ofline ok
CASE infra-adb-notfound ok
CASE infra-serial-notfound ok
CASE infra-devserverdied ok
CASE infra-install-failed ok
CASE infra-emulator-error ok
CASE infra-timeout-emulator ok
CASE chistyj-proval ok
CASE nizhe-poroga ok
CASE skript-eho-signatury ok
CASE attempt-2-ofline ok
CASE conclusion-success ok
CASE conclusion-cancelled ok
CASE upal-quality-tolko ok
CASE upali-oba ok
CASE gradle-lock ok
CASE fork-pr-bez-sekreta ok
CASE struktura-trigger ok
CASE struktura-prava ok
CASE struktura-runner ok
CASE struktura-if ok
CASE struktura-rerun ok
CASE struktura-sekrety ok
CASE struktura-vyrazhenija ok
CASE struktura-signatury ok
CASE pravka-mobile-yml ok
ATTACK prior-successful-step-signature: replay(model, chistyj-proval + successful-step log); rc= 0 stdout= ['VHOD: run=40198243018 conclusion=failure attempt=1', 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121184287236)'] calls= ['API_JOBS 40198243018', 'API_LOGS 121184287236', 'RERUN --failed 40198243018'] unreadable= False
```

### Сырая атака 2: длинный лог в пределах конформного входа

Команда: `python3 /tmp/dev-harness-verify/Critic139/large_log.py` (сам `probe.replay` исполняет **неизменённую модель** из OBJECT, оригинальные вход/оракул на диске не правились). Дословно:

```text
REPLAY lines=101 rc=0 unreadable=False stdout=['VHOD: run=40198247993 conclusion=failure attempt=1', 'POVTOR: android-e2e упал по инфраструктурной сигнатуре эмулятора (job 121190778790)'] calls=['API_JOBS 40198247993', 'API_LOGS 121190778790', 'RERUN --failed 40198247993']
REPLAY lines=200001 rc=0 unreadable=False stdout=['VHOD: run=40198247993 conclusion=failure attempt=1', 'SKIP: инфраструктурной сигнатуры в логе android-e2e нет — чистый провал проверки'] calls=['API_JOBS 40198247993', 'API_LOGS 121190778790']
```

Первый FAIL по этим классам; один исправительный вызов остаётся по §Быстрый-процесс. Ни контракт, ни модель судья не меняет.
