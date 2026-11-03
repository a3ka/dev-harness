FAIL
OBJECT=3077762ed0874b918e536f42ac3feaf2681e29f6
СУД: repo=dev-harness; предмет=157; фаза=контракт v1 (+красная батарея); роль=critic; вызов=1/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit157; модель-факт=openai-codex/gpt-6-sol; автор — Arch157b (openai-codex/gpt-6-sol) и судья одного семейства gpt; независимость не обеспечена; архитектор 157 на Sol по слову владельца 2026-11-02 ~22:35 («возьми в этот раз на роль архитектора сол модель»), владелец подтвердил ~00:35; исключение=слово владельца 2026-11-02 ~22:35. Строгость суда не снижена.

Суд зафиксированного OBJECT; рабочее дерево `/tmp/dev-harness-verify/Crit157/repo`, мутации только в одноразовом клоне `/tmp/dev-harness-verify/Crit157/attack`. `git cat-file -t OBJECT` → rc 0 `commit`; фактический git-автор объекта `architect`. Свидетельства ниже относятся к указанным деревьям, не к предполагаемой будущей реализации.

## Блокирующие классы

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:21-23,29-31 — ДОМЕН РАСКЛАДОК: батарея не отличает произвольный допустимый проект, которому отказывают, от чужой формы, ошибочно принятой за станцию. Сужение «третья форма без обоих маркеров» не снимает принятую владельцем обязанность fail-closed для ЛЮБОЙ третьей формы.
ОБЯЗАТЕЛЬСТВО: `<P>/home/.omp/profiles/<profile>/agent/sessions/...jsonl` с любым допустимым P доходит до двери с `<P>/state/zamok`; всё, что не является ни станцией `<S>/zones/<zone>/.omp/profiles/...`, ни проектом, блокируется до двери, без записи состояния (`boli.md` §Способ починки, контракт п. 1/3).
СОСТОЯНИЕ: валидный `.../dev-harness-projects/shadow/home/.omp/profiles/dev/agent/sessions/under/Agent157.jsonl`; чужой `.../foreign-layout/flat/.omp/profiles/dev/agent/sessions/some/zones/replay.jsonl` с `/zones/` лишь внутри хвоста имени сессии.
НАБЛЮДЕНИЕ: мутант с модельными корнями, отказывающий лишь проекту `shadow`, даёт `KLETKI subject 9 KRASNYH 0` и зелёные `--stabs`, но отказывает валидному проекту до двери. Чистая модель на чужой форме даёт `{"pass":true}`, вызывает дверь и создаёт замок под `.../agent/sessions/some/zamok`. Временный owner-коммит `02916231f` имеет тот же `indexOf('/zones/')` до проектной ветки: он является временной справкой, не новым разрешением менять обязательство «любая третья».
ОБХОД: сырые команды/вывод `audit_attack_157.py` и `audit_false_layout_157.py` в разделе «Атаки» ниже. Зелёные W и `--stabs` сочетаются с названным ложным отказом и ложным допуском.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка различает структурную позицию маркеров и допускает все значения переменных компонентов двух раскладок; ни ложное распознавание третьей формы, ни отказ допустимому проекту не могут пройти зелёными.

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:21,23,31 — КОРЕНЬ ЖУРНАЛОВ: модель и критерий выбирают последний совпавший `agent/sessions` вместо соответствующего каталога профиля на допустимом пути с вложенным одноимённым каталогом.
ОБЯЗАТЕЛЬСТВО: `--zhurnaly` для проекта указывает на `<P>/home/.omp/profiles/<profile>/agent/sessions`, независимо от имени сессии; значения имени не дополнительная политика.
СОСТОЯНИЕ: `<P>/home/.omp/profiles/dev/agent/sessions/under/agent/sessions/Agent157.jsonl`, абсолютный jsonl внутри заявленного каталога, без `/zones/` и без второго маркера `/home/.omp/profiles/`.
НАБЛЮДЕНИЕ: на модели дверь вызывается с правильным `<P>/state/zamok`, но `--zhurnaly` равен `.../agent/sessions/under/agent/sessions`; живой holder в настоящем каталоге может оказаться невидимым двери. `probe.py:86-88,121-123` проверяет только один зафиксированный хвост.
ОБХОД: `audit_attack_157.py` показывает `valid-project-nested-sessions` с ответом `DOOR_DENY_157`, фактическим argv с вложенным `--zhurnaly` и зелёными W/`--stabs`; сырой вывод ниже.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: на заявленном домене argv двери всегда содержит именно структурный корень журналов профиля; мутант, выбирающий совпадение в хвосте файла, краснит приёмку.

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:22,27-32 — ИСХОД ДВЕРИ: проектные пробы не отличают rc 2 fail-closed от rc 2 pass.
ОБЯЗАТЕЛЬСТВО: для каждого допустимого task дверь вызывается; rc 0 пропуск, rc 1 первая строка stderr, rc 2 блок (п. 2 и замороженный 140 инв. 1).
СОСТОЯНИЕ: проектный ctx, валидный `architect`, установленная дверь исполняется и завершается кодом 2; W использует на проекте только rc 1/0, станционная 140 p13 — только станцию.
НАБЛЮДЕНИЕ: мутант `if (r.status === 2 && sessionFile.includes('/dev-harness-projects/')) return undefined;` при модельных корнях проходит W и `--stabs` (оба rc 0), но project task с реальным вызовом двери rc 2 получает `{"pass":true}`.
ОБХОД: `python3 audit_rc2_157.py`, полный сырой вывод в разделе «Атаки».
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: проектная батарея доказывает все три заявленные ветви статуса двери, включая rc 2 fail-closed и первую строку stderr при rc 1; мутант пропуска на ошибке rc 2 красен.

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:120-123 — НОРМА 041: секция модели угроз оформлена двумя буллетами `- ЗАЩИЩАЕТ:`/`- НЕ ЗАЩИЩАЕТ:`, а не отдельными списками по грамматике действующего гейта.
ОБЯЗАТЕЛЬСТВО: вводящий guard для чужого пути контракт содержит списки `ЗАЩИЩАЕТ:` и `НЕ ЗАЩИЩАЕТ:` с ≥1 пунктом каждый (roles/critic.md §Норма модели угроз, 041).
СОСТОЯНИЕ: OBJECT 157 с буквальным содержимым строк 122–123.
НАБЛЮДЕНИЕ: `bash scripts/check_threat_model.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 1, `модель угроз: список ЗАЩИЩАЕТ: отсутствует`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: оба списка и пункты по грамматике, осмысленная граница защищает/не защищает; гейт rc 0.

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:120-123 — НОРМА 004: незамороженный контракт завершается моделью угроз, обязательной секции `## Незаполненные требования:` нет.
ОБЯЗАТЕЛЬСТВО: каждый незамороженный `contracts/NNN-*.md` содержит раздел с `нет` или непустым списком (`scripts/check_ceilings.sh`, 004).
СОСТОЯНИЕ: 157 ещё не заморожен; файл на OBJECT размером 24795 байт.
НАБЛЮДЕНИЕ: `bash scripts/check_ceilings.sh .` → rc 1: `FAIL контракт ./contracts/157-spawn-guard-proektnye-sessii.md (24795 байт): нет раздела «Незаполненные требования:»`; `превышений/нарушений: 1`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: раздел появляется в теле контракта по грамматике 004; гейт rc 0.

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:30 — НОРМА Н-39: проза критерия буквально привязывает стаб `blind-root` к «ветке станции» («blind-root обнаруживается ... включая ветку станции»), что запрещено AGENTS.md §Воркфлоу майлстоуна п. 1; заявление в предыдущем абзаце о кодовой привязке эту фразу не отменяет.
ОБЯЗАТЕЛЬСТВО: контракт несёт инварианты и команды с rc; пару обманный стаб↔ветвь доказывает архитектор по коду, контракт её не утверждает.
СОСТОЯНИЕ: зафиксированный п. 2 приёмки.
НАБЛЮДЕНИЕ: именованная пара `blind-root`↔станционная ветка находится непосредственно в нормативном тексте п. 2.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: требования к поведению обеих ветвей и rc сохраняются, привязки конкретных стабов к конкретным ветвям остаются в коде фикстуры.

## Атаки — сырые команды и вывод

Вызовы из `/tmp/dev-harness-verify/Crit157/attack`; мутируется только его `.omp/extensions/spawn-guard.ts`, не OBJECT. Привязка стаба к ветви проверена кодом `probe.py`, не принимается из прозы контракта.

`python3 audit_attack_157.py` → rc 0 (сам свидетель считает успехом обнаруженный обход):
```
MUTANT python3 /tmp/dev-harness-verify/Crit157/attack/fixtures/workshop_project/spawn_guard_157/probe.py rc 0
KLETKI subject 9 KRASNYH 0
MUTANT python3 /tmp/dev-harness-verify/Crit157/attack/fixtures/workshop_project/spawn_guard_157/probe.py --stabs rc 0
KLETKI model 9 KRASNYH 0
KLETKI blind-root 9 KRASNYH 6
KLETKI station-only 9 KRASNYH 3
KLETKI project-only 9 KRASNYH 3
KLETKI env-root 9 KRASNYH 3
valid-project-mutant rc 0 answer {"block":true,"reason":"ОТКАЗ: страж замка сломан (fail-closed): файл сессии вне грамматики"} actual argv None
valid-project-nested-sessions rc 0 answer {"block":true,"reason":"DOOR_DENY_157"} actual argv ['--sudit', '--sostojanie', '/tmp/critic157-witness-1a0eq6kt/dev-harness-projects/shadow/state/zamok', '--zhurnaly', '/tmp/critic157-witness-1a0eq6kt/dev-harness-projects/shadow/home/.omp/profiles/dev/agent/sessions/under/agent/sessions', '--repo', '/tmp/critic157-witness-1a0eq6kt', '/tmp/critic157-witness-1a0eq6kt/dev-harness-projects/shadow/state/.zamok140-event-64076-dionpzdwb49.json']
NESTED expected --zhurnaly /tmp/critic157-witness-1a0eq6kt/dev-harness-projects/shadow/home/.omp/profiles/dev/agent/sessions actual /tmp/critic157-witness-1a0eq6kt/dev-harness-projects/shadow/home/.omp/profiles/dev/agent/sessions/under/agent/sessions
```
`python3 audit_false_layout_157.py` → rc 0:
```
foreign layout with /zones/ under session: rc 0 answer {"pass":true}
door called True state root /tmp/critic157-false-layout-u1m4367n/foreign-layout/flat/.omp/profiles/dev/agent/sessions/some/zamok
```
`python3 audit_rc2_157.py` → rc 0:
```
MUTANT python3 /tmp/dev-harness-verify/Crit157/attack/fixtures/workshop_project/spawn_guard_157/probe.py rc 0
KLETKI subject 9 KRASNYH 0
MUTANT python3 /tmp/dev-harness-verify/Crit157/attack/fixtures/workshop_project/spawn_guard_157/probe.py --stabs rc 0
KLETKI model 9 KRASNYH 0
KLETKI blind-root 9 KRASNYH 6
KLETKI station-only 9 KRASNYH 3
KLETKI project-only 9 KRASNYH 3
KLETKI env-root 9 KRASNYH 3
PROJECT door exit 2: driver rc 0 answer {"pass":true} door called True
```

## САМООПИСАНИЕ — полный счёт и механические адреса

Расхождений заявленных чисел/имён не найдено: `probe.py:132-142` — 9 сценариев; текущая краснота ровно project-deny/project-allow/project-alt (3/9); `probe.py:173-179` — 4 обманных варианта с 6/9, 3/9, 3/9, 3/9 красных. `_krasnye_104.sh` → `клеток просмотрено: 6`, 6/6, стаб-пак 17/17; станционная 140 p01–p14+m01 → 15/15. Исходная `stateRoots()` — `.omp/extensions/spawn-guard.ts:152-160`; `_mir.sh:89` вызывает handler без ctx. В замороженном 140/1 `.omp/extensions/spawn-guard.ts` — implementer-зона, пересечение явно названо на 157:42. `origin/owner/strazh-proekt-vremenno` = `02916231f2d9fd06875dfc0bd1f2ee748901ccd6`; CI Node 26 (`ci.yml:125-127`). Строка `КЛАСС РИСКА: рисковый` на 157:3, исполнители и зоны на 157:36-41 названы. Новых механических расхождений в этих числах, именах и адресах нет.

## Контрольные команды на OBJECT

- `python3 fixtures/workshop_project/spawn_guard_157/probe.py` → rc 1, `KLETKI subject 9 KRASNYH 3`; красные ровно project-deny/project-allow/project-alt с `файл сессии вне грамматики`; станционные зелёные.
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --model` → rc 0, `KLETKI model 9 KRASNYH 0`.
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs` → rc 0, `KLETKI model 9 KRASNYH 0`, `KLETKI blind-root 9 KRASNYH 6`, `KLETKI station-only 9 KRASNYH 3`, `KLETKI project-only 9 KRASNYH 3`, `KLETKI env-root 9 KRASNYH 3`; красные у каждого на собственных случаях (blind-root station-allow: `root returned without door check`).
- `bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh` → rc 0, `PROB VSEGO 15 KRASNYH 0`.
- `bash fixtures/_krasnye_104.sh` → rc 0, `стаб-пак: 17/17 поймано`, `клеток просмотрено: 6`, `ИТОГ 104: rc=0`.
- `bash scripts/pre_critic.sh contracts/157-spawn-guard-proektnye-sessii.md` → rc 0, `КРИТИК: дверь зелёная`.
- `bash scripts/check_precision_gate.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0, `OK`; `bash scripts/check_spec_ready.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0, `OK`.
- `bash scripts/check_provodka.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 1, `проводка: guard не подключён: fixtures/workshop_project/spawn_guard_157/probe.py не вызывается в .githooks/ или .github/workflows/` — ожидаемо до реализации и проводки CI, не отдельный блокер.
- `bash scripts/check_threat_model.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 1; `bash scripts/check_ceilings.sh .` → rc 1; буквальные причины в блоках выше.
- `bash scripts/check_zones.sh .` → первый вызов прерван по deadline 120 с; повтор завершился за 399.63 с, его сырой footer: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42794 · проверено по зонам: 10165`, строки `FAIL` в полном выводе отсутствуют; сообщение фонового инструмента не содержит явного кода возврата. `--incr` без пути к кэшу не вызывался.

## Не проверено

Живой spawn в уже запущенном проектном процессе omp не исполнялся: граница красной батареи — настоящий установленный хук через Node-драйвер с синтетическим ctx. Точный rc повторного полного `check_zones.sh` недоступен в ответе фонового инструмента (полный вывод и завершающий footer доступны, `FAIL` не обнаружено); дельта пересечений независимо проверена `check_precision_gate.sh` rc 0. Проверки осуществлены на OBJECT и одноразовом клоне, а не на будущей реализации.
