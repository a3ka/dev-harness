FAIL
OBJECT=869174290f68c2175c61b16143015d5ebfd0efa2
СУД: repo=dev-harness; предмет=154; фаза=контракт (+красная батарея); роль=critic; вызов=2/2 (исправительный по санкции оркестратора, Быстрый-процесс; общий счёт 2 из 5); КЛАСС РИСКА=рисковый (деньги); модель-план=anthropic/claude-opus-5-5; сессия=Crit154b; модель-факт=anthropic/claude-opus-5-5; SHA=869174290f68c2175c61b16143015d5ebfd0efa2; предыдущий=FAIL (verdicts/critic/contracts-154-v1-fail.md, OBJECT a8b3e6eea, вызов 1, Crit154); исключение=нет.
Сверка счёта: копия живого учёта (`jq -c . …/c907157c/zamok/uchet.jsonl` → `/tmp/dev-harness-verify/Crit154b/livecopy/uchet.jsonl`, 139 строк, снята только чтением) несёт по dev-harness/154 ровно два critic START: `Crit154` (object a8b3e6ee…, 2026-11-02T01:21:58Z) и `Crit154b` (object 86917429…, 2026-11-02T11:48:30Z). Это вызовы 1 и 2. СУД-запись ДО вызова есть в main 8467a408e (HANDOFF.md, «154 вызов 2 из 5 — Crit154b … санкция оркестратора»).
Независимость: автор дельты — Arch154b (zai/glm-5.3), первая версия — Arch154 (openai-codex/gpt-6-sol); судья — anthropic/claude-opus-5-5. Семейства разные, Sol не судит.

Предмет — закоммиченный `869174290` (`git cat-file -t` → `commit`), один коммит поверх a8b3e6eea. Дерево судьи — одноразовый клон `/tmp/dev-harness-verify/Crit154b/repo` (fetch wip/154/architect, checkout OBJECT). Честная реализация и мутации — только во втором клоне `/tmp/dev-harness-verify/Crit154b/mut`. Живые сверки — на клоне main `/tmp/dev-harness-verify/Crit154b/mainclone` (342186cf0) и копии учёта. В основной чекаут ничего не писалось, push не было.

Итог: 2 блокирующих класса (Б6, Б7), 10 расхождений самоописания (С1–С10), 8 советов (Н1–Н8). Из пяти блоков Crit154 закрыты Б1, Б2, Б3, Б4; Б5 закрыт в тексте и модели, но не для реализации (это Б6). Набор артефактов полон.

## Замеры: сырые команды и rc (последовательно)

Корень `repo` = OBJECT без реализации:
```
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh              → rc=1  CELLS=49 GREEN=10 (RED 39; GREEN boundary-spawn-0..4, boundary-freeze-1, foreign-other-{repo,subject,roles}, do-zhurnala-seed-dopusk)
$ bash …/red_schet_vyzovov_154.sh --model                                                → rc=0  CELLS=52 GREEN=52
$ bash …/red_schet_vyzovov_154.sh --stabs                                                → rc=0  SVJAZI=17 CAUGHT=17 LIVE=0
$ bash …/red_schet_vyzovov_154.sh --domain-model                                         → rc=0  CELLS=198 GREEN=198
$ bash …/red_schet_vyzovov_154.sh --domain                                               → rc=1  CELLS=194 GREEN=82
$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh                    → rc=1  KLETKI 66 KRASNYH 3 (u01-uchet-svod, w20-limit-harness-tri-ok, w21-limit-back-tri-ok)
$ bash scripts/pre_critic.sh contracts/154-schet-vyzovov-kritika.md                      → rc=0  «КРИТИК: дверь зелёная»
$ bash scripts/check_ceilings.sh                                                         → rc=0  «потолки в порядке»
$ bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md          → rc=0  «OK»
$ bash scripts/check_threat_model.sh . contracts/154-schet-vyzovov-kritika.md            → rc=0  «секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))»
$ bash scripts/check_provodka.sh . contracts/154-schet-vyzovov-kritika.md                → rc=1  «guard не подключён: …red_schet_vyzovov_154.sh не вызывается в .githooks/ или .github/workflows/» (ожидаемо до CI-строки)
$ bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit154b/zcache/cache .     → rc=0  «incr: полный прогон (кеш отсутствует)» … «замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 41684 · проверено по зонам: 9928» (384 с)
```

Честная реализация в `mut`: `python3 /tmp/dev-harness-verify/Arch154b/mk_impl.py .`. Скрипт вызывает `probe.prepare_scripts(…, 'model')` батареи и кладёт модельные `zamok_predmeta.sh` и `freeze_contract.sh` в настоящие `scripts/` (diff +20/−1). `scripts/` на OBJECT побайтово равны BASELINE 7fd217d79 (`git diff --stat 7fd217d79 HEAD -- scripts/zamok_predmeta.sh scripts/freeze_contract.sh` пусто).
```
$ bash …/red_schet_vyzovov_154.sh            (mut, вставка)  → rc=0  CELLS=49 GREEN=49
$ bash …/red_schet_vyzovov_154.sh --domain   (mut, вставка)  → rc=0  CELLS=194 GREEN=194
$ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh (mut) → rc=1  KLETKI 66 KRASNYH 3 (те же u01, w20, w21)
```

Потребители freeze (база OBJECT → вставка):
```
bash fixtures/plan_084/red_plan_084.sh                          rc 0 «клеток 59, красных 0» → rc 1 «клеток 59, красных 6, зелёных 53» (ф2, ф3, ф4, ф6, ф9, ф10: «ожидались rc 0 и stdout v1, получено rc=1 … SCHET_NEIZVESTEN: корень состояния не передан»)
bash fixtures/workshop_project/red_samodostatochnost_repo_060.sh rc 0 «17, зелёных 17» → rc 1 «17, зелёных 14, красных: к3-е-реестр-в-toy к6б-… к6е-…»
bash scripts/drill_contract_change.sh                           rc 0 → rc 1 «ОТКАЗ: SCHET_NEIZVESTEN: корень состояния не передан / SCHET154: отказ бюджета»
bash scripts/verify_antiplacebo.sh --scope drill_contract_change rc 0 «предъявлено … 1» → rc 1 «предъявлено … 0, расхождений: 1»
python3 fixtures/check_check_contract_ready/_doc027.py lifecycle rc 0 → rc 1 (SCHET_NEIZVESTEN)
bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-cap | freeze-project-arbitration | freeze-root-arbitration | freeze-gate-preserved   rc 0 каждый → rc 1 каждый «проектный цикл не замкнут»
bash fixtures/check_precision_gate/red_14_freeze_refuses_red_precision.sh rc 0 → rc 0
bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh rc 0 → rc 0 «ветви «all» зелены»
bash fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh          rc 1 «красных 1, зелёных 22, не исполнено 31» → rc 1, тот же ИТОГ (см. С1)
```

## Закрытие блоков Crit154

- **Б1 — закрыт.** `probe.py` main → `return 0 if not failed else 1` во всех режимах. На эталонной вставке W даёт rc 0 49/49, W --domain — rc 0 194/194. Без реализации: rc 1 10/49 и rc 1 82/194.
- **Б2 — закрыт (путь а).** Все потребители, которых я нашёл `git grep` вызовов `freeze_contract.sh` по scripts/ и fixtures/, названы в :13 и получили ЗОНА/ПЕРЕСЕЧЕНИЕ :57, :73–:76 с приёмкой rc 0 после миграции :50. Найденное автором подтверждаю: `red_plan_084.sh` переходит с 59/0 в 6 красных (ф2/ф3/ф4/ф6/ф9/ф10), а вердикт Crit154 этого не назвал. Трактовку автора «rc как до» (отчёт, замечание 3) считаю верной. Путь (б) закрывающего свойства неисполним: все потребители зовут freeze с тремя аргументами, а И-2/:36 требует отказа `SCHET_NEIZVESTEN` без корня состояния. Поэтому на вставке они обязаны краснеть именованным отказом §6в, а rc 0 связывается миграцией. Мои замеры совпадают с отчётом. Остаток по зонам — Н3 и С2.
- **Б3 — закрыт.** Оси источника, посторонних строк и первой строки арбитража вошли в домен: 136+8+22+12+16+4 = 198 (пересчитано по `probe.DOMAIN`: base 136, arb 8, src 22, foreign 12, dozh 16; OLD_DOMAIN 4). Шесть мутантов Crit154 (`/tmp/dev-harness-verify/Arch154b/mutant.py`, по одному, затем `--model`) краснеют своими клетками:
  ```
  freeze-failopen        rc=1 CELLS=52 GREEN=32 (своя клетка RED freeze-no-state rc 0; прочие красные — артефакт мутанта, С4)
  no-repoid              rc=1 GREEN=51  RED foreign-other-repo
  no-subject             rc=1 GREEN=50  RED foreign-other-subject, freeze-second-counter-catcher
  all-judges             rc=1 GREEN=51  RED foreign-other-roles
  spawn-no-rashozhdenie  rc=1 GREEN=51  RED spawn-verdict-no-start
  freeze-arb-owner       rc=1 GREEN=51  RED arb-owner-freeze
  ```
  Те же шесть против `--domain-model` (все rc=1): freeze-failopen CELLS=198 GREEN=102; no-repoid 196; no-subject 196; all-judges 196; spawn-no-rashozhdenie 196; freeze-arb-owner 197.
  Точный freeze-failopen я поставил на самой реализации, а не в модели. В `mut/scripts/freeze_contract.sh` после вызова бюджета вставлена строка `{ [ -n "$st154" ] && [ -f "$st154/uchet.jsonl" ]; } || b154=0`. Результат: W → rc=1 CELLS=49 GREEN=48, RED freeze-no-state rc 0 — пойман своей клеткой.
- **Б4 — закрыт по своему закрывающему свойству.** И-6 :40 называет засев. Живая сверка эталона (`budget.py --sostojanie livecopy --repo mainclone`) на обеих фазах:
  - 140–150 → rc 1 `SCHET_NEIZVESTEN: история критика старше журнала, записи-засева нет`; среди них 145, 147, 148 (4 START), 149 и 150 (3 START);
  - 151, 153, 154 → rc 0;
  - 152 → spawn rc 1 `KAP_VYZOVOV_KRITIKA 5/5`, freeze rc 0;
  - 001, 116 → rc 3 (старые).

  Риск засева назван в Н1.
- **Б5 — в тексте и модели закрыт, для реализации НЕ закрыт.** И-5 :39 называет область, клетки `old-*` есть, а живая классификация совпадает с нормой: 134–137 → предок 5ca237e4e (старые), 138–154 → нет (новые). Но клетки старых предметов стоят только в модельных режимах, и приёмка реализации п.4 их не исполняет. Это Б6 ниже. Повтор класса Б5 при согласии автора — не арбитраж (§Остановка, слово владельца 2026-11-01: «повтор причины при согласии автора — не арбитраж — доделать правку»). Названного спора нет, арбитр не созывается.

## БЛОКИРУЕТ

**Б6. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:49 (п.4 — приёмка реализации только `W` и `W --domain`), :27 («Ось новизны предъявляется модельными прогонами»), :39 (И-5), :47 (п.2 «живая классификация» — команда git, не реализации); fixtures/workshop_project/schet_vyzovov_154/probe.py:449, :557, :561 (OLD_CASES/OLD_DOMAIN только в `model`/`domain-model`).** Классификация «старый/новый предмет» в реализации не проверяется ни одной командой приёмки. Обманная реализация проходит п.4 и снимает кап на живой станции.
ОБХОД: в реализации (`mut`, эталонная вставка) одна строка `staryj_predmet` (budget.py:37) заменена на `return True`, то есть «есть тег id/CONTRACT/NNN — значит старый, границу не смотреть»:
```
$ bash …/red_schet_vyzovov_154.sh            → CELLS=49 GREEN=49   rc=0
$ bash …/red_schet_vyzovov_154.sh --domain   → CELLS=194 GREEN=194 rc=0
$ python3 …/model/budget.py --sostojanie ../livecopy --repo ../mainclone --subject 152 --phase spawn → rc=3   (честный эталон: rc 1 «KAP_VYZOVOV_KRITIKA: предмет 152: 5/5 до спавна»)
  … --subject 154 → rc=3; 153 → rc=3; 151 → rc=3
```
При rc 3 вставка в замок пропускает спавн (`[ "$b154" -ne 0 ] && [ "$b154" -ne 3 ]`). Шестой платный вызов по 152 проходит, а кап не действует ни для одного нового предмета. Второй мутант — обратный порядок аргументов `merge-base --is-ancestor GRANICA tag`. Он тоже даёт W rc 0 49/49 и W --domain rc 0 194/194, а живые старые 001 и 116 получают rc 1 `SCHET_NEIZVESTEN` вместо rc 3, то есть ложный отказ заморозки старых предметов вопреки И-5. Третий мутант — `return False` («новизна игнорируется», двойник стаба `novelty-ignored`, но в реализации): W → CELLS=49 GREEN=49 rc=0, а живые 001 и 116 при `--phase freeze` → rc 1 `SCHET_NEIZVESTEN: история критика старше журнала…` вместо rc 3. Стабы `novelty-ignored` и `novelty-all-old` ловят дефект только в модели (`--stabs`), а приёмка реализации его не видит.
ОБЯЗАТЕЛЬСТВО: И-5 :39; закрывающее свойство Б5 Crit154 («Клетка закрепляет, что старый предмет судится прежним порядком, а новый — новым»); roles/critic.md §Пять вопросов п.2 (каждый пункт «готово» доказывается командой с rc).
СОСТОЯНИЕ: реализация, установленная в настоящие `scripts/`, на живом репозитории с тегами id/CONTRACT/NNN.
НАБЛЮДЕНИЕ: выше. Причина: в toy-репозиториях repo-режима нет ни объекта 5ca237e4e, ни тега номера, поэтому любая ветвь классификации реализации даёт «новый». Объяснение :27 «недостижима по построению» неверно. Объект границы достижим, например, `git fetch` объекта из ROOT или тегом-якорем. Кроме того, граница может быть входом, который ставит мир.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: команда приёмки реализации (п.4 или отдельная, с rc) исполняет установленные `scripts/` хотя бы на трёх входах: старый предмет (тег — предок границы) → прежний §6в и дверь без капа; новый предмет С тегом номера НЕ предком границы → новый кап; граница недоступна → новый. Мутанты «тег значит старый» и «обратный порядок» краснеют на ней своими клетками, честная вставка зелёная.

**Б7. БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:47 (состав домена 198/194), :31 («… SHA OBJECT не входят в ключ счёта»), :35 (И-1 «включая оборванные/освобождённые и все OBJECT/версии»), :188 (ЗАЩИЩАЕТ «смены OBJECT или обрыва сессии»); fixtures/workshop_project/schet_vyzovov_154/probe.py:260 (`object=f'{i + 1:040x}'` — у каждого START свой OBJECT).** В домене нет оси «повтор OBJECT», то есть новой платной сессии на том же OBJECT после обрыва или повтора. Счётчик, сжимающий START по OBJECT, проходит все три матрицы.
ОБХОД: в реализации (`mut`) budget.py:124 `count = len(starts)` заменён на `count = len({r['object'] for r in starts})`:
```
$ bash …/red_schet_vyzovov_154.sh                → CELLS=49 GREEN=49   rc=0
$ bash …/red_schet_vyzovov_154.sh --domain       → CELLS=194 GREEN=194 rc=0
$ bash …/red_schet_vyzovov_154.sh --domain-model → CELLS=198 GREEN=198 rc=0
$ python3 …/model/budget.py --sostojanie ../livecopy --repo ../mainclone --subject 152 --phase spawn → rc=0   (честный эталон: rc 1 KAP 5/5)
```
Живое состояние — ровно этот случай. У 152 пять critic START на четырёх OBJECT: `Crit152d` и `Crit152e` оба на `bdf34324e`, вызов 4 оборван, вызов 5 — новая сессия по слову владельца. У 148 `Crit148v3` и `Crit148v3b` оба на `f2a6d2092`. Мутант пропускает шестой платный вызов по 152.
ОБЯЗАТЕЛЬСТВО: :31, И-1 :35, ЗАЩИЩАЕТ :188; roles/critic.md §Счёт: «Обрыв и новая платная сессия получают следующий номер вызова»; слово владельца docs/owner/2026-11-01-porog-arbitra.md §«Что изменилось» и предмет 154 («включая accept и новые платные сессии после обрыва»).
СОСТОЯНИЕ: ≥2 critic START одного (repoId, subjectId) с одинаковым `object` — допустимый вход (живой).
НАБЛЮДЕНИЕ: выше. Это тот же класс, что Б3 (ось, названная обязательством, отсутствует в конечном домене), но для новой оси.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: конечный домен обеих фаз (и `--domain`, и `--domain-model`) содержит ось «OBJECT повторяется», например {все разные, пара одинаковых после aborted, все одинаковые} при n ∈ {5, 6}. Оракул от неё не зависит (count = все START). Мутант «сжатие по OBJECT» краснеет своей клеткой и в `--domain` на реализации, и в `--stabs`.

## САМООПИСАНИЕ (число/адрес в тексте → живое значение)

- С1. contracts/154:13 «`red_limit_aktivnyh_078.sh` — 55 красных клеток и на базе, и на вставке» и :50 «те же 55 красных, что на базе» → ИТОГ батареи: «красных 1, зелёных 22, не исполнено 31» и на базе, и на вставке. 55 — это число строк с префиксом `КРАСНОЕ 078:` (`grep -c КРАСНОЕ` → 55 из 56), из них 22 несут «ЗЕЛЁНАЯ». Неухудшение при этом верно: ИТОГ одинаков.
- С2. contracts/154:50 «Без правки остаются rc 0: … `bash fixtures/plan_084/red_plan_084.sh` после своей миграции (59/59)» → 084 правится: он в ЗОНА implementer :57 и в списке меняющихся потребителей :13, а на вставке даёт 53/59 rc 1. Место пункта — список «после реализации с миграцией». В отчёте автора «`fixtures/plan_084/` — НЕ заявлены ни одной замороженной зоной» → `git show frozen/contracts/084/1^{commit}:contracts/084-reestr-plana.md`:379: «ЗОНА architect: … fixtures/plan_084/red_plan_084.sh fixtures/plan_084/_toy.sh fixtures/plan_084/.probe-only …».
- С3. contracts/154:46 «Парный положительный вход: … → freeze rc 0 и тег» → `scenario()` (probe.py:355–396) для клеток с пустым оракулом сверяет только rc 0. Тег и реестр сверяются только на отказах.
- С4. contracts/154:48 «freeze-failopen (бюджет только при явном состоянии с живым ledger)» → в `freeze_block` (probe.py, ветка `freeze-failopen`) нет строк `guard`, и `st154` не присваивается. Под `set -euo pipefail` (freeze_contract.sh:35) каждый freeze с состоянием умирает: `run_case(boundary-freeze-3, 'model', 'freeze-failopen')` → «line 403: st154: unbound variable». Привязка к клетке freeze-no-state верна: точный мутант на реализации тоже ловится ею (см. Б3). Но описание стаба не совпадает с его кодом.
- С5. contracts/154:47 «источник {отсутствует, нечитаем, битый, битая-форма, пуст, без аргумента состояния} 22» → 22 = 19 + 2 no-state + 1 `domain-source-spawn-orphan-verdict`. Вердикт-сирота в перечне не назван.
- С6. contracts/154:47 «Оракул — функция n и источника» → `oracle(n, phase, source, foreign, arbitraz, history, seed, novelty, outcomes)`, то есть ещё фаза, история/засев и новизна. Докстринг probe.py:7–9 верен.
- С7. contracts/154:27 «источник — предок тега `id/CONTRACT/NNN`» от `5ca237e4e` → `git merge-base --is-ancestor 5ca237e4e main` → rc 1. Граница не лежит в истории main: в main вошла вишня 451626c74, а 5ca237e4e достижим только из `refs/remotes/origin/owner/bystryj-process` основного репозитория (`for-each-ref --contains`). Классификация 134–154 при этом верна (см. Б5).
- С8. contracts/154:17 «`roles/critic.md` §Область (в редакции 5ca237e4)» → в main редакция — 451626c74 и 9a87a0e26, а 5ca237e4 в main не входит (см. С7).
- С9. model/budget.py:116–117 — текст отказа «засев … противоречит до-журнальным вердиктам предмета» → проверяется только `k < 1`, сверки с вердиктами нет. Так же в contracts/154:40 «механизм читает и сверяет» означает только «≥ 1».
- С10. contracts/154:27 «toy-репозитории не содержат границы, поэтому … недостижима по построению» (то же в probe.py:443–447) → объект границы переносим в toy (`git fetch <ROOT> 5ca237e4e…` при живом объекте в ROOT). Недостижимость — выбор конструкции, а не построение. Содержательно см. Б6.
- Совпали с живыми:
  - число клеток: 49 и «39 красных из 49» (RED 39, GREEN 10); 52 = 49 + 3; 198 = 136+8+22+12+16+4; 194; «GREEN<194» (82);
  - стабы: 17 = 8+6+1+2 (15 в `BUDGET_EDITS` + 2 в `freeze_block`); `SVJAZI=17 CAUGHT=17 LIVE=0`;
  - регресс и потребители: `KLETKI 66 KRASNYH 3` (u01/w20/w21) до и после; 060 17/17 → 14/17 (к3-е/к6б/к6е); 084 59 → 6 красных (ф2/ф3/ф4/ф6/ф9/ф10); red_14 rc 0/0; doc_048 rc 0/0; drill, antiplacebo-drill, _doc027 lifecycle, 996 ×4 rc 0 → 1;
  - адреса: BASELINE 7fd217d79 (probe.py:25); probe.py:376 (oracle) до :379 (gate); frozen 140 §Приёмочный критерий п.9; `docs/owner/2026-11-01-porog-arbitra.md` §«Что изменилось» (:19), §«Остаточный риск (назван прямо)» (:36) п.2; AGENTS.md:171–173;
  - модель угроз 4/4; merge-base 154 → rc 1, 001 → rc 0.
- Отчёт автора «148 контрактов / 41664 коммитов / 9908 проверок» → живое значение: 148 / 41684 / 9928. Разница в 20 коммитов и 20 проверок — дрейф между прогонами (мой клон снят позже, с более свежими ссылками), а не дефект текста контракта. В контракте этих чисел нет.

## СОВЕТ

- Н1. Засев И-6 :40 — точка самоаттестации заинтересованной стороны. Пишет его оркестратор, которого владелец прямо назвал стороной (docs/owner/2026-11-01-porog-arbitra.md §«Остаточный риск» п.1). Механизм принимает любое `doZhurnala ≥ 1`. Нижняя граница вычислима из тех же коммитов: до первого critic START (2026-10-31T18:32:15Z) у предметов добавлено файлов вердикта 145:8, 146:5, 147:4, 148:4, 149:3, 150:2. Засев `doZhurnala=1` для 147 даёт счёт 1 при не менее чем 4 реальных вызовах, то есть открывает ещё 4. Граница угроз этот случай не объявляет ни в ЗАЩИЩАЕТ, ни в НЕ ЗАЩИЩАЕТ. По §Порог это атака вне объявленной границы, поэтому совет, а решение о границе — за владельцем. Варианты: сверка «засев ≥ числа до-журнальных файлов/событий вердикта» либо буллет НЕ ЗАЩИЩАЕТ с ловцом.
- Н2. Режим проекта (996): `budget.py` читает историю вердиктов из `<repo>/verdicts/critic`, а freeze — из `_PROFILE_VERDICTS_BASE` (freeze_contract.sh:92). У Complior-mob и Complior-back `workflowPaths.verdicts=.harness/verdicts`, и там И-3 (вердикт без START) и И-6 (до-журнальная история) слепы. Живо сейчас не достижимо: в учёте нет ни одного repoId, кроме dev-harness, а в `.harness/verdicts/critic` у обоих проектов истории нет. Стоит взять путь вердиктов из того же резолвера.
- Н3. Зоны по frozen-блобам (Н-71). `fixtures/plan_084/red_plan_084.sh`, `_toy.sh` и `.probe-only` лежат в ЗОНА architect frozen 084/1 (:379), а `fixtures/check_check_contract_ready/` — в ЗОНА architect frozen 008/2 (:48) и 027/3. 154 объявляет ПЕРЕСЕЧЕНИЕ только с 027 (:73) и не объявляет с 084 и 008. Гейт 043 сравнивает пути точным равенством (check_precision_gate.sh:217, :225), поэтому пересечения каталог/файл не видит и даёт rc 0. check_zones пропустит implementer по любой его зоне (check_zones.sh:1051), так что механического стопа нет. Ради единообразия с :73–:76 стоит дописать «ПЕРЕСЕЧЕНИЕ implementer: fixtures/plan_084/ — 084 …» и «… _doc027.py — 008 …».
- Н4. Граница 5ca237e4e достижима только из remote-tracking ветки `origin/owner/bystryj-process` (С7). Если ветку удалят и сделают prune/gc, `merge-base` даст ошибку, все предметы прочтутся новыми, и 001…116 получат ложный `SCHET_NEIZVESTEN`. Это громкий отказ, а не тихий пропуск, но лучше якорь в истории main (451626c74) или тег.
- Н5. repoId считается двумя функциями. Замок берёт `${URL##*/}` с fallback на basename корня (zamok_predmeta.sh:127–129), budget — `PurePosixPath(url).name` без fallback, а без origin отвечает `SCHET_NEIZVESTEN`. При URL с хвостовым «/» ключи расходятся: для `https://host/org/dev-harness/` замок получает `[]` и берёт basename корня, а budget — `[dev-harness]` (замерено). :23 обещает одну функцию подсчёта, но ключ считают двумя.
- Н6. `c0` берётся по `%ct`, а rebase, cherry-pick и amend переписывают дату коммиттера. Вердикт, перенесённый так после начала журнала, перестаёт быть «до-журнальным». Надёжнее `%at` либо счётная сверка.
- Н7. Положительные freeze-клетки не сверяют создание тега и записи реестра (С3). Обманный freeze, который выходит с rc 0 без тега, поймают только чужие батареи freeze.
- Н8. Н3 Crit154 (мёртвая часть стаба unreadable-ledger) осталась без изменений, не блок.

## Путь дальше (§Быстрый-процесс §Остановка)

Фазовый бюджет критика (один полный и один исправительный вызов) исчерпан с FAIL; по общему капу использовано 2 из 5. Оркестратор фиксирует ПОЗИЦИЮ АВТОРА по Б6 и Б7. Если автор письменно согласен, оркестратор вправе санкционировать ОДИН исправительный вызов записью: предмет 154, SHA исправленного кандидата, этот вердикт, согласие автора, закрываемые классы Б6 и Б7 плюс С1–С10, доказательства и номер вызова 3 из 5. Если автор письменно оспорит находку, созывается один арбитраж на предмет. Названного спора сейчас нет, поэтому арбитр не созывается. Решение о границе угроз засева (Н1) — за владельцем.

## Что НЕ проверено

- `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta` не прогонялся.
- Полные батареи семьи `fixtures/freeze_contract/` на вставке не прогонялись (зона implementer, миграция после freeze).
- Живой станционный путь `spawn-guard.ts → zamok --sudit` не исполнялся; эталон бюджета на живых данных вызывался напрямую на копии учёта.
- Эмуляторы и нативные сборки не запускались, чужие процессы CI не трогались.
