FAIL
OBJECT=6c30c359556263245c4ce78935a8bf927f1929b7
СУД: repo=dev-harness; предмет=111; фаза=контракт (адресная v5 по 143); роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit117a; модель-факт=openai-codex/gpt-6-sol; SHA=6c30c359556263245c4ce78935a8bf927f1929b7; предыдущий=нет; исключение=нет

БЛОКИРУЕТ contracts/111-cmp-mob-first-run.md:477-481 — раздел «Отложенная продуктовая приёмка» требует скриншоты First-Run в артефактах `android-e2e` и шаг «135 first-run-ekran» внутри job `android-e2e`. Это не исторический замер, а ещё действующий пункт приёмки; §Замены v5:67-74 назвал ссылку отложенной, но оставил неверный носитель. Та же старая ссылка на место скриншота осталась в разделе поставки, строка 368.
ОБЯЗАТЕЛЬСТВО: по слову владельца 27.10 и frozen 143/1 шаг 135 и его снимки принадлежат `e2e-first-run`; `android-e2e` — только required-агрегат. Визуальный критерий и доказательство по артефакту должны оставаться достижимыми.
СОСТОЯНИЕ: честная модель 143 с успешно выбранным `e2e-first-run`: шаг 135 и `actions/upload-artifact` с именем `maestro-first-run-*` исполняются экранным job; у агрегата только checkout и `ci-aggregate.cjs`, upload и шага 135 нет.
НАБЛЮДЕНИЕ: YAML-разбор модели дал `135_in_aggregate []`, `135_in_first_run ['135 first-run-ekran (валидатор 132 + cmp + проверка происхождения, Maestro × тема)']`, `uploads_in_aggregate []`; модель `mobile.yml:756-763` выгружает `maestro-first-run-*` именно из экранной задачи. Даже зелёный required job не содержит названного в приёмке шага. `git diff frozen/contracts/111/4 6c30c359556263245c4ce78935a8bf927f1929b7 -- contracts/111-cmp-mob-first-run.md` оставил строку 479 прежней.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: отложенная приёмка называет задачу `e2e-first-run` для шага 135 и её артефакт `maestro-first-run-*`, сохраняя валидатор 132, меру 123, элементы, порог и связь с required-агрегатом.

Проверка предмета. `git cat-file -t 6c30c359556263245c4ce78935a8bf927f1929b7` → `commit`, rc0; `git diff --numstat frozen/contracts/111/4 6c30c359556263245c4ce78935a8bf927f1929b7 -- contracts/111-cmp-mob-first-run.md` → `31 3 contracts/111-cmp-mob-first-run.md`, rc0. Три адресных ханка §Замены v5 совпадают с черновиком 143, сверх шапки и объясняющего перечня иной правки нет. `git diff-tree --no-commit-id --name-only -r 6c30c359556263245c4ce78935a8bf927f1929b7` → только контракт, rc0. `grep` батареи `first_run_111` по имени job: функциональной привязки к `android-e2e` нет; её тесты и пробы судят экран, а не DAG. Замороженная модель 143/1 (`git rev-parse frozen/contracts/143/1:fixtures/workshop_project/mob_ci_143/model/.github/workflows/mobile.yml`) имеет тот же blob `6f81f15f3fc2eadbe3c016f585be33714a117bea`, что и кандидат.

Батарея 111 (каждая команда последовательно): `python3 fixtures/workshop_project/first_run_111/first_run_static_probe.py --repo /tmp/dev-harness-verify/Crit117a/target-tree --model` → `static 16/16`, rc0; та же команда без `--model` на target и на monolith → `static 16/16`, rc0 ×2. `python3 fixtures/workshop_project/first_run_111/first_run_probe.py --repo /tmp/dev-harness-verify/Crit117a/target-tree --model` → `honest 23/23`, rc0; та же команда без `--model` на target и на monolith → `honest 23/23`, rc0 ×2. Общий источник `../vkhod_117/source.json` уже изменён на job `e2e-splash` и не сломал экранную семью.

`python3 fixtures/workshop_project/first_run_111/first_run_static_probe.py --repo /tmp/dev-harness-verify/Crit117a/target-tree --model --matrix` → 16 красных именованных мутантов, `STATIC111_MATRIX_RC=0` (оболочка `python3 -c` печатает код). Сырой вывод:
```
RED SPLASH_GROUND_SCHEME
RED SPLASH_DEFAULT_BLUE_GONE
RED SPLASH_EFFECTIVE_GROUND_BOTH
mutant splash-stays-default-blue red= ['SPLASH_DEFAULT_BLUE_GONE', 'SPLASH_EFFECTIVE_GROUND_BOTH', 'SPLASH_GROUND_SCHEME']
RED SCREEN_SAFEAREA_COMPONENT
mutant screen-plain-view red= ['SCREEN_SAFEAREA_COMPONENT']
STATIC111_MATRIX_RC=0
```
`MUTANT_GREEN`, `MUTANT_UNEXPECTED_RED`, инфраструктурных отказов нет. Собственная мутация: `python3 /tmp/dev-harness-verify/Crit117a/attack_first_run.py /tmp/dev-harness-verify/Crit117a/target-tree /tmp/dev-harness-verify/Crit117a/repo111/fixtures/workshop_project/first_run_111/first_run_static_probe.py` (одноразовый продукт: native light splash `#F3F2EE` → legacy blue `#208AEF`) →
```
ATTACK: native light splash ground restored to blue #208AEF
RED SPLASH_GROUND_SCHEME
RED SPLASH_DEFAULT_BLUE_GONE
RED SPLASH_EFFECTIVE_GROUND_BOTH
ATTACK_RC=1
```
Внутренняя проба rc1, оболочка rc0. Соседи 135/138 на `--model` — rc0 каждый.

Гейты: `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit117a/repo111 contracts/111-cmp-mob-first-run.md && bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit117a/repo111 contracts/111-cmp-mob-first-run.md && bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit117a/repo111 contracts/111-cmp-mob-first-run.md && bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit117a/repo111 contracts/111-cmp-mob-first-run.md && bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit117a/repo111 contracts/111-cmp-mob-first-run.md && bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit117a/repo111 contracts/111-cmp-mob-first-run.md` → `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1; КРИТИК: дверь зелёная; OK; OK; потолки в порядке; модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 1 буллет(ов))`, rc0.

НЕ проверено: живой PR после cutover; фактическая модель архитектора по трассе (план slow не доказательство факта).
