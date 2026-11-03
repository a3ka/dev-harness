ESCALATE
OBJECT=7c97dc7476a28f30cd1f06f4efbfedbcdaaf6178
СУД: repo=dev-harness; предмет=157; фаза=контракт v1 (+красная батарея), правка Arch157d по Crit157b; роль=critic; вызов=3/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit157c; модель-факт=zai/glm-5.3; предыдущий=contracts-157-v2-fail.md (FAIL, один класс: повторный структурный маркер в хвосте); исключение=нет.

## Почему не accept и не FAIL — независимость судьи нарушена

ОБЯЗАТЕЛЬСТВО: фактическая модель критика не совпадает по семейству/вендору с фактической моделью автора правки; «переход роли через autoFallback проверяется повторно по фактическому трейсу ДО материализации вердикта»; при совпадении предмет не принимается — законный маршрут: санкционированная замена либо остановка, не молчаливое исключение (roles/critic.md §Быстрый-процесс §Независимость; слово владельца 2026-11-02 ~22:35: критикует Sol, переключение критика на Claude/GLM «с целью экономии» запрещено).
СОСТОЯНИЕ: задание объявляет «модель-план=openai-codex/gpt-6-sol … судья Sol: независимость есть» и «автор правки Arch157d — zai/glm-5.3 (GLM)»; фактическая модель ЭТОЙ судейской сессии по трейсу рабочей станции — zai/glm-5.3.
НАБЛЮДЕНИЕ: судья и автор правки OBJECT — одна модель zai/glm-5.3. Сверка независимости до материализации НЕ пройдена; accept из этой сессии заморозил бы контракт мимо нормы — запрещено; FAIL несправедлив по существу (блокирующих инженерных находок нет, см. свидетельство ниже).
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: замена судьи на санкционированную независимую модель (штатный apex-sol) с повторным вызовом (следующий номер 4/5), ЛИБО явное слово владельца об исключении из нормы независимости. Эта сессия израсходовала вызов 3/5; счёт не обнулён. Раздел «Свидетельство по существу» ниже — НЕ вердикт и НЕ наследуется заменой как accept: судья-замена проводит собственный полный разбор.

## Свидетельство по существу (НЕ материализовано как вердикт)

Судился коммит OBJECT в изолированной копии `/tmp/dev-harness-verify/Crit157c-git` (git-clone --shared, checkout 7c97dc747); исходный чекаут не правился (статус чист после работы). `git cat-file -t 7c97dc747…` → rc 0 `commit`; автор `architect <architect@dev-harness.local>`, родитель 46484f278; дельта вызова — единственный коммит 7c97dc747 (contracts/157, model/stateRoots.ts, probe.py; 22/59/136 строк).

### Дельта и закрытие класса вызова 2

1. Грамматика переписана на разбор по сегментам с привязкой к ПЕРВОМУ полному структурному вхождению (`model/stateRoots.ts`, цикл `for (let i = 2; …)`): повторный маркер любого вида в хвосте не переопределяет ни `sost`, ни `zhurnaly`. Живой `--model`: 22/22 OK, включая контрпримеры Crit157b `project-double-home`, `station-double-zones`, `project-both-markers-tail`.
2. Клетки 16→22: +station-double-zones, station-home-tail, station-zones-in-s, project-double-home, project-both-markers-tail, project-home-in-p; безфлаговый прогон красен ровно 14 из 22 живыми «файл сессии вне грамматики» либо ложными argv хозяина платы.
3. Модель v1 (жадный префикс) поставлена как 9-й обманный вариант `greedy-prefix`, красна ровно тремя своими клетками (оба контрпримера критика + оба маркера в хвосте); привязка варианта к клеткам — код `probe.py` (dict `targets`, Н-39), проза контракта пару не утверждает.
4. Закрывающее свойство вердикта v2 внесено в контракт дословно («Красное предъявление и приёмка»). Все шесть классов вызова 1 и класс вызова 2 перепроверены живыми прогонами: rc 2 на проекте — project-broken (мутант rc2-pass красен), `--zhurnaly` при вложенном `agent/sessions` — project-nested (last-sessions красен), отказ валидному проекту — проектные клетки произвольных `<P>` (alt/shadow/nested/home-in-p), чужая форма с `/zones/` в хвосте — foreign-zones-tail (indexof-station красен), норма 041 — `check_threat_model` rc 0 (6/5), норма 004 — `check_ceilings` rc 0 в клоне с тегами.

### Атаки (сырые команды и вывод)

Одноразовое дерево `/tmp/dev-harness-verify/Crit157c-work` (копия трёх файлов батареи с перенаправленным REPO; удалена после атак). `python3 /tmp/dev-harness-verify/attack157c2.py` — файл сессии с компонентом `..` сразу за маркером (`…/agent/sessions/../Agent157.jsonl`) на обеих раскладках; сырой вывод:
```
station ANSWER {"block":true,"reason":"DOOR_DENY_157"}
station DOOR_CALLED True
station ARGV ['--sudit', '--sostojanie', '<…>/station-escape/dev-harness-sessions/station/zamok', '--zhurnaly', …]
project ANSWER {"block":true,"reason":"DOOR_DENY_157"}
project DOOR_CALLED True
project ARGV ['--sudit', '--sostojanie', '<…>/project-escape/dev-harness-projects/project/state/zamok', '--zhurnaly', …]
```
Корни НЕ сдвинуты (`..` остался в хвосте за пределами вычисленных корней) — обхода нет; точка вне заявленной границы (инвариант 3, НЕ ЗАЩИЩАЕТ п. 4) — совет, не блок.

`node /tmp/dev-harness-verify/grammar157c.mjs` (функция модели в Node) — граничные формы:
```
"relative/path.jsonl" => null                                  (неабсолютный — третья форма, как заявлено)
"/abs/trailing/" => null                                       (конечный / — третья форма, как заявлено)
"/dev-harness-sessions//zones/…/agent/sessions/A.jsonl" => sost "/dev-harness-sessions/"
"/dev-harness-projects//home/.omp/profiles/dev/agent/sessions/A.jsonl" => sost "/dev-harness-projects//state"
"/dev-harness-projects/p/home/.omp/profiles//agent/sessions/A.jsonl" => null
```
Пустой сегмент внутри `<S>`/`<P>` не сдвигает корень и не меняет профиль; пустой `<zone>`/`<profile>` отвергается (`seg[i+1] !== ''`). Расхождений с инвариантом 1 нет.

### САМООПИСАНИЕ — сверка чисел и имён (расхождений нет)

- «22 клетки», «красны 14 из 22»: `KLETKI subject 22 KRASNYH 14`; красные поимённо совпадают с перечислением; зелёные — 5 простых станционных, foreign-deny, malformed-session, project-alphabet.
- «9 вариантов»: `--stabs` вывел ровно 9 итогов (model 0; blind-root 18, station-only 10, project-only 8, env-root 10, shadow-deny 1, indexof-station 5, last-sessions 3, rc2-pass 1, greedy-prefix 3); контракт чисел по вариантам не утверждает (Н-39). Числа v1/v2 (16 клеток и пр.) в тексте OBJECT не остались.
- `greedy-prefix` красен ровно тремя клетками (station-double-zones, project-double-home, project-both-markers-tail) — живой вывод совпадает.
- Станция 140 — 15/15 (`PROB VSEGO 15 KRASNYH 0`); 104 — 6/6, стаб 17/17 (`ИТОГ 104: rc=0`).
- `spawn-guard.ts:152-160` — действующая stateRoots платы (grep подтверждает); в замороженном `frozen/contracts/140/1` `.omp/extensions/spawn-guard.ts` — ЗОНА implementer; пересечение объявлено тремя ПЕРЕСЕЧЕНИЕ-строками (140/104/099) — 157 вправе назначить зону, конфликт оформлен; `check_precision_gate` rc 0.
- Временная заплата: `02916231f` автор owner, на origin/owner/strazh-proekt-vremenno, 11+/3- только в .omp/extensions/spawn-guard.ts; её ветка `indexOf('/zones/')` → `indexOf('/home/.omp/profiles/')` с жадным `^(.*\/agent\/sessions)\/` сверена с §Существующее (7 расхождений) — соответствие подтверждено поведением клеток subject-прогона.
- ПРЕДПОСЫЛКИ: `actions/setup-node@v4` — ci.yml:125/201/251 (да); 65 ПЕРЕСЕЧЕНИЕ-строк, каждая привязана к ЗОНА (гейт зелёный). Среда: Node 26.5.1, Python 3.12.3.

### Контрольные команды и rc (клон OBJECT)

- `python3 fixtures/workshop_project/spawn_guard_157/probe.py` → rc 1, `KLETKI subject 22 KRASNYH 14` (красное предъявление ДО реализации живое).
- `…probe.py --model` → rc 0, `KLETKI model 22 KRASNYH 0`.
- `…probe.py --stabs` → rc 0; итоги: model 0, blind-root 18, station-only 10, project-only 8, env-root 10, shadow-deny 1, indexof-station 5, last-sessions 3, rc2-pass 1, greedy-prefix 3.
- `bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh` → rc 0, 15/15.
- `bash fixtures/_krasnye_104.sh` → rc 0 (`стаб-пак: 17/17 поймано`, `клеток просмотрено: 6`, `ИТОГ 104: rc=0`).
- `bash scripts/pre_critic.sh contracts/157-…` → rc 0 `КРИТИК: дверь зелёная` (первый прогон на archive-копии без .git — rc 1 «precision-gate красен» из-за отсутствующих тегов; среда, не контракт).
- `bash scripts/check_ceilings.sh .` → rc 0 `потолки в порядке` (git-клон с тегами).
- `bash scripts/check_precision_gate.sh . contracts/157-…` → rc 0 `OK`.
- `bash scripts/check_threat_model.sh . contracts/157-…` → rc 0 (ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 5).
- `bash scripts/check_spec_ready.sh . contracts/157-…` → rc 0 `OK`.
- `bash scripts/check_provodka.sh . contracts/157-…` → rc 1 `guard не подключён` — ОЖИДАЕМО до ленда реализации (CI подключает оркестратор; безфлаговая краснота до ленда — требование контракта).
- `bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit157c-zones-cache.sha .` — полный прогон завершён: footer `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42832 · проверено по зонам: 10203`, строк FAIL нет (grep = 0); повтор `--incr` с записанным кешем → `incr: check_zones судит 7c97dc74..7c97dc74 (0 коммитов)`, явный rc=0.

### Советы (для судьи-замены, не блок)

- СОВЕТ contracts/157:22 — развилка «полный маркер внутри `<S>`/`<P>`» закрыта заявленным допущением (побеждает первый маркер) и названа в НЕ ЗАЩИЩАЕТ; при появлении много-сегментных `<P>` допущение перепроверить.
- СОВЕТ §Существующее, пункт «(е) station-zones-in-s» — фраза обрезана многоточием (клетка живая и красная по правильной причине); при следующей правке дописать хвост.
- СОВЕТ — `..` в хвосте проходит к двери с несдвинутыми корнями (атака выше); вне границы, поведение детерминировано.

### Не проверено

Живой omp task из запущенного проектного процесса (не Node-драйвер с синтетическим ctx) и реальное holder-занятие в живом замке — поле адверсария/ревьюера рискового предмета. Интеграция CI — намеренно не подключена до ленда. Полный разбор выполнен в сессии с нарушенной независимостью и материализоваться как вердикт не может.
