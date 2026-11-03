FAIL
OBJECT=46484f278193edbf644376bfa3206b6d309c690d
СУД: repo=dev-harness; предмет=157; фаза=контракт v1 (+красная батарея); роль=critic; вызов=2/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit157b; модель-факт=openai-codex/gpt-6-sol; предыдущий=contracts-157-v1-fail.md (FAIL, шесть классов); исключение=нет. Правку OBJECT внёс architect <architect@dev-harness.local>, фактическая модель автора правки zai/glm-5.3 по предъявленному трейсу задания; от судьи Sol независима. Судился коммит OBJECT, не движущийся checkout. Рабочее дерево — изолированный worktree `/tmp/dev-harness-verify/Crit157b/work`, исходный checkout не правился.

## Блокирующий класс — неоднозначный структурный маркер в допустимом хвосте

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:22-24,28,30-32,43 — ДОМЕН РАСКЛАДОК / НЕИЗМЕННОСТЬ СТАНЦИОННОГО КОРНЯ. Исправленная модель сама является обманной «реализацией» для неиспытанного значения хвоста: `--model` и `--stabs` зелёные, а настоящий установленный хук выдаёт двери неверные argv и создаёт состояние не в корне сессии.
ОБЯЗАТЕЛЬСТВО: на абсолютном jsonl под `<P>/home/.omp/profiles/<profile>/agent/sessions/<хвост>` корень замка — `<P>/state`, корень журналов — каталог этого профиля; на станции `<S>/zones/<zone>/.omp/profiles/<profile>/agent/sessions/<хвост>` живой корень `<S>/zamok` сохраняется. Значения хвоста произвольны, включая вложенный `agent/sessions`; структурный маркер в хвосте не меняет принадлежность/корень (п. 1–3; слово владельца `boli.md` §Способ починки). Замороженный 140/1 инв. 1 требует не обходить одну дверь, а приводить её к действующим замкам; в 157 пересечение зоны implementer с 140 оформлено.
СОСТОЯНИЕ: существуют два абсолютных файла, оба действительно лежат под каталогом сессий своего первого профиля и оканчиваются `.jsonl`: `<P>/home/.omp/profiles/dev/agent/sessions/under/home/.omp/profiles/rogue/agent/sessions/Agent157.jsonl` и `<S>/zones/dev/.omp/profiles/dev/agent/sessions/under/zones/rogue/.omp/profiles/rogue/agent/sessions/Agent157.jsonl`. Нет симлинков, `..`, чужого ctx или сочетания станционного и проектного маркеров: в каждой форме повторён только **свой** структурный маркер внутри разрешённого хвоста. Живой ctx и валидный task проходят алфавит.
НАБЛЮДЕНИЕ: жадное `^(.+)` в `model/stateRoots.ts:11,18` выбирает ПРАВЫЙ повторный полный маркер; модель направляет проектную дверь в `<P>/home/.omp/profiles/dev/agent/sessions/under/state/zamok` вместо `<P>/state/zamok`, а станционную — в `<S>/zones/dev/.omp/profiles/dev/agent/sessions/under/zamok` вместо живого `<S>/zamok`. `--zhurnaly` тоже сдвигается в подложный профиль. Замок действующего предмета остаётся в настоящем корне и не судится: ложный допуск дубля становится возможным при rc 0 двери на пустом, ошибочно выбранном корне. Временная заплата owner использует ПЕРВЫЙ `/zones/`, и на том же станционном файле держит `<S>/zamok`; регрессия «станция неизменна» нарушена. Эти случаи отсутствуют в 16 клетках; зелёная обязательная модель имеет дефект ещё до появления кода implementer.
ОБХОД: реализация дословно переносит две предписанные регулярки из модели; безфлаговый W на ней получает 16/0, `--stabs` 0, тогда как оба приведённых абсолютных jsonl вызывают дверь с ложным корнем. Команды и прямой вывод ниже.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка доказывает неизменность действительного корня состояния и структурного корня журналов при повторном структурном маркере **в хвосте** на обеих раскладках; модель и W не бывают зелёными при сдвиге корня или пропуске замка. Если предлагается исключить эти значения из заявленного произвольного хвоста, требуется явная санкция владельца на изменение границы, а не молчаливое сужение контракта.

### Сырая атака

Одноразовый worktree `mutant` был получен из OBJECT; `python3 /tmp/dev-harness-verify/Crit157b/create_mutant.py` → rc 0 `MUTANT: installed hook changed only in stateRoots(), from committed model/stateRoots.ts`. Только в этом одноразовом дереве эталонный `stateRoots()` заменил исходный в поставленном `.omp/extensions/spawn-guard.ts`. `python3 fixtures/workshop_project/spawn_guard_157/probe.py` в `mutant` → rc 0, сырой результат:
```
CASE subject station-deny OK
CASE subject station-allow OK
CASE subject station-alt OK
CASE subject station-profile OK
CASE subject station-broken OK
CASE subject project-deny OK
CASE subject project-allow OK
CASE subject project-alt OK
CASE subject project-profile OK
CASE subject project-shadow OK
CASE subject project-nested OK
CASE subject project-broken OK
CASE subject foreign-deny OK
CASE subject foreign-zones-tail OK
CASE subject malformed-session OK
CASE subject project-alphabet OK
KLETKI subject 16 KRASNYH 0
```
`python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs` на том же мутанте → rc 0, сырые строки итогов всех мутантов: `KLETKI model 16 KRASNYH 0`, `KLETKI blind-root 16 KRASNYH 12`, `KLETKI station-only 16 KRASNYH 7`, `KLETKI project-only 16 KRASNYH 5`, `KLETKI env-root 16 KRASNYH 7`, `KLETKI shadow-deny 16 KRASNYH 1`, `KLETKI indexof-station 16 KRASNYH 1`, `KLETKI last-sessions 16 KRASNYH 1`, `KLETKI rc2-pass 16 KRASNYH 1`. Работа в `mutant` закончена и одноразовый worktree удалён командой `git worktree remove --force /tmp/dev-harness-verify/Crit157b/mutant` → rc 0.


Команда: `python3 /tmp/dev-harness-verify/Crit157b/attack157.py` в worktree OBJECT → rc 0 (скрипт-свидетель печатает нарушение, а не возвращает код теста). Скрипт импортирует штатный `probe.py`, заменяет в поставленном хуке ТОЛЬКО `stateRoots()` эталонным `model/stateRoots.ts` и через штатный `driver.mjs` вызывает `probe.case` на каждом новом входе. `TemporaryDirectory` очищается немедленно. Последний прогон:
```
VIOLATION project-double-home model ('project-double-home-model', ['--sudit', '--sostojanie', '/tmp/critic157-collisions-88q8gu62/project-double-home-model/dev-harness-projects/backend/home/.omp/profiles/dev/agent/sessions/under/state/zamok', '--zhurnaly', '/tmp/critic157-collisions-88q8gu62/project-double-home-model/dev-harness-projects/backend/home/.omp/profiles/dev/agent/sessions/under/home/.omp/profiles/rogue/agent/sessions', '--repo', '/tmp/critic157-collisions-88q8gu62/project-double-home-model', '/tmp/critic157-collisions-88q8gu62/project-double-home-model/dev-harness-projects/backend/home/.omp/profiles/dev/agent/sessions/under/state/.zamok140-event-3498512-hd8uni0qnk9.json'])
VIOLATION project-double-home owner ('project-double-home-owner', ['--sudit', '--sostojanie', '/tmp/critic157-collisions-88q8gu62/project-double-home-owner/dev-harness-projects/backend/state/zamok', '--zhurnaly', '/tmp/critic157-collisions-88q8gu62/project-double-home-owner/dev-harness-projects/backend/home/.omp/profiles/dev/agent/sessions/under/home/.omp/profiles/rogue/agent/sessions', '--repo', '/tmp/critic157-collisions-88q8gu62/project-double-home-owner', '/tmp/critic157-collisions-88q8gu62/project-double-home-owner/dev-harness-projects/backend/state/.zamok140-event-3498626-4jeld7b72p7.json'])
EXPECTED_STATE project-double-home /tmp/critic157-collisions-88q8gu62/project-double-home-model/dev-harness-projects/backend/state/zamok
EXPECTED_LOGS project-double-home /tmp/critic157-collisions-88q8gu62/project-double-home-model/dev-harness-projects/backend/home/.omp/profiles/dev/agent/sessions
VIOLATION station-double-zones model ('station-double-zones-model', ['--sudit', '--sostojanie', '/tmp/critic157-collisions-88q8gu62/station-double-zones-model/dev-harness-sessions/station/zones/dev/.omp/profiles/dev/agent/sessions/under/zamok', '--zhurnaly', '/tmp/critic157-collisions-88q8gu62/station-double-zones-model/dev-harness-sessions/station/zones/dev/.omp/profiles/dev/agent/sessions/under/zones/rogue/.omp/profiles/rogue/agent/sessions', '--repo', '/tmp/critic157-collisions-88q8gu62/station-double-zones-model', '/tmp/critic157-collisions-88q8gu62/station-double-zones-model/dev-harness-sessions/station/zones/dev/.omp/profiles/dev/agent/sessions/under/.zamok140-event-3498762-vmlu4mutopa.json'])
VIOLATION station-double-zones owner ('station-double-zones-owner', ['--sudit', '--sostojanie', '/tmp/critic157-collisions-88q8gu62/station-double-zones-owner/dev-harness-sessions/station/zamok', '--zhurnaly', '/tmp/critic157-collisions-88q8gu62/station-double-zones-owner/dev-harness-sessions/station/zones/dev/.omp/profiles/dev/agent/sessions/under/zones/rogue/.omp/profiles/rogue/agent/sessions', '--repo', '/tmp/critic157-collisions-88q8gu62/station-double-zones-owner', '/tmp/critic157-collisions-88q8gu62/station-double-zones-owner/dev-harness-sessions/station/.zamok140-event-3498880-m5r3ji6v29m.json'])
EXPECTED_STATE station-double-zones /tmp/critic157-collisions-88q8gu62/station-double-zones-model/dev-harness-sessions/station/zamok
EXPECTED_LOGS station-double-zones /tmp/critic157-collisions-88q8gu62/station-double-zones-model/dev-harness-sessions/station/zones/dev/.omp/profiles/dev/agent/sessions
```
У owner `probe.run` дополнительно дал `KLETKI owner 16 KRASNYH 2`, `OWNER_SUBJECT_FAILS ['foreign-zones-tail', 'project-nested']`, rc скрипта 0. Для owner двойной проектный маркер также проявляет прежнюю отдельную ошибку `--zhurnaly` (которая уже закрывается 157), **но только новая модель смещает здесь корень замка**; двойной станционный маркер смещает корень замка также только в модели.

## САМООПИСАНИЕ — полная сверка чисел и механических имён

- contracts/157-spawn-guard-proektnye-sessii.md:30–33: `KLETKI subject 16 KRASNYH 8` (7 project + foreign-zones-tail), `KLETKI model 16 KRASNYH 0`, 8 именованных мутантов, `--stabs` rc 0, `STAB_ZHIV` — проверено: 16 сценариев в `probe.py:201–228`, восемь ключей targets в `:267–276`, девять итогов KLETKI (model + 8). Подсчёт живыми выводами: blind-root 12, station-only 7, project-only 5, env-root 7, shadow-deny 1, indexof-station 1, last-sessions 1, rc2-pass 1. Каждая из восьми красных групп имеет названную собственную клетку. Никаких расхождений для этих чисел.
- contracts/157-spawn-guard-proektnye-sessii.md:33: станция 140 — 15/15; 104 — `клеток просмотрено: 6`, стаб-пак 17/17; наблюдалось именно это. `spawn-guard.ts:152–160` обозначает действующий блок функции, `_mir.sh:89` зовёт handler без ctx, оба адреса проверены. Две модельные regex `.exec(sessionFile)` фактически в `model/stateRoots.ts:11,18`.
- contracts/157-spawn-guard-proektnye-sessii.md:12: **расхождение САМООПИСАНИЕ**: `14 из 16` и имена ровно двух красных клеток на ВКЛЮЧЁННЫХ штатных сценариях верны, но утверждение «на остальных валидных входах поведения платы и 157 совпадают» ложно: допустимые `project-double-home`/`station-double-zones` из атаки показывают ещё один класс расхождения `--sostojanie`. Это тот же корневой класс, не второй самостоятельный блок. Нужно исправить утверждение о полноте расхождений, а не подменить допуск.
- contracts/157-spawn-guard-proektnye-sessii.md:123–134: `check_threat_model` 5/4 буллета и `check_ceilings` зелёные. Замороженный 140/1 содержит `ЗОНА implementer: ... .omp/extensions/spawn-guard.ts ...`; 157:38–45 повторно назначает тот же файл implementer и явно декларирует ПЕРЕСЕЧЕНИЕ 140/104/099. Исполнители/границы названы; CI-проводка поручена orchestrator и откладывается до зелёной реализации.

## Контрольные команды и raw-итоги на OBJECT

- `git cat-file -t 46484f278193edbf644376bfa3206b6d309c690d` → rc 0 `commit`; `git show -s --format='%H %an <%ae> %P' 46484f278193edbf644376bfa3206b6d309c690d` → rc 0 `46484f278193edbf644376bfa3206b6d309c690d architect <architect@dev-harness.local> 3077762ed0874b918e536f42ac3feaf2681e29f6`.
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py` → rc 1, `KLETKI subject 16 KRASNYH 8`; реальные красные CASE: project-deny, project-allow, project-alt, project-profile, project-shadow, project-nested, project-broken, foreign-zones-tail; пять station, foreign-deny, malformed-session, project-alphabet OK. Предъявление красное ДО реализации как положено.
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --model` → rc 0, `KLETKI model 16 KRASNYH 0`.
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs` → rc 0, сырой итог каждой атаки:
```
KLETKI model 16 KRASNYH 0
KLETKI blind-root 16 KRASNYH 12
KLETKI station-only 16 KRASNYH 7
KLETKI project-only 16 KRASNYH 5
KLETKI env-root 16 KRASNYH 7
KLETKI shadow-deny 16 KRASNYH 1
KLETKI indexof-station 16 KRASNYH 1
KLETKI last-sessions 16 KRASNYH 1
KLETKI rc2-pass 16 KRASNYH 1
```
Именные красные строки: `CASE blind-root station-allow KRASNO: ('station-allow', 'root returned without door check')`; `CASE shadow-deny project-shadow KRASNO`; `CASE indexof-station foreign-zones-tail KRASNO`; `CASE last-sessions project-nested KRASNO`; `CASE rc2-pass project-broken KRASNO` (все строки взяты из живого вывода).
- `bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh` → rc 0 `PROB VSEGO 15 KRASNYH 0`.
- `bash fixtures/_krasnye_104.sh` → rc 0 `стаб-пак: 17/17 поймано`, `клеток просмотрено: 6`, `ИТОГ 104: rc=0`.
- `bash scripts/pre_critic.sh contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `КРИТИК: дверь зелёная`.
- `bash scripts/check_threat_model.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 5 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))`.
- `bash scripts/check_ceilings.sh .` → rc 0 `потолки в порядке`.
- `bash scripts/check_spec_ready.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `OK`.
- `bash scripts/check_precision_gate.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `OK`.
- `bash scripts/check_provodka.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 1 `проводка: guard не подключён: fixtures/workshop_project/spawn_guard_157/probe.py не вызывается в .githooks/ или .github/workflows/`; ожидаемое намеренное ожидание CI после реализации, не отдельный блок.
- `bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit157b/zones-cache.sha .` → результат полный прогон завершён, cache HEAD=46484f278193edbf644376bfa3206b6d309c690d; footer `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42813 · проверено по зонам: 10184`, FAIL не печатался. Повтор с тем же cache → rc 0: `incr: check_zones судит 46484f27..46484f27 (0 коммитов)`, footer `... коммитов в диапазонах: 0 · проверено по зонам: 0`. Полный прогон выдал footer без явного rc из фонового инструмента; rc 0 полного прогона следует из записанного им cache, и подтверждён повтором с явным rc 0.

## Не проверено

Живой omp task из уже запущенного бэкенд-процесса и восстановление реального holder-занятия в продакшн-замке не исполнялись. Проба свидетельствует о фактическом argv установленного хука через Node-драйвер и подложную дверь, не об исполнении реального `zamok_predmeta.sh` на настоящем журнале держателя. Интеграция CI до ленда должна оставаться не подключённой.
