FAIL

СУД: repo=dev-harness; предмет=200; фаза=контракт (до заморозки); роль=critic; вызов=1/2; модель-план=config/agent_models.json (critic → apex-sol → @gpt-terra); сессия=Crit200V1b; модель-факт=openai-codex/gpt-6.1-terra; SHA=0b8d4a5b72a9b91b9dacd56d840261ad7e126d89; предыдущий=нет; исключение=нет. Предыдущая сессия Crit200V1 оборвана без вердикта, по заданию оркестратора `obryv_bez_verdikta`. Запись до вызова — HANDOFF state-WT, строка 4. `models_actual.sh --tsv --bind --session Crit200V1b` rc 0: critic, openai-codex/gpt-6.1-terra, allowed, этот SHA. Автор architect, модель Arch200 по заданию zai/glm-5.3; собственную работу не сужу.

## Блоки

БЛОКИРУЕТ contracts/200-okno-zamorozki-check-contract-frozen.md:32,244 — сравнение m11 не доказывает сохранение семейства 016 после переноса модели: на реализованном дереве подмена идемпотентна и сравнивает субъект с его собственной копией. Это нарушает заявленную нерегрессию и обещание сохранения вердиктов каждой замороженной версии.
ОБХОД: вход — действующая фикстура `fixtures/check_contract_frozen/case_verdikt_ne_accept.sh`: тег v1 и затем замена вердикта на FAIL. Исходная предметная операция `if [ "$first" != accept ]; then` в `scripts/check_contract_frozen.sh` заменена на `if false; then` в копии честной модели. В этом входе исходная дверь rc 1 с отказом, мутант rc 0 и ложно разрешает заморозку с вердиктом FAIL. При этом `--repo` на мутанте rc 0, 11/11, включая m11. Свойство закрытия: существующий замороженный отказ независимо распознаётся на настоящем реализованном субъекте; сравнение двух копий одного субъекта или совпадение двух ложных исходов недостаточно. Это один класс ложного свидетельства и для других ветвей 016, не требование отдельной клетки на каждый пример.
КЛАСС: К-08.

БЛОКИРУЕТ contracts/200-okno-zamorozki-check-contract-frozen.md:30,33 — текст контракта сам объявляет привязку обманок к клеткам (`s02 … различается миром m4`; строка 33 перечисляет все пять пар). AGENTS.md §«Воркфлоу майлстоуна», шаг 1 прямо запрещает контракту утверждать пару «обманный стаб ↔ ветвь»; задание отдельно подтверждает Н-39: привязка принадлежит коду архитектора, не прозе. То, что `pre_critic` не распознал стрелки, норму не отменяет. Свойство закрытия: в контракте остаются инварианты и rc-команды, привязки стабов к входам определены кодом батареи, не текстом контракта.
КЛАСС: К-01.

СОВЕТ contracts/200-okno-zamorozki-check-contract-frozen.md:33 — `scripts/check_sdacha.sh` отсутствует на объекте (rc 127), сдаточного листа нет. Задание называет это известным окном до предмета 193, не блоком 200.

## Исполненные проверки

Все запуски гейтов и батареи без ambient `GIT_AUTHOR_*` и `GIT_COMMITTER_*`. `bash scripts/pre_critic.sh contracts/200-okno-zamorozki-check-contract-frozen.md` rc 0 (первоначальная попытка с лишним `.` дала usage rc 1). `bash scripts/check_spec_ready.sh . contracts/200-okno-zamorozki-check-contract-frozen.md` rc 0; `bash scripts/check_precision_gate.sh . contracts/200-okno-zamorozki-check-contract-frozen.md` rc 0; `bash scripts/check_threat_model.sh . contracts/200-okno-zamorozki-check-contract-frozen.md` rc 0; `bash scripts/check_ceilings.sh .` rc 0. `bash scripts/check_contract_frozen.sh .` rc 1: локально скопированный тег frozen/contracts/197/2 указывает на 3447437488d09d38b5a3a26e5ec298cb85c140c3, не предка OBJECT (`git merge-base --is-ancestor` rc 1); у 197 в OBJECT нет вердикта v2 и блоб отличается. Это следствие набора refs клона, не доказанный дефект 200; приёмка на будущем носителе не проверена.

`bash fixtures/workshop_project/okno_zamorozki_200/red_okno_zamorozki_200.sh --model`: rc 0, m1–m11 ok, 11 зелёных. `--stabs`: rc 0, s01–s05 пойманы, всего 5. Без флага и `--repo .`: каждый rc 1, красные именно m1 и m6, остальные 9 зелёные. m11 исполняет 10 файлов case_*.sh; независимый подсчёт — 10; 2 файла батареи; 179 строк ПЕРЕСЕЧЕНИЕ, из них 178 orchestrator и 1 implementer.

## Собственные мутации в одноразовой копии

Общая подготовка: `git clone --no-hardlinks /tmp/dev-harness-verify/Crit200V1b/repo /tmp/dev-harness-verify/Crit200V1b/mutant`; `python3 fixtures/workshop_project/okno_zamorozki_200/podmena.py model scripts /tmp/dev-harness-verify/Crit200V1b/model`; перед каждой мутацией `cp /tmp/dev-harness-verify/Crit200V1b/model/scripts/check_contract_frozen.sh /tmp/dev-harness-verify/Crit200V1b/mutant/scripts/check_contract_frozen.sh`. Вызов каждой атаки: `env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_AUTHOR_DATE -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL -u GIT_COMMITTER_DATE bash fixtures/workshop_project/okno_zamorozki_200/red_okno_zamorozki_200.sh --repo /tmp/dev-harness-verify/Crit200V1b/mutant`.

1. Замена операции `g diff --quiet --no-renames "${c}^1" "$c" -- "$f" 2>/dev/null && continue` на `continue` (отбрасывать все merge, включая меняющие текст). Сырой вывод, rc 1:
```
ok   m1
ok   m2
FAIL m3 — m3: rc=0 (нужен 1: evil merge, p1-diff непуст без РАЗРЕШИЛ)
ok   m4
FAIL m5 — m5: без шима rc=0 (нужен 1: пары нет в аллоулисте)
ok   m6
ok   m7
ok   m8
ok   m9
ok   m10
ok   m11
ИТОГ 200 (субъекты дерева): клеток 11, красных 2, зелёных 9
КРАСНОЕ 200: красных 2 из 11 (до реализации ожидаемо; после — дефект)
```
2. Замена `if [ "$first" != accept ]; then` на `if false; then`. Сырой вывод, rc 0:
```
ok   m1
ok   m2
ok   m3
ok   m4
ok   m5
ok   m6
ok   m7
ok   m8
ok   m9
ok   m10
ok   m11
ИТОГ 200 (субъекты дерева): клеток 11, красных 0, зелёных 11
ЗЕЛЕНОЕ 200
```
Отдельная проба исхода: `BARRIER="$PWD/scripts/check_contract_frozen.sh" WORK=/tmp/dev-harness-verify/Crit200V1b/case-original bash fixtures/check_contract_frozen/case_verdikt_ne_accept.sh` и та же команда с BARRIER=/tmp/dev-harness-verify/Crit200V1b/mutant/scripts/check_contract_frozen.sh, WORK=…/case-mutant. Сырой вывод исходной двери:
```
  ok   contracts/001-x.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают

планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
  FAIL contracts/001-x.md: заморозка v1 лежит поверх вердикта, который её не разрешил: первая строка «FAIL» в verdicts/critic/contracts-001-v1.md

планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
original rc=1
```
Мутант:
```
  ok   contracts/001-x.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают

планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
  ok   contracts/001-x.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают

планов и контрактов на HEAD: 1 · черновиков: 0 · заморожено: 1 · реестр: full
mutant rc=0
```
3. Смежная ветка: удалён существующий вызов `grandfather_pair "$c" "$f" && continue` в CI-ветке. Сырой вывод, rc 1:
```
ok   m1
ok   m2
ok   m3
ok   m4
FAIL m5 — m5: с шимом rc=1 (нужен 0: grandfather-пара honored)
ok   m6
ok   m7
ok   m8
ok   m9
ok   m10
ok   m11
ИТОГ 200 (субъекты дерева): клеток 11, красных 1, зелёных 10
КРАСНОЕ 200: красных 1 из 11 (до реализации ожидаемо; после — дефект)
```
Шим m5 не заменяет исходный список целиком: он расширяет его одной исторически недоступной игрушечной парой, и у той же истории есть отрицательный контроль без шима. Сам по себе список реальных пар эта проба не доказывает, что названо остатком.

## Карта классов

К-01: блок — Н-39 в тексте контракта; `pre_critic` rc 0, `check_sdacha` отсутствует (окно 193).
К-02: чисто — задание п.9 и contracts/200:1–33, OBJECT автора.
К-03: блок — мутант отрицательного вердикта обходит заявленное сохранение 016.
К-04: чисто — зоны contracts/200:60–65, 178 пересечений orchestrator и одно implementer; `check_precision_gate` rc 0.
К-05: блок — m11 самосравнение не доказывает нерегрессию по rc-команде после реализации.
К-06: чисто — входы предпосылок и обработка отсутствия инструментов в шапке батареи.
К-07: чисто — `--model` rc 0; будущий носитель не проверен.
К-08: блок — семейство 016, зелёная мутация существующей проверки вердикта.
К-09: чисто — миры m1–m10 и прямые мутации отбора и смежной ветки.
К-10: блок — m11 сравнивает результаты проверяемого с ним же, не наблюдает прежний отказ.
К-11: блок — свидетель m11 зависит от изменяемого субъекта.
К-12: н/п — новый оракул формата не вводится.
К-13: н/п — секреты не являются предметом.
К-14: чисто — честная модель m1–m11 rc 0, штатные merge m1/m6.
К-15: чисто — 11 клеток, 5 стабов, 10 кейсов, 2 файла и 178+1 пересечений подсчитаны отдельно.
К-16: чисто — риск авторизации объявлен; `check_threat_model` rc 0 и входы m1–m10.
К-17: н/п — в объекте нет `tooling/checks/cli.js` и объявленного брифа архитектуры 188; предмет — существующий shell-гейт, не модель проекта.
