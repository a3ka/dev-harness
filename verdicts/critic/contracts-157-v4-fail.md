FAIL
OBJECT=7c97dc7476a28f30cd1f06f4efbfedbcdaaf6178
СУД: repo=dev-harness; предмет=157; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=4/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit157d; модель-факт=openai-codex/gpt-6-sol; предыдущий=contracts-157-v3-eskalacija.md (ESCALATE из-за fallback судьи); последний инженерный FAIL=contracts-157-v2-fail.md; исключение=нет. Автор OBJECT — Arch157d (zai/glm-5.3), первая версия — Arch157b (Sol), судится OBJECT целиком; от автора правки судья независим. `git cat-file -t OBJECT` → rc 0 `commit`; `git show -s --format='%H %an <%ae> %P' OBJECT` → rc 0 `7c97dc7476a28f30cd1f06f4efbfedbcdaaf6178 architect <architect@dev-harness.local> 46484f278193edbf644376bfa3206b6d309c690d`. Изолированное дерево извлечено `git archive OBJECT`; основной checkout read-only.

## Один блокирующий класс — чужой компонент внутри корня раскладки

БЛОКИРУЕТ contracts/157-spawn-guard-proektnye-sessii.md:24,26,29,34 — критерий `W` ложно достаточен для компонента `home` внутри `<S>` и `zones` внутри `<P>` ДО первого полного маркера собственной раскладки. Это один класс: матрица испытывает `station-zones-in-s` / `project-home-in-p` (компонент СВОЕГО типа внутри корня) и `station-home-tail` / `project-both-markers-tail` (чужой маркер ПОСЛЕ собственного), но не чужой компонент внутри корня.
ОБЯЗАТЕЛЬСТВО: инварианты 1–3 требуют сессиям обеих раскладок с допустимыми произвольными `<S>`/`<P>` (включая `home`/`zones` компонентами) доходить до действующей двери с `<S>/zamok` либо `<P>/state/zamok` и структурным каталогом журналов. Валидный `task` не отвергается раньше двери из-за такого компонента. Критерий 3 должен различать нарушение от честной реализации.
СОСТОЯНИЕ: живой ctx, валидный `architect`, файл `/home/harness/dev-harness-sessions/station/zones/dev/.omp/profiles/dev/agent/sessions/--repo--/parent/Agent157.jsonl` либо `/zones/cache/dev-harness-projects/backend/home/.omp/profiles/dev/agent/sessions/--repo--/parent/Agent157.jsonl`. Каждый абсолютен, оканчивается jsonl, содержит единственный полный структурный маркер СВОЕГО типа, без `..`/симлинков; даже допущение Frontier о `<root>/dev-harness-sessions/<id>` и `<root>/dev-harness-projects/<проект>` с одно-сегментным id/именем соблюдается. Префикс `/home/harness/` — реально используемый у станции (`boli.md` владельца).
НАБЛЮДЕНИЕ: два независимых негативных варианта модели с проверкой чужого компонента в префиксе дают `KLETKI ... 22 KRASNYH 0` и штатный `--stabs` rc 0, но на дополнительных конформных входах отвечают «файл сессии вне грамматики» вместо `DOOR_DENY_157`; честная модель эти входы проходит. Отдельный вариант с функцией `stateRoots()` побайтово совпадающей с моделью, но с ошибочной фильтрацией после её вызова, также даёт `KLETKI byte-identical-stateRoots 22 KRASNYH 0`, `VARIANT_STABS_RC 0` и отвергает оба файла до двери. Буквальное копирование функции не делает текущий поведенческий критерий достаточным.
ОБХОД: если после получения канонических `roots` считать чужой компонент в вычисленном префиксе запрещающим, `W`, `W --model`, `W --stabs` зелёные, но на допустимой станции из `/home/` и проекте с `/zones/` внутри `<root>` прежняя дверь не вызывается. Вариант меняет смежную ветвь хука и нарушает заявленную адресность правки; нынешние rc-команды этого также не обнаруживают. Сырые результаты — ниже.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка различает ОБА допустимых случая с чужим компонентом в корне до собственного полного маркера: проверяет вызов действительной двери, argv, корни и решение; перечисленные негативные варианты не получают зелёный `W`. Не предписывает единственную реализацию.

### Сырой вывод двух негативных вариантов модельной функции

`python3 /tmp/dev-harness-verify/Crit157d/check_project_zones.py` в одноразовом OBJECT → rc 0 (успех скрипта означает обнаруженное нарушение варианта, НЕ его приемлемость). Он подставляет `seg.slice(0,i).includes('zones')` для проекта или `.includes('home')` для станции, вызывает штатный Node-драйвер через `probe.run` и `probe.case` на дополнительных путях; исходный OBJECT не меняет. Сырой вывод:
```
CASE project-zones-in-p station-deny OK
CASE project-zones-in-p station-allow OK
CASE project-zones-in-p station-alt OK
CASE project-zones-in-p station-profile OK
CASE project-zones-in-p station-broken OK
CASE project-zones-in-p station-double-zones OK
CASE project-zones-in-p station-home-tail OK
CASE project-zones-in-p station-zones-in-s OK
CASE project-zones-in-p project-deny OK
CASE project-zones-in-p project-allow OK
CASE project-zones-in-p project-alt OK
CASE project-zones-in-p project-profile OK
CASE project-zones-in-p project-shadow OK
CASE project-zones-in-p project-nested OK
CASE project-zones-in-p project-broken OK
CASE project-zones-in-p project-double-home OK
CASE project-zones-in-p project-both-markers-tail OK
CASE project-zones-in-p project-home-in-p OK
CASE project-zones-in-p foreign-deny OK
CASE project-zones-in-p foreign-zones-tail OK
CASE project-zones-in-p malformed-session OK
CASE project-zones-in-p project-alphabet OK
KLETKI project-zones-in-p 22 KRASNYH 0
project-zones-in-p MODEL_EXTRA_CASE OK
project-zones-in-p VARIANT_EXTRA_CASE KRASNO: ('project-zones-in-p', {'block': True, 'reason': 'DOOR_DENY_157'}, {'block': True, 'reason': 'ОТКАЗ: страж замка сломан (fail-closed): файл сессии вне грамматики'})
CASE station-home-in-s station-deny OK
CASE station-home-in-s station-allow OK
CASE station-home-in-s station-alt OK
CASE station-home-in-s station-profile OK
CASE station-home-in-s station-broken OK
CASE station-home-in-s station-double-zones OK
CASE station-home-in-s station-home-tail OK
CASE station-home-in-s station-zones-in-s OK
CASE station-home-in-s project-deny OK
CASE station-home-in-s project-allow OK
CASE station-home-in-s project-alt OK
CASE station-home-in-s project-profile OK
CASE station-home-in-s project-shadow OK
CASE station-home-in-s project-nested OK
CASE station-home-in-s project-broken OK
CASE station-home-in-s project-double-home OK
CASE station-home-in-s project-both-markers-tail OK
CASE station-home-in-s project-home-in-p OK
CASE station-home-in-s foreign-deny OK
CASE station-home-in-s foreign-zones-tail OK
CASE station-home-in-s malformed-session OK
CASE station-home-in-s project-alphabet OK
KLETKI station-home-in-s 22 KRASNYH 0
station-home-in-s MODEL_EXTRA_CASE OK
station-home-in-s VARIANT_EXTRA_CASE KRASNO: ('station-home-in-s', {'block': True, 'reason': 'DOOR_DENY_157'}, {'block': True, 'reason': 'ОТКАЗ: страж замка сломан (fail-closed): файл сессии вне грамматики'})
```
`python3 /tmp/dev-harness-verify/Crit157d/check_variant_stabs.py` → rc 0, дословные итоги: `project-zones-in-p STABS_RC 0`, `station-home-in-s STABS_RC 0`. Контроль каждого исполнил штатные девять красных вариантов на эталоне.

### Сырой вывод варианта с побайтовой моделью

`python3 /tmp/dev-harness-verify/Crit157d/check_hook_cross.py` → rc 0. Каноническая функция модели без изменений; только в установленном хуке после `stateRoots` и до двери добавлена структурная фильтрация уже вычисленного `roots.sost`. Дословные существенные строки живого вывода (остальные строки штатных стабов исполнялись и печатались, каждая группа имела свои красные клетки):
```
CASE byte-identical-stateRoots station-deny OK
CASE byte-identical-stateRoots station-home-tail OK
CASE byte-identical-stateRoots station-zones-in-s OK
CASE byte-identical-stateRoots project-deny OK
CASE byte-identical-stateRoots project-both-markers-tail OK
CASE byte-identical-stateRoots project-home-in-p OK
CASE byte-identical-stateRoots foreign-zones-tail OK
KLETKI byte-identical-stateRoots 22 KRASNYH 0
project-zones-in-p MODEL_EXTRA_CASE OK
project-zones-in-p VARIANT_EXTRA_CASE KRASNO: ('project-zones-in-p', {'block': True, 'reason': 'DOOR_DENY_157'}, {'block': True, 'reason': 'ОТКАЗ: страж замка сломан (fail-closed): файл сессии вне грамматики'})
station-home-in-s MODEL_EXTRA_CASE OK
station-home-in-s VARIANT_EXTRA_CASE KRASNO: ('station-home-in-s', {'block': True, 'reason': 'DOOR_DENY_157'}, {'block': True, 'reason': 'ОТКАЗ: страж замка сломан (fail-closed): файл сессии вне грамматики'})
KLETKI model 22 KRASNYH 0
KLETKI blind-root 22 KRASNYH 18
KLETKI station-only 22 KRASNYH 10
KLETKI project-only 22 KRASNYH 8
KLETKI env-root 22 KRASNYH 10
KLETKI shadow-deny 22 KRASNYH 1
KLETKI indexof-station 22 KRASNYH 5
KLETKI last-sessions 22 KRASNYH 3
KLETKI rc2-pass 22 KRASNYH 1
KLETKI greedy-prefix 22 KRASNYH 3
VARIANT_STABS_RC 0
```
Временные установки `TemporaryDirectory` очищены; каталог архива OBJECT удалён после завершения проверок.

## Дельта, границы и контрольные команды

- Класс Crit157b (повтор полного маркера в допустимом хвосте) закрыт: сегментная модель выбирает ПЕРВЫЙ полный маркер; `station-double-zones`, `project-double-home`, `project-both-markers-tail` зелёные на модели и красные на `greedy-prefix` (оба исходных контрпримера критика пойманы). Новая находка относится к чужому компоненту в ПРЕФИКСЕ, не к хвосту.
- Первые шесть классов (проект/чужая форма/вложенный `agent/sessions`/rc 2/списки угроз/требования) перепроверены батареей и гейтами. `КЛАСС РИСКА: рисковый` адекватен охране замка. Зоны architect/implementer/critic/adversary/reviewer/orchestrator объявлены, пересечение implementer с замороженным 140/1 оформлено (у 140 `.omp/extensions/spawn-guard.ts` — `ЗОНА implementer`). Н-39: привязка именованных вариантов к клеткам — код `probe.py`. CI-проводка откладывается до реализации.
- `python3 /tmp/dev-harness-verify/Crit157d/check_owner.py` → rc 0; дословные итоги `KLETKI owner-cf4054e8e 22 KRASNYH 7`, `OWNER_ACTUAL ['foreign-zones-tail', 'project-both-markers-tail', 'project-double-home', 'project-nested', 'station-double-zones', 'station-home-tail', 'station-zones-in-s']` совпали с ожидаемыми; owner-код взят `git show cf4054e8e:.omp/extensions/spawn-guard.ts`.

Контрольные команды на OBJECT:
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py` → rc 1, `KLETKI subject 22 KRASNYH 14`: десять проектных, `foreign-zones-tail`, `station-double-zones`, `station-home-tail`, `station-zones-in-s` красны ДО реализации.
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --model` → rc 0, `KLETKI model 22 KRASNYH 0`.
- `python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs` → rc 0; сырые итоги `KLETKI model 22 KRASNYH 0`; `blind-root 22 KRASNYH 18`; `station-only 22 KRASNYH 10`; `project-only 22 KRASNYH 8`; `env-root 22 KRASNYH 10`; `shadow-deny 22 KRASNYH 1`; `indexof-station 22 KRASNYH 5`; `last-sessions 22 KRASNYH 3`; `rc2-pass 22 KRASNYH 1`; `greedy-prefix 22 KRASNYH 3` (у каждой строки префикс `KLETKI`).
- `bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh` → rc 0 `PROB VSEGO 15 KRASNYH 0`; `bash fixtures/_krasnye_104.sh` → rc 0 `стаб-пак: 17/17 поймано`, `клеток просмотрено: 6`, `ИТОГ 104: rc=0`.
- `bash scripts/pre_critic.sh contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `КРИТИК: дверь зелёная` (локальный git HEAD=OBJECT с frozen/id refs).
- `bash scripts/check_ceilings.sh .` → rc 0 `потолки в порядке`; `bash scripts/check_precision_gate.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `OK`; `bash scripts/check_threat_model.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 6 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))`; `bash scripts/check_spec_ready.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 0 `OK`.
- `bash scripts/check_provodka.sh . contracts/157-spawn-guard-proektnye-sessii.md` → rc 1 `проводка: guard не подключён: fixtures/workshop_project/spawn_guard_157/probe.py не вызывается в .githooks/ или .github/workflows/` — заявленный этап ПОСЛЕ реализации, не отдельный блок.
- `bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit157d/zones-parent.sha .` → rc 0, `incr: check_zones судит 46484f27..7c97dc74 (1 коммит)`, footer `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 147 · проверено по зонам: 147`. Это адресная проверка дельты, НЕ полный проход истории.

## Не проверено

Живой `omp task` из уже запущенного проекта, продукционный замок с holder и будущая CI-интеграция не запускались. Полный исторический `check_zones.sh --incr /tmp/dev-harness-verify/Crit157d/zones-cache.sha .` при отсутствующем кеше на изолированном git-архиве показал множество исторических `FAIL коммит вне зоны` до OBJECT (например, `architect fe8b15e1 fixtures/self_contained_cwd/.probe-only` и `orchestrator 1596a3ca ROADMAP.md`); после явных посторонних расхождений ресурсоёмкий фоновый прогон прекращён SIGTERM, он завершился `failed`, а не зеленью. Зона ОДНОГО коммита OBJECT проверена отдельно с rc 0 выше; исторические FAIL не приписываются предмету 157. Вердикт касается закоммиченного OBJECT и критерия, не будущей реализации.
