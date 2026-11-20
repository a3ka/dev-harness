accept
OBJECT=fa61f020fd2828da01f812e94267147d51a5fff4
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: рисковый; адверсарий предшествовал — accept; один вызов по дельте от c2fd07be, слово владельца 19:24)

СУД: repo=dev-harness; предмет=140; фаза=реализация v5, поезд PR #1160 (`wip/140/implementer-v5`, tip fa61f020fd); роль=reviewer; сессия=Rev140Train; модель-факт=anthropic/claude-opus-5-5.

Строка `bash scripts/models_actual.sh --tsv --bind --session Rev140Train` (rc 0):
`reviewer	anthropic/claude-opus-5-5	allowed	Rev140Train	fa61f020fd2828da01f812e94267147d51a5fff4`

- Предыдущий судья этого OBJECT — adversary Adv140Train (openai-codex/gpt-6.1-terra), accept, bceb91058e.
- Прежний reviewer Rev140Impl судил c2fd07be (accept 614720c847). Его accept я не переношу.
- Авторы дельты — implementer, architect и orchestrator (merge), не судья.

Scope: `git diff c2fd07be633522177f781ca6c7ee5bc091f65e96 fa61f020fd2828da01f812e94267147d51a5fff4` и область правки всего поезда (`origin/main...OBJECT`).

Находки — `.review/2026-11-20-122.md` (status: ready). Блоков нет, советов пять (С-1…С-5). Прежний С-2 (`.review/2026-11-20-120.md`, порядок ленда 199) закрыт поездом.

## БЛОКИРУЕТ

Нет.

## СОВЕТ (подробно — `.review/2026-11-20-122.md`)

- **С-1 (architect 157, `fixtures/workshop_project/spawn_guard_157/probe.py:89-106`).** Позиция ≥4 batch не несёт `isolated:true` ни в одной клетке. Мой мутант хука `isolated: out.length !== 3 && o.isolated === true` (`mut_misc.py hook-fourth-drop`) прогнан через S: `PROB VSEGO 45 KRASNYH 0`, rc 0. У adversary тот же мутант в 157 даёт 59/0. Ни 157, ни S его не ловят. Не блок: обход построен специально, а нормализация `spawn-guard.ts:202` поэлементная и индекса не читает.
- **С-2 (architect 140, `sdacha_140_v5.md:127`).** Прежний С-4 закрыт частично: «Production не изменялась.» осталась без привязки к дельте fa61f020.
- **С-3 (перенос прежнего С-1, `no-runtime-silent` у `scripts/pre_judge.sh`).** Файл в дельте не менялся, совет открыт, я его не перемерял.
- **С-4 (перенос прежнего С-3, пустой `--repo` у `--object`/`--snapshot`).** Дверь в дельте не менялась, совет открыт.
- **С-5 (architect 140 + владелец, `sdacha_140_v5.md:68`).** Дверь листа `S-station` гонит S в `check_sdacha --run`/`pre_critic` в любой копии. Приёмка 7 (`contracts/140…:84`) называет S из копии под `/zones/` NOT_RUN. Вреда в моём прогоне не наблюдал, см. файл находок.

## 1. Область правки

Коммиты дельты c2fd07be..OBJECT (`git log --format='%H %P | A=%an <%ae> C=%cn <%ce>'`), у всех автор = коммиттер. Пути — `git diff-tree --name-status`.

| Коммит | Автор | Пути | Зона |
|---|---|---|---|
| 0c6416bd | implementer | `.omp/extensions/spawn-guard.ts` | ЗОНА implementer frozen 140/5 `:94`; ЗОНА implementer frozen 199/1 `:75`; ПЕРЕСЕЧЕНИЕ 199/1 `:83` «140 только пронос поля isolated в событие двери; алфавит 104 и корни состояний неизменны» |
| b462e955 | architect | `fixtures/workshop_project/spawn_guard_157/probe.py` | ЗОНА architect frozen 157/1 `:41` |
| dd60a5a3 | architect | `fixtures/workshop_project/spawn_guard_157/probe.py` | то же |
| fa61f020 | architect | `fixtures/workshop_project/odin_agent_140/{stancija_odin_agent_140.sh,osi.md,sdacha_140_v5.md}` | ЗОНА architect frozen 140/5 `:90` |
| 7c4bd7a0 (merge) | orchestrator | main-сторона (land 193) | разрешений нет, см. ниже |

**Хук.** Дифф 0c6416bd — комментарий-слой, поле `isolated: boolean` в типе `TaskItem` и строка `isolated: o.isolated === true` в `taskItems`. Алфавит 104 и корни состояний не тронуты, что соответствует ПЕРЕСЕЧЕНИЮ.

Побайтность хука проверена своей мерой:
- `sha256sum .omp/extensions/spawn-guard.ts` → `d74fbe27e51d8b939318c354a2bb9652b2c24ac0058f78411e415b3f9b22ae23`;
- `git show 512e822676:.omp/extensions/spawn-guard.ts | sha256sum` → то же. Accept на 512e822676 — reviewer 2a6cec955d, первая строка вердикта `accept`, `OBJECT=512e822676…`;
- `git show e2ee8d8b3d:… | sha256sum` → то же. Это OBJECT accept adversary 4f326b601b.

**Merge 7c4bd7a0** (родители c2fd07be и b3394d0c):
- `git show --remerge-diff` и `git show --cc` дают 0 строк;
- `git merge-base --is-ancestor b3394d0c origin/main` → 0;
- `git diff --name-only origin/main...OBJECT` — 12 путей, все из таблицы выше и прежней принятой дельты (96f2c776, 9ab69b3f/c2fd07be, 161/172/185). Пути main-стороны (193: `scripts/lib_karta_sdachi.sh`, `fixtures/workshop_project/sdacha_193/*`, `verdicts/review/contracts-193-*`, `.review/2026-11-20-120.md`) в этот список не входят: они пришли из main.

Прежние коммиты поезда (96f2c776, 9ab69b3f, c2fd07be, 056f95cc, dca2a2b0, c2543c8d и merge ae5dbf6b/e46dabd9/53b67d30) судил прежний вердикт. Я перепроверил только автор = коммиттер (выдача `git log origin/main..HEAD` — 14 коммитов) и их пути в `origin/main...OBJECT`, они ⊆ зон 140/5, 161/1 `:36`, 172/2 `:39`, 185/1 `:42`.

**Нормы и барьеры:**
- `git diff --exit-code frozen/contracts/140/5 HEAD -- contracts/140-odin-agent-na-predmet.md` → rc 0;
- `git diff --name-only c2fd07be HEAD -- scripts/zamok_predmeta.sh scripts/pre_judge.sh scripts/verify_antiplacebo.sh scripts/check_sdacha.sh scripts/check_provodka.sh scripts/check_zones.sh scripts/pre_critic.sh roles/ AGENTS.md registry/ contracts/ .github/ …/red_odin_agent_140.sh …/normalizacija_140.py …/object_140.py …/spawn_guard_157/driver.mjs` → пусто;
- `git diff --name-only origin/main...HEAD -- roles/ AGENTS.md registry/ contracts/ .github/ scripts/{verify_antiplacebo,check_sdacha,check_provodka,check_zones,pre_critic}.sh` → пусто.

`bash scripts/check_zones.sh .` → rc 1 (818 с), итог «замороженных контрактов: 182 · объявленных авторов: 5 · коммитов в диапазонах: 65318 · проверено по зонам: 20860». Строк FAIL — 1310. Из них не содержат «не аннотированный» — 0 (`grep FAIL | grep -v -c 'не аннотированный'`). С короткими SHA коммитов поезда (0c6416bd b462e955 dd60a5a3 fa61f020 7c4bd7a0 96f2c776 9ab69b3f c2fd07be 056f95cc dca2a2b0 c2543c8d) — 0. Пример: «FAIL коммит вне зоны: orchestrator 63c3d44f registry/contracts.tsv — дверь минта 031: тег id/CONTRACT/037 не аннотированный». Красное даёт окружение копии (теги id/frozen — коммиты, а не tag-object), а не поезд. Это известный факт задания, подтверждён.

## 2. Сырой вывод (мои прогоны на OBJECT, TMPDIR=/tmp/dev-harness-verify/reviewer140train-1717276; полные логи `accA.log`/`accB.log`/`accC.log` там же)

Копия судьи (`/zones/…/td094e2b76/m`):
```
bash …/red_odin_agent_140.sh                → KLETKI 172 KRASNYH 0                         RC=0 (23s)
bash …/red_odin_agent_140.sh --model        → MODEL_KLETKI 172 KRASNYH 0                   RC=0
bash …/red_odin_agent_140.sh --stabs        → MODEL_KLETKI 172 KRASNYH 0 / SVJAZI 159 / MODEL_ZHIVYH 0 / SUBJEKT_SVJAZI 159   RC=0 (99s)
bash …/red_odin_agent_140.sh --sintaksis    → SINTAKSIS FILES 83                           RC=0
bash …/red_odin_agent_140.sh --owner-check  → OWNER_MUTANT s79/s80/s81 … / OWNER140_FAILURES 0   RC=0
python3 …/object_140.py --prepare           → PREPARE published ok / leak ok / unpublished ok   RC=0
bash scripts/check_sdacha.sh . contracts/140-odin-agent-na-predmet.md --run → СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)   RC=0 (220s)
bash scripts/pre_critic.sh --repo . contracts/140-odin-agent-na-predmet.md  → … ok сдаточный лист красен / КРИТИК: дверь зелёная   RC=0 (232s)
bash scripts/check_provodka.sh . contracts/140-odin-agent-na-predmet.md     → RC=0
bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta         → итог 4/4 классов закрыто   RC=0
npm run check:spawn-guard-157-family-selftest → KLETKI subject 59 KRASNYH 0   RC=0
python3 fixtures/workshop_project/spawn_guard_157/probe.py --stabs → KLETKI model 59/0 … isolated-control 59/0, isolated-always-false 59/23, isolated-truthy 59/10, first-only 59/19, last-only 59/19, middle-only 59/20, batch-all-or-nothing 59/19, batch-any 59/19, batch-only 59/1, worker-only 59/2 / STABY 46 NEPOIMANNYH 0   RC=0 (176s)
bash …/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh          → RC=0
bash …/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh --stabs  → STAB_CAUGHT tmpdir-write / hash-ignored / symlink-bypass   RC=0
bash fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.sh     → … STAB allow_archive_worktree/prefer_local/ignore_leak_rc caught   RC=0
bash …/pre_judge_leak_185/red_pre_judge_leak_185.sh --repo   → RC=0
bash …/pre_judge_leak_185/red_pre_judge_leak_185.sh --stabs  → 185 STAB fallback_to_local caught   RC=0
bash scripts/verify_antiplacebo.sh --scope pre_judge → FAIL pre_judge.sh: нет фикстур — ожидается fixtures/pre_judge/case_*.sh / расхождений: 1   rc=1
```
Scoped `verify_antiplacebo` красный по известной причине, она была и до поезда: `git ls-tree -r --name-only origin/main -- fixtures/pre_judge | wc -l` → 0, на HEAD → 0.

Независимый runtime-клон `$TMPDIR/runtime` (`git clone --no-hardlinks` копии, detached на OBJECT, sha256 хука `d74fbe27…`). Там S исполнима; причина отдельного клона — приёмка 7 контракта:
```
bash …/stancija_odin_agent_140.sh → PROB VSEGO 45 KRASNYH 0   RC=0 (8s)
python3 …/normalizacija_140.py → NORMALIZACIJA strict rc=0 / PROB VSEGO 45 KRASNYH 0
                                 NORMALIZACIJA truthy rc=1 / PROB VSEGO 45 KRASNYH 18 / NORMALIZACIJA truthy RAZLICHENO 9
                                 NORMALIZACIJA constant rc=1 / PROB VSEGO 45 KRASNYH 29 / NORMALIZACIJA constant RAZLICHENO 5   RC=0 (24s)
```
CI: `gh run view 44800075977 --json headSha,status,conclusion` → `fa61f020fd… completed success`. `gh pr checks 1160`: все `pass`, `vorota` — `skipping`.

Подсчёт своей мерой: 172/159/83/45/59/46 получены моими прогонами, а не взяты из листа или из вердикта adversary. Числа совпадают с листом `sdacha_140_v5.md` («Ремонт станционного frozen-мира») и с вердиктом adversary.

## 3. Проверки не подогнаны под код

**Ремонт мира fa61f020.**
- Дифф `stancija_odin_agent_140.sh`: новая функция `mir_frozen_kontrakt` и три вызова вместо `mir_kontrakt "$RE"` (p05, p10×6; в p16 вызов добавлен, раньше контракта в RE не было).
- `git diff c2fd07be HEAD -- …/stancija_odin_agent_140.sh | grep -E '^[-+]' | grep -i -E 'kejs|proba|want|block:|pass'` → пусто (rc 1). Ожидания клеток, `kejs`, `proba` и причины не тронуты.
- Дверь, хук-дверь, `red_odin_agent_140.sh` и `normalizacija_140.py` в дельте не менялись (п.1).

**Мир правдивый.** Построитель коммитит контракт, ставит аннотированный `frozen/contracts/141/1` и отдельным коммитом пишет строку `141 → <tag-object>` в `registry/contracts.tsv`. Формат совпадает с живым реестром: `registry/contracts.tsv:202` `140 → 42f063a6fa…`, `git cat-file -t 42f063a6fa` → `tag`. Дверь `scripts/zamok_predmeta.sh:384-396` (`frozen_predmeta`) требует строку `^NNN → [0-9a-f]{40}$`, тип объекта `tag` и ref под `refs/tags/frozen/contracts/NNN/` с тем же objectname.

Мои мутанты мира (`mut_world.py`, клоны `mut-*`; это другие оси, чем commit-pin и lightweight у adversary), S:
```
frozen-obychnyj (p05: frozen RE «обычный», OBJECT по-прежнему «рисковый"):
  PROBA p05-int-porjadok-adv-rev KRASNO: GOT p05 fail want=block:ADVERSARIJ_DO_REVJUERA got=pass unchanged=true
  PROB VSEGO 45 KRASNYH 1   rc=1
object-obychnyj (p05: OBJECT «обычный», frozen RE «рисковый»):
  PROB VSEGO 45 KRASNYH 0   rc=0
decoy-tag (pin = настоящий annotated tag-object, но не под refs/tags/frozen/contracts/141/):
  PROBA p05 … p10×6 … p16×4 KRASNO: … got=блок:ОТКАЗ: KLASS_RISKA_NET: предмет 141: закреплённый frozen недоступен
  PROB VSEGO 45 KRASNYH 11   rc=1
```
Класс в отремонтированном мире действительно берётся из закреплённого frozen владельца, а не из дерева OBJECT (инв. 6). Подделку pin дверь не принимает. Ремонт исправил предпосылку мира, а проверку двери не ослабил.

**157 остаётся точным.**
- `case()` сравнивает событие двери побайтно (`expected_event = json.dumps(…)`). Для `ISOLATION_BATCHES` оракул литеральный, по позициям (`ISOLATION_EXPECTED`), а не выводится из нормализации хука.
- Схема (pre/post-199) выбирается по объявлению типа `ISOLATED_TYPE in source`, а не по выражению нормализации. Сломанная нормализация оракул не меняет.

Мои позиционные мутанты (`mut157.py`, это не стабы из `ISOLATION_MUTATIONS`):
```
mirror (isolated из зеркальной позиции):         KLETKI mirror 59 KRASNYH 14   rc=1
shift-next (isolated из следующего item):        KLETKI shift-next 59 KRASNYH 19   rc=1
judge-forced-true (судья всегда isolated:true):  KLETKI judge-forced-true 59 KRASNYH 16   rc=1
```
Позиции 1–3 и роль различаются. Позиция ≥4 не покрыта (С-1).

**Пустой генератор** (наблюдение adversary). Мутант `probe-empty`: bare `KLETKI subject 0 KRASNYH 0` rc 0, `--stabs` → `STAB_ZHIV: blind-root: expected [...] got []` rc 1. CI-шаг `registry/ci-steps.tsv:287` гоняет оба режима, так что в CI порча ловится.

## 4. Красное предъявлено

У каждого нового барьера дельты есть красный прогон:
- **мир S:** мои мутанты `frozen-obychnyj` (1 красная) и `decoy-tag` (11), у adversary — `commit-pin`/`lightweight` (11);
- **позиционные клетки 157:** стабы `--stabs` (46 пойманы) и мои `mirror`/`shift-next`/`judge-forced-true`;
- **хук:** стабы `isolated-always-false`/`isolated-truthy` в 157 и normalizacija truthy/constant в S (RAZLICHENO 9/5).

## 5. Атомарность

- 0c6416bd — один путь, одна задача (пронос isolated).
- b462e955 (миграция оракула 157) и dd60a5a3 (позиционные клетки) — две отдельные задачи 157.
- fa61f020 — ремонт мира и его запись в осях и листе одного предмета.
- 7c4bd7a0 — чистое слияние.

Связок нет. В subject-строке каждого коммита назван номер предмета.

## 6. Норма не тронута

`roles/`, `AGENTS.md`, `contracts/`, `registry/`, `.github/` в дельте и в `origin/main...OBJECT` отсутствуют (п.1).

## Прежние советы (`.review/2026-11-20-120.md`)

- **С-1 `no-runtime-silent`.** Открыт, перенесён как С-3. `scripts/pre_judge.sh` в дельте не менялся.
- **С-2 `isolated`/порядок ленда.** Закрыт: хук 199 побайтно в этом же PR (0c6416bd), S 45/0 на поставленном хуке, p15–p20 судят NE_IZOLIROVAN и START-факт.
- **С-3 пустой `--repo`.** Открыт, перенесён как С-4.
- **С-4 устаревшие фразы листа `:124-126`.** Переписаны (`:124-128`: NOT_RUN отнесён к legacy-дельте, проверка в runtime-клоне названа). Остаток «Production не изменялась.» — С-2.

## Паразитная сложность (050) — по артефактам дельты

- **`mir_frozen_kontrakt` (`stancija_odin_agent_140.sh:142-152`).**
  - (1) Инв. 6 (риск из закреплённого frozen владельца). Миры p05/p10/p16 без него не доходят до своих причин.
  - (2) Состояние — только внутри `$W` синтетического мира: тег и pin-коммит, видимые в git мира.
  - (3) Связан с форматом реестра, который дверь читает (`zamok_predmeta.sh:386`). Число файлов, меняемых вместе, не выросло: формат и раньше жил в двери и реестре.
  - (4) 3 аргумента, работа нетривиальна (коммит, тег, pin).
  - (5) Потребители — p05/p10/p16 и строка листа S-station.
  - ESSENTIAL: более простая форма (`mir_kontrakt` без тега) даёт KLASS_RISKA_NET, это показано и `decoy-tag`.
- **157: `ISOLATION_MUTATIONS`, `ISOLATION_BATCHES`, `OMITTED`, `STRICT_BATCH_CELLS`, `carries_isolated`, `isolation_targets`, новые параметры `case(isolated=, carries_isolated=)`.**
  - (1) Контракт 199, инв. 1 (пронос isolated) и точность события 157.
  - (2) Состояния нет. Выбор схемы зависит от текста источника (`ISOLATED_TYPE in source`), это неявно, но fail-loud: переформатированный тип даёт рассогласование байтов.
  - (3) При правке хука 199 меняются хук и `ISOLATED_SEAM`/`ISOLATED_TYPE` — две строки-якоря.
  - (4) Интерфейс CLI не вырос (те же `--stabs`/`--mutant`).
  - (5) Потребитель — CI `:287`. Это семья case-фикстур, считается одним артефактом.
  - ESSENTIAL. Таблица ожиданий стабов (`isolation_targets`) длинная, но это точные множества, а не логика.
- **Поле `isolated` в `TaskItem` хука.**
  - (1) Инв. 7 v5 / 199 инв. 1.
  - (2) Поле в событии двери.
  - (5) S p15–p20, 157 `project-isolated-*`.
  - ESSENTIAL.
- **Дверь листа `S-station` (`sdacha_140_v5.md:68`).**
  - (1) Приёмка 7.
  - (5) Потребители — `check_sdacha --run` и `pre_critic`.
  - ESSENTIAL по свойству. Место запуска расходится с оговоркой приёмки 7 — С-5.

## СВЕРКА-СТАНДАРТОВ

н/п. `AGENTS.md` не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md`, этих файлов в дереве нет (как в прежнем вердикте; дельта `AGENTS.md`/`docs/` не трогает).

## СВЕРКА-АРХИТЕКТУРЫ

н/п по 188: в дереве нет `bindings.json` и `tooling/checks/cli.js`.

- Размещение: хук в `.omp/extensions/`, миры в фикстурах своих предметов.
- Зависимости: новых нет.
- Писатели: учёт по-прежнему пишет только дверь, хук лишь доносит поле.
- Операции: новых форм argv нет.
- Долг не растёт, диффа модели нет. L2/L3 нет.

## ОСТАТОК (контракт 192)

В `НЕ ЗАЩИЩАЕТ` (`contracts/140:199-210`) обозначений К-NN нет. Строки с ловцом reviewer называю по месту:

- **ОСТАТОК: :207 пронос isolated / порядок интеграции 199 — не укусил.** Источник поля — `o.isolated === true` из item wire-объекта (`spawn-guard.ts:202`), не из текста задания. Хук ложится тем же поездом, что и дверь (0c6416bd). Изоляция живого omp-спавна не доказана (остаток, «Не проверено»).
- **ОСТАТОК: :209 не sandbox — не укусил.** Дельта путей вне `$W`/TMPDIR не открывает.
- **ОСТАТОК: :210 подпись Git metadata — не укусил.** Синтетические миры подписывают `b <b@t>`, это вне двери. Дверь не менялась.
- **ОСТАТОК: :204 злонамеренный оркестратор — не укусил.** Merge 7c4bd7a0 чистый.

## Не проверено

- Живой omp и реальная изоляция спавна, полный CI (взят только статус run 44800075977), полный `verify_antiplacebo`.
- Произвольные batch больше трёх с isolated:true (С-1).
- Живые станционные теги `frozen_predmeta` на станции. В этой копии `frozen/contracts/140/5` указывает на коммит, а не на tag-object (`git cat-file -t frozen/contracts/140/5` → `commit`), хотя сам tag-object 42f063a6fa в копии есть (`cat-file -t` → `tag`).
- Перенос остальной ветки 199 (`zamok_predmeta.sh`, `privjazka_sdachi.sh`, роли) поверх новой двери — вне этого поезда, по сообщению 0c6416bd не переносится.

Исправленные ошибки своих команд (это не отказы механизма):
- первый bash без `cwd` остановлен Н-85, повторён с абсолютным cwd;
- три первых async-прогона не получили `TMPDIR`, потому что `export` из другого вызова не наследуется (`/run_acc.sh: No such file`). Перезапущены с явным `export TMPDIR=…`;
- прогон мутантов с `>`-перенаправлением отклонён политикой, переведён на `| tee`;
- ссылку на строку `mktemp` в файле находок исправил с `:47-48` на `:48-49`.
