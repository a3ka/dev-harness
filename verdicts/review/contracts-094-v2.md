FAIL — Р2-1 (регресс CI: land_agent/check_charter/063 красны, зелёны на main), Р2-2 (журнал candidates.tsv без проводки judge_gate/check_ci_gate — остаток Б-4), Р2-3 (И-7: production-allowlist зашит `branches="main"`), Р2-4 (check_zones rc=1: e3541682/618717dc harness/policy). Область правки — FAIL (Р2-4); сырой вывод — есть; подгонки проверок — нет; решение арбитража 094-carrier-krug6 п.5–6 architect исполнил буквально.

# Review 094, круг 2

**Находки (reslop):** `.review/2026-10-10-02.md` — блокирующих 4 (Р2-1…Р2-4), неблокирующих 5 (Н2-1…Н2-5).

**Предмет.** Контракт 094, `frozen/contracts/094/2` (= e29e4260; `git diff --stat frozen/contracts/094/2 HEAD -- contracts/094-*.md` на сборке пуст; sha256 текста `f72c9e31…`). Субъект `origin/wip/094/implementer` @ `e289d7a5167c2bd6beffd00ece1125695d928bd4`, батарея `origin/wip/094/architect` @ `07dcebc3220e0d49fc395886c5ad488c713c00d0`. Прошлый круг: `verdicts/review/contracts-094-v1.md` (FAIL Б-1…Б-6).

**Сборка.** Одноразовый клон `/tmp/dev-harness-verify/rev094v2/repo` (`git clone --no-local` основного репо): `assemble` = origin/main `79581091` + `merge --no-ff e289d7a5` + `merge --no-ff 07dcebc3` → `68c0a74f`, конфликтов нет; `git diff e289d7a5 HEAD -- scripts/` и `git diff 07dcebc3 HEAD -- fixtures/accept_publish_094 fixtures/_krasnye_094.sh` пусты. Базовая линия — worktree на origin/main `79581091`.

МОДЕЛЬ: anthropic/claude-opus-5-5

## Сырой вывод (мои прогоны, сборка 68c0a74f, если не сказано иное)

```text
bash fixtures/_krasnye_094.sh                      стабы s1…s19 ПОЙМАН, 18 клеток rc=0, ИТОГ 094: rc=0, rc=0
bash fixtures/_krasnye_094.sh --model              то же, ИТОГ 094: rc=0, rc=0
git ls-tree --name-only HEAD fixtures/accept_publish_094/ | grep -c '/red_.*\.sh$'   18
bash fixtures/_krasnye_094.sh ../main-wt           (корень без субъекта) 18 клеток rc=1, battery_stubs rc=0,
                                                   «красная: предмет отсутствует», ИТОГ 094: rc=1
git checkout e6009c5d -- scripts/accept_publish.sh && bash fixtures/_krasnye_094.sh
   КРАСНО: nositelja: переход носителя без санкции опубликован (rc=0, вывод: PUBLISHED target=main merge=64576183…)
   — red_perehod_nositelja_bez_sankcii.sh: rc=1      (единственная красная из 18; стабы все ПОЙМАН)
   ИТОГ 094: rc=1                                    rc=1
git checkout e289d7a5 -- scripts/accept_publish.sh; git diff --quiet HEAD → CLEAN
bash scripts/check_zones.sh                        17× FAIL (9× e3541682, 8× 618717dc harness/policy), rc=1
   на origin/main 79581091                         rc=0
   на кончике e289d7a5 отдельно                    те же 18 FAIL + FAIL грамматики ЗОНА 055, rc=1
npm run check:antiplacebo -- --scope land_agent    9/9 FAIL «нет положительного контроля», rc=1   (main: 9 предъявлено, rc=0)
npm run check:antiplacebo -- --scope check_charter барьеров 1 · фикстур 13 · предъявлено 8 · расхождений 5, rc=1   (main: 13, rc=0)
bash fixtures/check_judge_gate/krasnye_063.sh      FAIL к8 «ленд зелёного входа rc 0: rc 1», FAIL к9; итог 063: rc=1   (main: rc=0)
bash fixtures/_krasnye_087.sh                      КРАСНОЕ 087: нет scripts/ci_klass.sh …, rc=1   (main: то же, rc=1)
bash scripts/check_consumers.sh . contracts/094-…  rc=0
bash scripts/verify_ci_parity.sh .                 расхождений: 0, rc=0
git grep -nE 'update-ref .?refs/heads' -- scripts/ accept_publish.sh:337, accept_task_commit.sh:242 (wip/*, Н-6 круга 1)
bash scripts/accept_publish.sh prepare --repo . --task wip/094/implementer --base <main> --candidate e289d7a5
                                                   f3eb7044…, rc=0  (Б-4 «нет harness/policy на base» снят)
git grep -nl 'candidates\.tsv' -- scripts/         (пусто), rc=1
git diff --stat origin/main HEAD -- scripts/judge_gate.sh scripts/check_ci_gate.sh scripts/gitw_preflight_071.sh scripts/done_contract.sh
                                                   (пусто)
grep -cF '<фраза добавлен…>' / '<фраза удалён…>'   accept_publish.sh 1/1, model/dover.sh 1/1
```

## Семь проверок ревьюера

1. **Область правки — FAIL (Р2-4).** Нетто-дифф сборки против main — 20 путей; все в ЗОНА/ПЕРЕСЕЧЕНИЕ 094, кроме генерата `.omp/agents/orchestrator.md` (Н2-5). Пути Б-6 круга 1 ушли из диффа (`verify_ci_parity.sh`, `config/ci_parity_exceptions.txt`, `verdicts/critic/contracts-095-v2.md` — в `--stat` нет). Но барьер зон судит коммиты: `e3541682`/`618717dc` (`harness/policy`, вне ЗОН 094) дают `check_zones` rc=1 — на main rc=0. Диапазоны: architect `git log origin/main..07dcebc3 -- fixtures/accept_publish_094/ fixtures/_krasnye_094.sh contracts/094-*.md` → a20547bc, 484e8c12, 41f80d3b, 07dcebc3; implementer non-merge — 16 коммитов, все `implementer|implementer`; architect — 7, все `architect|architect`.
2. **Сырой вывод — есть** (выше; мои прогоны, не пересказ).
3. **Проверку под код не переписывали — подтверждено.** `git log --no-merges origin/main..HEAD -- fixtures/` → только architect (a20547bc, 484e8c12, 07dcebc3); implementer фикстур не трогал. Дифф раннера к истории: только счётчик 14→18 и комментарий (a20547bc/484e8c12: 14→17; 07dcebc3: 17→18). Новая клетка `red_perehod_nositelja_bez_sankcii.sh` (author/committer `architect`) честна: оракул `BASE` снят до вызова субъекта, мир проверен с обеих сторон (registry есть в кандидате, нет на base), фраза — литерал `grep -F`, отказ принимается на `prepare` ИЛИ `publish` (не подогнана под место проверки в e289d7a5), полный честный журнал по toy-политике на publish-ветке, `main == base` после отказа. Фраза совпадает с субъектом дословно — так ПРЕДПИСАЛ арбитраж п.5(б) («модель — источник фраз, принимая фразы субъекта дословно»), не подгонка.
4. **Красное предъявлено.** Новая клетка красна на e6009c5d (единственная из 18, rc=1) и против стаба s19 (стаб-пак «s19 ПОЙМАН клеткой red_perehod_nositelja_bez_sankcii.sh»); зелёная сторона — `--model` rc=0. До реализации — все 18 красны, стаб-пак rc=0 (Приёмка 1).
5. **Атомарность — допустимо.** 07dcebc3 — одна задача (арбитраж п.5), ссылка на предмет; implementer 59184a7f несёт Б-2+Б-4+CI-правку одним коммитом — связка, но не новых задач (замечание, не отказ).
6. **Норма не тронута молча — да.** Текст контракта на сборке = `frozen/contracts/094/2` (дифф пуст); 07dcebc3 текст не правил. Б-2 круга 1 (016 И-7/И-9) закрыт в двери (`accept_publish.sh:34-54` `_t94_identity_check` через `lib_zones.sh`), `verify_ci_parity.sh` вне диффа.
7. **Заявленное = сделанное — FAIL.** «18 клеток, 19 стабов» — подтверждено `ls-tree`/выводом. «check_zones зона чиста» — опровергнуто (Р2-4). «Б-4 закрыт» — закрыт только carrier (Р2-2, Р2-3). «Б-1/Б-3 закрыты тонкими обёртками» — обёртки чисты, но вечно-красны и рушат три чужих барьера (Р2-1); сам 59184a7f это признаёт («фикстуры краснеют на положительном контроле … ожидаемая цена миграции»).

## Исполнение арбитража 094-carrier-krug6 (не пересматриваю, сверяю п.5–6)

| Пункт | Требование | Наблюдение | Итог |
|---|---|---|---|
| 5(а) | клетка: toy-база, кандидат добавляет непустой `registry/ci-steps.tsv` (step-строка), честный verdict+check, без `policy`, именованный отказ до движения refs, main==base, оракул до вызова | `red_perehod_nositelja_bez_sankcii.sh` — всё перечисленное, строки 19-55 | исполнено |
| 5(б) | ветка модели: симметричное чтение base/candidate, фразы субъекта дословно | `model/dover.sh` t94-m19a…d, `grep -cF` обеих фраз = 1 в модели и в субъекте | исполнено |
| 5(в) | стаб s19 по якорю, ловится клеткой (а), привязка в коде стаб-пака | `zapest s19 red_perehod_nositelja_bez_sankcii.sh` порча m19c+m19d; ПОЙМАН | исполнено |
| 5 | текст контракта не правится | дифф с `frozen/contracts/094/2` пуст | исполнено |
| 6.1 | сборка: rc 0, 18 клеток, 19 стабов | rc=0, 18, s1…s19 | ✓ |
| 6.2 | `--model` rc 0 | rc=0 | ✓ |
| 6.3 | подмена e6009c5d → rc 1, красна ИМЕННО новая клетка | rc=1, красна только `red_perehod_nositelja_bez_sankcii.sh` | ✓ |

Заметка арбитража п.8 (production-positive клеток нет) — подтверждается Р2-3: зашитый allowlist production-ветки батарея не видит.

## Сверка обязательств (семантика)

| Обязательство | Фрагмент результата | Наблюдение |
|---|---|---|
| Решение 6; §Зоны «с сохранением зелёного CI»; Приёмка 6 (063) | `land_agent.sh` publish с пустым `--journal`; 59184a7f | land_agent 9/9, check_charter 5/13, 063 к8/к9 красны; на main зелёны (Р2-1) |
| Решение 3; Решение 6; ПЕРЕСЕЧЕНИЕ judge_gate/check_ci_gate | `registry/candidates.tsv` шапка «Потребители — …» | ни один названный скрипт не изменён и не ссылается на файл (Р2-2) |
| И-7; ПЕРЕСЕЧЕНИЕ profile_resolver (targetBranches) | `accept_publish.sh:133-134` `repoId="dev-harness"`, `branches="main"` | ключ схемы без читателя, allowlist зашит (Р2-3) |
| §Зоны (check_zones) | e3541682, 618717dc | rc=1 (Р2-4) |
| Приёмка 5 | `ls scripts/land_agent.sh scripts/land_project.sh` | оба есть; Решение 6 допускает обёртку — противоречие текста (Н2-1) |
| И-6б (carrier) | `accept_publish.sh:118-127` | симметрия есть, батарея её держит (арбитраж исполнен) |

## ПРОВОДКА (038)

`guard=fixtures/_krasnye_094.sh` — существует, подключён шагом `check:accept-publish-094-family-selftest` (`registry/ci-steps.tsv:78`, ключ в include-блоке `ci.yml:116`), барьер именно этого предмета (раннер семьи `fixtures/accept_publish_094/`). Строка ПРОВОДКА-ЭНФОРСМЕНТ обоснована: норма — отказы двери, поведенческий хвост — существующим каналом `roles/orchestrator.md`. Подключение тем же лендом, что и субъект, — не «преждевременно» (субъект в том же дереве).

## Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `red_perehod_nositelja_bez_sankcii.sh` | И-6б carrier-переход, арбитраж п.5(а) | toy-мир в /tmp, явно, вычистка trap | клетка+модель+стаб+раннер — 4, как у любой клетки семьи | интерфейс 0 аргументов, rc 0/1/2 | раннер 094, CI-шаг | ESSENTIAL |
| ветка модели t94-m19a…d | п.5(б), источник фраз | нет | субъект+модель — 2 (фразы) | 4 строки логики | `--model`, стаб s19 | ESSENTIAL |
| стаб s19 | Н-39, п.5(в) | нет | стаб-пак+модель | одна строка `zapest` | стаб-пак | ESSENTIAL |
| раннер: счётчик 18 | Приёмка «замер» | нет | раннер+текст (текст не правится, Н2-2) | — | CI-шаг | ESSENTIAL |
| `scripts/accept_publish.sh` (341 стр.) | Решение 1 — одна дверь | журнал/ref — явно в аргументах | — | 3 глагола, флаги по модели | батарея, обёртки | ESSENTIAL |
| `_t94_identity_check` | Решение 5 / 016 И-7, И-9 | читает реестр зон через `lib_zones.sh` (не дубль) | 1 | без новых флагов | prepare/publish | ESSENTIAL |
| production-ветка политики (`:128-150`) | Предмет 2.1, И-6 | — | дверь + profile_resolver (ключ не читается) | зашитые repoId/branches | нет клетки | дефект Р2-3, не сложность |
| `land_agent.sh`/`land_project.sh` | Решение 6 (обёртка) | временный пустой журнал (mktemp) — неявная константа отказа | обёртки + 3 чужие семьи | интерфейс прежний, работа = всегда отказ | фикстуры 016/022/063/065 — красны | дефект Р2-1 |
| `registry/candidates.tsv` | Решение 3 | файл состояния | — | — | потребителя в дереве нет | ACCIDENTAL до проводки (Н2-4, закрывается Р2-2) |
| `targetBranches` в `profile_resolver.sh` | ПЕРЕСЕЧЕНИЕ 054…059 | ключ схемы | схема + дверь | — | читателя нет | дефект Р2-3 |

## Итог

Батарея и её арбитражное усиление — в порядке: клетка честна, авторство architect, подгонки нет, регресс e289d7a5→e6009c5d ловится ровно новой клеткой. Субъект закрыл carrier (И-6б), identity (Б-2) и обход журнала обёртками (Б-1), но ленд сломает CI в трёх местах, которые зелёны на main (Р2-1), оставил журнал без производственных писателей (Р2-2), зашил allowlist в production-ветке (Р2-3) и оставил в истории два коммита вне зоны, на которых `check_zones` красен (Р2-4). Маршрут — норма 050: Р2-1 — сначала architect/владелец (судьба чужих семей и обёрток), затем implementer; Р2-2…Р2-4 — implementer (для Р2-4 — переписать историю ветки без пары e3541682/618717dc либо законная строка СПАСЕНО по грамматике `check_zones`). Батарея на этот круг изменений не требует.

Ревьюер: reviewer.
